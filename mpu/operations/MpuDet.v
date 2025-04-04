`define i8(x) 8'sd``x
`define ROW 0:((8*5)-1)
`define arrayOf(n) 0:((8*n)-1)
`define MATRIX_5x5  0:(8*25-1)
`define INTEGER_8   7:0
`define at(row, col) ((row * (8 * 5)) + (col * 8))
`define mat(row, col) matrix[`at(row, col) +: 8]
`define atCol(col) (8 * col)


module MpuDet (
    input  signed [`MATRIX_5x5] matrix,
    input  signed [`INTEGER_8] size,
	input clock,

    output reg signed [`INTEGER_8] result
);
	 
	wire signed [`INTEGER_8] det4;
	wire signed [`INTEGER_8] det5;

	MpuDet4 mpud4(matrix, clock, det4);
	MpuDet5 mpud5(matrix, clock, det5);

	always @(posedge clock) begin
		if (size == 1) result <= matrix[0 +: 8];
		else if (size == 2) 
			result <= Det2(
				`mat(0, 0), `mat(0, 1), 
				`mat(1, 0), `mat(1, 1)
			);
		else if (size == 3) 
			result <= Det3(
				`mat(0, 0), `mat(0, 1), `mat(0, 2),
				`mat(1, 0), `mat(1, 1), `mat(1, 2),
				`mat(2, 0), `mat(2, 1), `mat(2, 2)
			);
		else if (size == 4) 
			result <= det4;
		else if (size == 5) 
			result <= det5;
		else 
			result <= 0;
	end

	function [`INTEGER_8] Det2;
		input [`INTEGER_8] a11, a12;
		input [`INTEGER_8] a21, a22;

		begin
			Det2 = (a11 * a22) - (a12 * a21);
		end
	endfunction

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

module MpuDet4(
	input signed [`MATRIX_5x5] matrix,
	input clock,

	output reg signed [`INTEGER_8] result
);

	reg [`INTEGER_8] diagonals[0:3];
	integer i = 0;

	always @(posedge clock) begin
		if (i < 4) begin
			diagonals[i] <= `mat(0, i) * Det3(
				`mat(1, (i+1)%4), `mat(1, (i+2)%4), `mat(1, (i+3)%4),
				`mat(2, (i+1)%4), `mat(2, (i+2)%4), `mat(2, (i+3)%4),
				`mat(3, (i+1)%4), `mat(3, (i+2)%4), `mat(3, (i+3)%4)
			);

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
	input signed [`MATRIX_5x5] matrix,	
	input clock,

	output reg signed [`INTEGER_8] result
);

	reg [`INTEGER_8] diagonals[0:4];
	integer i = 0;

	always @(posedge clock) begin
		if (i < 5) begin
			diagonals[i] <= `mat(0, i) * Det4(
				`mat(1, (i+1)%5), `mat(1, (i+2)%5), `mat(1, (i+3)%5), `mat(1, (i+4)%5),
				`mat(2, (i+1)%5), `mat(2, (i+2)%5), `mat(2, (i+3)%5), `mat(2, (i+4)%5),
				`mat(3, (i+1)%5), `mat(3, (i+2)%5), `mat(3, (i+3)%5), `mat(3, (i+4)%5),
				`mat(3, (i+1)%5), `mat(3, (i+2)%5), `mat(3, (i+3)%5), `mat(3, (i+4)%5)
			);

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
		input [`INTEGER_8] a11, a12, a13, a14;
		input [`INTEGER_8] a21, a22, a23, a24;
		input [`INTEGER_8] a31, a32, a33, a34;
		input [`INTEGER_8] a41, a42, a43, a44;

		begin
			Det4 = a11 * Det3(
					a22, a23, a24,
					a32, a33, a34,
					a42, a43, a44
				)
				- a12 * Det3(
					a21, a23, a24,
					a31, a33, a34,
					a41, a43, a44
				)
				+ a13 * Det3(
					a21, a22, a24,
					a31, a32, a34,
					a41, a42, a44
				)
				- a14 * Det3(
					a21, a22, a23,
					a31, a32, a33,
					a41, a42, a43
				);
		end
	endfunction
endmodule