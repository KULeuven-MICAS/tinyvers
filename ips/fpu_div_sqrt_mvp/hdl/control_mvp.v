module control_mvp (
	Clk_CI,
	Rst_RBI,
	Div_start_SI,
	Sqrt_start_SI,
	Start_SI,
	Kill_SI,
	Special_case_SBI,
	Special_case_dly_SBI,
	Precision_ctl_SI,
	Format_sel_SI,
	Numerator_DI,
	Exp_num_DI,
	Denominator_DI,
	Exp_den_DI,
	Div_start_dly_SO,
	Sqrt_start_dly_SO,
	Div_enable_SO,
	Sqrt_enable_SO,
	Full_precision_SO,
	FP32_SO,
	FP64_SO,
	FP16_SO,
	FP16ALT_SO,
	Ready_SO,
	Done_SO,
	Mant_result_prenorm_DO,
	Exp_result_prenorm_DO
);
	input wire Clk_CI;
	input wire Rst_RBI;
	input wire Div_start_SI;
	input wire Sqrt_start_SI;
	input wire Start_SI;
	input wire Kill_SI;
	input wire Special_case_SBI;
	input wire Special_case_dly_SBI;
	localparam defs_div_sqrt_mvp_C_PC = 6;
	input wire [5:0] Precision_ctl_SI;
	input wire [1:0] Format_sel_SI;
	localparam defs_div_sqrt_mvp_C_MANT_FP64 = 52;
	input wire [defs_div_sqrt_mvp_C_MANT_FP64:0] Numerator_DI;
	localparam defs_div_sqrt_mvp_C_EXP_FP64 = 11;
	input wire [defs_div_sqrt_mvp_C_EXP_FP64:0] Exp_num_DI;
	input wire [defs_div_sqrt_mvp_C_MANT_FP64:0] Denominator_DI;
	input wire [defs_div_sqrt_mvp_C_EXP_FP64:0] Exp_den_DI;
	output wire Div_start_dly_SO;
	output wire Sqrt_start_dly_SO;
	output reg Div_enable_SO;
	output reg Sqrt_enable_SO;
	output wire Full_precision_SO;
	output wire FP32_SO;
	output wire FP64_SO;
	output wire FP16_SO;
	output wire FP16ALT_SO;
	output reg Ready_SO;
	output reg Done_SO;
	output reg [56:0] Mant_result_prenorm_DO;
	output wire [12:0] Exp_result_prenorm_DO;
	reg [57:0] Partial_remainder_DN;
	reg [57:0] Partial_remainder_DP;
	reg [56:0] Quotient_DP;
	wire [53:0] Numerator_se_D;
	wire [53:0] Denominator_se_D;
	reg [53:0] Denominator_se_DB;
	assign Numerator_se_D = {1'b0, Numerator_DI};
	assign Denominator_se_D = {1'b0, Denominator_DI};
	localparam defs_div_sqrt_mvp_C_MANT_FP16 = 10;
	localparam defs_div_sqrt_mvp_C_MANT_FP16ALT = 7;
	localparam defs_div_sqrt_mvp_C_MANT_FP32 = 23;
	always @(*)
		if (FP32_SO)
			Denominator_se_DB = {~Denominator_se_D[53:29], {29 {1'b0}}};
		else if (FP64_SO)
			Denominator_se_DB = ~Denominator_se_D;
		else if (FP16_SO)
			Denominator_se_DB = {~Denominator_se_D[53:42], {42 {1'b0}}};
		else
			Denominator_se_DB = {~Denominator_se_D[53:45], {45 {1'b0}}};
	wire [53:0] Mant_D_sqrt_Norm;
	assign Mant_D_sqrt_Norm = (Exp_num_DI[0] ? {1'b0, Numerator_DI} : {Numerator_DI, 1'b0});
	reg [1:0] Format_sel_S;
	always @(posedge Clk_CI or negedge Rst_RBI)
		if (~Rst_RBI)
			Format_sel_S <= 'b0;
		else if (Start_SI && Ready_SO)
			Format_sel_S <= Format_sel_SI;
		else
			Format_sel_S <= Format_sel_S;
	assign FP32_SO = Format_sel_S == 2'b00;
	assign FP64_SO = Format_sel_S == 2'b01;
	assign FP16_SO = Format_sel_S == 2'b10;
	assign FP16ALT_SO = Format_sel_S == 2'b11;
	reg [5:0] Precision_ctl_S;
	always @(posedge Clk_CI or negedge Rst_RBI)
		if (~Rst_RBI)
			Precision_ctl_S <= 'b0;
		else if (Start_SI && Ready_SO)
			Precision_ctl_S <= Precision_ctl_SI;
		else
			Precision_ctl_S <= Precision_ctl_S;
	assign Full_precision_SO = Precision_ctl_S == 6'h00;
	reg [5:0] State_ctl_S;
	wire [5:0] State_Two_iteration_unit_S;
	wire [5:0] State_Four_iteration_unit_S;
	assign State_Two_iteration_unit_S = Precision_ctl_S[5:1];
	assign State_Four_iteration_unit_S = Precision_ctl_S[5:2];
	localparam defs_div_sqrt_mvp_Iteration_unit_num_S = 2'b10;
	always @(*)
		case (defs_div_sqrt_mvp_Iteration_unit_num_S)
			2'b00:
				case (Format_sel_S)
					2'b00:
						if (Full_precision_SO)
							State_ctl_S = 6'h1b;
						else
							State_ctl_S = Precision_ctl_S;
					2'b01:
						if (Full_precision_SO)
							State_ctl_S = 6'h38;
						else
							State_ctl_S = Precision_ctl_S;
					2'b10:
						if (Full_precision_SO)
							State_ctl_S = 6'h0e;
						else
							State_ctl_S = Precision_ctl_S;
					2'b11:
						if (Full_precision_SO)
							State_ctl_S = 6'h0b;
						else
							State_ctl_S = Precision_ctl_S;
				endcase
			2'b01:
				case (Format_sel_S)
					2'b00:
						if (Full_precision_SO)
							State_ctl_S = 6'h0d;
						else
							State_ctl_S = State_Two_iteration_unit_S;
					2'b01:
						if (Full_precision_SO)
							State_ctl_S = 6'h1b;
						else
							State_ctl_S = State_Two_iteration_unit_S;
					2'b10:
						if (Full_precision_SO)
							State_ctl_S = 6'h06;
						else
							State_ctl_S = State_Two_iteration_unit_S;
					2'b11:
						if (Full_precision_SO)
							State_ctl_S = 6'h05;
						else
							State_ctl_S = State_Two_iteration_unit_S;
				endcase
			2'b10:
				case (Format_sel_S)
					2'b00:
						case (Precision_ctl_S)
							6'h00: State_ctl_S = 6'h08;
							6'h06, 6'h07, 6'h08: State_ctl_S = 6'h02;
							6'h09, 6'h0a, 6'h0b: State_ctl_S = 6'h03;
							6'h0c, 6'h0d, 6'h0e: State_ctl_S = 6'h04;
							6'h0f, 6'h10, 6'h11: State_ctl_S = 6'h05;
							6'h12, 6'h13, 6'h14: State_ctl_S = 6'h06;
							6'h15, 6'h16, 6'h17: State_ctl_S = 6'h07;
							default: State_ctl_S = 6'h08;
						endcase
					2'b01:
						case (Precision_ctl_S)
							6'h00: State_ctl_S = 6'h12;
							6'h06, 6'h07, 6'h08: State_ctl_S = 6'h02;
							6'h09, 6'h0a, 6'h0b: State_ctl_S = 6'h03;
							6'h0c, 6'h0d, 6'h0e: State_ctl_S = 6'h04;
							6'h0f, 6'h10, 6'h11: State_ctl_S = 6'h05;
							6'h12, 6'h13, 6'h14: State_ctl_S = 6'h06;
							6'h15, 6'h16, 6'h17: State_ctl_S = 6'h07;
							6'h18, 6'h19, 6'h1a: State_ctl_S = 6'h08;
							6'h1b, 6'h1c, 6'h1d: State_ctl_S = 6'h09;
							6'h1e, 6'h1f, 6'h20: State_ctl_S = 6'h0a;
							6'h21, 6'h22, 6'h23: State_ctl_S = 6'h0b;
							6'h24, 6'h25, 6'h26: State_ctl_S = 6'h0c;
							6'h27, 6'h28, 6'h29: State_ctl_S = 6'h0d;
							6'h2a, 6'h2b, 6'h2c: State_ctl_S = 6'h0e;
							6'h2d, 6'h2e, 6'h2f: State_ctl_S = 6'h0f;
							6'h30, 6'h31, 6'h32: State_ctl_S = 6'h10;
							6'h33, 6'h34, 6'h35: State_ctl_S = 6'h11;
							default: State_ctl_S = 6'h12;
						endcase
					2'b10:
						case (Precision_ctl_S)
							6'h00: State_ctl_S = 6'h04;
							6'h06, 6'h07, 6'h08: State_ctl_S = 6'h02;
							6'h09, 6'h0a, 6'h0b: State_ctl_S = 6'h03;
							default: State_ctl_S = 6'h04;
						endcase
					2'b11:
						case (Precision_ctl_S)
							6'h00: State_ctl_S = 6'h03;
							6'h06, 6'h07, 6'h08: State_ctl_S = 6'h02;
							default: State_ctl_S = 6'h03;
						endcase
				endcase
			2'b11:
				case (Format_sel_S)
					2'b00:
						if (Full_precision_SO)
							State_ctl_S = 6'h06;
						else
							State_ctl_S = State_Four_iteration_unit_S;
					2'b01:
						if (Full_precision_SO)
							State_ctl_S = 6'h0d;
						else
							State_ctl_S = State_Four_iteration_unit_S;
					2'b10:
						if (Full_precision_SO)
							State_ctl_S = 6'h03;
						else
							State_ctl_S = State_Four_iteration_unit_S;
					2'b11:
						if (Full_precision_SO)
							State_ctl_S = 6'h02;
						else
							State_ctl_S = State_Four_iteration_unit_S;
				endcase
		endcase
	reg Div_start_dly_S;
	always @(posedge Clk_CI or negedge Rst_RBI)
		if (~Rst_RBI)
			Div_start_dly_S <= 1'b0;
		else if (Div_start_SI && Ready_SO)
			Div_start_dly_S <= 1'b1;
		else
			Div_start_dly_S <= 1'b0;
	assign Div_start_dly_SO = Div_start_dly_S;
	always @(posedge Clk_CI or negedge Rst_RBI)
		if (~Rst_RBI)
			Div_enable_SO <= 1'b0;
		else if (Kill_SI)
			Div_enable_SO <= 1'b0;
		else if (Div_start_SI && Ready_SO)
			Div_enable_SO <= 1'b1;
		else if (Done_SO)
			Div_enable_SO <= 1'b0;
		else
			Div_enable_SO <= Div_enable_SO;
	reg Sqrt_start_dly_S;
	always @(posedge Clk_CI or negedge Rst_RBI)
		if (~Rst_RBI)
			Sqrt_start_dly_S <= 1'b0;
		else if (Sqrt_start_SI && Ready_SO)
			Sqrt_start_dly_S <= 1'b1;
		else
			Sqrt_start_dly_S <= 1'b0;
	assign Sqrt_start_dly_SO = Sqrt_start_dly_S;
	always @(posedge Clk_CI or negedge Rst_RBI)
		if (~Rst_RBI)
			Sqrt_enable_SO <= 1'b0;
		else if (Kill_SI)
			Sqrt_enable_SO <= 1'b0;
		else if (Sqrt_start_SI && Ready_SO)
			Sqrt_enable_SO <= 1'b1;
		else if (Done_SO)
			Sqrt_enable_SO <= 1'b0;
		else
			Sqrt_enable_SO <= Sqrt_enable_SO;
	reg [5:0] Crtl_cnt_S;
	wire Start_dly_S;
	assign Start_dly_S = Div_start_dly_S | Sqrt_start_dly_S;
	wire Fsm_enable_S;
	assign Fsm_enable_S = ((Start_dly_S | |Crtl_cnt_S) && ~Kill_SI) && Special_case_dly_SBI;
	wire Final_state_S;
	assign Final_state_S = Crtl_cnt_S == State_ctl_S;
	always @(posedge Clk_CI or negedge Rst_RBI)
		if (~Rst_RBI)
			Crtl_cnt_S <= 1'sb0;
		else if (Final_state_S | Kill_SI)
			Crtl_cnt_S <= 1'sb0;
		else if (Fsm_enable_S)
			Crtl_cnt_S <= Crtl_cnt_S + 1;
		else
			Crtl_cnt_S <= 1'sb0;
	always @(posedge Clk_CI or negedge Rst_RBI)
		if (~Rst_RBI)
			Done_SO <= 1'b0;
		else if (Start_SI && Ready_SO) begin
			if (~Special_case_SBI)
				Done_SO <= 1'b1;
			else
				Done_SO <= 1'b0;
		end
		else if (Final_state_S)
			Done_SO <= 1'b1;
		else
			Done_SO <= 1'b0;
	always @(posedge Clk_CI or negedge Rst_RBI)
		if (~Rst_RBI)
			Ready_SO <= 1'b1;
		else if (Start_SI && Ready_SO) begin
			if (~Special_case_SBI)
				Ready_SO <= 1'b1;
			else
				Ready_SO <= 1'b0;
		end
		else if (Final_state_S | Kill_SI)
			Ready_SO <= 1'b1;
		else
			Ready_SO <= Ready_SO;
	wire Qcnt_one_0;
	wire Qcnt_one_1;
	wire [1:0] Qcnt_one_2;
	wire [2:0] Qcnt_one_3;
	wire [3:0] Qcnt_one_4;
	wire [4:0] Qcnt_one_5;
	wire [5:0] Qcnt_one_6;
	wire [6:0] Qcnt_one_7;
	wire [7:0] Qcnt_one_8;
	wire [8:0] Qcnt_one_9;
	wire [9:0] Qcnt_one_10;
	wire [10:0] Qcnt_one_11;
	wire [11:0] Qcnt_one_12;
	wire [12:0] Qcnt_one_13;
	wire [13:0] Qcnt_one_14;
	wire [14:0] Qcnt_one_15;
	wire [15:0] Qcnt_one_16;
	wire [16:0] Qcnt_one_17;
	wire [17:0] Qcnt_one_18;
	wire [18:0] Qcnt_one_19;
	wire [19:0] Qcnt_one_20;
	wire [20:0] Qcnt_one_21;
	wire [21:0] Qcnt_one_22;
	wire [22:0] Qcnt_one_23;
	wire [23:0] Qcnt_one_24;
	wire [24:0] Qcnt_one_25;
	wire [25:0] Qcnt_one_26;
	wire [26:0] Qcnt_one_27;
	wire [27:0] Qcnt_one_28;
	wire [28:0] Qcnt_one_29;
	wire [29:0] Qcnt_one_30;
	wire [30:0] Qcnt_one_31;
	wire [31:0] Qcnt_one_32;
	wire [32:0] Qcnt_one_33;
	wire [33:0] Qcnt_one_34;
	wire [34:0] Qcnt_one_35;
	wire [35:0] Qcnt_one_36;
	wire [36:0] Qcnt_one_37;
	wire [37:0] Qcnt_one_38;
	wire [38:0] Qcnt_one_39;
	wire [39:0] Qcnt_one_40;
	wire [40:0] Qcnt_one_41;
	wire [41:0] Qcnt_one_42;
	wire [42:0] Qcnt_one_43;
	wire [43:0] Qcnt_one_44;
	wire [44:0] Qcnt_one_45;
	wire [45:0] Qcnt_one_46;
	wire [46:0] Qcnt_one_47;
	wire [47:0] Qcnt_one_48;
	wire [48:0] Qcnt_one_49;
	wire [49:0] Qcnt_one_50;
	wire [50:0] Qcnt_one_51;
	wire [51:0] Qcnt_one_52;
	wire [52:0] Qcnt_one_53;
	wire [53:0] Qcnt_one_54;
	wire [54:0] Qcnt_one_55;
	wire [55:0] Qcnt_one_56;
	wire [56:0] Qcnt_one_57;
	wire [57:0] Qcnt_one_58;
	wire [58:0] Qcnt_one_59;
	wire [59:0] Qcnt_one_60;
	wire [1:0] Qcnt_two_0;
	wire [2:0] Qcnt_two_1;
	wire [4:0] Qcnt_two_2;
	wire [6:0] Qcnt_two_3;
	wire [8:0] Qcnt_two_4;
	wire [10:0] Qcnt_two_5;
	wire [12:0] Qcnt_two_6;
	wire [14:0] Qcnt_two_7;
	wire [16:0] Qcnt_two_8;
	wire [18:0] Qcnt_two_9;
	wire [20:0] Qcnt_two_10;
	wire [22:0] Qcnt_two_11;
	wire [24:0] Qcnt_two_12;
	wire [26:0] Qcnt_two_13;
	wire [28:0] Qcnt_two_14;
	wire [30:0] Qcnt_two_15;
	wire [32:0] Qcnt_two_16;
	wire [34:0] Qcnt_two_17;
	wire [36:0] Qcnt_two_18;
	wire [38:0] Qcnt_two_19;
	wire [40:0] Qcnt_two_20;
	wire [42:0] Qcnt_two_21;
	wire [44:0] Qcnt_two_22;
	wire [46:0] Qcnt_two_23;
	wire [48:0] Qcnt_two_24;
	wire [50:0] Qcnt_two_25;
	wire [52:0] Qcnt_two_26;
	wire [54:0] Qcnt_two_27;
	wire [56:0] Qcnt_two_28;
	wire [2:0] Qcnt_three_0;
	wire [4:0] Qcnt_three_1;
	wire [7:0] Qcnt_three_2;
	wire [10:0] Qcnt_three_3;
	wire [13:0] Qcnt_three_4;
	wire [16:0] Qcnt_three_5;
	wire [19:0] Qcnt_three_6;
	wire [22:0] Qcnt_three_7;
	wire [25:0] Qcnt_three_8;
	wire [28:0] Qcnt_three_9;
	wire [31:0] Qcnt_three_10;
	wire [34:0] Qcnt_three_11;
	wire [37:0] Qcnt_three_12;
	wire [40:0] Qcnt_three_13;
	wire [43:0] Qcnt_three_14;
	wire [46:0] Qcnt_three_15;
	wire [49:0] Qcnt_three_16;
	wire [52:0] Qcnt_three_17;
	wire [55:0] Qcnt_three_18;
	wire [58:0] Qcnt_three_19;
	wire [61:0] Qcnt_three_20;
	wire [3:0] Qcnt_four_0;
	wire [6:0] Qcnt_four_1;
	wire [10:0] Qcnt_four_2;
	wire [14:0] Qcnt_four_3;
	wire [18:0] Qcnt_four_4;
	wire [22:0] Qcnt_four_5;
	wire [26:0] Qcnt_four_6;
	wire [30:0] Qcnt_four_7;
	wire [34:0] Qcnt_four_8;
	wire [38:0] Qcnt_four_9;
	wire [42:0] Qcnt_four_10;
	wire [46:0] Qcnt_four_11;
	wire [50:0] Qcnt_four_12;
	wire [54:0] Qcnt_four_13;
	wire [58:0] Qcnt_four_14;
	wire [57:0] Sqrt_R0;
	reg [57:0] Sqrt_Q0;
	reg [57:0] Q_sqrt0;
	reg [57:0] Q_sqrt_com_0;
	wire [57:0] Sqrt_R1;
	reg [57:0] Sqrt_Q1;
	reg [57:0] Q_sqrt1;
	reg [57:0] Q_sqrt_com_1;
	wire [57:0] Sqrt_R2;
	reg [57:0] Sqrt_Q2;
	reg [57:0] Q_sqrt2;
	reg [57:0] Q_sqrt_com_2;
	wire [57:0] Sqrt_R3;
	reg [57:0] Sqrt_Q3;
	reg [57:0] Q_sqrt3;
	reg [57:0] Q_sqrt_com_3;
	wire [57:0] Sqrt_R4;
	reg [1:0] Sqrt_DI [3:0];
	wire [1:0] Sqrt_DO [3:0];
	wire Sqrt_carry_DO;
	wire [57:0] Iteration_cell_a_D [3:0];
	wire [57:0] Iteration_cell_b_D [3:0];
	wire [57:0] Iteration_cell_a_BMASK_D [3:0];
	wire [57:0] Iteration_cell_b_BMASK_D [3:0];
	wire Iteration_cell_carry_D [3:0];
	wire [57:0] Iteration_cell_sum_D [3:0];
	wire [57:0] Iteration_cell_sum_AMASK_D [3:0];
	reg [3:0] Sqrt_quotinent_S;
	always @(*)
		case (Format_sel_S)
			2'b00: begin
				Sqrt_quotinent_S = {~Iteration_cell_sum_AMASK_D[0][28], ~Iteration_cell_sum_AMASK_D[1][28], ~Iteration_cell_sum_AMASK_D[2][28], ~Iteration_cell_sum_AMASK_D[3][28]};
				Q_sqrt_com_0 = {{29 {1'b0}}, ~Q_sqrt0[28:0]};
				Q_sqrt_com_1 = {{29 {1'b0}}, ~Q_sqrt1[28:0]};
				Q_sqrt_com_2 = {{29 {1'b0}}, ~Q_sqrt2[28:0]};
				Q_sqrt_com_3 = {{29 {1'b0}}, ~Q_sqrt3[28:0]};
			end
			2'b01: begin
				Sqrt_quotinent_S = {Iteration_cell_carry_D[0], Iteration_cell_carry_D[1], Iteration_cell_carry_D[2], Iteration_cell_carry_D[3]};
				Q_sqrt_com_0 = ~Q_sqrt0;
				Q_sqrt_com_1 = ~Q_sqrt1;
				Q_sqrt_com_2 = ~Q_sqrt2;
				Q_sqrt_com_3 = ~Q_sqrt3;
			end
			2'b10: begin
				Sqrt_quotinent_S = {~Iteration_cell_sum_AMASK_D[0][15], ~Iteration_cell_sum_AMASK_D[1][15], ~Iteration_cell_sum_AMASK_D[2][15], ~Iteration_cell_sum_AMASK_D[3][15]};
				Q_sqrt_com_0 = {{42 {1'b0}}, ~Q_sqrt0[15:0]};
				Q_sqrt_com_1 = {{42 {1'b0}}, ~Q_sqrt1[15:0]};
				Q_sqrt_com_2 = {{42 {1'b0}}, ~Q_sqrt2[15:0]};
				Q_sqrt_com_3 = {{42 {1'b0}}, ~Q_sqrt3[15:0]};
			end
			2'b11: begin
				Sqrt_quotinent_S = {~Iteration_cell_sum_AMASK_D[0][12], ~Iteration_cell_sum_AMASK_D[1][12], ~Iteration_cell_sum_AMASK_D[2][12], ~Iteration_cell_sum_AMASK_D[3][12]};
				Q_sqrt_com_0 = {{45 {1'b0}}, ~Q_sqrt0[12:0]};
				Q_sqrt_com_1 = {{45 {1'b0}}, ~Q_sqrt1[12:0]};
				Q_sqrt_com_2 = {{45 {1'b0}}, ~Q_sqrt2[12:0]};
				Q_sqrt_com_3 = {{45 {1'b0}}, ~Q_sqrt3[12:0]};
			end
		endcase
	assign Qcnt_one_0 = 1'b0;
	assign Qcnt_one_1 = {Quotient_DP[0]};
	assign Qcnt_one_2 = {Quotient_DP[1:0]};
	assign Qcnt_one_3 = {Quotient_DP[2:0]};
	assign Qcnt_one_4 = {Quotient_DP[3:0]};
	assign Qcnt_one_5 = {Quotient_DP[4:0]};
	assign Qcnt_one_6 = {Quotient_DP[5:0]};
	assign Qcnt_one_7 = {Quotient_DP[6:0]};
	assign Qcnt_one_8 = {Quotient_DP[7:0]};
	assign Qcnt_one_9 = {Quotient_DP[8:0]};
	assign Qcnt_one_10 = {Quotient_DP[9:0]};
	assign Qcnt_one_11 = {Quotient_DP[10:0]};
	assign Qcnt_one_12 = {Quotient_DP[11:0]};
	assign Qcnt_one_13 = {Quotient_DP[12:0]};
	assign Qcnt_one_14 = {Quotient_DP[13:0]};
	assign Qcnt_one_15 = {Quotient_DP[14:0]};
	assign Qcnt_one_16 = {Quotient_DP[15:0]};
	assign Qcnt_one_17 = {Quotient_DP[16:0]};
	assign Qcnt_one_18 = {Quotient_DP[17:0]};
	assign Qcnt_one_19 = {Quotient_DP[18:0]};
	assign Qcnt_one_20 = {Quotient_DP[19:0]};
	assign Qcnt_one_21 = {Quotient_DP[20:0]};
	assign Qcnt_one_22 = {Quotient_DP[21:0]};
	assign Qcnt_one_23 = {Quotient_DP[22:0]};
	assign Qcnt_one_24 = {Quotient_DP[23:0]};
	assign Qcnt_one_25 = {Quotient_DP[24:0]};
	assign Qcnt_one_26 = {Quotient_DP[25:0]};
	assign Qcnt_one_27 = {Quotient_DP[26:0]};
	assign Qcnt_one_28 = {Quotient_DP[27:0]};
	assign Qcnt_one_29 = {Quotient_DP[28:0]};
	assign Qcnt_one_30 = {Quotient_DP[29:0]};
	assign Qcnt_one_31 = {Quotient_DP[30:0]};
	assign Qcnt_one_32 = {Quotient_DP[31:0]};
	assign Qcnt_one_33 = {Quotient_DP[32:0]};
	assign Qcnt_one_34 = {Quotient_DP[33:0]};
	assign Qcnt_one_35 = {Quotient_DP[34:0]};
	assign Qcnt_one_36 = {Quotient_DP[35:0]};
	assign Qcnt_one_37 = {Quotient_DP[36:0]};
	assign Qcnt_one_38 = {Quotient_DP[37:0]};
	assign Qcnt_one_39 = {Quotient_DP[38:0]};
	assign Qcnt_one_40 = {Quotient_DP[39:0]};
	assign Qcnt_one_41 = {Quotient_DP[40:0]};
	assign Qcnt_one_42 = {Quotient_DP[41:0]};
	assign Qcnt_one_43 = {Quotient_DP[42:0]};
	assign Qcnt_one_44 = {Quotient_DP[43:0]};
	assign Qcnt_one_45 = {Quotient_DP[44:0]};
	assign Qcnt_one_46 = {Quotient_DP[45:0]};
	assign Qcnt_one_47 = {Quotient_DP[46:0]};
	assign Qcnt_one_48 = {Quotient_DP[47:0]};
	assign Qcnt_one_49 = {Quotient_DP[48:0]};
	assign Qcnt_one_50 = {Quotient_DP[49:0]};
	assign Qcnt_one_51 = {Quotient_DP[50:0]};
	assign Qcnt_one_52 = {Quotient_DP[51:0]};
	assign Qcnt_one_53 = {Quotient_DP[52:0]};
	assign Qcnt_one_54 = {Quotient_DP[53:0]};
	assign Qcnt_one_55 = {Quotient_DP[54:0]};
	assign Qcnt_one_56 = {Quotient_DP[55:0]};
	assign Qcnt_one_57 = {Quotient_DP[56:0]};
	assign Qcnt_two_0 = {1'b0, Sqrt_quotinent_S[3]};
	assign Qcnt_two_1 = {Quotient_DP[1:0], Sqrt_quotinent_S[3]};
	assign Qcnt_two_2 = {Quotient_DP[3:0], Sqrt_quotinent_S[3]};
	assign Qcnt_two_3 = {Quotient_DP[5:0], Sqrt_quotinent_S[3]};
	assign Qcnt_two_4 = {Quotient_DP[7:0], Sqrt_quotinent_S[3]};
	assign Qcnt_two_5 = {Quotient_DP[9:0], Sqrt_quotinent_S[3]};
	assign Qcnt_two_6 = {Quotient_DP[11:0], Sqrt_quotinent_S[3]};
	assign Qcnt_two_7 = {Quotient_DP[13:0], Sqrt_quotinent_S[3]};
	assign Qcnt_two_8 = {Quotient_DP[15:0], Sqrt_quotinent_S[3]};
	assign Qcnt_two_9 = {Quotient_DP[17:0], Sqrt_quotinent_S[3]};
	assign Qcnt_two_10 = {Quotient_DP[19:0], Sqrt_quotinent_S[3]};
	assign Qcnt_two_11 = {Quotient_DP[21:0], Sqrt_quotinent_S[3]};
	assign Qcnt_two_12 = {Quotient_DP[23:0], Sqrt_quotinent_S[3]};
	assign Qcnt_two_13 = {Quotient_DP[25:0], Sqrt_quotinent_S[3]};
	assign Qcnt_two_14 = {Quotient_DP[27:0], Sqrt_quotinent_S[3]};
	assign Qcnt_two_15 = {Quotient_DP[29:0], Sqrt_quotinent_S[3]};
	assign Qcnt_two_16 = {Quotient_DP[31:0], Sqrt_quotinent_S[3]};
	assign Qcnt_two_17 = {Quotient_DP[33:0], Sqrt_quotinent_S[3]};
	assign Qcnt_two_18 = {Quotient_DP[35:0], Sqrt_quotinent_S[3]};
	assign Qcnt_two_19 = {Quotient_DP[37:0], Sqrt_quotinent_S[3]};
	assign Qcnt_two_20 = {Quotient_DP[39:0], Sqrt_quotinent_S[3]};
	assign Qcnt_two_21 = {Quotient_DP[41:0], Sqrt_quotinent_S[3]};
	assign Qcnt_two_22 = {Quotient_DP[43:0], Sqrt_quotinent_S[3]};
	assign Qcnt_two_23 = {Quotient_DP[45:0], Sqrt_quotinent_S[3]};
	assign Qcnt_two_24 = {Quotient_DP[47:0], Sqrt_quotinent_S[3]};
	assign Qcnt_two_25 = {Quotient_DP[49:0], Sqrt_quotinent_S[3]};
	assign Qcnt_two_26 = {Quotient_DP[51:0], Sqrt_quotinent_S[3]};
	assign Qcnt_two_27 = {Quotient_DP[53:0], Sqrt_quotinent_S[3]};
	assign Qcnt_two_28 = {Quotient_DP[55:0], Sqrt_quotinent_S[3]};
	assign Qcnt_three_0 = {1'b0, Sqrt_quotinent_S[3], Sqrt_quotinent_S[2]};
	assign Qcnt_three_1 = {Quotient_DP[2:0], Sqrt_quotinent_S[3], Sqrt_quotinent_S[2]};
	assign Qcnt_three_2 = {Quotient_DP[5:0], Sqrt_quotinent_S[3], Sqrt_quotinent_S[2]};
	assign Qcnt_three_3 = {Quotient_DP[8:0], Sqrt_quotinent_S[3], Sqrt_quotinent_S[2]};
	assign Qcnt_three_4 = {Quotient_DP[11:0], Sqrt_quotinent_S[3], Sqrt_quotinent_S[2]};
	assign Qcnt_three_5 = {Quotient_DP[14:0], Sqrt_quotinent_S[3], Sqrt_quotinent_S[2]};
	assign Qcnt_three_6 = {Quotient_DP[17:0], Sqrt_quotinent_S[3], Sqrt_quotinent_S[2]};
	assign Qcnt_three_7 = {Quotient_DP[20:0], Sqrt_quotinent_S[3], Sqrt_quotinent_S[2]};
	assign Qcnt_three_8 = {Quotient_DP[23:0], Sqrt_quotinent_S[3], Sqrt_quotinent_S[2]};
	assign Qcnt_three_9 = {Quotient_DP[26:0], Sqrt_quotinent_S[3], Sqrt_quotinent_S[2]};
	assign Qcnt_three_10 = {Quotient_DP[29:0], Sqrt_quotinent_S[3], Sqrt_quotinent_S[2]};
	assign Qcnt_three_11 = {Quotient_DP[32:0], Sqrt_quotinent_S[3], Sqrt_quotinent_S[2]};
	assign Qcnt_three_12 = {Quotient_DP[35:0], Sqrt_quotinent_S[3], Sqrt_quotinent_S[2]};
	assign Qcnt_three_13 = {Quotient_DP[38:0], Sqrt_quotinent_S[3], Sqrt_quotinent_S[2]};
	assign Qcnt_three_14 = {Quotient_DP[41:0], Sqrt_quotinent_S[3], Sqrt_quotinent_S[2]};
	assign Qcnt_three_15 = {Quotient_DP[44:0], Sqrt_quotinent_S[3], Sqrt_quotinent_S[2]};
	assign Qcnt_three_16 = {Quotient_DP[47:0], Sqrt_quotinent_S[3], Sqrt_quotinent_S[2]};
	assign Qcnt_three_17 = {Quotient_DP[50:0], Sqrt_quotinent_S[3], Sqrt_quotinent_S[2]};
	assign Qcnt_three_18 = {Quotient_DP[53:0], Sqrt_quotinent_S[3], Sqrt_quotinent_S[2]};
	assign Qcnt_three_19 = {Quotient_DP[56:0], Sqrt_quotinent_S[3], Sqrt_quotinent_S[2]};
	assign Qcnt_four_0 = {1'b0, Sqrt_quotinent_S[3], Sqrt_quotinent_S[2], Sqrt_quotinent_S[1]};
	assign Qcnt_four_1 = {Quotient_DP[3:0], Sqrt_quotinent_S[3], Sqrt_quotinent_S[2], Sqrt_quotinent_S[1]};
	assign Qcnt_four_2 = {Quotient_DP[7:0], Sqrt_quotinent_S[3], Sqrt_quotinent_S[2], Sqrt_quotinent_S[1]};
	assign Qcnt_four_3 = {Quotient_DP[11:0], Sqrt_quotinent_S[3], Sqrt_quotinent_S[2], Sqrt_quotinent_S[1]};
	assign Qcnt_four_4 = {Quotient_DP[15:0], Sqrt_quotinent_S[3], Sqrt_quotinent_S[2], Sqrt_quotinent_S[1]};
	assign Qcnt_four_5 = {Quotient_DP[19:0], Sqrt_quotinent_S[3], Sqrt_quotinent_S[2], Sqrt_quotinent_S[1]};
	assign Qcnt_four_6 = {Quotient_DP[23:0], Sqrt_quotinent_S[3], Sqrt_quotinent_S[2], Sqrt_quotinent_S[1]};
	assign Qcnt_four_7 = {Quotient_DP[27:0], Sqrt_quotinent_S[3], Sqrt_quotinent_S[2], Sqrt_quotinent_S[1]};
	assign Qcnt_four_8 = {Quotient_DP[31:0], Sqrt_quotinent_S[3], Sqrt_quotinent_S[2], Sqrt_quotinent_S[1]};
	assign Qcnt_four_9 = {Quotient_DP[35:0], Sqrt_quotinent_S[3], Sqrt_quotinent_S[2], Sqrt_quotinent_S[1]};
	assign Qcnt_four_10 = {Quotient_DP[39:0], Sqrt_quotinent_S[3], Sqrt_quotinent_S[2], Sqrt_quotinent_S[1]};
	assign Qcnt_four_11 = {Quotient_DP[43:0], Sqrt_quotinent_S[3], Sqrt_quotinent_S[2], Sqrt_quotinent_S[1]};
	assign Qcnt_four_12 = {Quotient_DP[47:0], Sqrt_quotinent_S[3], Sqrt_quotinent_S[2], Sqrt_quotinent_S[1]};
	assign Qcnt_four_13 = {Quotient_DP[51:0], Sqrt_quotinent_S[3], Sqrt_quotinent_S[2], Sqrt_quotinent_S[1]};
	assign Qcnt_four_14 = {Quotient_DP[55:0], Sqrt_quotinent_S[3], Sqrt_quotinent_S[2], Sqrt_quotinent_S[1]};
	always @(*)
		case (defs_div_sqrt_mvp_Iteration_unit_num_S)
			2'b00:
				case (Crtl_cnt_S)
					6'b000000: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[53:defs_div_sqrt_mvp_C_MANT_FP64];
						Q_sqrt0 = {{57 {1'b0}}, Qcnt_one_0};
						Sqrt_Q0 = Q_sqrt_com_0;
					end
					6'b000001: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[51:50];
						Q_sqrt0 = {{57 {1'b0}}, Qcnt_one_1};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b000010: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[49:48];
						Q_sqrt0 = {{56 {1'b0}}, Qcnt_one_2};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b000011: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[47:46];
						Q_sqrt0 = {{55 {1'b0}}, Qcnt_one_3};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b000100: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[45:44];
						Q_sqrt0 = {{54 {1'b0}}, Qcnt_one_4};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b000101: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[43:42];
						Q_sqrt0 = {{53 {1'b0}}, Qcnt_one_5};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b000110: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[41:40];
						Q_sqrt0 = {{defs_div_sqrt_mvp_C_MANT_FP64 {1'b0}}, Qcnt_one_6};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b000111: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[39:38];
						Q_sqrt0 = {{51 {1'b0}}, Qcnt_one_7};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b001000: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[37:36];
						Q_sqrt0 = {{50 {1'b0}}, Qcnt_one_8};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b001001: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[35:34];
						Q_sqrt0 = {{49 {1'b0}}, Qcnt_one_9};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b001010: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[33:32];
						Q_sqrt0 = {{48 {1'b0}}, Qcnt_one_10};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b001011: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[31:30];
						Q_sqrt0 = {{47 {1'b0}}, Qcnt_one_11};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b001100: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[29:28];
						Q_sqrt0 = {{46 {1'b0}}, Qcnt_one_12};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b001101: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[27:26];
						Q_sqrt0 = {{45 {1'b0}}, Qcnt_one_13};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b001110: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[25:24];
						Q_sqrt0 = {{44 {1'b0}}, Qcnt_one_14};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b001111: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[23:22];
						Q_sqrt0 = {{43 {1'b0}}, Qcnt_one_15};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b010000: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[21:20];
						Q_sqrt0 = {{42 {1'b0}}, Qcnt_one_16};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b010001: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[19:18];
						Q_sqrt0 = {{41 {1'b0}}, Qcnt_one_17};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b010010: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[17:16];
						Q_sqrt0 = {{40 {1'b0}}, Qcnt_one_18};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b010011: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[15:14];
						Q_sqrt0 = {{39 {1'b0}}, Qcnt_one_19};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b010100: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[13:12];
						Q_sqrt0 = {{38 {1'b0}}, Qcnt_one_20};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b010101: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[11:10];
						Q_sqrt0 = {{37 {1'b0}}, Qcnt_one_21};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b010110: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[9:8];
						Q_sqrt0 = {{36 {1'b0}}, Qcnt_one_22};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b010111: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[7:6];
						Q_sqrt0 = {{35 {1'b0}}, Qcnt_one_23};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b011000: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[5:4];
						Q_sqrt0 = {{34 {1'b0}}, Qcnt_one_24};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b011001: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[3:2];
						Q_sqrt0 = {{33 {1'b0}}, Qcnt_one_25};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b011010: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[1:0];
						Q_sqrt0 = {{32 {1'b0}}, Qcnt_one_26};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b011011: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{31 {1'b0}}, Qcnt_one_27};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b011100: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{30 {1'b0}}, Qcnt_one_28};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b011101: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{29 {1'b0}}, Qcnt_one_29};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b011110: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{28 {1'b0}}, Qcnt_one_30};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b011111: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{27 {1'b0}}, Qcnt_one_31};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b100000: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{26 {1'b0}}, Qcnt_one_32};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b100001: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{25 {1'b0}}, Qcnt_one_33};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b100010: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{24 {1'b0}}, Qcnt_one_34};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b100011: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{23 {1'b0}}, Qcnt_one_35};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b100100: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{22 {1'b0}}, Qcnt_one_36};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b100101: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{21 {1'b0}}, Qcnt_one_37};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b100110: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{20 {1'b0}}, Qcnt_one_38};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b100111: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{19 {1'b0}}, Qcnt_one_39};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b101000: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{18 {1'b0}}, Qcnt_one_40};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b101001: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{17 {1'b0}}, Qcnt_one_41};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b101010: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{16 {1'b0}}, Qcnt_one_42};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b101011: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{15 {1'b0}}, Qcnt_one_43};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b101100: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{14 {1'b0}}, Qcnt_one_44};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b101101: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{13 {1'b0}}, Qcnt_one_45};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b101110: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{12 {1'b0}}, Qcnt_one_46};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b101111: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{11 {1'b0}}, Qcnt_one_47};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b110000: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{10 {1'b0}}, Qcnt_one_48};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b110001: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{9 {1'b0}}, Qcnt_one_49};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b110010: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{8 {1'b0}}, Qcnt_one_50};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b110011: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{7 {1'b0}}, Qcnt_one_51};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b110100: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{6 {1'b0}}, Qcnt_one_52};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b110101: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{5 {1'b0}}, Qcnt_one_53};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b110110: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{4 {1'b0}}, Qcnt_one_54};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b110111: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{3 {1'b0}}, Qcnt_one_55};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b111000: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{2 {1'b0}}, Qcnt_one_56};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					default: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = 1'sb0;
						Sqrt_Q0 = 1'sb0;
					end
				endcase
			2'b01:
				case (Crtl_cnt_S)
					6'b000000: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[53:defs_div_sqrt_mvp_C_MANT_FP64];
						Q_sqrt0 = {{57 {1'b0}}, Qcnt_two_0[1]};
						Sqrt_Q0 = Q_sqrt_com_0;
						Sqrt_DI[1] = Mant_D_sqrt_Norm[51:50];
						Q_sqrt1 = {{56 {1'b0}}, Qcnt_two_0[1:0]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
					end
					6'b000001: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[49:48];
						Q_sqrt0 = {{56 {1'b0}}, Qcnt_two_1[2:1]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = Mant_D_sqrt_Norm[47:46];
						Q_sqrt1 = {{55 {1'b0}}, Qcnt_two_1[2:0]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
					end
					6'b000010: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[45:44];
						Q_sqrt0 = {{54 {1'b0}}, Qcnt_two_2[4:1]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = Mant_D_sqrt_Norm[43:42];
						Q_sqrt1 = {{53 {1'b0}}, Qcnt_two_2[4:0]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
					end
					6'b000011: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[41:40];
						Q_sqrt0 = {{defs_div_sqrt_mvp_C_MANT_FP64 {1'b0}}, Qcnt_two_3[6:1]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = Mant_D_sqrt_Norm[39:38];
						Q_sqrt1 = {{51 {1'b0}}, Qcnt_two_3[6:0]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
					end
					6'b000100: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[37:36];
						Q_sqrt0 = {{50 {1'b0}}, Qcnt_two_4[8:1]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = Mant_D_sqrt_Norm[35:34];
						Q_sqrt1 = {{49 {1'b0}}, Qcnt_two_4[8:0]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
					end
					6'b000101: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[33:32];
						Q_sqrt0 = {{48 {1'b0}}, Qcnt_two_5[10:1]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = Mant_D_sqrt_Norm[31:30];
						Q_sqrt1 = {{47 {1'b0}}, Qcnt_two_5[10:0]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
					end
					6'b000110: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[29:28];
						Q_sqrt0 = {{46 {1'b0}}, Qcnt_two_6[12:1]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = Mant_D_sqrt_Norm[27:26];
						Q_sqrt1 = {{45 {1'b0}}, Qcnt_two_6[12:0]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
					end
					6'b000111: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[25:24];
						Q_sqrt0 = {{44 {1'b0}}, Qcnt_two_7[14:1]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = Mant_D_sqrt_Norm[23:22];
						Q_sqrt1 = {{43 {1'b0}}, Qcnt_two_7[14:0]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
					end
					6'b001000: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[21:20];
						Q_sqrt0 = {{42 {1'b0}}, Qcnt_two_8[16:1]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = Mant_D_sqrt_Norm[19:18];
						Q_sqrt1 = {{41 {1'b0}}, Qcnt_two_8[16:0]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
					end
					6'b001001: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[17:16];
						Q_sqrt0 = {{40 {1'b0}}, Qcnt_two_9[18:1]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = Mant_D_sqrt_Norm[15:14];
						Q_sqrt1 = {{39 {1'b0}}, Qcnt_two_9[18:0]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
					end
					6'b001010: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[13:12];
						Q_sqrt0 = {{38 {1'b0}}, Qcnt_two_10[20:1]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = Mant_D_sqrt_Norm[11:10];
						Q_sqrt1 = {{37 {1'b0}}, Qcnt_two_10[20:0]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
					end
					6'b001011: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[9:8];
						Q_sqrt0 = {{36 {1'b0}}, Qcnt_two_11[22:1]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = Mant_D_sqrt_Norm[7:6];
						Q_sqrt1 = {{35 {1'b0}}, Qcnt_two_11[22:0]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
					end
					6'b001100: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[5:4];
						Q_sqrt0 = {{34 {1'b0}}, Qcnt_two_12[24:1]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = Mant_D_sqrt_Norm[3:2];
						Q_sqrt1 = {{33 {1'b0}}, Qcnt_two_12[24:0]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
					end
					6'b001101: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[1:0];
						Q_sqrt0 = {{32 {1'b0}}, Qcnt_two_13[26:1]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = 2'b00;
						Q_sqrt1 = {{31 {1'b0}}, Qcnt_two_13[26:0]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
					end
					6'b001110: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{30 {1'b0}}, Qcnt_two_14[28:1]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = 2'b00;
						Q_sqrt1 = {{29 {1'b0}}, Qcnt_two_14[28:0]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
					end
					6'b001111: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{28 {1'b0}}, Qcnt_two_15[30:1]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = 2'b00;
						Q_sqrt1 = {{27 {1'b0}}, Qcnt_two_15[30:0]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
					end
					6'b010000: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{26 {1'b0}}, Qcnt_two_16[32:1]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = 2'b00;
						Q_sqrt1 = {{25 {1'b0}}, Qcnt_two_16[32:0]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
					end
					6'b010001: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{24 {1'b0}}, Qcnt_two_17[34:1]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = 2'b00;
						Q_sqrt1 = {{23 {1'b0}}, Qcnt_two_17[34:0]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
					end
					6'b010010: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{22 {1'b0}}, Qcnt_two_18[36:1]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = 2'b00;
						Q_sqrt1 = {{21 {1'b0}}, Qcnt_two_18[36:0]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
					end
					6'b010011: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{20 {1'b0}}, Qcnt_two_19[38:1]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = 2'b00;
						Q_sqrt1 = {{19 {1'b0}}, Qcnt_two_19[38:0]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
					end
					6'b010100: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{18 {1'b0}}, Qcnt_two_20[40:1]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = 2'b00;
						Q_sqrt1 = {{17 {1'b0}}, Qcnt_two_20[40:0]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
					end
					6'b010101: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{16 {1'b0}}, Qcnt_two_21[42:1]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = 2'b00;
						Q_sqrt1 = {{15 {1'b0}}, Qcnt_two_21[42:0]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
					end
					6'b010110: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{14 {1'b0}}, Qcnt_two_22[44:1]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = 2'b00;
						Q_sqrt1 = {{13 {1'b0}}, Qcnt_two_22[44:0]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
					end
					6'b010111: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{12 {1'b0}}, Qcnt_two_23[46:1]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = 2'b00;
						Q_sqrt1 = {{11 {1'b0}}, Qcnt_two_23[46:0]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
					end
					6'b011000: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{10 {1'b0}}, Qcnt_two_24[48:1]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = 2'b00;
						Q_sqrt1 = {{9 {1'b0}}, Qcnt_two_24[48:0]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
					end
					6'b011001: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{8 {1'b0}}, Qcnt_two_25[50:1]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = 2'b00;
						Q_sqrt1 = {{7 {1'b0}}, Qcnt_two_25[50:0]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
					end
					6'b011010: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{6 {1'b0}}, Qcnt_two_26[52:1]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = 2'b00;
						Q_sqrt1 = {{5 {1'b0}}, Qcnt_two_26[52:0]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
					end
					6'b011011: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{4 {1'b0}}, Qcnt_two_27[54:1]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = 2'b00;
						Q_sqrt1 = {{3 {1'b0}}, Qcnt_two_27[54:0]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
					end
					6'b011100: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{2 {1'b0}}, Qcnt_two_28[56:1]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = 2'b00;
						Q_sqrt1 = {1'b0, Qcnt_two_28[56:0]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
					end
					default: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[53:defs_div_sqrt_mvp_C_MANT_FP64];
						Q_sqrt0 = {{57 {1'b0}}, Qcnt_two_0[1]};
						Sqrt_Q0 = Q_sqrt_com_0;
						Sqrt_DI[1] = Mant_D_sqrt_Norm[51:50];
						Q_sqrt1 = {{56 {1'b0}}, Qcnt_two_0[1:0]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
					end
				endcase
			2'b10:
				case (Crtl_cnt_S)
					6'b000000: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[53:defs_div_sqrt_mvp_C_MANT_FP64];
						Q_sqrt0 = {{57 {1'b0}}, Qcnt_three_0[2]};
						Sqrt_Q0 = Q_sqrt_com_0;
						Sqrt_DI[1] = Mant_D_sqrt_Norm[51:50];
						Q_sqrt1 = {{56 {1'b0}}, Qcnt_three_0[2:1]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
						Sqrt_DI[2] = Mant_D_sqrt_Norm[49:48];
						Q_sqrt2 = {{55 {1'b0}}, Qcnt_three_0[2:0]};
						Sqrt_Q2 = (Sqrt_quotinent_S[2] ? Q_sqrt_com_2 : Q_sqrt2);
					end
					6'b000001: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[47:46];
						Q_sqrt0 = {{54 {1'b0}}, Qcnt_three_1[4:2]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = Mant_D_sqrt_Norm[45:44];
						Q_sqrt1 = {{53 {1'b0}}, Qcnt_three_1[4:1]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
						Sqrt_DI[2] = Mant_D_sqrt_Norm[43:42];
						Q_sqrt2 = {{defs_div_sqrt_mvp_C_MANT_FP64 {1'b0}}, Qcnt_three_1[4:0]};
						Sqrt_Q2 = (Sqrt_quotinent_S[2] ? Q_sqrt_com_2 : Q_sqrt2);
					end
					6'b000010: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[41:40];
						Q_sqrt0 = {{51 {1'b0}}, Qcnt_three_2[7:2]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = Mant_D_sqrt_Norm[39:38];
						Q_sqrt1 = {{50 {1'b0}}, Qcnt_three_2[7:1]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
						Sqrt_DI[2] = Mant_D_sqrt_Norm[37:36];
						Q_sqrt2 = {{49 {1'b0}}, Qcnt_three_2[7:0]};
						Sqrt_Q2 = (Sqrt_quotinent_S[2] ? Q_sqrt_com_2 : Q_sqrt2);
					end
					6'b000011: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[35:34];
						Q_sqrt0 = {{48 {1'b0}}, Qcnt_three_3[10:2]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = Mant_D_sqrt_Norm[33:32];
						Q_sqrt1 = {{47 {1'b0}}, Qcnt_three_3[10:1]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
						Sqrt_DI[2] = Mant_D_sqrt_Norm[31:30];
						Q_sqrt2 = {{46 {1'b0}}, Qcnt_three_3[10:0]};
						Sqrt_Q2 = (Sqrt_quotinent_S[2] ? Q_sqrt_com_2 : Q_sqrt2);
					end
					6'b000100: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[29:28];
						Q_sqrt0 = {{45 {1'b0}}, Qcnt_three_4[13:2]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = Mant_D_sqrt_Norm[27:26];
						Q_sqrt1 = {{44 {1'b0}}, Qcnt_three_4[13:1]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
						Sqrt_DI[2] = Mant_D_sqrt_Norm[25:24];
						Q_sqrt2 = {{43 {1'b0}}, Qcnt_three_4[13:0]};
						Sqrt_Q2 = (Sqrt_quotinent_S[2] ? Q_sqrt_com_2 : Q_sqrt2);
					end
					6'b000101: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[23:22];
						Q_sqrt0 = {{42 {1'b0}}, Qcnt_three_5[16:2]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = Mant_D_sqrt_Norm[21:20];
						Q_sqrt1 = {{41 {1'b0}}, Qcnt_three_5[16:1]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
						Sqrt_DI[2] = Mant_D_sqrt_Norm[19:18];
						Q_sqrt2 = {{40 {1'b0}}, Qcnt_three_5[16:0]};
						Sqrt_Q2 = (Sqrt_quotinent_S[2] ? Q_sqrt_com_2 : Q_sqrt2);
					end
					6'b000110: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[17:16];
						Q_sqrt0 = {{39 {1'b0}}, Qcnt_three_6[19:2]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = Mant_D_sqrt_Norm[15:14];
						Q_sqrt1 = {{38 {1'b0}}, Qcnt_three_6[19:1]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
						Sqrt_DI[2] = Mant_D_sqrt_Norm[13:12];
						Q_sqrt2 = {{37 {1'b0}}, Qcnt_three_6[19:0]};
						Sqrt_Q2 = (Sqrt_quotinent_S[2] ? Q_sqrt_com_2 : Q_sqrt2);
					end
					6'b000111: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[11:10];
						Q_sqrt0 = {{36 {1'b0}}, Qcnt_three_7[22:2]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = Mant_D_sqrt_Norm[9:8];
						Q_sqrt1 = {{35 {1'b0}}, Qcnt_three_7[22:1]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
						Sqrt_DI[2] = Mant_D_sqrt_Norm[7:6];
						Q_sqrt2 = {{34 {1'b0}}, Qcnt_three_7[22:0]};
						Sqrt_Q2 = (Sqrt_quotinent_S[2] ? Q_sqrt_com_2 : Q_sqrt2);
					end
					6'b001000: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[5:4];
						Q_sqrt0 = {{33 {1'b0}}, Qcnt_three_8[25:2]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = Mant_D_sqrt_Norm[3:2];
						Q_sqrt1 = {{32 {1'b0}}, Qcnt_three_8[25:1]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
						Sqrt_DI[2] = Mant_D_sqrt_Norm[1:0];
						Q_sqrt2 = {{31 {1'b0}}, Qcnt_three_8[25:0]};
						Sqrt_Q2 = (Sqrt_quotinent_S[2] ? Q_sqrt_com_2 : Q_sqrt2);
					end
					6'b001001: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{30 {1'b0}}, Qcnt_three_9[28:2]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = 2'b00;
						Q_sqrt1 = {{29 {1'b0}}, Qcnt_three_9[28:1]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
						Sqrt_DI[2] = 2'b00;
						Q_sqrt2 = {{28 {1'b0}}, Qcnt_three_9[28:0]};
						Sqrt_Q2 = (Sqrt_quotinent_S[2] ? Q_sqrt_com_2 : Q_sqrt2);
					end
					6'b001010: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{27 {1'b0}}, Qcnt_three_10[31:2]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = 2'b00;
						Q_sqrt1 = {{26 {1'b0}}, Qcnt_three_10[31:1]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
						Sqrt_DI[2] = 2'b00;
						Q_sqrt2 = {{25 {1'b0}}, Qcnt_three_10[31:0]};
						Sqrt_Q2 = (Sqrt_quotinent_S[2] ? Q_sqrt_com_2 : Q_sqrt2);
					end
					6'b001011: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{24 {1'b0}}, Qcnt_three_11[34:2]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = 2'b00;
						Q_sqrt1 = {{23 {1'b0}}, Qcnt_three_11[34:1]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
						Sqrt_DI[2] = 2'b00;
						Q_sqrt2 = {{22 {1'b0}}, Qcnt_three_11[34:0]};
						Sqrt_Q2 = (Sqrt_quotinent_S[2] ? Q_sqrt_com_2 : Q_sqrt2);
					end
					6'b001100: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{21 {1'b0}}, Qcnt_three_12[37:2]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = 2'b00;
						Q_sqrt1 = {{20 {1'b0}}, Qcnt_three_12[37:1]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
						Sqrt_DI[2] = 2'b00;
						Q_sqrt2 = {{19 {1'b0}}, Qcnt_three_12[37:0]};
						Sqrt_Q2 = (Sqrt_quotinent_S[2] ? Q_sqrt_com_2 : Q_sqrt2);
					end
					6'b001101: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{18 {1'b0}}, Qcnt_three_13[40:2]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = 2'b00;
						Q_sqrt1 = {{17 {1'b0}}, Qcnt_three_13[40:1]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
						Sqrt_DI[2] = 2'b00;
						Q_sqrt2 = {{16 {1'b0}}, Qcnt_three_13[40:0]};
						Sqrt_Q2 = (Sqrt_quotinent_S[2] ? Q_sqrt_com_2 : Q_sqrt2);
					end
					6'b001110: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{15 {1'b0}}, Qcnt_three_14[43:2]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = 2'b00;
						Q_sqrt1 = {{14 {1'b0}}, Qcnt_three_14[43:1]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
						Sqrt_DI[2] = 2'b00;
						Q_sqrt2 = {{13 {1'b0}}, Qcnt_three_14[43:0]};
						Sqrt_Q2 = (Sqrt_quotinent_S[2] ? Q_sqrt_com_2 : Q_sqrt2);
					end
					6'b001111: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{12 {1'b0}}, Qcnt_three_15[46:2]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = 2'b00;
						Q_sqrt1 = {{11 {1'b0}}, Qcnt_three_15[46:1]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
						Sqrt_DI[2] = 2'b00;
						Q_sqrt2 = {{10 {1'b0}}, Qcnt_three_15[46:0]};
						Sqrt_Q2 = (Sqrt_quotinent_S[2] ? Q_sqrt_com_2 : Q_sqrt2);
					end
					6'b010000: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{9 {1'b0}}, Qcnt_three_16[49:2]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = 2'b00;
						Q_sqrt1 = {{8 {1'b0}}, Qcnt_three_16[49:1]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
						Sqrt_DI[2] = 2'b00;
						Q_sqrt2 = {{7 {1'b0}}, Qcnt_three_16[49:0]};
						Sqrt_Q2 = (Sqrt_quotinent_S[2] ? Q_sqrt_com_2 : Q_sqrt2);
					end
					6'b010001: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{6 {1'b0}}, Qcnt_three_17[52:2]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = 2'b00;
						Q_sqrt1 = {{5 {1'b0}}, Qcnt_three_17[52:1]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
						Sqrt_DI[2] = 2'b00;
						Q_sqrt2 = {{4 {1'b0}}, Qcnt_three_17[52:0]};
						Sqrt_Q2 = (Sqrt_quotinent_S[2] ? Q_sqrt_com_2 : Q_sqrt2);
					end
					6'b010010: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{3 {1'b0}}, Qcnt_three_18[55:2]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = 2'b00;
						Q_sqrt1 = {{2 {1'b0}}, Qcnt_three_18[55:1]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
						Sqrt_DI[2] = 2'b00;
						Q_sqrt2 = {1'b0, Qcnt_three_18[55:0]};
						Sqrt_Q2 = (Sqrt_quotinent_S[2] ? Q_sqrt_com_2 : Q_sqrt2);
					end
					default: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[53:defs_div_sqrt_mvp_C_MANT_FP64];
						Q_sqrt0 = {{57 {1'b0}}, Qcnt_three_0[2]};
						Sqrt_Q0 = Q_sqrt_com_0;
						Sqrt_DI[1] = Mant_D_sqrt_Norm[51:50];
						Q_sqrt1 = {{56 {1'b0}}, Qcnt_three_0[2:1]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
						Sqrt_DI[2] = Mant_D_sqrt_Norm[49:48];
						Q_sqrt2 = {{55 {1'b0}}, Qcnt_three_0[2:0]};
						Sqrt_Q2 = (Sqrt_quotinent_S[2] ? Q_sqrt_com_2 : Q_sqrt2);
					end
				endcase
			2'b11:
				case (Crtl_cnt_S)
					6'b000000: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[53:defs_div_sqrt_mvp_C_MANT_FP64];
						Q_sqrt0 = {{57 {1'b0}}, Qcnt_four_0[3]};
						Sqrt_Q0 = Q_sqrt_com_0;
						Sqrt_DI[1] = Mant_D_sqrt_Norm[51:50];
						Q_sqrt1 = {{56 {1'b0}}, Qcnt_four_0[3:2]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
						Sqrt_DI[2] = Mant_D_sqrt_Norm[49:48];
						Q_sqrt2 = {{55 {1'b0}}, Qcnt_four_0[3:1]};
						Sqrt_Q2 = (Sqrt_quotinent_S[2] ? Q_sqrt_com_2 : Q_sqrt2);
						Sqrt_DI[3] = Mant_D_sqrt_Norm[47:46];
						Q_sqrt3 = {{54 {1'b0}}, Qcnt_four_0[3:0]};
						Sqrt_Q3 = (Sqrt_quotinent_S[1] ? Q_sqrt_com_3 : Q_sqrt3);
					end
					6'b000001: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[45:44];
						Q_sqrt0 = {{53 {1'b0}}, Qcnt_four_1[6:3]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = Mant_D_sqrt_Norm[43:42];
						Q_sqrt1 = {{defs_div_sqrt_mvp_C_MANT_FP64 {1'b0}}, Qcnt_four_1[6:2]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
						Sqrt_DI[2] = Mant_D_sqrt_Norm[41:40];
						Q_sqrt2 = {{51 {1'b0}}, Qcnt_four_1[6:1]};
						Sqrt_Q2 = (Sqrt_quotinent_S[2] ? Q_sqrt_com_2 : Q_sqrt2);
						Sqrt_DI[3] = Mant_D_sqrt_Norm[39:38];
						Q_sqrt3 = {{50 {1'b0}}, Qcnt_four_1[6:0]};
						Sqrt_Q3 = (Sqrt_quotinent_S[1] ? Q_sqrt_com_3 : Q_sqrt3);
					end
					6'b000010: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[37:36];
						Q_sqrt0 = {{49 {1'b0}}, Qcnt_four_2[10:3]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = Mant_D_sqrt_Norm[35:34];
						Q_sqrt1 = {{48 {1'b0}}, Qcnt_four_2[10:2]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
						Sqrt_DI[2] = Mant_D_sqrt_Norm[33:32];
						Q_sqrt2 = {{47 {1'b0}}, Qcnt_four_2[10:1]};
						Sqrt_Q2 = (Sqrt_quotinent_S[2] ? Q_sqrt_com_2 : Q_sqrt2);
						Sqrt_DI[3] = Mant_D_sqrt_Norm[31:30];
						Q_sqrt3 = {{46 {1'b0}}, Qcnt_four_2[10:0]};
						Sqrt_Q3 = (Sqrt_quotinent_S[1] ? Q_sqrt_com_3 : Q_sqrt3);
					end
					6'b000011: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[29:28];
						Q_sqrt0 = {{45 {1'b0}}, Qcnt_four_3[14:3]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = Mant_D_sqrt_Norm[27:26];
						Q_sqrt1 = {{44 {1'b0}}, Qcnt_four_3[14:2]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
						Sqrt_DI[2] = Mant_D_sqrt_Norm[25:24];
						Q_sqrt2 = {{43 {1'b0}}, Qcnt_four_3[14:1]};
						Sqrt_Q2 = (Sqrt_quotinent_S[2] ? Q_sqrt_com_2 : Q_sqrt2);
						Sqrt_DI[3] = Mant_D_sqrt_Norm[23:22];
						Q_sqrt3 = {{42 {1'b0}}, Qcnt_four_3[14:0]};
						Sqrt_Q3 = (Sqrt_quotinent_S[1] ? Q_sqrt_com_3 : Q_sqrt3);
					end
					6'b000100: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[21:20];
						Q_sqrt0 = {{41 {1'b0}}, Qcnt_four_4[18:3]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = Mant_D_sqrt_Norm[19:18];
						Q_sqrt1 = {{40 {1'b0}}, Qcnt_four_4[18:2]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
						Sqrt_DI[2] = Mant_D_sqrt_Norm[17:16];
						Q_sqrt2 = {{39 {1'b0}}, Qcnt_four_4[18:1]};
						Sqrt_Q2 = (Sqrt_quotinent_S[2] ? Q_sqrt_com_2 : Q_sqrt2);
						Sqrt_DI[3] = Mant_D_sqrt_Norm[15:14];
						Q_sqrt3 = {{38 {1'b0}}, Qcnt_four_4[18:0]};
						Sqrt_Q3 = (Sqrt_quotinent_S[1] ? Q_sqrt_com_3 : Q_sqrt3);
					end
					6'b000101: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[13:12];
						Q_sqrt0 = {{37 {1'b0}}, Qcnt_four_5[22:3]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = Mant_D_sqrt_Norm[11:10];
						Q_sqrt1 = {{36 {1'b0}}, Qcnt_four_5[22:2]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
						Sqrt_DI[2] = Mant_D_sqrt_Norm[9:8];
						Q_sqrt2 = {{35 {1'b0}}, Qcnt_four_5[22:1]};
						Sqrt_Q2 = (Sqrt_quotinent_S[2] ? Q_sqrt_com_2 : Q_sqrt2);
						Sqrt_DI[3] = Mant_D_sqrt_Norm[7:6];
						Q_sqrt3 = {{34 {1'b0}}, Qcnt_four_5[22:0]};
						Sqrt_Q3 = (Sqrt_quotinent_S[1] ? Q_sqrt_com_3 : Q_sqrt3);
					end
					6'b000110: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[5:4];
						Q_sqrt0 = {{33 {1'b0}}, Qcnt_four_6[26:3]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = Mant_D_sqrt_Norm[3:2];
						Q_sqrt1 = {{32 {1'b0}}, Qcnt_four_6[26:2]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
						Sqrt_DI[2] = Mant_D_sqrt_Norm[1:0];
						Q_sqrt2 = {{31 {1'b0}}, Qcnt_four_6[26:1]};
						Sqrt_Q2 = (Sqrt_quotinent_S[2] ? Q_sqrt_com_2 : Q_sqrt2);
						Sqrt_DI[3] = 2'b00;
						Q_sqrt3 = {{30 {1'b0}}, Qcnt_four_6[26:0]};
						Sqrt_Q3 = (Sqrt_quotinent_S[1] ? Q_sqrt_com_3 : Q_sqrt3);
					end
					6'b000111: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{29 {1'b0}}, Qcnt_four_7[30:3]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = 2'b00;
						Q_sqrt1 = {{28 {1'b0}}, Qcnt_four_7[30:2]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
						Sqrt_DI[2] = 2'b00;
						Q_sqrt2 = {{27 {1'b0}}, Qcnt_four_7[30:1]};
						Sqrt_Q2 = (Sqrt_quotinent_S[2] ? Q_sqrt_com_2 : Q_sqrt2);
						Sqrt_DI[3] = 2'b00;
						Q_sqrt3 = {{26 {1'b0}}, Qcnt_four_7[30:0]};
						Sqrt_Q3 = (Sqrt_quotinent_S[1] ? Q_sqrt_com_3 : Q_sqrt3);
					end
					6'b001000: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{25 {1'b0}}, Qcnt_four_8[34:3]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = 2'b00;
						Q_sqrt1 = {{24 {1'b0}}, Qcnt_four_8[34:2]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
						Sqrt_DI[2] = 2'b00;
						Q_sqrt2 = {{23 {1'b0}}, Qcnt_four_8[34:1]};
						Sqrt_Q2 = (Sqrt_quotinent_S[2] ? Q_sqrt_com_2 : Q_sqrt2);
						Sqrt_DI[3] = 2'b00;
						Q_sqrt3 = {{22 {1'b0}}, Qcnt_four_8[34:0]};
						Sqrt_Q3 = (Sqrt_quotinent_S[1] ? Q_sqrt_com_3 : Q_sqrt3);
					end
					6'b001001: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{21 {1'b0}}, Qcnt_four_9[38:3]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = 2'b00;
						Q_sqrt1 = {{20 {1'b0}}, Qcnt_four_9[38:2]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
						Sqrt_DI[2] = 2'b00;
						Q_sqrt2 = {{19 {1'b0}}, Qcnt_four_9[38:1]};
						Sqrt_Q2 = (Sqrt_quotinent_S[2] ? Q_sqrt_com_2 : Q_sqrt2);
						Sqrt_DI[3] = 2'b00;
						Q_sqrt3 = {{18 {1'b0}}, Qcnt_four_9[38:0]};
						Sqrt_Q3 = (Sqrt_quotinent_S[1] ? Q_sqrt_com_3 : Q_sqrt3);
					end
					6'b001010: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{17 {1'b0}}, Qcnt_four_10[42:3]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = 2'b00;
						Q_sqrt1 = {{16 {1'b0}}, Qcnt_four_10[42:2]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
						Sqrt_DI[2] = 2'b00;
						Q_sqrt2 = {{15 {1'b0}}, Qcnt_four_10[42:1]};
						Sqrt_Q2 = (Sqrt_quotinent_S[2] ? Q_sqrt_com_2 : Q_sqrt2);
						Sqrt_DI[3] = 2'b00;
						Q_sqrt3 = {{14 {1'b0}}, Qcnt_four_10[42:0]};
						Sqrt_Q3 = (Sqrt_quotinent_S[1] ? Q_sqrt_com_3 : Q_sqrt3);
					end
					6'b001011: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{13 {1'b0}}, Qcnt_four_11[46:3]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = 2'b00;
						Q_sqrt1 = {{12 {1'b0}}, Qcnt_four_11[46:2]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
						Sqrt_DI[2] = 2'b00;
						Q_sqrt2 = {{11 {1'b0}}, Qcnt_four_11[46:1]};
						Sqrt_Q2 = (Sqrt_quotinent_S[2] ? Q_sqrt_com_2 : Q_sqrt2);
						Sqrt_DI[3] = 2'b00;
						Q_sqrt3 = {{10 {1'b0}}, Qcnt_four_11[46:0]};
						Sqrt_Q3 = (Sqrt_quotinent_S[1] ? Q_sqrt_com_3 : Q_sqrt3);
					end
					6'b001100: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{9 {1'b0}}, Qcnt_four_12[50:3]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = 2'b00;
						Q_sqrt1 = {{8 {1'b0}}, Qcnt_four_12[50:2]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
						Sqrt_DI[2] = 2'b00;
						Q_sqrt2 = {{7 {1'b0}}, Qcnt_four_12[50:1]};
						Sqrt_Q2 = (Sqrt_quotinent_S[2] ? Q_sqrt_com_2 : Q_sqrt2);
						Sqrt_DI[3] = 2'b00;
						Q_sqrt3 = {{6 {1'b0}}, Qcnt_four_12[50:0]};
						Sqrt_Q3 = (Sqrt_quotinent_S[1] ? Q_sqrt_com_3 : Q_sqrt3);
					end
					6'b001101: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{5 {1'b0}}, Qcnt_four_13[54:3]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = 2'b00;
						Q_sqrt1 = {{4 {1'b0}}, Qcnt_four_13[54:2]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
						Sqrt_DI[2] = 2'b00;
						Q_sqrt2 = {{3 {1'b0}}, Qcnt_four_13[54:1]};
						Sqrt_Q2 = (Sqrt_quotinent_S[2] ? Q_sqrt_com_2 : Q_sqrt2);
						Sqrt_DI[3] = 2'b00;
						Q_sqrt3 = {{2 {1'b0}}, Qcnt_four_13[54:0]};
						Sqrt_Q3 = (Sqrt_quotinent_S[1] ? Q_sqrt_com_3 : Q_sqrt3);
					end
					default: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[53:defs_div_sqrt_mvp_C_MANT_FP64];
						Q_sqrt0 = {{57 {1'b0}}, Qcnt_four_0[3]};
						Sqrt_Q0 = Q_sqrt_com_0;
						Sqrt_DI[1] = Mant_D_sqrt_Norm[51:50];
						Q_sqrt1 = {{56 {1'b0}}, Qcnt_four_0[3:2]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
						Sqrt_DI[2] = Mant_D_sqrt_Norm[49:48];
						Q_sqrt2 = {{55 {1'b0}}, Qcnt_four_0[3:1]};
						Sqrt_Q2 = (Sqrt_quotinent_S[2] ? Q_sqrt_com_2 : Q_sqrt2);
						Sqrt_DI[3] = Mant_D_sqrt_Norm[47:46];
						Q_sqrt3 = {{54 {1'b0}}, Qcnt_four_0[3:0]};
						Sqrt_Q3 = (Sqrt_quotinent_S[1] ? Q_sqrt_com_3 : Q_sqrt3);
					end
				endcase
		endcase
	assign Sqrt_R0 = (Sqrt_start_dly_S ? {58 {1'sb0}} : {Partial_remainder_DP[57:0]});
	assign Sqrt_R1 = {Iteration_cell_sum_AMASK_D[0][57], Iteration_cell_sum_AMASK_D[0][54:0], Sqrt_DO[0]};
	assign Sqrt_R2 = {Iteration_cell_sum_AMASK_D[1][57], Iteration_cell_sum_AMASK_D[1][54:0], Sqrt_DO[1]};
	assign Sqrt_R3 = {Iteration_cell_sum_AMASK_D[2][57], Iteration_cell_sum_AMASK_D[2][54:0], Sqrt_DO[2]};
	assign Sqrt_R4 = {Iteration_cell_sum_AMASK_D[3][57], Iteration_cell_sum_AMASK_D[3][54:0], Sqrt_DO[3]};
	wire [57:0] Denominator_se_format_DB;
	assign Denominator_se_format_DB = {Denominator_se_DB[53:45], (FP16ALT_SO ? FP16ALT_SO : Denominator_se_DB[44]), Denominator_se_DB[43:42], (FP16_SO ? FP16_SO : Denominator_se_DB[41]), Denominator_se_DB[40:29], (FP32_SO ? FP32_SO : Denominator_se_DB[28]), Denominator_se_DB[27:0], FP64_SO, 3'b000};
	wire [57:0] First_iteration_cell_div_a_D;
	wire [57:0] First_iteration_cell_div_b_D;
	wire Sel_b_for_first_S;
	assign First_iteration_cell_div_a_D = (Div_start_dly_S ? {Numerator_se_D[53:45], (FP16ALT_SO ? FP16ALT_SO : Numerator_se_D[44]), Numerator_se_D[43:42], (FP16_SO ? FP16_SO : Numerator_se_D[41]), Numerator_se_D[40:29], (FP32_SO ? FP32_SO : Numerator_se_D[28]), Numerator_se_D[27:0], FP64_SO, 3'b000} : {Partial_remainder_DP[56:48], (FP16ALT_SO ? Quotient_DP[0] : Partial_remainder_DP[47]), Partial_remainder_DP[46:45], (FP16_SO ? Quotient_DP[0] : Partial_remainder_DP[44]), Partial_remainder_DP[43:32], (FP32_SO ? Quotient_DP[0] : Partial_remainder_DP[31]), Partial_remainder_DP[30:3], FP64_SO && Quotient_DP[0], 3'b000});
	assign Sel_b_for_first_S = (Div_start_dly_S ? 1 : Quotient_DP[0]);
	assign First_iteration_cell_div_b_D = (Sel_b_for_first_S ? Denominator_se_format_DB : {Denominator_se_D, 4'b0000});
	assign Iteration_cell_a_BMASK_D[0] = (Sqrt_enable_SO ? Sqrt_R0 : {First_iteration_cell_div_a_D});
	assign Iteration_cell_b_BMASK_D[0] = (Sqrt_enable_SO ? Sqrt_Q0 : {First_iteration_cell_div_b_D});
	wire [57:0] Sec_iteration_cell_div_a_D;
	wire [57:0] Sec_iteration_cell_div_b_D;
	wire Sel_b_for_sec_S;
	generate
		if (|defs_div_sqrt_mvp_Iteration_unit_num_S) begin : genblk1
			assign Sel_b_for_sec_S = ~Iteration_cell_sum_AMASK_D[0][57];
			assign Sec_iteration_cell_div_a_D = {Iteration_cell_sum_AMASK_D[0][56:48], (FP16ALT_SO ? Sel_b_for_sec_S : Iteration_cell_sum_AMASK_D[0][47]), Iteration_cell_sum_AMASK_D[0][46:45], (FP16_SO ? Sel_b_for_sec_S : Iteration_cell_sum_AMASK_D[0][44]), Iteration_cell_sum_AMASK_D[0][43:32], (FP32_SO ? Sel_b_for_sec_S : Iteration_cell_sum_AMASK_D[0][31]), Iteration_cell_sum_AMASK_D[0][30:3], FP64_SO && Sel_b_for_sec_S, 3'b000};
			assign Sec_iteration_cell_div_b_D = (Sel_b_for_sec_S ? Denominator_se_format_DB : {Denominator_se_D, 4'b0000});
			assign Iteration_cell_a_BMASK_D[1] = (Sqrt_enable_SO ? Sqrt_R1 : {Sec_iteration_cell_div_a_D});
			assign Iteration_cell_b_BMASK_D[1] = (Sqrt_enable_SO ? Sqrt_Q1 : {Sec_iteration_cell_div_b_D});
		end
	endgenerate
	wire [57:0] Thi_iteration_cell_div_a_D;
	wire [57:0] Thi_iteration_cell_div_b_D;
	wire Sel_b_for_thi_S;
	generate
		if (1'd1 | 1'd0) begin : genblk2
			assign Sel_b_for_thi_S = ~Iteration_cell_sum_AMASK_D[1][57];
			assign Thi_iteration_cell_div_a_D = {Iteration_cell_sum_AMASK_D[1][56:48], (FP16ALT_SO ? Sel_b_for_thi_S : Iteration_cell_sum_AMASK_D[1][47]), Iteration_cell_sum_AMASK_D[1][46:45], (FP16_SO ? Sel_b_for_thi_S : Iteration_cell_sum_AMASK_D[1][44]), Iteration_cell_sum_AMASK_D[1][43:32], (FP32_SO ? Sel_b_for_thi_S : Iteration_cell_sum_AMASK_D[1][31]), Iteration_cell_sum_AMASK_D[1][30:3], FP64_SO && Sel_b_for_thi_S, 3'b000};
			assign Thi_iteration_cell_div_b_D = (Sel_b_for_thi_S ? Denominator_se_format_DB : {Denominator_se_D, 4'b0000});
			assign Iteration_cell_a_BMASK_D[2] = (Sqrt_enable_SO ? Sqrt_R2 : {Thi_iteration_cell_div_a_D});
			assign Iteration_cell_b_BMASK_D[2] = (Sqrt_enable_SO ? Sqrt_Q2 : {Thi_iteration_cell_div_b_D});
		end
	endgenerate
	wire [57:0] Fou_iteration_cell_div_a_D;
	wire [57:0] Fou_iteration_cell_div_b_D;
	wire Sel_b_for_fou_S;
	wire [57:0] Mask_bits_ctl_S;
	assign Mask_bits_ctl_S = 58'h3ffffffffffffff;
	wire Div_enable_SI [3:0];
	wire Div_start_dly_SI [3:0];
	wire Sqrt_enable_SI [3:0];
	genvar i;
	genvar j;
	generate
		for (i = 0; i <= defs_div_sqrt_mvp_Iteration_unit_num_S; i = i + 1) begin : genblk4
			for (j = 0; j <= 57; j = j + 1) begin : genblk1
				assign Iteration_cell_a_D[i][j] = Mask_bits_ctl_S[j] && Iteration_cell_a_BMASK_D[i][j];
				assign Iteration_cell_b_D[i][j] = Mask_bits_ctl_S[j] && Iteration_cell_b_BMASK_D[i][j];
				assign Iteration_cell_sum_AMASK_D[i][j] = Mask_bits_ctl_S[j] && Iteration_cell_sum_D[i][j];
			end
			assign Div_enable_SI[i] = Div_enable_SO;
			assign Div_start_dly_SI[i] = Div_start_dly_S;
			assign Sqrt_enable_SI[i] = Sqrt_enable_SO;
			iteration_div_sqrt_mvp #(.WIDTH(58)) iteration_div_sqrt(
				.A_DI(Iteration_cell_a_D[i]),
				.B_DI(Iteration_cell_b_D[i]),
				.Div_enable_SI(Div_enable_SI[i]),
				.Div_start_dly_SI(Div_start_dly_SI[i]),
				.Sqrt_enable_SI(Sqrt_enable_SI[i]),
				.D_DI(Sqrt_DI[i]),
				.D_DO(Sqrt_DO[i]),
				.Sum_DO(Iteration_cell_sum_D[i]),
				.Carry_out_DO(Iteration_cell_carry_D[i])
			);
		end
	endgenerate
	always @(*)
		case (defs_div_sqrt_mvp_Iteration_unit_num_S)
			2'b00:
				if (Fsm_enable_S)
					Partial_remainder_DN = (Sqrt_enable_SO ? Sqrt_R1 : Iteration_cell_sum_AMASK_D[0]);
				else
					Partial_remainder_DN = Partial_remainder_DP;
			2'b01:
				if (Fsm_enable_S)
					Partial_remainder_DN = (Sqrt_enable_SO ? Sqrt_R2 : Iteration_cell_sum_AMASK_D[1]);
				else
					Partial_remainder_DN = Partial_remainder_DP;
			2'b10:
				if (Fsm_enable_S)
					Partial_remainder_DN = (Sqrt_enable_SO ? Sqrt_R3 : Iteration_cell_sum_AMASK_D[2]);
				else
					Partial_remainder_DN = Partial_remainder_DP;
			2'b11:
				if (Fsm_enable_S)
					Partial_remainder_DN = (Sqrt_enable_SO ? Sqrt_R4 : Iteration_cell_sum_AMASK_D[3]);
				else
					Partial_remainder_DN = Partial_remainder_DP;
		endcase
	always @(posedge Clk_CI or negedge Rst_RBI)
		if (~Rst_RBI)
			Partial_remainder_DP <= 1'sb0;
		else
			Partial_remainder_DP <= Partial_remainder_DN;
	reg [56:0] Quotient_DN;
	always @(*)
		case (defs_div_sqrt_mvp_Iteration_unit_num_S)
			2'b00:
				if (Fsm_enable_S)
					Quotient_DN = (Sqrt_enable_SO ? {Quotient_DP[55:0], Sqrt_quotinent_S[3]} : {Quotient_DP[55:0], Iteration_cell_carry_D[0]});
				else
					Quotient_DN = Quotient_DP;
			2'b01:
				if (Fsm_enable_S)
					Quotient_DN = (Sqrt_enable_SO ? {Quotient_DP[54:0], Sqrt_quotinent_S[3:2]} : {Quotient_DP[54:0], Iteration_cell_carry_D[0], Iteration_cell_carry_D[1]});
				else
					Quotient_DN = Quotient_DP;
			2'b10:
				if (Fsm_enable_S)
					Quotient_DN = (Sqrt_enable_SO ? {Quotient_DP[53:0], Sqrt_quotinent_S[3:1]} : {Quotient_DP[53:0], Iteration_cell_carry_D[0], Iteration_cell_carry_D[1], Iteration_cell_carry_D[2]});
				else
					Quotient_DN = Quotient_DP;
			2'b11:
				if (Fsm_enable_S)
					Quotient_DN = (Sqrt_enable_SO ? {Quotient_DP[defs_div_sqrt_mvp_C_MANT_FP64:0], Sqrt_quotinent_S} : {Quotient_DP[defs_div_sqrt_mvp_C_MANT_FP64:0], Iteration_cell_carry_D[0], Iteration_cell_carry_D[1], Iteration_cell_carry_D[2], Iteration_cell_carry_D[3]});
				else
					Quotient_DN = Quotient_DP;
		endcase
	always @(posedge Clk_CI or negedge Rst_RBI)
		if (~Rst_RBI)
			Quotient_DP <= 1'sb0;
		else
			Quotient_DP <= Quotient_DN;
	generate
		if (1) begin : genblk7
			always @(*)
				case (Format_sel_S)
					2'b00:
						case (Precision_ctl_S)
							6'h00: Mant_result_prenorm_DO = {Quotient_DP[26:0], {30 {1'b0}}};
							6'h17, 6'h16, 6'h15: Mant_result_prenorm_DO = {Quotient_DP[defs_div_sqrt_mvp_C_MANT_FP32:0], {33 {1'b0}}};
							6'h14, 6'h13, 6'h12: Mant_result_prenorm_DO = {Quotient_DP[20:0], {36 {1'b0}}};
							6'h11, 6'h10, 6'h0f: Mant_result_prenorm_DO = {Quotient_DP[17:0], {39 {1'b0}}};
							6'h0e, 6'h0d, 6'h0c: Mant_result_prenorm_DO = {Quotient_DP[14:0], {42 {1'b0}}};
							6'h0b, 6'h0a, 6'h09: Mant_result_prenorm_DO = {Quotient_DP[11:0], {45 {1'b0}}};
							6'h08, 6'h07, 6'h06: Mant_result_prenorm_DO = {Quotient_DP[8:0], {48 {1'b0}}};
							default: Mant_result_prenorm_DO = {Quotient_DP[26:0], {30 {1'b0}}};
						endcase
					2'b01:
						case (Precision_ctl_S)
							6'h00: Mant_result_prenorm_DO = Quotient_DP[56:0];
							6'h34, 6'h33: Mant_result_prenorm_DO = {Quotient_DP[53:1], {4 {1'b0}}};
							6'h32, 6'h31, 6'h30: Mant_result_prenorm_DO = {Quotient_DP[50:0], {6 {1'b0}}};
							6'h2f, 6'h2e, 6'h2d: Mant_result_prenorm_DO = {Quotient_DP[47:0], {9 {1'b0}}};
							6'h2c, 6'h2b, 6'h2a: Mant_result_prenorm_DO = {Quotient_DP[44:0], {12 {1'b0}}};
							6'h29, 6'h28, 6'h27: Mant_result_prenorm_DO = {Quotient_DP[41:0], {15 {1'b0}}};
							6'h26, 6'h25, 6'h24: Mant_result_prenorm_DO = {Quotient_DP[38:0], {18 {1'b0}}};
							6'h23, 6'h22, 6'h21: Mant_result_prenorm_DO = {Quotient_DP[35:0], {21 {1'b0}}};
							6'h20, 6'h1f, 6'h1e: Mant_result_prenorm_DO = {Quotient_DP[32:0], {24 {1'b0}}};
							6'h1d, 6'h1c, 6'h1b: Mant_result_prenorm_DO = {Quotient_DP[29:0], {27 {1'b0}}};
							6'h1a, 6'h19, 6'h18: Mant_result_prenorm_DO = {Quotient_DP[26:0], {30 {1'b0}}};
							6'h17, 6'h16, 6'h15: Mant_result_prenorm_DO = {Quotient_DP[23:0], {33 {1'b0}}};
							6'h14, 6'h13, 6'h12: Mant_result_prenorm_DO = {Quotient_DP[20:0], {36 {1'b0}}};
							6'h11, 6'h10, 6'h0f: Mant_result_prenorm_DO = {Quotient_DP[17:0], {39 {1'b0}}};
							6'h0e, 6'h0d, 6'h0c: Mant_result_prenorm_DO = {Quotient_DP[14:0], {42 {1'b0}}};
							6'h0b, 6'h0a, 6'h09: Mant_result_prenorm_DO = {Quotient_DP[11:0], {45 {1'b0}}};
							6'h08, 6'h07, 6'h06: Mant_result_prenorm_DO = {Quotient_DP[8:0], {48 {1'b0}}};
							default: Mant_result_prenorm_DO = Quotient_DP[56:0];
						endcase
					2'b10:
						case (Precision_ctl_S)
							6'b000000: Mant_result_prenorm_DO = {Quotient_DP[14:0], {42 {1'b0}}};
							6'h0a, 6'h09: Mant_result_prenorm_DO = {Quotient_DP[11:1], {46 {1'b0}}};
							6'h08, 6'h07, 6'h06: Mant_result_prenorm_DO = {Quotient_DP[8:0], {48 {1'b0}}};
							default: Mant_result_prenorm_DO = {Quotient_DP[14:0], {42 {1'b0}}};
						endcase
					2'b11:
						case (Precision_ctl_S)
							6'b000000: Mant_result_prenorm_DO = {Quotient_DP[11:0], {45 {1'b0}}};
							6'h07, 6'h06: Mant_result_prenorm_DO = {Quotient_DP[8:1], {49 {1'b0}}};
							default: Mant_result_prenorm_DO = {Quotient_DP[11:0], {45 {1'b0}}};
						endcase
				endcase
		end
	endgenerate
	wire [12:0] Exp_result_prenorm_DN;
	reg [12:0] Exp_result_prenorm_DP;
	wire [12:0] Exp_add_a_D;
	wire [12:0] Exp_add_b_D;
	wire [12:0] Exp_add_c_D;
	integer C_BIAS_AONE;
	integer C_HALF_BIAS;
	localparam defs_div_sqrt_mvp_C_BIAS_AONE_FP16 = 5'h10;
	localparam defs_div_sqrt_mvp_C_BIAS_AONE_FP16ALT = 8'h80;
	localparam defs_div_sqrt_mvp_C_BIAS_AONE_FP32 = 8'h80;
	localparam defs_div_sqrt_mvp_C_BIAS_AONE_FP64 = 11'h400;
	localparam defs_div_sqrt_mvp_C_HALF_BIAS_FP16 = 7;
	localparam defs_div_sqrt_mvp_C_HALF_BIAS_FP16ALT = 63;
	localparam defs_div_sqrt_mvp_C_HALF_BIAS_FP32 = 63;
	localparam defs_div_sqrt_mvp_C_HALF_BIAS_FP64 = 511;
	always @(*)
		case (Format_sel_S)
			2'b00: begin
				C_BIAS_AONE = defs_div_sqrt_mvp_C_BIAS_AONE_FP32;
				C_HALF_BIAS = defs_div_sqrt_mvp_C_HALF_BIAS_FP32;
			end
			2'b01: begin
				C_BIAS_AONE = defs_div_sqrt_mvp_C_BIAS_AONE_FP64;
				C_HALF_BIAS = defs_div_sqrt_mvp_C_HALF_BIAS_FP64;
			end
			2'b10: begin
				C_BIAS_AONE = defs_div_sqrt_mvp_C_BIAS_AONE_FP16;
				C_HALF_BIAS = defs_div_sqrt_mvp_C_HALF_BIAS_FP16;
			end
			2'b11: begin
				C_BIAS_AONE = defs_div_sqrt_mvp_C_BIAS_AONE_FP16ALT;
				C_HALF_BIAS = defs_div_sqrt_mvp_C_HALF_BIAS_FP16ALT;
			end
		endcase
	assign Exp_add_a_D = {(Sqrt_start_dly_S ? {Exp_num_DI[defs_div_sqrt_mvp_C_EXP_FP64], Exp_num_DI[defs_div_sqrt_mvp_C_EXP_FP64], Exp_num_DI[defs_div_sqrt_mvp_C_EXP_FP64], Exp_num_DI[defs_div_sqrt_mvp_C_EXP_FP64:1]} : {Exp_num_DI[defs_div_sqrt_mvp_C_EXP_FP64], Exp_num_DI[defs_div_sqrt_mvp_C_EXP_FP64], Exp_num_DI})};
	localparam defs_div_sqrt_mvp_C_EXP_ZERO_FP64 = 11'h000;
	assign Exp_add_b_D = {(Sqrt_start_dly_S ? {1'b0, defs_div_sqrt_mvp_C_EXP_ZERO_FP64, Exp_num_DI[0]} : {~Exp_den_DI[defs_div_sqrt_mvp_C_EXP_FP64], ~Exp_den_DI[defs_div_sqrt_mvp_C_EXP_FP64], ~Exp_den_DI})};
	assign Exp_add_c_D = {(Div_start_dly_S ? {C_BIAS_AONE} : {C_HALF_BIAS})};
	assign Exp_result_prenorm_DN = (Start_dly_S ? {(Exp_add_a_D + Exp_add_b_D) + Exp_add_c_D} : Exp_result_prenorm_DP);
	always @(posedge Clk_CI or negedge Rst_RBI)
		if (~Rst_RBI)
			Exp_result_prenorm_DP <= 1'sb0;
		else
			Exp_result_prenorm_DP <= Exp_result_prenorm_DN;
	assign Exp_result_prenorm_DO = Exp_result_prenorm_DP;
endmodule
