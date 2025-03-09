`define _8_BITS 7:0
`define _16_BITS 15:0

module MpuOpposite (
    matrix,
    result
);
    input  [_8_BITS]   matrix[4:0][4:0];
    output [_8_BITS]   result[4:0][4:0];

    MpuIMul(matrix, -1, result);

endmodule