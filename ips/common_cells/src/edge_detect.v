module edge_detect (
	clk_i,
	rst_ni,
	d_i,
	re_o,
	fe_o
);
	input wire clk_i;
	input wire rst_ni;
	input wire d_i;
	output wire re_o;
	output wire fe_o;
	sync_wedge i_sync_wedge(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.en_i(1'b1),
		.serial_i(d_i),
		.r_edge_o(re_o),
		.f_edge_o(fe_o),
		.serial_o()
	);
endmodule
