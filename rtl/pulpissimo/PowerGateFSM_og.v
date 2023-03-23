module PowerGateFSM (
	clk,
	rst,
	power,
	sleep_send,
	sleep_ack,
	reset,
	isolate,
	clk_en,
	done
);
	input clk;
	input rst;
	input power;
	output reg sleep_send;
	input sleep_ack;
	output reg reset;
	output reg isolate;
	output reg clk_en;
	output wire done;
	parameter integer STATE_W = 3;
	reg [STATE_W - 1:0] state;
	reg [STATE_W - 1:0] state_nxt;
	function automatic [STATE_W - 1:0] sv2v_cast_B8280;
		input reg [STATE_W - 1:0] inp;
		sv2v_cast_B8280 = inp;
	endfunction
	always @(posedge clk or negedge rst)
		if (rst == 0)
			state <= sv2v_cast_B8280(5);
		else
			state <= state_nxt;
	always @(*) begin
		state_nxt = sv2v_cast_B8280(0);
		case (state)
			sv2v_cast_B8280(0):
				if (power)
					state_nxt = state;
				else
					state_nxt = sv2v_cast_B8280(1);
			sv2v_cast_B8280(1):
				if (power)
					state_nxt = sv2v_cast_B8280(0);
				else
					state_nxt = sv2v_cast_B8280(2);
			sv2v_cast_B8280(2):
				if (power)
					state_nxt = sv2v_cast_B8280(1);
				else
					state_nxt = sv2v_cast_B8280(3);
			sv2v_cast_B8280(3):
				if (power)
					state_nxt = sv2v_cast_B8280(2);
				else
					state_nxt = sv2v_cast_B8280(4);
			sv2v_cast_B8280(4):
				if (sleep_ack == sleep_send) begin
					if (power)
						state_nxt = sv2v_cast_B8280(3);
					else
						state_nxt = sv2v_cast_B8280(5);
				end
				else
					state_nxt = state;
			sv2v_cast_B8280(5):
				if (power)
					state_nxt = sv2v_cast_B8280(4);
				else
					state_nxt = state;
			default: state_nxt = sv2v_cast_B8280(5);
		endcase
	end
	assign done = ((state == sv2v_cast_B8280(5)) && ~power) || ((state == sv2v_cast_B8280(0)) && power);
	reg clk_en_nxt;
	reg reset_nxt;
	reg isolate_nxt;
	reg sleep_send_nxt;
	wire [1:1] sv2v_tmp_clk_en_reg_dout;
	always @(*) clk_en = sv2v_tmp_clk_en_reg_dout;
	reg_arstn #(
		.DATA_W(1),
		.PRESET_VAL('b0)
	) clk_en_reg(
		.clk(clk),
		.arst_n(rst),
		.din(clk_en_nxt),
		.dout(sv2v_tmp_clk_en_reg_dout),
		.wen(1'b1)
	);
	wire [1:1] sv2v_tmp_reset_reg_dout;
	always @(*) reset = sv2v_tmp_reset_reg_dout;
	reg_arstn #(
		.DATA_W(1),
		.PRESET_VAL('b0)
	) reset_reg(
		.clk(clk),
		.arst_n(rst),
		.din(reset_nxt),
		.dout(sv2v_tmp_reset_reg_dout),
		.wen(1'b1)
	);
	wire [1:1] sv2v_tmp_isolate_reg_dout;
	always @(*) isolate = sv2v_tmp_isolate_reg_dout;
	reg_arstn #(
		.DATA_W(1),
		.PRESET_VAL('b1)
	) isolate_reg(
		.clk(clk),
		.arst_n(rst),
		.din(isolate_nxt),
		.dout(sv2v_tmp_isolate_reg_dout),
		.wen(1'b1)
	);
	wire [1:1] sv2v_tmp_sleep_send_reg_dout;
	always @(*) sleep_send = sv2v_tmp_sleep_send_reg_dout;
	reg_arstn #(
		.DATA_W(1),
		.PRESET_VAL('b1)
	) sleep_send_reg(
		.clk(clk),
		.arst_n(rst),
		.din(sleep_send_nxt),
		.dout(sv2v_tmp_sleep_send_reg_dout),
		.wen(1'b1)
	);
	always @(*) begin
		clk_en_nxt = 1'b1;
		reset_nxt = 1'b0;
		isolate_nxt = 1'b0;
		sleep_send_nxt = 1'b0;
		case (state)
			sv2v_cast_B8280(0): begin
				clk_en_nxt = 1'b1;
				reset_nxt = 1'b1;
				isolate_nxt = 1'b0;
				sleep_send_nxt = 1'b0;
			end
			sv2v_cast_B8280(1): begin
				clk_en_nxt = power;
				reset_nxt = 1'b1;
				isolate_nxt = 1'b0;
				sleep_send_nxt = 1'b0;
			end
			sv2v_cast_B8280(2): begin
				clk_en_nxt = 1'b0;
				reset_nxt = 1'b1;
				isolate_nxt = ~power;
				sleep_send_nxt = 1'b0;
			end
			sv2v_cast_B8280(3): begin
				clk_en_nxt = 1'b0;
				reset_nxt = power;
				isolate_nxt = 1'b1;
				sleep_send_nxt = 1'b0;
			end
			sv2v_cast_B8280(4): begin
				clk_en_nxt = 1'b0;
				reset_nxt = 1'b0;
				isolate_nxt = 1'b1;
				sleep_send_nxt = ~power;
			end
			sv2v_cast_B8280(5): begin
				clk_en_nxt = 1'b0;
				reset_nxt = 1'b0;
				isolate_nxt = 1'b1;
				sleep_send_nxt = 1'b1;
			end
			default: begin
				clk_en_nxt = 1'b1;
				reset_nxt = 1'b1;
				isolate_nxt = 1'b0;
				sleep_send_nxt = 1'b0;
			end
		endcase
	end
endmodule
