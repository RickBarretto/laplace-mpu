#include <assert.h>

#include <mpu/matrix.h>

extern void mpu_imul(Matrix *x, i8 factor, Matrix *out)
{
    out->length = x->length;

    #define mul_at(i, j) out->data[i][j] = x->data[i][j] * factor;
    #define mul_row(i)  \
        mul_at(i , 0)   \
        mul_at(i , 1)   \
        mul_at(i , 2)   \
        mul_at(i , 3)   \
        mul_at(i , 4)

    mul_row(0);
    mul_row(1);
    mul_row(2);
    mul_row(3);
    mul_row(4);

}
