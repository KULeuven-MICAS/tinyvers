module register_file_1r_1w (
	clk,
	ReadEnable,
	ReadAddr,
	ReadData,
	WriteEnable,
	WriteAddr,
	WriteData
);
	parameter ADDR_WIDTH = 5;
	parameter DATA_WIDTH = 32;
	input wire clk;
	input wire ReadEnable;
	input wire [ADDR_WIDTH - 1:0] ReadAddr;
	output wire [DATA_WIDTH - 1:0] ReadData;
	input wire WriteEnable;
	input wire [ADDR_WIDTH - 1:0] WriteAddr;
	input wire [DATA_WIDTH - 1:0] WriteData;
	localparam NUM_WORDS = 2 ** ADDR_WIDTH;
	reg [ADDR_WIDTH - 1:0] RAddrRegxDP;
	reg [NUM_WORDS - 1:0] RAddrOneHotxD;
	reg [DATA_WIDTH - 1:0] MemContentxDP [0:NUM_WORDS - 1];
	reg [NUM_WORDS - 1:0] WAddrOneHotxD;
	wire [NUM_WORDS - 1:0] ClocksxC;
	reg [DATA_WIDTH - 1:0] WDataIntxD;
	wire clk_int;
	reg [31:0] i;
	wire [31:0] j;
	reg [31:0] k;
	wire [31:0] l;
	wire [31:0] m;
	genvar x;
	genvar y;
	cluster_clock_gating CG_WE_GLOBAL(
		.clk_o(clk_int),
		.en_i(WriteEnable),
		.test_en_i(1'b0),
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
		if (WriteEnable)
			WDataIntxD <= WriteData;
	end
	always @(*) begin : latch_wdata
		for (k = 0; k < NUM_WORDS; k = k + 1)
			begin : w_WordIter
				if (ClocksxC[k] == 1'b1)
					MemContentxDP[k] = WDataIntxD;
			end
	end
endmodule
