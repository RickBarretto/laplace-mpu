#include <stdio.h>

#include <app/app.h>

ExitCode main(void) {

    Matrix matrix = {
        .data = {
            {10, 20, 30, 40},
            {10, 20, 30, 40},
            {10, 20, 30, 40},
            {10, 20, 30, 40},
        },
        .length = 4
    };

    print_matrix(matrix);
    
    return OkCode;
}