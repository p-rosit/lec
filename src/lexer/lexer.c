#include <assert.h>
#include <stdio.h>
#include <ctype.h>
#include <stdbool.h>
#include <lec_lexer.h>
#include <lec_internal.h>

enum LecError lec_internal_lexer_next_char(struct LecLexer *lexer, struct LecToken *token);
enum LecError lec_internal_lexer_start(struct LecLexer *lexer, struct LecToken *token, char c);
enum LecError lec_internal_lexer_multi_char(struct LecLexer *lexer, struct LecToken *token, char c);
enum LecError lec_internal_lexer_chars(struct LecLexer *lexer, struct LecToken *token, char c);
enum LecError lec_internal_lexer_number(struct LecLexer *lexer, struct LecToken *token, char c);
enum LecError lec_internal_lexer_comment(struct LecLexer *lexer, struct LecToken *token, char c);
enum LecError lec_internal_lexer_eof(struct LecLexer *lexer, struct LecToken *token);

enum LecError lec_lexer_init(struct LecLexer *lexer, struct GciInterfaceReader reader, struct LecArena arena) {
    if (lexer == NULL) { return LEC_ERROR_NULL; }
    
    lexer->state = LEC_STATE_START;
    lexer->sub_state.char_state = 0; // invalid value
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
            if (length != 1 && gci_reader_eof(lexer->reader)) {
                return lec_internal_lexer_eof(lexer, token);
            } else if (length != 1) {
                return LEC_ERROR_READER;
            }

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
        if (length != 1 && gci_reader_eof(lexer->reader)) {
            return lec_internal_lexer_eof(lexer, token);
        } else if (length != 1) {
            return LEC_ERROR_READER;
        }
        lexer->byte_position += 1;
    } else {
        c = (char) lexer->buffer_char;
        lexer->buffer_char = EOF;
    }

    switch (lexer->state) {
        case (LEC_STATE_START): {
            enum LecError err = lec_internal_lexer_start(lexer, token, c);
            if (err) { return err; }
            break;
        }
        case (LEC_STATE_MULTI_CHAR): {
            enum LecError err = lec_internal_lexer_multi_char(lexer, token, c);
            if (err) { return err; }
            break;
        }
        case (LEC_STATE_CHAR):
        case (LEC_STATE_STRING): {
            enum LecError err = lec_internal_lexer_chars(lexer, token, c);
            if (err) { return err; }
            break;
        }
        case (LEC_STATE_NUMBER): {
            enum LecError err = lec_internal_lexer_number(lexer, token, c);
            if (err) { return err; }
            break;
        }
        case (LEC_STATE_COMMENT): {
            enum LecError err = lec_internal_lexer_comment(lexer, token, c);
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
        || lexer->state == LEC_STATE_STRING
    );
    if (!allow_whitespace && isspace((unsigned char) c)) {
        lexer->state = LEC_STATE_END;
        return LEC_ERROR_OK;
    }

    return LEC_ERROR_OK;
}

enum LecError lec_internal_lexer_start(struct LecLexer *lexer, struct LecToken *token, char c) {
    bool skip_char = false;

    if (isalpha((unsigned char) c) || c == '_') {
        assert(false);
    } else if (isdigit((unsigned char) c)) {
        lexer->state = LEC_STATE_NUMBER;
        if (c == '0') {
            lexer->sub_state.number_state = LEC_STATE_NUMBER_ZERO;
        } else {
            lexer->sub_state.number_state = LEC_STATE_NUMBER_WHOLE;
        }
    } else {
        switch (c) {
            case '+':
                lexer->state = LEC_STATE_MULTI_CHAR;
                lexer->sub_state.multi_state = LEC_STATE_MULTI_CHAR_PLUS;
                break;
            case '-':
                lexer->state = LEC_STATE_MULTI_CHAR;
                lexer->sub_state.multi_state = LEC_STATE_MULTI_CHAR_MINUS;
                break;
            case '!':
                lexer->state = LEC_STATE_MULTI_CHAR;
                lexer->sub_state.multi_state = LEC_STATE_MULTI_CHAR_NOT;
                break;
            case '*':
                lexer->state = LEC_STATE_END;
                token->type = LEC_TOKEN_TYPE_MUL;
                break;
            case '/':
                lexer->state = LEC_STATE_MULTI_CHAR;
                lexer->sub_state.multi_state = LEC_STATE_MULTI_CHAR_COMMENT_START;
                break;
            case '=':
                lexer->state = LEC_STATE_MULTI_CHAR;
                lexer->sub_state.multi_state = LEC_STATE_MULTI_CHAR_ASSIGN;
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
                lexer->state = LEC_STATE_MULTI_CHAR;
                lexer->sub_state.multi_state = LEC_STATE_MULTI_CHAR_LESS;
                break;
            case '>':
                lexer->state = LEC_STATE_MULTI_CHAR;
                lexer->sub_state.multi_state = LEC_STATE_MULTI_CHAR_GREAT;
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
            case '#':
                lexer->state = LEC_STATE_END;
                token->type = LEC_TOKEN_TYPE_PREPROC;
                break;
            case '"':
                skip_char = true;
                lexer->state = LEC_STATE_STRING;
                lexer->sub_state.char_state = LEC_STATE_CHARS;
                token->byte_start = lexer->byte_position;
                break;
            case '\'':
                skip_char = true;
                lexer->state = LEC_STATE_CHAR;
                lexer->sub_state.char_state = LEC_STATE_CHARS;
                token->byte_start = lexer->byte_position;
                break;
            default:
                assert(false); // TODO: now what?
        }
    }
    
