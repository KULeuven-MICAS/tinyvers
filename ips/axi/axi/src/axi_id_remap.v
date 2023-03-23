module axi_id_resize (
	clk_i,
	rst_ni,
	in,
	out
);
	parameter signed [31:0] ADDR_WIDTH = -1;
	parameter signed [31:0] DATA_WIDTH = -1;
	parameter signed [31:0] USER_WIDTH = -1;
	parameter signed [31:0] ID_WIDTH_IN = -1;
	parameter signed [31:0] ID_WIDTH_OUT = -1;
	parameter signed [31:0] TABLE_SIZE = 1;
	input wire clk_i;
	input wire rst_ni;
	input AXI_BUS.Slave in;
	input AXI_BUS.Master out;
	generate
		if (ID_WIDTH_IN > ID_WIDTH_OUT) begin : g_remap
			axi_id_downsize #(
				.ADDR_WIDTH(ADDR_WIDTH),
				.DATA_WIDTH(DATA_WIDTH),
				.USER_WIDTH(USER_WIDTH),
				.ID_WIDTH_IN(ID_WIDTH_IN),
				.ID_WIDTH_OUT(ID_WIDTH_OUT),
				.TABLE_SIZE(TABLE_SIZE)
			) i_downsize(
				.clk_i(clk_i),
				.rst_ni(rst_ni),
				.in(in),
				.out(out)
			);
		end
		else begin : g_remap
			axi_join i_join(
				in,
				out
			);
		end
	endgenerate
endmodule
module axi_id_remap (
	clk_i,
	rst_ni,
	in,
	out
);
	parameter signed [31:0] ADDR_WIDTH = -1;
	parameter signed [31:0] DATA_WIDTH = -1;
	parameter signed [31:0] USER_WIDTH = -1;
	parameter signed [31:0] ID_WIDTH_IN = -1;
	parameter signed [31:0] ID_WIDTH_OUT = -1;
	parameter signed [31:0] TABLE_SIZE = 1;
	input wire clk_i;
	input wire rst_ni;
	input AXI_BUS.Slave in;
	input AXI_BUS.Master out;
	wire full_id_aw_b;
	wire empty_id_aw_b;
	wire full_id_ar_r;
	wire empty_id_ar_r;
	assign out.aw_addr = in.aw_addr;
	assign out.aw_len = in.aw_len;
	assign out.aw_size = in.aw_size;
	assign out.aw_burst = in.aw_burst;
	assign out.aw_lock = in.aw_lock;
	assign out.aw_cache = in.aw_cache;
	assign out.aw_prot = in.aw_prot;
	assign out.aw_qos = in.aw_qos;
	assign out.aw_region = in.aw_region;
	assign out.aw_atop = in.aw_atop;
	assign out.aw_user = in.aw_user;
	assign out.ar_addr = in.ar_addr;
	assign out.ar_len = in.ar_len;
	assign out.ar_size = in.ar_size;
	assign out.ar_burst = in.ar_burst;
	assign out.ar_lock = in.ar_lock;
	assign out.ar_cache = in.ar_cache;
	assign out.ar_prot = in.ar_prot;
	assign out.ar_qos = in.ar_qos;
	assign out.ar_region = in.ar_region;
	assign out.ar_user = in.ar_user;
	assign out.w_data = in.w_data;
	assign out.w_strb = in.w_strb;
	assign out.w_last = in.w_last;
	assign out.w_user = in.w_user;
	assign out.w_valid = in.w_valid;
	assign in.w_ready = out.w_ready;
	assign in.r_data = out.r_data;
	assign in.r_resp = out.r_resp;
	assign in.r_last = out.r_last;
	assign in.r_user = out.r_user;
	assign in.b_resp = out.b_resp;
	assign in.b_user = out.b_user;
	assign in.aw_ready = out.aw_ready & ~full_id_aw_b;
	assign out.aw_valid = in.aw_valid & ~full_id_aw_b;
	assign in.b_valid = out.b_valid & ~empty_id_aw_b;
	assign out.b_ready = in.b_ready & ~empty_id_aw_b;
	assign in.ar_ready = out.ar_ready & ~full_id_ar_r;
	assign out.ar_valid = in.ar_valid & ~full_id_ar_r;
	assign in.r_valid = out.r_valid & ~empty_id_ar_r;
	assign out.r_ready = in.r_ready & ~empty_id_ar_r;
	axi_remap_table #(
		.ID_WIDTH_IN(ID_WIDTH_IN),
		.ID_WIDTH_OUT(ID_WIDTH_OUT),
		.TABLE_SIZE(TABLE_SIZE)
	) i_aw_b_remap(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.incr_i((in.aw_valid & ~full_id_aw_b) & out.aw_ready),
		.full_o(full_id_aw_b),
		.id_i(in.aw_id),
		.id_o(out.aw_id),
		.release_id_i((out.b_valid & in.b_ready) & ~empty_id_aw_b),
		.rel_id_i(out.b_id),
		.rel_id_o(in.b_id),
		.empty_o(empty_id_aw_b)
	);
	axi_remap_table #(
		.ID_WIDTH_IN(ID_WIDTH_IN),
		.ID_WIDTH_OUT(ID_WIDTH_OUT),
		.TABLE_SIZE(TABLE_SIZE)
	) i_ar_r_remap(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.incr_i((in.ar_valid & ~full_id_ar_r) & out.ar_ready),
		.full_o(full_id_ar_r),
		.id_i(in.ar_id),
		.id_o(out.ar_id),
		.release_id_i(((out.r_valid & in.r_ready) & out.r_last) & ~empty_id_ar_r),
		.rel_id_i(out.r_id),
		.rel_id_o(in.r_id),
		.empty_o(empty_id_ar_r)
	);
