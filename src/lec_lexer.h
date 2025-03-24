#ifndef LEC_LEXER_H
#define LEC_LEXER_H
#include <stdlib.h>
#include <gci_interface_reader.h>
#include <lec_arena.h>
#include <lec_token.h>

enum LecState {
    LEC_STATE_START,

    LEC_STATE_ASSIGN,
    LEC_STATE_EQUAL,
    LEC_STATE_LESS,
    LEC_STATE_GREAT,

    LEC_STATE_END,
    LEC_STATE_MAX,
};

struct LecLexer {
    struct GciInterfaceReader reader;
    struct LecArena arena;
    size_t prev_arena_start;
    size_t byte_position;
    enum LecState state;
    int buffer_char;
};

enum LecError lec_lexer_init(struct LecLexer *lexer, struct GciInterfaceReader reader, struct LecArena arena);

enum LecError lec_lexer_next(struct LecLexer *lexer, struct LecToken *token);
enum LecError lec_lexer_value(struct LecLexer *lexer, struct LecToken token, char **string, size_t *length);

#endif
