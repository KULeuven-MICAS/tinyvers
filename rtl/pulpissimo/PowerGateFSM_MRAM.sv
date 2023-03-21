module PowerGateFSM_MRAM #(
	parameter realtime T_SD   = 30517, // 100, //ns
        parameter realtime T_RT   = 30517, //3000,
        parameter realtime T_PR   = 30517, //20,
        parameter realtime T_RSW  = 30517, //2000,
        parameter realtime T_RH   = 30517, //20000,
        parameter realtime T_DPDS = 30517, //100,
        parameter realtime T_DPDH = 30517, //20,
        parameter realtime T_EXTERNAL_VDD_ACTIVATION = 30517, //5000,

        parameter realtime T_CLK = 30517 //ns --32KHz //100 //ns -- so 10MHz
)(
	input      clk,
	input      rst,
	input      power,
        input      external_pg,
	output     VDDA_out,
	output     VDD_out,
	output     VREF_out,
	output     PORb,
	output     RETb,
	output     RSTb,
	output     TRIM,
	output     DPD,
	output     CEb_HIGH,
        input      wu_bypass_mux,
        input      isolate_byp,
	output reg isolate,
	output reg done
);

/*localparam real TELLER1 = T_SD  ; localparam real NOEMER1 = real'(T_CLK); localparam real BREUK1 = TELLER1/NOEMER1; localparam int P_SD   =  int'($ceil(BREUK1));
localparam real TELLER2 = T_RT  ; localparam real NOEMER2 = real'(T_CLK); localparam real BREUK2 = TELLER2/NOEMER2; localparam int P_RT   =  int'($ceil(BREUK2));
localparam real TELLER3 = T_PR  ; localparam real NOEMER3 = real'(T_CLK); localparam real BREUK3 = TELLER3/NOEMER3; localparam int P_PR   =  int'($ceil(BREUK3));
localparam real TELLER4 = T_RSW ; localparam real NOEMER4 = real'(T_CLK); localparam real BREUK4 = TELLER4/NOEMER4; localparam int P_RSW  =  int'($ceil(BREUK4));
localparam real TELLER5 = T_RH  ; localparam real NOEMER5 = real'(T_CLK); localparam real BREUK5 = TELLER5/NOEMER5; localparam int P_RH   =  int'($ceil(BREUK5));
localparam real TELLER6 = T_DPDS; localparam real NOEMER6 = real'(T_CLK); localparam real BREUK6 = TELLER6/NOEMER6; localparam int P_DPDS =  int'($ceil(BREUK6));
localparam real TELLER7 = T_DPDH; localparam real NOEMER7 = real'(T_CLK); localparam real BREUK7 = TELLER7/NOEMER7; localparam int P_DPDH =  int'($ceil(BREUK7));
localparam real TELLER8 = T_EXTERNAL_VDD_ACTIVATION; localparam real NOEMER8 = real'(T_CLK); localparam real BREUK8 = TELLER8/NOEMER8; localparam int P_EXTERNAL_VDD_ACTIVATION =  int'($ceil(BREUK8));
*/

localparam int P_SD = 1;
localparam int P_RT = 1;
localparam int P_PR = 1;
localparam int P_RSW = 1;
localparam int P_RH = 1;
localparam int P_DPDS = 1;
localparam int P_DPDH = 1;
localparam int P_EXTERNAL_VDD_ACTIVATION = 2;
localparam int P_TRIM =  1;

parameter integer CNT_W = 8;
wire unsigned [CNT_W-1:0] cnt; reg unsigned [CNT_W-1:0] cnt_nxt;
reg_arstn #(CNT_W,'b0) counter (clk, rst, cnt_nxt, cnt, 1'b1);

parameter integer STATE_W = 5;
typedef enum logic[STATE_W-1:0] {POWER_OFF, CHANGE_VDD, CHANGE_VDDA, CHANGE_VDDREF, CHANGE_POR_RET, CHANGE_RET_DPD, CHANGE_RST, CHANGE_ISOL, TRIM_CONFIG, ACTIVATE_TRIM, TRIG_CE, UNTRIG_CE, TRIG_DPD, UNTRIG_DPD, POWER_ON} state_type;

reg isolate_int;
reg isolate_byp_int;

