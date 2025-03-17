`define i8(x) 8'sd``x                /// defined a 8-bit integer
`define MATRIX_5x5 (0):(8*25-1)     /// defines a 5x5 matrix flatted array indexes
`define at(col, row) (8 * (row + 5*col))    /// Access each 8-bit element in the 5x5 matrix

module MpuSub (
    input      signed [8*25-1:0] matrix_a,  // Flattened 5x5 matrix of 8-bit elements
    input      signed [8*25-1:0] matrix_b,  
    output reg signed [8*25-1:0] result    
);

    genvar col, row;
    generate
        for (col = 0; col < 5; col = col + 1) begin : col_loop
            for (row = 0; row < 5; row = row + 1) begin : row_loop
                always @(*) begin
                    result[`at(col, row) +: 8] = matrix_a[`at(col, row) +: 8] - matrix_b[`at(col, row) +: 8];
                end
            end
        end
    endgenerate

endmodule


module test_MpuSub;

    reg  [`MATRIX_5x5] matrix_a;
    reg  [`MATRIX_5x5] matrix_b;
    wire [`MATRIX_5x5] result;

    MpuSub sub_operation (
        .matrix_a(matrix_a),
        .matrix_b(matrix_b),
        .result(result)
    );

    initial begin

        matrix_a = {`i8(1),  `i8(2),  `i8(3),  `i8(4),  `i8(5), 
                    `i8(6),  `i8(7),  `i8(8),  `i8(9),  `i8(10), 
                    `i8(11), `i8(12), `i8(13), `i8(14), `i8(15), 
                    `i8(16), `i8(17), `i8(18), `i8(19), `i8(20), 
                    `i8(21), `i8(22), `i8(23), `i8(24), `i8(25)};

        matrix_b = {`i8(25), `i8(24), `i8(23), `i8(22), `i8(21), 
                    `i8(20), `i8(19), `i8(18), `i8(17), `i8(16), 
                    `i8(15), `i8(14), `i8(13), `i8(12), `i8(11), 
                    `i8(10), `i8(9),  `i8(8),  `i8(7),  `i8(6), 
                    `i8(5),  `i8(4),  `i8(3),  `i8(2),  `i8(1)};

        $display("Matrix A (matrix_a):");
        display_matrix(matrix_a);
        $display("Matrix B (matrix_b):");
        display_matrix(matrix_b);
        #1;        
        $display("Result (matrix_c or result):");
        display_matrix(result);

        $finish;
    end

    task display_matrix;
        input signed [8*25-1:0] matrix;
        integer i, j;
        begin
            for (i = 0; i < 5; i = i + 1) begin
                for (j = 0; j < 5; j = j + 1) begin
                    $write("%8d ", $signed(matrix[(i*5+j)*8 +: 8]));
                end
                $display(""); // New line for each row
            end
        end
    endtask


endmodule
