module udma_filter_rx_dataout (
	clk_i,
	resetn_i,
	rx_ch_addr_o,
	rx_ch_datasize_o,
	rx_ch_valid_o,
	rx_ch_data_o,
	rx_ch_ready_i,
	cmd_start_i,
	cmd_done_o,
	cfg_start_addr_i,
	cfg_datasize_i,
	cfg_mode_i,
	cfg_len0_i,
	cfg_len1_i,
	cfg_len2_i,
	stream_data_i,
	stream_valid_i,
	stream_ready_o
);
	parameter DATA_WIDTH = 32;
	parameter FILTID_WIDTH = 8;
	parameter L2_AWIDTH_NOAL = 15;
	parameter BUFFER_DEPTH = 4;
	parameter TRANS_SIZE = 16;
	input wire clk_i;
	input wire resetn_i;
	output wire [L2_AWIDTH_NOAL - 1:0] rx_ch_addr_o;
	output wire [1:0] rx_ch_datasize_o;
	output wire rx_ch_valid_o;
	output wire [DATA_WIDTH - 1:0] rx_ch_data_o;
	input wire rx_ch_ready_i;
	input wire cmd_start_i;
	output wire cmd_done_o;
	input wire [L2_AWIDTH_NOAL - 1:0] cfg_start_addr_i;
	input wire [1:0] cfg_datasize_i;
	input wire [1:0] cfg_mode_i;
	input wire [TRANS_SIZE - 1:0] cfg_len0_i;
	input wire [TRANS_SIZE - 1:0] cfg_len1_i;
	input wire [TRANS_SIZE - 1:0] cfg_len2_i;
	input wire [DATA_WIDTH - 1:0] stream_data_i;
	input wire stream_valid_i;
	output wire stream_ready_o;
	reg [L2_AWIDTH_NOAL - 1:0] r_loc_startaddr;
	reg [L2_AWIDTH_NOAL - 1:0] s_loc_startaddr;
	reg [L2_AWIDTH_NOAL - 1:0] r_loc_pointer;
	reg [L2_AWIDTH_NOAL - 1:0] s_loc_pointer;
	reg [TRANS_SIZE - 1:0] r_ptn_buffer_l;
	reg [TRANS_SIZE - 1:0] s_ptn_buffer_l;
	reg [TRANS_SIZE - 1:0] r_ptn_buffer_w;
	reg [TRANS_SIZE - 1:0] s_ptn_buffer_w;
	wire [DATA_WIDTH - 1:0] s_data_rx;
	wire s_data_rx_valid;
	wire s_data_rx_ready;
	reg s_done;
	reg s_sample_loc_startaddr;
	reg s_sample_loc_pointer;
	reg s_sample_ptn_buffer_w;
	reg s_sample_ptn_buffer_l;
	reg [1:0] r_mode;
	reg [TRANS_SIZE - 1:0] s_datasize_toadd;
	reg s_start;
	reg s_running;
	reg [1:0] r_state;
	reg [1:0] s_state;
	assign rx_ch_addr_o = r_loc_pointer;
	assign rx_ch_datasize_o = cfg_datasize_i;
	assign rx_ch_data_o = s_data_rx;
	assign rx_ch_valid_o = s_data_rx_valid;
	assign s_data_rx_ready = rx_ch_ready_i;
	assign cmd_done_o = s_done;
	io_generic_fifo #(
		.DATA_WIDTH(DATA_WIDTH),
		.BUFFER_DEPTH(BUFFER_DEPTH)
	) i_fifo(
		.clk_i(clk_i),
		.rstn_i(resetn_i),
		.clr_i(1'b0),
		.elements_o(),
		.data_o(s_data_rx),
		.valid_o(s_data_rx_valid),
		.ready_i(s_data_rx_ready),
		.valid_i(stream_valid_i),
		.data_i(stream_data_i),
		.ready_o(stream_ready_o)
	);
	always @(*) begin
		s_done = 1'b0;
		s_loc_startaddr = r_loc_startaddr;
		s_loc_pointer = r_loc_pointer;
		s_ptn_buffer_w = r_ptn_buffer_w;
		s_ptn_buffer_l = r_ptn_buffer_l;
		s_sample_loc_startaddr = 1'b0;
		s_sample_loc_pointer = 1'b0;
		s_sample_ptn_buffer_w = 1'b0;
		s_sample_ptn_buffer_l = 1'b0;
		if (s_running)
			case (r_mode)
				0:
					if (s_data_rx_valid && s_data_rx_ready) begin
						s_sample_ptn_buffer_w = 1'b1;
						if (r_ptn_buffer_w == cfg_len0_i) begin
							s_done = 1'b1;
							s_ptn_buffer_w = 0;
						end
						else begin
							s_ptn_buffer_w = r_ptn_buffer_w + 1;
							s_loc_pointer = r_loc_pointer + s_datasize_toadd;
							s_sample_loc_pointer = 1'b1;
						end
					end
				1:
					if (s_data_rx_valid && s_data_rx_ready) begin
						s_sample_ptn_buffer_w = 1'b1;
						if ((r_ptn_buffer_w == cfg_len0_i) && (r_ptn_buffer_l == cfg_len1_i)) begin
							s_done = 1'b1;
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
				2:
					if (s_data_rx_valid && s_data_rx_ready) begin
						s_sample_ptn_buffer_w = 1'b1;
						if ((r_ptn_buffer_w == cfg_len0_i) && (r_ptn_buffer_l == cfg_len1_i)) begin
							s_done = 1'b1;
							s_ptn_buffer_w = 0;
							s_ptn_buffer_l = 0;
							s_sample_ptn_buffer_l = 1'b1;
						end
						else if (r_ptn_buffer_l == cfg_len1_i) begin
							s_sample_ptn_buffer_l = 1'b1;
							s_sample_loc_pointer = 1'b1;
							s_sample_loc_startaddr = 1'b1;
							s_ptn_buffer_l = 0;
							s_ptn_buffer_w = r_ptn_buffer_w + 1;
							s_loc_pointer = r_loc_startaddr + s_datasize_toadd;
							s_loc_startaddr = s_loc_pointer;
						end
						else begin
							s_sample_ptn_buffer_l = 1'b1;
							s_sample_loc_pointer = 1'b1;
							s_ptn_buffer_l = r_ptn_buffer_l + 1;
							s_loc_pointer = r_loc_pointer + cfg_len2_i;
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
		end
		else begin
			r_state <= s_state;
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