    if (!skip_char) {
        enum LecError err = lec_arena_add(&lexer->arena, c);
        if (err) { return err; }
    }
    return LEC_ERROR_OK;
}

enum LecError lec_internal_lexer_multi_char(struct LecLexer *lexer, struct LecToken *token, char c) {
    assert(lexer != NULL);
    assert(token != NULL);
    assert(lexer->state == LEC_STATE_MULTI_CHAR);

    assert(LEC_STATE_MULTI_CHAR_FIRST < lexer->sub_state.char_state);
    assert(lexer->sub_state.char_state < LEC_STATE_MULTI_CHAR_LAST);

    switch (lexer->sub_state.multi_state) {
        case (LEC_STATE_MULTI_CHAR_ASSIGN):
            if (c == '=') {
                token->type = LEC_TOKEN_TYPE_EQUAL;
            } else {
                token->type = LEC_TOKEN_TYPE_ASSIGN;
                lexer->buffer_char = c;
            }
            lexer->state = LEC_STATE_END;
            break;
        case (LEC_STATE_MULTI_CHAR_LESS):
            if (c == '=') {
                token->type = LEC_TOKEN_TYPE_LEQ;
            } else {
                token->type = LEC_TOKEN_TYPE_L_ANGLE;
                lexer->buffer_char = c;
            }
            lexer->state = LEC_STATE_END;
            break;
        case (LEC_STATE_MULTI_CHAR_GREAT):
            if (c == '=') {
                token->type = LEC_TOKEN_TYPE_GEQ;
            } else {
                token->type = LEC_TOKEN_TYPE_R_ANGLE;
                lexer->buffer_char = c;
            }
            lexer->state = LEC_STATE_END;
            break;
        case (LEC_STATE_MULTI_CHAR_PLUS):
            if (c == '+') {
                token->type = LEC_TOKEN_TYPE_INC;
            } else {
                token->type = LEC_TOKEN_TYPE_PLUS;
                lexer->buffer_char = c;
            }
            lexer->state = LEC_STATE_END;
            break;
        case (LEC_STATE_MULTI_CHAR_MINUS):
            if (c == '-') {
                token->type = LEC_TOKEN_TYPE_DEC;
            } else {
                token->type = LEC_TOKEN_TYPE_MINUS;
                lexer->buffer_char = c;
            }
            lexer->state = LEC_STATE_END;
            break;
        case (LEC_STATE_MULTI_CHAR_COMMENT_START):
            if (c == '/') {
                assert(lexer->arena.position > 0);
                lexer->arena.position -= 1;
                token->byte_start += 2;
                lexer->state = LEC_STATE_COMMENT;
                return LEC_ERROR_OK;
            } else {
                token->type = LEC_TOKEN_TYPE_DIV;
                lexer->state = LEC_STATE_END;
                lexer->buffer_char = c;
            }
            break;
        case (LEC_STATE_MULTI_CHAR_NOT):
            if (c == '=') {
                token->type = LEC_TOKEN_TYPE_NEQ;
            } else {
                token->type = LEC_TOKEN_TYPE_NOT;
                lexer->buffer_char = c;
            }
            lexer->state = LEC_STATE_END;
            break;
        case (LEC_STATE_MULTI_CHAR_FIRST):
        case (LEC_STATE_MULTI_CHAR_LAST):
            assert(false);
    }

    if (lexer->buffer_char == EOF) {
        enum LecError err = lec_arena_add(&lexer->arena, c);
        if (err) { return err; }
    }
    return LEC_ERROR_OK;
}

enum LecError lec_internal_lexer_chars(struct LecLexer *lexer, struct LecToken *token, char c) {
    assert(lexer != NULL);
    assert(token != NULL);
    assert(lexer->state == LEC_STATE_CHAR || lexer->state == LEC_STATE_STRING);

    assert(LEC_STATE_CHARS_FIRST < lexer->sub_state.char_state);
    assert(lexer->sub_state.char_state < LEC_STATE_CHARS_LAST);

