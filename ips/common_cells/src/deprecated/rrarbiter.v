module rrarbiter (
	clk_i,
	rst_ni,
	flush_i,
	en_i,
	req_i,
	ack_o,
	vld_o,
	idx_o
);
	parameter [31:0] NUM_REQ = 64;
	parameter [0:0] LOCK_IN = 1'b0;
	input wire clk_i;
	input wire rst_ni;
	input wire flush_i;
	input wire en_i;
	input wire [NUM_REQ - 1:0] req_i;
	output wire [NUM_REQ - 1:0] ack_o;
	output wire vld_o;
	output wire [$clog2(NUM_REQ) - 1:0] idx_o;
	wire req;
	assign vld_o = |req_i & en_i;
	rr_arb_tree #(
		.NumIn(NUM_REQ),
		.DataWidth(1),
		.LockIn(LOCK_IN)
	) i_rr_arb_tree(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.flush_i(flush_i),
		.rr_i(1'sb0),
		.req_i(req_i),
		.gnt_o(ack_o),
		.data_i(1'sb0),
		.gnt_i(en_i & req),
		.req_o(req),
		.data_o(),
		.idx_o(idx_o)
	);
endmodule
