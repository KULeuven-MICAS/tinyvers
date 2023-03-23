module norm_div_sqrt_mvp (
	Mant_in_DI,
	Exp_in_DI,
	Sign_in_DI,
	Div_enable_SI,
	Sqrt_enable_SI,
	Inf_a_SI,
	Inf_b_SI,
	Zero_a_SI,
	Zero_b_SI,
	NaN_a_SI,
	NaN_b_SI,
	SNaN_SI,
	RM_SI,
	Full_precision_SI,
	FP32_SI,
	FP64_SI,
	FP16_SI,
	FP16ALT_SI,
	Result_DO,
	Fflags_SO
);
	localparam defs_div_sqrt_mvp_C_MANT_FP64 = 52;
	input wire [56:0] Mant_in_DI;
	localparam defs_div_sqrt_mvp_C_EXP_FP64 = 11;
	input wire signed [12:0] Exp_in_DI;
	input wire Sign_in_DI;
	input wire Div_enable_SI;
	input wire Sqrt_enable_SI;
	input wire Inf_a_SI;
	input wire Inf_b_SI;
	input wire Zero_a_SI;
	input wire Zero_b_SI;
	input wire NaN_a_SI;
	input wire NaN_b_SI;
	input wire SNaN_SI;
	localparam defs_div_sqrt_mvp_C_RM = 3;
	input wire [2:0] RM_SI;
	input wire Full_precision_SI;
	input wire FP32_SI;
	input wire FP64_SI;
	input wire FP16_SI;
	input wire FP16ALT_SI;
	output reg [63:0] Result_DO;
	output wire [4:0] Fflags_SO;
	reg Sign_res_D;
	reg NV_OP_S;
	reg Exp_OF_S;
	reg Exp_UF_S;
	reg Div_Zero_S;
	wire In_Exact_S;
	reg [defs_div_sqrt_mvp_C_MANT_FP64:0] Mant_res_norm_D;
	reg [10:0] Exp_res_norm_D;
	wire [12:0] Exp_Max_RS_FP64_D;
	localparam defs_div_sqrt_mvp_C_EXP_FP32 = 8;
	wire [9:0] Exp_Max_RS_FP32_D;
	localparam defs_div_sqrt_mvp_C_EXP_FP16 = 5;
	wire [6:0] Exp_Max_RS_FP16_D;
	localparam defs_div_sqrt_mvp_C_EXP_FP16ALT = 8;
	wire [9:0] Exp_Max_RS_FP16ALT_D;
	assign Exp_Max_RS_FP64_D = (Exp_in_DI[defs_div_sqrt_mvp_C_EXP_FP64:0] + defs_div_sqrt_mvp_C_MANT_FP64) + 1;
	localparam defs_div_sqrt_mvp_C_MANT_FP32 = 23;
	assign Exp_Max_RS_FP32_D = (Exp_in_DI[defs_div_sqrt_mvp_C_EXP_FP32:0] + defs_div_sqrt_mvp_C_MANT_FP32) + 1;
	localparam defs_div_sqrt_mvp_C_MANT_FP16 = 10;
	assign Exp_Max_RS_FP16_D = (Exp_in_DI[defs_div_sqrt_mvp_C_EXP_FP16:0] + defs_div_sqrt_mvp_C_MANT_FP16) + 1;
	localparam defs_div_sqrt_mvp_C_MANT_FP16ALT = 7;
	assign Exp_Max_RS_FP16ALT_D = (Exp_in_DI[defs_div_sqrt_mvp_C_EXP_FP16ALT:0] + defs_div_sqrt_mvp_C_MANT_FP16ALT) + 1;
	wire [12:0] Num_RS_D;
	assign Num_RS_D = ~Exp_in_DI + 2;
	wire [defs_div_sqrt_mvp_C_MANT_FP64:0] Mant_RS_D;
	wire [56:0] Mant_forsticky_D;
	assign {Mant_RS_D, Mant_forsticky_D} = {Mant_in_DI, {53 {1'b0}}} >> Num_RS_D;
	wire [12:0] Exp_subOne_D;
	assign Exp_subOne_D = Exp_in_DI - 1;
	reg [1:0] Mant_lower_D;
	reg Mant_sticky_bit_D;
	reg [56:0] Mant_forround_D;
	localparam defs_div_sqrt_mvp_C_EXP_ONE_FP64 = 13'h0001;
	localparam defs_div_sqrt_mvp_C_MANT_NAN_FP64 = 52'h8000000000000;
	always @(*)
		if (NaN_a_SI) begin
			Div_Zero_S = 1'b0;
			Exp_OF_S = 1'b0;
			Exp_UF_S = 1'b0;
			Mant_res_norm_D = {1'b0, defs_div_sqrt_mvp_C_MANT_NAN_FP64};
			Exp_res_norm_D = 1'sb1;
			Mant_forround_D = 1'sb0;
			Sign_res_D = 1'b0;
			NV_OP_S = SNaN_SI;
		end
		else if (NaN_b_SI) begin
			Div_Zero_S = 1'b0;
			Exp_OF_S = 1'b0;
			Exp_UF_S = 1'b0;
			Mant_res_norm_D = {1'b0, defs_div_sqrt_mvp_C_MANT_NAN_FP64};
			Exp_res_norm_D = 1'sb1;
			Mant_forround_D = 1'sb0;
			Sign_res_D = 1'b0;
			NV_OP_S = SNaN_SI;
		end
		else if (Inf_a_SI) begin
			if (Div_enable_SI && Inf_b_SI) begin
				Div_Zero_S = 1'b0;
				Exp_OF_S = 1'b0;
				Exp_UF_S = 1'b0;
				Mant_res_norm_D = {1'b0, defs_div_sqrt_mvp_C_MANT_NAN_FP64};
				Exp_res_norm_D = 1'sb1;
				Mant_forround_D = 1'sb0;
				Sign_res_D = 1'b0;
				NV_OP_S = 1'b1;
			end
			else if (Sqrt_enable_SI && Sign_in_DI) begin
				Div_Zero_S = 1'b0;
				Exp_OF_S = 1'b0;
				Exp_UF_S = 1'b0;
				Mant_res_norm_D = {1'b0, defs_div_sqrt_mvp_C_MANT_NAN_FP64};
				Exp_res_norm_D = 1'sb1;
				Mant_forround_D = 1'sb0;
				Sign_res_D = 1'b0;
				NV_OP_S = 1'b1;
			end
			else begin
				Div_Zero_S = 1'b0;
				Exp_OF_S = 1'b1;
				Exp_UF_S = 1'b0;
				Mant_res_norm_D = 1'sb0;
				Exp_res_norm_D = 1'sb1;
				Mant_forround_D = 1'sb0;
				Sign_res_D = Sign_in_DI;
				NV_OP_S = 1'b0;
			end
		end
		else if (Div_enable_SI && Inf_b_SI) begin
			Div_Zero_S = 1'b0;
			Exp_OF_S = 1'b1;
			Exp_UF_S = 1'b0;
			Mant_res_norm_D = 1'sb0;
			Exp_res_norm_D = 1'sb0;
			Mant_forround_D = 1'sb0;
			Sign_res_D = Sign_in_DI;
			NV_OP_S = 1'b0;
		end
		else if (Zero_a_SI) begin
			if (Div_enable_SI && Zero_b_SI) begin
				Div_Zero_S = 1'b1;
				Exp_OF_S = 1'b0;
				Exp_UF_S = 1'b0;
				Mant_res_norm_D = {1'b0, defs_div_sqrt_mvp_C_MANT_NAN_FP64};
				Exp_res_norm_D = 1'sb1;
				Mant_forround_D = 1'sb0;
				Sign_res_D = 1'b0;
				NV_OP_S = 1'b1;
			end
			else begin
				Div_Zero_S = 1'b0;
				Exp_OF_S = 1'b0;
				Exp_UF_S = 1'b0;
				Mant_res_norm_D = 1'sb0;
				Exp_res_norm_D = 1'sb0;
				Mant_forround_D = 1'sb0;
				Sign_res_D = Sign_in_DI;
				NV_OP_S = 1'b0;
			end
		end
		else if (Div_enable_SI && Zero_b_SI) begin
			Div_Zero_S = 1'b1;
			Exp_OF_S = 1'b0;
			Exp_UF_S = 1'b0;
			Mant_res_norm_D = 1'sb0;
			Exp_res_norm_D = 1'sb1;
			Mant_forround_D = 1'sb0;
			Sign_res_D = Sign_in_DI;
			NV_OP_S = 1'b0;
		end
		else if (Sign_in_DI && Sqrt_enable_SI) begin
			Div_Zero_S = 1'b0;
			Exp_OF_S = 1'b0;
			Exp_UF_S = 1'b0;
			Mant_res_norm_D = {1'b0, defs_div_sqrt_mvp_C_MANT_NAN_FP64};
			Exp_res_norm_D = 1'sb1;
			Mant_forround_D = 1'sb0;
			Sign_res_D = 1'b0;
			NV_OP_S = 1'b1;
		end
		else if (Exp_in_DI[defs_div_sqrt_mvp_C_EXP_FP64:0] == {12 {1'sb0}}) begin
			if (Mant_in_DI != {57 {1'sb0}}) begin
				Div_Zero_S = 1'b0;
				Exp_OF_S = 1'b0;
				Exp_UF_S = 1'b1;
				Mant_res_norm_D = {1'b0, Mant_in_DI[56:5]};
				Exp_res_norm_D = 1'sb0;
				Mant_forround_D = {Mant_in_DI[4:0], {defs_div_sqrt_mvp_C_MANT_FP64 {1'b0}}};
				Sign_res_D = Sign_in_DI;
				NV_OP_S = 1'b0;
			end
			else begin
				Div_Zero_S = 1'b0;
				Exp_OF_S = 1'b0;
				Exp_UF_S = 1'b0;
				Mant_res_norm_D = 1'sb0;
				Exp_res_norm_D = 1'sb0;
				Mant_forround_D = 1'sb0;
				Sign_res_D = Sign_in_DI;
				NV_OP_S = 1'b0;
			end
		end
		else if ((Exp_in_DI[defs_div_sqrt_mvp_C_EXP_FP64:0] == defs_div_sqrt_mvp_C_EXP_ONE_FP64) && ~Mant_in_DI[56]) begin
			Div_Zero_S = 1'b0;
			Exp_OF_S = 1'b0;
			Exp_UF_S = 1'b1;
			Mant_res_norm_D = Mant_in_DI[56:4];
			Exp_res_norm_D = 1'sb0;
			Mant_forround_D = {Mant_in_DI[3:0], {53 {1'b0}}};
			Sign_res_D = Sign_in_DI;
			NV_OP_S = 1'b0;
		end
		else if (Exp_in_DI[12]) begin
			if ((((~Exp_Max_RS_FP32_D[9] && FP32_SI) | (~Exp_Max_RS_FP64_D[12] && FP64_SI)) | (~Exp_Max_RS_FP16_D[6] && FP16_SI)) | (~Exp_Max_RS_FP16ALT_D[9] && FP16ALT_SI)) begin
				Div_Zero_S = 1'b0;
				Exp_OF_S = 1'b1;
				Exp_UF_S = 1'b0;
				Mant_res_norm_D = 1'sb0;
				Exp_res_norm_D = 1'sb0;
				Mant_forround_D = 1'sb0;
				Sign_res_D = Sign_in_DI;
				NV_OP_S = 1'b0;
			end
			else begin
				Div_Zero_S = 1'b0;
				Exp_OF_S = 1'b0;
				Exp_UF_S = 1'b1;
				Mant_res_norm_D = {Mant_RS_D[defs_div_sqrt_mvp_C_MANT_FP64:0]};
				Exp_res_norm_D = 1'sb0;
				Mant_forround_D = {Mant_forsticky_D[56:0]};
				Sign_res_D = Sign_in_DI;
				NV_OP_S = 1'b0;
			end
		end
		else if ((((Exp_in_DI[defs_div_sqrt_mvp_C_EXP_FP32] && FP32_SI) | (Exp_in_DI[defs_div_sqrt_mvp_C_EXP_FP64] && FP64_SI)) | (Exp_in_DI[defs_div_sqrt_mvp_C_EXP_FP16] && FP16_SI)) | (Exp_in_DI[defs_div_sqrt_mvp_C_EXP_FP16ALT] && FP16ALT_SI)) begin
			Div_Zero_S = 1'b0;
			Exp_OF_S = 1'b1;
			Exp_UF_S = 1'b0;
			Mant_res_norm_D = 1'sb0;
			Exp_res_norm_D = 1'sb1;
			Mant_forround_D = 1'sb0;
			Sign_res_D = Sign_in_DI;
			NV_OP_S = 1'b0;
		end
		else if (((((Exp_in_DI[7:0] == {8 {1'sb1}}) && FP32_SI) | ((Exp_in_DI[10:0] == {11 {1'sb1}}) && FP64_SI)) | ((Exp_in_DI[4:0] == {5 {1'sb1}}) && FP16_SI)) | ((Exp_in_DI[7:0] == {8 {1'sb1}}) && FP16ALT_SI)) begin
			if (~Mant_in_DI[56]) begin
				Div_Zero_S = 1'b0;
				Exp_OF_S = 1'b0;
				Exp_UF_S = 1'b0;
				Mant_res_norm_D = Mant_in_DI[55:3];
				Exp_res_norm_D = Exp_subOne_D;
				Mant_forround_D = {Mant_in_DI[2:0], {54 {1'b0}}};
				Sign_res_D = Sign_in_DI;
				NV_OP_S = 1'b0;
			end
			else if (Mant_in_DI != {57 {1'sb0}}) begin
				Div_Zero_S = 1'b0;
				Exp_OF_S = 1'b1;
				Exp_UF_S = 1'b0;
				Mant_res_norm_D = 1'sb0;
				Exp_res_norm_D = 1'sb1;
				Mant_forround_D = 1'sb0;
				Sign_res_D = Sign_in_DI;
				NV_OP_S = 1'b0;
			end
			else begin
				Div_Zero_S = 1'b0;
				Exp_OF_S = 1'b1;
				Exp_UF_S = 1'b0;
				Mant_res_norm_D = 1'sb0;
				Exp_res_norm_D = 1'sb1;
				Mant_forround_D = 1'sb0;
				Sign_res_D = Sign_in_DI;
				NV_OP_S = 1'b0;
			end
		end
		else if (Mant_in_DI[56]) begin
			Div_Zero_S = 1'b0;
			Exp_OF_S = 1'b0;
			Exp_UF_S = 1'b0;
			Mant_res_norm_D = Mant_in_DI[56:4];
			Exp_res_norm_D = Exp_in_DI[10:0];
			Mant_forround_D = {Mant_in_DI[3:0], {53 {1'b0}}};
			Sign_res_D = Sign_in_DI;
			NV_OP_S = 1'b0;
		end
		else begin
			Div_Zero_S = 1'b0;
			Exp_OF_S = 1'b0;
			Exp_UF_S = 1'b0;
			Mant_res_norm_D = Mant_in_DI[55:3];
			Exp_res_norm_D = Exp_subOne_D;
			Mant_forround_D = {Mant_in_DI[2:0], {54 {1'b0}}};
			Sign_res_D = Sign_in_DI;
			NV_OP_S = 1'b0;
		end
	reg [defs_div_sqrt_mvp_C_MANT_FP64:0] Mant_upper_D;
	wire [53:0] Mant_upperRounded_D;
	reg Mant_roundUp_S;
	wire Mant_rounded_S;
	always @(*)
		if (FP32_SI) begin
			Mant_upper_D = {Mant_res_norm_D[defs_div_sqrt_mvp_C_MANT_FP64:29], {29 {1'b0}}};
			Mant_lower_D = Mant_res_norm_D[28:27];
			Mant_sticky_bit_D = |Mant_res_norm_D[26:0];
		end
		else if (FP64_SI) begin
			Mant_upper_D = Mant_res_norm_D[defs_div_sqrt_mvp_C_MANT_FP64:0];
			Mant_lower_D = Mant_forround_D[56:55];
			Mant_sticky_bit_D = |Mant_forround_D[55:0];
		end
		else if (FP16_SI) begin
			Mant_upper_D = {Mant_res_norm_D[defs_div_sqrt_mvp_C_MANT_FP64:42], {42 {1'b0}}};
			Mant_lower_D = Mant_res_norm_D[41:40];
			Mant_sticky_bit_D = |Mant_res_norm_D[39:30];
		end
		else begin
			Mant_upper_D = {Mant_res_norm_D[defs_div_sqrt_mvp_C_MANT_FP64:45], {45 {1'b0}}};
			Mant_lower_D = Mant_res_norm_D[44:43];
			Mant_sticky_bit_D = |Mant_res_norm_D[42:30];
		end
	assign Mant_rounded_S = |Mant_lower_D | Mant_sticky_bit_D;
	localparam defs_div_sqrt_mvp_C_RM_MINUSINF = 3'h3;
	localparam defs_div_sqrt_mvp_C_RM_NEAREST = 3'h0;
	localparam defs_div_sqrt_mvp_C_RM_PLUSINF = 3'h2;
	localparam defs_div_sqrt_mvp_C_RM_TRUNC = 3'h1;
	always @(*) begin
		Mant_roundUp_S = 1'b0;
		case (RM_SI)
			defs_div_sqrt_mvp_C_RM_NEAREST: Mant_roundUp_S = Mant_lower_D[1] && ((Mant_lower_D[0] | Mant_sticky_bit_D) | ((((FP32_SI && Mant_upper_D[29]) | (FP64_SI && Mant_upper_D[0])) | (FP16_SI && Mant_upper_D[42])) | (FP16ALT_SI && Mant_upper_D[45])));
			defs_div_sqrt_mvp_C_RM_TRUNC: Mant_roundUp_S = 0;
			defs_div_sqrt_mvp_C_RM_PLUSINF: Mant_roundUp_S = Mant_rounded_S & ~Sign_in_DI;
			defs_div_sqrt_mvp_C_RM_MINUSINF: Mant_roundUp_S = Mant_rounded_S & Sign_in_DI;
			default: Mant_roundUp_S = 0;
		endcase
	end
	wire Mant_renorm_S;
	wire [defs_div_sqrt_mvp_C_MANT_FP64:0] Mant_roundUp_Vector_S;
	assign Mant_roundUp_Vector_S = {7'h00, FP16ALT_SI && Mant_roundUp_S, 2'h0, FP16_SI && Mant_roundUp_S, 12'h000, FP32_SI && Mant_roundUp_S, 28'h0000000, FP64_SI && Mant_roundUp_S};
	assign Mant_upperRounded_D = Mant_upper_D + Mant_roundUp_Vector_S;
	assign Mant_renorm_S = Mant_upperRounded_D[53];
	wire [51:0] Mant_res_round_D;
	wire [10:0] Exp_res_round_D;
	assign Mant_res_round_D = (Mant_renorm_S ? Mant_upperRounded_D[defs_div_sqrt_mvp_C_MANT_FP64:1] : Mant_upperRounded_D[51:0]);
	assign Exp_res_round_D = Exp_res_norm_D + Mant_renorm_S;
	wire [51:0] Mant_before_format_ctl_D;
	wire [10:0] Exp_before_format_ctl_D;
	assign Mant_before_format_ctl_D = (Full_precision_SI ? Mant_res_round_D : Mant_res_norm_D);
	assign Exp_before_format_ctl_D = (Full_precision_SI ? Exp_res_round_D : Exp_res_norm_D);
	always @(*)
		if (FP32_SI)
			Result_DO = {32'hffffffff, Sign_res_D, Exp_before_format_ctl_D[7:0], Mant_before_format_ctl_D[51:29]};
		else if (FP64_SI)
			Result_DO = {Sign_res_D, Exp_before_format_ctl_D[10:0], Mant_before_format_ctl_D[51:0]};
		else if (FP16_SI)
			Result_DO = {48'hffffffffffff, Sign_res_D, Exp_before_format_ctl_D[4:0], Mant_before_format_ctl_D[51:42]};
		else
			Result_DO = {48'hffffffffffff, Sign_res_D, Exp_before_format_ctl_D[7:0], Mant_before_format_ctl_D[51:45]};
	assign In_Exact_S = ~Full_precision_SI | Mant_rounded_S;
	assign Fflags_SO = {NV_OP_S, Div_Zero_S, Exp_OF_S, Exp_UF_S, In_Exact_S};
endmodule
