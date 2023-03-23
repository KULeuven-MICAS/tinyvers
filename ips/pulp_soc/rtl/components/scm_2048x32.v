module scm_2048x32 (
	CLK,
	RSTN,
	CEN,
	CEN_scm0,
	CEN_scm1,
	WEN,
	WEN_scm0,
	WEN_scm1,
	BE,
	BE_scm0,
	A,
	A_scm0,
	A_scm1,
	D,
	D_scm0,
	Q,
	Q_scm0,
	Q_scm1
);
	input wire CLK;
	input wire RSTN;
	input wire CEN;
	input wire CEN_scm0;
	input wire CEN_scm1;
	input wire WEN;
	input wire WEN_scm0;
	input wire WEN_scm1;
	input wire [3:0] BE;
	input wire [3:0] BE_scm0;
	input wire [10:0] A;
	input wire [10:0] A_scm0;
	input wire [10:0] A_scm1;
	input wire [31:0] D;
	input wire [31:0] D_scm0;
	output wire [31:0] Q;
	output wire [31:0] Q_scm0;
	output wire [31:0] Q_scm1;
	localparam NB_BANKS = 16;
	localparam ADDR_WIDTH = 7;
	wire [15:0] CEN_int;
	wire [15:0] CEN_scm0_int;
	wire [15:0] CEN_scm1_int;
	wire [15:0] read_enA;
	wire [15:0] read_enB;
	wire [15:0] read_enC;
	wire [15:0] write_enA;
	wire [15:0] write_enB;
	wire [511:0] Q_int;
	wire [511:0] Q_int_scm0;
	wire [511:0] Q_int_scm1;
	reg [3:0] muxsel_A;
	reg [3:0] muxsel_A_scm0;
	reg [3:0] muxsel_A_scm1;
	always @(posedge CLK or negedge RSTN)
		if (~RSTN) begin
			muxsel_A <= 1'sb0;
			muxsel_A_scm0 <= 1'sb0;
			muxsel_A_scm1 <= 1'sb0;
		end
		else begin
			if (CEN == 1'b0)
				muxsel_A <= A[10:7];
			if (CEN_scm0 == 1'b0)
				muxsel_A_scm0 <= A_scm0[10:7];
			if (CEN_scm1 == 1'b0)
				muxsel_A_scm1 <= A_scm1[10:7];
		end
	assign Q = Q_int[muxsel_A * 32+:32];
	assign Q_scm0 = Q_int_scm0[muxsel_A_scm0 * 32+:32];
	assign Q_scm1 = Q_int_scm1[muxsel_A_scm1 * 32+:32];
	genvar i;
	generate
		for (i = 0; i < NB_BANKS; i = i + 1) begin : SCM_CUT
			assign CEN_int[i] = CEN | (A[10:7] != i);
			assign CEN_scm0_int[i] = CEN_scm0 | (A_scm0[10:7] != i);
			assign CEN_scm1_int[i] = CEN_scm1 | (A_scm1[10:7] != i);
			assign read_enA[i] = ~CEN_int[i] & WEN;
			assign read_enB[i] = ~CEN_scm0_int[i] & WEN_scm0;
			assign read_enC[i] = ~CEN_scm1_int[i] & WEN_scm1;
			assign write_enA[i] = ~CEN_int[i] & ~WEN;
			assign write_enB[i] = ~CEN_scm0_int[i] & ~WEN_scm0;
			register_file_3r_2w_be #(
				.ADDR_WIDTH(ADDR_WIDTH),
				.DATA_WIDTH(32)
			) scm_i(
				.clk(CLK),
				.ReadEnable_A(read_enA[i]),
				.ReadAddr_A(A[6:0]),
				.ReadData_A(Q_int[i * 32+:32]),
				.ReadEnable_B(read_enB[i]),
				.ReadAddr_B(A_scm0[6:0]),
				.ReadData_B(Q_int_scm0[i * 32+:32]),
				.ReadEnable_C(read_enC[i]),
				.ReadAddr_C(A_scm1[6:0]),
				.ReadData_C(Q_int_scm1[i * 32+:32]),
				.WriteEnable_A(write_enA[i]),
				.WriteAddr_A(A[6:0]),
				.WriteData_A(D[31:0]),
				.WriteBE_A(BE),
				.WriteEnable_B(write_enB[i]),
				.WriteAddr_B(A_scm0[6:0]),
				.WriteData_B(D_scm0[31:0]),
				.WriteBE_B(BE_scm0)
			);
		end
	endgenerate
endmodule
