`define _8_BITS 7:0
`define _16_BITS 15:0

module MpuAdd (
    matrix_a,
    matrix_b,

    result
);
    input  [_8_BITS] matrix_a[4:0][4:0];
    input  [_8_BITS] matrix_b[4:0][4:0];
    output [_8_BITS]   result[4:0][4:0];

    AdditionOperation(matrix_a, matrix_b, result);

endmodule


module AdditionOperation (
    input  [_8_BITS]   x[4:0][4:0],
    input  [_8_BITS]   y[4:0][4:0],
    output [_8_BITS] out[4:0][4:0]
);
    `define add_at(i, j) assign out[i][j] = x[i][j] + y[i][j];

    `add_at(0, 0)
    `add_at(0, 1)
    `add_at(0, 2)
    `add_at(0, 3)
    `add_at(0, 4)

    `add_at(1, 0)
    `add_at(1, 1)
    `add_at(1, 2)
    `add_at(1, 3)
    `add_at(1, 4)

    `add_at(2, 0)
    `add_at(2, 1)
    `add_at(2, 2)
    `add_at(2, 3)
    `add_at(2, 4)

    `add_at(3, 0)
    `add_at(3, 1)
    `add_at(3, 2)
    `add_at(3, 3)
    `add_at(3, 4)

    `add_at(4, 0)
    `add_at(4, 1)
    `add_at(4, 2)
    `add_at(4, 3)
    `add_at(4, 4)

endmodule