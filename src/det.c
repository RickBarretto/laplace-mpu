#include <assert.h>
#include <stdbool.h>

#include <mpu/matrix.h>


void products_of(Matrix *x, i16 out[2][5])
{
    #define at(i, j) x->data[(i)][(j)]
    #define prod1(x1) (x1)
    #define prod2(x1, x2) (x1) * (x2)
    #define prod3(x1, x2, x3) prod2((x1), prod2((x2), (x3)))
    #define prod4(x1, x2, x3, x4) prod2((x1), prod3((x2), (x3), (x4)))
    #define prod5(x1, x2, x3, x4, x5) prod2((x1), prod4((x2), (x3), (x4), (x5)))

    switch (x->length)
    {
        case 1:
            // 00 .. ..
            // .. .. ..
            // .. .. ..

            out[0][0] = prod1(at(0, 0));
            
            // Clear
            out[0][1] = 0;
            out[0][2] = 0;
            out[0][3] = 0;
            out[0][4] = 0;
            
            out[1][0] = 0;
            out[1][1] = 0;
            out[1][2] = 0;
            out[1][3] = 0;
            out[1][4] = 0;
            break;
        case 2:
            // 00 01 ..
            // 10 11 ..
            // .. .. ..

            out[0][0] = prod2(at(0, 0), at(1, 1));   // Main diagonal
            out[1][0] = prod2(at(0, 1), at(1, 0));   // Secondary diagonal
                
            // Clear
            out[0][1] = 0;
            out[0][2] = 0;
            out[0][3] = 0;
            out[0][4] = 0;
            
            out[1][1] = 0;
            out[1][2] = 0;
            out[1][3] = 0;
            out[1][4] = 0;
            break;
        case 3:
            // 00 01 02 ..
            // 10 11 12 ..
            // 20 21 22 ..
            // .. .. .. ..

            out[0][0] = prod3(at(0, 0), at(1, 1), at(2, 2));
            out[0][1] = prod3(at(0, 1), at(1, 2), at(2, 0));
            out[0][2] = prod3(at(0, 2), at(1, 0), at(2, 1));

            out[1][0] = prod3(at(0, 2), at(1, 1), at(2, 0));
            out[1][1] = prod3(at(0, 1), at(1, 0), at(2, 2));
            out[1][2] = prod3(at(0, 0), at(1, 2), at(2, 1));
            
            out[0][3] = 0;
            out[0][4] = 0;
            out[1][3] = 0;
            out[1][4] = 0;
            break;
        case 4:
            // 00 01 02 03 ..
            // 10 11 12 13 ..
            // 20 21 22 23 ..
            // 30 31 32 33 ..
            // .. .. .. .. ..

            out[0][0] = prod4(at(0, 0), at(1, 1), at(2, 2), at(3, 3));
            out[0][1] = prod4(at(0, 1), at(1, 2), at(2, 3), at(3, 0));
            out[0][2] = prod4(at(0, 2), at(1, 3), at(2, 0), at(3, 1));
            out[0][3] = prod4(at(0, 3), at(1, 0), at(2, 1), at(3, 2));
            
            out[1][0] = prod4(at(0, 3), at(1, 2), at(2, 1), at(3, 0));
            out[1][1] = prod4(at(0, 2), at(1, 1), at(2, 0), at(3, 3));
            out[1][2] = prod4(at(0, 1), at(1, 0), at(2, 3), at(3, 2));
            out[1][3] = prod4(at(0, 0), at(1, 3), at(2, 2), at(3, 1));
            
            out[0][4] = 0;
            out[1][4] = 0;
            break;
        case 5:
            // Main Diagonals
            out[0][0] = prod5(at(0, 0), at(1, 1), at(2, 2), at(3, 3), at(4, 4));
            out[0][1] = prod5(at(0, 1), at(1, 2), at(2, 3), at(3, 4), at(4, 0));
            out[0][2] = prod5(at(0, 2), at(1, 3), at(2, 4), at(3, 0), at(4, 1));
            out[0][3] = prod5(at(0, 3), at(1, 4), at(2, 0), at(3, 1), at(4, 2));
            out[0][4] = prod5(at(0, 4), at(1, 0), at(2, 1), at(3, 2), at(4, 3));
            
            // Secondary Diagonals
            out[1][0] = prod5(at(0, 4), at(1, 3), at(2, 2), at(3, 1), at(4, 0));
            out[1][1] = prod5(at(0, 3), at(1, 2), at(2, 1), at(3, 0), at(4, 4));
            out[1][2] = prod5(at(0, 2), at(1, 1), at(2, 0), at(3, 4), at(4, 3));
            out[1][3] = prod5(at(0, 1), at(1, 0), at(2, 4), at(3, 3), at(4, 2));
            out[1][4] = prod5(at(0, 0), at(1, 4), at(2, 3), at(3, 2), at(4, 1));
            break;
        default:
            assert(false || "Unreachable: Matrix length should be between 1 and 5");
    }
}

void sums_of(i16 products[2][5], i16 *det) 
{
    i16 diff[5];

    diff[0] = products[0][0] - products[1][0];
    diff[1] = products[0][1] - products[1][1];
    diff[2] = products[0][2] - products[1][2];
    diff[3] = products[0][3] - products[1][3];
    diff[4] = products[0][4] - products[1][4];

    *det = diff[0] + diff[1] + diff[2] + diff[3] + diff[4];

}

void mpu_det(Matrix *x, i16 *out)
{
    i16 products[2][5];
    i16 det;

    products_of(x, products);
    sums_of(products, &det);

    *out = det;

}
