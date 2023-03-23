module soc_domain (
	ref_clk_i,
	clk_soc_ext_i,
	clk_per_ext_i,
	slow_clk_i,
	test_clk_i,
	rstn_glob_i,
	dft_test_mode_i,
	dft_cg_enable_i,
	mode_select_i,
	bootsel_i,
	jtag_tck_i,
	jtag_trst_ni,
	jtag_tms_i,
	jtag_tdi_i,
	jtag_tdo_o,
	gpio_in_i,
	gpio_out_o,
	gpio_dir_o,
	gpio_cfg_o,
	pad_mux_o,
	pad_cfg_o,
	uart_tx_o,
	uart_rx_i,
	cam_clk_i,
	cam_data_i,
	cam_hsync_i,
	cam_vsync_i,
	timer_ch0_o,
	timer_ch1_o,
	timer_ch2_o,
	timer_ch3_o,
	i2c0_scl_i,
	i2c0_scl_o,
	i2c0_scl_oe_o,
	i2c0_sda_i,
	i2c0_sda_o,
	i2c0_sda_oe_o,
	i2c1_scl_i,
	i2c1_scl_o,
	i2c1_scl_oe_o,
	i2c1_sda_i,
	i2c1_sda_o,
	i2c1_sda_oe_o,
	i2s_slave_sd0_i,
	i2s_slave_sd1_i,
	i2s_slave_ws_i,
	i2s_slave_ws_o,
	i2s_slave_ws_oe,
	i2s_slave_sck_i,
	i2s_slave_sck_o,
	i2s_slave_sck_oe,
	spi_master0_clk_o,
	spi_master0_csn0_o,
	spi_master0_csn1_o,
	spi_master0_oen0_o,
	spi_master0_oen1_o,
	spi_master0_oen2_o,
	spi_master0_oen3_o,
	spi_master0_sdo0_o,
	spi_master0_sdo1_o,
	spi_master0_sdo2_o,
	spi_master0_sdo3_o,
	spi_master0_sdi0_i,
	spi_master0_sdi1_i,
	spi_master0_sdi2_i,
	spi_master0_sdi3_i,
	sdio_clk_o,
	sdio_cmd_o,
	sdio_cmd_i,
	sdio_cmd_oen_o,
	sdio_data_o,
	sdio_data_i,
	sdio_data_oen_o,
	cluster_clk_o,
	cluster_rstn_o,
	cluster_busy_i,
	cluster_irq_o,
	cluster_rtc_o,
	cluster_fetch_enable_o,
	cluster_boot_addr_o,
	cluster_test_en_o,
	cluster_pow_o,
	cluster_byp_o,
	pg_logic_rstn_o,
	pg_udma_rstn_o,
	gnd_con,
	cluster_events_wt_o,
	cluster_events_rp_i,
	cluster_events_da_o,
	dma_pe_evt_ack_o,
	dma_pe_evt_valid_i,
	dma_pe_irq_ack_o,
	dma_pe_irq_valid_i,
	pf_evt_ack_o,
	pf_evt_valid_i,
	data_slave_aw_writetoken_i,
	data_slave_aw_addr_i,
	data_slave_aw_prot_i,
	data_slave_aw_region_i,
	data_slave_aw_len_i,
	data_slave_aw_size_i,
	data_slave_aw_burst_i,
	data_slave_aw_lock_i,
	data_slave_aw_cache_i,
	data_slave_aw_qos_i,
	data_slave_aw_id_i,
	data_slave_aw_user_i,
	data_slave_aw_readpointer_o,
	data_slave_ar_writetoken_i,
	data_slave_ar_addr_i,
	data_slave_ar_prot_i,
	data_slave_ar_region_i,
	data_slave_ar_len_i,
	data_slave_ar_size_i,
	data_slave_ar_burst_i,
	data_slave_ar_lock_i,
	data_slave_ar_cache_i,
	data_slave_ar_qos_i,
	data_slave_ar_id_i,
	data_slave_ar_user_i,
	data_slave_ar_readpointer_o,
	data_slave_w_writetoken_i,
	data_slave_w_data_i,
	data_slave_w_strb_i,
	data_slave_w_user_i,
	data_slave_w_last_i,
	data_slave_w_readpointer_o,
	data_slave_r_writetoken_o,
	data_slave_r_data_o,
	data_slave_r_resp_o,
	data_slave_r_last_o,
	data_slave_r_id_o,
	data_slave_r_user_o,
	data_slave_r_readpointer_i,
	data_slave_b_writetoken_o,
	data_slave_b_resp_o,
	data_slave_b_id_o,
	data_slave_b_user_o,
	data_slave_b_readpointer_i,
	data_master_aw_writetoken_o,
	data_master_aw_addr_o,
	data_master_aw_prot_o,
	data_master_aw_region_o,
	data_master_aw_len_o,
	data_master_aw_size_o,
	data_master_aw_burst_o,
	data_master_aw_lock_o,
	data_master_aw_cache_o,
	data_master_aw_qos_o,
	data_master_aw_id_o,
	data_master_aw_user_o,
	data_master_aw_readpointer_i,
	data_master_ar_writetoken_o,
	data_master_ar_addr_o,
	data_master_ar_prot_o,
	data_master_ar_region_o,
	data_master_ar_len_o,
	data_master_ar_size_o,
	data_master_ar_burst_o,
	data_master_ar_lock_o,
	data_master_ar_cache_o,
	data_master_ar_qos_o,
	data_master_ar_id_o,
	data_master_ar_user_o,
	data_master_ar_readpointer_i,
	data_master_w_writetoken_o,
	data_master_w_data_o,
	data_master_w_strb_o,
	data_master_w_user_o,
	data_master_w_last_o,
	data_master_w_readpointer_i,
	data_master_r_writetoken_i,
	data_master_r_data_i,
	data_master_r_resp_i,
	data_master_r_last_i,
	data_master_r_id_i,
	data_master_r_user_i,
	data_master_r_readpointer_o,
	data_master_b_writetoken_i,
	data_master_b_resp_i,
	data_master_b_id_i,
	data_master_b_user_i,
	data_master_b_readpointer_o,
	VDD_out_pg,
	VDDA_out_pg,
	VREF_out_pg,
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
	scan_en_in
);
	parameter CORE_TYPE = 0;
	parameter USE_FPU = 1;
	parameter USE_HWPE = 1;
	parameter AXI_ADDR_WIDTH = 32;
	parameter AXI_DATA_IN_WIDTH = 64;
	parameter AXI_DATA_OUT_WIDTH = 32;
	parameter AXI_ID_IN_WIDTH = 4;
	parameter AXI_ID_INT_WIDTH = 8;
	parameter AXI_ID_OUT_WIDTH = 6;
	parameter AXI_USER_WIDTH = 6;
	parameter AXI_STRB_IN_WIDTH = AXI_DATA_IN_WIDTH / 8;
	parameter AXI_STRB_OUT_WIDTH = AXI_DATA_OUT_WIDTH / 8;
	parameter BUFFER_WIDTH = 8;
	parameter EVNT_WIDTH = 8;
	input wire ref_clk_i;
	input wire clk_soc_ext_i;
	input wire clk_per_ext_i;
	input wire slow_clk_i;
	input wire test_clk_i;
	input wire rstn_glob_i;
	input wire dft_test_mode_i;
	input wire dft_cg_enable_i;
	input wire mode_select_i;
	input wire bootsel_i;
	input wire jtag_tck_i;
	input wire jtag_trst_ni;
	input wire jtag_tms_i;
	input wire jtag_tdi_i;
	output wire jtag_tdo_o;
	input wire [31:0] gpio_in_i;
	output wire [31:0] gpio_out_o;
	output wire [31:0] gpio_dir_o;
	output wire [191:0] gpio_cfg_o;
	output wire [127:0] pad_mux_o;
	output wire [383:0] pad_cfg_o;
	output wire uart_tx_o;
	input wire uart_rx_i;
	input wire cam_clk_i;
	input wire [7:0] cam_data_i;
	input wire cam_hsync_i;
	input wire cam_vsync_i;
	output wire [3:0] timer_ch0_o;
	output wire [3:0] timer_ch1_o;
	output wire [3:0] timer_ch2_o;
	output wire [3:0] timer_ch3_o;
	input wire i2c0_scl_i;
	output wire i2c0_scl_o;
	output wire i2c0_scl_oe_o;
	input wire i2c0_sda_i;
	output wire i2c0_sda_o;
	output wire i2c0_sda_oe_o;
	input wire i2c1_scl_i;
	output wire i2c1_scl_o;
	output wire i2c1_scl_oe_o;
	input wire i2c1_sda_i;
	output wire i2c1_sda_o;
	output wire i2c1_sda_oe_o;
	input wire i2s_slave_sd0_i;
	input wire i2s_slave_sd1_i;
	input wire i2s_slave_ws_i;
	output wire i2s_slave_ws_o;
	output wire i2s_slave_ws_oe;
	input wire i2s_slave_sck_i;
	output wire i2s_slave_sck_o;
	output wire i2s_slave_sck_oe;
	output wire spi_master0_clk_o;
	output wire spi_master0_csn0_o;
	output wire spi_master0_csn1_o;
	output wire spi_master0_oen0_o;
	output wire spi_master0_oen1_o;
	output wire spi_master0_oen2_o;
	output wire spi_master0_oen3_o;
	output wire spi_master0_sdo0_o;
	output wire spi_master0_sdo1_o;
	output wire spi_master0_sdo2_o;
	output wire spi_master0_sdo3_o;
	input wire spi_master0_sdi0_i;
	input wire spi_master0_sdi1_i;
	input wire spi_master0_sdi2_i;
	input wire spi_master0_sdi3_i;
	output wire sdio_clk_o;
	output wire sdio_cmd_o;
	input wire sdio_cmd_i;
	output wire sdio_cmd_oen_o;
	output wire [3:0] sdio_data_o;
	input wire [3:0] sdio_data_i;
	output wire [3:0] sdio_data_oen_o;
	output wire cluster_clk_o;
	output wire cluster_rstn_o;
	input wire cluster_busy_i;
	output wire cluster_irq_o;
	output wire cluster_rtc_o;
	output wire cluster_fetch_enable_o;
	output wire [63:0] cluster_boot_addr_o;
	output wire cluster_test_en_o;
	output wire cluster_pow_o;
	output wire cluster_byp_o;
	output wire pg_logic_rstn_o;
	output wire pg_udma_rstn_o;
	output wire gnd_con;
	output wire [BUFFER_WIDTH - 1:0] cluster_events_wt_o;
	input wire [BUFFER_WIDTH - 1:0] cluster_events_rp_i;
	output wire [EVNT_WIDTH - 1:0] cluster_events_da_o;
	output wire dma_pe_evt_ack_o;
	input wire dma_pe_evt_valid_i;
	output wire dma_pe_irq_ack_o;
	input wire dma_pe_irq_valid_i;
	output wire pf_evt_ack_o;
	input wire pf_evt_valid_i;
	input wire [7:0] data_slave_aw_writetoken_i;
	input wire [AXI_ADDR_WIDTH - 1:0] data_slave_aw_addr_i;
	input wire [2:0] data_slave_aw_prot_i;
	input wire [3:0] data_slave_aw_region_i;
	input wire [7:0] data_slave_aw_len_i;
	input wire [2:0] data_slave_aw_size_i;
	input wire [1:0] data_slave_aw_burst_i;
	input wire data_slave_aw_lock_i;
	input wire [3:0] data_slave_aw_cache_i;
	input wire [3:0] data_slave_aw_qos_i;
	input wire [AXI_ID_IN_WIDTH - 1:0] data_slave_aw_id_i;
	input wire [AXI_USER_WIDTH - 1:0] data_slave_aw_user_i;
	output wire [7:0] data_slave_aw_readpointer_o;
	input wire [7:0] data_slave_ar_writetoken_i;
	input wire [AXI_ADDR_WIDTH - 1:0] data_slave_ar_addr_i;
	input wire [2:0] data_slave_ar_prot_i;
	input wire [3:0] data_slave_ar_region_i;
	input wire [7:0] data_slave_ar_len_i;
	input wire [2:0] data_slave_ar_size_i;
	input wire [1:0] data_slave_ar_burst_i;
	input wire data_slave_ar_lock_i;
	input wire [3:0] data_slave_ar_cache_i;
	input wire [3:0] data_slave_ar_qos_i;
	input wire [AXI_ID_IN_WIDTH - 1:0] data_slave_ar_id_i;
	input wire [AXI_USER_WIDTH - 1:0] data_slave_ar_user_i;
	output wire [7:0] data_slave_ar_readpointer_o;
	input wire [7:0] data_slave_w_writetoken_i;
	input wire [AXI_DATA_IN_WIDTH - 1:0] data_slave_w_data_i;
	input wire [AXI_STRB_IN_WIDTH - 1:0] data_slave_w_strb_i;
	input wire [AXI_USER_WIDTH - 1:0] data_slave_w_user_i;
	input wire data_slave_w_last_i;
	output wire [7:0] data_slave_w_readpointer_o;
	output wire [7:0] data_slave_r_writetoken_o;
	output wire [AXI_DATA_IN_WIDTH - 1:0] data_slave_r_data_o;
	output wire [1:0] data_slave_r_resp_o;
	output wire data_slave_r_last_o;
	output wire [AXI_ID_IN_WIDTH - 1:0] data_slave_r_id_o;
	output wire [AXI_USER_WIDTH - 1:0] data_slave_r_user_o;
	input wire [7:0] data_slave_r_readpointer_i;
	output wire [7:0] data_slave_b_writetoken_o;
	output wire [1:0] data_slave_b_resp_o;
	output wire [AXI_ID_IN_WIDTH - 1:0] data_slave_b_id_o;
	output wire [AXI_USER_WIDTH - 1:0] data_slave_b_user_o;
	input wire [7:0] data_slave_b_readpointer_i;
	output wire [7:0] data_master_aw_writetoken_o;
	output wire [AXI_ADDR_WIDTH - 1:0] data_master_aw_addr_o;
	output wire [2:0] data_master_aw_prot_o;
	output wire [3:0] data_master_aw_region_o;
	output wire [7:0] data_master_aw_len_o;
	output wire [2:0] data_master_aw_size_o;
	output wire [1:0] data_master_aw_burst_o;
	output wire data_master_aw_lock_o;
	output wire [3:0] data_master_aw_cache_o;
	output wire [3:0] data_master_aw_qos_o;
	output wire [AXI_ID_OUT_WIDTH - 1:0] data_master_aw_id_o;
	output wire [AXI_USER_WIDTH - 1:0] data_master_aw_user_o;
	input wire [7:0] data_master_aw_readpointer_i;
	output wire [7:0] data_master_ar_writetoken_o;
	output wire [AXI_ADDR_WIDTH - 1:0] data_master_ar_addr_o;
	output wire [2:0] data_master_ar_prot_o;
	output wire [3:0] data_master_ar_region_o;
	output wire [7:0] data_master_ar_len_o;
	output wire [2:0] data_master_ar_size_o;
	output wire [1:0] data_master_ar_burst_o;
	output wire data_master_ar_lock_o;
	output wire [3:0] data_master_ar_cache_o;
	output wire [3:0] data_master_ar_qos_o;
	output wire [AXI_ID_OUT_WIDTH - 1:0] data_master_ar_id_o;
	output wire [AXI_USER_WIDTH - 1:0] data_master_ar_user_o;
	input wire [7:0] data_master_ar_readpointer_i;
	output wire [7:0] data_master_w_writetoken_o;
	output wire [AXI_DATA_OUT_WIDTH - 1:0] data_master_w_data_o;
	output wire [AXI_STRB_OUT_WIDTH - 1:0] data_master_w_strb_o;
	output wire [AXI_USER_WIDTH - 1:0] data_master_w_user_o;
	output wire data_master_w_last_o;
	input wire [7:0] data_master_w_readpointer_i;
	input wire [7:0] data_master_r_writetoken_i;
	input wire [AXI_DATA_OUT_WIDTH - 1:0] data_master_r_data_i;
	input wire [1:0] data_master_r_resp_i;
	input wire data_master_r_last_i;
	input wire [AXI_ID_OUT_WIDTH - 1:0] data_master_r_id_i;
	input wire [AXI_USER_WIDTH - 1:0] data_master_r_user_i;
	output wire [7:0] data_master_r_readpointer_o;
	input wire [7:0] data_master_b_writetoken_i;
	input wire [1:0] data_master_b_resp_i;
	input wire [AXI_ID_OUT_WIDTH - 1:0] data_master_b_id_i;
	input wire [AXI_USER_WIDTH - 1:0] data_master_b_user_i;
	output wire [7:0] data_master_b_readpointer_o;
	output wire VDD_out_pg;
	output wire VDDA_out_pg;
	output wire VREF_out_pg;
	input wire hold_wu;
	input wire step_wu;
	input wire wu_bypass_en;
	input wire wu_bypass_data_in;
	input wire wu_bypass_shift;
	input wire wu_bypass_mux;
	output wire wu_bypass_data_out;
	input wire ext_pg_logic;
	input wire ext_pg_l2;
	input wire ext_pg_l2_udma;
	input wire ext_pg_l1;
	input wire ext_pg_udma;
	input wire ext_pg_mram;
	input wire scan_en_in;
	pulp_soc #(
		.CORE_TYPE(CORE_TYPE),
		.USE_FPU(USE_FPU),
		.USE_HWPE(USE_HWPE),
		.AXI_ADDR_WIDTH(AXI_ADDR_WIDTH),
		.AXI_DATA_IN_WIDTH(AXI_DATA_IN_WIDTH),
		.AXI_DATA_OUT_WIDTH(AXI_DATA_OUT_WIDTH),
		.AXI_ID_IN_WIDTH(AXI_ID_IN_WIDTH),
		.AXI_ID_OUT_WIDTH(AXI_ID_OUT_WIDTH),
		.AXI_USER_WIDTH(AXI_USER_WIDTH),
		.EVNT_WIDTH(EVNT_WIDTH),
		.BUFFER_WIDTH(BUFFER_WIDTH)
	) pulp_soc_i(
		.boot_l2_i(1'b0),
		.*
	);
endmodule
