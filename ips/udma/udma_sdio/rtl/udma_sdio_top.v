module udma_sdio_top (
	sys_clk_i,
	periph_clk_i,
	rstn_i,
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
	eot_o,
	err_o,
	sdclk_o,
	sdcmd_o,
	sdcmd_i,
	sdcmd_oen_o,
	sddata_o,
	sddata_i,
	sddata_oen_o
);
	parameter L2_AWIDTH_NOAL = 12;
	parameter TRANS_SIZE = 16;
	input wire sys_clk_i;
	input wire periph_clk_i;
	input wire rstn_i;
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
	input wire [31:0] data_tx_i;
	input wire data_tx_valid_i;
	output wire data_tx_ready_o;
	output wire [1:0] data_rx_datasize_o;
	output wire [31:0] data_rx_o;
	output wire data_rx_valid_o;
	input wire data_rx_ready_i;
	output wire eot_o;
	output wire err_o;
	output wire sdclk_o;
	output wire sdcmd_o;
	input wire sdcmd_i;
	output wire sdcmd_oen_o;
	output wire [3:0] sddata_o;
	input wire [3:0] sddata_i;
	output wire [3:0] sddata_oen_o;
	wire [31:0] s_data_tx;
	wire s_data_tx_valid;
	wire s_data_tx_ready;
	wire [31:0] s_data_tx_dc;
	wire s_data_tx_dc_valid;
	wire s_data_tx_dc_ready;
	wire [31:0] s_data_rx_dc;
	wire s_data_rx_dc_valid;
	wire s_data_rx_dc_ready;
	wire [5:0] s_cmd_op;
	wire [31:0] s_cmd_arg;
	wire [2:0] s_cmd_rsp_type;
	wire [127:0] s_rsp_data;
	wire s_data_en;
	wire s_data_rwn;
	wire s_data_quad;
	wire [9:0] s_data_block_size;
	wire [7:0] s_data_block_num;
	wire [15:0] s_status;
	wire s_start;
	wire s_start_sync;
	wire s_clkdiv_en;
	wire [7:0] s_clkdiv_data;
	wire s_clkdiv_valid;
	wire s_clkdiv_ack;
	wire s_clk_sdio;
	wire s_eot;
	wire s_err;
	assign data_tx_datasize_o = 2'b10;
	assign data_rx_datasize_o = 2'b10;
	assign s_clkdiv_en = 1'b1;
	assign s_err = (s_status ? 1'b1 : 1'b0);
	pulp_sync_wedge error_int_sync(
		.clk_i(sys_clk_i),
		.rstn_i(rstn_i),
		.en_i(1'b1),
		.serial_i(s_err),
		.r_edge_o(err_o),
		.f_edge_o(),
		.serial_o()
	);
	udma_sdio_reg_if #(
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
		.cfg_sdio_start_o(s_start),
		.cfg_clk_div_data_o(s_clkdiv_data),
		.cfg_clk_div_valid_o(s_clkdiv_valid),
		.cfg_clk_div_ack_i(s_clkdiv_ack),
		.txrx_status_i(s_status),
		.txrx_eot_i(eot_o),
		.txrx_err_i(err_o),
		.cfg_cmd_op_o(s_cmd_op),
		.cfg_cmd_arg_o(s_cmd_arg),
		.cfg_cmd_rsp_type_o(s_cmd_rsp_type),
		.cfg_rsp_data_i(s_rsp_data),
		.cfg_data_en_o(s_data_en),
		.cfg_data_rwn_o(s_data_rwn),
		.cfg_data_quad_o(s_data_quad),
		.cfg_data_block_size_o(s_data_block_size),
		.cfg_data_block_num_o(s_data_block_num)
	);
	udma_clkgen u_clockgen(
		.clk_i(periph_clk_i),
		.rstn_i(rstn_i),
		.dft_test_mode_i(1'b0),
		.dft_cg_enable_i(1'b0),
		.clock_enable_i(s_clkdiv_en),
		.clk_div_data_i(s_clkdiv_data),
		.clk_div_valid_i(s_clkdiv_valid),
		.clk_div_ack_o(s_clkdiv_ack),
		.clk_o(s_clk_sdio)
	);
	edge_propagator i_start_sync(
		.clk_tx_i(sys_clk_i),
		.rstn_tx_i(rstn_i),
		.edge_i(s_start),
		.clk_rx_i(s_clk_sdio),
		.rstn_rx_i(rstn_i),
		.edge_o(s_start_sync)
	);
	edge_propagator i_eot_sync(
		.clk_tx_i(s_clk_sdio),
		.rstn_tx_i(rstn_i),
		.edge_i(s_eot),
		.clk_rx_i(sys_clk_i),
		.rstn_rx_i(rstn_i),
		.edge_o(eot_o)
	);
	sdio_txrx i_sdio_txrx(
		.clk_i(s_clk_sdio),
		.rstn_i(rstn_i),
		.clr_stat_i(1'b0),
		.cmd_start_i(s_start_sync),
		.cmd_op_i(s_cmd_op),
		.cmd_arg_i(s_cmd_arg),
		.cmd_rsp_type_i(s_cmd_rsp_type),
		.rsp_data_o(s_rsp_data),
		.data_en_i(s_data_en),
		.data_rwn_i(s_data_rwn),
		.data_quad_i(s_data_quad),
		.data_block_size_i(s_data_block_size),
		.data_block_num_i(s_data_block_num),
		.eot_o(s_eot),
		.status_o(s_status),
		.in_data_if_data_i(s_data_tx_dc),
		.in_data_if_valid_i(s_data_tx_dc_valid),
		.in_data_if_ready_o(s_data_tx_dc_ready),
		.out_data_if_data_o(s_data_rx_dc),
		.out_data_if_valid_o(s_data_rx_dc_valid),
		.out_data_if_ready_i(s_data_rx_dc_ready),
		.sdclk_o(sdclk_o),
		.sdcmd_o(sdcmd_o),
		.sdcmd_i(sdcmd_i),
		.sdcmd_oen_o(sdcmd_oen_o),
		.sddata_o(sddata_o),
		.sddata_i(sddata_i),
		.sddata_oen_o(sddata_oen_o)
	);
	io_tx_fifo #(
		.DATA_WIDTH(32),
		.BUFFER_DEPTH(2)
	) i_sdio_tx_fifo(
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
		32,
		4
	) i_dc_fifo_tx(
		.src_clk_i(sys_clk_i),
		.src_rstn_i(rstn_i),
		.src_data_i(s_data_tx),
		.src_valid_i(s_data_tx_valid),
		.src_ready_o(s_data_tx_ready),
		.dst_clk_i(s_clk_sdio),
		.dst_rstn_i(rstn_i),
		.dst_data_o(s_data_tx_dc),
		.dst_valid_o(s_data_tx_dc_valid),
		.dst_ready_i(s_data_tx_dc_ready)
	);
	udma_dc_fifo #(
		32,
		4
	) u_dc_fifo_rx(
		.src_clk_i(s_clk_sdio),
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
endmodule
