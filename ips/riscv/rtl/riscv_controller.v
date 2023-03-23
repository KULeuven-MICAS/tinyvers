module riscv_controller (
	clk,
	rst_n,
	fetch_enable_i,
	ctrl_busy_o,
	first_fetch_o,
	is_decoding_o,
	is_fetch_failed_i,
	deassert_we_o,
	illegal_insn_i,
	ecall_insn_i,
	mret_insn_i,
	uret_insn_i,
	dret_insn_i,
	mret_dec_i,
	uret_dec_i,
	dret_dec_i,
	pipe_flush_i,
	ebrk_insn_i,
	fencei_insn_i,
	csr_status_i,
	instr_multicycle_i,
	hwloop_mask_o,
	instr_valid_i,
	instr_req_o,
	pc_set_o,
	pc_mux_o,
	exc_pc_mux_o,
	trap_addr_mux_o,
	data_req_ex_i,
	data_we_ex_i,
	data_misaligned_i,
	data_load_event_i,
	data_err_i,
	data_err_ack_o,
	mult_multicycle_i,
	apu_en_i,
	apu_read_dep_i,
	apu_write_dep_i,
	apu_stall_o,
	branch_taken_ex_i,
	jump_in_id_i,
	jump_in_dec_i,
	irq_i,
	irq_req_ctrl_i,
	irq_sec_ctrl_i,
	irq_id_ctrl_i,
	m_IE_i,
	u_IE_i,
	current_priv_lvl_i,
	irq_ack_o,
	irq_id_o,
	exc_cause_o,
	exc_ack_o,
	exc_kill_o,
	debug_mode_o,
	debug_cause_o,
	debug_csr_save_o,
	debug_req_i,
	debug_single_step_i,
	debug_ebreakm_i,
	debug_ebreaku_i,
	csr_save_if_o,
	csr_save_id_o,
	csr_save_ex_o,
	csr_cause_o,
	csr_irq_sec_o,
	csr_restore_mret_id_o,
	csr_restore_uret_id_o,
	csr_restore_dret_id_o,
	csr_save_cause_o,
	regfile_we_id_i,
	regfile_alu_waddr_id_i,
	regfile_we_ex_i,
	regfile_waddr_ex_i,
	regfile_we_wb_i,
	regfile_alu_we_fw_i,
	operand_a_fw_mux_sel_o,
	operand_b_fw_mux_sel_o,
	operand_c_fw_mux_sel_o,
	reg_d_ex_is_reg_a_i,
	reg_d_ex_is_reg_b_i,
	reg_d_ex_is_reg_c_i,
	reg_d_wb_is_reg_a_i,
	reg_d_wb_is_reg_b_i,
	reg_d_wb_is_reg_c_i,
	reg_d_alu_is_reg_a_i,
	reg_d_alu_is_reg_b_i,
	reg_d_alu_is_reg_c_i,
	halt_if_o,
	halt_id_o,
	misaligned_stall_o,
	jr_stall_o,
	load_stall_o,
	id_ready_i,
	ex_valid_i,
	wb_ready_i,
	perf_jump_o,
	perf_jr_stall_o,
	perf_ld_stall_o,
	perf_pipeline_stall_o
);
	parameter FPU = 0;
	input wire clk;
	input wire rst_n;
	input wire fetch_enable_i;
	output reg ctrl_busy_o;
	output reg first_fetch_o;
	output reg is_decoding_o;
	input wire is_fetch_failed_i;
	output reg deassert_we_o;
	input wire illegal_insn_i;
	input wire ecall_insn_i;
	input wire mret_insn_i;
	input wire uret_insn_i;
	input wire dret_insn_i;
	input wire mret_dec_i;
	input wire uret_dec_i;
	input wire dret_dec_i;
	input wire pipe_flush_i;
	input wire ebrk_insn_i;
	input wire fencei_insn_i;
	input wire csr_status_i;
	input wire instr_multicycle_i;
	output reg hwloop_mask_o;
	input wire instr_valid_i;
	output reg instr_req_o;
	output reg pc_set_o;
	output reg [2:0] pc_mux_o;
	output reg [2:0] exc_pc_mux_o;
	output reg trap_addr_mux_o;
	input wire data_req_ex_i;
	input wire data_we_ex_i;
	input wire data_misaligned_i;
	input wire data_load_event_i;
	input wire data_err_i;
	output reg data_err_ack_o;
	input wire mult_multicycle_i;
	input wire apu_en_i;
	input wire apu_read_dep_i;
	input wire apu_write_dep_i;
	output wire apu_stall_o;
	input wire branch_taken_ex_i;
	input wire [1:0] jump_in_id_i;
	input wire [1:0] jump_in_dec_i;
	input wire irq_i;
	input wire irq_req_ctrl_i;
	input wire irq_sec_ctrl_i;
	input wire [4:0] irq_id_ctrl_i;
	input wire m_IE_i;
	input wire u_IE_i;
	input wire [1:0] current_priv_lvl_i;
	output reg irq_ack_o;
	output reg [4:0] irq_id_o;
	output reg [5:0] exc_cause_o;
	output reg exc_ack_o;
	output reg exc_kill_o;
	output wire debug_mode_o;
	output reg [2:0] debug_cause_o;
	output reg debug_csr_save_o;
	input wire debug_req_i;
	input wire debug_single_step_i;
	input wire debug_ebreakm_i;
	input wire debug_ebreaku_i;
	output reg csr_save_if_o;
	output reg csr_save_id_o;
	output reg csr_save_ex_o;
	output reg [5:0] csr_cause_o;
	output reg csr_irq_sec_o;
	output reg csr_restore_mret_id_o;
	output reg csr_restore_uret_id_o;
	output reg csr_restore_dret_id_o;
	output reg csr_save_cause_o;
	input wire regfile_we_id_i;
	input wire [5:0] regfile_alu_waddr_id_i;
	input wire regfile_we_ex_i;
	input wire [5:0] regfile_waddr_ex_i;
	input wire regfile_we_wb_i;
	input wire regfile_alu_we_fw_i;
	output reg [1:0] operand_a_fw_mux_sel_o;
	output reg [1:0] operand_b_fw_mux_sel_o;
	output reg [1:0] operand_c_fw_mux_sel_o;
	input wire reg_d_ex_is_reg_a_i;
	input wire reg_d_ex_is_reg_b_i;
	input wire reg_d_ex_is_reg_c_i;
	input wire reg_d_wb_is_reg_a_i;
	input wire reg_d_wb_is_reg_b_i;
	input wire reg_d_wb_is_reg_c_i;
	input wire reg_d_alu_is_reg_a_i;
	input wire reg_d_alu_is_reg_b_i;
	input wire reg_d_alu_is_reg_c_i;
	output reg halt_if_o;
	output reg halt_id_o;
	output wire misaligned_stall_o;
	output reg jr_stall_o;
	output reg load_stall_o;
	input wire id_ready_i;
	input wire ex_valid_i;
	input wire wb_ready_i;
	output wire perf_jump_o;
	output wire perf_jr_stall_o;
	output wire perf_ld_stall_o;
	output reg perf_pipeline_stall_o;
	reg [4:0] ctrl_fsm_cs;
	reg [4:0] ctrl_fsm_ns;
	reg jump_done;
	reg jump_done_q;
	reg jump_in_dec;
	reg branch_in_id;
	reg boot_done;
	reg boot_done_q;
	reg irq_enable_int;
	reg data_err_q;
	reg debug_mode_q;
	reg debug_mode_n;
	reg ebrk_force_debug_mode;
	reg illegal_insn_q;
	reg illegal_insn_n;
	reg instr_valid_irq_flush_n;
	reg instr_valid_irq_flush_q;
	always @(negedge clk)
		if (is_decoding_o && illegal_insn_i)
			$display("%t: Illegal instruction (core %0d) at PC 0x%h:", $time, riscv_core.core_id_i, riscv_id_stage.pc_id_i);
	localparam riscv_defines_BRANCH_COND = 2'b11;
	localparam riscv_defines_BRANCH_JAL = 2'b01;
	localparam riscv_defines_BRANCH_JALR = 2'b10;
	localparam riscv_defines_DBG_CAUSE_EBREAK = 3'h1;
	localparam riscv_defines_DBG_CAUSE_HALTREQ = 3'h3;
	localparam riscv_defines_DBG_CAUSE_STEP = 3'h4;
	localparam riscv_defines_EXC_CAUSE_BREAKPOINT = 6'h03;
	localparam riscv_defines_EXC_CAUSE_ECALL_MMODE = 6'h0b;
	localparam riscv_defines_EXC_CAUSE_ECALL_UMODE = 6'h08;
	localparam riscv_defines_EXC_CAUSE_ILLEGAL_INSN = 6'h02;
	localparam riscv_defines_EXC_CAUSE_INSTR_FAULT = 6'h01;
	localparam riscv_defines_EXC_CAUSE_LOAD_FAULT = 6'h05;
	localparam riscv_defines_EXC_CAUSE_STORE_FAULT = 6'h07;
	localparam riscv_defines_EXC_PC_DBD = 3'b010;
	localparam riscv_defines_EXC_PC_EXCEPTION = 3'b000;
	localparam riscv_defines_EXC_PC_IRQ = 3'b001;
	localparam riscv_defines_PC_BOOT = 3'b000;
	localparam riscv_defines_PC_BRANCH = 3'b011;
	localparam riscv_defines_PC_DRET = 3'b111;
	localparam riscv_defines_PC_EXCEPTION = 3'b100;
	localparam riscv_defines_PC_FENCEI = 3'b001;
	localparam riscv_defines_PC_JUMP = 3'b010;
	localparam riscv_defines_PC_MRET = 3'b101;
	localparam riscv_defines_PC_URET = 3'b110;
	localparam riscv_defines_TRAP_MACHINE = 1'b0;
	localparam riscv_defines_TRAP_USER = 1'b1;
	always @(*) begin
		instr_req_o = 1'b1;
		exc_ack_o = 1'b0;
		exc_kill_o = 1'b0;
		data_err_ack_o = 1'b0;
		csr_save_if_o = 1'b0;
		csr_save_id_o = 1'b0;
		csr_save_ex_o = 1'b0;
		csr_restore_mret_id_o = 1'b0;
		csr_restore_uret_id_o = 1'b0;
		csr_restore_dret_id_o = 1'b0;
		csr_save_cause_o = 1'b0;
		exc_cause_o = 1'sb0;
		exc_pc_mux_o = riscv_defines_EXC_PC_IRQ;
		trap_addr_mux_o = riscv_defines_TRAP_MACHINE;
		csr_cause_o = 1'sb0;
		csr_irq_sec_o = 1'b0;
		pc_mux_o = riscv_defines_PC_BOOT;
		pc_set_o = 1'b0;
		jump_done = jump_done_q;
		ctrl_fsm_ns = ctrl_fsm_cs;
		ctrl_busy_o = 1'b1;
		first_fetch_o = 1'b0;
		halt_if_o = 1'b0;
		halt_id_o = 1'b0;
		irq_ack_o = 1'b0;
		irq_id_o = irq_id_ctrl_i;
		boot_done = 1'b0;
		jump_in_dec = (jump_in_dec_i == riscv_defines_BRANCH_JALR) || (jump_in_dec_i == riscv_defines_BRANCH_JAL);
		branch_in_id = jump_in_id_i == riscv_defines_BRANCH_COND;
		irq_enable_int = ((u_IE_i | irq_sec_ctrl_i) & (current_priv_lvl_i == 2'b00)) | (m_IE_i & (current_priv_lvl_i == 2'b11));
		ebrk_force_debug_mode = (debug_ebreakm_i && (current_priv_lvl_i == 2'b11)) || (debug_ebreaku_i && (current_priv_lvl_i == 2'b00));
		debug_csr_save_o = 1'b0;
		debug_cause_o = riscv_defines_DBG_CAUSE_EBREAK;
		debug_mode_n = debug_mode_q;
		illegal_insn_n = illegal_insn_q;
		perf_pipeline_stall_o = 1'b0;
		instr_valid_irq_flush_n = 1'b0;
		hwloop_mask_o = 1'b0;
		case (ctrl_fsm_cs)
			5'd0: begin
				is_decoding_o = 1'b0;
				instr_req_o = 1'b0;
				if (fetch_enable_i == 1'b1)
					ctrl_fsm_ns = 5'd1;
			end
			5'd1: begin
				is_decoding_o = 1'b0;
				instr_req_o = 1'b1;
				pc_mux_o = riscv_defines_PC_BOOT;
				pc_set_o = 1'b1;
				boot_done = 1'b1;
				ctrl_fsm_ns = 5'd4;
			end
			5'd3: begin
				is_decoding_o = 1'b0;
				ctrl_busy_o = 1'b0;
				instr_req_o = 1'b0;
				halt_if_o = 1'b1;
				halt_id_o = 1'b1;
				ctrl_fsm_ns = 5'd2;
			end
			5'd2: begin
				is_decoding_o = 1'b0;
				ctrl_busy_o = 1'b0;
				instr_req_o = 1'b0;
				halt_if_o = 1'b1;
				halt_id_o = 1'b1;
				if (irq_i || ((debug_req_i || debug_mode_q) || debug_single_step_i))
					ctrl_fsm_ns = 5'd4;
			end
			5'd4: begin
				is_decoding_o = 1'b0;
				first_fetch_o = 1'b1;
				if (id_ready_i == 1'b1)
					ctrl_fsm_ns = 5'd5;
				if (irq_req_ctrl_i & irq_enable_int) begin
					ctrl_fsm_ns = 5'd7;
					halt_if_o = 1'b1;
					halt_id_o = 1'b1;
				end
				if (debug_req_i & ~debug_mode_q) begin
					ctrl_fsm_ns = 5'd15;
					halt_if_o = 1'b1;
					halt_id_o = 1'b1;
				end
			end
			5'd5:
				if (branch_taken_ex_i) begin
					is_decoding_o = 1'b0;
					pc_mux_o = riscv_defines_PC_BRANCH;
					pc_set_o = 1'b1;
				end
				else if (data_err_i) begin
					is_decoding_o = 1'b0;
					halt_if_o = 1'b1;
					halt_id_o = 1'b1;
					csr_save_ex_o = 1'b1;
					csr_save_cause_o = 1'b1;
					data_err_ack_o = 1'b1;
					csr_cause_o = (data_we_ex_i ? riscv_defines_EXC_CAUSE_STORE_FAULT : riscv_defines_EXC_CAUSE_LOAD_FAULT);
					ctrl_fsm_ns = 5'd12;
				end
				else if (is_fetch_failed_i) begin
					is_decoding_o = 1'b0;
					halt_id_o = 1'b1;
					halt_if_o = 1'b1;
					csr_save_if_o = 1'b1;
					csr_save_cause_o = 1'b1;
					csr_cause_o = riscv_defines_EXC_CAUSE_INSTR_FAULT;
					ctrl_fsm_ns = 5'd12;
				end
				else if (instr_valid_i || instr_valid_irq_flush_q) begin
					is_decoding_o = 1'b1;
					case (1'b1)
						((irq_req_ctrl_i & irq_enable_int) & ~debug_req_i) & ~debug_mode_q: begin
							halt_if_o = 1'b1;
							halt_id_o = 1'b1;
							ctrl_fsm_ns = 5'd8;
							hwloop_mask_o = 1'b1;
						end
						debug_req_i & ~debug_mode_q: begin
							halt_if_o = 1'b1;
							halt_id_o = 1'b1;
							ctrl_fsm_ns = 5'd16;
						end
						default: begin
							exc_kill_o = (irq_req_ctrl_i ? 1'b1 : 1'b0);
							if (illegal_insn_i) begin
								halt_if_o = 1'b1;
								halt_id_o = 1'b1;
								csr_save_id_o = 1'b1;
								csr_save_cause_o = 1'b1;
								csr_cause_o = riscv_defines_EXC_CAUSE_ILLEGAL_INSN;
								ctrl_fsm_ns = 5'd11;
								illegal_insn_n = 1'b1;
							end
							else
								case (1'b1)
									jump_in_dec: begin
										pc_mux_o = riscv_defines_PC_JUMP;
										if (~jr_stall_o && ~jump_done_q) begin
											pc_set_o = 1'b1;
											jump_done = 1'b1;
										end
									end
									ebrk_insn_i: begin
										halt_if_o = 1'b1;
										halt_id_o = 1'b1;
										if (debug_mode_q)
											ctrl_fsm_ns = 5'd16;
										else if (ebrk_force_debug_mode)
											ctrl_fsm_ns = 5'd16;
										else begin
											csr_save_id_o = 1'b1;
											csr_save_cause_o = 1'b1;
											ctrl_fsm_ns = 5'd11;
											csr_cause_o = riscv_defines_EXC_CAUSE_BREAKPOINT;
										end
									end
									pipe_flush_i: begin
										halt_if_o = 1'b1;
										halt_id_o = 1'b1;
										ctrl_fsm_ns = 5'd11;
									end
									ecall_insn_i: begin
										halt_if_o = 1'b1;
										halt_id_o = 1'b1;
										csr_save_id_o = 1'b1;
										csr_save_cause_o = 1'b1;
										csr_cause_o = (current_priv_lvl_i == 2'b00 ? riscv_defines_EXC_CAUSE_ECALL_UMODE : riscv_defines_EXC_CAUSE_ECALL_MMODE);
										ctrl_fsm_ns = 5'd11;
									end
									fencei_insn_i: begin
										halt_if_o = 1'b1;
										halt_id_o = 1'b1;
										ctrl_fsm_ns = 5'd11;
									end
									(mret_insn_i | uret_insn_i) | dret_insn_i: begin
										halt_if_o = 1'b1;
										halt_id_o = 1'b1;
										ctrl_fsm_ns = 5'd11;
									end
									csr_status_i: begin
										halt_if_o = 1'b1;
										ctrl_fsm_ns = (id_ready_i ? 5'd11 : 5'd5);
									end
									data_load_event_i: begin
										ctrl_fsm_ns = (id_ready_i ? 5'd10 : 5'd5);
										halt_if_o = 1'b1;
									end
									default:
										;
								endcase
							if (debug_single_step_i & ~debug_mode_q) begin
								halt_if_o = 1'b1;
								if (id_ready_i)
									case (1'b1)
										illegal_insn_i | ecall_insn_i: ctrl_fsm_ns = 5'd11;
										~ebrk_force_debug_mode & ebrk_insn_i: ctrl_fsm_ns = 5'd11;
										mret_insn_i | uret_insn_i: ctrl_fsm_ns = 5'd11;
										branch_in_id: ctrl_fsm_ns = 5'd17;
										default: ctrl_fsm_ns = 5'd16;
									endcase
							end
						end
					endcase
				end
				else begin
					is_decoding_o = 1'b0;
					perf_pipeline_stall_o = data_load_event_i;
				end
			5'd11: begin
				is_decoding_o = 1'b0;
				halt_if_o = 1'b1;
				halt_id_o = 1'b1;
				if (data_err_i) begin
					csr_save_ex_o = 1'b1;
					csr_save_cause_o = 1'b1;
					data_err_ack_o = 1'b1;
					csr_cause_o = (data_we_ex_i ? riscv_defines_EXC_CAUSE_STORE_FAULT : riscv_defines_EXC_CAUSE_LOAD_FAULT);
					ctrl_fsm_ns = 5'd12;
					illegal_insn_n = 1'b0;
				end
				else if (ex_valid_i)
					ctrl_fsm_ns = 5'd12;
			end
			5'd8: begin
				is_decoding_o = 1'b0;
				halt_if_o = 1'b1;
				halt_id_o = 1'b1;
				if (data_err_i) begin
					csr_save_ex_o = 1'b1;
					csr_save_cause_o = 1'b1;
					data_err_ack_o = 1'b1;
					csr_cause_o = (data_we_ex_i ? riscv_defines_EXC_CAUSE_STORE_FAULT : riscv_defines_EXC_CAUSE_LOAD_FAULT);
					ctrl_fsm_ns = 5'd12;
				end
				else if (irq_i & irq_enable_int)
					ctrl_fsm_ns = 5'd6;
				else begin
					exc_kill_o = 1'b1;
					instr_valid_irq_flush_n = 1'b1;
					ctrl_fsm_ns = 5'd5;
				end
			end
			5'd9: begin
				is_decoding_o = 1'b0;
				halt_if_o = 1'b1;
				halt_id_o = 1'b1;
				perf_pipeline_stall_o = data_load_event_i;
				if (irq_i & irq_enable_int)
					ctrl_fsm_ns = 5'd6;
				else begin
					exc_kill_o = 1'b1;
					ctrl_fsm_ns = 5'd5;
				end
			end
			5'd10: begin
				is_decoding_o = 1'b0;
				halt_if_o = 1'b1;
				halt_id_o = 1'b1;
				if (id_ready_i)
					ctrl_fsm_ns = (debug_req_i & ~debug_mode_q ? 5'd16 : 5'd9);
				else
					ctrl_fsm_ns = 5'd10;
				perf_pipeline_stall_o = data_load_event_i;
			end
			5'd6: begin
				is_decoding_o = 1'b0;
				pc_set_o = 1'b1;
				pc_mux_o = riscv_defines_PC_EXCEPTION;
				exc_pc_mux_o = riscv_defines_EXC_PC_IRQ;
				exc_cause_o = {1'b0, irq_id_ctrl_i};
				csr_irq_sec_o = irq_sec_ctrl_i;
				csr_save_cause_o = 1'b1;
				csr_cause_o = {1'b1, irq_id_ctrl_i};
				csr_save_id_o = 1'b1;
				if (irq_sec_ctrl_i)
					trap_addr_mux_o = riscv_defines_TRAP_MACHINE;
				else
					trap_addr_mux_o = (current_priv_lvl_i == 2'b00 ? riscv_defines_TRAP_USER : riscv_defines_TRAP_MACHINE);
				irq_ack_o = 1'b1;
				exc_ack_o = 1'b1;
				ctrl_fsm_ns = 5'd5;
			end
			5'd7: begin
				is_decoding_o = 1'b0;
				pc_set_o = 1'b1;
				pc_mux_o = riscv_defines_PC_EXCEPTION;
				exc_pc_mux_o = riscv_defines_EXC_PC_IRQ;
				exc_cause_o = {1'b0, irq_id_ctrl_i};
				csr_irq_sec_o = irq_sec_ctrl_i;
				csr_save_cause_o = 1'b1;
				csr_cause_o = {1'b1, irq_id_ctrl_i};
				csr_save_if_o = 1'b1;
				if (irq_sec_ctrl_i)
					trap_addr_mux_o = riscv_defines_TRAP_MACHINE;
				else
					trap_addr_mux_o = (current_priv_lvl_i == 2'b00 ? riscv_defines_TRAP_USER : riscv_defines_TRAP_MACHINE);
				irq_ack_o = 1'b1;
				exc_ack_o = 1'b1;
				ctrl_fsm_ns = 5'd5;
			end
			5'd12: begin
				is_decoding_o = 1'b0;
				halt_if_o = 1'b1;
				halt_id_o = 1'b1;
				ctrl_fsm_ns = 5'd5;
				if (data_err_q) begin
					pc_mux_o = riscv_defines_PC_EXCEPTION;
					pc_set_o = 1'b1;
					trap_addr_mux_o = riscv_defines_TRAP_MACHINE;
					exc_pc_mux_o = riscv_defines_EXC_PC_EXCEPTION;
					exc_cause_o = (data_we_ex_i ? riscv_defines_EXC_CAUSE_LOAD_FAULT : riscv_defines_EXC_CAUSE_STORE_FAULT);
				end
				else if (is_fetch_failed_i) begin
					pc_mux_o = riscv_defines_PC_EXCEPTION;
					pc_set_o = 1'b1;
					trap_addr_mux_o = riscv_defines_TRAP_MACHINE;
					exc_pc_mux_o = riscv_defines_EXC_PC_EXCEPTION;
					exc_cause_o = riscv_defines_EXC_CAUSE_INSTR_FAULT;
				end
				else if (illegal_insn_q) begin
					pc_mux_o = riscv_defines_PC_EXCEPTION;
					pc_set_o = 1'b1;
					trap_addr_mux_o = riscv_defines_TRAP_MACHINE;
					exc_pc_mux_o = riscv_defines_EXC_PC_EXCEPTION;
					illegal_insn_n = 1'b0;
					if (debug_single_step_i && ~debug_mode_q)
						ctrl_fsm_ns = 5'd15;
				end
				else
					case (1'b1)
						ebrk_insn_i: begin
							pc_mux_o = riscv_defines_PC_EXCEPTION;
							pc_set_o = 1'b1;
							trap_addr_mux_o = riscv_defines_TRAP_MACHINE;
							exc_pc_mux_o = riscv_defines_EXC_PC_EXCEPTION;
							if (debug_single_step_i && ~debug_mode_q)
								ctrl_fsm_ns = 5'd15;
						end
						ecall_insn_i: begin
							pc_mux_o = riscv_defines_PC_EXCEPTION;
							pc_set_o = 1'b1;
							trap_addr_mux_o = riscv_defines_TRAP_MACHINE;
							exc_pc_mux_o = riscv_defines_EXC_PC_EXCEPTION;
							exc_cause_o = riscv_defines_EXC_CAUSE_ECALL_MMODE;
							if (debug_single_step_i && ~debug_mode_q)
								ctrl_fsm_ns = 5'd15;
						end
						mret_insn_i: begin
							csr_restore_mret_id_o = 1'b1;
							ctrl_fsm_ns = 5'd13;
						end
						uret_insn_i: begin
							csr_restore_uret_id_o = 1'b1;
							ctrl_fsm_ns = 5'd13;
						end
						dret_insn_i: begin
							csr_restore_dret_id_o = 1'b1;
							ctrl_fsm_ns = 5'd13;
						end
						csr_status_i:
							;
						pipe_flush_i: ctrl_fsm_ns = 5'd3;
						fencei_insn_i: begin
							pc_mux_o = riscv_defines_PC_FENCEI;
							pc_set_o = 1'b1;
						end
						default:
							;
					endcase
			end
			5'd13: begin
				is_decoding_o = 1'b0;
				ctrl_fsm_ns = 5'd5;
				case (1'b1)
					mret_dec_i: begin
						pc_mux_o = riscv_defines_PC_MRET;
						pc_set_o = 1'b1;
					end
					uret_dec_i: begin
						pc_mux_o = riscv_defines_PC_URET;
						pc_set_o = 1'b1;
					end
					dret_dec_i: begin
						pc_mux_o = riscv_defines_PC_DRET;
						pc_set_o = 1'b1;
						debug_mode_n = 1'b0;
					end
					default:
						;
				endcase
				if (debug_single_step_i && ~debug_mode_q)
					ctrl_fsm_ns = 5'd15;
			end
			5'd17: begin
				is_decoding_o = 1'b0;
				halt_if_o = 1'b1;
				if (branch_taken_ex_i) begin
					pc_mux_o = riscv_defines_PC_BRANCH;
					pc_set_o = 1'b1;
				end
				ctrl_fsm_ns = 5'd16;
			end
			5'd14: begin
				is_decoding_o = 1'b0;
				pc_set_o = 1'b1;
				pc_mux_o = riscv_defines_PC_EXCEPTION;
				exc_pc_mux_o = riscv_defines_EXC_PC_DBD;
				if ((debug_req_i && ~debug_mode_q) || ((ebrk_insn_i && ebrk_force_debug_mode) && ~debug_mode_q)) begin
					csr_save_cause_o = 1'b1;
					csr_save_id_o = 1'b1;
					debug_csr_save_o = 1'b1;
					if (debug_req_i)
						debug_cause_o = riscv_defines_DBG_CAUSE_HALTREQ;
					if (ebrk_insn_i)
						debug_cause_o = riscv_defines_DBG_CAUSE_EBREAK;
				end
				ctrl_fsm_ns = 5'd5;
				debug_mode_n = 1'b1;
			end
			5'd15: begin
				is_decoding_o = 1'b0;
				pc_set_o = 1'b1;
				pc_mux_o = riscv_defines_PC_EXCEPTION;
				exc_pc_mux_o = riscv_defines_EXC_PC_DBD;
				csr_save_cause_o = 1'b1;
				debug_csr_save_o = 1'b1;
				if (debug_single_step_i)
					debug_cause_o = riscv_defines_DBG_CAUSE_STEP;
				if (debug_req_i)
					debug_cause_o = riscv_defines_DBG_CAUSE_HALTREQ;
				if (ebrk_insn_i)
					debug_cause_o = riscv_defines_DBG_CAUSE_EBREAK;
				csr_save_if_o = 1'b1;
				ctrl_fsm_ns = 5'd5;
				debug_mode_n = 1'b1;
			end
			5'd16: begin
				is_decoding_o = 1'b0;
				halt_if_o = 1'b1;
				halt_id_o = 1'b1;
				perf_pipeline_stall_o = data_load_event_i;
				if (data_err_i) begin
					csr_save_ex_o = 1'b1;
					csr_save_cause_o = 1'b1;
					data_err_ack_o = 1'b1;
					csr_cause_o = (data_we_ex_i ? riscv_defines_EXC_CAUSE_STORE_FAULT : riscv_defines_EXC_CAUSE_LOAD_FAULT);
					ctrl_fsm_ns = 5'd12;
				end
				else if (debug_mode_q)
					ctrl_fsm_ns = 5'd14;
				else if (data_load_event_i)
					ctrl_fsm_ns = 5'd14;
				else if (debug_single_step_i)
					ctrl_fsm_ns = 5'd15;
				else
					ctrl_fsm_ns = 5'd14;
			end
			default: begin
				is_decoding_o = 1'b0;
				instr_req_o = 1'b0;
				ctrl_fsm_ns = 5'd0;
			end
		endcase
	end
	always @(*) begin
		load_stall_o = 1'b0;
		jr_stall_o = 1'b0;
		deassert_we_o = 1'b0;
		if (~is_decoding_o)
			deassert_we_o = 1'b1;
		if (illegal_insn_i)
			deassert_we_o = 1'b1;
		if ((((data_req_ex_i == 1'b1) && (regfile_we_ex_i == 1'b1)) || ((wb_ready_i == 1'b0) && (regfile_we_wb_i == 1'b1))) && ((((reg_d_ex_is_reg_a_i == 1'b1) || (reg_d_ex_is_reg_b_i == 1'b1)) || (reg_d_ex_is_reg_c_i == 1'b1)) || ((is_decoding_o && regfile_we_id_i) && (regfile_waddr_ex_i == regfile_alu_waddr_id_i)))) begin
			deassert_we_o = 1'b1;
			load_stall_o = 1'b1;
		end
		if ((jump_in_dec_i == riscv_defines_BRANCH_JALR) && ((((regfile_we_wb_i == 1'b1) && (reg_d_wb_is_reg_a_i == 1'b1)) || ((regfile_we_ex_i == 1'b1) && (reg_d_ex_is_reg_a_i == 1'b1))) || ((regfile_alu_we_fw_i == 1'b1) && (reg_d_alu_is_reg_a_i == 1'b1)))) begin
			jr_stall_o = 1'b1;
			deassert_we_o = 1'b1;
		end
	end
	assign misaligned_stall_o = data_misaligned_i;
	assign apu_stall_o = apu_read_dep_i | (apu_write_dep_i & ~apu_en_i);
	localparam riscv_defines_SEL_FW_EX = 2'b01;
	localparam riscv_defines_SEL_FW_WB = 2'b10;
	localparam riscv_defines_SEL_REGFILE = 2'b00;
	always @(*) begin
		operand_a_fw_mux_sel_o = riscv_defines_SEL_REGFILE;
		operand_b_fw_mux_sel_o = riscv_defines_SEL_REGFILE;
		operand_c_fw_mux_sel_o = riscv_defines_SEL_REGFILE;
		if (regfile_we_wb_i == 1'b1) begin
			if (reg_d_wb_is_reg_a_i == 1'b1)
				operand_a_fw_mux_sel_o = riscv_defines_SEL_FW_WB;
			if (reg_d_wb_is_reg_b_i == 1'b1)
				operand_b_fw_mux_sel_o = riscv_defines_SEL_FW_WB;
			if (reg_d_wb_is_reg_c_i == 1'b1)
				operand_c_fw_mux_sel_o = riscv_defines_SEL_FW_WB;
		end
		if (regfile_alu_we_fw_i == 1'b1) begin
			if (reg_d_alu_is_reg_a_i == 1'b1)
				operand_a_fw_mux_sel_o = riscv_defines_SEL_FW_EX;
			if (reg_d_alu_is_reg_b_i == 1'b1)
				operand_b_fw_mux_sel_o = riscv_defines_SEL_FW_EX;
			if (reg_d_alu_is_reg_c_i == 1'b1)
				operand_c_fw_mux_sel_o = riscv_defines_SEL_FW_EX;
		end
		if (data_misaligned_i) begin
			operand_a_fw_mux_sel_o = riscv_defines_SEL_FW_EX;
			operand_b_fw_mux_sel_o = riscv_defines_SEL_REGFILE;
		end
		else if (mult_multicycle_i)
			operand_c_fw_mux_sel_o = riscv_defines_SEL_FW_EX;
	end
	always @(posedge clk or negedge rst_n) begin : UPDATE_REGS
		if (rst_n == 1'b0) begin
			ctrl_fsm_cs <= 5'd0;
			jump_done_q <= 1'b0;
			boot_done_q <= 1'b0;
			data_err_q <= 1'b0;
			debug_mode_q <= 1'b0;
			illegal_insn_q <= 1'b0;
			instr_valid_irq_flush_q <= 1'b0;
		end
		else begin
			ctrl_fsm_cs <= ctrl_fsm_ns;
			boot_done_q <= boot_done | (~boot_done & boot_done_q);
			jump_done_q <= jump_done & ~id_ready_i;
			data_err_q <= data_err_i;
			debug_mode_q <= debug_mode_n;
			illegal_insn_q <= illegal_insn_n;
			instr_valid_irq_flush_q <= instr_valid_irq_flush_n;
		end
	end
	assign perf_jump_o = (jump_in_id_i == riscv_defines_BRANCH_JAL) || (jump_in_id_i == riscv_defines_BRANCH_JALR);
	assign perf_jr_stall_o = jr_stall_o;
	assign perf_ld_stall_o = load_stall_o;
	assign debug_mode_o = debug_mode_q;
endmodule
