module tc_clk_and2 (
	clk0_i,
	clk1_i,
	clk_o
);
	input wire clk0_i;
	input wire clk1_i;
	output wire clk_o;
	assign clk_o = clk0_i & clk1_i;
endmodule
module tc_clk_buffer (
	clk_i,
	clk_o
);
	input wire clk_i;
	output wire clk_o;
	assign clk_o = clk_i;
endmodule
module tc_clk_gating (
	clk_i,
	en_i,
	test_en_i,
	clk_o
);
	input wire clk_i;
	input wire en_i;
	input wire test_en_i;
	output wire clk_o;
	reg clk_en;
	always @(*)
		if (clk_i == 1'b0)
			clk_en <= en_i | test_en_i;
	assign clk_o = clk_i & clk_en;
endmodule
module tc_clk_inverter (
	clk_i,
	clk_o
);
	input wire clk_i;
	output wire clk_o;
	assign clk_o = ~clk_i;
endmodule
module tc_clk_mux2 (
	clk0_i,
	clk1_i,
	clk_sel_i,
	clk_o
);
	input wire clk0_i;
	input wire clk1_i;
	input wire clk_sel_i;
	output wire clk_o;
	assign clk_o = (clk_sel_i ? clk1_i : clk0_i);
endmodule
module tc_clk_xor2 (
	clk0_i,
	clk1_i,
	clk_o
);
	input wire clk0_i;
	input wire clk1_i;
	output wire clk_o;
	assign clk_o = clk0_i ^ clk1_i;
endmodule
module tc_clk_delay (
	in_i,
	out_o
);
	parameter [31:0] Delay = 300ps;
	input wire in_i;
	output wire out_o;
	assign #(Delay) out_o = in_i;
endmodule
