module PowerGateFSM_MRAM (
	clk,
	rst,
	power,
	VDDA_out,
	VDD_out,
	VREF_out,
	PORb,
	RETb,
	RSTb,
	TRIM,
	DPD,
	CEb_HIGH,
	isolate,
	done
);
	parameter realtime T_SD = 30517;
	parameter realtime T_RT = 30517;
	parameter realtime T_PR = 30517;
	parameter realtime T_RSW = 30517;
	parameter realtime T_RH = 30517;
	parameter realtime T_DPDS = 30517;
	parameter realtime T_DPDH = 30517;
	parameter realtime T_EXTERNAL_VDD_ACTIVATION = 30517;
	parameter realtime T_CLK = 30517;
	input clk;
	input rst;
	input power;
	output wire VDDA_out;
	output wire VDD_out;
	output wire VREF_out;
	output wire PORb;
	output wire RETb;
	output wire RSTb;
	output wire TRIM;
	output wire DPD;
	output wire CEb_HIGH;
	output wire isolate;
	output reg done;
	localparam signed [31:0] P_SD = 1;
	localparam signed [31:0] P_RT = 1;
	localparam signed [31:0] P_PR = 1;
	localparam signed [31:0] P_RSW = 1;
	localparam signed [31:0] P_RH = 1;
	localparam signed [31:0] P_DPDS = 1;
	localparam signed [31:0] P_DPDH = 1;
	localparam signed [31:0] P_EXTERNAL_VDD_ACTIVATION = 1;
	localparam signed [31:0] P_TRIM = 1;
	parameter integer CNT_W = 8;
	wire [CNT_W - 1:0] cnt;
	reg [CNT_W - 1:0] cnt_nxt;
	reg_arstn #(
		.DATA_W(CNT_W),
		.PRESET_VAL('b0)
	) counter(
		.clk(clk),
		.arst_n(rst),
		.din(cnt_nxt),
		.dout(cnt),
		.wen(1'b1)
	);
	parameter integer STATE_W = 5;
	reg [STATE_W - 1:0] state;
	reg [STATE_W - 1:0] state_nxt;
	function automatic [STATE_W - 1:0] sv2v_cast_B8280;
		input reg [STATE_W - 1:0] inp;
		sv2v_cast_B8280 = inp;
	endfunction
	always @(posedge clk or negedge rst)
		if (rst == 0)
			state <= sv2v_cast_B8280(0);
		else
			state <= state_nxt;
	always @(*) begin
		state_nxt = sv2v_cast_B8280(13);
		cnt_nxt = 0;
		case (state)
			sv2v_cast_B8280(0): begin
				if (power)
					state_nxt = sv2v_cast_B8280(1);
				else
					state_nxt = sv2v_cast_B8280(0);
				cnt_nxt = 0;
			end
			sv2v_cast_B8280(1):
				if (cnt == 0) begin
					if (power)
						state_nxt = sv2v_cast_B8280(2);
					else
						state_nxt = sv2v_cast_B8280(0);
					cnt_nxt = 0;
				end
				else begin
					state_nxt = state;
					cnt_nxt = cnt + 1;
				end
			sv2v_cast_B8280(2):
				if (cnt == 0) begin
					if (power)
						state_nxt = sv2v_cast_B8280(3);
					else
						state_nxt = sv2v_cast_B8280(1);
					cnt_nxt = 0;
				end
				else begin
					state_nxt = state;
					cnt_nxt = cnt + 1;
				end
			sv2v_cast_B8280(3):
				if (cnt == 0) begin
					if (power)
						state_nxt = sv2v_cast_B8280(4);
					else
						state_nxt = sv2v_cast_B8280(2);
					cnt_nxt = 0;
				end
				else begin
					state_nxt = state;
					cnt_nxt = cnt + 1;
				end
			sv2v_cast_B8280(4):
				if (cnt == 0) begin
					if (power)
						state_nxt = sv2v_cast_B8280(5);
					else
						state_nxt = sv2v_cast_B8280(3);
					cnt_nxt = 0;
				end
				else begin
					state_nxt = state;
					cnt_nxt = cnt + 1;
				end
			sv2v_cast_B8280(5):
				if (cnt == 0) begin
					if (power)
						state_nxt = sv2v_cast_B8280(6);
					else
						state_nxt = sv2v_cast_B8280(4);
					cnt_nxt = 0;
				end
				else begin
					state_nxt = state;
					cnt_nxt = cnt + 1;
				end
			sv2v_cast_B8280(6):
				if (cnt == 0) begin
					if (power)
						state_nxt = sv2v_cast_B8280(7);
					else
						state_nxt = sv2v_cast_B8280(5);
					cnt_nxt = 0;
				end
				else begin
					state_nxt = state;
					cnt_nxt = cnt + 1;
				end
			sv2v_cast_B8280(7):
				if (cnt == 0) begin
					if (power)
						state_nxt = sv2v_cast_B8280(8);
					else
						state_nxt = sv2v_cast_B8280(6);
					cnt_nxt = 0;
				end
				else begin
					state_nxt = state;
					cnt_nxt = cnt + 1;
				end
			sv2v_cast_B8280(8):
				if (cnt == 0) begin
					if (power)
						state_nxt = sv2v_cast_B8280(13);
					else
						state_nxt = sv2v_cast_B8280(5);
					cnt_nxt = 0;
				end
				else begin
					state_nxt = state;
					cnt_nxt = cnt + 1;
				end
			sv2v_cast_B8280(11):
				if (cnt == 0) begin
					if (power)
						state_nxt = sv2v_cast_B8280(12);
					else
						state_nxt = sv2v_cast_B8280(6);
					cnt_nxt = 0;
				end
				else begin
					state_nxt = state;
					cnt_nxt = cnt + 1;
				end
			sv2v_cast_B8280(10):
				if (cnt == 0) begin
					if (power)
						state_nxt = sv2v_cast_B8280(11);
					else
						state_nxt = sv2v_cast_B8280(11);
					cnt_nxt = 0;
				end
				else begin
					state_nxt = state;
					cnt_nxt = cnt + 1;
				end
			sv2v_cast_B8280(13): begin
				if (power)
					state_nxt = sv2v_cast_B8280(13);
				else
					state_nxt = sv2v_cast_B8280(10);
				cnt_nxt = 0;
			end
			default: state_nxt = sv2v_cast_B8280(0);
		endcase
	end
	wire [1:1] sv2v_tmp_CA34C;
	assign sv2v_tmp_CA34C = ((power == 1) && (state == sv2v_cast_B8280(13))) || ((power == 0) && (state == sv2v_cast_B8280(0)));
	always @(*) done = sv2v_tmp_CA34C;
	reg VDDA_out_nxt;
	reg VDD_out_nxt;
	reg VREF_out_nxt;
	reg PORb_nxt;
	reg RETb_nxt;
	reg RSTb_nxt;
	reg TRIM_nxt;
	reg DPD_nxt;
	reg CEb_HIGH_nxt;
	reg isolate_nxt;
	reg_arstn #(
		.DATA_W(1),
		.PRESET_VAL('b0)
	) VDDA_out_reg(
		.clk(clk),
		.arst_n(rst),
		.din(VDDA_out_nxt),
		.dout(VDDA_out),
		.wen(1'b1)
	);
	reg_arstn #(
		.DATA_W(1),
		.PRESET_VAL('b0)
	) VDD_out_reg(
		.clk(clk),
		.arst_n(rst),
		.din(VDD_out_nxt),
		.dout(VDD_out),
		.wen(1'b1)
	);
	reg_arstn #(
		.DATA_W(1),
		.PRESET_VAL('b0)
	) VREF_out_reg(
		.clk(clk),
		.arst_n(rst),
		.din(VREF_out_nxt),
		.dout(VREF_out),
		.wen(1'b1)
	);
	reg_arstn #(
		.DATA_W(1),
		.PRESET_VAL('b0)
	) PORb_reg(
		.clk(clk),
		.arst_n(rst),
		.din(PORb_nxt),
		.dout(PORb),
		.wen(1'b1)
	);
	reg_arstn #(
		.DATA_W(1),
		.PRESET_VAL('b0)
	) RETb_reg(
		.clk(clk),
		.arst_n(rst),
		.din(RETb_nxt),
		.dout(RETb),
		.wen(1'b1)
	);
	reg_arstn #(
		.DATA_W(1),
		.PRESET_VAL('b0)
	) RSTb_reg(
		.clk(clk),
		.arst_n(rst),
		.din(RSTb_nxt),
		.dout(RSTb),
		.wen(1'b1)
	);
	reg_arstn #(
		.DATA_W(1),
		.PRESET_VAL('b0)
	) TRIM_reg(
		.clk(clk),
		.arst_n(rst),
		.din(TRIM_nxt),
		.dout(TRIM),
		.wen(1'b1)
	);
	reg_arstn #(
		.DATA_W(1),
		.PRESET_VAL('b0)
	) DPD_reg(
		.clk(clk),
		.arst_n(rst),
		.din(DPD_nxt),
		.dout(DPD),
		.wen(1'b1)
	);
	reg_arstn #(
		.DATA_W(1),
		.PRESET_VAL('b1)
	) CEb_HIGH_reg(
		.clk(clk),
		.arst_n(rst),
		.din(CEb_HIGH_nxt),
		.dout(CEb_HIGH),
		.wen(1'b1)
	);
	reg_arstn #(
		.DATA_W(1),
		.PRESET_VAL('b1)
	) isolate_reg(
		.clk(clk),
		.arst_n(rst),
		.din(isolate_nxt),
		.dout(isolate),
		.wen(1'b1)
	);
	always @(*) begin
		VDDA_out_nxt = 1'b0;
		VDD_out_nxt = 1'b0;
		VREF_out_nxt = 1'b0;
		PORb_nxt = 1'b0;
		RETb_nxt = 1'b0;
		RSTb_nxt = 1'b0;
		isolate_nxt = 1'b1;
		TRIM_nxt = 1'b0;
		DPD_nxt = 1'b0;
		CEb_HIGH_nxt = 1'b1;
		case (state)
			sv2v_cast_B8280(0): begin
				VDDA_out_nxt = 1'b0;
				VDD_out_nxt = 1'b0;
				VREF_out_nxt = 1'b0;
				PORb_nxt = 1'b0;
				RETb_nxt = 1'b0;
				RSTb_nxt = 1'b0;
				isolate_nxt = 1'b1;
				TRIM_nxt = 1'b0;
				DPD_nxt = 1'b1;
				CEb_HIGH_nxt = 1'b1;
			end
			sv2v_cast_B8280(1): begin
				VDDA_out_nxt = 1'b0;
				VDD_out_nxt = power;
				VREF_out_nxt = 1'b0;
				PORb_nxt = 1'b0;
				RETb_nxt = 1'b0;
				RSTb_nxt = 1'b0;
				isolate_nxt = 1'b1;
				TRIM_nxt = 1'b0;
				DPD_nxt = 1'b0 || ~power;
				CEb_HIGH_nxt = 1'b1;
			end
			sv2v_cast_B8280(2): begin
				VDDA_out_nxt = power;
				VDD_out_nxt = 1'b1;
				VREF_out_nxt = 1'b0;
				PORb_nxt = 1'b0;
				RETb_nxt = 1'b0;
				RSTb_nxt = 1'b0;
				isolate_nxt = 1'b1;
				TRIM_nxt = 1'b0;
				DPD_nxt = 1'b0 || ~power;
				CEb_HIGH_nxt = 1'b1;
			end
			sv2v_cast_B8280(3): begin
				VDDA_out_nxt = 1'b1;
				VDD_out_nxt = 1'b1;
				VREF_out_nxt = power;
				PORb_nxt = 1'b0;
				RETb_nxt = 1'b0;
				RSTb_nxt = 1'b0;
				isolate_nxt = 1'b1;
				TRIM_nxt = 1'b0;
				DPD_nxt = 1'b0 || ~power;
				CEb_HIGH_nxt = 1'b1;
			end
			sv2v_cast_B8280(4): begin
				VDDA_out_nxt = 1'b1;
				VDD_out_nxt = 1'b1;
				VREF_out_nxt = 1'b1;
				PORb_nxt = power;
				RETb_nxt = power;
				RSTb_nxt = 1'b0;
				isolate_nxt = 1'b1;
				TRIM_nxt = 1'b0;
				DPD_nxt = 1'b0 || ~power;
				CEb_HIGH_nxt = 1'b1;
			end
			sv2v_cast_B8280(5): begin
				VDDA_out_nxt = 1'b1;
				VDD_out_nxt = 1'b1;
				VREF_out_nxt = 1'b1;
				PORb_nxt = 1'b1;
				RETb_nxt = 1'b1;
				RSTb_nxt = power;
				isolate_nxt = 1'b1;
				TRIM_nxt = 1'b0;
				DPD_nxt = 1'b0 || ~power;
				CEb_HIGH_nxt = 1'b1;
			end
			sv2v_cast_B8280(6): begin
				VDDA_out_nxt = 1'b1;
				VDD_out_nxt = 1'b1;
				VREF_out_nxt = 1'b1;
				PORb_nxt = 1'b1;
				RETb_nxt = 1'b1;
				RSTb_nxt = 1'b1;
				isolate_nxt = ~power;
				TRIM_nxt = 1'b0;
				DPD_nxt = 1'b0 || ~power;
				CEb_HIGH_nxt = 1'b1;
			end
			sv2v_cast_B8280(7): begin
				VDDA_out_nxt = 1'b1;
				VDD_out_nxt = 1'b1;
				VREF_out_nxt = 1'b1;
				PORb_nxt = 1'b1;
				RETb_nxt = 1'b1;
				RSTb_nxt = 1'b1;
				isolate_nxt = 1'b0;
				TRIM_nxt = 1'b1;
				DPD_nxt = 1'b0;
				CEb_HIGH_nxt = 1'b1;
			end
			sv2v_cast_B8280(8): begin
				VDDA_out_nxt = 1'b1;
				VDD_out_nxt = 1'b1;
				VREF_out_nxt = 1'b1;
				PORb_nxt = 1'b1;
				RETb_nxt = 1'b1;
				RSTb_nxt = 1'b1;
				isolate_nxt = 1'b0;
				TRIM_nxt = 1'b0;
				DPD_nxt = 1'b0;
				CEb_HIGH_nxt = 1'b1;
			end
			sv2v_cast_B8280(10): begin
				VDDA_out_nxt = 1'b1;
				VDD_out_nxt = 1'b1;
				VREF_out_nxt = 1'b1;
				PORb_nxt = 1'b1;
				RETb_nxt = 1'b1;
				RSTb_nxt = 1'b1;
				isolate_nxt = 1'b0;
				TRIM_nxt = 1'b0;
				DPD_nxt = 1'b0;
				CEb_HIGH_nxt = 1'b1;
			end
			sv2v_cast_B8280(11): begin
				VDDA_out_nxt = 1'b1;
				VDD_out_nxt = 1'b1;
				VREF_out_nxt = 1'b1;
				PORb_nxt = 1'b1;
				RETb_nxt = 1'b1;
				RSTb_nxt = 1'b1;
				isolate_nxt = 1'b0;
				TRIM_nxt = 1'b0;
				DPD_nxt = 1'b1;
				CEb_HIGH_nxt = 1'b1;
			end
			sv2v_cast_B8280(12): begin
				VDDA_out_nxt = 1'b1;
				VDD_out_nxt = 1'b1;
				VREF_out_nxt = 1'b1;
				PORb_nxt = 1'b1;
				RETb_nxt = 1'b1;
				RSTb_nxt = 1'b1;
				isolate_nxt = 1'b0;
				TRIM_nxt = 1'b0;
				DPD_nxt = 1'b0;
				CEb_HIGH_nxt = 1'b1;
			end
			sv2v_cast_B8280(13): begin
				VDDA_out_nxt = 1'b1;
				VDD_out_nxt = 1'b1;
				VREF_out_nxt = 1'b1;
				PORb_nxt = 1'b1;
				RETb_nxt = 1'b1;
				RSTb_nxt = 1'b1;
				isolate_nxt = 1'b0;
				TRIM_nxt = 1'b0;
				DPD_nxt = 1'b0;
				CEb_HIGH_nxt = 1'b0;
			end
			default: begin
				VDDA_out_nxt = 1'b1;
				VDD_out_nxt = 1'b1;
				VREF_out_nxt = 1'b1;
				PORb_nxt = 1'b1;
				RETb_nxt = 1'b1;
				RSTb_nxt = 1'b1;
				isolate_nxt = 1'b0;
				TRIM_nxt = 1'b0;
				DPD_nxt = 1'b0;
				CEb_HIGH_nxt = 1'b0;
			end
		endcase
	end
endmodule
