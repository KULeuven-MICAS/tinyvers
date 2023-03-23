module rtc_date (
	clk_i,
	rstn_i,
	date_update_i,
	date_i,
	date_o,
	new_day_i
);
	input wire clk_i;
	input wire rstn_i;
	input wire date_update_i;
	input wire [31:0] date_i;
	output wire [31:0] date_o;
	input wire new_day_i;
	wire [5:0] s_day;
	wire [4:0] s_month;
	wire [13:0] s_year;
	reg [5:0] r_day;
	reg [4:0] r_month;
	reg [13:0] r_year;
	reg s_end_of_month;
	wire s_end_of_year;
	wire s_year_century;
	wire s_year_400;
	wire s_year_leap;
	wire s_year_div_4;
	assign s_day = date_i[5:0];
	assign s_month = date_i[12:8];
	assign s_year = date_i[29:16];
	assign date_o = {2'b00, r_year, 3'b000, r_month, 2'b00, r_day};
	assign s_end_of_year = s_end_of_month & (r_month == 5'h12);
	always @(*)
		case (r_month)
			5'h01: s_end_of_month = r_day == 6'h31;
			5'h02: s_end_of_month = (r_day == 6'h29) || (~s_year_leap && (r_day == 6'h28));
			5'h03: s_end_of_month = r_day == 6'h31;
			5'h04: s_end_of_month = r_day == 6'h30;
			5'h05: s_end_of_month = r_day == 6'h31;
			5'h06: s_end_of_month = r_day == 6'h30;
			5'h07: s_end_of_month = r_day == 6'h31;
			5'h08: s_end_of_month = r_day == 6'h31;
			5'h09: s_end_of_month = r_day == 6'h30;
			5'h10: s_end_of_month = r_day == 6'h31;
			5'h11: s_end_of_month = r_day == 6'h30;
			5'h12: s_end_of_month = r_day == 6'h31;
			default: s_end_of_month = 1'b0;
		endcase
	assign s_year_div_4 = ~r_year[0] && (r_year[4] == r_year[1]);
	assign s_year_century = r_year[7:0] == 8'h00;
	assign s_year_400 = ~r_year[8] && (r_year[12] == r_year[9]);
	assign s_year_leap = s_year_div_4 && (~s_year_century || (s_year_century && s_year_400));
	always @(posedge clk_i or negedge rstn_i) begin : proc_r_day
		if (~rstn_i)
			r_day <= 6'h01;
		else if (date_update_i)
			r_day <= s_day;
		else if (new_day_i && s_end_of_month)
			r_day <= 6'h01;
		else if (new_day_i && (r_day[3:0] != 4'h9))
			r_day[3:0] <= r_day[3:0] + 4'h1;
		else if (new_day_i) begin
			r_day[3:0] <= 4'h0;
			r_day[5:4] <= r_day[5:4] + 2'h1;
		end
	end
	always @(posedge clk_i or negedge rstn_i) begin : proc_r_month
		if (~rstn_i)
			r_month <= 5'h01;
		else if (date_update_i)
			r_month <= s_month;
		else if (new_day_i && s_end_of_year)
			r_month <= 5'h01;
		else if ((new_day_i && s_end_of_month) && (r_month[3:0] != 4'h9))
			r_month[3:0] <= r_month[3:0] + 4'h1;
		else if (new_day_i && s_end_of_month) begin
			r_month[3:0] <= 4'h0;
			r_month[4] <= 1;
		end
	end
	always @(posedge clk_i or negedge rstn_i) begin : proc_r_year
		if (~rstn_i)
			r_year <= 14'h2000;
		else if (date_update_i)
			r_year <= s_year;
		else if (new_day_i && s_end_of_year)
			if (r_year[3:0] != 4'h9)
				r_year[3:0] <= r_year[3:0] + 4'h1;
			else begin
				r_year[3:0] <= 4'h0;
				if (r_year[7:4] != 4'h9)
					r_year[7:4] <= r_year[7:4] + 4'h1;
				else begin
					r_year[7:4] <= 4'h0;
					if (r_year[11:8] != 4'h9)
						r_year[11:8] <= r_year[11:8] + 4'h1;
					else begin
						r_year[11:8] <= 4'h0;
						r_year[13:12] <= r_year[13:12] + 2'h1;
					end
				end
			end
	end
endmodule
