#include <assert.h>

#include <mpu/matrix.h>

extern void mpu_add(Matrix *x, Matrix *y, Matrix *out)
{
    assert(x->length == y->length);
    out->length = x->length;

    #define add_at(i, j) out->data[i][j] = x->data[i][j] + y->data[i][j];
    #define add_row(i)  \
        add_at(i , 0)   \
        add_at(i , 1)   \
        add_at(i , 2)   \
        add_at(i , 3)   \
        add_at(i , 4)

    add_row(0);
    add_row(1);
    add_row(2);
    add_row(3);
    add_row(4);

}
