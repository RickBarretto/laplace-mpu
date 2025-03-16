`define i8(x) 8'd``x                /// defined a 8-bit integer
`define MATRIX_5x5 (8*25-1):(0)     /// defines a 5x5 matrix flatted array indexes
`define at(i, j) (8 * (i + 5*j))    /// Access each 8-bit element in the 5x5 matrix

module MpuTranspose (
    input      [`MATRIX_5x5] matrix,    // 5x5 8-bits matrix
    output reg [`MATRIX_5x5] result     // 5x5 8-bits matrix
);

    `define transpose_at(i, j) result[`at(i, j) +: 8] = matrix[`at(j, i) +: 8];
    `define transpose_row(i)    \
        `transpose_at(i, 0);    \
        `transpose_at(i, 1);    \
        `transpose_at(i, 2);    \
        `transpose_at(i, 3);    \
        `transpose_at(i, 4);

    always @* begin
        `transpose_row(0)
        `transpose_row(1)
        `transpose_row(2)
        `transpose_row(3)
        `transpose_row(4)
    end

endmodule

module test_MpuTranspose;

    reg  [`MATRIX_5x5] matrix;
    wire [`MATRIX_5x5] result;

    MpuTranspose trans_operation (
        .matrix(matrix),
        .result(result)
    );

    initial begin

        matrix = {  `i8(1),  `i8(2),  `i8(3),  `i8(4),  `i8(5), 
                    `i8(6),  `i8(7),  `i8(8),  `i8(9),  `i8(10), 
                    `i8(11), `i8(12), `i8(13), `i8(14), `i8(15), 
                    `i8(16), `i8(17), `i8(18), `i8(19), `i8(20), 
                    `i8(21), `i8(22), `i8(23), `i8(24), `i8(25)};

        $display("Matrix A (matrix):");
        display_matrix(matrix);
        #1;
        $display("Result (result):");
        display_matrix(result);

        $finish;
    end

    task display_matrix;
        input [`MATRIX_5x5] matrix;
        integer i;
        begin
            for (i = 0; i < 5; i = i + 1) begin
                $display("%4d %4d %4d %4d %4d", 
                    matrix[`at(i, 0) +: 8],
                    matrix[`at(i, 1) +: 8],
                    matrix[`at(i, 2) +: 8],
                    matrix[`at(i, 3) +: 8],
                    matrix[`at(i, 4) +: 8]);
            end
        end
    endtask

endmodule
