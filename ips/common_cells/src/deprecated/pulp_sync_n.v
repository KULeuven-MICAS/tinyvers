module pulp_sync_n (
	clk_i,
	serial_i,
	serial_o
);
	parameter STAGES = 2;
	input wire clk_i;
	input wire serial_i;
	output wire serial_o;
	reg [STAGES - 1:0] r_reg;
	wire clk_int;
	assign clk_int = !clk_i;
	always @(posedge clk_int) r_reg <= {r_reg[STAGES - 2:0], serial_i};
	assign serial_o = r_reg[STAGES - 1];
endmodule
