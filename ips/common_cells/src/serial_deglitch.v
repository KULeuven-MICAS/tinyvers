module serial_deglitch (
	clk_i,
	rst_ni,
	en_i,
	d_i,
	q_o
);
	parameter [31:0] SIZE = 4;
	input wire clk_i;
	input wire rst_ni;
	input wire en_i;
	input wire d_i;
	output reg q_o;
	reg [SIZE - 1:0] count_q;
	reg q;
	always @(posedge clk_i or negedge rst_ni)
		if (~rst_ni) begin
			count_q <= 1'sb0;
			q <= 1'b0;
		end
		else if (en_i)
			if ((d_i == 1'b1) && (count_q != SIZE[SIZE - 1:0]))
				count_q <= count_q + 1;
			else if ((d_i == 1'b0) && (count_q != SIZE[SIZE - 1:0]))
				count_q <= count_q - 1;
	always @(*)
		if (count_q == SIZE[SIZE - 1:0])
			q_o = 1'b1;
		else if (count_q == 0)
			q_o = 1'b0;
endmodule
