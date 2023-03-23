module udma_subsystem (
	L2_ro_wen_o,
	L2_ro_req_o,
	L2_ro_gnt_i,
	L2_ro_addr_o,
	L2_ro_be_o,
	L2_ro_wdata_o,
	L2_ro_rvalid_i,
	L2_ro_rdata_i,
	L2_wo_wen_o,
	L2_wo_req_o,
	L2_wo_gnt_i,
	L2_wo_addr_o,
	L2_wo_wdata_o,
	L2_wo_be_o,
	L2_wo_rvalid_i,
	L2_wo_rdata_i,
	dft_test_mode_i,
	dft_cg_enable_i,
	sys_clk_i,
	sys_resetn_i,
	periph_clk_i,
	udma_apb_paddr,
	udma_apb_pwdata,
	udma_apb_pwrite,
	udma_apb_psel,
	udma_apb_penable,
	udma_apb_prdata,
	udma_apb_pready,
	udma_apb_pslverr,
	events_o,
	event_valid_i,
	event_data_i,
	event_ready_o,
	spi_clk,
	spi_csn,
	spi_oen,
	spi_sdo,
	spi_sdi,
	i2c_scl_i,
	i2c_scl_o,
	i2c_scl_oe,
	i2c_sda_i,
	i2c_sda_o,
	i2c_sda_oe,
	cam_clk_i,
	cam_data_i,
	cam_hsync_i,
	cam_vsync_i,
	uart_rx_i,
	uart_tx_o,
	sdio_clk_o,
	sdio_cmd_o,
	sdio_cmd_i,
	sdio_cmd_oen_o,
	sdio_data_o,
	sdio_data_i,
	sdio_data_oen_o,
	i2s_slave_sd0_i,
	i2s_slave_sd1_i,
	i2s_slave_ws_i,
	i2s_slave_ws_o,
	i2s_slave_ws_oe,
	i2s_slave_sck_i,
	i2s_slave_sck_o,
	i2s_slave_sck_oe,
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
	parameter L2_DATA_WIDTH = 32;
	parameter L2_ADDR_WIDTH = 19;
	parameter CAM_DATA_WIDTH = 8;
	parameter APB_ADDR_WIDTH = 12;
	parameter TRANS_SIZE = 20;
	parameter N_SPI = 4;
	parameter N_UART = 4;
	parameter N_I2C = 1;
	output wire L2_ro_wen_o;
	output wire L2_ro_req_o;
	input wire L2_ro_gnt_i;
	output wire [31:0] L2_ro_addr_o;
	output wire [(L2_DATA_WIDTH / 8) - 1:0] L2_ro_be_o;
	output wire [L2_DATA_WIDTH - 1:0] L2_ro_wdata_o;
	input wire L2_ro_rvalid_i;
	input wire [L2_DATA_WIDTH - 1:0] L2_ro_rdata_i;
	output wire L2_wo_wen_o;
	output wire L2_wo_req_o;
	input wire L2_wo_gnt_i;
	output wire [31:0] L2_wo_addr_o;
	output wire [L2_DATA_WIDTH - 1:0] L2_wo_wdata_o;
	output wire [(L2_DATA_WIDTH / 8) - 1:0] L2_wo_be_o;
	input wire L2_wo_rvalid_i;
	input wire [L2_DATA_WIDTH - 1:0] L2_wo_rdata_i;
	input wire dft_test_mode_i;
	input wire dft_cg_enable_i;
	input wire sys_clk_i;
	input wire sys_resetn_i;
	input wire periph_clk_i;
	input wire [APB_ADDR_WIDTH - 1:0] udma_apb_paddr;
	input wire [31:0] udma_apb_pwdata;
	input wire udma_apb_pwrite;
	input wire udma_apb_psel;
	input wire udma_apb_penable;
	output wire [31:0] udma_apb_prdata;
	output wire udma_apb_pready;
	output wire udma_apb_pslverr;
	output wire [127:0] events_o;
	input wire event_valid_i;
	input wire [7:0] event_data_i;
	output wire event_ready_o;
	output wire [N_SPI - 1:0] spi_clk;
	output wire [(N_SPI * 4) - 1:0] spi_csn;
	output wire [(N_SPI * 4) - 1:0] spi_oen;
	output wire [(N_SPI * 4) - 1:0] spi_sdo;
	input wire [(N_SPI * 4) - 1:0] spi_sdi;
	input wire [N_I2C - 1:0] i2c_scl_i;
	output wire [N_I2C - 1:0] i2c_scl_o;
	output wire [N_I2C - 1:0] i2c_scl_oe;
	input wire [N_I2C - 1:0] i2c_sda_i;
	output wire [N_I2C - 1:0] i2c_sda_o;
	output wire [N_I2C - 1:0] i2c_sda_oe;
	input wire cam_clk_i;
	input wire [CAM_DATA_WIDTH - 1:0] cam_data_i;
	input wire cam_hsync_i;
	input wire cam_vsync_i;
	input wire [N_UART - 1:0] uart_rx_i;
	output wire [N_UART - 1:0] uart_tx_o;
	output wire sdio_clk_o;
	output wire sdio_cmd_o;
	input wire sdio_cmd_i;
	output wire sdio_cmd_oen_o;
	output wire [3:0] sdio_data_o;
	input wire [3:0] sdio_data_i;
	output wire [3:0] sdio_data_oen_o;
	input wire i2s_slave_sd0_i;
	input wire i2s_slave_sd1_i;
	input wire i2s_slave_ws_i;
	output wire i2s_slave_ws_o;
	output wire i2s_slave_ws_oe;
	input wire i2s_slave_sck_i;
	output wire i2s_slave_sck_o;
	output wire i2s_slave_sck_oe;
	input wire VDDA_i;
	input wire VDD_i;
	input wire VREF_i;
	input wire PORb_i;
	input wire RETb_i;
	input wire RSTb_i;
	input wire TRIM_i;
	input wire DPD_i;
	input wire CEb_HIGH_i;
	localparam DEST_SIZE = 2;
	localparam L2_AWIDTH_NOAL = L2_ADDR_WIDTH + 2;
	localparam N_I2S = 1;
	localparam N_CAM = 1;
	localparam N_CSI2 = 0;
	localparam N_HYPER = 0;
	localparam N_SDIO = 1;
	localparam N_JTAG = 0;
	localparam N_MRAM = 1;
	localparam N_FILTER = 1;
	localparam N_FPGA = 0;
	localparam N_RX_CHANNELS = (((((((((N_SPI + N_HYPER) + N_MRAM) + N_JTAG) + N_SDIO) + N_UART) + N_I2C) + N_I2S) + N_CAM) + 0) + N_FPGA;
	localparam N_TX_CHANNELS = ((((((((2 * N_SPI) + N_HYPER) + N_MRAM) + N_JTAG) + N_SDIO) + N_UART) + N_I2C) + N_I2S) + N_FPGA;
	localparam N_RX_EXT_CHANNELS = N_FILTER;
	localparam N_TX_EXT_CHANNELS = 2;
	localparam N_STREAMS = N_FILTER;
	localparam STREAM_ID_WIDTH = 1;
	localparam N_PERIPHS = ((((((((((N_SPI + N_HYPER) + N_UART) + N_MRAM) + N_I2C) + N_CAM) + N_I2S) + N_CSI2) + N_SDIO) + N_JTAG) + N_FILTER) + N_FPGA;
	localparam CH_ID_TX_UART = 0;
	localparam CH_ID_TX_SPIM = N_UART;
	localparam CH_ID_CMD_SPIM = N_SPI + N_UART;
	localparam CH_ID_TX_I2C = (N_SPI * 2) + +N_UART;
	localparam CH_ID_TX_SDIO = ((N_SPI * 2) + N_UART) + N_I2C;
	localparam CH_ID_TX_I2S = CH_ID_TX_SDIO + 1;
	localparam CH_ID_TX_MRAM = CH_ID_TX_I2S + 1;
	localparam CH_ID_RX_UART = 0;
	localparam CH_ID_RX_SPIM = N_UART;
	localparam CH_ID_RX_I2C = N_SPI + N_UART;
	localparam CH_ID_RX_SDIO = (N_SPI + N_UART) + N_I2C;
	localparam CH_ID_RX_I2S = CH_ID_RX_SDIO + 1;
	localparam CH_ID_RX_CAM = CH_ID_RX_I2S + 1;
	localparam CH_ID_RX_MRAM = CH_ID_RX_CAM + 1;
	localparam PER_ID_UART = 0;
	localparam PER_ID_SPIM = 1;
	localparam PER_ID_I2C = N_SPI + N_UART;
	localparam PER_ID_SDIO = (N_SPI + N_UART) + N_I2C;
	localparam PER_ID_I2S = PER_ID_SDIO + 1;
	localparam PER_ID_CAM = PER_ID_I2S + 1;
	localparam PER_ID_FILTER = PER_ID_CAM + 1;
	localparam PER_ID_MRAM = PER_ID_FILTER + 1;
	localparam CH_ID_EXT_TX_FILTER = 0;
	localparam CH_ID_EXT_RX_FILTER = 0;
	localparam STREAM_ID_FILTER = 0;
	wire [(N_TX_CHANNELS * L2_AWIDTH_NOAL) - 1:0] s_tx_cfg_startaddr;
	wire [(N_TX_CHANNELS * TRANS_SIZE) - 1:0] s_tx_cfg_size;
	wire [N_TX_CHANNELS - 1:0] s_tx_cfg_continuous;
	wire [N_TX_CHANNELS - 1:0] s_tx_cfg_en;
	wire [N_TX_CHANNELS - 1:0] s_tx_cfg_clr;
	wire [N_TX_CHANNELS - 1:0] s_tx_ch_req;
	wire [N_TX_CHANNELS - 1:0] s_tx_ch_gnt;
	wire [(N_TX_CHANNELS * 32) - 1:0] s_tx_ch_data;
	wire [N_TX_CHANNELS - 1:0] s_tx_ch_valid;
	wire [N_TX_CHANNELS - 1:0] s_tx_ch_ready;
	wire [(N_TX_CHANNELS * 2) - 1:0] s_tx_ch_datasize;
	wire [(N_TX_CHANNELS * 2) - 1:0] s_tx_ch_destination;
	wire [N_TX_CHANNELS - 1:0] s_tx_ch_events;
	wire [N_TX_CHANNELS - 1:0] s_tx_ch_en;
	wire [N_TX_CHANNELS - 1:0] s_tx_ch_pending;
	wire [(N_TX_CHANNELS * L2_AWIDTH_NOAL) - 1:0] s_tx_ch_curr_addr;
	wire [(N_TX_CHANNELS * TRANS_SIZE) - 1:0] s_tx_ch_bytes_left;
	wire [(N_RX_CHANNELS * L2_AWIDTH_NOAL) - 1:0] s_rx_cfg_startaddr;
	wire [(N_RX_CHANNELS * TRANS_SIZE) - 1:0] s_rx_cfg_size;
	wire [N_RX_CHANNELS - 1:0] s_rx_cfg_continuous;
	wire [N_RX_CHANNELS - 1:0] s_rx_cfg_en;
	wire [N_RX_CHANNELS - 1:0] s_rx_cfg_clr;
	wire [(N_RX_CHANNELS * 2) - 1:0] s_rx_cfg_stream;
	wire [N_RX_CHANNELS - 1:0] s_rx_cfg_stream_id;
	wire [(N_RX_CHANNELS * 32) - 1:0] s_rx_ch_data;
	wire [N_RX_CHANNELS - 1:0] s_rx_ch_valid;
	wire [N_RX_CHANNELS - 1:0] s_rx_ch_ready;
	wire [(N_RX_CHANNELS * 2) - 1:0] s_rx_ch_datasize;
	wire [(N_RX_CHANNELS * 2) - 1:0] s_rx_ch_destination;
	wire [N_RX_CHANNELS - 1:0] s_rx_ch_events;
	wire [N_RX_CHANNELS - 1:0] s_rx_ch_en;
	wire [N_RX_CHANNELS - 1:0] s_rx_ch_pending;
	wire [(N_RX_CHANNELS * L2_AWIDTH_NOAL) - 1:0] s_rx_ch_curr_addr;
	wire [(N_RX_CHANNELS * TRANS_SIZE) - 1:0] s_rx_ch_bytes_left;
	wire [L2_AWIDTH_NOAL - 1:0] s_rx_ext_addr;
	wire [1:0] s_rx_ext_datasize;
	wire [1:0] s_rx_ext_destination;
	wire [1:0] s_rx_ext_stream;
	wire [0:0] s_rx_ext_stream_id;
	wire [0:0] s_rx_ext_sot;
	wire [0:0] s_rx_ext_eot;
	wire [0:0] s_rx_ext_valid;
	wire [31:0] s_rx_ext_data;
	wire [0:0] s_rx_ext_ready;
	wire [1:0] s_tx_ext_req;
	wire [3:0] s_tx_ext_datasize;
	wire [3:0] s_tx_ext_destination;
	wire [(2 * L2_AWIDTH_NOAL) - 1:0] s_tx_ext_addr;
	wire [1:0] s_tx_ext_gnt;
	wire [1:0] s_tx_ext_valid;
	wire [63:0] s_tx_ext_data;
	wire [1:0] s_tx_ext_ready;
	wire [31:0] s_stream_data;
	wire [1:0] s_stream_datasize;
	wire [0:0] s_stream_valid;
	wire [0:0] s_stream_sot;
	wire [0:0] s_stream_eot;
	wire [0:0] s_stream_ready;
	wire [127:0] s_events;
	wire [1:0] s_rf_event;
	wire [N_PERIPHS - 1:0] s_clk_periphs_core;
	wire [N_PERIPHS - 1:0] s_clk_periphs_per;
	wire [31:0] s_periph_data_to;
	wire [4:0] s_periph_addr;
	wire s_periph_rwn;
	wire [(N_PERIPHS * 32) - 1:0] s_periph_data_from;
	wire [N_PERIPHS - 1:0] s_periph_valid;
	wire [N_PERIPHS - 1:0] s_periph_ready;
	wire [N_SPI - 1:0] s_spi_eot;
	wire [N_I2C - 1:0] s_i2c_evt;
	wire [N_UART - 1:0] s_uart_evt;
	wire [3:0] s_trigger_events;
	wire s_cam_evt;
	wire s_i2s_evt;
	wire s_i2c1_evt;
	wire s_filter_eot_evt;
	wire s_filter_act_evt;
	wire s_erase_done_event;
	wire s_ref_line_done_event;
	wire s_trim_cfg_done_event;
	wire s_tx_done_event;
	integer i;
	assign s_cam_evt = 1'b0;
	assign s_i2s_evt = 1'b0;
	assign s_uart_evt = 1'b0;
	assign events_o = s_events;
	assign L2_ro_wen_o = 1'b1;
	assign L2_wo_wen_o = 1'b0;
	assign L2_ro_be_o = 'h0;
	assign L2_ro_wdata_o = 'h0;
	udma_core #(
		.L2_AWIDTH_NOAL(L2_AWIDTH_NOAL),
		.L2_DATA_WIDTH(L2_DATA_WIDTH),
		.DATA_WIDTH(32),
		.N_RX_LIN_CHANNELS(N_RX_CHANNELS),
		.N_TX_LIN_CHANNELS(N_TX_CHANNELS),
		.N_RX_EXT_CHANNELS(N_RX_EXT_CHANNELS),
		.N_TX_EXT_CHANNELS(N_TX_EXT_CHANNELS),
		.N_STREAMS(N_STREAMS),
		.STREAM_ID_WIDTH(STREAM_ID_WIDTH),
		.TRANS_SIZE(TRANS_SIZE),
		.N_PERIPHS(N_PERIPHS),
		.APB_ADDR_WIDTH(APB_ADDR_WIDTH)
	) i_udmacore(
		.sys_clk_i(sys_clk_i),
		.per_clk_i(periph_clk_i),
		.dft_cg_enable_i(dft_test_mode_i),
		.HRESETn(sys_resetn_i),
		.PADDR(udma_apb_paddr),
		.PWDATA(udma_apb_pwdata),
		.PWRITE(udma_apb_pwrite),
		.PSEL(udma_apb_psel),
		.PENABLE(udma_apb_penable),
		.PRDATA(udma_apb_prdata),
		.PREADY(udma_apb_pready),
		.PSLVERR(udma_apb_pslverr),
		.periph_per_clk_o(s_clk_periphs_per),
		.periph_sys_clk_o(s_clk_periphs_core),
		.event_valid_i(event_valid_i),
		.event_data_i(event_data_i),
		.event_ready_o(event_ready_o),
		.event_o(s_trigger_events),
		.periph_data_to_o(s_periph_data_to),
		.periph_addr_o(s_periph_addr),
		.periph_data_from_i(s_periph_data_from),
		.periph_ready_i(s_periph_ready),
		.periph_valid_o(s_periph_valid),
		.periph_rwn_o(s_periph_rwn),
		.tx_l2_req_o(L2_ro_req_o),
		.tx_l2_gnt_i(L2_ro_gnt_i),
		.tx_l2_addr_o(L2_ro_addr_o),
		.tx_l2_rdata_i(L2_ro_rdata_i),
		.tx_l2_rvalid_i(L2_ro_rvalid_i),
		.rx_l2_req_o(L2_wo_req_o),
		.rx_l2_gnt_i(L2_wo_gnt_i),
		.rx_l2_addr_o(L2_wo_addr_o),
		.rx_l2_be_o(L2_wo_be_o),
		.rx_l2_wdata_o(L2_wo_wdata_o),
		.stream_data_o(s_stream_data),
		.stream_datasize_o(s_stream_datasize),
		.stream_valid_o(s_stream_valid),
		.stream_sot_o(s_stream_sot),
		.stream_eot_o(s_stream_eot),
		.stream_ready_i(s_stream_ready),
		.tx_lin_req_i(s_tx_ch_req),
		.tx_lin_gnt_o(s_tx_ch_gnt),
		.tx_lin_valid_o(s_tx_ch_valid),
		.tx_lin_data_o(s_tx_ch_data),
		.tx_lin_ready_i(s_tx_ch_ready),
		.tx_lin_datasize_i(s_tx_ch_datasize),
		.tx_lin_destination_i(s_tx_ch_destination),
		.tx_lin_events_o(s_tx_ch_events),
		.tx_lin_en_o(s_tx_ch_en),
		.tx_lin_pending_o(s_tx_ch_pending),
		.tx_lin_curr_addr_o(s_tx_ch_curr_addr),
		.tx_lin_bytes_left_o(s_tx_ch_bytes_left),
		.tx_lin_cfg_startaddr_i(s_tx_cfg_startaddr),
		.tx_lin_cfg_size_i(s_tx_cfg_size),
		.tx_lin_cfg_continuous_i(s_tx_cfg_continuous),
		.tx_lin_cfg_en_i(s_tx_cfg_en),
		.tx_lin_cfg_clr_i(s_tx_cfg_clr),
		.rx_lin_valid_i(s_rx_ch_valid),
		.rx_lin_data_i(s_rx_ch_data),
		.rx_lin_ready_o(s_rx_ch_ready),
		.rx_lin_datasize_i(s_rx_ch_datasize),
		.rx_lin_destination_i(s_rx_ch_destination),
		.rx_lin_events_o(s_rx_ch_events),
		.rx_lin_en_o(s_rx_ch_en),
		.rx_lin_pending_o(s_rx_ch_pending),
		.rx_lin_curr_addr_o(s_rx_ch_curr_addr),
		.rx_lin_bytes_left_o(s_rx_ch_bytes_left),
		.rx_lin_cfg_startaddr_i(s_rx_cfg_startaddr),
		.rx_lin_cfg_size_i(s_rx_cfg_size),
		.rx_lin_cfg_continuous_i(s_rx_cfg_continuous),
		.rx_lin_cfg_stream_i(s_rx_cfg_stream),
		.rx_lin_cfg_stream_id_i(s_rx_cfg_stream_id),
		.rx_lin_cfg_en_i(s_rx_cfg_en),
		.rx_lin_cfg_clr_i(s_rx_cfg_clr),
		.rx_ext_addr_i(s_rx_ext_addr),
		.rx_ext_datasize_i(s_rx_ext_datasize),
		.rx_ext_destination_i(s_rx_ext_destination),
		.rx_ext_stream_i(s_rx_ext_stream),
		.rx_ext_stream_id_i(s_rx_ext_stream_id),
		.rx_ext_sot_i(s_rx_ext_sot),
		.rx_ext_eot_i(s_rx_ext_eot),
		.rx_ext_valid_i(s_rx_ext_valid),
		.rx_ext_data_i(s_rx_ext_data),
		.rx_ext_ready_o(s_rx_ext_ready),
		.tx_ext_req_i(s_tx_ext_req),
		.tx_ext_datasize_i(s_tx_ext_datasize),
		.tx_ext_destination_i(s_tx_ext_destination),
		.tx_ext_addr_i(s_tx_ext_addr),
		.tx_ext_gnt_o(s_tx_ext_gnt),
		.tx_ext_valid_o(s_tx_ext_valid),
		.tx_ext_data_o(s_tx_ext_data),
		.tx_ext_ready_i(s_tx_ext_ready)
	);
	genvar g_uart;
	generate
		for (g_uart = 0; g_uart < N_UART; g_uart = g_uart + 1) begin : i_uart_gen
			assign s_events[(4 * (PER_ID_UART + g_uart)) + 0] = s_rx_ch_events[CH_ID_RX_UART + g_uart];
			assign s_events[(4 * (PER_ID_UART + g_uart)) + 1] = s_tx_ch_events[CH_ID_TX_UART + g_uart];
			assign s_events[(4 * (PER_ID_UART + g_uart)) + 2] = 1'b0;
			assign s_events[(4 * (PER_ID_UART + g_uart)) + 3] = 1'b0;
			assign s_rx_cfg_stream[(CH_ID_RX_UART + g_uart) * 2+:2] = 'h0;
			assign s_rx_cfg_stream_id[CH_ID_RX_UART + g_uart+:1] = 'h0;
			assign s_rx_ch_destination[(CH_ID_RX_UART + g_uart) * 2+:2] = 'h0;
			assign s_tx_ch_destination[(CH_ID_TX_UART + g_uart) * 2+:2] = 'h0;
			udma_uart_top #(
				.L2_AWIDTH_NOAL(L2_AWIDTH_NOAL),
				.TRANS_SIZE(TRANS_SIZE)
			) i_uart(
				.sys_clk_i(s_clk_periphs_core[PER_ID_UART + g_uart]),
				.periph_clk_i(s_clk_periphs_per[PER_ID_UART + g_uart]),
				.rstn_i(sys_resetn_i),
				.uart_tx_o(uart_tx_o[g_uart]),
				.uart_rx_i(uart_rx_i[g_uart]),
				.cfg_data_i(s_periph_data_to),
				.cfg_addr_i(s_periph_addr),
				.cfg_valid_i(s_periph_valid[PER_ID_UART + g_uart]),
				.cfg_rwn_i(s_periph_rwn),
				.cfg_data_o(s_periph_data_from[(PER_ID_UART + g_uart) * 32+:32]),
				.cfg_ready_o(s_periph_ready[PER_ID_UART + g_uart]),
				.cfg_rx_startaddr_o(s_rx_cfg_startaddr[(CH_ID_RX_UART + g_uart) * L2_AWIDTH_NOAL+:L2_AWIDTH_NOAL]),
				.cfg_rx_size_o(s_rx_cfg_size[(CH_ID_RX_UART + g_uart) * TRANS_SIZE+:TRANS_SIZE]),
				.cfg_rx_continuous_o(s_rx_cfg_continuous[CH_ID_RX_UART + g_uart]),
				.cfg_rx_en_o(s_rx_cfg_en[CH_ID_RX_UART + g_uart]),
				.cfg_rx_clr_o(s_rx_cfg_clr[CH_ID_RX_UART + g_uart]),
				.cfg_rx_en_i(s_rx_ch_en[CH_ID_RX_UART + g_uart]),
				.cfg_rx_pending_i(s_rx_ch_pending[CH_ID_RX_UART + g_uart]),
				.cfg_rx_curr_addr_i(s_rx_ch_curr_addr[(CH_ID_RX_UART + g_uart) * L2_AWIDTH_NOAL+:L2_AWIDTH_NOAL]),
				.cfg_rx_bytes_left_i(s_rx_ch_bytes_left[(CH_ID_RX_UART + g_uart) * TRANS_SIZE+:TRANS_SIZE]),
				.cfg_rx_datasize_o(),
				.cfg_tx_startaddr_o(s_tx_cfg_startaddr[(CH_ID_TX_UART + g_uart) * L2_AWIDTH_NOAL+:L2_AWIDTH_NOAL]),
				.cfg_tx_size_o(s_tx_cfg_size[(CH_ID_TX_UART + g_uart) * TRANS_SIZE+:TRANS_SIZE]),
				.cfg_tx_continuous_o(s_tx_cfg_continuous[CH_ID_TX_UART + g_uart]),
				.cfg_tx_en_o(s_tx_cfg_en[CH_ID_TX_UART + g_uart]),
				.cfg_tx_clr_o(s_tx_cfg_clr[CH_ID_TX_UART + g_uart]),
				.cfg_tx_en_i(s_tx_ch_en[CH_ID_TX_UART + g_uart]),
				.cfg_tx_pending_i(s_tx_ch_pending[CH_ID_TX_UART + g_uart]),
				.cfg_tx_curr_addr_i(s_tx_ch_curr_addr[(CH_ID_TX_UART + g_uart) * L2_AWIDTH_NOAL+:L2_AWIDTH_NOAL]),
				.cfg_tx_bytes_left_i(s_tx_ch_bytes_left[(CH_ID_TX_UART + g_uart) * TRANS_SIZE+:TRANS_SIZE]),
				.cfg_tx_datasize_o(),
				.data_tx_req_o(s_tx_ch_req[CH_ID_TX_UART + g_uart]),
				.data_tx_gnt_i(s_tx_ch_gnt[CH_ID_TX_UART + g_uart]),
				.data_tx_datasize_o(s_tx_ch_datasize[(CH_ID_TX_UART + g_uart) * 2+:2]),
				.data_tx_i(s_tx_ch_data[(CH_ID_TX_UART + g_uart) * 32+:32]),
				.data_tx_valid_i(s_tx_ch_valid[CH_ID_TX_UART + g_uart]),
				.data_tx_ready_o(s_tx_ch_ready[CH_ID_TX_UART + g_uart]),
				.data_rx_datasize_o(s_rx_ch_datasize[(CH_ID_RX_UART + g_uart) * 2+:2]),
				.data_rx_o(s_rx_ch_data[(CH_ID_RX_UART + g_uart) * 32+:32]),
				.data_rx_valid_o(s_rx_ch_valid[CH_ID_RX_UART + g_uart]),
				.data_rx_ready_i(s_rx_ch_ready[CH_ID_RX_UART + g_uart])
			);
		end
	endgenerate
	genvar g_spi;
	generate
		for (g_spi = 0; g_spi < N_SPI; g_spi = g_spi + 1) begin : i_spim_gen
			assign s_events[(4 * (PER_ID_SPIM + g_spi)) + 0] = s_rx_ch_events[CH_ID_RX_SPIM + g_spi];
			assign s_events[(4 * (PER_ID_SPIM + g_spi)) + 1] = s_tx_ch_events[CH_ID_TX_SPIM + g_spi];
			assign s_events[(4 * (PER_ID_SPIM + g_spi)) + 2] = s_tx_ch_events[CH_ID_CMD_SPIM + g_spi];
			assign s_events[(4 * (PER_ID_SPIM + g_spi)) + 3] = s_spi_eot[g_spi];
			assign s_rx_cfg_stream[(CH_ID_RX_SPIM + g_spi) * 2+:2] = 'h0;
			assign s_rx_cfg_stream_id[CH_ID_RX_SPIM + g_spi+:1] = 'h0;
			assign s_rx_ch_destination[(CH_ID_RX_SPIM + g_spi) * 2+:2] = 'h0;
			assign s_tx_ch_destination[(CH_ID_TX_SPIM + g_spi) * 2+:2] = 'h0;
			assign s_tx_ch_destination[(CH_ID_CMD_SPIM + g_spi) * 2+:2] = 'h0;
			udma_spim_top #(
				.L2_AWIDTH_NOAL(L2_AWIDTH_NOAL),
				.TRANS_SIZE(TRANS_SIZE)
			) i_spim(
				.sys_clk_i(s_clk_periphs_core[PER_ID_SPIM + g_spi]),
				.periph_clk_i(s_clk_periphs_per[PER_ID_SPIM + g_spi]),
				.rstn_i(sys_resetn_i),
				.dft_test_mode_i(dft_test_mode_i),
				.dft_cg_enable_i(dft_cg_enable_i),
				.spi_eot_o(s_spi_eot[g_spi]),
				.spi_event_i(s_trigger_events),
				.spi_clk_o(spi_clk[g_spi]),
				.spi_csn0_o(spi_csn[g_spi * 4]),
				.spi_csn1_o(spi_csn[(g_spi * 4) + 1]),
				.spi_csn2_o(spi_csn[(g_spi * 4) + 2]),
				.spi_csn3_o(spi_csn[(g_spi * 4) + 3]),
				.spi_oen0_o(spi_oen[g_spi * 4]),
				.spi_oen1_o(spi_oen[(g_spi * 4) + 1]),
				.spi_oen2_o(spi_oen[(g_spi * 4) + 2]),
				.spi_oen3_o(spi_oen[(g_spi * 4) + 3]),
				.spi_sdo0_o(spi_sdo[g_spi * 4]),
				.spi_sdo1_o(spi_sdo[(g_spi * 4) + 1]),
				.spi_sdo2_o(spi_sdo[(g_spi * 4) + 2]),
				.spi_sdo3_o(spi_sdo[(g_spi * 4) + 3]),
				.spi_sdi0_i(spi_sdi[g_spi * 4]),
				.spi_sdi1_i(spi_sdi[(g_spi * 4) + 1]),
				.spi_sdi2_i(spi_sdi[(g_spi * 4) + 2]),
				.spi_sdi3_i(spi_sdi[(g_spi * 4) + 3]),
				.cfg_data_i(s_periph_data_to),
				.cfg_addr_i(s_periph_addr),
				.cfg_valid_i(s_periph_valid[PER_ID_SPIM + g_spi]),
				.cfg_rwn_i(s_periph_rwn),
				.cfg_data_o(s_periph_data_from[(PER_ID_SPIM + g_spi) * 32+:32]),
				.cfg_ready_o(s_periph_ready[PER_ID_SPIM + g_spi]),
				.cmd_req_o(s_tx_ch_req[CH_ID_CMD_SPIM + g_spi]),
				.cmd_gnt_i(s_tx_ch_gnt[CH_ID_CMD_SPIM + g_spi]),
				.cmd_datasize_o(s_tx_ch_datasize[(CH_ID_CMD_SPIM + g_spi) * 2+:2]),
				.cmd_i(s_tx_ch_data[(CH_ID_CMD_SPIM + g_spi) * 32+:32]),
				.cmd_valid_i(s_tx_ch_valid[CH_ID_CMD_SPIM + g_spi]),
				.cmd_ready_o(s_tx_ch_ready[CH_ID_CMD_SPIM + g_spi]),
				.data_tx_req_o(s_tx_ch_req[CH_ID_TX_SPIM + g_spi]),
				.data_tx_gnt_i(s_tx_ch_gnt[CH_ID_TX_SPIM + g_spi]),
				.data_tx_datasize_o(s_tx_ch_datasize[(CH_ID_TX_SPIM + g_spi) * 2+:2]),
				.data_tx_i(s_tx_ch_data[(CH_ID_TX_SPIM + g_spi) * 32+:32]),
				.data_tx_valid_i(s_tx_ch_valid[CH_ID_TX_SPIM + g_spi]),
				.data_tx_ready_o(s_tx_ch_ready[CH_ID_TX_SPIM + g_spi]),
				.data_rx_datasize_o(s_rx_ch_datasize[(CH_ID_RX_SPIM + g_spi) * 2+:2]),
				.data_rx_o(s_rx_ch_data[(CH_ID_RX_SPIM + g_spi) * 32+:32]),
				.data_rx_valid_o(s_rx_ch_valid[CH_ID_RX_SPIM + g_spi]),
				.data_rx_ready_i(s_rx_ch_ready[CH_ID_RX_SPIM + g_spi]),
				.cfg_cmd_startaddr_o(s_tx_cfg_startaddr[(CH_ID_CMD_SPIM + g_spi) * L2_AWIDTH_NOAL+:L2_AWIDTH_NOAL]),
				.cfg_cmd_size_o(s_tx_cfg_size[(CH_ID_CMD_SPIM + g_spi) * TRANS_SIZE+:TRANS_SIZE]),
				.cfg_cmd_continuous_o(s_tx_cfg_continuous[CH_ID_CMD_SPIM + g_spi]),
				.cfg_cmd_en_o(s_tx_cfg_en[CH_ID_CMD_SPIM + g_spi]),
				.cfg_cmd_clr_o(s_tx_cfg_clr[CH_ID_CMD_SPIM + g_spi]),
				.cfg_cmd_en_i(s_tx_ch_en[CH_ID_CMD_SPIM + g_spi]),
				.cfg_cmd_pending_i(s_tx_ch_pending[CH_ID_CMD_SPIM + g_spi]),
				.cfg_cmd_curr_addr_i(s_tx_ch_curr_addr[(CH_ID_CMD_SPIM + g_spi) * L2_AWIDTH_NOAL+:L2_AWIDTH_NOAL]),
				.cfg_cmd_bytes_left_i(s_tx_ch_bytes_left[(CH_ID_CMD_SPIM + g_spi) * TRANS_SIZE+:TRANS_SIZE]),
				.cfg_tx_startaddr_o(s_tx_cfg_startaddr[(CH_ID_TX_SPIM + g_spi) * L2_AWIDTH_NOAL+:L2_AWIDTH_NOAL]),
				.cfg_tx_size_o(s_tx_cfg_size[(CH_ID_TX_SPIM + g_spi) * TRANS_SIZE+:TRANS_SIZE]),
				.cfg_tx_continuous_o(s_tx_cfg_continuous[CH_ID_TX_SPIM + g_spi]),
				.cfg_tx_en_o(s_tx_cfg_en[CH_ID_TX_SPIM + g_spi]),
				.cfg_tx_clr_o(s_tx_cfg_clr[CH_ID_TX_SPIM + g_spi]),
				.cfg_tx_en_i(s_tx_ch_en[CH_ID_TX_SPIM + g_spi]),
				.cfg_tx_pending_i(s_tx_ch_pending[CH_ID_TX_SPIM + g_spi]),
				.cfg_tx_curr_addr_i(s_tx_ch_curr_addr[(CH_ID_TX_SPIM + g_spi) * L2_AWIDTH_NOAL+:L2_AWIDTH_NOAL]),
				.cfg_tx_bytes_left_i(s_tx_ch_bytes_left[(CH_ID_TX_SPIM + g_spi) * TRANS_SIZE+:TRANS_SIZE]),
				.cfg_rx_startaddr_o(s_rx_cfg_startaddr[(CH_ID_RX_SPIM + g_spi) * L2_AWIDTH_NOAL+:L2_AWIDTH_NOAL]),
				.cfg_rx_size_o(s_rx_cfg_size[(CH_ID_RX_SPIM + g_spi) * TRANS_SIZE+:TRANS_SIZE]),
				.cfg_rx_continuous_o(s_rx_cfg_continuous[CH_ID_RX_SPIM + g_spi]),
				.cfg_rx_en_o(s_rx_cfg_en[CH_ID_RX_SPIM + g_spi]),
				.cfg_rx_clr_o(s_rx_cfg_clr[CH_ID_RX_SPIM + g_spi]),
				.cfg_rx_en_i(s_rx_ch_en[CH_ID_RX_SPIM + g_spi]),
				.cfg_rx_pending_i(s_rx_ch_pending[CH_ID_RX_SPIM + g_spi]),
				.cfg_rx_curr_addr_i(s_rx_ch_curr_addr[(CH_ID_RX_SPIM + g_spi) * L2_AWIDTH_NOAL+:L2_AWIDTH_NOAL]),
				.cfg_rx_bytes_left_i(s_rx_ch_bytes_left[(CH_ID_RX_SPIM + g_spi) * TRANS_SIZE+:TRANS_SIZE])
			);
		end
	endgenerate
	genvar g_i2c;
	generate
		for (g_i2c = 0; g_i2c < N_I2C; g_i2c = g_i2c + 1) begin : i_i2c_gen
			assign s_events[(4 * (PER_ID_I2C + g_i2c)) + 0] = s_rx_ch_events[CH_ID_RX_I2C + g_i2c];
			assign s_events[(4 * (PER_ID_I2C + g_i2c)) + 1] = s_tx_ch_events[CH_ID_TX_I2C + g_i2c];
			assign s_events[(4 * (PER_ID_I2C + g_i2c)) + 2] = 1'b0;
			assign s_events[(4 * (PER_ID_I2C + g_i2c)) + 3] = 1'b0;
			assign s_rx_cfg_stream[(CH_ID_RX_I2C + g_i2c) * 2+:2] = 'h0;
			assign s_rx_cfg_stream_id[CH_ID_RX_I2C + g_i2c+:1] = 'h0;
			assign s_rx_ch_destination[(CH_ID_RX_I2C + g_i2c) * 2+:2] = 'h0;
			assign s_tx_ch_destination[(CH_ID_TX_I2C + g_i2c) * 2+:2] = 'h0;
			udma_i2c_top #(
				.L2_AWIDTH_NOAL(L2_AWIDTH_NOAL),
				.TRANS_SIZE(TRANS_SIZE)
			) i_i2c(
				.sys_clk_i(s_clk_periphs_core[PER_ID_I2C + g_i2c]),
				.periph_clk_i(s_clk_periphs_per[PER_ID_I2C + g_i2c]),
				.rstn_i(sys_resetn_i),
				.cfg_data_i(s_periph_data_to),
				.cfg_addr_i(s_periph_addr),
				.cfg_valid_i(s_periph_valid[PER_ID_I2C + g_i2c]),
				.cfg_rwn_i(s_periph_rwn),
				.cfg_data_o(s_periph_data_from[(PER_ID_I2C + g_i2c) * 32+:32]),
				.cfg_ready_o(s_periph_ready[PER_ID_I2C + g_i2c]),
				.cfg_tx_startaddr_o(s_tx_cfg_startaddr[(CH_ID_TX_I2C + g_i2c) * L2_AWIDTH_NOAL+:L2_AWIDTH_NOAL]),
				.cfg_tx_size_o(s_tx_cfg_size[(CH_ID_TX_I2C + g_i2c) * TRANS_SIZE+:TRANS_SIZE]),
				.cfg_tx_continuous_o(s_tx_cfg_continuous[CH_ID_TX_I2C + g_i2c]),
				.cfg_tx_en_o(s_tx_cfg_en[CH_ID_TX_I2C + g_i2c]),
				.cfg_tx_clr_o(s_tx_cfg_clr[CH_ID_TX_I2C + g_i2c]),
				.cfg_tx_en_i(s_tx_ch_en[CH_ID_TX_I2C + g_i2c]),
				.cfg_tx_pending_i(s_tx_ch_pending[CH_ID_TX_I2C + g_i2c]),
				.cfg_tx_curr_addr_i(s_tx_ch_curr_addr[(CH_ID_TX_I2C + g_i2c) * L2_AWIDTH_NOAL+:L2_AWIDTH_NOAL]),
				.cfg_tx_bytes_left_i(s_tx_ch_bytes_left[(CH_ID_TX_I2C + g_i2c) * TRANS_SIZE+:TRANS_SIZE]),
				.cfg_rx_startaddr_o(s_rx_cfg_startaddr[(CH_ID_RX_I2C + g_i2c) * L2_AWIDTH_NOAL+:L2_AWIDTH_NOAL]),
				.cfg_rx_size_o(s_rx_cfg_size[(CH_ID_RX_I2C + g_i2c) * TRANS_SIZE+:TRANS_SIZE]),
				.cfg_rx_continuous_o(s_rx_cfg_continuous[CH_ID_RX_I2C + g_i2c]),
				.cfg_rx_en_o(s_rx_cfg_en[CH_ID_RX_I2C + g_i2c]),
				.cfg_rx_clr_o(s_rx_cfg_clr[CH_ID_RX_I2C + g_i2c]),
				.cfg_rx_en_i(s_rx_ch_en[CH_ID_RX_I2C + g_i2c]),
				.cfg_rx_pending_i(s_rx_ch_pending[CH_ID_RX_I2C + g_i2c]),
				.cfg_rx_curr_addr_i(s_rx_ch_curr_addr[(CH_ID_RX_I2C + g_i2c) * L2_AWIDTH_NOAL+:L2_AWIDTH_NOAL]),
				.cfg_rx_bytes_left_i(s_rx_ch_bytes_left[(CH_ID_RX_I2C + g_i2c) * TRANS_SIZE+:TRANS_SIZE]),
				.data_tx_req_o(s_tx_ch_req[CH_ID_TX_I2C + g_i2c]),
				.data_tx_gnt_i(s_tx_ch_gnt[CH_ID_TX_I2C + g_i2c]),
				.data_tx_datasize_o(s_tx_ch_datasize[(CH_ID_TX_I2C + g_i2c) * 2+:2]),
				.data_tx_i(s_tx_ch_data[((CH_ID_TX_I2C + g_i2c) * 32) + 7-:8]),
				.data_tx_valid_i(s_tx_ch_valid[CH_ID_TX_I2C + g_i2c]),
				.data_tx_ready_o(s_tx_ch_ready[CH_ID_TX_I2C + g_i2c]),
				.data_rx_datasize_o(s_rx_ch_datasize[(CH_ID_RX_I2C + g_i2c) * 2+:2]),
				.data_rx_o(s_rx_ch_data[((CH_ID_RX_I2C + g_i2c) * 32) + 7-:8]),
				.data_rx_valid_o(s_rx_ch_valid[CH_ID_RX_I2C + g_i2c]),
				.data_rx_ready_i(s_rx_ch_ready[CH_ID_RX_I2C + g_i2c]),
				.err_o(s_i2c_evt[g_i2c]),
				.scl_i(i2c_scl_i[g_i2c]),
				.scl_o(i2c_scl_o[g_i2c]),
				.scl_oe(i2c_scl_oe[g_i2c]),
				.sda_i(i2c_sda_i[g_i2c]),
				.sda_o(i2c_sda_o[g_i2c]),
				.sda_oe(i2c_sda_oe[g_i2c]),
				.ext_events_i(s_trigger_events)
			);
			assign s_rx_ch_data[((CH_ID_RX_I2C + g_i2c) * 32) + 31-:24] = 'h0;
		end
	endgenerate
	wire s_sdio_eot;
	wire s_sdio_err;
	assign s_events[4 * PER_ID_SDIO] = s_rx_ch_events[CH_ID_RX_SDIO];
	assign s_events[(4 * PER_ID_SDIO) + 1] = s_tx_ch_events[CH_ID_TX_SDIO];
	assign s_events[(4 * PER_ID_SDIO) + 2] = s_sdio_eot;
	assign s_events[(4 * PER_ID_SDIO) + 3] = s_sdio_err;
	assign s_rx_cfg_stream[CH_ID_RX_SDIO * 2+:2] = 'h0;
	assign s_rx_cfg_stream_id[CH_ID_RX_SDIO+:1] = 'h0;
	assign s_rx_ch_destination[CH_ID_RX_SDIO * 2+:2] = 'h0;
	assign s_tx_ch_destination[CH_ID_TX_SDIO * 2+:2] = 'h0;
	udma_sdio_top #(
		.L2_AWIDTH_NOAL(L2_AWIDTH_NOAL),
		.TRANS_SIZE(TRANS_SIZE)
	) i_sdio(
		.sys_clk_i(s_clk_periphs_core[PER_ID_SDIO]),
		.periph_clk_i(s_clk_periphs_per[PER_ID_SDIO]),
		.rstn_i(sys_resetn_i),
		.err_o(s_sdio_err),
		.eot_o(s_sdio_eot),
		.sdclk_o(sdio_clk_o),
		.sdcmd_o(sdio_cmd_o),
		.sdcmd_i(sdio_cmd_i),
		.sdcmd_oen_o(sdio_cmd_oen_o),
		.sddata_o(sdio_data_o),
		.sddata_i(sdio_data_i),
		.sddata_oen_o(sdio_data_oen_o),
		.cfg_data_i(s_periph_data_to),
		.cfg_addr_i(s_periph_addr),
		.cfg_valid_i(s_periph_valid[PER_ID_SDIO]),
		.cfg_rwn_i(s_periph_rwn),
		.cfg_data_o(s_periph_data_from[PER_ID_SDIO * 32+:32]),
		.cfg_ready_o(s_periph_ready[PER_ID_SDIO]),
		.cfg_rx_startaddr_o(s_rx_cfg_startaddr[CH_ID_RX_SDIO * L2_AWIDTH_NOAL+:L2_AWIDTH_NOAL]),
		.cfg_rx_size_o(s_rx_cfg_size[CH_ID_RX_SDIO * TRANS_SIZE+:TRANS_SIZE]),
		.cfg_rx_continuous_o(s_rx_cfg_continuous[CH_ID_RX_SDIO]),
		.cfg_rx_en_o(s_rx_cfg_en[CH_ID_RX_SDIO]),
		.cfg_rx_clr_o(s_rx_cfg_clr[CH_ID_RX_SDIO]),
		.cfg_rx_en_i(s_rx_ch_en[CH_ID_RX_SDIO]),
		.cfg_rx_pending_i(s_rx_ch_pending[CH_ID_RX_SDIO]),
		.cfg_rx_curr_addr_i(s_rx_ch_curr_addr[CH_ID_RX_SDIO * L2_AWIDTH_NOAL+:L2_AWIDTH_NOAL]),
		.cfg_rx_bytes_left_i(s_rx_ch_bytes_left[CH_ID_RX_SDIO * TRANS_SIZE+:TRANS_SIZE]),
		.cfg_tx_startaddr_o(s_tx_cfg_startaddr[CH_ID_TX_SDIO * L2_AWIDTH_NOAL+:L2_AWIDTH_NOAL]),
		.cfg_tx_size_o(s_tx_cfg_size[CH_ID_TX_SDIO * TRANS_SIZE+:TRANS_SIZE]),
		.cfg_tx_continuous_o(s_tx_cfg_continuous[CH_ID_TX_SDIO]),
		.cfg_tx_en_o(s_tx_cfg_en[CH_ID_TX_SDIO]),
		.cfg_tx_clr_o(s_tx_cfg_clr[CH_ID_TX_SDIO]),
		.cfg_tx_en_i(s_tx_ch_en[CH_ID_TX_SDIO]),
		.cfg_tx_pending_i(s_tx_ch_pending[CH_ID_TX_SDIO]),
		.cfg_tx_curr_addr_i(s_tx_ch_curr_addr[CH_ID_TX_SDIO * L2_AWIDTH_NOAL+:L2_AWIDTH_NOAL]),
		.cfg_tx_bytes_left_i(s_tx_ch_bytes_left[CH_ID_TX_SDIO * TRANS_SIZE+:TRANS_SIZE]),
		.data_tx_req_o(s_tx_ch_req[CH_ID_TX_SDIO]),
		.data_tx_gnt_i(s_tx_ch_gnt[CH_ID_TX_SDIO]),
		.data_tx_datasize_o(s_tx_ch_datasize[CH_ID_TX_SDIO * 2+:2]),
		.data_tx_i(s_tx_ch_data[CH_ID_TX_SDIO * 32+:32]),
		.data_tx_valid_i(s_tx_ch_valid[CH_ID_TX_SDIO]),
		.data_tx_ready_o(s_tx_ch_ready[CH_ID_TX_SDIO]),
		.data_rx_datasize_o(s_rx_ch_datasize[CH_ID_RX_SDIO * 2+:2]),
		.data_rx_o(s_rx_ch_data[CH_ID_RX_SDIO * 32+:32]),
		.data_rx_valid_o(s_rx_ch_valid[CH_ID_RX_SDIO]),
		.data_rx_ready_i(s_rx_ch_ready[CH_ID_RX_SDIO])
	);
	assign s_events[4 * PER_ID_I2S] = s_rx_ch_events[CH_ID_RX_I2S];
	assign s_events[(4 * PER_ID_I2S) + 1] = s_tx_ch_events[CH_ID_TX_I2S];
	assign s_events[(4 * PER_ID_I2S) + 2] = 1'b0;
	assign s_events[(4 * PER_ID_I2S) + 3] = 1'b0;
	assign s_rx_cfg_stream[CH_ID_RX_I2S * 2+:2] = 'h0;
	assign s_rx_cfg_stream_id[CH_ID_RX_I2S+:1] = 'h0;
	assign s_rx_ch_destination[CH_ID_RX_I2S * 2+:2] = 'h0;
	assign s_tx_ch_destination[CH_ID_TX_I2S * 2+:2] = 'h0;
	udma_i2s_top #(
		.L2_AWIDTH_NOAL(L2_AWIDTH_NOAL),
		.TRANS_SIZE(TRANS_SIZE)
	) i_i2s_udma(
		.sys_clk_i(s_clk_periphs_core[PER_ID_I2S]),
		.periph_clk_i(s_clk_periphs_per[PER_ID_I2S]),
		.rstn_i(sys_resetn_i),
		.dft_test_mode_i(dft_test_mode_i),
		.dft_cg_enable_i(dft_test_mode_i),
		.pad_slave_sd0_i(i2s_slave_sd0_i),
		.pad_slave_sd1_i(i2s_slave_sd1_i),
		.pad_slave_sck_i(i2s_slave_sck_i),
		.pad_slave_sck_o(i2s_slave_sck_o),
		.pad_slave_sck_oe(i2s_slave_sck_oe),
		.pad_slave_ws_i(i2s_slave_ws_i),
		.pad_slave_ws_o(i2s_slave_ws_o),
		.pad_slave_ws_oe(i2s_slave_ws_oe),
		.pad_master_sd0_o(),
		.pad_master_sd1_o(),
		.pad_master_sck_i(),
		.pad_master_sck_o(),
		.pad_master_sck_oe(),
		.pad_master_ws_i(1'b0),
		.pad_master_ws_o(),
		.pad_master_ws_oe(),
		.cfg_data_i(s_periph_data_to),
		.cfg_addr_i(s_periph_addr),
		.cfg_valid_i(s_periph_valid[PER_ID_I2S]),
		.cfg_rwn_i(s_periph_rwn),
		.cfg_data_o(s_periph_data_from[PER_ID_I2S * 32+:32]),
		.cfg_ready_o(s_periph_ready[PER_ID_I2S]),
		.cfg_rx_startaddr_o(s_rx_cfg_startaddr[CH_ID_RX_I2S * L2_AWIDTH_NOAL+:L2_AWIDTH_NOAL]),
		.cfg_rx_size_o(s_rx_cfg_size[CH_ID_RX_I2S * TRANS_SIZE+:TRANS_SIZE]),
		.cfg_rx_continuous_o(s_rx_cfg_continuous[CH_ID_RX_I2S]),
		.cfg_rx_en_o(s_rx_cfg_en[CH_ID_RX_I2S]),
		.cfg_rx_clr_o(s_rx_cfg_clr[CH_ID_RX_I2S]),
		.cfg_rx_en_i(s_rx_ch_en[CH_ID_RX_I2S]),
		.cfg_rx_pending_i(s_rx_ch_pending[CH_ID_RX_I2S]),
		.cfg_rx_curr_addr_i(s_rx_ch_curr_addr[CH_ID_RX_I2S * L2_AWIDTH_NOAL+:L2_AWIDTH_NOAL]),
		.cfg_rx_bytes_left_i(s_rx_ch_bytes_left[CH_ID_RX_I2S * TRANS_SIZE+:TRANS_SIZE]),
		.cfg_tx_startaddr_o(s_tx_cfg_startaddr[CH_ID_TX_I2S * L2_AWIDTH_NOAL+:L2_AWIDTH_NOAL]),
		.cfg_tx_size_o(s_tx_cfg_size[CH_ID_TX_I2S * TRANS_SIZE+:TRANS_SIZE]),
		.cfg_tx_continuous_o(s_tx_cfg_continuous[CH_ID_TX_I2S]),
		.cfg_tx_en_o(s_tx_cfg_en[CH_ID_TX_I2S]),
		.cfg_tx_clr_o(s_tx_cfg_clr[CH_ID_TX_I2S]),
		.cfg_tx_en_i(s_tx_ch_en[CH_ID_TX_I2S]),
		.cfg_tx_pending_i(s_tx_ch_pending[CH_ID_TX_I2S]),
		.cfg_tx_curr_addr_i(s_tx_ch_curr_addr[CH_ID_TX_I2S * L2_AWIDTH_NOAL+:L2_AWIDTH_NOAL]),
		.cfg_tx_bytes_left_i(s_tx_ch_bytes_left[CH_ID_TX_I2S * TRANS_SIZE+:TRANS_SIZE]),
		.data_rx_datasize_o(s_rx_ch_datasize[CH_ID_RX_I2S * 2+:2]),
		.data_rx_o(s_rx_ch_data[CH_ID_RX_I2S * 32+:32]),
		.data_rx_valid_o(s_rx_ch_valid[CH_ID_RX_I2S]),
		.data_rx_ready_i(s_rx_ch_ready[CH_ID_RX_I2S]),
		.data_tx_req_o(s_tx_ch_req[CH_ID_TX_I2S]),
		.data_tx_gnt_i(s_tx_ch_gnt[CH_ID_TX_I2S]),
		.data_tx_datasize_o(s_tx_ch_datasize[CH_ID_TX_I2S * 2+:2]),
		.data_tx_i(s_tx_ch_data[CH_ID_TX_I2S * 32+:32]),
		.data_tx_valid_i(s_tx_ch_valid[CH_ID_TX_I2S]),
		.data_tx_ready_o(s_tx_ch_ready[CH_ID_TX_I2S])
	);
	assign s_events[4 * PER_ID_CAM] = s_rx_ch_events[CH_ID_RX_CAM];
	assign s_events[(4 * PER_ID_CAM) + 1] = 1'b0;
	assign s_events[(4 * PER_ID_CAM) + 2] = 1'b0;
	assign s_events[(4 * PER_ID_CAM) + 3] = 1'b0;
	assign s_rx_cfg_stream[CH_ID_RX_CAM * 2+:2] = 'h0;
	assign s_rx_cfg_stream_id[CH_ID_RX_CAM+:1] = 'h0;
	assign s_rx_ch_destination[CH_ID_RX_CAM * 2+:2] = 'h0;
	camera_if #(
		.L2_AWIDTH_NOAL(L2_AWIDTH_NOAL),
		.TRANS_SIZE(TRANS_SIZE),
		.DATA_WIDTH(8)
	) i_camera_if(
		.clk_i(s_clk_periphs_core[PER_ID_CAM]),
		.rstn_i(sys_resetn_i),
		.dft_test_mode_i(dft_test_mode_i),
		.dft_cg_enable_i(dft_cg_enable_i),
		.cfg_data_i(s_periph_data_to),
		.cfg_addr_i(s_periph_addr),
		.cfg_valid_i(s_periph_valid[PER_ID_CAM]),
		.cfg_rwn_i(s_periph_rwn),
		.cfg_data_o(s_periph_data_from[PER_ID_CAM * 32+:32]),
		.cfg_ready_o(s_periph_ready[PER_ID_CAM]),
		.cfg_rx_startaddr_o(s_rx_cfg_startaddr[CH_ID_RX_CAM * L2_AWIDTH_NOAL+:L2_AWIDTH_NOAL]),
		.cfg_rx_size_o(s_rx_cfg_size[CH_ID_RX_CAM * TRANS_SIZE+:TRANS_SIZE]),
		.cfg_rx_continuous_o(s_rx_cfg_continuous[CH_ID_RX_CAM]),
		.cfg_rx_en_o(s_rx_cfg_en[CH_ID_RX_CAM]),
		.cfg_rx_clr_o(s_rx_cfg_clr[CH_ID_RX_CAM]),
		.cfg_rx_en_i(s_rx_ch_en[CH_ID_RX_CAM]),
		.cfg_rx_pending_i(s_rx_ch_pending[CH_ID_RX_CAM]),
		.cfg_rx_curr_addr_i(s_rx_ch_curr_addr[CH_ID_RX_CAM * L2_AWIDTH_NOAL+:L2_AWIDTH_NOAL]),
		.cfg_rx_bytes_left_i(s_rx_ch_bytes_left[CH_ID_RX_CAM * TRANS_SIZE+:TRANS_SIZE]),
		.data_rx_datasize_o(s_rx_ch_datasize[CH_ID_RX_CAM * 2+:2]),
		.data_rx_data_o(s_rx_ch_data[(CH_ID_RX_CAM * 32) + 15-:16]),
		.data_rx_valid_o(s_rx_ch_valid[CH_ID_RX_CAM]),
		.data_rx_ready_i(s_rx_ch_ready[CH_ID_RX_CAM]),
		.cam_clk_i(cam_clk_i),
		.cam_data_i(cam_data_i),
		.cam_hsync_i(cam_hsync_i),
		.cam_vsync_i(cam_vsync_i)
	);
	assign s_rx_ch_data[(CH_ID_RX_CAM * 32) + 31-:16] = 'h0;
	assign s_events[4 * PER_ID_FILTER] = s_filter_eot_evt;
	assign s_events[(4 * PER_ID_FILTER) + 1] = s_filter_act_evt;
	assign s_events[(4 * PER_ID_FILTER) + 2] = 1'b0;
	assign s_events[(4 * PER_ID_FILTER) + 3] = 1'b0;
	assign s_rx_ext_destination[0+:2] = 'h0;
	assign s_rx_ext_stream[0+:2] = 'h0;
	assign s_rx_ext_stream_id[CH_ID_EXT_RX_FILTER+:1] = 'h0;
	assign s_rx_ext_sot[CH_ID_EXT_RX_FILTER] = 'h0;
	assign s_rx_ext_eot[CH_ID_EXT_RX_FILTER] = 'h0;
	assign s_tx_ext_destination[0+:2] = 'h0;
	assign s_tx_ext_destination[2+:2] = 'h0;
	udma_filter #(
		.L2_AWIDTH_NOAL(L2_AWIDTH_NOAL),
		.TRANS_SIZE(TRANS_SIZE)
	) i_filter(
		.clk_i(s_clk_periphs_core[PER_ID_FILTER]),
		.resetn_i(sys_resetn_i),
		.cfg_data_i(s_periph_data_to),
		.cfg_addr_i(s_periph_addr),
		.cfg_valid_i(s_periph_valid[PER_ID_FILTER]),
		.cfg_rwn_i(s_periph_rwn),
		.cfg_data_o(s_periph_data_from[PER_ID_FILTER * 32+:32]),
		.cfg_ready_o(s_periph_ready[PER_ID_FILTER]),
		.eot_event_o(s_filter_eot_evt),
		.act_event_o(s_filter_act_evt),
		.filter_tx_ch0_req_o(s_tx_ext_req[CH_ID_EXT_TX_FILTER]),
		.filter_tx_ch0_addr_o(s_tx_ext_addr[0+:L2_AWIDTH_NOAL]),
		.filter_tx_ch0_datasize_o(s_tx_ext_datasize[0+:2]),
		.filter_tx_ch0_gnt_i(s_tx_ext_gnt[CH_ID_EXT_TX_FILTER]),
		.filter_tx_ch0_valid_i(s_tx_ext_valid[CH_ID_EXT_TX_FILTER]),
		.filter_tx_ch0_data_i(s_tx_ext_data[0+:32]),
		.filter_tx_ch0_ready_o(s_tx_ext_ready[CH_ID_EXT_TX_FILTER]),
		.filter_tx_ch1_req_o(s_tx_ext_req[1]),
		.filter_tx_ch1_addr_o(s_tx_ext_addr[L2_AWIDTH_NOAL+:L2_AWIDTH_NOAL]),
		.filter_tx_ch1_datasize_o(s_tx_ext_datasize[2+:2]),
		.filter_tx_ch1_gnt_i(s_tx_ext_gnt[1]),
		.filter_tx_ch1_valid_i(s_tx_ext_valid[1]),
		.filter_tx_ch1_data_i(s_tx_ext_data[32+:32]),
		.filter_tx_ch1_ready_o(s_tx_ext_ready[1]),
		.filter_rx_ch_addr_o(s_rx_ext_addr[0+:L2_AWIDTH_NOAL]),
		.filter_rx_ch_datasize_o(s_rx_ext_datasize[0+:2]),
		.filter_rx_ch_valid_o(s_rx_ext_valid[CH_ID_EXT_RX_FILTER]),
		.filter_rx_ch_data_o(s_rx_ext_data[0+:32]),
		.filter_rx_ch_ready_i(s_rx_ext_ready[CH_ID_EXT_RX_FILTER]),
		.filter_id_i(),
		.filter_data_i(s_stream_data[0+:32]),
		.filter_datasize_i(s_stream_datasize[0+:2]),
		.filter_valid_i(s_stream_valid[STREAM_ID_FILTER]),
		.filter_sof_i(s_stream_sot[STREAM_ID_FILTER]),
		.filter_eof_i(s_stream_eot[STREAM_ID_FILTER]),
		.filter_ready_o(s_stream_ready[STREAM_ID_FILTER])
	);
	assign s_events[4 * PER_ID_MRAM] = s_rx_ch_events[CH_ID_RX_MRAM];
	assign s_events[(4 * PER_ID_MRAM) + 1] = s_tx_ch_events[CH_ID_TX_MRAM];
	assign s_events[(4 * PER_ID_MRAM) + 2] = s_tx_done_event;
	assign s_events[(4 * PER_ID_MRAM) + 3] = 1'b0;
	assign s_rx_cfg_stream[CH_ID_RX_MRAM * 2+:2] = 'h0;
	assign s_rx_cfg_stream_id[CH_ID_RX_MRAM+:1] = 'h0;
	assign s_rx_ch_destination[CH_ID_RX_MRAM * 2+:2] = 'h0;
	assign s_tx_ch_destination[CH_ID_TX_MRAM * 2+:2] = 'h0;
	udma_mram_top_wrapper #(
		.L2_AWIDTH_NOAL(L2_AWIDTH_NOAL),
		.TRANS_SIZE(TRANS_SIZE)
	) i_mram_top_wrapper(
		.sys_clk_i(s_clk_periphs_core[PER_ID_MRAM]),
		.periph_clk_i(s_clk_periphs_per[PER_ID_MRAM]),
		.rstn_i(sys_resetn_i),
		.dft_test_mode_i(dft_test_mode_i),
		.dft_cg_enable_i(dft_test_mode_i),
		.cfg_data_i(s_periph_data_to),
		.cfg_addr_i(s_periph_addr),
		.cfg_valid_i(s_periph_valid[PER_ID_MRAM]),
		.cfg_rwn_i(s_periph_rwn),
		.cfg_ready_o(s_periph_ready[PER_ID_MRAM]),
		.cfg_data_o(s_periph_data_from[PER_ID_MRAM * 32+:32]),
		.cfg_rx_startaddr_o(s_rx_cfg_startaddr[CH_ID_RX_MRAM * L2_AWIDTH_NOAL+:L2_AWIDTH_NOAL]),
		.cfg_rx_size_o(s_rx_cfg_size[CH_ID_RX_MRAM * TRANS_SIZE+:TRANS_SIZE]),
		.cfg_rx_continuous_o(s_rx_cfg_continuous[CH_ID_RX_MRAM]),
		.cfg_rx_en_o(s_rx_cfg_en[CH_ID_RX_MRAM]),
		.cfg_rx_clr_o(s_rx_cfg_clr[CH_ID_RX_MRAM]),
		.cfg_rx_en_i(s_rx_ch_en[CH_ID_RX_MRAM]),
		.cfg_rx_pending_i(s_rx_ch_pending[CH_ID_RX_MRAM]),
		.cfg_rx_curr_addr_i(s_rx_ch_curr_addr[CH_ID_RX_MRAM * L2_AWIDTH_NOAL+:L2_AWIDTH_NOAL]),
		.cfg_rx_bytes_left_i(s_rx_ch_bytes_left[CH_ID_RX_MRAM * TRANS_SIZE+:TRANS_SIZE]),
		.cfg_tx_startaddr_o(s_tx_cfg_startaddr[CH_ID_TX_MRAM * L2_AWIDTH_NOAL+:L2_AWIDTH_NOAL]),
		.cfg_tx_size_o(s_tx_cfg_size[CH_ID_TX_MRAM * TRANS_SIZE+:TRANS_SIZE]),
		.cfg_tx_continuous_o(s_tx_cfg_continuous[CH_ID_TX_MRAM]),
		.cfg_tx_en_o(s_tx_cfg_en[CH_ID_TX_MRAM]),
		.cfg_tx_clr_o(s_tx_cfg_clr[CH_ID_TX_MRAM]),
		.cfg_tx_en_i(s_tx_ch_en[CH_ID_TX_MRAM]),
		.cfg_tx_pending_i(s_tx_ch_pending[CH_ID_TX_MRAM]),
		.cfg_tx_curr_addr_i(s_tx_ch_curr_addr[CH_ID_TX_MRAM * L2_AWIDTH_NOAL+:L2_AWIDTH_NOAL]),
		.cfg_tx_bytes_left_i(s_tx_ch_bytes_left[CH_ID_TX_MRAM * TRANS_SIZE+:TRANS_SIZE]),
		.data_tx_req_o(s_tx_ch_req[CH_ID_TX_MRAM]),
		.data_tx_gnt_i(s_tx_ch_gnt[CH_ID_TX_MRAM]),
		.data_tx_datasize_o(s_tx_ch_datasize[CH_ID_TX_MRAM * 2+:2]),
		.data_tx_i(s_tx_ch_data[CH_ID_TX_MRAM * 32+:32]),
		.data_tx_valid_i(s_tx_ch_valid[CH_ID_TX_MRAM]),
		.data_tx_ready_o(s_tx_ch_ready[CH_ID_TX_MRAM]),
		.data_rx_datasize_o(s_rx_ch_datasize[CH_ID_RX_MRAM * 2+:2]),
		.data_rx_o(s_rx_ch_data[CH_ID_RX_MRAM * 32+:32]),
		.data_rx_valid_o(s_rx_ch_valid[CH_ID_RX_MRAM]),
		.data_rx_ready_i(s_rx_ch_ready[CH_ID_RX_MRAM]),
		.VDDA_i(VDDA_i),
		.VDD_i(VDD_i),
		.VREF_i(VREF_i),
		.PORb_i(PORb_i),
		.RETb_i(RETb_i),
		.RSTb_i(RSTb_i),
		.TRIM_i(TRIM_i),
		.DPD_i(DPD_i),
		.CEb_HIGH_i(CEb_HIGH_i),
		.erase_done_event_o(s_erase_done_event),
		.ref_line_done_event_o(s_ref_line_done_event),
		.trim_cfg_done_event_o(s_trim_cfg_done_event),
		.tx_done_event_o(s_tx_done_event)
	);
endmodule
