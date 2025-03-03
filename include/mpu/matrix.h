#ifndef __MATRIX_H__
#define __MATRIX_H__

#include <mpu/common.h>

typedef struct {
    u8 length;
    i8 data[5][5];
} Matrix;

void mpu_add(Matrix *x, Matrix *y, Matrix *out);
void mpu_sub(Matrix *x, Matrix *y, Matrix *out);
void mpu_mul(Matrix *x, Matrix *y, Matrix *out);
void mpu_imul(Matrix *x, i8 factor, Matrix *out);
void mpu_opposite(Matrix *x, Matrix *out);
void mpu_transpose(Matrix *x, Matrix *out);
void mpu_det(Matrix *x, i16 *out);

#endif