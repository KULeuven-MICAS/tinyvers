module udma_clk_div_cnt (
	clk_i,
	rstn_i,
	en_i,
	clk_div_i,
	clk_div_valid_i,
	clk_o
);
	input wire clk_i;
	input wire rstn_i;
	input wire en_i;
	input wire [7:0] clk_div_i;
	input wire clk_div_valid_i;
	output reg clk_o;
	reg [7:0] r_counter;
	reg [7:0] r_target;
	always @(posedge clk_i or negedge rstn_i)
		if (~rstn_i) begin
			r_counter <= 'h0;
			r_target <= 'h0;
			clk_o <= 1'b0;
		end
		else if (clk_div_valid_i) begin
			r_target <= clk_div_i;
			r_counter <= 'h0;
			clk_o <= 1'b0;
		end
		else if (en_i)
			if (r_counter == (r_target - 1)) begin
				clk_o <= ~clk_o;
				r_counter <= 'h0;
			end
			else
				r_counter <= r_counter + 1;
endmodule
