#ifndef LEC_LEXER_H
#define LEC_LEXER_H
#include <stdlib.h>
#include <gci_interface_reader.h>
#include <lec_arena.h>
#include <lec_token.h>

enum LecState {
    LEC_STATE_START         = 1,

    LEC_STATE_TEXT          = 2,
    LEC_STATE_MULTI_CHAR    = 3,
    LEC_STATE_CHAR          = 4,
    LEC_STATE_STRING        = 5,
    LEC_STATE_NUMBER        = 6,
    LEC_STATE_COMMENT       = 7,

    LEC_STATE_END           = 8,
    LEC_STATE_MAX,
};

enum LecStateMultiChar {
    LEC_STATE_MULTI_CHAR_FIRST          = 1,
    LEC_STATE_MULTI_CHAR_ASSIGN         = 2,
    LEC_STATE_MULTI_CHAR_LESS           = 3,
    LEC_STATE_MULTI_CHAR_GREAT          = 4,
    LEC_STATE_MULTI_CHAR_PLUS           = 5,
    LEC_STATE_MULTI_CHAR_MINUS          = 6,
    LEC_STATE_MULTI_CHAR_COMMENT_START  = 7,
    LEC_STATE_MULTI_CHAR_NOT            = 8,
    LEC_STATE_MULTI_CHAR_ESCAPE         = 9,
    LEC_STATE_MULTI_CHAR_WHITESPACE     = 10,
    LEC_STATE_MULTI_CHAR_DOT            = 11,
    LEC_STATE_MULTI_CHAR_LAST           = 12,
};

enum LecStateChars {
    LEC_STATE_CHARS_FIRST       = 13,
    LEC_STATE_CHARS             = 14,
    LEC_STATE_CHARS_ESCAPED     = 15,
    LEC_STATE_CHARS_ESCAPED_X   = 16,
    LEC_STATE_CHARS_ESCAPED_U   = 17,
    LEC_STATE_CHARS_LAST        = 18,
};

enum LecStateNumber {
    LEC_STATE_NUMBER_FIRST              = 19,

    LEC_STATE_NUMBER_ZERO               = 20,
    LEC_STATE_NUMBER_WHOLE              = 21,
    LEC_STATE_NUMBER_POINT              = 22,
    LEC_STATE_NUMBER_FRACTION           = 23,
    LEC_STATE_NUMBER_E                  = 24,
    LEC_STATE_NUMBER_EXPONENT_SIGN      = 25,
    LEC_STATE_NUMBER_EXPONENT           = 26,

    LEC_STATE_NUMBER_HEX_WHOLE          = 27,
    LEC_STATE_NUMBER_HEX_POINT          = 28,
    LEC_STATE_NUMBER_HEX_FRACTION       = 29,
    LEC_STATE_NUMBER_HEX_P              = 30,
    LEC_STATE_NUMBER_HEX_EXPONENT_SIGN  = 31,
    LEC_STATE_NUMBER_HEX_EXPONENT       = 32,

    LEC_STATE_NUMBER_BIN                = 33,

    LEC_STATE_NUMBER_LAST               = 34,
};

struct LecLexer {
    struct GciInterfaceReader reader;
    struct LecArena arena;
    size_t prev_arena_start;
    size_t prev_byte_position;
    size_t byte_position;
    enum LecState state;
    union {
        enum LecStateMultiChar multi_state;
        enum LecStateChars char_state;
        enum LecStateNumber number_state;
    } sub_state;
    int buffer_char;
};

enum LecError lec_lexer_init(struct LecLexer *lexer, struct GciInterfaceReader reader, struct LecArena arena);

enum LecError lec_lexer_next(struct LecLexer *lexer, struct LecToken *token);
enum LecError lec_lexer_value(struct LecLexer *lexer, struct LecToken token, char **string, size_t *length);

#endif
