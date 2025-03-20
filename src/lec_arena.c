#include <assert.h>
#include "lec_arena.h"

enum LecError lec_arena_init(struct LecArena *arena, char *buffer, size_t length) {
    if (arena == NULL) { return LEC_ERROR_NULL; }
    if (buffer == NULL) { return LEC_ERROR_NULL; }
    if (length <= 0) { return LEC_ERROR_BUFFER; }

    arena->buffer = buffer;
    arena->capacity = length;
    arena->position = 0;

    return LEC_ERROR_OK;
}

enum LecError lec_arena_add(struct LecArena *arena, char c) {
    assert(arena != NULL);
    if (arena->position >= arena->capacity) { return LEC_ERROR_BUFFER; }

    assert(arena->buffer != NULL);
    arena->buffer[arena->position++] = c;
    return LEC_ERROR_OK;
}
