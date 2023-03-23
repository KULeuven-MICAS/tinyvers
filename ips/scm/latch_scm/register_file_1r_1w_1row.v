module register_file_1r_1w_1row (
	clk,
	ReadEnable,
	ReadData,
	WriteEnable,
	WriteData
);
	parameter DATA_WIDTH = 32;
	input wire clk;
	input wire ReadEnable;
	output wire [DATA_WIDTH - 1:0] ReadData;
	input wire WriteEnable;
	input wire [DATA_WIDTH - 1:0] WriteData;
	reg [DATA_WIDTH - 1:0] MemContentxDP;
	wire ClocksxC;
	reg [DATA_WIDTH - 1:0] WDataIntxD;
	wire clk_int;
	cluster_clock_gating CG_WE_GLOBAL(
		.clk_o(clk_int),
		.en_i(WriteEnable),
		.test_en_i(1'b0),
		.clk_i(clk)
	);
	assign ReadData = MemContentxDP;
	cluster_clock_gating CG_Inst(
		.clk_o(ClocksxC),
		.en_i(WriteEnable),
		.test_en_i(1'b0),
		.clk_i(clk_int)
	);
	always @(posedge clk)
		if (WriteEnable)
			WDataIntxD <= WriteData;
	always @(*)
		if (ClocksxC == 1'b1)
			MemContentxDP = WDataIntxD;
endmodule
