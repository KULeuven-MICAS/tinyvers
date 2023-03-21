module power_gating_shift
  (
   input logic        sleep_send_LOGIC,
   input logic        sleep_send_L2,
   input logic        sleep_send_L2_UDMA,
   input logic        sleep_send_L1,
   input logic        sleep_send_UDMA,
   output  logic        sleep_ack_LOGIC,
   output  logic        sleep_ack_L2,
   output  logic        sleep_ack_L2_UDMA,
   output  logic        sleep_ack_L1,
   output  logic        sleep_ack_UDMA
/*
   output logic        sleep_send_LOGIC_shift,
   output logic        sleep_send_L2_shift,
   output logic        sleep_send_L2_UDMA_shift,
   output logic        sleep_send_L1_shift,
   output logic        sleep_send_UDMA_shift,
   input  logic        sleep_ack_LOGIC_shift,
   input  logic        sleep_ack_L2_shift,
   input  logic        sleep_ack_L2_UDMA_shift,
   input  logic        sleep_ack_L1_shift,
   input  logic        sleep_ack_UDMA_shift
*/
  );

  logic s_sleep_send_LOGIC;
  logic s_sleep_send_L2;
  logic s_sleep_send_L2_UDMA;
  logic s_sleep_send_L1;
  logic s_sleep_send_UDMA;
  logic s_sleep_ack_LOGIC;
  logic s_sleep_ack_L2;
  logic s_sleep_ack_L2_UDMA;
  logic s_sleep_ack_L1;
  logic s_sleep_ack_UDMA;

  //assign sleep_send_LOGIC_shift = s_sleep_send_LOGIC;
  //assign sleep_send_L2_shift = s_sleep_send_L2;
  //assign sleep_send_L2_UDMA_shift = s_sleep_send_L2_UDMA;
  //assign sleep_send_L1_shift = s_sleep_send_L1;
  //assign sleep_send_UDMA_shift = s_sleep_send_UDMA;

  //assign sleep_ack_LOGIC = s_sleep_ack_LOGIC;
 // assign sleep_ack_L2 = s_sleep_ack_L2;
 // assign sleep_ack_L2_UDMA = s_sleep_ack_L2_UDMA;
 // assign sleep_ack_L1 = s_sleep_ack_L1;
  //assign sleep_ack_UDMA = s_sleep_ack_UDMA;

  SC7P5T_BUFX4_CSC28L send_logic_buf (.A (sleep_send_LOGIC), .Z (s_sleep_send_LOGIC));
  SC7P5T_BUFX4_CSC28L send_l2_buf (.A (sleep_send_L2), .Z (s_sleep_send_L2));
  SC7P5T_BUFX4_CSC28L send_l2_udma_buf (.A (sleep_send_L2_UDMA), .Z (s_sleep_send_L2_UDMA));
  SC7P5T_BUFX4_CSC28L send_l1_buf (.A (sleep_send_L1), .Z (s_sleep_send_L1));
  SC7P5T_BUFX4_CSC28L send_udma_buf (.A (sleep_send_UDMA), .Z (s_sleep_send_UDMA));

  SC7P5T_BUFX4_CSC28L ack_logic_buf (.A (s_sleep_ack_LOGIC), .Z (sleep_ack_LOGIC));
  SC7P5T_BUFX4_CSC28L ack_l2_buf (.A (s_sleep_ack_L2), .Z (sleep_ack_L2));
  SC7P5T_BUFX4_CSC28L ack_l2_udma_buf (.A (s_sleep_ack_L2_UDMA), .Z (sleep_ack_L2_UDMA));
  SC7P5T_BUFX4_CSC28L ack_l1_buf (.A (s_sleep_ack_L1), .Z (sleep_ack_L1));
  SC7P5T_BUFX4_CSC28L ack_udma_buf (.A (s_sleep_ack_UDMA), .Z (sleep_ack_UDMA));

/*
  always_ff @(posedge clk_i, negedge rstn_i)
  begin
    if (~rstn_i) begin
      s_sleep_send_LOGIC = 1'b0;
      s_sleep_send_L2 = 1'b0;
      s_sleep_send_L2_UDMA = 1'b0;
      s_sleep_send_L1 = 1'b0;
      s_sleep_send_UDMA = 1'b0;

      sleep_ack_LOGIC = 1'b0;
      sleep_ack_L2 = 1'b0;
      sleep_ack_L2_UDMA = 1'b0;
      sleep_ack_L1 = 1'b0;
      sleep_ack_UDMA = 1'b0;
    end else begin
      s_sleep_send_LOGIC = sleep_send_LOGIC;
      s_sleep_send_L2 = sleep_send_L2;
      s_sleep_send_L2_UDMA = sleep_send_L2_UDMA;
      s_sleep_send_L1 = sleep_send_L1;
      s_sleep_send_UDMA = sleep_send_UDMA;

      sleep_ack_LOGIC = s_sleep_ack_LOGIC;
      sleep_ack_L2 = s_sleep_ack_L2;
      sleep_ack_L2_UDMA = s_sleep_ack_L2_UDMA;
      sleep_ack_L1 = s_sleep_ack_L1;
      sleep_ack_UDMA = s_sleep_ack_UDMA;
    end
  end
*/
  dummy_decap i_dummy_decap_shift();

endmodule
