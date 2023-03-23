module fpnew_top (
	clk_i,
	rst_ni,
	operands_i,
	rnd_mode_i,
	op_i,
	op_mod_i,
	src_fmt_i,
	dst_fmt_i,
	int_fmt_i,
	vectorial_op_i,
	tag_i,
	in_valid_i,
	in_ready_o,
	flush_i,
	result_o,
	status_o,
	tag_o,
	out_valid_o,
	out_ready_i,
	busy_o
);
	localparam [31:0] fpnew_pkg_NUM_FP_FORMATS = 5;
	localparam [31:0] fpnew_pkg_NUM_INT_FORMATS = 4;
	localparam [42:0] fpnew_pkg_RV64D_Xsflt = 43'h000000207ff;
	parameter [42:0] Features = fpnew_pkg_RV64D_Xsflt;
	localparam [31:0] fpnew_pkg_NUM_OPGROUPS = 4;
	function automatic [159:0] sv2v_cast_B9240;
		input reg [159:0] inp;
		sv2v_cast_B9240 = inp;
	endfunction
	function automatic [((32'd4 * 32'd5) * 32) - 1:0] sv2v_cast_CDC93;
		input reg [((32'd4 * 32'd5) * 32) - 1:0] inp;
		sv2v_cast_CDC93 = inp;
	endfunction
	function automatic [((32'd4 * 32'd5) * 2) - 1:0] sv2v_cast_15FEF;
		input reg [((32'd4 * 32'd5) * 2) - 1:0] inp;
		sv2v_cast_15FEF = inp;
	endfunction
	localparam [(((fpnew_pkg_NUM_OPGROUPS * fpnew_pkg_NUM_FP_FORMATS) * 32) + ((fpnew_pkg_NUM_OPGROUPS * fpnew_pkg_NUM_FP_FORMATS) * 2)) + 1:0] fpnew_pkg_DEFAULT_NOREGS = {sv2v_cast_CDC93({fpnew_pkg_NUM_OPGROUPS {sv2v_cast_B9240(0)}}), sv2v_cast_15FEF({{fpnew_pkg_NUM_FP_FORMATS {2'd1}}, {fpnew_pkg_NUM_FP_FORMATS {2'd2}}, {fpnew_pkg_NUM_FP_FORMATS {2'd1}}, {fpnew_pkg_NUM_FP_FORMATS {2'd2}}}), 2'd0};
	parameter [(((fpnew_pkg_NUM_OPGROUPS * fpnew_pkg_NUM_FP_FORMATS) * 32) + ((fpnew_pkg_NUM_OPGROUPS * fpnew_pkg_NUM_FP_FORMATS) * 2)) + 1:0] Implementation = fpnew_pkg_DEFAULT_NOREGS;
	localparam [31:0] WIDTH = Features[42-:32];
	localparam [31:0] NUM_OPERANDS = 3;
	input wire clk_i;
	input wire rst_ni;
	input wire [(NUM_OPERANDS * WIDTH) - 1:0] operands_i;
	input wire [2:0] rnd_mode_i;
	localparam [31:0] fpnew_pkg_OP_BITS = 4;
	input wire [3:0] op_i;
	input wire op_mod_i;
	localparam [31:0] fpnew_pkg_FP_FORMAT_BITS = 3;
	input wire [2:0] src_fmt_i;
	input wire [2:0] dst_fmt_i;
	localparam [31:0] fpnew_pkg_INT_FORMAT_BITS = 2;
	input wire [1:0] int_fmt_i;
	input wire vectorial_op_i;
	input wire tag_i;
	input wire in_valid_i;
	output wire in_ready_o;
	input wire flush_i;
	output wire [WIDTH - 1:0] result_o;
	output wire [4:0] status_o;
	output wire tag_o;
	output wire out_valid_o;
	input wire out_ready_i;
	output wire busy_o;
	localparam [31:0] NUM_OPGROUPS = fpnew_pkg_NUM_OPGROUPS;
	localparam [31:0] NUM_FORMATS = fpnew_pkg_NUM_FP_FORMATS;
	wire [3:0] opgrp_in_ready;
	wire [3:0] opgrp_out_valid;
	wire [3:0] opgrp_out_ready;
	wire [3:0] opgrp_ext;
	wire [3:0] opgrp_busy;
	wire [((WIDTH + 5) >= 0 ? (4 * (WIDTH + 6)) - 1 : (4 * (1 - (WIDTH + 5))) + (WIDTH + 4)):((WIDTH + 5) >= 0 ? 0 : WIDTH + 5)] opgrp_outputs;
	wire [(NUM_FORMATS * NUM_OPERANDS) - 1:0] is_boxed;
	function automatic [3:0] sv2v_cast_A53F3;
		input reg [3:0] inp;
		sv2v_cast_A53F3 = inp;
	endfunction
	function automatic [1:0] fpnew_pkg_get_opgroup;
		input reg [3:0] op;
		case (op)
			sv2v_cast_A53F3(0), sv2v_cast_A53F3(1), sv2v_cast_A53F3(2), sv2v_cast_A53F3(3): fpnew_pkg_get_opgroup = 2'd0;
			sv2v_cast_A53F3(4), sv2v_cast_A53F3(5): fpnew_pkg_get_opgroup = 2'd1;
			sv2v_cast_A53F3(6), sv2v_cast_A53F3(7), sv2v_cast_A53F3(8), sv2v_cast_A53F3(9): fpnew_pkg_get_opgroup = 2'd2;
			sv2v_cast_A53F3(10), sv2v_cast_A53F3(11), sv2v_cast_A53F3(12), sv2v_cast_A53F3(13), sv2v_cast_A53F3(14): fpnew_pkg_get_opgroup = 2'd3;
			default: fpnew_pkg_get_opgroup = 2'd2;
		endcase
	endfunction
	assign in_ready_o = in_valid_i & opgrp_in_ready[fpnew_pkg_get_opgroup(op_i)];
	genvar fmt;
	localparam [319:0] fpnew_pkg_FP_ENCODINGS = 320'h8000000170000000b00000034000000050000000a00000005000000020000000800000007;
	function automatic [31:0] fpnew_pkg_fp_width;
		input reg [2:0] fmt;
		fpnew_pkg_fp_width = (fpnew_pkg_FP_ENCODINGS[((4 - fmt) * 64) + 63-:32] + fpnew_pkg_FP_ENCODINGS[((4 - fmt) * 64) + 31-:32]) + 1;
	endfunction
	function automatic [2:0] sv2v_cast_0BC43;
		input reg [2:0] inp;
		sv2v_cast_0BC43 = inp;
	endfunction
	function automatic signed [31:0] sv2v_cast_32_signed;
		input reg signed [31:0] inp;
		sv2v_cast_32_signed = inp;
	endfunction
	generate
		for (fmt = 0; fmt < sv2v_cast_32_signed(NUM_FORMATS); fmt = fmt + 1) begin : gen_nanbox_check
			localparam [31:0] FP_WIDTH = fpnew_pkg_fp_width(sv2v_cast_0BC43(fmt));
			if (Features[9] && (FP_WIDTH < WIDTH)) begin : check
				genvar op;
				for (op = 0; op < sv2v_cast_32_signed(NUM_OPERANDS); op = op + 1) begin : operands
					assign is_boxed[(fmt * NUM_OPERANDS) + op] = (!vectorial_op_i ? operands_i[(op * WIDTH) + ((WIDTH - 1) >= FP_WIDTH ? WIDTH - 1 : ((WIDTH - 1) + ((WIDTH - 1) >= FP_WIDTH ? ((WIDTH - 1) - FP_WIDTH) + 1 : (FP_WIDTH - (WIDTH - 1)) + 1)) - 1)-:((WIDTH - 1) >= FP_WIDTH ? ((WIDTH - 1) - FP_WIDTH) + 1 : (FP_WIDTH - (WIDTH - 1)) + 1)] == {((WIDTH - 1) >= FP_WIDTH ? ((WIDTH - 1) - FP_WIDTH) + 1 : (FP_WIDTH - (WIDTH - 1)) + 1) * 1 {1'sb1}} : 1'b1);
				end
			end
			else begin : no_check
				assign is_boxed[fmt * NUM_OPERANDS+:NUM_OPERANDS] = 1'sb1;
			end
		end
	endgenerate
	genvar opgrp;
	function automatic [31:0] fpnew_pkg_num_operands;
		input reg [1:0] grp;
		case (grp)
			2'd0: fpnew_pkg_num_operands = 3;
			2'd1: fpnew_pkg_num_operands = 2;
			2'd2: fpnew_pkg_num_operands = 2;
			2'd3: fpnew_pkg_num_operands = 3;
			default: fpnew_pkg_num_operands = 0;
		endcase
	endfunction
	function automatic [1:0] sv2v_cast_2;
		input reg [1:0] inp;
		sv2v_cast_2 = inp;
	endfunction
	generate
		for (opgrp = 0; opgrp < sv2v_cast_32_signed(NUM_OPGROUPS); opgrp = opgrp + 1) begin : gen_operation_groups
			localparam [31:0] NUM_OPS = fpnew_pkg_num_operands(sv2v_cast_2(opgrp));
			wire in_valid;
			reg [(NUM_FORMATS * NUM_OPS) - 1:0] input_boxed;
			assign in_valid = in_valid_i & (fpnew_pkg_get_opgroup(op_i) == sv2v_cast_2(opgrp));
			always @(*) begin : slice_inputs
				begin : sv2v_autoblock_1
					reg [31:0] fmt;
					for (fmt = 0; fmt < NUM_FORMATS; fmt = fmt + 1)
						input_boxed[fmt * fpnew_pkg_num_operands(sv2v_cast_2(opgrp))+:fpnew_pkg_num_operands(sv2v_cast_2(opgrp))] = is_boxed[(fmt * NUM_OPERANDS) + (NUM_OPS - 1)-:NUM_OPS];
				end
			end
			fpnew_opgroup_block_E7A9E #(
				.OpGroup(sv2v_cast_2(opgrp)),
				.Width(WIDTH),
				.EnableVectors(Features[10]),
				.FpFmtMask(Features[8-:5]),
				.IntFmtMask(Features[3-:fpnew_pkg_NUM_INT_FORMATS]),
				.FmtPipeRegs(Implementation[(((fpnew_pkg_NUM_OPGROUPS * fpnew_pkg_NUM_FP_FORMATS) * 32) + (((fpnew_pkg_NUM_OPGROUPS * fpnew_pkg_NUM_FP_FORMATS) * 2) + 1)) - ((((fpnew_pkg_NUM_OPGROUPS * fpnew_pkg_NUM_FP_FORMATS) * 32) - 1) - (32 * ((3 - opgrp) * fpnew_pkg_NUM_FP_FORMATS)))+:160]),
				.FmtUnitTypes(Implementation[(((fpnew_pkg_NUM_OPGROUPS * fpnew_pkg_NUM_FP_FORMATS) * 2) + 1) - ((((fpnew_pkg_NUM_OPGROUPS * fpnew_pkg_NUM_FP_FORMATS) * 2) - 1) - (2 * ((3 - opgrp) * fpnew_pkg_NUM_FP_FORMATS)))+:10]),
				.PipeConfig(Implementation[1-:2])
			) i_opgroup_block(
				.clk_i(clk_i),
				.rst_ni(rst_ni),
				.operands_i(operands_i[WIDTH * ((NUM_OPS - 1) - (NUM_OPS - 1))+:WIDTH * NUM_OPS]),
				.is_boxed_i(input_boxed),
				.rnd_mode_i(rnd_mode_i),
				.op_i(op_i),
				.op_mod_i(op_mod_i),
				.src_fmt_i(src_fmt_i),
				.dst_fmt_i(dst_fmt_i),
				.int_fmt_i(int_fmt_i),
				.vectorial_op_i(vectorial_op_i),
				.tag_i(tag_i),
				.in_valid_i(in_valid),
				.in_ready_o(opgrp_in_ready[opgrp]),
				.flush_i(flush_i),
				.result_o(opgrp_outputs[((WIDTH + 5) >= 0 ? (opgrp * ((WIDTH + 5) >= 0 ? WIDTH + 6 : 1 - (WIDTH + 5))) + ((WIDTH + 5) >= 0 ? WIDTH + 5 : (WIDTH + 5) - (WIDTH + 5)) : (((opgrp * ((WIDTH + 5) >= 0 ? WIDTH + 6 : 1 - (WIDTH + 5))) + ((WIDTH + 5) >= 0 ? WIDTH + 5 : (WIDTH + 5) - (WIDTH + 5))) + ((WIDTH + 5) >= 6 ? WIDTH + 0 : 7 - (WIDTH + 5))) - 1)-:((WIDTH + 5) >= 6 ? WIDTH + 0 : 7 - (WIDTH + 5))]),
				.status_o(opgrp_outputs[((WIDTH + 5) >= 0 ? (opgrp * ((WIDTH + 5) >= 0 ? WIDTH + 6 : 1 - (WIDTH + 5))) + ((WIDTH + 5) >= 0 ? 5 : WIDTH + 0) : ((opgrp * ((WIDTH + 5) >= 0 ? WIDTH + 6 : 1 - (WIDTH + 5))) + ((WIDTH + 5) >= 0 ? 5 : WIDTH + 0)) + 4)-:5]),
				.extension_bit_o(opgrp_ext[opgrp]),
				.tag_o(opgrp_outputs[(opgrp * ((WIDTH + 5) >= 0 ? WIDTH + 6 : 1 - (WIDTH + 5))) + ((WIDTH + 5) >= 0 ? 0 : WIDTH + 5)]),
				.out_valid_o(opgrp_out_valid[opgrp]),
				.out_ready_i(opgrp_out_ready[opgrp]),
				.busy_o(opgrp_busy[opgrp])
			);
		end
	endgenerate
	wire [WIDTH + 5:0] arbiter_output;
	rr_arb_tree_02E82_EBE23 #(
		.DataType_WIDTH(WIDTH),
		.NumIn(NUM_OPGROUPS),
		.AxiVldRdy(1'b1)
	) i_arbiter(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.flush_i(flush_i),
		.rr_i(1'sb0),
		.req_i(opgrp_out_valid),
		.gnt_o(opgrp_out_ready),
		.data_i(opgrp_outputs),
		.gnt_i(out_ready_i),
		.req_o(out_valid_o),
		.data_o(arbiter_output),
		.idx_o()
	);
	assign result_o = arbiter_output[WIDTH + 5-:((WIDTH + 5) >= 6 ? WIDTH + 0 : 7 - (WIDTH + 5))];
	assign status_o = arbiter_output[5-:5];
	assign tag_o = arbiter_output[0];
	assign busy_o = |opgrp_busy;
endmodule
