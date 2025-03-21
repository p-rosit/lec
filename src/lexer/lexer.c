#include <assert.h>
#include <stdio.h>
#include <ctype.h>
#include <lec_lexer.h>
#include <lec_internal.h>

enum LecError lec_internal_lexer_next_char(struct LecLexer *lexer, struct LecToken *token);

enum LecError lec_lexer_init(struct LecLexer *lexer, struct GciInterfaceReader reader, struct LecArena arena) {
    if (lexer == NULL) { return LEC_ERROR_NULL; }
    
    lexer->state = LEC_STATE_START;
    lexer->reader = reader;
    lexer->arena = arena;
    lexer->buffer_char = EOF;

    return LEC_ERROR_OK;
}

enum LecError lec_lexer_next(struct LecLexer *lexer, struct LecToken *token) {
    assert(lexer != NULL);
    if (token == NULL) { return LEC_ERROR_NULL; }

    token->type = LEC_TOKEN_TYPE_UNKNOWN;
    token->start = lexer->arena.position;
    token->length = 0;

    if (lexer->state != LEC_STATE_START) {
        token->start = lexer->prev_start;
    } else {
        lexer->prev_start = lexer->arena.position;

        char c = lexer->buffer_char == EOF ? ' ' : (char) lexer->buffer_char;
        while (isspace((unsigned char) c)) {
            size_t length = gci_reader_read(lexer->reader, &c, 1);
            if (length != 1) { return LEC_ERROR_READER; }
            lexer->buffer_char = c;
        }
    }

    while (lexer->state != LEC_STATE_END) {
        enum LecError err = lec_internal_lexer_next_char(lexer, token);
        if (err) { return err; }
    }

    lexer->state = LEC_STATE_START;
    token->length = lexer->arena.position - token->start;
    return LEC_ERROR_OK;
}

enum LecError lec_internal_lexer_next_char(struct LecLexer *lexer, struct LecToken *token) {
    assert(lexer != NULL);
    assert(token != NULL);

    char c;
    if (lexer->buffer_char == EOF) {
        size_t length = gci_reader_read(lexer->reader, &c, 1);
        if (length != 1) { return LEC_ERROR_READER; }
    } else {
        c = (char) lexer->buffer_char;
        lexer->buffer_char = EOF;
    }

    if (isspace((unsigned char) c)) {
        lexer->state = LEC_STATE_END;
        return LEC_ERROR_OK;
    }

    switch (lexer->state) {
        case (LEC_STATE_START):
            switch (c) {
                case '+':
                case '-':
                case '*':
                case '(':
                case ')':
                case '[':
                case ']':
                case '{':
                case '}':
                case '<':
                case '>':
                case '.':
                case ',':
                case '?':
                case ':':
                case ';':
                    lexer->state = LEC_STATE_END;
                    break;
                default:
                    assert(0); // TODO: now what?
            }
            break;
        case (LEC_STATE_END):
        case (LEC_STATE_MAX):
            assert(0);
    }

    enum LecError err = lec_arena_add(&lexer->arena, c);
    if (err) { return err; }

    return LEC_ERROR_OK;
}
