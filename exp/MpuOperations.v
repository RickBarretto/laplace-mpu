module MpuOperations(
    input        [2:0] operation,
    input signed [`MATRIX_5x5] matrix_a,
    input signed [`MATRIX_5x5] matrix_b,
    input        [`INTEGER_8] size,
    input signed [`INTEGER_8] factor,

    input clock,

    output reg signed [`MATRIX_5x5] result,
    output reg signed [`INTEGER_8] determinant
);

    always @(posedge clock) begin
        case (operation)
            0: MpuAdd(matrix_a, matrix_b, result);
            1: MpuSub(matrix_a, matrix_b, result);
            2: MpuIMul(matrix_a, factor, result);
            3: MpuOpposite(matrix_a, result);
            4: MpuTranspose(matrix_a, result);
            5: MpuDet(matrix_a, determinant);
            6: MpuMul(matrix_a, matrix_b, result);
            default:
        endcase
    end

endmodule