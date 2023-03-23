module soc_event_generator (
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
	low_speed_clk_i,
	per_events_i,
	fc_events_o,
	err_event_o,
	timer_event_lo_o,
	timer_event_hi_o,
	fc_event_valid_o,
	fc_event_data_o,
	fc_event_ready_i,
	cl_event_valid_o,
	cl_event_data_o,
	cl_event_ready_i,
	pr_event_valid_o,
	pr_event_data_o,
	pr_event_ready_i
);
	parameter APB_ADDR_WIDTH = 12;
	parameter PER_EVNT_NUM = 17;
	parameter APB_EVNT_NUM = 16;
	parameter EVNT_WIDTH = 8;
	parameter FC_EVENT_POS = 3;
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
	input wire low_speed_clk_i;
	input wire [PER_EVNT_NUM - 1:0] per_events_i;
	output wire [1:0] fc_events_o;
	output wire err_event_o;
	output wire timer_event_lo_o;
	output wire timer_event_hi_o;
	output wire fc_event_valid_o;
	output wire [EVNT_WIDTH - 1:0] fc_event_data_o;
	input wire fc_event_ready_i;
	output wire cl_event_valid_o;
	output wire [EVNT_WIDTH - 1:0] cl_event_data_o;
	input wire cl_event_ready_i;
	output wire pr_event_valid_o;
	output wire [EVNT_WIDTH - 1:0] pr_event_data_o;
	input wire pr_event_ready_i;
	genvar j;
	localparam EVNT_NUM = (PER_EVNT_NUM + APB_EVNT_NUM) + 1;
	reg [7:0] r_timer_sel_hi;
	reg [7:0] r_timer_sel_lo;
	reg [EVNT_WIDTH - 1:0] s_event_data;
	wire s_event_valid;
	wire s_event_ready;
	wire [EVNT_NUM - 1:0] s_err;
	reg [255:0] r_err;
	wire [EVNT_NUM - 1:0] s_req;
	wire [EVNT_NUM - 1:0] s_ack;
	wire [EVNT_NUM - 1:0] s_events;
	wire [EVNT_NUM - 1:0] s_grant;
	wire [5:0] s_apb_addr;
	reg [255:0] r_fc_mask;
	reg [255:0] r_cl_mask;
	reg [255:0] r_pr_mask;
	wire [EVNT_NUM - 1:0] s_fc_mask;
	wire [EVNT_NUM - 1:0] s_cl_mask;
	wire [EVNT_NUM - 1:0] s_pr_mask;
	wire s_ready_fc;
	wire s_ready_cl;
	wire s_ready_pr;
	wire s_valid_fc;
	wire s_valid_cl;
	wire s_valid_pr;
	reg [2:0] r_ls_sync;
	wire s_ls_rise;
	reg [APB_EVNT_NUM - 1:0] r_apb_events;
	assign fc_events_o = per_events_i[FC_EVENT_POS + 1:FC_EVENT_POS];
	assign s_apb_addr = PADDR[7:2];
	assign s_ls_rise = ~r_ls_sync[2] & r_ls_sync[1];
	assign err_event_o = |s_err;
	assign s_fc_mask = r_fc_mask[EVNT_NUM - 1:0];
	assign s_cl_mask = r_cl_mask[EVNT_NUM - 1:0];
	assign s_pr_mask = r_pr_mask[EVNT_NUM - 1:0];
	assign fc_event_data_o = s_event_data;
	assign cl_event_data_o = s_event_data;
	assign pr_event_data_o = s_event_data;
	assign fc_event_valid_o = s_valid_fc;
	assign cl_event_valid_o = s_valid_cl;
	assign pr_event_valid_o = s_valid_pr;
	assign s_valid_fc = |(s_grant & ~s_fc_mask);
	assign s_valid_cl = |(s_grant & ~s_cl_mask);
	assign s_valid_pr = |(s_grant & ~s_pr_mask);
	assign s_ready_fc = (s_valid_fc ? fc_event_ready_i : 1'b1);
	assign s_ready_cl = (s_valid_cl ? cl_event_ready_i : 1'b1);
	assign s_ready_pr = (s_valid_pr ? pr_event_ready_i : 1'b1);
	assign s_event_ready = (s_ready_fc & s_ready_cl) & s_ready_pr;
	assign s_events = {s_ls_rise, r_apb_events, per_events_i};
	assign s_ack = s_grant & {EVNT_NUM {s_event_ready}};
	assign timer_event_lo_o = s_events[r_timer_sel_lo];
	assign timer_event_hi_o = s_events[r_timer_sel_hi];
	generate
		for (j = 0; j < EVNT_NUM; j = j + 1) begin : genblk1
			soc_event_queue u_soc_event_queue(
				.clk_i(HCLK),
				.rstn_i(HRESETn),
				.event_i(s_events[j]),
				.err_o(s_err[j]),
				.event_o(s_req[j]),
				.event_ack_i(s_ack[j])
			);
		end
	endgenerate
	soc_event_arbiter #(.EVNT_NUM(EVNT_NUM)) u_arbiter(
		.clk_i(HCLK),
		.rstn_i(HRESETn),
		.req_i(s_req),
		.grant_o(s_grant),
		.grant_ack_i(s_event_ready),
		.anyGrant_o(s_event_valid)
	);
	always @(*) begin : proc_data_o
		s_event_data = 'h0;
		begin : sv2v_autoblock_1
			reg signed [31:0] i;
			for (i = 0; i < EVNT_NUM; i = i + 1)
				if (s_grant[i])
					s_event_data = i;
		end
	end
	always @(posedge HCLK or negedge HRESETn)
		if (~HRESETn)
			r_ls_sync <= 'h0;
		else
			r_ls_sync <= {r_ls_sync[1:0], low_speed_clk_i};
	always @(posedge HCLK or negedge HRESETn)
		if (~HRESETn) begin
			r_apb_events = 'h0;
			r_fc_mask <= {256 {1'b1}};
			r_cl_mask <= {256 {1'b1}};
			r_pr_mask <= {256 {1'b1}};
			r_timer_sel_lo <= 'h0;
			r_timer_sel_hi <= 'h0;
			r_err = 'h0;
		end
		else begin
			begin : sv2v_autoblock_2
				reg signed [31:0] i;
				for (i = 0; i < EVNT_NUM; i = i + 1)
					if (s_err[i])
						r_err[i] = 1'b1;
			end
			r_apb_events = 'h0;
			if ((PSEL && PENABLE) && PWRITE)
				case (s_apb_addr)
					6'b000000: r_apb_events = PWDATA[APB_EVNT_NUM - 1:0];
					6'b000001: r_fc_mask[31:0] <= PWDATA;
					6'b000010: r_fc_mask[63:32] <= PWDATA;
					6'b000011: r_fc_mask[95:64] <= PWDATA;
					6'b000100: r_fc_mask[127:96] <= PWDATA;
					6'b000101: r_fc_mask[159:128] <= PWDATA;
					6'b000110: r_fc_mask[191:160] <= PWDATA;
					6'b000111: r_fc_mask[223:192] <= PWDATA;
					6'b001000: r_fc_mask[255:224] <= PWDATA;
					6'b001001: r_cl_mask[31:0] <= PWDATA;
					6'b001010: r_cl_mask[63:32] <= PWDATA;
					6'b001011: r_cl_mask[95:64] <= PWDATA;
					6'b001100: r_cl_mask[127:96] <= PWDATA;
					6'b001101: r_cl_mask[159:128] <= PWDATA;
					6'b001110: r_cl_mask[191:160] <= PWDATA;
					6'b001111: r_cl_mask[223:192] <= PWDATA;
					6'b010000: r_cl_mask[255:224] <= PWDATA;
					6'b010001: r_pr_mask[31:0] <= PWDATA;
					6'b010010: r_pr_mask[63:32] <= PWDATA;
					6'b010011: r_pr_mask[95:64] <= PWDATA;
					6'b010100: r_pr_mask[127:96] <= PWDATA;
					6'b010101: r_pr_mask[159:128] <= PWDATA;
					6'b010110: r_pr_mask[191:160] <= PWDATA;
					6'b010111: r_pr_mask[223:192] <= PWDATA;
					6'b011000: r_pr_mask[255:224] <= PWDATA;
					6'b100010: r_timer_sel_lo <= PWDATA[7:0];
					6'b100001: r_timer_sel_hi <= PWDATA[7:0];
				endcase
			else if ((PSEL && PENABLE) && ~PWRITE)
				case (s_apb_addr)
					6'b011001: r_err[31:0] = 'h0;
					6'b011010: r_err[63:32] = 'h0;
					6'b011011: r_err[95:64] = 'h0;
					6'b011100: r_err[127:96] = 'h0;
					6'b011101: r_err[159:128] = 'h0;
					6'b011110: r_err[191:160] = 'h0;
					6'b011111: r_err[223:192] = 'h0;
					6'b100000: r_err[255:224] = 'h0;
				endcase
		end
	always @(*) begin
		PRDATA = 'h0;
		case (s_apb_addr)
			6'b000001: PRDATA = r_fc_mask[31:0];
			6'b000010: PRDATA = r_fc_mask[63:32];
			6'b000011: PRDATA = r_fc_mask[95:64];
			6'b000100: PRDATA = r_fc_mask[127:96];
			6'b000101: PRDATA = r_fc_mask[159:128];
			6'b000110: PRDATA = r_fc_mask[191:160];
			6'b000111: PRDATA = r_fc_mask[223:192];
			6'b001000: PRDATA = r_fc_mask[255:224];
			6'b001001: PRDATA = r_cl_mask[31:0];
			6'b001010: PRDATA = r_cl_mask[63:32];
			6'b001011: PRDATA = r_cl_mask[95:64];
			6'b001100: PRDATA = r_cl_mask[127:96];
			6'b001101: PRDATA = r_cl_mask[159:128];
			6'b001110: PRDATA = r_cl_mask[191:160];
			6'b001111: PRDATA = r_cl_mask[223:192];
			6'b010000: PRDATA = r_cl_mask[255:224];
			6'b010001: PRDATA = r_pr_mask[31:0];
			6'b010010: PRDATA = r_pr_mask[63:32];
			6'b010011: PRDATA = r_pr_mask[95:64];
			6'b010100: PRDATA = r_pr_mask[127:96];
			6'b010101: PRDATA = r_pr_mask[159:128];
			6'b010110: PRDATA = r_pr_mask[191:160];
			6'b010111: PRDATA = r_pr_mask[223:192];
			6'b011000: PRDATA = r_pr_mask[255:224];
			6'b011001: PRDATA = r_err[31:0];
			6'b011010: PRDATA = r_err[63:32];
			6'b011011: PRDATA = r_err[95:64];
			6'b011100: PRDATA = r_err[127:96];
			6'b011101: PRDATA = r_err[159:128];
			6'b011110: PRDATA = r_err[191:160];
			6'b011111: PRDATA = r_err[223:192];
			6'b100000: PRDATA = r_err[255:224];
			6'b100010: PRDATA = {24'h000000, r_timer_sel_lo};
			6'b100001: PRDATA = {24'h000000, r_timer_sel_hi};
			default: PRDATA = 'h0;
		endcase
	end
	assign PREADY = 1'b1;
	assign PSLVERR = 1'b0;
endmodule
