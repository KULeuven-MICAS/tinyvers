module pulp_clock_and2 (
	clk0_i,
	clk1_i,
	clk_o
);
	input wire clk0_i;
	input wire clk1_i;
	output wire clk_o;
	assign clk_o = clk0_i & clk1_i;
endmodule
module pulp_clock_buffer (
	clk_i,
	clk_o
);
	input wire clk_i;
	output wire clk_o;
	assign clk_o = clk_i;
endmodule
module pulp_clock_gating_8t (
	clk_i,
	en_i,
	test_en_i,
	clk_o
);
	input wire clk_i;
	input wire en_i;
	input wire test_en_i;
	output wire clk_o;
	SC8T_CKGPRELATNX4_DDC32UH cg_pulp(
		.E(en_i),
		.CLK(clk_i),
		.TE(test_en_i),
		.Z(clk_o)
	);
endmodule
module pulp_clock_gating (
	clk_i,
	en_i,
	test_en_i,
	clk_o
);
	input wire clk_i;
	input wire en_i;
	input wire test_en_i;
	output wire clk_o;
	SC7P5T_CKGPRELATNX1_CSC28L cg_pulp(
		.E(en_i),
		.CLK(clk_i),
		.TE(test_en_i),
		.Z(clk_o)
	);
endmodule
module pulp_clock_inverter (
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
	SC7P5T_CKMUX2X4_CSC28L clk_mux_i(
		.Z(clk_o),
		.CLK1(clk0_i),
		.CLK2(clk1_i),
		.CLKSEL(clk_sel_i)
	);
endmodule
module pulp_clock_xor2 (
	clk0_i,
	clk1_i,
	clk_o
);
	input wire clk0_i;
	input wire clk1_i;
	output wire clk_o;
	assign clk_o = clk0_i ^ clk1_i;
endmodule
module pulp_clock_delay (
	in_i,
	out_o
);
	input wire in_i;
	output wire out_o;
	assign #(300ps) out_o = in_i;
endmodule
