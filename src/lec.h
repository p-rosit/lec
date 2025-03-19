#ifndef LEC_H
#define LEC_H
#include <stdlib.h>
#include <gci_interface_reader.h>
#include "lec_token.h"

enum LecError {
    LEC_ERROR_OK = 0,
    LEC_ERROR_NULL = 1,
    LEC_ERROR_BUFFER = 2,
};

struct LecArena {
    char *buffer;
    size_t capacity;
    size_t position;
};

struct LecContext {
    struct GciInterfaceReader reader;
    struct LecArena arena;
};

enum LecError lec_arena_init(struct LecArena *arena, char *buffer, size_t length);
enum LecError lec_context_init(struct LecContext *context, struct GciInterfaceReader reader, struct LecArena arena);

enum LecError lec_token_next(struct LecContext *context, struct LecToken *token);
enum LecError lec_token_value(struct LecContext *context, struct LecToken token, char **string, size_t *length);

#endif
