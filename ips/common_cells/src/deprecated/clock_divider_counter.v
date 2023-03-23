module clock_divider_counter (
	clk,
	rstn,
	test_mode,
	clk_div,
	clk_div_valid,
	clk_out
);
	parameter BYPASS_INIT = 1;
	parameter DIV_INIT = 'hff;
	input wire clk;
	input wire rstn;
	input wire test_mode;
	input wire [7:0] clk_div;
	input wire clk_div_valid;
	output wire clk_out;
	reg [7:0] counter;
	reg [7:0] counter_next;
	reg [7:0] clk_cnt;
	reg en1;
	reg en2;
	reg is_odd;
	reg div1;
	reg div2;
	wire div2_neg_sync;
	wire [7:0] clk_cnt_odd;
	wire [7:0] clk_cnt_odd_incr;
	wire [7:0] clk_cnt_even;
	wire [7:0] clk_cnt_en2;
	reg bypass;
	wire clk_out_gen;
	reg clk_div_valid_reg;
	wire clk_inv_test;
	wire clk_inv;
	assign clk_cnt_odd = clk_div - 8'h01;
	assign clk_cnt_even = (clk_div == 8'h02 ? 8'h00 : {1'b0, clk_div[7:1]} - 8'h01);
	assign clk_cnt_en2 = {1'b0, clk_cnt[7:1]} + 8'h01;
	always @(*) begin
		if (counter == 'h0)
			en1 = 1'b1;
		else
			en1 = 1'b0;
		if (clk_div_valid)
			counter_next = 'h0;
		else if (counter == clk_cnt)
			counter_next = 'h0;
		else
			counter_next = counter + 1;
		if (clk_div_valid)
			en2 = 1'b0;
		else if (counter == clk_cnt_en2)
			en2 = 1'b1;
		else
			en2 = 1'b0;
	end
	always @(posedge clk or negedge rstn)
		if (~rstn) begin
			counter <= 'h0;
			div1 <= 1'b0;
			bypass <= BYPASS_INIT;
			clk_cnt <= DIV_INIT;
			is_odd <= 1'b0;
			clk_div_valid_reg <= 1'b0;
		end
		else begin
			if (!bypass)
				counter <= counter_next;
			clk_div_valid_reg <= clk_div_valid;
			if (clk_div_valid) begin
				if ((clk_div == 8'h00) || (clk_div == 8'h01)) begin
					bypass <= 1'b1;
					clk_cnt <= 'h0;
					is_odd <= 1'b0;
				end
				else begin
					bypass <= 1'b0;
					if (clk_div[0]) begin
						is_odd <= 1'b1;
						clk_cnt <= clk_cnt_odd;
					end
					else begin
						is_odd <= 1'b0;
						clk_cnt <= clk_cnt_even;
					end
				end
				div1 <= 1'b0;
			end
			else if (en1 && !bypass)
				div1 <= ~div1;
		end
	pulp_clock_inverter clk_inv_i(
		.clk_i(clk),
		.clk_o(clk_inv)
	);
	assign clk_inv_test = clk_inv;
	always @(posedge clk_inv_test or negedge rstn)
		if (!rstn)
			div2 <= 1'b0;
		else if (clk_div_valid_reg)
			div2 <= 1'b0;
		else if ((en2 && is_odd) && !bypass)
			div2 <= ~div2;
	pulp_clock_xor2 clock_xor_i(
		.clk_o(clk_out_gen),
		.clk0_i(div1),
		.clk1_i(div2)
	);
	pulp_clock_mux2 clk_mux_i(
		.clk0_i(clk_out_gen),
		.clk1_i(clk),
		.clk_sel_i(bypass || test_mode),
		.clk_o(clk_out)
	);
endmodule
