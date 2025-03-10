`define _8_BITS 7:0
`define _16_BITS 15:0

module MpuIntMul (
    matrix,
    factor,

    result
);
    input  [_8_BITS]   matrix[4:0][4:0];
    input  [_8_BITS]   factor;
    output [_8_BITS]   result[4:0][4:0];

    IntegerMultiplication(matrix_a, factor, result);

endmodule


module IntegerMultiplication (
    input  [_8_BITS]   matrix[4:0][4:0],
    input  [_8_BITS]   factor,
    output [_8_BITS]      out[4:0][4:0]
);
    `define mul_at(i, j) assign out[i][j] = matrix[i][j] * factor;

    `mul_at(0, 0)
    `mul_at(0, 1)
    `mul_at(0, 2)
    `mul_at(0, 3)
    `mul_at(0, 4)

    `mul_at(1, 0)
    `mul_at(1, 1)
    `mul_at(1, 2)
    `mul_at(1, 3)
    `mul_at(1, 4)

    `mul_at(2, 0)
    `mul_at(2, 1)
    `mul_at(2, 2)
    `mul_at(2, 3)
    `mul_at(2, 4)

    `mul_at(3, 0)
    `mul_at(3, 1)
    `mul_at(3, 2)
    `mul_at(3, 3)
    `mul_at(3, 4)

    `mul_at(4, 0)
    `mul_at(4, 1)
    `mul_at(4, 2)
    `mul_at(4, 3)
    `mul_at(4, 4)

endmodule