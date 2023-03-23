module register_file_1w_multi_port_read_1row (
	clk,
	test_en_i,
	ReadEnable,
	ReadData,
	WriteEnable,
	WriteData
);
	parameter ADDR_WIDTH = 5;
	parameter DATA_WIDTH = 32;
	parameter N_READ = 2;
	parameter N_WRITE = 1;
	input wire clk;
	input wire test_en_i;
	input wire [N_READ - 1:0] ReadEnable;
	output wire [(N_READ * DATA_WIDTH) - 1:0] ReadData;
	input wire WriteEnable;
	input wire [DATA_WIDTH - 1:0] WriteData;
	localparam NUM_WORDS = 1;
	reg [DATA_WIDTH - 1:0] MemContentxDP;
	wire ClocksxC;
	reg [DATA_WIDTH - 1:0] WDataIntxD;
	wire clk_int;
	genvar z;
	cluster_clock_gating CG_WE_GLOBAL(
		.clk_o(clk_int),
		.en_i(WriteEnable),
		.test_en_i(test_en_i),
		.clk_i(clk)
	);
	generate
		for (z = 0; z < N_READ; z = z + 1) begin : genblk1
			assign ReadData[z * DATA_WIDTH+:DATA_WIDTH] = MemContentxDP;
		end
	endgenerate
	cluster_clock_gating CG_Inst(
		.clk_o(ClocksxC),
		.en_i(WriteEnable),
		.test_en_i(1'b0),
		.clk_i(clk_int)
	);
	always @(posedge clk) begin : sample_waddr
		if (WriteEnable)
			WDataIntxD <= WriteData;
	end
	always @(*) begin : latch_wdata
		if (ClocksxC == 1'b1)
			MemContentxDP = WDataIntxD;
	end
endmodule
