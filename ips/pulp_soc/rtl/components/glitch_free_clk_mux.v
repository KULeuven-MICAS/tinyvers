module glitch_free_clk_mux (
	select_i,
	test_mode_i,
	clk_selected_o,
	clk0_i,
	rstn0_i,
	clk1_i,
	rstn1_i,
	clk_out_o
);
	input wire select_i;
	input wire test_mode_i;
	output wire clk_selected_o;
	input wire clk0_i;
	input wire rstn0_i;
	input wire clk1_i;
	input wire rstn1_i;
	output wire clk_out_o;
	reg [2:0] r_sync0;
	reg [2:0] r_sync1;
	wire s_en0;
	wire s_en1;
	wire s_clk0;
	wire s_clk1;
	assign clk_selected_o = ~r_sync1[2] & r_sync0[2];
	assign s_en0 = ~select_i & ~r_sync1[2];
	assign s_en1 = select_i & ~r_sync0[2];
	always @(posedge clk0_i or negedge rstn0_i)
		if (~rstn0_i)
			r_sync0 <= 0;
		else
			r_sync0 <= {r_sync0[1:0], s_en0};
	always @(posedge clk1_i or negedge rstn1_i)
		if (~rstn1_i)
			r_sync1 <= 0;
		else
			r_sync1 <= {r_sync1[1:0], s_en1};
	pulp_clock_xor2 u_xorout(
		.clk0_i(s_clk0),
		.clk1_i(s_clk1),
		.clk_o(clk_out_o)
	);
	pulp_clock_gating u_clkgate0(
		.clk_i(clk0_i),
		.en_i(r_sync0[1]),
		.test_en_i(test_mode_i),
		.clk_o(s_clk0)
	);
	pulp_clock_gating u_clkgate1(
		.clk_i(clk1_i),
		.en_i(r_sync1[1]),
		.test_en_i(test_mode_i),
		.clk_o(s_clk1)
	);
endmodule
