module udma_filter_tx_datafetch (
	clk_i,
	resetn_i,
	tx_ch_req_o,
	tx_ch_addr_o,
	tx_ch_datasize_o,
	tx_ch_gnt_i,
	tx_ch_valid_i,
	tx_ch_data_i,
	tx_ch_ready_o,
	cmd_start_i,
	cmd_done_o,
	cfg_start_addr_i,
	cfg_datasize_i,
	cfg_mode_i,
	cfg_len0_i,
	cfg_len1_i,
	cfg_len2_i,
	stream_data_o,
	stream_datasize_o,
	stream_valid_o,
	stream_sof_o,
	stream_eof_o,
	stream_ready_i
);
	parameter DATA_WIDTH = 32;
	parameter FILTID_WIDTH = 8;
	parameter L2_AWIDTH_NOAL = 15;
	parameter TRANS_SIZE = 16;
	input wire clk_i;
	input wire resetn_i;
	output wire tx_ch_req_o;
	output wire [L2_AWIDTH_NOAL - 1:0] tx_ch_addr_o;
	output wire [1:0] tx_ch_datasize_o;
	input wire tx_ch_gnt_i;
	input wire tx_ch_valid_i;
	input wire [DATA_WIDTH - 1:0] tx_ch_data_i;
	output wire tx_ch_ready_o;
	input wire cmd_start_i;
	output wire cmd_done_o;
	input wire [L2_AWIDTH_NOAL - 1:0] cfg_start_addr_i;
	input wire [1:0] cfg_datasize_i;
	input wire [1:0] cfg_mode_i;
	input wire [TRANS_SIZE - 1:0] cfg_len0_i;
	input wire [TRANS_SIZE - 1:0] cfg_len1_i;
	input wire [TRANS_SIZE - 1:0] cfg_len2_i;
	output wire [DATA_WIDTH - 1:0] stream_data_o;
	output wire [1:0] stream_datasize_o;
	output wire stream_valid_o;
	output wire stream_sof_o;
	output wire stream_eof_o;
	input wire stream_ready_i;
	reg [L2_AWIDTH_NOAL - 1:0] r_loc_startaddr;
	reg [L2_AWIDTH_NOAL - 1:0] s_loc_startaddr;
	reg [L2_AWIDTH_NOAL - 1:0] r_loc_pointer;
	reg [L2_AWIDTH_NOAL - 1:0] s_loc_pointer;
	reg [TRANS_SIZE - 1:0] r_ptn_buffer_l;
	reg [TRANS_SIZE - 1:0] s_ptn_buffer_l;
	reg [TRANS_SIZE - 1:0] r_ptn_buffer_w;
	reg [TRANS_SIZE - 1:0] s_ptn_buffer_w;
	wire s_data_tx_req;
	wire s_data_tx_gnt;
	wire s_data_tx_ready;
	wire s_data_tx_valid;
	wire [DATA_WIDTH - 1:0] s_data_tx;
	wire s_data_int_ready;
	wire s_data_int_valid;
	wire [DATA_WIDTH - 1:0] s_data_int;
	reg s_done;
	reg s_sample_loc_startaddr;
	reg s_sample_loc_pointer;
	reg s_sample_ptn_buffer_w;
	reg s_sample_ptn_buffer_l;
	reg [1:0] r_mode;
	reg [TRANS_SIZE - 1:0] s_datasize_toadd;
	reg s_start;
	reg s_running;
	wire s_evnt_sof;
	wire s_evnt_eof;
	reg s_is_sof;
	reg s_is_sof_next;
	reg s_is_eof;
	reg r_issof;
	reg [1:0] r_state;
	reg [1:0] s_state;
	assign tx_ch_req_o = s_data_tx_req & s_running;
	assign tx_ch_addr_o = r_loc_pointer;
	assign tx_ch_datasize_o = cfg_datasize_i;
	assign s_data_tx_gnt = tx_ch_gnt_i;
	assign s_data_tx_valid = tx_ch_valid_i;
	assign s_data_tx = tx_ch_data_i;
	assign tx_ch_ready_o = s_data_tx_ready;
	assign s_data_int_ready = stream_ready_i;
	assign stream_data_o = s_data_int;
	assign stream_valid_o = s_data_int_valid;
	assign stream_datasize_o = cfg_datasize_i;
	assign stream_sof_o = s_evnt_sof;
	assign stream_eof_o = s_evnt_eof;
	assign cmd_done_o = s_done;
	io_tx_fifo_mark #(
		.DATA_WIDTH(DATA_WIDTH),
		.BUFFER_DEPTH(4)
	) u_fifo(
		.clk_i(clk_i),
		.rstn_i(resetn_i),
		.clr_i(1'b0),
		.sof_i(s_is_sof),
		.eof_i(s_is_eof),
		.data_o(s_data_int),
		.valid_o(s_data_int_valid),
		.sof_o(s_evnt_sof),
		.eof_o(s_evnt_eof),
		.ready_i(s_data_int_ready),
		.req_o(s_data_tx_req),
		.gnt_i(s_data_tx_gnt),
		.valid_i(s_data_tx_valid),
		.data_i(s_data_tx),
		.ready_o(s_data_tx_ready)
	);
	always @(*) begin
		s_done = 1'b0;
		s_is_sof = 1'b0;
		s_is_eof = 1'b0;
		s_is_sof_next = 1'b0;
		s_ptn_buffer_w = r_ptn_buffer_w;
		s_ptn_buffer_l = r_ptn_buffer_l;
		s_sample_loc_startaddr = 1'b0;
		s_sample_loc_pointer = 1'b0;
		s_sample_ptn_buffer_w = 1'b0;
		s_sample_ptn_buffer_l = 1'b0;
		s_loc_pointer = r_loc_pointer;
		s_loc_startaddr = r_loc_startaddr;
		case (r_mode)
			0:
				if (s_data_tx_req && s_data_tx_gnt) begin
					s_is_sof = r_issof;
					s_sample_ptn_buffer_w = 1'b1;
					if (r_ptn_buffer_w == cfg_len0_i) begin
						s_done = 1'b1;
						s_is_eof = 1'b1;
						s_ptn_buffer_w = 0;
					end
					else begin
						s_ptn_buffer_w = r_ptn_buffer_w + 1;
						s_loc_pointer = r_loc_pointer + s_datasize_toadd;
						s_sample_loc_pointer = 1'b1;
						s_sample_ptn_buffer_w = 1'b1;
					end
				end
			1:
				if (s_data_tx_req && s_data_tx_gnt) begin
					s_is_sof = r_issof;
					s_sample_ptn_buffer_w = 1'b1;
					if ((r_ptn_buffer_w == cfg_len0_i) && (r_ptn_buffer_l == cfg_len1_i)) begin
						s_done = 1'b1;
						s_is_eof = 1'b1;
						s_ptn_buffer_w = 0;
						s_ptn_buffer_l = 0;
						s_sample_ptn_buffer_l = 1'b1;
					end
					else if (r_ptn_buffer_w == cfg_len0_i) begin
						s_is_eof = 1'b1;
						s_is_sof_next = 1'b1;
						s_sample_ptn_buffer_l = 1'b1;
						s_sample_loc_pointer = 1'b1;
						s_sample_loc_startaddr = 1'b1;
						s_loc_startaddr = r_loc_startaddr + s_datasize_toadd;
						s_ptn_buffer_w = 0;
						s_ptn_buffer_l = r_ptn_buffer_l + 1;
						s_loc_pointer = r_loc_startaddr + s_datasize_toadd;
					end
					else begin
						s_sample_ptn_buffer_w = 1'b1;
						s_sample_loc_pointer = 1'b1;
						s_ptn_buffer_w = r_ptn_buffer_w + 1;
						s_loc_pointer = r_loc_pointer + s_datasize_toadd;
					end
				end
			2:
				if (s_data_tx_req && s_data_tx_gnt) begin
					s_is_sof = r_issof;
					s_sample_ptn_buffer_w = 1'b1;
					if ((r_ptn_buffer_w == cfg_len0_i) && (r_ptn_buffer_l == cfg_len1_i)) begin
						s_done = 1'b1;
						s_is_eof = 1'b1;
						s_ptn_buffer_w = 0;
						s_ptn_buffer_l = 0;
						s_sample_ptn_buffer_l = 1'b1;
					end
					else if (r_ptn_buffer_w == cfg_len0_i) begin
						s_is_eof = 1'b1;
						s_is_sof_next = 1'b1;
						s_sample_ptn_buffer_l = 1'b1;
						s_sample_loc_pointer = 1'b1;
						s_ptn_buffer_w = 0;
						s_ptn_buffer_l = r_ptn_buffer_l + 1;
						s_loc_pointer = r_loc_startaddr;
					end
					else begin
						s_sample_ptn_buffer_w = 1'b1;
						s_sample_loc_pointer = 1'b1;
						s_ptn_buffer_w = r_ptn_buffer_w + 1;
						s_loc_pointer = r_loc_pointer + s_datasize_toadd;
					end
				end
			3:
				if (s_data_tx_req && s_data_tx_gnt) begin
					s_is_sof = r_issof;
					s_sample_ptn_buffer_w = 1'b1;
					if ((r_ptn_buffer_w == cfg_len0_i) && (r_ptn_buffer_l == cfg_len1_i)) begin
						s_done = 1'b1;
						s_is_eof = 1'b1;
						s_ptn_buffer_w = 0;
						s_ptn_buffer_l = 0;
						s_sample_ptn_buffer_l = 1'b1;
					end
					else if (r_ptn_buffer_w == cfg_len0_i) begin
						s_sample_ptn_buffer_l = 1'b1;
						s_sample_loc_pointer = 1'b1;
						s_sample_loc_startaddr = 1'b1;
						s_ptn_buffer_w = 0;
						s_ptn_buffer_l = r_ptn_buffer_l + 1;
						s_loc_pointer = r_loc_startaddr + cfg_len2_i;
						s_loc_startaddr = s_loc_pointer;
					end
					else begin
						s_sample_ptn_buffer_w = 1'b1;
						s_sample_loc_pointer = 1'b1;
						s_ptn_buffer_w = r_ptn_buffer_w + 1;
						s_loc_pointer = r_loc_pointer + s_datasize_toadd;
					end
				end
		endcase
	end
	always @(*) begin : mux_datasize
		case (cfg_datasize_i)
			2'b00: s_datasize_toadd = 'h1;
			2'b01: s_datasize_toadd = 'h2;
			2'b10: s_datasize_toadd = 'h4;
			default: s_datasize_toadd = 1'sb0;
		endcase
	end
	always @(*) begin
		s_state = r_state;
		s_start = 1'b0;
		s_running = 1'b0;
		case (r_state)
			2'd0:
				if (cmd_start_i) begin
					s_state = 2'd1;
					s_start = 1'b1;
				end
			2'd1: begin
				s_running = 1'b1;
				if (s_done)
					s_state = 2'd0;
			end
		endcase
	end
	always @(posedge clk_i or negedge resetn_i)
		if (~resetn_i) begin
			r_loc_startaddr <= 0;
			r_loc_pointer <= 0;
			r_ptn_buffer_w <= 0;
			r_ptn_buffer_l <= 0;
			r_mode <= 0;
			r_state <= 2'd0;
			r_issof <= 1'b0;
		end
		else begin
			r_state <= s_state;
			if (s_start || s_is_sof_next)
				r_issof <= 1'b1;
			else if (r_issof & (s_data_tx_req && s_data_tx_gnt))
				r_issof <= 1'b0;
			if (s_start) begin
				r_mode <= cfg_mode_i;
				r_loc_startaddr <= cfg_start_addr_i;
				r_loc_pointer <= cfg_start_addr_i;
				r_ptn_buffer_w <= 0;
				r_ptn_buffer_l <= 0;
			end
			else begin
				if (s_sample_loc_startaddr)
					r_loc_startaddr <= s_loc_startaddr;
				if (s_sample_loc_pointer)
					r_loc_pointer <= s_loc_pointer;
				if (s_sample_ptn_buffer_w)
					r_ptn_buffer_w <= s_ptn_buffer_w;
				if (s_sample_ptn_buffer_l)
					r_ptn_buffer_l <= s_ptn_buffer_l;
			end
		end
endmodule