always_comb begin
    if (wu_bypass_mux) begin
        isolate = isolate_byp;
    end
    else begin
        isolate = isolate_int;
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
        cnt_nxt=0;
	case(state)
		POWER_OFF:begin
			if(power || external_pg) begin state_nxt = CHANGE_VDD; end
			else      begin state_nxt = POWER_OFF;  end
			cnt_nxt=0;
		end
		CHANGE_VDD:begin
			if(cnt==(P_EXTERNAL_VDD_ACTIVATION-1)) begin
				if(power || external_pg) begin state_nxt = CHANGE_VDDA; end
				else      begin state_nxt = POWER_OFF;   end
				cnt_nxt=0;
			end else begin
				state_nxt=state;
				cnt_nxt=cnt+1;
			end
		end
		CHANGE_VDDA:begin
			if(cnt==(P_EXTERNAL_VDD_ACTIVATION-1)) begin
				if(power || external_pg) begin state_nxt = CHANGE_VDDREF; end
				else      begin state_nxt = CHANGE_VDD; end
				cnt_nxt=0;
			end else begin
				state_nxt=state;
				cnt_nxt=cnt+1;
			end
		end
		CHANGE_VDDREF:begin
			if(cnt==(P_RT-1)) begin
				if(power || external_pg) begin state_nxt = CHANGE_POR_RET; end
				else      begin state_nxt = CHANGE_VDDA; end
				cnt_nxt=0;
			end else begin
				state_nxt=state;
				cnt_nxt=cnt+1;
			end
		end
		CHANGE_POR_RET:begin
			if(cnt==(P_RSW-1)) begin
				if(power || external_pg) begin state_nxt = CHANGE_RST; end
				else      begin state_nxt = CHANGE_VDDREF; end
				cnt_nxt=0;
			end else begin
				state_nxt=state;
				cnt_nxt=cnt+1;
			end
		end
                CHANGE_RET_DPD:begin
                        if(cnt==0) begin
                                if(power || external_pg) begin state_nxt = CHANGE_RST; end
                                else      begin state_nxt = CHANGE_POR_RET; end
                                cnt_nxt=0;
                        end else begin
                                state_nxt=state;
                                cnt_nxt=cnt+1;
                        end
                end
		CHANGE_RST:begin
			if(cnt==0) begin
				if(power || external_pg) begin state_nxt = CHANGE_ISOL; end
				else      begin state_nxt = CHANGE_RET_DPD; end
				cnt_nxt=0;
			end else begin
				state_nxt=state;
				cnt_nxt=cnt+1;
			end
		end
		CHANGE_ISOL:begin
			if(cnt==0) begin
				if(power || external_pg) begin state_nxt = TRIM_CONFIG; end
				else      begin state_nxt = CHANGE_RST; end
				cnt_nxt=0;
			end else begin
				state_nxt=state;
				cnt_nxt=cnt+1;
			end
		end
		TRIM_CONFIG:begin
			if(cnt==(P_TRIM-1)) begin
				if(power || external_pg) begin state_nxt = ACTIVATE_TRIM; end
				else      begin state_nxt = CHANGE_ISOL; end
				cnt_nxt=0;
			end else begin
				state_nxt=state;
				cnt_nxt=cnt+1;
			end
		end
		ACTIVATE_TRIM:begin
			if(cnt==(P_RH-1)) begin
				if(power || external_pg) begin state_nxt = POWER_ON; end
				else      begin state_nxt = CHANGE_RST; end
				cnt_nxt=0;
			end else begin
				state_nxt=state;
				cnt_nxt=cnt+1;
			end
		end
		TRIG_DPD:begin
			if(cnt==0) begin
				if(power || external_pg) begin state_nxt = UNTRIG_DPD; end
				else      begin state_nxt = CHANGE_ISOL; end
				cnt_nxt=0;
			end else begin
				state_nxt=state;
				cnt_nxt=cnt+1;
			end
		end
		UNTRIG_CE:begin
			if(cnt==(P_DPDS-1)) begin
				if(power || external_pg) begin state_nxt = TRIG_DPD; end
				else      begin state_nxt = TRIG_DPD; end
				cnt_nxt=0;
			end else begin
				state_nxt=state;
				cnt_nxt=cnt+1;
			end
		end
		POWER_ON:begin
			if(power || external_pg) begin state_nxt = POWER_ON; end
			else      begin state_nxt = UNTRIG_CE; end
			cnt_nxt=0;
		end
		default:begin
			state_nxt = POWER_OFF;
		end
	endcase
end

assign done = ((power==1) && (state==POWER_ON)) || ((power==0) && (state==POWER_OFF));
reg VDDA_out_nxt, VDD_out_nxt, VREF_out_nxt, PORb_nxt, RETb_nxt, RSTb_nxt, TRIM_nxt, DPD_nxt, CEb_HIGH_nxt, isolate_nxt;

