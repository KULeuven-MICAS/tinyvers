module clock_divider (
	clk_i,
	rstn_i,
	test_mode_i,
	clk_gate_async_i,
	clk_div_data_i,
	clk_div_valid_i,
	clk_div_ack_o,
	clk_o
);
	parameter DIV_INIT = 0;
	parameter BYPASS_INIT = 1;
	input wire clk_i;
	input wire rstn_i;
	input wire test_mode_i;
	input wire clk_gate_async_i;
	input wire [7:0] clk_div_data_i;
	input wire clk_div_valid_i;
	output wire clk_div_ack_o;
	output wire clk_o;
	reg [1:0] state;
	reg [1:0] state_next;
	wire s_clk_out;
	reg s_clock_enable;
	wire s_clock_enable_gate;
	reg s_clk_div_valid;
	reg [7:0] reg_clk_div;
	wire s_clk_div_valid_sync;
	wire s_rstn_sync;
	reg [1:0] reg_ext_gate_sync;
	assign s_clock_enable_gate = s_clock_enable & reg_ext_gate_sync;
	rstgen i_rst_gen(
		.clk_i(clk_i),
		.rst_ni(rstn_i),
		.test_mode_i(test_mode_i),
		.rst_no(s_rstn_sync),
		.init_no()
	);
	pulp_sync_wedge i_edge_prop(
		.clk_i(clk_i),
		.rstn_i(s_rstn_sync),
		.en_i(1'b1),
		.serial_i(clk_div_valid_i),
		.serial_o(clk_div_ack_o),
		.r_edge_o(s_clk_div_valid_sync)
	);
	clock_divider_counter #(
		.BYPASS_INIT(BYPASS_INIT),
		.DIV_INIT(DIV_INIT)
	) i_clkdiv_cnt(
		.clk(clk_i),
		.rstn(s_rstn_sync),
		.test_mode(test_mode_i),
		.clk_div(reg_clk_div),
		.clk_div_valid(s_clk_div_valid),
		.clk_out(s_clk_out)
	);
	pulp_clock_gating i_clk_gate(
		.clk_i(s_clk_out),
		.en_i(s_clock_enable_gate),
		.test_en_i(test_mode_i),
		.clk_o(clk_o)
	);
	always @(*)
		case (state)
			2'd0: begin
				s_clock_enable = 1'b1;
				s_clk_div_valid = 1'b0;
				if (s_clk_div_valid_sync)
					state_next = 2'd1;
				else
					state_next = 2'd0;
			end
			2'd1: begin
				s_clock_enable = 1'b0;
				s_clk_div_valid = 1'b1;
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
	always @(posedge clk_i or negedge s_rstn_sync)
		if (!s_rstn_sync)
			state <= 2'd0;
		else
			state <= state_next;
	always @(posedge clk_i or negedge s_rstn_sync)
		if (!s_rstn_sync)
			reg_clk_div <= 1'sb0;
		else if (s_clk_div_valid_sync)
			reg_clk_div <= clk_div_data_i;
	always @(posedge clk_i or negedge s_rstn_sync)
		if (!s_rstn_sync)
			reg_ext_gate_sync <= 2'b00;
		else
			reg_ext_gate_sync <= {clk_gate_async_i, reg_ext_gate_sync[1]};
endmodule
