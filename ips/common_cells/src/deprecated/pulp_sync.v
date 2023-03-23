module pulp_sync (
	clk_i,
	rstn_i,
	serial_i,
	serial_o
);
	parameter STAGES = 2;
	input wire clk_i;
	input wire rstn_i;
	input wire serial_i;
	output wire serial_o;
	reg [STAGES - 1:0] r_reg;
	always @(posedge clk_i or negedge rstn_i)
		if (!rstn_i)
			r_reg <= 'h0;
		else
			r_reg <= {r_reg[STAGES - 2:0], serial_i};
	assign serial_o = r_reg[STAGES - 1];
endmodule
