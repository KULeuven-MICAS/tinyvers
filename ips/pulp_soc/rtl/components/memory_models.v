module model_8192x32_memory (
	CLK,
	RSTN,
	INITN,
	scan_en_in,
	CSN,
	WEN,
	M,
	A,
	D,
	Q
);
	input wire CLK;
	input wire RSTN;
	input wire INITN;
	input wire scan_en_in;
	input wire CSN;
	input wire WEN;
	input wire [31:0] M;
	input wire [12:0] A;
	input wire [31:0] D;
	output wire [31:0] Q;
	wire csn_1;
	wire csn_0;
	wire [63:0] Q_int;
	reg muxsel;
	wire CLK_gated;
	assign csn_0 = CSN | A[12];
	assign csn_1 = CSN | ~A[12];
	assign Q = Q_int[muxsel * 32+:32];
	always @(posedge CLK or negedge RSTN)
		if (~RSTN)
			muxsel <= 0;
		else if (CSN == 1'b0)
			muxsel <= A[12];
	MEMS1D_BUFG_4096x32_wrapper cut_0(
		.CLK(CLK_gated),
		.D(D),
		.AS(A[11:9]),
		.AW(A[8:2]),
		.AC(A[1:0]),
		.CEN(csn_0),
		.RDWEN(WEN),
		.BW(~M),
		.Q(Q_int[0+:32])
	);
	MEMS1D_BUFG_4096x32_wrapper cut_1(
		.CLK(CLK_gated),
		.D(D),
		.AS(A[11:9]),
		.AW(A[8:2]),
		.AC(A[1:0]),
		.CEN(csn_1),
		.RDWEN(WEN),
		.BW(~M),
		.Q(Q_int[32+:32])
	);
	pulp_clock_gating i_clk_gate_l2_mem_1(
		.clk_i(CLK),
		.en_i(~scan_en_in),
		.test_en_i(1'b0),
		.clk_o(CLK_gated)
	);
endmodule
module model_sram_28672x32_scm_512x32 (
	CLK,
	RSTN,
	scan_en_in,
	CEN,
	WEN,
	BEN,
	A,
	D,
	Q
);
	input wire CLK;
	input wire RSTN;
	input wire scan_en_in;
	input wire CEN;
	input wire WEN;
	input wire [3:0] BEN;
	input wire [14:0] A;
	input wire [31:0] D;
	output wire [31:0] Q;
	wire [7:0] CEN_int;
	wire CEN_sram;
	wire [255:0] Q_int;
	reg [2:0] muxsel;
	wire [31:0] BE_BW;
	wire [31:0] mask;
	wire CLK_gated;
	wire [3:0] BE;
	assign BE = ~BEN;
	assign BE_BW = {{8 {BE[3]}}, {8 {BE[2]}}, {8 {BE[1]}}, {8 {BE[0]}}};
	assign mask = {{8 {BEN[3]}}, {8 {BEN[2]}}, {8 {BEN[1]}}, {8 {BEN[0]}}};
	assign CEN_int[0] = ((CEN | A[14]) | A[13]) | A[12];
	assign CEN_int[1] = ((CEN | A[14]) | A[13]) | ~A[12];
	assign CEN_int[2] = ((CEN | A[14]) | ~A[13]) | A[12];
	assign CEN_int[3] = ((CEN | A[14]) | ~A[13]) | ~A[12];
	assign CEN_int[4] = ((CEN | ~A[14]) | A[13]) | A[12];
	assign CEN_int[5] = ((CEN | ~A[14]) | A[13]) | ~A[12];
	assign CEN_int[6] = ((CEN | ~A[14]) | ~A[13]) | A[12];
	assign CEN_int[7] = ((CEN | ~A[14]) | ~A[13]) | ~A[12];
	assign Q = Q_int[muxsel * 32+:32];
	always @(posedge CLK or negedge RSTN)
		if (~RSTN)
			muxsel <= 1'sb0;
		else if (CEN == 1'b0)
			muxsel <= A[14:12];
	MEMS1D_BUFG_4096x32_wrapper cut_0(
		.CLK(CLK_gated),
		.D(D),
		.AS(A[11:9]),
		.AW(A[8:2]),
		.AC(A[1:0]),
		.CEN(CEN_int[0]),
		.RDWEN(WEN),
		.BW(~mask),
		.Q(Q_int[0+:32])
	);
	MEMS1D_BUFG_4096x32_wrapper cut_1(
		.CLK(CLK_gated),
		.D(D),
		.AS(A[11:9]),
		.AW(A[8:2]),
		.AC(A[1:0]),
		.CEN(CEN_int[1]),
		.RDWEN(WEN),
		.BW(~mask),
		.Q(Q_int[32+:32])
	);
	MEMS1D_BUFG_4096x32_wrapper cut_2(
		.CLK(CLK_gated),
		.D(D),
		.AS(A[11:9]),
		.AW(A[8:2]),
		.AC(A[1:0]),
		.CEN(CEN_int[2]),
		.RDWEN(WEN),
		.BW(~mask),
		.Q(Q_int[64+:32])
	);
	MEMS1D_BUFG_4096x32_wrapper cut_3(
		.CLK(CLK_gated),
		.D(D),
		.AS(A[11:9]),
		.AW(A[8:2]),
		.AC(A[1:0]),
		.CEN(CEN_int[3]),
		.RDWEN(WEN),
		.BW(~mask),
		.Q(Q_int[96+:32])
	);
	MEMS1D_BUFG_4096x32_wrapper cut_4(
		.CLK(CLK_gated),
		.D(D),
		.AS(A[11:9]),
		.AW(A[8:2]),
		.AC(A[1:0]),
		.CEN(CEN_int[4]),
		.RDWEN(WEN),
		.BW(~mask),
		.Q(Q_int[128+:32])
	);
	MEMS1D_BUFG_4096x32_wrapper cut_5(
		.CLK(CLK_gated),
		.D(D),
		.AS(A[11:9]),
		.AW(A[8:2]),
		.AC(A[1:0]),
		.CEN(CEN_int[5]),
		.RDWEN(WEN),
		.BW(~mask),
		.Q(Q_int[160+:32])
	);
	MEMS1D_BUFG_4096x32_wrapper cut_6(
		.CLK(CLK_gated),
		.D(D),
		.AS(A[11:9]),
		.AW(A[8:2]),
		.AC(A[1:0]),
		.CEN(CEN_int[6]),
		.RDWEN(WEN),
		.BW(~mask),
		.Q(Q_int[192+:32])
	);
	MEMS1D_BUFG_512x32_wrapper scm_7(
		.CLK(CLK_gated),
		.D(D[31:0]),
		.AS(A[8]),
		.AW(A[7:2]),
		.AC(A[1:0]),
		.CEN(CEN_int[7]),
		.RDWEN(WEN),
		.BW(BE_BW),
		.Q(Q_int[224+:32])
	);
	pulp_clock_gating i_clk_gate_l2_mem(
		.clk_i(CLK),
		.en_i(~scan_en_in),
		.test_en_i(1'b0),
		.clk_o(CLK_gated)
	);
endmodule