reg_arstn #(1,'b0) VDDA_out_reg (clk, rst, VDDA_out_nxt, VDDA_out, 1'b1);
reg_arstn #(1,'b0) VDD_out_reg  (clk, rst, VDD_out_nxt,  VDD_out,  1'b1);
reg_arstn #(1,'b0) VREF_out_reg (clk, rst, VREF_out_nxt, VREF_out, 1'b1);
reg_arstn #(1,'b0) PORb_reg     (clk, rst, PORb_nxt,     PORb,     1'b1);
reg_arstn #(1,'b0) RETb_reg     (clk, rst, RETb_nxt,     RETb,     1'b1);
reg_arstn #(1,'b0) RSTb_reg     (clk, rst, RSTb_nxt,     RSTb,     1'b1);
reg_arstn #(1,'b0) TRIM_reg     (clk, rst, TRIM_nxt,     TRIM,     1'b1);
reg_arstn #(1,'b0) DPD_reg      (clk, rst, DPD_nxt,      DPD,      1'b1);
reg_arstn #(1,'b1) CEb_HIGH_reg (clk, rst, CEb_HIGH_nxt, CEb_HIGH, 1'b1);
reg_arstn #(1,'b1) isolate_reg     (clk, rst, isolate_nxt,     isolate_int,     1'b1);
//reg_arstn #(1,'b1) isolate_byp_reg     (clk, rst, isolate_byp,     isolate_byp_int,     1'b1);


