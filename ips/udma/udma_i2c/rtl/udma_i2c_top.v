module udma_i2c_top (
	sys_clk_i,
	periph_clk_i,
	rstn_i,
	ext_events_i,
	cfg_data_i,
	cfg_addr_i,
	cfg_valid_i,
	cfg_rwn_i,
	cfg_data_o,
	cfg_ready_o,
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
	data_tx_req_o,
	data_tx_gnt_i,
	data_tx_datasize_o,
	data_tx_i,
	data_tx_valid_i,
	data_tx_ready_o,
	data_rx_datasize_o,
	data_rx_o,
	data_rx_valid_o,
	data_rx_ready_i,
	err_o,
	scl_i,
	scl_o,
	scl_oe,
	sda_i,
	sda_o,
	sda_oe
);
	parameter L2_AWIDTH_NOAL = 12;
	parameter TRANS_SIZE = 16;
	input wire sys_clk_i;
	input wire periph_clk_i;
	input wire rstn_i;
	input wire [3:0] ext_events_i;
	input wire [31:0] cfg_data_i;
	input wire [4:0] cfg_addr_i;
	input wire cfg_valid_i;
	input wire cfg_rwn_i;
	output wire [31:0] cfg_data_o;
	output wire cfg_ready_o;
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
	output wire data_tx_req_o;
	input wire data_tx_gnt_i;
	output wire [1:0] data_tx_datasize_o;
	input wire [7:0] data_tx_i;
	input wire data_tx_valid_i;
	output wire data_tx_ready_o;
	output wire [1:0] data_rx_datasize_o;
	output wire [7:0] data_rx_o;
	output wire data_rx_valid_o;
	input wire data_rx_ready_i;
	output wire err_o;
	input wire scl_i;
	output wire scl_o;
	output wire scl_oe;
	input wire sda_i;
	output wire sda_o;
	output wire sda_oe;
	wire [7:0] s_data_tx;
	wire s_data_tx_valid;
	wire s_data_tx_ready;
	wire [7:0] s_data_tx_dc;
	wire s_data_tx_dc_valid;
	wire s_data_tx_dc_ready;
	wire [7:0] s_data_rx_dc;
	wire s_data_rx_dc_valid;
	wire s_data_rx_dc_ready;
	wire s_do_rst;
	assign data_tx_datasize_o = 2'b00;
	assign data_rx_datasize_o = 2'b00;
	udma_i2c_reg_if #(
		.L2_AWIDTH_NOAL(L2_AWIDTH_NOAL),
		.TRANS_SIZE(TRANS_SIZE)
	) u_reg_if(
		.clk_i(sys_clk_i),
		.rstn_i(rstn_i),
		.cfg_data_i(cfg_data_i),
		.cfg_addr_i(cfg_addr_i),
		.cfg_valid_i(cfg_valid_i),
		.cfg_rwn_i(cfg_rwn_i),
		.cfg_ready_o(cfg_ready_o),
		.cfg_data_o(cfg_data_o),
		.cfg_rx_startaddr_o(cfg_rx_startaddr_o),
		.cfg_rx_size_o(cfg_rx_size_o),
		.cfg_rx_continuous_o(cfg_rx_continuous_o),
		.cfg_rx_en_o(cfg_rx_en_o),
		.cfg_rx_clr_o(cfg_rx_clr_o),
		.cfg_rx_en_i(cfg_rx_en_i),
		.cfg_rx_pending_i(cfg_rx_pending_i),
		.cfg_rx_curr_addr_i(cfg_rx_curr_addr_i),
		.cfg_rx_bytes_left_i(cfg_rx_bytes_left_i),
		.cfg_tx_startaddr_o(cfg_tx_startaddr_o),
		.cfg_tx_size_o(cfg_tx_size_o),
		.cfg_tx_continuous_o(cfg_tx_continuous_o),
		.cfg_tx_en_o(cfg_tx_en_o),
		.cfg_tx_clr_o(cfg_tx_clr_o),
		.cfg_tx_en_i(cfg_tx_en_i),
		.cfg_tx_pending_i(cfg_tx_pending_i),
		.cfg_tx_curr_addr_i(cfg_tx_curr_addr_i),
		.cfg_tx_bytes_left_i(cfg_tx_bytes_left_i),
		.cfg_do_rst_o(s_do_rst),
		.status_busy_i(1'b0),
		.status_al_i(1'b0)
	);
	io_tx_fifo #(
		.DATA_WIDTH(8),
		.BUFFER_DEPTH(2)
	) i_i2c_tx_fifo(
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
	udma_dc_fifo #(
		8,
		4
	) i_dc_fifo_tx(
		.src_clk_i(sys_clk_i),
		.src_rstn_i(rstn_i),
		.src_data_i(s_data_tx),
		.src_valid_i(s_data_tx_valid),
		.src_ready_o(s_data_tx_ready),
		.dst_clk_i(periph_clk_i),
		.dst_rstn_i(rstn_i),
		.dst_data_o(s_data_tx_dc),
		.dst_valid_o(s_data_tx_dc_valid),
		.dst_ready_i(s_data_tx_dc_ready)
	);
	udma_dc_fifo #(
		8,
		4
	) u_dc_fifo_rx(
		.src_clk_i(periph_clk_i),
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
	udma_i2c_control i_i2c_control(
		.clk_i(periph_clk_i),
		.rstn_i(rstn_i),
		.ext_events_i(ext_events_i),
		.data_tx_i(s_data_tx_dc),
		.data_tx_valid_i(s_data_tx_dc_valid),
		.data_tx_ready_o(s_data_tx_dc_ready),
		.data_rx_o(s_data_rx_dc),
		.data_rx_valid_o(s_data_rx_dc_valid),
		.data_rx_ready_i(s_data_rx_dc_ready),
		.sw_rst_i(s_do_rst),
		.scl_i(scl_i),
		.scl_o(scl_o),
		.scl_oe(scl_oe),
		.sda_i(sda_i),
		.sda_o(sda_o),
		.sda_oe(sda_oe)
	);
endmodule
