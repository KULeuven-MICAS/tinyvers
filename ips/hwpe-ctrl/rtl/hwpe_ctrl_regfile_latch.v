module hwpe_ctrl_regfile_latch (
	clk,
	rst_n,
	clear,
	ReadEnable,
	ReadAddr,
	ReadData,
	WriteEnable,
	WriteAddr,
	WriteData,
	WriteBE,
	scan_en_in,
	MemContent
);
	parameter ADDR_WIDTH = 5;
	parameter DATA_WIDTH = 32;
	parameter NUM_BYTE = DATA_WIDTH / 8;
	input wire clk;
	input wire rst_n;
	input wire clear;
	input wire ReadEnable;
	input wire [ADDR_WIDTH - 1:0] ReadAddr;
	output wire [DATA_WIDTH - 1:0] ReadData;
	input wire WriteEnable;
	input wire [ADDR_WIDTH - 1:0] WriteAddr;
	input wire [(NUM_BYTE * 8) - 1:0] WriteData;
	input wire [NUM_BYTE - 1:0] WriteBE;
	input wire scan_en_in;
	output wire [((2 ** ADDR_WIDTH) * DATA_WIDTH) - 1:0] MemContent;
	localparam NUM_WORDS = 2 ** ADDR_WIDTH;
	reg [ADDR_WIDTH - 1:0] RAddrRegxDP;
	reg [NUM_WORDS - 1:0] RAddrOneHotxD;
	reg [(NUM_BYTE * 8) - 1:0] MemContentxDP [0:NUM_WORDS - 1];
	reg [(NUM_WORDS * NUM_BYTE) - 1:0] WAddrOneHotxD;
	wire [(NUM_WORDS * NUM_BYTE) - 1:0] ClocksxC;
	reg [(NUM_BYTE * 8) - 1:0] WDataIntxD;
	wire rst_clr_array;
	wire clk_int;
	reg [31:0] i;
	reg [31:0] j;
	genvar k;
	genvar l;
	reg [31:0] m;
	genvar x;
	genvar y;
	cluster_clock_gating CG_WE_GLOBAL(
		.clk_o(clk_int),
		.en_i(WriteEnable | clear),
		.test_en_i(scan_en_in),
		.clk_i(clk)
	);
	always @(posedge clk) begin : p_RAddrReg
		if (ReadEnable)
			RAddrRegxDP <= ReadAddr;
	end
	always @(*) begin : p_RAD
		RAddrOneHotxD = 1'sb0;
		RAddrOneHotxD[RAddrRegxDP] = 1'b1;
	end
	assign ReadData = MemContentxDP[RAddrRegxDP];
	always @(*) begin : p_WAD
		for (i = 0; i < NUM_WORDS; i = i + 1)
			begin : p_WordIter
				for (j = 0; j < NUM_BYTE; j = j + 1)
					begin : p_ByteIter
						if ((clear == 1'b1) | (((WriteEnable == 1'b1) && (WriteBE[j] == 1'b1)) && (WriteAddr == i)))
							WAddrOneHotxD[(i * NUM_BYTE) + j] = 1'b1;
						else
							WAddrOneHotxD[(i * NUM_BYTE) + j] = 1'b0;
					end
			end
	end
	generate
		for (x = 0; x < NUM_WORDS; x = x + 1) begin : CG_CELL_WORD_ITER
			for (y = 0; y < NUM_BYTE; y = y + 1) begin : CG_CELL_BYTE_ITER
				cluster_clock_gating CG_Inst(
					.clk_o(ClocksxC[(x * NUM_BYTE) + y]),
					.en_i(WAddrOneHotxD[(x * NUM_BYTE) + y]),
					.test_en_i(scan_en_in),
					.clk_i(clk_int)
				);
			end
		end
	endgenerate
	always @(*) begin : sample_waddr
		for (m = 0; m < NUM_BYTE; m = m + 1)
			if (clear)
				WDataIntxD[m * 8+:8] <= 1'sb0;
			else
				WDataIntxD[m * 8+:8] <= WriteData[m * 8+:8];
	end
	generate
		for (k = 0; k < NUM_WORDS; k = k + 1) begin : w_WordIter
			for (l = 0; l < NUM_BYTE; l = l + 1) begin : w_ByteIter
				always @(posedge ClocksxC[(k * NUM_BYTE) + l] or negedge rst_n)
					if (~rst_n)
						MemContentxDP[k][l * 8+:8] = 1'sb0;
					else
						MemContentxDP[k][l * 8+:8] = WDataIntxD[l * 8+:8];
			end
		end
	endgenerate
	genvar p;
	generate
		for (p = 0; p < NUM_WORDS; p = p + 1) begin : MemContentOut_Iter
			assign MemContent[p * DATA_WIDTH+:DATA_WIDTH] = MemContentxDP[p];
		end
	endgenerate
endmodule
