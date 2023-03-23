module adv_timer_apb_if (
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
	events_en_o,
	events_sel_0_o,
	events_sel_1_o,
	events_sel_2_o,
	events_sel_3_o,
	timer0_counter_i,
	timer1_counter_i,
	timer2_counter_i,
	timer3_counter_i,
	timer0_start_o,
	timer0_stop_o,
	timer0_update_o,
	timer0_arm_o,
	timer0_rst_o,
	timer0_saw_o,
	timer0_in_mode_o,
	timer0_in_sel_o,
	timer0_in_clk_o,
	timer0_presc_o,
	timer0_th_hi_o,
	timer0_th_low_o,
	timer0_ch0_mode_o,
	timer0_ch0_flt_o,
	timer0_ch0_th_o,
	timer0_ch0_lut_o,
	timer0_ch1_mode_o,
	timer0_ch1_flt_o,
	timer0_ch1_th_o,
	timer0_ch1_lut_o,
	timer0_ch2_mode_o,
	timer0_ch2_flt_o,
	timer0_ch2_th_o,
	timer0_ch2_lut_o,
	timer0_ch3_mode_o,
	timer0_ch3_flt_o,
	timer0_ch3_th_o,
	timer0_ch3_lut_o,
	timer1_start_o,
	timer1_stop_o,
	timer1_update_o,
	timer1_arm_o,
	timer1_rst_o,
	timer1_saw_o,
	timer1_in_mode_o,
	timer1_in_sel_o,
	timer1_in_clk_o,
	timer1_presc_o,
	timer1_th_hi_o,
	timer1_th_low_o,
	timer1_ch0_mode_o,
	timer1_ch0_flt_o,
	timer1_ch0_th_o,
	timer1_ch0_lut_o,
	timer1_ch1_mode_o,
	timer1_ch1_flt_o,
	timer1_ch1_th_o,
	timer1_ch1_lut_o,
	timer1_ch2_mode_o,
	timer1_ch2_flt_o,
	timer1_ch2_th_o,
	timer1_ch2_lut_o,
	timer1_ch3_mode_o,
	timer1_ch3_flt_o,
	timer1_ch3_th_o,
	timer1_ch3_lut_o,
	timer2_start_o,
	timer2_stop_o,
	timer2_update_o,
	timer2_arm_o,
	timer2_rst_o,
	timer2_saw_o,
	timer2_in_mode_o,
	timer2_in_sel_o,
	timer2_in_clk_o,
	timer2_presc_o,
	timer2_th_hi_o,
	timer2_th_low_o,
	timer2_ch0_mode_o,
	timer2_ch0_flt_o,
	timer2_ch0_th_o,
	timer2_ch0_lut_o,
	timer2_ch1_mode_o,
	timer2_ch1_flt_o,
	timer2_ch1_th_o,
	timer2_ch1_lut_o,
	timer2_ch2_mode_o,
	timer2_ch2_flt_o,
	timer2_ch2_th_o,
	timer2_ch2_lut_o,
	timer2_ch3_mode_o,
	timer2_ch3_flt_o,
	timer2_ch3_th_o,
	timer2_ch3_lut_o,
	timer3_start_o,
	timer3_stop_o,
	timer3_update_o,
	timer3_arm_o,
	timer3_rst_o,
	timer3_saw_o,
	timer3_in_mode_o,
	timer3_in_sel_o,
	timer3_in_clk_o,
	timer3_presc_o,
	timer3_th_hi_o,
	timer3_th_low_o,
	timer3_ch0_mode_o,
	timer3_ch0_flt_o,
	timer3_ch0_th_o,
	timer3_ch0_lut_o,
	timer3_ch1_mode_o,
	timer3_ch1_flt_o,
	timer3_ch1_th_o,
	timer3_ch1_lut_o,
	timer3_ch2_mode_o,
	timer3_ch2_flt_o,
	timer3_ch2_th_o,
	timer3_ch2_lut_o,
	timer3_ch3_mode_o,
	timer3_ch3_flt_o,
	timer3_ch3_th_o,
	timer3_ch3_lut_o,
	timer0_clk_en_o,
	timer1_clk_en_o,
	timer2_clk_en_o,
	timer3_clk_en_o
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
	output wire [3:0] events_en_o;
	output wire [3:0] events_sel_0_o;
	output wire [3:0] events_sel_1_o;
	output wire [3:0] events_sel_2_o;
	output wire [3:0] events_sel_3_o;
	input wire [15:0] timer0_counter_i;
	input wire [15:0] timer1_counter_i;
	input wire [15:0] timer2_counter_i;
	input wire [15:0] timer3_counter_i;
	output wire timer0_start_o;
	output wire timer0_stop_o;
	output wire timer0_update_o;
	output wire timer0_arm_o;
	output wire timer0_rst_o;
	output wire timer0_saw_o;
	output wire [2:0] timer0_in_mode_o;
	output wire [7:0] timer0_in_sel_o;
	output wire timer0_in_clk_o;
	output wire [7:0] timer0_presc_o;
	output wire [15:0] timer0_th_hi_o;
	output wire [15:0] timer0_th_low_o;
	output wire [2:0] timer0_ch0_mode_o;
	output wire [1:0] timer0_ch0_flt_o;
	output wire [15:0] timer0_ch0_th_o;
	output wire [15:0] timer0_ch0_lut_o;
	output wire [2:0] timer0_ch1_mode_o;
	output wire [1:0] timer0_ch1_flt_o;
	output wire [15:0] timer0_ch1_th_o;
	output wire [15:0] timer0_ch1_lut_o;
	output wire [2:0] timer0_ch2_mode_o;
	output wire [1:0] timer0_ch2_flt_o;
	output wire [15:0] timer0_ch2_th_o;
	output wire [15:0] timer0_ch2_lut_o;
	output wire [2:0] timer0_ch3_mode_o;
	output wire [1:0] timer0_ch3_flt_o;
	output wire [15:0] timer0_ch3_th_o;
	output wire [15:0] timer0_ch3_lut_o;
	output wire timer1_start_o;
	output wire timer1_stop_o;
	output wire timer1_update_o;
	output wire timer1_arm_o;
	output wire timer1_rst_o;
	output wire timer1_saw_o;
	output wire [2:0] timer1_in_mode_o;
	output wire [7:0] timer1_in_sel_o;
	output wire timer1_in_clk_o;
	output wire [7:0] timer1_presc_o;
	output wire [15:0] timer1_th_hi_o;
	output wire [15:0] timer1_th_low_o;
	output wire [2:0] timer1_ch0_mode_o;
	output wire [1:0] timer1_ch0_flt_o;
	output wire [15:0] timer1_ch0_th_o;
	output wire [15:0] timer1_ch0_lut_o;
	output wire [2:0] timer1_ch1_mode_o;
	output wire [1:0] timer1_ch1_flt_o;
	output wire [15:0] timer1_ch1_th_o;
	output wire [15:0] timer1_ch1_lut_o;
	output wire [2:0] timer1_ch2_mode_o;
	output wire [1:0] timer1_ch2_flt_o;
	output wire [15:0] timer1_ch2_th_o;
	output wire [15:0] timer1_ch2_lut_o;
	output wire [2:0] timer1_ch3_mode_o;
	output wire [1:0] timer1_ch3_flt_o;
	output wire [15:0] timer1_ch3_th_o;
	output wire [15:0] timer1_ch3_lut_o;
	output wire timer2_start_o;
	output wire timer2_stop_o;
	output wire timer2_update_o;
	output wire timer2_arm_o;
	output wire timer2_rst_o;
	output wire timer2_saw_o;
	output wire [2:0] timer2_in_mode_o;
	output wire [7:0] timer2_in_sel_o;
	output wire timer2_in_clk_o;
	output wire [7:0] timer2_presc_o;
	output wire [15:0] timer2_th_hi_o;
	output wire [15:0] timer2_th_low_o;
	output wire [2:0] timer2_ch0_mode_o;
	output wire [1:0] timer2_ch0_flt_o;
	output wire [15:0] timer2_ch0_th_o;
	output wire [15:0] timer2_ch0_lut_o;
	output wire [2:0] timer2_ch1_mode_o;
	output wire [1:0] timer2_ch1_flt_o;
	output wire [15:0] timer2_ch1_th_o;
	output wire [15:0] timer2_ch1_lut_o;
	output wire [2:0] timer2_ch2_mode_o;
	output wire [1:0] timer2_ch2_flt_o;
	output wire [15:0] timer2_ch2_th_o;
	output wire [15:0] timer2_ch2_lut_o;
	output wire [2:0] timer2_ch3_mode_o;
	output wire [1:0] timer2_ch3_flt_o;
	output wire [15:0] timer2_ch3_th_o;
	output wire [15:0] timer2_ch3_lut_o;
	output wire timer3_start_o;
	output wire timer3_stop_o;
	output wire timer3_update_o;
	output wire timer3_arm_o;
	output wire timer3_rst_o;
	output wire timer3_saw_o;
	output wire [2:0] timer3_in_mode_o;
	output wire [7:0] timer3_in_sel_o;
	output wire timer3_in_clk_o;
	output wire [7:0] timer3_presc_o;
	output wire [15:0] timer3_th_hi_o;
	output wire [15:0] timer3_th_low_o;
	output wire [2:0] timer3_ch0_mode_o;
	output wire [1:0] timer3_ch0_flt_o;
	output wire [15:0] timer3_ch0_th_o;
	output wire [15:0] timer3_ch0_lut_o;
	output wire [2:0] timer3_ch1_mode_o;
	output wire [1:0] timer3_ch1_flt_o;
	output wire [15:0] timer3_ch1_th_o;
	output wire [15:0] timer3_ch1_lut_o;
	output wire [2:0] timer3_ch2_mode_o;
	output wire [1:0] timer3_ch2_flt_o;
	output wire [15:0] timer3_ch2_th_o;
	output wire [15:0] timer3_ch2_lut_o;
	output wire [2:0] timer3_ch3_mode_o;
	output wire [1:0] timer3_ch3_flt_o;
	output wire [15:0] timer3_ch3_th_o;
	output wire [15:0] timer3_ch3_lut_o;
	output wire timer0_clk_en_o;
	output wire timer1_clk_en_o;
	output wire timer2_clk_en_o;
	output wire timer3_clk_en_o;
	wire s_timer1_apb_in_clk;
	wire s_timer2_apb_in_clk;
	wire s_timer3_apb_in_clk;
	wire s_timer1_apb_start;
	wire s_timer1_apb_stop;
	wire s_timer2_apb_start;
	wire s_timer2_apb_stop;
	wire s_timer3_apb_start;
	wire s_timer3_apb_stop;
	reg [31:0] r_timer0_th;
	reg [7:0] r_timer0_presc;
	reg [7:0] r_timer0_in_sel;
	reg r_timer0_in_clk;
	reg [2:0] r_timer0_in_mode;
	reg r_timer0_start;
	reg r_timer0_stop;
	reg r_timer0_update;
	reg r_timer0_arm;
	reg r_timer0_rst;
	reg r_timer0_saw;
	reg [15:0] r_timer0_ch0_th;
	reg [2:0] r_timer0_ch0_mode;
	reg [15:0] r_timer0_ch0_lut;
	reg [1:0] r_timer0_ch0_flt;
	reg [15:0] r_timer0_ch1_th;
	reg [2:0] r_timer0_ch1_mode;
	reg [15:0] r_timer0_ch1_lut;
	reg [1:0] r_timer0_ch1_flt;
	reg [15:0] r_timer0_ch2_th;
	reg [2:0] r_timer0_ch2_mode;
	reg [15:0] r_timer0_ch2_lut;
	reg [1:0] r_timer0_ch2_flt;
	reg [15:0] r_timer0_ch3_th;
	reg [2:0] r_timer0_ch3_mode;
	reg [15:0] r_timer0_ch3_lut;
	reg [1:0] r_timer0_ch3_flt;
	reg [31:0] r_timer1_th;
	reg [7:0] r_timer1_presc;
	reg [7:0] r_timer1_in_sel;
	reg r_timer1_in_clk;
	reg [2:0] r_timer1_in_mode;
	reg r_timer1_start;
	reg r_timer1_stop;
	reg r_timer1_update;
	reg r_timer1_arm;
	reg r_timer1_rst;
	reg r_timer1_saw;
	reg [15:0] r_timer1_ch0_th;
	reg [2:0] r_timer1_ch0_mode;
	reg [15:0] r_timer1_ch0_lut;
	reg [1:0] r_timer1_ch0_flt;
	reg [15:0] r_timer1_ch1_th;
	reg [2:0] r_timer1_ch1_mode;
	reg [15:0] r_timer1_ch1_lut;
	reg [1:0] r_timer1_ch1_flt;
	reg [15:0] r_timer1_ch2_th;
	reg [2:0] r_timer1_ch2_mode;
	reg [15:0] r_timer1_ch2_lut;
	reg [1:0] r_timer1_ch2_flt;
	reg [15:0] r_timer1_ch3_th;
	reg [2:0] r_timer1_ch3_mode;
	reg [15:0] r_timer1_ch3_lut;
	reg [1:0] r_timer1_ch3_flt;
	reg [31:0] r_timer2_th;
	reg [7:0] r_timer2_presc;
	reg [7:0] r_timer2_in_sel;
	reg r_timer2_in_clk;
	reg [2:0] r_timer2_in_mode;
	reg r_timer2_start;
	reg r_timer2_stop;
	reg r_timer2_update;
	reg r_timer2_arm;
	reg r_timer2_rst;
	reg r_timer2_saw;
	reg [15:0] r_timer2_ch0_th;
	reg [2:0] r_timer2_ch0_mode;
	reg [15:0] r_timer2_ch0_lut;
	reg [1:0] r_timer2_ch0_flt;
	reg [15:0] r_timer2_ch1_th;
	reg [2:0] r_timer2_ch1_mode;
	reg [15:0] r_timer2_ch1_lut;
	reg [1:0] r_timer2_ch1_flt;
	reg [15:0] r_timer2_ch2_th;
	reg [2:0] r_timer2_ch2_mode;
	reg [15:0] r_timer2_ch2_lut;
	reg [1:0] r_timer2_ch2_flt;
	reg [15:0] r_timer2_ch3_th;
	reg [2:0] r_timer2_ch3_mode;
	reg [15:0] r_timer2_ch3_lut;
	reg [1:0] r_timer2_ch3_flt;
	reg [31:0] r_timer3_th;
	reg [7:0] r_timer3_presc;
	reg [7:0] r_timer3_in_sel;
	reg r_timer3_in_clk;
	reg [2:0] r_timer3_in_mode;
	reg r_timer3_start;
	reg r_timer3_stop;
	reg r_timer3_update;
	reg r_timer3_arm;
	reg r_timer3_rst;
	reg r_timer3_saw;
	reg [15:0] r_timer3_ch0_th;
	reg [2:0] r_timer3_ch0_mode;
	reg [15:0] r_timer3_ch0_lut;
	reg [1:0] r_timer3_ch0_flt;
	reg [15:0] r_timer3_ch1_th;
	reg [2:0] r_timer3_ch1_mode;
	reg [15:0] r_timer3_ch1_lut;
	reg [1:0] r_timer3_ch1_flt;
	reg [15:0] r_timer3_ch2_th;
	reg [2:0] r_timer3_ch2_mode;
	reg [15:0] r_timer3_ch2_lut;
	reg [1:0] r_timer3_ch2_flt;
	reg [15:0] r_timer3_ch3_th;
	reg [2:0] r_timer3_ch3_mode;
	reg [15:0] r_timer3_ch3_lut;
	reg [1:0] r_timer3_ch3_flt;
	reg [3:0] r_event_sel_0;
	reg [3:0] r_event_sel_1;
	reg [3:0] r_event_sel_2;
	reg [3:0] r_event_sel_3;
	reg [3:0] r_event_en;
	reg [3:0] r_clk_en;
	wire [7:0] s_apb_addr;
	assign events_en_o = r_event_en;
	assign events_sel_0_o = r_event_sel_0;
	assign events_sel_1_o = r_event_sel_1;
	assign events_sel_2_o = r_event_sel_2;
	assign events_sel_3_o = r_event_sel_3;
	assign timer0_start_o = r_timer0_start;
	assign timer0_stop_o = r_timer0_stop;
	assign timer0_update_o = r_timer0_update;
	assign timer0_rst_o = r_timer0_rst;
	assign timer0_arm_o = r_timer0_arm;
	assign timer0_saw_o = r_timer0_saw;
	assign timer0_in_mode_o = r_timer0_in_mode;
	assign timer0_in_sel_o = r_timer0_in_sel;
	assign timer0_in_clk_o = r_timer0_in_clk;
	assign timer0_presc_o = r_timer0_presc;
	assign timer0_th_hi_o = r_timer0_th[31:16];
	assign timer0_th_low_o = r_timer0_th[15:0];
	assign timer0_ch0_mode_o = r_timer0_ch0_mode;
	assign timer0_ch0_flt_o = r_timer0_ch0_flt;
	assign timer0_ch0_th_o = r_timer0_ch0_th;
	assign timer0_ch0_lut_o = r_timer0_ch0_lut;
	assign timer0_ch1_mode_o = r_timer0_ch1_mode;
	assign timer0_ch1_flt_o = r_timer0_ch1_flt;
	assign timer0_ch1_th_o = r_timer0_ch1_th;
	assign timer0_ch1_lut_o = r_timer0_ch1_lut;
	assign timer0_ch2_mode_o = r_timer0_ch2_mode;
	assign timer0_ch2_flt_o = r_timer0_ch2_flt;
	assign timer0_ch2_th_o = r_timer0_ch2_th;
	assign timer0_ch2_lut_o = r_timer0_ch2_lut;
	assign timer0_ch3_mode_o = r_timer0_ch3_mode;
	assign timer0_ch3_flt_o = r_timer0_ch3_flt;
	assign timer0_ch3_th_o = r_timer0_ch3_th;
	assign timer0_ch3_lut_o = r_timer0_ch3_lut;
	assign timer1_start_o = r_timer1_start;
	assign timer1_stop_o = r_timer1_stop;
	assign timer1_update_o = r_timer1_update;
	assign timer1_rst_o = r_timer1_rst;
	assign timer1_arm_o = r_timer1_arm;
	assign timer1_saw_o = r_timer1_saw;
	assign timer1_in_mode_o = r_timer1_in_mode;
	assign timer1_in_sel_o = r_timer1_in_sel;
	assign timer1_in_clk_o = r_timer1_in_clk;
	assign timer1_presc_o = r_timer1_presc;
	assign timer1_th_hi_o = r_timer1_th[31:16];
	assign timer1_th_low_o = r_timer1_th[15:0];
	assign timer1_ch0_mode_o = r_timer1_ch0_mode;
	assign timer1_ch0_flt_o = r_timer1_ch0_flt;
	assign timer1_ch0_th_o = r_timer1_ch0_th;
	assign timer1_ch0_lut_o = r_timer1_ch0_lut;
	assign timer1_ch1_mode_o = r_timer1_ch1_mode;
	assign timer1_ch1_flt_o = r_timer1_ch1_flt;
	assign timer1_ch1_th_o = r_timer1_ch1_th;
	assign timer1_ch1_lut_o = r_timer1_ch1_lut;
	assign timer1_ch2_mode_o = r_timer1_ch2_mode;
	assign timer1_ch2_flt_o = r_timer1_ch2_flt;
	assign timer1_ch2_th_o = r_timer1_ch2_th;
	assign timer1_ch2_lut_o = r_timer1_ch2_lut;
	assign timer1_ch3_mode_o = r_timer1_ch3_mode;
	assign timer1_ch3_flt_o = r_timer1_ch3_flt;
	assign timer1_ch3_th_o = r_timer1_ch3_th;
	assign timer1_ch3_lut_o = r_timer1_ch3_lut;
	assign timer2_start_o = r_timer2_start;
	assign timer2_stop_o = r_timer2_stop;
	assign timer2_update_o = r_timer2_update;
	assign timer2_rst_o = r_timer2_rst;
	assign timer2_arm_o = r_timer2_arm;
	assign timer2_saw_o = r_timer2_saw;
	assign timer2_in_mode_o = r_timer2_in_mode;
	assign timer2_in_sel_o = r_timer2_in_sel;
	assign timer2_in_clk_o = r_timer2_in_clk;
	assign timer2_presc_o = r_timer2_presc;
	assign timer2_th_hi_o = r_timer2_th[31:16];
	assign timer2_th_low_o = r_timer2_th[15:0];
	assign timer2_ch0_mode_o = r_timer2_ch0_mode;
	assign timer2_ch0_flt_o = r_timer2_ch0_flt;
	assign timer2_ch0_th_o = r_timer2_ch0_th;
	assign timer2_ch0_lut_o = r_timer2_ch0_lut;
	assign timer2_ch1_mode_o = r_timer2_ch1_mode;
	assign timer2_ch1_flt_o = r_timer2_ch1_flt;
	assign timer2_ch1_th_o = r_timer2_ch1_th;
	assign timer2_ch1_lut_o = r_timer2_ch1_lut;
	assign timer2_ch2_mode_o = r_timer2_ch2_mode;
	assign timer2_ch2_flt_o = r_timer2_ch2_flt;
	assign timer2_ch2_th_o = r_timer2_ch2_th;
	assign timer2_ch2_lut_o = r_timer2_ch2_lut;
	assign timer2_ch3_mode_o = r_timer2_ch3_mode;
	assign timer2_ch3_flt_o = r_timer2_ch3_flt;
	assign timer2_ch3_th_o = r_timer2_ch3_th;
	assign timer2_ch3_lut_o = r_timer2_ch3_lut;
	assign timer3_start_o = r_timer3_start;
	assign timer3_stop_o = r_timer3_stop;
	assign timer3_update_o = r_timer3_update;
	assign timer3_rst_o = r_timer3_rst;
	assign timer3_arm_o = r_timer3_arm;
	assign timer3_saw_o = r_timer3_saw;
	assign timer3_in_mode_o = r_timer3_in_mode;
	assign timer3_in_sel_o = r_timer3_in_sel;
	assign timer3_in_clk_o = r_timer3_in_clk;
	assign timer3_presc_o = r_timer3_presc;
	assign timer3_th_hi_o = r_timer3_th[31:16];
	assign timer3_th_low_o = r_timer3_th[15:0];
	assign timer3_ch0_mode_o = r_timer3_ch0_mode;
	assign timer3_ch0_flt_o = r_timer3_ch0_flt;
	assign timer3_ch0_th_o = r_timer3_ch0_th;
	assign timer3_ch0_lut_o = r_timer3_ch0_lut;
	assign timer3_ch1_mode_o = r_timer3_ch1_mode;
	assign timer3_ch1_flt_o = r_timer3_ch1_flt;
	assign timer3_ch1_th_o = r_timer3_ch1_th;
	assign timer3_ch1_lut_o = r_timer3_ch1_lut;
	assign timer3_ch2_mode_o = r_timer3_ch2_mode;
	assign timer3_ch2_flt_o = r_timer3_ch2_flt;
	assign timer3_ch2_th_o = r_timer3_ch2_th;
	assign timer3_ch2_lut_o = r_timer3_ch2_lut;
	assign timer3_ch3_mode_o = r_timer3_ch3_mode;
	assign timer3_ch3_flt_o = r_timer3_ch3_flt;
	assign timer3_ch3_th_o = r_timer3_ch3_th;
	assign timer3_ch3_lut_o = r_timer3_ch3_lut;
	assign timer0_clk_en_o = r_clk_en[0];
	assign timer1_clk_en_o = r_clk_en[1];
	assign timer2_clk_en_o = r_clk_en[2];
	assign timer3_clk_en_o = r_clk_en[3];
	assign s_apb_addr = PADDR[9:2];
	always @(posedge HCLK or negedge HRESETn)
		if (~HRESETn) begin
			r_timer0_th <= 'h0;
			r_timer0_in_sel <= 'h0;
			r_timer0_in_clk <= 'h0;
			r_timer0_in_mode <= 'h0;
			r_timer0_presc <= 'h0;
			r_timer0_start <= 1'b0;
			r_timer0_stop <= 1'b0;
			r_timer0_update <= 1'b0;
			r_timer0_arm <= 1'b0;
			r_timer0_rst <= 1'b0;
			r_timer0_saw <= 1'b1;
			r_timer0_ch0_th <= 'h0;
			r_timer0_ch0_mode <= 'h0;
			r_timer0_ch0_lut <= 'h0;
			r_timer0_ch0_flt <= 'h0;
			r_timer0_ch1_th <= 'h0;
			r_timer0_ch1_mode <= 'h0;
			r_timer0_ch1_lut <= 'h0;
			r_timer0_ch1_flt <= 'h0;
			r_timer0_ch2_th <= 'h0;
			r_timer0_ch2_mode <= 'h0;
			r_timer0_ch2_lut <= 'h0;
			r_timer0_ch2_flt <= 'h0;
			r_timer0_ch3_th <= 'h0;
			r_timer0_ch3_mode <= 'h0;
			r_timer0_ch3_lut <= 'h0;
			r_timer0_ch3_flt <= 'h0;
			r_timer1_th <= 'h0;
			r_timer1_in_sel <= 'h0;
			r_timer1_in_clk <= 'h0;
			r_timer1_in_mode <= 'h0;
			r_timer1_presc <= 'h0;
			r_timer1_start <= 1'b0;
			r_timer1_stop <= 1'b0;
			r_timer1_update <= 1'b0;
			r_timer1_rst <= 1'b0;
			r_timer1_arm <= 1'b0;
			r_timer1_saw <= 1'b1;
			r_timer1_ch0_th <= 'h0;
			r_timer1_ch0_mode <= 'h0;
			r_timer1_ch0_lut <= 'h0;
			r_timer1_ch0_flt <= 'h0;
			r_timer1_ch1_th <= 'h0;
			r_timer1_ch1_mode <= 'h0;
			r_timer1_ch1_lut <= 'h0;
			r_timer1_ch1_flt <= 'h0;
			r_timer1_ch2_th <= 'h0;
			r_timer1_ch2_mode <= 'h0;
			r_timer1_ch2_lut <= 'h0;
			r_timer1_ch2_flt <= 'h0;
			r_timer1_ch3_th <= 'h0;
			r_timer1_ch3_mode <= 'h0;
			r_timer1_ch3_lut <= 'h0;
			r_timer1_ch3_flt <= 'h0;
			r_timer2_th <= 'h0;
			r_timer2_in_sel <= 'h0;
			r_timer2_in_clk <= 'h0;
			r_timer2_in_mode <= 'h0;
			r_timer2_presc <= 'h0;
			r_timer2_start <= 1'b0;
			r_timer2_stop <= 1'b0;
			r_timer2_update <= 1'b0;
			r_timer2_rst <= 1'b0;
			r_timer2_arm <= 1'b0;
			r_timer2_saw <= 1'b1;
			r_timer2_ch0_th <= 'h0;
			r_timer2_ch0_mode <= 'h0;
			r_timer2_ch0_lut <= 'h0;
			r_timer2_ch0_flt <= 'h0;
			r_timer2_ch1_th <= 'h0;
			r_timer2_ch1_mode <= 'h0;
			r_timer2_ch1_lut <= 'h0;
			r_timer2_ch1_flt <= 'h0;
			r_timer2_ch2_th <= 'h0;
			r_timer2_ch2_mode <= 'h0;
			r_timer2_ch2_lut <= 'h0;
			r_timer2_ch2_flt <= 'h0;
			r_timer2_ch3_th <= 'h0;
			r_timer2_ch3_mode <= 'h0;
			r_timer2_ch3_lut <= 'h0;
			r_timer2_ch3_flt <= 'h0;
			r_timer3_th <= 'h0;
			r_timer3_in_sel <= 'h0;
			r_timer3_in_clk <= 'h0;
			r_timer3_in_mode <= 'h0;
			r_timer3_presc <= 'h0;
			r_timer3_start <= 1'b0;
			r_timer3_stop <= 1'b0;
			r_timer3_update <= 1'b0;
			r_timer3_rst <= 1'b0;
			r_timer3_arm <= 1'b0;
			r_timer3_saw <= 1'b1;
			r_timer3_ch0_th <= 'h0;
			r_timer3_ch0_mode <= 'h0;
			r_timer3_ch0_lut <= 'h0;
			r_timer3_ch0_flt <= 'h0;
			r_timer3_ch1_th <= 'h0;
			r_timer3_ch1_mode <= 'h0;
			r_timer3_ch1_lut <= 'h0;
			r_timer3_ch1_flt <= 'h0;
			r_timer3_ch2_th <= 'h0;
			r_timer3_ch2_mode <= 'h0;
			r_timer3_ch2_lut <= 'h0;
			r_timer3_ch2_flt <= 'h0;
			r_timer3_ch3_th <= 'h0;
			r_timer3_ch3_mode <= 'h0;
			r_timer3_ch3_lut <= 'h0;
			r_timer3_ch3_flt <= 'h0;
			r_event_sel_0 <= 'h0;
			r_event_sel_1 <= 'h0;
			r_event_sel_2 <= 'h0;
			r_event_sel_3 <= 'h0;
			r_event_en <= 'h0;
			r_clk_en <= 'h0;
		end
		else if ((PSEL && PENABLE) && PWRITE)
			case (s_apb_addr)
				8'b00000010: r_timer0_th <= PWDATA;
				8'b00000000: begin
					r_timer0_start <= PWDATA[0];
					r_timer0_stop <= PWDATA[1];
					r_timer0_update <= PWDATA[2];
					r_timer0_rst <= PWDATA[3];
					r_timer0_arm <= PWDATA[4];
				end
				8'b00000001: begin
					r_timer0_in_sel <= PWDATA[7:0];
					r_timer0_in_mode <= PWDATA[10:8];
					r_timer0_in_clk <= PWDATA[11];
					r_timer0_saw <= PWDATA[12];
					r_timer0_presc <= PWDATA[23:16];
				end
				8'b00000011: begin
					r_timer0_ch0_th <= PWDATA[15:0];
					r_timer0_ch0_mode <= PWDATA[18:16];
				end
				8'b00000111: begin
					r_timer0_ch0_lut <= PWDATA[15:0];
					r_timer0_ch0_flt <= PWDATA[17:16];
				end
				8'b00000100: begin
					r_timer0_ch1_th <= PWDATA[15:0];
					r_timer0_ch1_mode <= PWDATA[18:16];
				end
				8'b00001000: begin
					r_timer0_ch1_lut <= PWDATA[15:0];
					r_timer0_ch1_flt <= PWDATA[17:16];
				end
				8'b00000101: begin
					r_timer0_ch2_th <= PWDATA[15:0];
					r_timer0_ch2_mode <= PWDATA[18:16];
				end
				8'b00001001: begin
					r_timer0_ch2_lut <= PWDATA[15:0];
					r_timer0_ch2_flt <= PWDATA[17:16];
				end
				8'b00000110: begin
					r_timer0_ch3_th <= PWDATA[15:0];
					r_timer0_ch3_mode <= PWDATA[18:16];
				end
				8'b00001010: begin
					r_timer0_ch3_lut <= PWDATA[15:0];
					r_timer0_ch3_flt <= PWDATA[17:16];
				end
				8'b00010010: r_timer1_th <= PWDATA;
				8'b00010000: begin
					r_timer1_start <= PWDATA[0];
					r_timer1_stop <= PWDATA[1];
					r_timer1_update <= PWDATA[2];
					r_timer1_rst <= PWDATA[3];
					r_timer1_arm <= PWDATA[4];
				end
				8'b00010001: begin
					r_timer1_in_sel <= PWDATA[7:0];
					r_timer1_in_mode <= PWDATA[10:8];
					r_timer1_in_clk <= PWDATA[11];
					r_timer1_saw <= PWDATA[12];
					r_timer1_presc <= PWDATA[23:16];
				end
				8'b00010011: begin
					r_timer1_ch0_th <= PWDATA[15:0];
					r_timer1_ch0_mode <= PWDATA[18:16];
				end
				8'b00010111: begin
					r_timer1_ch0_lut <= PWDATA[15:0];
					r_timer1_ch0_flt <= PWDATA[17:16];
				end
				8'b00010100: begin
					r_timer1_ch1_th <= PWDATA[15:0];
					r_timer1_ch1_mode <= PWDATA[18:16];
				end
				8'b00011000: begin
					r_timer1_ch1_lut <= PWDATA[15:0];
					r_timer1_ch1_flt <= PWDATA[17:16];
				end
				8'b00010101: begin
					r_timer1_ch2_th <= PWDATA[15:0];
					r_timer1_ch2_mode <= PWDATA[18:16];
				end
				8'b00011001: begin
					r_timer1_ch2_lut <= PWDATA[15:0];
					r_timer1_ch2_flt <= PWDATA[17:16];
				end
				8'b00010110: begin
					r_timer1_ch3_th <= PWDATA[15:0];
					r_timer1_ch3_mode <= PWDATA[18:16];
				end
				8'b00011010: begin
					r_timer1_ch3_lut <= PWDATA[15:0];
					r_timer1_ch3_flt <= PWDATA[17:16];
				end
				8'b00100010: r_timer2_th <= PWDATA;
				8'b00100000: begin
					r_timer2_start <= PWDATA[0];
					r_timer2_stop <= PWDATA[1];
					r_timer2_update <= PWDATA[2];
					r_timer2_rst <= PWDATA[3];
					r_timer2_arm <= PWDATA[4];
				end
				8'b00100001: begin
					r_timer2_in_sel <= PWDATA[7:0];
					r_timer2_in_mode <= PWDATA[10:8];
					r_timer2_in_clk <= PWDATA[11];
					r_timer2_saw <= PWDATA[12];
					r_timer2_presc <= PWDATA[23:16];
				end
				8'b00100011: begin
					r_timer2_ch0_th <= PWDATA[15:0];
					r_timer2_ch0_mode <= PWDATA[18:16];
				end
				8'b00100111: begin
					r_timer2_ch0_lut <= PWDATA[15:0];
					r_timer2_ch0_flt <= PWDATA[17:16];
				end
				8'b00100100: begin
					r_timer2_ch1_th <= PWDATA[15:0];
					r_timer2_ch1_mode <= PWDATA[18:16];
				end
				8'b00101000: begin
					r_timer2_ch1_lut <= PWDATA[15:0];
					r_timer2_ch1_flt <= PWDATA[17:16];
				end
				8'b00100101: begin
					r_timer2_ch2_th <= PWDATA[15:0];
					r_timer2_ch2_mode <= PWDATA[18:16];
				end
				8'b00101001: begin
					r_timer2_ch2_lut <= PWDATA[15:0];
					r_timer2_ch2_flt <= PWDATA[17:16];
				end
				8'b00100110: begin
					r_timer2_ch3_th <= PWDATA[15:0];
					r_timer2_ch3_mode <= PWDATA[18:16];
				end
				8'b00101010: begin
					r_timer2_ch3_lut <= PWDATA[15:0];
					r_timer2_ch3_flt <= PWDATA[17:16];
				end
				8'b00110010: r_timer3_th <= PWDATA;
				8'b00110000: begin
					r_timer3_start <= PWDATA[0];
					r_timer3_stop <= PWDATA[1];
					r_timer3_update <= PWDATA[2];
					r_timer3_rst <= PWDATA[3];
					r_timer3_arm <= PWDATA[4];
				end
				8'b00110001: begin
					r_timer3_in_sel <= PWDATA[7:0];
					r_timer3_in_mode <= PWDATA[10:8];
					r_timer3_in_clk <= PWDATA[11];
					r_timer3_saw <= PWDATA[12];
					r_timer3_presc <= PWDATA[23:16];
				end
				8'b00110011: begin
					r_timer3_ch0_th <= PWDATA[15:0];
					r_timer3_ch0_mode <= PWDATA[18:16];
				end
				8'b00110111: begin
					r_timer3_ch0_lut <= PWDATA[15:0];
					r_timer3_ch0_flt <= PWDATA[17:16];
				end
				8'b00110100: begin
					r_timer3_ch1_th <= PWDATA[15:0];
					r_timer3_ch1_mode <= PWDATA[18:16];
				end
				8'b00111000: begin
					r_timer3_ch1_lut <= PWDATA[15:0];
					r_timer3_ch1_flt <= PWDATA[17:16];
				end
				8'b00110101: begin
					r_timer3_ch2_th <= PWDATA[15:0];
					r_timer3_ch2_mode <= PWDATA[18:16];
				end
				8'b00111001: begin
					r_timer3_ch2_lut <= PWDATA[15:0];
					r_timer3_ch2_flt <= PWDATA[17:16];
				end
				8'b00110110: begin
					r_timer3_ch3_th <= PWDATA[15:0];
					r_timer3_ch3_mode <= PWDATA[18:16];
				end
				8'b00111010: begin
					r_timer3_ch3_lut <= PWDATA[15:0];
					r_timer3_ch3_flt <= PWDATA[17:16];
				end
				8'b01000000: begin
					r_event_sel_0 <= PWDATA[3:0];
					r_event_sel_1 <= PWDATA[7:4];
					r_event_sel_2 <= PWDATA[11:8];
					r_event_sel_3 <= PWDATA[15:12];
					r_event_en <= PWDATA[19:16];
				end
				8'b01000001: r_clk_en <= PWDATA[3:0];
			endcase
		else begin
			r_timer0_start <= 1'b0;
			r_timer0_stop <= 1'b0;
			r_timer0_rst <= 1'b0;
			r_timer0_update <= 1'b0;
			r_timer0_arm <= 1'b0;
			r_timer1_start <= 1'b0;
			r_timer1_stop <= 1'b0;
			r_timer1_rst <= 1'b0;
			r_timer1_update <= 1'b0;
			r_timer1_arm <= 1'b0;
			r_timer2_start <= 1'b0;
			r_timer2_stop <= 1'b0;
			r_timer2_rst <= 1'b0;
			r_timer2_update <= 1'b0;
			r_timer2_arm <= 1'b0;
			r_timer3_start <= 1'b0;
			r_timer3_stop <= 1'b0;
			r_timer3_rst <= 1'b0;
			r_timer3_update <= 1'b0;
			r_timer3_arm <= 1'b0;
		end
	always @(*)
		case (s_apb_addr)
			8'b00000010: PRDATA = r_timer0_th;
			8'b00010010: PRDATA = r_timer1_th;
			8'b00100010: PRDATA = r_timer2_th;
			8'b00110010: PRDATA = r_timer3_th;
			8'b00000001: PRDATA = {8'h00, r_timer0_presc, 3'h0, r_timer0_saw, r_timer0_in_clk, r_timer0_in_mode, r_timer0_in_sel};
			8'b00000011: PRDATA = {13'h0000, r_timer0_ch0_mode, r_timer0_ch0_th};
			8'b00000111: PRDATA = {14'h0000, r_timer0_ch0_flt, r_timer0_ch0_lut};
			8'b00000100: PRDATA = {13'h0000, r_timer0_ch1_mode, r_timer0_ch1_th};
			8'b00001000: PRDATA = {14'h0000, r_timer0_ch1_flt, r_timer0_ch1_lut};
			8'b00000101: PRDATA = {13'h0000, r_timer0_ch2_mode, r_timer0_ch2_th};
			8'b00001001: PRDATA = {14'h0000, r_timer0_ch2_flt, r_timer0_ch2_lut};
			8'b00000110: PRDATA = {13'h0000, r_timer0_ch3_mode, r_timer0_ch3_th};
			8'b00001010: PRDATA = {14'h0000, r_timer0_ch3_flt, r_timer0_ch3_lut};
			8'b00010001: PRDATA = {8'h00, r_timer1_presc, 3'h0, r_timer1_saw, r_timer1_in_clk, r_timer1_in_mode, r_timer1_in_sel};
			8'b00010011: PRDATA = {13'h0000, r_timer1_ch0_mode, r_timer1_ch0_th};
			8'b00010111: PRDATA = {14'h0000, r_timer1_ch0_flt, r_timer1_ch0_lut};
			8'b00010100: PRDATA = {13'h0000, r_timer1_ch1_mode, r_timer1_ch1_th};
			8'b00011000: PRDATA = {14'h0000, r_timer1_ch1_flt, r_timer1_ch1_lut};
			8'b00010101: PRDATA = {13'h0000, r_timer1_ch2_mode, r_timer1_ch2_th};
			8'b00011001: PRDATA = {14'h0000, r_timer1_ch2_flt, r_timer1_ch2_lut};
			8'b00010110: PRDATA = {13'h0000, r_timer1_ch3_mode, r_timer1_ch3_th};
			8'b00011010: PRDATA = {14'h0000, r_timer1_ch3_flt, r_timer1_ch3_lut};
			8'b00100001: PRDATA = {8'h00, r_timer2_presc, 3'h0, r_timer2_saw, r_timer2_in_clk, r_timer2_in_mode, r_timer2_in_sel};
			8'b00100011: PRDATA = {13'h0000, r_timer2_ch0_mode, r_timer2_ch0_th};
			8'b00100111: PRDATA = {14'h0000, r_timer2_ch0_flt, r_timer2_ch0_lut};
			8'b00100100: PRDATA = {13'h0000, r_timer2_ch1_mode, r_timer2_ch1_th};
			8'b00101000: PRDATA = {14'h0000, r_timer2_ch1_flt, r_timer2_ch1_lut};
			8'b00100101: PRDATA = {13'h0000, r_timer2_ch2_mode, r_timer2_ch2_th};
			8'b00101001: PRDATA = {14'h0000, r_timer2_ch2_flt, r_timer2_ch2_lut};
			8'b00100110: PRDATA = {13'h0000, r_timer2_ch3_mode, r_timer2_ch3_th};
			8'b00101010: PRDATA = {14'h0000, r_timer2_ch3_flt, r_timer2_ch3_lut};
			8'b00110001: PRDATA = {8'h00, r_timer3_presc, 3'h0, r_timer3_saw, r_timer3_in_clk, r_timer3_in_mode, r_timer3_in_sel};
			8'b00110011: PRDATA = {13'h0000, r_timer3_ch0_mode, r_timer3_ch0_th};
			8'b00110111: PRDATA = {14'h0000, r_timer3_ch0_flt, r_timer3_ch0_lut};
			8'b00110100: PRDATA = {13'h0000, r_timer3_ch1_mode, r_timer3_ch1_th};
			8'b00111000: PRDATA = {14'h0000, r_timer3_ch1_flt, r_timer3_ch1_lut};
			8'b00110101: PRDATA = {13'h0000, r_timer3_ch2_mode, r_timer3_ch2_th};
			8'b00111001: PRDATA = {14'h0000, r_timer3_ch2_flt, r_timer3_ch2_lut};
			8'b00110110: PRDATA = {13'h0000, r_timer3_ch3_mode, r_timer3_ch3_th};
			8'b00111010: PRDATA = {14'h0000, r_timer3_ch3_flt, r_timer3_ch3_lut};
			8'b00001011: PRDATA = {16'h0000, timer0_counter_i};
			8'b00011011: PRDATA = {16'h0000, timer1_counter_i};
			8'b00101011: PRDATA = {16'h0000, timer2_counter_i};
			8'b00111011: PRDATA = {16'h0000, timer3_counter_i};
			8'b01000000: PRDATA = {12'h000, r_event_en, r_event_sel_3, r_event_sel_2, r_event_sel_1, r_event_sel_0};
			8'b01000001: PRDATA = {28'h0000000, r_clk_en};
			default: PRDATA = 'h0;
		endcase
	assign PREADY = 1'b1;
	assign PSLVERR = 1'b0;
endmodule
