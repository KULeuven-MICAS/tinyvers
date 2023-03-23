module axi_to_axi_lite (
	clk_i,
	rst_ni,
	testmode_i,
	in,
	out
);
	parameter signed [31:0] NUM_PENDING_RD = 1;
	parameter signed [31:0] NUM_PENDING_WR = 1;
	input wire clk_i;
	input wire rst_ni;
	input wire testmode_i;
	input AXI_BUS.Slave in;
	input AXI_LITE.Master out;
	localparam signed [31:0] DEPTH_FIFO_RD = 2 ** $clog2(NUM_PENDING_RD);
	localparam signed [31:0] DEPTH_FIFO_WR = 2 ** $clog2(NUM_PENDING_WR);
	wire [$bits(type(in.r_id)) - 1:0] meta_rd_id;
	wire [$bits(type(in.r_user)) - 1:0] meta_rd_user;
	wire [$bits(type(in.b_id)) - 1:0] meta_wr_id;
	wire [$bits(type(in.b_user)) - 1:0] meta_wr_user;
	wire rd_full;
	wire wr_full;
	wire [($bits(type(in.r_id)) + $bits(type(in.r_user))) - 1:0] meta_rd;
	wire [($bits(type(in.b_id)) + $bits(type(in.b_user))) - 1:0] meta_wr;
	~fifo #(
		.dtype(struct packed {
			logic [$bits(type(in.r_id)) - 1:0] id;
			logic [$bits(type(in.r_user)) - 1:0] user;
		}),
		.DEPTH(DEPTH_FIFO_RD)
	) i_fifo_rd(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.testmode_i(testmode_i),
		.flush_i(1'sb0),
		.full_o(rd_full),
		.empty_o(),
		.threshold_o(),
		.data_i({in.ar_id, in.ar_user}),
		.push_i(in.ar_ready & in.ar_valid),
		.data_o({meta_rd_id, meta_rd_user}),
		.pop_i((in.r_valid & in.r_ready) & in.r_last)
	);
	~fifo #(
		.dtype(struct packed {
			logic [$bits(type(in.b_id)) - 1:0] id;
			logic [$bits(type(in.b_user)) - 1:0] user;
		}),
		.DEPTH(DEPTH_FIFO_WR)
	) i_fifo_wr(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.testmode_i(testmode_i),
		.flush_i(1'sb0),
		.full_o(wr_full),
		.empty_o(),
		.threshold_o(),
		.data_i({in.aw_id, in.aw_user}),
		.push_i(in.aw_ready & in.aw_valid),
		.data_o({meta_wr_id, meta_wr_user}),
		.pop_i(in.b_valid & in.b_ready)
	);
	assign in.aw_ready = ~wr_full & out.aw_ready;
	assign in.ar_ready = ~rd_full & out.ar_ready;
	assign out.aw_addr = in.aw_addr;
	assign out.ar_addr = in.ar_addr;
	assign out.aw_valid = in.aw_valid;
	assign out.ar_valid = in.ar_valid;
	assign out.w_data = in.w_data;
	assign out.w_strb = in.w_strb;
	assign out.w_valid = in.w_valid;
	assign in.w_ready = out.w_ready;
	assign in.b_id = meta_wr_id;
	assign in.b_resp = out.b_resp;
	assign in.b_user = meta_wr_user;
	assign in.b_valid = out.b_valid;
	assign out.b_ready = in.b_ready;
	assign in.r_id = meta_rd_id;
	assign in.r_data = out.r_data;
	assign in.r_resp = out.r_resp;
	assign in.r_last = 1'sb1;
	assign in.r_user = meta_rd_user;
	assign in.r_valid = out.r_valid;
	assign out.r_ready = in.r_ready;
endmodule
