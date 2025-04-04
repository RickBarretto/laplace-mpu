`define i8(x) 8'sd``x
`define ROW 0:((8*5)-1)
`define arrayOf(n) 0:((8*n)-1)
`define MATRIX_5x5  0:(8*25-1)
`define INTEGER_8   7:0
`define at(row, col) ((row * (8 * 5)) + (col * 8))
`define atCol(col) (8 * col)


module MpuDet (
    input  signed [`MATRIX_5x5] matrix,
    input  signed [`INTEGER_8] size,
	input clock,

    output reg signed [`INTEGER_8] result
);

    wire signed [`ROW] row1;
    wire signed [`ROW] row2;
    wire signed [`ROW] row3;
    wire signed [`ROW] row4;
    wire signed [`ROW] row5;

    assign row1 = matrix[`at(0, 0) +: (8*5)];
    assign row2 = matrix[`at(1, 0) +: (8*5)];
    assign row3 = matrix[`at(2, 0) +: (8*5)];
    assign row4 = matrix[`at(3, 0) +: (8*5)];
    assign row5 = matrix[`at(4, 0) +: (8*5)];
	 
	 wire signed [`INTEGER_8] det4;
	 wire signed [`INTEGER_8] det5;

	MpuDet4 mpud4(row1, row2, row3, row4, clock, det4);
	MpuDet5 mpud5(row1, row2, row3, row4, row5, clock, det5);


	always @(posedge clock) begin
		if (size == 1) result <= matrix[0 +: 8];
		else if (size == 2) result <= 
				matrix[0 +: 8] * matrix[`at(1, 1) +: 8] 
				- matrix[`at(0, 1) +: 8] * matrix[`at(1, 0) +: 8];
		else if (size == 3) result <= 
				matrix[`at(0, 0) +: 8] * matrix[`at(1, 1) +: 8] * matrix[`at(2, 2) +: 8]
				- matrix[`at(0, 1) +: 8] * matrix[`at(1, 2) +: 8] * matrix[`at(2, 0) +: 8]
				+ matrix[`at(0, 2) +: 8] * matrix[`at(1, 0) +: 8] * matrix[`at(2, 1) +: 8];
		else if (size == 4) result <= det4;
		else if (size == 5) result <= det5;
		else result <= 0;
	end

endmodule

