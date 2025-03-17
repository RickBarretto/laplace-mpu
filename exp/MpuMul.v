`define i8(x) 8'd``x
`define INTEGER_8 7:0
`define MATRIX8_5x5 0:(8*25-1)
`define MATRIX16_5x5 0:(16*25-1)
`define at(col, row) (8 * (row + 5*col))    /// Access each 8-bit element in the 5x5 matrix

module MpuMul (
    input      [`MATRIX8_5x5] matrix_a, // Flattened 5x5 matrix (each element 8 bits)
    input      [`MATRIX8_5x5] matrix_b, // Flattened 5x5 matrix (each element 8 bits)
    output reg [`MATRIX16_5x5] result   // Flattened 5x5 result matrix (each element 16 bits)
);
    integer i, j, k;
    reg [15:0] temp_result [0:4][0:4];
    reg [7:0] a_mat [0:4][0:4];
    reg [7:0] b_mat [0:4][0:4];

    always @(*) begin
        // Unpack flattened input matrices (Correct indexing order)
        for (i = 0; i < 5; i = i + 1) begin
            for (j = 0; j < 5; j = j + 1) begin
                a_mat[i][j] = matrix_a[`at(i, j) +: 8];
                b_mat[i][j] = matrix_b[`at(i, j) +: 8];
                temp_result[i][j] = 0;
            end
        end
        
        // Matrix multiplication logic
        for (i = 0; i < 5; i = i + 1) begin
            for (j = 0; j < 5; j = j + 1) begin
                for (k = 0; k < 5; k = k + 1) begin
                    temp_result[i][j] = temp_result[i][j] + (a_mat[i][k] * b_mat[k][j]);
                end
            end
        end
        
        // Flatten result matrix (Correct indexing order)
        for (i = 0; i < 5; i = i + 1) begin
            for (j = 0; j < 5; j = j + 1) begin
                result[(j*5 + i)*16 +: 16] = temp_result[i][j];
            end
        end
    end
endmodule

module test_MpuMul;
    reg [`MATRIX8_5x5] matrix_a;
    reg [`MATRIX8_5x5] matrix_b;
    wire [`MATRIX16_5x5] result;
    reg [`INTEGER_8] size;
    
    MpuMul uut (
        .matrix_a(matrix_a),
        .matrix_b(matrix_b),
        .result(result)
    );
    
    initial begin
        size = 5;
        
        // Example test case
        matrix_a = {`i8(1), `i8(6), `i8(11), `i8(16), `i8(21),
                    `i8(2), `i8(7), `i8(12), `i8(17), `i8(22),
                    `i8(3), `i8(8), `i8(13), `i8(18), `i8(23),
                    `i8(4), `i8(9), `i8(14), `i8(19), `i8(24),
                    `i8(5), `i8(10), `i8(15), `i8(20), `i8(25)};
                    
        matrix_b = {`i8(1), `i8(0), `i8(0), `i8(0), `i8(0),
                    `i8(0), `i8(1), `i8(0), `i8(0), `i8(0),
                    `i8(0), `i8(0), `i8(1), `i8(0), `i8(0),
                    `i8(0), `i8(0), `i8(0), `i8(1), `i8(0),
                    `i8(0), `i8(0), `i8(0), `i8(0), `i8(1)};
        
        run_test();
        #10 $finish;
    end
    
    task display8_matrix;
        input [`MATRIX8_5x5] matrix;
        input [`INTEGER_8] size;
        integer i, j;
        begin
            for (i = 0; i < size; i = i + 1) begin
                for (j = 0; j < size; j = j + 1) begin
                    $write("%4d", matrix[`at(i, j) +: 8]);
                end
                $write("\n");
            end
        end
    endtask
    
    task display16_matrix;
        input [`MATRIX16_5x5] matrix;
        input [`INTEGER_8] size;
        integer i, j;
        begin
            for (i = 0; i < size; i = i + 1) begin
                for (j = 0; j < size; j = j + 1) begin
                    $write("%4d", matrix[`at(i, j)*2 +: 16]);
                end
                $write("\n");
            end
        end
    endtask
    
    task run_test;
        begin
            #10;
            $display("------ TEST CASE --------");
            $display("Matrix A (matrix_a):");
            display8_matrix(matrix_a, size);
            $display("Matrix B (matrix_b):");
            display8_matrix(matrix_b, size);
            #10;
            $display("Matrix C (result):");
            display16_matrix(result, size);
            $display("-------------------------");
            #10;
        end
    endtask
endmodule