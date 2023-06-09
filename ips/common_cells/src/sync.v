module sync (
	clk_i,
	rst_ni,
	serial_i,
	serial_o
);
	parameter [31:0] STAGES = 2;
	input wire clk_i;
	input wire rst_ni;
	input wire serial_i;
	output wire serial_o;
	reg [STAGES - 1:0] reg_q;
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni)
			reg_q <= 'h0;
		else
			reg_q <= {reg_q[STAGES - 2:0], serial_i};
	assign serial_o = reg_q[STAGES - 1];
endmodule
