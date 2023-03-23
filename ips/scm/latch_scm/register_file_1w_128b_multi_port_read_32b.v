module register_file_1w_128b_multi_port_read_32b (
	clk,
	ReadEnable,
	ReadAddr,
	ReadData,
	WriteEnable,
	WriteAddr,
	WriteData
);
	parameter WADDR_WIDTH = 5;
	parameter WDATA_WIDTH = 128;
	parameter RDATA_WIDTH = 32;
	parameter RADDR_WIDTH = WADDR_WIDTH + $clog2(WDATA_WIDTH / RDATA_WIDTH);
	parameter N_READ = 4;
	parameter N_WRITE = 1;
	input wire clk;
	input wire [N_READ - 1:0] ReadEnable;
	input wire [(N_READ * RADDR_WIDTH) - 1:0] ReadAddr;
	output wire [(N_READ * RDATA_WIDTH) - 1:0] ReadData;
	input wire WriteEnable;
	input wire [WADDR_WIDTH - 1:0] WriteAddr;
	input wire [WDATA_WIDTH - 1:0] WriteData;
	localparam NUM_R_WORDS = 2 ** RADDR_WIDTH;
	localparam NUM_W_WORDS = 2 ** WADDR_WIDTH;
	reg [(N_READ * RADDR_WIDTH) - 1:0] RAddrRegxDP;
	reg [(N_READ * NUM_R_WORDS) - 1:0] RAddrOneHotxD;
	reg [RDATA_WIDTH - 1:0] MemContentxDP [0:NUM_R_WORDS - 1];
	reg [NUM_W_WORDS - 1:0] WAddrOneHotxD;
	wire [NUM_W_WORDS - 1:0] ClocksxC;
	reg [((WDATA_WIDTH / RDATA_WIDTH) * RDATA_WIDTH) - 1:0] WDataIntxD;
	wire clk_int;
	reg [31:0] i;
	reg [31:0] k;
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
	always @(*) begin : p_WAD
		for (i = 0; i < NUM_W_WORDS; i = i + 1)
			begin : p_WordIter
				if ((WriteEnable == 1'b1) && (WriteAddr == i))
					WAddrOneHotxD[i] = 1'b1;
				else
					WAddrOneHotxD[i] = 1'b0;
			end
	end
	generate
		for (x = 0; x < NUM_W_WORDS; x = x + 1) begin : CG_CELL_WORD_ITER
			cluster_clock_gating CG_Inst(
				.clk_o(ClocksxC[x]),
				.en_i(WAddrOneHotxD[x]),
				.test_en_i(1'b0),
				.clk_i(clk_int)
			);
		end
	endgenerate
	always @(posedge clk) begin : sample_waddr
		if (WriteEnable)
			WDataIntxD <= WriteData;
	end
	always @(*) begin : latch_wdata
		for (k = 0; k < NUM_W_WORDS; k = k + 1)
			begin : w_WordIter
				if (ClocksxC[k] == 1'b1) begin
					MemContentxDP[k * 4] = WDataIntxD[0+:RDATA_WIDTH];
					MemContentxDP[(k * 4) + 1] = WDataIntxD[RDATA_WIDTH+:RDATA_WIDTH];
					MemContentxDP[(k * 4) + 2] = WDataIntxD[2 * RDATA_WIDTH+:RDATA_WIDTH];
					MemContentxDP[(k * 4) + 3] = WDataIntxD[3 * RDATA_WIDTH+:RDATA_WIDTH];
				end
			end
	end
endmodule
