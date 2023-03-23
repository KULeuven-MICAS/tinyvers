module jtag_tap_top (
	tck_i,
	trst_ni,
	tms_i,
	td_i,
	td_o,
	test_clk_i,
	test_rstn_i,
	soc_jtag_reg_i,
	soc_jtag_reg_o,
	sel_fll_clk_o,
	jtag_shift_dr_o,
	jtag_update_dr_o,
	jtag_capture_dr_o,
	axireg_sel_o,
	dbg_axi_scan_in_o,
	dbg_axi_scan_out_i
);
	input wire tck_i;
	input wire trst_ni;
	input wire tms_i;
	input wire td_i;
	output wire td_o;
	input wire test_clk_i;
	input wire test_rstn_i;
	input wire [7:0] soc_jtag_reg_i;
	output wire [7:0] soc_jtag_reg_o;
	output wire sel_fll_clk_o;
	output wire jtag_shift_dr_o;
	output wire jtag_update_dr_o;
	output wire jtag_capture_dr_o;
	output wire axireg_sel_o;
	output wire dbg_axi_scan_in_o;
	input wire dbg_axi_scan_out_i;
	wire s_scan_i;
	wire [8:0] s_confreg;
	wire confscan;
	wire confreg_sel;
	wire td_o_int;
	reg [7:0] r_soc_reg0;
	reg [7:0] r_soc_reg1;
	wire [7:0] s_soc_jtag_reg_sync;
	tap_top tap_top_i(
		.tms_i(tms_i),
		.tck_i(tck_i),
		.rst_ni(trst_ni),
		.td_i(td_i),
		.td_o(td_o),
		.shift_dr_o(jtag_shift_dr_o),
		.update_dr_o(jtag_update_dr_o),
		.capture_dr_o(jtag_capture_dr_o),
		.memory_sel_o(axireg_sel_o),
		.fifo_sel_o(),
		.confreg_sel_o(confreg_sel),
		.scan_in_o(s_scan_i),
		.memory_out_i(dbg_axi_scan_out_i),
		.fifo_out_i(1'b0),
		.confreg_out_i(confscan)
	);
	jtagreg #(
		.JTAGREGSIZE(9),
		.SYNC(0)
	) confreg(
		.clk_i(tck_i),
		.rst_ni(trst_ni),
		.enable_i(confreg_sel),
		.capture_dr_i(jtag_capture_dr_o),
		.shift_dr_i(jtag_shift_dr_o),
		.update_dr_i(jtag_update_dr_o),
		.jtagreg_in_i({1'b0, s_soc_jtag_reg_sync}),
		.mode_i(1'b1),
		.scan_in_i(s_scan_i),
		.jtagreg_out_o(s_confreg),
		.scan_out_o(confscan)
	);
	always @(posedge tck_i or negedge trst_ni)
		if (~trst_ni) begin
			r_soc_reg0 <= 0;
			r_soc_reg1 <= 0;
		end
		else begin
			r_soc_reg1 <= soc_jtag_reg_i;
			r_soc_reg0 <= r_soc_reg1;
		end
	assign s_soc_jtag_reg_sync = r_soc_reg0;
	assign dbg_axi_scan_in_o = s_scan_i;
	assign soc_jtag_reg_o = s_confreg[7:0];
	assign sel_fll_clk_o = s_confreg[8];
endmodule
