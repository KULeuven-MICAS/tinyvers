module safe_domain (
	ref_clk_i,
	slow_clk_o,
	rst_ni,
	rst_no,
	test_clk_o,
	test_mode_o,
	mode_select_o,
	dft_cg_enable_o,
	pad_mux_i,
	pad_cfg_i,
	pad_cfg_o,
	gpio_out_i,
	gpio_in_o,
	gpio_dir_i,
	gpio_cfg_i,
	uart_tx_i,
	uart_rx_o,
	i2c0_scl_out_i,
	i2c0_scl_in_o,
	i2c0_scl_oe_i,
	i2c0_sda_out_i,
	i2c0_sda_in_o,
	i2c0_sda_oe_i,
	i2c1_scl_out_i,
	i2c1_scl_in_o,
	i2c1_scl_oe_i,
	i2c1_sda_out_i,
	i2c1_sda_in_o,
	i2c1_sda_oe_i,
	i2s_slave_sd0_o,
	i2s_slave_sd1_o,
	i2s_slave_ws_o,
	i2s_slave_ws_i,
	i2s_slave_ws_oe,
	i2s_slave_sck_o,
	i2s_slave_sck_i,
	i2s_slave_sck_oe,
	spi_master0_csn0_i,
	spi_master0_csn1_i,
	spi_master0_sck_i,
	spi_master0_sdi0_o,
	spi_master0_sdi1_o,
	spi_master0_sdi2_o,
	spi_master0_sdi3_o,
	spi_master0_sdo0_i,
	spi_master0_sdo1_i,
	spi_master0_sdo2_i,
	spi_master0_sdo3_i,
	spi_master0_oen0_i,
	spi_master0_oen1_i,
	spi_master0_oen2_i,
	spi_master0_oen3_i,
	spi_master1_csn0_i,
	spi_master1_csn1_i,
	spi_master1_sck_i,
	spi_master1_sdi_o,
	spi_master1_sdo_i,
	spi_master1_mode_i,
	sdio_clk_i,
	sdio_cmd_i,
	sdio_cmd_o,
	sdio_cmd_oen_i,
	sdio_data_i,
	sdio_data_o,
	sdio_data_oen_i,
	cam_pclk_o,
	cam_data_o,
	cam_hsync_o,
	cam_vsync_o,
	timer0_i,
	timer1_i,
	timer2_i,
	timer3_i,
	out_spim_sdio0_o,
	out_spim_sdio1_o,
	out_spim_sdio2_o,
	out_spim_sdio3_o,
	out_spim_csn0_o,
	out_spim_csn1_o,
	out_spim_sck_o,
	out_sdio_clk_o,
	out_sdio_cmd_o,
	out_sdio_data0_o,
	out_sdio_data1_o,
	out_sdio_data2_o,
	out_sdio_data3_o,
	out_uart_rx_o,
	out_uart_tx_o,
	out_cam_pclk_o,
	out_cam_hsync_o,
	out_cam_data0_o,
	out_cam_data1_o,
	out_cam_data2_o,
	out_cam_data3_o,
	out_cam_data4_o,
	out_cam_data5_o,
	out_cam_data6_o,
	out_cam_data7_o,
	out_cam_vsync_o,
	out_i2c0_sda_o,
	out_i2c0_scl_o,
	out_i2s0_sck_o,
	out_i2s0_ws_o,
	out_i2s0_sdi_o,
	out_i2s1_sdi_o,
	in_spim_sdio0_i,
	in_spim_sdio1_i,
	in_spim_sdio2_i,
	in_spim_sdio3_i,
	in_spim_csn0_i,
	in_spim_csn1_i,
	in_spim_sck_i,
	in_sdio_clk_i,
	in_sdio_cmd_i,
	in_sdio_data0_i,
	in_sdio_data1_i,
	in_sdio_data2_i,
	in_sdio_data3_i,
	in_uart_rx_i,
	in_uart_tx_i,
	in_cam_pclk_i,
	in_cam_hsync_i,
	in_cam_data0_i,
	in_cam_data1_i,
	in_cam_data2_i,
	in_cam_data3_i,
	in_cam_data4_i,
	in_cam_data5_i,
	in_cam_data6_i,
	in_cam_data7_i,
	in_cam_vsync_i,
	in_i2c0_sda_i,
	in_i2c0_scl_i,
	in_i2s0_sck_i,
	in_i2s0_ws_i,
	in_i2s0_sdi_i,
	in_i2s1_sdi_i,
	oe_spim_sdio0_o,
	oe_spim_sdio1_o,
	oe_spim_sdio2_o,
	oe_spim_sdio3_o,
	oe_spim_csn0_o,
	oe_spim_csn1_o,
	oe_spim_sck_o,
	oe_sdio_clk_o,
	oe_sdio_cmd_o,
	oe_sdio_data0_o,
	oe_sdio_data1_o,
	oe_sdio_data2_o,
	oe_sdio_data3_o,
	oe_uart_rx_o,
	oe_uart_tx_o,
	oe_cam_pclk_o,
	oe_cam_hsync_o,
	oe_cam_data0_o,
	oe_cam_data1_o,
	oe_cam_data2_o,
	oe_cam_data3_o,
	oe_cam_data4_o,
	oe_cam_data5_o,
	oe_cam_data6_o,
	oe_cam_data7_o,
	oe_cam_vsync_o,
	oe_i2c0_sda_o,
	oe_i2c0_scl_o,
	oe_i2s0_sck_o,
	oe_i2s0_ws_o,
	oe_i2s0_sdi_o,
	oe_i2s1_sdi_o
);
	parameter FLL_DATA_WIDTH = 32;
	parameter FLL_ADDR_WIDTH = 32;
	input wire ref_clk_i;
	output wire slow_clk_o;
	input wire rst_ni;
	output wire rst_no;
	output wire test_clk_o;
	output wire test_mode_o;
	output wire mode_select_o;
	output wire dft_cg_enable_o;
	input wire [127:0] pad_mux_i;
	input wire [383:0] pad_cfg_i;
	output wire [287:0] pad_cfg_o;
	input wire [31:0] gpio_out_i;
	output wire [31:0] gpio_in_o;
	input wire [31:0] gpio_dir_i;
	input wire [191:0] gpio_cfg_i;
	input wire uart_tx_i;
	output wire uart_rx_o;
	input wire i2c0_scl_out_i;
	output wire i2c0_scl_in_o;
	input wire i2c0_scl_oe_i;
	input wire i2c0_sda_out_i;
	output wire i2c0_sda_in_o;
	input wire i2c0_sda_oe_i;
	input wire i2c1_scl_out_i;
	output wire i2c1_scl_in_o;
	input wire i2c1_scl_oe_i;
	input wire i2c1_sda_out_i;
	output wire i2c1_sda_in_o;
	input wire i2c1_sda_oe_i;
	output wire i2s_slave_sd0_o;
	output wire i2s_slave_sd1_o;
	output wire i2s_slave_ws_o;
	input wire i2s_slave_ws_i;
	input wire i2s_slave_ws_oe;
	output wire i2s_slave_sck_o;
	input wire i2s_slave_sck_i;
	input wire i2s_slave_sck_oe;
	input wire spi_master0_csn0_i;
	input wire spi_master0_csn1_i;
	input wire spi_master0_sck_i;
	output wire spi_master0_sdi0_o;
	output wire spi_master0_sdi1_o;
	output wire spi_master0_sdi2_o;
	output wire spi_master0_sdi3_o;
	input wire spi_master0_sdo0_i;
	input wire spi_master0_sdo1_i;
	input wire spi_master0_sdo2_i;
	input wire spi_master0_sdo3_i;
	input wire spi_master0_oen0_i;
	input wire spi_master0_oen1_i;
	input wire spi_master0_oen2_i;
	input wire spi_master0_oen3_i;
	input wire spi_master1_csn0_i;
	input wire spi_master1_csn1_i;
	input wire spi_master1_sck_i;
	output wire spi_master1_sdi_o;
	input wire spi_master1_sdo_i;
	input wire [1:0] spi_master1_mode_i;
	input wire sdio_clk_i;
	input wire sdio_cmd_i;
	output wire sdio_cmd_o;
	input wire sdio_cmd_oen_i;
	input wire [3:0] sdio_data_i;
	output wire [3:0] sdio_data_o;
	input wire [3:0] sdio_data_oen_i;
	output wire cam_pclk_o;
	output wire [7:0] cam_data_o;
	output wire cam_hsync_o;
	output wire cam_vsync_o;
	input wire [3:0] timer0_i;
	input wire [3:0] timer1_i;
	input wire [3:0] timer2_i;
	input wire [3:0] timer3_i;
	output wire out_spim_sdio0_o;
	output wire out_spim_sdio1_o;
	output wire out_spim_sdio2_o;
	output wire out_spim_sdio3_o;
	output wire out_spim_csn0_o;
	output wire out_spim_csn1_o;
	output wire out_spim_sck_o;
	output wire out_sdio_clk_o;
	output wire out_sdio_cmd_o;
	output wire out_sdio_data0_o;
	output wire out_sdio_data1_o;
	output wire out_sdio_data2_o;
	output wire out_sdio_data3_o;
	output wire out_uart_rx_o;
	output wire out_uart_tx_o;
	output wire out_cam_pclk_o;
	output wire out_cam_hsync_o;
	output wire out_cam_data0_o;
	output wire out_cam_data1_o;
	output wire out_cam_data2_o;
	output wire out_cam_data3_o;
	output wire out_cam_data4_o;
	output wire out_cam_data5_o;
	output wire out_cam_data6_o;
	output wire out_cam_data7_o;
	output wire out_cam_vsync_o;
	output wire out_i2c0_sda_o;
	output wire out_i2c0_scl_o;
	output wire out_i2s0_sck_o;
	output wire out_i2s0_ws_o;
	output wire out_i2s0_sdi_o;
	output wire out_i2s1_sdi_o;
	input wire in_spim_sdio0_i;
	input wire in_spim_sdio1_i;
	input wire in_spim_sdio2_i;
	input wire in_spim_sdio3_i;
	input wire in_spim_csn0_i;
	input wire in_spim_csn1_i;
	input wire in_spim_sck_i;
	input wire in_sdio_clk_i;
	input wire in_sdio_cmd_i;
	input wire in_sdio_data0_i;
	input wire in_sdio_data1_i;
	input wire in_sdio_data2_i;
	input wire in_sdio_data3_i;
	input wire in_uart_rx_i;
	input wire in_uart_tx_i;
	input wire in_cam_pclk_i;
	input wire in_cam_hsync_i;
	input wire in_cam_data0_i;
	input wire in_cam_data1_i;
	input wire in_cam_data2_i;
	input wire in_cam_data3_i;
	input wire in_cam_data4_i;
	input wire in_cam_data5_i;
	input wire in_cam_data6_i;
	input wire in_cam_data7_i;
	input wire in_cam_vsync_i;
	input wire in_i2c0_sda_i;
	input wire in_i2c0_scl_i;
	input wire in_i2s0_sck_i;
	input wire in_i2s0_ws_i;
	input wire in_i2s0_sdi_i;
	input wire in_i2s1_sdi_i;
	output wire oe_spim_sdio0_o;
	output wire oe_spim_sdio1_o;
	output wire oe_spim_sdio2_o;
	output wire oe_spim_sdio3_o;
	output wire oe_spim_csn0_o;
	output wire oe_spim_csn1_o;
	output wire oe_spim_sck_o;
	output wire oe_sdio_clk_o;
	output wire oe_sdio_cmd_o;
	output wire oe_sdio_data0_o;
	output wire oe_sdio_data1_o;
	output wire oe_sdio_data2_o;
	output wire oe_sdio_data3_o;
	output wire oe_uart_rx_o;
	output wire oe_uart_tx_o;
	output wire oe_cam_pclk_o;
	output wire oe_cam_hsync_o;
	output wire oe_cam_data0_o;
	output wire oe_cam_data1_o;
	output wire oe_cam_data2_o;
	output wire oe_cam_data3_o;
	output wire oe_cam_data4_o;
	output wire oe_cam_data5_o;
	output wire oe_cam_data6_o;
	output wire oe_cam_data7_o;
	output wire oe_cam_vsync_o;
	output wire oe_i2c0_sda_o;
	output wire oe_i2c0_scl_o;
	output wire oe_i2s0_sck_o;
	output wire oe_i2s0_ws_o;
	output wire oe_i2s0_sdi_o;
	output wire oe_i2s1_sdi_o;
	wire s_test_clk;
	wire s_rtc_int;
	wire s_gpio_wake;
	wire s_rstn_sync;
	wire s_rstn;
	wire [191:0] s_gpio_cfg;
	genvar i;
	genvar j;
	pad_control pad_control_i(
		.pad_mux_i(pad_mux_i),
		.pad_cfg_i(pad_cfg_i),
		.pad_cfg_o(pad_cfg_o),
		.gpio_out_i(gpio_out_i),
		.gpio_in_o(gpio_in_o),
		.gpio_dir_i(gpio_dir_i),
		.gpio_cfg_i(s_gpio_cfg),
		.uart_tx_i(uart_tx_i),
		.uart_rx_o(uart_rx_o),
		.i2c0_scl_out_i(i2c0_scl_out_i),
		.i2c0_scl_in_o(i2c0_scl_in_o),
		.i2c0_scl_oe_i(i2c0_scl_oe_i),
		.i2c0_sda_out_i(i2c0_sda_out_i),
		.i2c0_sda_in_o(i2c0_sda_in_o),
		.i2c0_sda_oe_i(i2c0_sda_oe_i),
		.i2c1_scl_out_i(i2c1_scl_out_i),
		.i2c1_scl_in_o(i2c1_scl_in_o),
		.i2c1_scl_oe_i(i2c1_scl_oe_i),
		.i2c1_sda_out_i(i2c1_sda_out_i),
		.i2c1_sda_in_o(i2c1_sda_in_o),
		.i2c1_sda_oe_i(i2c1_sda_oe_i),
		.i2s_slave_sd0_o(i2s_slave_sd0_o),
		.i2s_slave_sd1_o(i2s_slave_sd1_o),
		.i2s_slave_ws_o(i2s_slave_ws_o),
		.i2s_slave_ws_i(i2s_slave_ws_i),
		.i2s_slave_ws_oe(i2s_slave_ws_oe),
		.i2s_slave_sck_o(i2s_slave_sck_o),
		.i2s_slave_sck_i(i2s_slave_sck_i),
		.i2s_slave_sck_oe(i2s_slave_sck_oe),
		.spi_master0_csn0_i(spi_master0_csn0_i),
		.spi_master0_csn1_i(spi_master0_csn1_i),
		.spi_master0_sck_i(spi_master0_sck_i),
		.spi_master0_sdi0_o(spi_master0_sdi0_o),
		.spi_master0_sdi1_o(spi_master0_sdi1_o),
		.spi_master0_sdi2_o(spi_master0_sdi2_o),
		.spi_master0_sdi3_o(spi_master0_sdi3_o),
		.spi_master0_sdo0_i(spi_master0_sdo0_i),
		.spi_master0_sdo1_i(spi_master0_sdo1_i),
		.spi_master0_sdo2_i(spi_master0_sdo2_i),
		.spi_master0_sdo3_i(spi_master0_sdo3_i),
		.spi_master0_oen0_i(spi_master0_oen0_i),
		.spi_master0_oen1_i(spi_master0_oen1_i),
		.spi_master0_oen2_i(spi_master0_oen2_i),
		.spi_master0_oen3_i(spi_master0_oen3_i),
		.sdio_clk_i(sdio_clk_i),
		.sdio_cmd_i(sdio_cmd_i),
		.sdio_cmd_o(sdio_cmd_o),
		.sdio_cmd_oen_i(sdio_cmd_oen_i),
		.sdio_data_i(sdio_data_i),
		.sdio_data_o(sdio_data_o),
		.sdio_data_oen_i(sdio_data_oen_i),
		.cam_pclk_o(cam_pclk_o),
		.cam_data_o(cam_data_o),
		.cam_hsync_o(cam_hsync_o),
		.cam_vsync_o(cam_vsync_o),
		.timer0_i(timer0_i),
		.timer1_i(timer1_i),
		.timer2_i(timer2_i),
		.timer3_i(timer3_i),
		.out_spim_sdio0_o(out_spim_sdio0_o),
		.out_spim_sdio1_o(out_spim_sdio1_o),
		.out_spim_sdio2_o(out_spim_sdio2_o),
		.out_spim_sdio3_o(out_spim_sdio3_o),
		.out_spim_csn0_o(out_spim_csn0_o),
		.out_spim_csn1_o(out_spim_csn1_o),
		.out_spim_sck_o(out_spim_sck_o),
		.out_sdio_clk_o(out_sdio_clk_o),
		.out_sdio_cmd_o(out_sdio_cmd_o),
		.out_sdio_data0_o(out_sdio_data0_o),
		.out_sdio_data1_o(out_sdio_data1_o),
		.out_sdio_data2_o(out_sdio_data2_o),
		.out_sdio_data3_o(out_sdio_data3_o),
		.out_uart_rx_o(out_uart_rx_o),
		.out_uart_tx_o(out_uart_tx_o),
		.out_cam_pclk_o(out_cam_pclk_o),
		.out_cam_hsync_o(out_cam_hsync_o),
		.out_cam_data0_o(out_cam_data0_o),
		.out_cam_data1_o(out_cam_data1_o),
		.out_cam_data2_o(out_cam_data2_o),
		.out_cam_data3_o(out_cam_data3_o),
		.out_cam_data4_o(out_cam_data4_o),
		.out_cam_data5_o(out_cam_data5_o),
		.out_cam_data6_o(out_cam_data6_o),
		.out_cam_data7_o(out_cam_data7_o),
		.out_cam_vsync_o(out_cam_vsync_o),
		.out_i2c0_sda_o(out_i2c0_sda_o),
		.out_i2c0_scl_o(out_i2c0_scl_o),
		.out_i2s0_sck_o(out_i2s0_sck_o),
		.out_i2s0_ws_o(out_i2s0_ws_o),
		.out_i2s0_sdi_o(out_i2s0_sdi_o),
		.out_i2s1_sdi_o(out_i2s1_sdi_o),
		.in_spim_sdio0_i(in_spim_sdio0_i),
		.in_spim_sdio1_i(in_spim_sdio1_i),
		.in_spim_sdio2_i(in_spim_sdio2_i),
		.in_spim_sdio3_i(in_spim_sdio3_i),
		.in_spim_csn0_i(in_spim_csn0_i),
		.in_spim_csn1_i(in_spim_csn1_i),
		.in_spim_sck_i(in_spim_sck_i),
		.in_sdio_clk_i(in_sdio_clk_i),
		.in_sdio_cmd_i(in_sdio_cmd_i),
		.in_sdio_data0_i(in_sdio_data0_i),
		.in_sdio_data1_i(in_sdio_data1_i),
		.in_sdio_data2_i(in_sdio_data2_i),
		.in_sdio_data3_i(in_sdio_data3_i),
		.in_uart_rx_i(in_uart_rx_i),
		.in_uart_tx_i(in_uart_tx_i),
		.in_cam_pclk_i(in_cam_pclk_i),
		.in_cam_hsync_i(in_cam_hsync_i),
		.in_cam_data0_i(in_cam_data0_i),
		.in_cam_data1_i(in_cam_data1_i),
		.in_cam_data2_i(in_cam_data2_i),
		.in_cam_data3_i(in_cam_data3_i),
		.in_cam_data4_i(in_cam_data4_i),
		.in_cam_data5_i(in_cam_data5_i),
		.in_cam_data6_i(in_cam_data6_i),
		.in_cam_data7_i(in_cam_data7_i),
		.in_cam_vsync_i(in_cam_vsync_i),
		.in_i2c0_sda_i(in_i2c0_sda_i),
		.in_i2c0_scl_i(in_i2c0_scl_i),
		.in_i2s0_sck_i(in_i2s0_sck_i),
		.in_i2s0_ws_i(in_i2s0_ws_i),
		.in_i2s0_sdi_i(in_i2s0_sdi_i),
		.in_i2s1_sdi_i(in_i2s1_sdi_i),
		.oe_spim_sdio0_o(oe_spim_sdio0_o),
		.oe_spim_sdio1_o(oe_spim_sdio1_o),
		.oe_spim_sdio2_o(oe_spim_sdio2_o),
		.oe_spim_sdio3_o(oe_spim_sdio3_o),
		.oe_spim_csn0_o(oe_spim_csn0_o),
		.oe_spim_csn1_o(oe_spim_csn1_o),
		.oe_spim_sck_o(oe_spim_sck_o),
		.oe_sdio_clk_o(oe_sdio_clk_o),
		.oe_sdio_cmd_o(oe_sdio_cmd_o),
		.oe_sdio_data0_o(oe_sdio_data0_o),
		.oe_sdio_data1_o(oe_sdio_data1_o),
		.oe_sdio_data2_o(oe_sdio_data2_o),
		.oe_sdio_data3_o(oe_sdio_data3_o),
		.oe_uart_rx_o(oe_uart_rx_o),
		.oe_uart_tx_o(oe_uart_tx_o),
		.oe_cam_pclk_o(oe_cam_pclk_o),
		.oe_cam_hsync_o(oe_cam_hsync_o),
		.oe_cam_data0_o(oe_cam_data0_o),
		.oe_cam_data1_o(oe_cam_data1_o),
		.oe_cam_data2_o(oe_cam_data2_o),
		.oe_cam_data3_o(oe_cam_data3_o),
		.oe_cam_data4_o(oe_cam_data4_o),
		.oe_cam_data5_o(oe_cam_data5_o),
		.oe_cam_data6_o(oe_cam_data6_o),
		.oe_cam_data7_o(oe_cam_data7_o),
		.oe_cam_vsync_o(oe_cam_vsync_o),
		.oe_i2c0_sda_o(oe_i2c0_sda_o),
		.oe_i2c0_scl_o(oe_i2c0_scl_o),
		.oe_i2s0_sck_o(oe_i2s0_sck_o),
		.oe_i2s0_ws_o(oe_i2s0_ws_o),
		.oe_i2s0_sdi_o(oe_i2s0_sdi_o),
		.oe_i2s1_sdi_o(oe_i2s1_sdi_o)
	);
	rstgen i_rstgen(
		.clk_i(ref_clk_i),
		.rst_ni(s_rstn),
		.test_mode_i(test_mode_o),
		.rst_no(s_rstn_sync),
		.init_no()
	);
	assign slow_clk_o = ref_clk_i;
	assign s_rstn = rst_ni;
	assign rst_no = s_rstn;
	assign test_clk_o = 1'b0;
	assign dft_cg_enable_o = 1'b0;
	assign test_mode_o = 1'b0;
	assign mode_select_o = 1'b0;
	generate
		for (i = 0; i < 32; i = i + 1) begin : GEN_GPIO_CFG_I
			for (j = 0; j < 6; j = j + 1) begin : GEN_GPIO_CFG_J
				assign s_gpio_cfg[(i * 6) + j] = gpio_cfg_i[j + (6 * i)];
			end
		end
	endgenerate
endmodule
