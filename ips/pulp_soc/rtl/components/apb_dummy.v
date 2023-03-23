module apb_dummy_registers (
	HCLK,
	HRESETn,
	PADDR,
	PWDATA,
	PWRITE,
	PSEL,
	PENABLE,
	PRDATA,
	PREADY,
	PSLVERR
);
	parameter APB_ADDR_WIDTH = 12;
	input wire HCLK;
	input wire HRESETn;
	input wire [APB_ADDR_WIDTH - 1:0] PADDR;
	input wire [31:0] PWDATA;
	input wire PWRITE;
	input wire PSEL;
	input wire PENABLE;
	output wire [31:0] PRDATA;
	output wire PREADY;
	output wire PSLVERR;
	wire s_apb_write;
	wire s_apb_addr;
	wire [31:0] reg_signature;
	wire [31:0] reg_scratch;
	assign s_apb_write = (PSEL && PENABLE) && PWRITE;
	assign s_apb_addr = PADDR[2];
	assign reg_signature = 1'sb0;
	assign PREADY = 1'b1;
	assign PSLVERR = 1'b0;
endmodule
