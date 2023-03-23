module cic_integrator (
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
	reg [(4 * WIDTH) - 1:0] r_accumulator;
	wire [WIDTH - 1:0] s_sum;
	wire [WIDTH - 1:0] s_mux;
	assign s_mux = r_accumulator[sel_i * WIDTH+:WIDTH];
	assign s_sum = s_mux + data_i;
	always @(posedge clk_i or negedge rstn_i)
		if (~rstn_i) begin
			r_accumulator[0+:WIDTH] <= 'h0;
			r_accumulator[WIDTH+:WIDTH] <= 'h0;
			r_accumulator[2 * WIDTH+:WIDTH] <= 'h0;
			r_accumulator[3 * WIDTH+:WIDTH] <= 'h0;
		end
		else if (clr_i) begin
			r_accumulator[0+:WIDTH] <= 'h0;
			r_accumulator[WIDTH+:WIDTH] <= 'h0;
			r_accumulator[2 * WIDTH+:WIDTH] <= 'h0;
			r_accumulator[3 * WIDTH+:WIDTH] <= 'h0;
		end
		else if (en_i)
			r_accumulator[sel_i * WIDTH+:WIDTH] <= s_sum;
endmodule
