module register_file_3r_2w_be (
	clk,
	ReadEnable_A,
	ReadAddr_A,
	ReadData_A,
	ReadEnable_B,
	ReadAddr_B,
	ReadData_B,
	ReadEnable_C,
	ReadAddr_C,
	ReadData_C,
	WriteEnable_A,
	WriteAddr_A,
	WriteData_A,
	WriteBE_A,
	WriteEnable_B,
	WriteAddr_B,
	WriteData_B,
	WriteBE_B
);
	parameter ADDR_WIDTH = 5;
	parameter DATA_WIDTH = 32;
	parameter NUM_BYTE = DATA_WIDTH / 8;
	input wire clk;
	input wire ReadEnable_A;
	input wire [ADDR_WIDTH - 1:0] ReadAddr_A;
	output wire [DATA_WIDTH - 1:0] ReadData_A;
	input wire ReadEnable_B;
	input wire [ADDR_WIDTH - 1:0] ReadAddr_B;
	output wire [DATA_WIDTH - 1:0] ReadData_B;
	input wire ReadEnable_C;
	input wire [ADDR_WIDTH - 1:0] ReadAddr_C;
	output wire [DATA_WIDTH - 1:0] ReadData_C;
	input wire WriteEnable_A;
	input wire [ADDR_WIDTH - 1:0] WriteAddr_A;
	input wire [(NUM_BYTE * 8) - 1:0] WriteData_A;
	input wire [NUM_BYTE - 1:0] WriteBE_A;
	input wire WriteEnable_B;
	input wire [ADDR_WIDTH - 1:0] WriteAddr_B;
	input wire [(NUM_BYTE * 8) - 1:0] WriteData_B;
	input wire [NUM_BYTE - 1:0] WriteBE_B;
	localparam NUM_WORDS = 2 ** ADDR_WIDTH;
	reg [ADDR_WIDTH - 1:0] RAddrRegxDP_A;
	reg [ADDR_WIDTH - 1:0] RAddrRegxDP_B;
	reg [ADDR_WIDTH - 1:0] RAddrRegxDP_C;
	reg [((NUM_WORDS * NUM_BYTE) * 8) - 1:0] MemContentxDP;
	reg [(NUM_WORDS * NUM_BYTE) - 1:0] WAddrOneHotxD_A;
	reg [(NUM_WORDS * NUM_BYTE) - 1:0] WAddrOneHotxD_B;
	reg [(NUM_WORDS * NUM_BYTE) - 1:0] WAddrOneHotxD_B_q;
	wire [(NUM_WORDS * NUM_BYTE) - 1:0] ClocksxC;
	reg [(NUM_BYTE * 8) - 1:0] WDataIntxD_A;
	reg [(NUM_BYTE * 8) - 1:0] WDataIntxD_B;
	wire clk_int;
	reg readA_q;
	reg readB_q;
	reg readC_q;
	reg [31:0] i;
	reg [31:0] j;
	reg [31:0] m;
	genvar x;
	genvar y;
	genvar k;
	genvar l;
	always @(negedge clk)
		if (WriteEnable_A && WriteEnable_B)
			if (WriteAddr_A == WriteAddr_B)
				$display("[SCM] Contention in SCM!!!! addr %x time %t", WriteAddr_B, $time);
	always @(posedge clk) begin
		readA_q <= ReadEnable_A;
		readB_q <= ReadEnable_B;
		readC_q <= ReadEnable_C;
	end
	cluster_clock_gating CG_WE_GLOBAL(
		.clk_o(clk_int),
		.en_i(WriteEnable_A | WriteEnable_B),
		.test_en_i(1'b0),
		.clk_i(clk)
	);
	always @(posedge clk) begin : p_RAddrReg
		if (ReadEnable_A)
			RAddrRegxDP_A <= ReadAddr_A;
		if (ReadEnable_B)
			RAddrRegxDP_B <= ReadAddr_B;
		if (ReadEnable_C)
			RAddrRegxDP_C <= ReadAddr_C;
	end
	assign ReadData_A = MemContentxDP[8 * (RAddrRegxDP_A * NUM_BYTE)+:8 * NUM_BYTE];
	assign ReadData_B = MemContentxDP[8 * (RAddrRegxDP_B * NUM_BYTE)+:8 * NUM_BYTE];
	assign ReadData_C = MemContentxDP[8 * (RAddrRegxDP_C * NUM_BYTE)+:8 * NUM_BYTE];
	always @(*) begin : p_WAD
		for (i = 0; i < NUM_WORDS; i = i + 1)
			begin : p_WordIter
				for (j = 0; j < NUM_BYTE; j = j + 1)
					begin : p_ByteIter
						if (((WriteEnable_A == 1'b1) && (WriteBE_A[j] == 1'b1)) && (WriteAddr_A == i))
							WAddrOneHotxD_A[(i * NUM_BYTE) + j] = 1'b1;
						else
							WAddrOneHotxD_A[(i * NUM_BYTE) + j] = 1'b0;
						if (((WriteEnable_B == 1'b1) && (WriteBE_B[j] == 1'b1)) && (WriteAddr_B == i))
							WAddrOneHotxD_B[(i * NUM_BYTE) + j] = 1'b1;
						else
							WAddrOneHotxD_B[(i * NUM_BYTE) + j] = 1'b0;
					end
			end
	end
	always @(posedge clk_int)
		if (WriteEnable_A | WriteEnable_B)
			WAddrOneHotxD_B_q <= WAddrOneHotxD_B;
	generate
		for (x = 0; x < NUM_WORDS; x = x + 1) begin : CG_CELL_WORD_ITER
			for (y = 0; y < NUM_BYTE; y = y + 1) begin : CG_CELL_BYTE_ITER
				cluster_clock_gating CG_Inst(
					.clk_o(ClocksxC[(x * NUM_BYTE) + y]),
					.en_i(WAddrOneHotxD_A[(x * NUM_BYTE) + y] | WAddrOneHotxD_B[(x * NUM_BYTE) + y]),
					.test_en_i(1'b0),
					.clk_i(clk_int)
				);
			end
		end
	endgenerate
	always @(posedge clk) begin : sample_waddr
		for (m = 0; m < NUM_BYTE; m = m + 1)
			begin
				if (WriteEnable_A & WriteBE_A[m])
					WDataIntxD_A[m * 8+:8] <= WriteData_A[m * 8+:8];
				if (WriteEnable_B & WriteBE_B[m])
					WDataIntxD_B[m * 8+:8] <= WriteData_B[m * 8+:8];
			end
	end
	generate
		for (k = 0; k < NUM_WORDS; k = k + 1) begin : w_WordIter
			for (l = 0; l < NUM_BYTE; l = l + 1) begin : w_ByteIter
				always @(ClocksxC[(k * NUM_BYTE) + l] or WAddrOneHotxD_B_q[(k * NUM_BYTE) + l] or WDataIntxD_B[l * 8+:8] or WDataIntxD_A[l * 8+:8]) begin : latch_wdata
					if (ClocksxC[(k * NUM_BYTE) + l] == 1'b1)
						MemContentxDP[((k * NUM_BYTE) + l) * 8+:8] = (WAddrOneHotxD_B_q[(k * NUM_BYTE) + l] ? WDataIntxD_B[l * 8+:8] : WDataIntxD_A[l * 8+:8]);
				end
			end
		end
	endgenerate
endmodule
