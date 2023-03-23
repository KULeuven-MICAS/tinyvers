module register_file_2r_1w_asymm (
	clk,
	ReadEnable_a,
	ReadAddr_a,
	ReadData_a,
	ReadEnable_b,
	ReadAddr_b,
	ReadData_b,
	WriteEnable,
	WriteAddr,
	WriteData,
	WriteBE
);
	parameter ADDR_WIDTH = 5;
	parameter DATA_WIDTH = 32;
	parameter NUM_BYTE = DATA_WIDTH / 8;
	parameter ASYMM_FACTOR = 3;
	input wire clk;
	input wire ReadEnable_a;
	input wire [ADDR_WIDTH - 1:0] ReadAddr_a;
	output wire [DATA_WIDTH - 1:0] ReadData_a;
	input wire ReadEnable_b;
	input wire [ADDR_WIDTH - 1:0] ReadAddr_b;
	output wire [(ASYMM_FACTOR * DATA_WIDTH) - 1:0] ReadData_b;
	input wire WriteEnable;
	input wire [ADDR_WIDTH - 1:0] WriteAddr;
	input wire [(NUM_BYTE * 8) - 1:0] WriteData;
	input wire [NUM_BYTE - 1:0] WriteBE;
	localparam NUM_WORDS = 2 ** ADDR_WIDTH;
	reg [ADDR_WIDTH - 1:0] RAddrRegxDPa;
	reg [NUM_WORDS - 1:0] RAddrOneHotxDa;
	reg [ADDR_WIDTH - 1:0] RAddrRegxDPb;
	reg [NUM_WORDS - 1:0] RAddrOneHotxDb;
	reg [((NUM_WORDS * NUM_BYTE) * 8) - 1:0] MemContentxDP;
	wire [((NUM_WORDS * (ASYMM_FACTOR * NUM_BYTE)) * 8) - 1:0] MemContentxDPas;
	reg [(NUM_WORDS * NUM_BYTE) - 1:0] WAddrOneHotxD;
	wire [(NUM_WORDS * NUM_BYTE) - 1:0] ClocksxC;
	reg [(NUM_BYTE * 8) - 1:0] WDataIntxD;
	wire clk_int;
	reg [31:0] i;
	reg [31:0] j;
	reg [31:0] k;
	reg [31:0] l;
	reg [31:0] m;
	genvar x;
	genvar y;
	cluster_clock_gating CG_WE_GLOBAL(
		.clk_o(clk_int),
		.en_i(WriteEnable),
		.test_en_i(1'b0),
		.clk_i(clk)
	);
	generate
		for (x = 0; x < (2 ** ADDR_WIDTH); x = x + 1) begin : asymm_circular_rewiring_gen
			localparam x_low = x % (2 ** ADDR_WIDTH);
			localparam x_high = ((x + ASYMM_FACTOR) - 1) % (2 ** ADDR_WIDTH);
			if (x_high > x_low) begin : genblk1
				assign MemContentxDPas[8 * (x_low * (ASYMM_FACTOR * NUM_BYTE))+:8 * (ASYMM_FACTOR * NUM_BYTE)] = MemContentxDP[8 * (NUM_BYTE * ((x_high >= x_low ? x_high : (x_high + (x_high >= x_low ? (x_high - x_low) + 1 : (x_low - x_high) + 1)) - 1) - ((x_high >= x_low ? (x_high - x_low) + 1 : (x_low - x_high) + 1) - 1)))+:8 * (NUM_BYTE * (x_high >= x_low ? (x_high - x_low) + 1 : (x_low - x_high) + 1))];
			end
			else begin : genblk1
				assign MemContentxDPas[8 * (x_low * (ASYMM_FACTOR * NUM_BYTE))+:8 * (ASYMM_FACTOR * NUM_BYTE)] = {MemContentxDP[8 * (NUM_BYTE * ((x_high >= 0 ? x_high : (x_high + (x_high >= 0 ? x_high + 1 : 1 - x_high)) - 1) - ((x_high >= 0 ? x_high + 1 : 1 - x_high) - 1)))+:8 * (NUM_BYTE * (x_high >= 0 ? x_high + 1 : 1 - x_high))], MemContentxDP[8 * (NUM_BYTE * (({ADDR_WIDTH {1'b1}} >= x_low ? {ADDR_WIDTH {1'b1}} : ({ADDR_WIDTH {1'b1}} + ({ADDR_WIDTH {1'b1}} >= x_low ? ({ADDR_WIDTH {1'b1}} - x_low) + 1 : (x_low - {ADDR_WIDTH {1'b1}}) + 1)) - 1) - (({ADDR_WIDTH {1'b1}} >= x_low ? ({ADDR_WIDTH {1'b1}} - x_low) + 1 : (x_low - {ADDR_WIDTH {1'b1}}) + 1) - 1)))+:8 * (NUM_BYTE * ({ADDR_WIDTH {1'b1}} >= x_low ? ({ADDR_WIDTH {1'b1}} - x_low) + 1 : (x_low - {ADDR_WIDTH {1'b1}}) + 1))]};
			end
		end
	endgenerate
	always @(posedge clk) begin : p_RAddrReg_a
		if (ReadEnable_a)
			RAddrRegxDPa <= ReadAddr_a;
	end
	always @(posedge clk) begin : p_RAddrReg_b
		if (ReadEnable_b)
			RAddrRegxDPb <= ReadAddr_b;
	end
	always @(*) begin : p_RAD_a
		RAddrOneHotxDa = 1'sb0;
		RAddrOneHotxDa[RAddrRegxDPa] = 1'b1;
	end
	assign ReadData_a = MemContentxDP[8 * (RAddrRegxDPa * NUM_BYTE)+:8 * NUM_BYTE];
	always @(*) begin : p_RAD_b
		RAddrOneHotxDb = 1'sb0;
		RAddrOneHotxDb[RAddrRegxDPb] = 1'b1;
	end
	assign ReadData_b = MemContentxDPas[8 * (RAddrRegxDPb * (ASYMM_FACTOR * NUM_BYTE))+:8 * (ASYMM_FACTOR * NUM_BYTE)];
	always @(*) begin : p_WAD
		for (i = 0; i < NUM_WORDS; i = i + 1)
			begin : p_WordIter
				for (j = 0; j < NUM_BYTE; j = j + 1)
					begin : p_ByteIter
						if (((WriteEnable == 1'b1) && (WriteBE[j] == 1'b1)) && (WriteAddr == i))
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
					.test_en_i(1'b0),
					.clk_i(clk_int)
				);
			end
		end
	endgenerate
	always @(posedge clk) begin : sample_waddr
		for (m = 0; m < NUM_BYTE; m = m + 1)
			if (WriteEnable & WriteBE[m])
				WDataIntxD[m * 8+:8] <= WriteData[m * 8+:8];
	end
	always @(*) begin : latch_wdata
		for (k = 0; k < NUM_WORDS; k = k + 1)
			begin : w_WordIter
				for (l = 0; l < NUM_BYTE; l = l + 1)
					begin : w_ByteIter
						if (ClocksxC[(k * NUM_BYTE) + l] == 1'b1)
							MemContentxDP[((k * NUM_BYTE) + l) * 8+:8] = WDataIntxD[l * 8+:8];
					end
			end
	end
endmodule
