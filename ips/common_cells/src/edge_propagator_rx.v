module edge_propagator_rx (
	clk_i,
	rstn_i,
	valid_i,
	ack_o,
	valid_o
);
	input wire clk_i;
	input wire rstn_i;
	input wire valid_i;
	output wire ack_o;
	output wire valid_o;
	pulp_sync_wedge i_sync_clkb(
		.clk_i(clk_i),
		.rstn_i(rstn_i),
		.en_i(1'b1),
		.serial_i(valid_i),
		.r_edge_o(valid_o),
		.f_edge_o(),
		.serial_o(ack_o)
	);
endmodule
