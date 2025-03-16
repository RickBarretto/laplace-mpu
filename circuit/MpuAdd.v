`define _8_BITS 7:0
`define _16_BITS 15:0

module MpuAdd (
    matrix_a,
    matrix_b,

    result
);
    input  [`_8_BITS] matrix_a[4:0][4:0];
    input  [`_8_BITS] matrix_b[4:0][4:0];
    output [`_8_BITS]   result[4:0][4:0];

    AdditionOperation(matrix_a, matrix_b, result);

endmodule


module AdditionOperation (
    input  [`_8_BITS]   x[4:0][4:0],
    input  [`_8_BITS]   y[4:0][4:0],
    output [`_8_BITS] out[4:0][4:0]
);
    `define add_at(i, j) assign out[i][j] = x[i][j] + y[i][j];


    initial begin
        $display("Matrix A (x):");
        $display_matrix(x);
        $display("Matrix B (y):");
        $display_matrix(y);
    end

    initial begin
        #1;  // Ensure the addition is performed first
        $display("Matrix C (out):");
        $display_matrix(out);
    end

    `add_at(0, 0)
    `add_at(0, 1)
    `add_at(0, 2)
    `add_at(0, 3)
    `add_at(0, 4)

    `add_at(1, 0)
    `add_at(1, 1)
    `add_at(1, 2)
    `add_at(1, 3)
    `add_at(1, 4)

    `add_at(2, 0)
    `add_at(2, 1)
    `add_at(2, 2)
    `add_at(2, 3)
    `add_at(2, 4)

    `add_at(3, 0)
    `add_at(3, 1)
    `add_at(3, 2)
    `add_at(3, 3)
    `add_at(3, 4)

    `add_at(4, 0)
    `add_at(4, 1)
    `add_at(4, 2)
    `add_at(4, 3)
    `add_at(4, 4)

    task $display_matrix;
        input [4:0][4:0] matrix;
        integer i, j;
        begin
            for (i = 0; i < 5; i = i + 1) begin
                for (j = 0; j < 5; j = j + 1) begin
                    $display("matrix[%0d][%0d] = %0d", i, j, matrix[i][j]);
                end
            end
        end
    endtask

endmodule
