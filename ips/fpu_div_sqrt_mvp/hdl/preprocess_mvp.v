module preprocess_mvp (
	Clk_CI,
	Rst_RBI,
	Div_start_SI,
	Sqrt_start_SI,
	Ready_SI,
	Operand_a_DI,
	Operand_b_DI,
	RM_SI,
	Format_sel_SI,
	Start_SO,
	Exp_a_DO_norm,
	Exp_b_DO_norm,
	Mant_a_DO_norm,
	Mant_b_DO_norm,
	RM_dly_SO,
	Sign_z_DO,
	Inf_a_SO,
	Inf_b_SO,
	Zero_a_SO,
	Zero_b_SO,
	NaN_a_SO,
	NaN_b_SO,
	SNaN_SO,
	Special_case_SBO,
	Special_case_dly_SBO
);
	input wire Clk_CI;
	input wire Rst_RBI;
	input wire Div_start_SI;
	input wire Sqrt_start_SI;
	input wire Ready_SI;
	localparam defs_div_sqrt_mvp_C_OP_FP64 = 64;
	input wire [63:0] Operand_a_DI;
	input wire [63:0] Operand_b_DI;
	localparam defs_div_sqrt_mvp_C_RM = 3;
	input wire [2:0] RM_SI;
	localparam defs_div_sqrt_mvp_C_FS = 2;
	input wire [1:0] Format_sel_SI;
	output wire Start_SO;
	localparam defs_div_sqrt_mvp_C_EXP_FP64 = 11;
	output wire [defs_div_sqrt_mvp_C_EXP_FP64:0] Exp_a_DO_norm;
	output wire [defs_div_sqrt_mvp_C_EXP_FP64:0] Exp_b_DO_norm;
	localparam defs_div_sqrt_mvp_C_MANT_FP64 = 52;
	output wire [defs_div_sqrt_mvp_C_MANT_FP64:0] Mant_a_DO_norm;
	output wire [defs_div_sqrt_mvp_C_MANT_FP64:0] Mant_b_DO_norm;
	output wire [2:0] RM_dly_SO;
	output wire Sign_z_DO;
	output wire Inf_a_SO;
	output wire Inf_b_SO;
	output wire Zero_a_SO;
	output wire Zero_b_SO;
	output wire NaN_a_SO;
	output wire NaN_b_SO;
	output wire SNaN_SO;
	output wire Special_case_SBO;
	output reg Special_case_dly_SBO;
	wire Hb_a_D;
	wire Hb_b_D;
	reg [10:0] Exp_a_D;
	reg [10:0] Exp_b_D;
	reg [51:0] Mant_a_NonH_D;
	reg [51:0] Mant_b_NonH_D;
	wire [defs_div_sqrt_mvp_C_MANT_FP64:0] Mant_a_D;
	wire [defs_div_sqrt_mvp_C_MANT_FP64:0] Mant_b_D;
	reg Sign_a_D;
	reg Sign_b_D;
	wire Start_S;
	localparam defs_div_sqrt_mvp_C_MANT_FP16 = 10;
	localparam defs_div_sqrt_mvp_C_MANT_FP16ALT = 7;
	localparam defs_div_sqrt_mvp_C_MANT_FP32 = 23;
	localparam defs_div_sqrt_mvp_C_OP_FP16 = 16;
	localparam defs_div_sqrt_mvp_C_OP_FP16ALT = 16;
	localparam defs_div_sqrt_mvp_C_OP_FP32 = 32;
	always @(*)
		case (Format_sel_SI)
			2'b00: begin
				Sign_a_D = Operand_a_DI[31];
				Sign_b_D = Operand_b_DI[31];
				Exp_a_D = {3'h0, Operand_a_DI[30:defs_div_sqrt_mvp_C_MANT_FP32]};
				Exp_b_D = {3'h0, Operand_b_DI[30:defs_div_sqrt_mvp_C_MANT_FP32]};
				Mant_a_NonH_D = {Operand_a_DI[22:0], 29'h00000000};
				Mant_b_NonH_D = {Operand_b_DI[22:0], 29'h00000000};
			end
			2'b01: begin
				Sign_a_D = Operand_a_DI[63];
				Sign_b_D = Operand_b_DI[63];
				Exp_a_D = Operand_a_DI[62:defs_div_sqrt_mvp_C_MANT_FP64];
				Exp_b_D = Operand_b_DI[62:defs_div_sqrt_mvp_C_MANT_FP64];
				Mant_a_NonH_D = Operand_a_DI[51:0];
				Mant_b_NonH_D = Operand_b_DI[51:0];
			end
			2'b10: begin
				Sign_a_D = Operand_a_DI[15];
				Sign_b_D = Operand_b_DI[15];
				Exp_a_D = {6'h00, Operand_a_DI[14:defs_div_sqrt_mvp_C_MANT_FP16]};
				Exp_b_D = {6'h00, Operand_b_DI[14:defs_div_sqrt_mvp_C_MANT_FP16]};
				Mant_a_NonH_D = {Operand_a_DI[9:0], 42'h00000000000};
				Mant_b_NonH_D = {Operand_b_DI[9:0], 42'h00000000000};
			end
			2'b11: begin
				Sign_a_D = Operand_a_DI[15];
				Sign_b_D = Operand_b_DI[15];
				Exp_a_D = {3'h0, Operand_a_DI[14:defs_div_sqrt_mvp_C_MANT_FP16ALT]};
				Exp_b_D = {3'h0, Operand_b_DI[14:defs_div_sqrt_mvp_C_MANT_FP16ALT]};
				Mant_a_NonH_D = {Operand_a_DI[6:0], 45'h000000000000};
				Mant_b_NonH_D = {Operand_b_DI[6:0], 45'h000000000000};
			end
		endcase
	assign Mant_a_D = {Hb_a_D, Mant_a_NonH_D};
	assign Mant_b_D = {Hb_b_D, Mant_b_NonH_D};
	assign Hb_a_D = |Exp_a_D;
	assign Hb_b_D = |Exp_b_D;
	assign Start_S = Div_start_SI | Sqrt_start_SI;
	reg Mant_a_prenorm_zero_S;
	reg Mant_b_prenorm_zero_S;
	wire Exp_a_prenorm_zero_S;
	wire Exp_b_prenorm_zero_S;
	assign Exp_a_prenorm_zero_S = ~Hb_a_D;
	assign Exp_b_prenorm_zero_S = ~Hb_b_D;
	reg Exp_a_prenorm_Inf_NaN_S;
	reg Exp_b_prenorm_Inf_NaN_S;
	wire Mant_a_prenorm_QNaN_S;
	wire Mant_a_prenorm_SNaN_S;
	wire Mant_b_prenorm_QNaN_S;
	wire Mant_b_prenorm_SNaN_S;
	assign Mant_a_prenorm_QNaN_S = Mant_a_NonH_D[51] && ~(|Mant_a_NonH_D[50:0]);
	assign Mant_a_prenorm_SNaN_S = ~Mant_a_NonH_D[51] && |Mant_a_NonH_D[50:0];
	assign Mant_b_prenorm_QNaN_S = Mant_b_NonH_D[51] && ~(|Mant_b_NonH_D[50:0]);
	assign Mant_b_prenorm_SNaN_S = ~Mant_b_NonH_D[51] && |Mant_b_NonH_D[50:0];
	localparam defs_div_sqrt_mvp_C_EXP_INF_FP16 = 5'h1f;
	localparam defs_div_sqrt_mvp_C_EXP_INF_FP16ALT = 8'hff;
	localparam defs_div_sqrt_mvp_C_EXP_INF_FP32 = 8'hff;
	localparam defs_div_sqrt_mvp_C_EXP_INF_FP64 = 11'h7ff;
	localparam defs_div_sqrt_mvp_C_MANT_ZERO_FP16 = 10'h000;
	localparam defs_div_sqrt_mvp_C_MANT_ZERO_FP16ALT = 7'h00;
	localparam defs_div_sqrt_mvp_C_MANT_ZERO_FP32 = 23'h000000;
	localparam defs_div_sqrt_mvp_C_MANT_ZERO_FP64 = 52'h0000000000000;
	always @(*)
		case (Format_sel_SI)
			2'b00: begin
				Mant_a_prenorm_zero_S = Operand_a_DI[22:0] == defs_div_sqrt_mvp_C_MANT_ZERO_FP32;
				Mant_b_prenorm_zero_S = Operand_b_DI[22:0] == defs_div_sqrt_mvp_C_MANT_ZERO_FP32;
				Exp_a_prenorm_Inf_NaN_S = Operand_a_DI[30:defs_div_sqrt_mvp_C_MANT_FP32] == defs_div_sqrt_mvp_C_EXP_INF_FP32;
				Exp_b_prenorm_Inf_NaN_S = Operand_b_DI[30:defs_div_sqrt_mvp_C_MANT_FP32] == defs_div_sqrt_mvp_C_EXP_INF_FP32;
			end
			2'b01: begin
				Mant_a_prenorm_zero_S = Operand_a_DI[51:0] == defs_div_sqrt_mvp_C_MANT_ZERO_FP64;
				Mant_b_prenorm_zero_S = Operand_b_DI[51:0] == defs_div_sqrt_mvp_C_MANT_ZERO_FP64;
				Exp_a_prenorm_Inf_NaN_S = Operand_a_DI[62:defs_div_sqrt_mvp_C_MANT_FP64] == defs_div_sqrt_mvp_C_EXP_INF_FP64;
				Exp_b_prenorm_Inf_NaN_S = Operand_b_DI[62:defs_div_sqrt_mvp_C_MANT_FP64] == defs_div_sqrt_mvp_C_EXP_INF_FP64;
			end
			2'b10: begin
				Mant_a_prenorm_zero_S = Operand_a_DI[9:0] == defs_div_sqrt_mvp_C_MANT_ZERO_FP16;
				Mant_b_prenorm_zero_S = Operand_b_DI[9:0] == defs_div_sqrt_mvp_C_MANT_ZERO_FP16;
				Exp_a_prenorm_Inf_NaN_S = Operand_a_DI[14:defs_div_sqrt_mvp_C_MANT_FP16] == defs_div_sqrt_mvp_C_EXP_INF_FP16;
				Exp_b_prenorm_Inf_NaN_S = Operand_b_DI[14:defs_div_sqrt_mvp_C_MANT_FP16] == defs_div_sqrt_mvp_C_EXP_INF_FP16;
			end
			2'b11: begin
				Mant_a_prenorm_zero_S = Operand_a_DI[6:0] == defs_div_sqrt_mvp_C_MANT_ZERO_FP16ALT;
				Mant_b_prenorm_zero_S = Operand_b_DI[6:0] == defs_div_sqrt_mvp_C_MANT_ZERO_FP16ALT;
				Exp_a_prenorm_Inf_NaN_S = Operand_a_DI[14:defs_div_sqrt_mvp_C_MANT_FP16ALT] == defs_div_sqrt_mvp_C_EXP_INF_FP16ALT;
				Exp_b_prenorm_Inf_NaN_S = Operand_b_DI[14:defs_div_sqrt_mvp_C_MANT_FP16ALT] == defs_div_sqrt_mvp_C_EXP_INF_FP16ALT;
			end
		endcase
	wire Zero_a_SN;
	reg Zero_a_SP;
	wire Zero_b_SN;
	reg Zero_b_SP;
	wire Inf_a_SN;
	reg Inf_a_SP;
	wire Inf_b_SN;
	reg Inf_b_SP;
	wire NaN_a_SN;
	reg NaN_a_SP;
	wire NaN_b_SN;
	reg NaN_b_SP;
	wire SNaN_SN;
	reg SNaN_SP;
	assign Zero_a_SN = (Start_S && Ready_SI ? Exp_a_prenorm_zero_S && Mant_a_prenorm_zero_S : Zero_a_SP);
	assign Zero_b_SN = (Start_S && Ready_SI ? Exp_b_prenorm_zero_S && Mant_b_prenorm_zero_S : Zero_b_SP);
	assign Inf_a_SN = (Start_S && Ready_SI ? Exp_a_prenorm_Inf_NaN_S && Mant_a_prenorm_zero_S : Inf_a_SP);
	assign Inf_b_SN = (Start_S && Ready_SI ? Exp_b_prenorm_Inf_NaN_S && Mant_b_prenorm_zero_S : Inf_b_SP);
	assign NaN_a_SN = (Start_S && Ready_SI ? Exp_a_prenorm_Inf_NaN_S && ~Mant_a_prenorm_zero_S : NaN_a_SP);
	assign NaN_b_SN = (Start_S && Ready_SI ? Exp_b_prenorm_Inf_NaN_S && ~Mant_b_prenorm_zero_S : NaN_b_SP);
	assign SNaN_SN = (Start_S && Ready_SI ? (Mant_a_prenorm_SNaN_S && NaN_a_SN) | (Mant_b_prenorm_SNaN_S && NaN_b_SN) : SNaN_SP);
	always @(posedge Clk_CI or negedge Rst_RBI)
		if (~Rst_RBI) begin
			Zero_a_SP <= 1'sb0;
			Zero_b_SP <= 1'sb0;
			Inf_a_SP <= 1'sb0;
			Inf_b_SP <= 1'sb0;
			NaN_a_SP <= 1'sb0;
			NaN_b_SP <= 1'sb0;
			SNaN_SP <= 1'sb0;
		end
		else begin
			Inf_a_SP <= Inf_a_SN;
			Inf_b_SP <= Inf_b_SN;
			Zero_a_SP <= Zero_a_SN;
			Zero_b_SP <= Zero_b_SN;
			NaN_a_SP <= NaN_a_SN;
			NaN_b_SP <= NaN_b_SN;
			SNaN_SP <= SNaN_SN;
		end
	assign Special_case_SBO = ~{(Div_start_SI ? ((((Zero_a_SN | Zero_b_SN) | Inf_a_SN) | Inf_b_SN) | NaN_a_SN) | NaN_b_SN : ((Zero_a_SN | Inf_a_SN) | NaN_a_SN) | Sign_a_D)} && (Start_S && Ready_SI);
	always @(posedge Clk_CI or negedge Rst_RBI)
		if (~Rst_RBI)
			Special_case_dly_SBO <= 1'sb0;
		else if (Start_S && Ready_SI)
			Special_case_dly_SBO <= Special_case_SBO;
		else if (Special_case_dly_SBO)
			Special_case_dly_SBO <= 1'b1;
		else
			Special_case_dly_SBO <= 1'sb0;
	reg Sign_z_DN;
	reg Sign_z_DP;
	always @(*)
		if (Div_start_SI && Ready_SI)
			Sign_z_DN = Sign_a_D ^ Sign_b_D;
		else if (Sqrt_start_SI && Ready_SI)
			Sign_z_DN = Sign_a_D;
		else
			Sign_z_DN = Sign_z_DP;
	always @(posedge Clk_CI or negedge Rst_RBI)
		if (~Rst_RBI)
			Sign_z_DP <= 1'sb0;
		else
			Sign_z_DP <= Sign_z_DN;
	reg [2:0] RM_DN;
	reg [2:0] RM_DP;
	always @(*)
		if (Start_S && Ready_SI)
			RM_DN = RM_SI;
		else
			RM_DN = RM_DP;
	always @(posedge Clk_CI or negedge Rst_RBI)
		if (~Rst_RBI)
			RM_DP <= 1'sb0;
		else
			RM_DP <= RM_DN;
	assign RM_dly_SO = RM_DP;
	wire [5:0] Mant_leadingOne_a;
	wire [5:0] Mant_leadingOne_b;
	wire Mant_zero_S_a;
	wire Mant_zero_S_b;
	lzc #(
		.WIDTH(53),
		.MODE(1)
	) LOD_Ua(
		.in_i(Mant_a_D),
		.cnt_o(Mant_leadingOne_a),
		.empty_o(Mant_zero_S_a)
	);
	wire [defs_div_sqrt_mvp_C_MANT_FP64:0] Mant_a_norm_DN;
	reg [defs_div_sqrt_mvp_C_MANT_FP64:0] Mant_a_norm_DP;
	assign Mant_a_norm_DN = (Start_S && Ready_SI ? Mant_a_D << Mant_leadingOne_a : Mant_a_norm_DP);
	always @(posedge Clk_CI or negedge Rst_RBI)
		if (~Rst_RBI)
			Mant_a_norm_DP <= 1'sb0;
		else
			Mant_a_norm_DP <= Mant_a_norm_DN;
	wire [defs_div_sqrt_mvp_C_EXP_FP64:0] Exp_a_norm_DN;
	reg [defs_div_sqrt_mvp_C_EXP_FP64:0] Exp_a_norm_DP;
	assign Exp_a_norm_DN = (Start_S && Ready_SI ? (Exp_a_D - Mant_leadingOne_a) + |Mant_leadingOne_a : Exp_a_norm_DP);
	always @(posedge Clk_CI or negedge Rst_RBI)
		if (~Rst_RBI)
			Exp_a_norm_DP <= 1'sb0;
		else
			Exp_a_norm_DP <= Exp_a_norm_DN;
	lzc #(
		.WIDTH(53),
		.MODE(1)
	) LOD_Ub(
		.in_i(Mant_b_D),
		.cnt_o(Mant_leadingOne_b),
		.empty_o(Mant_zero_S_b)
	);
	wire [defs_div_sqrt_mvp_C_MANT_FP64:0] Mant_b_norm_DN;
	reg [defs_div_sqrt_mvp_C_MANT_FP64:0] Mant_b_norm_DP;
	assign Mant_b_norm_DN = (Start_S && Ready_SI ? Mant_b_D << Mant_leadingOne_b : Mant_b_norm_DP);
	always @(posedge Clk_CI or negedge Rst_RBI)
		if (~Rst_RBI)
			Mant_b_norm_DP <= 1'sb0;
		else
			Mant_b_norm_DP <= Mant_b_norm_DN;
	wire [defs_div_sqrt_mvp_C_EXP_FP64:0] Exp_b_norm_DN;
	reg [defs_div_sqrt_mvp_C_EXP_FP64:0] Exp_b_norm_DP;
	assign Exp_b_norm_DN = (Start_S && Ready_SI ? (Exp_b_D - Mant_leadingOne_b) + |Mant_leadingOne_b : Exp_b_norm_DP);
	always @(posedge Clk_CI or negedge Rst_RBI)
		if (~Rst_RBI)
			Exp_b_norm_DP <= 1'sb0;
		else
			Exp_b_norm_DP <= Exp_b_norm_DN;
	assign Start_SO = Start_S;
	assign Exp_a_DO_norm = Exp_a_norm_DP;
	assign Exp_b_DO_norm = Exp_b_norm_DP;
	assign Mant_a_DO_norm = Mant_a_norm_DP;
	assign Mant_b_DO_norm = Mant_b_norm_DP;
	assign Sign_z_DO = Sign_z_DP;
	assign Inf_a_SO = Inf_a_SP;
	assign Inf_b_SO = Inf_b_SP;
	assign Zero_a_SO = Zero_a_SP;
	assign Zero_b_SO = Zero_b_SP;
	assign NaN_a_SO = NaN_a_SP;
	assign NaN_b_SO = NaN_b_SP;
	assign SNaN_SO = SNaN_SP;
endmodule
