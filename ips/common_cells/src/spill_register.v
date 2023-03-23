module spill_register (
	clk_i,
	rst_ni,
	valid_i,
	ready_o,
	data_i,
	valid_o,
	ready_i,
	data_o
);
	input wire clk_i;
	input wire rst_ni;
	input wire valid_i;
	output wire ready_o;
	input wire data_i;
	output wire valid_o;
	input wire ready_i;
	output wire data_o;
	reg a_data_q;
	reg a_full_q;
	wire a_fill;
	wire a_drain;
	wire a_en;
	wire a_en_data;
	always @(posedge clk_i or negedge rst_ni) begin : ps_a_data
		if (!rst_ni)
			a_data_q <= 1'sb0;
		else if (a_fill)
			a_data_q <= data_i;
	end
	always @(posedge clk_i or negedge rst_ni) begin : ps_a_full
		if (!rst_ni)
			a_full_q <= 0;
		else if (a_fill || a_drain)
			a_full_q <= a_fill;
	end
	reg b_data_q;
	reg b_full_q;
	wire b_fill;
	wire b_drain;
	always @(posedge clk_i or negedge rst_ni) begin : ps_b_data
		if (!rst_ni)
			b_data_q <= 1'sb0;
		else if (b_fill)
			b_data_q <= a_data_q;
	end
	always @(posedge clk_i or negedge rst_ni) begin : ps_b_full
		if (!rst_ni)
			b_full_q <= 0;
		else if (b_fill || b_drain)
			b_full_q <= b_fill;
	end
	assign a_fill = valid_i && ready_o;
	assign a_drain = a_full_q && !b_full_q;
	assign b_fill = a_drain && !ready_i;
	assign b_drain = b_full_q && ready_i;
	assign ready_o = !a_full_q || !b_full_q;
	assign valid_o = a_full_q | b_full_q;
	assign data_o = (b_full_q ? b_data_q : a_data_q);
endmodule
