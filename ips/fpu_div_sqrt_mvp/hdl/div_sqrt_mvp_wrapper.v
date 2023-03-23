module div_sqrt_mvp_wrapper (
	Clk_CI,
	Rst_RBI,
	Div_start_SI,
	Sqrt_start_SI,
	Operand_a_DI,
	Operand_b_DI,
	RM_SI,
	Precision_ctl_SI,
	Format_sel_SI,
	Kill_SI,
	Result_DO,
	Fflags_SO,
	Ready_SO,
	Done_SO
);
	parameter PrePipeline_depth_S = 0;
	parameter PostPipeline_depth_S = 2;
	input wire Clk_CI;
	input wire Rst_RBI;
	input wire Div_start_SI;
	input wire Sqrt_start_SI;
	localparam defs_div_sqrt_mvp_C_OP_FP64 = 64;
	input wire [63:0] Operand_a_DI;
	input wire [63:0] Operand_b_DI;
	localparam defs_div_sqrt_mvp_C_RM = 3;
	input wire [2:0] RM_SI;
	localparam defs_div_sqrt_mvp_C_PC = 6;
	input wire [5:0] Precision_ctl_SI;
	localparam defs_div_sqrt_mvp_C_FS = 2;
	input wire [1:0] Format_sel_SI;
	input wire Kill_SI;
	output wire [63:0] Result_DO;
	output wire [4:0] Fflags_SO;
	output wire Ready_SO;
	output wire Done_SO;
	reg Div_start_S_S;
	reg Sqrt_start_S_S;
	reg [63:0] Operand_a_S_D;
	reg [63:0] Operand_b_S_D;
	reg [2:0] RM_S_S;
	reg [5:0] Precision_ctl_S_S;
	reg [1:0] Format_sel_S_S;
	reg Kill_S_S;
	wire [63:0] Result_D;
	wire Ready_S;
	wire Done_S;
	wire [4:0] Fflags_S;
	generate
		if (PrePipeline_depth_S == 1) begin : genblk1
			div_sqrt_top_mvp div_top_U0(
				.Clk_CI(Clk_CI),
				.Rst_RBI(Rst_RBI),
				.Div_start_SI(Div_start_S_S),
				.Sqrt_start_SI(Sqrt_start_S_S),
				.Operand_a_DI(Operand_a_S_D),
				.Operand_b_DI(Operand_b_S_D),
				.RM_SI(RM_S_S),
				.Precision_ctl_SI(Precision_ctl_S_S),
				.Format_sel_SI(Format_sel_S_S),
				.Kill_SI(Kill_S_S),
				.Result_DO(Result_D),
				.Fflags_SO(Fflags_S),
				.Ready_SO(Ready_S),
				.Done_SO(Done_S)
			);
			always @(posedge Clk_CI or negedge Rst_RBI)
				if (~Rst_RBI) begin
					Div_start_S_S <= 1'sb0;
					Sqrt_start_S_S <= 1'b0;
					Operand_a_S_D <= 1'sb0;
					Operand_b_S_D <= 1'sb0;
					RM_S_S <= 1'b0;
					Precision_ctl_S_S <= 1'sb0;
					Format_sel_S_S <= 1'sb0;
					Kill_S_S <= 1'sb0;
				end
				else begin
					Div_start_S_S <= Div_start_SI;
					Sqrt_start_S_S <= Sqrt_start_SI;
					Operand_a_S_D <= Operand_a_DI;
					Operand_b_S_D <= Operand_b_DI;
					RM_S_S <= RM_SI;
					Precision_ctl_S_S <= Precision_ctl_SI;
					Format_sel_S_S <= Format_sel_SI;
					Kill_S_S <= Kill_SI;
				end
		end
		else begin : genblk1
			div_sqrt_top_mvp div_top_U0(
				.Clk_CI(Clk_CI),
				.Rst_RBI(Rst_RBI),
				.Div_start_SI(Div_start_SI),
				.Sqrt_start_SI(Sqrt_start_SI),
				.Operand_a_DI(Operand_a_DI),
				.Operand_b_DI(Operand_b_DI),
				.RM_SI(RM_SI),
				.Precision_ctl_SI(Precision_ctl_SI),
				.Format_sel_SI(Format_sel_SI),
				.Kill_SI(Kill_SI),
				.Result_DO(Result_D),
				.Fflags_SO(Fflags_S),
				.Ready_SO(Ready_S),
				.Done_SO(Done_S)
			);
		end
	endgenerate
	reg [63:0] Result_dly_S_D;
	reg Ready_dly_S_S;
	reg Done_dly_S_S;
	reg [4:0] Fflags_dly_S_S;
	always @(posedge Clk_CI or negedge Rst_RBI)
		if (~Rst_RBI) begin
			Result_dly_S_D <= 1'sb0;
			Ready_dly_S_S <= 1'b0;
			Done_dly_S_S <= 1'b0;
			Fflags_dly_S_S <= 1'b0;
		end
		else begin
			Result_dly_S_D <= Result_D;
			Ready_dly_S_S <= Ready_S;
			Done_dly_S_S <= Done_S;
			Fflags_dly_S_S <= Fflags_S;
		end
	reg [63:0] Result_dly_D_D;
	reg Ready_dly_D_S;
	reg Done_dly_D_S;
	reg [4:0] Fflags_dly_D_S;
	generate
		if (PostPipeline_depth_S == 2) begin : genblk2
			always @(posedge Clk_CI or negedge Rst_RBI)
				if (~Rst_RBI) begin
					Result_dly_D_D <= 1'sb0;
					Ready_dly_D_S <= 1'b0;
					Done_dly_D_S <= 1'b0;
					Fflags_dly_D_S <= 1'b0;
				end
				else begin
					Result_dly_D_D <= Result_dly_S_D;
					Ready_dly_D_S <= Ready_dly_S_S;
					Done_dly_D_S <= Done_dly_S_S;
					Fflags_dly_D_S <= Fflags_dly_S_S;
				end
			assign Result_DO = Result_dly_D_D;
			assign Ready_SO = Ready_dly_D_S;
			assign Done_SO = Done_dly_D_S;
			assign Fflags_SO = Fflags_dly_D_S;
		end
		else begin : genblk2
			assign Result_DO = Result_dly_S_D;
			assign Ready_SO = Ready_dly_S_S;
			assign Done_SO = Done_dly_S_S;
			assign Fflags_SO = Fflags_dly_S_S;
		end
	endgenerate
endmodule
