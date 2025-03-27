`define i8(x) 8'sd``x
`define INTEGER_8 7:0
`define MATRIX_5x5 (8*25-1):0
`define at(row, col) (8 * (col + 5*row))
`define a(row, col) matrix[`at(row, col) +: 8]

module MpuDet (
    input      signed [`MATRIX_5x5] matrix,
    input      signed [`INTEGER_8]  size,

    input start,
    input clock,
    input reset,

    output reg signed [`INTEGER_8]  result,
    output reg done
);

    parameter IDLE   = 0;
    parameter START  = 1;
    parameter FETCH  = 2;
    parameter MUL    = 3;
    parameter SUM    = 4;
    parameter FINISH = 5;

    integer i;
    integer state;
    integer nextState;

    // Fetch
    reg [7:0] main[0:5][0:5];
    reg [7:0] sec[0:5][0:5];

    // Mul
    reg [7:0] products[0:1][0:5];

    // Sum
    reg [7:0] diff[0:5];

    always @(posedge clock, posedge reset, posedge start) begin
        if (reset || start) begin 
            state <= IDLE;
            main <= 0; sec <= 0; products <= 0; 
            i <= 0;
            done <= 0;
        end else begin 
            state <= nextState;
        end

        if (start) begin 
            state <= START;
        end
    end

    always @(*) begin
        case (state)
        START: nextState <= FETCH;
        FETCH: begin
            case (size)
            2: begin
                main[0] = {`a(0, 0), `a(1, 1)};
                main[1] = 8'd1;
                main[2] = 8'd1;
                main[3] = 8'd1;
                main[4] = 8'd1;

                sec[0]  = {`a(0, 1), `a(1, 0)};
                sec[1] = 8'd1;
                sec[2] = 8'd1;
                sec[3] = 8'd1;
                sec[4] = 8'd1;
            end
            3: begin
                main[0] = {`a(0, 0), `a(1, 1), `a(2, 2)};
                main[1] = {`a(0, 1), `a(1, 2), `a(2, 0)};
                main[2] = {`a(0, 2), `a(1, 0), `a(2, 1)};
                main[3] = 8'd1;
                main[4] = 8'd1;

                sec[0]  = {`a(0, 2), `a(1, 1), `a(2, 0)};
                sec[1]  = {`a(0, 1), `a(1, 0), `a(2, 2)};
                sec[2]  = {`a(0, 0), `a(1, 2), `a(2, 1)};
                sec[3]  = 8'd1;
                sec[4]  = 8'd1;
            end
            4: begin
                main[0] = {`a(0, 0), `a(1, 1), `a(2, 2), `a(3, 3)};
                main[1] = {`a(0, 1), `a(1, 2), `a(2, 3), `a(3, 0)};
                main[2] = {`a(0, 2), `a(1, 3), `a(2, 0), `a(3, 1)};
                main[3] = {`a(0, 3), `a(1, 0), `a(2, 1), `a(3, 2)};
                main[4] = 8'd1;

                sec[0]  = {`a(0, 3), `a(1, 2), `a(2, 1), `a(3, 0)};
                sec[1]  = {`a(0, 2), `a(1, 1), `a(2, 0), `a(3, 3)};
                sec[2]  = {`a(0, 1), `a(1, 0), `a(2, 3), `a(3, 2)};
                sec[3]  = {`a(0, 0), `a(1, 3), `a(2, 2), `a(3, 1)};
                sec[4]  = 8'd1;
            end
            5: begin
                main[0] = {`a(0, 0), `a(1, 1), `a(2, 2), `a(3, 3), `a(4, 4)};
                main[1] = {`a(0, 1), `a(1, 2), `a(2, 3), `a(3, 4), `a(4, 0)};
                main[2] = {`a(0, 2), `a(1, 3), `a(2, 4), `a(3, 0), `a(4, 1)};
                main[3] = {`a(0, 3), `a(1, 4), `a(2, 0), `a(3, 1), `a(4, 2)};
                main[4] = {`a(0, 4), `a(1, 0), `a(2, 1), `a(3, 2), `a(4, 3)};

                sec[0]  = {`a(0, 4), `a(1, 3), `a(2, 2), `a(3, 1), `a(4, 0)};
                sec[1]  = {`a(0, 3), `a(1, 2), `a(2, 1), `a(3, 0), `a(4, 4)};
                sec[2]  = {`a(0, 2), `a(1, 1), `a(2, 0), `a(3, 4), `a(4, 3)};
                sec[3]  = {`a(0, 1), `a(1, 0), `a(2, 4), `a(3, 3), `a(4, 2)};
                sec[4]  = {`a(0, 0), `a(1, 4), `a(2, 3), `a(3, 2), `a(4, 1)};
            end
            endcase
            nextState <= MUL;
        end
        MUL: begin
            if (i < 5) begin
                products[0][i] <= main[0 +: 8] * main[8 +: 8] * main[16 +: 8] * main[24 +: 8] * main[32 +: 8];
                products[1][i] <= sec[0  +: 8] *  sec[8 +: 8] *  sec[16 +: 8] *  sec[24 +: 8] *  sec[32 +: 8];

                i <= i + 1;
            end else begin
                i <= 0;
                nextState <= SUM;
            end
        end
        SUM: begin
            for (i = 0; i < 5; i = i + 1) begin
                diff[i] <= products[0][i] - products[1][i];
            end
            nextState <= FINISH;
        end
        FINISH: begin
            result    <= diff[0] + diff[1] + diff[2] + diff[3] + diff[4];
            done      <= 1;
            nextState <= FINISH;
        end
        default:
            nextState <= IDLE;
        endcase
    end
endmodule