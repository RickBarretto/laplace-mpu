`define _8_BITS 7:0
`define _16_BITS 15:0

module MpuAdd (
    matrix_a,
    matrix_b,
    size,

    result
);
    input  [_8_BITS] matrix_a[4:0][4:0];
    input  [_8_BITS] matrix_b[4:0][4:0];
    input  [_8_BITS] size;
    output [_8_BITS] result[4:0][4:0];

    wire   [_8_BITS] cleared_a[4:0][4:0];
    wire   [_8_BITS] cleared_b[4:0][4:0];

    Clear(matrix_a, cleared_a);
    Clear(matrix_b, cleared_b);
    Multiply(cleared_a, cleared_b, result);

endmodule



module Multiply (
    input  [_8_BITS] matrix_a[4:0][4:0],
    input  [_8_BITS] matrix_b[4:0][4:0],
    output [_8_BITS]   result[4:0][4:0]
);

    `define at(entity, i, j) entity[(i)][(j)]
    `define left(i, j) at(matrix_a, i, j)
    `define right(i, j) at(matrix_b, i, j)

    `define product_at(i, j)            \
        assign `at(result, i, j) =      \
        `left(i, 0) * `right(0, j)      \
        + `left(i, 1) * `right(1, j)    \
        + `left(i, 2) * `right(2, j)    \
        + `left(i, 3) * `right(3, j)    \
        + `left(i, 4) * `right(4, j);

    `define row_product(i)  \
        `product_at(i , 0); \
        `product_at(i , 1); \
        `product_at(i , 2); \
        `product_at(i , 3); \
        `product_at(i , 4);

    `row_product(0)
    `row_product(1)
    `row_product(2)
    `row_product(3)
    `row_product(4)

endmodule



module Clear (
    input  [_8_BITS] x[4:0][4:0],
    input  [_8_BITS] size,
    output [_8_BITS] out[4:0][4:0]
);

    `define at(entity, i, j) entity[(i)][(j)]
    `define copy(i, j) at(out, i, j) = at(matrix, i, j)
    `define clear(i, j) at(out, i, j) = 0

    copy(0, 0);

    // .. 01
    // 10 11

    if (size > 1) begin
        copy(0, 1); // Vertical
        copy(1, 0); // Horizontal
        copy(1, 1); // Corner
    end else begin
        clear(0, 2); // Vertical
        clear(0, 3); // Horizontal
        clear(0, 4); // Corner
    end

      // .. .. 02
    // .. .. 12
    // 20 21 22
    
    if (size > 2) begin
        copy(0, 2); copy(1, 2); // Vertical
        copy(2, 0); copy(2, 1); // Horizontal
        copy(2, 2);             // Corner
    end else begin
        clear(0, 2); clear(1, 2); // Vertical
        clear(2, 0); clear(2, 1); // Horizontal
        clear(2, 2);              // Corner
    end

    // .. .. .. 03
    // .. .. .. 13
    // .. .. .. 23
    // 30 31 32 33
    
    if (size > 3) begin
        copy(0, 3); copy(1, 3); copy(2, 3); // Vertical
        copy(3, 0); copy(3, 1); copy(3, 2); // Horizontal
        copy(3, 3);                         // Corner
    end else begin
        clear(0, 3); clear(1, 3); clear(2, 3); // Vertical
        clear(3, 0); clear(3, 1); clear(3, 2); // Horizontal
        clear(3, 3);                           // Corner
    end

    // .. .. .. .. 04
    // .. .. .. .. 14
    // .. .. .. .. 24
    // .. .. .. .. 34
    // 40 41 42 43 44
    
    if (size > 4) begin
        copy(0, 4); copy(1, 4); copy(2, 4); copy(3, 4); // Vertical
        copy(4, 0); copy(4, 1); copy(4, 2); copy(4, 3); // Horizontal
        copy(4, 4);                                     // Corner
    end else begin
        clear(0, 4); clear(1, 4); clear(2, 4); clear(3, 4); // Vertical
        clear(4, 0); clear(4, 1); clear(4, 2); clear(4, 3); // Horizontal
        clear(4, 4);                                        // Corner
    end
endmodule