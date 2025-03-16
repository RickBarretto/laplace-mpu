`define i8arr(amount) (8 * amount)    // 8 bits per element
`define at(i, j) (8 * (i + 5*j))  // Access each 8-bit element in the 5x5 matrix

module MpuAdd (
    input  [`i8arr(25)-1:0] matrix_a,  // 5x5 matrix A flattened (each element is 8-bit)
    input  [`i8arr(25)-1:0] matrix_b,  // 5x5 matrix B flattened (each element is 8-bit)
    output reg [`i8arr(25)-1:0] result // 5x5 result matrix flattened (each element is 8-bit)
);

    always @* begin
        result = matrix_a + matrix_b; // Add matrix_a and matrix_b element-wise
    end

endmodule

module test_MpuAdd;

    // Declare the input and output arrays (flattened 1D arrays for 5x5 matrices)
    reg  [`i8arr(25)-1:0] matrix_a;    // 5x5 matrix A (flattened 1D array)
    reg  [`i8arr(25)-1:0] matrix_b;    // 5x5 matrix B (flattened 1D array)
    wire [`i8arr(25)-1:0] result;      // 5x5 result matrix (flattened 1D array)

    // Instantiate the MpuAdd module
    MpuAdd uut (
        .matrix_a(matrix_a),
        .matrix_b(matrix_b),
        .result(result)
    );

    // Testbench block to manually set the input values and display the result
    initial begin

        // Manually set values for matrix_a and matrix_b (use any 8-bit values)
        matrix_a = {8'd1, 8'd2, 8'd3, 8'd4, 8'd5, 
                    8'd6, 8'd7, 8'd8, 8'd9, 8'd10, 
                    8'd11, 8'd12, 8'd13, 8'd14, 8'd15, 
                    8'd16, 8'd17, 8'd18, 8'd19, 8'd20, 
                    8'd21, 8'd22, 8'd23, 8'd24, 8'd25};  // Initialize matrix_a

        matrix_b = {8'd25, 8'd24, 8'd23, 8'd22, 8'd21, 
                    8'd20, 8'd19, 8'd18, 8'd17, 8'd16, 
                    8'd15, 8'd14, 8'd13, 8'd12, 8'd11, 
                    8'd10, 8'd9, 8'd8, 8'd7, 8'd6, 
                    8'd5, 8'd4, 8'd3, 8'd2, 8'd1};  // Initialize matrix_b

        // Display the matrices before the addition
        $display("Matrix A (matrix_a):");
        display_matrix(matrix_a);

        $display("Matrix B (matrix_b):");
        display_matrix(matrix_b);

        // Wait for the addition to complete
        #1;
        
        // Display the result matrix after the addition
        $display("Result (matrix_c or result):");
        display_matrix(result);

        $finish;
    end

    // Task to display a flattened 5x5 matrix (accessing each 8-bit element)
    task display_matrix;
        input [`i8arr(25)-1:0] matrix;  // Flattened 1D matrix
        integer i, j;
        begin
            for (i = 0; i < 5; i = i + 1) begin
                // Accessing each 8-bit element using the correct bit-select
                $display("%4d %4d %4d %4d %4d", 
                    matrix[`at(i, 0) +: 8],  // Access 8-bit value at row i, column 0
                    matrix[`at(i, 1) +: 8],  // Access 8-bit value at row i, column 1
                    matrix[`at(i, 2) +: 8],  // Access 8-bit value at row i, column 2
                    matrix[`at(i, 3) +: 8],  // Access 8-bit value at row i, column 3
                    matrix[`at(i, 4) +: 8]   // Access 8-bit value at row i, column 4
                );
            end
        end
    endtask

endmodule
