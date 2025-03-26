#ifndef LEC_LEXER_H
#define LEC_LEXER_H
#include <stdlib.h>
#include <gci_interface_reader.h>
#include <lec_arena.h>
#include <lec_token.h>

enum LecState {
    LEC_STATE_START,

    LEC_STATE_MULTI_CHAR,
    LEC_STATE_CHAR,
    LEC_STATE_STRING,
    LEC_STATE_NUMBER,
    LEC_STATE_COMMENT,

    LEC_STATE_END,
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
    LEC_STATE_MULTI_CHAR_LAST           = 8,
};

enum LecStateChars {
    LEC_STATE_CHARS_FIRST       = 9,
    LEC_STATE_CHARS             = 10,
    LEC_STATE_CHARS_ESCAPED     = 11,
    LEC_STATE_CHARS_ESCAPED_X   = 12,
    LEC_STATE_CHARS_ESCAPED_U   = 13,
    LEC_STATE_CHARS_LAST        = 14,
};

enum LecStateNumber {
    LEC_STATE_NUMBER_FIRST          = 15,
    LEC_STATE_NUMBER_NEGATIVE       = 16,
    LEC_STATE_NUMBER_ZERO           = 17,
    LEC_STATE_NUMBER_WHOLE          = 18,
    LEC_STATE_NUMBER_POINT          = 19,
    LEC_STATE_NUMBER_FRACTION       = 20,
    LEC_STATE_NUMBER_E              = 21,
    LEC_STATE_NUMBER_EXPONENT_SIGN  = 22,
    LEC_STATE_NUMBER_EXPONENT       = 23,
    LEC_STATE_NUMBER_LAST           = 24,
};

struct LecLexer {
    struct GciInterfaceReader reader;
    struct LecArena arena;
    size_t prev_arena_start;
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
