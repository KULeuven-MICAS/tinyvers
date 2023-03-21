module PowerGateFSM (
	input      clk,
	input      rst,
	input      power,
        input      external_pg,
        input      sleep_send_byp,
	output reg sleep_send,
	input      sleep_ack,
	output reg reset,
        input      wu_bypass_mux,
        input      isolate_byp,
	output reg isolate,
	output reg clk_en,
	output     done
);

parameter integer STATE_W = 3;
typedef enum logic[STATE_W-1:0] {POWER_ON, CLK_ENABLE, ISOLATE, RESET, SWITCH_POWER_1, SWITCH_POWER_2, POWER_OFF} state_type;

reg sleep_send_int;
reg isolate_int;
reg isolate_byp_int;

always_comb begin
    if (wu_bypass_mux) begin
        isolate = isolate_byp;
        sleep_send = sleep_send_byp;
    end
    else begin
        isolate = isolate_int;
        sleep_send = sleep_send_int;
    end
end

state_type state;
state_type  state_nxt;
always@(posedge clk, negedge rst) begin
	if(rst==0)begin
		state<=POWER_OFF;
	end else begin
		state<=state_nxt;
	end
end

always@(*)begin
	state_nxt = POWER_ON;
	case(state)
		POWER_ON:begin
			if(power || external_pg) begin state_nxt = state; end
			else      begin state_nxt = CLK_ENABLE; end
		end
		CLK_ENABLE:begin
			if(power || external_pg) begin state_nxt = POWER_ON; end
			else      begin state_nxt = ISOLATE; end
		end
		ISOLATE:begin
			if(power || external_pg) begin state_nxt = CLK_ENABLE; end
			else      begin state_nxt = RESET; end
		end
		RESET:begin
			if(power || external_pg) begin state_nxt = ISOLATE; end
			else      begin state_nxt = SWITCH_POWER_1; end
		end
		SWITCH_POWER_1:begin
			if(sleep_ack==sleep_send_int)
				if(power || external_pg) begin state_nxt = RESET; end
				else      begin state_nxt = SWITCH_POWER_2; end
			else
				state_nxt = state;
		end
                SWITCH_POWER_2:begin
                        if(power || external_pg) begin state_nxt = SWITCH_POWER_1; end
                        else       begin state_nxt = POWER_OFF; end
                end
		POWER_OFF:begin
			if(power || external_pg) begin state_nxt = SWITCH_POWER_2; end
			else      begin state_nxt = state; end
		end
		default:begin
			state_nxt = POWER_OFF;
		end
	endcase
end

assign done = ((state==POWER_OFF) && (~power)) || ((state==POWER_ON) && (power) );

reg clk_en_nxt, reset_nxt, isolate_nxt, sleep_send_nxt;
reg_arstn #(1,'b0) clk_en_reg     (clk, rst, clk_en_nxt,     clk_en,     1'b1);
reg_arstn #(1,'b0) reset_reg      (clk, rst, reset_nxt,      reset,      1'b1);
reg_arstn #(1,'b1) isolate_reg    (clk, rst, isolate_nxt,    isolate_int,    1'b1);
//reg_arstn #(1,'b1) isolate_byp_reg (clk, rst, isolate_byp,    isolate_byp_int,    1'b1);
reg_arstn #(1,'b1) sleep_send_reg (clk, rst, sleep_send_nxt, sleep_send_int, 1'b1);

always_comb begin
	clk_en_nxt     = 1'b0;
	reset_nxt      = 1'b0;
	isolate_nxt    = 1'b0;
	sleep_send_nxt = 1'b0;
	case(state)
		POWER_ON:begin
			clk_en_nxt     = 1'b1;
			reset_nxt      = 1'b1;
			isolate_nxt    = 1'b0;
			sleep_send_nxt = 1'b0;
		end
		CLK_ENABLE:begin
			clk_en_nxt     = power || external_pg;
			reset_nxt      = 1'b1;
			isolate_nxt    = 1'b0;
			sleep_send_nxt = 1'b0;
		end
		ISOLATE:begin
			clk_en_nxt     = 1'b0;
			reset_nxt      = 1'b1;
			isolate_nxt    = ~(power || external_pg);
			sleep_send_nxt = 1'b0;
		end
		RESET:begin
			clk_en_nxt     = 1'b0;
			reset_nxt      = power || external_pg;
			isolate_nxt    = 1'b1;
			sleep_send_nxt = 1'b0;
		end
		SWITCH_POWER_1:begin
			clk_en_nxt     = 1'b0;
			reset_nxt      = 1'b0;
			isolate_nxt    = 1'b1;
			sleep_send_nxt = ~(power || external_pg);
		end
                SWITCH_POWER_2:begin
                        clk_en_nxt     = 1'b0;
                        reset_nxt      = 1'b0;
                        isolate_nxt    = 1'b1;
                        sleep_send_nxt = ~(power || external_pg);
                end
		POWER_OFF:begin
			clk_en_nxt     = 1'b0;
			reset_nxt      = 1'b0;
			isolate_nxt    = 1'b1;
			sleep_send_nxt = 1'b1;
		end
		default:begin
			clk_en_nxt     = 1'b1;
			reset_nxt      = 1'b1;
			isolate_nxt    = 1'b0;
			sleep_send_nxt = 1'b0;
		end
	endcase
end



endmodule
