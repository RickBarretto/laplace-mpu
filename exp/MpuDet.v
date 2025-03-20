`define i8(x) 8'sd``x
`define ROW 0:((8*5)-1)
`define arrayOf(n) 0:((8*n)-1)
`define MATRIX_5x5  0:(8*25-1)
`define INTEGER_8   7:0
`define at(row, col) (8 * (col + 5*row))
`define atCol(col) (8 * col)


module MpuDet (
    input  signed [`MATRIX_5x5] matrix,
    input  signed [`INTEGER_8] size,
    output signed [`INTEGER_8] result
);

    wire signed [`ROW] row1;
    wire signed [`ROW] row2;
    wire signed [`ROW] row3;
    wire signed [`ROW] row4;
    wire signed [`ROW] row5;

    wire signed [`INTEGER_8] det2;
    wire signed [`INTEGER_8] det3;
    wire signed [`INTEGER_8] det4;
    wire signed [`INTEGER_8] det5;

    assign row1 = matrix[`at(0, 0) +: (8*5)];
    assign row2 = matrix[`at(1, 0) +: (8*5)];
    assign row3 = matrix[`at(2, 0) +: (8*5)];
    assign row4 = matrix[`at(3, 0) +: (8*5)];
    assign row5 = matrix[`at(4, 0) +: (8*5)];

    Det2 det_instance2x2 (row1[0 +: 8*2], row2[0 +: 8*2], det2);
    Det3 det_instance3x3 (row1[0 +: 8*3], row2[0 +: 8*3], row3[0 +: 8*3], det3);
    Det4 det_instance4x4 (row1[0 +: 8*4], row2[0 +: 8*4], row3[0 +: 8*4], row4[0 +: 8*4], det4);
    Det5 det_instance5x5 (row1[0 +: 8*5], row2[0 +: 8*5], row3[0 +: 8*5], row4[0 +: 8*5], row5[0 +: 8*5], det5);

    assign result = 
        (size == 1)? matrix[0 +: 8]
        : (size == 2)? det2 
        : (size == 3)? det3
        : (size == 4)? det4
        : (size == 5)? det5
        : 0;

endmodule


