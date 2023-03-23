module dmi_jtag (
	clk_i,
	rst_ni,
	testmode_i,
	dmi_rst_no,
	dmi_req_o,
	dmi_req_valid_o,
	dmi_req_ready_i,
	dmi_resp_i,
	dmi_resp_ready_o,
	dmi_resp_valid_i,
	tck_i,
	tms_i,
	trst_ni,
	td_i,
	td_o,
	tdo_oe_o
);
	parameter [31:0] IdcodeValue = 32'h00000001;
	input wire clk_i;
	input wire rst_ni;
	input wire testmode_i;
	output wire dmi_rst_no;
	output wire [40:0] dmi_req_o;
	output wire dmi_req_valid_o;
	input wire dmi_req_ready_i;
	input wire [33:0] dmi_resp_i;
	output wire dmi_resp_ready_o;
	input wire dmi_resp_valid_i;
	input wire tck_i;
	input wire tms_i;
	input wire trst_ni;
	input wire td_i;
	output wire td_o;
	output wire tdo_oe_o;
	assign dmi_rst_no = rst_ni;
	wire test_logic_reset;
	wire shift_dr;
	wire update_dr;
	wire capture_dr;
	wire dmi_access;
	wire dtmcs_select;
	wire dmi_reset;
	wire dmi_tdi;
	wire dmi_tdo;
	wire [40:0] dmi_req;
	wire dmi_req_ready;
	reg dmi_req_valid;
	wire [33:0] dmi_resp;
	wire dmi_resp_valid;
	wire dmi_resp_ready;
	reg [2:0] state_d;
	reg [2:0] state_q;
	reg [40:0] dr_d;
	reg [40:0] dr_q;
	reg [6:0] address_d;
	reg [6:0] address_q;
	reg [31:0] data_d;
	reg [31:0] data_q;
	wire [40:0] dmi;
	assign dmi = dr_q;
	assign dmi_req[40-:7] = address_q;
	assign dmi_req[31-:32] = data_q;
	assign dmi_req[33-:2] = (state_q == 3'd3 ? 2'h2 : 2'h1);
	assign dmi_resp_ready = 1'b1;
	reg error_dmi_busy;
	reg [1:0] error_d;
	reg [1:0] error_q;
	function automatic [1:0] sv2v_cast_2;
		input reg [1:0] inp;
		sv2v_cast_2 = inp;
	endfunction
	always @(*) begin
		error_dmi_busy = 1'b0;
		state_d = state_q;
		address_d = address_q;
		data_d = data_q;
		error_d = error_q;
		dmi_req_valid = 1'b0;
		case (state_q)
			3'd0:
				if ((dmi_access && update_dr) && (error_q == 2'h0)) begin
					address_d = dmi[40-:7];
					data_d = dmi[33-:32];
					if (sv2v_cast_2(dmi[1-:2]) == 2'h1)
						state_d = 3'd1;
					else if (sv2v_cast_2(dmi[1-:2]) == 2'h2)
						state_d = 3'd3;
				end
			3'd1: begin
				dmi_req_valid = 1'b1;
				if (dmi_req_ready)
					state_d = 3'd2;
			end
			3'd2:
				if (dmi_resp_valid) begin
					data_d = dmi_resp[33-:32];
					state_d = 3'd0;
				end
			3'd3: begin
				dmi_req_valid = 1'b1;
				if (dmi_req_ready)
					state_d = 3'd0;
			end
			default:
				if (dmi_resp_valid)
					state_d = 3'd0;
		endcase
		if (update_dr && (state_q != 3'd0))
			error_dmi_busy = 1'b1;
		if (capture_dr && |{state_q == 3'd1, state_q == 3'd2})
			error_dmi_busy = 1'b1;
		if (error_dmi_busy)
			error_d = 2'h3;
		if (dmi_reset && dtmcs_select)
			error_d = 2'h0;
	end
	assign dmi_tdo = dr_q[0];
	always @(*) begin
		dr_d = dr_q;
		if (capture_dr)
			if (dmi_access)
				if ((error_q == 2'h0) && !error_dmi_busy)
					dr_d = {address_q, data_q, 2'h0};
				else if ((error_q == 2'h3) || error_dmi_busy)
					dr_d = {address_q, data_q, 2'h3};
		if (shift_dr)
			if (dmi_access)
				dr_d = {dmi_tdi, dr_q[40:1]};
		if (test_logic_reset)
			dr_d = 1'sb0;
	end
	always @(posedge tck_i or negedge trst_ni)
		if (!trst_ni) begin
			dr_q <= 1'sb0;
			state_q <= 3'd0;
			address_q <= 1'sb0;
			data_q <= 1'sb0;
			error_q <= 2'h0;
		end
		else begin
			dr_q <= dr_d;
			state_q <= state_d;
			address_q <= address_d;
			data_q <= data_d;
			error_q <= error_d;
		end
	dmi_jtag_tap #(
		.IrLength(5),
		.IdcodeValue(IdcodeValue)
	) i_dmi_jtag_tap(
		.tck_i(tck_i),
		.tms_i(tms_i),
		.trst_ni(trst_ni),
		.td_i(td_i),
		.td_o(td_o),
		.tdo_oe_o(tdo_oe_o),
		.testmode_i(testmode_i),
		.test_logic_reset_o(test_logic_reset),
		.shift_dr_o(shift_dr),
		.update_dr_o(update_dr),
		.capture_dr_o(capture_dr),
		.dmi_access_o(dmi_access),
		.dtmcs_select_o(dtmcs_select),
		.dmi_reset_o(dmi_reset),
		.dmi_error_i(error_q),
		.dmi_tdi_o(dmi_tdi),
		.dmi_tdo_i(dmi_tdo)
	);
	dmi_cdc i_dmi_cdc(
		.tck_i(tck_i),
		.trst_ni(trst_ni),
		.jtag_dmi_req_i(dmi_req),
		.jtag_dmi_ready_o(dmi_req_ready),
		.jtag_dmi_valid_i(dmi_req_valid),
		.jtag_dmi_resp_o(dmi_resp),
		.jtag_dmi_valid_o(dmi_resp_valid),
		.jtag_dmi_ready_i(dmi_resp_ready),
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.core_dmi_req_o(dmi_req_o),
		.core_dmi_valid_o(dmi_req_valid_o),
		.core_dmi_ready_i(dmi_req_ready_i),
		.core_dmi_resp_i(dmi_resp_i),
		.core_dmi_ready_o(dmi_resp_ready_o),
		.core_dmi_valid_i(dmi_resp_valid_i)
	);
endmodule
