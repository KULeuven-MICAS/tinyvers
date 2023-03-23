module fpnew_opgroup_block (
	clk_i,
	rst_ni,
	operands_i,
	is_boxed_i,
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
	extension_bit_o,
	tag_o,
	out_valid_o,
	out_ready_i,
	busy_o
);
	parameter [1:0] OpGroup = 2'd0;
	parameter [31:0] Width = 32;
	parameter [0:0] EnableVectors = 1'b1;
	localparam [31:0] fpnew_pkg_NUM_FP_FORMATS = 5;
	parameter [0:4] FpFmtMask = 1'sb1;
	localparam [31:0] fpnew_pkg_NUM_INT_FORMATS = 4;
	parameter [0:3] IntFmtMask = 1'sb1;
	parameter [159:0] FmtPipeRegs = {fpnew_pkg_NUM_FP_FORMATS {32'd0}};
	parameter [9:0] FmtUnitTypes = {fpnew_pkg_NUM_FP_FORMATS {2'd1}};
	parameter [1:0] PipeConfig = 2'd0;
	localparam [31:0] NUM_FORMATS = fpnew_pkg_NUM_FP_FORMATS;
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
	localparam [31:0] NUM_OPERANDS = fpnew_pkg_num_operands(OpGroup);
	input wire clk_i;
	input wire rst_ni;
	input wire [(NUM_OPERANDS * Width) - 1:0] operands_i;
	input wire [(NUM_FORMATS * NUM_OPERANDS) - 1:0] is_boxed_i;
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
	output wire [Width - 1:0] result_o;
	output wire [4:0] status_o;
	output wire extension_bit_o;
	output wire tag_o;
	output wire out_valid_o;
	input wire out_ready_i;
	output wire busy_o;
	wire [4:0] fmt_in_ready;
	wire [4:0] fmt_out_valid;
	wire [4:0] fmt_out_ready;
	wire [4:0] fmt_busy;
	wire [((Width + 6) >= 0 ? (5 * (Width + 7)) - 1 : (5 * (1 - (Width + 6))) + (Width + 5)):((Width + 6) >= 0 ? 0 : Width + 6)] fmt_outputs;
	assign in_ready_o = in_valid_i & fmt_in_ready[dst_fmt_i];
	genvar fmt;
	localparam [0:0] fpnew_pkg_DONT_CARE = 1'b1;
	function automatic fpnew_pkg_any_enabled_multi;
		input reg [9:0] types;
		input reg [0:4] cfg;
		reg [0:1] _sv2v_jump;
		begin
			_sv2v_jump = 2'b00;
			begin : sv2v_autoblock_1
				reg [31:0] i;
				begin : sv2v_autoblock_2
					reg [31:0] _sv2v_value_on_break;
					for (i = 0; i < fpnew_pkg_NUM_FP_FORMATS; i = i + 1)
						if (_sv2v_jump < 2'b10) begin
							_sv2v_jump = 2'b00;
							if (cfg[i] && (types[(4 - i) * 2+:2] == 2'd2)) begin
								fpnew_pkg_any_enabled_multi = 1'b1;
								_sv2v_jump = 2'b11;
							end
							_sv2v_value_on_break = i;
						end
					if (!(_sv2v_jump < 2'b10))
						i = _sv2v_value_on_break;
					if (_sv2v_jump != 2'b11)
						_sv2v_jump = 2'b00;
				end
			end
			if (_sv2v_jump == 2'b00) begin
				fpnew_pkg_any_enabled_multi = 1'b0;
				_sv2v_jump = 2'b11;
			end
		end
	endfunction
	function automatic [2:0] sv2v_cast_0BC43;
		input reg [2:0] inp;
		sv2v_cast_0BC43 = inp;
	endfunction
	function automatic [2:0] fpnew_pkg_get_first_enabled_multi;
		input reg [9:0] types;
		input reg [0:4] cfg;
		reg [0:1] _sv2v_jump;
		begin
			_sv2v_jump = 2'b00;
			begin : sv2v_autoblock_3
				reg [31:0] i;
				begin : sv2v_autoblock_4
					reg [31:0] _sv2v_value_on_break;
					for (i = 0; i < fpnew_pkg_NUM_FP_FORMATS; i = i + 1)
						if (_sv2v_jump < 2'b10) begin
							_sv2v_jump = 2'b00;
							if (cfg[i] && (types[(4 - i) * 2+:2] == 2'd2)) begin
								fpnew_pkg_get_first_enabled_multi = sv2v_cast_0BC43(i);
								_sv2v_jump = 2'b11;
							end
							_sv2v_value_on_break = i;
						end
					if (!(_sv2v_jump < 2'b10))
						i = _sv2v_value_on_break;
					if (_sv2v_jump != 2'b11)
						_sv2v_jump = 2'b00;
				end
			end
			if (_sv2v_jump == 2'b00) begin
				fpnew_pkg_get_first_enabled_multi = sv2v_cast_0BC43(0);
				_sv2v_jump = 2'b11;
			end
		end
	endfunction
	function automatic fpnew_pkg_is_first_enabled_multi;
		input reg [2:0] fmt;
		input reg [9:0] types;
		input reg [0:4] cfg;
		reg [0:1] _sv2v_jump;
		begin
			_sv2v_jump = 2'b00;
			begin : sv2v_autoblock_5
				reg [31:0] i;
				begin : sv2v_autoblock_6
					reg [31:0] _sv2v_value_on_break;
					for (i = 0; i < fpnew_pkg_NUM_FP_FORMATS; i = i + 1)
						if (_sv2v_jump < 2'b10) begin
							_sv2v_jump = 2'b00;
							if (cfg[i] && (types[(4 - i) * 2+:2] == 2'd2)) begin
								fpnew_pkg_is_first_enabled_multi = sv2v_cast_0BC43(i) == fmt;
								_sv2v_jump = 2'b11;
							end
							_sv2v_value_on_break = i;
						end
					if (!(_sv2v_jump < 2'b10))
						i = _sv2v_value_on_break;
					if (_sv2v_jump != 2'b11)
						_sv2v_jump = 2'b00;
				end
			end
			if (_sv2v_jump == 2'b00) begin
				fpnew_pkg_is_first_enabled_multi = 1'b0;
				_sv2v_jump = 2'b11;
			end
		end
	endfunction
	function automatic signed [31:0] sv2v_cast_32_signed;
		input reg signed [31:0] inp;
		sv2v_cast_32_signed = inp;
	endfunction
	generate
		for (fmt = 0; fmt < sv2v_cast_32_signed(NUM_FORMATS); fmt = fmt + 1) begin : gen_parallel_slices
			localparam [0:0] ANY_MERGED = fpnew_pkg_any_enabled_multi(FmtUnitTypes, FpFmtMask);
			localparam [0:0] IS_FIRST_MERGED = fpnew_pkg_is_first_enabled_multi(sv2v_cast_0BC43(fmt), FmtUnitTypes, FpFmtMask);
			if (FpFmtMask[fmt] && (FmtUnitTypes[(4 - fmt) * 2+:2] == 2'd1)) begin : active_format
				wire in_valid;
				assign in_valid = in_valid_i & (dst_fmt_i == fmt);
				fpnew_opgroup_fmt_slice_09303 #(
					.OpGroup(OpGroup),
					.FpFormat(sv2v_cast_0BC43(fmt)),
					.Width(Width),
					.EnableVectors(EnableVectors),
					.NumPipeRegs(FmtPipeRegs[(4 - fmt) * 32+:32]),
					.PipeConfig(PipeConfig)
				) i_fmt_slice(
					.clk_i(clk_i),
					.rst_ni(rst_ni),
					.operands_i(operands_i),
					.is_boxed_i(is_boxed_i[fmt * NUM_OPERANDS+:NUM_OPERANDS]),
					.rnd_mode_i(rnd_mode_i),
					.op_i(op_i),
					.op_mod_i(op_mod_i),
					.vectorial_op_i(vectorial_op_i),
					.tag_i(tag_i),
					.in_valid_i(in_valid),
					.in_ready_o(fmt_in_ready[fmt]),
					.flush_i(flush_i),
					.result_o(fmt_outputs[((Width + 6) >= 0 ? (fmt * ((Width + 6) >= 0 ? Width + 7 : 1 - (Width + 6))) + ((Width + 6) >= 0 ? Width + 6 : (Width + 6) - (Width + 6)) : (((fmt * ((Width + 6) >= 0 ? Width + 7 : 1 - (Width + 6))) + ((Width + 6) >= 0 ? Width + 6 : (Width + 6) - (Width + 6))) + ((Width + 6) >= 7 ? Width + 0 : 8 - (Width + 6))) - 1)-:((Width + 6) >= 7 ? Width + 0 : 8 - (Width + 6))]),
					.status_o(fmt_outputs[((Width + 6) >= 0 ? (fmt * ((Width + 6) >= 0 ? Width + 7 : 1 - (Width + 6))) + ((Width + 6) >= 0 ? 6 : Width + 0) : ((fmt * ((Width + 6) >= 0 ? Width + 7 : 1 - (Width + 6))) + ((Width + 6) >= 0 ? 6 : Width + 0)) + 4)-:5]),
					.extension_bit_o(fmt_outputs[(fmt * ((Width + 6) >= 0 ? Width + 7 : 1 - (Width + 6))) + ((Width + 6) >= 0 ? 1 : Width + 5)]),
					.tag_o(fmt_outputs[(fmt * ((Width + 6) >= 0 ? Width + 7 : 1 - (Width + 6))) + ((Width + 6) >= 0 ? 0 : Width + 6)]),
					.out_valid_o(fmt_out_valid[fmt]),
					.out_ready_i(fmt_out_ready[fmt]),
					.busy_o(fmt_busy[fmt])
				);
			end
			else if ((FpFmtMask[fmt] && ANY_MERGED) && !IS_FIRST_MERGED) begin : merged_unused
				assign fmt_in_ready[fmt] = fmt_in_ready[fpnew_pkg_get_first_enabled_multi(FmtUnitTypes, FpFmtMask)];
				assign fmt_out_valid[fmt] = 1'b0;
				assign fmt_busy[fmt] = 1'b0;
				assign fmt_outputs[((Width + 6) >= 0 ? (fmt * ((Width + 6) >= 0 ? Width + 7 : 1 - (Width + 6))) + ((Width + 6) >= 0 ? Width + 6 : (Width + 6) - (Width + 6)) : (((fmt * ((Width + 6) >= 0 ? Width + 7 : 1 - (Width + 6))) + ((Width + 6) >= 0 ? Width + 6 : (Width + 6) - (Width + 6))) + ((Width + 6) >= 7 ? Width + 0 : 8 - (Width + 6))) - 1)-:((Width + 6) >= 7 ? Width + 0 : 8 - (Width + 6))] = {Width {fpnew_pkg_DONT_CARE}};
				assign fmt_outputs[((Width + 6) >= 0 ? (fmt * ((Width + 6) >= 0 ? Width + 7 : 1 - (Width + 6))) + ((Width + 6) >= 0 ? 6 : Width + 0) : ((fmt * ((Width + 6) >= 0 ? Width + 7 : 1 - (Width + 6))) + ((Width + 6) >= 0 ? 6 : Width + 0)) + 4)-:5] = {fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE};
				assign fmt_outputs[(fmt * ((Width + 6) >= 0 ? Width + 7 : 1 - (Width + 6))) + ((Width + 6) >= 0 ? 1 : Width + 5)] = fpnew_pkg_DONT_CARE;
				assign fmt_outputs[(fmt * ((Width + 6) >= 0 ? Width + 7 : 1 - (Width + 6))) + ((Width + 6) >= 0 ? 0 : Width + 6)] = fpnew_pkg_DONT_CARE;
			end
			else if (!FpFmtMask[fmt] || (FmtUnitTypes[(4 - fmt) * 2+:2] == 2'd0)) begin : disable_fmt
				assign fmt_in_ready[fmt] = 1'b0;
				assign fmt_out_valid[fmt] = 1'b0;
				assign fmt_busy[fmt] = 1'b0;
				assign fmt_outputs[((Width + 6) >= 0 ? (fmt * ((Width + 6) >= 0 ? Width + 7 : 1 - (Width + 6))) + ((Width + 6) >= 0 ? Width + 6 : (Width + 6) - (Width + 6)) : (((fmt * ((Width + 6) >= 0 ? Width + 7 : 1 - (Width + 6))) + ((Width + 6) >= 0 ? Width + 6 : (Width + 6) - (Width + 6))) + ((Width + 6) >= 7 ? Width + 0 : 8 - (Width + 6))) - 1)-:((Width + 6) >= 7 ? Width + 0 : 8 - (Width + 6))] = {Width {fpnew_pkg_DONT_CARE}};
				assign fmt_outputs[((Width + 6) >= 0 ? (fmt * ((Width + 6) >= 0 ? Width + 7 : 1 - (Width + 6))) + ((Width + 6) >= 0 ? 6 : Width + 0) : ((fmt * ((Width + 6) >= 0 ? Width + 7 : 1 - (Width + 6))) + ((Width + 6) >= 0 ? 6 : Width + 0)) + 4)-:5] = {fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE};
				assign fmt_outputs[(fmt * ((Width + 6) >= 0 ? Width + 7 : 1 - (Width + 6))) + ((Width + 6) >= 0 ? 1 : Width + 5)] = fpnew_pkg_DONT_CARE;
				assign fmt_outputs[(fmt * ((Width + 6) >= 0 ? Width + 7 : 1 - (Width + 6))) + ((Width + 6) >= 0 ? 0 : Width + 6)] = fpnew_pkg_DONT_CARE;
			end
		end
		if (fpnew_pkg_any_enabled_multi(FmtUnitTypes, FpFmtMask)) begin : gen_merged_slice
			localparam FMT = fpnew_pkg_get_first_enabled_multi(FmtUnitTypes, FpFmtMask);
			wire in_valid;
			assign in_valid = in_valid_i & (FmtUnitTypes[(4 - dst_fmt_i) * 2+:2] == 2'd2);
			fpnew_opgroup_multifmt_slice_180FF #(
				.OpGroup(OpGroup),
				.Width(Width),
				.FpFmtConfig(FpFmtMask),
				.IntFmtConfig(IntFmtMask),
				.EnableVectors(EnableVectors),
				.NumPipeRegs(FmtPipeRegs[(4 - FMT) * 32+:32]),
				.PipeConfig(PipeConfig)
			) i_multifmt_slice(
				.clk_i(clk_i),
				.rst_ni(rst_ni),
				.operands_i(operands_i),
				.is_boxed_i(is_boxed_i),
				.rnd_mode_i(rnd_mode_i),
				.op_i(op_i),
				.op_mod_i(op_mod_i),
				.src_fmt_i(src_fmt_i),
				.dst_fmt_i(dst_fmt_i),
				.int_fmt_i(int_fmt_i),
				.vectorial_op_i(vectorial_op_i),
				.tag_i(tag_i),
				.in_valid_i(in_valid),
				.in_ready_o(fmt_in_ready[FMT]),
				.flush_i(flush_i),
				.result_o(fmt_outputs[((Width + 6) >= 0 ? (FMT * ((Width + 6) >= 0 ? Width + 7 : 1 - (Width + 6))) + ((Width + 6) >= 0 ? Width + 6 : (Width + 6) - (Width + 6)) : (((FMT * ((Width + 6) >= 0 ? Width + 7 : 1 - (Width + 6))) + ((Width + 6) >= 0 ? Width + 6 : (Width + 6) - (Width + 6))) + ((Width + 6) >= 7 ? Width + 0 : 8 - (Width + 6))) - 1)-:((Width + 6) >= 7 ? Width + 0 : 8 - (Width + 6))]),
				.status_o(fmt_outputs[((Width + 6) >= 0 ? (FMT * ((Width + 6) >= 0 ? Width + 7 : 1 - (Width + 6))) + ((Width + 6) >= 0 ? 6 : Width + 0) : ((FMT * ((Width + 6) >= 0 ? Width + 7 : 1 - (Width + 6))) + ((Width + 6) >= 0 ? 6 : Width + 0)) + 4)-:5]),
				.extension_bit_o(fmt_outputs[(FMT * ((Width + 6) >= 0 ? Width + 7 : 1 - (Width + 6))) + ((Width + 6) >= 0 ? 1 : Width + 5)]),
				.tag_o(fmt_outputs[(FMT * ((Width + 6) >= 0 ? Width + 7 : 1 - (Width + 6))) + ((Width + 6) >= 0 ? 0 : Width + 6)]),
				.out_valid_o(fmt_out_valid[FMT]),
				.out_ready_i(fmt_out_ready[FMT]),
				.busy_o(fmt_busy[FMT])
			);
		end
	endgenerate
	wire [Width + 6:0] arbiter_output;
	rr_arb_tree_3B043_A8992 #(
		.DataType_Width(Width),
		.NumIn(NUM_FORMATS),
		.AxiVldRdy(1'b1)
	) i_arbiter(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.flush_i(flush_i),
		.rr_i(1'sb0),
		.req_i(fmt_out_valid),
		.gnt_o(fmt_out_ready),
		.data_i(fmt_outputs),
		.gnt_i(out_ready_i),
		.req_o(out_valid_o),
		.data_o(arbiter_output),
		.idx_o()
	);
	assign result_o = arbiter_output[Width + 6-:((Width + 6) >= 7 ? Width + 0 : 8 - (Width + 6))];
	assign status_o = arbiter_output[6-:5];
	assign extension_bit_o = arbiter_output[1];
	assign tag_o = arbiter_output[0];
	assign busy_o = |fmt_busy;
endmodule
