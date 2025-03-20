#include <assert.h>
#include <stdio.h>
#include <ctype.h>
#include "lec_lexer.h"
#include "lec_internal.h"

enum LecError lec_lexer_init(struct LecContext *context, struct GciInterfaceReader reader, struct LecArena arena) {
    if (context == NULL) { return LEC_ERROR_NULL; }
    
    context->reader = reader;
    context->arena = arena;
    context->buffer_char = EOF;

    return LEC_ERROR_OK;
}
