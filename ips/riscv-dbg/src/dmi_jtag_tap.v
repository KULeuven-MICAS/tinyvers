module dmi_jtag_tap (
	tck_i,
	tms_i,
	trst_ni,
	td_i,
	td_o,
	tdo_oe_o,
	testmode_i,
	test_logic_reset_o,
	shift_dr_o,
	update_dr_o,
	capture_dr_o,
	dmi_access_o,
	dtmcs_select_o,
	dmi_reset_o,
	dmi_error_i,
	dmi_tdi_o,
	dmi_tdo_i
);
	parameter signed [31:0] IrLength = 5;
	parameter [31:0] IdcodeValue = 32'h00000001;
	input wire tck_i;
	input wire tms_i;
	input wire trst_ni;
	input wire td_i;
	output reg td_o;
	output reg tdo_oe_o;
	input wire testmode_i;
	output reg test_logic_reset_o;
	output reg shift_dr_o;
	output reg update_dr_o;
	output reg capture_dr_o;
	output reg dmi_access_o;
	output reg dtmcs_select_o;
	output wire dmi_reset_o;
	input wire [1:0] dmi_error_i;
	output wire dmi_tdi_o;
	input wire dmi_tdo_i;
	assign dmi_tdi_o = td_i;
	reg [3:0] tap_state_q;
	reg [3:0] tap_state_d;
	reg [IrLength - 1:0] jtag_ir_shift_d;
	reg [IrLength - 1:0] jtag_ir_shift_q;
	reg [IrLength - 1:0] jtag_ir_d;
	reg [IrLength - 1:0] jtag_ir_q;
	reg capture_ir;
	reg shift_ir;
	reg pause_ir;
	reg update_ir;
	function automatic [IrLength - 1:0] sv2v_cast_7FF5F;
		input reg [IrLength - 1:0] inp;
		sv2v_cast_7FF5F = inp;
	endfunction
	always @(*) begin
		jtag_ir_shift_d = jtag_ir_shift_q;
		jtag_ir_d = jtag_ir_q;
		if (shift_ir)
			jtag_ir_shift_d = {td_i, jtag_ir_shift_q[IrLength - 1:1]};
		if (capture_ir)
			jtag_ir_shift_d = 'b101;
		if (update_ir)
			jtag_ir_d = sv2v_cast_7FF5F(jtag_ir_shift_q);
		if (test_logic_reset_o) begin
			jtag_ir_shift_d = 1'sb0;
			jtag_ir_d = sv2v_cast_7FF5F('h1);
		end
	end
	always @(posedge tck_i or negedge trst_ni)
		if (!trst_ni) begin
			jtag_ir_shift_q <= 1'sb0;
			jtag_ir_q <= sv2v_cast_7FF5F('h1);
		end
		else begin
			jtag_ir_shift_q <= jtag_ir_shift_d;
			jtag_ir_q <= jtag_ir_d;
		end
	reg [31:0] idcode_d;
	reg [31:0] idcode_q;
	reg idcode_select;
	reg bypass_select;
	reg [31:0] dtmcs_d;
	reg [31:0] dtmcs_q;
	reg bypass_d;
	reg bypass_q;
	assign dmi_reset_o = dtmcs_q[16];
	always @(*) begin
		idcode_d = idcode_q;
		bypass_d = bypass_q;
		dtmcs_d = dtmcs_q;
		if (capture_dr_o) begin
			if (idcode_select)
				idcode_d = IdcodeValue;
			if (bypass_select)
				bypass_d = 1'b0;
			if (dtmcs_select_o)
				dtmcs_d = {20'h00001, dmi_error_i, 10'h071};
		end
		if (shift_dr_o) begin
			if (idcode_select)
				idcode_d = {td_i, idcode_q[31:1]};
			if (bypass_select)
				bypass_d = td_i;
			if (dtmcs_select_o)
				dtmcs_d = {td_i, dtmcs_q[31:1]};
		end
		if (test_logic_reset_o) begin
			idcode_d = IdcodeValue;
			bypass_d = 1'b0;
		end
	end
	always @(*) begin
		dmi_access_o = 1'b0;
		dtmcs_select_o = 1'b0;
		idcode_select = 1'b0;
		bypass_select = 1'b0;
		case (jtag_ir_q)
			sv2v_cast_7FF5F('h0): bypass_select = 1'b1;
			sv2v_cast_7FF5F('h1): idcode_select = 1'b1;
			sv2v_cast_7FF5F('h10): dtmcs_select_o = 1'b1;
			sv2v_cast_7FF5F('h11): dmi_access_o = 1'b1;
			sv2v_cast_7FF5F('h1f): bypass_select = 1'b1;
			default: bypass_select = 1'b1;
		endcase
	end
	reg tdo_mux;
	always @(*)
		if (shift_ir)
			tdo_mux = jtag_ir_shift_q[0];
		else
			case (jtag_ir_q)
				sv2v_cast_7FF5F('h1): tdo_mux = idcode_q[0];
				sv2v_cast_7FF5F('h10): tdo_mux = dtmcs_q[0];
				sv2v_cast_7FF5F('h11): tdo_mux = dmi_tdo_i;
				default: tdo_mux = bypass_q;
			endcase
	wire tck_n;
	wire tck_ni;
	cluster_clock_inverter i_tck_inv(
		.clk_i(tck_i),
		.clk_o(tck_ni)
	);
	pulp_clock_mux2 i_dft_tck_mux(
		.clk0_i(tck_ni),
		.clk1_i(tck_i),
		.clk_sel_i(testmode_i),
		.clk_o(tck_n)
	);
	always @(posedge tck_n or negedge trst_ni)
		if (!trst_ni) begin
			td_o <= 1'b0;
			tdo_oe_o <= 1'b0;
		end
		else begin
			td_o <= tdo_mux;
			tdo_oe_o <= shift_ir | shift_dr_o;
		end
	always @(*) begin
		test_logic_reset_o = 1'b0;
		capture_dr_o = 1'b0;
		shift_dr_o = 1'b0;
		update_dr_o = 1'b0;
		capture_ir = 1'b0;
		shift_ir = 1'b0;
		pause_ir = 1'b0;
		update_ir = 1'b0;
		case (tap_state_q)
			4'd0: begin
				tap_state_d = (tms_i ? 4'd0 : 4'd1);
				test_logic_reset_o = 1'b1;
			end
			4'd1: tap_state_d = (tms_i ? 4'd2 : 4'd1);
			4'd2: tap_state_d = (tms_i ? 4'd9 : 4'd3);
			4'd3: begin
				capture_dr_o = 1'b1;
				tap_state_d = (tms_i ? 4'd5 : 4'd4);
			end
			4'd4: begin
				shift_dr_o = 1'b1;
				tap_state_d = (tms_i ? 4'd5 : 4'd4);
			end
			4'd5: tap_state_d = (tms_i ? 4'd8 : 4'd6);
			4'd6: tap_state_d = (tms_i ? 4'd7 : 4'd6);
			4'd7: tap_state_d = (tms_i ? 4'd8 : 4'd4);
			4'd8: begin
				update_dr_o = 1'b1;
				tap_state_d = (tms_i ? 4'd2 : 4'd1);
			end
			4'd9: tap_state_d = (tms_i ? 4'd0 : 4'd10);
			4'd10: begin
				capture_ir = 1'b1;
				tap_state_d = (tms_i ? 4'd12 : 4'd11);
			end
			4'd11: begin
				shift_ir = 1'b1;
				tap_state_d = (tms_i ? 4'd12 : 4'd11);
			end
			4'd12: tap_state_d = (tms_i ? 4'd15 : 4'd13);
			4'd13: begin
				pause_ir = 1'b1;
				tap_state_d = (tms_i ? 4'd14 : 4'd13);
			end
			4'd14: tap_state_d = (tms_i ? 4'd15 : 4'd11);
			4'd15: begin
				update_ir = 1'b1;
				tap_state_d = (tms_i ? 4'd2 : 4'd1);
			end
			default: tap_state_d = 4'd0;
		endcase
	end
	always @(posedge tck_i or negedge trst_ni)
		if (!trst_ni) begin
			tap_state_q <= 4'd1;
			idcode_q <= IdcodeValue;
			bypass_q <= 1'b0;
			dtmcs_q <= 1'sb0;
		end
		else begin
			tap_state_q <= tap_state_d;
			idcode_q <= idcode_d;
			bypass_q <= bypass_d;
			dtmcs_q <= dtmcs_d;
		end
endmodule
