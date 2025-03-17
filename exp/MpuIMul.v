`define i8(x) 8'sd``x                        /// defined a 8-bit integer
`define MATRIX_5x5 (0):(8*25-1)             /// 5x5 matrix flatted array indexes
`define INTEGER_8 7:0                       /// 8-bits integer indexes
`define at(col, row) (8 * (row + 5*col))    /// Access each 8-bit element in the 5x5 matrix

module MpuIMul (
    input      signed [`MATRIX_5x5] matrix_a,  // 5x5 8-bits matrix
    input      signed [`INTEGER_8 ] factor,    // 8-bits integer
    output reg signed [`MATRIX_5x5] result     // 5x5 8-bits matrix
);

    integer col, row;
    always @(*) begin
        for (col = 0; col < 5; col = col + 1) begin
            for (row = 0; row < 5; row = row + 1) begin
                result[`at(col, row) +: 8] = factor * matrix_a[`at(col, row) +: 8];
            end
        end
    end

endmodule

module test_MpuIMul;

    reg  signed [`MATRIX_5x5] matrix_a;
    reg  signed [`INTEGER_8 ] factor;
    wire signed [`MATRIX_5x5] result;

    MpuIMul imul_operation (
        .matrix_a(matrix_a),
        .factor(factor),
        .result(result)
    );

    initial begin

        matrix_a = {`i8(1),  `i8(2),  `i8(3),  `i8(4),  `i8(5), 
                    `i8(6),  `i8(7),  `i8(8),  `i8(9),  `i8(10), 
                    `i8(11), `i8(12), `i8(13), `i8(14), `i8(15), 
                    `i8(16), `i8(17), `i8(18), `i8(19), `i8(20), 
                    `i8(21), `i8(22), `i8(23), `i8(24), `i8(25)};

        factor = `i8(2);

        $display("Matrix A (matrix_a):");
        display_matrix(matrix_a);
        $display("Factor (factor):");
        $display("%d", factor);
        #1;        
        $display("Result (result):");
        display_matrix(result);

        $finish;
    end

    task display_matrix;
        input signed [`MATRIX_5x5] matrix;
        integer i;
        begin
            for (i = 0; i < 5; i = i + 1) begin
                $display("%4d %4d %4d %4d %4d", 
                    $signed(matrix[`at(i, 0) +: 8]),
                    $signed(matrix[`at(i, 1) +: 8]),
                    $signed(matrix[`at(i, 2) +: 8]),
                    $signed(matrix[`at(i, 3) +: 8]),
                    $signed(matrix[`at(i, 4) +: 8]));
            end
        end
    endtask

endmodule
