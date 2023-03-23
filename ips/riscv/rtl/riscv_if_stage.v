module riscv_if_stage (
	clk,
	rst_n,
	m_trap_base_addr_i,
	u_trap_base_addr_i,
	trap_addr_mux_i,
	boot_addr_i,
	req_i,
	instr_req_o,
	instr_addr_o,
	instr_gnt_i,
	instr_rvalid_i,
	instr_rdata_i,
	instr_err_pmp_i,
	hwlp_dec_cnt_id_o,
	is_hwlp_id_o,
	instr_valid_id_o,
	instr_rdata_id_o,
	is_compressed_id_o,
	illegal_c_insn_id_o,
	pc_if_o,
	pc_id_o,
	is_fetch_failed_o,
	clear_instr_valid_i,
	pc_set_i,
	mepc_i,
	uepc_i,
	depc_i,
	pc_mux_i,
	exc_pc_mux_i,
	exc_vec_pc_mux_i,
	jump_target_id_i,
	jump_target_ex_i,
	hwlp_start_i,
	hwlp_end_i,
	hwlp_cnt_i,
	halt_if_i,
	id_ready_i,
	if_busy_o,
	perf_imiss_o
);
	parameter N_HWLP = 2;
	parameter RDATA_WIDTH = 32;
	parameter FPU = 0;
	parameter DM_HaltAddress = 32'h1a110800;
	input wire clk;
	input wire rst_n;
	input wire [23:0] m_trap_base_addr_i;
	input wire [23:0] u_trap_base_addr_i;
	input wire trap_addr_mux_i;
	input wire [30:0] boot_addr_i;
	input wire req_i;
	output wire instr_req_o;
	output wire [31:0] instr_addr_o;
	input wire instr_gnt_i;
	input wire instr_rvalid_i;
	input wire [RDATA_WIDTH - 1:0] instr_rdata_i;
	input wire instr_err_pmp_i;
	output reg [N_HWLP - 1:0] hwlp_dec_cnt_id_o;
	output wire is_hwlp_id_o;
	output reg instr_valid_id_o;
	output reg [31:0] instr_rdata_id_o;
	output reg is_compressed_id_o;
	output reg illegal_c_insn_id_o;
	output wire [31:0] pc_if_o;
	output reg [31:0] pc_id_o;
	output reg is_fetch_failed_o;
	input wire clear_instr_valid_i;
	input wire pc_set_i;
	input wire [31:0] mepc_i;
	input wire [31:0] uepc_i;
	input wire [31:0] depc_i;
	input wire [2:0] pc_mux_i;
	input wire [2:0] exc_pc_mux_i;
	input wire [4:0] exc_vec_pc_mux_i;
	input wire [31:0] jump_target_id_i;
	input wire [31:0] jump_target_ex_i;
	input wire [(N_HWLP * 32) - 1:0] hwlp_start_i;
	input wire [(N_HWLP * 32) - 1:0] hwlp_end_i;
	input wire [(N_HWLP * 32) - 1:0] hwlp_cnt_i;
	input wire halt_if_i;
	input wire id_ready_i;
	output wire if_busy_o;
	output wire perf_imiss_o;
	reg [0:0] offset_fsm_cs;
	reg [0:0] offset_fsm_ns;
	wire if_valid;
	wire if_ready;
	reg valid;
	wire prefetch_busy;
	reg branch_req;
	reg [31:0] fetch_addr_n;
	wire fetch_valid;
	reg fetch_ready;
	wire [31:0] fetch_rdata;
	wire [31:0] fetch_addr;
	reg is_hwlp_id_q;
	wire fetch_is_hwlp;
	reg [31:0] exc_pc;
	wire hwlp_jump;
	wire hwlp_branch;
	wire [31:0] hwlp_target;
	wire [N_HWLP - 1:0] hwlp_dec_cnt;
	reg [N_HWLP - 1:0] hwlp_dec_cnt_if;
	reg [23:0] trap_base_addr;
	wire fetch_failed;
	localparam riscv_defines_EXC_PC_DBD = 3'b010;
	localparam riscv_defines_EXC_PC_EXCEPTION = 3'b000;
	localparam riscv_defines_EXC_PC_IRQ = 3'b001;
	localparam riscv_defines_TRAP_MACHINE = 1'b0;
	localparam riscv_defines_TRAP_USER = 1'b1;
	always @(*) begin : EXC_PC_MUX
		exc_pc = 1'sb0;
		case (trap_addr_mux_i)
			riscv_defines_TRAP_MACHINE: trap_base_addr = m_trap_base_addr_i;
			riscv_defines_TRAP_USER: trap_base_addr = u_trap_base_addr_i;
			default:
				;
		endcase
		case (exc_pc_mux_i)
			riscv_defines_EXC_PC_EXCEPTION: exc_pc = {trap_base_addr, 8'h00};
			riscv_defines_EXC_PC_IRQ: exc_pc = {trap_base_addr, 1'b0, exc_vec_pc_mux_i[4:0], 2'b00};
			riscv_defines_EXC_PC_DBD: exc_pc = {DM_HaltAddress};
			default:
				;
		endcase
	end
	localparam riscv_defines_PC_BOOT = 3'b000;
	localparam riscv_defines_PC_BRANCH = 3'b011;
	localparam riscv_defines_PC_DRET = 3'b111;
	localparam riscv_defines_PC_EXCEPTION = 3'b100;
	localparam riscv_defines_PC_FENCEI = 3'b001;
	localparam riscv_defines_PC_JUMP = 3'b010;
	localparam riscv_defines_PC_MRET = 3'b101;
	localparam riscv_defines_PC_URET = 3'b110;
	always @(*) begin
		fetch_addr_n = 1'sb0;
		case (pc_mux_i)
			riscv_defines_PC_BOOT: fetch_addr_n = {boot_addr_i, 1'b0};
			riscv_defines_PC_JUMP: fetch_addr_n = jump_target_id_i;
			riscv_defines_PC_BRANCH: fetch_addr_n = jump_target_ex_i;
			riscv_defines_PC_EXCEPTION: fetch_addr_n = exc_pc;
			riscv_defines_PC_MRET: fetch_addr_n = mepc_i;
			riscv_defines_PC_URET: fetch_addr_n = uepc_i;
			riscv_defines_PC_DRET: fetch_addr_n = depc_i;
			riscv_defines_PC_FENCEI: fetch_addr_n = pc_id_o + 4;
			default:
				;
		endcase
	end
	generate
		if (RDATA_WIDTH == 32) begin : prefetch_32
			riscv_prefetch_buffer prefetch_buffer_i(
				.clk(clk),
				.rst_n(rst_n),
				.req_i(req_i),
				.branch_i(branch_req),
				.addr_i({fetch_addr_n[31:1], 1'b0}),
				.hwloop_i(hwlp_jump),
				.hwloop_target_i(hwlp_target),
				.hwlp_branch_o(hwlp_branch),
				.ready_i(fetch_ready),
				.valid_o(fetch_valid),
				.rdata_o(fetch_rdata),
				.addr_o(fetch_addr),
				.is_hwlp_o(fetch_is_hwlp),
				.instr_req_o(instr_req_o),
				.instr_addr_o(instr_addr_o),
				.instr_gnt_i(instr_gnt_i),
				.instr_rvalid_i(instr_rvalid_i),
				.instr_err_pmp_i(instr_err_pmp_i),
				.fetch_failed_o(fetch_failed),
				.instr_rdata_i(instr_rdata_i),
				.busy_o(prefetch_busy)
			);
		end
		else if (RDATA_WIDTH == 128) begin : prefetch_128
			riscv_prefetch_L0_buffer prefetch_buffer_i(
				.clk(clk),
				.rst_n(rst_n),
				.req_i(1'b1),
				.branch_i(branch_req),
				.addr_i({fetch_addr_n[31:1], 1'b0}),
				.hwloop_i(hwlp_jump),
				.hwloop_target_i(hwlp_target),
				.ready_i(fetch_ready),
				.valid_o(fetch_valid),
				.rdata_o(fetch_rdata),
				.addr_o(fetch_addr),
				.is_hwlp_o(fetch_is_hwlp),
				.instr_req_o(instr_req_o),
				.instr_addr_o(instr_addr_o),
				.instr_gnt_i(instr_gnt_i),
				.instr_rvalid_i(instr_rvalid_i),
				.instr_rdata_i(instr_rdata_i),
				.busy_o(prefetch_busy)
			);
			assign hwlp_branch = 1'b0;
			assign fetch_failed = 1'b0;
		end
	endgenerate
	always @(posedge clk or negedge rst_n)
		if (rst_n == 1'b0)
			offset_fsm_cs <= 1'd1;
		else
			offset_fsm_cs <= offset_fsm_ns;
	always @(*) begin
		offset_fsm_ns = offset_fsm_cs;
		fetch_ready = 1'b0;
		branch_req = 1'b0;
		valid = 1'b0;
		case (offset_fsm_cs)
			1'd1:
				if (req_i) begin
					branch_req = 1'b1;
					offset_fsm_ns = 1'd0;
				end
			1'd0:
				if (fetch_valid) begin
					valid = 1'b1;
					if (req_i && if_valid) begin
						fetch_ready = 1'b1;
						offset_fsm_ns = 1'd0;
					end
				end
			default: offset_fsm_ns = 1'd1;
		endcase
		if (pc_set_i) begin
			valid = 1'b0;
			branch_req = 1'b1;
			offset_fsm_ns = 1'd0;
		end
		else if (hwlp_branch)
			valid = 1'b0;
	end
	riscv_hwloop_controller #(.N_REGS(N_HWLP)) hwloop_controller_i(
		.current_pc_i(fetch_addr),
		.hwlp_jump_o(hwlp_jump),
		.hwlp_targ_addr_o(hwlp_target),
		.hwlp_start_addr_i(hwlp_start_i),
		.hwlp_end_addr_i(hwlp_end_i),
		.hwlp_counter_i(hwlp_cnt_i),
		.hwlp_dec_cnt_o(hwlp_dec_cnt),
		.hwlp_dec_cnt_id_i(hwlp_dec_cnt_id_o & {N_HWLP {is_hwlp_id_o}})
	);
	assign pc_if_o = fetch_addr;
	assign if_busy_o = prefetch_busy;
	assign perf_imiss_o = ~fetch_valid | branch_req;
	wire [31:0] instr_decompressed;
	wire illegal_c_insn;
	wire instr_compressed_int;
	riscv_compressed_decoder #(.FPU(FPU)) compressed_decoder_i(
		.instr_i(fetch_rdata),
		.instr_o(instr_decompressed),
		.is_compressed_o(instr_compressed_int),
		.illegal_instr_o(illegal_c_insn)
	);
	always @(posedge clk or negedge rst_n)
		if (rst_n == 1'b0)
			hwlp_dec_cnt_if <= 1'sb0;
		else if (hwlp_jump)
			hwlp_dec_cnt_if <= hwlp_dec_cnt;
	always @(posedge clk or negedge rst_n) begin : IF_ID_PIPE_REGISTERS
		if (rst_n == 1'b0) begin
			instr_valid_id_o <= 1'b0;
			instr_rdata_id_o <= 1'sb0;
			illegal_c_insn_id_o <= 1'b0;
			is_compressed_id_o <= 1'b0;
			pc_id_o <= 1'sb0;
			is_hwlp_id_q <= 1'b0;
			hwlp_dec_cnt_id_o <= 1'sb0;
			is_fetch_failed_o <= 1'b0;
		end
		else if (if_valid) begin
			instr_valid_id_o <= 1'b1;
			instr_rdata_id_o <= instr_decompressed;
			illegal_c_insn_id_o <= illegal_c_insn;
			is_compressed_id_o <= instr_compressed_int;
			pc_id_o <= pc_if_o;
			is_hwlp_id_q <= fetch_is_hwlp;
			is_fetch_failed_o <= 1'b0;
			if (fetch_is_hwlp)
				hwlp_dec_cnt_id_o <= hwlp_dec_cnt_if;
		end
		else if (clear_instr_valid_i) begin
			instr_valid_id_o <= 1'b0;
			is_fetch_failed_o <= fetch_failed;
		end
	end
	assign is_hwlp_id_o = is_hwlp_id_q & instr_valid_id_o;
	assign if_ready = valid & id_ready_i;
	assign if_valid = ~halt_if_i & if_ready;
endmodule
