module udma_dc_fifo_mram (
	src_clk_i,
	src_rstn_i,
	src_data_i,
	src_valid_i,
	src_ready_o,
	dst_clk_i,
	dst_rstn_i,
	dst_data_o,
	dst_valid_o,
	dst_ready_i
);
	parameter DATA_WIDTH = 32;
	parameter BUFFER_DEPTH = 8;
	input wire src_clk_i;
	input wire src_rstn_i;
	input wire [DATA_WIDTH - 1:0] src_data_i;
	input wire src_valid_i;
	output wire src_ready_o;
	input wire dst_clk_i;
	input wire dst_rstn_i;
	output wire [DATA_WIDTH - 1:0] dst_data_o;
	output wire dst_valid_o;
	input wire dst_ready_i;
	wire [DATA_WIDTH - 1:0] data_async;
	wire [BUFFER_DEPTH - 1:0] write_token;
	wire [BUFFER_DEPTH - 1:0] read_pointer;
	dc_token_ring_fifo_din_mram #(
		.DATA_WIDTH(DATA_WIDTH),
		.BUFFER_DEPTH(BUFFER_DEPTH)
	) u_din(
		.clk(src_clk_i),
		.rstn(src_rstn_i),
		.data(src_data_i),
		.valid(src_valid_i),
		.ready(src_ready_o),
		.write_token(write_token),
		.read_pointer(read_pointer),
		.data_async(data_async)
	);
	dc_token_ring_fifo_dout #(
		.DATA_WIDTH(DATA_WIDTH),
		.BUFFER_DEPTH(BUFFER_DEPTH)
	) u_dout(
		.clk(dst_clk_i),
		.rstn(dst_rstn_i),
		.data(dst_data_o),
		.valid(dst_valid_o),
		.ready(dst_ready_i),
		.write_token(write_token),
		.read_pointer(read_pointer),
		.data_async(data_async)
	);
endmodule