always_comb begin
	VDDA_out_nxt = 1'b0;
	VDD_out_nxt  = 1'b0;
	VREF_out_nxt = 1'b0;
	PORb_nxt     = 1'b0;
	RETb_nxt     = 1'b0;
	RSTb_nxt     = 1'b0;
	isolate_nxt     = 1'b1;
	TRIM_nxt     = 1'b0;
	DPD_nxt      = 1'b0;
	CEb_HIGH_nxt = 1'b1;
	case(state)
		POWER_OFF:begin
			VDDA_out_nxt = 1'b0;
			VDD_out_nxt  = 1'b0;
			VREF_out_nxt = 1'b0;
			PORb_nxt     = 1'b0;
			RETb_nxt     = 1'b0;
			RSTb_nxt     = 1'b0;
			isolate_nxt     = 1'b1;
			TRIM_nxt     = 1'b0;
			DPD_nxt      = 1'b1;
			CEb_HIGH_nxt = 1'b1;
		end
		CHANGE_VDD:begin
			VDDA_out_nxt = 1'b0;
			VDD_out_nxt  = power || external_pg;
			VREF_out_nxt = 1'b0;
			PORb_nxt     = 1'b0;
			RETb_nxt     = 1'b0;
			RSTb_nxt     = 1'b0;
			isolate_nxt     = 1'b1;
			TRIM_nxt     = 1'b0;
			DPD_nxt      = 1'b0 || ~(power || external_pg);
			CEb_HIGH_nxt = 1'b1;
		end
		CHANGE_VDDA:begin
			VDDA_out_nxt = power || external_pg;
			VDD_out_nxt  = 1'b1;
			VREF_out_nxt = 1'b0;
			PORb_nxt     = 1'b0;
			RETb_nxt     = 1'b0;
			RSTb_nxt     = 1'b0;
			isolate_nxt     = 1'b1;
			TRIM_nxt     = 1'b0;
			DPD_nxt      = 1'b0 || ~(power || external_pg);
			CEb_HIGH_nxt = 1'b1;
		end
		CHANGE_VDDREF:begin
			VDDA_out_nxt = 1'b1;
			VDD_out_nxt  = 1'b1;
			VREF_out_nxt = power || external_pg;
			PORb_nxt     = 1'b0;
			RETb_nxt     = 1'b0;
			RSTb_nxt     = 1'b0;
			isolate_nxt     = 1'b1;
			TRIM_nxt     = 1'b0;
			DPD_nxt      = 1'b0 || ~(power || external_pg);
			CEb_HIGH_nxt = 1'b1;
		end
		CHANGE_POR_RET:begin
			VDDA_out_nxt = 1'b1;
			VDD_out_nxt  = 1'b1;
			VREF_out_nxt = 1'b1;
			PORb_nxt     = power || external_pg;
			RETb_nxt     = power || external_pg;
			RSTb_nxt     = 1'b0;
			isolate_nxt     = 1'b1;
			TRIM_nxt     = 1'b0;
			DPD_nxt      = 1'b0 || ~(power || external_pg);
			CEb_HIGH_nxt = 1'b1;
		end
                CHANGE_RET_DPD:begin
                        VDDA_out_nxt = 1'b1;
                        VDD_out_nxt  = 1'b1;
                        VREF_out_nxt = 1'b1;
                        PORb_nxt     = 1'b1;
                        RETb_nxt     = power || external_pg;
                        RSTb_nxt     = 1'b0;
                        isolate_nxt     = 1'b1;
                        TRIM_nxt     = 1'b0;
                        DPD_nxt      = 1'b0 || ~(power || external_pg);
                        CEb_HIGH_nxt = 1'b1;
                end
		CHANGE_RST:begin
			VDDA_out_nxt = 1'b1;
			VDD_out_nxt  = 1'b1;
			VREF_out_nxt = 1'b1;
			PORb_nxt     = 1'b1;
			RETb_nxt     = 1'b1;
			RSTb_nxt     = power || external_pg;
			isolate_nxt     = 1'b1;
			TRIM_nxt     = 1'b0;
			DPD_nxt      = 1'b0 || ~(power || external_pg);
			CEb_HIGH_nxt = 1'b1;
		end
		CHANGE_ISOL:begin
			VDDA_out_nxt = 1'b1;
			VDD_out_nxt  = 1'b1;
			VREF_out_nxt = 1'b1;
			PORb_nxt     = 1'b1;
			RETb_nxt     = 1'b1;
			RSTb_nxt     = 1'b1;
			isolate_nxt     = ~(power || external_pg);
			TRIM_nxt     = 1'b0;
			DPD_nxt      = 1'b0 || ~(power || external_pg);
			CEb_HIGH_nxt = 1'b1;
		end
		TRIM_CONFIG:begin
			VDDA_out_nxt = 1'b1;
			VDD_out_nxt  = 1'b1;
			VREF_out_nxt = 1'b1;
			PORb_nxt     = 1'b1;
			RETb_nxt     = 1'b1;
			RSTb_nxt     = 1'b1;
			isolate_nxt     = 1'b0;
			TRIM_nxt     = 1'b1;
			DPD_nxt      = 1'b0;
			CEb_HIGH_nxt = 1'b1;
		end
		ACTIVATE_TRIM:begin
			VDDA_out_nxt = 1'b1;
			VDD_out_nxt  = 1'b1;
			VREF_out_nxt = 1'b1;
			PORb_nxt     = 1'b1;
			RETb_nxt     = 1'b1;
			RSTb_nxt     = 1'b1;
			isolate_nxt     = 1'b0;
			TRIM_nxt     = 1'b0;
			DPD_nxt      = 1'b0;
			CEb_HIGH_nxt = 1'b1;
		end
		UNTRIG_CE:begin
			VDDA_out_nxt = 1'b1;
			VDD_out_nxt  = 1'b1;
			VREF_out_nxt = 1'b1;
			PORb_nxt     = 1'b1;
			RETb_nxt     = 1'b1;
			RSTb_nxt     = 1'b1;
			isolate_nxt     = 1'b0;
			TRIM_nxt     = 1'b0;
			DPD_nxt      = 1'b0;
			CEb_HIGH_nxt = 1'b1;
		end
		TRIG_DPD:begin
			VDDA_out_nxt = 1'b1;
			VDD_out_nxt  = 1'b1;
			VREF_out_nxt = 1'b1;
			PORb_nxt     = 1'b1;
			RETb_nxt     = 1'b1;
			RSTb_nxt     = 1'b1;
			isolate_nxt     = 1'b0;
			TRIM_nxt     = 1'b0;
			DPD_nxt      = 1'b1;
			CEb_HIGH_nxt = 1'b1;
		end
		UNTRIG_DPD:begin
			VDDA_out_nxt = 1'b1;
			VDD_out_nxt  = 1'b1;
			VREF_out_nxt = 1'b1;
			PORb_nxt     = 1'b1;
			RETb_nxt     = 1'b1;
			RSTb_nxt     = 1'b1;
			isolate_nxt     = 1'b0;
			TRIM_nxt     = 1'b0;
			DPD_nxt      = 1'b0;
			CEb_HIGH_nxt = 1'b1;
		end
		POWER_ON:begin
			VDDA_out_nxt = 1'b1;
			VDD_out_nxt  = 1'b1;
			VREF_out_nxt = 1'b1;
			PORb_nxt     = 1'b1;
			RETb_nxt     = 1'b1;
			RSTb_nxt     = 1'b1;
			isolate_nxt     = 1'b0;
			TRIM_nxt     = 1'b0;
			DPD_nxt      = 1'b0;
			CEb_HIGH_nxt = 1'b0;
		end
		default:begin
			VDDA_out_nxt = 1'b1;
			VDD_out_nxt  = 1'b1;
			VREF_out_nxt = 1'b1;
			PORb_nxt     = 1'b1;
			RETb_nxt     = 1'b1;
			RSTb_nxt     = 1'b1;
			isolate_nxt     = 1'b0;
			TRIM_nxt     = 1'b0;
			DPD_nxt      = 1'b0;
			CEb_HIGH_nxt = 1'b0;
		end
	endcase
end



endmodule
