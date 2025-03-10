`define _8_BITS 7:0
`define _16_BITS 15:0

module MpuDet (
    matrix,
    size,

    determinant
);

    // IO definition
    // -------------

    input [_8_BITS] matrix[4:0][4:0]; // 5x5 of 8 bits each
    input [_8_BITS] size;               // size of the matrix

    output [_16_BITS] determinant;      // 16 bits output

    // Internal Wires definition
    // -------------------------

    wire [_16_BITS] products[4:0];

    ProductOperation(matrix, size, products);
    SumOperation(products, determinant);

endmodule



module ProductOperation(
    input [_8_BITS] matrix[4:0][4:0],
    input [_8_BITS] size,
    output [_16_BITS] products[1:0][4:0]
);

    `define at(i, j) matrix[(i)][(j)]
    `define prod1(x1)                 (x1)
    `define prod2(x1, x2)             (x1) * (x2)
    `define prod3(x1, x2, x3)         (x1) * (x2) * (x3)
    `define prod4(x1, x2, x3, x4)     (x1) * (x2) * (x3) * (x4)
    `define prod5(x1, x2, x3, x4, x5) (x1) * (x2) * (x3) * (x4) * (x5)

    case (size)
        1: 
            // 00 .. ..
            // .. .. ..
            // .. .. ..
            out[0][0] = `prod1(`at(0, 0));
            
            // Clear
            out[0][1] = 0;
            out[0][2] = 0;
            out[0][3] = 0;
            out[0][4] = 0;
            
            out[1][0] = 0;
            out[1][1] = 0;
            out[1][2] = 0;
            out[1][3] = 0;
            out[1][4] = 0;
        2:
            // 00 01 ..
            // 10 11 ..
            // .. .. ..
            out[0][0] = `prod2(`at(0, 0), `at(1, 1));   // Main diagonal
            out[1][0] = `prod2(`at(0, 1), `at(1, 0));   // Secondary diagonal
                
            // Clear
            out[0][1] = 0;
            out[0][2] = 0;
            out[0][3] = 0;
            out[0][4] = 0;
            
            out[1][1] = 0;
            out[1][2] = 0;
            out[1][3] = 0;
            out[1][4] = 0;
        3:
            // 00 01 02 ..
            // 10 11 12 ..
            // 20 21 22 ..
            // .. .. .. ..

            out[0][0] = `prod3(`at(0, 0), `at(1, 1), `at(2, 2));
            out[0][1] = `prod3(`at(0, 1), `at(1, 2), `at(2, 0));
            out[0][2] = `prod3(`at(0, 2), `at(1, 0), `at(2, 1));

            out[1][0] = `prod3(`at(0, 2), `at(1, 1), `at(2, 0));
            out[1][1] = `prod3(`at(0, 1), `at(1, 0), `at(2, 2));
            out[1][2] = `prod3(`at(0, 0), `at(1, 2), `at(2, 1));
            
            out[0][3] = 0;
            out[0][4] = 0;
            out[1][3] = 0;
            out[1][4] = 0;
        4:
            // 00 01 02 03 ..
            // 10 11 12 13 ..
            // 20 21 22 23 ..
            // 30 31 32 33 ..
            // .. .. .. .. ..
            out[0][0] = `prod4(`at(0, 0), `at(1, 1), `at(2, 2), `at(3, 3));
            out[0][1] = `prod4(`at(0, 1), `at(1, 2), `at(2, 3), `at(3, 0));
            out[0][2] = `prod4(`at(0, 2), `at(1, 3), `at(2, 0), `at(3, 1));
            out[0][3] = `prod4(`at(0, 3), `at(1, 0), `at(2, 1), `at(3, 2));
            
            out[1][0] = `prod4(`at(0, 3), `at(1, 2), `at(2, 1), `at(3, 0));
            out[1][1] = `prod4(`at(0, 2), `at(1, 1), `at(2, 0), `at(3, 3));
            out[1][2] = `prod4(`at(0, 1), `at(1, 0), `at(2, 3), `at(3, 2));
            out[1][3] = `prod4(`at(0, 0), `at(1, 3), `at(2, 2), `at(3, 1));
            
            out[0][4] = 0;
            out[1][4] = 0;
        5:
            // Main Diagonals
            out[0][0] = `prod5(`at(0, 0), `at(1, 1), `at(2, 2), `at(3, 3), `at(4, 4));
            out[0][1] = `prod5(`at(0, 1), `at(1, 2), `at(2, 3), `at(3, 4), `at(4, 0));
            out[0][2] = `prod5(`at(0, 2), `at(1, 3), `at(2, 4), `at(3, 0), `at(4, 1));
            out[0][3] = `prod5(`at(0, 3), `at(1, 4), `at(2, 0), `at(3, 1), `at(4, 2));
            out[0][4] = `prod5(`at(0, 4), `at(1, 0), `at(2, 1), `at(3, 2), `at(4, 3));
            
            // Secondary Diagonals
            out[1][0] = `prod5(`at(0, 4), `at(1, 3), `at(2, 2), `at(3, 1), `at(4, 0));
            out[1][1] = `prod5(`at(0, 3), `at(1, 2), `at(2, 1), `at(3, 0), `at(4, 4));
            out[1][2] = `prod5(`at(0, 2), `at(1, 1), `at(2, 0), `at(3, 4), `at(4, 3));
            out[1][3] = `prod5(`at(0, 1), `at(1, 0), `at(2, 4), `at(3, 3), `at(4, 2));
            out[1][4] = `prod5(`at(0, 0), `at(1, 4), `at(2, 3), `at(3, 2), `at(4, 1));
        default: 
            out[0][0] = 0;
            out[0][1] = 0;
            out[0][2] = 0;
            out[0][3] = 0;
            out[0][4] = 0;
            out[1][0] = 0;
            out[1][1] = 0;
            out[1][2] = 0;
            out[1][3] = 0;
            out[1][4] = 0;
    endcase

endmodule



module SumOperation(
    input [_16_BITS] products[1:0][4:0],
    output [_16_BITS] sum
);

    `define difference(i) assign diff[(i)] = products[0][(i)] - products[1][(i)];

    wire [_16_BITS] diff[4:0];

    `difference(0)
    `difference(1)
    `difference(2)
    `difference(3)
    `difference(4)

    assign sum = diff[0] + diff[1] + diff[2] + diff[3] + diff[4];

endmodule