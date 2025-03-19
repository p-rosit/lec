#include "lec.h"

enum LecError lec_arena_init(struct LecArena *arena, char *buffer, size_t length) {
    if (arena == NULL) { return LEC_ERROR_NULL; }
    if (buffer == NULL) { return LEC_ERROR_NULL; }
    if (length <= 0) { return LEC_ERROR_BUFFER; }

    arena->buffer = buffer;
    arena->capacity = length;
    arena->position = 0;

    return LEC_ERROR_OK;
}

enum LecError lec_context_init(struct LecContext *context, struct GciInterfaceReader reader, struct LecArena arena) {
    if (context == NULL) { return LEC_ERROR_NULL; }
    
    context->reader = reader;
    context->arena = arena;

    return LEC_ERROR_OK;
}
