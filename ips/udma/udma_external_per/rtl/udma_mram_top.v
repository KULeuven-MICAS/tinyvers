module udma_mram_top (
	sys_clk_i,
	periph_clk_i,
	rstn_i,
	dft_test_mode_i,
	dft_cg_enable_i,
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
	erase_done_event_o,
	ref_line_done_event_o,
	trim_cfg_done_event_o,
	tx_done_event_o,
	tx_busy_i,
	rx_busy_i,
	tx_done_i,
	rx_error_i,
	trim_cfg_done_i,
	erase_pending_i,
	erase_done_i,
	ref_line_pending_i,
	ref_line_done_i,
	data_tx_write_token_o,
	data_tx_read_pointer_i,
	data_tx_asynch_o,
	cmd_tx_write_token_o,
	cmd_tx_read_pointer_i,
	cmd_tx_asynch_o,
	data_rx_write_token_i,
	data_rx_read_pointer_o,
	data_rx_asynch_i,
	cmd_rx_write_token_o,
	cmd_rx_read_pointer_i,
	cmd_rx_asynch_o,
	mram_mode_static_o,
	rstn_dcfifo_i,
	mram_clk_o,
	mram_clk_en_i,
	mram_erase_addr_o,
	mram_erase_size_o
);
	parameter L2_AWIDTH_NOAL = 12;
	parameter TRANS_SIZE = 16;
	parameter MRAM_ADDR_WIDTH = 16;
	parameter TX_CMD_WIDTH = (MRAM_ADDR_WIDTH + TRANS_SIZE) + 11;
	parameter TX_DATA_WIDTH = 32;
	parameter TX_DC_FIFO_DEPTH = 4;
	parameter RX_CMD_WIDTH = (MRAM_ADDR_WIDTH + TRANS_SIZE) + 11;
	parameter RX_DATA_WIDTH = 64;
	parameter RX_DC_FIFO_DEPTH = 4;
	input wire sys_clk_i;
	input wire periph_clk_i;
	input wire rstn_i;
	input wire dft_test_mode_i;
	input wire dft_cg_enable_i;
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
	output wire erase_done_event_o;
	output wire ref_line_done_event_o;
	output wire trim_cfg_done_event_o;
	output wire tx_done_event_o;
	input wire tx_busy_i;
	input wire rx_busy_i;
	input wire tx_done_i;
	input wire [1:0] rx_error_i;
	input wire trim_cfg_done_i;
	input wire erase_pending_i;
	input wire erase_done_i;
	input wire ref_line_pending_i;
	input wire ref_line_done_i;
	output wire [TX_DC_FIFO_DEPTH - 1:0] data_tx_write_token_o;
	input wire [TX_DC_FIFO_DEPTH - 1:0] data_tx_read_pointer_i;
	output wire [TX_DATA_WIDTH - 1:0] data_tx_asynch_o;
	output wire [TX_DC_FIFO_DEPTH - 1:0] cmd_tx_write_token_o;
	input wire [TX_DC_FIFO_DEPTH - 1:0] cmd_tx_read_pointer_i;
	output wire [TX_CMD_WIDTH - 1:0] cmd_tx_asynch_o;
	input wire [RX_DC_FIFO_DEPTH - 1:0] data_rx_write_token_i;
	output wire [RX_DC_FIFO_DEPTH - 1:0] data_rx_read_pointer_o;
	input wire [RX_DATA_WIDTH - 1:0] data_rx_asynch_i;
	output wire [RX_DC_FIFO_DEPTH - 1:0] cmd_rx_write_token_o;
	input wire [RX_DC_FIFO_DEPTH - 1:0] cmd_rx_read_pointer_i;
	output wire [RX_CMD_WIDTH - 1:0] cmd_rx_asynch_o;
	output wire [4:0] mram_mode_static_o;
	input wire rstn_dcfifo_i;
	output wire mram_clk_o;
	input wire mram_clk_en_i;
	output wire [15:0] mram_erase_addr_o;
	output wire [9:0] mram_erase_size_o;
	wire mram_push_tx_req;
	wire [3:0] mram_irq_enable;
	wire cfg_tx_en_int;
	wire cfg_rx_en_int;
	wire s_clkdiv_valid;
	wire [7:0] s_clkdiv_data;
	wire s_clkdiv_ack;
	wire s_data_tx_valid;
	wire s_data_tx_ready;
	wire [TX_DATA_WIDTH - 1:0] s_data_tx;
	wire [MRAM_ADDR_WIDTH - 1:0] s_cfg_tx_dest_addr;
	wire [TX_CMD_WIDTH - 1:0] s_cmd_tx_data;
	wire s_cmd_tx_valid;
	wire s_cmd_tx_ready;
	wire [RX_DATA_WIDTH - 1:0] s_data_rx_to_ser;
	wire s_data_rx_valid_to_ser;
	wire s_data_rx_ready_from_ser;
	wire [MRAM_ADDR_WIDTH - 1:0] s_cfg_rx_dest_addr;
	wire [RX_CMD_WIDTH - 1:0] s_cmd_rx_data;
	wire s_cmd_rx_valid;
	wire s_cmd_rx_ready;
	wire s_tx_busy_synch;
	wire s_rx_busy_synch;
	wire s_erase_pending_synch;
	wire s_erase_done_synch;
	wire s_trim_cfg_done_synch;
	wire s_tx_done_synch;
	wire s_ref_line_pending_synch;
	wire s_ref_line_done_synch;
	wire [31:0] s_mram_mode;
	wire [3:0] s_mram_event_synch;
	wire s_rstn_dcfifo_sync;
	wire s_clk_mram;
	assign data_tx_datasize_o = 2'b10;
	assign data_rx_datasize_o = 2'b10;
	assign s_mram_event_synch = {s_ref_line_done_synch, s_trim_cfg_done_synch, s_tx_done_synch, s_erase_done_synch};
	assign mram_mode_static_o = {s_mram_mode[7], s_mram_mode[6], s_mram_mode[5], s_mram_mode[1], s_mram_mode[0]};
	rstgen i_mram_dcfifo_rstgen(
		.clk_i(sys_clk_i),
		.test_mode_i(dft_test_mode_i),
		.rst_ni(rstn_dcfifo_i),
		.rst_no(s_rstn_dcfifo_sync),
		.init_no()
	);
	udma_clkgen u_clockgen(
		.clk_i(periph_clk_i),
		.rstn_i(rstn_i),
		.dft_test_mode_i(dft_test_mode_i),
		.dft_cg_enable_i(dft_cg_enable_i),
		.clock_enable_i(1'b1),
		.clk_div_data_i(s_clkdiv_data),
		.clk_div_valid_i(s_clkdiv_valid),
		.clk_div_ack_o(s_clkdiv_ack),
		.clk_o(s_clk_mram)
	);
	pulp_clock_gating_async i_soc_cg(
		.clk_i(s_clk_mram),
		.rstn_i(rstn_i),
		.test_en_i(dft_cg_enable_i),
		.en_async_i(mram_clk_en_i),
		.en_ack_o(),
		.clk_o(mram_clk_o)
	);
	udma_mram_reg_if #(
		.L2_AWIDTH_NOAL(L2_AWIDTH_NOAL),
		.TRANS_SIZE(TRANS_SIZE),
		.MRAM_ADDR_WIDTH(MRAM_ADDR_WIDTH)
	) i_reg_if(
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
		.cfg_rx_dest_addr_o(s_cfg_rx_dest_addr),
		.cfg_rx_continuous_o(cfg_rx_continuous_o),
		.cfg_rx_en_o(cfg_rx_en_int),
		.cfg_rx_clr_o(cfg_rx_clr_o),
		.cfg_rx_en_i(cfg_rx_en_i),
		.cfg_rx_pending_i(cfg_rx_pending_i),
		.cfg_rx_curr_addr_i(cfg_rx_curr_addr_i),
		.cfg_rx_bytes_left_i(cfg_rx_bytes_left_i),
		.cfg_rx_busy_i(s_rx_busy_synch),
		.cfg_tx_startaddr_o(cfg_tx_startaddr_o),
		.cfg_tx_dest_addr_o(s_cfg_tx_dest_addr),
		.cfg_tx_size_o(cfg_tx_size_o),
		.cfg_tx_continuous_o(cfg_tx_continuous_o),
		.cfg_tx_en_o(cfg_tx_en_int),
		.cfg_tx_clr_o(cfg_tx_clr_o),
		.cfg_tx_en_i(cfg_tx_en_i),
		.cfg_tx_pending_i(cfg_tx_pending_i),
		.cfg_tx_curr_addr_i(cfg_tx_curr_addr_i),
		.cfg_tx_bytes_left_i(cfg_tx_bytes_left_i),
		.cfg_tx_busy_i(s_tx_busy_synch),
		.mram_mode_o(s_mram_mode),
		.mram_erase_addr_o(mram_erase_addr_o),
		.mram_erase_size_o(mram_erase_size_o),
		.mram_erase_pending_i(s_erase_pending_synch),
		.mram_ref_line_pending_i(s_ref_line_pending_synch),
		.mram_event_done_i(s_mram_event_synch),
		.mram_rx_ecc_error_i(rx_error_i),
		.cfg_clkdiv_data_o(s_clkdiv_data),
		.cfg_clkdiv_valid_o(s_clkdiv_valid),
		.cfg_clkdiv_ack_i(s_clkdiv_ack),
		.mram_push_tx_req_o(mram_push_tx_req),
		.mram_push_tx_ack_i(1'b1),
		.mram_irq_enable_o(mram_irq_enable)
	);
	io_tx_fifo #(
		.DATA_WIDTH(TX_DATA_WIDTH),
		.BUFFER_DEPTH(4)
	) u_io_tx_fifo(
		.clk_i(sys_clk_i),
		.rstn_i(rstn_i),
		.clr_i(1'b0),
		.req_o(data_tx_req_o),
		.gnt_i(data_tx_gnt_i),
		.data_o(s_data_tx),
		.valid_o(s_data_tx_valid),
		.ready_i(s_data_tx_ready),
		.valid_i(data_tx_valid_i),
		.data_i(data_tx_i),
		.ready_o(data_tx_ready_o)
	);
	assign s_cmd_tx_data = {s_mram_mode[15:8], s_mram_mode[4:2], cfg_tx_size_o, s_cfg_tx_dest_addr};
	assign s_cmd_tx_valid = (cfg_tx_en_int & cfg_tx_en_i) | mram_push_tx_req;
	assign cfg_tx_en_o = cfg_tx_en_int & s_cmd_tx_ready;
	dc_token_ring_fifo_din #(
		.DATA_WIDTH(TX_CMD_WIDTH),
		.BUFFER_DEPTH(TX_DC_FIFO_DEPTH)
	) u_push_cmd_tx_din(
		.clk(sys_clk_i),
		.rstn(s_rstn_dcfifo_sync),
		.data(s_cmd_tx_data),
		.valid(s_cmd_tx_valid),
		.ready(s_cmd_tx_ready),
		.write_token(cmd_tx_write_token_o),
		.read_pointer(cmd_tx_read_pointer_i),
		.data_async(cmd_tx_asynch_o)
	);
	dc_token_ring_fifo_din #(
		.DATA_WIDTH(TX_DATA_WIDTH),
		.BUFFER_DEPTH(TX_DC_FIFO_DEPTH)
	) u_dc_fifo_tx_din(
		.clk(sys_clk_i),
		.rstn(s_rstn_dcfifo_sync),
		.data(s_data_tx),
		.valid(s_data_tx_valid),
		.ready(s_data_tx_ready),
		.write_token(data_tx_write_token_o),
		.read_pointer(data_tx_read_pointer_i),
		.data_async(data_tx_asynch_o)
	);
	RX_serializer u_RX_serializer(
		.sys_clk(sys_clk_i),
		.rst_n(rstn_i),
		.data_rx_rdata_i(s_data_rx_to_ser),
		.data_rx_valid_i(s_data_rx_valid_to_ser),
		.data_rx_ready_o(s_data_rx_ready_from_ser),
		.data_rx_rdata_o(data_rx_o),
		.data_rx_valid_o(data_rx_valid_o),
		.data_rx_ready_i(data_rx_ready_i)
	);
	dc_token_ring_fifo_dout #(
		.DATA_WIDTH(RX_DATA_WIDTH),
		.BUFFER_DEPTH(RX_DC_FIFO_DEPTH)
	) u_dc_fifo_rx_dout(
		.clk(sys_clk_i),
		.rstn(s_rstn_dcfifo_sync),
		.data(s_data_rx_to_ser),
		.valid(s_data_rx_valid_to_ser),
		.ready(s_data_rx_ready_from_ser),
		.write_token(data_rx_write_token_i),
		.read_pointer(data_rx_read_pointer_o),
		.data_async(data_rx_asynch_i)
	);
	assign s_cmd_rx_data = {s_mram_mode[15:8], s_mram_mode[4:2], cfg_rx_size_o, s_cfg_rx_dest_addr};
	assign s_cmd_rx_valid = cfg_rx_en_int & cfg_rx_en_i;
	assign cfg_rx_en_o = cfg_rx_en_int & s_cmd_rx_ready;
	dc_token_ring_fifo_din #(
		.DATA_WIDTH(RX_CMD_WIDTH),
		.BUFFER_DEPTH(RX_DC_FIFO_DEPTH)
	) u_push_cmd_rx_din(
		.clk(sys_clk_i),
		.rstn(s_rstn_dcfifo_sync),
		.data(s_cmd_rx_data),
		.valid(s_cmd_rx_valid),
		.ready(s_cmd_rx_ready),
		.write_token(cmd_rx_write_token_o),
		.read_pointer(cmd_rx_read_pointer_i),
		.data_async(cmd_rx_asynch_o)
	);
	pulp_sync u_pulp_sync_ref_line_done(
		.clk_i(sys_clk_i),
		.rstn_i(rstn_i),
		.serial_i(ref_line_done_i),
		.serial_o(s_ref_line_done_synch)
	);
	pulp_sync u_pulp_sync_ref_line_pending(
		.clk_i(sys_clk_i),
		.rstn_i(rstn_i),
		.serial_i(ref_line_pending_i),
		.serial_o(s_ref_line_pending_synch)
	);
	pulp_sync u_pulp_sync_erase_done(
		.clk_i(sys_clk_i),
		.rstn_i(rstn_i),
		.serial_i(erase_done_i),
		.serial_o(s_erase_done_synch)
	);
	pulp_sync u_pulp_sync_erase_pending(
		.clk_i(sys_clk_i),
		.rstn_i(rstn_i),
		.serial_i(erase_pending_i),
		.serial_o(s_erase_pending_synch)
	);
	pulp_sync u_pulp_sync_trim_cfg_done(
		.clk_i(sys_clk_i),
		.rstn_i(rstn_i),
		.serial_i(trim_cfg_done_i),
		.serial_o(s_trim_cfg_done_synch)
	);
	pulp_sync u_pulp_sync_tx_done(
		.clk_i(sys_clk_i),
		.rstn_i(rstn_i),
		.serial_i(tx_done_i),
		.serial_o(s_tx_done_synch)
	);
	pulp_sync u_pulp_sync_tx_busy(
		.clk_i(sys_clk_i),
		.rstn_i(rstn_i),
		.serial_i(tx_busy_i),
		.serial_o(s_tx_busy_synch)
	);
	pulp_sync u_pulp_sync_rx_busy(
		.clk_i(sys_clk_i),
		.rstn_i(rstn_i),
		.serial_i(rx_busy_i),
		.serial_o(s_rx_busy_synch)
	);
	pulp_sync_wedge erase_done_int_sync(
		.clk_i(sys_clk_i),
		.rstn_i(rstn_i),
		.en_i(1'b1),
		.serial_i(s_erase_done_synch & mram_irq_enable[0]),
		.r_edge_o(erase_done_event_o),
		.f_edge_o(),
		.serial_o()
	);
	pulp_sync_wedge tx_done_int_sync(
		.clk_i(sys_clk_i),
		.rstn_i(rstn_i),
		.en_i(1'b1),
		.serial_i(s_tx_done_synch & mram_irq_enable[1]),
		.r_edge_o(tx_done_event_o),
		.f_edge_o(),
		.serial_o()
	);
	pulp_sync_wedge trm_cfg_done_int_sync(
		.clk_i(sys_clk_i),
		.rstn_i(rstn_i),
		.en_i(1'b1),
		.serial_i(s_trim_cfg_done_synch & mram_irq_enable[2]),
		.r_edge_o(trim_cfg_done_event_o),
		.f_edge_o(),
		.serial_o()
	);
	pulp_sync_wedge ref_line_done_int_sync(
		.clk_i(sys_clk_i),
		.rstn_i(rstn_i),
		.en_i(1'b1),
		.serial_i(s_ref_line_done_synch & mram_irq_enable[3]),
		.r_edge_o(ref_line_done_event_o),
		.f_edge_o(),
		.serial_o()
	);
endmodule
