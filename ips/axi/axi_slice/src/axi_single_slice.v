module axi_single_slice (
	clk_i,
	rst_ni,
	testmode_i,
	valid_i,
	ready_o,
	data_i,
	ready_i,
	valid_o,
	data_o
);
	parameter signed [31:0] BUFFER_DEPTH = -1;
	parameter signed [31:0] DATA_WIDTH = -1;
	input wire clk_i;
	input wire rst_ni;
	input wire testmode_i;
	input wire valid_i;
	output wire ready_o;
	input wire [DATA_WIDTH - 1:0] data_i;
	input wire ready_i;
	output wire valid_o;
	output wire [DATA_WIDTH - 1:0] data_o;
	wire full;
	wire empty;
	assign ready_o = ~full;
	assign valid_o = ~empty;
	fifo #(
		.FALL_THROUGH(1'b0),
		.DATA_WIDTH(DATA_WIDTH),
		.DEPTH(BUFFER_DEPTH)
	) i_fifo(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.flush_i(1'b0),
		.threshold_o(),
		.testmode_i(testmode_i),
		.full_o(full),
		.empty_o(empty),
		.data_i(data_i),
		.push_i(valid_i & ready_o),
		.data_o(data_o),
		.pop_i(ready_i & valid_o)
	);
endmodule
