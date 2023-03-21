module bypass_register
(
  input logic clk_i,
  input logic rstn_i,
  input logic wu_bypass_data_in,
  input logic wu_bypass_en,
  input logic wu_bypass_shift,
  output logic wu_bypass_data_out,
  output logic bypass_sleep_send_LOGIC,
  output logic bypass_sleep_send_L2,
  output logic bypass_sleep_send_L2_UDMA, 
  output logic bypass_sleep_send_L1,
  output logic bypass_sleep_send_UDMA,
  output logic bypass_isolate_LOGIC,
  output logic bypass_isolate_L2,
  output logic bypass_isolate_L2_UDMA,
  output logic bypass_isolate_L1,
  output logic bypass_isolate_UDMA,
  output logic bypass_isolate_MRAM,
  output logic bypass_clk_en_system,
  output logic bypass_pg_logic_rstn_o,
  output logic bypass_pg_udma_rstn_o,
  output logic bypass_VDDA_out,
  output logic bypass_VDD_out,
  output logic bypass_VREF_out,
  output logic bypass_PORb,
  output logic bypass_RETb,
  output logic bypass_RSTb,
  output logic bypass_TRIM,
  output logic bypass_DPD,
  output logic bypass_CEb_HIGH
);

  logic [23:0] bypass_reg_stage1;
  logic [23:0] bypass_reg_stage2;

  assign wu_bypass_data_out = bypass_reg_stage1[23];

  // WU bypass logic- fill stage 1 bypass reg
  always_ff @(posedge clk_i, negedge rstn_i)
    begin
       if (~rstn_i) begin
          bypass_reg_stage1 <= '0;
       end else begin
          if (wu_bypass_en) begin
             bypass_reg_stage1 <= {bypass_reg_stage1[22:0],wu_bypass_data_in};
          end
       end // else: !if(~rstn_i)
    end // always_ff @

  // WU bypass logic- fill stage 2 bypass reg
  always_ff @(posedge clk_i, negedge rstn_i)
    begin
       if (~rstn_i) begin
          bypass_reg_stage2 <= 24'b000000000000011111111111;
       end else begin
          if (~wu_bypass_en && wu_bypass_shift) begin
             bypass_reg_stage2 <= bypass_reg_stage1;
          end
       end // else: !if(~rstn_i)
    end // always_ff @

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
