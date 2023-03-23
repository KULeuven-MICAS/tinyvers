module pulpemu_clk_gating (
	pulp_cluster_clk,
	pulp_soc_rst_n,
	pulp_cluster_clk_enable,
	pulp_cluster_clk_gated
);
	input wire pulp_cluster_clk;
	input wire pulp_soc_rst_n;
	input wire pulp_cluster_clk_enable;
	output wire pulp_cluster_clk_gated;
	reg s_en_int;
	always @(posedge pulp_cluster_clk) s_en_int = pulp_cluster_clk_enable;
	BUFGCE bufgce_i(
		.I(pulp_cluster_clk),
		.CE(s_en_int),
		.O(pulp_cluster_clk_gated)
	);
endmodule
