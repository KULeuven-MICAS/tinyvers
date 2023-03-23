module cluster_clock_and2 (
	clk0_i,
	clk1_i,
	clk_o
);
	input wire clk0_i;
	input wire clk1_i;
	output wire clk_o;
	assign clk_o = clk0_i & clk1_i;
endmodule
module cluster_clock_buffer (
	clk_i,
	clk_o
);
	input wire clk_i;
	output wire clk_o;
	assign clk_o = clk_i;
endmodule
module cluster_clock_gating (
	clk_i,
	en_i,
	test_en_i,
	clk_o
);
	input wire clk_i;
	input wire en_i;
	input wire test_en_i;
	output wire clk_o;
	assign clk_o = clk_i;
endmodule
module cluster_clock_inverter (
	clk_i,
	clk_o
);
	input wire clk_i;
	output wire clk_o;
	assign clk_o = ~clk_i;
endmodule
module pulp_clock_mux2 (
	clk0_i,
	clk1_i,
	clk_sel_i,
	clk_o
);
	input wire clk0_i;
	input wire clk1_i;
	input wire clk_sel_i;
	output wire clk_o;
	BUFGMUX i_BUFGMUX(
		.S(clk_sel_i),
		.I0(clk0_i),
		.I1(clk1_i),
		.O(clk_o)
	);
endmodule
module cluster_clock_xor2 (
	clk0_i,
	clk1_i,
	clk_o
);
	input wire clk0_i;
	input wire clk1_i;
	output wire clk_o;
	assign clk_o = clk0_i ^ clk1_i;
endmodule
