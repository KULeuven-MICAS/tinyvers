module edge_propagator (
	clk_tx_i,
	rstn_tx_i,
	edge_i,
	clk_rx_i,
	rstn_rx_i,
	edge_o
);
	input wire clk_tx_i;
	input wire rstn_tx_i;
	input wire edge_i;
	input wire clk_rx_i;
	input wire rstn_rx_i;
	output wire edge_o;
	reg [1:0] sync_a;
	wire sync_b;
	reg r_input_reg;
	wire s_input_reg_next;
	assign s_input_reg_next = edge_i | (r_input_reg & ~sync_a[0]);
	always @(negedge rstn_tx_i or posedge clk_tx_i)
		if (~rstn_tx_i) begin
			r_input_reg <= 1'b0;
			sync_a <= 2'b00;
		end
		else begin
			r_input_reg <= s_input_reg_next;
			sync_a <= {sync_b, sync_a[1]};
		end
	pulp_sync_wedge i_sync_clkb(
		.clk_i(clk_rx_i),
		.rstn_i(rstn_rx_i),
		.en_i(1'b1),
		.serial_i(r_input_reg),
		.r_edge_o(edge_o),
		.f_edge_o(),
		.serial_o(sync_b)
	);
endmodule
