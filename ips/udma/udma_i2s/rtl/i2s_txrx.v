module i2s_txrx (
	rstn_i,
	dft_test_mode_i,
	dft_cg_enable_i,
	slave_clk_i,
	slave_ws_i,
	master_clk_i,
	master_ws_i,
	pad_pdm_clk_o,
	pad_slave_sd0_i,
	pad_slave_sd1_i,
	pad_master_sd0_o,
	pad_master_sd1_o,
	cfg_slave_en_i,
	cfg_master_en_i,
	cfg_slave_i2s_lsb_first_i,
	cfg_slave_i2s_2ch_i,
	cfg_slave_i2s_bits_word_i,
	cfg_slave_i2s_words_i,
	cfg_slave_pdm_en_i,
	cfg_slave_pdm_mode_i,
	cfg_slave_pdm_decimation_i,
	cfg_slave_pdm_shift_i,
	cfg_master_i2s_lsb_first_i,
	cfg_master_i2s_2ch_i,
	cfg_master_i2s_bits_word_i,
	cfg_master_i2s_words_i,
	fifo_rx_data_o,
	fifo_rx_data_valid_o,
	fifo_rx_data_ready_i,
	fifo_tx_data_i,
	fifo_tx_data_valid_i,
	fifo_tx_data_ready_o
);
	input wire rstn_i;
	input wire dft_test_mode_i;
	input wire dft_cg_enable_i;
	input wire slave_clk_i;
	input wire slave_ws_i;
	input wire master_clk_i;
	input wire master_ws_i;
	output wire pad_pdm_clk_o;
	input wire pad_slave_sd0_i;
	input wire pad_slave_sd1_i;
	output wire pad_master_sd0_o;
	output wire pad_master_sd1_o;
	input wire cfg_slave_en_i;
	input wire cfg_master_en_i;
	input wire cfg_slave_i2s_lsb_first_i;
	input wire cfg_slave_i2s_2ch_i;
	input wire [4:0] cfg_slave_i2s_bits_word_i;
	input wire [2:0] cfg_slave_i2s_words_i;
	input wire cfg_slave_pdm_en_i;
	input wire [1:0] cfg_slave_pdm_mode_i;
	input wire [9:0] cfg_slave_pdm_decimation_i;
	input wire [2:0] cfg_slave_pdm_shift_i;
	input wire cfg_master_i2s_lsb_first_i;
	input wire cfg_master_i2s_2ch_i;
	input wire [4:0] cfg_master_i2s_bits_word_i;
	input wire [2:0] cfg_master_i2s_words_i;
	output wire [31:0] fifo_rx_data_o;
	output wire fifo_rx_data_valid_o;
	input wire fifo_rx_data_ready_i;
	input wire [31:0] fifo_tx_data_i;
	input wire fifo_tx_data_valid_i;
	output wire fifo_tx_data_ready_o;
	wire [15:0] s_pdm_fifo_data;
	wire s_pdm_fifo_data_valid;
	wire s_pdm_fifo_data_ready;
	wire [31:0] s_i2s_slv_fifo_data;
	wire s_i2s_slv_fifo_data_valid;
	wire s_i2s_slv_fifo_data_ready;
	wire s_i2s_slv_en;
	assign s_i2s_slv_en = cfg_slave_en_i & !cfg_slave_pdm_en_i;
	assign fifo_rx_data_o = (cfg_slave_pdm_en_i ? {16'h0000, s_pdm_fifo_data} : s_i2s_slv_fifo_data);
	assign fifo_rx_data_valid_o = (cfg_slave_pdm_en_i ? s_pdm_fifo_data_valid : s_i2s_slv_fifo_data_valid);
	assign s_i2s_slv_fifo_data_ready = fifo_rx_data_ready_i;
	assign s_pdm_fifo_data_ready = fifo_rx_data_ready_i;
	i2s_rx_channel i_i2s_slave(
		.sck_i(slave_clk_i),
		.rstn_i(rstn_i),
		.i2s_ch0_i(pad_slave_sd0_i),
		.i2s_ch1_i(pad_slave_sd1_i),
		.i2s_ws_i(slave_ws_i),
		.fifo_data_o(s_i2s_slv_fifo_data),
		.fifo_data_valid_o(s_i2s_slv_fifo_data_valid),
		.fifo_data_ready_i(s_i2s_slv_fifo_data_ready),
		.cfg_en_i(s_i2s_slv_en),
		.cfg_2ch_i(cfg_slave_i2s_2ch_i),
		.cfg_wlen_i(cfg_slave_i2s_bits_word_i),
		.cfg_wnum_i(cfg_slave_i2s_words_i),
		.cfg_lsb_first_i(cfg_slave_i2s_lsb_first_i)
	);
	pdm_top i_pdm(
		.clk_i(slave_clk_i),
		.rstn_i(rstn_i),
		.pdm_clk_o(pad_pdm_clk_o),
		.cfg_pdm_ch_mode_i(cfg_slave_pdm_mode_i),
		.cfg_pdm_decimation_i(cfg_slave_pdm_decimation_i),
		.cfg_pdm_shift_i(cfg_slave_pdm_shift_i),
		.cfg_pdm_en_i(cfg_slave_pdm_en_i),
		.pdm_ch0_i(pad_slave_sd0_i),
		.pdm_ch1_i(pad_slave_sd1_i),
		.pcm_data_o(s_pdm_fifo_data),
		.pcm_data_valid_o(s_pdm_fifo_data_valid),
		.pcm_data_ready_i(s_pdm_fifo_data_ready)
	);
	i2s_tx_channel i_i2s_master(
		.sck_i(master_clk_i),
		.rstn_i(rstn_i),
		.i2s_ch0_o(pad_master_sd0_o),
		.i2s_ch1_o(pad_master_sd1_o),
		.i2s_ws_i(master_ws_i),
		.fifo_data_i(fifo_tx_data_i),
		.fifo_data_valid_i(fifo_tx_data_valid_i),
		.fifo_data_ready_o(fifo_tx_data_ready_o),
		.cfg_en_i(cfg_master_en_i),
		.cfg_2ch_i(cfg_master_i2s_2ch_i),
		.cfg_wlen_i(cfg_master_i2s_bits_word_i),
		.cfg_wnum_i(cfg_master_i2s_words_i),
		.cfg_lsb_first_i(cfg_master_i2s_lsb_first_i)
	);
endmodule
