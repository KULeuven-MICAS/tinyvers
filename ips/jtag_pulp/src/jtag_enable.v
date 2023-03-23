module jtag_enable (
	capture_syn_i,
	shift_syn_i,
	update_syn_i,
	enable_i,
	axireg_sel_syn_i,
	bbmuxreg_sel_syn_i,
	clkgatereg_sel_syn_i,
	confreg_sel_syn_i,
	axireg_capture_syn_o,
	axireg_shift_syn_o,
	axireg_update_syn_o,
	bbmuxreg_capture_syn_o,
	bbmuxreg_shift_syn_o,
	bbmuxreg_update_syn_o,
	clkgatereg_capture_syn_o,
	clkgatereg_shift_syn_o,
	clkgatereg_update_syn_o,
	confreg_capture_syn_o,
	confreg_shift_syn_o,
	confreg_update_syn_o,
	update_enable_o
);
	input wire capture_syn_i;
	input wire shift_syn_i;
	input wire update_syn_i;
	input wire enable_i;
	input wire axireg_sel_syn_i;
	input wire bbmuxreg_sel_syn_i;
	input wire clkgatereg_sel_syn_i;
	input wire confreg_sel_syn_i;
	output wire axireg_capture_syn_o;
	output wire axireg_shift_syn_o;
	output wire axireg_update_syn_o;
	output wire bbmuxreg_capture_syn_o;
	output wire bbmuxreg_shift_syn_o;
	output wire bbmuxreg_update_syn_o;
	output wire clkgatereg_capture_syn_o;
	output wire clkgatereg_shift_syn_o;
	output wire clkgatereg_update_syn_o;
	output wire confreg_capture_syn_o;
	output wire confreg_shift_syn_o;
	output wire confreg_update_syn_o;
	output wire update_enable_o;
	assign axireg_capture_syn_o = axireg_sel_syn_i & capture_syn_i;
	assign axireg_shift_syn_o = axireg_sel_syn_i & shift_syn_i;
	assign axireg_update_syn_o = axireg_sel_syn_i & update_syn_i;
	assign bbmuxreg_capture_syn_o = bbmuxreg_sel_syn_i & capture_syn_i;
	assign bbmuxreg_shift_syn_o = bbmuxreg_sel_syn_i & shift_syn_i;
	assign bbmuxreg_update_syn_o = bbmuxreg_sel_syn_i & update_syn_i;
	assign clkgatereg_capture_syn_o = clkgatereg_sel_syn_i & capture_syn_i;
	assign clkgatereg_shift_syn_o = clkgatereg_sel_syn_i & shift_syn_i;
	assign clkgatereg_update_syn_o = clkgatereg_sel_syn_i & update_syn_i;
	assign confreg_capture_syn_o = confreg_sel_syn_i & capture_syn_i;
	assign confreg_shift_syn_o = confreg_sel_syn_i & shift_syn_i;
	assign confreg_update_syn_o = confreg_sel_syn_i & update_syn_i;
	assign update_enable_o = enable_i & update_syn_i;
endmodule
