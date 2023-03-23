module riscv_id_stage (
	clk,
	rst_n,
	test_en_i,
	fregfile_disable_i,
	fetch_enable_i,
	ctrl_busy_o,
	core_ctrl_firstfetch_o,
	is_decoding_o,
	hwlp_dec_cnt_i,
	is_hwlp_i,
	instr_valid_i,
	instr_rdata_i,
	instr_req_o,
	branch_in_ex_o,
	branch_decision_i,
	jump_target_o,
	clear_instr_valid_o,
	pc_set_o,
	pc_mux_o,
	exc_pc_mux_o,
	trap_addr_mux_o,
	illegal_c_insn_i,
	is_compressed_i,
	is_fetch_failed_i,
	pc_if_i,
	pc_id_i,
	halt_if_o,
	id_ready_o,
	ex_ready_i,
	wb_ready_i,
	id_valid_o,
	ex_valid_i,
	pc_ex_o,
	alu_operand_a_ex_o,
	alu_operand_b_ex_o,
	alu_operand_c_ex_o,
	bmask_a_ex_o,
	bmask_b_ex_o,
	imm_vec_ext_ex_o,
	alu_vec_mode_ex_o,
	regfile_waddr_ex_o,
	regfile_we_ex_o,
	regfile_alu_waddr_ex_o,
	regfile_alu_we_ex_o,
	alu_en_ex_o,
	alu_operator_ex_o,
	alu_is_clpx_ex_o,
	alu_is_subrot_ex_o,
	alu_clpx_shift_ex_o,
	mult_operator_ex_o,
	mult_operand_a_ex_o,
	mult_operand_b_ex_o,
	mult_operand_c_ex_o,
	mult_en_ex_o,
	mult_sel_subword_ex_o,
	mult_signed_mode_ex_o,
	mult_imm_ex_o,
	mult_dot_op_a_ex_o,
	mult_dot_op_b_ex_o,
	mult_dot_op_c_ex_o,
	mult_dot_signed_ex_o,
	mult_is_clpx_ex_o,
	mult_clpx_shift_ex_o,
	mult_clpx_img_ex_o,
	apu_en_ex_o,
	apu_type_ex_o,
	apu_op_ex_o,
	apu_lat_ex_o,
	apu_operands_ex_o,
	apu_flags_ex_o,
	apu_waddr_ex_o,
	apu_read_regs_o,
	apu_read_regs_valid_o,
	apu_read_dep_i,
	apu_write_regs_o,
	apu_write_regs_valid_o,
	apu_write_dep_i,
	apu_perf_dep_o,
	apu_busy_i,
	frm_i,
	csr_access_ex_o,
	csr_op_ex_o,
	current_priv_lvl_i,
	csr_irq_sec_o,
	csr_cause_o,
	csr_save_if_o,
	csr_save_id_o,
	csr_save_ex_o,
	csr_restore_mret_id_o,
	csr_restore_uret_id_o,
	csr_restore_dret_id_o,
	csr_save_cause_o,
	hwlp_start_o,
	hwlp_end_o,
	hwlp_cnt_o,
	csr_hwlp_regid_i,
	csr_hwlp_we_i,
	csr_hwlp_data_i,
	data_req_ex_o,
	data_we_ex_o,
	data_type_ex_o,
	data_sign_ext_ex_o,
	data_reg_offset_ex_o,
	data_load_event_ex_o,
	data_misaligned_ex_o,
	prepost_useincr_ex_o,
	data_misaligned_i,
	data_err_i,
	data_err_ack_o,
	irq_i,
	irq_sec_i,
	irq_id_i,
	m_irq_enable_i,
	u_irq_enable_i,
	irq_ack_o,
	irq_id_o,
	exc_cause_o,
	debug_mode_o,
	debug_cause_o,
	debug_csr_save_o,
	debug_req_i,
	debug_single_step_i,
	debug_ebreakm_i,
	debug_ebreaku_i,
	regfile_waddr_wb_i,
	regfile_we_wb_i,
	regfile_wdata_wb_i,
	regfile_alu_waddr_fw_i,
	regfile_alu_we_fw_i,
	regfile_alu_wdata_fw_i,
	mult_multicycle_i,
	perf_jump_o,
	perf_jr_stall_o,
	perf_ld_stall_o,
	perf_pipeline_stall_o
);
	parameter N_HWLP = 2;
	parameter N_HWLP_BITS = $clog2(N_HWLP);
	parameter PULP_SECURE = 0;
	parameter APU = 0;
	parameter FPU = 0;
	parameter Zfinx = 0;
	parameter FP_DIVSQRT = 0;
	parameter SHARED_FP = 0;
	parameter SHARED_DSP_MULT = 0;
	parameter SHARED_INT_MULT = 0;
	parameter SHARED_INT_DIV = 0;
	parameter SHARED_FP_DIVSQRT = 0;
	parameter WAPUTYPE = 1;
	parameter APU_NARGS_CPU = 3;
	parameter APU_WOP_CPU = 6;
	parameter APU_NDSFLAGS_CPU = 15;
	parameter APU_NUSFLAGS_CPU = 5;
	input wire clk;
	input wire rst_n;
	input wire test_en_i;
	input wire fregfile_disable_i;
	input wire fetch_enable_i;
	output wire ctrl_busy_o;
	output wire core_ctrl_firstfetch_o;
	output wire is_decoding_o;
	input wire [N_HWLP - 1:0] hwlp_dec_cnt_i;
	input wire is_hwlp_i;
	input wire instr_valid_i;
	input wire [31:0] instr_rdata_i;
	output wire instr_req_o;
	output reg branch_in_ex_o;
	input wire branch_decision_i;
	output wire [31:0] jump_target_o;
	output wire clear_instr_valid_o;
	output wire pc_set_o;
	output wire [2:0] pc_mux_o;
	output wire [2:0] exc_pc_mux_o;
	output wire trap_addr_mux_o;
	input wire illegal_c_insn_i;
	input wire is_compressed_i;
	input wire is_fetch_failed_i;
	input wire [31:0] pc_if_i;
	input wire [31:0] pc_id_i;
	output wire halt_if_o;
	output wire id_ready_o;
	input wire ex_ready_i;
	input wire wb_ready_i;
	output wire id_valid_o;
	input wire ex_valid_i;
	output reg [31:0] pc_ex_o;
	output reg [31:0] alu_operand_a_ex_o;
	output reg [31:0] alu_operand_b_ex_o;
	output reg [31:0] alu_operand_c_ex_o;
	output reg [4:0] bmask_a_ex_o;
	output reg [4:0] bmask_b_ex_o;
	output reg [1:0] imm_vec_ext_ex_o;
	output reg [1:0] alu_vec_mode_ex_o;
	output reg [5:0] regfile_waddr_ex_o;
	output reg regfile_we_ex_o;
	output reg [5:0] regfile_alu_waddr_ex_o;
	output reg regfile_alu_we_ex_o;
	output reg alu_en_ex_o;
	localparam riscv_defines_ALU_OP_WIDTH = 7;
	output reg [6:0] alu_operator_ex_o;
	output reg alu_is_clpx_ex_o;
	output reg alu_is_subrot_ex_o;
	output reg [1:0] alu_clpx_shift_ex_o;
	output reg [2:0] mult_operator_ex_o;
	output reg [31:0] mult_operand_a_ex_o;
	output reg [31:0] mult_operand_b_ex_o;
	output reg [31:0] mult_operand_c_ex_o;
	output reg mult_en_ex_o;
	output reg mult_sel_subword_ex_o;
	output reg [1:0] mult_signed_mode_ex_o;
	output reg [4:0] mult_imm_ex_o;
	output reg [31:0] mult_dot_op_a_ex_o;
	output reg [31:0] mult_dot_op_b_ex_o;
	output reg [31:0] mult_dot_op_c_ex_o;
	output reg [1:0] mult_dot_signed_ex_o;
	output reg mult_is_clpx_ex_o;
	output reg [1:0] mult_clpx_shift_ex_o;
	output reg mult_clpx_img_ex_o;
	output reg apu_en_ex_o;
	output reg [WAPUTYPE - 1:0] apu_type_ex_o;
	output reg [APU_WOP_CPU - 1:0] apu_op_ex_o;
	output reg [1:0] apu_lat_ex_o;
	output reg [(APU_NARGS_CPU * 32) - 1:0] apu_operands_ex_o;
	output reg [APU_NDSFLAGS_CPU - 1:0] apu_flags_ex_o;
	output reg [5:0] apu_waddr_ex_o;
	output wire [17:0] apu_read_regs_o;
	output wire [2:0] apu_read_regs_valid_o;
	input wire apu_read_dep_i;
	output wire [11:0] apu_write_regs_o;
	output wire [1:0] apu_write_regs_valid_o;
	input wire apu_write_dep_i;
	output wire apu_perf_dep_o;
	input wire apu_busy_i;
	localparam riscv_defines_C_RM = 3;
	input wire [2:0] frm_i;
	output reg csr_access_ex_o;
	output reg [1:0] csr_op_ex_o;
	input wire [1:0] current_priv_lvl_i;
	output wire csr_irq_sec_o;
	output wire [5:0] csr_cause_o;
	output wire csr_save_if_o;
	output wire csr_save_id_o;
	output wire csr_save_ex_o;
	output wire csr_restore_mret_id_o;
	output wire csr_restore_uret_id_o;
	output wire csr_restore_dret_id_o;
	output wire csr_save_cause_o;
	output wire [(N_HWLP * 32) - 1:0] hwlp_start_o;
	output wire [(N_HWLP * 32) - 1:0] hwlp_end_o;
	output wire [(N_HWLP * 32) - 1:0] hwlp_cnt_o;
	input wire [N_HWLP_BITS - 1:0] csr_hwlp_regid_i;
	input wire [2:0] csr_hwlp_we_i;
	input wire [31:0] csr_hwlp_data_i;
	output reg data_req_ex_o;
	output reg data_we_ex_o;
	output reg [1:0] data_type_ex_o;
	output reg [1:0] data_sign_ext_ex_o;
	output reg [1:0] data_reg_offset_ex_o;
	output reg data_load_event_ex_o;
	output reg data_misaligned_ex_o;
	output reg prepost_useincr_ex_o;
	input wire data_misaligned_i;
	input wire data_err_i;
	output wire data_err_ack_o;
	input wire irq_i;
	input wire irq_sec_i;
	input wire [4:0] irq_id_i;
	input wire m_irq_enable_i;
	input wire u_irq_enable_i;
	output wire irq_ack_o;
	output wire [4:0] irq_id_o;
	output wire [5:0] exc_cause_o;
	output wire debug_mode_o;
	output wire [2:0] debug_cause_o;
	output wire debug_csr_save_o;
	input wire debug_req_i;
	input wire debug_single_step_i;
	input wire debug_ebreakm_i;
	input wire debug_ebreaku_i;
	input wire [5:0] regfile_waddr_wb_i;
	input wire regfile_we_wb_i;
	input wire [31:0] regfile_wdata_wb_i;
	input wire [5:0] regfile_alu_waddr_fw_i;
	input wire regfile_alu_we_fw_i;
	input wire [31:0] regfile_alu_wdata_fw_i;
	input wire mult_multicycle_i;
	output wire perf_jump_o;
	output wire perf_jr_stall_o;
	output wire perf_ld_stall_o;
	output wire perf_pipeline_stall_o;
	wire [31:0] instr;
	wire deassert_we;
	wire illegal_insn_dec;
	wire ebrk_insn;
	wire mret_insn_dec;
	wire uret_insn_dec;
	wire dret_insn_dec;
	wire ecall_insn_dec;
	wire pipe_flush_dec;
	wire fencei_insn_dec;
	wire rega_used_dec;
	wire regb_used_dec;
	wire regc_used_dec;
	wire branch_taken_ex;
	wire [1:0] jump_in_id;
	wire [1:0] jump_in_dec;
	wire misaligned_stall;
	wire jr_stall;
	wire load_stall;
	wire csr_apu_stall;
	wire instr_multicycle;
	wire hwloop_mask;
	wire halt_id;
	wire [31:0] imm_i_type;
	wire [31:0] imm_iz_type;
	wire [31:0] imm_s_type;
	wire [31:0] imm_sb_type;
	wire [31:0] imm_u_type;
	wire [31:0] imm_uj_type;
	wire [31:0] imm_z_type;
	wire [31:0] imm_s2_type;
	wire [31:0] imm_bi_type;
	wire [31:0] imm_s3_type;
	wire [31:0] imm_vs_type;
	wire [31:0] imm_vu_type;
	wire [31:0] imm_shuffleb_type;
	wire [31:0] imm_shuffleh_type;
	reg [31:0] imm_shuffle_type;
	wire [31:0] imm_clip_type;
	reg [31:0] imm_a;
	reg [31:0] imm_b;
	reg [31:0] jump_target;
	wire irq_req_ctrl;
	wire irq_sec_ctrl;
	wire [4:0] irq_id_ctrl;
	wire exc_ack;
	wire exc_kill;
	wire [5:0] regfile_addr_ra_id;
	wire [5:0] regfile_addr_rb_id;
	reg [5:0] regfile_addr_rc_id;
	wire regfile_fp_a;
	wire regfile_fp_b;
	wire regfile_fp_c;
	wire regfile_fp_d;
	wire fregfile_ena;
	wire [5:0] regfile_waddr_id;
	wire [5:0] regfile_alu_waddr_id;
	wire regfile_alu_we_id;
	wire regfile_alu_we_dec_id;
	wire [31:0] regfile_data_ra_id;
	wire [31:0] regfile_data_rb_id;
	wire [31:0] regfile_data_rc_id;
	wire alu_en;
	wire [6:0] alu_operator;
	wire [2:0] alu_op_a_mux_sel;
	wire [2:0] alu_op_b_mux_sel;
	wire [1:0] alu_op_c_mux_sel;
	wire [1:0] regc_mux;
	wire [0:0] imm_a_mux_sel;
	wire [3:0] imm_b_mux_sel;
	wire [1:0] jump_target_mux_sel;
	wire [2:0] mult_operator;
	wire mult_en;
	wire mult_int_en;
	wire mult_sel_subword;
	wire [1:0] mult_signed_mode;
	wire mult_dot_en;
	wire [1:0] mult_dot_signed;
	localparam [31:0] fpnew_pkg_NUM_FP_FORMATS = 5;
	localparam [31:0] fpnew_pkg_FP_FORMAT_BITS = 3;
	localparam riscv_defines_C_FPNEW_FMTBITS = fpnew_pkg_FP_FORMAT_BITS;
	wire [2:0] fpu_src_fmt;
	wire [2:0] fpu_dst_fmt;
	localparam [31:0] fpnew_pkg_NUM_INT_FORMATS = 4;
	localparam [31:0] fpnew_pkg_INT_FORMAT_BITS = 2;
	localparam riscv_defines_C_FPNEW_IFMTBITS = fpnew_pkg_INT_FORMAT_BITS;
	wire [1:0] fpu_int_fmt;
	wire apu_en;
	wire [WAPUTYPE - 1:0] apu_type;
	wire [APU_WOP_CPU - 1:0] apu_op;
	wire [1:0] apu_lat;
	wire [(APU_NARGS_CPU * 32) - 1:0] apu_operands;
	reg [APU_NDSFLAGS_CPU - 1:0] apu_flags;
	wire [5:0] apu_waddr;
	reg [17:0] apu_read_regs;
	reg [2:0] apu_read_regs_valid;
	wire [11:0] apu_write_regs;
	wire [1:0] apu_write_regs_valid;
	wire [WAPUTYPE - 1:0] apu_flags_src;
	wire apu_stall;
	wire [2:0] fp_rnd_mode;
	wire regfile_we_id;
	wire regfile_alu_waddr_mux_sel;
	wire data_we_id;
	wire [1:0] data_type_id;
	wire [1:0] data_sign_ext_id;
	wire [1:0] data_reg_offset_id;
	wire data_req_id;
	wire data_load_event_id;
	wire [N_HWLP_BITS - 1:0] hwloop_regid;
	wire [N_HWLP_BITS - 1:0] hwloop_regid_int;
	wire [2:0] hwloop_we;
	wire [2:0] hwloop_we_int;
	wire [2:0] hwloop_we_masked;
	wire hwloop_target_mux_sel;
	wire hwloop_start_mux_sel;
	wire hwloop_cnt_mux_sel;
	reg [31:0] hwloop_target;
	wire [31:0] hwloop_start;
	reg [31:0] hwloop_start_int;
	wire [31:0] hwloop_end;
	wire [31:0] hwloop_cnt;
	reg [31:0] hwloop_cnt_int;
	wire hwloop_valid;
	wire csr_access;
	wire [1:0] csr_op;
	wire csr_status;
	wire prepost_useincr;
	wire [1:0] operand_a_fw_mux_sel;
	wire [1:0] operand_b_fw_mux_sel;
	wire [1:0] operand_c_fw_mux_sel;
	reg [31:0] operand_a_fw_id;
	reg [31:0] operand_b_fw_id;
	reg [31:0] operand_c_fw_id;
	reg [31:0] operand_b;
	reg [31:0] operand_b_vec;
	reg [31:0] operand_c;
	reg [31:0] operand_c_vec;
	reg [31:0] alu_operand_a;
	wire [31:0] alu_operand_b;
	wire [31:0] alu_operand_c;
	wire [0:0] bmask_a_mux;
	wire [1:0] bmask_b_mux;
	wire alu_bmask_a_mux_sel;
	wire alu_bmask_b_mux_sel;
	wire [0:0] mult_imm_mux;
	reg [4:0] bmask_a_id_imm;
	reg [4:0] bmask_b_id_imm;
	reg [4:0] bmask_a_id;
	reg [4:0] bmask_b_id;
	wire [1:0] imm_vec_ext_id;
	reg [4:0] mult_imm_id;
	wire [1:0] alu_vec_mode;
	wire scalar_replication;
	wire scalar_replication_c;
	wire reg_d_ex_is_reg_a_id;
	wire reg_d_ex_is_reg_b_id;
	wire reg_d_ex_is_reg_c_id;
	wire reg_d_wb_is_reg_a_id;
	wire reg_d_wb_is_reg_b_id;
	wire reg_d_wb_is_reg_c_id;
	wire reg_d_alu_is_reg_a_id;
	wire reg_d_alu_is_reg_b_id;
	wire reg_d_alu_is_reg_c_id;
	wire is_clpx;
	wire is_subrot;
	wire mret_dec;
	wire uret_dec;
	wire dret_dec;
	assign instr = instr_rdata_i;
	assign imm_i_type = {{20 {instr[31]}}, instr[31:20]};
	assign imm_iz_type = {20'b00000000000000000000, instr[31:20]};
	assign imm_s_type = {{20 {instr[31]}}, instr[31:25], instr[11:7]};
	assign imm_sb_type = {{19 {instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
	assign imm_u_type = {instr[31:12], 12'b000000000000};
	assign imm_uj_type = {{12 {instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};
	assign imm_z_type = {27'b000000000000000000000000000, instr[19:15]};
	assign imm_s2_type = {27'b000000000000000000000000000, instr[24:20]};
	assign imm_bi_type = {{27 {instr[24]}}, instr[24:20]};
	assign imm_s3_type = {27'b000000000000000000000000000, instr[29:25]};
	assign imm_vs_type = {{26 {instr[24]}}, instr[24:20], instr[25]};
	assign imm_vu_type = {26'b00000000000000000000000000, instr[24:20], instr[25]};
	assign imm_shuffleb_type = {6'b000000, instr[28:27], 6'b000000, instr[24:23], 6'b000000, instr[22:21], 6'b000000, instr[20], instr[25]};
	assign imm_shuffleh_type = {15'h0000, instr[20], 15'h0000, instr[25]};
	assign imm_clip_type = (32'h00000001 << instr[24:20]) - 1;
	assign fregfile_ena = (FPU && !Zfinx ? ~fregfile_disable_i : 1'b0);
	assign regfile_addr_ra_id = {fregfile_ena & regfile_fp_a, instr[19:15]};
	assign regfile_addr_rb_id = {fregfile_ena & regfile_fp_b, instr[24:20]};
	localparam riscv_defines_REGC_RD = 2'b01;
	localparam riscv_defines_REGC_S1 = 2'b10;
	localparam riscv_defines_REGC_S4 = 2'b00;
	localparam riscv_defines_REGC_ZERO = 2'b11;
	always @(*)
		case (regc_mux)
			riscv_defines_REGC_ZERO: regfile_addr_rc_id = 1'sb0;
			riscv_defines_REGC_RD: regfile_addr_rc_id = {fregfile_ena & regfile_fp_c, instr[11:7]};
			riscv_defines_REGC_S1: regfile_addr_rc_id = {fregfile_ena & regfile_fp_c, instr[19:15]};
			riscv_defines_REGC_S4: regfile_addr_rc_id = {fregfile_ena & regfile_fp_c, instr[31:27]};
			default: regfile_addr_rc_id = 1'sb0;
		endcase
	assign regfile_waddr_id = {fregfile_ena & regfile_fp_d, instr[11:7]};
	assign regfile_alu_waddr_id = (regfile_alu_waddr_mux_sel ? regfile_waddr_id : regfile_addr_ra_id);
	assign reg_d_ex_is_reg_a_id = ((regfile_waddr_ex_o == regfile_addr_ra_id) && (rega_used_dec == 1'b1)) && (regfile_addr_ra_id != {6 {1'sb0}});
	assign reg_d_ex_is_reg_b_id = ((regfile_waddr_ex_o == regfile_addr_rb_id) && (regb_used_dec == 1'b1)) && (regfile_addr_rb_id != {6 {1'sb0}});
	assign reg_d_ex_is_reg_c_id = ((regfile_waddr_ex_o == regfile_addr_rc_id) && (regc_used_dec == 1'b1)) && (regfile_addr_rc_id != {6 {1'sb0}});
	assign reg_d_wb_is_reg_a_id = ((regfile_waddr_wb_i == regfile_addr_ra_id) && (rega_used_dec == 1'b1)) && (regfile_addr_ra_id != {6 {1'sb0}});
	assign reg_d_wb_is_reg_b_id = ((regfile_waddr_wb_i == regfile_addr_rb_id) && (regb_used_dec == 1'b1)) && (regfile_addr_rb_id != {6 {1'sb0}});
	assign reg_d_wb_is_reg_c_id = ((regfile_waddr_wb_i == regfile_addr_rc_id) && (regc_used_dec == 1'b1)) && (regfile_addr_rc_id != {6 {1'sb0}});
	assign reg_d_alu_is_reg_a_id = ((regfile_alu_waddr_fw_i == regfile_addr_ra_id) && (rega_used_dec == 1'b1)) && (regfile_addr_ra_id != {6 {1'sb0}});
	assign reg_d_alu_is_reg_b_id = ((regfile_alu_waddr_fw_i == regfile_addr_rb_id) && (regb_used_dec == 1'b1)) && (regfile_addr_rb_id != {6 {1'sb0}});
	assign reg_d_alu_is_reg_c_id = ((regfile_alu_waddr_fw_i == regfile_addr_rc_id) && (regc_used_dec == 1'b1)) && (regfile_addr_rc_id != {6 {1'sb0}});
	assign clear_instr_valid_o = (id_ready_o | halt_id) | branch_taken_ex;
	assign branch_taken_ex = branch_in_ex_o & branch_decision_i;
	assign mult_en = mult_int_en | mult_dot_en;
	assign hwloop_regid_int = instr[7];
	always @(*)
		case (hwloop_target_mux_sel)
			1'b0: hwloop_target = pc_id_i + {imm_iz_type[30:0], 1'b0};
			1'b1: hwloop_target = pc_id_i + {imm_z_type[30:0], 1'b0};
		endcase
	always @(*)
		case (hwloop_start_mux_sel)
			1'b0: hwloop_start_int = hwloop_target;
			1'b1: hwloop_start_int = pc_if_i;
		endcase
	always @(*) begin : hwloop_cnt_mux
		case (hwloop_cnt_mux_sel)
			1'b0: hwloop_cnt_int = imm_iz_type;
			1'b1: hwloop_cnt_int = operand_a_fw_id;
		endcase
	end
	assign hwloop_we_masked = (hwloop_we_int & ~{3 {hwloop_mask}}) & {3 {id_ready_o}};
	assign hwloop_start = (hwloop_we_masked[0] ? hwloop_start_int : csr_hwlp_data_i);
	assign hwloop_end = (hwloop_we_masked[1] ? hwloop_target : csr_hwlp_data_i);
	assign hwloop_cnt = (hwloop_we_masked[2] ? hwloop_cnt_int : csr_hwlp_data_i);
	assign hwloop_regid = (|hwloop_we_masked ? hwloop_regid_int : csr_hwlp_regid_i);
	assign hwloop_we = (|hwloop_we_masked ? hwloop_we_masked : csr_hwlp_we_i);
	localparam riscv_defines_JT_COND = 2'b11;
	localparam riscv_defines_JT_JAL = 2'b01;
	localparam riscv_defines_JT_JALR = 2'b10;
	always @(*) begin : jump_target_mux
		case (jump_target_mux_sel)
			riscv_defines_JT_JAL: jump_target = pc_id_i + imm_uj_type;
			riscv_defines_JT_COND: jump_target = pc_id_i + imm_sb_type;
			riscv_defines_JT_JALR: jump_target = regfile_data_ra_id + imm_i_type;
			default: jump_target = regfile_data_ra_id + imm_i_type;
		endcase
	end
	assign jump_target_o = jump_target;
	localparam riscv_defines_OP_A_CURRPC = 3'b001;
	localparam riscv_defines_OP_A_IMM = 3'b010;
	localparam riscv_defines_OP_A_REGA_OR_FWD = 3'b000;
	localparam riscv_defines_OP_A_REGB_OR_FWD = 3'b011;
	localparam riscv_defines_OP_A_REGC_OR_FWD = 3'b100;
	always @(*) begin : alu_operand_a_mux
		case (alu_op_a_mux_sel)
			riscv_defines_OP_A_REGA_OR_FWD: alu_operand_a = operand_a_fw_id;
			riscv_defines_OP_A_REGB_OR_FWD: alu_operand_a = operand_b_fw_id;
			riscv_defines_OP_A_REGC_OR_FWD: alu_operand_a = operand_c_fw_id;
			riscv_defines_OP_A_CURRPC: alu_operand_a = pc_id_i;
			riscv_defines_OP_A_IMM: alu_operand_a = imm_a;
			default: alu_operand_a = operand_a_fw_id;
		endcase
	end
	localparam riscv_defines_IMMA_Z = 1'b0;
	localparam riscv_defines_IMMA_ZERO = 1'b1;
	always @(*) begin : immediate_a_mux
		case (imm_a_mux_sel)
			riscv_defines_IMMA_Z: imm_a = imm_z_type;
			riscv_defines_IMMA_ZERO: imm_a = 1'sb0;
			default: imm_a = 1'sb0;
		endcase
	end
	localparam riscv_defines_SEL_FW_EX = 2'b01;
	localparam riscv_defines_SEL_FW_WB = 2'b10;
	localparam riscv_defines_SEL_REGFILE = 2'b00;
	always @(*) begin : operand_a_fw_mux
		case (operand_a_fw_mux_sel)
			riscv_defines_SEL_FW_EX: operand_a_fw_id = regfile_alu_wdata_fw_i;
			riscv_defines_SEL_FW_WB: operand_a_fw_id = regfile_wdata_wb_i;
			riscv_defines_SEL_REGFILE: operand_a_fw_id = regfile_data_ra_id;
			default: operand_a_fw_id = regfile_data_ra_id;
		endcase
	end
	localparam riscv_defines_IMMB_BI = 4'b1011;
	localparam riscv_defines_IMMB_CLIP = 4'b1001;
	localparam riscv_defines_IMMB_I = 4'b0000;
	localparam riscv_defines_IMMB_PCINCR = 4'b0011;
	localparam riscv_defines_IMMB_S = 4'b0001;
	localparam riscv_defines_IMMB_S2 = 4'b0100;
	localparam riscv_defines_IMMB_S3 = 4'b0101;
	localparam riscv_defines_IMMB_SHUF = 4'b1000;
	localparam riscv_defines_IMMB_U = 4'b0010;
	localparam riscv_defines_IMMB_VS = 4'b0110;
	localparam riscv_defines_IMMB_VU = 4'b0111;
	always @(*) begin : immediate_b_mux
		case (imm_b_mux_sel)
			riscv_defines_IMMB_I: imm_b = imm_i_type;
			riscv_defines_IMMB_S: imm_b = imm_s_type;
			riscv_defines_IMMB_U: imm_b = imm_u_type;
			riscv_defines_IMMB_PCINCR: imm_b = (is_compressed_i && ~data_misaligned_i ? 32'h00000002 : 32'h00000004);
			riscv_defines_IMMB_S2: imm_b = imm_s2_type;
			riscv_defines_IMMB_BI: imm_b = imm_bi_type;
			riscv_defines_IMMB_S3: imm_b = imm_s3_type;
			riscv_defines_IMMB_VS: imm_b = imm_vs_type;
			riscv_defines_IMMB_VU: imm_b = imm_vu_type;
			riscv_defines_IMMB_SHUF: imm_b = imm_shuffle_type;
			riscv_defines_IMMB_CLIP: imm_b = {1'b0, imm_clip_type[31:1]};
			default: imm_b = imm_i_type;
		endcase
	end
	localparam riscv_defines_OP_B_BMASK = 3'b100;
	localparam riscv_defines_OP_B_IMM = 3'b010;
	localparam riscv_defines_OP_B_REGA_OR_FWD = 3'b011;
	localparam riscv_defines_OP_B_REGB_OR_FWD = 3'b000;
	localparam riscv_defines_OP_B_REGC_OR_FWD = 3'b001;
	always @(*) begin : alu_operand_b_mux
		case (alu_op_b_mux_sel)
			riscv_defines_OP_B_REGA_OR_FWD: operand_b = operand_a_fw_id;
			riscv_defines_OP_B_REGB_OR_FWD: operand_b = operand_b_fw_id;
			riscv_defines_OP_B_REGC_OR_FWD: operand_b = operand_c_fw_id;
			riscv_defines_OP_B_IMM: operand_b = imm_b;
			riscv_defines_OP_B_BMASK: operand_b = $unsigned(operand_b_fw_id[4:0]);
			default: operand_b = operand_b_fw_id;
		endcase
	end
	localparam riscv_defines_VEC_MODE8 = 2'b11;
	always @(*)
		if (alu_vec_mode == riscv_defines_VEC_MODE8) begin
			operand_b_vec = {4 {operand_b[7:0]}};
			imm_shuffle_type = imm_shuffleb_type;
		end
		else begin
			operand_b_vec = {2 {operand_b[15:0]}};
			imm_shuffle_type = imm_shuffleh_type;
		end
	assign alu_operand_b = (scalar_replication == 1'b1 ? operand_b_vec : operand_b);
	always @(*) begin : operand_b_fw_mux
		case (operand_b_fw_mux_sel)
			riscv_defines_SEL_FW_EX: operand_b_fw_id = regfile_alu_wdata_fw_i;
			riscv_defines_SEL_FW_WB: operand_b_fw_id = regfile_wdata_wb_i;
			riscv_defines_SEL_REGFILE: operand_b_fw_id = regfile_data_rb_id;
			default: operand_b_fw_id = regfile_data_rb_id;
		endcase
	end
	localparam riscv_defines_OP_C_JT = 2'b10;
	localparam riscv_defines_OP_C_REGB_OR_FWD = 2'b01;
	localparam riscv_defines_OP_C_REGC_OR_FWD = 2'b00;
	always @(*) begin : alu_operand_c_mux
		case (alu_op_c_mux_sel)
			riscv_defines_OP_C_REGC_OR_FWD: operand_c = operand_c_fw_id;
			riscv_defines_OP_C_REGB_OR_FWD: operand_c = operand_b_fw_id;
			riscv_defines_OP_C_JT: operand_c = jump_target;
			default: operand_c = operand_c_fw_id;
		endcase
	end
	always @(*)
		if (alu_vec_mode == riscv_defines_VEC_MODE8)
			operand_c_vec = {4 {operand_c[7:0]}};
		else
			operand_c_vec = {2 {operand_c[15:0]}};
	assign alu_operand_c = (scalar_replication_c == 1'b1 ? operand_c_vec : operand_c);
	always @(*) begin : operand_c_fw_mux
		case (operand_c_fw_mux_sel)
			riscv_defines_SEL_FW_EX: operand_c_fw_id = regfile_alu_wdata_fw_i;
			riscv_defines_SEL_FW_WB: operand_c_fw_id = regfile_wdata_wb_i;
			riscv_defines_SEL_REGFILE: operand_c_fw_id = regfile_data_rc_id;
			default: operand_c_fw_id = regfile_data_rc_id;
		endcase
	end
	localparam riscv_defines_BMASK_A_S3 = 1'b1;
	localparam riscv_defines_BMASK_A_ZERO = 1'b0;
	always @(*)
		case (bmask_a_mux)
			riscv_defines_BMASK_A_ZERO: bmask_a_id_imm = 1'sb0;
			riscv_defines_BMASK_A_S3: bmask_a_id_imm = imm_s3_type[4:0];
			default: bmask_a_id_imm = 1'sb0;
		endcase
	localparam riscv_defines_BMASK_B_ONE = 2'b11;
	localparam riscv_defines_BMASK_B_S2 = 2'b00;
	localparam riscv_defines_BMASK_B_S3 = 2'b01;
	localparam riscv_defines_BMASK_B_ZERO = 2'b10;
	always @(*)
		case (bmask_b_mux)
			riscv_defines_BMASK_B_ZERO: bmask_b_id_imm = 1'sb0;
			riscv_defines_BMASK_B_ONE: bmask_b_id_imm = 5'd1;
			riscv_defines_BMASK_B_S2: bmask_b_id_imm = imm_s2_type[4:0];
			riscv_defines_BMASK_B_S3: bmask_b_id_imm = imm_s3_type[4:0];
			default: bmask_b_id_imm = 1'sb0;
		endcase
	localparam riscv_defines_BMASK_A_IMM = 1'b1;
	localparam riscv_defines_BMASK_A_REG = 1'b0;
	always @(*)
		case (alu_bmask_a_mux_sel)
			riscv_defines_BMASK_A_IMM: bmask_a_id = bmask_a_id_imm;
			riscv_defines_BMASK_A_REG: bmask_a_id = operand_b_fw_id[9:5];
			default: bmask_a_id = bmask_a_id_imm;
		endcase
	localparam riscv_defines_BMASK_B_IMM = 1'b1;
	localparam riscv_defines_BMASK_B_REG = 1'b0;
	always @(*)
		case (alu_bmask_b_mux_sel)
			riscv_defines_BMASK_B_IMM: bmask_b_id = bmask_b_id_imm;
			riscv_defines_BMASK_B_REG: bmask_b_id = operand_b_fw_id[4:0];
			default: bmask_b_id = bmask_b_id_imm;
		endcase
	assign imm_vec_ext_id = imm_vu_type[1:0];
	localparam riscv_defines_MIMM_S3 = 1'b1;
	localparam riscv_defines_MIMM_ZERO = 1'b0;
	always @(*)
		case (mult_imm_mux)
			riscv_defines_MIMM_ZERO: mult_imm_id = 1'sb0;
			riscv_defines_MIMM_S3: mult_imm_id = imm_s3_type[4:0];
			default: mult_imm_id = 1'sb0;
		endcase
	localparam apu_core_package_APU_FLAGS_DSP_MULT = 0;
	localparam apu_core_package_APU_FLAGS_FP = 2;
	localparam apu_core_package_APU_FLAGS_FPNEW = 3;
	localparam apu_core_package_APU_FLAGS_INT_MULT = 1;
	generate
		if (APU == 1) begin : apu_op_preparation
			if (APU_NARGS_CPU >= 1) begin : genblk1
				assign apu_operands[0+:32] = alu_operand_a;
			end
			if (APU_NARGS_CPU >= 2) begin : genblk2
				assign apu_operands[32+:32] = alu_operand_b;
			end
			if (APU_NARGS_CPU >= 3) begin : genblk3
				assign apu_operands[64+:32] = alu_operand_c;
			end
			assign apu_waddr = regfile_alu_waddr_id;
			always @(*)
				case (apu_flags_src)
					apu_core_package_APU_FLAGS_INT_MULT: apu_flags = {7'h00, mult_imm_id, mult_signed_mode, mult_sel_subword};
					apu_core_package_APU_FLAGS_DSP_MULT: apu_flags = {13'h0000, mult_dot_signed};
					apu_core_package_APU_FLAGS_FP:
						if (FPU == 1)
							apu_flags = fp_rnd_mode;
						else
							apu_flags = 1'sb0;
					apu_core_package_APU_FLAGS_FPNEW:
						if (FPU == 1)
							apu_flags = {fpu_int_fmt, fpu_src_fmt, fpu_dst_fmt, fp_rnd_mode};
						else
							apu_flags = 1'sb0;
					default: apu_flags = 1'sb0;
				endcase
			always @(*)
				case (alu_op_a_mux_sel)
					riscv_defines_OP_A_REGA_OR_FWD: begin
						apu_read_regs[0+:6] = regfile_addr_ra_id;
						apu_read_regs_valid[0] = 1'b1;
					end
					riscv_defines_OP_A_REGB_OR_FWD: begin
						apu_read_regs[0+:6] = regfile_addr_rb_id;
						apu_read_regs_valid[0] = 1'b1;
					end
					default: begin
						apu_read_regs[0+:6] = regfile_addr_ra_id;
						apu_read_regs_valid[0] = 1'b0;
					end
				endcase
			always @(*)
				case (alu_op_b_mux_sel)
					riscv_defines_OP_B_REGA_OR_FWD: begin
						apu_read_regs[6+:6] = regfile_addr_ra_id;
						apu_read_regs_valid[1] = 1'b1;
					end
					riscv_defines_OP_B_REGB_OR_FWD: begin
						apu_read_regs[6+:6] = regfile_addr_rb_id;
						apu_read_regs_valid[1] = 1'b1;
					end
					riscv_defines_OP_B_REGC_OR_FWD: begin
						apu_read_regs[6+:6] = regfile_addr_rc_id;
						apu_read_regs_valid[1] = 1'b1;
					end
					default: begin
						apu_read_regs[6+:6] = regfile_addr_rb_id;
						apu_read_regs_valid[1] = 1'b0;
					end
				endcase
			always @(*)
				case (alu_op_c_mux_sel)
					riscv_defines_OP_C_REGB_OR_FWD: begin
						apu_read_regs[12+:6] = regfile_addr_rb_id;
						apu_read_regs_valid[2] = 1'b1;
					end
					riscv_defines_OP_C_REGC_OR_FWD: begin
						apu_read_regs[12+:6] = regfile_addr_rc_id;
						apu_read_regs_valid[2] = 1'b1;
					end
					default: begin
						apu_read_regs[12+:6] = regfile_addr_rc_id;
						apu_read_regs_valid[2] = 1'b0;
					end
				endcase
			assign apu_write_regs[0+:6] = regfile_alu_waddr_id;
			assign apu_write_regs_valid[0] = regfile_alu_we_id;
			assign apu_write_regs[6+:6] = regfile_waddr_id;
			assign apu_write_regs_valid[1] = regfile_we_id;
			assign apu_read_regs_o = apu_read_regs;
			assign apu_read_regs_valid_o = apu_read_regs_valid;
			assign apu_write_regs_o = apu_write_regs;
			assign apu_write_regs_valid_o = apu_write_regs_valid;
		end
		else begin : genblk1
			genvar i;
			for (i = 0; i < APU_NARGS_CPU; i = i + 1) begin : apu_tie_off
				assign apu_operands[i * 32+:32] = 1'sb0;
			end
			assign apu_waddr = 1'sb0;
			wire [APU_NDSFLAGS_CPU:1] sv2v_tmp_718B3;
			assign sv2v_tmp_718B3 = 1'sb0;
			always @(*) apu_flags = sv2v_tmp_718B3;
			assign apu_write_regs_o = 1'sb0;
			assign apu_read_regs_o = 1'sb0;
			assign apu_write_regs_valid_o = 1'sb0;
			assign apu_read_regs_valid_o = 1'sb0;
		end
	endgenerate
	assign apu_perf_dep_o = apu_stall;
	assign csr_apu_stall = csr_access & ((apu_en_ex_o & (apu_lat_ex_o[1] == 1'b1)) | apu_busy_i);
	always @(*)
		if ((FPU == 1) && (SHARED_FP != 1))
			;
	register_file_test_wrap #(
		.ADDR_WIDTH(6),
		.FPU(FPU),
		.Zfinx(Zfinx)
	) registers_i(
		.clk(clk),
		.rst_n(rst_n),
		.test_en_i(test_en_i),
		.raddr_a_i(regfile_addr_ra_id),
		.rdata_a_o(regfile_data_ra_id),
		.raddr_b_i(regfile_addr_rb_id),
		.rdata_b_o(regfile_data_rb_id),
		.raddr_c_i(regfile_addr_rc_id),
		.rdata_c_o(regfile_data_rc_id),
		.waddr_a_i(regfile_waddr_wb_i),
		.wdata_a_i(regfile_wdata_wb_i),
		.we_a_i(regfile_we_wb_i),
		.waddr_b_i(regfile_alu_waddr_fw_i),
		.wdata_b_i(regfile_alu_wdata_fw_i),
		.we_b_i(regfile_alu_we_fw_i),
		.BIST(1'b0),
		.CSN_T(),
		.WEN_T(),
		.A_T(),
		.D_T(),
		.Q_T()
	);
	riscv_decoder #(
		.FPU(FPU),
		.FP_DIVSQRT(FP_DIVSQRT),
		.PULP_SECURE(PULP_SECURE),
		.SHARED_FP(SHARED_FP),
		.SHARED_DSP_MULT(SHARED_DSP_MULT),
		.SHARED_INT_MULT(SHARED_INT_MULT),
		.SHARED_INT_DIV(SHARED_INT_DIV),
		.SHARED_FP_DIVSQRT(SHARED_FP_DIVSQRT),
		.WAPUTYPE(WAPUTYPE),
		.APU_WOP_CPU(APU_WOP_CPU)
	) decoder_i(
		.deassert_we_i(deassert_we),
		.data_misaligned_i(data_misaligned_i),
		.mult_multicycle_i(mult_multicycle_i),
		.instr_multicycle_o(instr_multicycle),
		.illegal_insn_o(illegal_insn_dec),
		.ebrk_insn_o(ebrk_insn),
		.mret_insn_o(mret_insn_dec),
		.uret_insn_o(uret_insn_dec),
		.dret_insn_o(dret_insn_dec),
		.mret_dec_o(mret_dec),
		.uret_dec_o(uret_dec),
		.dret_dec_o(dret_dec),
		.ecall_insn_o(ecall_insn_dec),
		.pipe_flush_o(pipe_flush_dec),
		.fencei_insn_o(fencei_insn_dec),
		.rega_used_o(rega_used_dec),
		.regb_used_o(regb_used_dec),
		.regc_used_o(regc_used_dec),
		.reg_fp_a_o(regfile_fp_a),
		.reg_fp_b_o(regfile_fp_b),
		.reg_fp_c_o(regfile_fp_c),
		.reg_fp_d_o(regfile_fp_d),
		.bmask_a_mux_o(bmask_a_mux),
		.bmask_b_mux_o(bmask_b_mux),
		.alu_bmask_a_mux_sel_o(alu_bmask_a_mux_sel),
		.alu_bmask_b_mux_sel_o(alu_bmask_b_mux_sel),
		.instr_rdata_i(instr),
		.illegal_c_insn_i(illegal_c_insn_i),
		.alu_en_o(alu_en),
		.alu_operator_o(alu_operator),
		.alu_op_a_mux_sel_o(alu_op_a_mux_sel),
		.alu_op_b_mux_sel_o(alu_op_b_mux_sel),
		.alu_op_c_mux_sel_o(alu_op_c_mux_sel),
		.alu_vec_mode_o(alu_vec_mode),
		.scalar_replication_o(scalar_replication),
		.scalar_replication_c_o(scalar_replication_c),
		.imm_a_mux_sel_o(imm_a_mux_sel),
		.imm_b_mux_sel_o(imm_b_mux_sel),
		.regc_mux_o(regc_mux),
		.is_clpx_o(is_clpx),
		.is_subrot_o(is_subrot),
		.mult_operator_o(mult_operator),
		.mult_int_en_o(mult_int_en),
		.mult_sel_subword_o(mult_sel_subword),
		.mult_signed_mode_o(mult_signed_mode),
		.mult_imm_mux_o(mult_imm_mux),
		.mult_dot_en_o(mult_dot_en),
		.mult_dot_signed_o(mult_dot_signed),
		.frm_i(frm_i),
		.fpu_src_fmt_o(fpu_src_fmt),
		.fpu_dst_fmt_o(fpu_dst_fmt),
		.fpu_int_fmt_o(fpu_int_fmt),
		.apu_en_o(apu_en),
		.apu_type_o(apu_type),
		.apu_op_o(apu_op),
		.apu_lat_o(apu_lat),
		.apu_flags_src_o(apu_flags_src),
		.fp_rnd_mode_o(fp_rnd_mode),
		.regfile_mem_we_o(regfile_we_id),
		.regfile_alu_we_o(regfile_alu_we_id),
		.regfile_alu_we_dec_o(regfile_alu_we_dec_id),
		.regfile_alu_waddr_sel_o(regfile_alu_waddr_mux_sel),
		.csr_access_o(csr_access),
		.csr_status_o(csr_status),
		.csr_op_o(csr_op),
		.current_priv_lvl_i(current_priv_lvl_i),
		.data_req_o(data_req_id),
		.data_we_o(data_we_id),
		.prepost_useincr_o(prepost_useincr),
		.data_type_o(data_type_id),
		.data_sign_extension_o(data_sign_ext_id),
		.data_reg_offset_o(data_reg_offset_id),
		.data_load_event_o(data_load_event_id),
		.hwloop_we_o(hwloop_we_int),
		.hwloop_target_mux_sel_o(hwloop_target_mux_sel),
		.hwloop_start_mux_sel_o(hwloop_start_mux_sel),
		.hwloop_cnt_mux_sel_o(hwloop_cnt_mux_sel),
		.jump_in_dec_o(jump_in_dec),
		.jump_in_id_o(jump_in_id),
		.jump_target_mux_sel_o(jump_target_mux_sel)
	);
	riscv_controller #(.FPU(FPU)) controller_i(
		.clk(clk),
		.rst_n(rst_n),
		.fetch_enable_i(fetch_enable_i),
		.ctrl_busy_o(ctrl_busy_o),
		.first_fetch_o(core_ctrl_firstfetch_o),
		.is_decoding_o(is_decoding_o),
		.is_fetch_failed_i(is_fetch_failed_i),
		.deassert_we_o(deassert_we),
		.illegal_insn_i(illegal_insn_dec),
		.ecall_insn_i(ecall_insn_dec),
		.mret_insn_i(mret_insn_dec),
		.uret_insn_i(uret_insn_dec),
		.dret_insn_i(dret_insn_dec),
		.mret_dec_i(mret_dec),
		.uret_dec_i(uret_dec),
		.dret_dec_i(dret_dec),
		.pipe_flush_i(pipe_flush_dec),
		.ebrk_insn_i(ebrk_insn),
		.fencei_insn_i(fencei_insn_dec),
		.csr_status_i(csr_status),
		.instr_multicycle_i(instr_multicycle),
		.hwloop_mask_o(hwloop_mask),
		.instr_valid_i(instr_valid_i),
		.instr_req_o(instr_req_o),
		.pc_set_o(pc_set_o),
		.pc_mux_o(pc_mux_o),
		.exc_pc_mux_o(exc_pc_mux_o),
		.exc_cause_o(exc_cause_o),
		.trap_addr_mux_o(trap_addr_mux_o),
		.data_req_ex_i(data_req_ex_o),
		.data_we_ex_i(data_we_ex_o),
		.data_misaligned_i(data_misaligned_i),
		.data_load_event_i(data_load_event_id),
		.data_err_i(data_err_i),
		.data_err_ack_o(data_err_ack_o),
		.mult_multicycle_i(mult_multicycle_i),
		.apu_en_i(apu_en),
		.apu_read_dep_i(apu_read_dep_i),
		.apu_write_dep_i(apu_write_dep_i),
		.apu_stall_o(apu_stall),
		.branch_taken_ex_i(branch_taken_ex),
		.jump_in_id_i(jump_in_id),
		.jump_in_dec_i(jump_in_dec),
		.irq_i(irq_i),
		.irq_req_ctrl_i(irq_req_ctrl),
		.irq_sec_ctrl_i(irq_sec_ctrl),
		.irq_id_ctrl_i(irq_id_ctrl),
		.m_IE_i(m_irq_enable_i),
		.u_IE_i(u_irq_enable_i),
		.current_priv_lvl_i(current_priv_lvl_i),
		.irq_ack_o(irq_ack_o),
		.irq_id_o(irq_id_o),
		.exc_ack_o(exc_ack),
		.exc_kill_o(exc_kill),
		.debug_mode_o(debug_mode_o),
		.debug_cause_o(debug_cause_o),
		.debug_csr_save_o(debug_csr_save_o),
		.debug_req_i(debug_req_i),
		.debug_single_step_i(debug_single_step_i),
		.debug_ebreakm_i(debug_ebreakm_i),
		.debug_ebreaku_i(debug_ebreaku_i),
		.csr_save_cause_o(csr_save_cause_o),
		.csr_cause_o(csr_cause_o),
		.csr_save_if_o(csr_save_if_o),
		.csr_save_id_o(csr_save_id_o),
		.csr_save_ex_o(csr_save_ex_o),
		.csr_restore_mret_id_o(csr_restore_mret_id_o),
		.csr_restore_uret_id_o(csr_restore_uret_id_o),
		.csr_restore_dret_id_o(csr_restore_dret_id_o),
		.csr_irq_sec_o(csr_irq_sec_o),
		.regfile_we_id_i(regfile_alu_we_dec_id),
		.regfile_alu_waddr_id_i(regfile_alu_waddr_id),
		.regfile_we_ex_i(regfile_we_ex_o),
		.regfile_waddr_ex_i(regfile_waddr_ex_o),
		.regfile_we_wb_i(regfile_we_wb_i),
		.regfile_alu_we_fw_i(regfile_alu_we_fw_i),
		.reg_d_ex_is_reg_a_i(reg_d_ex_is_reg_a_id),
		.reg_d_ex_is_reg_b_i(reg_d_ex_is_reg_b_id),
		.reg_d_ex_is_reg_c_i(reg_d_ex_is_reg_c_id),
		.reg_d_wb_is_reg_a_i(reg_d_wb_is_reg_a_id),
		.reg_d_wb_is_reg_b_i(reg_d_wb_is_reg_b_id),
		.reg_d_wb_is_reg_c_i(reg_d_wb_is_reg_c_id),
		.reg_d_alu_is_reg_a_i(reg_d_alu_is_reg_a_id),
		.reg_d_alu_is_reg_b_i(reg_d_alu_is_reg_b_id),
		.reg_d_alu_is_reg_c_i(reg_d_alu_is_reg_c_id),
		.operand_a_fw_mux_sel_o(operand_a_fw_mux_sel),
		.operand_b_fw_mux_sel_o(operand_b_fw_mux_sel),
		.operand_c_fw_mux_sel_o(operand_c_fw_mux_sel),
		.halt_if_o(halt_if_o),
		.halt_id_o(halt_id),
		.misaligned_stall_o(misaligned_stall),
		.jr_stall_o(jr_stall),
		.load_stall_o(load_stall),
		.id_ready_i(id_ready_o),
		.ex_valid_i(ex_valid_i),
		.wb_ready_i(wb_ready_i),
		.perf_jump_o(perf_jump_o),
		.perf_jr_stall_o(perf_jr_stall_o),
		.perf_ld_stall_o(perf_ld_stall_o),
		.perf_pipeline_stall_o(perf_pipeline_stall_o)
	);
	riscv_int_controller #(.PULP_SECURE(PULP_SECURE)) int_controller_i(
		.clk(clk),
		.rst_n(rst_n),
		.irq_req_ctrl_o(irq_req_ctrl),
		.irq_sec_ctrl_o(irq_sec_ctrl),
		.irq_id_ctrl_o(irq_id_ctrl),
		.ctrl_ack_i(exc_ack),
		.ctrl_kill_i(exc_kill),
		.irq_i(irq_i),
		.irq_sec_i(irq_sec_i),
		.irq_id_i(irq_id_i),
		.m_IE_i(m_irq_enable_i),
		.u_IE_i(u_irq_enable_i),
		.current_priv_lvl_i(current_priv_lvl_i)
	);
	riscv_hwloop_regs #(.N_REGS(N_HWLP)) hwloop_regs_i(
		.clk(clk),
		.rst_n(rst_n),
		.hwlp_start_data_i(hwloop_start),
		.hwlp_end_data_i(hwloop_end),
		.hwlp_cnt_data_i(hwloop_cnt),
		.hwlp_we_i(hwloop_we),
		.hwlp_regid_i(hwloop_regid),
		.valid_i(hwloop_valid),
		.hwlp_start_addr_o(hwlp_start_o),
		.hwlp_end_addr_o(hwlp_end_o),
		.hwlp_counter_o(hwlp_cnt_o),
		.hwlp_dec_cnt_i(hwlp_dec_cnt_i)
	);
	assign hwloop_valid = (instr_valid_i & clear_instr_valid_o) & is_hwlp_i;
	localparam riscv_defines_ALU_SLTU = 7'b0000011;
	localparam riscv_defines_BRANCH_COND = 2'b11;
	localparam riscv_defines_CSR_OP_NONE = 2'b00;
	always @(posedge clk or negedge rst_n) begin : ID_EX_PIPE_REGISTERS
		if (rst_n == 1'b0) begin
			alu_en_ex_o <= 1'sb0;
			alu_operator_ex_o <= riscv_defines_ALU_SLTU;
			alu_operand_a_ex_o <= 1'sb0;
			alu_operand_b_ex_o <= 1'sb0;
			alu_operand_c_ex_o <= 1'sb0;
			bmask_a_ex_o <= 1'sb0;
			bmask_b_ex_o <= 1'sb0;
			imm_vec_ext_ex_o <= 1'sb0;
			alu_vec_mode_ex_o <= 1'sb0;
			alu_clpx_shift_ex_o <= 2'b00;
			alu_is_clpx_ex_o <= 1'b0;
			alu_is_subrot_ex_o <= 1'b0;
			mult_operator_ex_o <= 1'sb0;
			mult_operand_a_ex_o <= 1'sb0;
			mult_operand_b_ex_o <= 1'sb0;
			mult_operand_c_ex_o <= 1'sb0;
			mult_en_ex_o <= 1'b0;
			mult_sel_subword_ex_o <= 1'b0;
			mult_signed_mode_ex_o <= 2'b00;
			mult_imm_ex_o <= 1'sb0;
			mult_dot_op_a_ex_o <= 1'sb0;
			mult_dot_op_b_ex_o <= 1'sb0;
			mult_dot_op_c_ex_o <= 1'sb0;
			mult_dot_signed_ex_o <= 1'sb0;
			mult_is_clpx_ex_o <= 1'b0;
			mult_clpx_shift_ex_o <= 2'b00;
			mult_clpx_img_ex_o <= 1'b0;
			apu_en_ex_o <= 1'sb0;
			apu_type_ex_o <= 1'sb0;
			apu_op_ex_o <= 1'sb0;
			apu_lat_ex_o <= 1'sb0;
			apu_operands_ex_o[0+:32] <= 1'sb0;
			apu_operands_ex_o[32+:32] <= 1'sb0;
			apu_operands_ex_o[64+:32] <= 1'sb0;
			apu_flags_ex_o <= 1'sb0;
			apu_waddr_ex_o <= 1'sb0;
			regfile_waddr_ex_o <= 6'b000000;
			regfile_we_ex_o <= 1'b0;
			regfile_alu_waddr_ex_o <= 6'b000000;
			regfile_alu_we_ex_o <= 1'b0;
			prepost_useincr_ex_o <= 1'b0;
			csr_access_ex_o <= 1'b0;
			csr_op_ex_o <= riscv_defines_CSR_OP_NONE;
			data_we_ex_o <= 1'b0;
			data_type_ex_o <= 2'b00;
			data_sign_ext_ex_o <= 2'b00;
			data_reg_offset_ex_o <= 2'b00;
			data_req_ex_o <= 1'b0;
			data_load_event_ex_o <= 1'b0;
			data_misaligned_ex_o <= 1'b0;
			pc_ex_o <= 1'sb0;
			branch_in_ex_o <= 1'b0;
		end
		else if (data_misaligned_i) begin
			if (ex_ready_i) begin
				if (prepost_useincr_ex_o == 1'b1)
					alu_operand_a_ex_o <= alu_operand_a;
				alu_operand_b_ex_o <= alu_operand_b;
				regfile_alu_we_ex_o <= regfile_alu_we_id;
				prepost_useincr_ex_o <= prepost_useincr;
				data_misaligned_ex_o <= 1'b1;
			end
		end
		else if (mult_multicycle_i)
			mult_operand_c_ex_o <= alu_operand_c;
		else if (id_valid_o) begin
			alu_en_ex_o <= alu_en | branch_taken_ex;
			if (alu_en | branch_taken_ex) begin
				alu_operator_ex_o <= (branch_taken_ex ? riscv_defines_ALU_SLTU : alu_operator);
				if (~branch_taken_ex) begin
					alu_operand_a_ex_o <= alu_operand_a;
					alu_operand_b_ex_o <= alu_operand_b;
					alu_operand_c_ex_o <= alu_operand_c;
					bmask_a_ex_o <= bmask_a_id;
					bmask_b_ex_o <= bmask_b_id;
					imm_vec_ext_ex_o <= imm_vec_ext_id;
					alu_vec_mode_ex_o <= alu_vec_mode;
					alu_is_clpx_ex_o <= is_clpx;
					alu_clpx_shift_ex_o <= instr[14:13];
					alu_is_subrot_ex_o <= is_subrot;
				end
			end
			mult_en_ex_o <= mult_en;
			if (mult_int_en) begin
				mult_operator_ex_o <= mult_operator;
				mult_sel_subword_ex_o <= mult_sel_subword;
				mult_signed_mode_ex_o <= mult_signed_mode;
				mult_operand_a_ex_o <= alu_operand_a;
				mult_operand_b_ex_o <= alu_operand_b;
				mult_operand_c_ex_o <= alu_operand_c;
				mult_imm_ex_o <= mult_imm_id;
			end
			if (mult_dot_en) begin
				mult_operator_ex_o <= mult_operator;
				mult_dot_signed_ex_o <= mult_dot_signed;
				mult_dot_op_a_ex_o <= alu_operand_a;
				mult_dot_op_b_ex_o <= alu_operand_b;
				mult_dot_op_c_ex_o <= alu_operand_c;
				mult_is_clpx_ex_o <= is_clpx;
				mult_clpx_shift_ex_o <= instr[14:13];
				mult_clpx_img_ex_o <= instr[25];
			end
			apu_en_ex_o <= apu_en;
			if (apu_en) begin
				apu_type_ex_o <= apu_type;
				apu_op_ex_o <= apu_op;
				apu_lat_ex_o <= apu_lat;
				apu_operands_ex_o <= apu_operands;
				apu_flags_ex_o <= apu_flags;
				apu_waddr_ex_o <= apu_waddr;
			end
			regfile_we_ex_o <= regfile_we_id;
			if (regfile_we_id)
				regfile_waddr_ex_o <= regfile_waddr_id;
			regfile_alu_we_ex_o <= regfile_alu_we_id;
			if (regfile_alu_we_id)
				regfile_alu_waddr_ex_o <= regfile_alu_waddr_id;
			prepost_useincr_ex_o <= prepost_useincr;
			csr_access_ex_o <= csr_access;
			csr_op_ex_o <= csr_op;
			data_req_ex_o <= data_req_id;
			if (data_req_id) begin
				data_we_ex_o <= data_we_id;
				data_type_ex_o <= data_type_id;
				data_sign_ext_ex_o <= data_sign_ext_id;
				data_reg_offset_ex_o <= data_reg_offset_id;
				data_load_event_ex_o <= data_load_event_id;
			end
			else
				data_load_event_ex_o <= 1'b0;
			data_misaligned_ex_o <= 1'b0;
			if ((jump_in_id == riscv_defines_BRANCH_COND) || data_req_id)
				pc_ex_o <= pc_id_i;
			branch_in_ex_o <= jump_in_id == riscv_defines_BRANCH_COND;
		end
		else if (ex_ready_i) begin
			regfile_we_ex_o <= 1'b0;
			regfile_alu_we_ex_o <= 1'b0;
			csr_op_ex_o <= riscv_defines_CSR_OP_NONE;
			data_req_ex_o <= 1'b0;
			data_load_event_ex_o <= 1'b0;
			data_misaligned_ex_o <= 1'b0;
			branch_in_ex_o <= 1'b0;
			apu_en_ex_o <= 1'b0;
			alu_operator_ex_o <= riscv_defines_ALU_SLTU;
			mult_en_ex_o <= 1'b0;
			alu_en_ex_o <= 1'b1;
		end
		else if (csr_access_ex_o)
			regfile_alu_we_ex_o <= 1'b0;
	end
	assign id_ready_o = ((((~misaligned_stall & ~jr_stall) & ~load_stall) & ~apu_stall) & ~csr_apu_stall) & ex_ready_i;
	assign id_valid_o = ~halt_id & id_ready_o;
endmodule