    if (lexer->sub_state.char_state == LEC_STATE_CHARS) {
        if (lexer->state == LEC_STATE_CHAR && c == '\'') {
            token->type = LEC_TOKEN_TYPE_CHAR;
            lexer->state = LEC_STATE_END;
        } else if (lexer->state == LEC_STATE_STRING && c == '"') {
            token->type = LEC_TOKEN_TYPE_STRING;
            lexer->state = LEC_STATE_END;
        } else if (c == '\\') {
            lexer->sub_state.char_state = LEC_STATE_CHARS_ESCAPED;
        } else {
            enum LecError err = lec_arena_add(&lexer->arena, c);
            if (err) { return err; }
        }
    } else if (lexer->sub_state.char_state == LEC_STATE_CHARS_ESCAPED) {
        if (c == 't') {
            c = '\t';
        }

        enum LecError err = lec_arena_add(&lexer->arena, c);
        if (err) { return err; }

        lexer->sub_state.char_state = LEC_STATE_CHARS;
    } else if (lexer->sub_state.char_state == LEC_STATE_CHARS_ESCAPED_X) {
        assert(false);
    } else if (lexer->sub_state.char_state == LEC_STATE_CHARS_ESCAPED_U) {
        assert(false);
    } else {
        assert(false);
    }

    return LEC_ERROR_OK;
}

enum LecError lec_internal_lexer_number(struct LecLexer *lexer, struct LecToken *token, char c) {
    assert(lexer != NULL);
    assert(token != NULL);
    assert(lexer->state == LEC_STATE_NUMBER);

    assert(LEC_STATE_NUMBER_FIRST < lexer->sub_state.char_state);
    assert(lexer->sub_state.char_state < LEC_STATE_NUMBER_LAST);

    switch (c) {
        case (LEC_STATE_NUMBER_ZERO):
            if (c == '.') {
                lexer->sub_state.number_state = LEC_STATE_NUMBER_POINT;
            } else if (c == 'e' || c == 'E') {
                lexer->sub_state.number_state = LEC_STATE_NUMBER_E;
            } else if (c == 'b') {
                lexer->sub_state.number_state = LEC_STATE_NUMBER_BIN;
            } else if (c == 'x') {
                lexer->sub_state.number_state = LEC_STATE_NUMBER_HEX;
            } else {
                lexer->buffer_char = c;
                return LEC_ERROR_NUMBER;
            }
            break;
        case (LEC_STATE_NUMBER_WHOLE):
            if (isdigit((unsigned char) c)) {
                lexer->sub_state.number_state = LEC_STATE_NUMBER_WHOLE;
            } else if (c == '.') {
                lexer->sub_state.number_state = LEC_STATE_NUMBER_POINT;
            } else if (c == 'e' || c == 'E') {
                lexer->sub_state.number_state = LEC_STATE_NUMBER_E;
            } else {
                lexer->buffer_char = c;
                return LEC_ERROR_NUMBER;
            }
            break;
        case (LEC_STATE_NUMBER_POINT):
            if (!isdigit((unsigned char) c)) {
                lexer->buffer_char = c;
                return LEC_ERROR_NUMBER;
            }
            lexer->sub_state.number_state = LEC_STATE_NUMBER_FRACTION;
            break;
        case (LEC_STATE_NUMBER_FRACTION):
            if (isdigit((unsigned char) c)) {
                lexer->sub_state.number_state = LEC_STATE_NUMBER_FRACTION;
            } else if (c == 'e' || c == 'E') {
                lexer->sub_state.number_state = LEC_STATE_NUMBER_E;
            } else {
                lexer->buffer_char = c;
                return LEC_ERROR_NUMBER;
            }
            break;
        case (LEC_STATE_NUMBER_E):
            if (isdigit((unsigned char) c)) {
                lexer->sub_state.number_state = LEC_STATE_NUMBER_EXPONENT;
            } if (c == '+' || c == '-') {
                lexer->sub_state.number_state = LEC_STATE_NUMBER_EXPONENT_SIGN;
            } else {
                lexer->buffer_char = c;
                return LEC_ERROR_NUMBER;
            }
            break;
        case (LEC_STATE_NUMBER_EXPONENT_SIGN):
            if (!isdigit((unsigned char) c)) {
                lexer->buffer_char = c;
                return LEC_ERROR_NUMBER;
            }
            lexer->sub_state.number_state = LEC_STATE_NUMBER_EXPONENT;
            break;
        case (LEC_STATE_NUMBER_EXPONENT):
            if (!isdigit((unsigned char) c)) {
                lexer->buffer_char = c;
                return LEC_ERROR_NUMBER;
            }
            break;
        case (LEC_STATE_NUMBER_BIN):
            if (c != '0' && c != '1') {
                lexer->buffer_char = c;
                return LEC_ERROR_NUMBER;
            }
            break;
        case (LEC_STATE_NUMBER_HEX):
            if (!isxdigit((unsigned char) c)) {
                lexer->buffer_char = c;
                return LEC_ERROR_NUMBER;
            }
            break;
        case (LEC_STATE_NUMBER_FIRST):
        case (LEC_STATE_NUMBER_LAST):
            assert(false);
    }

