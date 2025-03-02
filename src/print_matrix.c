#include <stdio.h>
#include <assert.h>

#include <app/print_matrix.h>

void print_row(u8 row[5], u8 length)
{
    for (u8 col = 0; col < length; col++)
    {
        printf("%d, ", row[col]);
    }
}

extern void print_matrix(Matrix matrix)
{
    for (u8 row = 0; row < matrix.length; row++)
    {
        print_row(matrix.data[row], matrix.length);
        puts("");
    }
}