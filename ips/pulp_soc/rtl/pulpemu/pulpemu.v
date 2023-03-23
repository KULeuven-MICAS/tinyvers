module pulpemu (
	DDR_addr,
	DDR_ba,
	DDR_cas_n,
	DDR_ck_n,
	DDR_ck_p,
	DDR_cke,
	DDR_cs_n,
	DDR_dm,
	DDR_dq,
	DDR_dqs_n,
	DDR_dqs_p,
	DDR_odt,
	DDR_ras_n,
	DDR_reset_n,
	DDR_we_n,
	FIXED_IO_ddr_vrn,
	FIXED_IO_ddr_vrp,
	FIXED_IO_mio,
	FIXED_IO_ps_clk,
	FIXED_IO_ps_porb,
	FIXED_IO_ps_srstb,
	FMC_mspi_sck,
	FMC_mspi_sdio3,
	FMC_mspi_sdio2,
	FMC_mspi_sdio1,
	FMC_mspi_sdio0,
	FMC_mspi_ncs0,
	FMC_mspi_ncs1,
	FMC_mspi_ncs2,
	FMC_sspi_sck,
	FMC_sspi_ncs,
	FMC_sspi_sdio3,
	FMC_sspi_sdio2,
	FMC_sspi_sdio1,
	FMC_sspi_sdio0,
	FMC_sens_int0,
	FMC_sens_int1,
	FMC_sens_int2,
	FMC_i2s_sck0,
	FMC_i2s_sdi0,
	FMC_i2s_sdi1,
	FMC_i2s_sdi2,
	FMC_i2s_sdi3,
	FMC_i2c_scl,
	FMC_i2c_sda,
	FMC_adc_sdi0,
	FMC_adc_sdi1,
	FMC_adc_sdi2,
	FMC_adc_sdi3,
	FMC_adc_sck,
	FMC_adc_ncs,
	FMC_gpio0,
	FMC_gpio1,
	FMC_gpio2,
	FMC_gpio3,
	FMC_gpio4,
	FMC_gpio5,
	FMC_gpio6,
	FMC_gpio7,
	FMC_loop0_o,
	FMC_loop0_i,
	FMC_loop1_o,
	FMC_loop1_i,
	FMC_loop2_o,
	FMC_loop2_i,
	FMC_loop3_o,
	FMC_loop3_i,
	FMC_loop4_o,
	FMC_loop4_i,
	FMC_cam_pclk,
	FMC_cam_href,
	FMC_cam_vsync,
	FMC_cam_d0,
	FMC_cam_d1,
	FMC_cam_d2,
	FMC_cam_d3,
	FMC_cam_d4,
	FMC_cam_d5,
	FMC_cam_d6,
	FMC_cam_d7,
	FMC_cam_sck,
	FMC_cam_mosi,
	FMC_cam_miso,
	FMC_cam_ncs,
	FMC_CHART_atreb215_cs1,
	FMC_CHART_atreb215_spi2_miso,
	FMC_CHART_atreb215_spi2_mosi,
	FMC_CHART_atreb215_spi2_sclk,
	FMC_CHART_enable_sky,
	FMC_CHART_pa0900_ant_sel,
	FMC_CHART_pa0900_ctx,
	FMC_CHART_pa0900_cps,
	FMC_CHART_pa0900_csd,
	FMC_CHART_rf_switch_1,
	FMC_CHART_rf_switch_2,
	FMC_CHART_sata1_ap,
	FMC_CHART_sata1_an,
	FMC_CHART_sata1_bp,
	FMC_CHART_sata1_bn,
	FMC_CHART_sata2_ap,
	FMC_CHART_sata2_an,
	FMC_CHART_sata3_ap,
	FMC_CHART_sata3_an,
	FMC_CHART_sata3_bp,
	FMC_CHART_sata3_bn,
	FMC_CHART_vdd_3v3_en,
	FMC_CHART_sky_spi_sdo,
	FMC_CHART_sky_spi_sck,
	FMC_CHART_sky_spi_sdi,
	FMC_CHART_sky_spi_ncs,
	FMC_CHART_user_led1,
	FMC_CHART_user_led2,
	FMC_CHART_user_led3,
	PAD_jtag_tdi,
	PAD_jtag_tdo,
	PAD_jtag_tms,
	PAD_jtag_trst,
	PAD_jtag_tck,
	PAD_reset_n
);
	inout [14:0] DDR_addr;
	inout [2:0] DDR_ba;
	inout DDR_cas_n;
	inout DDR_ck_n;
	inout DDR_ck_p;
	inout DDR_cke;
	inout DDR_cs_n;
	inout [3:0] DDR_dm;
	inout [31:0] DDR_dq;
	inout [3:0] DDR_dqs_n;
	inout [3:0] DDR_dqs_p;
	inout DDR_odt;
	inout DDR_ras_n;
	inout DDR_reset_n;
	inout DDR_we_n;
	inout FIXED_IO_ddr_vrn;
	inout FIXED_IO_ddr_vrp;
	inout [53:0] FIXED_IO_mio;
	inout FIXED_IO_ps_clk;
	inout FIXED_IO_ps_porb;
	inout FIXED_IO_ps_srstb;
	inout FMC_mspi_sck;
	inout FMC_mspi_sdio3;
	inout FMC_mspi_sdio2;
	inout FMC_mspi_sdio1;
	inout FMC_mspi_sdio0;
	inout FMC_mspi_ncs0;
	inout FMC_mspi_ncs1;
	inout FMC_mspi_ncs2;
	inout FMC_sspi_sck;
	inout FMC_sspi_ncs;
	inout FMC_sspi_sdio3;
	inout FMC_sspi_sdio2;
	inout FMC_sspi_sdio1;
	inout FMC_sspi_sdio0;
	inout FMC_sens_int0;
	inout FMC_sens_int1;
	inout FMC_sens_int2;
	inout FMC_i2s_sck0;
	inout FMC_i2s_sdi0;
	inout FMC_i2s_sdi1;
	inout FMC_i2s_sdi2;
	inout FMC_i2s_sdi3;
	inout FMC_i2c_scl;
	inout FMC_i2c_sda;
	inout FMC_adc_sdi0;
	inout FMC_adc_sdi1;
	inout FMC_adc_sdi2;
	inout FMC_adc_sdi3;
	inout FMC_adc_sck;
	inout FMC_adc_ncs;
	inout FMC_gpio0;
	inout FMC_gpio1;
	inout FMC_gpio2;
	inout FMC_gpio3;
	inout FMC_gpio4;
	inout FMC_gpio5;
	inout FMC_gpio6;
	inout FMC_gpio7;
	inout FMC_loop0_o;
	inout FMC_loop0_i;
	inout FMC_loop1_o;
	inout FMC_loop1_i;
	inout FMC_loop2_o;
	inout FMC_loop2_i;
	inout FMC_loop3_o;
	inout FMC_loop3_i;
	inout FMC_loop4_o;
	inout FMC_loop4_i;
	inout FMC_cam_pclk;
	inout FMC_cam_href;
	inout FMC_cam_vsync;
	inout FMC_cam_d0;
	inout FMC_cam_d1;
	inout FMC_cam_d2;
	inout FMC_cam_d3;
	inout FMC_cam_d4;
	inout FMC_cam_d5;
	inout FMC_cam_d6;
	inout FMC_cam_d7;
	inout FMC_cam_sck;
	inout FMC_cam_mosi;
	inout FMC_cam_miso;
	inout FMC_cam_ncs;
	inout FMC_CHART_atreb215_cs1;
	inout FMC_CHART_atreb215_spi2_miso;
	inout FMC_CHART_atreb215_spi2_mosi;
	inout FMC_CHART_atreb215_spi2_sclk;
	inout FMC_CHART_enable_sky;
	inout FMC_CHART_pa0900_ant_sel;
	inout FMC_CHART_pa0900_ctx;
	inout FMC_CHART_pa0900_cps;
	inout FMC_CHART_pa0900_csd;
	inout FMC_CHART_rf_switch_1;
	inout FMC_CHART_rf_switch_2;
	inout FMC_CHART_sata1_ap;
	inout FMC_CHART_sata1_an;
	inout FMC_CHART_sata1_bp;
	inout FMC_CHART_sata1_bn;
	inout FMC_CHART_sata2_ap;
	inout FMC_CHART_sata2_an;
	inout FMC_CHART_sata3_ap;
	inout FMC_CHART_sata3_an;
	inout FMC_CHART_sata3_bp;
	inout FMC_CHART_sata3_bn;
	inout FMC_CHART_vdd_3v3_en;
	inout FMC_CHART_sky_spi_sdo;
	inout FMC_CHART_sky_spi_sck;
	inout FMC_CHART_sky_spi_sdi;
	inout FMC_CHART_sky_spi_ncs;
	inout FMC_CHART_user_led1;
	inout FMC_CHART_user_led2;
	inout FMC_CHART_user_led3;
	inout PAD_jtag_tdi;
	inout PAD_jtag_tdo;
	inout PAD_jtag_tms;
	inout PAD_jtag_trst;
	inout PAD_jtag_tck;
	inout PAD_reset_n;
	localparam NB_CORES = 8;
	localparam AXI_ADDR_WIDTH = 32;
	localparam AXI_DATA_WIDTH = 64;
	localparam AXI_ID_WIDTH = 7;
	localparam AXI_USER_WIDTH = 6;
	localparam AXI_STRB_WIDTH = 8;
	wire mode_fmc_zynqn;
	wire zynq_clk;
	wire zynq_rst_n;
	wire pulp_soc_clk;
	wire pulp_cluster_clk;
	wire pulp_cluster_clk_gated;
	wire pulp_soc_rst_n;
	wire [31:0] pulp2zynq_gpio;
	wire [31:0] zynq2pulp_gpio;
	wire pad_xtal_in;
	wire pad_xtal_out;
	wire pad_bootmode;
	wire pulp_eoc;
	wire pulp_spi_master0_clk;
	wire [1:0] pulp_spi_master0_csn;
	wire [1:0] pulp_spi_master0_mode;
	wire pulp_spi_master0_sdo0;
	wire pulp_spi_master0_sdo1;
	wire pulp_spi_master0_sdo2;
	wire pulp_spi_master0_sdo3;
	wire pulp_spi_master0_sdi0;
	wire pulp_spi_master0_sdi1;
	wire pulp_spi_master0_sdi2;
	wire pulp_spi_master0_sdi3;
	wire pulp_spi_slave_clk;
	wire pulp_spi_slave_csn;
	wire [1:0] pulp_spi_slave_mode;
	wire pulp_spi_slave_sdo0;
	wire pulp_spi_slave_sdo1;
	wire pulp_spi_slave_sdo2;
	wire pulp_spi_slave_sdo3;
	wire pulp_spi_slave_sdi0;
	wire pulp_spi_slave_sdi1;
	wire pulp_spi_slave_sdi2;
	wire pulp_spi_slave_sdi3;
	wire s_zynq_safen_spis;
	wire s_zynq_safen_spim;
	wire s_zynq_safen_uart;
	wire s_zynq2soc_spis_sck;
	wire s_zynq2soc_spis_csn;
	wire s_zynq2soc_spis_sdo0;
	wire s_zynq2soc_spis_sdo1;
	wire s_zynq2soc_spis_sdo2;
	wire s_zynq2soc_spis_sdo3;
	wire s_zynq2soc_spis_sdi0;
	wire s_zynq2soc_spis_sdi1;
	wire s_zynq2soc_spis_sdi2;
	wire s_zynq2soc_spis_sdi3;
	wire s_zynq2soc_spim_sck;
	wire s_zynq2soc_spim_csn;
	wire s_zynq2soc_spim_sdo0;
	wire s_zynq2soc_spim_sdo1;
	wire s_zynq2soc_spim_sdo2;
	wire s_zynq2soc_spim_sdo3;
	wire s_zynq2soc_spim_sdi0;
	wire s_zynq2soc_spim_sdi1;
	wire s_zynq2soc_spim_sdi2;
	wire s_zynq2soc_spim_sdi3;
	wire s_zynq2soc_uart_rx;
	wire s_zynq2soc_uart_tx;
	wire fetch_en;
	wire fault_en;
	wire cg_clken;
	wire [15:0] trace_master_addr;
	wire trace_master_clk;
	wire [31:0] trace_master_din;
	wire [31:0] trace_master_dout;
	wire trace_master_en;
	wire trace_master_rst;
	wire trace_master_we;
	wire [511:0] instr_trace_cycles;
	wire [255:0] instr_trace_instr;
	wire [255:0] instr_trace_pc;
	wire [7:0] instr_trace_valid;
	wire trace_flushed;
	wire trace_wait;
	wire stdout_flushed;
	wire stdout_wait;
	wire [31:0] zynq2pulp_apb_paddr;
	wire zynq2pulp_apb_penable;
	wire [31:0] zynq2pulp_apb_prdata;
	wire [0:0] zynq2pulp_apb_pready;
	wire [0:0] zynq2pulp_apb_psel;
	wire [0:0] zynq2pulp_apb_pslverr;
	wire [31:0] zynq2pulp_apb_pwdata;
	wire zynq2pulp_apb_pwrite;
	wire [31:0] zynq2pulp_spi_slave_paddr;
	wire zynq2pulp_spi_slave_penable;
	wire [31:0] zynq2pulp_spi_slave_prdata;
	wire zynq2pulp_spi_slave_pready;
	wire zynq2pulp_spi_slave_psel;
	wire zynq2pulp_spi_slave_pslverr;
	wire [31:0] zynq2pulp_spi_slave_pwdata;
	wire zynq2pulp_spi_slave_pwrite;
	wire [31:0] zynq2pulp_uart_paddr;
	wire zynq2pulp_uart_penable;
	wire [31:0] zynq2pulp_uart_prdata;
	wire zynq2pulp_uart_pready;
	wire zynq2pulp_uart_psel;
	wire zynq2pulp_uart_pslverr;
	wire [31:0] zynq2pulp_uart_pwdata;
	wire zynq2pulp_uart_pwrite;
	wire pulp2zynq_axi_aw_valid;
	wire [31:0] pulp2zynq_axi_aw_addr;
	wire [2:0] pulp2zynq_axi_aw_prot;
	wire [3:0] pulp2zynq_axi_aw_region;
	wire [7:0] pulp2zynq_axi_aw_len;
	wire [2:0] pulp2zynq_axi_aw_size;
	wire [1:0] pulp2zynq_axi_aw_burst;
	wire pulp2zynq_axi_aw_lock;
	wire [3:0] pulp2zynq_axi_aw_cache;
	wire [3:0] pulp2zynq_axi_aw_qos;
	wire [6:0] pulp2zynq_axi_aw_id;
	wire [5:0] pulp2zynq_axi_aw_user;
	wire pulp2zynq_axi_aw_ready;
	wire pulp2zynq_axi_ar_valid;
	wire [31:0] pulp2zynq_axi_ar_addr;
	wire [2:0] pulp2zynq_axi_ar_prot;
	wire [3:0] pulp2zynq_axi_ar_region;
	wire [7:0] pulp2zynq_axi_ar_len;
	wire [2:0] pulp2zynq_axi_ar_size;
	wire [1:0] pulp2zynq_axi_ar_burst;
	wire pulp2zynq_axi_ar_lock;
	wire [3:0] pulp2zynq_axi_ar_cache;
	wire [3:0] pulp2zynq_axi_ar_qos;
	wire [6:0] pulp2zynq_axi_ar_id;
	wire [5:0] pulp2zynq_axi_ar_user;
	wire pulp2zynq_axi_ar_ready;
	wire pulp2zynq_axi_w_valid;
	wire [63:0] pulp2zynq_axi_w_data;
	wire [7:0] pulp2zynq_axi_w_strb;
	wire [5:0] pulp2zynq_axi_w_user;
	wire pulp2zynq_axi_w_last;
	wire pulp2zynq_axi_w_ready;
	wire pulp2zynq_axi_r_valid;
	wire [63:0] pulp2zynq_axi_r_data;
	wire [1:0] pulp2zynq_axi_r_resp;
	wire pulp2zynq_axi_r_last;
	wire [6:0] pulp2zynq_axi_r_id;
	wire [5:0] pulp2zynq_axi_r_user;
	wire pulp2zynq_axi_r_ready;
	wire pulp2zynq_axi_b_valid;
	wire [1:0] pulp2zynq_axi_b_resp;
	wire [6:0] pulp2zynq_axi_b_id;
	wire [5:0] pulp2zynq_axi_b_user;
	wire pulp2zynq_axi_b_ready;
	pulp_chip pulp_chip_i(
		.zynq_safen_spis_i(s_zynq_safen_spis),
		.zynq_safen_spim_i(s_zynq_safen_spim),
		.zynq_safen_uart_i(s_zynq_safen_uart),
		.zynq2soc_spis_sck_i(s_zynq2soc_spis_sck),
		.zynq2soc_spis_csn_i(s_zynq2soc_spis_csn),
		.zynq2soc_spis_sdo0_i(s_zynq2soc_spis_sdo0),
		.zynq2soc_spis_sdo1_i(s_zynq2soc_spis_sdo1),
		.zynq2soc_spis_sdo2_i(s_zynq2soc_spis_sdo2),
		.zynq2soc_spis_sdo3_i(s_zynq2soc_spis_sdo3),
		.zynq2soc_spis_sdi0_o(s_zynq2soc_spis_sdi0),
		.zynq2soc_spis_sdi1_o(s_zynq2soc_spis_sdi1),
		.zynq2soc_spis_sdi2_o(s_zynq2soc_spis_sdi2),
		.zynq2soc_spis_sdi3_o(s_zynq2soc_spis_sdi3),
		.zynq2soc_spim_sck_o(s_zynq2soc_spim_sck),
		.zynq2soc_spim_csn_o(s_zynq2soc_spim_csn),
		.zynq2soc_spim_sdo0_o(s_zynq2soc_spim_sdo0),
		.zynq2soc_spim_sdo1_o(s_zynq2soc_spim_sdo1),
		.zynq2soc_spim_sdo2_o(s_zynq2soc_spim_sdo2),
		.zynq2soc_spim_sdo3_o(s_zynq2soc_spim_sdo3),
		.zynq2soc_spim_sdi0_i(s_zynq2soc_spim_sdi0),
		.zynq2soc_spim_sdi1_i(s_zynq2soc_spim_sdi1),
		.zynq2soc_spim_sdi2_i(s_zynq2soc_spim_sdi2),
		.zynq2soc_spim_sdi3_i(s_zynq2soc_spim_sdi3),
		.zynq2soc_uart_tx_o(s_zynq2soc_uart_tx),
		.zynq2soc_uart_rx_i(s_zynq2soc_uart_rx),
		.zynq_clk_i(zynq_clk),
		.zynq_soc_clk_i(pulp_soc_clk),
		.zynq_cluster_clk_i(pulp_cluster_clk),
		.zynq_rst_n_i(zynq_rst_n),
		.pad_rf_txd_p(FMC_CHART_sata1_ap),
		.pad_rf_txd_n(FMC_CHART_sata1_an),
		.pad_rf_txclk_p(FMC_CHART_sata1_bp),
		.pad_rf_txclk_n(FMC_CHART_sata1_bn),
		.pad_rf_rxd_p(FMC_CHART_sata2_ap),
		.pad_rf_rxd_n(FMC_CHART_sata2_an),
		.pad_rf_rxclk_p(FMC_CHART_sata3_bp),
		.pad_rf_rxclk_n(FMC_CHART_sata3_bn),
		.pad_rf_miso(FMC_CHART_atreb215_spi2_miso),
		.pad_rf_mosi(FMC_CHART_atreb215_spi2_mosi),
		.pad_rf_cs(FMC_CHART_atreb215_cs1),
		.pad_rf_sck(FMC_CHART_atreb215_spi2_sclk),
		.pad_rf_pactrl0(FMC_CHART_pa0900_ant_sel),
		.pad_rf_pactrl1(FMC_CHART_pa0900_ctx),
		.pad_rf_pactrl2(FMC_CHART_pa0900_cps),
		.pad_rf_pactrl3(FMC_CHART_pa0900_csd),
		.pad_cam_pclk(FMC_cam_pclk),
		.pad_cam_valid(FMC_CHART_enable_sky),
		.pad_cam_data0(FMC_cam_d0),
		.pad_cam_data1(FMC_cam_d1),
		.pad_cam_data2(FMC_cam_d2),
		.pad_cam_data3(FMC_cam_d3),
		.pad_cam_data4(FMC_cam_d4),
		.pad_cam_data5(FMC_cam_d5),
		.pad_cam_data6(FMC_cam_d6),
		.pad_cam_data7(FMC_cam_d7),
		.pad_cam_hsync(FMC_cam_href),
		.pad_cam_vsync(FMC_cam_vsync),
		.pad_cam_miso(FMC_CHART_sky_spi_sdi),
		.pad_cam_mosi(FMC_CHART_sky_spi_sdo),
		.pad_cam_cs(FMC_CHART_sky_spi_ncs),
		.pad_cam_sck(FMC_CHART_sky_spi_sck),
		.pad_i2c0_sda(FMC_i2c_sda),
		.pad_i2c0_scl(FMC_i2c_scl),
		.pad_i2c1_sda(FMC_CHART_rf_switch_1),
		.pad_i2c1_scl(FMC_CHART_rf_switch_2),
		.pad_timer0_ch0(FMC_CHART_user_led1),
		.pad_timer0_ch1(FMC_CHART_user_led2),
		.pad_timer0_ch2(FMC_CHART_user_led3),
		.pad_timer0_ch3(FMC_CHART_vdd_3v3_en),
		.pad_i2s0_sck(FMC_i2s_sck0),
		.pad_i2s0_ws(FMC_adc_ncs),
		.pad_i2s0_sdi(FMC_i2s_sdi0),
		.pad_i2s1_sck(FMC_adc_sck),
		.pad_i2s1_ws(FMC_adc_sdi0),
		.pad_i2s1_sdi(FMC_i2s_sdi1),
		.pad_uart_rx(FMC_loop2_i),
		.pad_uart_tx(FMC_loop3_o),
		.pad_spim_sdio0(FMC_mspi_sdio0),
		.pad_spim_sdio1(FMC_mspi_sdio1),
		.pad_spim_sdio2(FMC_mspi_sdio2),
		.pad_spim_sdio3(FMC_mspi_sdio3),
		.pad_spim_csn0(FMC_mspi_ncs0),
		.pad_spim_csn1(FMC_mspi_ncs1),
		.pad_spim_sck(FMC_mspi_sck),
		.pad_jtag_tdi(PAD_jtag_tdi),
		.pad_jtag_tdo(PAD_jtag_tdo),
		.pad_jtag_tms(PAD_jtag_tms),
		.pad_jtag_trst(PAD_jtag_trst),
		.pad_jtag_tck(PAD_jtag_tck),
		.pad_reset_n(PAD_reset_n),
		.pad_xtal_in(pad_xtal_in),
		.pad_xtal_out(pad_xtal_out),
		.pad_bootmode(pad_bootmode)
	);
	zynq_wrapper zynq_wrapper_i(
		.DDR_addr(DDR_addr),
		.DDR_ba(DDR_ba),
		.DDR_cas_n(DDR_cas_n),
		.DDR_ck_n(DDR_ck_n),
		.DDR_ck_p(DDR_ck_p),
		.DDR_cke(DDR_cke),
		.DDR_cs_n(DDR_cs_n),
		.DDR_dm(DDR_dm),
		.DDR_dq(DDR_dq),
		.DDR_dqs_n(DDR_dqs_n),
		.DDR_dqs_p(DDR_dqs_p),
		.DDR_odt(DDR_odt),
		.DDR_ras_n(DDR_ras_n),
		.DDR_reset_n(DDR_reset_n),
		.DDR_we_n(DDR_we_n),
		.FIXED_IO_ddr_vrn(FIXED_IO_ddr_vrn),
		.FIXED_IO_ddr_vrp(FIXED_IO_ddr_vrp),
		.FIXED_IO_mio(FIXED_IO_mio),
		.FIXED_IO_ps_clk(FIXED_IO_ps_clk),
		.FIXED_IO_ps_porb(FIXED_IO_ps_porb),
		.FIXED_IO_ps_srstb(FIXED_IO_ps_srstb),
		.zynq_clk(zynq_clk),
		.zynq_rst_n(zynq_rst_n),
		.pulp_soc_clk(pulp_soc_clk),
		.pulp_cluster_clk(pulp_cluster_clk),
		.pulp2zynq_axi_araddr(pulp2zynq_axi_ar_addr),
		.pulp2zynq_axi_arburst(pulp2zynq_axi_ar_burst),
		.pulp2zynq_axi_arcache(pulp2zynq_axi_ar_cache),
		.pulp2zynq_axi_arlen(pulp2zynq_axi_ar_len),
		.pulp2zynq_axi_arlock(pulp2zynq_axi_ar_lock),
		.pulp2zynq_axi_arprot(pulp2zynq_axi_ar_prot),
		.pulp2zynq_axi_arqos(pulp2zynq_axi_ar_qos),
		.pulp2zynq_axi_arready(pulp2zynq_axi_ar_ready),
		.pulp2zynq_axi_arregion(pulp2zynq_axi_ar_region),
		.pulp2zynq_axi_arsize(pulp2zynq_axi_ar_size),
		.pulp2zynq_axi_arvalid(pulp2zynq_axi_ar_valid),
		.pulp2zynq_axi_awaddr(pulp2zynq_axi_aw_addr),
		.pulp2zynq_axi_awburst(pulp2zynq_axi_aw_burst),
		.pulp2zynq_axi_awcache(pulp2zynq_axi_aw_cache),
		.pulp2zynq_axi_awlen(pulp2zynq_axi_aw_len),
		.pulp2zynq_axi_awlock(pulp2zynq_axi_aw_lock),
		.pulp2zynq_axi_awprot(pulp2zynq_axi_aw_prot),
		.pulp2zynq_axi_awqos(pulp2zynq_axi_aw_qos),
		.pulp2zynq_axi_awready(pulp2zynq_axi_aw_ready),
		.pulp2zynq_axi_awregion(pulp2zynq_axi_aw_region),
		.pulp2zynq_axi_awsize(pulp2zynq_axi_aw_size),
		.pulp2zynq_axi_awvalid(pulp2zynq_axi_aw_valid),
		.pulp2zynq_axi_bready(pulp2zynq_axi_b_ready),
		.pulp2zynq_axi_bresp(pulp2zynq_axi_b_resp),
		.pulp2zynq_axi_bvalid(pulp2zynq_axi_b_valid),
		.pulp2zynq_axi_rdata(pulp2zynq_axi_r_data),
		.pulp2zynq_axi_rlast(pulp2zynq_axi_r_last),
		.pulp2zynq_axi_rready(pulp2zynq_axi_r_ready),
		.pulp2zynq_axi_rresp(pulp2zynq_axi_r_resp),
		.pulp2zynq_axi_rvalid(pulp2zynq_axi_r_valid),
		.pulp2zynq_axi_wdata(pulp2zynq_axi_w_data),
		.pulp2zynq_axi_wlast(pulp2zynq_axi_w_last),
		.pulp2zynq_axi_wready(pulp2zynq_axi_w_ready),
		.pulp2zynq_axi_wstrb(pulp2zynq_axi_w_strb),
		.pulp2zynq_axi_wvalid(pulp2zynq_axi_w_valid),
		.pulp2zynq_gpio(pulp2zynq_gpio),
		.zynq2pulp_apb_paddr(zynq2pulp_apb_paddr),
		.zynq2pulp_apb_penable(zynq2pulp_apb_penable),
		.zynq2pulp_apb_prdata(zynq2pulp_apb_prdata),
		.zynq2pulp_apb_pready(zynq2pulp_apb_pready),
		.zynq2pulp_apb_psel(zynq2pulp_apb_psel),
		.zynq2pulp_apb_pslverr(zynq2pulp_apb_pslverr),
		.zynq2pulp_apb_pwdata(zynq2pulp_apb_pwdata),
		.zynq2pulp_apb_pwrite(zynq2pulp_apb_pwrite),
		.zynq2pulp_gpio(zynq2pulp_gpio)
	);
	pulpemu_clk_gating pulpemu_clk_gating_i(
		.pulp_cluster_clk(pulp_cluster_clk),
		.pulp_soc_rst_n(pulp_soc_rst_n),
		.pulp_cluster_clk_enable(cg_clken),
		.pulp_cluster_clk_gated(pulp_cluster_clk_gated)
	);
	pulpemu_apb_demux pulpemu_apb_demux_i(
		.clk(zynq_clk),
		.rst_n(zynq_rst_n),
		.zynq2pulp_apb_paddr(zynq2pulp_apb_paddr),
		.zynq2pulp_apb_penable(zynq2pulp_apb_penable),
		.zynq2pulp_apb_prdata(zynq2pulp_apb_prdata),
		.zynq2pulp_apb_pready(zynq2pulp_apb_pready),
		.zynq2pulp_apb_psel(zynq2pulp_apb_psel),
		.zynq2pulp_apb_pslverr(zynq2pulp_apb_pslverr),
		.zynq2pulp_apb_pwdata(zynq2pulp_apb_pwdata),
		.zynq2pulp_apb_pwrite(zynq2pulp_apb_pwrite),
		.zynq2pulp_spi_slave_paddr(zynq2pulp_spi_slave_paddr),
		.zynq2pulp_spi_slave_penable(zynq2pulp_spi_slave_penable),
		.zynq2pulp_spi_slave_prdata(zynq2pulp_spi_slave_prdata),
		.zynq2pulp_spi_slave_pready(zynq2pulp_spi_slave_pready),
		.zynq2pulp_spi_slave_psel(zynq2pulp_spi_slave_psel),
		.zynq2pulp_spi_slave_pslverr(zynq2pulp_spi_slave_pslverr),
		.zynq2pulp_spi_slave_pwdata(zynq2pulp_spi_slave_pwdata),
		.zynq2pulp_spi_slave_pwrite(zynq2pulp_spi_slave_pwrite),
		.zynq2pulp_uart_paddr(zynq2pulp_uart_paddr),
		.zynq2pulp_uart_penable(zynq2pulp_uart_penable),
		.zynq2pulp_uart_prdata(zynq2pulp_uart_prdata),
		.zynq2pulp_uart_pready(zynq2pulp_uart_pready),
		.zynq2pulp_uart_psel(zynq2pulp_uart_psel),
		.zynq2pulp_uart_pslverr(zynq2pulp_uart_pslverr),
		.zynq2pulp_uart_pwdata(zynq2pulp_uart_pwdata),
		.zynq2pulp_uart_pwrite(zynq2pulp_uart_pwrite)
	);
	pulpemu_spi_slave pulpemu_spi_slave_i(
		.mode_fmc_zynqn_i(mode_fmc_zynqn),
		.clk(zynq_clk),
		.rst_n(zynq_rst_n),
		.zynq2pulp_apb_paddr(zynq2pulp_spi_slave_paddr),
		.zynq2pulp_apb_penable(zynq2pulp_spi_slave_penable),
		.zynq2pulp_apb_prdata(zynq2pulp_spi_slave_prdata),
		.zynq2pulp_apb_pready(zynq2pulp_spi_slave_pready),
		.zynq2pulp_apb_psel(zynq2pulp_spi_slave_psel),
		.zynq2pulp_apb_pslverr(zynq2pulp_spi_slave_pslverr),
		.zynq2pulp_apb_pwdata(zynq2pulp_spi_slave_pwdata),
		.zynq2pulp_apb_pwrite(zynq2pulp_spi_slave_pwrite),
		.pulp_spi_clk_o(s_zynq2soc_spis_sck),
		.pulp_spi_csn0_o(s_zynq2soc_spis_csn),
		.pulp_spi_sdo0_i(s_zynq2soc_spis_sdi0),
		.pulp_spi_sdo1_i(s_zynq2soc_spis_sdi1),
		.pulp_spi_sdo2_i(s_zynq2soc_spis_sdi2),
		.pulp_spi_sdo3_i(s_zynq2soc_spis_sdi3),
		.pulp_spi_sdi0_o(s_zynq2soc_spis_sdo0),
		.pulp_spi_sdi1_o(s_zynq2soc_spis_sdo1),
		.pulp_spi_sdi2_o(s_zynq2soc_spis_sdo2),
		.pulp_spi_sdi3_o(s_zynq2soc_spis_sdo3),
		.pads2pulp_spi_clk_i(pulp_spi_slave_clk),
		.pads2pulp_spi_csn_i(pulp_spi_slave_csn),
		.pads2pulp_spi_mode_o(pulp_spi_slave_mode),
		.pads2pulp_spi_sdo0_o(pulp_spi_slave_sdo0),
		.pads2pulp_spi_sdo1_o(pulp_spi_slave_sdo1),
		.pads2pulp_spi_sdo2_o(pulp_spi_slave_sdo2),
		.pads2pulp_spi_sdo3_o(pulp_spi_slave_sdo3),
		.pads2pulp_spi_sdi0_i(pulp_spi_slave_sdi0),
		.pads2pulp_spi_sdi1_i(pulp_spi_slave_sdi1),
		.pads2pulp_spi_sdi2_i(pulp_spi_slave_sdi2),
		.pads2pulp_spi_sdi3_i(pulp_spi_slave_sdi3)
	);
	pulpemu_spi_master pulpemu_spi_master_i(
		.mode_fmc_zynqn_i(mode_fmc_zynqn),
		.zynq_clk(zynq_clk),
		.zynq_rst_n(zynq_rst_n),
		.zynq_axi_aw_valid_o(pulp2zynq_axi_aw_valid),
		.zynq_axi_aw_addr_o(pulp2zynq_axi_aw_addr),
		.zynq_axi_aw_prot_o(pulp2zynq_axi_aw_prot),
		.zynq_axi_aw_region_o(pulp2zynq_axi_aw_region),
		.zynq_axi_aw_len_o(pulp2zynq_axi_aw_len),
		.zynq_axi_aw_size_o(pulp2zynq_axi_aw_size),
		.zynq_axi_aw_burst_o(pulp2zynq_axi_aw_burst),
		.zynq_axi_aw_lock_o(pulp2zynq_axi_aw_lock),
		.zynq_axi_aw_cache_o(pulp2zynq_axi_aw_cache),
		.zynq_axi_aw_qos_o(pulp2zynq_axi_aw_qos),
		.zynq_axi_aw_id_o(pulp2zynq_axi_aw_id),
		.zynq_axi_aw_user_o(pulp2zynq_axi_aw_user),
		.zynq_axi_aw_ready_i(pulp2zynq_axi_aw_ready),
		.zynq_axi_ar_valid_o(pulp2zynq_axi_ar_valid),
		.zynq_axi_ar_addr_o(pulp2zynq_axi_ar_addr),
		.zynq_axi_ar_prot_o(pulp2zynq_axi_ar_prot),
		.zynq_axi_ar_region_o(pulp2zynq_axi_ar_region),
		.zynq_axi_ar_len_o(pulp2zynq_axi_ar_len),
		.zynq_axi_ar_size_o(pulp2zynq_axi_ar_size),
		.zynq_axi_ar_burst_o(pulp2zynq_axi_ar_burst),
		.zynq_axi_ar_lock_o(pulp2zynq_axi_ar_lock),
		.zynq_axi_ar_cache_o(pulp2zynq_axi_ar_cache),
		.zynq_axi_ar_qos_o(pulp2zynq_axi_ar_qos),
		.zynq_axi_ar_id_o(pulp2zynq_axi_ar_id),
		.zynq_axi_ar_user_o(pulp2zynq_axi_ar_user),
		.zynq_axi_ar_ready_i(pulp2zynq_axi_ar_ready),
		.zynq_axi_w_valid_o(pulp2zynq_axi_w_valid),
		.zynq_axi_w_data_o(pulp2zynq_axi_w_data),
		.zynq_axi_w_strb_o(pulp2zynq_axi_w_strb),
		.zynq_axi_w_user_o(pulp2zynq_axi_w_user),
		.zynq_axi_w_last_o(pulp2zynq_axi_w_last),
		.zynq_axi_w_ready_i(pulp2zynq_axi_w_ready),
		.zynq_axi_r_valid_i(pulp2zynq_axi_r_valid),
		.zynq_axi_r_data_i(pulp2zynq_axi_r_data),
		.zynq_axi_r_resp_i(pulp2zynq_axi_r_resp),
		.zynq_axi_r_last_i(pulp2zynq_axi_r_last),
		.zynq_axi_r_id_i(pulp2zynq_axi_r_id),
		.zynq_axi_r_user_i(pulp2zynq_axi_r_user),
		.zynq_axi_r_ready_o(pulp2zynq_axi_r_ready),
		.zynq_axi_b_valid_i(pulp2zynq_axi_b_valid),
		.zynq_axi_b_resp_i(pulp2zynq_axi_b_resp),
		.zynq_axi_b_id_i(pulp2zynq_axi_b_id),
		.zynq_axi_b_user_i(pulp2zynq_axi_b_user),
		.zynq_axi_b_ready_o(pulp2zynq_axi_b_ready),
		.pulp_spi_clk_i(s_zynq2soc_spim_sck),
		.pulp_spi_csn_i(s_zynq2soc_spim_csn),
		.pulp_spi_sdo0_i(s_zynq2soc_spim_sdo0),
		.pulp_spi_sdo1_i(s_zynq2soc_spim_sdo1),
		.pulp_spi_sdo2_i(s_zynq2soc_spim_sdo2),
		.pulp_spi_sdo3_i(s_zynq2soc_spim_sdo3),
		.pulp_spi_sdi0_o(s_zynq2soc_spim_sdi0),
		.pulp_spi_sdi1_o(s_zynq2soc_spim_sdi1),
		.pulp_spi_sdi2_o(s_zynq2soc_spim_sdi2),
		.pulp_spi_sdi3_o(s_zynq2soc_spim_sdi3),
		.pads2pulp_spi_clk_o(pulp_spi_master0_clk),
		.pads2pulp_spi_csn_o(pulp_spi_master0_csn[0]),
		.pads2pulp_spi_mode_o(pulp_spi_master0_mode),
		.pads2pulp_spi_sdo0_o(pulp_spi_master0_sdo0),
		.pads2pulp_spi_sdo1_o(pulp_spi_master0_sdo1),
		.pads2pulp_spi_sdo2_o(pulp_spi_master0_sdo2),
		.pads2pulp_spi_sdo3_o(pulp_spi_master0_sdo3),
		.pads2pulp_spi_sdi0_i(pulp_spi_master0_sdi0),
		.pads2pulp_spi_sdi1_i(pulp_spi_master0_sdi1),
		.pads2pulp_spi_sdi2_i(pulp_spi_master0_sdi2),
		.pads2pulp_spi_sdi3_i(pulp_spi_master0_sdi3)
	);
	pulpemu_uart pulpemu_uart_i(
		.mode_fmc_zynqn_i(mode_fmc_zynqn),
		.clk(zynq_clk),
		.rst_n(zynq_rst_n),
		.apb_paddr(zynq2pulp_uart_paddr),
		.apb_penable(zynq2pulp_uart_penable),
		.apb_prdata(zynq2pulp_uart_prdata),
		.apb_pready(zynq2pulp_uart_pready),
		.apb_psel(zynq2pulp_uart_psel),
		.apb_pslverr(zynq2pulp_uart_pslverr),
		.apb_pwdata(zynq2pulp_uart_pwdata),
		.apb_pwrite(zynq2pulp_uart_pwrite),
		.pads2pulp_uart_rx_i(s_zynq2soc_uart_tx),
		.pads2pulp_uart_tx_o(s_zynq2soc_uart_rx)
	);
	pulpemu_zynq2pulp_gpio pulpemu_zynq2pulp_gpio_i(
		.clk(zynq_clk),
		.rst_n(zynq_rst_n),
		.pulp2zynq_gpio(pulp2zynq_gpio),
		.zynq2pulp_gpio(zynq2pulp_gpio),
		.stdout_flushed(stdout_flushed),
		.trace_flushed(trace_flushed),
		.cg_clken(cg_clken),
		.fetch_en(fetch_en),
		.mode_fmc_zynqn(mode_fmc_zynqn),
		.fault_en(fault_en),
		.stdout_wait(stdout_wait),
		.trace_wait(trace_wait),
		.eoc(pulp_eoc),
		.pulp_soc_rst_n(pulp_soc_rst_n),
		.zynq_safen_spis_o(s_zynq_safen_spis),
		.zynq_safen_spim_o(s_zynq_safen_spim),
		.zynq_safen_uart_o(s_zynq_safen_uart)
	);
	assign pad_xtal_in = 1'sb0;
	assign pad_bootmode = 1'sb0;
endmodule
