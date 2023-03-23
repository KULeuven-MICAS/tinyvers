module io_tx_fifo_dc (
	src_clk_i,
	rstn_i,
	clr_i,
	dst_clk_i,
	dst_data_o,
	dst_valid_o,
	dst_ready_i,
	src_req_o,
	src_gnt_i,
	src_valid_i,
	src_data_i,
	src_ready_o
);
	parameter DATA_WIDTH = 32;
	parameter BUFFER_DEPTH_SYNC = 2;
	parameter BUFFER_DEPTH_ASYNC = 8;
	input wire src_clk_i;
	input wire rstn_i;
	input wire clr_i;
	input wire dst_clk_i;
	output wire [DATA_WIDTH - 1:0] dst_data_o;
	output wire dst_valid_o;
	input wire dst_ready_i;
	output wire src_req_o;
	input wire src_gnt_i;
	input wire src_valid_i;
	input wire [DATA_WIDTH - 1:0] src_data_i;
	output wire src_ready_o;
	localparam LOG_BUFFER_DEPTH = $clog2(BUFFER_DEPTH_SYNC);
	wire [LOG_BUFFER_DEPTH:0] s_elements;
	wire [LOG_BUFFER_DEPTH:0] s_free_ele;
	reg [LOG_BUFFER_DEPTH:0] r_inflight;
	wire s_stop_req;
	wire [DATA_WIDTH - 1:0] s_data;
	wire s_valid;
	wire s_ready;
	io_generic_fifo #(
		.DATA_WIDTH(DATA_WIDTH),
		.BUFFER_DEPTH(BUFFER_DEPTH_SYNC),
		.LOG_BUFFER_DEPTH(LOG_BUFFER_DEPTH)
	) i_fifo(
		.clk_i(src_clk_i),
		.rstn_i(rstn_i),
		.clr_i(clr_i),
		.elements_o(s_elements),
		.data_o(s_data),
		.valid_o(s_valid),
		.ready_i(s_ready),
		.valid_i(src_valid_i),
		.data_i(src_data_i),
		.ready_o(src_ready_o)
	);
	assign s_free_ele = BUFFER_DEPTH_SYNC - s_elements;
	assign s_stop_req = s_free_ele == r_inflight;
	assign src_req_o = src_ready_o & ~s_stop_req;
	always @(posedge src_clk_i or negedge rstn_i) begin : elements_sequential
		if (rstn_i == 1'b0)
			r_inflight <= 0;
		else if (src_req_o && src_gnt_i) begin
			if (~src_valid_i || ~src_ready_o)
				r_inflight <= r_inflight + 1;
		end
		else if (src_valid_i && src_ready_o)
			r_inflight <= r_inflight - 1;
	end
	udma_dc_fifo #(
		.DATA_WIDTH(DATA_WIDTH),
		.BUFFER_DEPTH(BUFFER_DEPTH_ASYNC)
	) i_dc_fifo(
		.src_clk_i(src_clk_i),
		.src_rstn_i(rstn_i),
		.src_data_i(s_data),
		.src_valid_i(s_valid),
		.src_ready_o(s_ready),
		.dst_clk_i(dst_clk_i),
		.dst_rstn_i(rstn_i),
		.dst_data_o(dst_data_o),
		.dst_valid_o(dst_valid_o),
		.dst_ready_i(dst_ready_i)
	);
endmodule
