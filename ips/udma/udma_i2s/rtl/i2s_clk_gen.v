module i2s_clk_gen (
	clk_i,
	rstn_i,
	test_mode_i,
	sck_o,
	cfg_clk_en_i,
	cfg_clk_en_o,
	cfg_div_i
);
	input wire clk_i;
	input wire rstn_i;
	input wire test_mode_i;
	output wire sck_o;
	input wire cfg_clk_en_i;
	output wire cfg_clk_en_o;
	input wire [15:0] cfg_div_i;
	reg [15:0] r_counter;
	reg r_clk;
	reg [15:0] r_sampled_config;
	reg r_clock_en;
	assign cfg_clk_en_o = r_clock_en;
	always @(posedge clk_i or negedge rstn_i)
		if (rstn_i == 1'b0) begin
			r_counter <= 'h0;
			r_sampled_config <= 'h0;
			r_clk <= 1'b0;
			r_clock_en <= 1'b0;
		end
		else if (cfg_clk_en_i && !r_clock_en) begin
			r_clock_en <= 1'b1;
			r_sampled_config <= cfg_div_i;
		end
		else if (!cfg_clk_en_i) begin
			if (!r_clk) begin
				r_counter <= 'h0;
				r_clock_en <= 1'b0;
			end
			else if (r_counter == r_sampled_config) begin
				r_sampled_config <= cfg_div_i;
				r_counter <= 'h0;
				r_clk <= 'h0;
			end
			else
				r_counter <= r_counter + 1;
		end
		else if (r_counter == r_sampled_config) begin
			r_counter <= 'h0;
			r_sampled_config <= cfg_div_i;
			r_clk <= ~r_clk;
		end
		else
			r_counter <= r_counter + 1;
	assign sck_o = r_clk;
endmodule
