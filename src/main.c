#include <stdio.h>

#include <app/app.h>

void print_add()
{
    Matrix x, y, out;

    x = (Matrix) {
        .data = {
            {10, 20, 30, 40},
            {10, 20, 30, 40},
            {10, 20, 30, 40},
            {10, 20, 30, 40},
        },
        .length = 4
    };
    y = x;

    puts("===================================");
    puts("add");
    print_matrix(x);
    puts("");
    print_matrix(y);
    puts("");
    
    mpu_add(&x, &y, &out);
    print_matrix(out);
    puts("===================================");
}

void print_sub()
{
    Matrix out;

    Matrix x = {
        .data = {
            {20, 40, 60, 80},
            {20, 40, 60, 80},
            {20, 40, 60, 80},
            {20, 40, 60, 80},
        },
        .length = 4
    };
    
    Matrix y = {
        .data = {
            {10, 20, 30, 40},
            {10, 20, 30, 40},
            {10, 20, 30, 40},
            {10, 20, 30, 40},
        },
        .length = 4
    };

    puts("===================================");
    puts("sub");
    print_matrix(x);
    puts("");
    print_matrix(y);
    puts("");
    
    mpu_sub(&x, &y, &out);
    print_matrix(out);
    puts("===================================");
}

void print_imul()
{
    i8 factor = 3;
    Matrix out;
    Matrix x = {
        .data = {
            {20, 40, 60, 80},
            {20, 40, 60, 80},
            {20, 40, 60, 80},
            {20, 40, 60, 80},
        },
        .length = 4
    };

    puts("===================================");
    puts("imul");
    print_matrix(x);
    puts("");
    printf("%d", factor);
    puts("");
    
    mpu_imul(&x, factor, &out);
    print_matrix(out);
    puts("===================================");
}

void print_opposite()
{
    Matrix out;
    Matrix x = {
        .data = {
            {20, 40, 60, 80},
            {20, 40, 60, 80},
            {20, 40, 60, 80},
            {20, 40, 60, 80},
        },
        .length = 4
    };

    puts("===================================");
    puts("opposite");
    print_matrix(x);
    puts("");
    
    mpu_opposite(&x, &out);
    print_matrix(out);
    puts("===================================");
}

void print_transpose()
{
    Matrix out;
    Matrix x = {
        .data = {
            {20, 40, 60, 80},
            {20, 40, 60, 80},
            {20, 40, 60, 80},
            {20, 40, 60, 80},
        },
        .length = 4
    };

    puts("===================================");
    puts("transpose");
    print_matrix(x);
    puts("");
    
    mpu_transpose(&x, &out);
    print_matrix(out);
    puts("===================================");
}

void print_det()
{
    i16 out;
    Matrix x = {
        .data = {
            {5, 4},
            {2, 3},
        },
        .length = 2
    };

    puts("===================================");
    puts("det");
    print_matrix(x);
    puts("");
    
    mpu_det(&x, &out);
    printf("%d\n", out);
    puts("===================================");
}

ExitCode main(void) {

    print_add();
    print_sub();
    print_imul();
    print_opposite();
    print_transpose();
    print_det();

    return OkCode;
}