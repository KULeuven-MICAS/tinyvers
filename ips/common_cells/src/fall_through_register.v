module fall_through_register (
	clk_i,
	rst_ni,
	clr_i,
	testmode_i,
	valid_i,
	ready_o,
	data_i,
	valid_o,
	ready_i,
	data_o
);
	input wire clk_i;
	input wire rst_ni;
	input wire clr_i;
	input wire testmode_i;
	input wire valid_i;
	output wire ready_o;
	input wire data_i;
	output wire valid_o;
	input wire ready_i;
	output wire data_o;
	wire fifo_empty;
	wire fifo_full;
	fifo_v2_87BAC #(
		.FALL_THROUGH(1'b1),
		.DATA_WIDTH(1'sbx),
		.DEPTH(1)
	) i_fifo(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.flush_i(clr_i),
		.testmode_i(testmode_i),
		.full_o(fifo_full),
		.empty_o(fifo_empty),
		.alm_full_o(),
		.alm_empty_o(),
		.data_i(data_i),
		.push_i(valid_i & ~fifo_full),
		.data_o(data_o),
		.pop_i(ready_i & ~fifo_empty)
	);
	assign ready_o = ~fifo_full;
	assign valid_o = ~fifo_empty;
endmodule
