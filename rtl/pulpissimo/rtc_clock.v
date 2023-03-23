module rtc_clock (
	clk_i,
	rstn_i,
	clock_update_i,
	clock_o,
	clock_i,
	init_sec_cnt_i,
	timer_update_i,
	timer_enable_i,
	timer_retrig_i,
	timer_target_i,
	timer_value_o,
	alarm_enable_i,
	alarm_update_i,
	alarm_clock_i,
	alarm_clock_o,
	event_o,
	update_day_o
);
	input wire clk_i;
	input wire rstn_i;
	input wire clock_update_i;
	output wire [21:0] clock_o;
	input wire [21:0] clock_i;
	input wire [9:0] init_sec_cnt_i;
	input wire timer_update_i;
	input wire timer_enable_i;
	input wire timer_retrig_i;
	input wire [16:0] timer_target_i;
	output wire [16:0] timer_value_o;
	input wire alarm_enable_i;
	input wire alarm_update_i;
	input wire [21:0] alarm_clock_i;
	output wire [21:0] alarm_clock_o;
	output wire event_o;
	output wire update_day_o;
	reg [7:0] r_seconds;
	reg [7:0] r_minutes;
	reg [6:0] r_hours;
	wire [7:0] s_seconds;
	wire [7:0] s_minutes;
	wire [6:0] s_hours;
	reg [7:0] r_alarm_seconds;
	reg [7:0] r_alarm_minutes;
	reg [6:0] r_alarm_hours;
	reg r_alarm_enable;
	wire [7:0] s_alarm_seconds;
	wire [7:0] s_alarm_minutes;
	wire [5:0] s_alarm_hours;
	reg [14:0] r_sec_counter;
	wire s_update_seconds;
	wire s_update_minutes;
	wire s_update_hours;
	wire s_alarm_match;
	reg r_alarm_match;
	wire s_alarm_event;
	wire s_timer_event;
	reg [16:0] r_timer;
	reg [16:0] r_timer_target;
	reg r_timer_en;
	reg r_timer_retrig;
	assign s_seconds = clock_i[7:0];
	assign s_minutes = clock_i[15:8];
	assign s_hours = clock_i[21:16];
	assign s_alarm_seconds = alarm_clock_i[7:0];
	assign s_alarm_minutes = alarm_clock_i[15:8];
	assign s_alarm_hours = alarm_clock_i[21:16];
	assign s_alarm_match = ((r_seconds == s_alarm_seconds) & (r_minutes == s_alarm_minutes)) & (r_hours == s_alarm_hours);
	assign s_alarm_event = (r_alarm_enable & s_alarm_match) & ~r_alarm_match;
	wire s_timer_match;
	assign s_timer_match = r_timer == r_timer_target;
	assign s_timer_event = r_timer_en & s_timer_match;
	assign s_update_seconds = r_sec_counter == 15'h7fff;
	assign s_update_minutes = s_update_seconds & (r_seconds == 8'h59);
	assign s_update_hours = s_update_minutes & (r_minutes == 8'h59);
	assign event_o = s_alarm_event | s_timer_event;
	assign update_day_o = s_update_hours & (r_hours == 6'h23);
	assign clock_o = {r_hours, r_minutes, r_seconds};
	assign alarm_clock_o = {r_alarm_hours, r_alarm_minutes, r_alarm_seconds};
	assign timer_value_o = r_timer;
	always @(posedge clk_i or negedge rstn_i)
		if (~rstn_i) begin
			r_alarm_seconds <= 'h0;
			r_alarm_minutes <= 'h0;
			r_alarm_hours <= 'h0;
			r_alarm_enable <= 'h0;
		end
		else if (alarm_update_i) begin
			r_alarm_enable <= alarm_enable_i;
			r_alarm_seconds <= s_alarm_seconds;
			r_alarm_minutes <= s_alarm_minutes;
			r_alarm_hours <= s_alarm_hours;
		end
		else if (s_alarm_event)
			r_alarm_enable <= 'h0;
	always @(posedge clk_i or negedge rstn_i)
		if (~rstn_i)
			r_alarm_match <= 'h0;
		else
			r_alarm_match <= s_alarm_match;
	always @(posedge clk_i or negedge rstn_i)
		if (~rstn_i) begin
			r_timer_en <= 'h0;
			r_timer_target <= 'h0;
			r_timer <= 'h0;
			r_timer_retrig <= 'h0;
		end
		else if (timer_update_i) begin
			r_timer_en <= timer_enable_i;
			r_timer_target <= timer_target_i;
			r_timer_retrig <= timer_retrig_i;
			r_timer <= 'h0;
		end
		else if (r_timer_en)
			if (s_timer_match) begin
				if (!r_timer_retrig)
					r_timer_en <= 0;
				r_timer <= 'h0;
			end
			else
				r_timer <= r_timer + 1;
	always @(posedge clk_i or negedge rstn_i)
		if (~rstn_i)
			r_sec_counter <= 'h0;
		else if (clock_update_i)
			r_sec_counter <= {init_sec_cnt_i, 5'h00};
		else
			r_sec_counter <= r_sec_counter + 1;
	always @(posedge clk_i or negedge rstn_i)
		if (~rstn_i) begin
			r_seconds <= 0;
			r_minutes <= 0;
			r_hours <= 0;
		end
		else if (clock_update_i) begin
			r_seconds <= s_seconds;
			r_minutes <= s_minutes;
			r_hours <= s_hours;
		end
		else begin
			if (s_update_seconds) begin
				if (r_seconds[3:0] >= 4'h9)
					r_seconds[3:0] <= 4'h0;
				else
					r_seconds[3:0] <= r_seconds[3:0] + 4'h1;
				if (r_seconds >= 8'h59)
					r_seconds[7:4] <= 4'h0;
				else if (r_seconds[3:0] >= 4'h9)
					r_seconds[7:4] <= r_seconds[7:4] + 4'h1;
			end
			if (s_update_minutes) begin
				if (r_minutes[3:0] >= 4'h9)
					r_minutes[3:0] <= 4'h0;
				else
					r_minutes[3:0] <= r_minutes[3:0] + 4'h1;
				if (r_minutes >= 8'h59)
					r_minutes[7:4] <= 4'h0;
				else if (r_minutes[3:0] >= 4'h9)
					r_minutes[7:4] <= r_minutes[7:4] + 4'h1;
			end
			if (s_update_hours)
				if (r_hours >= 6'h23)
					r_hours <= 6'h00;
				else if (r_hours[3:0] >= 4'h9) begin
					r_hours[3:0] <= 4'h0;
					r_hours[5:4] <= r_hours[5:4] + 2'h1;
				end
				else
					r_hours[3:0] <= r_hours[3:0] + 4'h1;
		end
endmodule
