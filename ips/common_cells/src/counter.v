module counter (
	clk_i,
	rst_ni,
	clear_i,
	en_i,
	load_i,
	down_i,
	d_i,
	q_o,
	overflow_o
);
	parameter [31:0] WIDTH = 4;
	input wire clk_i;
	input wire rst_ni;
	input wire clear_i;
	input wire en_i;
	input wire load_i;
	input wire down_i;
	input wire [WIDTH - 1:0] d_i;
	output wire [WIDTH - 1:0] q_o;
	output wire overflow_o;
	reg [WIDTH:0] counter_q;
	reg [WIDTH:0] counter_d;
	assign overflow_o = counter_q[WIDTH];
	assign q_o = counter_q[WIDTH - 1:0];
	always @(*) begin
		counter_d = counter_q;
		if (clear_i)
			counter_d = 1'sb0;
		else if (load_i)
			counter_d = {1'b0, d_i};
		else if (en_i)
			if (down_i)
				counter_d = counter_q - 1;
			else
				counter_d = counter_q + 1;
	end
	always @(posedge clk_i or negedge rst_ni)
		if (~rst_ni)
			counter_q <= 1'sb0;
		else
			counter_q <= counter_d;
endmodule
