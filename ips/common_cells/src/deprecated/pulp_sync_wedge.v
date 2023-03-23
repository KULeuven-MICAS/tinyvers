module pulp_sync_wedge (
	clk_i,
	rstn_i,
	en_i,
	serial_i,
	r_edge_o,
	f_edge_o,
	serial_o
);
	parameter [31:0] STAGES = 2;
	input wire clk_i;
	input wire rstn_i;
	input wire en_i;
	input wire serial_i;
	output wire r_edge_o;
	output wire f_edge_o;
	output wire serial_o;
	wire clk;
	wire serial;
	reg serial_q;
	assign serial_o = serial_q;
	assign f_edge_o = ~serial & serial_q;
	assign r_edge_o = serial & ~serial_q;
	pulp_sync #(.STAGES(STAGES)) i_pulp_sync(
		.clk_i(clk_i),
		.rstn_i(rstn_i),
		.serial_i(serial_i),
		.serial_o(serial)
	);
	pulp_clock_gating i_pulp_clock_gating(
		.clk_i(clk_i),
		.en_i(en_i),
		.test_en_i(1'b0),
		.clk_o(clk)
	);
	always @(posedge clk or negedge rstn_i)
		if (!rstn_i)
			serial_q <= 1'b0;
		else
			serial_q <= serial;
endmodule
