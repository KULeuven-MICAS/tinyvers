module register_file_1w_64b_multi_port_read_32b_1row (
	clk,
	rst_n,
	ReadEnable,
	ReadAddr,
	ReadData,
	WriteEnable,
	WriteData
);
	parameter WADDR_WIDTH = 0;
	parameter WDATA_WIDTH = 64;
	parameter RDATA_WIDTH = 32;
	parameter RADDR_WIDTH = $clog2(WDATA_WIDTH / RDATA_WIDTH);
	parameter N_READ = 4;
	parameter N_WRITE = 1;
	input wire clk;
	input wire rst_n;
	input wire [N_READ - 1:0] ReadEnable;
	input wire [(N_READ * RADDR_WIDTH) - 1:0] ReadAddr;
	output wire [(N_READ * RDATA_WIDTH) - 1:0] ReadData;
	input wire WriteEnable;
	input wire [WDATA_WIDTH - 1:0] WriteData;
	localparam NUM_R_WORDS = 2 ** RADDR_WIDTH;
	localparam NUM_W_WORDS = 1;
	reg [(N_READ * RADDR_WIDTH) - 1:0] RAddrRegxDP;
	reg [(N_READ * NUM_R_WORDS) - 1:0] RAddrOneHotxD;
	reg [RDATA_WIDTH - 1:0] MemContentxDP [0:NUM_R_WORDS - 1];
	wire ClocksxC;
	reg [((WDATA_WIDTH / RDATA_WIDTH) * RDATA_WIDTH) - 1:0] WDataIntxD;
	wire clk_int;
	wire [31:0] i;
	wire [31:0] k;
	genvar x;
	genvar z;
	cluster_clock_gating CG_WE_GLOBAL(
		.clk_o(clk_int),
		.en_i(WriteEnable),
		.test_en_i(1'b0),
		.clk_i(clk)
	);
	generate
		for (z = 0; z < N_READ; z = z + 1) begin : genblk1
			always @(posedge clk) begin : p_RAddrReg
				if (ReadEnable[z])
					RAddrRegxDP[z * RADDR_WIDTH+:RADDR_WIDTH] <= ReadAddr[z * RADDR_WIDTH+:RADDR_WIDTH];
			end
			always @(*) begin : p_RAD
				RAddrOneHotxD[z * NUM_R_WORDS+:NUM_R_WORDS] = 1'sb0;
				RAddrOneHotxD[(z * NUM_R_WORDS) + RAddrRegxDP[z * RADDR_WIDTH+:RADDR_WIDTH]] = 1'b1;
			end
			assign ReadData[z * RDATA_WIDTH+:RDATA_WIDTH] = MemContentxDP[RAddrRegxDP[z * RADDR_WIDTH+:RADDR_WIDTH]];
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
		if (ClocksxC == 1'b1) begin
			MemContentxDP[0] = WDataIntxD[0+:RDATA_WIDTH];
			MemContentxDP[1] = WDataIntxD[RDATA_WIDTH+:RDATA_WIDTH];
		end
	end
endmodule
