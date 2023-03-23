module udma_stream_unit (
	clk_i,
	rstn_i,
	cmd_clr_i,
	tx_ch_req_o,
	tx_ch_addr_o,
	tx_ch_datasize_o,
	tx_ch_gnt_i,
	tx_ch_valid_i,
	tx_ch_data_i,
	tx_ch_ready_o,
	in_stream_dest_i,
	in_stream_data_i,
	in_stream_datasize_i,
	in_stream_valid_i,
	in_stream_sot_i,
	in_stream_eot_i,
	in_stream_ready_o,
	out_stream_data_o,
	out_stream_datasize_o,
	out_stream_valid_o,
	out_stream_sot_o,
	out_stream_eot_o,
	out_stream_ready_i,
	spoof_addr_i,
	spoof_dest_i,
	spoof_datasize_i,
	spoof_req_i,
	spoof_gnt_i
);
	parameter L2_AWIDTH_NOAL = 16;
	parameter DATA_WIDTH = 32;
	parameter STREAM_ID_WIDTH = 2;
	parameter INST_ID = 0;
	input wire clk_i;
	input wire rstn_i;
	input wire cmd_clr_i;
	output wire tx_ch_req_o;
	output wire [L2_AWIDTH_NOAL - 1:0] tx_ch_addr_o;
	output wire [1:0] tx_ch_datasize_o;
	input wire tx_ch_gnt_i;
	input wire tx_ch_valid_i;
	input wire [DATA_WIDTH - 1:0] tx_ch_data_i;
	output wire tx_ch_ready_o;
	input wire [STREAM_ID_WIDTH - 1:0] in_stream_dest_i;
	input wire [DATA_WIDTH - 1:0] in_stream_data_i;
	input wire [1:0] in_stream_datasize_i;
	input wire in_stream_valid_i;
	input wire in_stream_sot_i;
	input wire in_stream_eot_i;
	output wire in_stream_ready_o;
	output wire [DATA_WIDTH - 1:0] out_stream_data_o;
	output wire [1:0] out_stream_datasize_o;
	output wire out_stream_valid_o;
	output wire out_stream_sot_o;
	output wire out_stream_eot_o;
	input wire out_stream_ready_i;
	input wire [L2_AWIDTH_NOAL - 1:0] spoof_addr_i;
	input wire [STREAM_ID_WIDTH - 1:0] spoof_dest_i;
	input wire [1:0] spoof_datasize_i;
	input wire spoof_req_i;
	input wire spoof_gnt_i;
	wire s_spoof_match;
	wire s_input_match;
	wire s_ptr_match;
	wire s_rd_ptr_jmp_match;
	wire s_trans_stream;
	wire s_trans_wr;
	wire s_trans_rd;
	reg s_stream_sel;
	reg [L2_AWIDTH_NOAL - 1:0] r_wr_ptr;
	reg [L2_AWIDTH_NOAL - 1:0] r_rd_ptr;
	reg [L2_AWIDTH_NOAL - 1:0] r_jump_dst;
	reg [L2_AWIDTH_NOAL - 1:0] r_jump_src;
	reg [L2_AWIDTH_NOAL - 1:0] s_datasize_toadd;
	wire [1:0] r_datasize;
	wire s_fifo_out_req;
	wire s_fifo_out_gnt;
	wire s_fifo_out_valid;
	wire [DATA_WIDTH - 1:0] s_fifo_out_data;
	wire s_fifo_out_ready;
	wire [DATA_WIDTH - 1:0] s_fifo_in_data;
	wire s_fifo_in_valid;
	reg s_fifo_in_ready;
	reg s_req;
	reg s_rd_ptr_next;
	reg r_do_jump;
	reg s_sample_rd;
	reg s_sample_wr;
	reg s_sample_wr_start;
	reg r_err;
	reg s_stream_buf_en;
	reg [1:0] s_state;
	reg [1:0] r_state;
	assign s_spoof_match = spoof_dest_i == INST_ID;
	assign s_input_match = in_stream_dest_i == INST_ID;
	assign s_ptr_match = r_rd_ptr == r_wr_ptr;
	assign s_rd_ptr_jmp_match = r_rd_ptr == r_jump_src;
	assign s_trans_stream = in_stream_valid_i & s_input_match;
	assign s_trans_wr = (spoof_gnt_i & spoof_req_i) & s_spoof_match;
	assign s_trans_rd = s_req & tx_ch_gnt_i;
	wire s_int_datasize;
	assign s_int_datasize = (s_stream_sel ? r_datasize : in_stream_datasize_i);
	assign out_stream_data_o = (s_stream_sel ? s_fifo_in_data : in_stream_data_i);
	assign out_stream_datasize_o = (s_stream_sel ? r_datasize : in_stream_datasize_i);
	assign out_stream_valid_o = (s_stream_sel ? s_fifo_in_valid : in_stream_valid_i);
	assign out_stream_sot_o = (s_stream_sel ? 1'b0 : in_stream_sot_i);
	assign out_stream_eot_o = (s_stream_sel ? 1'b0 : in_stream_eot_i);
	wire s_wr_ptr_guess;
	assign s_wr_ptr_guess = r_wr_ptr + s_datasize_toadd;
	wire s_is_jump;
	assign s_is_jump = spoof_addr_i != s_wr_ptr_guess;
	assign tx_ch_req_o = s_fifo_out_req & s_stream_buf_en;
	assign s_fifo_out_gnt = tx_ch_gnt_i & s_stream_buf_en;
	assign s_fifo_out_valid = tx_ch_valid_i;
	assign s_fifo_out_data = tx_ch_data_i;
	assign tx_ch_ready_o = s_fifo_out_ready;
	assign tx_ch_addr_o = r_rd_ptr;
	assign tx_ch_datasize_o = 'h0;
	io_tx_fifo #(
		.DATA_WIDTH(DATA_WIDTH),
		.BUFFER_DEPTH(4)
	) i_fifo(
		.clk_i(clk_i),
		.rstn_i(rstn_i),
		.clr_i(cmd_clr_i),
		.req_o(s_fifo_out_req),
		.gnt_i(s_fifo_out_gnt),
		.valid_i(s_fifo_out_valid),
		.data_i(s_fifo_out_data),
		.ready_o(s_fifo_out_ready),
		.data_o(s_fifo_in_data),
		.valid_o(s_fifo_in_valid),
		.ready_i(s_fifo_in_ready)
	);
	always @(*) begin
		s_rd_ptr_next = 'h0;
		if (r_do_jump && s_rd_ptr_jmp_match)
			s_rd_ptr_next = r_jump_dst;
		else
			s_rd_ptr_next = r_rd_ptr + s_datasize_toadd;
	end
	always @(*)
		case (s_int_datasize)
			2'b00: s_datasize_toadd = 'h1;
			2'b01: s_datasize_toadd = 'h2;
			2'b10: s_datasize_toadd = 'h4;
			default: s_datasize_toadd = 1'sb0;
		endcase
	always @(*) begin
		s_fifo_in_ready = 1'b0;
		s_stream_buf_en = 1'b0;
		s_state = r_state;
		s_req = 1'b0;
		s_stream_sel = 1'b0;
		s_sample_rd = 1'b0;
		s_sample_wr = 1'b0;
		s_sample_wr_start = 1'b0;
		case (r_state)
			2'd0:
				if (cmd_clr_i)
					s_state = 2'd0;
				else if (s_trans_wr) begin
					s_sample_wr_start = 1'b1;
					s_sample_rd = 1'b1;
					s_state = 2'd1;
				end
			2'd1: begin
				s_req = 1'b1;
				s_stream_sel = 1'b1;
				if (s_trans_wr)
					s_sample_wr = 1'b1;
				if (cmd_clr_i)
					s_state = 2'd0;
				else if (s_trans_rd)
					if (!s_ptr_match)
						s_sample_rd = 1'b1;
					else
						s_state = 2'd2;
			end
			2'd2: begin
				s_stream_sel = 1'b1;
				if (cmd_clr_i)
					s_state = 2'd0;
				else if (s_trans_wr) begin
					s_sample_wr = 1'b1;
					s_sample_rd = 1'b1;
					s_state = 2'd1;
				end
			end
			2'd3: s_state = 2'd0;
			default: s_state = 2'd0;
		endcase
	end
	always @(posedge clk_i or negedge rstn_i)
		if (~rstn_i) begin
			r_wr_ptr <= 'h0;
			r_rd_ptr <= 'h0;
			r_jump_src <= 'h0;
			r_jump_dst <= 'h0;
			r_do_jump <= 'h0;
			r_err <= 'h0;
			r_state <= 2'd0;
		end
		else if (cmd_clr_i) begin
			r_wr_ptr <= 'h0;
			r_rd_ptr <= 'h0;
			r_jump_src <= 'h0;
			r_jump_dst <= 'h0;
			r_do_jump <= 'h0;
			r_err <= 'h0;
			r_state <= 2'd0;
		end
		else begin
			r_state <= s_state;
			if (s_sample_wr_start)
				r_wr_ptr <= spoof_addr_i;
			else if (s_sample_wr) begin
				if (s_is_jump) begin
					r_jump_src <= r_wr_ptr;
					r_jump_dst <= spoof_addr_i;
					r_do_jump <= 1'b1;
				end
				r_wr_ptr <= spoof_addr_i;
			end
		end
endmodule