module MpuDet4(
	input signed [`arrayOf(4)] row1,
    input signed [`arrayOf(4)] row2,
	input signed [`arrayOf(4)] row3,
	input signed [`arrayOf(4)] row4,

	input clock,

	output reg signed [`INTEGER_8] result
);

	reg [`INTEGER_8] diagonals[0:3];

	integer i = 0;

	always @(posedge clock) begin
		if (i < 4) begin
			diagonals[i] <= row1[i*8 +: 8] * Det3(
				row2[`atCol(i+1 % 4) +: 8], row2[`atCol(i+2 % 4) +: 8], row2[`atCol(i+3 % 4) +: 8],
				row3[`atCol(i+1 % 4) +: 8], row3[`atCol(i+2 % 4) +: 8], row3[`atCol(i+3 % 4) +: 8], 
				row4[`atCol(i+1 % 4) +: 8], row4[`atCol(i+2 % 4) +: 8], row4[`atCol(i+3 % 4) +: 8]);

			i <= i + 1;
		end else begin
			result <= diagonals[0] - diagonals[1] + diagonals[2] - diagonals[3];
		end
	end

	function [`INTEGER_8] Det3;
		input [`INTEGER_8] a11, a12, a13;
		input [`INTEGER_8] a21, a22, a23;
		input [`INTEGER_8] a31, a32, a33;

		begin
			Det3 = (a11 * a22 * a33) - (a13 * a22 * a31)
				 + (a12 * a23 * a31) - (a12 * a21 * a33)
				 + (a13 * a21 * a32) - (a11 * a23 * a32);
		end
	endfunction

endmodule


module MpuDet5(
	input signed [`arrayOf(5)] row1,
   input signed [`arrayOf(5)] row2,
	input signed [`arrayOf(5)] row3,
	input signed [`arrayOf(5)] row4,
	input signed [`arrayOf(5)] row5,
	
	input clock,

	output reg signed [`INTEGER_8] result
);

	reg [`INTEGER_8] diagonals[0:4];

	integer i = 0;

	always @(posedge clock) begin
		if (i < 5) begin
			diagonals[i] <= row1[i*8 +: 8] * Det4(
				{row2[`atCol(i+1 % 5) +: 8], row2[`atCol(i+2 % 5) +: 8], row2[`atCol(i+3 % 5) +: 8], row2[`atCol(i+4 % 5) +: 8]},
				{row3[`atCol(i+1 % 5) +: 8], row3[`atCol(i+2 % 5) +: 8], row3[`atCol(i+3 % 5) +: 8], row3[`atCol(i+4 % 5) +: 8]}, 
				{row4[`atCol(i+1 % 5) +: 8], row4[`atCol(i+2 % 5) +: 8], row4[`atCol(i+3 % 5) +: 8], row4[`atCol(i+4 % 5) +: 8]},
				{row5[`atCol(i+1 % 5) +: 8], row5[`atCol(i+2 % 5) +: 8], row5[`atCol(i+3 % 5) +: 8], row5[`atCol(i+4 % 5) +: 8]});

			i <= i + 1;
		end else begin
			result <= diagonals[0] - diagonals[1] + diagonals[2] - diagonals[3] + diagonals[4];
		end
	end
	
	function [`INTEGER_8] Det3;
		input [`INTEGER_8] a11, a12, a13;
		input [`INTEGER_8] a21, a22, a23;
		input [`INTEGER_8] a31, a32, a33;

		begin
			Det3 = (a11 * a22 * a33) - (a13 * a22 * a31)
				 + (a12 * a23 * a31) - (a12 * a21 * a33)
				 + (a13 * a21 * a32) - (a11 * a23 * a32);
		end
	endfunction

	function [`INTEGER_8] Det4;
		input signed [`arrayOf(4)] row1;
		input signed [`arrayOf(4)] row2;
		input signed [`arrayOf(4)] row3;
		input signed [`arrayOf(4)] row4;

		begin
			// a b c d
			// e f g h
			// i j k l
			// m n o p

			Det4 = row1[0*8 +: 8] * Det3(
					row2[`atCol(1) +: 8], row2[`atCol(2) +: 8], row2[`atCol(3) +: 8],
					row3[`atCol(1) +: 8], row3[`atCol(2) +: 8], row3[`atCol(3) +: 8], 
					row4[`atCol(1) +: 8], row4[`atCol(2) +: 8], row4[`atCol(3) +: 8])
				- row1[1*8 +: 8] * Det3(
					row2[`atCol(0) +: 8], row2[`atCol(2) +: 8], row2[`atCol(3) +: 8],
					row3[`atCol(0) +: 8], row3[`atCol(2) +: 8], row3[`atCol(3) +: 8], 
					row4[`atCol(0) +: 8], row4[`atCol(2) +: 8], row4[`atCol(3) +: 8])
				+ row1[2*8 +: 8] * Det3(
					row2[`atCol(0) +: 8], row2[`atCol(1) +: 8], row2[`atCol(3) +: 8],
					row3[`atCol(0) +: 8], row3[`atCol(1) +: 8], row3[`atCol(3) +: 8], 
					row4[`atCol(0) +: 8], row4[`atCol(1) +: 8], row4[`atCol(3) +: 8])
				- row1[3*8 +: 8] * Det3(
					row2[`atCol(0) +: 8], row2[`atCol(1) +: 8], row2[`atCol(2) +: 8],
					row3[`atCol(0) +: 8], row3[`atCol(1) +: 8], row3[`atCol(2) +: 8], 
					row4[`atCol(0) +: 8], row4[`atCol(1) +: 8], row4[`atCol(2) +: 8]);
		end
	endfunction

endmodule