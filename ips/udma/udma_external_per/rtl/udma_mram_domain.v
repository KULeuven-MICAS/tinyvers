module udma_mram_domain (
	mram_clk_i,
	rstn_i,
	tx_busy_o,
	rx_busy_o,
	tx_done_o,
	rx_error_o,
	trim_cfg_done_o,
	erase_pending_o,
	erase_done_o,
	ref_line_pending_o,
	ref_line_done_o,
	data_tx_write_token_i,
	data_tx_read_pointer_o,
	data_tx_asynch_i,
	cmd_tx_write_token_i,
	cmd_tx_read_pointer_o,
	cmd_tx_asynch_i,
	data_rx_write_token_o,
	data_rx_read_pointer_i,
	data_rx_asynch_o,
	cmd_rx_write_token_i,
	cmd_rx_read_pointer_o,
	cmd_rx_asynch_i,
	mram_mode_static_i,
	mram_erase_addr_i,
	mram_erase_size_i,
	mram_clk_en_o,
	rstn_dcfifo_o,
	dft_test_mode_i,
	VDDA_i,
	VDD_i,
	VREF_i,
	PORb_i,
	RETb_i,
	RSTb_i,
	TRIM_i,
	DPD_i,
	CEb_HIGH_i
);
	parameter TRANS_SIZE = 20;
	parameter MRAM_ADDR_WIDTH = 16;
	parameter TX_CMD_WIDTH = (MRAM_ADDR_WIDTH + TRANS_SIZE) + 11;
	parameter TX_DATA_WIDTH = 32;
	parameter TX_DC_FIFO_DEPTH = 4;
	parameter RX_CMD_WIDTH = (MRAM_ADDR_WIDTH + TRANS_SIZE) + 11;
	parameter RX_DATA_WIDTH = 64;
	parameter RX_DC_FIFO_DEPTH = 4;
	input wire mram_clk_i;
	input wire rstn_i;
	output wire tx_busy_o;
	output wire rx_busy_o;
	output wire tx_done_o;
	output wire [1:0] rx_error_o;
	output wire trim_cfg_done_o;
	output wire erase_pending_o;
	output wire erase_done_o;
	output wire ref_line_pending_o;
	output wire ref_line_done_o;
	input wire [TX_DC_FIFO_DEPTH - 1:0] data_tx_write_token_i;
	output wire [TX_DC_FIFO_DEPTH - 1:0] data_tx_read_pointer_o;
	input wire [TX_DATA_WIDTH - 1:0] data_tx_asynch_i;
	input wire [TX_DC_FIFO_DEPTH - 1:0] cmd_tx_write_token_i;
	output wire [TX_DC_FIFO_DEPTH - 1:0] cmd_tx_read_pointer_o;
	input wire [TX_CMD_WIDTH - 1:0] cmd_tx_asynch_i;
	output wire [RX_DC_FIFO_DEPTH - 1:0] data_rx_write_token_o;
	input wire [RX_DC_FIFO_DEPTH - 1:0] data_rx_read_pointer_i;
	output wire [RX_DATA_WIDTH - 1:0] data_rx_asynch_o;
	input wire [RX_DC_FIFO_DEPTH - 1:0] cmd_rx_write_token_i;
	output wire [RX_DC_FIFO_DEPTH - 1:0] cmd_rx_read_pointer_o;
	input wire [RX_CMD_WIDTH - 1:0] cmd_rx_asynch_i;
	input wire [4:0] mram_mode_static_i;
	input wire [15:0] mram_erase_addr_i;
	input wire [9:0] mram_erase_size_i;
	output wire mram_clk_en_o;
	output wire rstn_dcfifo_o;
	input wire dft_test_mode_i;
	input wire VDDA_i;
	input wire VDD_i;
	input wire VREF_i;
	input wire PORb_i;
	input wire RETb_i;
	input wire RSTb_i;
	input wire TRIM_i;
	input wire DPD_i;
	input wire CEb_HIGH_i;
	wire s_cmd_tx_dc_push_req;
	wire s_cmd_tx_dc_push_gnt;
	wire [TX_CMD_WIDTH - 1:0] s_cmd_tx_dc_push_dat;
	wire [MRAM_ADDR_WIDTH - 1:0] s_cmd_tx_dc_addr;
	wire [TRANS_SIZE - 1:0] s_cmd_tx_dc_size;
	wire [7:0] s_mram_mode_tx;
	wire s_NVR_tx;
	wire s_TMEN_tx;
	wire s_AREF_tx;
	wire s_data_tx_dc_valid;
	wire s_data_tx_dc_ready;
	wire [TX_DATA_WIDTH - 1:0] s_data_tx_dc_wdata;
	wire [RX_CMD_WIDTH - 1:0] s_cmd_rx_dc_push_dat;
	wire s_cmd_rx_dc_push_req;
	wire s_cmd_rx_dc_push_gnt;
	wire [TRANS_SIZE - 1:0] s_cmd_rx_dc_size;
	wire [MRAM_ADDR_WIDTH - 1:0] s_cmd_rx_dc_addr;
	wire [7:0] s_mram_mode_rx;
	wire s_NVR_rx;
	wire s_TMEN_rx;
	wire s_AREF_rx;
	wire s_data_rx_dc_valid;
	wire s_data_rx_dc_ready;
	wire [RX_DATA_WIDTH - 1:0] s_data_rx_dc;
	wire [4:0] s_mram_mode_synch;
	wire [7:0] s_mram_mode_tx_out;
	wire [15:0] mram_waddr;
	wire [77:0] mram_wdata;
	wire mram_wreq;
	wire mram_weot;
	wire mram_wgnt;
	wire [15:0] mram_raddr;
	wire mram_rclk_en;
	wire mram_rreq;
	wire mram_reot;
	wire mram_rgnt;
	wire [RX_DATA_WIDTH - 1:0] mram_rdata;
	wire [1:0] mram_rerror;
	wire mram_NVR_tx;
	wire mram_TMEN_tx;
	wire mram_AREF_tx;
	wire mram_NVR_rx;
	wire mram_TMEN_rx;
	wire mram_AREF_rx;
	wire s_mram_CLK;
	wire s_mram_CEb;
	wire [15:0] s_mram_A;
	wire [77:0] s_mram_DIN;
	wire [77:0] s_mram_DOUT;
	wire s_mram_RDEN;
	wire s_mram_WEb;
	wire s_mram_PROGEN;
	wire s_mram_PROG;
	wire s_mram_ERASE;
	wire s_mram_SCE;
	wire s_mram_CHIP;
	wire s_mram_PEON;
	wire s_mram_PORb;
	wire s_mram_RETb;
	wire s_mram_RSTb;
	wire s_mram_NVR;
	wire s_mram_TMEN;
	wire s_mram_AREF;
	wire s_mram_DPD;
	wire s_mram_ECCBYPS;
	wire s_mram_SHIFT;
	wire s_mram_SUPD;
	wire s_mram_SDI;
	wire s_mram_SCLK;
	wire s_mram_SDO;
	wire s_mram_RDY;
	wire s_mram_DONE;
	wire s_mram_EC;
	wire s_mram_UE;
	wire s_rstn;
	wire s_rstn_sync;
	assign mram_clk_en_o = 1;
	assign s_rstn = rstn_i;
	assign rstn_dcfifo_o = s_rstn;
	assign rx_error_o = mram_rerror;
	assign s_mram_SCE = 1'sb0;
	assign s_mram_PEON = 1'sb0;
	rstgen i_mram_domain_rstgen(
		.clk_i(mram_clk_i),
		.test_mode_i(dft_test_mode_i),
		.rst_ni(s_rstn),
		.rst_no(s_rstn_sync),
		.init_no()
	);
	wire pmu_rst_ctrl_i;
	wire pmu_rst_ack_o;
	rstgen i_mram_rstctrl(
		.clk_i(mram_clk_i),
		.test_mode_i(dft_test_mode_i),
		.rst_ni(pmu_rst_ctrl_i),
		.rst_no(pmu_rst_ack_o),
		.init_no()
	);
	assign {s_mram_mode_tx, s_NVR_tx, s_TMEN_tx, s_AREF_tx, s_cmd_tx_dc_size, s_cmd_tx_dc_addr} = s_cmd_tx_dc_push_dat;
	dc_token_ring_fifo_dout #(
		.DATA_WIDTH(TX_CMD_WIDTH),
		.BUFFER_DEPTH(TX_DC_FIFO_DEPTH)
	) u_push_cmd_tx_dout(
		.clk(mram_clk_i),
		.rstn(s_rstn_sync),
		.data(s_cmd_tx_dc_push_dat),
		.valid(s_cmd_tx_dc_push_req),
		.ready(s_cmd_tx_dc_push_gnt),
		.write_token(cmd_tx_write_token_i),
		.read_pointer(cmd_tx_read_pointer_o),
		.data_async(cmd_tx_asynch_i)
	);
	dc_token_ring_fifo_dout #(
		.DATA_WIDTH(TX_DATA_WIDTH),
		.BUFFER_DEPTH(TX_DC_FIFO_DEPTH)
	) u_dc_fifo_tx_dout(
		.clk(mram_clk_i),
		.rstn(s_rstn_sync),
		.data(s_data_tx_dc_wdata),
		.valid(s_data_tx_dc_valid),
		.ready(s_data_tx_dc_ready),
		.write_token(data_tx_write_token_i),
		.read_pointer(data_tx_read_pointer_o),
		.data_async(data_tx_asynch_i)
	);
	dc_token_ring_fifo_din #(
		.DATA_WIDTH(RX_DATA_WIDTH),
		.BUFFER_DEPTH(RX_DC_FIFO_DEPTH)
	) u_dc_fifo_rx_din(
		.clk(mram_clk_i),
		.rstn(s_rstn_sync),
		.data(s_data_rx_dc),
		.valid(s_data_rx_dc_valid),
		.ready(s_data_rx_dc_ready),
		.write_token(data_rx_write_token_o),
		.read_pointer(data_rx_read_pointer_i),
		.data_async(data_rx_asynch_o)
	);
	assign {s_mram_mode_rx, s_NVR_rx, s_TMEN_rx, s_AREF_rx, s_cmd_rx_dc_size, s_cmd_rx_dc_addr} = s_cmd_rx_dc_push_dat;
	dc_token_ring_fifo_dout #(
		.DATA_WIDTH(RX_CMD_WIDTH),
		.BUFFER_DEPTH(RX_DC_FIFO_DEPTH)
	) u_push_cmd_rx_dout(
		.clk(mram_clk_i),
		.rstn(s_rstn_sync),
		.data(s_cmd_rx_dc_push_dat),
		.valid(s_cmd_rx_dc_push_req),
		.ready(s_cmd_rx_dc_push_gnt),
		.write_token(cmd_rx_write_token_i),
		.read_pointer(cmd_rx_read_pointer_o),
		.data_async(cmd_rx_asynch_i)
	);
	genvar i;
	generate
		for (i = 0; i < 5; i = i + 1) begin : synch_mram_mode
			pulp_sync u_pulp_sync(
				.clk_i(mram_clk_i),
				.rstn_i(s_rstn_sync),
				.serial_i(mram_mode_static_i[i]),
				.serial_o(s_mram_mode_synch[i])
			);
		end
	endgenerate
	assign s_mram_PORb = s_mram_mode_synch[4];
	assign s_mram_RETb = s_mram_mode_synch[3];
	assign s_mram_RSTb = s_mram_mode_synch[2];
	assign s_mram_DPD = s_mram_mode_synch[1];
	assign s_mram_ECCBYPS = s_mram_mode_synch[0];
	size_conv_TX_32_to_64 #(.TRANS_SIZE(TRANS_SIZE)) u_size_conv_TX_32_to_64(
		.clk(mram_clk_i),
		.rst_n(s_rstn_sync),
		.data_tx_wdata_i(s_data_tx_dc_wdata),
		.data_tx_valid_i(s_data_tx_dc_valid),
		.data_tx_ready_o(s_data_tx_dc_ready),
		.push_cmd_req_i(s_cmd_tx_dc_push_req),
		.push_cmd_gnt_o(s_cmd_tx_dc_push_gnt),
		.data_tx_addr_i(s_cmd_tx_dc_addr),
		.data_tx_size_i(s_cmd_tx_dc_size),
		.erase_addr_i(mram_erase_addr_i),
		.erase_size_i(mram_erase_size_i),
		.pending_o(tx_busy_o),
		.tx_done_o(tx_done_o),
		.trim_cfg_done_o(trim_cfg_done_o),
		.erase_done_o(erase_done_o),
		.erase_pending_o(erase_pending_o),
		.ref_line_pending_o(ref_line_pending_o),
		.ref_line_done_o(ref_line_done_o),
		.mram_mode_i(s_mram_mode_tx),
		.mram_mode_o(s_mram_mode_tx_out),
		.data_tx_wdata_o(mram_wdata),
		.data_tx_addr_o(mram_waddr),
		.data_tx_req_o(mram_wreq),
		.data_tx_eot_o(mram_weot),
		.data_tx_gnt_i(mram_wgnt),
		.NVR_i(s_NVR_tx),
		.TMEN_i(s_TMEN_tx),
		.AREF_i(s_AREF_tx),
		.mram_NVR_o(mram_NVR_tx),
		.mram_TMEN_o(mram_TMEN_tx),
		.mram_AREF_o(mram_AREF_tx),
		.mram_SHIFT_o(s_mram_SHIFT),
		.mram_SUPD_o(s_mram_SUPD),
		.mram_SDI_o(s_mram_SDI),
		.mram_SCLK_o(s_mram_SCLK),
		.mram_SDO_i(s_mram_SDO)
	);
	size_conv_RX_64_to_32 #(.TRANS_SIZE(TRANS_SIZE)) u_size_conv_RX_32_to_64(
		.clk(mram_clk_i),
		.rst_n(s_rstn_sync),
		.push_cmd_req_i(s_cmd_rx_dc_push_req),
		.push_cmd_gnt_o(s_cmd_rx_dc_push_gnt),
		.data_rx_addr_i(s_cmd_rx_dc_addr),
		.data_rx_size_i(s_cmd_rx_dc_size),
		.data_rx_raddr_o(mram_raddr),
		.data_rx_clk_en_o(mram_rclk_en),
		.data_rx_req_o(mram_rreq),
		.data_rx_eot_o(mram_reot),
		.data_rx_gnt_i(mram_rgnt),
		.mram_mode_i(s_mram_mode_rx),
		.NVR_i(s_NVR_rx),
		.TMEN_i(s_TMEN_rx),
		.AREF_i(s_AREF_rx),
		.mram_NVR_o(mram_NVR_rx),
		.mram_TMEN_o(mram_TMEN_rx),
		.mram_AREF_o(mram_AREF_rx),
		.data_rx_rdata_i(mram_rdata),
		.pending_o(rx_busy_o),
		.data_rx_rdata_o(s_data_rx_dc),
		.data_rx_valid_o(s_data_rx_dc_valid),
		.data_rx_ready_i(s_data_rx_dc_ready)
	);
	TX_RX_to_MRAM i_TX_RX_to_MRAM(
		.clk(mram_clk_i),
		.rst_n(s_rstn_sync),
		.scan_en_in(dft_test_mode_i),
		.mram_mode_tx_i(s_mram_mode_tx_out),
		.data_tx_wdata_i(mram_wdata),
		.data_tx_addr_i(mram_waddr),
		.data_tx_req_i(mram_wreq),
		.data_tx_eot_i(mram_weot),
		.data_tx_gnt_o(mram_wgnt),
		.NVR_tx_i(mram_NVR_tx),
		.TMEN_tx_i(mram_TMEN_tx),
		.AREF_tx_i(mram_AREF_tx),
		.mram_mode_rx_i(s_mram_mode_rx),
		.data_rx_raddr_i(mram_raddr),
		.data_rx_clk_en_i(mram_rclk_en),
		.data_rx_req_i(mram_rreq),
		.data_rx_eot_i(mram_reot),
		.data_rx_gnt_o(mram_rgnt),
		.data_rx_rdata_o(mram_rdata),
		.data_rx_error_o(mram_rerror),
		.NVR_rx_i(mram_NVR_rx),
		.TMEN_rx_i(mram_TMEN_rx),
		.AREF_rx_i(mram_AREF_rx),
		.CEb_o(s_mram_CEb),
		.A_o(s_mram_A),
		.DIN_o(s_mram_DIN),
		.RDEN_o(s_mram_RDEN),
		.WEb_o(s_mram_WEb),
		.PROGEN_o(s_mram_PROGEN),
		.PROG_o(s_mram_PROG),
		.ERASE_o(s_mram_ERASE),
		.CHIP_o(s_mram_CHIP),
		.DONE_i(s_mram_DONE),
		.DOUT_i(s_mram_DOUT),
		.CLK_o(s_mram_CLK),
		.EC_i(s_mram_EC),
		.UE_i(s_mram_UE),
		.NVR_o(s_mram_NVR),
		.TMEN_o(s_mram_TMEN),
		.AREF_o(s_mram_AREF)
	);
	supply1 VREF;
	supply1 VPR;
	supply1 VDDA;
	supply1 VDD_cfg;
	supply1 VDD;
	supply0 VSS;
	initial force i_MRAM_eFLASH_64Kx78.cr_lat = 1'sb0;
	MRAM_eFLASH_64Kx78 i_MRAM_eFLASH_64Kx78(
		.CLK(s_mram_CLK),
		.CEb(s_mram_CEb || CEb_HIGH_i),
		.A(s_mram_A),
		.DIN(s_mram_DIN),
		.RDEN(s_mram_RDEN),
		.WEb(s_mram_WEb),
		.PROGEN(s_mram_PROGEN),
		.PROG(s_mram_PROG),
		.ERASE(s_mram_ERASE),
		.SCE(s_mram_SCE),
		.CHIP(s_mram_CHIP),
		.PEON(s_mram_PEON),
		.DONE(s_mram_DONE),
		.RDY(s_mram_RDY),
		.DOUT(s_mram_DOUT),
		.TMEN(s_mram_TMEN),
		.NVR(s_mram_NVR),
		.PORb(s_mram_PORb || PORb_i),
		.RSTb(s_mram_RSTb || RSTb_i),
		.RETb(s_mram_RETb || RETb_i),
		.DPD(s_mram_DPD || DPD_i),
		.SHIFT(s_mram_SHIFT),
		.SUPD(s_mram_SUPD),
		.SDI(s_mram_SDI),
		.SCLK(s_mram_SCLK),
		.SDO(s_mram_SDO),
		.EC(s_mram_EC),
		.UE(s_mram_UE),
		.ECCBYPS(s_mram_ECCBYPS),
		.VREF(VREF_i),
		.VPR(VPR),
		.VDDA(VDDA_i),
		.VDD_cfg(VDD_cfg),
		.VDD(VDD_i),
		.VSS(VSS),
		.TMO()
	);
endmodule
