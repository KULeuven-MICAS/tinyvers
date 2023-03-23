module riscv_ex_stage (
	clk,
	rst_n,
	alu_operator_i,
	alu_operand_a_i,
	alu_operand_b_i,
	alu_operand_c_i,
	alu_en_i,
	bmask_a_i,
	bmask_b_i,
	imm_vec_ext_i,
	alu_vec_mode_i,
	alu_is_clpx_i,
	alu_is_subrot_i,
	alu_clpx_shift_i,
	mult_operator_i,
	mult_operand_a_i,
	mult_operand_b_i,
	mult_operand_c_i,
	mult_en_i,
	mult_sel_subword_i,
	mult_signed_mode_i,
	mult_imm_i,
	mult_dot_op_a_i,
	mult_dot_op_b_i,
	mult_dot_op_c_i,
	mult_dot_signed_i,
	mult_is_clpx_i,
	mult_clpx_shift_i,
	mult_clpx_img_i,
	mult_multicycle_o,
	fpu_prec_i,
	fpu_fflags_o,
	fpu_fflags_we_o,
	apu_en_i,
	apu_op_i,
	apu_lat_i,
	apu_operands_i,
	apu_waddr_i,
	apu_flags_i,
	apu_read_regs_i,
	apu_read_regs_valid_i,
	apu_read_dep_o,
	apu_write_regs_i,
	apu_write_regs_valid_i,
	apu_write_dep_o,
	apu_perf_type_o,
	apu_perf_cont_o,
	apu_perf_wb_o,
	apu_busy_o,
	apu_ready_wb_o,
	apu_master_req_o,
	apu_master_ready_o,
	apu_master_gnt_i,
	apu_master_operands_o,
	apu_master_op_o,
	apu_master_valid_i,
	apu_master_result_i,
	lsu_en_i,
	lsu_rdata_i,
	branch_in_ex_i,
	regfile_alu_waddr_i,
	regfile_alu_we_i,
	regfile_we_i,
	regfile_waddr_i,
	csr_access_i,
	csr_rdata_i,
	regfile_waddr_wb_o,
	regfile_we_wb_o,
	regfile_wdata_wb_o,
	regfile_alu_waddr_fw_o,
	regfile_alu_we_fw_o,
	regfile_alu_wdata_fw_o,
	jump_target_o,
	branch_decision_o,
	lsu_ready_ex_i,
	lsu_err_i,
	ex_ready_o,
	ex_valid_o,
	wb_ready_i
);
	parameter FPU = 0;
	parameter FP_DIVSQRT = 0;
	parameter SHARED_FP = 0;
	parameter SHARED_DSP_MULT = 0;
	parameter SHARED_INT_DIV = 0;
	parameter APU_NARGS_CPU = 3;
	parameter APU_WOP_CPU = 6;
	parameter APU_NDSFLAGS_CPU = 15;
	parameter APU_NUSFLAGS_CPU = 5;
	input wire clk;
	input wire rst_n;
	localparam riscv_defines_ALU_OP_WIDTH = 7;
	input wire [6:0] alu_operator_i;
	input wire [31:0] alu_operand_a_i;
	input wire [31:0] alu_operand_b_i;
	input wire [31:0] alu_operand_c_i;
	input wire alu_en_i;
	input wire [4:0] bmask_a_i;
	input wire [4:0] bmask_b_i;
	input wire [1:0] imm_vec_ext_i;
	input wire [1:0] alu_vec_mode_i;
	input wire alu_is_clpx_i;
	input wire alu_is_subrot_i;
	input wire [1:0] alu_clpx_shift_i;
	input wire [2:0] mult_operator_i;
	input wire [31:0] mult_operand_a_i;
	input wire [31:0] mult_operand_b_i;
	input wire [31:0] mult_operand_c_i;
	input wire mult_en_i;
	input wire mult_sel_subword_i;
	input wire [1:0] mult_signed_mode_i;
	input wire [4:0] mult_imm_i;
	input wire [31:0] mult_dot_op_a_i;
	input wire [31:0] mult_dot_op_b_i;
	input wire [31:0] mult_dot_op_c_i;
	input wire [1:0] mult_dot_signed_i;
	input wire mult_is_clpx_i;
	input wire [1:0] mult_clpx_shift_i;
	input wire mult_clpx_img_i;
	output wire mult_multicycle_o;
	localparam riscv_defines_C_PC = 5;
	input wire [4:0] fpu_prec_i;
	localparam riscv_defines_C_FFLAG = 5;
	output wire [4:0] fpu_fflags_o;
	output wire fpu_fflags_we_o;
	input wire apu_en_i;
	input wire [APU_WOP_CPU - 1:0] apu_op_i;
	input wire [1:0] apu_lat_i;
	input wire [(APU_NARGS_CPU * 32) - 1:0] apu_operands_i;
	input wire [5:0] apu_waddr_i;
	input wire [APU_NDSFLAGS_CPU - 1:0] apu_flags_i;
	input wire [17:0] apu_read_regs_i;
	input wire [2:0] apu_read_regs_valid_i;
	output wire apu_read_dep_o;
	input wire [11:0] apu_write_regs_i;
	input wire [1:0] apu_write_regs_valid_i;
	output wire apu_write_dep_o;
	output wire apu_perf_type_o;
	output wire apu_perf_cont_o;
	output wire apu_perf_wb_o;
	output wire apu_busy_o;
	output wire apu_ready_wb_o;
	output wire apu_master_req_o;
	output wire apu_master_ready_o;
	input wire apu_master_gnt_i;
	output wire [(APU_NARGS_CPU * 32) - 1:0] apu_master_operands_o;
	output wire [APU_WOP_CPU - 1:0] apu_master_op_o;
	input wire apu_master_valid_i;
	input wire [31:0] apu_master_result_i;
	input wire lsu_en_i;
	input wire [31:0] lsu_rdata_i;
	input wire branch_in_ex_i;
	input wire [5:0] regfile_alu_waddr_i;
	input wire regfile_alu_we_i;
	input wire regfile_we_i;
	input wire [5:0] regfile_waddr_i;
	input wire csr_access_i;
	input wire [31:0] csr_rdata_i;
	output reg [5:0] regfile_waddr_wb_o;
	output reg regfile_we_wb_o;
	output reg [31:0] regfile_wdata_wb_o;
	output reg [5:0] regfile_alu_waddr_fw_o;
	output reg regfile_alu_we_fw_o;
	output reg [31:0] regfile_alu_wdata_fw_o;
	output wire [31:0] jump_target_o;
	output wire branch_decision_o;
	input wire lsu_ready_ex_i;
	input wire lsu_err_i;
	output wire ex_ready_o;
	output wire ex_valid_o;
	input wire wb_ready_i;
	wire [31:0] alu_result;
	wire [31:0] mult_result;
	wire alu_cmp_result;
	reg regfile_we_lsu;
	reg [5:0] regfile_waddr_lsu;
	reg wb_contention;
	reg wb_contention_lsu;
	wire alu_ready;
	wire mult_ready;
	wire fpu_ready;
	wire fpu_valid;
	wire apu_valid;
	wire [5:0] apu_waddr;
	wire [31:0] apu_result;
	wire apu_stall;
	wire apu_active;
	wire apu_singlecycle;
	wire apu_multicycle;
	wire apu_req;
	wire apu_ready;
	wire apu_gnt;
	always @(*) begin
		regfile_alu_wdata_fw_o = 1'sb0;
		regfile_alu_waddr_fw_o = 1'sb0;
		regfile_alu_we_fw_o = 1'sb0;
		wb_contention = 1'b0;
		if (apu_valid & (apu_singlecycle | apu_multicycle)) begin
			regfile_alu_we_fw_o = 1'b1;
			regfile_alu_waddr_fw_o = apu_waddr;
			regfile_alu_wdata_fw_o = apu_result;
			if (regfile_alu_we_i & ~apu_en_i)
				wb_contention = 1'b1;
		end
		else begin
			regfile_alu_we_fw_o = regfile_alu_we_i & ~apu_en_i;
			regfile_alu_waddr_fw_o = regfile_alu_waddr_i;
			if (alu_en_i)
				regfile_alu_wdata_fw_o = alu_result;
			if (mult_en_i)
				regfile_alu_wdata_fw_o = mult_result;
			if (csr_access_i)
				regfile_alu_wdata_fw_o = csr_rdata_i;
		end
	end
	always @(*) begin
		regfile_we_wb_o = 1'b0;
		regfile_waddr_wb_o = regfile_waddr_lsu;
		regfile_wdata_wb_o = lsu_rdata_i;
		wb_contention_lsu = 1'b0;
		if (regfile_we_lsu) begin
			regfile_we_wb_o = 1'b1;
			if (apu_valid & (!apu_singlecycle & !apu_multicycle))
				wb_contention_lsu = 1'b1;
		end
		else if (apu_valid & (!apu_singlecycle & !apu_multicycle)) begin
			regfile_we_wb_o = 1'b1;
			regfile_waddr_wb_o = apu_waddr;
			regfile_wdata_wb_o = apu_result;
		end
	end
	assign branch_decision_o = alu_cmp_result;
	assign jump_target_o = alu_operand_c_i;
	riscv_alu #(
		.SHARED_INT_DIV(SHARED_INT_DIV),
		.FPU(FPU)
	) alu_i(
		.clk(clk),
		.rst_n(rst_n),
		.enable_i(alu_en_i),
		.operator_i(alu_operator_i),
		.operand_a_i(alu_operand_a_i),
		.operand_b_i(alu_operand_b_i),
		.operand_c_i(alu_operand_c_i),
		.vector_mode_i(alu_vec_mode_i),
		.bmask_a_i(bmask_a_i),
		.bmask_b_i(bmask_b_i),
		.imm_vec_ext_i(imm_vec_ext_i),
		.is_clpx_i(alu_is_clpx_i),
		.clpx_shift_i(alu_clpx_shift_i),
		.is_subrot_i(alu_is_subrot_i),
		.result_o(alu_result),
		.comparison_result_o(alu_cmp_result),
		.ready_o(alu_ready),
		.ex_ready_i(ex_ready_o)
	);
	riscv_mult #(.SHARED_DSP_MULT(SHARED_DSP_MULT)) mult_i(
		.clk(clk),
		.rst_n(rst_n),
		.enable_i(mult_en_i),
		.operator_i(mult_operator_i),
		.short_subword_i(mult_sel_subword_i),
		.short_signed_i(mult_signed_mode_i),
		.op_a_i(mult_operand_a_i),
		.op_b_i(mult_operand_b_i),
		.op_c_i(mult_operand_c_i),
		.imm_i(mult_imm_i),
		.dot_op_a_i(mult_dot_op_a_i),
		.dot_op_b_i(mult_dot_op_b_i),
		.dot_op_c_i(mult_dot_op_c_i),
		.dot_signed_i(mult_dot_signed_i),
		.is_clpx_i(mult_is_clpx_i),
		.clpx_shift_i(mult_clpx_shift_i),
		.clpx_img_i(mult_clpx_img_i),
		.result_o(mult_result),
		.multicycle_o(mult_multicycle_o),
		.ready_o(mult_ready),
		.ex_ready_i(ex_ready_o)
	);
	localparam [31:0] fpnew_pkg_NUM_FP_FORMATS = 5;
	localparam [31:0] fpnew_pkg_FP_FORMAT_BITS = 3;
	localparam [31:0] fpnew_pkg_NUM_INT_FORMATS = 4;
	localparam [31:0] fpnew_pkg_NUM_OPGROUPS = 4;
	localparam [31:0] fpnew_pkg_INT_FORMAT_BITS = 2;
	localparam [31:0] fpnew_pkg_OP_BITS = 4;
	localparam [0:0] riscv_defines_C_RVD = 1'b0;
	localparam [0:0] riscv_defines_C_RVF = 1'b1;
	localparam [0:0] riscv_defines_C_XF16 = 1'b0;
	localparam [0:0] riscv_defines_C_XF16ALT = 1'b0;
	localparam [0:0] riscv_defines_C_XF8 = 1'b0;
	localparam riscv_defines_C_FLEN = (riscv_defines_C_RVD ? 64 : (riscv_defines_C_RVF ? 32 : (riscv_defines_C_XF16 ? 16 : (riscv_defines_C_XF16ALT ? 16 : (riscv_defines_C_XF8 ? 8 : 0)))));
	localparam riscv_defines_C_FPNEW_FMTBITS = fpnew_pkg_FP_FORMAT_BITS;
	localparam riscv_defines_C_FPNEW_IFMTBITS = fpnew_pkg_INT_FORMAT_BITS;
	localparam riscv_defines_C_FPNEW_OPBITS = fpnew_pkg_OP_BITS;
	localparam [31:0] riscv_defines_C_LAT_CONV = 'd0;
	localparam [31:0] riscv_defines_C_LAT_DIVSQRT = 'd1;
	localparam [31:0] riscv_defines_C_LAT_FP16 = 'd0;
	localparam [31:0] riscv_defines_C_LAT_FP16ALT = 'd0;
	localparam [31:0] riscv_defines_C_LAT_FP32 = 'd0;
	localparam [31:0] riscv_defines_C_LAT_FP64 = 'd0;
	localparam [31:0] riscv_defines_C_LAT_FP8 = 'd0;
	localparam [31:0] riscv_defines_C_LAT_NONCOMP = 'd0;
	localparam riscv_defines_C_RM = 3;
	localparam [0:0] riscv_defines_C_XFVEC = 1'b0;
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
	function automatic [31:0] sv2v_cast_32;
		input reg [31:0] inp;
		sv2v_cast_32 = inp;
	endfunction
	function automatic [4:0] sv2v_cast_5;
		input reg [4:0] inp;
		sv2v_cast_5 = inp;
	endfunction
	function automatic [3:0] sv2v_cast_4;
		input reg [3:0] inp;
		sv2v_cast_4 = inp;
	endfunction
	function automatic [((32'd4 * 32'd5) * 32) - 1:0] sv2v_cast_CDC93;
		input reg [((32'd4 * 32'd5) * 32) - 1:0] inp;
		sv2v_cast_CDC93 = inp;
	endfunction
	function automatic [((32'd4 * 32'd5) * 2) - 1:0] sv2v_cast_15FEF;
		input reg [((32'd4 * 32'd5) * 2) - 1:0] inp;
		sv2v_cast_15FEF = inp;
	endfunction
	generate
		if (FPU == 1) begin : genblk1
			riscv_apu_disp apu_disp_i(
				.clk_i(clk),
				.rst_ni(rst_n),
				.enable_i(apu_en_i),
				.apu_lat_i(apu_lat_i),
				.apu_waddr_i(apu_waddr_i),
				.apu_waddr_o(apu_waddr),
				.apu_multicycle_o(apu_multicycle),
				.apu_singlecycle_o(apu_singlecycle),
				.active_o(apu_active),
				.stall_o(apu_stall),
				.read_regs_i(apu_read_regs_i),
				.read_regs_valid_i(apu_read_regs_valid_i),
				.read_dep_o(apu_read_dep_o),
				.write_regs_i(apu_write_regs_i),
				.write_regs_valid_i(apu_write_regs_valid_i),
				.write_dep_o(apu_write_dep_o),
				.perf_type_o(apu_perf_type_o),
				.perf_cont_o(apu_perf_cont_o),
				.apu_master_req_o(apu_req),
				.apu_master_ready_o(apu_ready),
				.apu_master_gnt_i(apu_gnt),
				.apu_master_valid_i(apu_valid)
			);
			assign apu_perf_wb_o = wb_contention | wb_contention_lsu;
			assign apu_ready_wb_o = ~((apu_active | apu_en_i) | apu_stall) | apu_valid;
			if (SHARED_FP) begin : genblk1
				assign apu_master_req_o = apu_req;
				assign apu_master_ready_o = apu_ready;
				assign apu_gnt = apu_master_gnt_i;
				assign apu_valid = apu_master_valid_i;
				assign apu_master_operands_o = apu_operands_i;
				assign apu_master_op_o = apu_op_i;
				assign apu_result = apu_master_result_i;
				assign fpu_fflags_we_o = apu_valid;
				assign fpu_ready = 1'b1;
			end
			else begin : genblk1
				wire [3:0] fpu_op;
				wire fpu_op_mod;
				wire fpu_vec_op;
				wire [2:0] fpu_dst_fmt;
				wire [2:0] fpu_src_fmt;
				wire [1:0] fpu_int_fmt;
				wire [2:0] fp_rnd_mode;
				assign {fpu_vec_op, fpu_op_mod, fpu_op} = apu_op_i;
				assign {fpu_int_fmt, fpu_src_fmt, fpu_dst_fmt, fp_rnd_mode} = apu_flags_i;
				localparam C_DIV = (FP_DIVSQRT ? 2'd2 : 2'd0);
				wire FPU_ready_int;
				localparam [42:0] FPU_FEATURES = {sv2v_cast_32(riscv_defines_C_FLEN), riscv_defines_C_XFVEC, 1'b0, sv2v_cast_5({riscv_defines_C_RVF, riscv_defines_C_RVD, riscv_defines_C_XF16, riscv_defines_C_XF8, riscv_defines_C_XF16ALT}), sv2v_cast_4({riscv_defines_C_XFVEC && riscv_defines_C_XF8, riscv_defines_C_XFVEC && (riscv_defines_C_XF16 || riscv_defines_C_XF16ALT), 2'b10})};
				localparam [(((fpnew_pkg_NUM_OPGROUPS * fpnew_pkg_NUM_FP_FORMATS) * 32) + ((fpnew_pkg_NUM_OPGROUPS * fpnew_pkg_NUM_FP_FORMATS) * 2)) + 1:0] FPU_IMPLEMENTATION = {sv2v_cast_CDC93({riscv_defines_C_LAT_FP32, riscv_defines_C_LAT_FP64, riscv_defines_C_LAT_FP16, riscv_defines_C_LAT_FP8, riscv_defines_C_LAT_FP16ALT, {fpnew_pkg_NUM_FP_FORMATS {riscv_defines_C_LAT_DIVSQRT}}, {fpnew_pkg_NUM_FP_FORMATS {riscv_defines_C_LAT_NONCOMP}}, {fpnew_pkg_NUM_FP_FORMATS {riscv_defines_C_LAT_CONV}}}), sv2v_cast_15FEF({{fpnew_pkg_NUM_FP_FORMATS {2'd2}}, {fpnew_pkg_NUM_FP_FORMATS {C_DIV}}, {fpnew_pkg_NUM_FP_FORMATS {2'd1}}, {fpnew_pkg_NUM_FP_FORMATS {2'd2}}}), 2'd1};
				fpnew_top_FF541 #(
					.Features(FPU_FEATURES),
					.Implementation(FPU_IMPLEMENTATION)
				) i_fpnew_bulk(
					.clk_i(clk),
					.rst_ni(rst_n),
					.operands_i(apu_operands_i),
					.rnd_mode_i(fp_rnd_mode),
					.op_i(sv2v_cast_A53F3(fpu_op)),
					.op_mod_i(fpu_op_mod),
					.src_fmt_i(sv2v_cast_0BC43(fpu_src_fmt)),
					.dst_fmt_i(sv2v_cast_0BC43(fpu_dst_fmt)),
					.int_fmt_i(sv2v_cast_87CC5(fpu_int_fmt)),
					.vectorial_op_i(fpu_vec_op),
					.tag_i(1'b0),
					.in_valid_i(apu_req),
					.in_ready_o(FPU_ready_int),
					.flush_i(1'b0),
					.result_o(apu_result),
					.status_o(fpu_fflags_o),
					.tag_o(),
					.out_valid_o(apu_valid),
					.out_ready_i(1'b1),
					.busy_o()
				);
				assign fpu_fflags_we_o = apu_valid;
				assign apu_master_req_o = 1'sb0;
				assign apu_master_ready_o = 1'b1;
				assign apu_master_operands_o[0+:32] = 1'sb0;
				assign apu_master_operands_o[32+:32] = 1'sb0;
				assign apu_master_operands_o[64+:32] = 1'sb0;
				assign apu_master_op_o = 1'sb0;
				assign apu_gnt = 1'b1;
				assign fpu_ready = (FPU_ready_int & apu_req) | ~apu_req;
			end
		end
		else begin : genblk1
			assign apu_master_req_o = 1'sb0;
			assign apu_master_ready_o = 1'b1;
			assign apu_master_operands_o[0+:32] = 1'sb0;
			assign apu_master_operands_o[32+:32] = 1'sb0;
			assign apu_master_operands_o[64+:32] = 1'sb0;
			assign apu_master_op_o = 1'sb0;
			assign apu_valid = 1'b0;
			assign apu_waddr = 6'b000000;
			assign apu_stall = 1'b0;
			assign apu_active = 1'b0;
			assign apu_ready_wb_o = 1'b1;
			assign apu_perf_wb_o = 1'b0;
			assign apu_perf_cont_o = 1'b0;
			assign apu_perf_type_o = 1'b0;
			assign apu_singlecycle = 1'b0;
			assign apu_multicycle = 1'b0;
			assign apu_read_dep_o = 1'b0;
			assign apu_write_dep_o = 1'b0;
			assign fpu_fflags_we_o = 1'b0;
			assign fpu_fflags_o = 1'sb0;
			assign fpu_ready = 1'b1;
		end
	endgenerate
	assign apu_busy_o = apu_active;
	always @(posedge clk or negedge rst_n) begin : EX_WB_Pipeline_Register
		if (~rst_n) begin
			regfile_waddr_lsu <= 1'sb0;
			regfile_we_lsu <= 1'b0;
		end
		else if (ex_valid_o) begin
			regfile_we_lsu <= regfile_we_i & ~lsu_err_i;
			if (regfile_we_i & ~lsu_err_i)
				regfile_waddr_lsu <= regfile_waddr_i;
		end
		else if (wb_ready_i)
			regfile_we_lsu <= 1'b0;
	end
	assign ex_ready_o = ((((((~apu_stall & alu_ready) & mult_ready) & lsu_ready_ex_i) & wb_ready_i) & ~wb_contention) & fpu_ready) | branch_in_ex_i;
	assign ex_valid_o = ((((apu_valid | alu_en_i) | mult_en_i) | csr_access_i) | lsu_en_i) & (((alu_ready & mult_ready) & lsu_ready_ex_i) & wb_ready_i);
endmodule
