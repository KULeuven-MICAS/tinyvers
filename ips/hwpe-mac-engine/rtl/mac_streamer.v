module mac_streamer (
	clk_i,
	rst_ni,
	test_mode_i,
	enable_i,
	clear_i,
	a_o,
	b_o,
	c_i,
	tcdm,
	ctrl_i,
	flags_o
);
	parameter [31:0] MP = 4;
	parameter [31:0] FD = 2;
	input wire clk_i;
	input wire rst_ni;
	input wire test_mode_i;
	input wire enable_i;
	input wire clear_i;
	input hwpe_stream_intf_stream.source a_o;
	input hwpe_stream_intf_stream.source b_o;
	input hwpe_stream_intf_stream.sink c_i;
	input hwpe_stream_intf_tcdm.master [MP - 1:0] tcdm;
	input wire [464:0] ctrl_i;
	output wire [83:0] flags_o;
	hwpe_stream_intf_stream #(.DATA_WIDTH(32)) a_prefifo(.clk(clk_i));
	hwpe_stream_intf_stream #(.DATA_WIDTH(32)) b_prefifo(.clk(clk_i));
	hwpe_stream_intf_stream #(.DATA_WIDTH(64)) c_postfifo(.clk(clk_i));
	hwpe_stream_source #(.DATA_WIDTH(32)) i_a_source(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.test_mode_i(test_mode_i),
		.clear_i(clear_i),
		.tcdm(tcdm[0:0]),
		.stream(a_prefifo.source),
		.ctrl_i(ctrl_i[464-:155]),
		.flags_o(flags_o[83-:28])
	);
	hwpe_stream_source #(.DATA_WIDTH(32)) i_b_source(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.test_mode_i(test_mode_i),
		.clear_i(clear_i),
		.tcdm(tcdm[1:1]),
		.stream(b_prefifo.source),
		.ctrl_i(ctrl_i[309-:155]),
		.flags_o(flags_o[55-:28])
	);
	hwpe_stream_sink #(.DATA_WIDTH(64)) i_c_sink(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.test_mode_i(test_mode_i),
		.clear_i(clear_i),
		.tcdm(tcdm[3:2]),
		.stream(c_postfifo.sink),
		.ctrl_i(ctrl_i[154-:155]),
		.flags_o(flags_o[27-:28])
	);
	hwpe_stream_fifo #(
		.DATA_WIDTH(32),
		.FIFO_DEPTH(2),
		.LATCH_FIFO(0)
	) i_a_fifo(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.clear_i(clear_i),
		.push_i(a_prefifo.sink),
		.pop_o(a_o),
		.flags_o()
	);
	hwpe_stream_fifo #(
		.DATA_WIDTH(32),
		.FIFO_DEPTH(2),
		.LATCH_FIFO(0)
	) i_b_fifo(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.clear_i(clear_i),
		.push_i(b_prefifo.sink),
		.pop_o(b_o),
		.flags_o()
	);
	hwpe_stream_fifo #(
		.DATA_WIDTH(64),
		.FIFO_DEPTH(8),
		.LATCH_FIFO(0)
	) i_c_fifo(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.clear_i(clear_i),
		.push_i(c_i),
		.pop_o(c_postfifo.source),
		.flags_o()
	);
endmodule
