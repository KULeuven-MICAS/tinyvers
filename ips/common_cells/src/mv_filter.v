module mv_filter (
	clk_i,
	rst_ni,
	sample_i,
	clear_i,
	d_i,
	q_o
);
	parameter [31:0] WIDTH = 4;
	parameter [31:0] THRESHOLD = 10;
	input wire clk_i;
	input wire rst_ni;
	input wire sample_i;
	input wire clear_i;
	input wire d_i;
	output wire q_o;
	reg [WIDTH - 1:0] counter_q;
	reg [WIDTH - 1:0] counter_d;
	reg d;
	reg q;
	assign q_o = q;
	always @(*) begin
		counter_d = counter_q;
		d = q;
		if (counter_q >= THRESHOLD[WIDTH - 1:0])
			d = 1'b1;
		else if (sample_i && d_i)
			counter_d = counter_q + 1;
		if (clear_i) begin
			counter_d = 1'sb0;
			d = 1'b0;
		end
	end
	always @(posedge clk_i or negedge rst_ni)
		if (~rst_ni) begin
			counter_q <= 1'sb0;
			q <= 1'b0;
		end
		else begin
			counter_q <= counter_d;
			q <= d;
		end
endmodule
