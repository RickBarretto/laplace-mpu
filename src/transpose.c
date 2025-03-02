#include <mpu/matrix.h>

void mpu_transpose(Matrix *x, Matrix *out)
{
    out->length = x->length;
    
    #define transpose_at(i, j) out->data[i][j] = x->data[j][i];
    #define transpose_row(i) \
        transpose_at(i, 0)   \
        transpose_at(i, 1)   \
        transpose_at(i, 2)   \
        transpose_at(i, 3)   \
        transpose_at(i, 4)

    transpose_row(0);
    transpose_row(1);
    transpose_row(2);
    transpose_row(3);
    transpose_row(4);

}