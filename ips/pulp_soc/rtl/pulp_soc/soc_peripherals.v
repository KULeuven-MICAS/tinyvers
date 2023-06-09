module soc_peripherals (
	clk_i,
	periph_clk_i,
	clk_soc_ext_i,
	rst_ni,
	ref_clk_i,
	slow_clk_i,
	sel_fll_clk_i,
	dft_test_mode_i,
	dft_cg_enable_i,
	fc_bootaddr_o,
	fc_fetchen_o,
	soc_jtag_reg_i,
	soc_jtag_reg_o,
	boot_l2_i,
	bootsel_i,
	apb_slave,
	apb_eu_master,
	apb_hwpe_master,
	apb_debug_master,
	l2_rx_master,
	l2_tx_master,
	soc_fll_master,
	per_fll_master,
	cluster_fll_master,
	dma_pe_evt_i,
	dma_pe_irq_i,
	pf_evt_i,
	fc_hwpe_events_i,
	fc_events_o,
	gpio_in,
	gpio_out,
	gpio_dir,
	gpio_padcfg,
	pad_mux_o,
	pad_cfg_o,
	timer_ch0_o,
	timer_ch1_o,
	timer_ch2_o,
	timer_ch3_o,
	cam_clk_i,
	cam_data_i,
	cam_hsync_i,
	cam_vsync_i,
	uart_tx,
	uart_rx,
	i2c_scl_i,
	i2c_scl_o,
	i2c_scl_oe,
	i2c_sda_i,
	i2c_sda_o,
	i2c_sda_oe,
	i2s_slave_sd0_i,
	i2s_slave_sd1_i,
	i2s_slave_ws_i,
	i2s_slave_ws_o,
	i2s_slave_ws_oe,
	i2s_slave_sck_i,
	i2s_slave_sck_o,
	i2s_slave_sck_oe,
	spi_clk,
	spi_csn,
	spi_oen,
	spi_sdo,
	spi_sdi,
	sdclk_o,
	sdcmd_o,
	sdcmd_i,
	sdcmd_oen_o,
	sddata_o,
	sddata_i,
	sddata_oen_o,
	cl_event_data_o,
	cl_event_valid_o,
	cl_event_ready_i,
	fc_event_data_o,
	fc_event_valid_o,
	fc_event_ready_i,
	cluster_pow_o,
	cluster_byp_o,
	cluster_boot_addr_o,
	cluster_fetch_enable_o,
	cluster_rstn_o,
	cluster_irq_o,
	clk_en_system,
	pg_logic_rstn_o,
	pg_udma_rstn_o,
	pg_ram_rom_rstn_o,
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
	ext_pg_mram
);
	parameter CORE_TYPE = 0;
	parameter MEM_ADDR_WIDTH = 13;
	parameter APB_ADDR_WIDTH = 32;
	parameter APB_DATA_WIDTH = 32;
	parameter NB_CORES = 4;
	parameter NB_CLUSTERS = 0;
	parameter EVNT_WIDTH = 8;
	parameter NGPIO = 64;
	parameter NPAD = 64;
	parameter NBIT_PADCFG = 4;
	parameter NBIT_PADMUX = 2;
	input wire clk_i;
	input wire periph_clk_i;
	input wire clk_soc_ext_i;
	input wire rst_ni;
	input wire ref_clk_i;
	input wire slow_clk_i;
	input wire sel_fll_clk_i;
	input wire dft_test_mode_i;
	input wire dft_cg_enable_i;
	output wire [31:0] fc_bootaddr_o;
	output wire fc_fetchen_o;
	input wire [7:0] soc_jtag_reg_i;
	output wire [7:0] soc_jtag_reg_o;
	input wire boot_l2_i;
	input wire bootsel_i;
	input APB_BUS.Slave apb_slave;
	input APB_BUS.Master apb_eu_master;
	input APB_BUS.Master apb_hwpe_master;
	input APB_BUS.Master apb_debug_master;
	input XBAR_TCDM_BUS.Master l2_rx_master;
	input XBAR_TCDM_BUS.Master l2_tx_master;
	input FLL_BUS.Master soc_fll_master;
	input FLL_BUS.Master per_fll_master;
	input FLL_BUS.Master cluster_fll_master;
	input wire dma_pe_evt_i;
	input wire dma_pe_irq_i;
	input wire pf_evt_i;
	input wire [1:0] fc_hwpe_events_i;
	output wire [31:0] fc_events_o;
	input wire [NGPIO - 1:0] gpio_in;
	output wire [NGPIO - 1:0] gpio_out;
	output wire [NGPIO - 1:0] gpio_dir;
	output wire [(NGPIO * NBIT_PADCFG) - 1:0] gpio_padcfg;
	output wire [(NPAD * NBIT_PADMUX) - 1:0] pad_mux_o;
	output wire [(NPAD * NBIT_PADCFG) - 1:0] pad_cfg_o;
	output wire [3:0] timer_ch0_o;
	output wire [3:0] timer_ch1_o;
	output wire [3:0] timer_ch2_o;
	output wire [3:0] timer_ch3_o;
	input wire cam_clk_i;
	input wire [7:0] cam_data_i;
	input wire cam_hsync_i;
	input wire cam_vsync_i;
	output wire uart_tx;
	input wire uart_rx;
	input wire [1:0] i2c_scl_i;
	output wire [1:0] i2c_scl_o;
	output wire [1:0] i2c_scl_oe;
	input wire [1:0] i2c_sda_i;
	output wire [1:0] i2c_sda_o;
	output wire [1:0] i2c_sda_oe;
	input wire i2s_slave_sd0_i;
	input wire i2s_slave_sd1_i;
	input wire i2s_slave_ws_i;
	output wire i2s_slave_ws_o;
	output wire i2s_slave_ws_oe;
	input wire i2s_slave_sck_i;
	output wire i2s_slave_sck_o;
	output wire i2s_slave_sck_oe;
	output wire spi_clk;
	output wire [3:0] spi_csn;
	output wire [3:0] spi_oen;
	output wire [3:0] spi_sdo;
	input wire [3:0] spi_sdi;
	output wire sdclk_o;
	output wire sdcmd_o;
	input wire sdcmd_i;
	output wire sdcmd_oen_o;
	output wire [3:0] sddata_o;
	input wire [3:0] sddata_i;
	output wire [3:0] sddata_oen_o;
	output wire [EVNT_WIDTH - 1:0] cl_event_data_o;
	output wire cl_event_valid_o;
	input wire cl_event_ready_i;
	output wire [EVNT_WIDTH - 1:0] fc_event_data_o;
	output wire fc_event_valid_o;
	input wire fc_event_ready_i;
	output wire cluster_pow_o;
	output wire cluster_byp_o;
	output wire [63:0] cluster_boot_addr_o;
	output wire cluster_fetch_enable_o;
	output wire cluster_rstn_o;
	output wire cluster_irq_o;
	output wire clk_en_system;
	output wire pg_logic_rstn_o;
	output wire pg_udma_rstn_o;
	output wire pg_ram_rom_rstn_o;
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
	localparam USE_IBEX = (CORE_TYPE == 1) || (CORE_TYPE == 2);
	APB_BUS s_fll_bus();
	APB_BUS s_gpio_bus();
	APB_BUS s_udma_bus();
	APB_BUS s_soc_ctrl_bus();
	APB_BUS s_adv_timer_bus();
	APB_BUS s_soc_evnt_gen_bus();
	APB_BUS s_stdout_bus();
	APB_BUS s_apb_timer_bus();
	APB_BUS s_apb_wakeup_bus();
	localparam UDMA_EVENTS = 128;
	wire [31:0] s_gpio_sync;
	wire s_sel_hyper_axi;
	wire s_gpio_event;
	wire [1:0] s_spim_event;
	wire s_uart_event;
	wire s_i2c_event;
	wire s_i2s_event;
	wire s_i2s_cam_event;
	wire [3:0] s_adv_timer_events;
	wire [1:0] s_fc_hp_events;
	wire s_fc_err_events;
	wire s_ref_rise_event;
	wire s_ref_fall_event;
	wire s_timer_hi_event;
	wire s_timer_lo_event;
	wire s_pr_event_valid;
	wire [7:0] s_pr_event_data;
	wire s_pr_event_ready;
	wire [127:0] s_udma_events;
	wire [159:0] s_events;
	wire s_timer_in_lo_event;
	wire s_timer_in_hi_event;
	wire s_pg_logic_rstn;
	wire s_pg_udma_rstn;
	wire s_VDDA_out_pg;
	wire s_VDD_out_pg;
	wire s_VREF_out_pg;
	wire PORb_pg;
	wire RETb_pg;
	wire RSTb_pg;
	wire TRIM_pg;
	wire DPD_pg;
	wire CEb_HIGH_pg;
	assign pg_logic_rstn_o = s_pg_logic_rstn;
	assign pg_udma_rstn_o = s_pg_udma_rstn;
	assign VDD_out_pg = s_VDD_out_pg;
	assign VDDA_out_pg = s_VDDA_out_pg;
	assign VREF_out_pg = s_VREF_out_pg;
	assign s_events[127:0] = s_udma_events;
	assign s_events[135] = s_adv_timer_events[0];
	assign s_events[136] = s_adv_timer_events[1];
	assign s_events[137] = s_adv_timer_events[2];
	assign s_events[138] = s_adv_timer_events[3];
	assign s_events[139] = s_gpio_event;
	assign s_events[140] = fc_hwpe_events_i[0];
	assign s_events[141] = fc_hwpe_events_i[1];
	assign s_events[159:142] = 1'sb0;
	generate
		if (USE_IBEX == 0) begin : FC_EVENTS
			assign fc_events_o[7:0] = 8'h00;
			assign fc_events_o[8] = dma_pe_evt_i;
			assign fc_events_o[9] = dma_pe_irq_i;
			assign fc_events_o[10] = s_timer_lo_event;
			assign fc_events_o[11] = s_timer_hi_event;
			assign fc_events_o[12] = pf_evt_i;
			assign fc_events_o[13] = 1'b0;
			assign fc_events_o[14] = s_ref_rise_event | s_ref_fall_event;
			assign fc_events_o[15] = s_gpio_event;
			assign fc_events_o[16] = 1'b0;
			assign fc_events_o[17] = s_adv_timer_events[0];
			assign fc_events_o[18] = s_adv_timer_events[1];
			assign fc_events_o[19] = s_adv_timer_events[2];
			assign fc_events_o[20] = s_adv_timer_events[3];
			assign fc_events_o[21] = 1'b0;
			assign fc_events_o[22] = 1'b0;
			assign fc_events_o[23] = 1'b0;
			assign fc_events_o[24] = 1'b0;
			assign fc_events_o[25] = 1'b0;
			assign fc_events_o[26] = 1'b0;
			assign fc_events_o[27] = 1'b0;
			assign fc_events_o[28] = 1'b0;
			assign fc_events_o[29] = s_fc_err_events;
			assign fc_events_o[30] = s_fc_hp_events[0];
			assign fc_events_o[31] = s_fc_hp_events[1];
		end
		else begin : FC_EVENTS
			assign fc_events_o[0] = s_timer_lo_event;
			assign fc_events_o[1] = s_timer_hi_event;
			assign fc_events_o[2] = s_ref_rise_event | s_ref_fall_event;
			assign fc_events_o[3] = s_gpio_event;
			assign fc_events_o[4] = s_adv_timer_events[0];
			assign fc_events_o[5] = s_adv_timer_events[1];
			assign fc_events_o[6] = s_adv_timer_events[2];
			assign fc_events_o[7] = s_adv_timer_events[3];
			assign fc_events_o[8] = 1'b0;
			assign fc_events_o[9] = 1'b0;
			assign fc_events_o[10] = 1'b0;
			assign fc_events_o[11] = s_fc_err_events;
			assign fc_events_o[12] = s_fc_hp_events[0];
			assign fc_events_o[13] = s_fc_hp_events[1];
			assign fc_events_o[14] = 1'b0;
			assign fc_events_o[31:15] = 17'b00000000000000000;
		end
	endgenerate
	pulp_sync_wedge i_ref_clk_sync(
		.clk_i(clk_i),
		.rstn_i(s_pg_logic_rstn),
		.en_i(1'b1),
		.serial_i(slow_clk_i),
		.r_edge_o(s_ref_rise_event),
		.f_edge_o(s_ref_fall_event),
		.serial_o()
	);
	periph_bus_wrap #(
		.APB_ADDR_WIDTH(32),
		.APB_DATA_WIDTH(32)
	) periph_bus_i(
		.clk_i(clk_i),
		.rst_ni(s_pg_logic_rstn),
		.apb_slave(apb_slave),
		.fll_master(s_fll_bus),
		.gpio_master(s_gpio_bus),
		.udma_master(s_udma_bus),
		.soc_ctrl_master(s_soc_ctrl_bus),
		.adv_timer_master(s_adv_timer_bus),
		.soc_evnt_gen_master(s_soc_evnt_gen_bus),
		.eu_master(apb_eu_master),
		.mmap_debug_master(apb_debug_master),
		.hwpe_master(apb_hwpe_master),
		.timer_master(s_apb_timer_bus),
		.stdout_master(s_stdout_bus),
		.wakeup_master(s_apb_wakeup_bus)
	);
	apb_fll_if #(.APB_ADDR_WIDTH(APB_ADDR_WIDTH)) apb_fll_if_i(
		.HCLK(clk_i),
		.HRESETn(s_pg_logic_rstn),
		.PADDR(s_fll_bus.paddr),
		.PWDATA(s_fll_bus.pwdata),
		.PWRITE(s_fll_bus.pwrite),
		.PSEL(s_fll_bus.psel),
		.PENABLE(s_fll_bus.penable),
		.PRDATA(s_fll_bus.prdata),
		.PREADY(s_fll_bus.pready),
		.PSLVERR(s_fll_bus.pslverr),
		.fll1_req(soc_fll_master.req),
		.fll1_wrn(soc_fll_master.wrn),
		.fll1_add(soc_fll_master.add[1:0]),
		.fll1_data(soc_fll_master.data),
		.fll1_ack(soc_fll_master.ack),
		.fll1_r_data(soc_fll_master.r_data),
		.fll1_lock(soc_fll_master.lock),
		.fll2_req(per_fll_master.req),
		.fll2_wrn(per_fll_master.wrn),
		.fll2_add(per_fll_master.add[1:0]),
		.fll2_data(per_fll_master.data),
		.fll2_ack(per_fll_master.ack),
		.fll2_r_data(per_fll_master.r_data),
		.fll2_lock(per_fll_master.lock),
		.fll3_req(cluster_fll_master.req),
		.fll3_wrn(cluster_fll_master.wrn),
		.fll3_add(cluster_fll_master.add[1:0]),
		.fll3_data(cluster_fll_master.data),
		.fll3_ack(cluster_fll_master.ack),
		.fll3_r_data(cluster_fll_master.r_data),
		.fll3_lock(cluster_fll_master.lock)
	);
	apb_gpio #(
		.APB_ADDR_WIDTH(APB_ADDR_WIDTH),
		.PAD_NUM(NGPIO)
	) apb_gpio_i(
		.HCLK(clk_i),
		.HRESETn(s_pg_logic_rstn),
		.dft_cg_enable_i(dft_cg_enable_i),
		.PADDR(s_gpio_bus.paddr),
		.PWDATA(s_gpio_bus.pwdata),
		.PWRITE(s_gpio_bus.pwrite),
		.PSEL(s_gpio_bus.psel),
		.PENABLE(s_gpio_bus.penable),
		.PRDATA(s_gpio_bus.prdata),
		.PREADY(s_gpio_bus.pready),
		.PSLVERR(s_gpio_bus.pslverr),
		.gpio_in_sync(s_gpio_sync),
		.gpio_in(gpio_in),
		.gpio_out(gpio_out),
		.gpio_dir(gpio_dir),
		.gpio_padcfg(gpio_padcfg),
		.interrupt(s_gpio_event)
	);
	udma_subsystem #(
		.APB_ADDR_WIDTH(APB_ADDR_WIDTH),
		.L2_ADDR_WIDTH(MEM_ADDR_WIDTH),
		.N_SPI(1),
		.N_UART(1),
		.N_I2C(2)
	) i_udma(
		.L2_ro_req_o(l2_tx_master.req),
		.L2_ro_gnt_i(l2_tx_master.gnt),
		.L2_ro_wen_o(l2_tx_master.wen),
		.L2_ro_addr_o(l2_tx_master.add),
		.L2_ro_wdata_o(l2_tx_master.wdata),
		.L2_ro_be_o(l2_tx_master.be),
		.L2_ro_rdata_i(l2_tx_master.r_rdata),
		.L2_ro_rvalid_i(l2_tx_master.r_valid),
		.L2_wo_req_o(l2_rx_master.req),
		.L2_wo_gnt_i(l2_rx_master.gnt),
		.L2_wo_wen_o(l2_rx_master.wen),
		.L2_wo_addr_o(l2_rx_master.add),
		.L2_wo_wdata_o(l2_rx_master.wdata),
		.L2_wo_be_o(l2_rx_master.be),
		.L2_wo_rdata_i(l2_rx_master.r_rdata),
		.L2_wo_rvalid_i(l2_rx_master.r_valid),
		.dft_test_mode_i(dft_test_mode_i),
		.dft_cg_enable_i(dft_test_mode_i),
		.sys_clk_i(clk_i),
		.periph_clk_i(periph_clk_i),
		.sys_resetn_i(s_pg_udma_rstn),
		.udma_apb_paddr(s_udma_bus.paddr),
		.udma_apb_pwdata(s_udma_bus.pwdata),
		.udma_apb_pwrite(s_udma_bus.pwrite),
		.udma_apb_psel(s_udma_bus.psel),
		.udma_apb_penable(s_udma_bus.penable),
		.udma_apb_prdata(s_udma_bus.prdata),
		.udma_apb_pready(s_udma_bus.pready),
		.udma_apb_pslverr(s_udma_bus.pslverr),
		.events_o(s_udma_events),
		.event_valid_i(s_pr_event_valid),
		.event_data_i(s_pr_event_data),
		.event_ready_o(s_pr_event_ready),
		.spi_clk(spi_clk),
		.spi_csn(spi_csn),
		.spi_oen(spi_oen),
		.spi_sdo(spi_sdo),
		.spi_sdi(spi_sdi),
		.sdio_clk_o(sdclk_o),
		.sdio_cmd_o(sdcmd_o),
		.sdio_cmd_i(sdcmd_i),
		.sdio_cmd_oen_o(sdcmd_oen_o),
		.sdio_data_o(sddata_o),
		.sdio_data_i(sddata_i),
		.sdio_data_oen_o(sddata_oen_o),
		.cam_clk_i(cam_clk_i),
		.cam_data_i(cam_data_i),
		.cam_hsync_i(cam_hsync_i),
		.cam_vsync_i(cam_vsync_i),
		.i2s_slave_sd0_i(i2s_slave_sd0_i),
		.i2s_slave_sd1_i(i2s_slave_sd1_i),
		.i2s_slave_ws_i(i2s_slave_ws_i),
		.i2s_slave_ws_o(i2s_slave_ws_o),
		.i2s_slave_ws_oe(i2s_slave_ws_oe),
		.i2s_slave_sck_i(i2s_slave_sck_i),
		.i2s_slave_sck_o(i2s_slave_sck_o),
		.i2s_slave_sck_oe(i2s_slave_sck_oe),
		.uart_rx_i(uart_rx),
		.uart_tx_o(uart_tx),
		.i2c_scl_i(i2c_scl_i),
		.i2c_scl_o(i2c_scl_o),
		.i2c_scl_oe(i2c_scl_oe),
		.i2c_sda_i(i2c_sda_i),
		.i2c_sda_o(i2c_sda_o),
		.i2c_sda_oe(i2c_sda_oe),
		.VDDA_i(s_VDDA_out_pg),
		.VDD_i(s_VDD_out_pg),
		.VREF_i(s_VREF_out_pg),
		.PORb_i(PORb_pg),
		.RETb_i(RETb_pg),
		.RSTb_i(RSTb_pg),
		.TRIM_i(TRIM_pg),
		.DPD_i(DPD_pg),
		.CEb_HIGH_i(CEb_HIGH_pg)
	);
	apb_soc_ctrl #(
		.NB_CORES(NB_CORES),
		.NB_CLUSTERS(NB_CLUSTERS),
		.APB_ADDR_WIDTH(APB_ADDR_WIDTH)
	) apb_soc_ctrl_i(
		.HCLK(clk_i),
		.HRESETn(s_pg_logic_rstn),
		.PADDR(s_soc_ctrl_bus.paddr),
		.PWDATA(s_soc_ctrl_bus.pwdata),
		.PWRITE(s_soc_ctrl_bus.pwrite),
		.PSEL(s_soc_ctrl_bus.psel),
		.PENABLE(s_soc_ctrl_bus.penable),
		.PRDATA(s_soc_ctrl_bus.prdata),
		.PREADY(s_soc_ctrl_bus.pready),
		.PSLVERR(s_soc_ctrl_bus.pslverr),
		.sel_fll_clk_i(sel_fll_clk_i),
		.boot_l2_i(boot_l2_i),
		.bootsel_i(bootsel_i),
		.fc_bootaddr_o(fc_bootaddr_o),
		.fc_fetchen_o(fc_fetchen_o),
		.soc_jtag_reg_i(soc_jtag_reg_i),
		.soc_jtag_reg_o(soc_jtag_reg_o),
		.pad_mux(pad_mux_o),
		.pad_cfg(pad_cfg_o),
		.cluster_pow_o(cluster_pow_o),
		.sel_hyper_axi_o(s_sel_hyper_axi),
		.cluster_byp_o(cluster_byp_o),
		.cluster_boot_addr_o(cluster_boot_addr_o),
		.cluster_fetch_enable_o(cluster_fetch_enable_o),
		.cluster_rstn_o(cluster_rstn_o),
		.cluster_irq_o(cluster_irq_o)
	);
	apb_adv_timer #(
		.APB_ADDR_WIDTH(APB_ADDR_WIDTH),
		.EXTSIG_NUM(32)
	) apb_adv_timer_i(
		.HCLK(clk_i),
		.HRESETn(s_pg_logic_rstn),
		.dft_cg_enable_i(dft_test_mode_i),
		.PADDR(s_adv_timer_bus.paddr),
		.PWDATA(s_adv_timer_bus.pwdata),
		.PWRITE(s_adv_timer_bus.pwrite),
		.PSEL(s_adv_timer_bus.psel),
		.PENABLE(s_adv_timer_bus.penable),
		.PRDATA(s_adv_timer_bus.prdata),
		.PREADY(s_adv_timer_bus.pready),
		.PSLVERR(s_adv_timer_bus.pslverr),
		.low_speed_clk_i(slow_clk_i),
		.ext_sig_i(s_gpio_sync),
		.events_o(s_adv_timer_events),
		.ch_0_o(timer_ch0_o),
		.ch_1_o(timer_ch1_o),
		.ch_2_o(timer_ch2_o),
		.ch_3_o(timer_ch3_o)
	);
	soc_event_generator #(
		.APB_ADDR_WIDTH(APB_ADDR_WIDTH),
		.APB_EVNT_NUM(8),
		.PER_EVNT_NUM(160),
		.EVNT_WIDTH(EVNT_WIDTH),
		.FC_EVENT_POS(7)
	) u_evnt_gen(
		.HCLK(clk_i),
		.HRESETn(s_pg_logic_rstn),
		.PADDR(s_soc_evnt_gen_bus.paddr),
		.PWDATA(s_soc_evnt_gen_bus.pwdata),
		.PWRITE(s_soc_evnt_gen_bus.pwrite),
		.PSEL(s_soc_evnt_gen_bus.psel),
		.PENABLE(s_soc_evnt_gen_bus.penable),
		.PRDATA(s_soc_evnt_gen_bus.prdata),
		.PREADY(s_soc_evnt_gen_bus.pready),
		.PSLVERR(s_soc_evnt_gen_bus.pslverr),
		.low_speed_clk_i(slow_clk_i),
		.timer_event_lo_o(s_timer_in_lo_event),
		.timer_event_hi_o(s_timer_in_hi_event),
		.per_events_i(s_events),
		.err_event_o(s_fc_err_events),
		.fc_events_o(s_fc_hp_events),
		.fc_event_valid_o(fc_event_valid_o),
		.fc_event_data_o(fc_event_data_o),
		.fc_event_ready_i(fc_event_ready_i),
		.cl_event_valid_o(cl_event_valid_o),
		.cl_event_data_o(cl_event_data_o),
		.cl_event_ready_i(cl_event_ready_i),
		.pr_event_valid_o(s_pr_event_valid),
		.pr_event_data_o(s_pr_event_data),
		.pr_event_ready_i(s_pr_event_ready)
	);
	apb_timer_unit #(.APB_ADDR_WIDTH(APB_ADDR_WIDTH)) i_apb_timer_unit(
		.HCLK(clk_i),
		.HRESETn(s_pg_logic_rstn),
		.PADDR(s_apb_timer_bus.paddr),
		.PWDATA(s_apb_timer_bus.pwdata),
		.PWRITE(s_apb_timer_bus.pwrite),
		.PSEL(s_apb_timer_bus.psel),
		.PENABLE(s_apb_timer_bus.penable),
		.PRDATA(s_apb_timer_bus.prdata),
		.PREADY(s_apb_timer_bus.pready),
		.PSLVERR(s_apb_timer_bus.pslverr),
		.ref_clk_i(slow_clk_i),
		.event_lo_i(s_timer_in_lo_event),
		.event_hi_i(s_timer_in_hi_event),
		.irq_lo_o(s_timer_lo_event),
		.irq_hi_o(s_timer_hi_event),
		.busy_o()
	);
	apb_wakeup #(.APB_ADDR_WIDTH(APB_ADDR_WIDTH)) i_apb_wakeup_unit(
		.HCLK(clk_i),
		.clk_soc_ext_i(clk_soc_ext_i),
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
		.ext_pg_mram(ext_pg_mram),
		.HRESETn(s_pg_logic_rstn),
		.PADDR(s_apb_wakeup_bus.paddr),
		.PWDATA(s_apb_wakeup_bus.pwdata),
		.PWRITE(s_apb_wakeup_bus.pwrite),
		.PSEL(s_apb_wakeup_bus.psel),
		.PENABLE(s_apb_wakeup_bus.penable),
		.PRDATA(s_apb_wakeup_bus.prdata),
		.PREADY(s_apb_wakeup_bus.pready),
		.PSLVERR(s_apb_wakeup_bus.pslverr),
		.ref_clk_i(ref_clk_i),
		.rstn_i(rst_ni),
		.clk_en_system(clk_en_system),
		.pg_logic_rstn_o(s_pg_logic_rstn),
		.pg_udma_rstn_o(s_pg_udma_rstn),
		.pg_ram_rom_rstn_o(pg_ram_rom_rstn_o),
		.VDDA_out(s_VDDA_out_pg),
		.VDD_out(s_VDD_out_pg),
		.VREF_out(s_VREF_out_pg),
		.PORb(PORb_pg),
		.RETb(RETb_pg),
		.RSTb(RSTb_pg),
		.TRIM(TRIM_pg),
		.DPD(DPD_pg),
		.CEb_HIGH(CEb_HIGH_pg)
	);
endmodule
