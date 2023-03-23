module safe_domain_reg_if (
	clk_i,
	rstn_i,
	cfg_mem_ret_o,
	cfg_fll_ret_o,
	cfg_rar_nv_volt_o,
	cfg_rar_mv_volt_o,
	cfg_rar_lv_volt_o,
	cfg_rar_rv_volt_o,
	cfg_wakeup_o,
	wake_gpio_i,
	wake_event_o,
	boot_l2_o,
	rtc_event_o,
	pad_sleep_mode_o,
	pad_sleep_cfg_o,
	reg_if_req_i,
	reg_if_wrn_i,
	reg_if_add_i,
	reg_if_wdata_i,
	reg_if_ack_o,
	reg_if_rdata_o,
	pmu_sleep_control_o
);
	input wire clk_i;
	input wire rstn_i;
	output wire [11:0] cfg_mem_ret_o;
	output wire [1:0] cfg_fll_ret_o;
	output wire [4:0] cfg_rar_nv_volt_o;
	output wire [4:0] cfg_rar_mv_volt_o;
	output wire [4:0] cfg_rar_lv_volt_o;
	output wire [4:0] cfg_rar_rv_volt_o;
	output wire [1:0] cfg_wakeup_o;
	input wire [31:0] wake_gpio_i;
	output wire wake_event_o;
	output wire boot_l2_o;
	output wire rtc_event_o;
	output wire pad_sleep_mode_o;
	output reg [127:0] pad_sleep_cfg_o;
	input wire reg_if_req_i;
	input wire reg_if_wrn_i;
	input wire [5:0] reg_if_add_i;
	input wire [31:0] reg_if_wdata_i;
	output reg reg_if_ack_o;
	output reg [31:0] reg_if_rdata_o;
	output wire [31:0] pmu_sleep_control_o;
	reg [4:0] r_rar_nv_volt;
	reg [4:0] r_rar_mv_volt;
	reg [4:0] r_rar_lv_volt;
	reg [4:0] r_rar_rv_volt;
	reg [4:0] r_extwake_sel;
	reg r_extwake_en;
	reg [1:0] r_extwake_type;
	reg r_extevent;
	reg [2:0] r_extevent_sync;
	reg [2:0] r_reboot;
	wire s_extwake_rise;
	wire s_extwake_fall;
	wire s_extwake_in;
	reg [1:0] r_wakeup;
	reg r_cluster_wake;
	reg [13:0] r_cfg_ret;
	wire s_rise;
	wire s_fall;
	reg [63:0] r_sleep_pad_cfg0;
	reg [63:0] r_sleep_pad_cfg1;
	reg r_pad_sleep;
	wire s_req_sync;
	reg r_boot_l2;
	wire [31:0] s_pmu_sleep_control;
	wire [21:0] s_rtc_clock;
	wire [21:0] s_rtc_alarm;
	wire [31:0] s_rtc_date;
	wire [16:0] s_rtc_timer;
	pulp_sync_wedge i_sync(
		.clk_i(clk_i),
		.rstn_i(rstn_i),
		.en_i(1'b1),
		.serial_i(reg_if_req_i),
		.r_edge_o(s_rise),
		.f_edge_o(s_fall),
		.serial_o(s_req_sync)
	);
	assign cfg_rar_nv_volt_o = r_rar_nv_volt;
	assign cfg_rar_mv_volt_o = r_rar_mv_volt;
	assign cfg_rar_lv_volt_o = r_rar_lv_volt;
	assign cfg_rar_rv_volt_o = r_rar_rv_volt;
	assign cfg_mem_ret_o = r_cfg_ret[11:0];
	assign cfg_fll_ret_o = r_cfg_ret[13:12];
	assign wake_event_o = r_extevent;
	assign cfg_wakeup_o = r_wakeup;
	assign boot_l2_o = r_boot_l2;
	always @(posedge clk_i or negedge rstn_i)
		if (!rstn_i)
			reg_if_ack_o <= 1'b0;
		else if (s_rise)
			reg_if_ack_o <= 1'b1;
		else if (s_fall)
			reg_if_ack_o <= 1'b0;
	assign s_extwake_in = wake_gpio_i[r_extwake_sel];
	assign s_extwake_rise = r_extevent_sync[1] & ~r_extevent_sync[0];
	assign s_extwake_fall = ~r_extevent_sync[1] & r_extevent_sync[0];
	wire s_rtc_date_select;
	assign s_rtc_date_select = reg_if_add_i == 6'b110111;
	wire s_rtc_clock_select;
	assign s_rtc_clock_select = reg_if_add_i == 6'b110100;
	wire s_rtc_timer_select;
	assign s_rtc_timer_select = reg_if_add_i == 6'b110110;
	wire s_rtc_alarm_select;
	assign s_rtc_alarm_select = reg_if_add_i == 6'b110101;
	wire s_rtc_date_update;
	assign s_rtc_date_update = s_rtc_date_select & (s_rise & ~reg_if_wrn_i);
	wire s_rtc_alarm_update;
	assign s_rtc_alarm_update = s_rtc_alarm_select & (s_rise & ~reg_if_wrn_i);
	wire s_rtc_clock_update;
	assign s_rtc_clock_update = s_rtc_clock_select & (s_rise & ~reg_if_wrn_i);
	wire s_rtc_timer_update;
	assign s_rtc_timer_update = s_rtc_timer_select & (s_rise & ~reg_if_wrn_i);
	wire s_rtc_update_day;
	rtc_clock i_rtc_clock(
		.clk_i(clk_i),
		.rstn_i(rstn_i),
		.clock_update_i(s_rtc_clock_update),
		.clock_o(s_rtc_clock),
		.clock_i(reg_if_wdata_i[21:0]),
		.init_sec_cnt_i(reg_if_wdata_i[31:22]),
		.timer_update_i(s_rtc_timer_update),
		.timer_enable_i(reg_if_wdata_i[31]),
		.timer_retrig_i(reg_if_wdata_i[30]),
		.timer_target_i(reg_if_wdata_i[16:0]),
		.timer_value_o(s_rtc_timer),
		.alarm_enable_i(reg_if_wdata_i[31]),
		.alarm_update_i(s_rtc_alarm_update),
		.alarm_clock_i(reg_if_wdata_i[21:0]),
		.alarm_clock_o(s_rtc_alarm),
		.event_o(rtc_event_o),
		.update_day_o(s_rtc_update_day)
	);
	rtc_date i_rtc_date(
		.clk_i(clk_i),
		.rstn_i(rstn_i),
		.date_update_i(s_rtc_date_update),
		.date_i(reg_if_wdata_i[31:0]),
		.date_o(s_rtc_date),
		.new_day_i(s_rtc_update_day)
	);
	always @(posedge clk_i or negedge rstn_i)
		if (!rstn_i) begin
			r_cfg_ret <= 13'h0000;
			r_rar_nv_volt <= 5'h0d;
			r_rar_mv_volt <= 5'h09;
			r_rar_lv_volt <= 5'h09;
			r_rar_rv_volt <= 5'h05;
			r_sleep_pad_cfg0 <= 1'sb0;
			r_sleep_pad_cfg1 <= 1'sb0;
			r_pad_sleep <= 1'sb0;
			r_extwake_sel <= 1'sb0;
			r_extwake_en <= 1'sb0;
			r_extwake_type <= 1'sb0;
			r_extevent <= 0;
			r_extevent_sync <= 0;
			r_wakeup <= 0;
			r_cluster_wake <= 1'b0;
			r_boot_l2 <= 0;
			r_reboot <= 2'b00;
		end
		else if (s_rise & ~reg_if_wrn_i)
			case (reg_if_add_i)
				6'b000000: begin
					r_rar_nv_volt <= reg_if_wdata_i[4:0];
					r_rar_mv_volt <= reg_if_wdata_i[12:8];
					r_rar_lv_volt <= reg_if_wdata_i[20:16];
					r_rar_rv_volt <= reg_if_wdata_i[28:24];
				end
				6'b000001: begin
					r_cfg_ret[13:12] <= reg_if_wdata_i[1:0];
					r_cfg_ret[11] <= reg_if_wdata_i[2];
					r_extwake_sel <= reg_if_wdata_i[10:6];
					r_extwake_type <= reg_if_wdata_i[12:11];
					r_extwake_en <= reg_if_wdata_i[13];
					r_wakeup <= reg_if_wdata_i[15:14];
					r_boot_l2 <= reg_if_wdata_i[16];
					r_reboot <= reg_if_wdata_i[19:18];
					r_cluster_wake <= reg_if_wdata_i[20];
					r_cfg_ret[10:0] <= reg_if_wdata_i[31:21];
				end
				6'b010100: begin : sv2v_autoblock_1
					reg signed [31:0] i;
					for (i = 0; i < 16; i = i + 1)
						begin
							r_sleep_pad_cfg0[i] <= reg_if_wdata_i[i * 2];
							r_sleep_pad_cfg1[i] <= reg_if_wdata_i[(i * 2) + 1];
						end
				end
				6'b010101: begin : sv2v_autoblock_2
					reg signed [31:0] i;
					for (i = 0; i < 16; i = i + 1)
						begin
							r_sleep_pad_cfg0[16 + i] <= reg_if_wdata_i[i * 2];
							r_sleep_pad_cfg1[16 + i] <= reg_if_wdata_i[(i * 2) + 1];
						end
				end
				6'b010110: begin : sv2v_autoblock_3
					reg signed [31:0] i;
					for (i = 0; i < 16; i = i + 1)
						begin
							r_sleep_pad_cfg0[32 + i] <= reg_if_wdata_i[i * 2];
							r_sleep_pad_cfg1[32 + i] <= reg_if_wdata_i[(i * 2) + 1];
						end
				end
				6'b010111: begin : sv2v_autoblock_4
					reg signed [31:0] i;
					for (i = 0; i < 16; i = i + 1)
						begin
							r_sleep_pad_cfg0[48 + i] <= reg_if_wdata_i[i * 2];
							r_sleep_pad_cfg1[48 + i] <= reg_if_wdata_i[(i * 2) + 1];
						end
				end
				6'b011000: r_pad_sleep <= reg_if_wdata_i[0];
			endcase
		else if (s_rise & reg_if_wrn_i)
			case (reg_if_add_i)
				6'b000001:
					if (r_extevent)
						r_extevent <= 1'b0;
			endcase
		else if (r_extwake_en) begin
			r_extevent_sync <= {s_extwake_in, r_extevent_sync[2:1]};
			case (r_extwake_type)
				2'b00:
					if (s_extwake_rise)
						r_extevent <= 1'b1;
				2'b01:
					if (s_extwake_fall)
						r_extevent <= 1'b1;
				2'b10:
					if (r_extevent_sync[0])
						r_extevent <= 1'b1;
				2'b11:
					if (!r_extevent_sync[0])
						r_extevent <= 1'b1;
			endcase
		end
	always @(*)
		case (reg_if_add_i)
			6'b000000: reg_if_rdata_o = {3'h0, r_rar_rv_volt, 3'h0, r_rar_lv_volt, 3'h0, r_rar_mv_volt, 3'h0, r_rar_nv_volt};
			6'b000001: reg_if_rdata_o = s_pmu_sleep_control;
			6'b010100: begin : sv2v_autoblock_5
				reg signed [31:0] i;
				for (i = 0; i < 16; i = i + 1)
					begin
						reg_if_rdata_o[i * 2] = r_sleep_pad_cfg0[i];
						reg_if_rdata_o[(i * 2) + 1] = r_sleep_pad_cfg1[i];
					end
			end
			6'b010101: begin : sv2v_autoblock_6
				reg signed [31:0] i;
				for (i = 0; i < 16; i = i + 1)
					begin
						reg_if_rdata_o[i * 2] = r_sleep_pad_cfg0[16 + i];
						reg_if_rdata_o[(i * 2) + 1] = r_sleep_pad_cfg1[16 + i];
					end
			end
			6'b010110: begin : sv2v_autoblock_7
				reg signed [31:0] i;
				for (i = 0; i < 16; i = i + 1)
					begin
						reg_if_rdata_o[i * 2] = r_sleep_pad_cfg0[32 + i];
						reg_if_rdata_o[(i * 2) + 1] = r_sleep_pad_cfg1[32 + i];
					end
			end
			6'b010111: begin : sv2v_autoblock_8
				reg signed [31:0] i;
				for (i = 0; i < 16; i = i + 1)
					begin
						reg_if_rdata_o[i * 2] = r_sleep_pad_cfg0[48 + i];
						reg_if_rdata_o[(i * 2) + 1] = r_sleep_pad_cfg1[48 + i];
					end
			end
			6'b011000: reg_if_rdata_o = {31'h00000000, r_pad_sleep};
			6'b110111: reg_if_rdata_o = s_rtc_date;
			6'b110100: reg_if_rdata_o = s_rtc_clock;
			6'b110110: reg_if_rdata_o = s_rtc_timer;
			6'b110101: reg_if_rdata_o = s_rtc_alarm;
			default: reg_if_rdata_o = 'h0;
		endcase
	always @(*) begin : sv2v_autoblock_9
		reg signed [31:0] i;
		for (i = 0; i < 64; i = i + 1)
			begin
				pad_sleep_cfg_o[i * 2] = r_sleep_pad_cfg0[i];
				pad_sleep_cfg_o[(i * 2) + 1] = r_sleep_pad_cfg1[i];
			end
	end
	assign pad_sleep_mode_o = r_pad_sleep;
	assign s_pmu_sleep_control = {r_cfg_ret[10:0], r_cluster_wake, r_reboot, r_extevent, r_boot_l2, r_wakeup, r_extwake_en, r_extwake_type, r_extwake_sel, 3'h0, r_cfg_ret[11], r_cfg_ret[13:12]};
	assign pmu_sleep_control_o = s_pmu_sleep_control;
endmodule
