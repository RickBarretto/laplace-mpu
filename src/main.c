#include <stdio.h>

#include <app/app.h>

ExitCode main(void) {

    Matrix x = {
        .data = {
            {10, 20, 30, 40},
            {10, 20, 30, 40},
            {10, 20, 30, 40},
            {10, 20, 30, 40},
        },
        .length = 4
    };
    
    Matrix y = x;
    Matrix out;

    puts("add");
    print_matrix(x);
    puts("");
    print_matrix(y);
    puts("");

    mpu_add(&x, &y, &out);
    print_matrix(out);

    return OkCode;
}