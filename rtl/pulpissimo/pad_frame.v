module pad_frame (
	pad_cfg_i,
	ref_clk_o,
	clk_soc_ext_o,
	clk_per_ext_o,
	rstn_o,
	jtag_tck_o,
	jtag_tdi_o,
	jtag_tdo_i,
	jtag_tms_o,
	jtag_trst_o,
	oe_sdio_clk_i,
	oe_sdio_cmd_i,
	oe_sdio_data0_i,
	oe_sdio_data1_i,
	oe_sdio_data2_i,
	oe_sdio_data3_i,
	oe_spim_sdio0_i,
	oe_spim_sdio1_i,
	oe_spim_sdio2_i,
	oe_spim_sdio3_i,
	oe_spim_csn0_i,
	oe_spim_csn1_i,
	oe_spim_sck_i,
	oe_i2s0_sck_i,
	oe_i2s0_ws_i,
	oe_i2s0_sdi_i,
	oe_i2s1_sdi_i,
	oe_cam_pclk_i,
	oe_cam_hsync_i,
	oe_cam_data0_i,
	oe_cam_data1_i,
	oe_cam_data2_i,
	oe_cam_data3_i,
	oe_cam_data4_i,
	oe_cam_data5_i,
	oe_cam_data6_i,
	oe_cam_data7_i,
	oe_cam_vsync_i,
	oe_i2c0_sda_i,
	oe_i2c0_scl_i,
	oe_uart_rx_i,
	oe_uart_tx_i,
	out_sdio_clk_i,
	out_sdio_cmd_i,
	out_sdio_data0_i,
	out_sdio_data1_i,
	out_sdio_data2_i,
	out_sdio_data3_i,
	out_spim_sdio0_i,
	out_spim_sdio1_i,
	out_spim_sdio2_i,
	out_spim_sdio3_i,
	out_spim_csn0_i,
	out_spim_csn1_i,
	out_spim_sck_i,
	out_i2s0_sck_i,
	out_i2s0_ws_i,
	out_i2s0_sdi_i,
	out_i2s1_sdi_i,
	out_cam_pclk_i,
	out_cam_hsync_i,
	out_cam_data0_i,
	out_cam_data1_i,
	out_cam_data2_i,
	out_cam_data3_i,
	out_cam_data4_i,
	out_cam_data5_i,
	out_cam_data6_i,
	out_cam_data7_i,
	out_cam_vsync_i,
	out_i2c0_sda_i,
	out_i2c0_scl_i,
	out_uart_rx_i,
	out_uart_tx_i,
	gatemram_vdd,
	gatemram_vdda,
	gatemram_vref,
	hold_wu,
	step_wu,
	wu_bypass_en,
	wu_bypass_data_in,
	wu_bypass_shift,
	wu_bypass_mux,
	wu_bypass_data_out,
	ext_pg_logic,
	ext_pg_l2,
	ext_pg_l2_udma,
	ext_pg_l1,
	ext_pg_udma,
	ext_pg_mram,
	scan_en_in,
	soc_scan_in,
	soc_scan_out,
	per_scan_in,
	per_scan_out,
	ref_scan_in,
	ref_scan_out,
	in_sdio_clk_o,
	in_sdio_cmd_o,
	in_sdio_data0_mux_o,
	in_sdio_data1_mux_o,
	in_sdio_data2_mux_o,
	in_sdio_data3_o,
	in_spim_sdio0_o,
	in_spim_sdio1_o,
	in_spim_sdio2_o,
	in_spim_sdio3_o,
	in_spim_csn0_o,
	in_spim_csn1_o,
	in_spim_sck_o,
	in_i2s0_sck_o,
	in_i2s0_ws_o,
	in_i2s0_sdi_o,
	in_i2s1_sdi_o,
	in_cam_pclk_mux_o,
	in_cam_hsync_mux_o,
	in_cam_data0_mux_o,
	in_cam_data1_mux_o,
	in_cam_data2_mux_o,
	in_cam_data3_mux_o,
	in_cam_data4_mux_o,
	in_cam_data5_mux_o,
	in_cam_data6_mux_o,
	in_cam_data7_mux_o,
	in_cam_vsync_o,
	in_i2c0_sda_o,
	in_i2c0_scl_o,
	in_uart_rx_o,
	in_uart_tx_o,
	bootsel_o,
	pad_sdio_clk,
	pad_sdio_cmd,
	pad_sdio_data0,
	pad_sdio_data1,
	pad_sdio_data2,
	pad_sdio_data3,
	pad_spim_sdio0,
	pad_spim_sdio1,
	pad_spim_sdio2,
	pad_spim_sdio3,
	pad_spim_csn0,
	pad_spim_csn1,
	pad_spim_sck,
	pad_i2s0_sck,
	pad_i2s0_ws,
	pad_i2s0_sdi,
	pad_i2s1_sdi,
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
	pad_i2c0_sda,
	pad_i2c0_scl,
	pad_uart_rx,
	pad_uart_tx,
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
	input wire [287:0] pad_cfg_i;
	output wire ref_clk_o;
	output wire clk_soc_ext_o;
	output wire clk_per_ext_o;
	output wire rstn_o;
	output wire jtag_tck_o;
	output wire jtag_tdi_o;
	input wire jtag_tdo_i;
	output wire jtag_tms_o;
	output wire jtag_trst_o;
	input wire oe_sdio_clk_i;
	input wire oe_sdio_cmd_i;
	input wire oe_sdio_data0_i;
	input wire oe_sdio_data1_i;
	input wire oe_sdio_data2_i;
	input wire oe_sdio_data3_i;
	input wire oe_spim_sdio0_i;
	input wire oe_spim_sdio1_i;
	input wire oe_spim_sdio2_i;
	input wire oe_spim_sdio3_i;
	input wire oe_spim_csn0_i;
	input wire oe_spim_csn1_i;
	input wire oe_spim_sck_i;
	input wire oe_i2s0_sck_i;
	input wire oe_i2s0_ws_i;
	input wire oe_i2s0_sdi_i;
	input wire oe_i2s1_sdi_i;
	input wire oe_cam_pclk_i;
	input wire oe_cam_hsync_i;
	input wire oe_cam_data0_i;
	input wire oe_cam_data1_i;
	input wire oe_cam_data2_i;
	input wire oe_cam_data3_i;
	input wire oe_cam_data4_i;
	input wire oe_cam_data5_i;
	input wire oe_cam_data6_i;
	input wire oe_cam_data7_i;
	input wire oe_cam_vsync_i;
	input wire oe_i2c0_sda_i;
	input wire oe_i2c0_scl_i;
	input wire oe_uart_rx_i;
	input wire oe_uart_tx_i;
	input wire out_sdio_clk_i;
	input wire out_sdio_cmd_i;
	input wire out_sdio_data0_i;
	input wire out_sdio_data1_i;
	input wire out_sdio_data2_i;
	input wire out_sdio_data3_i;
	input wire out_spim_sdio0_i;
	input wire out_spim_sdio1_i;
	input wire out_spim_sdio2_i;
	input wire out_spim_sdio3_i;
	input wire out_spim_csn0_i;
	input wire out_spim_csn1_i;
	input wire out_spim_sck_i;
	input wire out_i2s0_sck_i;
	input wire out_i2s0_ws_i;
	input wire out_i2s0_sdi_i;
	input wire out_i2s1_sdi_i;
	input wire out_cam_pclk_i;
	input wire out_cam_hsync_i;
	input wire out_cam_data0_i;
	input wire out_cam_data1_i;
	input wire out_cam_data2_i;
	input wire out_cam_data3_i;
	input wire out_cam_data4_i;
	input wire out_cam_data5_i;
	input wire out_cam_data6_i;
	input wire out_cam_data7_i;
	input wire out_cam_vsync_i;
	input wire out_i2c0_sda_i;
	input wire out_i2c0_scl_i;
	input wire out_uart_rx_i;
	input wire out_uart_tx_i;
	input wire gatemram_vdd;
	input wire gatemram_vdda;
	input wire gatemram_vref;
	output wire hold_wu;
	output wire step_wu;
	output reg wu_bypass_en;
	output reg wu_bypass_data_in;
	output reg wu_bypass_shift;
	output wire wu_bypass_mux;
	input wire wu_bypass_data_out;
	output reg ext_pg_logic;
	output reg ext_pg_l2;
	output reg ext_pg_l2_udma;
	output reg ext_pg_l1;
	output reg ext_pg_udma;
	output reg ext_pg_mram;
	output wire scan_en_in;
	output reg soc_scan_in;
	input wire soc_scan_out;
	output reg per_scan_in;
	input wire per_scan_out;
	output reg ref_scan_in;
	input wire ref_scan_out;
	output wire in_sdio_clk_o;
	output wire in_sdio_cmd_o;
	output reg in_sdio_data0_mux_o;
	output reg in_sdio_data1_mux_o;
	output reg in_sdio_data2_mux_o;
	output wire in_sdio_data3_o;
	output wire in_spim_sdio0_o;
	output wire in_spim_sdio1_o;
	output wire in_spim_sdio2_o;
	output wire in_spim_sdio3_o;
	output wire in_spim_csn0_o;
	output wire in_spim_csn1_o;
	output wire in_spim_sck_o;
	output wire in_i2s0_sck_o;
	output wire in_i2s0_ws_o;
	output wire in_i2s0_sdi_o;
	output wire in_i2s1_sdi_o;
	output reg in_cam_pclk_mux_o;
	output reg in_cam_hsync_mux_o;
	output reg in_cam_data0_mux_o;
	output reg in_cam_data1_mux_o;
	output reg in_cam_data2_mux_o;
	output reg in_cam_data3_mux_o;
	output reg in_cam_data4_mux_o;
	output reg in_cam_data5_mux_o;
	output reg in_cam_data6_mux_o;
	output reg in_cam_data7_mux_o;
	output wire in_cam_vsync_o;
	output wire in_i2c0_sda_o;
	output wire in_i2c0_scl_o;
	output wire in_uart_rx_o;
	output wire in_uart_tx_o;
	output wire bootsel_o;
	inout wire pad_sdio_clk;
	inout wire pad_sdio_cmd;
	inout wire pad_sdio_data0;
	inout wire pad_sdio_data1;
	inout wire pad_sdio_data2;
	inout wire pad_sdio_data3;
	inout wire pad_spim_sdio0;
	inout wire pad_spim_sdio1;
	inout wire pad_spim_sdio2;
	inout wire pad_spim_sdio3;
	inout wire pad_spim_csn0;
	inout wire pad_spim_csn1;
	inout wire pad_spim_sck;
	inout wire pad_i2s0_sck;
	inout wire pad_i2s0_ws;
	inout wire pad_i2s0_sdi;
	inout wire pad_i2s1_sdi;
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
	inout wire pad_i2c0_sda;
	inout wire pad_i2c0_scl;
	inout wire pad_uart_rx;
	inout wire pad_uart_tx;
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
	wire debug_ctrl;
	wire in_cam_pclk_o;
	wire in_cam_hsync_o;
	wire in_cam_data0_o;
	wire in_cam_data1_o;
	wire in_cam_data2_o;
	wire in_cam_data3_o;
	wire in_cam_data4_o;
	wire in_cam_data5_o;
	wire in_cam_data6_o;
	wire in_cam_data7_o;
	wire in_sdio_data0_o;
	wire in_sdio_data1_o;
	wire in_sdio_data2_o;
	wire io_pwr_ok_a;
	wire pwr_ok_a;
	wire io_pwr_ok_b;
	wire pwr_ok_b;
	wire io_pwr_ok_c;
	wire pwr_ok_c;
	wire netTie0;
	assign netTie0 = 1'b0;
	pad_functional_h_pd padinst_sdio_data0(
		.OEN(~oe_sdio_data0_i || scan_en_in),
		.I(out_sdio_data0_i),
		.io_pwr_ok(),
		.pwr_ok(),
		.O(in_sdio_data0_o),
		.PAD(pad_sdio_data0),
		.PEN(~pad_cfg_i[132] || scan_en_in)
	);
	pad_functional_h_pd padinst_sdio_data1(
		.OEN(~oe_sdio_data1_i || scan_en_in),
		.I(out_sdio_data1_i),
		.io_pwr_ok(),
		.pwr_ok(),
		.O(in_sdio_data1_o),
		.PAD(pad_sdio_data1),
		.PEN(~pad_cfg_i[138] || scan_en_in)
	);
	pad_functional_h_pd padinst_sdio_data2(
		.OEN(~oe_sdio_data2_i || scan_en_in),
		.I(out_sdio_data2_i),
		.io_pwr_ok(),
		.pwr_ok(),
		.O(in_sdio_data2_o),
		.PAD(pad_sdio_data2),
		.PEN(~pad_cfg_i[144] || scan_en_in)
	);
	pad_functional_h_pd padinst_sdio_data3(
		.OEN(~oe_sdio_data3_i),
		.I(out_sdio_data3_i),
		.io_pwr_ok(),
		.pwr_ok(),
		.O(in_sdio_data3_o),
		.PAD(pad_sdio_data3),
		.PEN(~pad_cfg_i[150])
	);
	pad_functional_h_pd padinst_sdio_clk(
		.OEN(~oe_sdio_clk_i),
		.I(out_sdio_clk_i),
		.io_pwr_ok(),
		.pwr_ok(),
		.O(in_sdio_clk_o),
		.PAD(pad_sdio_clk),
		.PEN(~pad_cfg_i[120])
	);
	pad_functional_h_pd padinst_sdio_cmd(
		.OEN(~oe_sdio_cmd_i),
		.I(out_sdio_cmd_i),
		.io_pwr_ok(),
		.pwr_ok(),
		.O(in_sdio_cmd_o),
		.PAD(pad_sdio_cmd),
		.PEN(~pad_cfg_i[126])
	);
	pad_functional_h_pd padinst_spim_sck(
		.OEN(~oe_spim_sck_i),
		.I(out_spim_sck_i),
		.io_pwr_ok(),
		.pwr_ok(),
		.O(in_spim_sck_o),
		.PAD(pad_spim_sck),
		.PEN(~pad_cfg_i[36])
	);
	pad_functional_h_pd padinst_spim_sdio0(
		.OEN(~oe_spim_sdio0_i),
		.I(out_spim_sdio0_i),
		.io_pwr_ok(),
		.pwr_ok(),
		.O(in_spim_sdio0_o),
		.PAD(pad_spim_sdio0),
		.PEN(~pad_cfg_i[0])
	);
	pad_functional_h_pd padinst_spim_sdio1(
		.OEN(~oe_spim_sdio1_i),
		.I(out_spim_sdio1_i),
		.io_pwr_ok(),
		.pwr_ok(),
		.O(in_spim_sdio1_o),
		.PAD(pad_spim_sdio1),
		.PEN(~pad_cfg_i[6])
	);
	pad_functional_h_pd padinst_spim_sdio2(
		.OEN(~oe_spim_sdio2_i),
		.I(out_spim_sdio2_i),
		.io_pwr_ok(),
		.pwr_ok(),
		.O(in_spim_sdio2_o),
		.PAD(pad_spim_sdio2),
		.PEN(~pad_cfg_i[12])
	);
	pad_functional_h_pd padinst_spim_sdio3(
		.OEN(~oe_spim_sdio3_i),
		.I(out_spim_sdio3_i),
		.io_pwr_ok(),
		.pwr_ok(),
		.O(in_spim_sdio3_o),
		.PAD(pad_spim_sdio3),
		.PEN(~pad_cfg_i[18])
	);
	pad_functional_h_pd padinst_spim_csn1(
		.OEN(~oe_spim_csn1_i),
		.I(out_spim_csn1_i),
		.io_pwr_ok(),
		.pwr_ok(),
		.O(in_spim_csn1_o),
		.PAD(pad_spim_csn1),
		.PEN(~pad_cfg_i[30])
	);
	pad_functional_h_pd padinst_spim_csn0(
		.OEN(~oe_spim_csn0_i),
		.I(out_spim_csn0_i),
		.io_pwr_ok(),
		.pwr_ok(),
		.O(in_spim_csn0_o),
		.PAD(pad_spim_csn0),
		.PEN(~pad_cfg_i[24])
	);
	pad_functional_h_pd padinst_i2s1_sdi(
		.OEN(~oe_i2s1_sdi_i),
		.I(out_i2s1_sdi_i),
		.io_pwr_ok(),
		.pwr_ok(),
		.O(in_i2s1_sdi_o),
		.PAD(pad_i2s1_sdi),
		.PEN(~pad_cfg_i[228])
	);
	pad_functional_h_pd padinst_i2s0_ws(
		.OEN(~oe_i2s0_ws_i),
		.I(out_i2s0_ws_i),
		.io_pwr_ok(),
		.pwr_ok(),
		.O(in_i2s0_ws_o),
		.PAD(pad_i2s0_ws),
		.PEN(~pad_cfg_i[216])
	);
	pad_functional_h_pd padinst_i2s0_sdi(
		.OEN(~oe_i2s0_sdi_i),
		.I(out_i2s0_sdi_i),
		.io_pwr_ok(),
		.pwr_ok(),
		.O(in_i2s0_sdi_o),
		.PAD(pad_i2s0_sdi),
		.PEN(~pad_cfg_i[222])
	);
	pad_functional_h_pd padinst_i2s0_sck(
		.OEN(~oe_i2s0_sck_i),
		.I(out_i2s0_sck_i),
		.io_pwr_ok(),
		.pwr_ok(),
		.O(in_i2s0_sck_o),
		.PAD(pad_i2s0_sck),
		.PEN(~pad_cfg_i[210])
	);
	pad_functional_h_pd padinst_cam_pclk(
		.OEN(~oe_cam_pclk_i || debug_ctrl),
		.I(out_cam_pclk_i),
		.io_pwr_ok(),
		.pwr_ok(),
		.O(in_cam_pclk_o),
		.PAD(pad_cam_pclk),
		.PEN(~pad_cfg_i[54] || debug_ctrl)
	);
	pad_functional_h_pd padinst_cam_hsync(
		.OEN(~oe_cam_hsync_i || debug_ctrl),
		.I(out_cam_hsync_i),
		.io_pwr_ok(),
		.pwr_ok(),
		.O(in_cam_hsync_o),
		.PAD(pad_cam_hsync),
		.PEN(~pad_cfg_i[60] || debug_ctrl)
	);
	pad_functional_h_pd padinst_cam_data0(
		.OEN(~oe_cam_data0_i || debug_ctrl),
		.I(out_cam_data0_i),
		.io_pwr_ok(),
		.pwr_ok(),
		.O(in_cam_data0_o),
		.PAD(pad_cam_data0),
		.PEN(~pad_cfg_i[66] || debug_ctrl)
	);
	pad_functional_h_pd padinst_cam_data1(
		.OEN(~oe_cam_data1_i),
		.I(out_cam_data1_i),
		.io_pwr_ok(),
		.pwr_ok(),
		.O(in_cam_data1_o),
		.PAD(pad_cam_data1),
		.PEN(~pad_cfg_i[72])
	);
	pad_functional_h_pd padinst_cam_data2(
		.OEN(~oe_cam_data2_i || debug_ctrl),
		.I(out_cam_data2_i),
		.io_pwr_ok(),
		.pwr_ok(),
		.O(in_cam_data2_o),
		.PAD(pad_cam_data2),
		.PEN(~pad_cfg_i[78] || debug_ctrl)
	);
	pad_functional_h_pd padinst_cam_data3(
		.OEN(~oe_cam_data3_i || debug_ctrl),
		.I(out_cam_data3_i),
		.io_pwr_ok(),
		.pwr_ok(),
		.O(in_cam_data3_o),
		.PAD(pad_cam_data3),
		.PEN(~pad_cfg_i[84] || debug_ctrl)
	);
	pad_functional_h_pd padinst_cam_data4(
		.OEN(~oe_cam_data4_i || debug_ctrl),
		.I(out_cam_data4_i),
		.io_pwr_ok(),
		.pwr_ok(),
		.O(in_cam_data4_o),
		.PAD(pad_cam_data4),
		.PEN(~pad_cfg_i[90] || debug_ctrl)
	);
	pad_functional_h_pd padinst_cam_data5(
		.OEN(~oe_cam_data5_i || debug_ctrl),
		.I(out_cam_data5_i),
		.io_pwr_ok(),
		.pwr_ok(),
		.O(in_cam_data5_o),
		.PAD(pad_cam_data5),
		.PEN(~pad_cfg_i[96] || debug_ctrl)
	);
	pad_functional_h_pd padinst_cam_data6(
		.OEN(~oe_cam_data6_i || debug_ctrl),
		.I(out_cam_data6_i),
		.io_pwr_ok(),
		.pwr_ok(),
		.O(in_cam_data6_o),
		.PAD(pad_cam_data6),
		.PEN(~pad_cfg_i[102] || debug_ctrl)
	);
	pad_functional_h_pd padinst_cam_data7(
		.OEN(~oe_cam_data7_i || debug_ctrl),
		.I(out_cam_data7_i),
		.io_pwr_ok(),
		.pwr_ok(),
		.O(in_cam_data7_o),
		.PAD(pad_cam_data7),
		.PEN(~pad_cfg_i[108] || debug_ctrl)
	);
	pad_functional_h_pd padinst_cam_vsync(
		.OEN(~oe_cam_vsync_i),
		.I(out_cam_vsync_i),
		.io_pwr_ok(),
		.pwr_ok(),
		.O(in_cam_vsync_o),
		.PAD(pad_cam_vsync),
		.PEN(~pad_cfg_i[114])
	);
	pad_functional_h_pd padinst_uart_rx(
		.OEN(~oe_uart_rx_i),
		.I(out_uart_rx_i),
		.io_pwr_ok(),
		.pwr_ok(),
		.O(in_uart_rx_o),
		.PAD(pad_uart_rx),
		.PEN(~pad_cfg_i[198])
	);
	pad_functional_h_pd padinst_uart_tx(
		.OEN(~oe_uart_tx_i),
		.I(out_uart_tx_i),
		.io_pwr_ok(),
		.pwr_ok(),
		.O(in_uart_tx_o),
		.PAD(pad_uart_tx),
		.PEN(~pad_cfg_i[204])
	);
	pad_functional_h_pd padinst_i2c0_sda(
		.OEN(~oe_i2c0_sda_i),
		.I(out_i2c0_sda_i),
		.io_pwr_ok(),
		.pwr_ok(),
		.O(in_i2c0_sda_o),
		.PAD(pad_i2c0_sda),
		.PEN(~pad_cfg_i[42])
	);
	pad_functional_h_pd padinst_i2c0_scl(
		.OEN(~oe_i2c0_scl_i),
		.I(out_i2c0_scl_i),
		.io_pwr_ok(),
		.pwr_ok(),
		.O(in_i2c0_scl_o),
		.PAD(pad_i2c0_scl),
		.PEN(~pad_cfg_i[48])
	);
	pad_functional_h_pd padinst_bootsel(
		.OEN(1'b1),
		.I(),
		.io_pwr_ok(),
		.pwr_ok(),
		.O(bootsel_o),
		.PAD(pad_bootsel),
		.PEN(1'b1)
	);
	pad_functional_h_pd padinst_ref_clk(
		.OEN(1'b1),
		.I(),
		.io_pwr_ok(),
		.pwr_ok(),
		.O(ref_clk_o),
		.PAD(pad_xtal_in),
		.PEN(1'b1)
	);
	pad_functional_h_pd padinst_clk_soc_ext(
		.OEN(1'b1),
		.I(),
		.io_pwr_ok(),
		.pwr_ok(),
		.O(clk_soc_ext_o),
		.PAD(pad_clk_soc_ext),
		.PEN(1'b1)
	);
	pad_functional_h_pd padinst_clk_per_ext(
		.OEN(1'b1),
		.I(),
		.io_pwr_ok(),
		.pwr_ok(),
		.O(clk_per_ext_o),
		.PAD(pad_clk_per_ext),
		.PEN(1'b1)
	);
	pad_functional_h_pd padinst_reset_n(
		.OEN(1'b1),
		.I(),
		.io_pwr_ok(),
		.pwr_ok(),
		.O(rstn_o),
		.PAD(pad_reset_n),
		.PEN(1'b1)
	);
	pad_functional_h_pd padinst_jtag_tck(
		.OEN(1'b1),
		.I(),
		.io_pwr_ok(),
		.pwr_ok(),
		.O(jtag_tck_o),
		.PAD(pad_jtag_tck),
		.PEN(1'b1)
	);
	pad_functional_h_pd padinst_jtag_tms(
		.OEN(1'b1),
		.I(),
		.io_pwr_ok(),
		.pwr_ok(),
		.O(jtag_tms_o),
		.PAD(pad_jtag_tms),
		.PEN(1'b1)
	);
	pad_functional_h_pd padinst_jtag_tdi(
		.OEN(1'b1),
		.I(),
		.io_pwr_ok(),
		.pwr_ok(),
		.O(jtag_tdi_o),
		.PAD(pad_jtag_tdi),
		.PEN(1'b1)
	);
	pad_functional_h_pd padinst_jtag_trstn(
		.OEN(1'b1),
		.I(),
		.io_pwr_ok(),
		.pwr_ok(),
		.O(jtag_trst_o),
		.PAD(pad_jtag_trst),
		.PEN(1'b1)
	);
	pad_functional_h_pd padinst_jtag_tdo(
		.OEN(1'b0),
		.I(jtag_tdo_i),
		.io_pwr_ok(),
		.pwr_ok(),
		.O(),
		.PAD(pad_jtag_tdo),
		.PEN(1'b1)
	);
	pad_functional_h_pd padinst_gatemram_vdd(
		.OEN(1'b0),
		.I(gatemram_vdd),
		.io_pwr_ok(),
		.pwr_ok(),
		.O(),
		.PAD(pad_gatemram_vdd),
		.PEN(1'b1)
	);
	pad_functional_h_pd padinst_gatemram_vdda(
		.OEN(1'b0),
		.I(gatemram_vdda),
		.io_pwr_ok(),
		.pwr_ok(),
		.O(),
		.PAD(pad_gatemram_vdda),
		.PEN(1'b1)
	);
	pad_functional_h_pd padinst_gatemram_vref(
		.OEN(1'b0),
		.I(gatemram_vref),
		.io_pwr_ok(),
		.pwr_ok(),
		.O(),
		.PAD(pad_gatemram_vref),
		.PEN(1'b1)
	);
	pad_functional_h_pd padinst_wu_bypass(
		.OEN(1'b0),
		.I(wu_bypass_data_out),
		.io_pwr_ok(),
		.pwr_ok(),
		.O(),
		.PAD(pad_wu_bypass_out),
		.PEN(1'b1)
	);
	pad_functional_h_pd padinst_wu_bypass_mux(
		.OEN(1'b1),
		.I(),
		.io_pwr_ok(),
		.pwr_ok(),
		.O(wu_bypass_mux),
		.PAD(pad_wu_bypass_mux),
		.PEN(1'b1)
	);
	pad_functional_h_pd padinst_hold_wu(
		.OEN(1'b1),
		.I(),
		.io_pwr_ok(),
		.pwr_ok(),
		.O(hold_wu),
		.PAD(pad_hold_wu),
		.PEN(1'b1)
	);
	pad_functional_h_pd padinst_step_wu(
		.OEN(1'b1),
		.I(),
		.io_pwr_ok(),
		.pwr_ok(),
		.O(step_wu),
		.PAD(pad_step_wu),
		.PEN(1'b1)
	);
	pad_functional_h_pd padinst_debug(
		.OEN(1'b1),
		.I(),
		.io_pwr_ok(),
		.pwr_ok(),
		.O(debug_ctrl),
		.PAD(pad_debug_ctrl),
		.PEN(1'b1)
	);
	pad_functional_h_pd padinst_scan_chain_en(
		.OEN(1'b1),
		.I(),
		.io_pwr_ok(),
		.pwr_ok(),
		.O(scan_en_in),
		.PAD(pad_scan_en_in),
		.PEN(1'b1)
	);
	pad_functional_h_pd padinst_scan_chain_soc_out(
		.OEN(1'b0),
		.I(),
		.io_pwr_ok(),
		.pwr_ok(),
		.O(),
		.PAD(pad_soc_scan_out),
		.PEN(1'b1)
	);
	pad_functional_h_pd padinst_scan_chain_per_out(
		.OEN(1'b0),
		.I(),
		.io_pwr_ok(),
		.pwr_ok(),
		.O(),
		.PAD(pad_per_scan_out),
		.PEN(1'b1)
	);
	pad_functional_h_pd padinst_scan_chain_ref_out(
		.OEN(1'b0),
		.I(),
		.io_pwr_ok(),
		.pwr_ok(),
		.O(),
		.PAD(pad_ref_scan_out),
		.PEN(1'b1)
	);
	always @(*)
		if (debug_ctrl) begin
			wu_bypass_en = in_cam_pclk_o;
			wu_bypass_data_in = in_cam_hsync_o;
			wu_bypass_shift = in_cam_data0_o;
			ext_pg_logic = in_cam_data2_o;
			ext_pg_l2 = in_cam_data3_o;
			ext_pg_l2_udma = in_cam_data4_o;
			ext_pg_l1 = in_cam_data5_o;
			ext_pg_udma = in_cam_data6_o;
			ext_pg_mram = in_cam_data7_o;
			in_cam_pclk_mux_o = 1'b0;
			in_cam_hsync_mux_o = 1'b0;
			in_cam_data0_mux_o = 1'b0;
			in_cam_data1_mux_o = 1'b0;
			in_cam_data2_mux_o = 1'b0;
			in_cam_data3_mux_o = 1'b0;
			in_cam_data4_mux_o = 1'b0;
			in_cam_data5_mux_o = 1'b0;
			in_cam_data6_mux_o = 1'b0;
			in_cam_data7_mux_o = 1'b0;
		end
		else begin
			in_cam_pclk_mux_o = in_cam_pclk_o;
			in_cam_hsync_mux_o = in_cam_hsync_o;
			in_cam_data0_mux_o = in_cam_data0_o;
			in_cam_data1_mux_o = in_cam_data1_o;
			in_cam_data2_mux_o = in_cam_data2_o;
			in_cam_data3_mux_o = in_cam_data3_o;
			in_cam_data4_mux_o = in_cam_data4_o;
			in_cam_data5_mux_o = in_cam_data5_o;
			in_cam_data6_mux_o = in_cam_data6_o;
			in_cam_data7_mux_o = in_cam_data7_o;
			wu_bypass_en = 1'b0;
			wu_bypass_data_in = 1'b0;
			wu_bypass_shift = 1'b0;
			ext_pg_logic = 1'b0;
			ext_pg_l2 = 1'b0;
			ext_pg_l2_udma = 1'b0;
			ext_pg_l1 = 1'b0;
			ext_pg_udma = 1'b0;
			ext_pg_mram = 1'b0;
		end
	always @(*)
		if (scan_en_in) begin
			soc_scan_in = in_sdio_data0_o;
			per_scan_in = in_sdio_data1_o;
			ref_scan_in = in_sdio_data2_o;
			in_sdio_data0_mux_o = 1'b0;
			in_sdio_data1_mux_o = 1'b0;
			in_sdio_data2_mux_o = 1'b0;
		end
		else begin
			in_sdio_data0_mux_o = in_sdio_data0_o;
			in_sdio_data1_mux_o = in_sdio_data1_o;
			in_sdio_data2_mux_o = in_sdio_data2_o;
			soc_scan_in = 1'b0;
			per_scan_in = 1'b0;
			ref_scan_in = 1'b0;
		end
endmodule
