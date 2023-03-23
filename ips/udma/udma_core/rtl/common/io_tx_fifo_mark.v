module io_tx_fifo_mark (
	clk_i,
	rstn_i,
	clr_i,
	req_o,
	gnt_i,
	sof_i,
	eof_i,
	data_o,
	sof_o,
	eof_o,
	valid_o,
	ready_i,
	valid_i,
	data_i,
	ready_o
);
	parameter DATA_WIDTH = 32;
	parameter BUFFER_DEPTH = 2;
	parameter LOG_BUFFER_DEPTH = $clog2(BUFFER_DEPTH);
	input wire clk_i;
	input wire rstn_i;
	input wire clr_i;
	output wire req_o;
	input wire gnt_i;
	input wire sof_i;
	input wire eof_i;
	output wire [DATA_WIDTH - 1:0] data_o;
	output wire sof_o;
	output wire eof_o;
	output wire valid_o;
	input wire ready_i;
	input wire valid_i;
	input wire [DATA_WIDTH - 1:0] data_i;
	output wire ready_o;
	localparam FIFO_WIDTH = DATA_WIDTH + 2;
	wire [LOG_BUFFER_DEPTH:0] s_elements;
	wire [LOG_BUFFER_DEPTH:0] s_free_ele;
	reg [LOG_BUFFER_DEPTH:0] r_inflight;
	reg [LOG_BUFFER_DEPTH:0] r_mark_sof_cnt;
	reg [LOG_BUFFER_DEPTH:0] r_mark_eof_cnt;
	wire s_stop_req;
	wire s_mark_sof_evt;
	wire s_mark_eof_evt;
	wire s_mark_sof_dec;
	wire s_mark_eof_dec;
	wire s_mark;
	wire r_issof;
	wire [FIFO_WIDTH - 1:0] s_fifoin;
	wire [FIFO_WIDTH - 1:0] s_fifoout;
	assign s_fifoin = {s_mark_eof_evt, s_mark_sof_evt, data_i};
	assign data_o = s_fifoout[DATA_WIDTH - 1:0];
	assign sof_o = s_fifoout[FIFO_WIDTH - 2];
	assign eof_o = s_fifoout[FIFO_WIDTH - 1];
	io_generic_fifo #(
		.DATA_WIDTH(FIFO_WIDTH),
		.BUFFER_DEPTH(BUFFER_DEPTH),
		.LOG_BUFFER_DEPTH(LOG_BUFFER_DEPTH)
	) i_fifo(
		.clk_i(clk_i),
		.rstn_i(rstn_i),
		.clr_i(clr_i),
		.elements_o(s_elements),
		.data_o(s_fifoout),
		.valid_o(valid_o),
		.ready_i(ready_i),
		.valid_i(valid_i),
		.data_i(s_fifoin),
		.ready_o(ready_o)
	);
	assign s_free_ele = BUFFER_DEPTH - s_elements;
	assign s_stop_req = s_free_ele == r_inflight;
	assign s_mark_sof_dec = r_mark_sof_cnt != 0;
	assign s_mark_sof_evt = (r_mark_sof_cnt == 1) & (valid_i & ready_o);
	assign s_mark_eof_dec = r_mark_eof_cnt != 0;
	assign s_mark_eof_evt = (r_mark_eof_cnt == 1) & (valid_i & ready_o);
	assign req_o = ready_o & ~s_stop_req;
	always @(posedge clk_i or negedge rstn_i) begin : elements_sequential
		if (rstn_i == 1'b0) begin
			r_inflight <= 0;
			r_mark_sof_cnt <= 0;
			r_mark_eof_cnt <= 0;
		end
		else begin
			if (sof_i) begin
				if ((req_o && gnt_i) && (~valid_i || ~ready_o))
					r_mark_sof_cnt <= r_inflight + 1;
				else
					r_mark_sof_cnt <= r_inflight;
			end
			else if (s_mark_sof_dec && (valid_i && ready_o))
				r_mark_sof_cnt <= r_mark_sof_cnt - 1;
			if (eof_i) begin
				if ((req_o && gnt_i) && (~valid_i || ~ready_o))
					r_mark_eof_cnt <= r_inflight + 1;
				else
					r_mark_eof_cnt <= r_inflight;
			end
			else if (s_mark_eof_dec && (valid_i && ready_o))
				r_mark_eof_cnt <= r_mark_eof_cnt - 1;
			if (req_o && gnt_i) begin
				if (~valid_i || ~ready_o)
					r_inflight <= r_inflight + 1;
			end
			else if (valid_i && ready_o)
				r_inflight <= r_inflight - 1;
		end
	end
endmodule
