module pulp_clock_gating_async (
	clk_i,
	rstn_i,
	en_async_i,
	en_ack_o,
	test_en_i,
	clk_o
);
	parameter [31:0] STAGES = 2;
	input wire clk_i;
	input wire rstn_i;
	input wire en_async_i;
	output wire en_ack_o;
	input wire test_en_i;
	output wire clk_o;
	reg [STAGES - 1:0] r_reg;
	assign en_ack_o = r_reg[STAGES - 1];
	always @(posedge clk_i or negedge rstn_i)
		if (!rstn_i)
			r_reg <= 1'sb0;
		else
			r_reg <= {r_reg[STAGES - 2:0], en_async_i};
	pulp_clock_gating i_clk_gate(
		.clk_i(clk_i),
		.en_i(r_reg[STAGES - 1]),
		.test_en_i(test_en_i),
		.clk_o(clk_o)
	);
endmodule
