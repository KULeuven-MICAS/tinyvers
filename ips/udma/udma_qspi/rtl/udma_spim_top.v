module udma_spim_top (
	sys_clk_i,
	periph_clk_i,
	rstn_i,
	dft_test_mode_i,
	dft_cg_enable_i,
	spi_eot_o,
	spi_event_i,
	cfg_data_i,
	cfg_addr_i,
	cfg_valid_i,
	cfg_rwn_i,
	cfg_data_o,
	cfg_ready_o,
	cfg_cmd_startaddr_o,
	cfg_cmd_size_o,
	cfg_cmd_continuous_o,
	cfg_cmd_en_o,
	cfg_cmd_clr_o,
	cfg_cmd_en_i,
	cfg_cmd_pending_i,
	cfg_cmd_curr_addr_i,
	cfg_cmd_bytes_left_i,
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
	cmd_req_o,
	cmd_gnt_i,
	cmd_datasize_o,
	cmd_i,
	cmd_valid_i,
	cmd_ready_o,
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
	spi_clk_o,
	spi_csn0_o,
	spi_csn1_o,
	spi_csn2_o,
	spi_csn3_o,
	spi_oen0_o,
	spi_oen1_o,
	spi_oen2_o,
	spi_oen3_o,
	spi_sdo0_o,
	spi_sdo1_o,
	spi_sdo2_o,
	spi_sdo3_o,
	spi_sdi0_i,
	spi_sdi1_i,
	spi_sdi2_i,
	spi_sdi3_i
);
	parameter L2_AWIDTH_NOAL = 12;
	parameter TRANS_SIZE = 16;
	parameter REPLAY_BUFFER_DEPTH = 6;
	input wire sys_clk_i;
	input wire periph_clk_i;
	input wire rstn_i;
	input wire dft_test_mode_i;
	input wire dft_cg_enable_i;
	output wire spi_eot_o;
	input wire [3:0] spi_event_i;
	input wire [31:0] cfg_data_i;
	input wire [4:0] cfg_addr_i;
	input wire cfg_valid_i;
	input wire cfg_rwn_i;
	output wire [31:0] cfg_data_o;
	output wire cfg_ready_o;
	output wire [L2_AWIDTH_NOAL - 1:0] cfg_cmd_startaddr_o;
	output wire [TRANS_SIZE - 1:0] cfg_cmd_size_o;
	output wire cfg_cmd_continuous_o;
	output wire cfg_cmd_en_o;
	output wire cfg_cmd_clr_o;
	input wire cfg_cmd_en_i;
	input wire cfg_cmd_pending_i;
	input wire [L2_AWIDTH_NOAL - 1:0] cfg_cmd_curr_addr_i;
	input wire [TRANS_SIZE - 1:0] cfg_cmd_bytes_left_i;
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
	output wire cmd_req_o;
	input wire cmd_gnt_i;
	output wire [1:0] cmd_datasize_o;
	input wire [31:0] cmd_i;
	input wire cmd_valid_i;
	output wire cmd_ready_o;
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
	output wire spi_clk_o;
	output wire spi_csn0_o;
	output wire spi_csn1_o;
	output wire spi_csn2_o;
	output wire spi_csn3_o;
	output wire spi_oen0_o;
	output wire spi_oen1_o;
	output wire spi_oen2_o;
	output wire spi_oen3_o;
	output wire spi_sdo0_o;
	output wire spi_sdo1_o;
	output wire spi_sdo2_o;
	output wire spi_sdo3_o;
	input wire spi_sdi0_i;
	input wire spi_sdi1_i;
	input wire spi_sdi2_i;
	input wire spi_sdi3_i;
	localparam BUFFER_WIDTH = 8;
	wire [1:0] s_status;
	wire s_tx_start;
	wire [15:0] s_tx_size;
	wire s_tx_qpi;
	wire s_tx_done;
	wire [31:0] s_tx_data;
	wire s_tx_data_valid;
	wire s_tx_data_ready;
	wire s_rx_start;
	wire [15:0] s_rx_size;
	wire s_rx_qpi;
	wire s_rx_done;
	wire [31:0] s_rx_data;
	wire s_rx_data_valid;
	wire s_rx_data_ready;
	wire [31:0] s_udma_rx_data;
	wire s_udma_rx_data_valid;
	wire s_udma_rx_data_ready;
	wire [31:0] s_udma_tx_data;
	wire s_udma_tx_data_valid;
	wire s_udma_tx_data_ready;
	wire [31:0] s_spi_data_tx;
	wire s_spi_data_tx_valid;
	wire s_spi_data_tx_ready;
	wire [31:0] s_udma_cmd;
	wire s_udma_cmd_valid;
	wire s_udma_cmd_ready;
	wire [31:0] s_spi_cmd;
	wire s_spi_cmd_valid;
	wire s_spi_cmd_ready;
	wire [7:0] s_clkdiv_data;
	wire s_clkdiv_valid;
	wire s_clkdiv_ack;
	wire s_clkdiv_en;
	wire [3:0] s_events;
	wire s_clk_spi;
	wire s_spi_eot;
	wire s_cfg_cpol;
	wire s_cfg_cpha;
	wire s_tx_customsize;
	wire s_rx_customsize;
	wire [4:0] s_tx_bitsword;
	wire [1:0] s_tx_wordtransf;
	wire s_tx_lsbfirst;
	wire [4:0] s_rx_bitsword;
	wire [1:0] s_rx_wordtransf;
	wire s_rx_lsbfirst;
	assign s_clkdiv_en = 1'b1;
	genvar i;
	generate
		for (i = 0; i < 4; i = i + 1) begin : genblk1
			edge_propagator u_eot_ep(
				.clk_tx_i(sys_clk_i),
				.rstn_tx_i(rstn_i),
				.edge_i(spi_event_i[i]),
				.clk_rx_i(s_clk_spi),
				.rstn_rx_i(rstn_i),
				.edge_o(s_events[i])
			);
		end
	endgenerate
	udma_spim_reg_if #(
		.L2_AWIDTH_NOAL(L2_AWIDTH_NOAL),
		.TRANS_SIZE(TRANS_SIZE)
	) u_reg_if(
		.clk_i(sys_clk_i),
		.rstn_i(rstn_i),
		.status_i(s_status),
		.cfg_data_i(cfg_data_i),
		.cfg_addr_i(cfg_addr_i),
		.cfg_valid_i(cfg_valid_i),
		.cfg_rwn_i(cfg_rwn_i),
		.cfg_ready_o(cfg_ready_o),
		.cfg_data_o(cfg_data_o),
		.cfg_cmd_startaddr_o(cfg_cmd_startaddr_o),
		.cfg_cmd_size_o(cfg_cmd_size_o),
		.cfg_cmd_datasize_o(cmd_datasize_o),
		.cfg_cmd_continuous_o(cfg_cmd_continuous_o),
		.cfg_cmd_en_o(cfg_cmd_en_o),
		.cfg_cmd_clr_o(cfg_cmd_clr_o),
		.cfg_cmd_en_i(cfg_cmd_en_i),
		.cfg_cmd_pending_i(cfg_cmd_pending_i),
		.cfg_cmd_curr_addr_i(cfg_cmd_curr_addr_i),
		.cfg_cmd_bytes_left_i(cfg_cmd_bytes_left_i),
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
		.udma_cmd_i(s_spi_cmd),
		.udma_cmd_valid_i(s_spi_cmd_valid),
		.udma_cmd_ready_i(s_spi_cmd_ready)
	);
	udma_clkgen u_clockgen(
		.clk_i(periph_clk_i),
		.rstn_i(rstn_i),
		.dft_test_mode_i(dft_test_mode_i),
		.dft_cg_enable_i(dft_cg_enable_i),
		.clock_enable_i(s_clkdiv_en),
		.clk_div_data_i(s_clkdiv_data),
		.clk_div_valid_i(s_clkdiv_valid),
		.clk_div_ack_o(s_clkdiv_ack),
		.clk_o(s_clk_spi)
	);
	udma_dc_fifo #(
		32,
		BUFFER_WIDTH
	) u_dc_cmd(
		.dst_clk_i(s_clk_spi),
		.dst_rstn_i(rstn_i),
		.dst_data_o(s_udma_cmd),
		.dst_valid_o(s_udma_cmd_valid),
		.dst_ready_i(s_udma_cmd_ready),
		.src_clk_i(sys_clk_i),
		.src_rstn_i(rstn_i),
		.src_data_i(s_spi_cmd),
		.src_valid_i(s_spi_cmd_valid),
		.src_ready_o(s_spi_cmd_ready)
	);
	io_tx_fifo #(
		.DATA_WIDTH(32),
		.BUFFER_DEPTH(2)
	) u_cmd_fifo(
		.clk_i(sys_clk_i),
		.rstn_i(rstn_i),
		.clr_i(1'b0),
		.data_o(s_spi_cmd),
		.valid_o(s_spi_cmd_valid),
		.ready_i(s_spi_cmd_ready),
		.req_o(cmd_req_o),
		.gnt_i(cmd_gnt_i),
		.valid_i(cmd_valid_i),
		.data_i(cmd_i),
		.ready_o(cmd_ready_o)
	);
	udma_dc_fifo #(
		32,
		BUFFER_WIDTH
	) u_dc_tx(
		.dst_clk_i(s_clk_spi),
		.dst_rstn_i(rstn_i),
		.dst_data_o(s_udma_tx_data),
		.dst_valid_o(s_udma_tx_data_valid),
		.dst_ready_i(s_udma_tx_data_ready),
		.src_clk_i(sys_clk_i),
		.src_rstn_i(rstn_i),
		.src_data_i(s_spi_data_tx),
		.src_valid_i(s_spi_data_tx_valid),
		.src_ready_o(s_spi_data_tx_ready)
	);
	io_tx_fifo #(
		.DATA_WIDTH(32),
		.BUFFER_DEPTH(2)
	) u_fifo(
		.clk_i(sys_clk_i),
		.rstn_i(rstn_i),
		.clr_i(1'b0),
		.data_o(s_spi_data_tx),
		.valid_o(s_spi_data_tx_valid),
		.ready_i(s_spi_data_tx_ready),
		.req_o(data_tx_req_o),
		.gnt_i(data_tx_gnt_i),
		.valid_i(data_tx_valid_i),
		.data_i(data_tx_i),
		.ready_o(data_tx_ready_o)
	);
	udma_dc_fifo #(
		32,
		BUFFER_WIDTH
	) u_dc_rx(
		.dst_clk_i(sys_clk_i),
		.dst_rstn_i(rstn_i),
		.dst_data_o(data_rx_o),
		.dst_valid_o(data_rx_valid_o),
		.dst_ready_i(data_rx_ready_i),
		.src_clk_i(s_clk_spi),
		.src_rstn_i(rstn_i),
		.src_data_i(s_udma_rx_data),
		.src_valid_i(s_udma_rx_data_valid),
		.src_ready_o(s_udma_rx_data_ready)
	);
	udma_spim_ctrl #(.REPLAY_BUFFER_DEPTH(REPLAY_BUFFER_DEPTH)) u_spictrl(
		.clk_i(s_clk_spi),
		.rstn_i(rstn_i),
		.eot_o(s_spi_eot),
		.event_i(s_events),
		.status_o(s_status),
		.cfg_cpol_o(s_cfg_cpol),
		.cfg_cpha_o(s_cfg_cpha),
		.cfg_clkdiv_data_o(s_clkdiv_data),
		.cfg_clkdiv_valid_o(s_clkdiv_valid),
		.cfg_clkdiv_ack_i(s_clkdiv_ack),
		.tx_start_o(s_tx_start),
		.tx_size_o(s_tx_size),
		.tx_qpi_o(s_tx_qpi),
		.tx_bitsword_o(s_tx_bitsword),
		.tx_wordtransf_o(s_tx_wordtransf),
		.tx_lsbfirst_o(s_tx_lsbfirst),
		.tx_done_i(s_tx_done),
		.tx_data_o(s_tx_data),
		.tx_data_valid_o(s_tx_data_valid),
		.tx_data_ready_i(s_tx_data_ready),
		.rx_start_o(s_rx_start),
		.rx_size_o(s_rx_size),
		.rx_bitsword_o(s_rx_bitsword),
		.rx_wordtransf_o(s_rx_wordtransf),
		.rx_lsbfirst_o(s_rx_lsbfirst),
		.rx_qpi_o(s_rx_qpi),
		.rx_done_i(s_rx_done),
		.rx_data_i(s_rx_data),
		.rx_data_valid_i(s_rx_data_valid),
		.rx_data_ready_o(s_rx_data_ready),
		.udma_cmd_i(s_udma_cmd),
		.udma_cmd_valid_i(s_udma_cmd_valid),
		.udma_cmd_ready_o(s_udma_cmd_ready),
		.udma_tx_data_i(s_udma_tx_data),
		.udma_tx_data_valid_i(s_udma_tx_data_valid),
		.udma_tx_data_ready_o(s_udma_tx_data_ready),
		.udma_rx_data_o(s_udma_rx_data),
		.udma_rx_data_valid_o(s_udma_rx_data_valid),
		.udma_rx_data_ready_i(s_udma_rx_data_ready),
		.spi_csn0_o(spi_csn0_o),
		.spi_csn1_o(spi_csn1_o),
		.spi_csn2_o(spi_csn2_o),
		.spi_csn3_o(spi_csn3_o)
	);
	udma_spim_txrx u_txrx(
		.clk_i(s_clk_spi),
		.rstn_i(rstn_i),
		.cfg_cpol_i(s_cfg_cpol),
		.cfg_cpha_i(s_cfg_cpha),
		.tx_start_i(s_tx_start),
		.tx_size_i(s_tx_size),
		.tx_bitsword_i(s_tx_bitsword),
		.tx_wordtransf_i(s_tx_wordtransf),
		.tx_lsbfirst_i(s_tx_lsbfirst),
		.tx_qpi_i(s_tx_qpi),
		.tx_done_o(s_tx_done),
		.tx_data_i(s_tx_data),
		.tx_data_valid_i(s_tx_data_valid),
		.tx_data_ready_o(s_tx_data_ready),
		.rx_start_i(s_rx_start),
		.rx_size_i(s_rx_size),
		.rx_bitsword_i(s_rx_bitsword),
		.rx_wordtransf_i(s_rx_wordtransf),
		.rx_lsbfirst_i(s_rx_lsbfirst),
		.rx_qpi_i(s_rx_qpi),
		.rx_done_o(s_rx_done),
		.rx_data_o(s_rx_data),
		.rx_data_valid_o(s_rx_data_valid),
		.rx_data_ready_i(s_rx_data_ready),
		.spi_clk_o(spi_clk_o),
		.spi_oen0_o(spi_oen0_o),
		.spi_oen1_o(spi_oen1_o),
		.spi_oen2_o(spi_oen2_o),
		.spi_oen3_o(spi_oen3_o),
		.spi_sdo0_o(spi_sdo0_o),
		.spi_sdo1_o(spi_sdo1_o),
		.spi_sdo2_o(spi_sdo2_o),
		.spi_sdo3_o(spi_sdo3_o),
		.spi_sdi0_i(spi_sdi0_i),
		.spi_sdi1_i(spi_sdi1_i),
		.spi_sdi2_i(spi_sdi2_i),
		.spi_sdi3_i(spi_sdi3_i)
	);
	edge_propagator u_eot_ep(
		.clk_tx_i(s_clk_spi),
		.rstn_tx_i(rstn_i),
		.edge_i(s_spi_eot),
		.clk_rx_i(sys_clk_i),
		.rstn_rx_i(rstn_i),
		.edge_o(spi_eot_o)
	);
endmodule
