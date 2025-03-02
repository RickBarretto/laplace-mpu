#ifndef __MATRIX_H__
#define __MATRIX_H__

#include <mpu/common.h>

typedef struct {
    u8 length;
    i8 data[5][5];
} Matrix;

#endif