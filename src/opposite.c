#include <mpu/matrix.h>

void mpu_opposite(Matrix *x, Matrix *out)
{
    mpu_imul(x, -1, out);
}