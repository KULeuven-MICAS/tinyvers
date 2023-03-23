module riscv_cs_registers (
	clk,
	rst_n,
	core_id_i,
	cluster_id_i,
	mtvec_o,
	utvec_o,
	boot_addr_i,
	csr_access_i,
	csr_addr_i,
	csr_wdata_i,
	csr_op_i,
	csr_rdata_o,
	frm_o,
	fprec_o,
	fflags_i,
	fflags_we_i,
	m_irq_enable_o,
	u_irq_enable_o,
	csr_irq_sec_i,
	sec_lvl_o,
	mepc_o,
	uepc_o,
	debug_mode_i,
	debug_cause_i,
	debug_csr_save_i,
	depc_o,
	debug_single_step_o,
	debug_ebreakm_o,
	debug_ebreaku_o,
	pmp_addr_o,
	pmp_cfg_o,
	priv_lvl_o,
	pc_if_i,
	pc_id_i,
	pc_ex_i,
	csr_save_if_i,
	csr_save_id_i,
	csr_save_ex_i,
	csr_restore_mret_i,
	csr_restore_uret_i,
	csr_restore_dret_i,
	csr_cause_i,
	csr_save_cause_i,
	hwlp_start_i,
	hwlp_end_i,
	hwlp_cnt_i,
	hwlp_data_o,
	hwlp_regid_o,
	hwlp_we_o,
	id_valid_i,
	is_compressed_i,
	is_decoding_i,
	imiss_i,
	pc_set_i,
	jump_i,
	branch_i,
	branch_taken_i,
	ld_stall_i,
	jr_stall_i,
	pipeline_stall_i,
	apu_typeconflict_i,
	apu_contention_i,
	apu_dep_i,
	apu_wb_i,
	mem_load_i,
	mem_store_i,
	ext_counters_i
);
	parameter N_HWLP = 2;
	parameter N_HWLP_BITS = $clog2(N_HWLP);
	parameter N_EXT_CNT = 0;
	parameter APU = 0;
	parameter FPU = 0;
	parameter PULP_SECURE = 0;
	parameter USE_PMP = 0;
	parameter N_PMP_ENTRIES = 16;
	input wire clk;
	input wire rst_n;
	input wire [3:0] core_id_i;
	input wire [5:0] cluster_id_i;
	output wire [23:0] mtvec_o;
	output wire [23:0] utvec_o;
	input wire [30:0] boot_addr_i;
	input wire csr_access_i;
	input wire [11:0] csr_addr_i;
	input wire [31:0] csr_wdata_i;
	input wire [1:0] csr_op_i;
	output reg [31:0] csr_rdata_o;
	output wire [2:0] frm_o;
	localparam riscv_defines_C_PC = 5;
	output wire [4:0] fprec_o;
	localparam riscv_defines_C_FFLAG = 5;
	input wire [4:0] fflags_i;
	input wire fflags_we_i;
	output wire m_irq_enable_o;
	output wire u_irq_enable_o;
	input wire csr_irq_sec_i;
	output wire sec_lvl_o;
	output wire [31:0] mepc_o;
	output wire [31:0] uepc_o;
	input wire debug_mode_i;
	input wire [2:0] debug_cause_i;
	input wire debug_csr_save_i;
	output wire [31:0] depc_o;
	output wire debug_single_step_o;
	output wire debug_ebreakm_o;
	output wire debug_ebreaku_o;
	output wire [(N_PMP_ENTRIES * 32) - 1:0] pmp_addr_o;
	output wire [(N_PMP_ENTRIES * 8) - 1:0] pmp_cfg_o;
	output wire [1:0] priv_lvl_o;
	input wire [31:0] pc_if_i;
	input wire [31:0] pc_id_i;
	input wire [31:0] pc_ex_i;
	input wire csr_save_if_i;
	input wire csr_save_id_i;
	input wire csr_save_ex_i;
	input wire csr_restore_mret_i;
	input wire csr_restore_uret_i;
	input wire csr_restore_dret_i;
	input wire [5:0] csr_cause_i;
	input wire csr_save_cause_i;
	input wire [(N_HWLP * 32) - 1:0] hwlp_start_i;
	input wire [(N_HWLP * 32) - 1:0] hwlp_end_i;
	input wire [(N_HWLP * 32) - 1:0] hwlp_cnt_i;
	output wire [31:0] hwlp_data_o;
	output reg [N_HWLP_BITS - 1:0] hwlp_regid_o;
	output reg [2:0] hwlp_we_o;
	input wire id_valid_i;
	input wire is_compressed_i;
	input wire is_decoding_i;
	input wire imiss_i;
	input wire pc_set_i;
	input wire jump_i;
	input wire branch_i;
	input wire branch_taken_i;
	input wire ld_stall_i;
	input wire jr_stall_i;
	input wire pipeline_stall_i;
	input wire apu_typeconflict_i;
	input wire apu_contention_i;
	input wire apu_dep_i;
	input wire apu_wb_i;
	input wire mem_load_i;
	input wire mem_store_i;
	input wire [N_EXT_CNT - 1:0] ext_counters_i;
	localparam N_APU_CNT = (APU == 1 ? 4 : 0);
	localparam N_PERF_COUNTERS = (12 + N_EXT_CNT) + N_APU_CNT;
	localparam PERF_EXT_ID = 12;
	localparam PERF_APU_ID = PERF_EXT_ID + N_EXT_CNT;
	localparam MTVEC_MODE = 2'b01;
	localparam MAX_N_PMP_ENTRIES = 16;
	localparam MAX_N_PMP_CFG = 4;
	localparam N_PMP_CFG = ((N_PMP_ENTRIES % 4) == 0 ? N_PMP_ENTRIES / 4 : (N_PMP_ENTRIES / 4) + 1);
	localparam N_PERF_REGS = N_PERF_COUNTERS;
	localparam [1:0] MXL = 2'd1;
	function automatic [31:0] sv2v_cast_32;
		input reg [31:0] inp;
		sv2v_cast_32 = inp;
	endfunction
	localparam [31:0] MISA_VALUE = (((((((4 | (FPU << 5)) | 256) | 4096) | 0) | 0) | (PULP_SECURE << 20)) | 8388608) | (sv2v_cast_32(MXL) << 30);
	initial $display("[CORE] Core settings: PULP_SECURE = %d, N_PMP_ENTRIES = %d, N_PMP_CFG %d", PULP_SECURE, N_PMP_ENTRIES, N_PMP_CFG);
	reg [31:0] csr_wdata_int;
	reg [31:0] csr_rdata_int;
	reg csr_we_int;
	localparam riscv_defines_C_RM = 3;
	reg [2:0] frm_q;
	reg [2:0] frm_n;
	reg [4:0] fflags_q;
	reg [4:0] fflags_n;
	reg [4:0] fprec_q;
	reg [4:0] fprec_n;
	reg [31:0] mepc_q;
	reg [31:0] mepc_n;
	reg [31:0] uepc_q;
	reg [31:0] uepc_n;
	reg [31:0] dcsr_q;
	reg [31:0] dcsr_n;
	reg [31:0] depc_q;
	reg [31:0] depc_n;
	reg [31:0] dscratch0_q;
	reg [31:0] dscratch0_n;
	reg [31:0] dscratch1_q;
	reg [31:0] dscratch1_n;
	reg [31:0] mscratch_q;
	reg [31:0] mscratch_n;
	reg [31:0] exception_pc;
	reg [6:0] mstatus_q;
	reg [6:0] mstatus_n;
	reg [5:0] mcause_q;
	reg [5:0] mcause_n;
	reg [5:0] ucause_q;
	reg [5:0] ucause_n;
	reg [23:0] mtvec_n;
	reg [23:0] mtvec_q;
	reg [23:0] utvec_n;
	reg [23:0] utvec_q;
	wire is_irq;
	reg [1:0] priv_lvl_n;
	reg [1:0] priv_lvl_q;
	wire [1:0] priv_lvl_reg_q;
	reg [767:0] pmp_reg_q;
	reg [767:0] pmp_reg_n;
	reg [15:0] pmpaddr_we;
	reg [15:0] pmpcfg_we;
	reg id_valid_q;
	wire [N_PERF_COUNTERS - 1:0] PCCR_in;
	reg [N_PERF_COUNTERS - 1:0] PCCR_inc;
	reg [N_PERF_COUNTERS - 1:0] PCCR_inc_q;
	reg [(N_PERF_REGS * 32) - 1:0] PCCR_q;
	reg [(N_PERF_REGS * 32) - 1:0] PCCR_n;
	reg [1:0] PCMR_n;
	reg [1:0] PCMR_q;
	reg [N_PERF_COUNTERS - 1:0] PCER_n;
	reg [N_PERF_COUNTERS - 1:0] PCER_q;
	reg [31:0] perf_rdata;
	reg [4:0] pccr_index;
	reg pccr_all_sel;
	reg is_pccr;
	reg is_pcer;
	reg is_pcmr;
	assign is_irq = csr_cause_i[5];
	genvar j;
	localparam riscv_defines_CSR_DCSR = 12'h7b0;
	localparam riscv_defines_CSR_DPC = 12'h7b1;
	localparam riscv_defines_CSR_DSCRATCH0 = 12'h7b2;
	localparam riscv_defines_CSR_DSCRATCH1 = 12'h7b3;
	localparam riscv_defines_HWLoop0_COUNTER = 12'h7c2;
	localparam riscv_defines_HWLoop0_END = 12'h7c1;
	localparam riscv_defines_HWLoop0_START = 12'h7c0;
	localparam riscv_defines_HWLoop1_COUNTER = 12'h7c6;
	localparam riscv_defines_HWLoop1_END = 12'h7c5;
	localparam riscv_defines_HWLoop1_START = 12'h7c4;
	generate
		if (PULP_SECURE == 1) begin : genblk1
			always @(*)
				case (csr_addr_i)
					12'h001: csr_rdata_int = (FPU == 1 ? {27'b000000000000000000000000000, fflags_q} : {32 {1'sb0}});
					12'h002: csr_rdata_int = (FPU == 1 ? {29'b00000000000000000000000000000, frm_q} : {32 {1'sb0}});
					12'h003: csr_rdata_int = (FPU == 1 ? {24'b000000000000000000000000, frm_q, fflags_q} : {32 {1'sb0}});
					12'h006: csr_rdata_int = (FPU == 1 ? {27'b000000000000000000000000000, fprec_q} : {32 {1'sb0}});
					12'h300: csr_rdata_int = {14'b00000000000000, mstatus_q[0], 4'b0000, mstatus_q[2-:2], 3'b000, mstatus_q[3], 2'h0, mstatus_q[4], mstatus_q[5], 2'h0, mstatus_q[6]};
					12'h301: csr_rdata_int = MISA_VALUE;
					12'h305: csr_rdata_int = {mtvec_q, 6'h00, MTVEC_MODE};
					12'h340: csr_rdata_int = mscratch_q;
					12'h341: csr_rdata_int = mepc_q;
					12'h342: csr_rdata_int = {mcause_q[5], 26'b00000000000000000000000000, mcause_q[4:0]};
					12'hf14: csr_rdata_int = {21'b000000000000000000000, cluster_id_i[5:0], 1'b0, core_id_i[3:0]};
					riscv_defines_CSR_DCSR: csr_rdata_int = dcsr_q;
					riscv_defines_CSR_DPC: csr_rdata_int = depc_q;
					riscv_defines_CSR_DSCRATCH0: csr_rdata_int = dscratch0_q;
					riscv_defines_CSR_DSCRATCH1: csr_rdata_int = dscratch1_q;
					riscv_defines_HWLoop0_START: csr_rdata_int = hwlp_start_i[0+:32];
					riscv_defines_HWLoop0_END: csr_rdata_int = hwlp_end_i[0+:32];
					riscv_defines_HWLoop0_COUNTER: csr_rdata_int = hwlp_cnt_i[0+:32];
					riscv_defines_HWLoop1_START: csr_rdata_int = hwlp_start_i[32+:32];
					riscv_defines_HWLoop1_END: csr_rdata_int = hwlp_end_i[32+:32];
					riscv_defines_HWLoop1_COUNTER: csr_rdata_int = hwlp_cnt_i[32+:32];
					12'h3a0: csr_rdata_int = (USE_PMP ? pmp_reg_q[128+:32] : {32 {1'sb0}});
					12'h3a1: csr_rdata_int = (USE_PMP ? pmp_reg_q[160+:32] : {32 {1'sb0}});
					12'h3a2: csr_rdata_int = (USE_PMP ? pmp_reg_q[192+:32] : {32 {1'sb0}});
					12'h3a3: csr_rdata_int = (USE_PMP ? pmp_reg_q[224+:32] : {32 {1'sb0}});
					12'h3bx: csr_rdata_int = (USE_PMP ? pmp_reg_q[256 + (csr_addr_i[3:0] * 32)+:32] : {32 {1'sb0}});
					12'h000: csr_rdata_int = {27'b000000000000000000000000000, mstatus_q[4], 3'h0, mstatus_q[6]};
					12'h005: csr_rdata_int = {utvec_q, 6'h00, MTVEC_MODE};
					12'h014: csr_rdata_int = {21'b000000000000000000000, cluster_id_i[5:0], 1'b0, core_id_i[3:0]};
					12'h041: csr_rdata_int = uepc_q;
					12'h042: csr_rdata_int = {ucause_q[5], 26'h0000000, ucause_q[4:0]};
					12'hc10: csr_rdata_int = {30'h00000000, priv_lvl_q};
					default: csr_rdata_int = 1'sb0;
				endcase
		end
		else begin : genblk1
			always @(*)
				case (csr_addr_i)
					12'h001: csr_rdata_int = (FPU == 1 ? {27'b000000000000000000000000000, fflags_q} : {32 {1'sb0}});
					12'h002: csr_rdata_int = (FPU == 1 ? {29'b00000000000000000000000000000, frm_q} : {32 {1'sb0}});
					12'h003: csr_rdata_int = (FPU == 1 ? {24'b000000000000000000000000, frm_q, fflags_q} : {32 {1'sb0}});
					12'h006: csr_rdata_int = (FPU == 1 ? {27'b000000000000000000000000000, fprec_q} : {32 {1'sb0}});
					12'h300: csr_rdata_int = {14'b00000000000000, mstatus_q[0], 4'b0000, mstatus_q[2-:2], 3'b000, mstatus_q[3], 2'h0, mstatus_q[4], mstatus_q[5], 2'h0, mstatus_q[6]};
					12'h301: csr_rdata_int = MISA_VALUE;
					12'h305: csr_rdata_int = {mtvec_q, 6'h00, MTVEC_MODE};
					12'h340: csr_rdata_int = mscratch_q;
					12'h341: csr_rdata_int = mepc_q;
					12'h342: csr_rdata_int = {mcause_q[5], 26'b00000000000000000000000000, mcause_q[4:0]};
					12'hf14: csr_rdata_int = {21'b000000000000000000000, cluster_id_i[5:0], 1'b0, core_id_i[3:0]};
					riscv_defines_CSR_DCSR: csr_rdata_int = dcsr_q;
					riscv_defines_CSR_DPC: csr_rdata_int = depc_q;
					riscv_defines_CSR_DSCRATCH0: csr_rdata_int = dscratch0_q;
					riscv_defines_CSR_DSCRATCH1: csr_rdata_int = dscratch1_q;
					riscv_defines_HWLoop0_START: csr_rdata_int = hwlp_start_i[0+:32];
					riscv_defines_HWLoop0_END: csr_rdata_int = hwlp_end_i[0+:32];
					riscv_defines_HWLoop0_COUNTER: csr_rdata_int = hwlp_cnt_i[0+:32];
					riscv_defines_HWLoop1_START: csr_rdata_int = hwlp_start_i[32+:32];
					riscv_defines_HWLoop1_END: csr_rdata_int = hwlp_end_i[32+:32];
					riscv_defines_HWLoop1_COUNTER: csr_rdata_int = hwlp_cnt_i[32+:32];
					12'h014: csr_rdata_int = {21'b000000000000000000000, cluster_id_i[5:0], 1'b0, core_id_i[3:0]};
					12'hc10: csr_rdata_int = {30'h00000000, priv_lvl_q};
					default: csr_rdata_int = 1'sb0;
				endcase
		end
	endgenerate
	function automatic [1:0] sv2v_cast_2;
		input reg [1:0] inp;
		sv2v_cast_2 = inp;
	endfunction
	generate
		if (PULP_SECURE == 1) begin : genblk2
			always @(*) begin
				fflags_n = fflags_q;
				frm_n = frm_q;
				fprec_n = fprec_q;
				mscratch_n = mscratch_q;
				mepc_n = mepc_q;
				uepc_n = uepc_q;
				depc_n = depc_q;
				dcsr_n = dcsr_q;
				dscratch0_n = dscratch0_q;
				dscratch1_n = dscratch1_q;
				mstatus_n = mstatus_q;
				mcause_n = mcause_q;
				ucause_n = ucause_q;
				hwlp_we_o = 1'sb0;
				hwlp_regid_o = 1'sb0;
				exception_pc = pc_id_i;
				priv_lvl_n = priv_lvl_q;
				mtvec_n = mtvec_q;
				utvec_n = utvec_q;
				pmp_reg_n[767-:512] = pmp_reg_q[767-:512];
				pmp_reg_n[255-:128] = pmp_reg_q[255-:128];
				pmpaddr_we = 1'sb0;
				pmpcfg_we = 1'sb0;
				if (FPU == 1)
					if (fflags_we_i)
						fflags_n = fflags_i | fflags_q;
				casex (csr_addr_i)
					12'h001:
						if (csr_we_int)
							fflags_n = (FPU == 1 ? csr_wdata_int[4:0] : {5 {1'sb0}});
					12'h002:
						if (csr_we_int)
							frm_n = (FPU == 1 ? csr_wdata_int[2:0] : {3 {1'sb0}});
					12'h003:
						if (csr_we_int) begin
							fflags_n = (FPU == 1 ? csr_wdata_int[4:0] : {5 {1'sb0}});
							frm_n = (FPU == 1 ? csr_wdata_int[7:riscv_defines_C_FFLAG] : {3 {1'sb0}});
						end
					12'h006:
						if (csr_we_int)
							fprec_n = (FPU == 1 ? csr_wdata_int[4:0] : {5 {1'sb0}});
					12'h300:
						if (csr_we_int)
							mstatus_n = {csr_wdata_int[0], csr_wdata_int[3], csr_wdata_int[4], csr_wdata_int[7], csr_wdata_int[12:11], csr_wdata_int[17]};
					12'h305:
						if (csr_we_int)
							mtvec_n = csr_wdata_int[31:8];
					12'h340:
						if (csr_we_int)
							mscratch_n = csr_wdata_int;
					12'h341:
						if (csr_we_int)
							mepc_n = csr_wdata_int & ~32'b00000000000000000000000000000001;
					12'h342:
						if (csr_we_int)
							mcause_n = {csr_wdata_int[31], csr_wdata_int[4:0]};
					riscv_defines_CSR_DCSR:
						if (csr_we_int) begin
							dcsr_n = csr_wdata_int;
							dcsr_n[31-:4] = 4'h4;
							dcsr_n[1-:2] = priv_lvl_q;
							dcsr_n[3] = 1'b0;
							dcsr_n[4] = 1'b0;
							dcsr_n[10] = 1'b0;
							dcsr_n[9] = 1'b0;
						end
					riscv_defines_CSR_DPC:
						if (csr_we_int)
							depc_n = csr_wdata_int & ~32'b00000000000000000000000000000001;
					riscv_defines_CSR_DSCRATCH0:
						if (csr_we_int)
							dscratch0_n = csr_wdata_int;
					riscv_defines_CSR_DSCRATCH1:
						if (csr_we_int)
							dscratch1_n = csr_wdata_int;
					riscv_defines_HWLoop0_START:
						if (csr_we_int) begin
							hwlp_we_o = 3'b001;
							hwlp_regid_o = 1'b0;
						end
					riscv_defines_HWLoop0_END:
						if (csr_we_int) begin
							hwlp_we_o = 3'b010;
							hwlp_regid_o = 1'b0;
						end
					riscv_defines_HWLoop0_COUNTER:
						if (csr_we_int) begin
							hwlp_we_o = 3'b100;
							hwlp_regid_o = 1'b0;
						end
					riscv_defines_HWLoop1_START:
						if (csr_we_int) begin
							hwlp_we_o = 3'b001;
							hwlp_regid_o = 1'b1;
						end
					riscv_defines_HWLoop1_END:
						if (csr_we_int) begin
							hwlp_we_o = 3'b010;
							hwlp_regid_o = 1'b1;
						end
					riscv_defines_HWLoop1_COUNTER:
						if (csr_we_int) begin
							hwlp_we_o = 3'b100;
							hwlp_regid_o = 1'b1;
						end
					12'h3a0:
						if (csr_we_int) begin
							pmp_reg_n[128+:32] = csr_wdata_int;
							pmpcfg_we[3:0] = 4'b1111;
						end
					12'h3a1:
						if (csr_we_int) begin
							pmp_reg_n[160+:32] = csr_wdata_int;
							pmpcfg_we[7:4] = 4'b1111;
						end
					12'h3a2:
						if (csr_we_int) begin
							pmp_reg_n[192+:32] = csr_wdata_int;
							pmpcfg_we[11:8] = 4'b1111;
						end
					12'h3a3:
						if (csr_we_int) begin
							pmp_reg_n[224+:32] = csr_wdata_int;
							pmpcfg_we[15:12] = 4'b1111;
						end
					12'h3bx:
						if (csr_we_int) begin
							pmp_reg_n[256 + (csr_addr_i[3:0] * 32)+:32] = csr_wdata_int;
							pmpaddr_we[csr_addr_i[3:0]] = 1'b1;
						end
					12'h000:
						if (csr_we_int)
							mstatus_n = {csr_wdata_int[0], mstatus_q[5], csr_wdata_int[4], mstatus_q[3], sv2v_cast_2(mstatus_q[2-:2]), mstatus_q[0]};
					12'h005:
						if (csr_we_int)
							utvec_n = csr_wdata_int[31:8];
					12'h041:
						if (csr_we_int)
							uepc_n = csr_wdata_int;
					12'h042:
						if (csr_we_int)
							ucause_n = {csr_wdata_int[31], csr_wdata_int[4:0]};
				endcase
				case (1'b1)
					csr_save_cause_i: begin
						case (1'b1)
							csr_save_if_i: exception_pc = pc_if_i;
							csr_save_id_i: exception_pc = pc_id_i;
							csr_save_ex_i: exception_pc = pc_ex_i;
							default:
								;
						endcase
						case (priv_lvl_q)
							2'b00:
								if (~is_irq) begin
									priv_lvl_n = 2'b11;
									mstatus_n[3] = mstatus_q[6];
									mstatus_n[5] = 1'b0;
									mstatus_n[2-:2] = 2'b00;
									if (debug_csr_save_i)
										depc_n = exception_pc;
									else
										mepc_n = exception_pc;
									mcause_n = csr_cause_i;
								end
								else if (~csr_irq_sec_i) begin
									priv_lvl_n = 2'b00;
									mstatus_n[4] = mstatus_q[6];
									mstatus_n[6] = 1'b0;
									if (debug_csr_save_i)
										depc_n = exception_pc;
									else
										uepc_n = exception_pc;
									ucause_n = csr_cause_i;
								end
								else begin
									priv_lvl_n = 2'b11;
									mstatus_n[3] = mstatus_q[6];
									mstatus_n[5] = 1'b0;
									mstatus_n[2-:2] = 2'b00;
									if (debug_csr_save_i)
										depc_n = exception_pc;
									else
										mepc_n = exception_pc;
									mcause_n = csr_cause_i;
								end
							2'b11:
								if (debug_csr_save_i) begin
									dcsr_n[1-:2] = 2'b11;
									dcsr_n[8-:3] = debug_cause_i;
									depc_n = exception_pc;
								end
								else begin
									priv_lvl_n = 2'b11;
									mstatus_n[3] = mstatus_q[5];
									mstatus_n[5] = 1'b0;
									mstatus_n[2-:2] = 2'b11;
									mepc_n = exception_pc;
									mcause_n = csr_cause_i;
								end
							default:
								;
						endcase
					end
					csr_restore_uret_i: begin
						mstatus_n[6] = mstatus_q[4];
						priv_lvl_n = 2'b00;
						mstatus_n[4] = 1'b1;
					end
					csr_restore_mret_i:
						case (mstatus_q[2-:2])
							2'b00: begin
								mstatus_n[6] = mstatus_q[3];
								priv_lvl_n = 2'b00;
								mstatus_n[3] = 1'b1;
								mstatus_n[2-:2] = 2'b00;
							end
							2'b11: begin
								mstatus_n[5] = mstatus_q[3];
								priv_lvl_n = 2'b11;
								mstatus_n[3] = 1'b1;
								mstatus_n[2-:2] = 2'b00;
							end
							default:
								;
						endcase
					csr_restore_dret_i: priv_lvl_n = dcsr_q[1-:2];
					default:
						;
				endcase
			end
		end
		else begin : genblk2
			always @(*) begin
				fflags_n = fflags_q;
				frm_n = frm_q;
				fprec_n = fprec_q;
				mscratch_n = mscratch_q;
				mepc_n = mepc_q;
				depc_n = depc_q;
				dcsr_n = dcsr_q;
				dscratch0_n = dscratch0_q;
				dscratch1_n = dscratch1_q;
				mstatus_n = mstatus_q;
				mcause_n = mcause_q;
				hwlp_we_o = 1'sb0;
				hwlp_regid_o = 1'sb0;
				exception_pc = pc_id_i;
				priv_lvl_n = priv_lvl_q;
				mtvec_n = mtvec_q;
				pmp_reg_n[767-:512] = pmp_reg_q[767-:512];
				pmp_reg_n[255-:128] = pmp_reg_q[255-:128];
				pmpaddr_we = 1'sb0;
				pmpcfg_we = 1'sb0;
				if (FPU == 1)
					if (fflags_we_i)
						fflags_n = fflags_i | fflags_q;
				case (csr_addr_i)
					12'h001:
						if (csr_we_int)
							fflags_n = (FPU == 1 ? csr_wdata_int[4:0] : {5 {1'sb0}});
					12'h002:
						if (csr_we_int)
							frm_n = (FPU == 1 ? csr_wdata_int[2:0] : {3 {1'sb0}});
					12'h003:
						if (csr_we_int) begin
							fflags_n = (FPU == 1 ? csr_wdata_int[4:0] : {5 {1'sb0}});
							frm_n = (FPU == 1 ? csr_wdata_int[7:riscv_defines_C_FFLAG] : {3 {1'sb0}});
						end
					12'h006:
						if (csr_we_int)
							fprec_n = (FPU == 1 ? csr_wdata_int[4:0] : {5 {1'sb0}});
					12'h300:
						if (csr_we_int)
							mstatus_n = {csr_wdata_int[0], csr_wdata_int[3], csr_wdata_int[4], csr_wdata_int[7], csr_wdata_int[12:11], csr_wdata_int[17]};
					12'h340:
						if (csr_we_int)
							mscratch_n = csr_wdata_int;
					12'h341:
						if (csr_we_int)
							mepc_n = csr_wdata_int & ~32'b00000000000000000000000000000001;
					12'h342:
						if (csr_we_int)
							mcause_n = {csr_wdata_int[31], csr_wdata_int[4:0]};
					riscv_defines_CSR_DCSR:
						if (csr_we_int) begin
							dcsr_n = csr_wdata_int;
							dcsr_n[31-:4] = 4'h4;
							dcsr_n[1-:2] = priv_lvl_q;
							dcsr_n[3] = 1'b0;
							dcsr_n[4] = 1'b0;
							dcsr_n[10] = 1'b0;
							dcsr_n[9] = 1'b0;
						end
					riscv_defines_CSR_DPC:
						if (csr_we_int)
							depc_n = csr_wdata_int & ~32'b00000000000000000000000000000001;
					riscv_defines_CSR_DSCRATCH0:
						if (csr_we_int)
							dscratch0_n = csr_wdata_int;
					riscv_defines_CSR_DSCRATCH1:
						if (csr_we_int)
							dscratch1_n = csr_wdata_int;
					riscv_defines_HWLoop0_START:
						if (csr_we_int) begin
							hwlp_we_o = 3'b001;
							hwlp_regid_o = 1'b0;
						end
					riscv_defines_HWLoop0_END:
						if (csr_we_int) begin
							hwlp_we_o = 3'b010;
							hwlp_regid_o = 1'b0;
						end
					riscv_defines_HWLoop0_COUNTER:
						if (csr_we_int) begin
							hwlp_we_o = 3'b100;
							hwlp_regid_o = 1'b0;
						end
					riscv_defines_HWLoop1_START:
						if (csr_we_int) begin
							hwlp_we_o = 3'b001;
							hwlp_regid_o = 1'b1;
						end
					riscv_defines_HWLoop1_END:
						if (csr_we_int) begin
							hwlp_we_o = 3'b010;
							hwlp_regid_o = 1'b1;
						end
					riscv_defines_HWLoop1_COUNTER:
						if (csr_we_int) begin
							hwlp_we_o = 3'b100;
							hwlp_regid_o = 1'b1;
						end
				endcase
				case (1'b1)
					csr_save_cause_i: begin
						case (1'b1)
							csr_save_if_i: exception_pc = pc_if_i;
							csr_save_id_i: exception_pc = pc_id_i;
							default:
								;
						endcase
						if (debug_csr_save_i) begin
							dcsr_n[1-:2] = 2'b11;
							dcsr_n[8-:3] = debug_cause_i;
							depc_n = exception_pc;
						end
						else begin
							priv_lvl_n = 2'b11;
							mstatus_n[3] = mstatus_q[5];
							mstatus_n[5] = 1'b0;
							mstatus_n[2-:2] = 2'b11;
							mepc_n = exception_pc;
							mcause_n = csr_cause_i;
						end
					end
					csr_restore_mret_i: begin
						mstatus_n[5] = mstatus_q[3];
						priv_lvl_n = 2'b11;
						mstatus_n[3] = 1'b1;
						mstatus_n[2-:2] = 2'b11;
					end
					csr_restore_dret_i: priv_lvl_n = dcsr_q[1-:2];
					default:
						;
				endcase
			end
		end
	endgenerate
	assign hwlp_data_o = csr_wdata_int;
	localparam riscv_defines_CSR_OP_CLEAR = 2'b11;
	localparam riscv_defines_CSR_OP_NONE = 2'b00;
	localparam riscv_defines_CSR_OP_SET = 2'b10;
	localparam riscv_defines_CSR_OP_WRITE = 2'b01;
	always @(*) begin
		csr_wdata_int = csr_wdata_i;
		csr_we_int = 1'b1;
		case (csr_op_i)
			riscv_defines_CSR_OP_WRITE: csr_wdata_int = csr_wdata_i;
			riscv_defines_CSR_OP_SET: csr_wdata_int = csr_wdata_i | csr_rdata_o;
			riscv_defines_CSR_OP_CLEAR: csr_wdata_int = ~csr_wdata_i & csr_rdata_o;
			riscv_defines_CSR_OP_NONE: begin
				csr_wdata_int = csr_wdata_i;
				csr_we_int = 1'b0;
			end
			default:
				;
		endcase
	end
	always @(*) begin
		csr_rdata_o = csr_rdata_int;
		if ((is_pccr || is_pcer) || is_pcmr)
			csr_rdata_o = perf_rdata;
	end
	assign m_irq_enable_o = mstatus_q[5] & (priv_lvl_q == 2'b11);
	assign u_irq_enable_o = mstatus_q[6] & (priv_lvl_q == 2'b00);
	assign priv_lvl_o = priv_lvl_q;
	assign sec_lvl_o = priv_lvl_q[0];
	assign frm_o = (FPU == 1 ? frm_q : {3 {1'sb0}});
	assign fprec_o = (FPU == 1 ? fprec_q : {5 {1'sb0}});
	assign mtvec_o = mtvec_q;
	assign utvec_o = utvec_q;
	assign mepc_o = mepc_q;
	assign uepc_o = uepc_q;
	assign depc_o = depc_q;
	assign pmp_addr_o = pmp_reg_q[767-:512];
	assign pmp_cfg_o = pmp_reg_q[127-:128];
	assign debug_single_step_o = dcsr_q[2];
	assign debug_ebreakm_o = dcsr_q[15];
	assign debug_ebreaku_o = dcsr_q[12];
	generate
		if (PULP_SECURE == 1) begin : genblk3
			for (j = 0; j < N_PMP_ENTRIES; j = j + 1) begin : CS_PMP_CFG
				wire [8:1] sv2v_tmp_C98C8;
				assign sv2v_tmp_C98C8 = pmp_reg_n[128 + (((j / 4) * 32) + (((8 * ((j % 4) + 1)) - 1) >= (8 * (j % 4)) ? (8 * ((j % 4) + 1)) - 1 : (((8 * ((j % 4) + 1)) - 1) + (((8 * ((j % 4) + 1)) - 1) >= (8 * (j % 4)) ? (((8 * ((j % 4) + 1)) - 1) - (8 * (j % 4))) + 1 : ((8 * (j % 4)) - ((8 * ((j % 4) + 1)) - 1)) + 1)) - 1))-:(((8 * ((j % 4) + 1)) - 1) >= (8 * (j % 4)) ? (((8 * ((j % 4) + 1)) - 1) - (8 * (j % 4))) + 1 : ((8 * (j % 4)) - ((8 * ((j % 4) + 1)) - 1)) + 1)];
				always @(*) pmp_reg_n[0 + (j * 8)+:8] = sv2v_tmp_C98C8;
				wire [(((8 * ((j % 4) + 1)) - 1) >= (8 * (j % 4)) ? (((8 * ((j % 4) + 1)) - 1) - (8 * (j % 4))) + 1 : ((8 * (j % 4)) - ((8 * ((j % 4) + 1)) - 1)) + 1) * 1:1] sv2v_tmp_864C8;
				assign sv2v_tmp_864C8 = pmp_reg_q[0 + (j * 8)+:8];
				always @(*) pmp_reg_q[128 + (((j / 4) * 32) + (((8 * ((j % 4) + 1)) - 1) >= (8 * (j % 4)) ? (8 * ((j % 4) + 1)) - 1 : (((8 * ((j % 4) + 1)) - 1) + (((8 * ((j % 4) + 1)) - 1) >= (8 * (j % 4)) ? (((8 * ((j % 4) + 1)) - 1) - (8 * (j % 4))) + 1 : ((8 * (j % 4)) - ((8 * ((j % 4) + 1)) - 1)) + 1)) - 1))-:(((8 * ((j % 4) + 1)) - 1) >= (8 * (j % 4)) ? (((8 * ((j % 4) + 1)) - 1) - (8 * (j % 4))) + 1 : ((8 * (j % 4)) - ((8 * ((j % 4) + 1)) - 1)) + 1)] = sv2v_tmp_864C8;
			end
			for (j = 0; j < N_PMP_ENTRIES; j = j + 1) begin : CS_PMP_REGS_FF
				always @(posedge clk or negedge rst_n)
					if (rst_n == 1'b0) begin
						pmp_reg_q[0 + (j * 8)+:8] <= 1'sb0;
						pmp_reg_q[256 + (j * 32)+:32] <= 1'sb0;
					end
					else begin
						if (pmpcfg_we[j])
							pmp_reg_q[0 + (j * 8)+:8] <= (USE_PMP ? pmp_reg_n[0 + (j * 8)+:8] : {8 {1'sb0}});
						if (pmpaddr_we[j])
							pmp_reg_q[256 + (j * 32)+:32] <= (USE_PMP ? pmp_reg_n[256 + (j * 32)+:32] : {32 {1'sb0}});
					end
			end
			always @(posedge clk or negedge rst_n)
				if (rst_n == 1'b0) begin
					uepc_q <= 1'sb0;
					ucause_q <= 1'sb0;
					mtvec_q <= 1'sb0;
					utvec_q <= 1'sb0;
					priv_lvl_q <= 2'b11;
				end
				else begin
					uepc_q <= uepc_n;
					ucause_q <= ucause_n;
					mtvec_q <= mtvec_n;
					utvec_q <= utvec_n;
					priv_lvl_q <= priv_lvl_n;
				end
		end
		else begin : genblk3
			wire [32:1] sv2v_tmp_6C649;
			assign sv2v_tmp_6C649 = 1'sb0;
			always @(*) uepc_q = sv2v_tmp_6C649;
			wire [6:1] sv2v_tmp_1A9D8;
			assign sv2v_tmp_1A9D8 = 1'sb0;
			always @(*) ucause_q = sv2v_tmp_1A9D8;
			wire [24:1] sv2v_tmp_5A489;
			assign sv2v_tmp_5A489 = boot_addr_i[30:7];
			always @(*) mtvec_q = sv2v_tmp_5A489;
			wire [24:1] sv2v_tmp_CC076;
			assign sv2v_tmp_CC076 = 1'sb0;
			always @(*) utvec_q = sv2v_tmp_CC076;
			wire [2:1] sv2v_tmp_16422;
			assign sv2v_tmp_16422 = 2'b11;
			always @(*) priv_lvl_q = sv2v_tmp_16422;
		end
	endgenerate
	always @(posedge clk or negedge rst_n)
		if (rst_n == 1'b0) begin
			if (FPU == 1) begin
				frm_q <= 1'sb0;
				fflags_q <= 1'sb0;
				fprec_q <= 1'sb0;
			end
			mstatus_q <= 7'b0000110;
			mepc_q <= 1'sb0;
			mcause_q <= 1'sb0;
			depc_q <= 1'sb0;
			dcsr_q <= 1'sb0;
			dcsr_q[1-:2] <= 2'b11;
			dscratch0_q <= 1'sb0;
			dscratch1_q <= 1'sb0;
			mscratch_q <= 1'sb0;
		end
		else begin
			if (FPU == 1) begin
				frm_q <= frm_n;
				fflags_q <= fflags_n;
				fprec_q <= fprec_n;
			end
			if (PULP_SECURE == 1)
				mstatus_q <= mstatus_n;
			else
				mstatus_q <= {1'b0, mstatus_n[5], 1'b0, mstatus_n[3], 3'b110};
			mepc_q <= mepc_n;
			mcause_q <= mcause_n;
			depc_q <= depc_n;
			dcsr_q <= dcsr_n;
			dscratch0_q <= dscratch0_n;
			dscratch1_q <= dscratch1_n;
			mscratch_q <= mscratch_n;
		end
	assign PCCR_in[0] = 1'b1;
	assign PCCR_in[1] = id_valid_i & is_decoding_i;
	assign PCCR_in[2] = ld_stall_i & id_valid_q;
	assign PCCR_in[3] = jr_stall_i & id_valid_q;
	assign PCCR_in[4] = imiss_i & ~pc_set_i;
	assign PCCR_in[5] = mem_load_i;
	assign PCCR_in[6] = mem_store_i;
	assign PCCR_in[7] = jump_i & id_valid_q;
	assign PCCR_in[8] = branch_i & id_valid_q;
	assign PCCR_in[9] = (branch_i & branch_taken_i) & id_valid_q;
	assign PCCR_in[10] = (id_valid_i & is_decoding_i) & is_compressed_i;
	assign PCCR_in[11] = pipeline_stall_i;
	generate
		if (APU == 1) begin : genblk4
			assign PCCR_in[PERF_APU_ID] = apu_typeconflict_i & ~apu_dep_i;
			assign PCCR_in[PERF_APU_ID + 1] = apu_contention_i;
			assign PCCR_in[PERF_APU_ID + 2] = apu_dep_i & ~apu_contention_i;
			assign PCCR_in[PERF_APU_ID + 3] = apu_wb_i;
		end
	endgenerate
	genvar i;
	generate
		for (i = 0; i < N_EXT_CNT; i = i + 1) begin : genblk5
			assign PCCR_in[PERF_EXT_ID + i] = ext_counters_i[i];
		end
	endgenerate
	localparam riscv_defines_PCER_MACHINE = 12'h7e0;
	localparam riscv_defines_PCER_USER = 12'hcc0;
	localparam riscv_defines_PCMR_MACHINE = 12'h7e1;
	localparam riscv_defines_PCMR_USER = 12'hcc1;
	always @(*) begin
		is_pccr = 1'b0;
		is_pcmr = 1'b0;
		is_pcer = 1'b0;
		pccr_all_sel = 1'b0;
		pccr_index = 1'sb0;
		perf_rdata = 1'sb0;
		if (csr_access_i) begin
			case (csr_addr_i)
				riscv_defines_PCER_USER, riscv_defines_PCER_MACHINE: begin
					is_pcer = 1'b1;
					perf_rdata[N_PERF_COUNTERS - 1:0] = PCER_q;
				end
				riscv_defines_PCMR_USER, riscv_defines_PCMR_MACHINE: begin
					is_pcmr = 1'b1;
					perf_rdata[1:0] = PCMR_q;
				end
				12'h79f: begin
					is_pccr = 1'b1;
					pccr_all_sel = 1'b1;
				end
				default:
					;
			endcase
			if (csr_addr_i[11:5] == 7'b0111100) begin
				is_pccr = 1'b1;
				pccr_index = csr_addr_i[4:0];
				perf_rdata = (csr_addr_i[4:0] < N_PERF_COUNTERS ? PCCR_q[csr_addr_i[4:0] * 32+:32] : {32 {1'sb0}});
			end
		end
	end
	always @(*) begin : sv2v_autoblock_1
		reg signed [31:0] i;
		for (i = 0; i < N_PERF_COUNTERS; i = i + 1)
			begin : PERF_CNT_INC
				PCCR_inc[i] = (PCCR_in[i] & PCER_q[i]) & PCMR_q[0];
				PCCR_n[i * 32+:32] = PCCR_q[i * 32+:32];
				if ((PCCR_inc_q[i] == 1'b1) && ((PCCR_q[i * 32+:32] != 32'hffffffff) || (PCMR_q[1] == 1'b0)))
					PCCR_n[i * 32+:32] = PCCR_q[i * 32+:32] + 1;
				if ((is_pccr == 1'b1) && ((pccr_all_sel == 1'b1) || (pccr_index == i)))
					case (csr_op_i)
						riscv_defines_CSR_OP_NONE:
							;
						riscv_defines_CSR_OP_WRITE: PCCR_n[i * 32+:32] = csr_wdata_i;
						riscv_defines_CSR_OP_SET: PCCR_n[i * 32+:32] = csr_wdata_i | PCCR_q[i * 32+:32];
						riscv_defines_CSR_OP_CLEAR: PCCR_n[i * 32+:32] = csr_wdata_i & ~PCCR_q[i * 32+:32];
					endcase
			end
	end
	always @(*) begin
		PCMR_n = PCMR_q;
		PCER_n = PCER_q;
		if (is_pcmr)
			case (csr_op_i)
				riscv_defines_CSR_OP_NONE:
					;
				riscv_defines_CSR_OP_WRITE: PCMR_n = csr_wdata_i[1:0];
				riscv_defines_CSR_OP_SET: PCMR_n = csr_wdata_i[1:0] | PCMR_q;
				riscv_defines_CSR_OP_CLEAR: PCMR_n = csr_wdata_i[1:0] & ~PCMR_q;
			endcase
		if (is_pcer)
			case (csr_op_i)
				riscv_defines_CSR_OP_NONE:
					;
				riscv_defines_CSR_OP_WRITE: PCER_n = csr_wdata_i[N_PERF_COUNTERS - 1:0];
				riscv_defines_CSR_OP_SET: PCER_n = csr_wdata_i[N_PERF_COUNTERS - 1:0] | PCER_q;
				riscv_defines_CSR_OP_CLEAR: PCER_n = csr_wdata_i[N_PERF_COUNTERS - 1:0] & ~PCER_q;
			endcase
	end
	always @(posedge clk or negedge rst_n)
		if (rst_n == 1'b0) begin
			id_valid_q <= 1'b0;
			PCER_q <= 1'sb0;
			PCMR_q <= 2'h3;
			begin : sv2v_autoblock_2
				reg signed [31:0] i;
				for (i = 0; i < N_PERF_REGS; i = i + 1)
					begin
						PCCR_q[i * 32+:32] <= 1'sb0;
						PCCR_inc_q[i] <= 1'sb0;
					end
			end
		end
		else begin
			id_valid_q <= id_valid_i;
			PCER_q <= PCER_n;
			PCMR_q <= PCMR_n;
			begin : sv2v_autoblock_3
				reg signed [31:0] i;
				for (i = 0; i < N_PERF_REGS; i = i + 1)
					begin
						PCCR_q[i * 32+:32] <= PCCR_n[i * 32+:32];
						PCCR_inc_q[i] <= PCCR_inc[i];
					end
			end
		end
endmodule
