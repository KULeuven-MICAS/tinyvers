module apb_timer_unit (
	HCLK,
	HRESETn,
	PADDR,
	PWDATA,
	PWRITE,
	PSEL,
	PENABLE,
	PRDATA,
	PREADY,
	PSLVERR,
	ref_clk_i,
	event_lo_i,
	event_hi_i,
	irq_lo_o,
	irq_hi_o,
	busy_o
);
	parameter APB_ADDR_WIDTH = 12;
	input wire HCLK;
	input wire HRESETn;
	input wire [APB_ADDR_WIDTH - 1:0] PADDR;
	input wire [31:0] PWDATA;
	input wire PWRITE;
	input wire PSEL;
	input wire PENABLE;
	output reg [31:0] PRDATA;
	output wire PREADY;
	output wire PSLVERR;
	input wire ref_clk_i;
	input wire event_lo_i;
	input wire event_hi_i;
	output reg irq_lo_o;
	output reg irq_hi_o;
	output wire busy_o;
	wire s_req;
	wire s_wen;
	wire [31:0] s_addr;
	reg s_write_counter_lo;
	reg s_write_counter_hi;
	reg s_start_timer_lo;
	reg s_start_timer_hi;
	reg s_reset_timer_lo;
	reg s_reset_timer_hi;
	reg s_ref_clk0;
	reg s_ref_clk1;
	reg s_ref_clk2;
	wire s_ref_clk_edge;
	wire [31:0] s_counter_val_lo;
	wire [31:0] s_counter_val_hi;
	reg [31:0] s_cfg_lo;
	reg [31:0] s_cfg_lo_reg;
	reg [31:0] s_cfg_hi;
	reg [31:0] s_cfg_hi_reg;
	wire [31:0] s_timer_val_lo;
	wire [31:0] s_timer_val_hi;
	reg [31:0] s_timer_cmp_lo;
	reg [31:0] s_timer_cmp_lo_reg;
	reg [31:0] s_timer_cmp_hi;
	reg [31:0] s_timer_cmp_hi_reg;
	reg s_enable_count_lo;
	reg s_enable_count_hi;
	reg s_enable_count_prescaler_lo;
	reg s_enable_count_prescaler_hi;
	reg s_reset_count_lo;
	reg s_reset_count_hi;
	reg s_reset_count_prescaler_lo;
	reg s_reset_count_prescaler_hi;
	wire s_target_reached_lo;
	wire s_target_reached_hi;
	wire s_target_reached_prescaler_lo;
	wire s_target_reached_prescaler_hi;
	wire s_clear_reset_lo;
	wire s_clear_reset_hi;
	always @(*) begin
		s_cfg_lo = s_cfg_lo_reg;
		s_cfg_hi = s_cfg_hi_reg;
		s_timer_cmp_lo = s_timer_cmp_lo_reg;
		s_timer_cmp_hi = s_timer_cmp_hi_reg;
		s_write_counter_lo = 1'b0;
		s_write_counter_hi = 1'b0;
		s_start_timer_lo = 1'b0;
		s_start_timer_hi = 1'b0;
		s_reset_timer_lo = 1'b0;
		s_reset_timer_hi = 1'b0;
		if ((PSEL && PENABLE) && PWRITE)
			case (PADDR[5:0])
				6'h00: s_cfg_lo = PWDATA;
				6'h04: s_cfg_hi = PWDATA;
				6'h08: s_write_counter_lo = 1'b1;
				6'h0c: s_write_counter_hi = 1'b1;
				6'h10: s_timer_cmp_lo = PWDATA;
				6'h14: s_timer_cmp_hi = PWDATA;
				6'h18: s_start_timer_lo = 1'b1;
				6'h1c: s_start_timer_hi = 1'b1;
				6'h20: s_reset_timer_lo = 1'b1;
				6'h24: s_reset_timer_hi = 1'b1;
			endcase
		if ((event_lo_i == 1) | (s_start_timer_lo == 1))
			s_cfg_lo['d0] = 1;
		else if (s_cfg_lo_reg['d31] == 1'b0) begin
			if ((s_cfg_lo['d5] == 1'b1) && (s_target_reached_lo == 1'b1))
				s_cfg_lo['d0] = 0;
		end
		else if (((s_cfg_lo['d5] == 1'b1) && (s_timer_val_lo == 32'hffffffff)) && (s_target_reached_hi == 1'b1))
			s_cfg_lo['d0] = 0;
		if ((event_hi_i == 1) | (s_start_timer_hi == 1))
			s_cfg_hi['d0] = 1;
		else if (((s_cfg_hi_reg['d31] == 1'b0) && (s_cfg_hi['d5] == 1'b1)) && (s_target_reached_hi == 1'b1))
			s_cfg_hi['d0] = 0;
		if (s_reset_count_lo == 1'b1)
			s_cfg_lo['d1] = 1'b0;
		if (s_reset_count_hi == 1'b1)
			s_cfg_hi['d1] = 1'b0;
	end
	always @(posedge HCLK or negedge HRESETn)
		if (~HRESETn) begin
			s_cfg_lo_reg <= 0;
			s_cfg_hi_reg <= 0;
			s_timer_cmp_lo_reg <= 0;
			s_timer_cmp_hi_reg <= 0;
		end
		else begin
			s_cfg_lo_reg <= s_cfg_lo;
			s_cfg_hi_reg <= s_cfg_hi;
			s_timer_cmp_lo_reg <= s_timer_cmp_lo;
			s_timer_cmp_hi_reg <= s_timer_cmp_hi;
		end
	assign PSLVERR = 1'b0;
	assign PREADY = PSEL & PENABLE;
	always @(*) begin
		PRDATA = 'b0;
		if ((PSEL && PENABLE) && !PWRITE)
			case (PADDR[5:0])
				6'h00: PRDATA = s_cfg_lo_reg;
				6'h04: PRDATA = s_cfg_hi_reg;
				6'h08: PRDATA = s_timer_val_lo;
				6'h0c: PRDATA = s_timer_val_hi;
				6'h10: PRDATA = s_timer_cmp_lo_reg;
				6'h14: PRDATA = s_timer_cmp_hi_reg;
			endcase
	end
	always @(*) begin
		s_reset_count_lo = 1'b0;
		s_reset_count_hi = 1'b0;
		s_reset_count_prescaler_lo = 1'b0;
		s_reset_count_prescaler_hi = 1'b0;
		if ((s_cfg_lo_reg['d1] == 1'b1) | (s_reset_timer_lo == 1'b1)) begin
			s_reset_count_lo = 1'b1;
			s_reset_count_prescaler_lo = 1'b1;
		end
		else if (s_cfg_lo_reg['d31] == 1'b0) begin
			if ((s_cfg_lo_reg['d4] == 1'b1) && (s_target_reached_lo == 1'b1))
				s_reset_count_lo = 1;
		end
		else if (((s_cfg_lo_reg['d4] == 1'b1) && (s_timer_val_lo == 32'hffffffff)) && (s_target_reached_hi == 1'b1))
			s_reset_count_lo = 1;
		if ((s_cfg_hi_reg['d1] == 1'b1) | (s_reset_timer_hi == 1'b1)) begin
			s_reset_count_hi = 1'b1;
			s_reset_count_prescaler_hi = 1'b1;
		end
		else if (s_cfg_lo_reg['d31] == 1'b0) begin
			if ((s_cfg_hi_reg['d4] == 1'b1) && (s_target_reached_hi == 1'b1))
				s_reset_count_hi = 1;
		end
		else if (((s_cfg_lo_reg['d4] == 1'b1) && (s_timer_val_lo == 32'hffffffff)) && (s_target_reached_hi == 1'b1))
			s_reset_count_hi = 1;
		if (s_cfg_lo_reg['d6] && (s_target_reached_prescaler_lo == 1'b1))
			s_reset_count_prescaler_lo = 1'b1;
		if (s_cfg_hi_reg['d6] && (s_target_reached_prescaler_hi == 1'b1))
			s_reset_count_prescaler_hi = 1'b1;
	end
	always @(*) begin
		s_enable_count_lo = 1'b0;
		s_enable_count_hi = 1'b0;
		s_enable_count_prescaler_lo = 1'b0;
		s_enable_count_prescaler_hi = 1'b0;
		if (s_cfg_lo_reg['d0] == 1'b1)
			if ((s_cfg_lo_reg['d6] == 1'b0) && (s_cfg_lo_reg['d7] == 1'b0))
				s_enable_count_lo = 1'b1;
			else if ((s_cfg_lo_reg['d6] == 1'b0) && (s_cfg_lo_reg['d7] == 1'b1))
				s_enable_count_lo = s_ref_clk_edge;
			else if ((s_cfg_lo_reg['d6] == 1'b1) && (s_cfg_lo_reg['d7] == 1'b1)) begin
				s_enable_count_prescaler_lo = s_ref_clk_edge;
				s_enable_count_lo = s_target_reached_prescaler_lo;
			end
			else begin
				s_enable_count_prescaler_lo = 1'b1;
				s_enable_count_lo = s_target_reached_prescaler_lo;
			end
		if (s_cfg_hi_reg['d0] == 1'b1)
			if ((s_cfg_hi_reg['d6] == 1'b0) && (s_cfg_hi_reg['d7] == 1'b0))
				s_enable_count_hi = 1'b1;
			else if ((s_cfg_hi_reg['d6] == 1'b0) && (s_cfg_hi_reg['d7] == 1'b1))
				s_enable_count_hi = s_ref_clk_edge;
			else if ((s_cfg_hi_reg['d6] == 1'b1) && (s_cfg_hi_reg['d7] == 1'b1)) begin
				s_enable_count_prescaler_hi = s_ref_clk_edge;
				s_enable_count_hi = s_target_reached_prescaler_hi;
			end
			else begin
				s_enable_count_prescaler_hi = 1'b1;
				s_enable_count_hi = s_target_reached_prescaler_hi;
			end
		if ((s_cfg_lo_reg['d0] == 1'b1) && (s_cfg_lo_reg['d31] == 1'b1)) begin
			s_enable_count_hi = s_timer_cmp_lo_reg == 32'hffffffff;
			if ((s_cfg_lo_reg['d6] == 1'b0) && (s_cfg_lo_reg['d7] == 1'b0))
				s_enable_count_lo = 1'b1;
			else if ((s_cfg_lo_reg['d6] == 1'b0) && (s_cfg_lo_reg['d7] == 1'b1))
				s_enable_count_lo = s_ref_clk_edge;
			else if ((s_cfg_lo_reg['d6] == 1'b1) && (s_cfg_lo_reg['d7] == 1'b1)) begin
				s_enable_count_prescaler_lo = s_ref_clk_edge;
				s_enable_count_lo = s_target_reached_prescaler_lo;
			end
			else begin
				s_enable_count_prescaler_lo = 1'b1;
				s_enable_count_lo = s_target_reached_prescaler_lo;
			end
		end
	end
	always @(*) begin
		irq_lo_o = 1'b0;
		irq_hi_o = 1'b0;
		if (s_cfg_lo_reg['d31] == 1'b0) begin
			irq_lo_o = s_target_reached_lo & s_cfg_lo_reg['d2];
			irq_hi_o = s_target_reached_hi & s_cfg_hi_reg['d2];
		end
		else
			irq_lo_o = (s_target_reached_lo & s_target_reached_hi) & s_cfg_lo_reg['d2];
	end
	always @(posedge HCLK or negedge HRESETn)
		if (~HRESETn) begin
			s_ref_clk0 <= 1'b0;
			s_ref_clk1 <= 1'b0;
			s_ref_clk2 <= 1'b0;
		end
		else begin
			s_ref_clk0 <= ref_clk_i;
			s_ref_clk1 <= s_ref_clk0;
			s_ref_clk2 <= s_ref_clk1;
		end
	assign s_ref_clk_edge = ((s_ref_clk1 == 1'b1) & (s_ref_clk2 == 1'b0) ? 1'b1 : 1'b0);
	timer_unit_counter prescaler_lo_i(
		.clk_i(HCLK),
		.rst_ni(HRESETn),
		.write_counter_i(1'b0),
		.counter_value_i(32'h00000000),
		.enable_count_i(s_enable_count_prescaler_lo),
		.reset_count_i(s_reset_count_prescaler_lo),
		.compare_value_i({24'd0, s_cfg_lo_reg['d15:'d8]}),
		.counter_value_o(),
		.target_reached_o(s_target_reached_prescaler_lo)
	);
	timer_unit_counter prescaler_hi_i(
		.clk_i(HCLK),
		.rst_ni(HRESETn),
		.write_counter_i(1'b0),
		.counter_value_i(32'h00000000),
		.enable_count_i(s_enable_count_prescaler_hi),
		.reset_count_i(s_reset_count_prescaler_hi),
		.compare_value_i({24'd0, s_cfg_hi_reg['d15:'d8]}),
		.counter_value_o(),
		.target_reached_o(s_target_reached_prescaler_hi)
	);
	timer_unit_counter counter_lo_i(
		.clk_i(HCLK),
		.rst_ni(HRESETn),
		.write_counter_i(s_write_counter_lo),
		.counter_value_i(PWDATA),
		.enable_count_i(s_enable_count_lo),
		.reset_count_i(s_reset_count_lo),
		.compare_value_i(s_timer_cmp_lo_reg),
		.counter_value_o(s_timer_val_lo),
		.target_reached_o(s_target_reached_lo)
	);
	timer_unit_counter counter_hi_i(
		.clk_i(HCLK),
		.rst_ni(HRESETn),
		.write_counter_i(s_write_counter_hi),
		.counter_value_i(PWDATA),
		.enable_count_i(s_enable_count_hi),
		.reset_count_i(s_reset_count_hi),
		.compare_value_i(s_timer_cmp_hi_reg),
		.counter_value_o(s_timer_val_hi),
		.target_reached_o(s_target_reached_hi)
	);
	assign busy_o = s_cfg_hi_reg['d0] | s_cfg_lo_reg['d0];
endmodule
