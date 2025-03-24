#ifndef LEC_TOKEN_H
#define LEC_TOKEN_H
#include <stdlib.h>

enum LecTokenType {
    LEC_TOKEN_TYPE_UNKNOWN,

    LEC_TOKEN_TYPE_TEXT,
    LEC_TOKEN_TYPE_NUMBER_INT, // 3
    LEC_TOKEN_TYPE_NUMBER_FLOAT, // -1.4e+5
    LEC_TOKEN_TYPE_CHAR, // '...'
    LEC_TOKEN_TYPE_STRING, // "..."
    LEC_TOKEN_TYPE_COMMENT, // c-style

    LEC_TOKEN_TYPE_PLUS, // +
    LEC_TOKEN_TYPE_MINUS, // -
    LEC_TOKEN_TYPE_MUL, // *
    LEC_TOKEN_TYPE_DIV, // /

    LEC_TOKEN_TYPE_L_PAREN, // (
    LEC_TOKEN_TYPE_R_PAREN, // )
    LEC_TOKEN_TYPE_L_BRACK, // [
    LEC_TOKEN_TYPE_R_BRACK, // ]
    LEC_TOKEN_TYPE_L_BRACE, // {
    LEC_TOKEN_TYPE_R_BRACE, // }
    LEC_TOKEN_TYPE_L_ANGLE, // <
    LEC_TOKEN_TYPE_R_ANGLE, // >

    LEC_TOKEN_TYPE_DOT, // .
    LEC_TOKEN_TYPE_COMMA, // ,
    LEC_TOKEN_TYPE_QUESTION, // ?
    LEC_TOKEN_TYPE_COLON, // :
    LEC_TOKEN_TYPE_SEMICOLON, // ;

    LEC_TOKEN_TYPE_MAX,
};

struct LecToken {
    size_t arena_start;
    size_t byte_start;
    size_t length;
    enum LecTokenType type;
};

#endif
