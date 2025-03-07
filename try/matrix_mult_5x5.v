module matrix_mult_5x5 (
    input wire clk,
    input wire resetn,
    input wire [31:0] s_axi_awaddr,
    input wire s_axi_awvalid,
    output wire s_axi_awready,
    input wire [31:0] s_axi_wdata,
    input wire s_axi_wvalid,
    output wire s_axi_wready,
    output wire [1:0] s_axi_bresp,
    output wire s_axi_bvalid,
    input wire s_axi_bready,
    input wire [31:0] s_axi_araddr,
    input wire s_axi_arvalid,
    output wire s_axi_arready,
    output wire [31:0] s_axi_rdata,
    output wire [1:0] s_axi_rresp,
    output wire s_axi_rvalid,
    input wire s_axi_rready
);

    reg [7:0] a[0:4][0:4];
    reg [7:0] b[0:4][0:4];
    reg [15:0] c[0:4][0:4];

    reg [31:0] axi_rdata_reg;
    reg axi_awready_reg, axi_wready_reg, axi_bvalid_reg, axi_arready_reg, axi_rvalid_reg;
    reg [1:0] axi_bresp_reg, axi_rresp_reg;

    reg [3:0] state;
    localparam IDLE = 0, WRITE_A = 1, WRITE_B = 2, COMPUTE = 3, READ = 4;

    integer i, j, k;

    always @(posedge clk) begin
        if (!resetn) begin
            state <= IDLE;
            axi_awready_reg <= 0;
            axi_wready_reg <= 0;
            axi_bvalid_reg <= 0;
            axi_arready_reg <= 0;
            axi_rvalid_reg <= 0;
            axi_rdata_reg <= 0;
            axi_bresp_reg <= 2'b00;
            axi_rresp_reg <= 2'b00;
        end else begin
            case (state)
                IDLE: begin
                    if (s_axi_awvalid) begin
                        axi_awready_reg <= 1;
                        state <= WRITE_A;
                    end else if (s_axi_arvalid) begin
                        axi_arready_reg <= 1;
                        state <= READ;
                    end
                end
                WRITE_A: begin
                    if (s_axi_wvalid) begin
                        axi_wready_reg <= 1;
                        a[s_axi_awaddr[6:4]][s_axi_awaddr[3:2]] <= s_axi_wdata[7:0];
                        state <= WRITE_B;
                        axi_awready_reg <= 0;
                        axi_wready_reg <= 0;
                        axi_bvalid_reg <= 1;
                    end
                end
                WRITE_B: begin
                    if (s_axi_wvalid) begin
                        axi_wready_reg <= 1;
                        b[s_axi_awaddr[6:4]][s_axi_awaddr[3:2]] <= s_axi_wdata[7:0];
                        state <= COMPUTE;
                        axi_awready_reg <= 0;
                        axi_wready_reg <= 0;
                        axi_bvalid_reg <= 1;
                    end
                end
                COMPUTE: begin
                    for (i = 0; i < 5; i = i + 1) begin
                        for (j = 0; j < 5; j = j + 1) begin
                            c[i][j] = 0;
                            for (k = 0; k < 5; k = k + 1) begin
                                c[i][j] = c[i][j] + a[i][k] * b[k][j];
                            end
                        end
                    end
                    state <= IDLE;
                end
                READ: begin
                    if (s_axi_rready) begin
                        axi_rdata_reg <= {16'b0, c[s_axi_araddr[6:4]][s_axi_araddr[3:2]]};
                        axi_rvalid_reg <= 1;
                        state <= IDLE;
                        axi_arready_reg <= 0;
                    end
                end
            endcase
        end
    end

    assign s_axi_awready = axi_awready_reg;
    assign s_axi_wready = axi_wready_reg;
    assign s_axi_bresp = axi_bresp_reg;
    assign s_axi_bvalid = axi_bvalid_reg;
    assign s_axi_arready = axi_arready_reg;
    assign s_axi_rdata = axi_rdata_reg;
    assign s_axi_rresp = axi_rresp_reg;
    assign s_axi_rvalid = axi_rvalid_reg;

endmodule