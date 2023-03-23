module apb_node (
	penable_i,
	pwrite_i,
	paddr_i,
	psel_i,
	pwdata_i,
	prdata_o,
	pready_o,
	pslverr_o,
	penable_o,
	pwrite_o,
	paddr_o,
	psel_o,
	pwdata_o,
	prdata_i,
	pready_i,
	pslverr_i,
	START_ADDR_i,
	END_ADDR_i
);
	parameter [31:0] NB_MASTER = 8;
	parameter [31:0] APB_DATA_WIDTH = 32;
	parameter [31:0] APB_ADDR_WIDTH = 32;
	input wire penable_i;
	input wire pwrite_i;
	input wire [APB_ADDR_WIDTH - 1:0] paddr_i;
	input wire psel_i;
	input wire [APB_DATA_WIDTH - 1:0] pwdata_i;
	output reg [APB_DATA_WIDTH - 1:0] prdata_o;
	output reg pready_o;
	output reg pslverr_o;
	output reg [NB_MASTER - 1:0] penable_o;
	output reg [NB_MASTER - 1:0] pwrite_o;
	output reg [(NB_MASTER * APB_ADDR_WIDTH) - 1:0] paddr_o;
	output reg [NB_MASTER - 1:0] psel_o;
	output reg [(NB_MASTER * APB_DATA_WIDTH) - 1:0] pwdata_o;
	input wire [(NB_MASTER * APB_DATA_WIDTH) - 1:0] prdata_i;
	input wire [NB_MASTER - 1:0] pready_i;
	input wire [NB_MASTER - 1:0] pslverr_i;
	input wire [(NB_MASTER * APB_ADDR_WIDTH) - 1:0] START_ADDR_i;
	input wire [(NB_MASTER * APB_ADDR_WIDTH) - 1:0] END_ADDR_i;
	always @(*) begin : match_address
		psel_o = 1'sb0;
		begin : sv2v_autoblock_1
			reg [31:0] i;
			for (i = 0; i < NB_MASTER; i = i + 1)
				psel_o[i] = (psel_i & (paddr_i >= START_ADDR_i[i * APB_ADDR_WIDTH+:APB_ADDR_WIDTH])) && (paddr_i <= END_ADDR_i[i * APB_ADDR_WIDTH+:APB_ADDR_WIDTH]);
		end
	end
	always @(*) begin
		penable_o = 1'sb0;
		pwrite_o = 1'sb0;
		paddr_o = 1'sb0;
		pwdata_o = 1'sb0;
		prdata_o = 1'sb0;
		pready_o = 1'b0;
		pslverr_o = 1'b0;
		begin : sv2v_autoblock_2
			reg [31:0] i;
			for (i = 0; i < NB_MASTER; i = i + 1)
				if (psel_o[i]) begin
					penable_o[i] = penable_i;
					pwrite_o[i] = pwrite_i;
					paddr_o[i * APB_ADDR_WIDTH+:APB_ADDR_WIDTH] = paddr_i;
					pwdata_o[i * APB_DATA_WIDTH+:APB_DATA_WIDTH] = pwdata_i;
					prdata_o = prdata_i[i * APB_DATA_WIDTH+:APB_DATA_WIDTH];
					pready_o = pready_i[i];
					pslverr_o = pslverr_i[i];
				end
		end
	end
endmodule
