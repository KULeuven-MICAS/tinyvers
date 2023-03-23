module siriusv2 (
	pad_spim_sdio0,
	pad_spim_sdio1,
	pad_spim_sdio2,
	pad_spim_sdio3,
	pad_spim_csn0,
	pad_spim_csn1,
	pad_spim_sck,
	pad_uart_rx,
	pad_uart_tx,
	pad_cam_pclk,
	pad_cam_hsync,
	pad_cam_data0,
	pad_cam_data1,
	pad_cam_data2,
	pad_cam_data3,
	pad_cam_data4,
	pad_cam_data5,
	pad_cam_data6,
	pad_cam_data7,
	pad_cam_vsync,
	pad_sdio_clk,
	pad_sdio_cmd,
	pad_sdio_data0,
	pad_sdio_data1,
	pad_sdio_data2,
	pad_sdio_data3,
	pad_i2c0_sda,
	pad_i2c0_scl,
	pad_i2s0_sck,
	pad_i2s0_ws,
	pad_i2s0_sdi,
	pad_i2s1_sdi,
	pad_reset_n,
	pad_bootsel,
	pad_jtag_tck,
	pad_jtag_tdi,
	pad_jtag_tdo,
	pad_jtag_tms,
	pad_jtag_trst,
	pad_xtal_in,
	pad_clk_soc_ext,
	pad_clk_per_ext,
	pad_gatemram_vdd,
	pad_gatemram_vdda,
	pad_gatemram_vref,
	pad_hold_wu,
	pad_step_wu,
	pad_wu_bypass_out,
	pad_wu_bypass_mux,
	pad_debug_ctrl,
	pad_scan_en_in,
	pad_soc_scan_out,
	pad_per_scan_out,
	pad_ref_scan_out
);
	parameter CORE_TYPE = 0;
	parameter USE_FPU = 1;
	parameter USE_HWPE = 1;
	inout wire pad_spim_sdio0;
	inout wire pad_spim_sdio1;
	inout wire pad_spim_sdio2;
	inout wire pad_spim_sdio3;
	inout wire pad_spim_csn0;
	inout wire pad_spim_csn1;
	inout wire pad_spim_sck;
	inout wire pad_uart_rx;
	inout wire pad_uart_tx;
	inout wire pad_cam_pclk;
	inout wire pad_cam_hsync;
	inout wire pad_cam_data0;
	inout wire pad_cam_data1;
	inout wire pad_cam_data2;
	inout wire pad_cam_data3;
	inout wire pad_cam_data4;
	inout wire pad_cam_data5;
	inout wire pad_cam_data6;
	inout wire pad_cam_data7;
	inout wire pad_cam_vsync;
	inout wire pad_sdio_clk;
	inout wire pad_sdio_cmd;
	inout wire pad_sdio_data0;
	inout wire pad_sdio_data1;
	inout wire pad_sdio_data2;
	inout wire pad_sdio_data3;
	inout wire pad_i2c0_sda;
	inout wire pad_i2c0_scl;
	inout wire pad_i2s0_sck;
	inout wire pad_i2s0_ws;
	inout wire pad_i2s0_sdi;
	inout wire pad_i2s1_sdi;
	inout wire pad_reset_n;
	inout wire pad_bootsel;
	inout wire pad_jtag_tck;
	inout wire pad_jtag_tdi;
	inout wire pad_jtag_tdo;
	inout wire pad_jtag_tms;
	inout wire pad_jtag_trst;
	inout wire pad_xtal_in;
	inout wire pad_clk_soc_ext;
	inout wire pad_clk_per_ext;
	inout wire pad_gatemram_vdd;
	inout wire pad_gatemram_vdda;
	inout wire pad_gatemram_vref;
	inout wire pad_hold_wu;
	inout wire pad_step_wu;
	inout wire pad_wu_bypass_out;
	inout wire pad_wu_bypass_mux;
	inout wire pad_debug_ctrl;
	inout wire pad_scan_en_in;
	inout wire pad_soc_scan_out;
	inout wire pad_per_scan_out;
	inout wire pad_ref_scan_out;
	localparam AXI_ADDR_WIDTH = 32;
	localparam AXI_CLUSTER_SOC_DATA_WIDTH = 64;
	localparam AXI_SOC_CLUSTER_DATA_WIDTH = 32;
	localparam AXI_CLUSTER_SOC_ID_WIDTH = 6;
	localparam AXI_SOC_CLUSTER_ID_WIDTH = 6;
	localparam AXI_USER_WIDTH = 6;
	localparam AXI_CLUSTER_SOC_STRB_WIDTH = 8;
	localparam AXI_SOC_CLUSTER_STRB_WIDTH = 4;
	localparam BUFFER_WIDTH = 8;
	localparam EVENT_WIDTH = 8;
	localparam CVP_ADDR_WIDTH = 32;
	localparam CVP_DATA_WIDTH = 32;
	wire [287:0] s_pad_cfg;
	wire s_out_spim_sdio0;
	wire s_out_spim_sdio1;
	wire s_out_spim_sdio2;
	wire s_out_spim_sdio3;
	wire s_out_spim_csn0;
	wire s_out_spim_csn1;
	wire s_out_spim_sck;
	wire s_out_uart_rx;
	wire s_out_uart_tx;
	wire s_out_cam_pclk;
	wire s_out_cam_hsync;
	wire s_out_cam_data0;
	wire s_out_cam_data1;
	wire s_out_cam_data2;
	wire s_out_cam_data3;
	wire s_out_cam_data4;
	wire s_out_cam_data5;
	wire s_out_cam_data6;
	wire s_out_cam_data7;
	wire s_out_cam_vsync;
	wire s_out_sdio_clk;
	wire s_out_sdio_cmd;
	wire s_out_sdio_data0;
	wire s_out_sdio_data1;
	wire s_out_sdio_data2;
	wire s_out_sdio_data3;
	wire s_out_i2c0_sda;
	wire s_out_i2c0_scl;
	wire s_out_i2s0_sck;
	wire s_out_i2s0_ws;
	wire s_out_i2s0_sdi;
	wire s_out_i2s1_sdi;
	wire s_in_spim_sdio0;
	wire s_in_spim_sdio1;
	wire s_in_spim_sdio2;
	wire s_in_spim_sdio3;
	wire s_in_spim_csn0;
	wire s_in_spim_csn1;
	wire s_in_spim_sck;
	wire s_in_uart_rx;
	wire s_in_uart_tx;
	wire s_in_cam_pclk;
	wire s_in_cam_hsync;
	wire s_in_cam_data0;
	wire s_in_cam_data1;
	wire s_in_cam_data2;
	wire s_in_cam_data3;
	wire s_in_cam_data4;
	wire s_in_cam_data5;
	wire s_in_cam_data6;
	wire s_in_cam_data7;
	wire s_in_cam_vsync;
	wire s_in_sdio_clk;
	wire s_in_sdio_cmd;
	wire s_in_sdio_data0;
	wire s_in_sdio_data1;
	wire s_in_sdio_data2;
	wire s_in_sdio_data3;
	wire s_in_i2c0_sda;
	wire s_in_i2c0_scl;
	wire s_in_i2s0_sck;
	wire s_in_i2s0_ws;
	wire s_in_i2s0_sdi;
	wire s_in_i2s1_sdi;
	wire s_oe_spim_sdio0;
	wire s_oe_spim_sdio1;
	wire s_oe_spim_sdio2;
	wire s_oe_spim_sdio3;
	wire s_oe_spim_csn0;
	wire s_oe_spim_csn1;
	wire s_oe_spim_sck;
	wire s_oe_uart_rx;
	wire s_oe_uart_tx;
	wire s_oe_cam_pclk;
	wire s_oe_cam_hsync;
	wire s_oe_cam_data0;
	wire s_oe_cam_data1;
	wire s_oe_cam_data2;
	wire s_oe_cam_data3;
	wire s_oe_cam_data4;
	wire s_oe_cam_data5;
	wire s_oe_cam_data6;
	wire s_oe_cam_data7;
	wire s_oe_cam_vsync;
	wire s_oe_sdio_clk;
	wire s_oe_sdio_cmd;
	wire s_oe_sdio_data0;
	wire s_oe_sdio_data1;
	wire s_oe_sdio_data2;
	wire s_oe_sdio_data3;
	wire s_oe_i2c0_sda;
	wire s_oe_i2c0_scl;
	wire s_oe_i2s0_sck;
	wire s_oe_i2s0_ws;
	wire s_oe_i2s0_sdi;
	wire s_oe_i2s1_sdi;
	wire s_ref_clk;
	wire s_clk_soc_ext;
	wire s_clk_per_ext;
	wire s_rstn;
	wire s_jtag_tck;
	wire s_jtag_tdi;
	wire s_jtag_tdo;
	wire s_jtag_tms;
	wire s_jtag_trst;
	wire s_test_clk;
	wire s_slow_clk;
	wire s_sel_fll_clk;
	wire [11:0] s_pm_cfg_data;
	wire s_pm_cfg_req;
	wire s_pm_cfg_ack;
	wire s_cluster_busy;
	wire s_soc_tck;
	wire s_soc_trstn;
	wire s_soc_tms;
	wire s_soc_tdi;
	wire s_test_mode;
	wire s_dft_cg_enable;
	wire s_mode_select;
	wire [31:0] s_gpio_out;
	wire [31:0] s_gpio_in;
	wire [31:0] s_gpio_dir;
	wire [191:0] s_gpio_cfg;
	wire s_rf_tx_clk;
	wire s_rf_tx_oeb;
	wire s_rf_tx_enb;
	wire s_rf_tx_mode;
	wire s_rf_tx_vsel;
	wire s_rf_tx_data;
	wire s_rf_rx_clk;
	wire s_rf_rx_enb;
	wire s_rf_rx_data;
	wire s_uart_tx;
	wire s_uart_rx;
	wire s_i2c0_scl_out;
	wire s_i2c0_scl_in;
	wire s_i2c0_scl_oe;
	wire s_i2c0_sda_out;
	wire s_i2c0_sda_in;
	wire s_i2c0_sda_oe;
	wire s_i2c1_scl_out;
	wire s_i2c1_scl_in;
	wire s_i2c1_scl_oe;
	wire s_i2c1_sda_out;
	wire s_i2c1_sda_in;
	wire s_i2c1_sda_oe;
	wire s_i2s_sd0_in;
	wire s_i2s_sd1_in;
	wire s_i2s_sck_in;
	wire s_i2s_ws_in;
	wire s_i2s_sck0_out;
	wire s_i2s_ws0_out;
	wire [1:0] s_i2s_mode0_out;
	wire s_i2s_sck1_out;
	wire s_i2s_ws1_out;
	wire [1:0] s_i2s_mode1_out;
	wire s_i2s_slave_sck_oe;
	wire s_i2s_slave_ws_oe;
	wire s_spi_master0_csn0;
	wire s_spi_master0_csn1;
	wire s_spi_master0_sck;
	wire s_spi_master0_sdi0;
	wire s_spi_master0_sdi1;
	wire s_spi_master0_sdi2;
	wire s_spi_master0_sdi3;
	wire s_spi_master0_sdo0;
	wire s_spi_master0_sdo1;
	wire s_spi_master0_sdo2;
	wire s_spi_master0_sdo3;
	wire s_spi_master0_oen0;
	wire s_spi_master0_oen1;
	wire s_spi_master0_oen2;
	wire s_spi_master0_oen3;
	wire s_spi_master1_csn0;
	wire s_spi_master1_csn1;
	wire s_spi_master1_sck;
	wire s_spi_master1_sdi;
	wire s_spi_master1_sdo;
	wire [1:0] s_spi_master1_mode;
	wire s_sdio_clk;
	wire s_sdio_cmdi;
	wire s_sdio_cmdo;
	wire s_sdio_cmd_oen;
	wire [3:0] s_sdio_datai;
	wire [3:0] s_sdio_datao;
	wire [3:0] s_sdio_data_oen;
	wire s_cam_pclk;
	wire [7:0] s_cam_data;
	wire s_cam_hsync;
	wire s_cam_vsync;
	wire [3:0] s_timer0;
	wire [3:0] s_timer1;
	wire [3:0] s_timer2;
	wire [3:0] s_timer3;
	wire s_jtag_shift_dr;
	wire s_jtag_update_dr;
	wire s_jtag_capture_dr;
	wire s_axireg_sel;
	wire s_axireg_tdi;
	wire s_axireg_tdo;
	wire [7:0] s_soc_jtag_regi;
	wire [7:0] s_soc_jtag_rego;
	wire s_rstn_por;
	wire s_cluster_pow;
	wire s_cluster_byp;
	wire s_dma_pe_irq_ack;
	wire s_dma_pe_irq_valid;
	wire [127:0] s_pad_mux_soc;
	wire [383:0] s_pad_cfg_soc;
	wire s_dma_pe_evt_ack;
	wire s_dma_pe_evt_valid;
	wire s_dma_pe_int_ack;
	wire s_dma_pe_int_valid;
	wire s_pf_evt_ack;
	wire s_pf_evt_valid;
	wire [7:0] s_event_writetoken;
	wire [7:0] s_event_readpointer;
	wire [7:0] s_event_dataasync;
	wire s_cluster_irq;
	wire s_bootsel;
	wire s_pg_logic_rstn;
	wire s_pg_udma_rstn;
	wire s_gatemram_vdd;
	wire s_gatemram_vdda;
	wire s_gatemram_vref;
	wire s_hold_wu;
	wire s_step_wu;
	wire s_wu_bypass_en;
	wire s_wu_bypass_data_in;
	wire s_wu_bypass_shift;
	wire s_wu_bypass_mux;
	wire s_wu_bypass_data_out;
	wire s_ext_pg_logic;
	wire s_ext_pg_l2;
	wire s_ext_pg_l2_udma;
	wire s_ext_pg_l1;
	wire s_ext_pg_udma;
	wire s_ext_pg_mram;
	wire s_scan_en_in;
	wire s_soc_scan_in;
	wire s_soc_scan_out;
	wire s_per_scan_in;
	wire s_per_scan_out;
	wire s_ref_scan_in;
	wire s_ref_scan_out;
	APB_BUS apb_debug();
	XBAR_TCDM_BUS lint_debug();
	pad_frame pad_frame_i(
		.pad_cfg_i(s_pad_cfg),
		.ref_clk_o(s_ref_clk),
		.clk_soc_ext_o(s_clk_soc_ext),
		.clk_per_ext_o(s_clk_per_ext),
		.rstn_o(s_rstn),
		.jtag_tdo_i(s_jtag_tdo),
		.jtag_tck_o(s_jtag_tck),
		.jtag_tdi_o(s_jtag_tdi),
		.jtag_tms_o(s_jtag_tms),
		.jtag_trst_o(s_jtag_trst),
		.oe_spim_sdio0_i(s_oe_spim_sdio0),
		.oe_spim_sdio1_i(s_oe_spim_sdio1),
		.oe_spim_sdio2_i(s_oe_spim_sdio2),
		.oe_spim_sdio3_i(s_oe_spim_sdio3),
		.oe_spim_csn0_i(s_oe_spim_csn0),
		.oe_spim_csn1_i(s_oe_spim_csn1),
		.oe_spim_sck_i(s_oe_spim_sck),
		.oe_sdio_clk_i(s_oe_sdio_clk),
		.oe_sdio_cmd_i(s_oe_sdio_cmd),
		.oe_sdio_data0_i(s_oe_sdio_data0),
		.oe_sdio_data1_i(s_oe_sdio_data1),
		.oe_sdio_data2_i(s_oe_sdio_data2),
		.oe_sdio_data3_i(s_oe_sdio_data3),
		.oe_i2s0_sck_i(s_oe_i2s0_sck),
		.oe_i2s0_ws_i(s_oe_i2s0_ws),
		.oe_i2s0_sdi_i(s_oe_i2s0_sdi),
		.oe_i2s1_sdi_i(s_oe_i2s1_sdi),
		.oe_cam_pclk_i(s_oe_cam_pclk),
		.oe_cam_hsync_i(s_oe_cam_hsync),
		.oe_cam_data0_i(s_oe_cam_data0),
		.oe_cam_data1_i(s_oe_cam_data1),
		.oe_cam_data2_i(s_oe_cam_data2),
		.oe_cam_data3_i(s_oe_cam_data3),
		.oe_cam_data4_i(s_oe_cam_data4),
		.oe_cam_data5_i(s_oe_cam_data5),
		.oe_cam_data6_i(s_oe_cam_data6),
		.oe_cam_data7_i(s_oe_cam_data7),
		.oe_cam_vsync_i(s_oe_cam_vsync),
		.oe_i2c0_sda_i(s_oe_i2c0_sda),
		.oe_i2c0_scl_i(s_oe_i2c0_scl),
		.oe_uart_rx_i(s_oe_uart_rx),
		.oe_uart_tx_i(s_oe_uart_tx),
		.out_spim_sdio0_i(s_out_spim_sdio0),
		.out_spim_sdio1_i(s_out_spim_sdio1),
		.out_spim_sdio2_i(s_out_spim_sdio2),
		.out_spim_sdio3_i(s_out_spim_sdio3),
		.out_spim_csn0_i(s_out_spim_csn0),
		.out_spim_csn1_i(s_out_spim_csn1),
		.out_spim_sck_i(s_out_spim_sck),
		.out_sdio_clk_i(s_out_sdio_clk),
		.out_sdio_cmd_i(s_out_sdio_cmd),
		.out_sdio_data0_i(s_out_sdio_data0),
		.out_sdio_data1_i(s_out_sdio_data1),
		.out_sdio_data2_i(s_out_sdio_data2),
		.out_sdio_data3_i(s_out_sdio_data3),
		.out_i2s0_sck_i(s_out_i2s0_sck),
		.out_i2s0_ws_i(s_out_i2s0_ws),
		.out_i2s0_sdi_i(s_out_i2s0_sdi),
		.out_i2s1_sdi_i(s_out_i2s1_sdi),
		.out_cam_pclk_i(s_out_cam_pclk),
		.out_cam_hsync_i(s_out_cam_hsync),
		.out_cam_data0_i(s_out_cam_data0),
		.out_cam_data1_i(s_out_cam_data1),
		.out_cam_data2_i(s_out_cam_data2),
		.out_cam_data3_i(s_out_cam_data3),
		.out_cam_data4_i(s_out_cam_data4),
		.out_cam_data5_i(s_out_cam_data5),
		.out_cam_data6_i(s_out_cam_data6),
		.out_cam_data7_i(s_out_cam_data7),
		.out_cam_vsync_i(s_out_cam_vsync),
		.out_i2c0_sda_i(s_out_i2c0_sda),
		.out_i2c0_scl_i(s_out_i2c0_scl),
		.out_uart_rx_i(s_out_uart_rx),
		.out_uart_tx_i(s_out_uart_tx),
		.gatemram_vdd(s_gatemram_vdd),
		.gatemram_vdda(s_gatemram_vdda),
		.gatemram_vref(s_gatemram_vref),
		.hold_wu(s_hold_wu),
		.step_wu(s_step_wu),
		.wu_bypass_en(s_wu_bypass_en),
		.wu_bypass_data_in(s_wu_bypass_data_in),
		.wu_bypass_shift(s_wu_bypass_shift),
		.wu_bypass_mux(s_wu_bypass_mux),
		.wu_bypass_data_out(s_wu_bypass_data_out),
		.ext_pg_logic(s_ext_pg_logic),
		.ext_pg_l2(s_ext_pg_l2),
		.ext_pg_l2_udma(s_ext_pg_l2_udma),
		.ext_pg_l1(s_ext_pg_l1),
		.ext_pg_udma(s_ext_pg_udma),
		.ext_pg_mram(s_ext_pg_mram),
		.scan_en_in(s_scan_en_in),
		.soc_scan_in(s_soc_scan_in),
		.soc_scan_out(s_soc_scan_out),
		.per_scan_in(s_per_scan_in),
		.per_scan_out(s_per_scan_out),
		.ref_scan_in(s_ref_scan_in),
		.ref_scan_out(s_ref_scan_out),
		.in_spim_sdio0_o(s_in_spim_sdio0),
		.in_spim_sdio1_o(s_in_spim_sdio1),
		.in_spim_sdio2_o(s_in_spim_sdio2),
		.in_spim_sdio3_o(s_in_spim_sdio3),
		.in_spim_csn0_o(s_in_spim_csn0),
		.in_spim_csn1_o(s_in_spim_csn1),
		.in_spim_sck_o(s_in_spim_sck),
		.in_sdio_clk_o(s_in_sdio_clk),
		.in_sdio_cmd_o(s_in_sdio_cmd),
		.in_sdio_data0_mux_o(s_in_sdio_data0),
		.in_sdio_data1_mux_o(s_in_sdio_data1),
		.in_sdio_data2_mux_o(s_in_sdio_data2),
		.in_sdio_data3_o(s_in_sdio_data3),
		.in_i2s0_sck_o(s_in_i2s0_sck),
		.in_i2s0_ws_o(s_in_i2s0_ws),
		.in_i2s0_sdi_o(s_in_i2s0_sdi),
		.in_i2s1_sdi_o(s_in_i2s1_sdi),
		.in_cam_pclk_mux_o(s_in_cam_pclk),
		.in_cam_hsync_mux_o(s_in_cam_hsync),
		.in_cam_data0_mux_o(s_in_cam_data0),
		.in_cam_data1_mux_o(s_in_cam_data1),
		.in_cam_data2_mux_o(s_in_cam_data2),
		.in_cam_data3_mux_o(s_in_cam_data3),
		.in_cam_data4_mux_o(s_in_cam_data4),
		.in_cam_data5_mux_o(s_in_cam_data5),
		.in_cam_data6_mux_o(s_in_cam_data6),
		.in_cam_data7_mux_o(s_in_cam_data7),
		.in_cam_vsync_o(s_in_cam_vsync),
		.in_i2c0_sda_o(s_in_i2c0_sda),
		.in_i2c0_scl_o(s_in_i2c0_scl),
		.in_uart_rx_o(s_in_uart_rx),
		.in_uart_tx_o(s_in_uart_tx),
		.bootsel_o(s_bootsel),
		.pad_spim_sdio0(pad_spim_sdio0),
		.pad_spim_sdio1(pad_spim_sdio1),
		.pad_spim_sdio2(pad_spim_sdio2),
		.pad_spim_sdio3(pad_spim_sdio3),
		.pad_spim_csn0(pad_spim_csn0),
		.pad_spim_csn1(pad_spim_csn1),
		.pad_spim_sck(pad_spim_sck),
		.pad_sdio_clk(pad_sdio_clk),
		.pad_sdio_cmd(pad_sdio_cmd),
		.pad_sdio_data0(pad_sdio_data0),
		.pad_sdio_data1(pad_sdio_data1),
		.pad_sdio_data2(pad_sdio_data2),
		.pad_sdio_data3(pad_sdio_data3),
		.pad_i2s0_sck(pad_i2s0_sck),
		.pad_i2s0_ws(pad_i2s0_ws),
		.pad_i2s0_sdi(pad_i2s0_sdi),
		.pad_i2s1_sdi(pad_i2s1_sdi),
		.pad_cam_pclk(pad_cam_pclk),
		.pad_cam_hsync(pad_cam_hsync),
		.pad_cam_data0(pad_cam_data0),
		.pad_cam_data1(pad_cam_data1),
		.pad_cam_data2(pad_cam_data2),
		.pad_cam_data3(pad_cam_data3),
		.pad_cam_data4(pad_cam_data4),
		.pad_cam_data5(pad_cam_data5),
		.pad_cam_data6(pad_cam_data6),
		.pad_cam_data7(pad_cam_data7),
		.pad_cam_vsync(pad_cam_vsync),
		.pad_i2c0_sda(pad_i2c0_sda),
		.pad_i2c0_scl(pad_i2c0_scl),
		.pad_uart_rx(pad_uart_rx),
		.pad_uart_tx(pad_uart_tx),
		.pad_bootsel(pad_bootsel),
		.pad_reset_n(pad_reset_n),
		.pad_jtag_tck(pad_jtag_tck),
		.pad_jtag_tdi(pad_jtag_tdi),
		.pad_jtag_tdo(pad_jtag_tdo),
		.pad_jtag_tms(pad_jtag_tms),
		.pad_jtag_trst(pad_jtag_trst),
		.pad_xtal_in(pad_xtal_in),
		.pad_clk_soc_ext(pad_clk_soc_ext),
		.pad_clk_per_ext(pad_clk_per_ext),
		.pad_gatemram_vdd(pad_gatemram_vdd),
		.pad_gatemram_vdda(pad_gatemram_vdda),
		.pad_gatemram_vref(pad_gatemram_vref),
		.pad_hold_wu(pad_hold_wu),
		.pad_step_wu(pad_step_wu),
		.pad_wu_bypass_out(pad_wu_bypass_out),
		.pad_wu_bypass_mux(pad_wu_bypass_mux),
		.pad_debug_ctrl(pad_debug_ctrl),
		.pad_scan_en_in(pad_scan_en_in),
		.pad_soc_scan_out(pad_soc_scan_out),
		.pad_per_scan_out(pad_per_scan_out),
		.pad_ref_scan_out(pad_ref_scan_out)
	);
	safe_domain safe_domain_i(
		.ref_clk_i(s_ref_clk),
		.slow_clk_o(s_slow_clk),
		.rst_ni(s_rstn),
		.rst_no(s_rstn_por),
		.test_clk_o(s_test_clk),
		.test_mode_o(s_test_mode),
		.mode_select_o(s_mode_select),
		.dft_cg_enable_o(s_dft_cg_enable),
		.pad_cfg_o(s_pad_cfg),
		.pad_cfg_i(s_pad_cfg_soc),
		.pad_mux_i(s_pad_mux_soc),
		.gpio_out_i(s_gpio_out),
		.gpio_in_o(s_gpio_in),
		.gpio_dir_i(s_gpio_dir),
		.gpio_cfg_i(s_gpio_cfg),
		.uart_tx_i(s_uart_tx),
		.uart_rx_o(s_uart_rx),
		.i2c0_scl_out_i(s_i2c0_scl_out),
		.i2c0_scl_in_o(s_i2c0_scl_in),
		.i2c0_scl_oe_i(s_i2c0_scl_oe),
		.i2c0_sda_out_i(s_i2c0_sda_out),
		.i2c0_sda_in_o(s_i2c0_sda_in),
		.i2c0_sda_oe_i(s_i2c0_sda_oe),
		.i2c1_scl_out_i(s_i2c1_scl_out),
		.i2c1_scl_in_o(s_i2c1_scl_in),
		.i2c1_scl_oe_i(s_i2c1_scl_oe),
		.i2c1_sda_out_i(s_i2c1_sda_out),
		.i2c1_sda_in_o(s_i2c1_sda_in),
		.i2c1_sda_oe_i(s_i2c1_sda_oe),
		.i2s_slave_sd0_o(s_i2s_sd0_in),
		.i2s_slave_sd1_o(s_i2s_sd1_in),
		.i2s_slave_ws_o(s_i2s_ws_in),
		.i2s_slave_ws_i(s_i2s_ws0_out),
		.i2s_slave_ws_oe(s_i2s_slave_ws_oe),
		.i2s_slave_sck_o(s_i2s_sck_in),
		.i2s_slave_sck_i(s_i2s_sck0_out),
		.i2s_slave_sck_oe(s_i2s_slave_sck_oe),
		.spi_master0_csn0_i(s_spi_master0_csn0),
		.spi_master0_csn1_i(s_spi_master0_csn1),
		.spi_master0_sck_i(s_spi_master0_sck),
		.spi_master0_sdi0_o(s_spi_master0_sdi0),
		.spi_master0_sdi1_o(s_spi_master0_sdi1),
		.spi_master0_sdi2_o(s_spi_master0_sdi2),
		.spi_master0_sdi3_o(s_spi_master0_sdi3),
		.spi_master0_sdo0_i(s_spi_master0_sdo0),
		.spi_master0_sdo1_i(s_spi_master0_sdo1),
		.spi_master0_sdo2_i(s_spi_master0_sdo2),
		.spi_master0_sdo3_i(s_spi_master0_sdo3),
		.spi_master0_oen0_i(s_spi_master0_oen0),
		.spi_master0_oen1_i(s_spi_master0_oen1),
		.spi_master0_oen2_i(s_spi_master0_oen2),
		.spi_master0_oen3_i(s_spi_master0_oen3),
		.spi_master1_csn0_i(1'b1),
		.spi_master1_csn1_i(1'b1),
		.spi_master1_sck_i(1'b0),
		.spi_master1_sdo_i(1'b0),
		.spi_master1_mode_i(2'b00),
		.sdio_clk_i(s_sdio_clk),
		.sdio_cmd_i(s_sdio_cmdo),
		.sdio_cmd_o(s_sdio_cmdi),
		.sdio_cmd_oen_i(s_sdio_cmd_oen),
		.sdio_data_i(s_sdio_datao),
		.sdio_data_o(s_sdio_datai),
		.sdio_data_oen_i(s_sdio_data_oen),
		.cam_pclk_o(s_cam_pclk),
		.cam_data_o(s_cam_data),
		.cam_hsync_o(s_cam_hsync),
		.cam_vsync_o(s_cam_vsync),
		.timer0_i(s_timer0),
		.timer1_i(s_timer1),
		.timer2_i(s_timer2),
		.timer3_i(s_timer3),
		.out_spim_sdio0_o(s_out_spim_sdio0),
		.out_spim_sdio1_o(s_out_spim_sdio1),
		.out_spim_sdio2_o(s_out_spim_sdio2),
		.out_spim_sdio3_o(s_out_spim_sdio3),
		.out_spim_csn0_o(s_out_spim_csn0),
		.out_spim_csn1_o(s_out_spim_csn1),
		.out_spim_sck_o(s_out_spim_sck),
		.out_sdio_clk_o(s_out_sdio_clk),
		.out_sdio_cmd_o(s_out_sdio_cmd),
		.out_sdio_data0_o(s_out_sdio_data0),
		.out_sdio_data1_o(s_out_sdio_data1),
		.out_sdio_data2_o(s_out_sdio_data2),
		.out_sdio_data3_o(s_out_sdio_data3),
		.out_uart_rx_o(s_out_uart_rx),
		.out_uart_tx_o(s_out_uart_tx),
		.out_cam_pclk_o(s_out_cam_pclk),
		.out_cam_hsync_o(s_out_cam_hsync),
		.out_cam_data0_o(s_out_cam_data0),
		.out_cam_data1_o(s_out_cam_data1),
		.out_cam_data2_o(s_out_cam_data2),
		.out_cam_data3_o(s_out_cam_data3),
		.out_cam_data4_o(s_out_cam_data4),
		.out_cam_data5_o(s_out_cam_data5),
		.out_cam_data6_o(s_out_cam_data6),
		.out_cam_data7_o(s_out_cam_data7),
		.out_cam_vsync_o(s_out_cam_vsync),
		.out_i2c0_sda_o(s_out_i2c0_sda),
		.out_i2c0_scl_o(s_out_i2c0_scl),
		.out_i2s0_sck_o(s_out_i2s0_sck),
		.out_i2s0_ws_o(s_out_i2s0_ws),
		.out_i2s0_sdi_o(s_out_i2s0_sdi),
		.out_i2s1_sdi_o(s_out_i2s1_sdi),
		.in_spim_sdio0_i(s_in_spim_sdio0),
		.in_spim_sdio1_i(s_in_spim_sdio1),
		.in_spim_sdio2_i(s_in_spim_sdio2),
		.in_spim_sdio3_i(s_in_spim_sdio3),
		.in_spim_csn0_i(s_in_spim_csn0),
		.in_spim_csn1_i(s_in_spim_csn1),
		.in_spim_sck_i(s_in_spim_sck),
		.in_sdio_clk_i(s_in_sdio_clk),
		.in_sdio_cmd_i(s_in_sdio_cmd),
		.in_sdio_data0_i(s_in_sdio_data0),
		.in_sdio_data1_i(s_in_sdio_data1),
		.in_sdio_data2_i(s_in_sdio_data2),
		.in_sdio_data3_i(s_in_sdio_data3),
		.in_uart_rx_i(s_in_uart_rx),
		.in_uart_tx_i(s_in_uart_tx),
		.in_cam_pclk_i(s_in_cam_pclk),
		.in_cam_hsync_i(s_in_cam_hsync),
		.in_cam_data0_i(s_in_cam_data0),
		.in_cam_data1_i(s_in_cam_data1),
		.in_cam_data2_i(s_in_cam_data2),
		.in_cam_data3_i(s_in_cam_data3),
		.in_cam_data4_i(s_in_cam_data4),
		.in_cam_data5_i(s_in_cam_data5),
		.in_cam_data6_i(s_in_cam_data6),
		.in_cam_data7_i(s_in_cam_data7),
		.in_cam_vsync_i(s_in_cam_vsync),
		.in_i2c0_sda_i(s_in_i2c0_sda),
		.in_i2c0_scl_i(s_in_i2c0_scl),
		.in_i2s0_sck_i(s_in_i2s0_sck),
		.in_i2s0_ws_i(s_in_i2s0_ws),
		.in_i2s0_sdi_i(s_in_i2s0_sdi),
		.in_i2s1_sdi_i(s_in_i2s1_sdi),
		.oe_spim_sdio0_o(s_oe_spim_sdio0),
		.oe_spim_sdio1_o(s_oe_spim_sdio1),
		.oe_spim_sdio2_o(s_oe_spim_sdio2),
		.oe_spim_sdio3_o(s_oe_spim_sdio3),
		.oe_spim_csn0_o(s_oe_spim_csn0),
		.oe_spim_csn1_o(s_oe_spim_csn1),
		.oe_spim_sck_o(s_oe_spim_sck),
		.oe_sdio_clk_o(s_oe_sdio_clk),
		.oe_sdio_cmd_o(s_oe_sdio_cmd),
		.oe_sdio_data0_o(s_oe_sdio_data0),
		.oe_sdio_data1_o(s_oe_sdio_data1),
		.oe_sdio_data2_o(s_oe_sdio_data2),
		.oe_sdio_data3_o(s_oe_sdio_data3),
		.oe_uart_rx_o(s_oe_uart_rx),
		.oe_uart_tx_o(s_oe_uart_tx),
		.oe_cam_pclk_o(s_oe_cam_pclk),
		.oe_cam_hsync_o(s_oe_cam_hsync),
		.oe_cam_data0_o(s_oe_cam_data0),
		.oe_cam_data1_o(s_oe_cam_data1),
		.oe_cam_data2_o(s_oe_cam_data2),
		.oe_cam_data3_o(s_oe_cam_data3),
		.oe_cam_data4_o(s_oe_cam_data4),
		.oe_cam_data5_o(s_oe_cam_data5),
		.oe_cam_data6_o(s_oe_cam_data6),
		.oe_cam_data7_o(s_oe_cam_data7),
		.oe_cam_vsync_o(s_oe_cam_vsync),
		.oe_i2c0_sda_o(s_oe_i2c0_sda),
		.oe_i2c0_scl_o(s_oe_i2c0_scl),
		.oe_i2s0_sck_o(s_oe_i2s0_sck),
		.oe_i2s0_ws_o(s_oe_i2s0_ws),
		.oe_i2s0_sdi_o(s_oe_i2s0_sdi),
		.oe_i2s1_sdi_o(s_oe_i2s1_sdi)
	);
	localparam [7:0] sv2v_uu_soc_domain_i_ext_data_slave_aw_writetoken_i_0 = 1'sb0;
	localparam sv2v_uu_soc_domain_i_AXI_ADDR_WIDTH = AXI_ADDR_WIDTH;
	localparam [31:0] sv2v_uu_soc_domain_i_ext_data_slave_aw_addr_i_0 = 1'sb0;
	localparam [2:0] sv2v_uu_soc_domain_i_ext_data_slave_aw_prot_i_0 = 1'sb0;
	localparam [3:0] sv2v_uu_soc_domain_i_ext_data_slave_aw_region_i_0 = 1'sb0;
	localparam [7:0] sv2v_uu_soc_domain_i_ext_data_slave_aw_len_i_0 = 1'sb0;
	localparam [2:0] sv2v_uu_soc_domain_i_ext_data_slave_aw_size_i_0 = 1'sb0;
	localparam [1:0] sv2v_uu_soc_domain_i_ext_data_slave_aw_burst_i_0 = 1'sb0;
	localparam [0:0] sv2v_uu_soc_domain_i_ext_data_slave_aw_lock_i_0 = 1'sb0;
	localparam [3:0] sv2v_uu_soc_domain_i_ext_data_slave_aw_cache_i_0 = 1'sb0;
	localparam [3:0] sv2v_uu_soc_domain_i_ext_data_slave_aw_qos_i_0 = 1'sb0;
	localparam sv2v_uu_soc_domain_i_AXI_ID_IN_WIDTH = AXI_CLUSTER_SOC_ID_WIDTH;
	localparam [5:0] sv2v_uu_soc_domain_i_ext_data_slave_aw_id_i_0 = 1'sb0;
	localparam sv2v_uu_soc_domain_i_AXI_USER_WIDTH = AXI_USER_WIDTH;
	localparam [5:0] sv2v_uu_soc_domain_i_ext_data_slave_aw_user_i_0 = 1'sb0;
	localparam [7:0] sv2v_uu_soc_domain_i_ext_data_slave_ar_writetoken_i_0 = 1'sb0;
	localparam [31:0] sv2v_uu_soc_domain_i_ext_data_slave_ar_addr_i_0 = 1'sb0;
	localparam [2:0] sv2v_uu_soc_domain_i_ext_data_slave_ar_prot_i_0 = 1'sb0;
	localparam [3:0] sv2v_uu_soc_domain_i_ext_data_slave_ar_region_i_0 = 1'sb0;
	localparam [7:0] sv2v_uu_soc_domain_i_ext_data_slave_ar_len_i_0 = 1'sb0;
	localparam [2:0] sv2v_uu_soc_domain_i_ext_data_slave_ar_size_i_0 = 1'sb0;
	localparam [1:0] sv2v_uu_soc_domain_i_ext_data_slave_ar_burst_i_0 = 1'sb0;
	localparam [0:0] sv2v_uu_soc_domain_i_ext_data_slave_ar_lock_i_0 = 1'sb0;
	localparam [3:0] sv2v_uu_soc_domain_i_ext_data_slave_ar_cache_i_0 = 1'sb0;
	localparam [3:0] sv2v_uu_soc_domain_i_ext_data_slave_ar_qos_i_0 = 1'sb0;
	localparam [5:0] sv2v_uu_soc_domain_i_ext_data_slave_ar_id_i_0 = 1'sb0;
	localparam [5:0] sv2v_uu_soc_domain_i_ext_data_slave_ar_user_i_0 = 1'sb0;
	localparam [7:0] sv2v_uu_soc_domain_i_ext_data_slave_w_writetoken_i_0 = 1'sb0;
	localparam sv2v_uu_soc_domain_i_AXI_DATA_IN_WIDTH = AXI_CLUSTER_SOC_DATA_WIDTH;
	localparam [63:0] sv2v_uu_soc_domain_i_ext_data_slave_w_data_i_0 = 1'sb0;
	localparam sv2v_uu_soc_domain_i_AXI_STRB_IN_WIDTH = AXI_CLUSTER_SOC_STRB_WIDTH;
	localparam [7:0] sv2v_uu_soc_domain_i_ext_data_slave_w_strb_i_0 = 1'sb0;
	localparam [5:0] sv2v_uu_soc_domain_i_ext_data_slave_w_user_i_0 = 1'sb0;
	localparam [0:0] sv2v_uu_soc_domain_i_ext_data_slave_w_last_i_0 = 1'sb0;
	localparam [7:0] sv2v_uu_soc_domain_i_ext_data_slave_r_readpointer_i_0 = 1'sb0;
	localparam [7:0] sv2v_uu_soc_domain_i_ext_data_slave_b_readpointer_i_0 = 1'sb0;
	localparam [7:0] sv2v_uu_soc_domain_i_ext_data_master_aw_readpointer_i_0 = 1'sb0;
	localparam [7:0] sv2v_uu_soc_domain_i_ext_data_master_ar_readpointer_i_0 = 1'sb0;
	localparam [7:0] sv2v_uu_soc_domain_i_ext_data_master_w_readpointer_i_0 = 1'sb0;
	localparam [7:0] sv2v_uu_soc_domain_i_ext_data_master_r_writetoken_i_0 = 1'sb0;
	localparam sv2v_uu_soc_domain_i_AXI_DATA_OUT_WIDTH = AXI_SOC_CLUSTER_DATA_WIDTH;
	localparam [31:0] sv2v_uu_soc_domain_i_ext_data_master_r_data_i_0 = 1'sb0;
	localparam [1:0] sv2v_uu_soc_domain_i_ext_data_master_r_resp_i_0 = 1'sb0;
	localparam [0:0] sv2v_uu_soc_domain_i_ext_data_master_r_last_i_0 = 1'sb0;
	localparam sv2v_uu_soc_domain_i_AXI_ID_OUT_WIDTH = AXI_SOC_CLUSTER_ID_WIDTH;
	localparam [5:0] sv2v_uu_soc_domain_i_ext_data_master_r_id_i_0 = 1'sb0;
	localparam [5:0] sv2v_uu_soc_domain_i_ext_data_master_r_user_i_0 = 1'sb0;
	localparam [7:0] sv2v_uu_soc_domain_i_ext_data_master_b_writetoken_i_0 = 1'sb0;
	localparam [1:0] sv2v_uu_soc_domain_i_ext_data_master_b_resp_i_0 = 1'sb0;
	localparam [5:0] sv2v_uu_soc_domain_i_ext_data_master_b_id_i_0 = 1'sb0;
	localparam [5:0] sv2v_uu_soc_domain_i_ext_data_master_b_user_i_0 = 1'sb0;
	soc_domain #(
		.CORE_TYPE(CORE_TYPE),
		.USE_FPU(USE_FPU),
		.USE_HWPE(USE_HWPE),
		.AXI_ADDR_WIDTH(AXI_ADDR_WIDTH),
		.AXI_DATA_IN_WIDTH(AXI_CLUSTER_SOC_DATA_WIDTH),
		.AXI_DATA_OUT_WIDTH(AXI_SOC_CLUSTER_DATA_WIDTH),
		.AXI_ID_IN_WIDTH(AXI_CLUSTER_SOC_ID_WIDTH),
		.AXI_ID_OUT_WIDTH(AXI_SOC_CLUSTER_ID_WIDTH),
		.AXI_USER_WIDTH(AXI_USER_WIDTH),
		.AXI_STRB_IN_WIDTH(AXI_CLUSTER_SOC_STRB_WIDTH),
		.AXI_STRB_OUT_WIDTH(AXI_SOC_CLUSTER_STRB_WIDTH),
		.BUFFER_WIDTH(BUFFER_WIDTH),
		.EVNT_WIDTH(EVENT_WIDTH)
	) soc_domain_i(
		.ref_clk_i(s_ref_clk),
		.clk_soc_ext_i(s_clk_soc_ext),
		.clk_per_ext_i(s_clk_per_ext),
		.slow_clk_i(s_slow_clk),
		.test_clk_i(s_test_clk),
		.rstn_glob_i(s_rstn_por),
		.mode_select_i(s_mode_select),
		.dft_cg_enable_i(s_dft_cg_enable),
		.dft_test_mode_i(s_scan_en_in),
		.bootsel_i(s_bootsel),
		.jtag_tck_i(s_jtag_tck),
		.jtag_trst_ni(s_jtag_trst),
		.jtag_tms_i(s_jtag_tms),
		.jtag_tdi_i(s_jtag_tdi),
		.jtag_tdo_o(s_jtag_tdo),
		.pad_cfg_o(s_pad_cfg_soc),
		.pad_mux_o(s_pad_mux_soc),
		.gpio_in_i(s_gpio_in),
		.gpio_out_o(s_gpio_out),
		.gpio_dir_o(s_gpio_dir),
		.gpio_cfg_o(s_gpio_cfg),
		.uart_tx_o(s_uart_tx),
		.uart_rx_i(s_uart_rx),
		.cam_clk_i(s_cam_pclk),
		.cam_data_i(s_cam_data),
		.cam_hsync_i(s_cam_hsync),
		.cam_vsync_i(s_cam_vsync),
		.timer_ch0_o(s_timer0),
		.timer_ch1_o(s_timer1),
		.timer_ch2_o(s_timer2),
		.timer_ch3_o(s_timer3),
		.i2c0_scl_i(s_i2c0_scl_in),
		.i2c0_scl_o(s_i2c0_scl_out),
		.i2c0_scl_oe_o(s_i2c0_scl_oe),
		.i2c0_sda_i(s_i2c0_sda_in),
		.i2c0_sda_o(s_i2c0_sda_out),
		.i2c0_sda_oe_o(s_i2c0_sda_oe),
		.i2c1_scl_i(s_i2c1_scl_in),
		.i2c1_scl_o(s_i2c1_scl_out),
		.i2c1_scl_oe_o(s_i2c1_scl_oe),
		.i2c1_sda_i(s_i2c1_sda_in),
		.i2c1_sda_o(s_i2c1_sda_out),
		.i2c1_sda_oe_o(s_i2c1_sda_oe),
		.i2s_slave_sd0_i(s_i2s_sd0_in),
		.i2s_slave_sd1_i(s_i2s_sd1_in),
		.i2s_slave_ws_i(s_i2s_ws_in),
		.i2s_slave_ws_o(s_i2s_ws0_out),
		.i2s_slave_ws_oe(s_i2s_slave_ws_oe),
		.i2s_slave_sck_i(s_i2s_sck_in),
		.i2s_slave_sck_o(s_i2s_sck0_out),
		.i2s_slave_sck_oe(s_i2s_slave_sck_oe),
		.spi_master0_clk_o(s_spi_master0_sck),
		.spi_master0_csn0_o(s_spi_master0_csn0),
		.spi_master0_csn1_o(s_spi_master0_csn1),
		.spi_master0_oen0_o(s_spi_master0_oen0),
		.spi_master0_oen1_o(s_spi_master0_oen1),
		.spi_master0_oen2_o(s_spi_master0_oen2),
		.spi_master0_oen3_o(s_spi_master0_oen3),
		.spi_master0_sdo0_o(s_spi_master0_sdo0),
		.spi_master0_sdo1_o(s_spi_master0_sdo1),
		.spi_master0_sdo2_o(s_spi_master0_sdo2),
		.spi_master0_sdo3_o(s_spi_master0_sdo3),
		.spi_master0_sdi0_i(s_spi_master0_sdi0),
		.spi_master0_sdi1_i(s_spi_master0_sdi1),
		.spi_master0_sdi2_i(s_spi_master0_sdi2),
		.spi_master0_sdi3_i(s_spi_master0_sdi3),
		.sdio_clk_o(s_sdio_clk),
		.sdio_cmd_o(s_sdio_cmdo),
		.sdio_cmd_i(s_sdio_cmdi),
		.sdio_cmd_oen_o(s_sdio_cmd_oen),
		.sdio_data_o(s_sdio_datao),
		.sdio_data_i(s_sdio_datai),
		.sdio_data_oen_o(s_sdio_data_oen),
		.cluster_busy_i(s_cluster_busy),
		.cluster_events_wt_o(s_event_writetoken),
		.cluster_events_rp_i(s_event_readpointer),
		.cluster_events_da_o(s_event_dataasync),
		.cluster_irq_o(s_cluster_irq),
		.dma_pe_evt_ack_o(s_dma_pe_evt_ack),
		.dma_pe_evt_valid_i(s_dma_pe_evt_valid),
		.dma_pe_irq_ack_o(s_dma_pe_irq_ack),
		.dma_pe_irq_valid_i(s_dma_pe_irq_valid),
		.pf_evt_ack_o(s_pf_evt_ack),
		.pf_evt_valid_i(s_pf_evt_valid),
		.cluster_pow_o(s_cluster_pow),
		.cluster_byp_o(s_cluster_byp),
		.data_slave_aw_writetoken_i(sv2v_uu_soc_domain_i_ext_data_slave_aw_writetoken_i_0),
		.data_slave_aw_addr_i(sv2v_uu_soc_domain_i_ext_data_slave_aw_addr_i_0),
		.data_slave_aw_prot_i(sv2v_uu_soc_domain_i_ext_data_slave_aw_prot_i_0),
		.data_slave_aw_region_i(sv2v_uu_soc_domain_i_ext_data_slave_aw_region_i_0),
		.data_slave_aw_len_i(sv2v_uu_soc_domain_i_ext_data_slave_aw_len_i_0),
		.data_slave_aw_size_i(sv2v_uu_soc_domain_i_ext_data_slave_aw_size_i_0),
		.data_slave_aw_burst_i(sv2v_uu_soc_domain_i_ext_data_slave_aw_burst_i_0),
		.data_slave_aw_lock_i(sv2v_uu_soc_domain_i_ext_data_slave_aw_lock_i_0),
		.data_slave_aw_cache_i(sv2v_uu_soc_domain_i_ext_data_slave_aw_cache_i_0),
		.data_slave_aw_qos_i(sv2v_uu_soc_domain_i_ext_data_slave_aw_qos_i_0),
		.data_slave_aw_id_i(sv2v_uu_soc_domain_i_ext_data_slave_aw_id_i_0),
		.data_slave_aw_user_i(sv2v_uu_soc_domain_i_ext_data_slave_aw_user_i_0),
		.data_slave_ar_writetoken_i(sv2v_uu_soc_domain_i_ext_data_slave_ar_writetoken_i_0),
		.data_slave_ar_addr_i(sv2v_uu_soc_domain_i_ext_data_slave_ar_addr_i_0),
		.data_slave_ar_prot_i(sv2v_uu_soc_domain_i_ext_data_slave_ar_prot_i_0),
		.data_slave_ar_region_i(sv2v_uu_soc_domain_i_ext_data_slave_ar_region_i_0),
		.data_slave_ar_len_i(sv2v_uu_soc_domain_i_ext_data_slave_ar_len_i_0),
		.data_slave_ar_size_i(sv2v_uu_soc_domain_i_ext_data_slave_ar_size_i_0),
		.data_slave_ar_burst_i(sv2v_uu_soc_domain_i_ext_data_slave_ar_burst_i_0),
		.data_slave_ar_lock_i(sv2v_uu_soc_domain_i_ext_data_slave_ar_lock_i_0),
		.data_slave_ar_cache_i(sv2v_uu_soc_domain_i_ext_data_slave_ar_cache_i_0),
		.data_slave_ar_qos_i(sv2v_uu_soc_domain_i_ext_data_slave_ar_qos_i_0),
		.data_slave_ar_id_i(sv2v_uu_soc_domain_i_ext_data_slave_ar_id_i_0),
		.data_slave_ar_user_i(sv2v_uu_soc_domain_i_ext_data_slave_ar_user_i_0),
		.data_slave_w_writetoken_i(sv2v_uu_soc_domain_i_ext_data_slave_w_writetoken_i_0),
		.data_slave_w_data_i(sv2v_uu_soc_domain_i_ext_data_slave_w_data_i_0),
		.data_slave_w_strb_i(sv2v_uu_soc_domain_i_ext_data_slave_w_strb_i_0),
		.data_slave_w_user_i(sv2v_uu_soc_domain_i_ext_data_slave_w_user_i_0),
		.data_slave_w_last_i(sv2v_uu_soc_domain_i_ext_data_slave_w_last_i_0),
		.data_slave_r_readpointer_i(sv2v_uu_soc_domain_i_ext_data_slave_r_readpointer_i_0),
		.data_slave_b_readpointer_i(sv2v_uu_soc_domain_i_ext_data_slave_b_readpointer_i_0),
		.data_master_aw_readpointer_i(sv2v_uu_soc_domain_i_ext_data_master_aw_readpointer_i_0),
		.data_master_ar_readpointer_i(sv2v_uu_soc_domain_i_ext_data_master_ar_readpointer_i_0),
		.data_master_w_readpointer_i(sv2v_uu_soc_domain_i_ext_data_master_w_readpointer_i_0),
		.data_master_r_writetoken_i(sv2v_uu_soc_domain_i_ext_data_master_r_writetoken_i_0),
		.data_master_r_data_i(sv2v_uu_soc_domain_i_ext_data_master_r_data_i_0),
		.data_master_r_resp_i(sv2v_uu_soc_domain_i_ext_data_master_r_resp_i_0),
		.data_master_r_last_i(sv2v_uu_soc_domain_i_ext_data_master_r_last_i_0),
		.data_master_r_id_i(sv2v_uu_soc_domain_i_ext_data_master_r_id_i_0),
		.data_master_r_user_i(sv2v_uu_soc_domain_i_ext_data_master_r_user_i_0),
		.data_master_b_writetoken_i(sv2v_uu_soc_domain_i_ext_data_master_b_writetoken_i_0),
		.data_master_b_resp_i(sv2v_uu_soc_domain_i_ext_data_master_b_resp_i_0),
		.data_master_b_id_i(sv2v_uu_soc_domain_i_ext_data_master_b_id_i_0),
		.data_master_b_user_i(sv2v_uu_soc_domain_i_ext_data_master_b_user_i_0),
		.pg_logic_rstn_o(s_pg_logic_rstn),
		.pg_udma_rstn_o(s_pg_udma_rstn),
		.VDD_out_pg(s_gatemram_vdd),
		.VDDA_out_pg(s_gatemram_vdda),
		.VREF_out_pg(s_gatemram_vref),
		.hold_wu(s_hold_wu),
		.step_wu(s_step_wu),
		.wu_bypass_en(s_wu_bypass_en),
		.wu_bypass_data_in(s_wu_bypass_data_in),
		.wu_bypass_shift(s_wu_bypass_shift),
		.wu_bypass_mux(s_wu_bypass_mux),
		.wu_bypass_data_out(s_wu_bypass_data_out),
		.ext_pg_logic(s_ext_pg_logic),
		.ext_pg_l2(s_ext_pg_l2),
		.ext_pg_l2_udma(s_ext_pg_l2_udma),
		.ext_pg_l1(s_ext_pg_l1),
		.ext_pg_udma(s_ext_pg_udma),
		.ext_pg_mram(s_ext_pg_mram),
		.scan_en_in(s_scan_en_in)
	);
	assign s_dma_pe_evt_valid = 1'sb0;
	assign s_dma_pe_irq_valid = 1'sb0;
	assign s_pf_evt_valid = 1'sb0;
	assign s_cluster_busy = 1'sb0;
	wire s_so;
	assign s_so = 1'sb0;
endmodule
