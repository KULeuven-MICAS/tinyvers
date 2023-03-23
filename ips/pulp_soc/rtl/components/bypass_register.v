module bypass_register (
	clk_i,
	rstn_i,
	wu_bypass_data_in,
	wu_bypass_en,
	wu_bypass_shift,
	wu_bypass_data_out,
	bypass_sleep_send_LOGIC,
	bypass_sleep_send_L2,
	bypass_sleep_send_L2_UDMA,
	bypass_sleep_send_L1,
	bypass_sleep_send_UDMA,
	bypass_isolate_LOGIC,
	bypass_isolate_L2,
	bypass_isolate_L2_UDMA,
	bypass_isolate_L1,
	bypass_isolate_UDMA,
	bypass_isolate_MRAM,
	bypass_clk_en_system,
	bypass_pg_logic_rstn_o,
	bypass_pg_udma_rstn_o,
	bypass_VDDA_out,
	bypass_VDD_out,
	bypass_VREF_out,
	bypass_PORb,
	bypass_RETb,
	bypass_RSTb,
	bypass_TRIM,
	bypass_DPD,
	bypass_CEb_HIGH
);
	input wire clk_i;
	input wire rstn_i;
	input wire wu_bypass_data_in;
	input wire wu_bypass_en;
	input wire wu_bypass_shift;
	output wire wu_bypass_data_out;
	output wire bypass_sleep_send_LOGIC;
	output wire bypass_sleep_send_L2;
	output wire bypass_sleep_send_L2_UDMA;
	output wire bypass_sleep_send_L1;
	output wire bypass_sleep_send_UDMA;
	output wire bypass_isolate_LOGIC;
	output wire bypass_isolate_L2;
	output wire bypass_isolate_L2_UDMA;
	output wire bypass_isolate_L1;
	output wire bypass_isolate_UDMA;
	output wire bypass_isolate_MRAM;
	output wire bypass_clk_en_system;
	output wire bypass_pg_logic_rstn_o;
	output wire bypass_pg_udma_rstn_o;
	output wire bypass_VDDA_out;
	output wire bypass_VDD_out;
	output wire bypass_VREF_out;
	output wire bypass_PORb;
	output wire bypass_RETb;
	output wire bypass_RSTb;
	output wire bypass_TRIM;
	output wire bypass_DPD;
	output wire bypass_CEb_HIGH;
	reg [23:0] bypass_reg_stage1;
	reg [23:0] bypass_reg_stage2;
	assign wu_bypass_data_out = bypass_reg_stage1[23];
	always @(posedge clk_i or negedge rstn_i)
		if (~rstn_i)
			bypass_reg_stage1 <= 1'sb0;
		else if (wu_bypass_en)
			bypass_reg_stage1 <= {bypass_reg_stage1[22:0], wu_bypass_data_in};
	always @(posedge clk_i or negedge rstn_i)
		if (~rstn_i)
			bypass_reg_stage2 <= 24'b000000000000011111111111;
		else if (~wu_bypass_en && wu_bypass_shift)
			bypass_reg_stage2 <= bypass_reg_stage1;
	assign bypass_sleep_send_LOGIC = bypass_reg_stage2[0];
	assign bypass_sleep_send_L2 = bypass_reg_stage2[1];
	assign bypass_sleep_send_L2_UDMA = bypass_reg_stage2[2];
	assign bypass_sleep_send_L1 = bypass_reg_stage2[3];
	assign bypass_sleep_send_UDMA = bypass_reg_stage2[4];
	assign bypass_isolate_LOGIC = bypass_reg_stage2[5];
	assign bypass_isolate_L2 = bypass_reg_stage2[6];
	assign bypass_isolate_L2_UDMA = bypass_reg_stage2[7];
	assign bypass_isolate_L1 = bypass_reg_stage2[8];
	assign bypass_isolate_UDMA = bypass_reg_stage2[9];
	assign bypass_isolate_MRAM = bypass_reg_stage2[10];
	assign bypass_clk_en_system = bypass_reg_stage2[11];
	assign bypass_pg_logic_rstn_o = bypass_reg_stage2[12];
	assign bypass_pg_udma_rstn_o = bypass_reg_stage2[13];
	assign bypass_VDDA_out = bypass_reg_stage2[14];
	assign bypass_VDD_out = bypass_reg_stage2[15];
	assign bypass_VREF_out = bypass_reg_stage2[16];
	assign bypass_PORb = bypass_reg_stage2[17];
	assign bypass_RETb = bypass_reg_stage2[18];
	assign bypass_RSTb = bypass_reg_stage2[19];
	assign bypass_TRIM = bypass_reg_stage2[20];
	assign bypass_DPD = bypass_reg_stage2[21];
	assign bypass_CEb_HIGH = bypass_reg_stage2[22];
endmodule
