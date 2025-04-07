`define i8(x) 8'sd``x
`define ROW 0:((8*5)-1)
`define arrayOf(n) 0:((8*n)-1)
`define MATRIX_5x5  (8*25-1):0
`define INTEGER_8   7:0
`define at(row, col) ((row * (8 * 5)) + (col * 8))
`define mat(row, col) matrix[`at(row, col) +: 8]
`define atCol(col) (8 * col)


module MpuDet (
    input  signed [`MATRIX_5x5] matrix,
    input  signed [`INTEGER_8] size,

    output signed [`INTEGER_8] result
);

	assign result = 
		(size == 1)? 
			matrix[0 +: 8]
		: (size == 2)? 
			Det2(
				`mat(0, 0), `mat(0, 1), 
				`mat(1, 0), `mat(1, 1)
			)
		: (size == 3)?
			Det3(
				`mat(0, 0), `mat(0, 1), `mat(0, 2),
				`mat(1, 0), `mat(1, 1), `mat(1, 2),
				`mat(2, 0), `mat(2, 1), `mat(2, 2)
			)
		: 8'sd0;

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