    if (lexer->buffer_char == EOF) {
        enum LecError err = lec_arena_add(&lexer->arena, c);
        if (err) { return err; }
    }
    return LEC_ERROR_OK;
}

enum LecError lec_internal_lexer_comment(struct LecLexer *lexer, struct LecToken *token, char c) {
    assert(lexer != NULL);
    assert(token != NULL);
    assert(lexer->state == LEC_STATE_COMMENT);

    if (c == '\n') {
        token->type = LEC_TOKEN_TYPE_COMMENT;
        lexer->state = LEC_STATE_END;
        return LEC_ERROR_OK;
    }

    enum LecError err = lec_arena_add(&lexer->arena, c);
    if (err) { return err; }
    return LEC_ERROR_OK;
}

enum LecError lec_internal_lexer_eof(struct LecLexer *lexer, struct LecToken *token) {
    switch (lexer->state) {
        case (LEC_STATE_START): {
            return LEC_ERROR_EOF;
        }
        case (LEC_STATE_MULTI_CHAR): {
            assert(LEC_STATE_MULTI_CHAR_FIRST < lexer->sub_state.char_state);
            assert(lexer->sub_state.char_state < LEC_STATE_MULTI_CHAR_LAST);
            switch (lexer->sub_state.multi_state) {
                case (LEC_STATE_MULTI_CHAR_ASSIGN):
                    token->type = LEC_TOKEN_TYPE_ASSIGN;
                    break;
                case (LEC_STATE_MULTI_CHAR_LESS):
                    token->type = LEC_TOKEN_TYPE_L_ANGLE;
                    break;
                case (LEC_STATE_MULTI_CHAR_GREAT):
                    token->type = LEC_TOKEN_TYPE_R_ANGLE;
                    break;
                case (LEC_STATE_MULTI_CHAR_PLUS):
                    token->type = LEC_TOKEN_TYPE_PLUS;
                    break;
                case (LEC_STATE_MULTI_CHAR_MINUS):
                    token->type = LEC_TOKEN_TYPE_MINUS;
                    break;
                case (LEC_STATE_MULTI_CHAR_COMMENT_START):
                    token->type = LEC_TOKEN_TYPE_DIV;
                    break;
                case (LEC_STATE_MULTI_CHAR_NOT):
                    token->type = LEC_TOKEN_TYPE_NOT;
                    break;
                case (LEC_STATE_MULTI_CHAR_FIRST):
                case (LEC_STATE_MULTI_CHAR_LAST):
                    assert(false);
            }
            lexer->state = LEC_STATE_END;
            break;
        }
        case (LEC_STATE_CHAR):
        case (LEC_STATE_STRING): {
            return LEC_ERROR_UNTERMINATED;
        }
        case (LEC_STATE_NUMBER): {
            assert(LEC_STATE_NUMBER_FIRST < lexer->sub_state.char_state);
            assert(lexer->sub_state.char_state < LEC_STATE_NUMBER_LAST);
            switch (lexer->sub_state.number_state) {
                case (LEC_STATE_NUMBER_FIRST):
                    assert(false);
                case (LEC_STATE_NUMBER_ZERO):
                case (LEC_STATE_NUMBER_WHOLE):
                case (LEC_STATE_NUMBER_BIN):
                case (LEC_STATE_NUMBER_HEX):
                    token->type = LEC_TOKEN_TYPE_NUMBER_INT;
                    break;
                case (LEC_STATE_NUMBER_POINT):
                    return LEC_ERROR_NUMBER;
                case (LEC_STATE_NUMBER_FRACTION):
                    token->type = LEC_TOKEN_TYPE_NUMBER_FLOAT;
                    break;
                case (LEC_STATE_NUMBER_E):
                    return LEC_ERROR_NUMBER;
                case (LEC_STATE_NUMBER_EXPONENT_SIGN):
                    return LEC_ERROR_NUMBER;
                case (LEC_STATE_NUMBER_EXPONENT):
                    token->type = LEC_TOKEN_TYPE_NUMBER_FLOAT;
                    break;
                case (LEC_STATE_NUMBER_LAST):
                    assert(false);
            }
            lexer->state = LEC_STATE_END;
            break;
        }
        case (LEC_STATE_COMMENT): {
            token->type = LEC_TOKEN_TYPE_COMMENT;
            lexer->state = LEC_STATE_END;
            break;
        }
        case (LEC_STATE_END):
        case (LEC_STATE_MAX):
            assert(false);
    }

    return LEC_ERROR_OK;
}
