module APC_wrapper (
	clk,
	rst,
	power,
	enable_PD_send,
	enable_PD_ack,
	reset,
	isolate,
	clk_en,
	done
);
	input clk;
	input rst;
	input power;
	output reg [2:0] enable_PD_send;
	input [2:0] enable_PD_ack;
	output reg reset;
	output reg isolate;
	output reg clk_en;
	output wire done;
	wire [2:0] sleep_send;
	wire [2:0] sleep_ack;
	wire [3:1] sv2v_tmp_36916;
	assign sv2v_tmp_36916 = ~sleep_send;
	always @(*) enable_PD_send = sv2v_tmp_36916;
	assign sleep_ack = ~enable_PD_ack;
	wire [1:1] sv2v_tmp_AC4CD;
	assign sv2v_tmp_AC4CD = ~isolate;
	always @(*) reset = sv2v_tmp_AC4CD;
	wire [1:1] sv2v_tmp_9879D;
	assign sv2v_tmp_9879D = ~isolate;
	always @(*) clk_en = sv2v_tmp_9879D;
	reg APC_req_nxt;
	wire power_d;
	wire APC_req;
	wire APC_accept;
	reg_arstn #(
		1,
		'b0
	) power_d_reg(
		clk,
		rst,
		power,
		power_d,
		1'b1
	);
	reg_arstn #(
		1,
		'b0
	) APC_req_reg(
		clk,
		rst,
		APC_req_nxt,
		APC_req,
		1'b1
	);
	always @(*)
		if (power != power_d)
			APC_req_nxt = 1'b1;
		else if (APC_accept)
			APC_req_nxt = 1'b0;
		else
			APC_req_nxt = APC_req;
	assign done = (APC_req_nxt == 0) && (APC_accept == 0);
	click_apc_wrapper click_apc_wrapper_i(
		.i_pclk(clk),
		.i_prst_n(rst),
		.i_preq(APC_req),
		.i_pstate({power, power, 5'b00000}),
		.o_paccept(APC_accept),
		.o_pdeny(),
		.o_pactive(),
		.o_ctrl_iso_ctrl(isolate),
		.o_ctrl_retain(),
		.o_psw_pwr_req(sleep_send),
		.i_psw_pwr_ack(sleep_ack),
		.i_scan_mode(1'b0)
	);
endmodule
