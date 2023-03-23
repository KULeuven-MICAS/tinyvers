module io_tx_fifo (
	clk_i,
	rstn_i,
	clr_i,
	req_o,
	gnt_i,
	data_o,
	valid_o,
	ready_i,
	valid_i,
	data_i,
	ready_o
);
	parameter DATA_WIDTH = 32;
	parameter BUFFER_DEPTH = 2;
	input wire clk_i;
	input wire rstn_i;
	input wire clr_i;
	output wire req_o;
	input wire gnt_i;
	output wire [DATA_WIDTH - 1:0] data_o;
	output wire valid_o;
	input wire ready_i;
	input wire valid_i;
	input wire [DATA_WIDTH - 1:0] data_i;
	output wire ready_o;
	localparam LOG_BUFFER_DEPTH = $clog2(BUFFER_DEPTH);
	wire [LOG_BUFFER_DEPTH:0] s_elements;
	wire [LOG_BUFFER_DEPTH:0] s_free_ele;
	reg [LOG_BUFFER_DEPTH:0] r_inflight;
	wire s_stop_req;
	io_generic_fifo #(
		.DATA_WIDTH(DATA_WIDTH),
		.BUFFER_DEPTH(BUFFER_DEPTH),
		.LOG_BUFFER_DEPTH(LOG_BUFFER_DEPTH)
	) i_fifo(
		.clk_i(clk_i),
		.rstn_i(rstn_i),
		.clr_i(clr_i),
		.elements_o(s_elements),
		.data_o(data_o),
		.valid_o(valid_o),
		.ready_i(ready_i),
		.valid_i(valid_i),
		.data_i(data_i),
		.ready_o(ready_o)
	);
	assign s_free_ele = BUFFER_DEPTH - s_elements;
	assign s_stop_req = s_free_ele == r_inflight;
	assign req_o = ready_o & ~s_stop_req;
	always @(posedge clk_i or negedge rstn_i) begin : elements_sequential
		if (rstn_i == 1'b0)
			r_inflight <= 0;
		else if (req_o && gnt_i) begin
			if (~valid_i || ~ready_o)
				r_inflight <= r_inflight + 1;
		end
		else if (valid_i && ready_o)
			r_inflight <= r_inflight - 1;
	end
endmodule
