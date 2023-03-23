module riscv_decoder (
	deassert_we_i,
	data_misaligned_i,
	mult_multicycle_i,
	instr_multicycle_o,
	illegal_insn_o,
	ebrk_insn_o,
	mret_insn_o,
	uret_insn_o,
	dret_insn_o,
	mret_dec_o,
	uret_dec_o,
	dret_dec_o,
	ecall_insn_o,
	pipe_flush_o,
	fencei_insn_o,
	rega_used_o,
	regb_used_o,
	regc_used_o,
	reg_fp_a_o,
	reg_fp_b_o,
	reg_fp_c_o,
	reg_fp_d_o,
	bmask_a_mux_o,
	bmask_b_mux_o,
	alu_bmask_a_mux_sel_o,
	alu_bmask_b_mux_sel_o,
	instr_rdata_i,
	illegal_c_insn_i,
	alu_en_o,
	alu_operator_o,
	alu_op_a_mux_sel_o,
	alu_op_b_mux_sel_o,
	alu_op_c_mux_sel_o,
	alu_vec_mode_o,
	scalar_replication_o,
	scalar_replication_c_o,
	imm_a_mux_sel_o,
	imm_b_mux_sel_o,
	regc_mux_o,
	is_clpx_o,
	is_subrot_o,
	mult_operator_o,
	mult_int_en_o,
	mult_dot_en_o,
	mult_imm_mux_o,
	mult_sel_subword_o,
	mult_signed_mode_o,
	mult_dot_signed_o,
	frm_i,
	fpu_dst_fmt_o,
	fpu_src_fmt_o,
	fpu_int_fmt_o,
	apu_en_o,
	apu_type_o,
	apu_op_o,
	apu_lat_o,
	apu_flags_src_o,
	fp_rnd_mode_o,
	regfile_mem_we_o,
	regfile_alu_we_o,
	regfile_alu_we_dec_o,
	regfile_alu_waddr_sel_o,
	csr_access_o,
	csr_status_o,
	csr_op_o,
	current_priv_lvl_i,
	data_req_o,
	data_we_o,
	prepost_useincr_o,
	data_type_o,
	data_sign_extension_o,
	data_reg_offset_o,
	data_load_event_o,
	hwloop_we_o,
	hwloop_target_mux_sel_o,
	hwloop_start_mux_sel_o,
	hwloop_cnt_mux_sel_o,
	jump_in_dec_o,
	jump_in_id_o,
	jump_target_mux_sel_o
);
	parameter FPU = 0;
	parameter FP_DIVSQRT = 0;
	parameter PULP_SECURE = 0;
	parameter SHARED_FP = 0;
	parameter SHARED_DSP_MULT = 0;
	parameter SHARED_INT_MULT = 0;
	parameter SHARED_INT_DIV = 0;
	parameter SHARED_FP_DIVSQRT = 0;
	parameter WAPUTYPE = 1;
	parameter APU_WOP_CPU = 6;
	input wire deassert_we_i;
	input wire data_misaligned_i;
	input wire mult_multicycle_i;
	output reg instr_multicycle_o;
	output reg illegal_insn_o;
	output reg ebrk_insn_o;
	output reg mret_insn_o;
	output reg uret_insn_o;
	output reg dret_insn_o;
	output reg mret_dec_o;
	output reg uret_dec_o;
	output reg dret_dec_o;
	output reg ecall_insn_o;
	output reg pipe_flush_o;
	output reg fencei_insn_o;
	output reg rega_used_o;
	output reg regb_used_o;
	output reg regc_used_o;
	output reg reg_fp_a_o;
	output reg reg_fp_b_o;
	output reg reg_fp_c_o;
	output reg reg_fp_d_o;
	output reg [0:0] bmask_a_mux_o;
	output reg [1:0] bmask_b_mux_o;
	output reg alu_bmask_a_mux_sel_o;
	output reg alu_bmask_b_mux_sel_o;
	input wire [31:0] instr_rdata_i;
	input wire illegal_c_insn_i;
	output reg alu_en_o;
	localparam riscv_defines_ALU_OP_WIDTH = 7;
	output reg [6:0] alu_operator_o;
	output reg [2:0] alu_op_a_mux_sel_o;
	output reg [2:0] alu_op_b_mux_sel_o;
	output reg [1:0] alu_op_c_mux_sel_o;
	output reg [1:0] alu_vec_mode_o;
	output reg scalar_replication_o;
	output reg scalar_replication_c_o;
	output reg [0:0] imm_a_mux_sel_o;
	output reg [3:0] imm_b_mux_sel_o;
	output reg [1:0] regc_mux_o;
	output reg is_clpx_o;
	output reg is_subrot_o;
	output reg [2:0] mult_operator_o;
	output wire mult_int_en_o;
	output wire mult_dot_en_o;
	output reg [0:0] mult_imm_mux_o;
	output reg mult_sel_subword_o;
	output reg [1:0] mult_signed_mode_o;
	output reg [1:0] mult_dot_signed_o;
	localparam riscv_defines_C_RM = 3;
	input wire [2:0] frm_i;
	localparam [31:0] fpnew_pkg_NUM_FP_FORMATS = 5;
	localparam [31:0] fpnew_pkg_FP_FORMAT_BITS = 3;
	localparam riscv_defines_C_FPNEW_FMTBITS = fpnew_pkg_FP_FORMAT_BITS;
	output reg [2:0] fpu_dst_fmt_o;
	output reg [2:0] fpu_src_fmt_o;
	localparam [31:0] fpnew_pkg_NUM_INT_FORMATS = 4;
	localparam [31:0] fpnew_pkg_INT_FORMAT_BITS = 2;
	localparam riscv_defines_C_FPNEW_IFMTBITS = fpnew_pkg_INT_FORMAT_BITS;
	output reg [1:0] fpu_int_fmt_o;
	output wire apu_en_o;
	output reg [WAPUTYPE - 1:0] apu_type_o;
	output reg [APU_WOP_CPU - 1:0] apu_op_o;
	output reg [1:0] apu_lat_o;
	output reg [WAPUTYPE - 1:0] apu_flags_src_o;
	output reg [2:0] fp_rnd_mode_o;
	output wire regfile_mem_we_o;
	output wire regfile_alu_we_o;
	output wire regfile_alu_we_dec_o;
	output reg regfile_alu_waddr_sel_o;
	output reg csr_access_o;
	output reg csr_status_o;
	output wire [1:0] csr_op_o;
	input wire [1:0] current_priv_lvl_i;
	output wire data_req_o;
	output reg data_we_o;
	output reg prepost_useincr_o;
	output reg [1:0] data_type_o;
	output reg [1:0] data_sign_extension_o;
	output reg [1:0] data_reg_offset_o;
	output reg data_load_event_o;
	output wire [2:0] hwloop_we_o;
	output reg hwloop_target_mux_sel_o;
	output reg hwloop_start_mux_sel_o;
	output reg hwloop_cnt_mux_sel_o;
	output wire [1:0] jump_in_dec_o;
	output wire [1:0] jump_in_id_o;
	output reg [1:0] jump_target_mux_sel_o;
	localparam APUTYPE_DSP_MULT = (SHARED_DSP_MULT ? 0 : 0);
	localparam APUTYPE_INT_MULT = (SHARED_INT_MULT ? SHARED_DSP_MULT : 0);
	localparam APUTYPE_INT_DIV = (SHARED_INT_DIV ? SHARED_DSP_MULT + SHARED_INT_MULT : 0);
	localparam APUTYPE_FP = (SHARED_FP ? (SHARED_DSP_MULT + SHARED_INT_MULT) + SHARED_INT_DIV : 0);
	localparam APUTYPE_ADDSUB = (SHARED_FP ? (SHARED_FP == 1 ? APUTYPE_FP : APUTYPE_FP) : 0);
	localparam APUTYPE_MULT = (SHARED_FP ? (SHARED_FP == 1 ? APUTYPE_FP + 1 : APUTYPE_FP) : 0);
	localparam APUTYPE_CAST = (SHARED_FP ? (SHARED_FP == 1 ? APUTYPE_FP + 2 : APUTYPE_FP) : 0);
	localparam APUTYPE_MAC = (SHARED_FP ? (SHARED_FP == 1 ? APUTYPE_FP + 3 : APUTYPE_FP) : 0);
	localparam APUTYPE_DIV = (SHARED_FP_DIVSQRT == 1 ? (SHARED_FP == 1 ? APUTYPE_FP + 4 : APUTYPE_FP) : (SHARED_FP_DIVSQRT == 2 ? (SHARED_FP == 1 ? APUTYPE_FP + 4 : APUTYPE_FP + 1) : 0));
	localparam APUTYPE_SQRT = (SHARED_FP_DIVSQRT == 1 ? (SHARED_FP == 1 ? APUTYPE_FP + 5 : APUTYPE_FP) : (SHARED_FP_DIVSQRT == 2 ? (SHARED_FP == 1 ? APUTYPE_FP + 4 : APUTYPE_FP + 1) : 0));
	reg regfile_mem_we;
	reg regfile_alu_we;
	reg data_req;
	reg [2:0] hwloop_we;
	reg csr_illegal;
	reg [1:0] jump_in_id;
	reg [1:0] csr_op;
	reg mult_int_en;
	reg mult_dot_en;
	reg apu_en;
	reg check_fprm;
	localparam [31:0] fpnew_pkg_OP_BITS = 4;
	localparam riscv_defines_C_FPNEW_OPBITS = fpnew_pkg_OP_BITS;
	reg [3:0] fpu_op;
	reg fpu_op_mod;
	reg fpu_vec_op;
	reg [1:0] fp_op_group;
	localparam apu_core_package_APU_FLAGS_DSP_MULT = 0;
	localparam apu_core_package_APU_FLAGS_FP = 2;
	localparam apu_core_package_APU_FLAGS_FPNEW = 3;
	localparam apu_core_package_APU_FLAGS_INT_MULT = 1;
	localparam apu_core_package_PIPE_REG_ADDSUB = 1;
	localparam apu_core_package_PIPE_REG_CAST = 1;
	localparam apu_core_package_PIPE_REG_DSP_MULT = 1;
	localparam apu_core_package_PIPE_REG_MAC = 2;
	localparam apu_core_package_PIPE_REG_MULT = 1;
	localparam riscv_defines_ALU_ABS = 7'b0010100;
	localparam riscv_defines_ALU_ADD = 7'b0011000;
	localparam riscv_defines_ALU_ADDR = 7'b0011100;
	localparam riscv_defines_ALU_ADDU = 7'b0011010;
	localparam riscv_defines_ALU_ADDUR = 7'b0011110;
	localparam riscv_defines_ALU_AND = 7'b0010101;
	localparam riscv_defines_ALU_BCLR = 7'b0101011;
	localparam riscv_defines_ALU_BEXT = 7'b0101000;
	localparam riscv_defines_ALU_BEXTU = 7'b0101001;
	localparam riscv_defines_ALU_BINS = 7'b0101010;
	localparam riscv_defines_ALU_BREV = 7'b1001001;
	localparam riscv_defines_ALU_BSET = 7'b0101100;
	localparam riscv_defines_ALU_CLB = 7'b0110101;
	localparam riscv_defines_ALU_CLIP = 7'b0010110;
	localparam riscv_defines_ALU_CLIPU = 7'b0010111;
	localparam riscv_defines_ALU_CNT = 7'b0110100;
	localparam riscv_defines_ALU_DIV = 7'b0110001;
	localparam riscv_defines_ALU_DIVU = 7'b0110000;
	localparam riscv_defines_ALU_EQ = 7'b0001100;
	localparam riscv_defines_ALU_EXT = 7'b0111111;
	localparam riscv_defines_ALU_EXTS = 7'b0111110;
	localparam riscv_defines_ALU_FCLASS = 7'b1001000;
	localparam riscv_defines_ALU_FEQ = 7'b1000011;
	localparam riscv_defines_ALU_FF1 = 7'b0110110;
	localparam riscv_defines_ALU_FKEEP = 7'b1111111;
	localparam riscv_defines_ALU_FL1 = 7'b0110111;
	localparam riscv_defines_ALU_FLE = 7'b1000101;
	localparam riscv_defines_ALU_FLT = 7'b1000100;
	localparam riscv_defines_ALU_FMAX = 7'b1000110;
	localparam riscv_defines_ALU_FMIN = 7'b1000111;
	localparam riscv_defines_ALU_FSGNJ = 7'b1000000;
	localparam riscv_defines_ALU_FSGNJN = 7'b1000001;
	localparam riscv_defines_ALU_FSGNJX = 7'b1000010;
	localparam riscv_defines_ALU_GES = 7'b0001010;
	localparam riscv_defines_ALU_GEU = 7'b0001011;
	localparam riscv_defines_ALU_GTS = 7'b0001000;
	localparam riscv_defines_ALU_GTU = 7'b0001001;
	localparam riscv_defines_ALU_INS = 7'b0101101;
	localparam riscv_defines_ALU_LES = 7'b0000100;
	localparam riscv_defines_ALU_LEU = 7'b0000101;
	localparam riscv_defines_ALU_LTS = 7'b0000000;
	localparam riscv_defines_ALU_LTU = 7'b0000001;
	localparam riscv_defines_ALU_MAX = 7'b0010010;
	localparam riscv_defines_ALU_MAXU = 7'b0010011;
	localparam riscv_defines_ALU_MIN = 7'b0010000;
	localparam riscv_defines_ALU_MINU = 7'b0010001;
	localparam riscv_defines_ALU_NE = 7'b0001101;
	localparam riscv_defines_ALU_OR = 7'b0101110;
	localparam riscv_defines_ALU_PCKHI = 7'b0111001;
	localparam riscv_defines_ALU_PCKLO = 7'b0111000;
	localparam riscv_defines_ALU_REM = 7'b0110011;
	localparam riscv_defines_ALU_REMU = 7'b0110010;
	localparam riscv_defines_ALU_ROR = 7'b0100110;
	localparam riscv_defines_ALU_SHUF = 7'b0111010;
	localparam riscv_defines_ALU_SHUF2 = 7'b0111011;
	localparam riscv_defines_ALU_SLETS = 7'b0000110;
	localparam riscv_defines_ALU_SLETU = 7'b0000111;
	localparam riscv_defines_ALU_SLL = 7'b0100111;
	localparam riscv_defines_ALU_SLTS = 7'b0000010;
	localparam riscv_defines_ALU_SLTU = 7'b0000011;
	localparam riscv_defines_ALU_SRA = 7'b0100100;
	localparam riscv_defines_ALU_SRL = 7'b0100101;
	localparam riscv_defines_ALU_SUB = 7'b0011001;
	localparam riscv_defines_ALU_SUBR = 7'b0011101;
	localparam riscv_defines_ALU_SUBU = 7'b0011011;
	localparam riscv_defines_ALU_SUBUR = 7'b0011111;
	localparam riscv_defines_ALU_XOR = 7'b0101111;
	localparam riscv_defines_BMASK_A_IMM = 1'b1;
	localparam riscv_defines_BMASK_A_REG = 1'b0;
	localparam riscv_defines_BMASK_A_S3 = 1'b1;
	localparam riscv_defines_BMASK_A_ZERO = 1'b0;
	localparam riscv_defines_BMASK_B_IMM = 1'b1;
	localparam riscv_defines_BMASK_B_ONE = 2'b11;
	localparam riscv_defines_BMASK_B_REG = 1'b0;
	localparam riscv_defines_BMASK_B_S2 = 2'b00;
	localparam riscv_defines_BMASK_B_S3 = 2'b01;
	localparam riscv_defines_BMASK_B_ZERO = 2'b10;
	localparam riscv_defines_BRANCH_COND = 2'b11;
	localparam riscv_defines_BRANCH_JAL = 2'b01;
	localparam riscv_defines_BRANCH_JALR = 2'b10;
	localparam riscv_defines_BRANCH_NONE = 2'b00;
	localparam riscv_defines_CSR_OP_CLEAR = 2'b11;
	localparam riscv_defines_CSR_OP_NONE = 2'b00;
	localparam riscv_defines_CSR_OP_SET = 2'b10;
	localparam riscv_defines_CSR_OP_WRITE = 2'b01;
	localparam [31:0] riscv_defines_C_LAT_CONV = 'd0;
	localparam [31:0] riscv_defines_C_LAT_FP16 = 'd0;
	localparam [31:0] riscv_defines_C_LAT_FP16ALT = 'd0;
	localparam [31:0] riscv_defines_C_LAT_FP32 = 'd0;
	localparam [31:0] riscv_defines_C_LAT_FP64 = 'd0;
	localparam [31:0] riscv_defines_C_LAT_FP8 = 'd0;
	localparam [31:0] riscv_defines_C_LAT_NONCOMP = 'd0;
	localparam [0:0] riscv_defines_C_RVD = 1'b0;
	localparam [0:0] riscv_defines_C_RVF = 1'b1;
	localparam [0:0] riscv_defines_C_XF16 = 1'b0;
	localparam [0:0] riscv_defines_C_XF16ALT = 1'b0;
	localparam [0:0] riscv_defines_C_XF8 = 1'b0;
	localparam [0:0] riscv_defines_C_XFVEC = 1'b0;
	localparam riscv_defines_IMMA_Z = 1'b0;
	localparam riscv_defines_IMMA_ZERO = 1'b1;
	localparam riscv_defines_IMMB_BI = 4'b1011;
	localparam riscv_defines_IMMB_CLIP = 4'b1001;
	localparam riscv_defines_IMMB_I = 4'b0000;
	localparam riscv_defines_IMMB_PCINCR = 4'b0011;
	localparam riscv_defines_IMMB_S = 4'b0001;
	localparam riscv_defines_IMMB_S2 = 4'b0100;
	localparam riscv_defines_IMMB_SHUF = 4'b1000;
	localparam riscv_defines_IMMB_U = 4'b0010;
	localparam riscv_defines_IMMB_VS = 4'b0110;
	localparam riscv_defines_IMMB_VU = 4'b0111;
	localparam riscv_defines_JT_COND = 2'b11;
	localparam riscv_defines_JT_JAL = 2'b01;
	localparam riscv_defines_JT_JALR = 2'b10;
	localparam riscv_defines_MIMM_S3 = 1'b1;
	localparam riscv_defines_MIMM_ZERO = 1'b0;
	localparam riscv_defines_MUL_DOT16 = 3'b101;
	localparam riscv_defines_MUL_DOT8 = 3'b100;
	localparam riscv_defines_MUL_H = 3'b110;
	localparam riscv_defines_MUL_I = 3'b010;
	localparam riscv_defines_MUL_IR = 3'b011;
	localparam riscv_defines_MUL_MAC32 = 3'b000;
	localparam riscv_defines_MUL_MSU32 = 3'b001;
	localparam riscv_defines_OPCODE_AUIPC = 7'h17;
	localparam riscv_defines_OPCODE_BRANCH = 7'h63;
	localparam riscv_defines_OPCODE_FENCE = 7'h0f;
	localparam riscv_defines_OPCODE_HWLOOP = 7'h7b;
	localparam riscv_defines_OPCODE_JAL = 7'h6f;
	localparam riscv_defines_OPCODE_JALR = 7'h67;
	localparam riscv_defines_OPCODE_LOAD = 7'h03;
	localparam riscv_defines_OPCODE_LOAD_FP = 7'h07;
	localparam riscv_defines_OPCODE_LOAD_POST = 7'h0b;
	localparam riscv_defines_OPCODE_LUI = 7'h37;
	localparam riscv_defines_OPCODE_OP = 7'h33;
	localparam riscv_defines_OPCODE_OPIMM = 7'h13;
	localparam riscv_defines_OPCODE_OP_FMADD = 7'h43;
	localparam riscv_defines_OPCODE_OP_FMSUB = 7'h47;
	localparam riscv_defines_OPCODE_OP_FNMADD = 7'h4f;
	localparam riscv_defines_OPCODE_OP_FNMSUB = 7'h4b;
	localparam riscv_defines_OPCODE_OP_FP = 7'h53;
	localparam riscv_defines_OPCODE_PULP_OP = 7'h5b;
	localparam riscv_defines_OPCODE_STORE = 7'h23;
	localparam riscv_defines_OPCODE_STORE_FP = 7'h27;
	localparam riscv_defines_OPCODE_STORE_POST = 7'h2b;
	localparam riscv_defines_OPCODE_SYSTEM = 7'h73;
	localparam riscv_defines_OPCODE_VECOP = 7'h57;
	localparam riscv_defines_OP_A_CURRPC = 3'b001;
	localparam riscv_defines_OP_A_IMM = 3'b010;
	localparam riscv_defines_OP_A_REGA_OR_FWD = 3'b000;
	localparam riscv_defines_OP_A_REGB_OR_FWD = 3'b011;
	localparam riscv_defines_OP_A_REGC_OR_FWD = 3'b100;
	localparam riscv_defines_OP_B_BMASK = 3'b100;
	localparam riscv_defines_OP_B_IMM = 3'b010;
	localparam riscv_defines_OP_B_REGA_OR_FWD = 3'b011;
	localparam riscv_defines_OP_B_REGB_OR_FWD = 3'b000;
	localparam riscv_defines_OP_B_REGC_OR_FWD = 3'b001;
	localparam riscv_defines_OP_C_JT = 2'b10;
	localparam riscv_defines_OP_C_REGB_OR_FWD = 2'b01;
	localparam riscv_defines_OP_C_REGC_OR_FWD = 2'b00;
	localparam riscv_defines_REGC_RD = 2'b01;
	localparam riscv_defines_REGC_S1 = 2'b10;
	localparam riscv_defines_REGC_S4 = 2'b00;
	localparam riscv_defines_REGC_ZERO = 2'b11;
	localparam riscv_defines_VEC_MODE16 = 2'b10;
	localparam riscv_defines_VEC_MODE32 = 2'b00;
	localparam riscv_defines_VEC_MODE8 = 2'b11;
	function automatic [3:0] sv2v_cast_A53F3;
		input reg [3:0] inp;
		sv2v_cast_A53F3 = inp;
	endfunction
	function automatic [2:0] sv2v_cast_0BC43;
		input reg [2:0] inp;
		sv2v_cast_0BC43 = inp;
	endfunction
	function automatic [1:0] sv2v_cast_87CC5;
		input reg [1:0] inp;
		sv2v_cast_87CC5 = inp;
	endfunction
	always @(*) begin
		jump_in_id = riscv_defines_BRANCH_NONE;
		jump_target_mux_sel_o = riscv_defines_JT_JAL;
		alu_en_o = 1'b1;
		alu_operator_o = riscv_defines_ALU_SLTU;
		alu_op_a_mux_sel_o = riscv_defines_OP_A_REGA_OR_FWD;
		alu_op_b_mux_sel_o = riscv_defines_OP_B_REGB_OR_FWD;
		alu_op_c_mux_sel_o = riscv_defines_OP_C_REGC_OR_FWD;
		alu_vec_mode_o = riscv_defines_VEC_MODE32;
		scalar_replication_o = 1'b0;
		scalar_replication_c_o = 1'b0;
		regc_mux_o = riscv_defines_REGC_ZERO;
		imm_a_mux_sel_o = riscv_defines_IMMA_ZERO;
		imm_b_mux_sel_o = riscv_defines_IMMB_I;
		mult_operator_o = riscv_defines_MUL_I;
		mult_int_en = 1'b0;
		mult_dot_en = 1'b0;
		mult_imm_mux_o = riscv_defines_MIMM_ZERO;
		mult_signed_mode_o = 2'b00;
		mult_sel_subword_o = 1'b0;
		mult_dot_signed_o = 2'b00;
		apu_en = 1'b0;
		apu_type_o = 1'sb0;
		apu_op_o = 1'sb0;
		apu_lat_o = 1'sb0;
		apu_flags_src_o = 1'sb0;
		fp_rnd_mode_o = 1'sb0;
		fpu_op = sv2v_cast_A53F3(6);
		fpu_op_mod = 1'b0;
		fpu_vec_op = 1'b0;
		fpu_dst_fmt_o = sv2v_cast_0BC43('d0);
		fpu_src_fmt_o = sv2v_cast_0BC43('d0);
		fpu_int_fmt_o = sv2v_cast_87CC5(2);
		check_fprm = 1'b0;
		fp_op_group = 2'd0;
		regfile_mem_we = 1'b0;
		regfile_alu_we = 1'b0;
		regfile_alu_waddr_sel_o = 1'b1;
		prepost_useincr_o = 1'b1;
		hwloop_we = 3'b000;
		hwloop_target_mux_sel_o = 1'b0;
		hwloop_start_mux_sel_o = 1'b0;
		hwloop_cnt_mux_sel_o = 1'b0;
		csr_access_o = 1'b0;
		csr_status_o = 1'b0;
		csr_illegal = 1'b0;
		csr_op = riscv_defines_CSR_OP_NONE;
		mret_insn_o = 1'b0;
		uret_insn_o = 1'b0;
		dret_insn_o = 1'b0;
		data_we_o = 1'b0;
		data_type_o = 2'b00;
		data_sign_extension_o = 2'b00;
		data_reg_offset_o = 2'b00;
		data_req = 1'b0;
		data_load_event_o = 1'b0;
		illegal_insn_o = 1'b0;
		ebrk_insn_o = 1'b0;
		ecall_insn_o = 1'b0;
		pipe_flush_o = 1'b0;
		fencei_insn_o = 1'b0;
		rega_used_o = 1'b0;
		regb_used_o = 1'b0;
		regc_used_o = 1'b0;
		reg_fp_a_o = 1'b0;
		reg_fp_b_o = 1'b0;
		reg_fp_c_o = 1'b0;
		reg_fp_d_o = 1'b0;
		bmask_a_mux_o = riscv_defines_BMASK_A_ZERO;
		bmask_b_mux_o = riscv_defines_BMASK_B_ZERO;
		alu_bmask_a_mux_sel_o = riscv_defines_BMASK_A_IMM;
		alu_bmask_b_mux_sel_o = riscv_defines_BMASK_B_IMM;
		instr_multicycle_o = 1'b0;
		is_clpx_o = 1'b0;
		is_subrot_o = 1'b0;
		mret_dec_o = 1'b0;
		uret_dec_o = 1'b0;
		dret_dec_o = 1'b0;
		case (instr_rdata_i[6:0])
			riscv_defines_OPCODE_JAL: begin
				jump_target_mux_sel_o = riscv_defines_JT_JAL;
				jump_in_id = riscv_defines_BRANCH_JAL;
				alu_op_a_mux_sel_o = riscv_defines_OP_A_CURRPC;
				alu_op_b_mux_sel_o = riscv_defines_OP_B_IMM;
				imm_b_mux_sel_o = riscv_defines_IMMB_PCINCR;
				alu_operator_o = riscv_defines_ALU_ADD;
				regfile_alu_we = 1'b1;
			end
			riscv_defines_OPCODE_JALR: begin
				jump_target_mux_sel_o = riscv_defines_JT_JALR;
				jump_in_id = riscv_defines_BRANCH_JALR;
				alu_op_a_mux_sel_o = riscv_defines_OP_A_CURRPC;
				alu_op_b_mux_sel_o = riscv_defines_OP_B_IMM;
				imm_b_mux_sel_o = riscv_defines_IMMB_PCINCR;
				alu_operator_o = riscv_defines_ALU_ADD;
				regfile_alu_we = 1'b1;
				rega_used_o = 1'b1;
				if (instr_rdata_i[14:12] != 3'b000) begin
					jump_in_id = riscv_defines_BRANCH_NONE;
					regfile_alu_we = 1'b0;
					illegal_insn_o = 1'b1;
				end
			end
			riscv_defines_OPCODE_BRANCH: begin
				jump_target_mux_sel_o = riscv_defines_JT_COND;
				jump_in_id = riscv_defines_BRANCH_COND;
				alu_op_c_mux_sel_o = riscv_defines_OP_C_JT;
				rega_used_o = 1'b1;
				regb_used_o = 1'b1;
				case (instr_rdata_i[14:12])
					3'b000: alu_operator_o = riscv_defines_ALU_EQ;
					3'b001: alu_operator_o = riscv_defines_ALU_NE;
					3'b100: alu_operator_o = riscv_defines_ALU_LTS;
					3'b101: alu_operator_o = riscv_defines_ALU_GES;
					3'b110: alu_operator_o = riscv_defines_ALU_LTU;
					3'b111: alu_operator_o = riscv_defines_ALU_GEU;
					3'b010: begin
						alu_operator_o = riscv_defines_ALU_EQ;
						regb_used_o = 1'b0;
						alu_op_b_mux_sel_o = riscv_defines_OP_B_IMM;
						imm_b_mux_sel_o = riscv_defines_IMMB_BI;
					end
					3'b011: begin
						alu_operator_o = riscv_defines_ALU_NE;
						regb_used_o = 1'b0;
						alu_op_b_mux_sel_o = riscv_defines_OP_B_IMM;
						imm_b_mux_sel_o = riscv_defines_IMMB_BI;
					end
				endcase
			end
			riscv_defines_OPCODE_STORE, riscv_defines_OPCODE_STORE_POST: begin
				data_req = 1'b1;
				data_we_o = 1'b1;
				rega_used_o = 1'b1;
				regb_used_o = 1'b1;
				alu_operator_o = riscv_defines_ALU_ADD;
				instr_multicycle_o = 1'b1;
				alu_op_c_mux_sel_o = riscv_defines_OP_C_REGB_OR_FWD;
				if (instr_rdata_i[6:0] == riscv_defines_OPCODE_STORE_POST) begin
					prepost_useincr_o = 1'b0;
					regfile_alu_waddr_sel_o = 1'b0;
					regfile_alu_we = 1'b1;
				end
				if (instr_rdata_i[14] == 1'b0) begin
					imm_b_mux_sel_o = riscv_defines_IMMB_S;
					alu_op_b_mux_sel_o = riscv_defines_OP_B_IMM;
				end
				else begin
					regc_used_o = 1'b1;
					alu_op_b_mux_sel_o = riscv_defines_OP_B_REGC_OR_FWD;
					regc_mux_o = riscv_defines_REGC_RD;
				end
				case (instr_rdata_i[13:12])
					2'b00: data_type_o = 2'b10;
					2'b01: data_type_o = 2'b01;
					2'b10: data_type_o = 2'b00;
					default: begin
						data_req = 1'b0;
						data_we_o = 1'b0;
						illegal_insn_o = 1'b1;
					end
				endcase
			end
			riscv_defines_OPCODE_LOAD, riscv_defines_OPCODE_LOAD_POST: begin
				data_req = 1'b1;
				regfile_mem_we = 1'b1;
				rega_used_o = 1'b1;
				data_type_o = 2'b00;
				instr_multicycle_o = 1'b1;
				alu_operator_o = riscv_defines_ALU_ADD;
				alu_op_b_mux_sel_o = riscv_defines_OP_B_IMM;
				imm_b_mux_sel_o = riscv_defines_IMMB_I;
				if (instr_rdata_i[6:0] == riscv_defines_OPCODE_LOAD_POST) begin
					prepost_useincr_o = 1'b0;
					regfile_alu_waddr_sel_o = 1'b0;
					regfile_alu_we = 1'b1;
				end
				data_sign_extension_o = {1'b0, ~instr_rdata_i[14]};
				case (instr_rdata_i[13:12])
					2'b00: data_type_o = 2'b10;
					2'b01: data_type_o = 2'b01;
					2'b10: data_type_o = 2'b00;
					default: data_type_o = 2'b00;
				endcase
				if (instr_rdata_i[14:12] == 3'b111) begin
					regb_used_o = 1'b1;
					alu_op_b_mux_sel_o = riscv_defines_OP_B_REGB_OR_FWD;
					data_sign_extension_o = {1'b0, ~instr_rdata_i[30]};
					case (instr_rdata_i[31:25])
						7'b0000000, 7'b0100000: data_type_o = 2'b10;
						7'b0001000, 7'b0101000: data_type_o = 2'b01;
						7'b0010000: data_type_o = 2'b00;
						default: illegal_insn_o = 1'b1;
					endcase
				end
				if (instr_rdata_i[14:12] == 3'b110)
					data_load_event_o = 1'b1;
				if (instr_rdata_i[14:12] == 3'b011)
					illegal_insn_o = 1'b1;
			end
			riscv_defines_OPCODE_LUI: begin
				alu_op_a_mux_sel_o = riscv_defines_OP_A_IMM;
				alu_op_b_mux_sel_o = riscv_defines_OP_B_IMM;
				imm_a_mux_sel_o = riscv_defines_IMMA_ZERO;
				imm_b_mux_sel_o = riscv_defines_IMMB_U;
				alu_operator_o = riscv_defines_ALU_ADD;
				regfile_alu_we = 1'b1;
			end
			riscv_defines_OPCODE_AUIPC: begin
				alu_op_a_mux_sel_o = riscv_defines_OP_A_CURRPC;
				alu_op_b_mux_sel_o = riscv_defines_OP_B_IMM;
				imm_b_mux_sel_o = riscv_defines_IMMB_U;
				alu_operator_o = riscv_defines_ALU_ADD;
				regfile_alu_we = 1'b1;
			end
			riscv_defines_OPCODE_OPIMM: begin
				alu_op_b_mux_sel_o = riscv_defines_OP_B_IMM;
				imm_b_mux_sel_o = riscv_defines_IMMB_I;
				regfile_alu_we = 1'b1;
				rega_used_o = 1'b1;
				case (instr_rdata_i[14:12])
					3'b000: alu_operator_o = riscv_defines_ALU_ADD;
					3'b010: alu_operator_o = riscv_defines_ALU_SLTS;
					3'b011: alu_operator_o = riscv_defines_ALU_SLTU;
					3'b100: alu_operator_o = riscv_defines_ALU_XOR;
					3'b110: alu_operator_o = riscv_defines_ALU_OR;
					3'b111: alu_operator_o = riscv_defines_ALU_AND;
					3'b001: begin
						alu_operator_o = riscv_defines_ALU_SLL;
						if (instr_rdata_i[31:25] != 7'b0000000)
							illegal_insn_o = 1'b1;
					end
					3'b101:
						if (instr_rdata_i[31:25] == 7'b0000000)
							alu_operator_o = riscv_defines_ALU_SRL;
						else if (instr_rdata_i[31:25] == 7'b0100000)
							alu_operator_o = riscv_defines_ALU_SRA;
						else
							illegal_insn_o = 1'b1;
				endcase
			end
			riscv_defines_OPCODE_OP:
				if (instr_rdata_i[31:30] == 2'b11) begin
					regfile_alu_we = 1'b1;
					rega_used_o = 1'b1;
					bmask_a_mux_o = riscv_defines_BMASK_A_S3;
					bmask_b_mux_o = riscv_defines_BMASK_B_S2;
					alu_op_b_mux_sel_o = riscv_defines_OP_B_IMM;
					case (instr_rdata_i[14:12])
						3'b000: begin
							alu_operator_o = riscv_defines_ALU_BEXT;
							imm_b_mux_sel_o = riscv_defines_IMMB_S2;
							bmask_b_mux_o = riscv_defines_BMASK_B_ZERO;
						end
						3'b001: begin
							alu_operator_o = riscv_defines_ALU_BEXTU;
							imm_b_mux_sel_o = riscv_defines_IMMB_S2;
							bmask_b_mux_o = riscv_defines_BMASK_B_ZERO;
						end
						3'b010: begin
							alu_operator_o = riscv_defines_ALU_BINS;
							imm_b_mux_sel_o = riscv_defines_IMMB_S2;
							regc_used_o = 1'b1;
							regc_mux_o = riscv_defines_REGC_RD;
						end
						3'b011: alu_operator_o = riscv_defines_ALU_BCLR;
						3'b100: alu_operator_o = riscv_defines_ALU_BSET;
						3'b101: begin
							alu_operator_o = riscv_defines_ALU_BREV;
							regc_used_o = 1'b1;
							regc_mux_o = riscv_defines_REGC_RD;
							imm_b_mux_sel_o = riscv_defines_IMMB_S2;
							alu_bmask_a_mux_sel_o = riscv_defines_BMASK_A_IMM;
						end
						default: illegal_insn_o = 1'b1;
					endcase
				end
				else if (instr_rdata_i[31:30] == 2'b10) begin
					if (instr_rdata_i[29:25] == 5'b00000) begin
						regfile_alu_we = 1'b1;
						rega_used_o = 1'b1;
						bmask_a_mux_o = riscv_defines_BMASK_A_S3;
						bmask_b_mux_o = riscv_defines_BMASK_B_S2;
						alu_op_b_mux_sel_o = riscv_defines_OP_B_IMM;
						case (instr_rdata_i[14:12])
							3'b000: begin
								alu_operator_o = riscv_defines_ALU_BEXT;
								imm_b_mux_sel_o = riscv_defines_IMMB_S2;
								bmask_b_mux_o = riscv_defines_BMASK_B_ZERO;
								alu_op_b_mux_sel_o = riscv_defines_OP_B_BMASK;
								alu_bmask_a_mux_sel_o = riscv_defines_BMASK_A_REG;
								regb_used_o = 1'b1;
							end
							3'b001: begin
								alu_operator_o = riscv_defines_ALU_BEXTU;
								imm_b_mux_sel_o = riscv_defines_IMMB_S2;
								bmask_b_mux_o = riscv_defines_BMASK_B_ZERO;
								alu_op_b_mux_sel_o = riscv_defines_OP_B_BMASK;
								alu_bmask_a_mux_sel_o = riscv_defines_BMASK_A_REG;
								regb_used_o = 1'b1;
							end
							3'b010: begin
								alu_operator_o = riscv_defines_ALU_BINS;
								imm_b_mux_sel_o = riscv_defines_IMMB_S2;
								regc_used_o = 1'b1;
								regc_mux_o = riscv_defines_REGC_RD;
								alu_op_b_mux_sel_o = riscv_defines_OP_B_BMASK;
								alu_bmask_a_mux_sel_o = riscv_defines_BMASK_A_REG;
								alu_bmask_b_mux_sel_o = riscv_defines_BMASK_B_REG;
								regb_used_o = 1'b1;
							end
							3'b011: begin
								alu_operator_o = riscv_defines_ALU_BCLR;
								regb_used_o = 1'b1;
								alu_bmask_a_mux_sel_o = riscv_defines_BMASK_A_REG;
								alu_bmask_b_mux_sel_o = riscv_defines_BMASK_B_REG;
							end
							3'b100: begin
								alu_operator_o = riscv_defines_ALU_BSET;
								regb_used_o = 1'b1;
								alu_bmask_a_mux_sel_o = riscv_defines_BMASK_A_REG;
								alu_bmask_b_mux_sel_o = riscv_defines_BMASK_B_REG;
							end
							default: illegal_insn_o = 1'b1;
						endcase
					end
					else if (((FPU == 1) && riscv_defines_C_XFVEC) && (SHARED_FP != 1)) begin
						apu_en = 1'b1;
						alu_en_o = 1'b0;
						apu_flags_src_o = apu_core_package_APU_FLAGS_FPNEW;
						rega_used_o = 1'b1;
						regb_used_o = 1'b1;
						reg_fp_a_o = 1'b1;
						reg_fp_b_o = 1'b1;
						reg_fp_d_o = 1'b1;
						fpu_vec_op = 1'b1;
						scalar_replication_o = instr_rdata_i[14];
						check_fprm = 1'b1;
						fp_rnd_mode_o = frm_i;
						case (instr_rdata_i[13:12])
							2'b00: begin
								fpu_dst_fmt_o = sv2v_cast_0BC43('d0);
								alu_vec_mode_o = riscv_defines_VEC_MODE32;
							end
							2'b01: begin
								fpu_dst_fmt_o = sv2v_cast_0BC43('d4);
								alu_vec_mode_o = riscv_defines_VEC_MODE16;
							end
							2'b10: begin
								fpu_dst_fmt_o = sv2v_cast_0BC43('d2);
								alu_vec_mode_o = riscv_defines_VEC_MODE16;
							end
							2'b11: begin
								fpu_dst_fmt_o = sv2v_cast_0BC43('d3);
								alu_vec_mode_o = riscv_defines_VEC_MODE8;
							end
						endcase
						fpu_src_fmt_o = fpu_dst_fmt_o;
						if (instr_rdata_i[29:25] == 5'b00001) begin
							fpu_op = sv2v_cast_A53F3(2);
							fp_op_group = 2'd0;
							apu_type_o = APUTYPE_ADDSUB;
							alu_op_b_mux_sel_o = riscv_defines_OP_B_REGA_OR_FWD;
							alu_op_c_mux_sel_o = riscv_defines_OP_C_REGB_OR_FWD;
							scalar_replication_o = 1'b0;
							scalar_replication_c_o = instr_rdata_i[14];
						end
						else if (instr_rdata_i[29:25] == 5'b00010) begin
							fpu_op = sv2v_cast_A53F3(2);
							fpu_op_mod = 1'b1;
							fp_op_group = 2'd0;
							apu_type_o = APUTYPE_ADDSUB;
							alu_op_b_mux_sel_o = riscv_defines_OP_B_REGA_OR_FWD;
							alu_op_c_mux_sel_o = riscv_defines_OP_C_REGB_OR_FWD;
							scalar_replication_o = 1'b0;
							scalar_replication_c_o = instr_rdata_i[14];
						end
						else if (instr_rdata_i[29:25] == 5'b00011) begin
							fpu_op = sv2v_cast_A53F3(3);
							fp_op_group = 2'd0;
							apu_type_o = APUTYPE_MULT;
						end
						else if (instr_rdata_i[29:25] == 5'b00100) begin
							if (FP_DIVSQRT) begin
								fpu_op = sv2v_cast_A53F3(4);
								fp_op_group = 2'd1;
								apu_type_o = APUTYPE_DIV;
							end
							else
								illegal_insn_o = 1'b1;
						end
						else if (instr_rdata_i[29:25] == 5'b00101) begin
							fpu_op = sv2v_cast_A53F3(7);
							fp_rnd_mode_o = 3'b000;
							fp_op_group = 2'd2;
							apu_type_o = APUTYPE_FP;
							check_fprm = 1'b0;
						end
						else if (instr_rdata_i[29:25] == 5'b00110) begin
							fpu_op = sv2v_cast_A53F3(7);
							fp_rnd_mode_o = 3'b001;
							fp_op_group = 2'd2;
							apu_type_o = APUTYPE_FP;
							check_fprm = 1'b0;
						end
						else if (instr_rdata_i[29:25] == 5'b00111) begin
							if (FP_DIVSQRT) begin
								regb_used_o = 1'b0;
								fpu_op = sv2v_cast_A53F3(5);
								fp_op_group = 2'd1;
								apu_type_o = APUTYPE_SQRT;
								if ((instr_rdata_i[24:20] != 5'b00000) || instr_rdata_i[14])
									illegal_insn_o = 1'b1;
							end
							else
								illegal_insn_o = 1'b1;
						end
						else if (instr_rdata_i[29:25] == 5'b01000) begin
							regc_used_o = 1'b1;
							regc_mux_o = riscv_defines_REGC_RD;
							reg_fp_c_o = 1'b1;
							fpu_op = sv2v_cast_A53F3(0);
							fp_op_group = 2'd0;
							apu_type_o = APUTYPE_MAC;
						end
						else if (instr_rdata_i[29:25] == 5'b01001) begin
							regc_used_o = 1'b1;
							regc_mux_o = riscv_defines_REGC_RD;
							reg_fp_c_o = 1'b1;
							fpu_op = sv2v_cast_A53F3(0);
							fpu_op_mod = 1'b1;
							fp_op_group = 2'd0;
							apu_type_o = APUTYPE_MAC;
						end
						else if (instr_rdata_i[29:25] == 5'b01100) begin
							regb_used_o = 1'b0;
							scalar_replication_o = 1'b0;
							if (instr_rdata_i[24:20] == 5'b00000) begin
								alu_op_b_mux_sel_o = riscv_defines_OP_B_REGA_OR_FWD;
								fpu_op = sv2v_cast_A53F3(6);
								fp_rnd_mode_o = 3'b011;
								fp_op_group = 2'd2;
								apu_type_o = APUTYPE_FP;
								check_fprm = 1'b0;
								if (instr_rdata_i[14]) begin
									reg_fp_a_o = 1'b0;
									fpu_op_mod = 1'b0;
								end
								else begin
									reg_fp_d_o = 1'b0;
									fpu_op_mod = 1'b1;
								end
							end
							else if (instr_rdata_i[24:20] == 5'b00001) begin
								reg_fp_d_o = 1'b0;
								fpu_op = sv2v_cast_A53F3(9);
								fp_rnd_mode_o = 3'b000;
								fp_op_group = 2'd2;
								apu_type_o = APUTYPE_FP;
								check_fprm = 1'b0;
								if (instr_rdata_i[14])
									illegal_insn_o = 1'b1;
							end
							else if ((instr_rdata_i[24:20] | 5'b00001) == 5'b00011) begin
								fp_op_group = 2'd3;
								fpu_op_mod = instr_rdata_i[14];
								apu_type_o = APUTYPE_CAST;
								case (instr_rdata_i[13:12])
									2'b00: fpu_int_fmt_o = sv2v_cast_87CC5(2);
									2'b01, 2'b10: fpu_int_fmt_o = sv2v_cast_87CC5(1);
									2'b11: fpu_int_fmt_o = sv2v_cast_87CC5(0);
								endcase
								if (instr_rdata_i[20]) begin
									reg_fp_a_o = 1'b0;
									fpu_op = sv2v_cast_A53F3(12);
								end
								else begin
									reg_fp_d_o = 1'b0;
									fpu_op = sv2v_cast_A53F3(11);
								end
							end
							else if ((instr_rdata_i[24:20] | 5'b00011) == 5'b00111) begin
								fpu_op = sv2v_cast_A53F3(10);
								fp_op_group = 2'd3;
								apu_type_o = APUTYPE_CAST;
								case (instr_rdata_i[21:20])
									2'b00: begin
										fpu_src_fmt_o = sv2v_cast_0BC43('d0);
										if (~riscv_defines_C_RVF)
											illegal_insn_o = 1'b1;
									end
									2'b01: begin
										fpu_src_fmt_o = sv2v_cast_0BC43('d4);
										if (~riscv_defines_C_XF16ALT)
											illegal_insn_o = 1'b1;
									end
									2'b10: begin
										fpu_src_fmt_o = sv2v_cast_0BC43('d2);
										if (~riscv_defines_C_XF16)
											illegal_insn_o = 1'b1;
									end
									2'b11: begin
										fpu_src_fmt_o = sv2v_cast_0BC43('d3);
										if (~riscv_defines_C_XF8)
											illegal_insn_o = 1'b1;
									end
								endcase
								if (instr_rdata_i[14])
									illegal_insn_o = 1'b1;
							end
							else
								illegal_insn_o = 1'b1;
						end
						else if (instr_rdata_i[29:25] == 5'b01101) begin
							fpu_op = sv2v_cast_A53F3(6);
							fp_rnd_mode_o = 3'b000;
							fp_op_group = 2'd2;
							apu_type_o = APUTYPE_FP;
							check_fprm = 1'b0;
						end
						else if (instr_rdata_i[29:25] == 5'b01110) begin
							fpu_op = sv2v_cast_A53F3(6);
							fp_rnd_mode_o = 3'b001;
							fp_op_group = 2'd2;
							apu_type_o = APUTYPE_FP;
							check_fprm = 1'b0;
						end
						else if (instr_rdata_i[29:25] == 5'b01111) begin
							fpu_op = sv2v_cast_A53F3(6);
							fp_rnd_mode_o = 3'b010;
							fp_op_group = 2'd2;
							apu_type_o = APUTYPE_FP;
							check_fprm = 1'b0;
						end
						else if (instr_rdata_i[29:25] == 5'b10000) begin
							reg_fp_d_o = 1'b0;
							fpu_op = sv2v_cast_A53F3(8);
							fp_rnd_mode_o = 3'b010;
							fp_op_group = 2'd2;
							apu_type_o = APUTYPE_FP;
							check_fprm = 1'b0;
						end
						else if (instr_rdata_i[29:25] == 5'b10001) begin
							reg_fp_d_o = 1'b0;
							fpu_op = sv2v_cast_A53F3(8);
							fpu_op_mod = 1'b1;
							fp_rnd_mode_o = 3'b010;
							fp_op_group = 2'd2;
							apu_type_o = APUTYPE_FP;
							check_fprm = 1'b0;
						end
						else if (instr_rdata_i[29:25] == 5'b10010) begin
							reg_fp_d_o = 1'b0;
							fpu_op = sv2v_cast_A53F3(8);
							fp_rnd_mode_o = 3'b001;
							fp_op_group = 2'd2;
							apu_type_o = APUTYPE_FP;
							check_fprm = 1'b0;
						end
						else if (instr_rdata_i[29:25] == 5'b10011) begin
							reg_fp_d_o = 1'b0;
							fpu_op = sv2v_cast_A53F3(8);
							fpu_op_mod = 1'b1;
							fp_rnd_mode_o = 3'b001;
							fp_op_group = 2'd2;
							apu_type_o = APUTYPE_FP;
							check_fprm = 1'b0;
						end
						else if (instr_rdata_i[29:25] == 5'b10100) begin
							reg_fp_d_o = 1'b0;
							fpu_op = sv2v_cast_A53F3(8);
							fp_rnd_mode_o = 3'b000;
							fp_op_group = 2'd2;
							apu_type_o = APUTYPE_FP;
							check_fprm = 1'b0;
						end
						else if (instr_rdata_i[29:25] == 5'b10101) begin
							reg_fp_d_o = 1'b0;
							fpu_op = sv2v_cast_A53F3(8);
							fpu_op_mod = 1'b1;
							fp_rnd_mode_o = 3'b000;
							fp_op_group = 2'd2;
							apu_type_o = APUTYPE_FP;
							check_fprm = 1'b0;
						end
						else if ((instr_rdata_i[29:25] | 5'b00011) == 5'b11011) begin
							fpu_op_mod = instr_rdata_i[14];
							fp_op_group = 2'd3;
							apu_type_o = APUTYPE_CAST;
							scalar_replication_o = 1'b0;
							if (instr_rdata_i[25])
								fpu_op = sv2v_cast_A53F3(14);
							else
								fpu_op = sv2v_cast_A53F3(13);
							if (instr_rdata_i[26]) begin
								fpu_src_fmt_o = sv2v_cast_0BC43('d1);
								if (~riscv_defines_C_RVD)
									illegal_insn_o = 1'b1;
							end
							else begin
								fpu_src_fmt_o = sv2v_cast_0BC43('d0);
								if (~riscv_defines_C_RVF)
									illegal_insn_o = 1'b1;
							end
							if (fpu_op == sv2v_cast_A53F3(14)) begin
								if (~riscv_defines_C_XF8 || ~riscv_defines_C_RVD)
									illegal_insn_o = 1'b1;
							end
							else if (instr_rdata_i[14]) begin
								if (fpu_dst_fmt_o == sv2v_cast_0BC43('d0))
									illegal_insn_o = 1'b1;
								if (~riscv_defines_C_RVD && (fpu_dst_fmt_o != sv2v_cast_0BC43('d3)))
									illegal_insn_o = 1'b1;
							end
						end
						else
							illegal_insn_o = 1'b1;
						if ((~riscv_defines_C_RVF || ~riscv_defines_C_RVD) && (fpu_dst_fmt_o == sv2v_cast_0BC43('d0)))
							illegal_insn_o = 1'b1;
						if ((~riscv_defines_C_XF16 || ~riscv_defines_C_RVF) && (fpu_dst_fmt_o == sv2v_cast_0BC43('d2)))
							illegal_insn_o = 1'b1;
						if ((~riscv_defines_C_XF16ALT || ~riscv_defines_C_RVF) && (fpu_dst_fmt_o == sv2v_cast_0BC43('d4)))
							illegal_insn_o = 1'b1;
						if ((~riscv_defines_C_XF8 || (~riscv_defines_C_XF16 && ~riscv_defines_C_XF16ALT)) && (fpu_dst_fmt_o == sv2v_cast_0BC43('d3)))
							illegal_insn_o = 1'b1;
						if (check_fprm)
							if ((3'b000 <= frm_i) && (3'b100 >= frm_i))
								;
							else
								illegal_insn_o = 1'b1;
						case (fp_op_group)
							2'd0:
								case (fpu_dst_fmt_o)
									sv2v_cast_0BC43('d0): apu_lat_o = 1;
									sv2v_cast_0BC43('d2): apu_lat_o = 1;
									sv2v_cast_0BC43('d4): apu_lat_o = 1;
									sv2v_cast_0BC43('d3): apu_lat_o = 1;
									default:
										;
								endcase
							2'd1: apu_lat_o = 2'h3;
							2'd2: apu_lat_o = 1;
							2'd3: apu_lat_o = 1;
						endcase
						apu_op_o = {fpu_vec_op, fpu_op_mod, fpu_op};
					end
					else
						illegal_insn_o = 1'b1;
				end
				else begin
					regfile_alu_we = 1'b1;
					rega_used_o = 1'b1;
					if (~instr_rdata_i[28])
						regb_used_o = 1'b1;
					case ({instr_rdata_i[30:25], instr_rdata_i[14:12]})
						9'b000000000: alu_operator_o = riscv_defines_ALU_ADD;
						9'b100000000: alu_operator_o = riscv_defines_ALU_SUB;
						9'b000000010: alu_operator_o = riscv_defines_ALU_SLTS;
						9'b000000011: alu_operator_o = riscv_defines_ALU_SLTU;
						9'b000000100: alu_operator_o = riscv_defines_ALU_XOR;
						9'b000000110: alu_operator_o = riscv_defines_ALU_OR;
						9'b000000111: alu_operator_o = riscv_defines_ALU_AND;
						9'b000000001: alu_operator_o = riscv_defines_ALU_SLL;
						9'b000000101: alu_operator_o = riscv_defines_ALU_SRL;
						9'b100000101: alu_operator_o = riscv_defines_ALU_SRA;
						9'b000001000: begin
							alu_en_o = 1'b0;
							mult_int_en = 1'b1;
							mult_operator_o = riscv_defines_MUL_MAC32;
							regc_mux_o = riscv_defines_REGC_ZERO;
						end
						9'b000001001: begin
							alu_en_o = 1'b0;
							regc_used_o = 1'b1;
							regc_mux_o = riscv_defines_REGC_ZERO;
							mult_signed_mode_o = 2'b11;
							mult_int_en = 1'b1;
							mult_operator_o = riscv_defines_MUL_H;
							instr_multicycle_o = 1'b1;
						end
						9'b000001010: begin
							alu_en_o = 1'b0;
							regc_used_o = 1'b1;
							regc_mux_o = riscv_defines_REGC_ZERO;
							mult_signed_mode_o = 2'b01;
							mult_int_en = 1'b1;
							mult_operator_o = riscv_defines_MUL_H;
							instr_multicycle_o = 1'b1;
						end
						9'b000001011: begin
							alu_en_o = 1'b0;
							regc_used_o = 1'b1;
							regc_mux_o = riscv_defines_REGC_ZERO;
							mult_signed_mode_o = 2'b00;
							mult_int_en = 1'b1;
							mult_operator_o = riscv_defines_MUL_H;
							instr_multicycle_o = 1'b1;
						end
						9'b000001100: begin
							alu_op_a_mux_sel_o = riscv_defines_OP_A_REGB_OR_FWD;
							alu_op_b_mux_sel_o = riscv_defines_OP_B_REGC_OR_FWD;
							regc_mux_o = riscv_defines_REGC_S1;
							regc_used_o = 1'b1;
							regb_used_o = 1'b1;
							rega_used_o = 1'b0;
							alu_operator_o = riscv_defines_ALU_DIV;
							instr_multicycle_o = 1'b1;
							if (SHARED_INT_DIV) begin
								alu_en_o = 1'b0;
								apu_en = 1'b1;
								apu_type_o = APUTYPE_INT_DIV;
								apu_op_o = alu_operator_o;
								apu_lat_o = 2'h3;
							end
						end
						9'b000001101: begin
							alu_op_a_mux_sel_o = riscv_defines_OP_A_REGB_OR_FWD;
							alu_op_b_mux_sel_o = riscv_defines_OP_B_REGC_OR_FWD;
							regc_mux_o = riscv_defines_REGC_S1;
							regc_used_o = 1'b1;
							regb_used_o = 1'b1;
							rega_used_o = 1'b0;
							alu_operator_o = riscv_defines_ALU_DIVU;
							instr_multicycle_o = 1'b1;
							if (SHARED_INT_DIV) begin
								alu_en_o = 1'b0;
								apu_en = 1'b1;
								apu_type_o = APUTYPE_INT_DIV;
								apu_op_o = alu_operator_o;
								apu_lat_o = 2'h3;
							end
						end
						9'b000001110: begin
							alu_op_a_mux_sel_o = riscv_defines_OP_A_REGB_OR_FWD;
							alu_op_b_mux_sel_o = riscv_defines_OP_B_REGC_OR_FWD;
							regc_mux_o = riscv_defines_REGC_S1;
							regc_used_o = 1'b1;
							regb_used_o = 1'b1;
							rega_used_o = 1'b0;
							alu_operator_o = riscv_defines_ALU_REM;
							instr_multicycle_o = 1'b1;
							if (SHARED_INT_DIV) begin
								alu_en_o = 1'b0;
								apu_en = 1'b1;
								apu_type_o = APUTYPE_INT_DIV;
								apu_op_o = alu_operator_o;
								apu_lat_o = 2'h3;
							end
						end
						9'b000001111: begin
							alu_op_a_mux_sel_o = riscv_defines_OP_A_REGB_OR_FWD;
							alu_op_b_mux_sel_o = riscv_defines_OP_B_REGC_OR_FWD;
							regc_mux_o = riscv_defines_REGC_S1;
							regc_used_o = 1'b1;
							regb_used_o = 1'b1;
							rega_used_o = 1'b0;
							alu_operator_o = riscv_defines_ALU_REMU;
							instr_multicycle_o = 1'b1;
							if (SHARED_INT_DIV) begin
								alu_en_o = 1'b0;
								apu_en = 1'b1;
								apu_type_o = APUTYPE_INT_DIV;
								apu_op_o = alu_operator_o;
								apu_lat_o = 2'h3;
							end
						end
						9'b100001000: begin
							alu_en_o = 1'b0;
							regc_used_o = 1'b1;
							regc_mux_o = riscv_defines_REGC_RD;
							mult_int_en = 1'b1;
							mult_operator_o = riscv_defines_MUL_MAC32;
							if (SHARED_INT_MULT) begin
								mult_int_en = 1'b0;
								mult_dot_en = 1'b0;
								apu_en = 1'b1;
								apu_flags_src_o = apu_core_package_APU_FLAGS_INT_MULT;
								apu_op_o = mult_operator_o;
								apu_type_o = APUTYPE_INT_MULT;
								apu_lat_o = 2'h1;
							end
						end
						9'b100001001: begin
							alu_en_o = 1'b0;
							regc_used_o = 1'b1;
							regc_mux_o = riscv_defines_REGC_RD;
							mult_int_en = 1'b1;
							mult_operator_o = riscv_defines_MUL_MSU32;
							if (SHARED_INT_MULT) begin
								mult_int_en = 1'b0;
								mult_dot_en = 1'b0;
								apu_en = 1'b1;
								apu_flags_src_o = apu_core_package_APU_FLAGS_INT_MULT;
								apu_op_o = mult_operator_o;
								apu_type_o = APUTYPE_INT_MULT;
								apu_lat_o = 2'h1;
							end
						end
						9'b000010010: alu_operator_o = riscv_defines_ALU_SLETS;
						9'b000010011: alu_operator_o = riscv_defines_ALU_SLETU;
						9'b000010100: alu_operator_o = riscv_defines_ALU_MIN;
						9'b000010101: alu_operator_o = riscv_defines_ALU_MINU;
						9'b000010110: alu_operator_o = riscv_defines_ALU_MAX;
						9'b000010111: alu_operator_o = riscv_defines_ALU_MAXU;
						9'b000100101: alu_operator_o = riscv_defines_ALU_ROR;
						9'b001000000: alu_operator_o = riscv_defines_ALU_FF1;
						9'b001000001: alu_operator_o = riscv_defines_ALU_FL1;
						9'b001000010: alu_operator_o = riscv_defines_ALU_CLB;
						9'b001000011: alu_operator_o = riscv_defines_ALU_CNT;
						9'b001000100: begin
							alu_operator_o = riscv_defines_ALU_EXTS;
							alu_vec_mode_o = riscv_defines_VEC_MODE16;
						end
						9'b001000101: begin
							alu_operator_o = riscv_defines_ALU_EXT;
							alu_vec_mode_o = riscv_defines_VEC_MODE16;
						end
						9'b001000110: begin
							alu_operator_o = riscv_defines_ALU_EXTS;
							alu_vec_mode_o = riscv_defines_VEC_MODE8;
						end
						9'b001000111: begin
							alu_operator_o = riscv_defines_ALU_EXT;
							alu_vec_mode_o = riscv_defines_VEC_MODE8;
						end
						9'b000010000: alu_operator_o = riscv_defines_ALU_ABS;
						9'b001010001: begin
							alu_operator_o = riscv_defines_ALU_CLIP;
							alu_op_b_mux_sel_o = riscv_defines_OP_B_IMM;
							imm_b_mux_sel_o = riscv_defines_IMMB_CLIP;
						end
						9'b001010010: begin
							alu_operator_o = riscv_defines_ALU_CLIPU;
							alu_op_b_mux_sel_o = riscv_defines_OP_B_IMM;
							imm_b_mux_sel_o = riscv_defines_IMMB_CLIP;
						end
						9'b001010101: begin
							alu_operator_o = riscv_defines_ALU_CLIP;
							regb_used_o = 1'b1;
						end
						9'b001010110: begin
							alu_operator_o = riscv_defines_ALU_CLIPU;
							regb_used_o = 1'b1;
						end
						default: illegal_insn_o = 1'b1;
					endcase
				end
			riscv_defines_OPCODE_OP_FP:
				if (FPU == 1) begin
					apu_en = 1'b1;
					alu_en_o = 1'b0;
					apu_flags_src_o = (SHARED_FP == 1 ? apu_core_package_APU_FLAGS_FP : apu_core_package_APU_FLAGS_FPNEW);
					rega_used_o = 1'b1;
					regb_used_o = 1'b1;
					reg_fp_a_o = 1'b1;
					reg_fp_b_o = 1'b1;
					reg_fp_d_o = 1'b1;
					check_fprm = 1'b1;
					fp_rnd_mode_o = instr_rdata_i[14:12];
					case (instr_rdata_i[26:25])
						2'b00: fpu_dst_fmt_o = sv2v_cast_0BC43('d0);
						2'b01: fpu_dst_fmt_o = sv2v_cast_0BC43('d1);
						2'b10:
							if (instr_rdata_i[14:12] == 3'b101)
								fpu_dst_fmt_o = sv2v_cast_0BC43('d4);
							else
								fpu_dst_fmt_o = sv2v_cast_0BC43('d2);
						2'b11: fpu_dst_fmt_o = sv2v_cast_0BC43('d3);
					endcase
					fpu_src_fmt_o = fpu_dst_fmt_o;
					case (instr_rdata_i[31:27])
						5'b00000: begin
							fpu_op = sv2v_cast_A53F3(2);
							fp_op_group = 2'd0;
							apu_type_o = APUTYPE_ADDSUB;
							apu_op_o = 2'b00;
							apu_lat_o = 2'h2;
							if (SHARED_FP != 1) begin
								alu_op_b_mux_sel_o = riscv_defines_OP_B_REGA_OR_FWD;
								alu_op_c_mux_sel_o = riscv_defines_OP_C_REGB_OR_FWD;
							end
						end
						5'b00001: begin
							fpu_op = sv2v_cast_A53F3(2);
							fpu_op_mod = 1'b1;
							fp_op_group = 2'd0;
							apu_type_o = APUTYPE_ADDSUB;
							apu_op_o = 2'b01;
							apu_lat_o = 2'h2;
							if (SHARED_FP != 1) begin
								alu_op_b_mux_sel_o = riscv_defines_OP_B_REGA_OR_FWD;
								alu_op_c_mux_sel_o = riscv_defines_OP_C_REGB_OR_FWD;
							end
						end
						5'b00010: begin
							fpu_op = sv2v_cast_A53F3(3);
							fp_op_group = 2'd0;
							apu_type_o = APUTYPE_MULT;
							apu_lat_o = 2'h2;
						end
						5'b00011:
							if (FP_DIVSQRT) begin
								fpu_op = sv2v_cast_A53F3(4);
								fp_op_group = 2'd1;
								apu_type_o = APUTYPE_DIV;
								apu_lat_o = 2'h3;
							end
							else
								illegal_insn_o = 1'b1;
						5'b01011:
							if (FP_DIVSQRT) begin
								regb_used_o = 1'b0;
								fpu_op = sv2v_cast_A53F3(5);
								fp_op_group = 2'd1;
								apu_type_o = APUTYPE_SQRT;
								apu_op_o = 1'b1;
								apu_lat_o = 2'h3;
								if (instr_rdata_i[24:20] != 5'b00000)
									illegal_insn_o = 1'b1;
							end
							else
								illegal_insn_o = 1'b1;
						5'b00100:
							if (SHARED_FP == 1) begin
								apu_en = 1'b0;
								alu_en_o = 1'b1;
								regfile_alu_we = 1'b1;
								case (instr_rdata_i[14:12])
									3'h0: alu_operator_o = riscv_defines_ALU_FSGNJ;
									3'h1: alu_operator_o = riscv_defines_ALU_FSGNJN;
									3'h2: alu_operator_o = riscv_defines_ALU_FSGNJX;
									default: illegal_insn_o = 1'b1;
								endcase
							end
							else begin
								fpu_op = sv2v_cast_A53F3(6);
								fp_op_group = 2'd2;
								apu_type_o = APUTYPE_FP;
								check_fprm = 1'b0;
								if (riscv_defines_C_XF16ALT) begin
									if (!(|{(3'b000 <= instr_rdata_i[14:12]) && (3'b010 >= instr_rdata_i[14:12]), (3'b100 <= instr_rdata_i[14:12]) && (3'b110 >= instr_rdata_i[14:12])}))
										illegal_insn_o = 1'b1;
									if (instr_rdata_i[14]) begin
										fpu_dst_fmt_o = sv2v_cast_0BC43('d4);
										fpu_src_fmt_o = sv2v_cast_0BC43('d4);
									end
									else
										fp_rnd_mode_o = {1'b0, instr_rdata_i[13:12]};
								end
								else if (!((3'b000 <= instr_rdata_i[14:12]) && (3'b010 >= instr_rdata_i[14:12])))
									illegal_insn_o = 1'b1;
							end
						5'b00101:
							if (SHARED_FP == 1) begin
								apu_en = 1'b0;
								alu_en_o = 1'b1;
								regfile_alu_we = 1'b1;
								case (instr_rdata_i[14:12])
									3'h0: alu_operator_o = riscv_defines_ALU_FMIN;
									3'h1: alu_operator_o = riscv_defines_ALU_FMAX;
									default: illegal_insn_o = 1'b1;
								endcase
							end
							else begin
								fpu_op = sv2v_cast_A53F3(7);
								fp_op_group = 2'd2;
								apu_type_o = APUTYPE_FP;
								check_fprm = 1'b0;
								if (riscv_defines_C_XF16ALT) begin
									if (!(|{(3'b000 <= instr_rdata_i[14:12]) && (3'b001 >= instr_rdata_i[14:12]), (3'b100 <= instr_rdata_i[14:12]) && (3'b101 >= instr_rdata_i[14:12])}))
										illegal_insn_o = 1'b1;
									if (instr_rdata_i[14]) begin
										fpu_dst_fmt_o = sv2v_cast_0BC43('d4);
										fpu_src_fmt_o = sv2v_cast_0BC43('d4);
									end
									else
										fp_rnd_mode_o = {1'b0, instr_rdata_i[13:12]};
								end
								else if (!((3'b000 <= instr_rdata_i[14:12]) && (3'b001 >= instr_rdata_i[14:12])))
									illegal_insn_o = 1'b1;
							end
						5'b01000:
							if (SHARED_FP == 1) begin
								apu_en = 1'b0;
								alu_en_o = 1'b1;
								regfile_alu_we = 1'b1;
								regb_used_o = 1'b0;
								alu_operator_o = riscv_defines_ALU_FKEEP;
							end
							else begin
								regb_used_o = 1'b0;
								fpu_op = sv2v_cast_A53F3(10);
								fp_op_group = 2'd3;
								apu_type_o = APUTYPE_CAST;
								if (instr_rdata_i[24:23])
									illegal_insn_o = 1'b1;
								case (instr_rdata_i[22:20])
									3'b000: begin
										if (~riscv_defines_C_RVF)
											illegal_insn_o = 1'b1;
										fpu_src_fmt_o = sv2v_cast_0BC43('d0);
									end
									3'b001: begin
										if (~riscv_defines_C_RVD)
											illegal_insn_o = 1'b1;
										fpu_src_fmt_o = sv2v_cast_0BC43('d1);
									end
									3'b010: begin
										if (~riscv_defines_C_XF16)
											illegal_insn_o = 1'b1;
										fpu_src_fmt_o = sv2v_cast_0BC43('d2);
									end
									3'b110: begin
										if (~riscv_defines_C_XF16ALT)
											illegal_insn_o = 1'b1;
										fpu_src_fmt_o = sv2v_cast_0BC43('d4);
									end
									3'b011: begin
										if (~riscv_defines_C_XF8)
											illegal_insn_o = 1'b1;
										fpu_src_fmt_o = sv2v_cast_0BC43('d3);
									end
									default: illegal_insn_o = 1'b1;
								endcase
							end
						5'b01001: begin
							fpu_op = sv2v_cast_A53F3(3);
							fp_op_group = 2'd0;
							apu_type_o = APUTYPE_MULT;
							apu_lat_o = 2'h2;
							fpu_dst_fmt_o = sv2v_cast_0BC43('d0);
						end
						5'b01010: begin
							regc_used_o = 1'b1;
							regc_mux_o = riscv_defines_REGC_RD;
							reg_fp_c_o = 1'b1;
							fpu_op = sv2v_cast_A53F3(0);
							fp_op_group = 2'd0;
							apu_type_o = APUTYPE_MAC;
							apu_lat_o = 2'h2;
							fpu_dst_fmt_o = sv2v_cast_0BC43('d0);
						end
						5'b10100:
							if (SHARED_FP == 1) begin
								apu_en = 1'b0;
								alu_en_o = 1'b1;
								regfile_alu_we = 1'b1;
								reg_fp_d_o = 1'b0;
								case (instr_rdata_i[14:12])
									3'h0: alu_operator_o = riscv_defines_ALU_FLE;
									3'h1: alu_operator_o = riscv_defines_ALU_FLT;
									3'h2: alu_operator_o = riscv_defines_ALU_FEQ;
									default: illegal_insn_o = 1'b1;
								endcase
							end
							else begin
								fpu_op = sv2v_cast_A53F3(8);
								fp_op_group = 2'd2;
								reg_fp_d_o = 1'b0;
								apu_type_o = APUTYPE_FP;
								check_fprm = 1'b0;
								if (riscv_defines_C_XF16ALT) begin
									if (!(|{(3'b000 <= instr_rdata_i[14:12]) && (3'b010 >= instr_rdata_i[14:12]), (3'b100 <= instr_rdata_i[14:12]) && (3'b110 >= instr_rdata_i[14:12])}))
										illegal_insn_o = 1'b1;
									if (instr_rdata_i[14]) begin
										fpu_dst_fmt_o = sv2v_cast_0BC43('d4);
										fpu_src_fmt_o = sv2v_cast_0BC43('d4);
									end
									else
										fp_rnd_mode_o = {1'b0, instr_rdata_i[13:12]};
								end
								else if (!((3'b000 <= instr_rdata_i[14:12]) && (3'b010 >= instr_rdata_i[14:12])))
									illegal_insn_o = 1'b1;
							end
						5'b11000: begin
							regb_used_o = 1'b0;
							reg_fp_d_o = 1'b0;
							fpu_op = sv2v_cast_A53F3(11);
							fp_op_group = 2'd3;
							fpu_op_mod = instr_rdata_i[20];
							apu_type_o = APUTYPE_CAST;
							apu_op_o = 2'b01;
							apu_lat_o = 2'h2;
							case (instr_rdata_i[26:25])
								2'b00:
									if (~riscv_defines_C_RVF)
										illegal_insn_o = 1;
									else
										fpu_src_fmt_o = sv2v_cast_0BC43('d0);
								2'b01:
									if (~riscv_defines_C_RVD)
										illegal_insn_o = 1;
									else
										fpu_src_fmt_o = sv2v_cast_0BC43('d1);
								2'b10:
									if (instr_rdata_i[14:12] == 3'b101) begin
										if (~riscv_defines_C_XF16ALT)
											illegal_insn_o = 1;
										else
											fpu_src_fmt_o = sv2v_cast_0BC43('d4);
									end
									else if (~riscv_defines_C_XF16)
										illegal_insn_o = 1;
									else
										fpu_src_fmt_o = sv2v_cast_0BC43('d2);
								2'b11:
									if (~riscv_defines_C_XF8)
										illegal_insn_o = 1;
									else
										fpu_src_fmt_o = sv2v_cast_0BC43('d3);
							endcase
							if (instr_rdata_i[24:21])
								illegal_insn_o = 1'b1;
						end
						5'b11010: begin
							regb_used_o = 1'b0;
							reg_fp_a_o = 1'b0;
							fpu_op = sv2v_cast_A53F3(12);
							fp_op_group = 2'd3;
							fpu_op_mod = instr_rdata_i[20];
							apu_type_o = APUTYPE_CAST;
							apu_op_o = 2'b00;
							apu_lat_o = 2'h2;
							if (instr_rdata_i[24:21])
								illegal_insn_o = 1'b1;
						end
						5'b11100:
							if (SHARED_FP == 1) begin
								apu_en = 1'b0;
								alu_en_o = 1'b1;
								regfile_alu_we = 1'b1;
								case (instr_rdata_i[14:12])
									3'b000: begin
										reg_fp_d_o = 1'b0;
										alu_operator_o = riscv_defines_ALU_ADD;
									end
									3'b001: begin
										regb_used_o = 1'b0;
										reg_fp_d_o = 1'b0;
										alu_operator_o = riscv_defines_ALU_FCLASS;
									end
									default: illegal_insn_o = 1'b1;
								endcase
							end
							else begin
								regb_used_o = 1'b0;
								reg_fp_d_o = 1'b0;
								fp_op_group = 2'd2;
								apu_type_o = APUTYPE_FP;
								check_fprm = 1'b0;
								if ((instr_rdata_i[14:12] == 3'b000) || (riscv_defines_C_XF16ALT && (instr_rdata_i[14:12] == 3'b100))) begin
									alu_op_b_mux_sel_o = riscv_defines_OP_B_REGA_OR_FWD;
									fpu_op = sv2v_cast_A53F3(6);
									fpu_op_mod = 1'b1;
									fp_rnd_mode_o = 3'b011;
									if (instr_rdata_i[14]) begin
										fpu_dst_fmt_o = sv2v_cast_0BC43('d4);
										fpu_src_fmt_o = sv2v_cast_0BC43('d4);
									end
								end
								else if ((instr_rdata_i[14:12] == 3'b001) || (riscv_defines_C_XF16ALT && (instr_rdata_i[14:12] == 3'b101))) begin
									fpu_op = sv2v_cast_A53F3(9);
									fp_rnd_mode_o = 3'b000;
									if (instr_rdata_i[14]) begin
										fpu_dst_fmt_o = sv2v_cast_0BC43('d4);
										fpu_src_fmt_o = sv2v_cast_0BC43('d4);
									end
								end
								else
									illegal_insn_o = 1'b1;
								if (instr_rdata_i[24:20])
									illegal_insn_o = 1'b1;
							end
						5'b11110:
							if (SHARED_FP == 1) begin
								apu_en = 1'b0;
								alu_en_o = 1'b1;
								regfile_alu_we = 1'b1;
								reg_fp_a_o = 1'b0;
								alu_operator_o = riscv_defines_ALU_ADD;
							end
							else begin
								regb_used_o = 1'b0;
								reg_fp_a_o = 1'b0;
								alu_op_b_mux_sel_o = riscv_defines_OP_B_REGA_OR_FWD;
								fpu_op = sv2v_cast_A53F3(6);
								fpu_op_mod = 1'b0;
								fp_op_group = 2'd2;
								fp_rnd_mode_o = 3'b011;
								apu_type_o = APUTYPE_FP;
								check_fprm = 1'b0;
								if ((instr_rdata_i[14:12] == 3'b000) || (riscv_defines_C_XF16ALT && (instr_rdata_i[14:12] == 3'b100))) begin
									if (instr_rdata_i[14]) begin
										fpu_dst_fmt_o = sv2v_cast_0BC43('d4);
										fpu_src_fmt_o = sv2v_cast_0BC43('d4);
									end
								end
								else
									illegal_insn_o = 1'b1;
								if (instr_rdata_i[24:20] != 5'b00000)
									illegal_insn_o = 1'b1;
							end
						default: illegal_insn_o = 1'b1;
					endcase
					if (~riscv_defines_C_RVF && (fpu_dst_fmt_o == sv2v_cast_0BC43('d0)))
						illegal_insn_o = 1'b1;
					if ((~riscv_defines_C_RVD || (SHARED_FP == 1)) && (fpu_dst_fmt_o == sv2v_cast_0BC43('d1)))
						illegal_insn_o = 1'b1;
					if ((~riscv_defines_C_XF16 || (SHARED_FP == 1)) && (fpu_dst_fmt_o == sv2v_cast_0BC43('d2)))
						illegal_insn_o = 1'b1;
					if ((~riscv_defines_C_XF16ALT || (SHARED_FP == 1)) && (fpu_dst_fmt_o == sv2v_cast_0BC43('d4)))
						illegal_insn_o = 1'b1;
					if ((~riscv_defines_C_XF8 || (SHARED_FP == 1)) && (fpu_dst_fmt_o == sv2v_cast_0BC43('d3)))
						illegal_insn_o = 1'b1;
					if (check_fprm)
						if ((3'b000 <= instr_rdata_i[14:12]) && (3'b100 >= instr_rdata_i[14:12]))
							;
						else if (instr_rdata_i[14:12] == 3'b101) begin
							if (~riscv_defines_C_XF16ALT || (fpu_dst_fmt_o != sv2v_cast_0BC43('d4)))
								illegal_insn_o = 1'b1;
							if ((3'b000 <= frm_i) && (3'b100 >= frm_i))
								fp_rnd_mode_o = frm_i;
							else
								illegal_insn_o = 1'b1;
						end
						else if (instr_rdata_i[14:12] == 3'b111) begin
							if ((3'b000 <= frm_i) && (3'b100 >= frm_i))
								fp_rnd_mode_o = frm_i;
							else
								illegal_insn_o = 1'b1;
						end
						else
							illegal_insn_o = 1'b1;
					if (SHARED_FP != 1)
						case (fp_op_group)
							2'd0:
								case (fpu_dst_fmt_o)
									sv2v_cast_0BC43('d0): apu_lat_o = 1;
									sv2v_cast_0BC43('d1): apu_lat_o = 1;
									sv2v_cast_0BC43('d2): apu_lat_o = 1;
									sv2v_cast_0BC43('d4): apu_lat_o = 1;
									sv2v_cast_0BC43('d3): apu_lat_o = 1;
									default:
										;
								endcase
							2'd1: apu_lat_o = 2'h3;
							2'd2: apu_lat_o = 1;
							2'd3: apu_lat_o = 1;
						endcase
					if (SHARED_FP != 1)
						apu_op_o = {fpu_vec_op, fpu_op_mod, fpu_op};
				end
				else
					illegal_insn_o = 1'b1;
			riscv_defines_OPCODE_OP_FMADD, riscv_defines_OPCODE_OP_FMSUB, riscv_defines_OPCODE_OP_FNMSUB, riscv_defines_OPCODE_OP_FNMADD:
				if (FPU == 1) begin
					apu_en = 1'b1;
					alu_en_o = 1'b0;
					apu_flags_src_o = (SHARED_FP == 1 ? apu_core_package_APU_FLAGS_FP : apu_core_package_APU_FLAGS_FPNEW);
					apu_type_o = APUTYPE_MAC;
					apu_lat_o = 2'h3;
					rega_used_o = 1'b1;
					regb_used_o = 1'b1;
					regc_used_o = 1'b1;
					regc_mux_o = riscv_defines_REGC_S4;
					reg_fp_a_o = 1'b1;
					reg_fp_b_o = 1'b1;
					reg_fp_c_o = 1'b1;
					reg_fp_d_o = 1'b1;
					fp_rnd_mode_o = instr_rdata_i[14:12];
					case (instr_rdata_i[26:25])
						2'b00: fpu_dst_fmt_o = sv2v_cast_0BC43('d0);
						2'b01: fpu_dst_fmt_o = sv2v_cast_0BC43('d1);
						2'b10:
							if (instr_rdata_i[14:12] == 3'b101)
								fpu_dst_fmt_o = sv2v_cast_0BC43('d4);
							else
								fpu_dst_fmt_o = sv2v_cast_0BC43('d2);
						2'b11: fpu_dst_fmt_o = sv2v_cast_0BC43('d3);
					endcase
					fpu_src_fmt_o = fpu_dst_fmt_o;
					case (instr_rdata_i[6:0])
						riscv_defines_OPCODE_OP_FMADD: begin
							fpu_op = sv2v_cast_A53F3(0);
							apu_op_o = 2'b00;
						end
						riscv_defines_OPCODE_OP_FMSUB: begin
							fpu_op = sv2v_cast_A53F3(0);
							fpu_op_mod = 1'b1;
							apu_op_o = 2'b01;
						end
						riscv_defines_OPCODE_OP_FNMSUB: begin
							fpu_op = sv2v_cast_A53F3(1);
							apu_op_o = 2'b10;
						end
						riscv_defines_OPCODE_OP_FNMADD: begin
							fpu_op = sv2v_cast_A53F3(1);
							fpu_op_mod = 1'b1;
							apu_op_o = 2'b11;
						end
					endcase
					if (~riscv_defines_C_RVF && (fpu_dst_fmt_o == sv2v_cast_0BC43('d0)))
						illegal_insn_o = 1'b1;
					if ((~riscv_defines_C_RVD || (SHARED_FP == 1)) && (fpu_dst_fmt_o == sv2v_cast_0BC43('d1)))
						illegal_insn_o = 1'b1;
					if ((~riscv_defines_C_XF16 || (SHARED_FP == 1)) && (fpu_dst_fmt_o == sv2v_cast_0BC43('d2)))
						illegal_insn_o = 1'b1;
					if ((~riscv_defines_C_XF16ALT || (SHARED_FP == 1)) && (fpu_dst_fmt_o == sv2v_cast_0BC43('d4)))
						illegal_insn_o = 1'b1;
					if ((~riscv_defines_C_XF8 || (SHARED_FP == 1)) && (fpu_dst_fmt_o == sv2v_cast_0BC43('d3)))
						illegal_insn_o = 1'b1;
					if ((3'b000 <= instr_rdata_i[14:12]) && (3'b100 >= instr_rdata_i[14:12]))
						;
					else if (instr_rdata_i[14:12] == 3'b101) begin
						if (~riscv_defines_C_XF16ALT || (fpu_dst_fmt_o != sv2v_cast_0BC43('d4)))
							illegal_insn_o = 1'b1;
						if ((3'b000 <= frm_i) && (3'b100 >= frm_i))
							fp_rnd_mode_o = frm_i;
						else
							illegal_insn_o = 1'b1;
					end
					else if (instr_rdata_i[14:12] == 3'b111) begin
						if ((3'b000 <= frm_i) && (3'b100 >= frm_i))
							fp_rnd_mode_o = frm_i;
						else
							illegal_insn_o = 1'b1;
					end
					else
						illegal_insn_o = 1'b1;
					if (SHARED_FP != 1)
						case (fpu_dst_fmt_o)
							sv2v_cast_0BC43('d0): apu_lat_o = 1;
							sv2v_cast_0BC43('d1): apu_lat_o = 1;
							sv2v_cast_0BC43('d2): apu_lat_o = 1;
							sv2v_cast_0BC43('d4): apu_lat_o = 1;
							sv2v_cast_0BC43('d3): apu_lat_o = 1;
							default:
								;
						endcase
					if (SHARED_FP != 1)
						apu_op_o = {fpu_vec_op, fpu_op_mod, fpu_op};
				end
				else
					illegal_insn_o = 1'b1;
			riscv_defines_OPCODE_STORE_FP:
				if (FPU == 1) begin
					data_req = 1'b1;
					data_we_o = 1'b1;
					rega_used_o = 1'b1;
					regb_used_o = 1'b1;
					alu_operator_o = riscv_defines_ALU_ADD;
					reg_fp_b_o = 1'b1;
					instr_multicycle_o = 1'b1;
					imm_b_mux_sel_o = riscv_defines_IMMB_S;
					alu_op_b_mux_sel_o = riscv_defines_OP_B_IMM;
					alu_op_c_mux_sel_o = riscv_defines_OP_C_REGB_OR_FWD;
					case (instr_rdata_i[14:12])
						3'b000:
							if (riscv_defines_C_XF8)
								data_type_o = 2'b10;
							else
								illegal_insn_o = 1'b1;
						3'b001:
							if (riscv_defines_C_XF16 | riscv_defines_C_XF16ALT)
								data_type_o = 2'b01;
							else
								illegal_insn_o = 1'b1;
						3'b010:
							if (riscv_defines_C_RVF)
								data_type_o = 2'b00;
							else
								illegal_insn_o = 1'b1;
						3'b011:
							if (riscv_defines_C_RVD)
								data_type_o = 2'b00;
							else
								illegal_insn_o = 1'b1;
						default: illegal_insn_o = 1'b1;
					endcase
					if (illegal_insn_o) begin
						data_req = 1'b0;
						data_we_o = 1'b0;
					end
				end
				else
					illegal_insn_o = 1'b1;
			riscv_defines_OPCODE_LOAD_FP:
				if (FPU == 1) begin
					data_req = 1'b1;
					regfile_mem_we = 1'b1;
					reg_fp_d_o = 1'b1;
					rega_used_o = 1'b1;
					alu_operator_o = riscv_defines_ALU_ADD;
					instr_multicycle_o = 1'b1;
					imm_b_mux_sel_o = riscv_defines_IMMB_I;
					alu_op_b_mux_sel_o = riscv_defines_OP_B_IMM;
					data_sign_extension_o = 2'b10;
					case (instr_rdata_i[14:12])
						3'b000:
							if (riscv_defines_C_XF8)
								data_type_o = 2'b10;
							else
								illegal_insn_o = 1'b1;
						3'b001:
							if (riscv_defines_C_XF16 | riscv_defines_C_XF16ALT)
								data_type_o = 2'b01;
							else
								illegal_insn_o = 1'b1;
						3'b010:
							if (riscv_defines_C_RVF)
								data_type_o = 2'b00;
							else
								illegal_insn_o = 1'b1;
						3'b011:
							if (riscv_defines_C_RVD)
								data_type_o = 2'b00;
							else
								illegal_insn_o = 1'b1;
						default: illegal_insn_o = 1'b1;
					endcase
				end
				else
					illegal_insn_o = 1'b1;
			riscv_defines_OPCODE_PULP_OP: begin
				regfile_alu_we = 1'b1;
				rega_used_o = 1'b1;
				regb_used_o = 1'b1;
				case (instr_rdata_i[13:12])
					2'b00: begin
						alu_en_o = 1'b0;
						mult_sel_subword_o = instr_rdata_i[30];
						mult_signed_mode_o = {2 {instr_rdata_i[31]}};
						mult_imm_mux_o = riscv_defines_MIMM_S3;
						regc_mux_o = riscv_defines_REGC_ZERO;
						mult_int_en = 1'b1;
						if (instr_rdata_i[14])
							mult_operator_o = riscv_defines_MUL_IR;
						else
							mult_operator_o = riscv_defines_MUL_I;
						if (SHARED_INT_MULT) begin
							mult_int_en = 1'b0;
							mult_dot_en = 1'b0;
							apu_en = 1'b1;
							apu_flags_src_o = apu_core_package_APU_FLAGS_INT_MULT;
							apu_op_o = mult_operator_o;
							apu_type_o = APUTYPE_INT_MULT;
							apu_lat_o = 2'h1;
						end
					end
					2'b01: begin
						alu_en_o = 1'b0;
						mult_sel_subword_o = instr_rdata_i[30];
						mult_signed_mode_o = {2 {instr_rdata_i[31]}};
						regc_used_o = 1'b1;
						regc_mux_o = riscv_defines_REGC_RD;
						mult_imm_mux_o = riscv_defines_MIMM_S3;
						mult_int_en = 1'b1;
						if (instr_rdata_i[14])
							mult_operator_o = riscv_defines_MUL_IR;
						else
							mult_operator_o = riscv_defines_MUL_I;
						if (SHARED_INT_MULT) begin
							mult_int_en = 1'b0;
							mult_dot_en = 1'b0;
							apu_en = 1'b1;
							apu_flags_src_o = apu_core_package_APU_FLAGS_INT_MULT;
							apu_op_o = mult_operator_o;
							apu_type_o = APUTYPE_INT_MULT;
							apu_lat_o = 2'h1;
						end
					end
					2'b10: begin
						case ({instr_rdata_i[31], instr_rdata_i[14]})
							2'b00: alu_operator_o = riscv_defines_ALU_ADD;
							2'b01: alu_operator_o = riscv_defines_ALU_ADDR;
							2'b10: alu_operator_o = riscv_defines_ALU_ADDU;
							2'b11: alu_operator_o = riscv_defines_ALU_ADDUR;
						endcase
						bmask_a_mux_o = riscv_defines_BMASK_A_ZERO;
						bmask_b_mux_o = riscv_defines_BMASK_B_S3;
						if (instr_rdata_i[30]) begin
							regc_used_o = 1'b1;
							regc_mux_o = riscv_defines_REGC_RD;
							alu_bmask_b_mux_sel_o = riscv_defines_BMASK_B_REG;
							alu_op_a_mux_sel_o = riscv_defines_OP_A_REGC_OR_FWD;
							alu_op_b_mux_sel_o = riscv_defines_OP_B_REGA_OR_FWD;
						end
					end
					2'b11: begin
						case ({instr_rdata_i[31], instr_rdata_i[14]})
							2'b00: alu_operator_o = riscv_defines_ALU_SUB;
							2'b01: alu_operator_o = riscv_defines_ALU_SUBR;
							2'b10: alu_operator_o = riscv_defines_ALU_SUBU;
							2'b11: alu_operator_o = riscv_defines_ALU_SUBUR;
						endcase
						bmask_a_mux_o = riscv_defines_BMASK_A_ZERO;
						bmask_b_mux_o = riscv_defines_BMASK_B_S3;
						if (instr_rdata_i[30]) begin
							regc_used_o = 1'b1;
							regc_mux_o = riscv_defines_REGC_RD;
							alu_bmask_b_mux_sel_o = riscv_defines_BMASK_B_REG;
							alu_op_a_mux_sel_o = riscv_defines_OP_A_REGC_OR_FWD;
							alu_op_b_mux_sel_o = riscv_defines_OP_B_REGA_OR_FWD;
						end
					end
				endcase
			end
			riscv_defines_OPCODE_VECOP: begin
				regfile_alu_we = 1'b1;
				rega_used_o = 1'b1;
				imm_b_mux_sel_o = riscv_defines_IMMB_VS;
				if (instr_rdata_i[12]) begin
					alu_vec_mode_o = riscv_defines_VEC_MODE8;
					mult_operator_o = riscv_defines_MUL_DOT8;
				end
				else begin
					alu_vec_mode_o = riscv_defines_VEC_MODE16;
					mult_operator_o = riscv_defines_MUL_DOT16;
				end
				if (instr_rdata_i[14]) begin
					scalar_replication_o = 1'b1;
					if (instr_rdata_i[13])
						alu_op_b_mux_sel_o = riscv_defines_OP_B_IMM;
					else
						regb_used_o = 1'b1;
				end
				else
					regb_used_o = 1'b1;
				case (instr_rdata_i[31:26])
					6'b000000: begin
						alu_operator_o = riscv_defines_ALU_ADD;
						imm_b_mux_sel_o = riscv_defines_IMMB_VS;
					end
					6'b000010: begin
						alu_operator_o = riscv_defines_ALU_SUB;
						imm_b_mux_sel_o = riscv_defines_IMMB_VS;
					end
					6'b000100: begin
						alu_operator_o = riscv_defines_ALU_ADD;
						imm_b_mux_sel_o = riscv_defines_IMMB_VS;
						bmask_b_mux_o = riscv_defines_BMASK_B_ONE;
					end
					6'b000110: begin
						alu_operator_o = riscv_defines_ALU_ADDU;
						imm_b_mux_sel_o = riscv_defines_IMMB_VU;
						bmask_b_mux_o = riscv_defines_BMASK_B_ONE;
					end
					6'b001000: begin
						alu_operator_o = riscv_defines_ALU_MIN;
						imm_b_mux_sel_o = riscv_defines_IMMB_VS;
					end
					6'b001010: begin
						alu_operator_o = riscv_defines_ALU_MINU;
						imm_b_mux_sel_o = riscv_defines_IMMB_VU;
					end
					6'b001100: begin
						alu_operator_o = riscv_defines_ALU_MAX;
						imm_b_mux_sel_o = riscv_defines_IMMB_VS;
					end
					6'b001110: begin
						alu_operator_o = riscv_defines_ALU_MAXU;
						imm_b_mux_sel_o = riscv_defines_IMMB_VU;
					end
					6'b010000: begin
						alu_operator_o = riscv_defines_ALU_SRL;
						imm_b_mux_sel_o = riscv_defines_IMMB_VS;
					end
					6'b010010: begin
						alu_operator_o = riscv_defines_ALU_SRA;
						imm_b_mux_sel_o = riscv_defines_IMMB_VS;
					end
					6'b010100: begin
						alu_operator_o = riscv_defines_ALU_SLL;
						imm_b_mux_sel_o = riscv_defines_IMMB_VS;
					end
					6'b010110: begin
						alu_operator_o = riscv_defines_ALU_OR;
						imm_b_mux_sel_o = riscv_defines_IMMB_VS;
					end
					6'b011000: begin
						alu_operator_o = riscv_defines_ALU_XOR;
						imm_b_mux_sel_o = riscv_defines_IMMB_VS;
					end
					6'b011010: begin
						alu_operator_o = riscv_defines_ALU_AND;
						imm_b_mux_sel_o = riscv_defines_IMMB_VS;
					end
					6'b011100: begin
						alu_operator_o = riscv_defines_ALU_ABS;
						imm_b_mux_sel_o = riscv_defines_IMMB_VS;
					end
					6'b111010, 6'b111100, 6'b111110, 6'b110000: begin
						alu_operator_o = riscv_defines_ALU_SHUF;
						imm_b_mux_sel_o = riscv_defines_IMMB_SHUF;
						regb_used_o = 1'b1;
						scalar_replication_o = 1'b0;
					end
					6'b110010: begin
						alu_operator_o = riscv_defines_ALU_SHUF2;
						regb_used_o = 1'b1;
						regc_used_o = 1'b1;
						regc_mux_o = riscv_defines_REGC_RD;
						scalar_replication_o = 1'b0;
					end
					6'b110100: begin
						alu_operator_o = (instr_rdata_i[25] ? riscv_defines_ALU_PCKHI : riscv_defines_ALU_PCKLO);
						regb_used_o = 1'b1;
					end
					6'b110110: begin
						alu_operator_o = riscv_defines_ALU_PCKHI;
						regb_used_o = 1'b1;
						regc_used_o = 1'b1;
						regc_mux_o = riscv_defines_REGC_RD;
					end
					6'b111000: begin
						alu_operator_o = riscv_defines_ALU_PCKLO;
						regb_used_o = 1'b1;
						regc_used_o = 1'b1;
						regc_mux_o = riscv_defines_REGC_RD;
					end
					6'b011110: alu_operator_o = riscv_defines_ALU_EXTS;
					6'b100100: alu_operator_o = riscv_defines_ALU_EXT;
					6'b101100: begin
						alu_operator_o = riscv_defines_ALU_INS;
						regc_used_o = 1'b1;
						regc_mux_o = riscv_defines_REGC_RD;
						alu_op_b_mux_sel_o = riscv_defines_OP_B_REGC_OR_FWD;
					end
					6'b100000: begin
						alu_en_o = 1'b0;
						mult_dot_en = 1'b1;
						mult_dot_signed_o = 2'b00;
						imm_b_mux_sel_o = riscv_defines_IMMB_VU;
						if (SHARED_DSP_MULT) begin
							mult_int_en = 1'b0;
							mult_dot_en = 1'b0;
							apu_en = 1'b1;
							apu_type_o = APUTYPE_DSP_MULT;
							apu_flags_src_o = apu_core_package_APU_FLAGS_DSP_MULT;
							apu_op_o = mult_operator_o;
							apu_lat_o = 2'h2;
						end
					end
					6'b100010: begin
						alu_en_o = 1'b0;
						mult_dot_en = 1'b1;
						mult_dot_signed_o = 2'b01;
						if (SHARED_DSP_MULT) begin
							mult_int_en = 1'b0;
							mult_dot_en = 1'b0;
							apu_en = 1'b1;
							apu_type_o = APUTYPE_DSP_MULT;
							apu_flags_src_o = apu_core_package_APU_FLAGS_DSP_MULT;
							apu_op_o = mult_operator_o;
							apu_lat_o = 2'h2;
						end
					end
					6'b100110: begin
						alu_en_o = 1'b0;
						mult_dot_en = 1'b1;
						mult_dot_signed_o = 2'b11;
						if (SHARED_DSP_MULT) begin
							mult_int_en = 1'b0;
							mult_dot_en = 1'b0;
							apu_en = 1'b1;
							apu_type_o = APUTYPE_DSP_MULT;
							apu_flags_src_o = apu_core_package_APU_FLAGS_DSP_MULT;
							apu_op_o = mult_operator_o;
							apu_lat_o = 2'h2;
						end
					end
					6'b101000: begin
						alu_en_o = 1'b0;
						mult_dot_en = 1'b1;
						mult_dot_signed_o = 2'b00;
						regc_used_o = 1'b1;
						regc_mux_o = riscv_defines_REGC_RD;
						imm_b_mux_sel_o = riscv_defines_IMMB_VU;
						if (SHARED_DSP_MULT) begin
							mult_int_en = 1'b0;
							mult_dot_en = 1'b0;
							apu_en = 1'b1;
							apu_type_o = APUTYPE_DSP_MULT;
							apu_flags_src_o = apu_core_package_APU_FLAGS_DSP_MULT;
							apu_op_o = mult_operator_o;
							apu_lat_o = 2'h2;
						end
					end
					6'b101010: begin
						alu_en_o = 1'b0;
						mult_dot_en = 1'b1;
						mult_dot_signed_o = 2'b01;
						regc_used_o = 1'b1;
						regc_mux_o = riscv_defines_REGC_RD;
						if (SHARED_DSP_MULT) begin
							mult_int_en = 1'b0;
							mult_dot_en = 1'b0;
							apu_en = 1'b1;
							apu_type_o = APUTYPE_DSP_MULT;
							apu_flags_src_o = apu_core_package_APU_FLAGS_DSP_MULT;
							apu_op_o = mult_operator_o;
							apu_lat_o = 2'h2;
						end
					end
					6'b101110: begin
						alu_en_o = 1'b0;
						mult_dot_en = 1'b1;
						mult_dot_signed_o = 2'b11;
						regc_used_o = 1'b1;
						regc_mux_o = riscv_defines_REGC_RD;
						if (SHARED_DSP_MULT) begin
							mult_int_en = 1'b0;
							mult_dot_en = 1'b0;
							apu_en = 1'b1;
							apu_type_o = APUTYPE_DSP_MULT;
							apu_flags_src_o = apu_core_package_APU_FLAGS_DSP_MULT;
							apu_op_o = mult_operator_o;
							apu_lat_o = 2'h2;
						end
					end
					6'b010101: begin
						alu_en_o = 1'b0;
						mult_dot_en = 1'b1;
						mult_dot_signed_o = 2'b11;
						is_clpx_o = 1'b1;
						regc_used_o = 1'b1;
						regc_mux_o = riscv_defines_REGC_RD;
						scalar_replication_o = 1'b0;
						alu_op_b_mux_sel_o = riscv_defines_OP_B_REGB_OR_FWD;
						regb_used_o = 1'b1;
						if (SHARED_DSP_MULT) begin
							mult_int_en = 1'b0;
							mult_dot_en = 1'b0;
							apu_en = 1'b1;
							apu_type_o = APUTYPE_DSP_MULT;
							apu_flags_src_o = apu_core_package_APU_FLAGS_DSP_MULT;
							apu_op_o = mult_operator_o;
							apu_lat_o = 2'h2;
						end
					end
					6'b011011: begin
						alu_operator_o = riscv_defines_ALU_SUB;
						is_clpx_o = 1'b1;
						scalar_replication_o = 1'b0;
						alu_op_b_mux_sel_o = riscv_defines_OP_B_REGB_OR_FWD;
						regb_used_o = 1'b1;
						is_subrot_o = 1'b1;
					end
					6'b010111: begin
						alu_operator_o = riscv_defines_ALU_ABS;
						is_clpx_o = 1'b1;
						scalar_replication_o = 1'b0;
						regb_used_o = 1'b0;
					end
					6'b011101: begin
						alu_operator_o = riscv_defines_ALU_ADD;
						is_clpx_o = 1'b1;
						scalar_replication_o = 1'b0;
						alu_op_b_mux_sel_o = riscv_defines_OP_B_REGB_OR_FWD;
						regb_used_o = 1'b1;
					end
					6'b011001: begin
						alu_operator_o = riscv_defines_ALU_SUB;
						is_clpx_o = 1'b1;
						scalar_replication_o = 1'b0;
						alu_op_b_mux_sel_o = riscv_defines_OP_B_REGB_OR_FWD;
						regb_used_o = 1'b1;
					end
					6'b000001: begin
						alu_operator_o = riscv_defines_ALU_EQ;
						imm_b_mux_sel_o = riscv_defines_IMMB_VS;
					end
					6'b000011: begin
						alu_operator_o = riscv_defines_ALU_NE;
						imm_b_mux_sel_o = riscv_defines_IMMB_VS;
					end
					6'b000101: begin
						alu_operator_o = riscv_defines_ALU_GTS;
						imm_b_mux_sel_o = riscv_defines_IMMB_VS;
					end
					6'b000111: begin
						alu_operator_o = riscv_defines_ALU_GES;
						imm_b_mux_sel_o = riscv_defines_IMMB_VS;
					end
					6'b001001: begin
						alu_operator_o = riscv_defines_ALU_LTS;
						imm_b_mux_sel_o = riscv_defines_IMMB_VS;
					end
					6'b001011: begin
						alu_operator_o = riscv_defines_ALU_LES;
						imm_b_mux_sel_o = riscv_defines_IMMB_VS;
					end
					6'b001101: begin
						alu_operator_o = riscv_defines_ALU_GTU;
						imm_b_mux_sel_o = riscv_defines_IMMB_VU;
					end
					6'b001111: begin
						alu_operator_o = riscv_defines_ALU_GEU;
						imm_b_mux_sel_o = riscv_defines_IMMB_VU;
					end
					6'b010001: begin
						alu_operator_o = riscv_defines_ALU_LTU;
						imm_b_mux_sel_o = riscv_defines_IMMB_VU;
					end
					6'b010011: begin
						alu_operator_o = riscv_defines_ALU_LEU;
						imm_b_mux_sel_o = riscv_defines_IMMB_VU;
					end
					default: illegal_insn_o = 1'b1;
				endcase
			end
			riscv_defines_OPCODE_FENCE:
				case (instr_rdata_i[14:12])
					3'b000: fencei_insn_o = 1'b1;
					3'b001: fencei_insn_o = 1'b1;
					default: illegal_insn_o = 1'b1;
				endcase
			riscv_defines_OPCODE_SYSTEM:
				if (instr_rdata_i[14:12] == 3'b000) begin
					if ({instr_rdata_i[19:15], instr_rdata_i[11:7]} == {10 {1'sb0}})
						case (instr_rdata_i[31:20])
							12'h000: ecall_insn_o = 1'b1;
							12'h001: ebrk_insn_o = 1'b1;
							12'h302: begin
								illegal_insn_o = (PULP_SECURE ? current_priv_lvl_i != 2'b11 : 1'b0);
								mret_insn_o = ~illegal_insn_o;
								mret_dec_o = 1'b1;
							end
							12'h002: begin
								uret_insn_o = (PULP_SECURE ? 1'b1 : 1'b0);
								uret_dec_o = 1'b1;
							end
							12'h7b2: begin
								illegal_insn_o = (PULP_SECURE ? current_priv_lvl_i != 2'b11 : 1'b0);
								dret_insn_o = ~illegal_insn_o;
								dret_dec_o = 1'b1;
							end
							12'h105: pipe_flush_o = 1'b1;
							default: illegal_insn_o = 1'b1;
						endcase
					else
						illegal_insn_o = 1'b1;
				end
				else begin
					csr_access_o = 1'b1;
					regfile_alu_we = 1'b1;
					alu_op_b_mux_sel_o = riscv_defines_OP_B_IMM;
					imm_a_mux_sel_o = riscv_defines_IMMA_Z;
					imm_b_mux_sel_o = riscv_defines_IMMB_I;
					instr_multicycle_o = 1'b1;
					if (instr_rdata_i[14] == 1'b1)
						alu_op_a_mux_sel_o = riscv_defines_OP_A_IMM;
					else begin
						rega_used_o = 1'b1;
						alu_op_a_mux_sel_o = riscv_defines_OP_A_REGA_OR_FWD;
					end
					case (instr_rdata_i[13:12])
						2'b01: csr_op = riscv_defines_CSR_OP_WRITE;
						2'b10: csr_op = riscv_defines_CSR_OP_SET;
						2'b11: csr_op = riscv_defines_CSR_OP_CLEAR;
						default: csr_illegal = 1'b1;
					endcase
					if (instr_rdata_i[29:28] > current_priv_lvl_i)
						csr_illegal = 1'b1;
					if (~csr_illegal)
						if (((((((instr_rdata_i[31:20] == 12'h300) || (instr_rdata_i[31:20] == 12'h000)) || (instr_rdata_i[31:20] == 12'h041)) || (instr_rdata_i[31:20] == 12'h7b0)) || (instr_rdata_i[31:20] == 12'h7b1)) || (instr_rdata_i[31:20] == 12'h7b2)) || (instr_rdata_i[31:20] == 12'h7b3))
							csr_status_o = 1'b1;
					illegal_insn_o = csr_illegal;
				end
			riscv_defines_OPCODE_HWLOOP: begin
				hwloop_target_mux_sel_o = 1'b0;
				case (instr_rdata_i[14:12])
					3'b000: begin
						hwloop_we[0] = 1'b1;
						hwloop_start_mux_sel_o = 1'b0;
					end
					3'b001: hwloop_we[1] = 1'b1;
					3'b010: begin
						hwloop_we[2] = 1'b1;
						hwloop_cnt_mux_sel_o = 1'b1;
						rega_used_o = 1'b1;
					end
					3'b011: begin
						hwloop_we[2] = 1'b1;
						hwloop_cnt_mux_sel_o = 1'b0;
					end
					3'b100: begin
						hwloop_we = 3'b111;
						hwloop_start_mux_sel_o = 1'b1;
						hwloop_cnt_mux_sel_o = 1'b1;
						rega_used_o = 1'b1;
					end
					3'b101: begin
						hwloop_we = 3'b111;
						hwloop_target_mux_sel_o = 1'b1;
						hwloop_start_mux_sel_o = 1'b1;
						hwloop_cnt_mux_sel_o = 1'b0;
					end
					default: illegal_insn_o = 1'b1;
				endcase
			end
			default: illegal_insn_o = 1'b1;
		endcase
		if (illegal_c_insn_i)
			illegal_insn_o = 1'b1;
		if (data_misaligned_i == 1'b1) begin
			alu_op_a_mux_sel_o = riscv_defines_OP_A_REGA_OR_FWD;
			alu_op_b_mux_sel_o = riscv_defines_OP_B_IMM;
			imm_b_mux_sel_o = riscv_defines_IMMB_PCINCR;
			regfile_alu_we = 1'b0;
			prepost_useincr_o = 1'b1;
			scalar_replication_o = 1'b0;
		end
		else if (mult_multicycle_i)
			alu_op_c_mux_sel_o = riscv_defines_OP_C_REGC_OR_FWD;
	end
	assign apu_en_o = (deassert_we_i ? 1'b0 : apu_en);
	assign mult_int_en_o = (deassert_we_i ? 1'b0 : mult_int_en);
	assign mult_dot_en_o = (deassert_we_i ? 1'b0 : mult_dot_en);
	assign regfile_mem_we_o = (deassert_we_i ? 1'b0 : regfile_mem_we);
	assign regfile_alu_we_o = (deassert_we_i ? 1'b0 : regfile_alu_we);
	assign data_req_o = (deassert_we_i ? 1'b0 : data_req);
	assign hwloop_we_o = (deassert_we_i ? 3'b000 : hwloop_we);
	assign csr_op_o = (deassert_we_i ? riscv_defines_CSR_OP_NONE : csr_op);
	assign jump_in_id_o = (deassert_we_i ? riscv_defines_BRANCH_NONE : jump_in_id);
	assign jump_in_dec_o = jump_in_id;
	assign regfile_alu_we_dec_o = regfile_alu_we;
endmodule
