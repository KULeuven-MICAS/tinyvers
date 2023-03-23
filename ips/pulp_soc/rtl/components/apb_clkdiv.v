module apb_clkdiv (
	HCLK,
	HRESETn,
	PADDR,
	PWDATA,
	PWRITE,
	PSEL,
	PENABLE,
	PRDATA,
	PREADY,
	PSLVERR,
	clk_div0,
	clk_div0_valid,
	clk_div1,
	clk_div1_valid,
	clk_div2,
	clk_div2_valid
);
	parameter APB_ADDR_WIDTH = 12;
	input wire HCLK;
	input wire HRESETn;
	input wire [APB_ADDR_WIDTH - 1:0] PADDR;
	input wire [31:0] PWDATA;
	input wire PWRITE;
	input wire PSEL;
	input wire PENABLE;
	output reg [31:0] PRDATA;
	output wire PREADY;
	output wire PSLVERR;
	output wire [7:0] clk_div0;
	output reg clk_div0_valid;
	output wire [7:0] clk_div1;
	output reg clk_div1_valid;
	output wire [7:0] clk_div2;
	output reg clk_div2_valid;
	reg [7:0] r_clkdiv0;
	reg [7:0] r_clkdiv1;
	reg [7:0] r_clkdiv2;
	wire [1:0] s_apb_addr;
	assign s_apb_addr = PADDR[3:2];
	always @(posedge HCLK or negedge HRESETn)
		if (~HRESETn) begin
			r_clkdiv0 = 'h0;
			r_clkdiv1 = 'h0;
			r_clkdiv2 = 8'h0a;
			clk_div0_valid = 1'b0;
			clk_div1_valid = 1'b0;
			clk_div2_valid = 1'b0;
		end
		else begin
			clk_div0_valid = 1'b0;
			clk_div1_valid = 1'b0;
			clk_div2_valid = 1'b0;
			if ((PSEL && PENABLE) && PWRITE)
				case (s_apb_addr)
					2'b00: begin
						r_clkdiv0 = PWDATA[7:0];
						clk_div0_valid = 1'b1;
					end
					2'b01: begin
						r_clkdiv1 = PWDATA[7:0];
						clk_div1_valid = 1'b1;
					end
					2'b10: begin
						r_clkdiv2 = PWDATA[7:0];
						clk_div2_valid = 1'b1;
					end
				endcase
		end
	always @(*)
		case (s_apb_addr)
			2'b00: PRDATA = {24'h000000, r_clkdiv0};
			2'b01: PRDATA = {24'h000000, r_clkdiv1};
			2'b10: PRDATA = {24'h000000, r_clkdiv2};
			default: PRDATA = 1'sb0;
		endcase
	assign clk_div0 = r_clkdiv0;
	assign clk_div1 = r_clkdiv1;
	assign clk_div2 = r_clkdiv2;
	assign PREADY = 1'b1;
	assign PSLVERR = 1'b0;
endmodule
