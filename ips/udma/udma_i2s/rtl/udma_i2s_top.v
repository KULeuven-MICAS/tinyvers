module udma_i2s_top (
	sys_clk_i,
	periph_clk_i,
	rstn_i,
	dft_test_mode_i,
	dft_cg_enable_i,
	pad_slave_sd0_i,
	pad_slave_sd1_i,
	pad_slave_sck_i,
	pad_slave_sck_o,
	pad_slave_sck_oe,
	pad_slave_ws_i,
	pad_slave_ws_o,
	pad_slave_ws_oe,
	pad_master_sd0_o,
	pad_master_sd1_o,
	pad_master_sck_i,
	pad_master_sck_o,
	pad_master_sck_oe,
	pad_master_ws_i,
	pad_master_ws_o,
	pad_master_ws_oe,
	cfg_data_i,
	cfg_addr_i,
	cfg_valid_i,
	cfg_rwn_i,
	cfg_ready_o,
	cfg_data_o,
	cfg_rx_startaddr_o,
	cfg_rx_size_o,
	cfg_rx_continuous_o,
	cfg_rx_en_o,
	cfg_rx_clr_o,
	cfg_rx_en_i,
	cfg_rx_pending_i,
	cfg_rx_curr_addr_i,
	cfg_rx_bytes_left_i,
	cfg_tx_startaddr_o,
	cfg_tx_size_o,
	cfg_tx_continuous_o,
	cfg_tx_en_o,
	cfg_tx_clr_o,
	cfg_tx_en_i,
	cfg_tx_pending_i,
	cfg_tx_curr_addr_i,
	cfg_tx_bytes_left_i,
	data_rx_datasize_o,
	data_rx_o,
	data_rx_valid_o,
	data_rx_ready_i,
	data_tx_req_o,
	data_tx_gnt_i,
	data_tx_datasize_o,
	data_tx_i,
	data_tx_valid_i,
	data_tx_ready_o
);
	parameter L2_AWIDTH_NOAL = 12;
	parameter TRANS_SIZE = 16;
	parameter BUFFER_WIDTH = 4;
	input wire sys_clk_i;
	input wire periph_clk_i;
	input wire rstn_i;
	input wire dft_test_mode_i;
	input wire dft_cg_enable_i;
	input wire pad_slave_sd0_i;
	input wire pad_slave_sd1_i;
	input wire pad_slave_sck_i;
	output wire pad_slave_sck_o;
	output wire pad_slave_sck_oe;
	input wire pad_slave_ws_i;
	output wire pad_slave_ws_o;
	output wire pad_slave_ws_oe;
	output wire pad_master_sd0_o;
	output wire pad_master_sd1_o;
	input wire pad_master_sck_i;
	output wire pad_master_sck_o;
	output wire pad_master_sck_oe;
	input wire pad_master_ws_i;
	output wire pad_master_ws_o;
	output wire pad_master_ws_oe;
	input wire [31:0] cfg_data_i;
	input wire [4:0] cfg_addr_i;
	input wire cfg_valid_i;
	input wire cfg_rwn_i;
	output wire cfg_ready_o;
	output wire [31:0] cfg_data_o;
	output wire [L2_AWIDTH_NOAL - 1:0] cfg_rx_startaddr_o;
	output wire [TRANS_SIZE - 1:0] cfg_rx_size_o;
	output wire cfg_rx_continuous_o;
	output wire cfg_rx_en_o;
	output wire cfg_rx_clr_o;
	input wire cfg_rx_en_i;
	input wire cfg_rx_pending_i;
	input wire [L2_AWIDTH_NOAL - 1:0] cfg_rx_curr_addr_i;
	input wire [TRANS_SIZE - 1:0] cfg_rx_bytes_left_i;
	output wire [L2_AWIDTH_NOAL - 1:0] cfg_tx_startaddr_o;
	output wire [TRANS_SIZE - 1:0] cfg_tx_size_o;
	output wire cfg_tx_continuous_o;
	output wire cfg_tx_en_o;
	output wire cfg_tx_clr_o;
	input wire cfg_tx_en_i;
	input wire cfg_tx_pending_i;
	input wire [L2_AWIDTH_NOAL - 1:0] cfg_tx_curr_addr_i;
	input wire [TRANS_SIZE - 1:0] cfg_tx_bytes_left_i;
	output wire [1:0] data_rx_datasize_o;
	output wire [31:0] data_rx_o;
	output wire data_rx_valid_o;
	input wire data_rx_ready_i;
	output wire data_tx_req_o;
	input wire data_tx_gnt_i;
	output wire [1:0] data_tx_datasize_o;
	input wire [31:0] data_tx_i;
	input wire data_tx_valid_i;
	output wire data_tx_ready_o;
	wire [1:0] s_slave_mode;
	wire [1:0] s_slave_i2s_mode;
	wire s_slave_i2s_lsb_first;
	wire [4:0] s_slave_i2s_bits_word;
	wire [2:0] s_slave_i2s_words;
	wire [1:0] s_slave_pdm_mode;
	wire [9:0] s_slave_pdm_decimation;
	wire [2:0] s_slave_pdm_shift;
	wire [1:0] s_master_i2s_mode;
	wire s_master_i2s_lsb_first;
	wire [4:0] s_master_i2s_bits_word;
	wire [2:0] s_master_i2s_words;
	wire s_slave_gen_clk_eni;
	wire s_slave_gen_clk_eno;
	wire [15:0] s_slave_gen_clk_div;
	wire s_master_gen_clk_eni;
	wire s_master_gen_clk_eno;
	wire [15:0] s_master_gen_clk_div;
	wire [31:0] s_fifo_data;
	wire s_fifo_valid;
	wire s_fifo_ready;
	wire [31:0] s_data_tx;
	wire s_data_tx_valid;
	wire s_data_tx_ready;
	wire [31:0] s_data_rx_dc;
	wire s_data_rx_dc_valid;
	wire s_data_rx_dc_ready;
	wire [31:0] s_data_tx_dc;
	wire s_data_tx_dc_valid;
	wire s_data_tx_dc_ready;
	wire [4:0] s_cfg_word_size_0;
	wire [2:0] s_cfg_word_num_0;
	wire [4:0] s_cfg_word_size_1;
	wire [2:0] s_cfg_word_num_1;
	wire s_sel_master_num;
	wire s_sel_master_ext;
	wire s_sel_slave_num;
	wire s_sel_slave_ext;
	wire s_master_clk_en;
	wire s_slave_clk_en;
	wire s_pdm_clk_en;
	wire s_slave_i2s_en;
	wire s_slave_i2s_2ch;
	wire s_slave_pdm_en;
	wire s_master_i2s_en;
	wire s_master_i2s_2ch;
	udma_i2s_reg_if #(
		.L2_AWIDTH_NOAL(L2_AWIDTH_NOAL),
		.TRANS_SIZE(TRANS_SIZE)
	) u_reg_if(
		.clk_i(sys_clk_i),
		.periph_clk_i(periph_clk_i),
		.rstn_i(rstn_i),
		.cfg_data_i(cfg_data_i),
		.cfg_addr_i(cfg_addr_i),
		.cfg_valid_i(cfg_valid_i),
		.cfg_rwn_i(cfg_rwn_i),
		.cfg_ready_o(cfg_ready_o),
		.cfg_data_o(cfg_data_o),
		.cfg_rx_startaddr_o(cfg_rx_startaddr_o),
		.cfg_rx_size_o(cfg_rx_size_o),
		.cfg_rx_datasize_o(data_rx_datasize_o),
		.cfg_rx_continuous_o(cfg_rx_continuous_o),
		.cfg_rx_en_o(cfg_rx_en_o),
		.cfg_rx_clr_o(cfg_rx_clr_o),
		.cfg_rx_en_i(cfg_rx_en_i),
		.cfg_rx_pending_i(cfg_rx_pending_i),
		.cfg_rx_curr_addr_i(cfg_rx_curr_addr_i),
		.cfg_rx_bytes_left_i(cfg_rx_bytes_left_i),
		.cfg_tx_startaddr_o(cfg_tx_startaddr_o),
		.cfg_tx_size_o(cfg_tx_size_o),
		.cfg_tx_datasize_o(data_tx_datasize_o),
		.cfg_tx_continuous_o(cfg_tx_continuous_o),
		.cfg_tx_en_o(cfg_tx_en_o),
		.cfg_tx_clr_o(cfg_tx_clr_o),
		.cfg_tx_en_i(cfg_tx_en_i),
		.cfg_tx_pending_i(cfg_tx_pending_i),
		.cfg_tx_curr_addr_i(cfg_tx_curr_addr_i),
		.cfg_tx_bytes_left_i(cfg_tx_bytes_left_i),
		.cfg_master_clk_en_o(s_master_clk_en),
		.cfg_slave_clk_en_o(s_slave_clk_en),
		.cfg_pdm_clk_en_o(s_pdm_clk_en),
		.cfg_master_sel_num_o(s_sel_master_num),
		.cfg_master_sel_ext_o(s_sel_master_ext),
		.cfg_slave_sel_num_o(s_sel_slave_num),
		.cfg_slave_sel_ext_o(s_sel_slave_ext),
		.cfg_slave_i2s_en_o(s_slave_i2s_en),
		.cfg_slave_i2s_lsb_first_o(s_slave_i2s_lsb_first),
		.cfg_slave_i2s_2ch_o(s_slave_i2s_2ch),
		.cfg_slave_i2s_bits_word_o(s_slave_i2s_bits_word),
		.cfg_slave_i2s_words_o(s_slave_i2s_words),
		.cfg_slave_pdm_en_o(s_slave_pdm_en),
		.cfg_slave_pdm_mode_o(s_slave_pdm_mode),
		.cfg_slave_pdm_decimation_o(s_slave_pdm_decimation),
		.cfg_slave_pdm_shift_o(s_slave_pdm_shift),
		.cfg_master_i2s_en_o(s_master_i2s_en),
		.cfg_master_i2s_lsb_first_o(s_master_i2s_lsb_first),
		.cfg_master_i2s_2ch_o(s_master_i2s_2ch),
		.cfg_master_i2s_bits_word_o(s_master_i2s_bits_word),
		.cfg_master_i2s_words_o(s_master_i2s_words),
		.cfg_slave_gen_clk_en_o(s_slave_gen_clk_eno),
		.cfg_slave_gen_clk_en_i(s_slave_gen_clk_eni),
		.cfg_slave_gen_clk_div_o(s_slave_gen_clk_div),
		.cfg_master_gen_clk_en_o(s_master_gen_clk_eno),
		.cfg_master_gen_clk_en_i(s_master_gen_clk_eni),
		.cfg_master_gen_clk_div_o(s_master_gen_clk_div)
	);
	io_tx_fifo #(
		.DATA_WIDTH(32),
		.BUFFER_DEPTH(2)
	) u_fifo(
		.clk_i(sys_clk_i),
		.rstn_i(rstn_i),
		.clr_i(1'b0),
		.data_o(s_data_tx),
		.valid_o(s_data_tx_valid),
		.ready_i(s_data_tx_ready),
		.req_o(data_tx_req_o),
		.gnt_i(data_tx_gnt_i),
		.valid_i(data_tx_valid_i),
		.data_i(data_tx_i),
		.ready_o(data_tx_ready_o)
	);
	wire s_i2s_master_clk;
	udma_dc_fifo #(
		32,
		4
	) u_dc_fifo_tx(
		.src_clk_i(sys_clk_i),
		.src_rstn_i(rstn_i),
		.src_data_i(s_data_tx),
		.src_valid_i(s_data_tx_valid),
		.src_ready_o(s_data_tx_ready),
		.dst_clk_i(s_i2s_master_clk),
		.dst_rstn_i(rstn_i),
		.dst_data_o(s_data_tx_dc),
		.dst_valid_o(s_data_tx_dc_valid),
		.dst_ready_i(s_data_tx_dc_ready)
	);
	wire s_i2s_slave_clk;
	udma_dc_fifo #(
		32,
		4
	) u_dc_fifo_rx(
		.src_clk_i(s_i2s_slave_clk),
		.src_rstn_i(rstn_i),
		.src_data_i(s_data_rx_dc),
		.src_valid_i(s_data_rx_dc_valid),
		.src_ready_o(s_data_rx_dc_ready),
		.dst_clk_i(sys_clk_i),
		.dst_rstn_i(rstn_i),
		.dst_data_o(data_rx_o),
		.dst_valid_o(data_rx_valid_o),
		.dst_ready_i(data_rx_ready_i)
	);
	wire s_pdm_clk;
	wire s_i2s_master_ws;
	wire s_i2s_slave_ws;
	i2s_clkws_gen i_clkws_gen(
		.clk_i(periph_clk_i),
		.rstn_i(rstn_i),
		.dft_test_mode_i(dft_test_mode_i),
		.dft_cg_enable_i(dft_cg_enable_i),
		.master_en_i(s_master_clk_en),
		.slave_en_i(s_slave_clk_en),
		.pdm_en_i(s_pdm_clk_en),
		.pdm_clk_i(s_pdm_clk),
		.pad_slave_sck_i(pad_slave_sck_i),
		.pad_slave_sck_o(pad_slave_sck_o),
		.pad_slave_sck_oe(pad_slave_sck_oe),
		.pad_slave_ws_i(pad_slave_ws_i),
		.pad_slave_ws_o(pad_slave_ws_o),
		.pad_slave_ws_oe(pad_slave_ws_oe),
		.pad_master_sck_i(pad_master_sck_i),
		.pad_master_sck_o(pad_master_sck_o),
		.pad_master_sck_oe(pad_master_sck_oe),
		.pad_master_ws_i(pad_master_ws_i),
		.pad_master_ws_o(pad_master_ws_o),
		.pad_master_ws_oe(pad_master_ws_oe),
		.cfg_div_1_i(s_slave_gen_clk_div),
		.cfg_div_0_i(s_master_gen_clk_div),
		.cfg_word_size_0_i(s_master_i2s_bits_word),
		.cfg_word_num_0_i(s_master_i2s_words),
		.cfg_word_size_1_i(s_slave_i2s_bits_word),
		.cfg_word_num_1_i(s_slave_i2s_words),
		.sel_master_num_i(s_sel_master_num),
		.sel_master_ext_i(s_sel_master_ext),
		.sel_slave_num_i(s_sel_slave_num),
		.sel_slave_ext_i(s_sel_slave_ext),
		.clk_master_o(s_i2s_master_clk),
		.ws_master_o(s_i2s_master_ws),
		.clk_slave_o(s_i2s_slave_clk),
		.ws_slave_o(s_i2s_slave_ws)
	);
	i2s_txrx i_i2s_txrx(
		.rstn_i(rstn_i),
		.dft_test_mode_i(dft_test_mode_i),
		.dft_cg_enable_i(dft_cg_enable_i),
		.slave_clk_i(s_i2s_slave_clk),
		.slave_ws_i(s_i2s_slave_ws),
		.master_clk_i(s_i2s_master_clk),
		.master_ws_i(s_i2s_master_ws),
		.pad_pdm_clk_o(s_pdm_clk),
		.pad_slave_sd0_i(pad_slave_sd0_i),
		.pad_slave_sd1_i(pad_slave_sd1_i),
		.pad_master_sd0_o(pad_master_sd0_o),
		.pad_master_sd1_o(pad_master_sd1_o),
		.cfg_slave_en_i(s_slave_i2s_en),
		.cfg_master_en_i(s_master_i2s_en),
		.cfg_slave_pdm_en_i(s_slave_pdm_en),
		.cfg_slave_pdm_mode_i(s_slave_pdm_mode),
		.cfg_slave_pdm_decimation_i(s_slave_pdm_decimation),
		.cfg_slave_pdm_shift_i(s_slave_pdm_shift),
		.cfg_slave_i2s_lsb_first_i(s_slave_i2s_lsb_first),
		.cfg_slave_i2s_2ch_i(s_slave_i2s_2ch),
		.cfg_slave_i2s_bits_word_i(s_slave_i2s_bits_word),
		.cfg_slave_i2s_words_i(s_slave_i2s_words),
		.cfg_master_i2s_lsb_first_i(s_master_i2s_lsb_first),
		.cfg_master_i2s_2ch_i(s_master_i2s_2ch),
		.cfg_master_i2s_bits_word_i(s_master_i2s_bits_word),
		.cfg_master_i2s_words_i(s_master_i2s_words),
		.fifo_rx_data_o(s_data_rx_dc),
		.fifo_rx_data_valid_o(s_data_rx_dc_valid),
		.fifo_rx_data_ready_i(s_data_rx_dc_ready),
		.fifo_tx_data_i(s_data_tx_dc),
		.fifo_tx_data_valid_i(s_data_tx_dc_valid),
		.fifo_tx_data_ready_o(s_data_tx_dc_ready)
	);
endmodule
