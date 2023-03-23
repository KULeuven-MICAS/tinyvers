module register_file_1w_multi_port_read (
	clk,
	rst_n,
	test_en_i,
	ReadEnable,
	ReadAddr,
	ReadData,
	WriteEnable,
	WriteAddr,
	WriteData
);
	parameter ADDR_WIDTH = 5;
	parameter DATA_WIDTH = 32;
	parameter N_READ = 2;
	parameter N_WRITE = 1;
	input wire clk;
	input wire rst_n;
	input wire test_en_i;
	input wire [N_READ - 1:0] ReadEnable;
	input wire [(N_READ * ADDR_WIDTH) - 1:0] ReadAddr;
	output wire [(N_READ * DATA_WIDTH) - 1:0] ReadData;
	input wire WriteEnable;
	input wire [ADDR_WIDTH - 1:0] WriteAddr;
	input wire [DATA_WIDTH - 1:0] WriteData;
	localparam NUM_WORDS = 2 ** ADDR_WIDTH;
	reg [(N_READ * ADDR_WIDTH) - 1:0] RAddrRegxDP;
	reg [(N_READ * NUM_WORDS) - 1:0] RAddrOneHotxD;
	reg [DATA_WIDTH - 1:0] MemContentxDP [0:NUM_WORDS - 1];
	reg [NUM_WORDS - 1:0] WAddrOneHotxD;
	wire [NUM_WORDS - 1:0] ClocksxC;
	reg [DATA_WIDTH - 1:0] WDataIntxD;
	wire clk_int;
	reg [31:0] i;
	reg [31:0] k;
	genvar x;
	genvar z;
	cluster_clock_gating CG_WE_GLOBAL(
		.clk_o(clk_int),
		.en_i(WriteEnable),
		.test_en_i(test_en_i),
		.clk_i(clk)
	);
	generate
		for (z = 0; z < N_READ; z = z + 1) begin : genblk1
			always @(posedge clk) begin : p_RAddrReg
				if (rst_n == 1'b0)
					RAddrRegxDP[z * ADDR_WIDTH+:ADDR_WIDTH] <= 1'sb0;
				else if (ReadEnable[z])
					RAddrRegxDP[z * ADDR_WIDTH+:ADDR_WIDTH] <= ReadAddr[z * ADDR_WIDTH+:ADDR_WIDTH];
			end
			always @(*) begin : p_RAD
				RAddrOneHotxD[z * NUM_WORDS+:NUM_WORDS] = 1'sb0;
				RAddrOneHotxD[(z * NUM_WORDS) + RAddrRegxDP[z * ADDR_WIDTH+:ADDR_WIDTH]] = 1'b1;
			end
			assign ReadData[z * DATA_WIDTH+:DATA_WIDTH] = MemContentxDP[RAddrRegxDP[z * ADDR_WIDTH+:ADDR_WIDTH]];
		end
	endgenerate
	always @(*) begin : p_WAD
		for (i = 0; i < NUM_WORDS; i = i + 1)
			begin : p_WordIter
				if ((WriteEnable == 1'b1) && (WriteAddr == i))
					WAddrOneHotxD[i] = 1'b1;
				else
					WAddrOneHotxD[i] = 1'b0;
			end
	end
	generate
		for (x = 0; x < NUM_WORDS; x = x + 1) begin : CG_CELL_WORD_ITER
			cluster_clock_gating CG_Inst(
				.clk_o(ClocksxC[x]),
				.en_i(WAddrOneHotxD[x]),
				.test_en_i(1'b0),
				.clk_i(clk_int)
			);
		end
	endgenerate
	always @(posedge clk) begin : sample_waddr
		if (rst_n == 1'b0)
			WDataIntxD <= 1'sb0;
		else if (WriteEnable)
			WDataIntxD <= WriteData;
	end
	always @(*) begin : latch_wdata
		for (k = 0; k < NUM_WORDS; k = k + 1)
			begin : w_WordIter
				if (ClocksxC[k] == 1'b1)
					MemContentxDP[k] <= WDataIntxD;
			end
	end
endmodule
