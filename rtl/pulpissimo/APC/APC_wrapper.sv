module APC_wrapper (
	input            clk,
	input            rst,
	input            power,
	output reg [2:0] enable_PD_send,
	input      [2:0] enable_PD_ack,
	output reg       reset,
	output reg       isolate,
	output reg       clk_en,
	output           done
);

wire [2:0] sleep_send, sleep_ack;
assign enable_PD_send = ~sleep_send;
assign sleep_ack  = ~enable_PD_ack;
assign reset  = ~isolate;
assign clk_en = ~isolate;
reg APC_req_nxt;
wire power_d, APC_req, APC_accept;

reg_arstn #(1,'b0) power_d_reg   (clk, rst, power,       power_d, 1'b1);
reg_arstn #(1,'b0) APC_req_reg   (clk, rst, APC_req_nxt, APC_req, 1'b1);

always_comb begin
  if(power!=power_d) begin
    APC_req_nxt = 1'b1;
  end else begin
    if(APC_accept) begin
      APC_req_nxt = 1'b0;
    end else begin
      APC_req_nxt = APC_req;
    end
  end
end
assign done = ((APC_req_nxt == 0) && (APC_accept == 0));

click_apc_wrapper click_apc_wrapper_i (
 //General
 .i_pclk         (clk),
 .i_prst_n       (rst),
 //Control interface
 .i_preq         (APC_req),
 .i_pstate       ({power, power, 5'b00000}),
 .o_paccept      (APC_accept),
 .o_pdeny        (),
 .o_pactive      (),
 //Status interface
 .o_ctrl_iso_ctrl(isolate),
 .o_ctrl_retain  (),
 //Power switches interface
 .o_psw_pwr_req  (sleep_send),
 .i_psw_pwr_ack  (sleep_ack),
 //Test interface
 .i_scan_mode    (1'b0)
);

endmodule
