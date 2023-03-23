module riscv_alu (
	clk,
	rst_n,
	enable_i,
	operator_i,
	operand_a_i,
	operand_b_i,
	operand_c_i,
	vector_mode_i,
	bmask_a_i,
	bmask_b_i,
	imm_vec_ext_i,
	is_clpx_i,
	is_subrot_i,
	clpx_shift_i,
	result_o,
	comparison_result_o,
	ready_o,
	ex_ready_i
);
	parameter SHARED_INT_DIV = 0;
	parameter FPU = 0;
	input wire clk;
	input wire rst_n;
	input wire enable_i;
	localparam riscv_defines_ALU_OP_WIDTH = 7;
	input wire [6:0] operator_i;
	input wire [31:0] operand_a_i;
	input wire [31:0] operand_b_i;
	input wire [31:0] operand_c_i;
	input wire [1:0] vector_mode_i;
	input wire [4:0] bmask_a_i;
	input wire [4:0] bmask_b_i;
	input wire [1:0] imm_vec_ext_i;
	input wire is_clpx_i;
	input wire is_subrot_i;
	input wire [1:0] clpx_shift_i;
	output reg [31:0] result_o;
	output wire comparison_result_o;
	output wire ready_o;
	input wire ex_ready_i;
	wire [31:0] operand_a_rev;
	wire [31:0] operand_a_neg;
	wire [31:0] operand_a_neg_rev;
	assign operand_a_neg = ~operand_a_i;
	genvar k;
	generate
		for (k = 0; k < 32; k = k + 1) begin : genblk1
			assign operand_a_rev[k] = operand_a_i[31 - k];
		end
	endgenerate
	genvar m;
	generate
		for (m = 0; m < 32; m = m + 1) begin : genblk2
			assign operand_a_neg_rev[m] = operand_a_neg[31 - m];
		end
	endgenerate
	wire [31:0] operand_b_neg;
	assign operand_b_neg = ~operand_b_i;
	wire [5:0] div_shift;
	wire div_valid;
	wire [31:0] bmask;
	wire adder_op_b_negate;
	wire [31:0] adder_op_a;
	wire [31:0] adder_op_b;
	reg [35:0] adder_in_a;
	reg [35:0] adder_in_b;
	wire [31:0] adder_result;
	wire [36:0] adder_result_expanded;
	localparam riscv_defines_ALU_SUB = 7'b0011001;
	localparam riscv_defines_ALU_SUBR = 7'b0011101;
	localparam riscv_defines_ALU_SUBU = 7'b0011011;
	localparam riscv_defines_ALU_SUBUR = 7'b0011111;
	assign adder_op_b_negate = ((((operator_i == riscv_defines_ALU_SUB) || (operator_i == riscv_defines_ALU_SUBR)) || (operator_i == riscv_defines_ALU_SUBU)) || (operator_i == riscv_defines_ALU_SUBUR)) || is_subrot_i;
	localparam riscv_defines_ALU_ABS = 7'b0010100;
	assign adder_op_a = (operator_i == riscv_defines_ALU_ABS ? operand_a_neg : (is_subrot_i ? {operand_b_i[15:0], operand_a_i[31:16]} : operand_a_i));
	assign adder_op_b = (adder_op_b_negate ? (is_subrot_i ? ~{operand_a_i[15:0], operand_b_i[31:16]} : operand_b_neg) : operand_b_i);
	localparam riscv_defines_ALU_CLIP = 7'b0010110;
	localparam riscv_defines_VEC_MODE16 = 2'b10;
	localparam riscv_defines_VEC_MODE8 = 2'b11;
	always @(*) begin
		adder_in_a[0] = 1'b1;
		adder_in_a[8:1] = adder_op_a[7:0];
		adder_in_a[9] = 1'b1;
		adder_in_a[17:10] = adder_op_a[15:8];
		adder_in_a[18] = 1'b1;
		adder_in_a[26:19] = adder_op_a[23:16];
		adder_in_a[27] = 1'b1;
		adder_in_a[35:28] = adder_op_a[31:24];
		adder_in_b[0] = 1'b0;
		adder_in_b[8:1] = adder_op_b[7:0];
		adder_in_b[9] = 1'b0;
		adder_in_b[17:10] = adder_op_b[15:8];
		adder_in_b[18] = 1'b0;
		adder_in_b[26:19] = adder_op_b[23:16];
		adder_in_b[27] = 1'b0;
		adder_in_b[35:28] = adder_op_b[31:24];
		if (adder_op_b_negate || ((operator_i == riscv_defines_ALU_ABS) || (operator_i == riscv_defines_ALU_CLIP))) begin
			adder_in_b[0] = 1'b1;
			case (vector_mode_i)
				riscv_defines_VEC_MODE16: adder_in_b[18] = 1'b1;
				riscv_defines_VEC_MODE8: begin
					adder_in_b[9] = 1'b1;
					adder_in_b[18] = 1'b1;
					adder_in_b[27] = 1'b1;
				end
			endcase
		end
		else
			case (vector_mode_i)
				riscv_defines_VEC_MODE16: adder_in_a[18] = 1'b0;
				riscv_defines_VEC_MODE8: begin
					adder_in_a[9] = 1'b0;
					adder_in_a[18] = 1'b0;
					adder_in_a[27] = 1'b0;
				end
			endcase
	end
	assign adder_result_expanded = $signed(adder_in_a) + $signed(adder_in_b);
	assign adder_result = {adder_result_expanded[35:28], adder_result_expanded[26:19], adder_result_expanded[17:10], adder_result_expanded[8:1]};
	wire [31:0] adder_round_value;
	wire [31:0] adder_round_result;
	localparam riscv_defines_ALU_ADDR = 7'b0011100;
	localparam riscv_defines_ALU_ADDUR = 7'b0011110;
	assign adder_round_value = ((((operator_i == riscv_defines_ALU_ADDR) || (operator_i == riscv_defines_ALU_SUBR)) || (operator_i == riscv_defines_ALU_ADDUR)) || (operator_i == riscv_defines_ALU_SUBUR) ? {1'b0, bmask[31:1]} : {32 {1'sb0}});
	assign adder_round_result = adder_result + adder_round_value;
	wire shift_left;
	wire shift_use_round;
	wire shift_arithmetic;
	reg [31:0] shift_amt_left;
	wire [31:0] shift_amt;
	wire [31:0] shift_amt_int;
	wire [31:0] shift_amt_norm;
	wire [31:0] shift_op_a;
	wire [31:0] shift_result;
	reg [31:0] shift_right_result;
	wire [31:0] shift_left_result;
	wire [15:0] clpx_shift_ex;
	assign shift_amt = (div_valid ? div_shift : operand_b_i);
	always @(*)
		case (vector_mode_i)
			riscv_defines_VEC_MODE16: begin
				shift_amt_left[15:0] = shift_amt[31:16];
				shift_amt_left[31:16] = shift_amt[15:0];
			end
			riscv_defines_VEC_MODE8: begin
				shift_amt_left[7:0] = shift_amt[31:24];
				shift_amt_left[15:8] = shift_amt[23:16];
				shift_amt_left[23:16] = shift_amt[15:8];
				shift_amt_left[31:24] = shift_amt[7:0];
			end
			default: shift_amt_left[31:0] = shift_amt[31:0];
		endcase
	localparam riscv_defines_ALU_BINS = 7'b0101010;
	localparam riscv_defines_ALU_BREV = 7'b1001001;
	localparam riscv_defines_ALU_CLB = 7'b0110101;
	localparam riscv_defines_ALU_DIV = 7'b0110001;
	localparam riscv_defines_ALU_DIVU = 7'b0110000;
	localparam riscv_defines_ALU_FL1 = 7'b0110111;
	localparam riscv_defines_ALU_REM = 7'b0110011;
	localparam riscv_defines_ALU_REMU = 7'b0110010;
	localparam riscv_defines_ALU_SLL = 7'b0100111;
	assign shift_left = ((((((((operator_i == riscv_defines_ALU_SLL) || (operator_i == riscv_defines_ALU_BINS)) || (operator_i == riscv_defines_ALU_FL1)) || (operator_i == riscv_defines_ALU_CLB)) || (operator_i == riscv_defines_ALU_DIV)) || (operator_i == riscv_defines_ALU_DIVU)) || (operator_i == riscv_defines_ALU_REM)) || (operator_i == riscv_defines_ALU_REMU)) || (operator_i == riscv_defines_ALU_BREV);
	localparam riscv_defines_ALU_ADD = 7'b0011000;
	localparam riscv_defines_ALU_ADDU = 7'b0011010;
	assign shift_use_round = (((((((operator_i == riscv_defines_ALU_ADD) || (operator_i == riscv_defines_ALU_SUB)) || (operator_i == riscv_defines_ALU_ADDR)) || (operator_i == riscv_defines_ALU_SUBR)) || (operator_i == riscv_defines_ALU_ADDU)) || (operator_i == riscv_defines_ALU_SUBU)) || (operator_i == riscv_defines_ALU_ADDUR)) || (operator_i == riscv_defines_ALU_SUBUR);
	localparam riscv_defines_ALU_BEXT = 7'b0101000;
	localparam riscv_defines_ALU_SRA = 7'b0100100;
	assign shift_arithmetic = (((((operator_i == riscv_defines_ALU_SRA) || (operator_i == riscv_defines_ALU_BEXT)) || (operator_i == riscv_defines_ALU_ADD)) || (operator_i == riscv_defines_ALU_SUB)) || (operator_i == riscv_defines_ALU_ADDR)) || (operator_i == riscv_defines_ALU_SUBR);
	assign shift_op_a = (shift_left ? operand_a_rev : (shift_use_round ? adder_round_result : operand_a_i));
	assign shift_amt_int = (shift_use_round ? shift_amt_norm : (shift_left ? shift_amt_left : shift_amt));
	assign shift_amt_norm = (is_clpx_i ? {clpx_shift_ex, clpx_shift_ex} : {4 {3'b000, bmask_b_i}});
	assign clpx_shift_ex = $unsigned(clpx_shift_i);
	wire [63:0] shift_op_a_32;
	localparam riscv_defines_ALU_ROR = 7'b0100110;
	assign shift_op_a_32 = (operator_i == riscv_defines_ALU_ROR ? {shift_op_a, shift_op_a} : $signed({{32 {shift_arithmetic & shift_op_a[31]}}, shift_op_a}));
	always @(*)
		case (vector_mode_i)
			riscv_defines_VEC_MODE16: begin
				shift_right_result[31:16] = $signed({shift_arithmetic & shift_op_a[31], shift_op_a[31:16]}) >>> shift_amt_int[19:16];
				shift_right_result[15:0] = $signed({shift_arithmetic & shift_op_a[15], shift_op_a[15:0]}) >>> shift_amt_int[3:0];
			end
			riscv_defines_VEC_MODE8: begin
				shift_right_result[31:24] = $signed({shift_arithmetic & shift_op_a[31], shift_op_a[31:24]}) >>> shift_amt_int[26:24];
				shift_right_result[23:16] = $signed({shift_arithmetic & shift_op_a[23], shift_op_a[23:16]}) >>> shift_amt_int[18:16];
				shift_right_result[15:8] = $signed({shift_arithmetic & shift_op_a[15], shift_op_a[15:8]}) >>> shift_amt_int[10:8];
				shift_right_result[7:0] = $signed({shift_arithmetic & shift_op_a[7], shift_op_a[7:0]}) >>> shift_amt_int[2:0];
			end
			default: shift_right_result = shift_op_a_32 >> shift_amt_int[4:0];
		endcase
	genvar j;
	generate
		for (j = 0; j < 32; j = j + 1) begin : genblk3
			assign shift_left_result[j] = shift_right_result[31 - j];
		end
	endgenerate
	assign shift_result = (shift_left ? shift_left_result : shift_right_result);
	reg [3:0] is_equal;
	reg [3:0] is_greater;
	wire [3:0] f_is_greater;
	reg [3:0] cmp_signed;
	wire [3:0] is_equal_vec;
	wire [3:0] is_greater_vec;
	reg [31:0] operand_b_eq;
	wire is_equal_clip;
	localparam riscv_defines_ALU_CLIPU = 7'b0010111;
	always @(*) begin
		operand_b_eq = operand_b_neg;
		if (operator_i == riscv_defines_ALU_CLIPU)
			operand_b_eq = 1'sb0;
		else
			operand_b_eq = operand_b_neg;
	end
	assign is_equal_clip = operand_a_i == operand_b_eq;
	localparam riscv_defines_ALU_FLE = 7'b1000101;
	localparam riscv_defines_ALU_FLT = 7'b1000100;
	localparam riscv_defines_ALU_FMAX = 7'b1000110;
	localparam riscv_defines_ALU_FMIN = 7'b1000111;
	localparam riscv_defines_ALU_GES = 7'b0001010;
	localparam riscv_defines_ALU_GTS = 7'b0001000;
	localparam riscv_defines_ALU_LES = 7'b0000100;
	localparam riscv_defines_ALU_LTS = 7'b0000000;
	localparam riscv_defines_ALU_MAX = 7'b0010010;
	localparam riscv_defines_ALU_MIN = 7'b0010000;
	localparam riscv_defines_ALU_SLETS = 7'b0000110;
	localparam riscv_defines_ALU_SLTS = 7'b0000010;
	always @(*) begin
		cmp_signed = 4'b0000;
		case (operator_i)
			riscv_defines_ALU_GTS, riscv_defines_ALU_GES, riscv_defines_ALU_LTS, riscv_defines_ALU_LES, riscv_defines_ALU_SLTS, riscv_defines_ALU_SLETS, riscv_defines_ALU_MIN, riscv_defines_ALU_MAX, riscv_defines_ALU_ABS, riscv_defines_ALU_CLIP, riscv_defines_ALU_CLIPU, riscv_defines_ALU_FLE, riscv_defines_ALU_FLT, riscv_defines_ALU_FMAX, riscv_defines_ALU_FMIN:
				case (vector_mode_i)
					riscv_defines_VEC_MODE8: cmp_signed[3:0] = 4'b1111;
					riscv_defines_VEC_MODE16: cmp_signed[3:0] = 4'b1010;
					default: cmp_signed[3:0] = 4'b1000;
				endcase
			default:
				;
		endcase
	end
	genvar i;
	generate
		for (i = 0; i < 4; i = i + 1) begin : genblk4
			assign is_equal_vec[i] = operand_a_i[(8 * i) + 7:8 * i] == operand_b_i[(8 * i) + 7:i * 8];
			assign is_greater_vec[i] = $signed({operand_a_i[(8 * i) + 7] & cmp_signed[i], operand_a_i[(8 * i) + 7:8 * i]}) > $signed({operand_b_i[(8 * i) + 7] & cmp_signed[i], operand_b_i[(8 * i) + 7:i * 8]});
		end
	endgenerate
	always @(*) begin
		is_equal[3:0] = {4 {((is_equal_vec[3] & is_equal_vec[2]) & is_equal_vec[1]) & is_equal_vec[0]}};
		is_greater[3:0] = {4 {is_greater_vec[3] | (is_equal_vec[3] & (is_greater_vec[2] | (is_equal_vec[2] & (is_greater_vec[1] | (is_equal_vec[1] & is_greater_vec[0])))))}};
		case (vector_mode_i)
			riscv_defines_VEC_MODE16: begin
				is_equal[1:0] = {2 {is_equal_vec[0] & is_equal_vec[1]}};
				is_equal[3:2] = {2 {is_equal_vec[2] & is_equal_vec[3]}};
				is_greater[1:0] = {2 {is_greater_vec[1] | (is_equal_vec[1] & is_greater_vec[0])}};
				is_greater[3:2] = {2 {is_greater_vec[3] | (is_equal_vec[3] & is_greater_vec[2])}};
			end
			riscv_defines_VEC_MODE8: begin
				is_equal[3:0] = is_equal_vec[3:0];
				is_greater[3:0] = is_greater_vec[3:0];
			end
			default:
				;
		endcase
	end
	assign f_is_greater[3:0] = {4 {is_greater[3] ^ ((operand_a_i[31] & operand_b_i[31]) & !is_equal[3])}};
	reg [3:0] cmp_result;
	wire f_is_qnan;
	wire f_is_snan;
	reg [3:0] f_is_nan;
	localparam riscv_defines_ALU_EQ = 7'b0001100;
	localparam riscv_defines_ALU_FEQ = 7'b1000011;
	localparam riscv_defines_ALU_GEU = 7'b0001011;
	localparam riscv_defines_ALU_GTU = 7'b0001001;
	localparam riscv_defines_ALU_LEU = 7'b0000101;
	localparam riscv_defines_ALU_LTU = 7'b0000001;
	localparam riscv_defines_ALU_NE = 7'b0001101;
	localparam riscv_defines_ALU_SLETU = 7'b0000111;
	localparam riscv_defines_ALU_SLTU = 7'b0000011;
	always @(*) begin
		cmp_result = is_equal;
		f_is_nan = {4 {f_is_qnan | f_is_snan}};
		case (operator_i)
			riscv_defines_ALU_EQ: cmp_result = is_equal;
			riscv_defines_ALU_NE: cmp_result = ~is_equal;
			riscv_defines_ALU_GTS, riscv_defines_ALU_GTU: cmp_result = is_greater;
			riscv_defines_ALU_GES, riscv_defines_ALU_GEU: cmp_result = is_greater | is_equal;
			riscv_defines_ALU_LTS, riscv_defines_ALU_SLTS, riscv_defines_ALU_LTU, riscv_defines_ALU_SLTU: cmp_result = ~(is_greater | is_equal);
			riscv_defines_ALU_SLETS, riscv_defines_ALU_SLETU, riscv_defines_ALU_LES, riscv_defines_ALU_LEU: cmp_result = ~is_greater;
			riscv_defines_ALU_FEQ: cmp_result = is_equal & ~f_is_nan;
			riscv_defines_ALU_FLE: cmp_result = ~f_is_greater & ~f_is_nan;
			riscv_defines_ALU_FLT: cmp_result = ~(f_is_greater | is_equal) & ~f_is_nan;
			default:
				;
		endcase
	end
	assign comparison_result_o = cmp_result[3];
	wire [31:0] result_minmax;
	wire [31:0] fp_canonical_nan;
	wire [3:0] sel_minmax;
	wire do_min;
	wire minmax_is_fp_special;
	wire [31:0] minmax_b;
	assign minmax_b = (operator_i == riscv_defines_ALU_ABS ? adder_result : operand_b_i);
	localparam riscv_defines_ALU_MINU = 7'b0010001;
	assign do_min = ((((operator_i == riscv_defines_ALU_MIN) || (operator_i == riscv_defines_ALU_MINU)) || (operator_i == riscv_defines_ALU_CLIP)) || (operator_i == riscv_defines_ALU_CLIPU)) || (operator_i == riscv_defines_ALU_FMIN);
	assign sel_minmax[3:0] = ((operator_i == riscv_defines_ALU_FMIN) || (operator_i == riscv_defines_ALU_FMAX) ? f_is_greater : is_greater) ^ {4 {do_min}};
	assign result_minmax[31:24] = (sel_minmax[3] == 1'b1 ? operand_a_i[31:24] : minmax_b[31:24]);
	assign result_minmax[23:16] = (sel_minmax[2] == 1'b1 ? operand_a_i[23:16] : minmax_b[23:16]);
	assign result_minmax[15:8] = (sel_minmax[1] == 1'b1 ? operand_a_i[15:8] : minmax_b[15:8]);
	assign result_minmax[7:0] = (sel_minmax[0] == 1'b1 ? operand_a_i[7:0] : minmax_b[7:0]);
	wire [31:0] fclass_result;
	generate
		if (FPU == 1) begin : genblk5
			wire [7:0] fclass_exponent;
			wire [22:0] fclass_mantiassa;
			wire fclass_ninf;
			wire fclass_pinf;
			wire fclass_normal;
			wire fclass_subnormal;
			wire fclass_nzero;
			wire fclass_pzero;
			wire fclass_is_negative;
			wire fclass_snan_a;
			wire fclass_qnan_a;
			wire fclass_snan_b;
			wire fclass_qnan_b;
			assign fclass_exponent = operand_a_i[30:23];
			assign fclass_mantiassa = operand_a_i[22:0];
			assign fclass_is_negative = operand_a_i[31];
			assign fclass_ninf = operand_a_i == 32'hff800000;
			assign fclass_pinf = operand_a_i == 32'h7f800000;
			assign fclass_normal = (fclass_exponent != 0) && (fclass_exponent != 255);
			assign fclass_subnormal = (fclass_exponent == 0) && (fclass_mantiassa != 0);
			assign fclass_nzero = operand_a_i == 32'h80000000;
			assign fclass_pzero = operand_a_i == 32'h00000000;
			assign fclass_snan_a = operand_a_i[30:0] == 32'h7fa00000;
			assign fclass_qnan_a = operand_a_i[30:0] == 32'h7fc00000;
			assign fclass_snan_b = operand_b_i[30:0] == 32'h7fa00000;
			assign fclass_qnan_b = operand_b_i[30:0] == 32'h7fc00000;
			assign fclass_result[31:0] = {{22 {1'b0}}, fclass_qnan_a, fclass_snan_a, fclass_pinf, fclass_normal && !fclass_is_negative, fclass_subnormal && !fclass_is_negative, fclass_pzero, fclass_nzero, fclass_subnormal && fclass_is_negative, fclass_normal && fclass_is_negative, fclass_ninf};
			assign f_is_qnan = fclass_qnan_a | fclass_qnan_b;
			assign f_is_snan = fclass_snan_a | fclass_snan_b;
			assign minmax_is_fp_special = ((operator_i == riscv_defines_ALU_FMIN) || (operator_i == riscv_defines_ALU_FMAX)) & (f_is_snan | f_is_qnan);
			assign fp_canonical_nan = 32'h7fc00000;
		end
		else begin : genblk5
			assign minmax_is_fp_special = 1'sb0;
			assign f_is_qnan = 1'sb0;
			assign f_is_snan = 1'sb0;
			assign fclass_result = 1'sb0;
			assign fp_canonical_nan = 1'sb0;
		end
	endgenerate
	reg [31:0] f_sign_inject_result;
	localparam riscv_defines_ALU_FKEEP = 7'b1111111;
	localparam riscv_defines_ALU_FSGNJ = 7'b1000000;
	localparam riscv_defines_ALU_FSGNJN = 7'b1000001;
	localparam riscv_defines_ALU_FSGNJX = 7'b1000010;
	always @(*)
		if (FPU == 1) begin
			f_sign_inject_result[30:0] = operand_a_i[30:0];
			f_sign_inject_result[31] = operand_a_i[31];
			case (operator_i)
				riscv_defines_ALU_FKEEP: f_sign_inject_result[31] = operand_a_i[31];
				riscv_defines_ALU_FSGNJ: f_sign_inject_result[31] = operand_b_i[31];
				riscv_defines_ALU_FSGNJN: f_sign_inject_result[31] = !operand_b_i[31];
				riscv_defines_ALU_FSGNJX: f_sign_inject_result[31] = operand_a_i[31] ^ operand_b_i[31];
				default:
					;
			endcase
		end
		else
			f_sign_inject_result = 1'sb0;
	reg [31:0] clip_result;
	always @(*) begin
		clip_result = result_minmax;
		if (operator_i == riscv_defines_ALU_CLIPU) begin
			if (operand_a_i[31] || is_equal_clip)
				clip_result = 1'sb0;
			else
				clip_result = result_minmax;
		end
		else if (adder_result_expanded[36] || is_equal_clip)
			clip_result = operand_b_neg;
		else
			clip_result = result_minmax;
	end
	reg [7:0] shuffle_byte_sel;
	reg [3:0] shuffle_reg_sel;
	reg [1:0] shuffle_reg1_sel;
	reg [1:0] shuffle_reg0_sel;
	reg [3:0] shuffle_through;
	wire [31:0] shuffle_r1;
	wire [31:0] shuffle_r0;
	wire [31:0] shuffle_r1_in;
	wire [31:0] shuffle_r0_in;
	wire [31:0] shuffle_result;
	wire [31:0] pack_result;
	localparam riscv_defines_ALU_EXT = 7'b0111111;
	localparam riscv_defines_ALU_EXTS = 7'b0111110;
	localparam riscv_defines_ALU_INS = 7'b0101101;
	localparam riscv_defines_ALU_PCKHI = 7'b0111001;
	localparam riscv_defines_ALU_PCKLO = 7'b0111000;
	localparam riscv_defines_ALU_SHUF2 = 7'b0111011;
	always @(*) begin
		shuffle_reg_sel = 1'sb0;
		shuffle_reg1_sel = 2'b01;
		shuffle_reg0_sel = 2'b10;
		shuffle_through = 1'sb1;
		case (operator_i)
			riscv_defines_ALU_EXT, riscv_defines_ALU_EXTS: begin
				if (operator_i == riscv_defines_ALU_EXTS)
					shuffle_reg1_sel = 2'b11;
				if (vector_mode_i == riscv_defines_VEC_MODE8) begin
					shuffle_reg_sel[3:1] = 3'b111;
					shuffle_reg_sel[0] = 1'b0;
				end
				else begin
					shuffle_reg_sel[3:2] = 2'b11;
					shuffle_reg_sel[1:0] = 2'b00;
				end
			end
			riscv_defines_ALU_PCKLO: begin
				shuffle_reg1_sel = 2'b00;
				if (vector_mode_i == riscv_defines_VEC_MODE8) begin
					shuffle_through = 4'b0011;
					shuffle_reg_sel = 4'b0001;
				end
				else
					shuffle_reg_sel = 4'b0011;
			end
			riscv_defines_ALU_PCKHI: begin
				shuffle_reg1_sel = 2'b00;
				if (vector_mode_i == riscv_defines_VEC_MODE8) begin
					shuffle_through = 4'b1100;
					shuffle_reg_sel = 4'b0100;
				end
				else
					shuffle_reg_sel = 4'b0011;
			end
			riscv_defines_ALU_SHUF2:
				case (vector_mode_i)
					riscv_defines_VEC_MODE8: begin
						shuffle_reg_sel[3] = ~operand_b_i[26];
						shuffle_reg_sel[2] = ~operand_b_i[18];
						shuffle_reg_sel[1] = ~operand_b_i[10];
						shuffle_reg_sel[0] = ~operand_b_i[2];
					end
					riscv_defines_VEC_MODE16: begin
						shuffle_reg_sel[3] = ~operand_b_i[17];
						shuffle_reg_sel[2] = ~operand_b_i[17];
						shuffle_reg_sel[1] = ~operand_b_i[1];
						shuffle_reg_sel[0] = ~operand_b_i[1];
					end
					default:
						;
				endcase
			riscv_defines_ALU_INS:
				case (vector_mode_i)
					riscv_defines_VEC_MODE8: begin
						shuffle_reg0_sel = 2'b00;
						case (imm_vec_ext_i)
							2'b00: shuffle_reg_sel[3:0] = 4'b1110;
							2'b01: shuffle_reg_sel[3:0] = 4'b1101;
							2'b10: shuffle_reg_sel[3:0] = 4'b1011;
							2'b11: shuffle_reg_sel[3:0] = 4'b0111;
							default:
								;
						endcase
					end
					riscv_defines_VEC_MODE16: begin
						shuffle_reg0_sel = 2'b01;
						shuffle_reg_sel[3] = ~imm_vec_ext_i[0];
						shuffle_reg_sel[2] = ~imm_vec_ext_i[0];
						shuffle_reg_sel[1] = imm_vec_ext_i[0];
						shuffle_reg_sel[0] = imm_vec_ext_i[0];
					end
					default:
						;
				endcase
			default:
				;
		endcase
	end
	localparam riscv_defines_ALU_SHUF = 7'b0111010;
	always @(*) begin
		shuffle_byte_sel = 1'sb0;
		case (operator_i)
			riscv_defines_ALU_EXTS, riscv_defines_ALU_EXT:
				case (vector_mode_i)
					riscv_defines_VEC_MODE8: begin
						shuffle_byte_sel[6+:2] = imm_vec_ext_i[1:0];
						shuffle_byte_sel[4+:2] = imm_vec_ext_i[1:0];
						shuffle_byte_sel[2+:2] = imm_vec_ext_i[1:0];
						shuffle_byte_sel[0+:2] = imm_vec_ext_i[1:0];
					end
					riscv_defines_VEC_MODE16: begin
						shuffle_byte_sel[6+:2] = {imm_vec_ext_i[0], 1'b1};
						shuffle_byte_sel[4+:2] = {imm_vec_ext_i[0], 1'b1};
						shuffle_byte_sel[2+:2] = {imm_vec_ext_i[0], 1'b1};
						shuffle_byte_sel[0+:2] = {imm_vec_ext_i[0], 1'b0};
					end
					default:
						;
				endcase
			riscv_defines_ALU_PCKLO:
				case (vector_mode_i)
					riscv_defines_VEC_MODE8: begin
						shuffle_byte_sel[6+:2] = 2'b00;
						shuffle_byte_sel[4+:2] = 2'b00;
						shuffle_byte_sel[2+:2] = 2'b00;
						shuffle_byte_sel[0+:2] = 2'b00;
					end
					riscv_defines_VEC_MODE16: begin
						shuffle_byte_sel[6+:2] = 2'b01;
						shuffle_byte_sel[4+:2] = 2'b00;
						shuffle_byte_sel[2+:2] = 2'b01;
						shuffle_byte_sel[0+:2] = 2'b00;
					end
					default:
						;
				endcase
			riscv_defines_ALU_PCKHI:
				case (vector_mode_i)
					riscv_defines_VEC_MODE8: begin
						shuffle_byte_sel[6+:2] = 2'b00;
						shuffle_byte_sel[4+:2] = 2'b00;
						shuffle_byte_sel[2+:2] = 2'b00;
						shuffle_byte_sel[0+:2] = 2'b00;
					end
					riscv_defines_VEC_MODE16: begin
						shuffle_byte_sel[6+:2] = 2'b11;
						shuffle_byte_sel[4+:2] = 2'b10;
						shuffle_byte_sel[2+:2] = 2'b11;
						shuffle_byte_sel[0+:2] = 2'b10;
					end
					default:
						;
				endcase
			riscv_defines_ALU_SHUF2, riscv_defines_ALU_SHUF:
				case (vector_mode_i)
					riscv_defines_VEC_MODE8: begin
						shuffle_byte_sel[6+:2] = operand_b_i[25:24];
						shuffle_byte_sel[4+:2] = operand_b_i[17:16];
						shuffle_byte_sel[2+:2] = operand_b_i[9:8];
						shuffle_byte_sel[0+:2] = operand_b_i[1:0];
					end
					riscv_defines_VEC_MODE16: begin
						shuffle_byte_sel[6+:2] = {operand_b_i[16], 1'b1};
						shuffle_byte_sel[4+:2] = {operand_b_i[16], 1'b0};
						shuffle_byte_sel[2+:2] = {operand_b_i[0], 1'b1};
						shuffle_byte_sel[0+:2] = {operand_b_i[0], 1'b0};
					end
					default:
						;
				endcase
			riscv_defines_ALU_INS: begin
				shuffle_byte_sel[6+:2] = 2'b11;
				shuffle_byte_sel[4+:2] = 2'b10;
				shuffle_byte_sel[2+:2] = 2'b01;
				shuffle_byte_sel[0+:2] = 2'b00;
			end
			default:
				;
		endcase
	end
	assign shuffle_r0_in = (shuffle_reg0_sel[1] ? operand_a_i : (shuffle_reg0_sel[0] ? {2 {operand_a_i[15:0]}} : {4 {operand_a_i[7:0]}}));
	assign shuffle_r1_in = (shuffle_reg1_sel[1] ? {{8 {operand_a_i[31]}}, {8 {operand_a_i[23]}}, {8 {operand_a_i[15]}}, {8 {operand_a_i[7]}}} : (shuffle_reg1_sel[0] ? operand_c_i : operand_b_i));
	assign shuffle_r0[31:24] = (shuffle_byte_sel[7] ? (shuffle_byte_sel[6] ? shuffle_r0_in[31:24] : shuffle_r0_in[23:16]) : (shuffle_byte_sel[6] ? shuffle_r0_in[15:8] : shuffle_r0_in[7:0]));
	assign shuffle_r0[23:16] = (shuffle_byte_sel[5] ? (shuffle_byte_sel[4] ? shuffle_r0_in[31:24] : shuffle_r0_in[23:16]) : (shuffle_byte_sel[4] ? shuffle_r0_in[15:8] : shuffle_r0_in[7:0]));
	assign shuffle_r0[15:8] = (shuffle_byte_sel[3] ? (shuffle_byte_sel[2] ? shuffle_r0_in[31:24] : shuffle_r0_in[23:16]) : (shuffle_byte_sel[2] ? shuffle_r0_in[15:8] : shuffle_r0_in[7:0]));
	assign shuffle_r0[7:0] = (shuffle_byte_sel[1] ? (shuffle_byte_sel[0] ? shuffle_r0_in[31:24] : shuffle_r0_in[23:16]) : (shuffle_byte_sel[0] ? shuffle_r0_in[15:8] : shuffle_r0_in[7:0]));
	assign shuffle_r1[31:24] = (shuffle_byte_sel[7] ? (shuffle_byte_sel[6] ? shuffle_r1_in[31:24] : shuffle_r1_in[23:16]) : (shuffle_byte_sel[6] ? shuffle_r1_in[15:8] : shuffle_r1_in[7:0]));
	assign shuffle_r1[23:16] = (shuffle_byte_sel[5] ? (shuffle_byte_sel[4] ? shuffle_r1_in[31:24] : shuffle_r1_in[23:16]) : (shuffle_byte_sel[4] ? shuffle_r1_in[15:8] : shuffle_r1_in[7:0]));
	assign shuffle_r1[15:8] = (shuffle_byte_sel[3] ? (shuffle_byte_sel[2] ? shuffle_r1_in[31:24] : shuffle_r1_in[23:16]) : (shuffle_byte_sel[2] ? shuffle_r1_in[15:8] : shuffle_r1_in[7:0]));
	assign shuffle_r1[7:0] = (shuffle_byte_sel[1] ? (shuffle_byte_sel[0] ? shuffle_r1_in[31:24] : shuffle_r1_in[23:16]) : (shuffle_byte_sel[0] ? shuffle_r1_in[15:8] : shuffle_r1_in[7:0]));
	assign shuffle_result[31:24] = (shuffle_reg_sel[3] ? shuffle_r1[31:24] : shuffle_r0[31:24]);
	assign shuffle_result[23:16] = (shuffle_reg_sel[2] ? shuffle_r1[23:16] : shuffle_r0[23:16]);
	assign shuffle_result[15:8] = (shuffle_reg_sel[1] ? shuffle_r1[15:8] : shuffle_r0[15:8]);
	assign shuffle_result[7:0] = (shuffle_reg_sel[0] ? shuffle_r1[7:0] : shuffle_r0[7:0]);
	assign pack_result[31:24] = (shuffle_through[3] ? shuffle_result[31:24] : operand_c_i[31:24]);
	assign pack_result[23:16] = (shuffle_through[2] ? shuffle_result[23:16] : operand_c_i[23:16]);
	assign pack_result[15:8] = (shuffle_through[1] ? shuffle_result[15:8] : operand_c_i[15:8]);
	assign pack_result[7:0] = (shuffle_through[0] ? shuffle_result[7:0] : operand_c_i[7:0]);
	reg [31:0] ff_input;
	wire [5:0] cnt_result;
	wire [5:0] clb_result;
	wire [4:0] ff1_result;
	wire ff_no_one;
	wire [4:0] fl1_result;
	reg [5:0] bitop_result;
	alu_popcnt alu_popcnt_i(
		.in_i(operand_a_i),
		.result_o(cnt_result)
	);
	localparam riscv_defines_ALU_FF1 = 7'b0110110;
	always @(*) begin
		ff_input = 1'sb0;
		case (operator_i)
			riscv_defines_ALU_FF1: ff_input = operand_a_i;
			riscv_defines_ALU_DIVU, riscv_defines_ALU_REMU, riscv_defines_ALU_FL1: ff_input = operand_a_rev;
			riscv_defines_ALU_DIV, riscv_defines_ALU_REM, riscv_defines_ALU_CLB:
				if (operand_a_i[31])
					ff_input = operand_a_neg_rev;
				else
					ff_input = operand_a_rev;
		endcase
	end
	alu_ff alu_ff_i(
		.in_i(ff_input),
		.first_one_o(ff1_result),
		.no_ones_o(ff_no_one)
	);
	assign fl1_result = 5'd31 - ff1_result;
	assign clb_result = ff1_result - 5'd1;
	localparam riscv_defines_ALU_CNT = 7'b0110100;
	always @(*) begin
		bitop_result = 1'sb0;
		case (operator_i)
			riscv_defines_ALU_FF1: bitop_result = (ff_no_one ? 6'd32 : {1'b0, ff1_result});
			riscv_defines_ALU_FL1: bitop_result = (ff_no_one ? 6'd32 : {1'b0, fl1_result});
			riscv_defines_ALU_CNT: bitop_result = cnt_result;
			riscv_defines_ALU_CLB:
				if (ff_no_one) begin
					if (operand_a_i[31])
						bitop_result = 6'd31;
					else
						bitop_result = 1'sb0;
				end
				else
					bitop_result = clb_result;
			default:
				;
		endcase
	end
	wire extract_is_signed;
	wire extract_sign;
	wire [31:0] bmask_first;
	wire [31:0] bmask_inv;
	wire [31:0] bextins_and;
	wire [31:0] bextins_result;
	wire [31:0] bclr_result;
	wire [31:0] bset_result;
	assign bmask_first = 32'hfffffffe << bmask_a_i;
	assign bmask = ~bmask_first << bmask_b_i;
	assign bmask_inv = ~bmask;
	assign bextins_and = (operator_i == riscv_defines_ALU_BINS ? operand_c_i : {32 {extract_sign}});
	assign extract_is_signed = operator_i == riscv_defines_ALU_BEXT;
	assign extract_sign = extract_is_signed & shift_result[bmask_a_i];
	assign bextins_result = (bmask & shift_result) | (bextins_and & bmask_inv);
	assign bclr_result = operand_a_i & bmask_inv;
	assign bset_result = operand_a_i | bmask;
	wire [31:0] radix_2_rev;
	wire [31:0] radix_4_rev;
	wire [31:0] radix_8_rev;
	reg [31:0] reverse_result;
	wire [1:0] radix_mux_sel;
	assign radix_mux_sel = bmask_a_i[1:0];
	generate
		for (j = 0; j < 32; j = j + 1) begin : genblk6
			assign radix_2_rev[j] = shift_result[31 - j];
		end
		for (j = 0; j < 16; j = j + 1) begin : genblk7
			assign radix_4_rev[(2 * j) + 1:2 * j] = shift_result[31 - (j * 2):(31 - (j * 2)) - 1];
		end
		for (j = 0; j < 10; j = j + 1) begin : genblk8
			assign radix_8_rev[(3 * j) + 2:3 * j] = shift_result[31 - (j * 3):(31 - (j * 3)) - 2];
		end
	endgenerate
	assign radix_8_rev[31:30] = 2'b00;
	always @(*) begin
		reverse_result = 1'sb0;
		case (radix_mux_sel)
			2'b00: reverse_result = radix_2_rev;
			2'b01: reverse_result = radix_4_rev;
			2'b10: reverse_result = radix_8_rev;
			default: reverse_result = radix_2_rev;
		endcase
	end
	wire [31:0] result_div;
	wire div_ready;
	generate
		if (SHARED_INT_DIV == 1) begin : genblk9
			assign result_div = 1'sb0;
			assign div_ready = 1'sb1;
			assign div_valid = 1'sb0;
		end
		else begin : int_div
			wire div_signed;
			wire div_op_a_signed;
			wire div_op_b_signed;
			wire [5:0] div_shift_int;
			assign div_signed = operator_i[0];
			assign div_op_a_signed = operand_a_i[31] & div_signed;
			assign div_op_b_signed = operand_b_i[31] & div_signed;
			assign div_shift_int = (ff_no_one ? 6'd31 : clb_result);
			assign div_shift = div_shift_int + (div_op_a_signed ? 6'd0 : 6'd1);
			assign div_valid = enable_i & ((((operator_i == riscv_defines_ALU_DIV) || (operator_i == riscv_defines_ALU_DIVU)) || (operator_i == riscv_defines_ALU_REM)) || (operator_i == riscv_defines_ALU_REMU));
			riscv_alu_div div_i(
				.Clk_CI(clk),
				.Rst_RBI(rst_n),
				.OpA_DI(operand_b_i),
				.OpB_DI(shift_left_result),
				.OpBShift_DI(div_shift),
				.OpBIsZero_SI(cnt_result == 0),
				.OpBSign_SI(div_op_a_signed),
				.OpCode_SI(operator_i[1:0]),
				.Res_DO(result_div),
				.InVld_SI(div_valid),
				.OutRdy_SI(ex_ready_i),
				.OutVld_SO(div_ready)
			);
		end
	endgenerate
	localparam riscv_defines_ALU_AND = 7'b0010101;
	localparam riscv_defines_ALU_BCLR = 7'b0101011;
	localparam riscv_defines_ALU_BEXTU = 7'b0101001;
	localparam riscv_defines_ALU_BSET = 7'b0101100;
	localparam riscv_defines_ALU_FCLASS = 7'b1001000;
	localparam riscv_defines_ALU_MAXU = 7'b0010011;
	localparam riscv_defines_ALU_OR = 7'b0101110;
	localparam riscv_defines_ALU_SRL = 7'b0100101;
	localparam riscv_defines_ALU_XOR = 7'b0101111;
	always @(*) begin
		result_o = 1'sb0;
		case (operator_i)
			riscv_defines_ALU_AND: result_o = operand_a_i & operand_b_i;
			riscv_defines_ALU_OR: result_o = operand_a_i | operand_b_i;
			riscv_defines_ALU_XOR: result_o = operand_a_i ^ operand_b_i;
			riscv_defines_ALU_ADD, riscv_defines_ALU_ADDR, riscv_defines_ALU_ADDU, riscv_defines_ALU_ADDUR, riscv_defines_ALU_SUB, riscv_defines_ALU_SUBR, riscv_defines_ALU_SUBU, riscv_defines_ALU_SUBUR, riscv_defines_ALU_SLL, riscv_defines_ALU_SRL, riscv_defines_ALU_SRA, riscv_defines_ALU_ROR: result_o = shift_result;
			riscv_defines_ALU_BINS, riscv_defines_ALU_BEXT, riscv_defines_ALU_BEXTU: result_o = bextins_result;
			riscv_defines_ALU_BCLR: result_o = bclr_result;
			riscv_defines_ALU_BSET: result_o = bset_result;
			riscv_defines_ALU_BREV: result_o = reverse_result;
			riscv_defines_ALU_SHUF, riscv_defines_ALU_SHUF2, riscv_defines_ALU_PCKLO, riscv_defines_ALU_PCKHI, riscv_defines_ALU_EXT, riscv_defines_ALU_EXTS, riscv_defines_ALU_INS: result_o = pack_result;
			riscv_defines_ALU_MIN, riscv_defines_ALU_MINU, riscv_defines_ALU_MAX, riscv_defines_ALU_MAXU, riscv_defines_ALU_FMIN, riscv_defines_ALU_FMAX: result_o = (minmax_is_fp_special ? fp_canonical_nan : result_minmax);
			riscv_defines_ALU_ABS: result_o = (is_clpx_i ? {adder_result[31:16], operand_a_i[15:0]} : result_minmax);
			riscv_defines_ALU_CLIP, riscv_defines_ALU_CLIPU: result_o = clip_result;
			riscv_defines_ALU_EQ, riscv_defines_ALU_NE, riscv_defines_ALU_GTU, riscv_defines_ALU_GEU, riscv_defines_ALU_LTU, riscv_defines_ALU_LEU, riscv_defines_ALU_GTS, riscv_defines_ALU_GES, riscv_defines_ALU_LTS, riscv_defines_ALU_LES: begin
				result_o[31:24] = {8 {cmp_result[3]}};
				result_o[23:16] = {8 {cmp_result[2]}};
				result_o[15:8] = {8 {cmp_result[1]}};
				result_o[7:0] = {8 {cmp_result[0]}};
			end
			riscv_defines_ALU_FEQ, riscv_defines_ALU_FLT, riscv_defines_ALU_FLE, riscv_defines_ALU_SLTS, riscv_defines_ALU_SLTU, riscv_defines_ALU_SLETS, riscv_defines_ALU_SLETU: result_o = {31'b0000000000000000000000000000000, comparison_result_o};
			riscv_defines_ALU_FF1, riscv_defines_ALU_FL1, riscv_defines_ALU_CLB, riscv_defines_ALU_CNT: result_o = {26'h0000000, bitop_result[5:0]};
			riscv_defines_ALU_DIV, riscv_defines_ALU_DIVU, riscv_defines_ALU_REM, riscv_defines_ALU_REMU: result_o = result_div;
			riscv_defines_ALU_FCLASS: result_o = fclass_result;
			riscv_defines_ALU_FSGNJ, riscv_defines_ALU_FSGNJN, riscv_defines_ALU_FSGNJX, riscv_defines_ALU_FKEEP: result_o = f_sign_inject_result;
			default:
				;
		endcase
	end
	assign ready_o = div_ready;
endmodule
module alu_ff (
	in_i,
	first_one_o,
	no_ones_o
);
	parameter LEN = 32;
	input wire [LEN - 1:0] in_i;
	output wire [$clog2(LEN) - 1:0] first_one_o;
	output wire no_ones_o;
	localparam NUM_LEVELS = $clog2(LEN);
	wire [(LEN * NUM_LEVELS) - 1:0] index_lut;
	wire [(2 ** NUM_LEVELS) - 1:0] sel_nodes;
	wire [((2 ** NUM_LEVELS) * NUM_LEVELS) - 1:0] index_nodes;
	genvar j;
	generate
		for (j = 0; j < LEN; j = j + 1) begin : genblk1
			assign index_lut[j * NUM_LEVELS+:NUM_LEVELS] = $unsigned(j);
		end
	endgenerate
	genvar k;
	genvar l;
	genvar level;
	generate
		for (level = 0; level < NUM_LEVELS; level = level + 1) begin : genblk2
			if (level < (NUM_LEVELS - 1)) begin : genblk1
				for (l = 0; l < (2 ** level); l = l + 1) begin : genblk1
					assign sel_nodes[((2 ** level) - 1) + l] = sel_nodes[((2 ** (level + 1)) - 1) + (l * 2)] | sel_nodes[(((2 ** (level + 1)) - 1) + (l * 2)) + 1];
					assign index_nodes[(((2 ** level) - 1) + l) * NUM_LEVELS+:NUM_LEVELS] = (sel_nodes[((2 ** (level + 1)) - 1) + (l * 2)] == 1'b1 ? index_nodes[(((2 ** (level + 1)) - 1) + (l * 2)) * NUM_LEVELS+:NUM_LEVELS] : index_nodes[((((2 ** (level + 1)) - 1) + (l * 2)) + 1) * NUM_LEVELS+:NUM_LEVELS]);
				end
			end
			if (level == (NUM_LEVELS - 1)) begin : genblk2
				for (k = 0; k < (2 ** level); k = k + 1) begin : genblk1
					if ((k * 2) < (LEN - 1)) begin : genblk1
						assign sel_nodes[((2 ** level) - 1) + k] = in_i[k * 2] | in_i[(k * 2) + 1];
						assign index_nodes[(((2 ** level) - 1) + k) * NUM_LEVELS+:NUM_LEVELS] = (in_i[k * 2] == 1'b1 ? index_lut[(k * 2) * NUM_LEVELS+:NUM_LEVELS] : index_lut[((k * 2) + 1) * NUM_LEVELS+:NUM_LEVELS]);
					end
					if ((k * 2) == (LEN - 1)) begin : genblk2
						assign sel_nodes[((2 ** level) - 1) + k] = in_i[k * 2];
						assign index_nodes[(((2 ** level) - 1) + k) * NUM_LEVELS+:NUM_LEVELS] = index_lut[(k * 2) * NUM_LEVELS+:NUM_LEVELS];
					end
					if ((k * 2) > (LEN - 1)) begin : genblk3
						assign sel_nodes[((2 ** level) - 1) + k] = 1'b0;
						assign index_nodes[(((2 ** level) - 1) + k) * NUM_LEVELS+:NUM_LEVELS] = 1'sb0;
					end
				end
			end
		end
	endgenerate
	assign first_one_o = index_nodes[0+:NUM_LEVELS];
	assign no_ones_o = ~sel_nodes[0];
endmodule
module alu_popcnt (
	in_i,
	result_o
);
	input wire [31:0] in_i;
	output wire [5:0] result_o;
	wire [31:0] cnt_l1;
	wire [23:0] cnt_l2;
	wire [15:0] cnt_l3;
	wire [9:0] cnt_l4;
	genvar l;
	genvar m;
	genvar n;
	genvar p;
	generate
		for (l = 0; l < 16; l = l + 1) begin : genblk1
			assign cnt_l1[l * 2+:2] = {1'b0, in_i[2 * l]} + {1'b0, in_i[(2 * l) + 1]};
		end
		for (m = 0; m < 8; m = m + 1) begin : genblk2
			assign cnt_l2[m * 3+:3] = {1'b0, cnt_l1[(2 * m) * 2+:2]} + {1'b0, cnt_l1[((2 * m) + 1) * 2+:2]};
		end
		for (n = 0; n < 4; n = n + 1) begin : genblk3
			assign cnt_l3[n * 4+:4] = {1'b0, cnt_l2[(2 * n) * 3+:3]} + {1'b0, cnt_l2[((2 * n) + 1) * 3+:3]};
		end
		for (p = 0; p < 2; p = p + 1) begin : genblk4
			assign cnt_l4[p * 5+:5] = {1'b0, cnt_l3[(2 * p) * 4+:4]} + {1'b0, cnt_l3[((2 * p) + 1) * 4+:4]};
		end
	endgenerate
	assign result_o = {1'b0, cnt_l4[0+:5]} + {1'b0, cnt_l4[5+:5]};
endmodule
