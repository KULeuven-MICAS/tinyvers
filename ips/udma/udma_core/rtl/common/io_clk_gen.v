module io_clk_gen (
	clk_i,
	rstn_i,
	en_i,
	clk_div_i,
	clk_o,
	fall_o,
	rise_o
);
	parameter COUNTER_WIDTH = 11;
	input wire clk_i;
	input wire rstn_i;
	input wire en_i;
	input wire [COUNTER_WIDTH - 1:0] clk_div_i;
	output reg clk_o;
	output reg fall_o;
	output reg rise_o;
	reg [COUNTER_WIDTH - 1:0] counter;
	reg [COUNTER_WIDTH - 1:0] counter_next;
	reg clk_o_next;
	reg running;
	always @(*) begin
		rise_o = 1'b0;
		fall_o = 1'b0;
		if (counter == clk_div_i) begin
			counter_next = 0;
			clk_o_next = ~clk_o;
			if (clk_o == 1'b0)
				rise_o = running;
			else
				fall_o = running;
		end
		else begin
			counter_next = counter + 1;
			clk_o_next = clk_o;
		end
	end
	always @(posedge clk_i or negedge rstn_i)
		if (rstn_i == 1'b0) begin
			clk_o <= 1'b0;
			counter <= 'h0;
			running <= 1'b0;
		end
		else if (!((clk_o == 1'b0) && ~en_i)) begin
			running <= 1'b1;
			clk_o <= clk_o_next;
			counter <= counter_next;
		end
		else
			running <= 1'b0;
endmodule
