module clk_div (
	clk_i,
	rst_ni,
	testmode_i,
	en_i,
	clk_o
);
	parameter [31:0] RATIO = 4;
	input wire clk_i;
	input wire rst_ni;
	input wire testmode_i;
	input wire en_i;
	output wire clk_o;
	reg [RATIO - 1:0] counter_q;
	reg clk_q;
	always @(posedge clk_i or negedge rst_ni)
		if (~rst_ni) begin
			clk_q <= 1'b0;
			counter_q <= 1'sb0;
		end
		else begin
			clk_q <= 1'b0;
			if (en_i)
				if (counter_q == (RATIO[RATIO - 1:0] - 1))
					clk_q <= 1'b1;
				else
					counter_q <= counter_q + 1;
		end
	assign clk_o = (testmode_i ? clk_i : clk_q);
endmodule
