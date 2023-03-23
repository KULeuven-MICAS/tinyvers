module cic_comb (
	clk_i,
	rstn_i,
	en_i,
	clr_i,
	sel_i,
	data_i,
	data_o
);
	parameter WIDTH = 64;
	input wire clk_i;
	input wire rstn_i;
	input wire en_i;
	input wire clr_i;
	input wire [1:0] sel_i;
	input wire [WIDTH - 1:0] data_i;
	output wire [WIDTH - 1:0] data_o;
	reg [(4 * WIDTH) - 1:0] r_previousdata;
	reg [(4 * WIDTH) - 1:0] r_data;
	wire [WIDTH - 1:0] s_sum;
	assign s_sum = data_i - r_previousdata[sel_i * WIDTH+:WIDTH];
	always @(posedge clk_i or negedge rstn_i)
		if (~rstn_i) begin
			r_previousdata[0+:WIDTH] <= 'h0;
			r_previousdata[WIDTH+:WIDTH] <= 'h0;
			r_previousdata[2 * WIDTH+:WIDTH] <= 'h0;
			r_previousdata[3 * WIDTH+:WIDTH] <= 'h0;
			r_data[0+:WIDTH] <= 'h0;
			r_data[WIDTH+:WIDTH] <= 'h0;
			r_data[2 * WIDTH+:WIDTH] <= 'h0;
			r_data[3 * WIDTH+:WIDTH] <= 'h0;
		end
		else if (clr_i) begin
			r_previousdata[0+:WIDTH] <= 'h0;
			r_previousdata[WIDTH+:WIDTH] <= 'h0;
			r_previousdata[2 * WIDTH+:WIDTH] <= 'h0;
			r_previousdata[3 * WIDTH+:WIDTH] <= 'h0;
			r_data[0+:WIDTH] <= 'h0;
			r_data[WIDTH+:WIDTH] <= 'h0;
			r_data[2 * WIDTH+:WIDTH] <= 'h0;
			r_data[3 * WIDTH+:WIDTH] <= 'h0;
		end
		else if (en_i) begin
			r_data[sel_i * WIDTH+:WIDTH] <= s_sum;
			r_previousdata[sel_i * WIDTH+:WIDTH] <= data_i;
		end
	assign data_o = 1'sb0;
endmodule
