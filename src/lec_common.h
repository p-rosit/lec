#ifndef LEC_COMMON_H
#define LEC_COMMON_H

enum LecError {
    LEC_ERROR_OK = 0,
    LEC_ERROR_NULL = 1,
    LEC_ERROR_BUFFER = 2,
    LEC_ERROR_READER = 3,
    LEC_ERROR_EOF = 4,
    LEC_ERROR_NUMBER = 5,
    LEC_ERROR_UNTERMINATED = 6,
};

#endif
