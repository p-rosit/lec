#include <assert.h>
#include <stdio.h>
#include <ctype.h>
#include <stdbool.h>
#include <lec_lexer.h>
#include <lec_internal.h>

enum LecError lec_internal_lexer_next_char(struct LecLexer *lexer, struct LecToken *token);
enum LecError lec_internal_lexer_escape(struct LecLexer *lexer, struct LecToken *token, char c);

enum LecError lec_lexer_init(struct LecLexer *lexer, struct GciInterfaceReader reader, struct LecArena arena) {
    if (lexer == NULL) { return LEC_ERROR_NULL; }
    
    lexer->state = LEC_STATE_START;
    lexer->prev_arena_start = 0;
    lexer->byte_position = 0;
    lexer->reader = reader;
    lexer->arena = arena;
    lexer->buffer_char = EOF;

    return LEC_ERROR_OK;
}

enum LecError lec_lexer_next(struct LecLexer *lexer, struct LecToken *token) {
    assert(lexer != NULL);
    if (token == NULL) { return LEC_ERROR_NULL; }

    token->type = LEC_TOKEN_TYPE_UNKNOWN;
    token->arena_start = lexer->arena.position;
    token->byte_start = lexer->byte_position;
    token->length = 0;

    if (lexer->state != LEC_STATE_START) {
        token->arena_start = lexer->prev_arena_start;
        token->byte_start = lexer->byte_position - (lexer->arena.position - lexer->prev_arena_start);
    } else {
        lexer->prev_arena_start = lexer->arena.position;

        char c = lexer->buffer_char == EOF ? ' ' : (char) lexer->buffer_char;
        while (isspace((unsigned char) c)) {
            size_t length = gci_reader_read(lexer->reader, &c, 1);
            if (length != 1) { return LEC_ERROR_READER; }

            lexer->buffer_char = c;
            lexer->byte_position += 1;
        }

        token->byte_start = lexer->byte_position - 1;
    }

    while (lexer->state != LEC_STATE_END) {
        enum LecError err = lec_internal_lexer_next_char(lexer, token);
        if (err) { return err; }
    }

    lexer->state = LEC_STATE_START;
    token->length = lexer->arena.position - token->arena_start;
    return LEC_ERROR_OK;
}

enum LecError lec_internal_lexer_next_char(struct LecLexer *lexer, struct LecToken *token) {
    assert(lexer != NULL);
    assert(token != NULL);

    char c;
    if (lexer->buffer_char == EOF) {
        size_t length = gci_reader_read(lexer->reader, &c, 1);
        if (length != 1) { return LEC_ERROR_READER; }
        lexer->byte_position += 1;
    } else {
        c = (char) lexer->buffer_char;
        lexer->buffer_char = EOF;
    }

