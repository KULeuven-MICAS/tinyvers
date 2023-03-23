module jtagreg (
	clk_i,
	rst_ni,
	enable_i,
	capture_dr_i,
	shift_dr_i,
	update_dr_i,
	jtagreg_in_i,
	mode_i,
	scan_in_i,
	scan_out_o,
	jtagreg_out_o
);
	parameter JTAGREGSIZE = 96;
	parameter SYNC = 1;
	input wire clk_i;
	input wire rst_ni;
	input wire enable_i;
	input wire capture_dr_i;
	input wire shift_dr_i;
	input wire update_dr_i;
	input wire [JTAGREGSIZE - 1:0] jtagreg_in_i;
	input wire mode_i;
	input wire scan_in_i;
	output wire scan_out_o;
	output wire [JTAGREGSIZE - 1:0] jtagreg_out_o;
	wire [JTAGREGSIZE - 2:0] s_scanbit;
	wire scan_in_syn;
	bscell reg_bit_last(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.mode_i(mode_i),
		.enable_i(enable_i),
		.shift_dr_i(shift_dr_i),
		.capture_dr_i(capture_dr_i),
		.update_dr_i(update_dr_i),
		.scan_in_i(scan_in_syn),
		.jtagreg_in_i(jtagreg_in_i[JTAGREGSIZE - 1]),
		.scan_out_o(s_scanbit[0]),
		.jtagreg_out_o(jtagreg_out_o[JTAGREGSIZE - 1])
	);
	genvar i;
	generate
		for (i = 1; i < (JTAGREGSIZE - 1); i = i + 1) begin : genblk1
			bscell reg_bit_mid(
				.clk_i(clk_i),
				.rst_ni(rst_ni),
				.mode_i(mode_i),
				.enable_i(enable_i),
				.shift_dr_i(shift_dr_i),
				.capture_dr_i(capture_dr_i),
				.update_dr_i(update_dr_i),
				.scan_in_i(s_scanbit[i - 1]),
				.jtagreg_in_i(jtagreg_in_i[(JTAGREGSIZE - 1) - i]),
				.scan_out_o(s_scanbit[i]),
				.jtagreg_out_o(jtagreg_out_o[(JTAGREGSIZE - 1) - i])
			);
		end
	endgenerate
	bscell reg_bit0(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.mode_i(mode_i),
		.enable_i(enable_i),
		.shift_dr_i(shift_dr_i),
		.capture_dr_i(capture_dr_i),
		.update_dr_i(update_dr_i),
		.scan_in_i(s_scanbit[JTAGREGSIZE - 2]),
		.jtagreg_in_i(jtagreg_in_i[0]),
		.scan_out_o(scan_out_o),
		.jtagreg_out_o(jtagreg_out_o[0])
	);
	generate
		if (SYNC == 1) begin : JTAG_SYNC
			jtag_sync jtag_sync_scanin(
				.clk_i(clk_i),
				.rst_ni(rst_ni),
				.tosynch(scan_in_i),
				.synched(scan_in_syn)
			);
		end
		else begin : JTAG_NO_SYNC
			assign scan_in_syn = scan_in_i;
		end
	endgenerate
endmodule
