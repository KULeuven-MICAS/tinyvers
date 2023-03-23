module timer_unit_counter_presc (
	clk_i,
	rst_ni,
	write_counter_i,
	counter_value_i,
	reset_count_i,
	enable_count_i,
	compare_value_i,
	counter_value_o,
	target_reached_o
);
	input wire clk_i;
	input wire rst_ni;
	input wire write_counter_i;
	input wire [31:0] counter_value_i;
	input wire reset_count_i;
	input wire enable_count_i;
	input wire [31:0] compare_value_i;
	output wire [31:0] counter_value_o;
	output reg target_reached_o;
	reg [31:0] s_count;
	reg [31:0] s_count_reg;
	always @(*) begin
		s_count = s_count_reg;
		if ((reset_count_i == 1) || (target_reached_o == 1))
			s_count = 0;
		else if (write_counter_i == 1)
			s_count = counter_value_i;
		else if (enable_count_i == 1)
			s_count = s_count_reg + 1;
	end
	always @(posedge clk_i or negedge rst_ni)
		if (rst_ni == 0)
			s_count_reg <= 0;
		else
			s_count_reg <= s_count;
	always @(posedge clk_i or negedge rst_ni)
		if (rst_ni == 0)
			target_reached_o <= 1'b0;
		else if (s_count == compare_value_i)
			target_reached_o <= 1'b1;
		else
			target_reached_o <= 1'b0;
	assign counter_value_o = s_count_reg;
endmodule
