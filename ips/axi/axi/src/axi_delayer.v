module axi_delayer (
	clk_i,
	rst_ni,
	aw_valid_i,
	aw_chan_i,
	aw_ready_o,
	w_valid_i,
	w_chan_i,
	w_ready_o,
	b_valid_o,
	b_chan_o,
	b_ready_i,
	ar_valid_i,
	ar_chan_i,
	ar_ready_o,
	r_valid_o,
	r_chan_o,
	r_ready_i,
	aw_valid_o,
	aw_chan_o,
	aw_ready_i,
	w_valid_o,
	w_chan_o,
	w_ready_i,
	b_valid_i,
	b_chan_i,
	b_ready_o,
	ar_valid_o,
	ar_chan_o,
	ar_ready_i,
	r_valid_i,
	r_chan_i,
	r_ready_o
);
	parameter [0:0] StallRandomOutput = 0;
	parameter [0:0] StallRandomInput = 0;
	parameter signed [31:0] FixedDelayInput = 1;
	parameter signed [31:0] FixedDelayOutput = 1;
	input wire clk_i;
	input wire rst_ni;
	input wire aw_valid_i;
	input wire aw_chan_i;
	output wire aw_ready_o;
	input wire w_valid_i;
	input wire w_chan_i;
	output wire w_ready_o;
	output wire b_valid_o;
	output wire b_chan_o;
	input wire b_ready_i;
	input wire ar_valid_i;
	input wire ar_chan_i;
	output wire ar_ready_o;
	output wire r_valid_o;
	output wire r_chan_o;
	input wire r_ready_i;
	output wire aw_valid_o;
	output wire aw_chan_o;
	input wire aw_ready_i;
	output wire w_valid_o;
	output wire w_chan_o;
	input wire w_ready_i;
	input wire b_valid_i;
	input wire b_chan_i;
	output wire b_ready_o;
	output wire ar_valid_o;
	output wire ar_chan_o;
	input wire ar_ready_i;
	input wire r_valid_i;
	input wire r_chan_i;
	output wire r_ready_o;
	stream_delay_8DD7D #(
		.StallRandom(StallRandomInput),
		.FixedDelay(FixedDelayInput)
	) i_stream_delay_aw(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.payload_i(aw_chan_i),
		.ready_o(aw_ready_o),
		.valid_i(aw_valid_i),
		.payload_o(aw_chan_o),
		.ready_i(aw_ready_i),
		.valid_o(aw_valid_o)
	);
	stream_delay_8DD7D #(
		.StallRandom(StallRandomInput),
		.FixedDelay(FixedDelayInput)
	) i_stream_delay_ar(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.payload_i(ar_chan_i),
		.ready_o(ar_ready_o),
		.valid_i(ar_valid_i),
		.payload_o(ar_chan_o),
		.ready_i(ar_ready_i),
		.valid_o(ar_valid_o)
	);
	stream_delay_8DD7D #(
		.StallRandom(StallRandomInput),
		.FixedDelay(FixedDelayInput)
	) i_stream_delay_w(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.payload_i(w_chan_i),
		.ready_o(w_ready_o),
		.valid_i(w_valid_i),
		.payload_o(w_chan_o),
		.ready_i(w_ready_i),
		.valid_o(w_valid_o)
	);
	stream_delay_8DD7D #(
		.StallRandom(StallRandomOutput),
		.FixedDelay(FixedDelayOutput)
	) i_stream_delay_b(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.payload_i(b_chan_i),
		.ready_o(b_ready_o),
		.valid_i(b_valid_i),
		.payload_o(b_chan_o),
		.ready_i(b_ready_i),
		.valid_o(b_valid_o)
	);
	stream_delay_8DD7D #(
		.StallRandom(StallRandomOutput),
		.FixedDelay(FixedDelayOutput)
	) i_stream_delay_r(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.payload_i(r_chan_i),
		.ready_o(r_ready_o),
		.valid_i(r_valid_i),
		.payload_o(r_chan_o),
		.ready_i(r_ready_i),
		.valid_o(r_valid_o)
	);
endmodule
