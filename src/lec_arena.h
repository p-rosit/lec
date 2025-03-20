#ifndef LEC_ARENA_H
#define LEC_ARENA_H
#include <stdlib.h>
#include <lec_common.h>

struct LecArena {
    char *buffer;
    size_t capacity;
    size_t position;
};

enum LecError lec_arena_init(struct LecArena *arena, char *buffer, size_t length);

#endif
