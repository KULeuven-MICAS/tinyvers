module timer_unit (
	clk_i,
	rst_ni,
	ref_clk_i,
	req_i,
	addr_i,
	wen_i,
	wdata_i,
	be_i,
	id_i,
	gnt_o,
	r_valid_o,
	r_opc_o,
	r_id_o,
	r_rdata_o,
	event_lo_i,
	event_hi_i,
	irq_lo_o,
	irq_hi_o,
	busy_o
);
	parameter ID_WIDTH = 5;
	input wire clk_i;
	input wire rst_ni;
	input wire ref_clk_i;
	input wire req_i;
	input wire [31:0] addr_i;
	input wire wen_i;
	input wire [31:0] wdata_i;
	input wire [3:0] be_i;
	input wire [ID_WIDTH - 1:0] id_i;
	output reg gnt_o;
	output reg r_valid_o;
	output wire r_opc_o;
	output reg [ID_WIDTH - 1:0] r_id_o;
	output reg [31:0] r_rdata_o;
	input wire event_lo_i;
	input wire event_hi_i;
	output reg irq_lo_o;
	output reg irq_hi_o;
	output wire busy_o;
	reg s_req;
	reg s_wen;
	reg [31:0] s_addr;
	reg s_write_counter_lo;
	reg s_write_counter_hi;
	reg s_start_timer_lo;
	reg s_start_timer_hi;
	reg s_reset_timer_lo;
	reg s_reset_timer_hi;
	reg s_ref_clk0;
	reg s_ref_clk1;
	reg s_ref_clk2;
	reg s_ref_clk3;
	wire s_ref_clk_edge;
	wire s_ref_clk_edge_del;
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
	reg [1:0] CS;
	reg [1:0] NS;
	assign r_opc_o = 1'b0;
	always @(posedge clk_i or negedge rst_ni)
		if (rst_ni == 1'b0)
			CS <= 2'd0;
		else
			CS <= NS;
	always @(*) begin
		gnt_o = 1'b1;
		r_valid_o = 1'b0;
		case (CS)
			2'd0:
				if (req_i == 1'b1)
					NS = 2'd1;
				else
					NS = 2'd0;
			2'd1: begin
				r_valid_o = 1'b1;
				if (req_i == 1'b1)
					NS = 2'd1;
				else
					NS = 2'd0;
			end
			default: NS = 2'd0;
		endcase
	end
	always @(posedge clk_i or negedge rst_ni)
		if (rst_ni == 1'b0) begin
			s_req <= 0;
			s_wen <= 0;
			s_addr <= 0;
			r_id_o <= 0;
		end
		else begin
			s_req <= req_i;
			s_wen <= wen_i;
			s_addr <= addr_i;
			r_id_o <= id_i;
		end
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
		if (req_i && ~wen_i)
			case (addr_i[5:0])
				6'h00: s_cfg_lo = wdata_i;
				6'h04: s_cfg_hi = wdata_i;
				6'h08: s_write_counter_lo = 1'b1;
				6'h0c: s_write_counter_hi = 1'b1;
				6'h10: s_timer_cmp_lo = wdata_i;
				6'h14: s_timer_cmp_hi = wdata_i;
				6'h18: s_start_timer_lo = 1'b1;
				6'h1c: s_start_timer_hi = 1'b1;
				6'h20: s_reset_timer_lo = 1'b1;
				6'h24: s_reset_timer_hi = 1'b1;
			endcase
		if (((event_lo_i == 1) && (s_cfg_lo['d3] == 1'b1)) | (s_start_timer_lo == 1))
			s_cfg_lo['d0] = 1;
		else if (s_cfg_lo_reg['d31] == 1'b0) begin
			if ((s_cfg_lo['d5] == 1'b1) && (s_target_reached_lo == 1'b1))
				s_cfg_lo['d0] = 0;
		end
		else if (((s_cfg_lo['d5] == 1'b1) && (s_target_reached_lo == 1'b1)) && (s_target_reached_hi == 1'b1))
			s_cfg_lo['d0] = 0;
		if (((event_hi_i == 1) && (s_cfg_hi['d3] == 1'b1)) | (s_start_timer_hi == 1))
			s_cfg_hi['d0] = 1;
		else if (((s_cfg_hi_reg['d31] == 1'b0) && (s_cfg_hi['d5] == 1'b1)) && (s_target_reached_hi == 1'b1))
			s_cfg_hi['d0] = 0;
		else if (((s_cfg_lo['d5] == 1'b1) && (s_target_reached_lo == 1'b1)) && (s_target_reached_hi == 1'b1))
			s_cfg_hi['d0] = 0;
		if (s_reset_count_lo == 1'b1)
			s_cfg_lo['d1] = 1'b0;
		if (s_reset_count_hi == 1'b1)
			s_cfg_hi['d1] = 1'b0;
	end
	always @(posedge clk_i or negedge rst_ni)
		if (~rst_ni) begin
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
	always @(*) begin
		r_rdata_o = 'b0;
		if (s_req && s_wen)
			case (s_addr[5:0])
				6'h00: r_rdata_o = s_cfg_lo_reg;
				6'h04: r_rdata_o = s_cfg_hi_reg;
				6'h08: r_rdata_o = s_timer_val_lo;
				6'h0c: r_rdata_o = s_timer_val_hi;
				6'h10: r_rdata_o = s_timer_cmp_lo_reg;
				6'h14: r_rdata_o = s_timer_cmp_hi_reg;
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
		else if (((s_cfg_lo_reg['d4] == 1'b1) && (s_target_reached_lo == 1'b1)) && (s_target_reached_hi == 1'b1))
			s_reset_count_lo = 1;
		if ((s_cfg_hi_reg['d1] == 1'b1) | (s_reset_timer_hi == 1'b1)) begin
			s_reset_count_hi = 1'b1;
			s_reset_count_prescaler_hi = 1'b1;
		end
		else if (s_cfg_lo_reg['d31] == 1'b0) begin
			if ((s_cfg_hi_reg['d4] == 1'b1) && (s_target_reached_hi == 1'b1))
				s_reset_count_hi = 1;
		end
		else if (((s_cfg_lo_reg['d4] == 1'b1) && (s_target_reached_lo == 1'b1)) && (s_target_reached_hi == 1'b1))
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
		if ((s_cfg_lo_reg['d0] == 1'b1) && (s_cfg_lo_reg['d31] == 1'b1))
			if ((s_cfg_lo_reg['d6] == 1'b0) && (s_cfg_lo_reg['d7] == 1'b0)) begin
				s_enable_count_lo = 1'b1;
				s_enable_count_hi = s_timer_val_lo == 32'hffffffff;
			end
			else if ((s_cfg_lo_reg['d6] == 1'b0) && (s_cfg_lo_reg['d7] == 1'b1)) begin
				s_enable_count_lo = s_ref_clk_edge;
				s_enable_count_hi = s_ref_clk_edge_del && (s_timer_val_lo == 32'hffffffff);
			end
			else if ((s_cfg_lo_reg['d6] == 1'b1) && (s_cfg_lo_reg['d7] == 1'b1)) begin
				s_enable_count_prescaler_lo = s_ref_clk_edge;
				s_enable_count_lo = s_target_reached_prescaler_lo;
				s_enable_count_hi = (s_target_reached_prescaler_lo && s_ref_clk_edge_del) && (s_timer_val_lo == 32'hffffffff);
			end
			else begin
				s_enable_count_prescaler_lo = 1'b1;
				s_enable_count_lo = s_target_reached_prescaler_lo;
				s_enable_count_hi = s_target_reached_prescaler_lo && (s_timer_val_lo == 32'hffffffff);
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
	always @(posedge clk_i or negedge rst_ni)
		if (~rst_ni) begin
			s_ref_clk0 <= 1'b0;
			s_ref_clk1 <= 1'b0;
			s_ref_clk2 <= 1'b0;
			s_ref_clk3 <= 1'b0;
		end
		else begin
			s_ref_clk0 <= ref_clk_i;
			s_ref_clk1 <= s_ref_clk0;
			s_ref_clk2 <= s_ref_clk1;
			s_ref_clk3 <= s_ref_clk2;
		end
	assign s_ref_clk_edge = ((s_ref_clk1 == 1'b1) & (s_ref_clk2 == 1'b0) ? 1'b1 : 1'b0);
	assign s_ref_clk_edge_del = ((s_ref_clk2 == 1'b1) & (s_ref_clk3 == 1'b0) ? 1'b1 : 1'b0);
	timer_unit_counter_presc prescaler_lo_i(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.write_counter_i(1'b0),
		.counter_value_i(32'h00000000),
		.enable_count_i(s_enable_count_prescaler_lo),
		.reset_count_i(s_reset_count_prescaler_lo),
		.compare_value_i({24'd0, s_cfg_lo_reg['d15:'d8]}),
		.target_reached_o(s_target_reached_prescaler_lo)
	);
	timer_unit_counter_presc prescaler_hi_i(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.write_counter_i(1'b0),
		.counter_value_i(32'h00000000),
		.enable_count_i(s_enable_count_prescaler_hi),
		.reset_count_i(s_reset_count_prescaler_hi),
		.compare_value_i({24'd0, s_cfg_hi_reg['d15:'d8]}),
		.target_reached_o(s_target_reached_prescaler_hi)
	);
	timer_unit_counter counter_lo_i(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.write_counter_i(s_write_counter_lo),
		.counter_value_i(wdata_i),
		.enable_count_i(s_enable_count_lo),
		.reset_count_i(s_reset_count_lo),
		.compare_value_i(s_timer_cmp_lo_reg),
		.counter_value_o(s_timer_val_lo),
		.target_reached_o(s_target_reached_lo)
	);
	timer_unit_counter counter_hi_i(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.write_counter_i(s_write_counter_hi),
		.counter_value_i(wdata_i),
		.enable_count_i(s_enable_count_hi),
		.reset_count_i(s_reset_count_hi),
		.compare_value_i(s_timer_cmp_hi_reg),
		.counter_value_o(s_timer_val_hi),
		.target_reached_o(s_target_reached_hi)
	);
	assign busy_o = s_cfg_hi_reg['d0] | s_cfg_lo_reg['d0];
endmodule
