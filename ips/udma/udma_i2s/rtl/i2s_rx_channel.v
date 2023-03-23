module i2s_rx_channel (
	sck_i,
	rstn_i,
	i2s_ch0_i,
	i2s_ch1_i,
	i2s_ws_i,
	fifo_data_o,
	fifo_data_valid_o,
	fifo_data_ready_i,
	fifo_err_o,
	cfg_en_i,
	cfg_2ch_i,
	cfg_wlen_i,
	cfg_wnum_i,
	cfg_lsb_first_i
);
	input wire sck_i;
	input wire rstn_i;
	input wire i2s_ch0_i;
	input wire i2s_ch1_i;
	input wire i2s_ws_i;
	output wire [31:0] fifo_data_o;
	output wire fifo_data_valid_o;
	input wire fifo_data_ready_i;
	output wire fifo_err_o;
	input wire cfg_en_i;
	input wire cfg_2ch_i;
	input wire [4:0] cfg_wlen_i;
	input wire [2:0] cfg_wnum_i;
	input wire cfg_lsb_first_i;
	reg [1:0] r_ws_sync;
	wire s_ws_edge;
	wire s_ws_redge;
	reg [31:0] r_shiftreg_ch0;
	reg [31:0] r_shiftreg_ch1;
	reg [31:0] s_shiftreg_ch0;
	reg [31:0] s_shiftreg_ch1;
	reg [31:0] r_shiftreg_shadow;
	reg [4:0] r_count_bit;
	wire [2:0] r_count_word;
	reg r_word_done_dly;
	wire s_word_done;
	reg r_started;
	assign s_ws_edge = r_ws_sync[1] ^ r_ws_sync[0];
	assign s_word_done = r_count_bit == cfg_wlen_i;
	assign fifo_data_o = (s_word_done ? r_shiftreg_ch0 : (r_word_done_dly ? r_shiftreg_shadow : 32'h00000000));
	assign fifo_data_valid_o = s_word_done | (cfg_2ch_i & r_word_done_dly);
	assign fifo_err_o = fifo_data_valid_o & ~fifo_data_ready_i;
	always @(*) begin : proc_shiftreg
		s_shiftreg_ch0 = r_shiftreg_ch0;
		s_shiftreg_ch1 = r_shiftreg_ch1;
		if (cfg_lsb_first_i) begin
			s_shiftreg_ch0 = {1'b0, r_shiftreg_ch0[31:1]};
			s_shiftreg_ch0[cfg_wlen_i] = i2s_ch0_i;
			s_shiftreg_ch1 = {1'b0, r_shiftreg_ch1[31:1]};
			s_shiftreg_ch1[cfg_wlen_i] = i2s_ch1_i;
		end
		else begin
			s_shiftreg_ch0 = {r_shiftreg_ch0[30:0], i2s_ch0_i};
			s_shiftreg_ch1 = {r_shiftreg_ch1[30:0], i2s_ch1_i};
		end
	end
	always @(posedge sck_i or negedge rstn_i)
		if (rstn_i == 1'b0) begin
			r_shiftreg_ch0 <= 'h0;
			r_shiftreg_ch1 <= 'h0;
		end
		else if (r_started) begin
			r_shiftreg_ch0 <= s_shiftreg_ch0;
			if (cfg_2ch_i) begin
				r_shiftreg_ch1 <= s_shiftreg_ch1;
				if (s_word_done)
					r_shiftreg_shadow <= s_shiftreg_ch1;
			end
		end
	always @(negedge sck_i or negedge rstn_i)
		if (rstn_i == 1'b0)
			r_count_bit <= 'h0;
		else if (r_started)
			if (s_word_done)
				r_count_bit <= 'h0;
			else
				r_count_bit <= r_count_bit + 1;
	always @(negedge sck_i or negedge rstn_i)
		if (rstn_i == 1'b0)
			r_word_done_dly <= 'h0;
		else if (r_started)
			r_word_done_dly <= s_word_done;
	always @(negedge sck_i or negedge rstn_i)
		if (rstn_i == 1'b0) begin
			r_ws_sync <= 'h0;
			r_started <= 'h0;
		end
		else begin
			r_ws_sync <= {r_ws_sync[0], i2s_ws_i};
			if (s_ws_edge)
				if (cfg_en_i)
					r_started <= 1'b1;
				else
					r_started <= 1'b0;
		end
endmodule
