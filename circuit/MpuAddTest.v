`define _8_BITS 7:0
`define _16_BITS 15:0

`define i8Array(amount) (8 * amount)
`define highest(amount) (amount - 1)

module MpuAddTest (
    input  [`highest(`i8Array(25)):0] matrix_a,
    input  [`highest(`i8Array(25)):0] matrix_b,
    output [`highest(`i8Array(25)):0] result
);

    `define at(i, j) (i + 5*j)
    `define add_at(i, j) assign result[`at(i, j)] = matrix_a[`at(i, j)] + matrix_b[`at(i, j)]; 


    generate
        genvar i, j;
        for (i = 0; i < 5; i = i + 1) begin : row_loop
            for (j = 0; j < 5; j = j + 1) begin : col_loop
                `add_at(i ,j)
                $display("x[%0d][%0d] = %0d + %0d = %0d", i, j, matrix_a[`at(i, j)], matrix_b[`at(i, j)], result[`at(i, j)]);
            end
        end
    endgenerate

    // Display the matrices before adding (initial block)
    initial begin
        $display("Matrix A (matrix_a):");
        display_matrix(matrix_a);
        $display("Matrix B (matrix_b):");
        display_matrix(matrix_b);
    end

    // Display the result matrix after adding (initial block)
    initial begin
        #1; // Wait for the addition to complete
        $display("Matrix C (result):");
        display_matrix(result);
    end

    // Helper task to display a matrix
    task display_matrix;
        input [`highest(`i8Array(25)):0] matrix; // Flattened 1D matrix (5x5)
        integer i;
        begin
            for (i = 0; i < 5; i = i + 1) begin
                $display("%0d\t%0d\t%0d\t%0d\t%0d", 
                    matrix[`at(0, i)], 
                    matrix[`at(1, i)], 
                    matrix[`at(2, i)], 
                    matrix[`at(3, i)], 
                    matrix[`at(4, i)]
                );
            end
        end
    endtask


endmodule
