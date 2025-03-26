`define i8(x) 8'sd``x
`define INTEGER_8 7:0
`define MATRIX_5x5 (8*25-1):0
`define at(row, col) (8 * (col + 5*row))

module MpuMul (
    input      signed [`MATRIX_5x5] matrix_a, // Flattened 5x5 matrix (each element 8 bits)
    input      signed [`MATRIX_5x5] matrix_b, // Flattened 5x5 matrix (each element 8 bits)
	 
	 input clock,
	 
    output reg signed [`MATRIX_5x5] result   // Flattened 5x5 result matrix (each element 16 bits)
);
    
	 reg [`INTEGER_8] row;
	 
    always @(*) begin
		result[`at(row, 0) +: 8] <= 
			  matrix_a[`at(row, 0) +: 8] * matrix_b[`at(0, 0) +: 8]
			+ matrix_a[`at(row, 1) +: 8] * matrix_b[`at(1, 0) +: 8]
			+ matrix_a[`at(row, 2) +: 8] * matrix_b[`at(2, 0) +: 8]
			+ matrix_a[`at(row, 3) +: 8] * matrix_b[`at(3, 0) +: 8]
			+ matrix_a[`at(row, 4) +: 8] * matrix_b[`at(4, 0) +: 8];
			
			result[`at(row, 1) +: 8] <= 
			  matrix_a[`at(row, 0) +: 8] * matrix_b[`at(0, 1) +: 8]
			+ matrix_a[`at(row, 1) +: 8] * matrix_b[`at(1, 1) +: 8]
			+ matrix_a[`at(row, 2) +: 8] * matrix_b[`at(2, 1) +: 8]
			+ matrix_a[`at(row, 3) +: 8] * matrix_b[`at(3, 1) +: 8]
			+ matrix_a[`at(row, 4) +: 8] * matrix_b[`at(4, 1) +: 8];
			
		result[`at(row, 2) +: 8] <= 
			  matrix_a[`at(row, 0) +: 8] * matrix_b[`at(0, 2) +: 8]
			+ matrix_a[`at(row, 1) +: 8] * matrix_b[`at(1, 2) +: 8]
			+ matrix_a[`at(row, 2) +: 8] * matrix_b[`at(2, 2) +: 8]
			+ matrix_a[`at(row, 3) +: 8] * matrix_b[`at(3, 2) +: 8]
			+ matrix_a[`at(row, 4) +: 8] * matrix_b[`at(4, 2) +: 8];
			
		result[`at(row, 3) +: 8] <= 
			  matrix_a[`at(row, 0) +: 8] * matrix_b[`at(0, 3) +: 8]
			+ matrix_a[`at(row, 1) +: 8] * matrix_b[`at(1, 3) +: 8]
			+ matrix_a[`at(row, 2) +: 8] * matrix_b[`at(2, 3) +: 8]
			+ matrix_a[`at(row, 3) +: 8] * matrix_b[`at(3, 3) +: 8]
			+ matrix_a[`at(row, 4) +: 8] * matrix_b[`at(4, 3) +: 8];
			
		result[`at(row, 4) +: 8] <= 
			  matrix_a[`at(row, 0) +: 8] * matrix_b[`at(0, 4) +: 8]
			+ matrix_a[`at(row, 1) +: 8] * matrix_b[`at(1, 4) +: 8]
			+ matrix_a[`at(row, 2) +: 8] * matrix_b[`at(2, 4) +: 8]
			+ matrix_a[`at(row, 3) +: 8] * matrix_b[`at(3, 4) +: 8]
			+ matrix_a[`at(row, 4) +: 8] * matrix_b[`at(4, 4) +: 8];

		if (row == 4) begin
		  row <= 0;
		end else begin
		  row <= row + 1;
		end
    end
endmodule


module test_MpuMul;
    reg  signed [`MATRIX_5x5] matrix_a;
    reg  signed [`MATRIX_5x5] matrix_b;
    wire signed [`MATRIX_5x5] result;
    
    MpuMul uut (
        .matrix_a(matrix_a),
        .matrix_b(matrix_b),
        .clock(1'd0),
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
    
    task display_matrix;
        input signed [`MATRIX_5x5] matrix;
        input [`INTEGER_8] size;
        integer i, j;
        begin
            for (i = 0; i < size; i = i + 1) begin
                for (j = 0; j < size; j = j + 1) begin
                    $write("%4d", $signed(matrix[`at(i, j) +: 8]));
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
            display_matrix(matrix_a, size);
            $display("Matrix B (matrix_b):");
            display_matrix(matrix_b, size);
            #10;
            $display("Matrix C (result):");
            display_matrix(result, size);
            $display("-------------------------");
            #10;
        end
    endtask
endmodule