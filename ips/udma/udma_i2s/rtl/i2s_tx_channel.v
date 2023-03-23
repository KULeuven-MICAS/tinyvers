module i2s_tx_channel (
	sck_i,
	rstn_i,
	i2s_ch0_o,
	i2s_ch1_o,
	i2s_ws_i,
	fifo_data_i,
	fifo_data_valid_i,
	fifo_data_ready_o,
	fifo_err_o,
	cfg_en_i,
	cfg_2ch_i,
	cfg_wlen_i,
	cfg_wnum_i,
	cfg_lsb_first_i
);
	input wire sck_i;
	input wire rstn_i;
	output reg i2s_ch0_o;
	output reg i2s_ch1_o;
	input wire i2s_ws_i;
	input wire [31:0] fifo_data_i;
	input wire fifo_data_valid_i;
	output wire fifo_data_ready_o;
	output wire fifo_err_o;
	input wire cfg_en_i;
	input wire cfg_2ch_i;
	input wire [4:0] cfg_wlen_i;
	input wire [2:0] cfg_wnum_i;
	input wire cfg_lsb_first_i;
	reg [1:0] r_ws_sync;
	wire s_ws_edge;
	reg [31:0] r_shiftreg_ch0;
	reg [31:0] r_shiftreg_ch1;
	reg [31:0] s_shiftreg_ch0;
	reg [31:0] s_shiftreg_ch1;
	reg [31:0] r_shiftreg_shadow;
	reg [31:0] s_shiftreg_shadow;
	reg s_sample_in;
	reg s_sample_sr0;
	reg s_sample_sr1;
	reg s_sample_swd;
	reg s_update_cnt;
	reg [4:0] r_count_bit;
	wire [2:0] r_count_word;
	wire s_word_done;
	wire r_started;
	reg [1:0] r_state;
	reg [1:0] s_state;
	assign s_ws_edge = i2s_ws_i ^ r_ws_sync[0];
	assign s_word_done = r_count_bit == cfg_wlen_i;
	wire s_word_done_pre;
	assign s_word_done_pre = r_count_bit == (cfg_wlen_i - 1);
	assign fifo_data_ready_o = s_sample_in;
	wire s_i2s_ch0;
	assign s_i2s_ch0 = (cfg_lsb_first_i ? r_shiftreg_ch0[0] : r_shiftreg_ch0[cfg_wlen_i]);
	wire s_i2s_ch1;
	assign s_i2s_ch1 = (cfg_lsb_first_i ? r_shiftreg_ch1[0] : r_shiftreg_ch1[cfg_wlen_i]);
	always @(*) begin : proc_SM
		s_sample_in = 1'b0;
		s_update_cnt = 1'b0;
		s_sample_sr0 = 1'b0;
		s_sample_sr1 = 1'b0;
		s_sample_swd = 1'b0;
		s_shiftreg_ch0 = r_shiftreg_ch0;
		s_shiftreg_ch1 = r_shiftreg_ch1;
		s_shiftreg_shadow = r_shiftreg_shadow;
		s_state = r_state;
		case (r_state)
			2'd0:
				if (fifo_data_valid_i) begin
					s_sample_in = 1'b1;
					s_sample_sr0 = 1'b1;
					s_shiftreg_ch0 = fifo_data_i;
					s_state = 2'd1;
				end
			2'd1:
				if (fifo_data_valid_i) begin
					s_sample_in = 1'b1;
					s_sample_sr1 = 1'b1;
					s_shiftreg_ch1 = fifo_data_i;
					s_state = 2'd2;
				end
			2'd2:
				if (s_ws_edge)
					s_state = 2'd3;
			2'd3: begin
				s_update_cnt = 1'b1;
				s_sample_sr0 = 1'b1;
				s_sample_sr1 = cfg_2ch_i;
				if (s_word_done_pre)
					if (cfg_2ch_i) begin
						s_sample_in = 1'b1;
						s_shiftreg_shadow = fifo_data_i;
						s_sample_swd = 1'b1;
					end
				if (s_word_done) begin
					s_sample_in = 1'b1;
					if (cfg_2ch_i)
						s_shiftreg_ch0 = r_shiftreg_shadow;
					else
						s_shiftreg_ch0 = fifo_data_i;
					s_shiftreg_ch1 = fifo_data_i;
				end
				else if (cfg_lsb_first_i) begin
					s_shiftreg_ch0 = {1'b0, r_shiftreg_ch0[31:1]};
					s_shiftreg_ch1 = {1'b0, r_shiftreg_ch1[31:1]};
				end
				else begin
					s_shiftreg_ch1 = {r_shiftreg_ch1[30:0], 1'b0};
					s_shiftreg_ch0 = {r_shiftreg_ch0[30:0], 1'b0};
				end
			end
		endcase
	end
	always @(posedge sck_i or negedge rstn_i)
		if (rstn_i == 1'b0)
			r_state <= 2'd0;
		else
			r_state <= s_state;
	always @(posedge sck_i or negedge rstn_i)
		if (rstn_i == 1'b0) begin
			r_shiftreg_ch0 <= 'h0;
			r_shiftreg_ch1 <= 'h0;
			r_shiftreg_shadow <= 'h0;
		end
		else begin
			if (s_sample_sr0)
				r_shiftreg_ch0 <= s_shiftreg_ch0;
			if (s_sample_sr1)
				r_shiftreg_ch1 <= s_shiftreg_ch1;
			if (s_sample_swd)
				r_shiftreg_shadow <= s_shiftreg_shadow;
		end
	always @(posedge sck_i or negedge rstn_i)
		if (rstn_i == 1'b0)
			r_count_bit <= 'h0;
		else if (s_update_cnt)
			if (s_word_done)
				r_count_bit <= 'h0;
			else
				r_count_bit <= r_count_bit + 1;
	always @(posedge sck_i or negedge rstn_i)
		if (rstn_i == 1'b0)
			r_ws_sync <= 'h0;
		else
			r_ws_sync <= {r_ws_sync[0], i2s_ws_i};
	always @(negedge sck_i or negedge rstn_i)
		if (rstn_i == 1'b0) begin
			i2s_ch0_o <= 'h0;
			i2s_ch1_o <= 'h0;
		end
		else begin
			i2s_ch0_o <= s_i2s_ch0;
			i2s_ch1_o <= s_i2s_ch1;
		end
endmodule
