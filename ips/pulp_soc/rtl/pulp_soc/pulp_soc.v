module pulp_soc (
	ref_clk_i,
	clk_soc_ext_i,
	clk_per_ext_i,
	slow_clk_i,
	test_clk_i,
	rstn_glob_i,
	dft_test_mode_i,
	dft_cg_enable_i,
	mode_select_i,
	boot_l2_i,
	bootsel_i,
	cluster_rtc_o,
	cluster_fetch_enable_o,
	cluster_boot_addr_o,
	cluster_test_en_o,
	cluster_pow_o,
	cluster_byp_o,
	cluster_rstn_o,
	cluster_irq_o,
	pg_logic_rstn_o,
	pg_udma_rstn_o,
	gnd_con,
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
	cluster_events_wt_o,
	cluster_events_rp_i,
	cluster_events_da_o,
	cluster_clk_o,
	cluster_busy_i,
	dma_pe_evt_ack_o,
	dma_pe_evt_valid_i,
	dma_pe_irq_ack_o,
	dma_pe_irq_valid_i,
	pf_evt_ack_o,
	pf_evt_valid_i,
	pad_mux_o,
	pad_cfg_o,
	gpio_in_i,
	gpio_out_o,
	gpio_dir_o,
	gpio_cfg_o,
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
	jtag_tck_i,
	jtag_trst_ni,
	jtag_tms_i,
	jtag_tdi_i,
	jtag_tdo_o,
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
	parameter USE_CLUSTER_EVENT = 1;
	parameter AXI_ADDR_WIDTH = 32;
	parameter AXI_DATA_IN_WIDTH = 64;
	parameter AXI_DATA_OUT_WIDTH = 32;
	parameter AXI_ID_IN_WIDTH = 6;
	parameter AXI_ID_OUT_WIDTH = 6;
	parameter AXI_USER_WIDTH = 6;
	parameter AXI_STRB_WIDTH_IN = AXI_DATA_IN_WIDTH / 8;
	parameter AXI_STRB_WIDTH_OUT = AXI_DATA_OUT_WIDTH / 8;
	parameter BUFFER_WIDTH = 8;
	parameter EVNT_WIDTH = 8;
	parameter NB_HWPE_PORTS = 4;
	parameter NGPIO = 43;
	parameter NPAD = 64;
	parameter NBIT_PADCFG = 4;
	parameter NBIT_PADMUX = 2;
	input wire ref_clk_i;
	input wire clk_soc_ext_i;
	input wire clk_per_ext_i;
	input wire slow_clk_i;
	input wire test_clk_i;
	input wire rstn_glob_i;
	input wire dft_test_mode_i;
	input wire dft_cg_enable_i;
	input wire mode_select_i;
	input wire boot_l2_i;
	input wire bootsel_i;
	output wire cluster_rtc_o;
	output wire cluster_fetch_enable_o;
	output wire [63:0] cluster_boot_addr_o;
	output wire cluster_test_en_o;
	output wire cluster_pow_o;
	output wire cluster_byp_o;
	output wire cluster_rstn_o;
	output wire cluster_irq_o;
	output wire pg_logic_rstn_o;
	output wire pg_udma_rstn_o;
	output wire gnd_con;
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
	input wire [AXI_STRB_WIDTH_IN - 1:0] data_slave_w_strb_i;
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
	output wire [AXI_STRB_WIDTH_OUT - 1:0] data_master_w_strb_o;
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
	output wire [BUFFER_WIDTH - 1:0] cluster_events_wt_o;
	input wire [BUFFER_WIDTH - 1:0] cluster_events_rp_i;
	output wire [EVNT_WIDTH - 1:0] cluster_events_da_o;
	output wire cluster_clk_o;
	input wire cluster_busy_i;
	output wire dma_pe_evt_ack_o;
	input wire dma_pe_evt_valid_i;
	output wire dma_pe_irq_ack_o;
	input wire dma_pe_irq_valid_i;
	output wire pf_evt_ack_o;
	input wire pf_evt_valid_i;
	output wire [127:0] pad_mux_o;
	output wire [383:0] pad_cfg_o;
	input wire [31:0] gpio_in_i;
	output wire [31:0] gpio_out_o;
	output wire [31:0] gpio_dir_o;
	output wire [191:0] gpio_cfg_o;
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
	input wire jtag_tck_i;
	input wire jtag_trst_ni;
	input wire jtag_tms_i;
	input wire jtag_tdi_i;
	output wire jtag_tdo_o;
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
	localparam FLL_ADDR_WIDTH = 32;
	localparam FLL_DATA_WIDTH = 32;
	localparam NB_L2_BANKS = 4;
	localparam L2_BANK_SIZE = 29184;
	localparam L2_MEM_ADDR_WIDTH = 15;
	localparam NB_L2_BANKS_PRI = 2;
	localparam L2_BANK_SIZE_PRI = 8192;
	localparam L2_MEM_ADDR_WIDTH_PRI = 13;
	localparam ROM_ADDR_WIDTH = 13;
	localparam FC_Core_CLUSTER_ID = 6'd31;
	localparam FC_Core_CORE_ID = 4'd0;
	localparam FC_Core_MHARTID = {FC_Core_CLUSTER_ID, 1'b0, FC_Core_CORE_ID};
	localparam NrHarts = 1024;
	localparam [1023:0] SELECTABLE_HARTS = 1 << FC_Core_MHARTID;
	localparam [11:0] dm_DataAddr = 12'h380;
	localparam [3:0] dm_DataCount = 4'h2;
	localparam [31:0] RI5CY_HARTINFO = {16'h0021, dm_DataCount, dm_DataAddr};
	reg [32767:0] hartinfo;
	wire [1:0] s_fc_hwpe_events;
	wire [31:0] s_fc_events;
	wire [7:0] s_soc_events_ack;
	wire [7:0] s_soc_events_val;
	wire s_timer_lo_event;
	wire s_timer_hi_event;
	wire [EVNT_WIDTH - 1:0] s_cl_event_data;
	wire s_cl_event_valid;
	wire s_cl_event_ready;
	wire [EVNT_WIDTH - 1:0] s_fc_event_data;
	wire s_fc_event_valid;
	wire s_fc_event_ready;
	wire [255:0] s_apb_mpu_rules;
	wire s_supervisor_mode;
	wire [31:0] s_fc_bootaddr;
	wire [191:0] s_gpio_cfg;
	wire [127:0] s_pad_mux;
	wire [383:0] s_pad_cfg;
	wire s_periph_clk;
	wire s_periph_rstn;
	wire s_soc_clk;
	wire s_soc_rstn;
	wire s_cluster_clk;
	wire s_cluster_rstn;
	wire s_cluster_rstn_soc_ctrl;
	wire s_sel_fll_clk;
	wire s_dma_pe_evt;
	wire s_dma_pe_irq;
	wire s_pf_evt;
	wire s_fc_fetchen;
	wire [1023:0] dm_debug_req;
	wire jtag_req_valid;
	wire debug_req_ready;
	wire jtag_resp_ready;
	wire jtag_resp_valid;
	wire [40:0] jtag_dmi_req;
	wire [33:0] debug_resp;
	wire slave_grant;
	reg slave_valid;
	wire slave_req;
	wire slave_we;
	wire [31:0] slave_addr;
	wire [31:0] slave_wdata;
	wire [31:0] slave_rdata;
	wire [3:0] slave_be;
	wire lint_riscv_jtag_bus_master_we;
	wire int_td;
	wire master_req;
	wire [31:0] master_add;
	wire master_we;
	wire [31:0] master_wdata;
	wire [3:0] master_be;
	wire master_gnt;
	wire master_r_valid;
	wire [31:0] master_r_rdata;
	wire [7:0] soc_jtag_reg_tap;
	wire [7:0] soc_jtag_reg_soc;
	wire spi_master0_csn3;
	wire spi_master0_csn2;
	wire s_pg_logic_rstn;
	wire s_pg_udma_rstn;
	wire s_pg_ram_rom_rstn_o;
	wire s_pg_logic_rstn_sync;
	wire s_pg_udma_rstn_sync;
	wire s_clk_en_system;
	wire clk_soc_ext_gated;
	wire clk_per_ext_gated;
	wire ref_clk_gated;
	wire jtag_tck_gated;
	genvar i;
	genvar j;
	APB_BUS s_apb_eu_bus();
	APB_BUS s_apb_hwpe_bus();
	APB_BUS s_apb_debug_bus();
	AXI_BUS_ASYNC #(
		.AXI_ADDR_WIDTH(AXI_ADDR_WIDTH),
		.AXI_DATA_WIDTH(AXI_DATA_OUT_WIDTH),
		.AXI_ID_WIDTH(AXI_ID_OUT_WIDTH),
		.AXI_USER_WIDTH(AXI_USER_WIDTH)
	) s_data_master();
	AXI_BUS_ASYNC #(
		.AXI_ADDR_WIDTH(AXI_ADDR_WIDTH),
		.AXI_DATA_WIDTH(AXI_DATA_IN_WIDTH),
		.AXI_ID_WIDTH(AXI_ID_OUT_WIDTH),
		.AXI_USER_WIDTH(AXI_USER_WIDTH)
	) s_data_slave();
	AXI_BUS #(
		.AXI_ADDR_WIDTH(AXI_ADDR_WIDTH),
		.AXI_DATA_WIDTH(AXI_DATA_IN_WIDTH),
		.AXI_ID_WIDTH(AXI_ID_OUT_WIDTH),
		.AXI_USER_WIDTH(AXI_USER_WIDTH)
	) s_data_in_bus();
	AXI_BUS #(
		.AXI_ADDR_WIDTH(AXI_ADDR_WIDTH),
		.AXI_DATA_WIDTH(AXI_DATA_OUT_WIDTH),
		.AXI_ID_WIDTH(AXI_ID_OUT_WIDTH),
		.AXI_USER_WIDTH(AXI_USER_WIDTH)
	) s_data_out_bus();
	FLL_BUS #(
		.FLL_ADDR_WIDTH(FLL_ADDR_WIDTH),
		.FLL_DATA_WIDTH(FLL_DATA_WIDTH)
	) s_soc_fll_master();
	FLL_BUS #(
		.FLL_ADDR_WIDTH(FLL_ADDR_WIDTH),
		.FLL_DATA_WIDTH(FLL_DATA_WIDTH)
	) s_per_fll_master();
	FLL_BUS #(
		.FLL_ADDR_WIDTH(FLL_ADDR_WIDTH),
		.FLL_DATA_WIDTH(FLL_DATA_WIDTH)
	) s_cluster_fll_master();
	APB_BUS s_apb_periph_bus();
	UNICAD_MEM_BUS_32 s_mem_rom_bus();
	UNICAD_MEM_BUS_32 s_mem_l2_bus[3:0]();
	UNICAD_MEM_BUS_32 s_mem_l2_pri_bus[1:0]();
	XBAR_TCDM_BUS s_lint_debug_bus();
	XBAR_TCDM_BUS s_lint_pulp_jtag_bus();
	XBAR_TCDM_BUS s_lint_riscv_jtag_bus();
	XBAR_TCDM_BUS s_lint_udma_tx_bus();
	XBAR_TCDM_BUS s_lint_udma_rx_bus();
	XBAR_TCDM_BUS s_lint_fc_data_bus();
	XBAR_TCDM_BUS s_lint_fc_instr_bus();
	XBAR_TCDM_BUS s_lint_hwpe_bus[NB_HWPE_PORTS - 1:0]();
	wire s_cluster_isolate_dc;
	wire s_rstn_cluster_sync_soc;
	assign pg_logic_rstn_o = s_pg_logic_rstn;
	assign pg_udma_rstn_o = s_pg_udma_rstn;
	assign s_pg_logic_rstn_sync = s_soc_rstn && s_pg_logic_rstn;
	assign s_pg_udma_rstn_sync = s_soc_rstn && s_pg_udma_rstn;
	assign cluster_clk_o = s_cluster_clk;
	assign cluster_rstn_o = s_cluster_rstn && s_cluster_rstn_soc_ctrl;
	assign s_rstn_cluster_sync_soc = s_cluster_rstn && s_cluster_rstn_soc_ctrl;
	assign cluster_rtc_o = ref_clk_gated;
	assign cluster_test_en_o = dft_test_mode_i;
	assign s_cluster_isolate_dc = 1'b0;
	axi_slice_dc_master_wrap #(
		.AXI_ADDR_WIDTH(AXI_ADDR_WIDTH),
		.AXI_DATA_WIDTH(AXI_DATA_IN_WIDTH),
		.AXI_ID_WIDTH(AXI_ID_IN_WIDTH),
		.AXI_USER_WIDTH(AXI_USER_WIDTH),
		.BUFFER_WIDTH(BUFFER_WIDTH)
	) dc_fifo_dataout_bus_i(
		.clk_i(s_soc_clk),
		.rst_ni(s_cluster_rstn && s_pg_logic_rstn),
		.isolate_i(s_cluster_isolate_dc),
		.test_cgbypass_i(1'b0),
		.clock_down_i(1'b0),
		.incoming_req_o(),
		.axi_master(s_data_in_bus),
		.axi_slave_async(s_data_slave)
	);
	axi_slice_dc_slave_wrap #(
		.AXI_ADDR_WIDTH(AXI_ADDR_WIDTH),
		.AXI_DATA_WIDTH(AXI_DATA_OUT_WIDTH),
		.AXI_ID_WIDTH(AXI_ID_OUT_WIDTH),
		.AXI_USER_WIDTH(AXI_USER_WIDTH),
		.BUFFER_WIDTH(BUFFER_WIDTH)
	) dc_fifo_datain_bus_i(
		.clk_i(s_soc_clk),
		.rst_ni(s_rstn_cluster_sync_soc && s_pg_logic_rstn),
		.isolate_i(s_cluster_isolate_dc),
		.axi_slave(s_data_out_bus),
		.axi_master_async(s_data_master)
	);
	l2_ram_multi_bank #(
		.MEM_ADDR_WIDTH(L2_MEM_ADDR_WIDTH),
		.NB_BANKS(NB_L2_BANKS),
		.BANK_SIZE(L2_BANK_SIZE),
		.MEM_ADDR_WIDTH_PRI(L2_MEM_ADDR_WIDTH_PRI),
		.NB_BANKS_PRI(NB_L2_BANKS_PRI)
	) l2_ram_i(
		.clk_i(s_soc_clk),
		.rst_ni(s_pg_udma_rstn_sync),
		.init_ni(1'b1),
		.test_mode_i(dft_test_mode_i),
		.mem_slave(s_mem_l2_bus),
		.mem_pri_slave(s_mem_l2_pri_bus)
	);
	boot_rom #(.ROM_ADDR_WIDTH(ROM_ADDR_WIDTH)) boot_rom_i(
		.clk_i(s_soc_clk),
		.rst_ni(s_pg_logic_rstn_sync),
		.scan_en_in(dft_test_mode_i),
		.init_ni(1'b1),
		.mem_slave(s_mem_rom_bus),
		.test_mode_i(dft_test_mode_i)
	);
	soc_peripherals #(
		.CORE_TYPE(CORE_TYPE),
		.MEM_ADDR_WIDTH(17),
		.APB_ADDR_WIDTH(32),
		.APB_DATA_WIDTH(32),
		.NB_CORES(8),
		.NB_CLUSTERS(1),
		.EVNT_WIDTH(EVNT_WIDTH),
		.NGPIO(NGPIO),
		.NPAD(NPAD),
		.NBIT_PADCFG(NBIT_PADCFG),
		.NBIT_PADMUX(NBIT_PADMUX)
	) soc_peripherals_i(
		.clk_i(s_soc_clk),
		.periph_clk_i(s_periph_clk),
		.clk_soc_ext_i(clk_soc_ext_gated),
		.rst_ni(rstn_glob_i),
		.sel_fll_clk_i(s_sel_fll_clk),
		.ref_clk_i(ref_clk_i),
		.slow_clk_i(slow_clk_i),
		.dft_test_mode_i(dft_test_mode_i),
		.dft_cg_enable_i(1'b0),
		.boot_l2_i(boot_l2_i),
		.bootsel_i(bootsel_i),
		.fc_bootaddr_o(s_fc_bootaddr),
		.fc_fetchen_o(s_fc_fetchen),
		.apb_slave(s_apb_periph_bus),
		.apb_eu_master(s_apb_eu_bus),
		.apb_debug_master(s_apb_debug_bus),
		.apb_hwpe_master(s_apb_hwpe_bus),
		.l2_rx_master(s_lint_udma_rx_bus),
		.l2_tx_master(s_lint_udma_tx_bus),
		.soc_jtag_reg_i(soc_jtag_reg_tap),
		.soc_jtag_reg_o(soc_jtag_reg_soc),
		.fc_hwpe_events_i(s_fc_hwpe_events),
		.fc_events_o(s_fc_events),
		.dma_pe_evt_i(s_dma_pe_evt),
		.dma_pe_irq_i(s_dma_pe_irq),
		.pf_evt_i(s_pf_evt),
		.soc_fll_master(s_soc_fll_master),
		.per_fll_master(s_per_fll_master),
		.cluster_fll_master(s_cluster_fll_master),
		.gpio_in(gpio_in_i),
		.gpio_out(gpio_out_o),
		.gpio_dir(gpio_dir_o),
		.gpio_padcfg(s_gpio_cfg),
		.pad_mux_o(s_pad_mux),
		.pad_cfg_o(s_pad_cfg),
		.cam_clk_i(cam_clk_i),
		.cam_data_i(cam_data_i),
		.cam_hsync_i(cam_hsync_i),
		.cam_vsync_i(cam_vsync_i),
		.uart_tx(uart_tx_o),
		.uart_rx(uart_rx_i),
		.i2c_scl_i({i2c1_scl_i, i2c0_scl_i}),
		.i2c_scl_o({i2c1_scl_o, i2c0_scl_o}),
		.i2c_scl_oe({i2c1_scl_oe_o, i2c0_scl_oe_o}),
		.i2c_sda_i({i2c1_sda_i, i2c0_sda_i}),
		.i2c_sda_o({i2c1_sda_o, i2c0_sda_o}),
		.i2c_sda_oe({i2c1_sda_oe_o, i2c0_sda_oe_o}),
		.i2s_slave_sd0_i(i2s_slave_sd0_i),
		.i2s_slave_sd1_i(i2s_slave_sd1_i),
		.i2s_slave_ws_i(i2s_slave_ws_i),
		.i2s_slave_ws_o(i2s_slave_ws_o),
		.i2s_slave_ws_oe(i2s_slave_ws_oe),
		.i2s_slave_sck_i(i2s_slave_sck_i),
		.i2s_slave_sck_o(i2s_slave_sck_o),
		.i2s_slave_sck_oe(i2s_slave_sck_oe),
		.spi_clk(spi_master0_clk_o),
		.spi_csn({spi_master0_csn3, spi_master0_csn2, spi_master0_csn1_o, spi_master0_csn0_o}),
		.spi_oen({spi_master0_oen3_o, spi_master0_oen2_o, spi_master0_oen1_o, spi_master0_oen0_o}),
		.spi_sdo({spi_master0_sdo3_o, spi_master0_sdo2_o, spi_master0_sdo1_o, spi_master0_sdo0_o}),
		.spi_sdi({spi_master0_sdi3_i, spi_master0_sdi2_i, spi_master0_sdi1_i, spi_master0_sdi0_i}),
		.sdclk_o(sdio_clk_o),
		.sdcmd_o(sdio_cmd_o),
		.sdcmd_i(sdio_cmd_i),
		.sdcmd_oen_o(sdio_cmd_oen_o),
		.sddata_o(sdio_data_o),
		.sddata_i(sdio_data_i),
		.sddata_oen_o(sdio_data_oen_o),
		.timer_ch0_o(timer_ch0_o),
		.timer_ch1_o(timer_ch1_o),
		.timer_ch2_o(timer_ch2_o),
		.timer_ch3_o(timer_ch3_o),
		.cl_event_data_o(s_cl_event_data),
		.cl_event_valid_o(s_cl_event_valid),
		.cl_event_ready_i(s_cl_event_ready),
		.fc_event_data_o(s_fc_event_data),
		.fc_event_valid_o(s_fc_event_valid),
		.fc_event_ready_i(s_fc_event_ready),
		.cluster_pow_o(cluster_pow_o),
		.cluster_byp_o(cluster_byp_o),
		.cluster_boot_addr_o(cluster_boot_addr_o),
		.cluster_fetch_enable_o(cluster_fetch_enable_o),
		.cluster_rstn_o(s_cluster_rstn_soc_ctrl),
		.cluster_irq_o(cluster_irq_o),
		.clk_en_system(s_clk_en_system),
		.pg_logic_rstn_o(s_pg_logic_rstn),
		.pg_udma_rstn_o(s_pg_udma_rstn),
		.pg_ram_rom_rstn_o(s_pg_ram_rom_rstn_o),
		.VDD_out_pg(VDD_out_pg),
		.VDDA_out_pg(VDDA_out_pg),
		.VREF_out_pg(VREF_out_pg),
		.hold_wu(hold_wu),
		.step_wu(step_wu),
		.wu_bypass_en(wu_bypass_en),
		.wu_bypass_data_in(wu_bypass_data_in),
		.wu_bypass_shift(wu_bypass_shift),
		.wu_bypass_mux(wu_bypass_mux),
		.wu_bypass_data_out(wu_bypass_data_out),
		.ext_pg_logic(ext_pg_logic),
		.ext_pg_l2(ext_pg_l2),
		.ext_pg_l2_udma(ext_pg_l2_udma),
		.ext_pg_l1(ext_pg_l1),
		.ext_pg_udma(ext_pg_udma),
		.ext_pg_mram(ext_pg_mram)
	);
	dc_token_ring_fifo_din #(
		.DATA_WIDTH(EVNT_WIDTH),
		.BUFFER_DEPTH(BUFFER_WIDTH)
	) u_event_dc(
		.clk(s_soc_clk),
		.rstn(s_rstn_cluster_sync_soc && s_pg_logic_rstn),
		.data(s_cl_event_data),
		.valid(s_cl_event_valid),
		.ready(s_cl_event_ready),
		.write_token(cluster_events_wt_o),
		.read_pointer(cluster_events_rp_i),
		.data_async(cluster_events_da_o)
	);
	edge_propagator_rx ep_dma_pe_evt_i(
		.clk_i(s_soc_clk),
		.rstn_i(s_rstn_cluster_sync_soc && s_pg_logic_rstn),
		.valid_o(s_dma_pe_evt),
		.ack_o(dma_pe_evt_ack_o),
		.valid_i(dma_pe_evt_valid_i)
	);
	edge_propagator_rx ep_dma_pe_irq_i(
		.clk_i(s_soc_clk),
		.rstn_i(s_rstn_cluster_sync_soc && s_pg_logic_rstn),
		.valid_o(s_dma_pe_irq),
		.ack_o(dma_pe_irq_ack_o),
		.valid_i(dma_pe_irq_valid_i)
	);
	edge_propagator_rx ep_pf_evt_i(
		.clk_i(s_soc_clk),
		.rstn_i(s_rstn_cluster_sync_soc && s_pg_logic_rstn),
		.valid_o(s_pf_evt),
		.ack_o(pf_evt_ack_o),
		.valid_i(pf_evt_valid_i)
	);
	fc_subsystem #(
		.CORE_TYPE(CORE_TYPE),
		.USE_FPU(USE_FPU),
		.CORE_ID(FC_Core_CORE_ID),
		.CLUSTER_ID(FC_Core_CLUSTER_ID),
		.USE_HWPE(USE_HWPE)
	) fc_subsystem_i(
		.clk_i(s_soc_clk),
		.rst_ni(s_pg_logic_rstn_sync),
		.test_en_i(dft_test_mode_i),
		.boot_addr_i(s_fc_bootaddr),
		.fetch_en_i(s_fc_fetchen),
		.l2_data_master(s_lint_fc_data_bus),
		.l2_instr_master(s_lint_fc_instr_bus),
		.l2_hwpe_master(s_lint_hwpe_bus),
		.apb_slave_eu(s_apb_eu_bus),
		.apb_slave_hwpe(s_apb_hwpe_bus),
		.debug_req_i(dm_debug_req[FC_Core_MHARTID]),
		.event_fifo_valid_i(s_fc_event_valid),
		.event_fifo_fulln_o(s_fc_event_ready),
		.event_fifo_data_i(s_fc_event_data),
		.events_i(s_fc_events),
		.hwpe_events_o(s_fc_hwpe_events),
		.supervisor_mode_o(s_supervisor_mode),
		.scan_en_in(scan_en_in)
	);
	soc_clk_rst_gen i_clk_rst_gen(
		.ref_clk_i(ref_clk_gated),
		.clk_soc_ext_i(clk_soc_ext_gated),
		.clk_per_ext_i(clk_per_ext_gated),
		.test_clk_i(test_clk_i),
		.sel_fll_clk_i(s_sel_fll_clk),
		.rstn_glob_i(s_pg_udma_rstn),
		.rstn_soc_sync_o(s_soc_rstn),
		.rstn_cluster_sync_o(s_cluster_rstn),
		.clk_cluster_o(s_cluster_clk),
		.test_mode_i(dft_test_mode_i),
		.shift_enable_i(1'b0),
		.soc_fll_slave_req_i(s_soc_fll_master.req),
		.soc_fll_slave_wrn_i(s_soc_fll_master.wrn),
		.soc_fll_slave_add_i(s_soc_fll_master.add[1:0]),
		.soc_fll_slave_data_i(s_soc_fll_master.data),
		.soc_fll_slave_ack_o(s_soc_fll_master.ack),
		.soc_fll_slave_r_data_o(s_soc_fll_master.r_data),
		.soc_fll_slave_lock_o(s_soc_fll_master.lock),
		.per_fll_slave_req_i(s_per_fll_master.req),
		.per_fll_slave_wrn_i(s_per_fll_master.wrn),
		.per_fll_slave_add_i(s_per_fll_master.add[1:0]),
		.per_fll_slave_data_i(s_per_fll_master.data),
		.per_fll_slave_ack_o(s_per_fll_master.ack),
		.per_fll_slave_r_data_o(s_per_fll_master.r_data),
		.per_fll_slave_lock_o(s_per_fll_master.lock),
		.cluster_fll_slave_req_i(s_cluster_fll_master.req),
		.cluster_fll_slave_wrn_i(s_cluster_fll_master.wrn),
		.cluster_fll_slave_add_i(s_cluster_fll_master.add[1:0]),
		.cluster_fll_slave_data_i(s_cluster_fll_master.data),
		.cluster_fll_slave_ack_o(s_cluster_fll_master.ack),
		.cluster_fll_slave_r_data_o(s_cluster_fll_master.r_data),
		.cluster_fll_slave_lock_o(s_cluster_fll_master.lock),
		.clk_soc_o(s_soc_clk),
		.clk_per_o(s_periph_clk)
	);
	soc_interconnect_wrap #(
		.N_L2_BANKS(NB_L2_BANKS),
		.ADDR_MEM_WIDTH(L2_MEM_ADDR_WIDTH),
		.N_HWPE_PORTS(NB_HWPE_PORTS),
		.N_L2_BANKS_PRI(NB_L2_BANKS_PRI),
		.ADDR_MEM_PRI_WIDTH(L2_MEM_ADDR_WIDTH_PRI),
		.ROM_ADDR_WIDTH(ROM_ADDR_WIDTH),
		.AXI_32_ID_WIDTH(AXI_ID_OUT_WIDTH),
		.AXI_32_USER_WIDTH(AXI_USER_WIDTH),
		.AXI_ADDR_WIDTH(AXI_ADDR_WIDTH),
		.AXI_DATA_WIDTH(AXI_DATA_IN_WIDTH),
		.AXI_STRB_WIDTH(AXI_DATA_IN_WIDTH / 8),
		.AXI_USER_WIDTH(AXI_USER_WIDTH),
		.AXI_ID_WIDTH(AXI_ID_IN_WIDTH)
	) i_soc_interconnect_wrap(
		.clk_i(s_soc_clk),
		.rstn_i(s_pg_udma_rstn_sync),
		.test_en_i(dft_test_mode_i),
		.lint_fc_data(s_lint_fc_data_bus),
		.lint_fc_instr(s_lint_fc_instr_bus),
		.lint_udma_tx(s_lint_udma_tx_bus),
		.lint_udma_rx(s_lint_udma_rx_bus),
		.lint_debug(s_lint_debug_bus),
		.lint_hwpe(s_lint_hwpe_bus),
		.axi_from_cluster(s_data_in_bus),
		.axi_to_cluster(s_data_out_bus),
		.apb_periph_bus(s_apb_periph_bus),
		.mem_l2_bus(s_mem_l2_bus),
		.mem_l2_pri_bus(s_mem_l2_pri_bus),
		.mem_rom_bus(s_mem_rom_bus)
	);
	dmi_jtag #(.IdcodeValue(32'h249511c3)) i_dmi_jtag(
		.clk_i(s_soc_clk),
		.rst_ni(s_pg_logic_rstn_sync),
		.testmode_i(1'b0),
		.dmi_req_o(jtag_dmi_req),
		.dmi_req_valid_o(jtag_req_valid),
		.dmi_req_ready_i(debug_req_ready),
		.dmi_resp_i(debug_resp),
		.dmi_resp_ready_o(jtag_resp_ready),
		.dmi_resp_valid_i(jtag_resp_valid),
		.dmi_rst_no(),
		.tck_i(jtag_tck_i),
		.tms_i(jtag_tms_i),
		.trst_ni(jtag_trst_ni),
		.td_i(jtag_tdi_i),
		.td_o(int_td),
		.tdo_oe_o()
	);
	always @(*) begin
		hartinfo = {NrHarts {32'b00000000000000000000000000000000}};
		hartinfo[FC_Core_MHARTID * 32+:32] = RI5CY_HARTINFO;
	end
	dm_top #(
		.NrHarts(NrHarts),
		.BusWidth(32),
		.SelectableHarts(SELECTABLE_HARTS)
	) i_dm_top(
		.clk_i(s_soc_clk),
		.rst_ni(s_pg_logic_rstn_sync),
		.testmode_i(1'b0),
		.ndmreset_o(),
		.dmactive_o(),
		.debug_req_o(dm_debug_req),
		.unavailable_i(~SELECTABLE_HARTS),
		.hartinfo_i(hartinfo),
		.slave_req_i(slave_req),
		.slave_we_i(slave_we),
		.slave_addr_i(slave_addr),
		.slave_be_i(slave_be),
		.slave_wdata_i(slave_wdata),
		.slave_rdata_o(slave_rdata),
		.master_req_o(s_lint_riscv_jtag_bus.req),
		.master_add_o(s_lint_riscv_jtag_bus.add),
		.master_we_o(lint_riscv_jtag_bus_master_we),
		.master_wdata_o(s_lint_riscv_jtag_bus.wdata),
		.master_be_o(s_lint_riscv_jtag_bus.be),
		.master_gnt_i(s_lint_riscv_jtag_bus.gnt),
		.master_r_valid_i(s_lint_riscv_jtag_bus.r_valid),
		.master_r_rdata_i(s_lint_riscv_jtag_bus.r_rdata),
		.dmi_rst_ni(s_pg_logic_rstn_sync),
		.dmi_req_valid_i(jtag_req_valid),
		.dmi_req_ready_o(debug_req_ready),
		.dmi_req_i(jtag_dmi_req),
		.dmi_resp_valid_o(jtag_resp_valid),
		.dmi_resp_ready_i(jtag_resp_ready),
		.dmi_resp_o(debug_resp)
	);
	assign s_lint_riscv_jtag_bus.wen = ~lint_riscv_jtag_bus_master_we;
	wire s_jtag_shift_dr;
	wire s_jtag_update_dr;
	wire s_jtag_capture_dr;
	wire s_jtag_axireg_sel;
	wire s_jtag_axireg_tdi;
	wire s_jtag_axireg_tdo;
	jtag_tap_top jtag_tap_top_i(
		.tck_i(jtag_tck_i),
		.trst_ni(jtag_trst_ni),
		.tms_i(jtag_tms_i),
		.td_i(int_td),
		.td_o(jtag_tdo_o),
		.test_clk_i(1'b0),
		.test_rstn_i(s_pg_logic_rstn_sync),
		.jtag_shift_dr_o(s_jtag_shift_dr),
		.jtag_update_dr_o(s_jtag_update_dr),
		.jtag_capture_dr_o(s_jtag_capture_dr),
		.axireg_sel_o(s_jtag_axireg_sel),
		.dbg_axi_scan_in_o(s_jtag_axireg_tdi),
		.dbg_axi_scan_out_i(s_jtag_axireg_tdo),
		.soc_jtag_reg_i(soc_jtag_reg_soc),
		.soc_jtag_reg_o(soc_jtag_reg_tap),
		.sel_fll_clk_o(s_sel_fll_clk)
	);
	lint_jtag_wrap i_lint_jtag(
		.tck_i(jtag_tck_i),
		.tdi_i(s_jtag_axireg_tdi),
		.trstn_i(jtag_trst_ni),
		.tdo_o(s_jtag_axireg_tdo),
		.shift_dr_i(s_jtag_shift_dr),
		.pause_dr_i(1'b0),
		.update_dr_i(s_jtag_update_dr),
		.capture_dr_i(s_jtag_capture_dr),
		.lint_select_i(s_jtag_axireg_sel),
		.clk_i(s_soc_clk),
		.rst_ni(s_pg_logic_rstn_sync),
		.jtag_lint_master(s_lint_pulp_jtag_bus)
	);
	tcdm_arbiter_2x1 jtag_lint_arbiter_i(
		.clk_i(s_soc_clk),
		.rst_ni(s_pg_logic_rstn_sync),
		.tcdm_bus_1_i(s_lint_riscv_jtag_bus),
		.tcdm_bus_0_i(s_lint_pulp_jtag_bus),
		.tcdm_bus_o(s_lint_debug_bus)
	);
	apb2per #(
		.PER_ADDR_WIDTH(32),
		.APB_ADDR_WIDTH(32)
	) apb2per_newdebug_i(
		.clk_i(s_soc_clk),
		.rst_ni(s_pg_logic_rstn_sync),
		.PADDR(s_apb_debug_bus.paddr),
		.PWDATA(s_apb_debug_bus.pwdata),
		.PWRITE(s_apb_debug_bus.pwrite),
		.PSEL(s_apb_debug_bus.psel),
		.PENABLE(s_apb_debug_bus.penable),
		.PRDATA(s_apb_debug_bus.prdata),
		.PREADY(s_apb_debug_bus.pready),
		.PSLVERR(s_apb_debug_bus.pslverr),
		.per_master_req_o(slave_req),
		.per_master_add_o(slave_addr),
		.per_master_we_o(slave_we),
		.per_master_wdata_o(slave_wdata),
		.per_master_be_o(slave_be),
		.per_master_gnt_i(slave_grant),
		.per_master_r_valid_i(slave_valid),
		.per_master_r_opc_i(1'sb0),
		.per_master_r_rdata_i(slave_rdata)
	);
	assign slave_grant = slave_req;
	always @(posedge s_soc_clk or negedge s_pg_logic_rstn_sync) begin : apb2per_valid
		if (~s_pg_logic_rstn_sync)
			slave_valid <= 0;
		else
			slave_valid <= slave_grant;
	end
	generate
		for (i = 0; i < 32; i = i + 1) begin : genblk1
			for (j = 0; j < 6; j = j + 1) begin : genblk1
				assign gpio_cfg_o[j + (6 * i)] = s_gpio_cfg[(i * 6) + j];
			end
		end
		for (i = 0; i < 64; i = i + 1) begin : genblk2
			for (j = 0; j < 2; j = j + 1) begin : genblk1
				assign pad_mux_o[j + (2 * i)] = s_pad_mux[(i * 2) + j];
			end
		end
		for (i = 0; i < 64; i = i + 1) begin : genblk3
			for (j = 0; j < 6; j = j + 1) begin : genblk1
				assign pad_cfg_o[j + (6 * i)] = s_pad_cfg[(i * 6) + j];
			end
		end
	endgenerate
	assign s_data_slave.aw_writetoken = data_slave_aw_writetoken_i;
	assign s_data_slave.aw_addr = data_slave_aw_addr_i;
	assign s_data_slave.aw_prot = data_slave_aw_prot_i;
	assign s_data_slave.aw_region = data_slave_aw_region_i;
	assign s_data_slave.aw_len = data_slave_aw_len_i;
	assign s_data_slave.aw_size = data_slave_aw_size_i;
	assign s_data_slave.aw_burst = data_slave_aw_burst_i;
	assign s_data_slave.aw_lock = data_slave_aw_lock_i;
	assign s_data_slave.aw_cache = data_slave_aw_cache_i;
	assign s_data_slave.aw_qos = data_slave_aw_qos_i;
	assign s_data_slave.aw_id = data_slave_aw_id_i;
	assign s_data_slave.aw_user = data_slave_aw_user_i;
	assign data_slave_aw_readpointer_o = s_data_slave.aw_readpointer;
	assign s_data_slave.ar_writetoken = data_slave_ar_writetoken_i;
	assign s_data_slave.ar_addr = data_slave_ar_addr_i;
	assign s_data_slave.ar_prot = data_slave_ar_prot_i;
	assign s_data_slave.ar_region = data_slave_ar_region_i;
	assign s_data_slave.ar_len = data_slave_ar_len_i;
	assign s_data_slave.ar_size = data_slave_ar_size_i;
	assign s_data_slave.ar_burst = data_slave_ar_burst_i;
	assign s_data_slave.ar_lock = data_slave_ar_lock_i;
	assign s_data_slave.ar_cache = data_slave_ar_cache_i;
	assign s_data_slave.ar_qos = data_slave_ar_qos_i;
	assign s_data_slave.ar_id = data_slave_ar_id_i;
	assign s_data_slave.ar_user = data_slave_ar_user_i;
	assign data_slave_ar_readpointer_o = s_data_slave.ar_readpointer;
	assign s_data_slave.w_writetoken = data_slave_w_writetoken_i;
	assign s_data_slave.w_data = data_slave_w_data_i;
	assign s_data_slave.w_strb = data_slave_w_strb_i;
	assign s_data_slave.w_user = data_slave_w_user_i;
	assign s_data_slave.w_last = data_slave_w_last_i;
	assign data_slave_w_readpointer_o = s_data_slave.w_readpointer;
	assign data_slave_r_writetoken_o = s_data_slave.r_writetoken;
	assign data_slave_r_data_o = s_data_slave.r_data;
	assign data_slave_r_resp_o = s_data_slave.r_resp;
	assign data_slave_r_last_o = s_data_slave.r_last;
	assign data_slave_r_id_o = s_data_slave.r_id;
	assign data_slave_r_user_o = s_data_slave.r_user;
	assign s_data_slave.r_readpointer = data_slave_r_readpointer_i;
	assign data_slave_b_writetoken_o = s_data_slave.b_writetoken;
	assign data_slave_b_resp_o = s_data_slave.b_resp;
	assign data_slave_b_id_o = s_data_slave.b_id;
	assign data_slave_b_user_o = s_data_slave.b_user;
	assign s_data_slave.b_readpointer = data_slave_b_readpointer_i;
	assign data_master_aw_writetoken_o = s_data_master.aw_writetoken;
	assign data_master_aw_addr_o = s_data_master.aw_addr;
	assign data_master_aw_prot_o = s_data_master.aw_prot;
	assign data_master_aw_region_o = s_data_master.aw_region;
	assign data_master_aw_len_o = s_data_master.aw_len;
	assign data_master_aw_size_o = s_data_master.aw_size;
	assign data_master_aw_burst_o = s_data_master.aw_burst;
	assign data_master_aw_lock_o = s_data_master.aw_lock;
	assign data_master_aw_cache_o = s_data_master.aw_cache;
	assign data_master_aw_qos_o = s_data_master.aw_qos;
	assign data_master_aw_id_o = s_data_master.aw_id;
	assign data_master_aw_user_o = s_data_master.aw_user;
	assign s_data_master.aw_readpointer = data_master_aw_readpointer_i;
	assign data_master_ar_writetoken_o = s_data_master.ar_writetoken;
	assign data_master_ar_addr_o = s_data_master.ar_addr;
	assign data_master_ar_prot_o = s_data_master.ar_prot;
	assign data_master_ar_region_o = s_data_master.ar_region;
	assign data_master_ar_len_o = s_data_master.ar_len;
	assign data_master_ar_size_o = s_data_master.ar_size;
	assign data_master_ar_burst_o = s_data_master.ar_burst;
	assign data_master_ar_lock_o = s_data_master.ar_lock;
	assign data_master_ar_cache_o = s_data_master.ar_cache;
	assign data_master_ar_qos_o = s_data_master.ar_qos;
	assign data_master_ar_id_o = s_data_master.ar_id;
	assign data_master_ar_user_o = s_data_master.ar_user;
	assign s_data_master.ar_readpointer = data_master_ar_readpointer_i;
	assign data_master_w_writetoken_o = s_data_master.w_writetoken;
	assign data_master_w_data_o = s_data_master.w_data;
	assign data_master_w_strb_o = s_data_master.w_strb;
	assign data_master_w_user_o = s_data_master.w_user;
	assign data_master_w_last_o = s_data_master.w_last;
	assign s_data_master.w_readpointer = data_master_w_readpointer_i;
	assign s_data_master.r_writetoken = data_master_r_writetoken_i;
	assign s_data_master.r_data = data_master_r_data_i;
	assign s_data_master.r_resp = data_master_r_resp_i;
	assign s_data_master.r_last = data_master_r_last_i;
	assign s_data_master.r_id = data_master_r_id_i;
	assign s_data_master.r_user = data_master_r_user_i;
	assign data_master_r_readpointer_o = s_data_master.r_readpointer;
	assign s_data_master.b_writetoken = data_master_b_writetoken_i;
	assign s_data_master.b_resp = data_master_b_resp_i;
	assign s_data_master.b_id = data_master_b_id_i;
	assign s_data_master.b_user = data_master_b_user_i;
	assign data_master_b_readpointer_o = s_data_master.b_readpointer;
	assign gnd_con = 1'sb0;
	dummy_decap i_dummy_decap_L1();
	dummy_decap i_dummy_decap_L2();
	dummy_decap i_dummy_decap_L2_udma();
	dummy_decap i_dummy_decap_mram();
	pulp_clock_gating_8t i_clk_gate_clk_soc(
		.clk_i(clk_soc_ext_i),
		.en_i(s_clk_en_system),
		.test_en_i(scan_en_in),
		.clk_o(clk_soc_ext_gated)
	);
	pulp_clock_gating_8t i_clk_gate_clk_per(
		.clk_i(clk_per_ext_i),
		.en_i(s_clk_en_system),
		.test_en_i(scan_en_in),
		.clk_o(clk_per_ext_gated)
	);
	pulp_clock_gating_8t i_clk_gate_ref_clk(
		.clk_i(ref_clk_i),
		.en_i(s_clk_en_system),
		.test_en_i(scan_en_in),
		.clk_o(ref_clk_gated)
	);
endmodule
