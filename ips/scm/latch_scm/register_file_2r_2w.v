module register_file_2r_2w (
	clk,
	rst_n,
	raddr_a_i,
	rdata_a_o,
	raddr_b_i,
	rdata_b_o,
	waddr_a_i,
	wdata_a_i,
	we_a_i,
	waddr_b_i,
	wdata_b_i,
	we_b_i
);
	parameter ADDR_WIDTH = 5;
	parameter DATA_WIDTH = 32;
	input wire clk;
	input wire rst_n;
	input wire [ADDR_WIDTH - 1:0] raddr_a_i;
	output wire [DATA_WIDTH - 1:0] rdata_a_o;
	input wire [ADDR_WIDTH - 1:0] raddr_b_i;
	output wire [DATA_WIDTH - 1:0] rdata_b_o;
	input wire [ADDR_WIDTH - 1:0] waddr_a_i;
	input wire [DATA_WIDTH - 1:0] wdata_a_i;
	input wire we_a_i;
	input wire [ADDR_WIDTH - 1:0] waddr_b_i;
	input wire [DATA_WIDTH - 1:0] wdata_b_i;
	input wire we_b_i;
	localparam NUM_WORDS = 2 ** ADDR_WIDTH;
	wire [ADDR_WIDTH - 1:0] RAddrRegxDPa;
	wire [ADDR_WIDTH - 1:0] RAddrRegxDPb;
	wire [NUM_WORDS - 1:0] RAddrOneHotxD;
	reg [DATA_WIDTH - 1:0] MemContentxDP [0:NUM_WORDS - 1];
	reg [NUM_WORDS - 1:0] WAddrOneHotxDa;
	reg [NUM_WORDS - 1:0] WAddrOneHotxDb;
	reg [NUM_WORDS - 1:0] WAddrOneHotxDb_reg;
	wire [NUM_WORDS - 1:0] ClocksxC;
	reg [DATA_WIDTH - 1:0] WDataIntxDa;
	reg [DATA_WIDTH - 1:0] WDataIntxDb;
	wire clk_int;
	wire we_int;
	reg [31:0] i;
	reg [31:0] j;
	reg [31:0] k;
	wire [31:0] l;
	wire [31:0] m;
	genvar x;
	genvar y;
	assign we_int = we_a_i | we_b_i;
	cluster_clock_gating CG_WE_GLOBAL(
		.clk_o(clk_int),
		.en_i(we_int),
		.test_en_i(1'b0),
		.clk_i(clk)
	);
	assign rdata_a_o = MemContentxDP[raddr_a_i];
	assign rdata_b_o = MemContentxDP[raddr_b_i];
	always @(*) begin : p_WADa
		for (i = 0; i < NUM_WORDS; i = i + 1)
			begin : p_WordItera
				if ((we_a_i == 1'b1) && (waddr_a_i == i))
					WAddrOneHotxDa[i] = 1'b1;
				else
					WAddrOneHotxDa[i] = 1'b0;
			end
	end
	always @(*) begin : p_WADb
		for (j = 0; j < NUM_WORDS; j = j + 1)
			begin : p_WordIterb
				if ((we_b_i == 1'b1) && (waddr_b_i == j))
					WAddrOneHotxDb[j] = 1'b1;
				else
					WAddrOneHotxDb[j] = 1'b0;
			end
	end
	always @(posedge clk_int)
		if (we_a_i | we_b_i)
			WAddrOneHotxDb_reg <= WAddrOneHotxDb;
	generate
		for (x = 0; x < NUM_WORDS; x = x + 1) begin : CG_CELL_WORD_ITER
			cluster_clock_gating CG_Inst(
				.clk_o(ClocksxC[x]),
				.en_i(WAddrOneHotxDa[x] | WAddrOneHotxDb[x]),
				.test_en_i(1'b0),
				.clk_i(clk_int)
			);
		end
	endgenerate
	always @(posedge clk) begin : sample_waddr
		if (we_a_i)
			WDataIntxDa <= wdata_a_i;
		if (we_b_i)
			WDataIntxDb <= wdata_b_i;
	end
	always @(*) begin : latch_wdata
		for (k = 0; k < NUM_WORDS; k = k + 1)
			begin : w_WordIter
				if (ClocksxC[k] == 1'b1)
					MemContentxDP[k] = (WAddrOneHotxDb_reg[k] ? WDataIntxDb : WDataIntxDa);
			end
	end
endmodule
