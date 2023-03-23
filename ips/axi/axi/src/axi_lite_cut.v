module axi_lite_cut (
	clk_i,
	rst_ni,
	in,
	out
);
	parameter signed [31:0] ADDR_WIDTH = -1;
	parameter signed [31:0] DATA_WIDTH = -1;
	input wire clk_i;
	input wire rst_ni;
	input AXI_LITE.Slave in;
	input AXI_LITE.Master out;
	wire [ADDR_WIDTH - 1:0] aw_in;
	wire [ADDR_WIDTH - 1:0] aw_out;
	assign aw_in[ADDR_WIDTH - 1-:ADDR_WIDTH] = in.aw_addr;
	assign out.aw_addr = aw_out[ADDR_WIDTH - 1-:ADDR_WIDTH];
	spill_register_99447_1BBF7 #(._ADDR_WIDTH(ADDR_WIDTH)) i_reg_aw(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.valid_i(in.aw_valid),
		.ready_o(in.aw_ready),
		.data_i(aw_in),
		.valid_o(out.aw_valid),
		.ready_i(out.aw_ready),
		.data_o(aw_out)
	);
	wire [(DATA_WIDTH + (DATA_WIDTH / 8)) - 1:0] w_in;
	wire [(DATA_WIDTH + (DATA_WIDTH / 8)) - 1:0] w_out;
	assign w_in[DATA_WIDTH + ((DATA_WIDTH / 8) - 1)-:((DATA_WIDTH + ((DATA_WIDTH / 8) - 1)) >= ((DATA_WIDTH / 8) + 0) ? ((DATA_WIDTH + ((DATA_WIDTH / 8) - 1)) - ((DATA_WIDTH / 8) + 0)) + 1 : (((DATA_WIDTH / 8) + 0) - (DATA_WIDTH + ((DATA_WIDTH / 8) - 1))) + 1)] = in.w_data;
	assign w_in[(DATA_WIDTH / 8) - 1-:DATA_WIDTH / 8] = in.w_strb;
	assign out.w_data = w_out[DATA_WIDTH + ((DATA_WIDTH / 8) - 1)-:((DATA_WIDTH + ((DATA_WIDTH / 8) - 1)) >= ((DATA_WIDTH / 8) + 0) ? ((DATA_WIDTH + ((DATA_WIDTH / 8) - 1)) - ((DATA_WIDTH / 8) + 0)) + 1 : (((DATA_WIDTH / 8) + 0) - (DATA_WIDTH + ((DATA_WIDTH / 8) - 1))) + 1)];
	assign out.w_strb = w_out[(DATA_WIDTH / 8) - 1-:DATA_WIDTH / 8];
	spill_register_055F4_21499 #(._DATA_WIDTH(DATA_WIDTH)) i_reg_w(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.valid_i(in.w_valid),
		.ready_o(in.w_ready),
		.data_i(w_in),
		.valid_o(out.w_valid),
		.ready_i(out.w_ready),
		.data_o(w_out)
	);
	wire [1:0] b_in;
	wire [1:0] b_out;
	assign b_out[1-:2] = out.b_resp;
	assign in.b_resp = b_in[1-:2];
	spill_register_54DD8 i_reg_b(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.valid_i(out.b_valid),
		.ready_o(out.b_ready),
		.data_i(b_out),
		.valid_o(in.b_valid),
		.ready_i(in.b_ready),
		.data_o(b_in)
	);
	wire [ADDR_WIDTH - 1:0] ar_in;
	wire [ADDR_WIDTH - 1:0] ar_out;
	assign ar_in[ADDR_WIDTH - 1-:ADDR_WIDTH] = in.ar_addr;
	assign out.ar_addr = ar_out[ADDR_WIDTH - 1-:ADDR_WIDTH];
	spill_register_99447_1BBF7 #(._ADDR_WIDTH(ADDR_WIDTH)) i_reg_ar(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.valid_i(in.ar_valid),
		.ready_o(in.ar_ready),
		.data_i(ar_in),
		.valid_o(out.ar_valid),
		.ready_i(out.ar_ready),
		.data_o(ar_out)
	);
	wire [DATA_WIDTH + 1:0] r_in;
	wire [DATA_WIDTH + 1:0] r_out;
	assign r_out[DATA_WIDTH + 1-:((DATA_WIDTH + 1) >= 2 ? DATA_WIDTH + 0 : 3 - (DATA_WIDTH + 1))] = out.r_data;
	assign r_out[1-:2] = out.r_resp;
	assign in.r_data = r_in[DATA_WIDTH + 1-:((DATA_WIDTH + 1) >= 2 ? DATA_WIDTH + 0 : 3 - (DATA_WIDTH + 1))];
	assign in.r_resp = r_in[1-:2];
	spill_register_1191C_E5E1C #(._DATA_WIDTH(DATA_WIDTH)) i_reg_r(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.valid_i(out.r_valid),
		.ready_o(out.r_ready),
		.data_i(r_out),
		.valid_o(in.r_valid),
		.ready_i(in.r_ready),
		.data_o(r_in)
	);
endmodule
