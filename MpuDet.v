`define i8(x) 8'sd``x
`define INTEGER_8 7:0
`define MATRIX_5x5 (8*25-1):0
`define ROW (8*5-1):0
`define at(row, col) (8 * (col + 5*row))
`define mat(row, col) matrix[`at(row, col) +: 8]

module MpuDet (
    input  signed [`MATRIX_5x5] matrix,
    input  signed [`INTEGER_8] size,
	 input clock,
    output reg signed [`INTEGER_8] result
);
	 
	 wire [7:0] high;
	 reg unsigned [7:0] i;
	 reg [7:0] products[0:1][0:4];
	 reg [7:0] diff[0:5];

	 assign high = size - 1;
	 
	 always @(posedge clock) begin
	 
		// Main Diagonals
		case (size)
		2: begin
			if (i < 1) begin
				products[0][0] <= `mat(0, 0) * `mat(1, 1);
			end
		end
		3: begin
			if (i < 3) begin
				products[0][i] <= 
				     `mat(0, i) 
					* `mat(1, (1+i)%high) 
					* `mat(2, (2+i)%high);
			end
		end
		4: begin
			if (i < 4) begin
				products[0][i] <= 
					  `mat(0, i) 
					* `mat(1, (1+i)%high) 
					* `mat(2, (2+i)%high) 
					* `mat(3, (3+i)%high);
			end
		end
		5: begin
			if (i < 5) begin
				products[0][i] <= 
					  `mat(0, i) 
					* `mat(1, (1+i)%high) 
					* `mat(2, (2+i)%high) 
					* `mat(3, (3+i)%high) 
					* `mat(4, (4+i)%high);
			end
		end
		endcase
		
		// Secondary Diagonals
		case (size)
		2: begin
			if (i < 1) begin
				products[1][0] <= `mat(0, 1) * `mat(1, 0);
			end
		end
		3: begin
			if (i < 3) begin
				products[1][i] <= 
				     `mat(0, (2-i)%high) 
					* `mat(1, (1-i)%high) 
					* `mat(2, (0-i)%high);
			end
		end
		4: begin
			if (i < 4) begin
				products[1][i] <= 
					  `mat(0, i) 
					* `mat(1, (3-i)%high) 
					* `mat(2, (2-i)%high) 
					* `mat(3, (1-i)%high);
			end
		end
		5: begin
			if (i < 5) begin
				products[1][i] <= 
					  `mat(0, i) 
					* `mat(1, (4-i)%high) 
					* `mat(2, (3-i)%high) 
					* `mat(3, (2-i)%high) 
					* `mat(4, (1-i)%high);
			end
		end
		endcase
		
		 diff[0] <= products[0][0] - products[1][0];
		 diff[1] <= products[0][1] - products[1][1];
		 diff[2] <= products[0][2] - products[1][2];
		 diff[3] <= products[0][3] - products[1][3];
		 diff[4] <= products[0][4] - products[1][4];

		 result <= diff[0] + diff[1] + diff[2] + diff[3] + diff[4];
		
		if (i == 4) begin
			i <= 0;
		end else begin
			i <= i + 1; 
		end
	 end
	 
endmodule


