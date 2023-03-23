module riscv_alu_basic (
	clk,
	rst_n,
	operator_i,
	operand_a_i,
	operand_b_i,
	operand_c_i,
	vector_mode_i,
	bmask_a_i,
	bmask_b_i,
	imm_vec_ext_i,
	result_o,
	comparison_result_o,
	ready_o,
	ex_ready_i
);
	input wire clk;
	input wire rst_n;
	localparam riscv_defines_ALU_OP_WIDTH = 7;
	input wire [6:0] operator_i;
	input wire [31:0] operand_a_i;
	input wire [31:0] operand_b_i;
	input wire [31:0] operand_c_i;
	input wire [1:0] vector_mode_i;
	input wire [4:0] bmask_a_i;
	input wire [4:0] bmask_b_i;
	input wire [1:0] imm_vec_ext_i;
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
	wire [31:0] bmask;
	wire adder_op_b_negate;
	wire [31:0] adder_op_a;
	wire [31:0] adder_op_b;
	wire [35:0] adder_in_a;
	wire [35:0] adder_in_b;
	wire [31:0] adder_result;
	wire [35:0] adder_result_expanded;
	localparam riscv_defines_ALU_SUB = 7'b0011001;
	localparam riscv_defines_ALU_SUBR = 7'b0011101;
	localparam riscv_defines_ALU_SUBU = 7'b0011011;
	assign adder_op_b_negate = (((operator_i == riscv_defines_ALU_SUB) || (operator_i == riscv_defines_ALU_SUBR)) || (operator_i == riscv_defines_ALU_SUBU)) || (operator_i == riscv_defines_ALU_SUBR);
	localparam riscv_defines_ALU_ABS = 7'b0010100;
	assign adder_op_a = (operator_i == riscv_defines_ALU_ABS ? operand_a_neg : operand_a_i);
	assign adder_op_b = (adder_op_b_negate ? operand_b_neg : operand_b_i);
	assign adder_result = (adder_op_a + adder_op_b) + adder_op_b_negate;
	wire shift_left;
	wire shift_arithmetic;
	wire [31:0] shift_amt_left;
	wire [31:0] shift_amt;
	wire [31:0] shift_amt_int;
	wire [31:0] shift_op_a;
	wire [32:0] shift_op_a_ext;
	wire [31:0] shift_result;
	wire [31:0] shift_right_result;
	wire [31:0] shift_left_result;
	assign shift_amt = operand_b_i;
	assign shift_amt_left[31:0] = shift_amt[31:0];
	localparam riscv_defines_ALU_SLL = 7'b0100111;
	assign shift_left = operator_i == riscv_defines_ALU_SLL;
	localparam riscv_defines_ALU_SRA = 7'b0100100;
	assign shift_arithmetic = operator_i == riscv_defines_ALU_SRA;
	assign shift_op_a = (shift_left ? operand_a_rev : operand_a_i);
	assign shift_amt_int = (shift_left ? shift_amt_left : shift_amt);
	assign shift_op_a_ext = (shift_arithmetic ? {shift_op_a[31], shift_op_a} : {1'b0, shift_op_a});
	assign shift_right_result = $signed(shift_op_a_ext) >>> shift_amt_int[4:0];
	genvar j;
	generate
		for (j = 0; j < 32; j = j + 1) begin : genblk3
			assign shift_left_result[j] = shift_right_result[31 - j];
		end
	endgenerate
	assign shift_result = (shift_left ? shift_left_result : shift_right_result);
	reg [3:0] is_equal;
	reg [3:0] is_greater;
	reg [3:0] cmp_signed;
	wire [3:0] is_equal_vec;
	wire [3:0] is_greater_vec;
	localparam riscv_defines_ALU_CLIP = 7'b0010110;
	localparam riscv_defines_ALU_CLIPU = 7'b0010111;
	localparam riscv_defines_ALU_GES = 7'b0001010;
	localparam riscv_defines_ALU_GTS = 7'b0001000;
	localparam riscv_defines_ALU_LES = 7'b0000100;
	localparam riscv_defines_ALU_LTS = 7'b0000000;
	localparam riscv_defines_ALU_MAX = 7'b0010010;
	localparam riscv_defines_ALU_MIN = 7'b0010000;
	localparam riscv_defines_ALU_SLETS = 7'b0000110;
	localparam riscv_defines_ALU_SLTS = 7'b0000010;
	localparam riscv_defines_VEC_MODE16 = 2'b10;
	localparam riscv_defines_VEC_MODE8 = 2'b11;
	always @(*) begin
		cmp_signed = 4'b0000;
		case (operator_i)
			riscv_defines_ALU_GTS, riscv_defines_ALU_GES, riscv_defines_ALU_LTS, riscv_defines_ALU_LES, riscv_defines_ALU_SLTS, riscv_defines_ALU_SLETS, riscv_defines_ALU_MIN, riscv_defines_ALU_MAX, riscv_defines_ALU_ABS, riscv_defines_ALU_CLIP, riscv_defines_ALU_CLIPU:
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
	reg [3:0] cmp_result;
	localparam riscv_defines_ALU_EQ = 7'b0001100;
	localparam riscv_defines_ALU_GEU = 7'b0001011;
	localparam riscv_defines_ALU_GTU = 7'b0001001;
	localparam riscv_defines_ALU_LEU = 7'b0000101;
	localparam riscv_defines_ALU_LTU = 7'b0000001;
	localparam riscv_defines_ALU_NE = 7'b0001101;
	localparam riscv_defines_ALU_SLETU = 7'b0000111;
	localparam riscv_defines_ALU_SLTU = 7'b0000011;
	always @(*) begin
		cmp_result = is_equal;
		case (operator_i)
			riscv_defines_ALU_EQ: cmp_result = is_equal;
			riscv_defines_ALU_NE: cmp_result = ~is_equal;
			riscv_defines_ALU_GTS, riscv_defines_ALU_GTU: cmp_result = is_greater;
			riscv_defines_ALU_GES, riscv_defines_ALU_GEU: cmp_result = is_greater | is_equal;
			riscv_defines_ALU_LTS, riscv_defines_ALU_SLTS, riscv_defines_ALU_LTU, riscv_defines_ALU_SLTU: cmp_result = ~(is_greater | is_equal);
			riscv_defines_ALU_SLETS, riscv_defines_ALU_SLETU, riscv_defines_ALU_LES, riscv_defines_ALU_LEU: cmp_result = ~is_greater;
			default:
				;
		endcase
	end
	assign comparison_result_o = cmp_result[3];
	localparam riscv_defines_ALU_ADD = 7'b0011000;
	localparam riscv_defines_ALU_AND = 7'b0010101;
	localparam riscv_defines_ALU_OR = 7'b0101110;
	localparam riscv_defines_ALU_SRL = 7'b0100101;
	localparam riscv_defines_ALU_XOR = 7'b0101111;
	always @(*) begin
		result_o = 1'sbx;
		case (operator_i)
			riscv_defines_ALU_AND: result_o = operand_a_i & operand_b_i;
			riscv_defines_ALU_OR: result_o = operand_a_i | operand_b_i;
			riscv_defines_ALU_XOR: result_o = operand_a_i ^ operand_b_i;
			riscv_defines_ALU_ADD, riscv_defines_ALU_SUB: result_o = adder_result;
			riscv_defines_ALU_SLL, riscv_defines_ALU_SRL, riscv_defines_ALU_SRA: result_o = shift_result;
			riscv_defines_ALU_EQ, riscv_defines_ALU_NE, riscv_defines_ALU_GTU, riscv_defines_ALU_GEU, riscv_defines_ALU_LTU, riscv_defines_ALU_LEU, riscv_defines_ALU_GTS, riscv_defines_ALU_GES, riscv_defines_ALU_LTS, riscv_defines_ALU_LES: begin
				result_o[31:24] = {8 {cmp_result[3]}};
				result_o[23:16] = {8 {cmp_result[2]}};
				result_o[15:8] = {8 {cmp_result[1]}};
				result_o[7:0] = {8 {cmp_result[0]}};
			end
			riscv_defines_ALU_SLTS, riscv_defines_ALU_SLTU, riscv_defines_ALU_SLETS, riscv_defines_ALU_SLETU: result_o = {31'b0000000000000000000000000000000, comparison_result_o};
			default:
				$warning("instruction not supported in basic alu");
		endcase
	end
	assign ready_o = 1'b1;
endmodule