module Det2(
    input signed [`arrayOf(2)] row1,
    input signed [`arrayOf(2)] row2,

    output signed [`INTEGER_8] result
);

    // a b
    // c d

    wire [7:0] a;
    wire [7:0] b;
    wire [7:0] c;
    wire [7:0] d;

    assign a = row1[0 +: 8];
    assign b = row1[8 +: 8];
    assign c = row2[0 +: 8];
    assign d = row2[8 +: 8];

    assign result = 
        a * d - b * c;

endmodule


module Det3(
    input signed [`arrayOf(3)] row1,
    input signed [`arrayOf(3)] row2,
    input signed [`arrayOf(3)] row3,

    output signed [`INTEGER_8] result
);

    // a b c
    // d e f
    // g h i

    wire [7:0] a;
    wire [7:0] b;
    wire [7:0] c;

    wire [7:0] a_partial; 
    wire [7:0] b_partial; 
    wire [7:0] c_partial;

    assign a = row1[`at(0, 0) +: 8];
    assign b = row1[`at(0, 1) +: 8];
    assign c = row1[`at(0, 2) +: 8];

    Det2 det_a(
        {row2[`atCol(1) +: 8], row2[`atCol(2) +: 8]},
        {row3[`atCol(1) +: 8], row3[`atCol(2) +: 8]}, 
        a_partial
    );

    Det2 det_b(
        {row2[`atCol(0) +: 8], row2[`atCol(2) +: 8]},
        {row3[`atCol(0) +: 8], row3[`atCol(2) +: 8]},
        b_partial
    );

    Det2 det_c(
        {row2[`atCol(0) +: 8], row2[`atCol(1) +: 8]},
        {row3[`atCol(0) +: 8], row3[`atCol(1) +: 8]},
        c_partial
    );

    assign result =
        a * a_partial - b * b_partial + c * c_partial;
    

endmodule


module Det4(
    input signed [`arrayOf(4)] row1,
    input signed [`arrayOf(4)] row2,
    input signed [`arrayOf(4)] row3,
    input signed [`arrayOf(4)] row4,

    output signed [`INTEGER_8] result
);

    // a b c d
    // e f g h
    // i j k l
    // m n o p

    wire [7:0] a;
    wire [7:0] b;
    wire [7:0] c;
    wire [7:0] d;

    wire [7:0] a_partial; 
    wire [7:0] b_partial; 
    wire [7:0] c_partial;
    wire [7:0] d_partial;

    assign a = row1[`at(0, 0) +: 8];
    assign b = row1[`at(0, 1) +: 8];
    assign c = row1[`at(0, 2) +: 8];
    assign d = row1[`at(0, 3) +: 8];

    Det3 det_a(
        {row2[`atCol(1) +: 8], row2[`atCol(2) +: 8], row2[`atCol(3) +: 8]},
        {row3[`atCol(1) +: 8], row3[`atCol(2) +: 8], row3[`atCol(3) +: 8]}, 
        {row4[`atCol(1) +: 8], row4[`atCol(2) +: 8], row4[`atCol(3) +: 8]}, 
        a_partial
    );

    Det3 det_b(
        {row2[`atCol(0) +: 8], row2[`atCol(2) +: 8], row2[`atCol(3) +: 8]},
        {row3[`atCol(0) +: 8], row3[`atCol(2) +: 8], row3[`atCol(3) +: 8]}, 
        {row4[`atCol(0) +: 8], row4[`atCol(2) +: 8], row4[`atCol(3) +: 8]}, 
        b_partial
    );

    Det3 det_c(
        {row2[`atCol(0) +: 8], row2[`atCol(1) +: 8], row2[`atCol(3) +: 8]},
        {row3[`atCol(0) +: 8], row3[`atCol(1) +: 8], row3[`atCol(3) +: 8]}, 
        {row4[`atCol(0) +: 8], row4[`atCol(1) +: 8], row4[`atCol(3) +: 8]}, 
        c_partial
    );
    
    Det3 det_d(
        {row2[`atCol(0) +: 8], row2[`atCol(1) +: 8], row2[`atCol(2) +: 8]},
        {row3[`atCol(0) +: 8], row3[`atCol(1) +: 8], row3[`atCol(2) +: 8]}, 
        {row4[`atCol(0) +: 8], row4[`atCol(1) +: 8], row4[`atCol(2) +: 8]}, 
        d_partial
    );

    assign result =
        a * a_partial - b * b_partial 
        + c * c_partial - d * d_partial;
    

endmodule


module Det5(
    input signed [`arrayOf(5)] row1,
    input signed [`arrayOf(5)] row2,
    input signed [`arrayOf(5)] row3,
    input signed [`arrayOf(5)] row4,
    input signed [`arrayOf(5)] row5,

    output signed [`INTEGER_8] result
);

    // a b c d e
    // f g h i j
    // k l m n o
    // p q r s t
    // u v w x y

    wire [7:0] a;
    wire [7:0] b;
    wire [7:0] c;
    wire [7:0] d;
    wire [7:0] e;

    wire [7:0] a_partial; 
    wire [7:0] b_partial; 
    wire [7:0] c_partial;
    wire [7:0] d_partial;
    wire [7:0] e_partial;

    assign a = row1[`at(0, 0) +: 8];
    assign b = row1[`at(0, 1) +: 8];
    assign c = row1[`at(0, 2) +: 8];
    assign d = row1[`at(0, 3) +: 8];
    assign e = row1[`at(0, 4) +: 8];

    Det4 det_a(
        {row2[`atCol(1) +: 8], row2[`atCol(2) +: 8], row2[`atCol(3) +: 8], row2[`atCol(4) +: 8]},
        {row3[`atCol(1) +: 8], row3[`atCol(2) +: 8], row3[`atCol(3) +: 8], row3[`atCol(4) +: 8]}, 
        {row4[`atCol(1) +: 8], row4[`atCol(2) +: 8], row4[`atCol(3) +: 8], row4[`atCol(4) +: 8]}, 
        {row5[`atCol(1) +: 8], row5[`atCol(2) +: 8], row5[`atCol(3) +: 8], row5[`atCol(4) +: 8]}, 
        a_partial
    );

    Det4 det_b(
        {row2[`atCol(0) +: 8], row2[`atCol(2) +: 8], row2[`atCol(3) +: 8], row2[`atCol(4) +: 8]},
        {row3[`atCol(0) +: 8], row3[`atCol(2) +: 8], row3[`atCol(3) +: 8], row3[`atCol(4) +: 8]}, 
        {row4[`atCol(0) +: 8], row4[`atCol(2) +: 8], row4[`atCol(3) +: 8], row4[`atCol(4) +: 8]}, 
        {row5[`atCol(0) +: 8], row5[`atCol(2) +: 8], row5[`atCol(3) +: 8], row5[`atCol(4) +: 8]},  
        b_partial
    );

    Det4 det_c(
        {row2[`atCol(0) +: 8], row2[`atCol(1) +: 8], row2[`atCol(3) +: 8], row2[`atCol(4) +: 8]},
        {row3[`atCol(0) +: 8], row3[`atCol(1) +: 8], row3[`atCol(3) +: 8], row3[`atCol(4) +: 8]}, 
        {row4[`atCol(0) +: 8], row4[`atCol(1) +: 8], row4[`atCol(3) +: 8], row4[`atCol(4) +: 8]}, 
        {row5[`atCol(0) +: 8], row5[`atCol(1) +: 8], row5[`atCol(3) +: 8], row5[`atCol(4) +: 8]}, 
        c_partial
    );
    
    Det4 det_d(
        {row2[`atCol(0) +: 8], row2[`atCol(1) +: 8], row2[`atCol(2) +: 8], row2[`atCol(4) +: 8]},
        {row3[`atCol(0) +: 8], row3[`atCol(1) +: 8], row3[`atCol(2) +: 8], row3[`atCol(4) +: 8]}, 
        {row4[`atCol(0) +: 8], row4[`atCol(1) +: 8], row4[`atCol(2) +: 8], row4[`atCol(4) +: 8]}, 
        {row5[`atCol(0) +: 8], row5[`atCol(1) +: 8], row5[`atCol(2) +: 8], row5[`atCol(4) +: 8]}, 
        d_partial
    );
   
    Det4 det_e(
        {row2[`atCol(0) +: 8], row2[`atCol(1) +: 8], row2[`atCol(2) +: 8], row2[`atCol(3) +: 8]},
        {row3[`atCol(0) +: 8], row3[`atCol(1) +: 8], row3[`atCol(2) +: 8], row3[`atCol(3) +: 8]}, 
        {row4[`atCol(0) +: 8], row4[`atCol(1) +: 8], row4[`atCol(2) +: 8], row4[`atCol(3) +: 8]}, 
        {row5[`atCol(0) +: 8], row5[`atCol(1) +: 8], row5[`atCol(2) +: 8], row5[`atCol(3) +: 8]}, 
        e_partial
    );

    assign result =
        a * a_partial - b * b_partial 
        + c * c_partial - d * d_partial + e * e_partial;
    

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
        matrix = { `i8(3), -`i8(1), `i8(0), `i8(0), `i8(0),
                   `i8(4), `i8(3), `i8(0), `i8(0), `i8(0),
                   `i8(0), `i8(0), `i8(0), `i8(0), `i8(0),
                   `i8(0), `i8(0), `i8(0), `i8(0), `i8(0),
                   `i8(0), `i8(0), `i8(0), `i8(0), `i8(0)};
        size = `i8(2);
        run_test();
        
        // Test Case 2: 4x4 Matrix
        matrix = { `i8(1), `i8(2), `i8(3), `i8(4), `i8(0),
                   `i8(5), `i8(6), `i8(7), `i8(8), `i8(0),
                   `i8(2), `i8(1), `i8(2), `i8(1), `i8(0),
                   `i8(2), `i8(2), `i8(1), `i8(6), `i8(0),
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
        integer row, col;
        begin
            for (row = 0; row < size; row = row + 1) begin
                for (col = 0; col < size; col = col + 1) begin
                    $write("%4d ", $signed(matrix[`at(row, col) +: 8])); // Print elements in the same row
                end
                $display(""); // Move to the next row
            end
        end
    endtask

endmodule
