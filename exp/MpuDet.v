`define i8(x) 8'sd``x                        // 8-bit integer
`define MATRIX_5x5  0:(8*25-1)              // 5x5 matrix's indexes
`define INTEGER_8   7:0                     // 8-bit integer indexes
`define at(col, row) (8 * (row + 5*col))    /// Access each 8-bit element in the 5x5 matrix

module MpuDet (
    input      signed [`MATRIX_5x5] matrix,  // 5x5 8-bit matrix
    input      signed [`INTEGER_8 ] size,    // 8-bit integer for the matrix size
    output reg signed [`INTEGER_8 ] result   // 8-bit output result
);

    reg signed [15:0] products [0:1][0:4];  // 2x5 matrix to store computed products
    integer i;

    always @(*) begin
        // Initialize products to 1 to avoid multiplication by zero
        for (i = 0; i < 5; i = i + 1) begin
            products[0][i] = 1;
            products[1][i] = 1;
        end

        case (size)
            1: products[0][0] = matrix[`at(0, 0) +: 8];
            2: begin
                products[0][0] = matrix[`at(0, 0) +: 8] * matrix[`at(1, 1) +: 8];
                products[1][0] = matrix[`at(0, 1) +: 8] * matrix[`at(1, 0) +: 8];
            end
            3: begin
                for (i = 0; i < 3; i = i + 1) begin
                    products[0][i] = matrix[`at(i, i) +: 8];
                    products[1][i] = matrix[`at(i, 2-i) +: 8];
                end
            end
            4: begin
                for (i = 0; i < 4; i = i + 1) begin
                    products[0][i] = matrix[`at(i, i) +: 8];
                    products[1][i] = matrix[`at(i, 3-i) +: 8];
                end
            end
            5: begin
                for (i = 0; i < 5; i = i + 1) begin
                    products[0][i] = matrix[`at(i, i) +: 8];
                    products[1][i] = matrix[`at(i, 4-i) +: 8];
                end
            end
        endcase
    end

    // Calculate the differences and sum them
    always @(*) begin
        result = 0;
        for (i = 0; i < 5; i = i + 1) begin
            result = result + (products[0][i] - products[1][i]);
        end
    end
endmodule

module test_MpuDet;

    reg  signed [`MATRIX_5x5] matrix;
    reg  signed [`INTEGER_8]  size;
    wire signed [`INTEGER_8] result;

    MpuDet det_operation (
        .matrix(matrix),
        .size(size),
        .result(result)
    );

    initial begin

        // Test Case 1: 2x2 Matrix
        matrix = { `i8(1), `i8(2), `i8(3), `i8(4), `i8(0),
                   `i8(0), `i8(0), `i8(0), `i8(0), `i8(0),
                   `i8(0), `i8(0), `i8(0), `i8(0), `i8(0),
                   `i8(0), `i8(0), `i8(0), `i8(0), `i8(0),
                   `i8(0), `i8(0), `i8(0), `i8(0), `i8(0)};
        size = `i8(2);
        run_test();
        
        // Test Case 2: 4x4 Matrix
        matrix = { `i8(1), `i8(2), `i8(3), `i8(4), `i8(0),
                   `i8(5), `i8(6), `i8(7), `i8(8), `i8(0),
                   `i8(9), `i8(10), `i8(11), `i8(12), `i8(0),
                   `i8(13), `i8(14), `i8(15), `i8(16), `i8(0),
                   `i8(0), `i8(0), `i8(0), `i8(0), `i8(0)};
        size = `i8(4);
        run_test();
        
        // Test Case 3: 5x5 Identity Matrix
        matrix = { `i8(1), `i8(0), `i8(0), `i8(0), `i8(0),
                   `i8(0), `i8(1), `i8(0), `i8(0), `i8(0),
                   `i8(0), `i8(0), `i8(1), `i8(0), `i8(0),
                   `i8(0), `i8(0), `i8(0), `i8(1), `i8(0),
                   `i8(0), `i8(0), `i8(0), `i8(0), `i8(1)};
        size = `i8(5);
        run_test();
        
        $finish;
    end

    task run_test;
        begin
            $display("------ TEST CASE --------");
            $display("Matrix A (matrix):");
            display_matrix(matrix, size);
            #1;
            $display("Result (result):");
            $display("%d", result);
            $display("-------------------------");
        end
    endtask

    task display_matrix;
        input signed [`MATRIX_5x5] matrix;
        input signed [`INTEGER_8] size;
        integer i, j;
        begin
            for (i = 0; i < size; i = i + 1) begin
                for (j = 0; j < size; j = j + 1) begin
                    $write("%4d ", $signed(matrix[`at(i, j) +: 8])); // Print elements in the same row
                end
                $display(""); // Move to the next row
            end
        end
    endtask

endmodule
