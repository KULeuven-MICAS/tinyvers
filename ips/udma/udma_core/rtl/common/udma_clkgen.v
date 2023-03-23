module udma_clkgen (
	clk_i,
	rstn_i,
	dft_test_mode_i,
	dft_cg_enable_i,
	clock_enable_i,
	clk_div_data_i,
	clk_div_valid_i,
	clk_div_ack_o,
	clk_o
);
	input wire clk_i;
	input wire rstn_i;
	input wire dft_test_mode_i;
	input wire dft_cg_enable_i;
	input wire clock_enable_i;
	input wire [7:0] clk_div_data_i;
	input wire clk_div_valid_i;
	output wire clk_div_ack_o;
	output wire clk_o;
	reg [1:0] state;
	reg [1:0] state_next;
	wire s_clk_out;
	wire s_clk_out_dft;
	reg s_clock_enable;
	wire s_clock_enable_gate;
	reg s_clk_div_valid;
	reg [7:0] reg_clk_div;
	wire s_clk_div_valid_sync;
	reg r_clockdiv_en;
	reg s_clockdiv_en;
	reg r_clockout_mux;
	reg s_clockout_mux;
	wire s_clk_out_div;
	assign s_clock_enable_gate = s_clock_enable & clock_enable_i;
	pulp_sync_wedge i_edge_prop(
		.clk_i(clk_i),
		.rstn_i(rstn_i),
		.en_i(1'b1),
		.serial_i(clk_div_valid_i),
		.serial_o(clk_div_ack_o),
		.r_edge_o(s_clk_div_valid_sync),
		.f_edge_o()
	);
	udma_clk_div_cnt i_clkdiv_cnt(
		.clk_i(clk_i),
		.rstn_i(rstn_i),
		.en_i(r_clockdiv_en),
		.clk_div_i(reg_clk_div),
		.clk_div_valid_i(s_clk_div_valid),
		.clk_o(s_clk_out_div)
	);
	pulp_clock_mux2 clk_mux_i(
		.clk0_i(s_clk_out_div),
		.clk1_i(clk_i),
		.clk_sel_i(r_clockout_mux),
		.clk_o(s_clk_out)
	);
	assign s_clk_out_dft = s_clk_out;
	pulp_clock_gating i_clk_gate(
		.clk_i(s_clk_out_dft),
		.en_i(s_clock_enable_gate),
		.test_en_i(dft_cg_enable_i),
		.clk_o(clk_o)
	);
	always @(*) begin
		s_clockout_mux = r_clockout_mux;
		s_clockdiv_en = r_clockdiv_en;
		case (state)
			2'd0: begin
				s_clock_enable = 1'b1;
				s_clockdiv_en = 1'b1;
				s_clk_div_valid = 1'b0;
				if (s_clk_div_valid_sync)
					state_next = 2'd1;
				else
					state_next = 2'd0;
			end
			2'd1: begin
				s_clock_enable = 1'b0;
				if (reg_clk_div == 0) begin
					s_clk_div_valid = 1'b0;
					s_clockout_mux = 1'b1;
				end
				else begin
					s_clk_div_valid = 1'b1;
					s_clockout_mux = 1'b0;
				end
				state_next = 2'd2;
			end
			2'd2: begin
				s_clock_enable = 1'b0;
				s_clk_div_valid = 1'b0;
				state_next = 2'd3;
			end
			2'd3: begin
				s_clock_enable = 1'b0;
				s_clk_div_valid = 1'b0;
				state_next = 2'd0;
			end
		endcase
	end
	always @(posedge clk_i or negedge rstn_i)
		if (!rstn_i)
			state <= 2'd0;
		else
			state <= state_next;
	always @(posedge clk_i or negedge rstn_i)
		if (!rstn_i) begin
			r_clockout_mux <= 1;
			r_clockdiv_en <= 0;
		end
		else begin
			r_clockout_mux <= s_clockout_mux;
			r_clockdiv_en <= s_clockdiv_en;
		end
	always @(posedge clk_i or negedge rstn_i)
		if (!rstn_i)
			reg_clk_div <= 1'sb0;
		else if (s_clk_div_valid_sync)
			reg_clk_div <= clk_div_data_i;
endmodule
