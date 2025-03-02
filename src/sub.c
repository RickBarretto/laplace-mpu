#include <assert.h>

#include <mpu/matrix.h>

extern void mpu_sub(Matrix *x, Matrix *y, Matrix *out)
{
    assert(x->length == y->length);
    out->length = x->length;

    #define sub_at(i, j) out->data[i][j] = x->data[i][j] - y->data[i][j];
    #define sub_row(i)  \
        sub_at(i , 0)   \
        sub_at(i , 1)   \
        sub_at(i , 2)   \
        sub_at(i , 3)   \
        sub_at(i , 4)

    sub_row(0);
    sub_row(1);
    sub_row(2);
    sub_row(3);
    sub_row(4);

}
