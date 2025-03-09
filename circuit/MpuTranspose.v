`define _8_BITS 7:0
`define _16_BITS 15:0

module MpuTranspose (
    matrix,
    result
);
    input  [_8_BITS] matrix[4:0][4:0];
    output [_8_BITS] result[4:0][4:0];

    Transpose(matrix, result);

endmodule


module Transpose(
    input  [_8_BITS] matrix[4:0][4:0],
    output [_8_BITS] result[4:0][4:0]
);

    `define transpose_at(i, j) result[i][j] = matrix[j][i];
    `define transpose_row(i) \
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

endmodule