endmodule
module axi_remap_table (
	clk_i,
	rst_ni,
	incr_i,
	full_o,
	id_i,
	id_o,
	release_id_i,
	rel_id_i,
	rel_id_o,
	empty_o
);
	parameter signed [31:0] ID_WIDTH_IN = -1;
	parameter signed [31:0] ID_WIDTH_OUT = -1;
	parameter [31:0] TABLE_SIZE = 1;
	input wire clk_i;
	input wire rst_ni;
	input wire incr_i;
	output wire full_o;
	input wire [ID_WIDTH_IN - 1:0] id_i;
	output wire [ID_WIDTH_OUT - 1:0] id_o;
	input wire release_id_i;
	input wire [ID_WIDTH_OUT - 1:0] rel_id_i;
	output wire [ID_WIDTH_IN - 1:0] rel_id_o;
	output wire empty_o;
	reg [(TABLE_SIZE * (1 + ID_WIDTH_IN)) - 1:0] remap_table_d;
	reg [(TABLE_SIZE * (1 + ID_WIDTH_IN)) - 1:0] remap_table_q;
	reg [(1 + ID_WIDTH_IN) - 1:0] id;
	wire [TABLE_SIZE - 1:0] valid;
	reg [$clog2(TABLE_SIZE):0] current_index;
	genvar i;
	generate
		for (i = 0; i < TABLE_SIZE; i = i + 1) begin : genblk1
			assign valid[i] = remap_table_q[(i * (1 + ID_WIDTH_IN)) + (ID_WIDTH_IN + 0)];
		end
	endgenerate
	assign empty_o = ~(|valid);
	assign full_o = id[ID_WIDTH_IN + 0];
	generate
		if (ID_WIDTH_OUT <= $clog2(TABLE_SIZE)) begin : genblk2
			assign id_o = current_index;
		end
		else begin : genblk2
			assign id_o = {{{ID_WIDTH_OUT - $clog2(TABLE_SIZE)} {1'b0}}, current_index};
		end
	endgenerate
	assign rel_id_o = remap_table_q[(rel_id_i * (1 + ID_WIDTH_IN)) + (ID_WIDTH_IN - 1)-:ID_WIDTH_IN];
	always @(*) begin : sv2v_autoblock_1
		reg [0:1] _sv2v_jump;
		_sv2v_jump = 2'b00;
		current_index = 0;
		remap_table_d = remap_table_q;
		begin : sv2v_autoblock_2
			reg [31:0] i;
			begin : sv2v_autoblock_3
				reg [31:0] _sv2v_value_on_break;
				for (i = 0; i < TABLE_SIZE; i = i + 1)
					if (_sv2v_jump < 2'b10) begin
						_sv2v_jump = 2'b00;
						if (!valid[i]) begin
							current_index = i;
							_sv2v_jump = 2'b10;
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
			id = remap_table_q[current_index * (1 + ID_WIDTH_IN)+:1 + ID_WIDTH_IN];
			if (incr_i) begin
				remap_table_d[(current_index * (1 + ID_WIDTH_IN)) + (ID_WIDTH_IN + 0)] = 1'b1;
				remap_table_d[(current_index * (1 + ID_WIDTH_IN)) + (ID_WIDTH_IN - 1)-:ID_WIDTH_IN] = id_i;
			end
			if (release_id_i)
				remap_table_d[(rel_id_i[$clog2(TABLE_SIZE) - 1:0] * (1 + ID_WIDTH_IN)) + (ID_WIDTH_IN + 0)] = 1'b0;
		end
	end
	always @(posedge clk_i or negedge rst_ni)
		if (~rst_ni) begin : sv2v_autoblock_4
			reg signed [31:0] i;
			for (i = 0; i < TABLE_SIZE; i = i + 1)
				remap_table_q[i * (1 + ID_WIDTH_IN)+:1 + ID_WIDTH_IN] <= 1'sb0;
		end
		else
			remap_table_q <= remap_table_d;
endmodule
