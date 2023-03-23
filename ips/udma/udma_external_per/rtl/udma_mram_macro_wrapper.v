module udma_mram_macro_wrapper (
	pmu_trc_clk_i,
	pmu_trc_rst_n_i,
	pmu_trc_ret_n_i,
	pmu_trc_curset_ret_i,
	pmu_trc_retain_en_i,
	pmu_trc_prog_delay_ret_i,
	pmu_trc_pok_ret_o,
	dft_test_mode_i,
	mram_CLK_i,
	mram_CEb_i,
	mram_A_i,
	mram_DIN_i,
	mram_DOUT_o,
	mram_RDEN_i,
	mram_WEb_i,
	mram_PROGEN_i,
	mram_PROG_i,
	mram_ERASE_i,
	mram_CHIP_i,
	mram_PORb_i,
	mram_RETb_i,
	mram_RSTb_i,
	mram_NVR_i,
	mram_TMEN_i,
	mram_AREF_i,
	mram_DPD_i,
	mram_ECCBYPS_i,
	mram_SHIFT_i,
	mram_SUPD_i,
	mram_SDI_i,
	mram_SCLK_i,
	mram_SDO_o,
	mram_RDY_o,
	mram_DONE_o,
	mram_EC_o,
	mram_UE_o
);
	input wire pmu_trc_clk_i;
	input wire pmu_trc_rst_n_i;
	input wire pmu_trc_ret_n_i;
	input wire [2:0] pmu_trc_curset_ret_i;
	input wire pmu_trc_retain_en_i;
	input wire [1:0] pmu_trc_prog_delay_ret_i;
	output wire pmu_trc_pok_ret_o;
	input wire dft_test_mode_i;
	input wire mram_CLK_i;
	input wire mram_CEb_i;
	input wire [18:0] mram_A_i;
	input wire [77:0] mram_DIN_i;
	output wire [77:0] mram_DOUT_o;
	input wire mram_RDEN_i;
	input wire mram_WEb_i;
	input wire mram_PROGEN_i;
	input wire mram_PROG_i;
	input wire mram_ERASE_i;
	input wire mram_CHIP_i;
	input wire mram_PORb_i;
	input wire mram_RETb_i;
	input wire mram_RSTb_i;
	input wire mram_NVR_i;
	input wire mram_TMEN_i;
	input wire mram_AREF_i;
	input wire mram_DPD_i;
	input wire mram_ECCBYPS_i;
	input wire mram_SHIFT_i;
	input wire mram_SUPD_i;
	input wire mram_SDI_i;
	input wire mram_SCLK_i;
	output wire mram_SDO_o;
	output wire mram_RDY_o;
	output wire mram_DONE_o;
	output wire mram_EC_o;
	output wire mram_UE_o;
	wire s_ao_retain;
	wire s_ao_isolate;
	wire s_ictrl;
	ick_rvt_hstrcl20d1 u_soc_trc(
		.CLK(pmu_trc_clk_i),
		.NRST(pmu_trc_rst_n_i),
		.POWER(pmu_trc_ret_n_i),
		.CURSET(pmu_trc_curset_ret_i),
		.RETAIN_EN(pmu_trc_retain_en_i),
		.PROG_DELAY(pmu_trc_prog_delay_ret_i),
		.TBYPASS_MODE(1'b0),
		.TBYPASS_ISOLATE(),
		.TBYPASS_RETAIN(),
		.POK(pmu_trc_pok_ret_o),
		.RETAIN(s_ao_retain),
		.ISOLATE(s_ao_isolate),
		.FB(),
		.ICTRL(s_ictrl),
		.ICTRL_DETECT(s_ictrl),
		.SCAN_MODE(dft_test_mode_i)
	);
	wire VREF;
	wire VPR;
	wire VDDA;
	wire VDD_cfg;
	wire VDD;
	wire VSS;
	MRAM_eFLASH_512Kx78 i_MRAM_eFLASH_512Kx78(
		.CLK(mram_CLK_i),
		.CEb(mram_CEb_i),
		.A(mram_A_i),
		.DIN(mram_DIN_i),
		.RDEN(mram_RDEN_i),
		.WEb(mram_WEb_i),
		.PROGEN(mram_PROGEN_i),
		.PROG(mram_PROG_i),
		.ERASE(mram_ERASE_i),
		.CHIP(mram_CHIP_i),
		.DONE(mram_DONE_o),
		.RDY(mram_RDY_o),
		.DOUT(mram_DOUT_o),
		.TMEN(mram_TMEN_i),
		.AREF(mram_AREF_i),
		.NVR(mram_NVR_i),
		.PORb(mram_PORb_i),
		.RSTb(mram_RSTb_i),
		.RETb(mram_RETb_i),
		.DPD(mram_DPD_i),
		.SHIFT(mram_SHIFT_i),
		.SUPD(mram_SUPD_i),
		.SDI(mram_SDI_i),
		.SCLK(mram_SCLK_i),
		.SDO(mram_SDO_o),
		.EC(mram_EC_o),
		.UE(mram_UE_o),
		.ECCBYPS(mram_ECCBYPS_i),
		.VREF(VREF),
		.VPR(VPR),
		.VDDA(VDDA),
		.VDD_cfg(VDD_cfg),
		.VDD(VDD),
		.VSS(VSS),
		.TMO()
	);
endmodule