    bool skip_char = false;
    switch (lexer->state) {
        case (LEC_STATE_START):
            switch (c) {
                case '+':
                    lexer->state = LEC_STATE_END;
                    token->type = LEC_TOKEN_TYPE_PLUS;
                    break;
                case '-':
                    lexer->state = LEC_STATE_END;
                    token->type = LEC_TOKEN_TYPE_MINUS;
                    break;
                case '*':
                    lexer->state = LEC_STATE_END;
                    token->type = LEC_TOKEN_TYPE_MUL;
                    break;
                case '/':
                    lexer->state = LEC_STATE_COMMENT_START;
                    break;
                case '=':
                    lexer->state = LEC_STATE_ASSIGN;
                    break;
                case '(':
                    lexer->state = LEC_STATE_END;
                    token->type = LEC_TOKEN_TYPE_L_PAREN;
                    break;
                case ')':
                    lexer->state = LEC_STATE_END;
                    token->type = LEC_TOKEN_TYPE_R_PAREN;
                    break;
                case '[':
                    lexer->state = LEC_STATE_END;
                    token->type = LEC_TOKEN_TYPE_L_BRACK;
                    break;
                case ']':
                    lexer->state = LEC_STATE_END;
                    token->type = LEC_TOKEN_TYPE_R_BRACK;
                    break;
                case '{':
                    lexer->state = LEC_STATE_END;
                    token->type = LEC_TOKEN_TYPE_L_BRACE;
                    break;
                case '}':
                    lexer->state = LEC_STATE_END;
                    token->type = LEC_TOKEN_TYPE_R_BRACE;
                    break;
                case '<':
                    lexer->state = LEC_STATE_LESS;
                    break;
                case '>':
                    lexer->state = LEC_STATE_GREAT;
                    break;
                case '.':
                    lexer->state = LEC_STATE_END;
                    token->type = LEC_TOKEN_TYPE_DOT;
                    break;
                case ',':
                    lexer->state = LEC_STATE_END;
                    token->type = LEC_TOKEN_TYPE_COMMA;
                    break;
                case '?':
                    lexer->state = LEC_STATE_END;
                    token->type = LEC_TOKEN_TYPE_QUESTION;
                    break;
                case ':':
                    lexer->state = LEC_STATE_END;
                    token->type = LEC_TOKEN_TYPE_COLON;
                    break;
                case ';':
                    lexer->state = LEC_STATE_END;
                    token->type = LEC_TOKEN_TYPE_SEMICOLON;
                    break;
                case '"':
                    skip_char = true;
                    lexer->state = LEC_STATE_STRING;
                    token->byte_start = lexer->byte_position;
                    break;
                case '\'':
                    skip_char = true;
                    lexer->state = LEC_STATE_CHAR;
                    token->byte_start = lexer->byte_position;
                    break;
                default:
                    assert(0); // TODO: now what?
            }
            break;
        case (LEC_STATE_ASSIGN):
            if (c == '=') {
                lexer->state = LEC_STATE_EQUAL;
            } else {
                lexer->buffer_char = c;
                lexer->state = LEC_STATE_END;
                token->type = LEC_TOKEN_TYPE_ASSIGN;
            }
            break;
        case (LEC_STATE_EQUAL):
            if (c == '=') {
                return LEC_ERROR_THREEQUAL;
            } else {
                lexer->buffer_char = c;
                lexer->state = LEC_STATE_END;
                token->type = LEC_TOKEN_TYPE_EQUAL;
            }
            break;
        case (LEC_STATE_LESS):
            if (c == '=') {
                lexer->state = LEC_STATE_END;
                token->type = LEC_TOKEN_TYPE_LEQ;
            } else {
                lexer->buffer_char = c;
                lexer->state = LEC_STATE_END;
                token->type = LEC_TOKEN_TYPE_L_ANGLE;
            }
            break;
        case (LEC_STATE_GREAT):
            if (c == '=') {
                lexer->state = LEC_STATE_END;
                token->type = LEC_TOKEN_TYPE_GEQ;
            } else {
                lexer->buffer_char = c;
                lexer->state = LEC_STATE_END;
                token->type = LEC_TOKEN_TYPE_R_ANGLE;
            }
            break;
        case (LEC_STATE_COMMENT_START):
            if (c == '/') {
                lexer->state = LEC_STATE_COMMENT;
                token->type = LEC_TOKEN_TYPE_COMMENT;
            } else {
                lexer->buffer_char = c;
                lexer->state = LEC_STATE_END;
                token->type = LEC_TOKEN_TYPE_DIV;
            }
            break;
        case (LEC_STATE_COMMENT):
            if (c == '\n') {
                lexer->state = LEC_STATE_END;
                token->type = LEC_TOKEN_TYPE_COMMENT;
            }
            break;
        case (LEC_STATE_CHAR):
            if (c == '\\') {
                skip_char = true;
                lexer->state = LEC_STATE_CHAR_ESCAPED;
            }
            if (c == '\'') {
                skip_char = true;
                lexer->state = LEC_STATE_END;
                token->type = LEC_TOKEN_TYPE_CHAR;
            }
            break;
        case (LEC_STATE_STRING):
            if (c == '\\') {
                skip_char = true;
                lexer->state = LEC_STATE_STRING_ESCAPED;
            }
            if (c == '"') {
                skip_char = true;
                lexer->state = LEC_STATE_END;
                token->type = LEC_TOKEN_TYPE_STRING;
            }
            break;
        case (LEC_STATE_CHAR_ESCAPED):
        case (LEC_STATE_CHAR_ESCAPED_X):
        case (LEC_STATE_CHAR_ESCAPED_U):
        case (LEC_STATE_STRING_ESCAPED):
        case (LEC_STATE_STRING_ESCAPED_X):
        case (LEC_STATE_STRING_ESCAPED_U): {
            skip_char = true;
            enum LecError err = lec_internal_lexer_escape(lexer, token, c);
            if (err) { return err; }
            break;
        }
        case (LEC_STATE_END):
        case (LEC_STATE_MAX):
            assert(0);
    }

    bool allow_whitespace = (
        lexer->state == LEC_STATE_COMMENT
        || lexer->state == LEC_STATE_CHAR
        || lexer->state == LEC_STATE_CHAR_ESCAPED
        || lexer->state == LEC_STATE_STRING
        || lexer->state == LEC_STATE_STRING_ESCAPED
    );
    if (!allow_whitespace && isspace((unsigned char) c)) {
        lexer->state = LEC_STATE_END;
        return LEC_ERROR_OK;
    }

    if (!skip_char) {
        enum LecError err = lec_arena_add(&lexer->arena, c);
        if (err) { return err; }
    }

    return LEC_ERROR_OK;
}

enum LecError lec_internal_lexer_escape(struct LecLexer *lexer, struct LecToken *token, char c) {
    assert(lexer != NULL);
    assert(token != NULL);

    assert(
        lexer->state == LEC_STATE_CHAR_ESCAPED
        || lexer->state == LEC_STATE_CHAR_ESCAPED_X
        || lexer->state == LEC_STATE_CHAR_ESCAPED_U
        || lexer->state == LEC_STATE_STRING_ESCAPED
        || lexer->state == LEC_STATE_STRING_ESCAPED_X
        || lexer->state == LEC_STATE_STRING_ESCAPED_U
    );

    if (lexer->state == LEC_STATE_CHAR_ESCAPED || lexer->state == LEC_STATE_STRING_ESCAPED) {
        if (c == 't') {
            c = '\t';
        }

        enum LecError err = lec_arena_add(&lexer->arena, c);
        if (err) { return err; }

        if (lexer->state == LEC_STATE_CHAR_ESCAPED) {
            lexer->state = LEC_STATE_CHAR;
        } else if (lexer->state == LEC_STATE_STRING_ESCAPED) {
            lexer->state = LEC_STATE_STRING;
        } else {
            assert(false);
        }
    } else if (lexer->state == LEC_STATE_CHAR_ESCAPED_X || lexer->state == LEC_STATE_STRING_ESCAPED_X) {
        assert(false);
    } else if (lexer->state == LEC_STATE_CHAR_ESCAPED_U || lexer->state == LEC_STATE_STRING_ESCAPED_U) {
        assert(false);
    } else {
        assert(false);
    }

    return LEC_ERROR_OK;
}
