`define i8(x) 8'sd``x                /// defined a 8-bit integer
`define MATRIX_5x5 (0):(8*25-1)     /// defines a 5x5 matrix flatted array indexes
`define at(col, row) (8 * (row + 5*col))    /// Access each 8-bit element in the 5x5 matrix

module MpuTranspose (
    input  wire signed [`MATRIX_5x5] matrix,  // 5x5 8-bit matrix
    output wire signed [`MATRIX_5x5] result   // 5x5 8-bit matrix
);

    genvar i, j;
    generate
        for (i = 0; i < 5; i = i + 1) begin : row_loop
            for (j = 0; j < 5; j = j + 1) begin : col_loop
                assign result[`at(i, j) +: 8] = matrix[`at(j, i) +: 8];
            end
        end
    endgenerate

endmodule


module test_MpuTranspose;

    reg  signed [`MATRIX_5x5] matrix;
    wire signed [`MATRIX_5x5] result;

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
