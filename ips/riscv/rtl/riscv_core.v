module riscv_core (
	clk_i,
	rst_ni,
	clock_en_i,
	test_en_i,
	fregfile_disable_i,
	boot_addr_i,
	core_id_i,
	cluster_id_i,
	instr_req_o,
	instr_gnt_i,
	instr_rvalid_i,
	instr_addr_o,
	instr_rdata_i,
	data_req_o,
	data_gnt_i,
	data_rvalid_i,
	data_we_o,
	data_be_o,
	data_addr_o,
	data_wdata_o,
	data_rdata_i,
	apu_master_req_o,
	apu_master_ready_o,
	apu_master_gnt_i,
	apu_master_operands_o,
	apu_master_op_o,
	apu_master_type_o,
	apu_master_flags_o,
	apu_master_valid_i,
	apu_master_result_i,
	apu_master_flags_i,
	irq_i,
	irq_id_i,
	irq_ack_o,
	irq_id_o,
	irq_sec_i,
	sec_lvl_o,
	debug_req_i,
	fetch_enable_i,
	core_busy_o,
	ext_perf_counters_i
);
	parameter N_EXT_PERF_COUNTERS = 0;
	parameter INSTR_RDATA_WIDTH = 32;
	parameter PULP_SECURE = 0;
	parameter N_PMP_ENTRIES = 16;
	parameter USE_PMP = 1;
	parameter PULP_CLUSTER = 1;
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
	parameter DM_HaltAddress = 32'h1a110800;
	input wire clk_i;
	input wire rst_ni;
	input wire clock_en_i;
	input wire test_en_i;
	input wire fregfile_disable_i;
	input wire [31:0] boot_addr_i;
	input wire [3:0] core_id_i;
	input wire [5:0] cluster_id_i;
	output wire instr_req_o;
	input wire instr_gnt_i;
	input wire instr_rvalid_i;
	output wire [31:0] instr_addr_o;
	input wire [INSTR_RDATA_WIDTH - 1:0] instr_rdata_i;
	output wire data_req_o;
	input wire data_gnt_i;
	input wire data_rvalid_i;
	output wire data_we_o;
	output wire [3:0] data_be_o;
	output wire [31:0] data_addr_o;
	output wire [31:0] data_wdata_o;
	input wire [31:0] data_rdata_i;
	output wire apu_master_req_o;
	output wire apu_master_ready_o;
	input wire apu_master_gnt_i;
	output wire [(APU_NARGS_CPU * 32) - 1:0] apu_master_operands_o;
	output wire [APU_WOP_CPU - 1:0] apu_master_op_o;
	output wire [WAPUTYPE - 1:0] apu_master_type_o;
	output wire [APU_NDSFLAGS_CPU - 1:0] apu_master_flags_o;
	input wire apu_master_valid_i;
	input wire [31:0] apu_master_result_i;
	input wire [APU_NUSFLAGS_CPU - 1:0] apu_master_flags_i;
	input wire irq_i;
	input wire [4:0] irq_id_i;
	output wire irq_ack_o;
	output wire [4:0] irq_id_o;
	input wire irq_sec_i;
	output wire sec_lvl_o;
	input wire debug_req_i;
	input wire fetch_enable_i;
	output wire core_busy_o;
	input wire [N_EXT_PERF_COUNTERS - 1:0] ext_perf_counters_i;
	localparam N_HWLP = 2;
	localparam N_HWLP_BITS = 1;
	localparam APU = (((SHARED_DSP_MULT == 1) | (SHARED_INT_DIV == 1)) | (FPU == 1) ? 1 : 0);
	wire is_hwlp_id;
	wire [1:0] hwlp_dec_cnt_id;
	wire instr_valid_id;
	wire [31:0] instr_rdata_id;
	wire is_compressed_id;
	wire is_fetch_failed_id;
	wire illegal_c_insn_id;
	wire [31:0] pc_if;
	wire [31:0] pc_id;
	wire clear_instr_valid;
	wire pc_set;
	wire [2:0] pc_mux_id;
	wire [2:0] exc_pc_mux_id;
	wire [5:0] exc_cause;
	wire trap_addr_mux;
	wire lsu_load_err;
	wire lsu_store_err;
	wire is_decoding;
	wire useincr_addr_ex;
	wire data_misaligned;
	wire mult_multicycle;
	wire [31:0] jump_target_id;
	wire [31:0] jump_target_ex;
	wire branch_in_ex;
	wire branch_decision;
	wire ctrl_busy;
	wire if_busy;
	wire lsu_busy;
	wire apu_busy;
	wire [31:0] pc_ex;
	wire alu_en_ex;
	localparam riscv_defines_ALU_OP_WIDTH = 7;
	wire [6:0] alu_operator_ex;
	wire [31:0] alu_operand_a_ex;
	wire [31:0] alu_operand_b_ex;
	wire [31:0] alu_operand_c_ex;
	wire [4:0] bmask_a_ex;
	wire [4:0] bmask_b_ex;
	wire [1:0] imm_vec_ext_ex;
	wire [1:0] alu_vec_mode_ex;
	wire alu_is_clpx_ex;
	wire alu_is_subrot_ex;
	wire [1:0] alu_clpx_shift_ex;
	wire [2:0] mult_operator_ex;
	wire [31:0] mult_operand_a_ex;
	wire [31:0] mult_operand_b_ex;
	wire [31:0] mult_operand_c_ex;
	wire mult_en_ex;
	wire mult_sel_subword_ex;
	wire [1:0] mult_signed_mode_ex;
	wire [4:0] mult_imm_ex;
	wire [31:0] mult_dot_op_a_ex;
	wire [31:0] mult_dot_op_b_ex;
	wire [31:0] mult_dot_op_c_ex;
	wire [1:0] mult_dot_signed_ex;
	wire mult_is_clpx_ex_o;
	wire [1:0] mult_clpx_shift_ex;
	wire mult_clpx_img_ex;
	localparam riscv_defines_C_PC = 5;
	wire [4:0] fprec_csr;
	localparam riscv_defines_C_RM = 3;
	wire [2:0] frm_csr;
	localparam riscv_defines_C_FFLAG = 5;
	wire [4:0] fflags;
	wire [4:0] fflags_csr;
	wire fflags_we;
	wire apu_en_ex;
	wire [WAPUTYPE - 1:0] apu_type_ex;
	wire [APU_NDSFLAGS_CPU - 1:0] apu_flags_ex;
	wire [APU_WOP_CPU - 1:0] apu_op_ex;
	wire [1:0] apu_lat_ex;
	wire [(APU_NARGS_CPU * 32) - 1:0] apu_operands_ex;
	wire [5:0] apu_waddr_ex;
	wire [17:0] apu_read_regs;
	wire [2:0] apu_read_regs_valid;
	wire apu_read_dep;
	wire [11:0] apu_write_regs;
	wire [1:0] apu_write_regs_valid;
	wire apu_write_dep;
	wire perf_apu_type;
	wire perf_apu_cont;
	wire perf_apu_dep;
	wire perf_apu_wb;
	wire [5:0] regfile_waddr_ex;
	wire regfile_we_ex;
	wire [5:0] regfile_waddr_fw_wb_o;
	wire regfile_we_wb;
	wire [31:0] regfile_wdata;
	wire [5:0] regfile_alu_waddr_ex;
	wire regfile_alu_we_ex;
	wire [5:0] regfile_alu_waddr_fw;
	wire regfile_alu_we_fw;
	wire [31:0] regfile_alu_wdata_fw;
	wire csr_access_ex;
	wire [1:0] csr_op_ex;
	wire [23:0] mtvec;
	wire [23:0] utvec;
	wire csr_access;
	wire [1:0] csr_op;
	wire [11:0] csr_addr;
	wire [11:0] csr_addr_int;
	wire [31:0] csr_rdata;
	wire [31:0] csr_wdata;
	wire [1:0] current_priv_lvl;
	wire data_we_ex;
	wire [1:0] data_type_ex;
	wire [1:0] data_sign_ext_ex;
	wire [1:0] data_reg_offset_ex;
	wire data_req_ex;
	wire data_load_event_ex;
	wire data_misaligned_ex;
	wire [31:0] lsu_rdata;
	wire halt_if;
	wire id_ready;
	wire ex_ready;
	wire id_valid;
	wire ex_valid;
	wire wb_valid;
	wire lsu_ready_ex;
	wire lsu_ready_wb;
	wire apu_ready_wb;
	wire instr_req_int;
	wire m_irq_enable;
	wire u_irq_enable;
	wire csr_irq_sec;
	wire [31:0] mepc;
	wire [31:0] uepc;
	wire [31:0] depc;
	wire csr_save_cause;
	wire csr_save_if;
	wire csr_save_id;
	wire csr_save_ex;
	wire [5:0] csr_cause;
	wire csr_restore_mret_id;
	wire csr_restore_uret_id;
	wire csr_restore_dret_id;
	wire debug_mode;
	wire [2:0] debug_cause;
	wire debug_csr_save;
	wire debug_single_step;
	wire debug_ebreakm;
	wire debug_ebreaku;
	wire [63:0] hwlp_start;
	wire [63:0] hwlp_end;
	wire [63:0] hwlp_cnt;
	wire [0:0] csr_hwlp_regid;
	wire [2:0] csr_hwlp_we;
	wire [31:0] csr_hwlp_data;
	wire perf_imiss;
	wire perf_jump;
	wire perf_jr_stall;
	wire perf_ld_stall;
	wire perf_pipeline_stall;
	wire core_ctrl_firstfetch;
	wire core_busy_int;
	reg core_busy_q;
	wire [(N_PMP_ENTRIES * 32) - 1:0] pmp_addr;
	wire [(N_PMP_ENTRIES * 8) - 1:0] pmp_cfg;
	wire data_req_pmp;
	wire [31:0] data_addr_pmp;
	wire data_we_pmp;
	wire data_gnt_pmp;
	wire data_err_pmp;
	wire data_err_ack;
	wire instr_req_pmp;
	wire instr_gnt_pmp;
	wire [31:0] instr_addr_pmp;
	wire instr_err_pmp;
	wire is_interrupt;
	localparam riscv_defines_EXC_PC_IRQ = 3'b001;
	localparam riscv_defines_PC_EXCEPTION = 3'b100;
	assign is_interrupt = (pc_mux_id == riscv_defines_PC_EXCEPTION) && (exc_pc_mux_id == riscv_defines_EXC_PC_IRQ);
	generate
		if (SHARED_FP) begin : genblk1
			assign apu_master_type_o = apu_type_ex;
			assign apu_master_flags_o = apu_flags_ex;
			assign fflags_csr = apu_master_flags_i;
		end
		else begin : genblk1
			assign apu_master_type_o = 1'sb0;
			assign apu_master_flags_o = 1'sb0;
			assign fflags_csr = fflags;
		end
	endgenerate
	wire clk;
	wire clock_en;
	wire sleeping;
	assign core_busy_o = (core_ctrl_firstfetch ? 1'b1 : core_busy_q);
	assign core_busy_int = ((PULP_CLUSTER & data_load_event_ex) & data_req_o ? if_busy | apu_busy : ((if_busy | ctrl_busy) | lsu_busy) | apu_busy);
	assign clock_en = (PULP_CLUSTER ? clock_en_i | core_busy_o : (irq_i | debug_req_i) | core_busy_o);
	assign sleeping = ~core_busy_o;
	always @(posedge clk_i or negedge rst_ni)
		if (rst_ni == 1'b0)
			core_busy_q <= 1'b0;
		else
			core_busy_q <= core_busy_int;
	cluster_clock_gating core_clock_gate_i(
		.clk_i(clk_i),
		.en_i(clock_en),
		.test_en_i(test_en_i),
		.clk_o(clk)
	);
	riscv_if_stage #(
		.N_HWLP(N_HWLP),
		.RDATA_WIDTH(INSTR_RDATA_WIDTH),
		.FPU(FPU),
		.DM_HaltAddress(DM_HaltAddress)
	) if_stage_i(
		.clk(clk),
		.rst_n(rst_ni),
		.boot_addr_i(boot_addr_i[31:1]),
		.m_trap_base_addr_i(mtvec),
		.u_trap_base_addr_i(utvec),
		.trap_addr_mux_i(trap_addr_mux),
		.req_i(instr_req_int),
		.instr_req_o(instr_req_pmp),
		.instr_addr_o(instr_addr_pmp),
		.instr_gnt_i(instr_gnt_pmp),
		.instr_rvalid_i(instr_rvalid_i),
		.instr_rdata_i(instr_rdata_i),
		.instr_err_pmp_i(instr_err_pmp),
		.hwlp_dec_cnt_id_o(hwlp_dec_cnt_id),
		.is_hwlp_id_o(is_hwlp_id),
		.instr_valid_id_o(instr_valid_id),
		.instr_rdata_id_o(instr_rdata_id),
		.is_compressed_id_o(is_compressed_id),
		.illegal_c_insn_id_o(illegal_c_insn_id),
		.pc_if_o(pc_if),
		.pc_id_o(pc_id),
		.is_fetch_failed_o(is_fetch_failed_id),
		.clear_instr_valid_i(clear_instr_valid),
		.pc_set_i(pc_set),
		.mepc_i(mepc),
		.uepc_i(uepc),
		.depc_i(depc),
		.pc_mux_i(pc_mux_id),
		.exc_pc_mux_i(exc_pc_mux_id),
		.exc_vec_pc_mux_i(exc_cause[4:0]),
		.hwlp_start_i(hwlp_start),
		.hwlp_end_i(hwlp_end),
		.hwlp_cnt_i(hwlp_cnt),
		.jump_target_id_i(jump_target_id),
		.jump_target_ex_i(jump_target_ex),
		.halt_if_i(halt_if),
		.id_ready_i(id_ready),
		.if_busy_o(if_busy),
		.perf_imiss_o(perf_imiss)
	);
	wire mult_is_clpx_ex;
	riscv_id_stage #(
		.N_HWLP(N_HWLP),
		.PULP_SECURE(PULP_SECURE),
		.APU(APU),
		.FPU(FPU),
		.Zfinx(Zfinx),
		.FP_DIVSQRT(FP_DIVSQRT),
		.SHARED_FP(SHARED_FP),
		.SHARED_DSP_MULT(SHARED_DSP_MULT),
		.SHARED_INT_MULT(SHARED_INT_MULT),
		.SHARED_INT_DIV(SHARED_INT_DIV),
		.SHARED_FP_DIVSQRT(SHARED_FP_DIVSQRT),
		.WAPUTYPE(WAPUTYPE),
		.APU_NARGS_CPU(APU_NARGS_CPU),
		.APU_WOP_CPU(APU_WOP_CPU),
		.APU_NDSFLAGS_CPU(APU_NDSFLAGS_CPU),
		.APU_NUSFLAGS_CPU(APU_NUSFLAGS_CPU)
	) id_stage_i(
		.clk(clk),
		.rst_n(rst_ni),
		.test_en_i(test_en_i),
		.fregfile_disable_i(fregfile_disable_i),
		.fetch_enable_i(fetch_enable_i),
		.ctrl_busy_o(ctrl_busy),
		.core_ctrl_firstfetch_o(core_ctrl_firstfetch),
		.is_decoding_o(is_decoding),
		.hwlp_dec_cnt_i(hwlp_dec_cnt_id),
		.is_hwlp_i(is_hwlp_id),
		.instr_valid_i(instr_valid_id),
		.instr_rdata_i(instr_rdata_id),
		.instr_req_o(instr_req_int),
		.branch_in_ex_o(branch_in_ex),
		.branch_decision_i(branch_decision),
		.jump_target_o(jump_target_id),
		.clear_instr_valid_o(clear_instr_valid),
		.pc_set_o(pc_set),
		.pc_mux_o(pc_mux_id),
		.exc_pc_mux_o(exc_pc_mux_id),
		.exc_cause_o(exc_cause),
		.trap_addr_mux_o(trap_addr_mux),
		.illegal_c_insn_i(illegal_c_insn_id),
		.is_compressed_i(is_compressed_id),
		.is_fetch_failed_i(is_fetch_failed_id),
		.pc_if_i(pc_if),
		.pc_id_i(pc_id),
		.halt_if_o(halt_if),
		.id_ready_o(id_ready),
		.ex_ready_i(ex_ready),
		.wb_ready_i(lsu_ready_wb),
		.id_valid_o(id_valid),
		.ex_valid_i(ex_valid),
		.pc_ex_o(pc_ex),
		.alu_en_ex_o(alu_en_ex),
		.alu_operator_ex_o(alu_operator_ex),
		.alu_operand_a_ex_o(alu_operand_a_ex),
		.alu_operand_b_ex_o(alu_operand_b_ex),
		.alu_operand_c_ex_o(alu_operand_c_ex),
		.bmask_a_ex_o(bmask_a_ex),
		.bmask_b_ex_o(bmask_b_ex),
		.imm_vec_ext_ex_o(imm_vec_ext_ex),
		.alu_vec_mode_ex_o(alu_vec_mode_ex),
		.alu_is_clpx_ex_o(alu_is_clpx_ex),
		.alu_is_subrot_ex_o(alu_is_subrot_ex),
		.alu_clpx_shift_ex_o(alu_clpx_shift_ex),
		.regfile_waddr_ex_o(regfile_waddr_ex),
		.regfile_we_ex_o(regfile_we_ex),
		.regfile_alu_we_ex_o(regfile_alu_we_ex),
		.regfile_alu_waddr_ex_o(regfile_alu_waddr_ex),
		.mult_operator_ex_o(mult_operator_ex),
		.mult_en_ex_o(mult_en_ex),
		.mult_sel_subword_ex_o(mult_sel_subword_ex),
		.mult_signed_mode_ex_o(mult_signed_mode_ex),
		.mult_operand_a_ex_o(mult_operand_a_ex),
		.mult_operand_b_ex_o(mult_operand_b_ex),
		.mult_operand_c_ex_o(mult_operand_c_ex),
		.mult_imm_ex_o(mult_imm_ex),
		.mult_dot_op_a_ex_o(mult_dot_op_a_ex),
		.mult_dot_op_b_ex_o(mult_dot_op_b_ex),
		.mult_dot_op_c_ex_o(mult_dot_op_c_ex),
		.mult_dot_signed_ex_o(mult_dot_signed_ex),
		.mult_is_clpx_ex_o(mult_is_clpx_ex),
		.mult_clpx_shift_ex_o(mult_clpx_shift_ex),
		.mult_clpx_img_ex_o(mult_clpx_img_ex),
		.frm_i(frm_csr),
		.apu_en_ex_o(apu_en_ex),
		.apu_type_ex_o(apu_type_ex),
		.apu_op_ex_o(apu_op_ex),
		.apu_lat_ex_o(apu_lat_ex),
		.apu_operands_ex_o(apu_operands_ex),
		.apu_flags_ex_o(apu_flags_ex),
		.apu_waddr_ex_o(apu_waddr_ex),
		.apu_read_regs_o(apu_read_regs),
		.apu_read_regs_valid_o(apu_read_regs_valid),
		.apu_read_dep_i(apu_read_dep),
		.apu_write_regs_o(apu_write_regs),
		.apu_write_regs_valid_o(apu_write_regs_valid),
		.apu_write_dep_i(apu_write_dep),
		.apu_perf_dep_o(perf_apu_dep),
		.apu_busy_i(apu_busy),
		.csr_access_ex_o(csr_access_ex),
		.csr_op_ex_o(csr_op_ex),
		.current_priv_lvl_i(current_priv_lvl),
		.csr_irq_sec_o(csr_irq_sec),
		.csr_cause_o(csr_cause),
		.csr_save_if_o(csr_save_if),
		.csr_save_id_o(csr_save_id),
		.csr_save_ex_o(csr_save_ex),
		.csr_restore_mret_id_o(csr_restore_mret_id),
		.csr_restore_uret_id_o(csr_restore_uret_id),
		.csr_restore_dret_id_o(csr_restore_dret_id),
		.csr_save_cause_o(csr_save_cause),
		.hwlp_start_o(hwlp_start),
		.hwlp_end_o(hwlp_end),
		.hwlp_cnt_o(hwlp_cnt),
		.csr_hwlp_regid_i(csr_hwlp_regid),
		.csr_hwlp_we_i(csr_hwlp_we),
		.csr_hwlp_data_i(csr_hwlp_data),
		.data_req_ex_o(data_req_ex),
		.data_we_ex_o(data_we_ex),
		.data_type_ex_o(data_type_ex),
		.data_sign_ext_ex_o(data_sign_ext_ex),
		.data_reg_offset_ex_o(data_reg_offset_ex),
		.data_load_event_ex_o(data_load_event_ex),
		.data_misaligned_ex_o(data_misaligned_ex),
		.prepost_useincr_ex_o(useincr_addr_ex),
		.data_misaligned_i(data_misaligned),
		.data_err_i(data_err_pmp),
		.data_err_ack_o(data_err_ack),
		.irq_i(irq_i),
		.irq_sec_i((PULP_SECURE ? irq_sec_i : 1'b0)),
		.irq_id_i(irq_id_i),
		.m_irq_enable_i(m_irq_enable),
		.u_irq_enable_i(u_irq_enable),
		.irq_ack_o(irq_ack_o),
		.irq_id_o(irq_id_o),
		.debug_mode_o(debug_mode),
		.debug_cause_o(debug_cause),
		.debug_csr_save_o(debug_csr_save),
		.debug_req_i(debug_req_i),
		.debug_single_step_i(debug_single_step),
		.debug_ebreakm_i(debug_ebreakm),
		.debug_ebreaku_i(debug_ebreaku),
		.regfile_waddr_wb_i(regfile_waddr_fw_wb_o),
		.regfile_we_wb_i(regfile_we_wb),
		.regfile_wdata_wb_i(regfile_wdata),
		.regfile_alu_waddr_fw_i(regfile_alu_waddr_fw),
		.regfile_alu_we_fw_i(regfile_alu_we_fw),
		.regfile_alu_wdata_fw_i(regfile_alu_wdata_fw),
		.mult_multicycle_i(mult_multicycle),
		.perf_jump_o(perf_jump),
		.perf_jr_stall_o(perf_jr_stall),
		.perf_ld_stall_o(perf_ld_stall),
		.perf_pipeline_stall_o(perf_pipeline_stall)
	);
	riscv_ex_stage #(
		.FPU(FPU),
		.FP_DIVSQRT(FP_DIVSQRT),
		.SHARED_FP(SHARED_FP),
		.SHARED_DSP_MULT(SHARED_DSP_MULT),
		.SHARED_INT_DIV(SHARED_INT_DIV),
		.APU_NARGS_CPU(APU_NARGS_CPU),
		.APU_WOP_CPU(APU_WOP_CPU),
		.APU_NDSFLAGS_CPU(APU_NDSFLAGS_CPU),
		.APU_NUSFLAGS_CPU(APU_NUSFLAGS_CPU)
	) ex_stage_i(
		.clk(clk),
		.rst_n(rst_ni),
		.alu_en_i(alu_en_ex),
		.alu_operator_i(alu_operator_ex),
		.alu_operand_a_i(alu_operand_a_ex),
		.alu_operand_b_i(alu_operand_b_ex),
		.alu_operand_c_i(alu_operand_c_ex),
		.bmask_a_i(bmask_a_ex),
		.bmask_b_i(bmask_b_ex),
		.imm_vec_ext_i(imm_vec_ext_ex),
		.alu_vec_mode_i(alu_vec_mode_ex),
		.alu_is_clpx_i(alu_is_clpx_ex),
		.alu_is_subrot_i(alu_is_subrot_ex),
		.alu_clpx_shift_i(alu_clpx_shift_ex),
		.mult_operator_i(mult_operator_ex),
		.mult_operand_a_i(mult_operand_a_ex),
		.mult_operand_b_i(mult_operand_b_ex),
		.mult_operand_c_i(mult_operand_c_ex),
		.mult_en_i(mult_en_ex),
		.mult_sel_subword_i(mult_sel_subword_ex),
		.mult_signed_mode_i(mult_signed_mode_ex),
		.mult_imm_i(mult_imm_ex),
		.mult_dot_op_a_i(mult_dot_op_a_ex),
		.mult_dot_op_b_i(mult_dot_op_b_ex),
		.mult_dot_op_c_i(mult_dot_op_c_ex),
		.mult_dot_signed_i(mult_dot_signed_ex),
		.mult_is_clpx_i(mult_is_clpx_ex),
		.mult_clpx_shift_i(mult_clpx_shift_ex),
		.mult_clpx_img_i(mult_clpx_img_ex),
		.mult_multicycle_o(mult_multicycle),
		.fpu_prec_i(fprec_csr),
		.fpu_fflags_o(fflags),
		.fpu_fflags_we_o(fflags_we),
		.apu_en_i(apu_en_ex),
		.apu_op_i(apu_op_ex),
		.apu_lat_i(apu_lat_ex),
		.apu_operands_i(apu_operands_ex),
		.apu_waddr_i(apu_waddr_ex),
		.apu_flags_i(apu_flags_ex),
		.apu_read_regs_i(apu_read_regs),
		.apu_read_regs_valid_i(apu_read_regs_valid),
		.apu_read_dep_o(apu_read_dep),
		.apu_write_regs_i(apu_write_regs),
		.apu_write_regs_valid_i(apu_write_regs_valid),
		.apu_write_dep_o(apu_write_dep),
		.apu_perf_type_o(perf_apu_type),
		.apu_perf_cont_o(perf_apu_cont),
		.apu_perf_wb_o(perf_apu_wb),
		.apu_ready_wb_o(apu_ready_wb),
		.apu_busy_o(apu_busy),
		.apu_master_req_o(apu_master_req_o),
		.apu_master_ready_o(apu_master_ready_o),
		.apu_master_gnt_i(apu_master_gnt_i),
		.apu_master_operands_o(apu_master_operands_o),
		.apu_master_op_o(apu_master_op_o),
		.apu_master_valid_i(apu_master_valid_i),
		.apu_master_result_i(apu_master_result_i),
		.lsu_en_i(data_req_ex),
		.lsu_rdata_i(lsu_rdata),
		.csr_access_i(csr_access_ex),
		.csr_rdata_i(csr_rdata),
		.branch_in_ex_i(branch_in_ex),
		.regfile_alu_waddr_i(regfile_alu_waddr_ex),
		.regfile_alu_we_i(regfile_alu_we_ex),
		.regfile_waddr_i(regfile_waddr_ex),
		.regfile_we_i(regfile_we_ex),
		.regfile_waddr_wb_o(regfile_waddr_fw_wb_o),
		.regfile_we_wb_o(regfile_we_wb),
		.regfile_wdata_wb_o(regfile_wdata),
		.jump_target_o(jump_target_ex),
		.branch_decision_o(branch_decision),
		.regfile_alu_waddr_fw_o(regfile_alu_waddr_fw),
		.regfile_alu_we_fw_o(regfile_alu_we_fw),
		.regfile_alu_wdata_fw_o(regfile_alu_wdata_fw),
		.lsu_ready_ex_i(lsu_ready_ex),
		.lsu_err_i(data_err_pmp),
		.ex_ready_o(ex_ready),
		.ex_valid_o(ex_valid),
		.wb_ready_i(lsu_ready_wb)
	);
	riscv_load_store_unit load_store_unit_i(
		.clk(clk),
		.rst_n(rst_ni),
		.data_req_o(data_req_pmp),
		.data_gnt_i(data_gnt_pmp),
		.data_rvalid_i(data_rvalid_i),
		.data_err_i(data_err_pmp),
		.data_addr_o(data_addr_pmp),
		.data_we_o(data_we_o),
		.data_be_o(data_be_o),
		.data_wdata_o(data_wdata_o),
		.data_rdata_i(data_rdata_i),
		.data_we_ex_i(data_we_ex),
		.data_type_ex_i(data_type_ex),
		.data_wdata_ex_i(alu_operand_c_ex),
		.data_reg_offset_ex_i(data_reg_offset_ex),
		.data_sign_ext_ex_i(data_sign_ext_ex),
		.data_rdata_ex_o(lsu_rdata),
		.data_req_ex_i(data_req_ex),
		.operand_a_ex_i(alu_operand_a_ex),
		.operand_b_ex_i(alu_operand_b_ex),
		.addr_useincr_ex_i(useincr_addr_ex),
		.data_misaligned_ex_i(data_misaligned_ex),
		.data_misaligned_o(data_misaligned),
		.lsu_ready_ex_o(lsu_ready_ex),
		.lsu_ready_wb_o(lsu_ready_wb),
		.ex_valid_i(ex_valid),
		.busy_o(lsu_busy)
	);
	assign wb_valid = lsu_ready_wb & apu_ready_wb;
	riscv_cs_registers #(
		.N_EXT_CNT(N_EXT_PERF_COUNTERS),
		.FPU(FPU),
		.APU(APU),
		.PULP_SECURE(PULP_SECURE),
		.USE_PMP(USE_PMP),
		.N_PMP_ENTRIES(N_PMP_ENTRIES)
	) cs_registers_i(
		.clk(clk),
		.rst_n(rst_ni),
		.core_id_i(core_id_i),
		.cluster_id_i(cluster_id_i),
		.mtvec_o(mtvec),
		.utvec_o(utvec),
		.boot_addr_i(boot_addr_i[31:1]),
		.csr_access_i(csr_access),
		.csr_addr_i(csr_addr),
		.csr_wdata_i(csr_wdata),
		.csr_op_i(csr_op),
		.csr_rdata_o(csr_rdata),
		.frm_o(frm_csr),
		.fprec_o(fprec_csr),
		.fflags_i(fflags_csr),
		.fflags_we_i(fflags_we),
		.m_irq_enable_o(m_irq_enable),
		.u_irq_enable_o(u_irq_enable),
		.csr_irq_sec_i(csr_irq_sec),
		.sec_lvl_o(sec_lvl_o),
		.mepc_o(mepc),
		.uepc_o(uepc),
		.debug_mode_i(debug_mode),
		.debug_cause_i(debug_cause),
		.debug_csr_save_i(debug_csr_save),
		.depc_o(depc),
		.debug_single_step_o(debug_single_step),
		.debug_ebreakm_o(debug_ebreakm),
		.debug_ebreaku_o(debug_ebreaku),
		.priv_lvl_o(current_priv_lvl),
		.pmp_addr_o(pmp_addr),
		.pmp_cfg_o(pmp_cfg),
		.pc_if_i(pc_if),
		.pc_id_i(pc_id),
		.pc_ex_i(pc_ex),
		.csr_save_if_i(csr_save_if),
		.csr_save_id_i(csr_save_id),
		.csr_save_ex_i(csr_save_ex),
		.csr_restore_mret_i(csr_restore_mret_id),
		.csr_restore_uret_i(csr_restore_uret_id),
		.csr_restore_dret_i(csr_restore_dret_id),
		.csr_cause_i(csr_cause),
		.csr_save_cause_i(csr_save_cause),
		.hwlp_start_i(hwlp_start),
		.hwlp_end_i(hwlp_end),
		.hwlp_cnt_i(hwlp_cnt),
		.hwlp_regid_o(csr_hwlp_regid),
		.hwlp_we_o(csr_hwlp_we),
		.hwlp_data_o(csr_hwlp_data),
		.id_valid_i(id_valid),
		.is_compressed_i(is_compressed_id),
		.is_decoding_i(is_decoding),
		.imiss_i(perf_imiss),
		.pc_set_i(pc_set),
		.jump_i(perf_jump),
		.branch_i(branch_in_ex),
		.branch_taken_i(branch_decision),
		.ld_stall_i(perf_ld_stall),
		.jr_stall_i(perf_jr_stall),
		.pipeline_stall_i(perf_pipeline_stall),
		.apu_typeconflict_i(perf_apu_type),
		.apu_contention_i(perf_apu_cont),
		.apu_dep_i(perf_apu_dep),
		.apu_wb_i(perf_apu_wb),
		.mem_load_i((data_req_o & data_gnt_i) & ~data_we_o),
		.mem_store_i((data_req_o & data_gnt_i) & data_we_o),
		.ext_counters_i(ext_perf_counters_i)
	);
	assign csr_access = csr_access_ex;
	assign csr_addr = csr_addr_int;
	assign csr_wdata = alu_operand_a_ex;
	assign csr_op = csr_op_ex;
	assign csr_addr_int = (csr_access_ex ? alu_operand_b_ex[11:0] : {12 {1'sb0}});
	generate
		if (PULP_SECURE && USE_PMP) begin : RISCY_PMP
			riscv_pmp #(.N_PMP_ENTRIES(N_PMP_ENTRIES)) pmp_unit_i(
				.clk(clk),
				.rst_n(rst_ni),
				.pmp_privil_mode_i(current_priv_lvl),
				.pmp_addr_i(pmp_addr),
				.pmp_cfg_i(pmp_cfg),
				.data_req_i(data_req_pmp),
				.data_addr_i(data_addr_pmp),
				.data_we_i(data_we_o),
				.data_gnt_o(data_gnt_pmp),
				.data_req_o(data_req_o),
				.data_gnt_i(data_gnt_i),
				.data_addr_o(data_addr_o),
				.data_err_o(data_err_pmp),
				.data_err_ack_i(data_err_ack),
				.instr_req_i(instr_req_pmp),
				.instr_addr_i(instr_addr_pmp),
				.instr_gnt_o(instr_gnt_pmp),
				.instr_req_o(instr_req_o),
				.instr_gnt_i(instr_gnt_i),
				.instr_addr_o(instr_addr_o),
				.instr_err_o(instr_err_pmp)
			);
		end
		else begin : genblk2
			assign instr_req_o = instr_req_pmp;
			assign instr_addr_o = instr_addr_pmp;
			assign instr_gnt_pmp = instr_gnt_i;
			assign instr_err_pmp = 1'b0;
			assign data_req_o = data_req_pmp;
			assign data_addr_o = data_addr_pmp;
			assign data_gnt_pmp = data_gnt_i;
			assign data_err_pmp = 1'b0;
		end
	endgenerate
	wire tracer_clk;
	assign #(1) tracer_clk = clk_i;
	riscv_tracer riscv_tracer_i(
		.clk(tracer_clk),
		.rst_n(rst_ni),
		.fetch_enable(fetch_enable_i),
		.core_id(core_id_i),
		.cluster_id(cluster_id_i),
		.pc(id_stage_i.pc_id_i),
		.instr(id_stage_i.instr),
		.compressed(id_stage_i.is_compressed_i),
		.id_valid(id_stage_i.id_valid_o),
		.is_decoding(id_stage_i.is_decoding_o),
		.pipe_flush(id_stage_i.controller_i.pipe_flush_i),
		.mret(id_stage_i.controller_i.mret_insn_i),
		.uret(id_stage_i.controller_i.uret_insn_i),
		.dret(id_stage_i.controller_i.dret_insn_i),
		.ecall(id_stage_i.controller_i.ecall_insn_i),
		.ebreak(id_stage_i.controller_i.ebrk_insn_i),
		.rs1_value(id_stage_i.operand_a_fw_id),
		.rs2_value(id_stage_i.operand_b_fw_id),
		.rs3_value(id_stage_i.alu_operand_c),
		.rs2_value_vec(id_stage_i.alu_operand_b),
		.rs1_is_fp(id_stage_i.regfile_fp_a),
		.rs2_is_fp(id_stage_i.regfile_fp_b),
		.rs3_is_fp(id_stage_i.regfile_fp_c),
		.rd_is_fp(id_stage_i.regfile_fp_d),
		.ex_valid(ex_valid),
		.ex_reg_addr(regfile_alu_waddr_fw),
		.ex_reg_we(regfile_alu_we_fw),
		.ex_reg_wdata(regfile_alu_wdata_fw),
		.ex_data_addr(data_addr_o),
		.ex_data_req(data_req_o),
		.ex_data_gnt(data_gnt_i),
		.ex_data_we(data_we_o),
		.ex_data_wdata(data_wdata_o),
		.wb_bypass(ex_stage_i.branch_in_ex_i),
		.wb_valid(wb_valid),
		.wb_reg_addr(regfile_waddr_fw_wb_o),
		.wb_reg_we(regfile_we_wb),
		.wb_reg_wdata(regfile_wdata),
		.imm_u_type(id_stage_i.imm_u_type),
		.imm_uj_type(id_stage_i.imm_uj_type),
		.imm_i_type(id_stage_i.imm_i_type),
		.imm_iz_type(id_stage_i.imm_iz_type[11:0]),
		.imm_z_type(id_stage_i.imm_z_type),
		.imm_s_type(id_stage_i.imm_s_type),
		.imm_sb_type(id_stage_i.imm_sb_type),
		.imm_s2_type(id_stage_i.imm_s2_type),
		.imm_s3_type(id_stage_i.imm_s3_type),
		.imm_vs_type(id_stage_i.imm_vs_type),
		.imm_vu_type(id_stage_i.imm_vu_type),
		.imm_shuffle_type(id_stage_i.imm_shuffle_type),
		.imm_clip_type(id_stage_i.instr_rdata_i[11:7])
	);
endmodule
