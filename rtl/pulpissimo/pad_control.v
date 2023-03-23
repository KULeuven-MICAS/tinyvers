module pad_control (
	pad_mux_i,
	pad_cfg_i,
	pad_cfg_o,
	sdio_clk_i,
	sdio_cmd_i,
	sdio_cmd_o,
	sdio_cmd_oen_i,
	sdio_data_i,
	sdio_data_o,
	sdio_data_oen_i,
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
	input wire [127:0] pad_mux_i;
	input wire [383:0] pad_cfg_i;
	output wire [287:0] pad_cfg_o;
	input wire sdio_clk_i;
	input wire sdio_cmd_i;
	output wire sdio_cmd_o;
	input wire sdio_cmd_oen_i;
	input wire [3:0] sdio_data_i;
	output wire [3:0] sdio_data_o;
	input wire [3:0] sdio_data_oen_i;
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
	wire s_alt0;
	wire s_alt1;
	wire s_alt2;
	wire s_alt3;
	assign s_alt0 = 1'b0;
	assign s_alt1 = 1'b0;
	assign s_alt2 = 1'b0;
	assign s_alt3 = 1'b0;
	assign oe_spim_sdio0_o = (pad_mux_i[0+:2] == 2'b00 ? ~spi_master0_oen0_i : (pad_mux_i[0+:2] == 2'b01 ? gpio_dir_i[0] : (pad_mux_i[0+:2] == 2'b10 ? s_alt2 : s_alt3)));
	assign oe_spim_sdio1_o = (pad_mux_i[2+:2] == 2'b00 ? ~spi_master0_oen1_i : (pad_mux_i[2+:2] == 2'b01 ? gpio_dir_i[1] : (pad_mux_i[2+:2] == 2'b10 ? s_alt2 : s_alt3)));
	assign oe_spim_sdio2_o = (pad_mux_i[4+:2] == 2'b00 ? ~spi_master0_oen2_i : (pad_mux_i[4+:2] == 2'b01 ? gpio_dir_i[2] : (pad_mux_i[4+:2] == 2'b10 ? i2c1_sda_oe_i : s_alt3)));
	assign oe_spim_sdio3_o = (pad_mux_i[6+:2] == 2'b00 ? ~spi_master0_oen3_i : (pad_mux_i[6+:2] == 2'b01 ? gpio_dir_i[3] : (pad_mux_i[6+:2] == 2'b10 ? i2c1_scl_oe_i : s_alt3)));
	assign oe_spim_csn0_o = (pad_mux_i[8+:2] == 2'b00 ? 1'b1 : (pad_mux_i[8+:2] == 2'b01 ? gpio_dir_i[4] : (pad_mux_i[8+:2] == 2'b10 ? s_alt2 : s_alt3)));
	assign oe_spim_csn1_o = (pad_mux_i[10+:2] == 2'b00 ? 1'b1 : (pad_mux_i[10+:2] == 2'b01 ? gpio_dir_i[5] : (pad_mux_i[10+:2] == 2'b10 ? s_alt2 : s_alt3)));
	assign oe_spim_sck_o = (pad_mux_i[12+:2] == 2'b00 ? 1'b1 : (pad_mux_i[12+:2] == 2'b01 ? gpio_dir_i[6] : (pad_mux_i[12+:2] == 2'b10 ? s_alt2 : s_alt3)));
	assign oe_uart_rx_o = (pad_mux_i[14+:2] == 2'b00 ? 1'b0 : (pad_mux_i[14+:2] == 2'b01 ? gpio_dir_i[7] : (pad_mux_i[14+:2] == 2'b10 ? i2c1_sda_oe_i : s_alt3)));
	assign oe_uart_tx_o = (pad_mux_i[16+:2] == 2'b00 ? 1'b1 : (pad_mux_i[16+:2] == 2'b01 ? gpio_dir_i[8] : (pad_mux_i[16+:2] == 2'b10 ? i2c1_scl_oe_i : s_alt3)));
	assign oe_cam_pclk_o = (pad_mux_i[18+:2] == 2'b00 ? 1'b0 : (pad_mux_i[18+:2] == 2'b01 ? gpio_dir_i[9] : (pad_mux_i[18+:2] == 2'b10 ? 1'b1 : s_alt3)));
	assign oe_cam_hsync_o = (pad_mux_i[20+:2] == 2'b00 ? 1'b0 : (pad_mux_i[20+:2] == 2'b01 ? gpio_dir_i[10] : (pad_mux_i[20+:2] == 2'b10 ? 1'b1 : s_alt3)));
	assign oe_cam_data0_o = (pad_mux_i[22+:2] == 2'b00 ? 1'b0 : (pad_mux_i[22+:2] == 2'b01 ? gpio_dir_i[11] : (pad_mux_i[22+:2] == 2'b10 ? 1'b1 : s_alt3)));
	assign oe_cam_data1_o = (pad_mux_i[24+:2] == 2'b00 ? 1'b0 : (pad_mux_i[24+:2] == 2'b01 ? gpio_dir_i[12] : (pad_mux_i[24+:2] == 2'b10 ? 1'b1 : s_alt3)));
	assign oe_cam_data2_o = (pad_mux_i[26+:2] == 2'b00 ? 1'b0 : (pad_mux_i[26+:2] == 2'b01 ? gpio_dir_i[13] : (pad_mux_i[26+:2] == 2'b10 ? 1'b1 : s_alt3)));
	assign oe_cam_data3_o = (pad_mux_i[28+:2] == 2'b00 ? 1'b0 : (pad_mux_i[28+:2] == 2'b01 ? gpio_dir_i[14] : (pad_mux_i[28+:2] == 2'b10 ? 1'b1 : s_alt3)));
	assign oe_cam_data4_o = (pad_mux_i[30+:2] == 2'b00 ? 1'b0 : (pad_mux_i[30+:2] == 2'b01 ? gpio_dir_i[15] : (pad_mux_i[30+:2] == 2'b10 ? 1'b1 : s_alt3)));
	assign oe_cam_data5_o = (pad_mux_i[32+:2] == 2'b00 ? 1'b0 : (pad_mux_i[32+:2] == 2'b01 ? gpio_dir_i[16] : (pad_mux_i[32+:2] == 2'b10 ? 1'b1 : s_alt3)));
	assign oe_cam_data6_o = (pad_mux_i[34+:2] == 2'b00 ? 1'b0 : (pad_mux_i[34+:2] == 2'b01 ? gpio_dir_i[17] : (pad_mux_i[34+:2] == 2'b10 ? 1'b1 : s_alt3)));
	assign oe_cam_data7_o = (pad_mux_i[36+:2] == 2'b00 ? 1'b0 : (pad_mux_i[36+:2] == 2'b01 ? gpio_dir_i[18] : (pad_mux_i[36+:2] == 2'b10 ? 1'b1 : s_alt3)));
	assign oe_cam_vsync_o = (pad_mux_i[38+:2] == 2'b00 ? 1'b0 : (pad_mux_i[38+:2] == 2'b01 ? gpio_dir_i[19] : (pad_mux_i[38+:2] == 2'b10 ? 1'b1 : s_alt3)));
	assign oe_sdio_clk_o = (pad_mux_i[40+:2] == 2'b00 ? 1'b1 : (pad_mux_i[40+:2] == 2'b01 ? gpio_dir_i[20] : (pad_mux_i[40+:2] == 2'b10 ? 1'b0 : s_alt3)));
	assign oe_sdio_cmd_o = (pad_mux_i[42+:2] == 2'b00 ? ~sdio_cmd_oen_i : (pad_mux_i[42+:2] == 2'b01 ? gpio_dir_i[21] : (pad_mux_i[42+:2] == 2'b10 ? 1'b0 : s_alt3)));
	assign oe_sdio_data0_o = (pad_mux_i[44+:2] == 2'b00 ? ~sdio_data_oen_i[0] : (pad_mux_i[44+:2] == 2'b01 ? gpio_dir_i[22] : (pad_mux_i[44+:2] == 2'b10 ? 1'b0 : s_alt3)));
	assign oe_sdio_data1_o = (pad_mux_i[46+:2] == 2'b00 ? ~sdio_data_oen_i[1] : (pad_mux_i[46+:2] == 2'b01 ? gpio_dir_i[23] : (pad_mux_i[46+:2] == 2'b10 ? 1'b0 : s_alt3)));
	assign oe_sdio_data2_o = (pad_mux_i[48+:2] == 2'b00 ? ~sdio_data_oen_i[2] : (pad_mux_i[48+:2] == 2'b01 ? gpio_dir_i[24] : (pad_mux_i[48+:2] == 2'b10 ? i2c1_sda_oe_i : s_alt3)));
	assign oe_sdio_data3_o = (pad_mux_i[50+:2] == 2'b00 ? ~sdio_data_oen_i[3] : (pad_mux_i[50+:2] == 2'b01 ? gpio_dir_i[25] : (pad_mux_i[50+:2] == 2'b10 ? i2c1_scl_oe_i : s_alt3)));
	assign oe_i2c0_sda_o = (pad_mux_i[66+:2] == 2'b00 ? i2c0_sda_oe_i : (pad_mux_i[66+:2] == 2'b01 ? gpio_dir_i[26] : (pad_mux_i[66+:2] == 2'b10 ? s_alt2 : s_alt3)));
	assign oe_i2c0_scl_o = (pad_mux_i[68+:2] == 2'b00 ? i2c0_scl_oe_i : (pad_mux_i[68+:2] == 2'b01 ? gpio_dir_i[27] : (pad_mux_i[68+:2] == 2'b10 ? s_alt2 : s_alt3)));
	assign oe_i2s0_sck_o = (pad_mux_i[70+:2] == 2'b00 ? i2s_slave_sck_oe : (pad_mux_i[70+:2] == 2'b01 ? gpio_dir_i[28] : (pad_mux_i[70+:2] == 2'b10 ? s_alt2 : s_alt3)));
	assign oe_i2s0_ws_o = (pad_mux_i[72+:2] == 2'b00 ? i2s_slave_ws_oe : (pad_mux_i[72+:2] == 2'b01 ? gpio_dir_i[29] : (pad_mux_i[72+:2] == 2'b10 ? s_alt2 : s_alt3)));
	assign oe_i2s0_sdi_o = (pad_mux_i[74+:2] == 2'b00 ? 1'b0 : (pad_mux_i[74+:2] == 2'b01 ? gpio_dir_i[30] : (pad_mux_i[74+:2] == 2'b10 ? s_alt2 : s_alt3)));
	assign oe_i2s1_sdi_o = (pad_mux_i[76+:2] == 2'b00 ? 1'b0 : (pad_mux_i[76+:2] == 2'b01 ? gpio_dir_i[31] : (pad_mux_i[76+:2] == 2'b10 ? s_alt2 : s_alt3)));
	assign out_spim_sdio0_o = (pad_mux_i[0+:2] == 2'b00 ? spi_master0_sdo0_i : (pad_mux_i[0+:2] == 2'b01 ? gpio_out_i[0] : (pad_mux_i[0+:2] == 2'b10 ? s_alt2 : s_alt3)));
	assign out_spim_sdio1_o = (pad_mux_i[2+:2] == 2'b00 ? spi_master0_sdo1_i : (pad_mux_i[2+:2] == 2'b01 ? gpio_out_i[1] : (pad_mux_i[2+:2] == 2'b10 ? s_alt2 : s_alt3)));
	assign out_spim_sdio2_o = (pad_mux_i[4+:2] == 2'b00 ? spi_master0_sdo2_i : (pad_mux_i[4+:2] == 2'b01 ? gpio_out_i[2] : (pad_mux_i[4+:2] == 2'b10 ? i2c1_sda_out_i : s_alt3)));
	assign out_spim_sdio3_o = (pad_mux_i[6+:2] == 2'b00 ? spi_master0_sdo3_i : (pad_mux_i[6+:2] == 2'b01 ? gpio_out_i[3] : (pad_mux_i[6+:2] == 2'b10 ? i2c1_scl_out_i : s_alt3)));
	assign out_spim_csn0_o = (pad_mux_i[8+:2] == 2'b00 ? spi_master0_csn0_i : (pad_mux_i[8+:2] == 2'b01 ? gpio_out_i[4] : (pad_mux_i[8+:2] == 2'b10 ? s_alt2 : s_alt3)));
	assign out_spim_csn1_o = (pad_mux_i[10+:2] == 2'b00 ? spi_master0_csn1_i : (pad_mux_i[10+:2] == 2'b01 ? gpio_out_i[5] : (pad_mux_i[10+:2] == 2'b10 ? s_alt2 : s_alt3)));
	assign out_spim_sck_o = (pad_mux_i[12+:2] == 2'b00 ? spi_master0_sck_i : (pad_mux_i[12+:2] == 2'b01 ? gpio_out_i[6] : (pad_mux_i[12+:2] == 2'b10 ? s_alt2 : s_alt3)));
	assign out_uart_rx_o = (pad_mux_i[14+:2] == 2'b00 ? 1'b0 : (pad_mux_i[14+:2] == 2'b01 ? gpio_out_i[7] : (pad_mux_i[14+:2] == 2'b10 ? i2c1_sda_out_i : s_alt3)));
	assign out_uart_tx_o = (pad_mux_i[16+:2] == 2'b00 ? uart_tx_i : (pad_mux_i[16+:2] == 2'b01 ? gpio_out_i[8] : (pad_mux_i[16+:2] == 2'b10 ? i2c1_scl_out_i : s_alt3)));
	assign out_cam_pclk_o = (pad_mux_i[18+:2] == 2'b00 ? 1'b0 : (pad_mux_i[18+:2] == 2'b01 ? gpio_out_i[9] : (pad_mux_i[18+:2] == 2'b10 ? timer1_i[0] : s_alt3)));
	assign out_cam_hsync_o = (pad_mux_i[20+:2] == 2'b00 ? 1'b0 : (pad_mux_i[20+:2] == 2'b01 ? gpio_out_i[10] : (pad_mux_i[20+:2] == 2'b10 ? timer1_i[1] : s_alt3)));
	assign out_cam_data0_o = (pad_mux_i[22+:2] == 2'b00 ? 1'b0 : (pad_mux_i[22+:2] == 2'b01 ? gpio_out_i[11] : (pad_mux_i[22+:2] == 2'b10 ? timer1_i[2] : s_alt3)));
	assign out_cam_data1_o = (pad_mux_i[24+:2] == 2'b00 ? 1'b0 : (pad_mux_i[24+:2] == 2'b01 ? gpio_out_i[12] : (pad_mux_i[24+:2] == 2'b10 ? timer1_i[3] : s_alt3)));
	assign out_cam_data2_o = (pad_mux_i[26+:2] == 2'b00 ? 1'b0 : (pad_mux_i[26+:2] == 2'b01 ? gpio_out_i[13] : (pad_mux_i[26+:2] == 2'b10 ? timer2_i[0] : s_alt3)));
	assign out_cam_data3_o = (pad_mux_i[28+:2] == 2'b00 ? 1'b0 : (pad_mux_i[28+:2] == 2'b01 ? gpio_out_i[14] : (pad_mux_i[28+:2] == 2'b10 ? timer2_i[1] : s_alt3)));
	assign out_cam_data4_o = (pad_mux_i[30+:2] == 2'b00 ? 1'b0 : (pad_mux_i[30+:2] == 2'b01 ? gpio_out_i[15] : (pad_mux_i[30+:2] == 2'b10 ? timer2_i[2] : s_alt3)));
	assign out_cam_data5_o = (pad_mux_i[32+:2] == 2'b00 ? 1'b0 : (pad_mux_i[32+:2] == 2'b01 ? gpio_out_i[16] : (pad_mux_i[32+:2] == 2'b10 ? timer2_i[3] : s_alt3)));
	assign out_cam_data6_o = (pad_mux_i[34+:2] == 2'b00 ? 1'b0 : (pad_mux_i[34+:2] == 2'b01 ? gpio_out_i[17] : (pad_mux_i[34+:2] == 2'b10 ? timer3_i[0] : s_alt3)));
	assign out_cam_data7_o = (pad_mux_i[36+:2] == 2'b00 ? 1'b0 : (pad_mux_i[36+:2] == 2'b01 ? gpio_out_i[18] : (pad_mux_i[36+:2] == 2'b10 ? timer3_i[1] : s_alt3)));
	assign out_cam_vsync_o = (pad_mux_i[38+:2] == 2'b00 ? 1'b0 : (pad_mux_i[38+:2] == 2'b01 ? gpio_out_i[19] : (pad_mux_i[38+:2] == 2'b10 ? timer3_i[2] : s_alt3)));
	assign out_sdio_clk_o = (pad_mux_i[40+:2] == 2'b00 ? sdio_clk_i : (pad_mux_i[40+:2] == 2'b01 ? gpio_out_i[20] : (pad_mux_i[40+:2] == 2'b10 ? s_alt2 : s_alt3)));
	assign out_sdio_cmd_o = (pad_mux_i[42+:2] == 2'b00 ? sdio_cmd_i : (pad_mux_i[42+:2] == 2'b01 ? gpio_out_i[21] : (pad_mux_i[42+:2] == 2'b10 ? s_alt2 : s_alt3)));
	assign out_sdio_data0_o = (pad_mux_i[44+:2] == 2'b00 ? sdio_data_i[0] : (pad_mux_i[44+:2] == 2'b01 ? gpio_out_i[22] : (pad_mux_i[44+:2] == 2'b10 ? s_alt2 : s_alt3)));
	assign out_sdio_data1_o = (pad_mux_i[46+:2] == 2'b00 ? sdio_data_i[1] : (pad_mux_i[46+:2] == 2'b01 ? gpio_out_i[23] : (pad_mux_i[46+:2] == 2'b10 ? s_alt2 : s_alt3)));
	assign out_sdio_data2_o = (pad_mux_i[48+:2] == 2'b00 ? sdio_data_i[2] : (pad_mux_i[48+:2] == 2'b01 ? gpio_out_i[24] : (pad_mux_i[48+:2] == 2'b10 ? i2c1_sda_out_i : s_alt3)));
	assign out_sdio_data3_o = (pad_mux_i[50+:2] == 2'b00 ? sdio_data_i[3] : (pad_mux_i[50+:2] == 2'b01 ? gpio_out_i[25] : (pad_mux_i[50+:2] == 2'b10 ? i2c1_scl_out_i : s_alt3)));
	assign out_i2c0_sda_o = (pad_mux_i[66+:2] == 2'b00 ? i2c0_sda_out_i : (pad_mux_i[66+:2] == 2'b01 ? gpio_out_i[26] : (pad_mux_i[66+:2] == 2'b10 ? s_alt2 : s_alt3)));
	assign out_i2c0_scl_o = (pad_mux_i[68+:2] == 2'b00 ? i2c0_scl_out_i : (pad_mux_i[68+:2] == 2'b01 ? gpio_out_i[27] : (pad_mux_i[68+:2] == 2'b10 ? s_alt2 : s_alt3)));
	assign out_i2s0_sck_o = (pad_mux_i[70+:2] == 2'b00 ? i2s_slave_sck_i : (pad_mux_i[70+:2] == 2'b01 ? gpio_out_i[28] : (pad_mux_i[70+:2] == 2'b10 ? s_alt2 : s_alt3)));
	assign out_i2s0_ws_o = (pad_mux_i[72+:2] == 2'b00 ? i2s_slave_ws_i : (pad_mux_i[72+:2] == 2'b01 ? gpio_out_i[29] : (pad_mux_i[72+:2] == 2'b10 ? s_alt2 : s_alt3)));
	assign out_i2s0_sdi_o = (pad_mux_i[74+:2] == 2'b00 ? 1'b0 : (pad_mux_i[74+:2] == 2'b01 ? gpio_out_i[30] : (pad_mux_i[74+:2] == 2'b10 ? s_alt2 : s_alt3)));
	assign out_i2s1_sdi_o = (pad_mux_i[76+:2] == 2'b00 ? 1'b0 : (pad_mux_i[76+:2] == 2'b01 ? gpio_out_i[31] : (pad_mux_i[76+:2] == 2'b10 ? s_alt2 : s_alt3)));
	wire spi_master1_sdi_o;
	assign spi_master1_sdi_o = 1'b0;
	assign sdio_cmd_o = (pad_mux_i[42+:2] == 2'b00 ? in_sdio_cmd_i : 1'b0);
	assign sdio_data_o[0] = (pad_mux_i[44+:2] == 2'b00 ? in_sdio_data0_i : 1'b0);
	assign sdio_data_o[1] = (pad_mux_i[46+:2] == 2'b00 ? in_sdio_data1_i : 1'b0);
	assign sdio_data_o[2] = (pad_mux_i[48+:2] == 2'b00 ? in_sdio_data2_i : 1'b0);
	assign sdio_data_o[3] = (pad_mux_i[50+:2] == 2'b00 ? in_sdio_data3_i : 1'b0);
	assign cam_pclk_o = (pad_mux_i[18+:2] == 2'b00 ? in_cam_pclk_i : 1'b0);
	assign cam_hsync_o = (pad_mux_i[20+:2] == 2'b00 ? in_cam_hsync_i : 1'b0);
	assign cam_data_o[0] = (pad_mux_i[22+:2] == 2'b00 ? in_cam_data0_i : 1'b0);
	assign cam_data_o[1] = (pad_mux_i[24+:2] == 2'b00 ? in_cam_data1_i : 1'b0);
	assign cam_data_o[2] = (pad_mux_i[26+:2] == 2'b00 ? in_cam_data2_i : 1'b0);
	assign cam_data_o[3] = (pad_mux_i[28+:2] == 2'b00 ? in_cam_data3_i : 1'b0);
	assign cam_data_o[4] = (pad_mux_i[30+:2] == 2'b00 ? in_cam_data4_i : 1'b0);
	assign cam_data_o[5] = (pad_mux_i[32+:2] == 2'b00 ? in_cam_data5_i : 1'b0);
	assign cam_data_o[6] = (pad_mux_i[34+:2] == 2'b00 ? in_cam_data6_i : 1'b0);
	assign cam_data_o[7] = (pad_mux_i[36+:2] == 2'b00 ? in_cam_data7_i : 1'b0);
	assign cam_vsync_o = (pad_mux_i[38+:2] == 2'b00 ? in_cam_vsync_i : 1'b0);
	assign i2c1_sda_in_o = (pad_mux_i[4+:2] == 2'b10 ? in_spim_sdio2_i : (pad_mux_i[14+:2] == 2'b10 ? in_uart_rx_i : (pad_mux_i[48+:2] == 2'b10 ? in_sdio_data2_i : 1'b1)));
	assign i2c1_scl_in_o = (pad_mux_i[6+:2] == 2'b10 ? in_spim_sdio3_i : (pad_mux_i[16+:2] == 2'b10 ? in_uart_tx_i : (pad_mux_i[50+:2] == 2'b10 ? in_sdio_data3_i : 1'b1)));
	assign i2s_slave_sd1_o = (pad_mux_i[58+:2] == 2'b00 ? in_i2s1_sdi_i : (pad_mux_i[54+:2] == 2'b11 ? in_i2s1_sdi_i : 1'b0));
	assign uart_rx_o = (pad_mux_i[76+:2] == 2'b00 ? in_uart_rx_i : 1'b1);
	assign spi_master0_sdi0_o = (pad_mux_i[66+:2] == 2'b00 ? in_spim_sdio0_i : 1'b0);
	assign spi_master0_sdi1_o = (pad_mux_i[68+:2] == 2'b00 ? in_spim_sdio1_i : 1'b0);
	assign spi_master0_sdi2_o = (pad_mux_i[70+:2] == 2'b00 ? in_spim_sdio2_i : 1'b0);
	assign spi_master0_sdi3_o = (pad_mux_i[72+:2] == 2'b00 ? in_spim_sdio3_i : 1'b0);
	assign i2c0_sda_in_o = (pad_mux_i[86+:2] == 2'b00 ? in_i2c0_sda_i : 1'b1);
	assign i2c0_scl_in_o = (pad_mux_i[88+:2] == 2'b00 ? in_i2c0_scl_i : 1'b1);
	assign i2s_slave_sck_o = (pad_mux_i[90+:2] == 2'b00 ? in_i2s0_sck_i : 1'b0);
	assign i2s_slave_ws_o = (pad_mux_i[92+:2] == 2'b00 ? in_i2s0_ws_i : 1'b0);
	assign i2s_slave_sd0_o = (pad_mux_i[94+:2] == 2'b00 ? in_i2s0_sdi_i : 1'b0);
	assign gpio_in_o[0] = (pad_mux_i[0+:2] == 2'b01 ? in_spim_sdio0_i : 1'b0);
	assign gpio_in_o[1] = (pad_mux_i[2+:2] == 2'b01 ? in_spim_sdio1_i : 1'b0);
	assign gpio_in_o[2] = (pad_mux_i[4+:2] == 2'b01 ? in_spim_sdio2_i : 1'b0);
	assign gpio_in_o[3] = (pad_mux_i[6+:2] == 2'b01 ? in_spim_sdio3_i : 1'b0);
	assign gpio_in_o[4] = (pad_mux_i[8+:2] == 2'b01 ? in_spim_csn0_i : 1'b0);
	assign gpio_in_o[5] = (pad_mux_i[10+:2] == 2'b01 ? in_spim_csn1_i : 1'b0);
	assign gpio_in_o[6] = (pad_mux_i[12+:2] == 2'b01 ? in_spim_sck_i : 1'b0);
	assign gpio_in_o[7] = (pad_mux_i[14+:2] == 2'b01 ? in_uart_rx_i : 1'b0);
	assign gpio_in_o[8] = (pad_mux_i[16+:2] == 2'b01 ? in_uart_tx_i : 1'b0);
	assign gpio_in_o[9] = (pad_mux_i[18+:2] == 2'b01 ? in_cam_pclk_i : 1'b0);
	assign gpio_in_o[10] = (pad_mux_i[20+:2] == 2'b01 ? in_cam_hsync_i : 1'b0);
	assign gpio_in_o[11] = (pad_mux_i[22+:2] == 2'b01 ? in_cam_data0_i : 1'b0);
	assign gpio_in_o[12] = (pad_mux_i[24+:2] == 2'b01 ? in_cam_data1_i : 1'b0);
	assign gpio_in_o[13] = (pad_mux_i[26+:2] == 2'b01 ? in_cam_data2_i : 1'b0);
	assign gpio_in_o[14] = (pad_mux_i[28+:2] == 2'b01 ? in_cam_data3_i : 1'b0);
	assign gpio_in_o[15] = (pad_mux_i[30+:2] == 2'b01 ? in_cam_data4_i : 1'b0);
	assign gpio_in_o[16] = (pad_mux_i[32+:2] == 2'b01 ? in_cam_data5_i : 1'b0);
	assign gpio_in_o[17] = (pad_mux_i[34+:2] == 2'b01 ? in_cam_data6_i : 1'b0);
	assign gpio_in_o[18] = (pad_mux_i[36+:2] == 2'b01 ? in_cam_data7_i : 1'b0);
	assign gpio_in_o[19] = (pad_mux_i[38+:2] == 2'b01 ? in_cam_vsync_i : 1'b0);
	assign gpio_in_o[20] = (pad_mux_i[40+:2] == 2'b01 ? in_sdio_clk_i : 1'b0);
	assign gpio_in_o[21] = (pad_mux_i[42+:2] == 2'b01 ? in_sdio_cmd_i : 1'b0);
	assign gpio_in_o[22] = (pad_mux_i[44+:2] == 2'b01 ? in_sdio_data0_i : 1'b0);
	assign gpio_in_o[23] = (pad_mux_i[46+:2] == 2'b01 ? in_sdio_data1_i : 1'b0);
	assign gpio_in_o[24] = (pad_mux_i[48+:2] == 2'b01 ? in_sdio_data2_i : 1'b0);
	assign gpio_in_o[25] = (pad_mux_i[50+:2] == 2'b01 ? in_sdio_data3_i : 1'b0);
	assign gpio_in_o[26] = (pad_mux_i[66+:2] == 2'b01 ? in_i2c0_sda_i : 1'b0);
	assign gpio_in_o[27] = (pad_mux_i[68+:2] == 2'b01 ? in_i2c0_scl_i : 1'b0);
	assign gpio_in_o[28] = (pad_mux_i[70+:2] == 2'b01 ? in_i2s0_sck_i : 1'b0);
	assign gpio_in_o[29] = (pad_mux_i[72+:2] == 2'b01 ? in_i2s0_ws_i : 1'b0);
	assign gpio_in_o[30] = (pad_mux_i[74+:2] == 2'b01 ? in_i2s0_sdi_i : 1'b0);
	assign gpio_in_o[31] = (pad_mux_i[76+:2] == 2'b01 ? in_i2s1_sdi_i : 1'b0);
	assign pad_cfg_o[0+:6] = (pad_mux_i[0+:2] == 2'b01 ? gpio_cfg_i[0+:6] : pad_cfg_i[0+:6]);
	assign pad_cfg_o[6+:6] = (pad_mux_i[2+:2] == 2'b01 ? gpio_cfg_i[6+:6] : pad_cfg_i[6+:6]);
	assign pad_cfg_o[12+:6] = (pad_mux_i[4+:2] == 2'b01 ? gpio_cfg_i[12+:6] : pad_cfg_i[12+:6]);
	assign pad_cfg_o[18+:6] = (pad_mux_i[6+:2] == 2'b01 ? gpio_cfg_i[18+:6] : pad_cfg_i[18+:6]);
	assign pad_cfg_o[24+:6] = (pad_mux_i[8+:2] == 2'b01 ? gpio_cfg_i[24+:6] : pad_cfg_i[24+:6]);
	assign pad_cfg_o[30+:6] = (pad_mux_i[10+:2] == 2'b01 ? gpio_cfg_i[30+:6] : pad_cfg_i[30+:6]);
	assign pad_cfg_o[36+:6] = (pad_mux_i[12+:2] == 2'b01 ? gpio_cfg_i[36+:6] : pad_cfg_i[36+:6]);
	assign pad_cfg_o[42+:6] = (pad_mux_i[14+:2] == 2'b01 ? gpio_cfg_i[42+:6] : pad_cfg_i[42+:6]);
	assign pad_cfg_o[48+:6] = (pad_mux_i[16+:2] == 2'b01 ? gpio_cfg_i[48+:6] : pad_cfg_i[48+:6]);
	assign pad_cfg_o[54+:6] = (pad_mux_i[18+:2] == 2'b01 ? gpio_cfg_i[54+:6] : pad_cfg_i[54+:6]);
	assign pad_cfg_o[60+:6] = (pad_mux_i[20+:2] == 2'b01 ? gpio_cfg_i[60+:6] : pad_cfg_i[60+:6]);
	assign pad_cfg_o[66+:6] = (pad_mux_i[22+:2] == 2'b01 ? gpio_cfg_i[66+:6] : pad_cfg_i[66+:6]);
	assign pad_cfg_o[72+:6] = (pad_mux_i[24+:2] == 2'b01 ? gpio_cfg_i[72+:6] : pad_cfg_i[72+:6]);
	assign pad_cfg_o[78+:6] = (pad_mux_i[26+:2] == 2'b01 ? gpio_cfg_i[78+:6] : pad_cfg_i[78+:6]);
	assign pad_cfg_o[84+:6] = (pad_mux_i[28+:2] == 2'b01 ? gpio_cfg_i[84+:6] : pad_cfg_i[84+:6]);
	assign pad_cfg_o[90+:6] = (pad_mux_i[30+:2] == 2'b01 ? gpio_cfg_i[90+:6] : pad_cfg_i[90+:6]);
	assign pad_cfg_o[96+:6] = (pad_mux_i[32+:2] == 2'b01 ? gpio_cfg_i[96+:6] : pad_cfg_i[96+:6]);
	assign pad_cfg_o[102+:6] = (pad_mux_i[34+:2] == 2'b01 ? gpio_cfg_i[102+:6] : pad_cfg_i[102+:6]);
	assign pad_cfg_o[108+:6] = (pad_mux_i[36+:2] == 2'b01 ? gpio_cfg_i[108+:6] : pad_cfg_i[108+:6]);
	assign pad_cfg_o[114+:6] = (pad_mux_i[38+:2] == 2'b01 ? gpio_cfg_i[114+:6] : pad_cfg_i[114+:6]);
	assign pad_cfg_o[120+:6] = (pad_mux_i[40+:2] == 2'b01 ? gpio_cfg_i[120+:6] : pad_cfg_i[120+:6]);
	assign pad_cfg_o[126+:6] = (pad_mux_i[42+:2] == 2'b01 ? gpio_cfg_i[126+:6] : pad_cfg_i[126+:6]);
	assign pad_cfg_o[132+:6] = (pad_mux_i[44+:2] == 2'b01 ? gpio_cfg_i[132+:6] : pad_cfg_i[132+:6]);
	assign pad_cfg_o[138+:6] = (pad_mux_i[46+:2] == 2'b01 ? gpio_cfg_i[138+:6] : pad_cfg_i[138+:6]);
	assign pad_cfg_o[144+:6] = (pad_mux_i[48+:2] == 2'b01 ? gpio_cfg_i[144+:6] : pad_cfg_i[144+:6]);
	assign pad_cfg_o[150+:6] = (pad_mux_i[50+:2] == 2'b01 ? gpio_cfg_i[150+:6] : pad_cfg_i[150+:6]);
	assign pad_cfg_o[156+:6] = pad_cfg_i[156+:6];
	assign pad_cfg_o[162+:6] = pad_cfg_i[162+:6];
	assign pad_cfg_o[168+:6] = pad_cfg_i[168+:6];
	assign pad_cfg_o[174+:6] = pad_cfg_i[174+:6];
	assign pad_cfg_o[180+:6] = pad_cfg_i[180+:6];
	assign pad_cfg_o[186+:6] = pad_cfg_i[186+:6];
	assign pad_cfg_o[192+:6] = pad_cfg_i[192+:6];
	assign pad_cfg_o[198+:6] = (pad_mux_i[66+:2] == 2'b01 ? gpio_cfg_i[156+:6] : pad_cfg_i[198+:6]);
	assign pad_cfg_o[204+:6] = (pad_mux_i[68+:2] == 2'b01 ? gpio_cfg_i[162+:6] : pad_cfg_i[204+:6]);
	assign pad_cfg_o[210+:6] = (pad_mux_i[70+:2] == 2'b01 ? gpio_cfg_i[168+:6] : pad_cfg_i[210+:6]);
	assign pad_cfg_o[216+:6] = (pad_mux_i[72+:2] == 2'b01 ? gpio_cfg_i[174+:6] : pad_cfg_i[216+:6]);
	assign pad_cfg_o[222+:6] = (pad_mux_i[74+:2] == 2'b01 ? gpio_cfg_i[180+:6] : pad_cfg_i[222+:6]);
	assign pad_cfg_o[228+:6] = (pad_mux_i[76+:2] == 2'b01 ? gpio_cfg_i[186+:6] : pad_cfg_i[228+:6]);
endmodule
