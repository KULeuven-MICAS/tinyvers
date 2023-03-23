module rstgen (
	clk_i,
	rst_ni,
	test_mode_i,
	rst_no,
	init_no
);
	input wire clk_i;
	input wire rst_ni;
	input wire test_mode_i;
	output wire rst_no;
	output wire init_no;
	rstgen_bypass i_rstgen_bypass(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.rst_test_mode_ni(rst_ni),
		.test_mode_i(test_mode_i),
		.rst_no(rst_no),
		.init_no(init_no)
	);
endmodule
