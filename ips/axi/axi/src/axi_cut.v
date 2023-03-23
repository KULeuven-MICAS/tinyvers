module axi_cut (
	clk_i,
	rst_ni,
	in,
	out
);
	parameter signed [31:0] ADDR_WIDTH = -1;
	parameter signed [31:0] DATA_WIDTH = -1;
	parameter signed [31:0] ID_WIDTH = -1;
	parameter signed [31:0] USER_WIDTH = -1;
	input wire clk_i;
	input wire rst_ni;
	input AXI_BUS.Slave in;
	input AXI_BUS.Master out;
	localparam STRB_WIDTH = DATA_WIDTH / 8;
	wire [(((ID_WIDTH + ADDR_WIDTH) + 35) + USER_WIDTH) - 1:0] aw_in;
	wire [(((ID_WIDTH + ADDR_WIDTH) + 35) + USER_WIDTH) - 1:0] aw_out;
	assign aw_in[ID_WIDTH + (ADDR_WIDTH + (29 + (USER_WIDTH + 5)))-:((ID_WIDTH + (ADDR_WIDTH + (29 + (USER_WIDTH + 5)))) >= (ADDR_WIDTH + (35 + (USER_WIDTH + 0))) ? ((ID_WIDTH + (ADDR_WIDTH + (29 + (USER_WIDTH + 5)))) - (ADDR_WIDTH + (35 + (USER_WIDTH + 0)))) + 1 : ((ADDR_WIDTH + (35 + (USER_WIDTH + 0))) - (ID_WIDTH + (ADDR_WIDTH + (29 + (USER_WIDTH + 5))))) + 1)] = in.aw_id;
	assign aw_in[ADDR_WIDTH + (29 + (USER_WIDTH + 5))-:((ADDR_WIDTH + (29 + (USER_WIDTH + 5))) >= (35 + (USER_WIDTH + 0)) ? ((ADDR_WIDTH + (29 + (USER_WIDTH + 5))) - (35 + (USER_WIDTH + 0))) + 1 : ((35 + (USER_WIDTH + 0)) - (ADDR_WIDTH + (29 + (USER_WIDTH + 5)))) + 1)] = in.aw_addr;
	assign aw_in[29 + (USER_WIDTH + 5)-:((29 + (USER_WIDTH + 5)) >= (27 + (USER_WIDTH + 0)) ? ((29 + (USER_WIDTH + 5)) - (27 + (USER_WIDTH + 0))) + 1 : ((27 + (USER_WIDTH + 0)) - (29 + (USER_WIDTH + 5))) + 1)] = in.aw_len;
	assign aw_in[17 + (USER_WIDTH + 9)-:((17 + (USER_WIDTH + 9)) >= (24 + (USER_WIDTH + 0)) ? ((17 + (USER_WIDTH + 9)) - (24 + (USER_WIDTH + 0))) + 1 : ((24 + (USER_WIDTH + 0)) - (17 + (USER_WIDTH + 9))) + 1)] = in.aw_size;
	assign aw_in[18 + (USER_WIDTH + 5)-:((18 + (USER_WIDTH + 5)) >= (22 + (USER_WIDTH + 0)) ? ((18 + (USER_WIDTH + 5)) - (22 + (USER_WIDTH + 0))) + 1 : ((22 + (USER_WIDTH + 0)) - (18 + (USER_WIDTH + 5))) + 1)] = in.aw_burst;
	assign aw_in[12 + (USER_WIDTH + 9)] = in.aw_lock;
	assign aw_in[15 + (USER_WIDTH + 5)-:((15 + (USER_WIDTH + 5)) >= (17 + (USER_WIDTH + 0)) ? ((15 + (USER_WIDTH + 5)) - (17 + (USER_WIDTH + 0))) + 1 : ((17 + (USER_WIDTH + 0)) - (15 + (USER_WIDTH + 5))) + 1)] = in.aw_cache;
	assign aw_in[7 + (USER_WIDTH + 9)-:((7 + (USER_WIDTH + 9)) >= (14 + (USER_WIDTH + 0)) ? ((7 + (USER_WIDTH + 9)) - (14 + (USER_WIDTH + 0))) + 1 : ((14 + (USER_WIDTH + 0)) - (7 + (USER_WIDTH + 9))) + 1)] = in.aw_prot;
	assign aw_in[8 + (USER_WIDTH + 5)-:((8 + (USER_WIDTH + 5)) >= (10 + (USER_WIDTH + 0)) ? ((8 + (USER_WIDTH + 5)) - (10 + (USER_WIDTH + 0))) + 1 : ((10 + (USER_WIDTH + 0)) - (8 + (USER_WIDTH + 5))) + 1)] = in.aw_qos;
	assign aw_in[USER_WIDTH + 9-:((USER_WIDTH + 9) >= (6 + (USER_WIDTH + 0)) ? ((USER_WIDTH + 9) - (6 + (USER_WIDTH + 0))) + 1 : ((6 + (USER_WIDTH + 0)) - (USER_WIDTH + 9)) + 1)] = in.aw_region;
	assign aw_in[USER_WIDTH + 5-:((USER_WIDTH + 5) >= (USER_WIDTH + 0) ? ((USER_WIDTH + 5) - (USER_WIDTH + 0)) + 1 : ((USER_WIDTH + 0) - (USER_WIDTH + 5)) + 1)] = in.aw_atop;
	assign aw_in[USER_WIDTH - 1-:USER_WIDTH] = in.aw_user;
	assign out.aw_id = aw_out[ID_WIDTH + (ADDR_WIDTH + (29 + (USER_WIDTH + 5)))-:((ID_WIDTH + (ADDR_WIDTH + (29 + (USER_WIDTH + 5)))) >= (ADDR_WIDTH + (35 + (USER_WIDTH + 0))) ? ((ID_WIDTH + (ADDR_WIDTH + (29 + (USER_WIDTH + 5)))) - (ADDR_WIDTH + (35 + (USER_WIDTH + 0)))) + 1 : ((ADDR_WIDTH + (35 + (USER_WIDTH + 0))) - (ID_WIDTH + (ADDR_WIDTH + (29 + (USER_WIDTH + 5))))) + 1)];
	assign out.aw_addr = aw_out[ADDR_WIDTH + (29 + (USER_WIDTH + 5))-:((ADDR_WIDTH + (29 + (USER_WIDTH + 5))) >= (35 + (USER_WIDTH + 0)) ? ((ADDR_WIDTH + (29 + (USER_WIDTH + 5))) - (35 + (USER_WIDTH + 0))) + 1 : ((35 + (USER_WIDTH + 0)) - (ADDR_WIDTH + (29 + (USER_WIDTH + 5)))) + 1)];
	assign out.aw_len = aw_out[29 + (USER_WIDTH + 5)-:((29 + (USER_WIDTH + 5)) >= (27 + (USER_WIDTH + 0)) ? ((29 + (USER_WIDTH + 5)) - (27 + (USER_WIDTH + 0))) + 1 : ((27 + (USER_WIDTH + 0)) - (29 + (USER_WIDTH + 5))) + 1)];
	assign out.aw_size = aw_out[17 + (USER_WIDTH + 9)-:((17 + (USER_WIDTH + 9)) >= (24 + (USER_WIDTH + 0)) ? ((17 + (USER_WIDTH + 9)) - (24 + (USER_WIDTH + 0))) + 1 : ((24 + (USER_WIDTH + 0)) - (17 + (USER_WIDTH + 9))) + 1)];
	assign out.aw_burst = aw_out[18 + (USER_WIDTH + 5)-:((18 + (USER_WIDTH + 5)) >= (22 + (USER_WIDTH + 0)) ? ((18 + (USER_WIDTH + 5)) - (22 + (USER_WIDTH + 0))) + 1 : ((22 + (USER_WIDTH + 0)) - (18 + (USER_WIDTH + 5))) + 1)];
	assign out.aw_lock = aw_out[12 + (USER_WIDTH + 9)];
	assign out.aw_cache = aw_out[15 + (USER_WIDTH + 5)-:((15 + (USER_WIDTH + 5)) >= (17 + (USER_WIDTH + 0)) ? ((15 + (USER_WIDTH + 5)) - (17 + (USER_WIDTH + 0))) + 1 : ((17 + (USER_WIDTH + 0)) - (15 + (USER_WIDTH + 5))) + 1)];
	assign out.aw_prot = aw_out[7 + (USER_WIDTH + 9)-:((7 + (USER_WIDTH + 9)) >= (14 + (USER_WIDTH + 0)) ? ((7 + (USER_WIDTH + 9)) - (14 + (USER_WIDTH + 0))) + 1 : ((14 + (USER_WIDTH + 0)) - (7 + (USER_WIDTH + 9))) + 1)];
	assign out.aw_qos = aw_out[8 + (USER_WIDTH + 5)-:((8 + (USER_WIDTH + 5)) >= (10 + (USER_WIDTH + 0)) ? ((8 + (USER_WIDTH + 5)) - (10 + (USER_WIDTH + 0))) + 1 : ((10 + (USER_WIDTH + 0)) - (8 + (USER_WIDTH + 5))) + 1)];
	assign out.aw_region = aw_out[USER_WIDTH + 9-:((USER_WIDTH + 9) >= (6 + (USER_WIDTH + 0)) ? ((USER_WIDTH + 9) - (6 + (USER_WIDTH + 0))) + 1 : ((6 + (USER_WIDTH + 0)) - (USER_WIDTH + 9)) + 1)];
	assign out.aw_atop = aw_out[USER_WIDTH + 5-:((USER_WIDTH + 5) >= (USER_WIDTH + 0) ? ((USER_WIDTH + 5) - (USER_WIDTH + 0)) + 1 : ((USER_WIDTH + 0) - (USER_WIDTH + 5)) + 1)];
	assign out.aw_user = aw_out[USER_WIDTH - 1-:USER_WIDTH];
	spill_register_FAEE3_E3265 #(
		.T_ADDR_WIDTH(ADDR_WIDTH),
		.T_ID_WIDTH(ID_WIDTH),
		.T_USER_WIDTH(USER_WIDTH)
	) i_reg_aw(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.valid_i(in.aw_valid),
		.ready_o(in.aw_ready),
		.data_i(aw_in),
		.valid_o(out.aw_valid),
		.ready_i(out.aw_ready),
		.data_o(aw_out)
	);
	wire [(((DATA_WIDTH + STRB_WIDTH) + 1) + USER_WIDTH) - 1:0] w_in;
	wire [(((DATA_WIDTH + STRB_WIDTH) + 1) + USER_WIDTH) - 1:0] w_out;
	assign w_in[DATA_WIDTH + (STRB_WIDTH + (USER_WIDTH + 0))-:((DATA_WIDTH + (STRB_WIDTH + (USER_WIDTH + 0))) >= (STRB_WIDTH + (1 + (USER_WIDTH + 0))) ? ((DATA_WIDTH + (STRB_WIDTH + (USER_WIDTH + 0))) - (STRB_WIDTH + (1 + (USER_WIDTH + 0)))) + 1 : ((STRB_WIDTH + (1 + (USER_WIDTH + 0))) - (DATA_WIDTH + (STRB_WIDTH + (USER_WIDTH + 0)))) + 1)] = in.w_data;
	assign w_in[STRB_WIDTH + (USER_WIDTH + 0)-:((STRB_WIDTH + (USER_WIDTH + 0)) >= (1 + (USER_WIDTH + 0)) ? ((STRB_WIDTH + (USER_WIDTH + 0)) - (1 + (USER_WIDTH + 0))) + 1 : ((1 + (USER_WIDTH + 0)) - (STRB_WIDTH + (USER_WIDTH + 0))) + 1)] = in.w_strb;
	assign w_in[USER_WIDTH + 0] = in.w_last;
	assign w_in[USER_WIDTH - 1-:USER_WIDTH] = in.w_user;
	assign out.w_data = w_out[DATA_WIDTH + (STRB_WIDTH + (USER_WIDTH + 0))-:((DATA_WIDTH + (STRB_WIDTH + (USER_WIDTH + 0))) >= (STRB_WIDTH + (1 + (USER_WIDTH + 0))) ? ((DATA_WIDTH + (STRB_WIDTH + (USER_WIDTH + 0))) - (STRB_WIDTH + (1 + (USER_WIDTH + 0)))) + 1 : ((STRB_WIDTH + (1 + (USER_WIDTH + 0))) - (DATA_WIDTH + (STRB_WIDTH + (USER_WIDTH + 0)))) + 1)];
	assign out.w_strb = w_out[STRB_WIDTH + (USER_WIDTH + 0)-:((STRB_WIDTH + (USER_WIDTH + 0)) >= (1 + (USER_WIDTH + 0)) ? ((STRB_WIDTH + (USER_WIDTH + 0)) - (1 + (USER_WIDTH + 0))) + 1 : ((1 + (USER_WIDTH + 0)) - (STRB_WIDTH + (USER_WIDTH + 0))) + 1)];
	assign out.w_last = w_out[USER_WIDTH + 0];
	assign out.w_user = w_out[USER_WIDTH - 1-:USER_WIDTH];
	spill_register_B3625_AA1CA #(
		.T_DATA_WIDTH(DATA_WIDTH),
		.T_STRB_WIDTH(STRB_WIDTH),
		.T_USER_WIDTH(USER_WIDTH)
	) i_reg_w(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.valid_i(in.w_valid),
		.ready_o(in.w_ready),
		.data_i(w_in),
		.valid_o(out.w_valid),
		.ready_i(out.w_ready),
		.data_o(w_out)
	);
	wire [((ID_WIDTH + 2) + USER_WIDTH) - 1:0] b_in;
	wire [((ID_WIDTH + 2) + USER_WIDTH) - 1:0] b_out;
	assign b_out[ID_WIDTH + (USER_WIDTH + 1)-:((ID_WIDTH + (USER_WIDTH + 1)) >= (2 + (USER_WIDTH + 0)) ? ((ID_WIDTH + (USER_WIDTH + 1)) - (2 + (USER_WIDTH + 0))) + 1 : ((2 + (USER_WIDTH + 0)) - (ID_WIDTH + (USER_WIDTH + 1))) + 1)] = out.b_id;
	assign b_out[USER_WIDTH + 1-:((USER_WIDTH + 1) >= (USER_WIDTH + 0) ? ((USER_WIDTH + 1) - (USER_WIDTH + 0)) + 1 : ((USER_WIDTH + 0) - (USER_WIDTH + 1)) + 1)] = out.b_resp;
	assign b_out[USER_WIDTH - 1-:USER_WIDTH] = out.b_user;
	assign in.b_id = b_in[ID_WIDTH + (USER_WIDTH + 1)-:((ID_WIDTH + (USER_WIDTH + 1)) >= (2 + (USER_WIDTH + 0)) ? ((ID_WIDTH + (USER_WIDTH + 1)) - (2 + (USER_WIDTH + 0))) + 1 : ((2 + (USER_WIDTH + 0)) - (ID_WIDTH + (USER_WIDTH + 1))) + 1)];
	assign in.b_resp = b_in[USER_WIDTH + 1-:((USER_WIDTH + 1) >= (USER_WIDTH + 0) ? ((USER_WIDTH + 1) - (USER_WIDTH + 0)) + 1 : ((USER_WIDTH + 0) - (USER_WIDTH + 1)) + 1)];
	assign in.b_user = b_in[USER_WIDTH - 1-:USER_WIDTH];
	spill_register_37E5C_79622 #(
		.T_ID_WIDTH(ID_WIDTH),
		.T_USER_WIDTH(USER_WIDTH)
	) i_reg_b(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.valid_i(out.b_valid),
		.ready_o(out.b_ready),
		.data_i(b_out),
		.valid_o(in.b_valid),
		.ready_i(in.b_ready),
		.data_o(b_in)
	);
	wire [(((ID_WIDTH + ADDR_WIDTH) + 35) + USER_WIDTH) - 1:0] ar_in;
	wire [(((ID_WIDTH + ADDR_WIDTH) + 35) + USER_WIDTH) - 1:0] ar_out;
	assign ar_in[ID_WIDTH + (ADDR_WIDTH + (29 + (USER_WIDTH + 5)))-:((ID_WIDTH + (ADDR_WIDTH + (29 + (USER_WIDTH + 5)))) >= (ADDR_WIDTH + (35 + (USER_WIDTH + 0))) ? ((ID_WIDTH + (ADDR_WIDTH + (29 + (USER_WIDTH + 5)))) - (ADDR_WIDTH + (35 + (USER_WIDTH + 0)))) + 1 : ((ADDR_WIDTH + (35 + (USER_WIDTH + 0))) - (ID_WIDTH + (ADDR_WIDTH + (29 + (USER_WIDTH + 5))))) + 1)] = in.ar_id;
	assign ar_in[ADDR_WIDTH + (29 + (USER_WIDTH + 5))-:((ADDR_WIDTH + (29 + (USER_WIDTH + 5))) >= (35 + (USER_WIDTH + 0)) ? ((ADDR_WIDTH + (29 + (USER_WIDTH + 5))) - (35 + (USER_WIDTH + 0))) + 1 : ((35 + (USER_WIDTH + 0)) - (ADDR_WIDTH + (29 + (USER_WIDTH + 5)))) + 1)] = in.ar_addr;
	assign ar_in[29 + (USER_WIDTH + 5)-:((29 + (USER_WIDTH + 5)) >= (27 + (USER_WIDTH + 0)) ? ((29 + (USER_WIDTH + 5)) - (27 + (USER_WIDTH + 0))) + 1 : ((27 + (USER_WIDTH + 0)) - (29 + (USER_WIDTH + 5))) + 1)] = in.ar_len;
	assign ar_in[17 + (USER_WIDTH + 9)-:((17 + (USER_WIDTH + 9)) >= (24 + (USER_WIDTH + 0)) ? ((17 + (USER_WIDTH + 9)) - (24 + (USER_WIDTH + 0))) + 1 : ((24 + (USER_WIDTH + 0)) - (17 + (USER_WIDTH + 9))) + 1)] = in.ar_size;
	assign ar_in[18 + (USER_WIDTH + 5)-:((18 + (USER_WIDTH + 5)) >= (22 + (USER_WIDTH + 0)) ? ((18 + (USER_WIDTH + 5)) - (22 + (USER_WIDTH + 0))) + 1 : ((22 + (USER_WIDTH + 0)) - (18 + (USER_WIDTH + 5))) + 1)] = in.ar_burst;
	assign ar_in[12 + (USER_WIDTH + 9)] = in.ar_lock;
	assign ar_in[15 + (USER_WIDTH + 5)-:((15 + (USER_WIDTH + 5)) >= (17 + (USER_WIDTH + 0)) ? ((15 + (USER_WIDTH + 5)) - (17 + (USER_WIDTH + 0))) + 1 : ((17 + (USER_WIDTH + 0)) - (15 + (USER_WIDTH + 5))) + 1)] = in.ar_cache;
	assign ar_in[7 + (USER_WIDTH + 9)-:((7 + (USER_WIDTH + 9)) >= (14 + (USER_WIDTH + 0)) ? ((7 + (USER_WIDTH + 9)) - (14 + (USER_WIDTH + 0))) + 1 : ((14 + (USER_WIDTH + 0)) - (7 + (USER_WIDTH + 9))) + 1)] = in.ar_prot;
	assign ar_in[8 + (USER_WIDTH + 5)-:((8 + (USER_WIDTH + 5)) >= (10 + (USER_WIDTH + 0)) ? ((8 + (USER_WIDTH + 5)) - (10 + (USER_WIDTH + 0))) + 1 : ((10 + (USER_WIDTH + 0)) - (8 + (USER_WIDTH + 5))) + 1)] = in.ar_qos;
	assign ar_in[USER_WIDTH + 9-:((USER_WIDTH + 9) >= (6 + (USER_WIDTH + 0)) ? ((USER_WIDTH + 9) - (6 + (USER_WIDTH + 0))) + 1 : ((6 + (USER_WIDTH + 0)) - (USER_WIDTH + 9)) + 1)] = in.ar_region;
	assign ar_in[USER_WIDTH + 5-:((USER_WIDTH + 5) >= (USER_WIDTH + 0) ? ((USER_WIDTH + 5) - (USER_WIDTH + 0)) + 1 : ((USER_WIDTH + 0) - (USER_WIDTH + 5)) + 1)] = 1'sbx;
	assign ar_in[USER_WIDTH - 1-:USER_WIDTH] = in.ar_user;
	assign out.ar_id = ar_out[ID_WIDTH + (ADDR_WIDTH + (29 + (USER_WIDTH + 5)))-:((ID_WIDTH + (ADDR_WIDTH + (29 + (USER_WIDTH + 5)))) >= (ADDR_WIDTH + (35 + (USER_WIDTH + 0))) ? ((ID_WIDTH + (ADDR_WIDTH + (29 + (USER_WIDTH + 5)))) - (ADDR_WIDTH + (35 + (USER_WIDTH + 0)))) + 1 : ((ADDR_WIDTH + (35 + (USER_WIDTH + 0))) - (ID_WIDTH + (ADDR_WIDTH + (29 + (USER_WIDTH + 5))))) + 1)];
	assign out.ar_addr = ar_out[ADDR_WIDTH + (29 + (USER_WIDTH + 5))-:((ADDR_WIDTH + (29 + (USER_WIDTH + 5))) >= (35 + (USER_WIDTH + 0)) ? ((ADDR_WIDTH + (29 + (USER_WIDTH + 5))) - (35 + (USER_WIDTH + 0))) + 1 : ((35 + (USER_WIDTH + 0)) - (ADDR_WIDTH + (29 + (USER_WIDTH + 5)))) + 1)];
	assign out.ar_len = ar_out[29 + (USER_WIDTH + 5)-:((29 + (USER_WIDTH + 5)) >= (27 + (USER_WIDTH + 0)) ? ((29 + (USER_WIDTH + 5)) - (27 + (USER_WIDTH + 0))) + 1 : ((27 + (USER_WIDTH + 0)) - (29 + (USER_WIDTH + 5))) + 1)];
	assign out.ar_size = ar_out[17 + (USER_WIDTH + 9)-:((17 + (USER_WIDTH + 9)) >= (24 + (USER_WIDTH + 0)) ? ((17 + (USER_WIDTH + 9)) - (24 + (USER_WIDTH + 0))) + 1 : ((24 + (USER_WIDTH + 0)) - (17 + (USER_WIDTH + 9))) + 1)];
	assign out.ar_burst = ar_out[18 + (USER_WIDTH + 5)-:((18 + (USER_WIDTH + 5)) >= (22 + (USER_WIDTH + 0)) ? ((18 + (USER_WIDTH + 5)) - (22 + (USER_WIDTH + 0))) + 1 : ((22 + (USER_WIDTH + 0)) - (18 + (USER_WIDTH + 5))) + 1)];
	assign out.ar_lock = ar_out[12 + (USER_WIDTH + 9)];
	assign out.ar_cache = ar_out[15 + (USER_WIDTH + 5)-:((15 + (USER_WIDTH + 5)) >= (17 + (USER_WIDTH + 0)) ? ((15 + (USER_WIDTH + 5)) - (17 + (USER_WIDTH + 0))) + 1 : ((17 + (USER_WIDTH + 0)) - (15 + (USER_WIDTH + 5))) + 1)];
	assign out.ar_prot = ar_out[7 + (USER_WIDTH + 9)-:((7 + (USER_WIDTH + 9)) >= (14 + (USER_WIDTH + 0)) ? ((7 + (USER_WIDTH + 9)) - (14 + (USER_WIDTH + 0))) + 1 : ((14 + (USER_WIDTH + 0)) - (7 + (USER_WIDTH + 9))) + 1)];
	assign out.ar_qos = ar_out[8 + (USER_WIDTH + 5)-:((8 + (USER_WIDTH + 5)) >= (10 + (USER_WIDTH + 0)) ? ((8 + (USER_WIDTH + 5)) - (10 + (USER_WIDTH + 0))) + 1 : ((10 + (USER_WIDTH + 0)) - (8 + (USER_WIDTH + 5))) + 1)];
	assign out.ar_region = ar_out[USER_WIDTH + 9-:((USER_WIDTH + 9) >= (6 + (USER_WIDTH + 0)) ? ((USER_WIDTH + 9) - (6 + (USER_WIDTH + 0))) + 1 : ((6 + (USER_WIDTH + 0)) - (USER_WIDTH + 9)) + 1)];
	assign out.ar_user = ar_out[USER_WIDTH - 1-:USER_WIDTH];
	spill_register_FAEE3_E3265 #(
		.T_ADDR_WIDTH(ADDR_WIDTH),
		.T_ID_WIDTH(ID_WIDTH),
		.T_USER_WIDTH(USER_WIDTH)
	) i_reg_ar(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.valid_i(in.ar_valid),
		.ready_o(in.ar_ready),
		.data_i(ar_in),
		.valid_o(out.ar_valid),
		.ready_i(out.ar_ready),
		.data_o(ar_out)
	);
	wire [(((ID_WIDTH + DATA_WIDTH) + 3) + USER_WIDTH) - 1:0] r_in;
	wire [(((ID_WIDTH + DATA_WIDTH) + 3) + USER_WIDTH) - 1:0] r_out;
	assign r_out[ID_WIDTH + (DATA_WIDTH + (USER_WIDTH + 2))-:((ID_WIDTH + (DATA_WIDTH + (USER_WIDTH + 2))) >= (DATA_WIDTH + (3 + (USER_WIDTH + 0))) ? ((ID_WIDTH + (DATA_WIDTH + (USER_WIDTH + 2))) - (DATA_WIDTH + (3 + (USER_WIDTH + 0)))) + 1 : ((DATA_WIDTH + (3 + (USER_WIDTH + 0))) - (ID_WIDTH + (DATA_WIDTH + (USER_WIDTH + 2)))) + 1)] = out.r_id;
	assign r_out[DATA_WIDTH + (USER_WIDTH + 2)-:((DATA_WIDTH + (USER_WIDTH + 2)) >= (3 + (USER_WIDTH + 0)) ? ((DATA_WIDTH + (USER_WIDTH + 2)) - (3 + (USER_WIDTH + 0))) + 1 : ((3 + (USER_WIDTH + 0)) - (DATA_WIDTH + (USER_WIDTH + 2))) + 1)] = out.r_data;
	assign r_out[USER_WIDTH + 2-:((USER_WIDTH + 2) >= (1 + (USER_WIDTH + 0)) ? ((USER_WIDTH + 2) - (1 + (USER_WIDTH + 0))) + 1 : ((1 + (USER_WIDTH + 0)) - (USER_WIDTH + 2)) + 1)] = out.r_resp;
	assign r_out[USER_WIDTH + 0] = out.r_last;
	assign r_out[USER_WIDTH - 1-:USER_WIDTH] = out.r_user;
	assign in.r_id = r_in[ID_WIDTH + (DATA_WIDTH + (USER_WIDTH + 2))-:((ID_WIDTH + (DATA_WIDTH + (USER_WIDTH + 2))) >= (DATA_WIDTH + (3 + (USER_WIDTH + 0))) ? ((ID_WIDTH + (DATA_WIDTH + (USER_WIDTH + 2))) - (DATA_WIDTH + (3 + (USER_WIDTH + 0)))) + 1 : ((DATA_WIDTH + (3 + (USER_WIDTH + 0))) - (ID_WIDTH + (DATA_WIDTH + (USER_WIDTH + 2)))) + 1)];
	assign in.r_data = r_in[DATA_WIDTH + (USER_WIDTH + 2)-:((DATA_WIDTH + (USER_WIDTH + 2)) >= (3 + (USER_WIDTH + 0)) ? ((DATA_WIDTH + (USER_WIDTH + 2)) - (3 + (USER_WIDTH + 0))) + 1 : ((3 + (USER_WIDTH + 0)) - (DATA_WIDTH + (USER_WIDTH + 2))) + 1)];
	assign in.r_resp = r_in[USER_WIDTH + 2-:((USER_WIDTH + 2) >= (1 + (USER_WIDTH + 0)) ? ((USER_WIDTH + 2) - (1 + (USER_WIDTH + 0))) + 1 : ((1 + (USER_WIDTH + 0)) - (USER_WIDTH + 2)) + 1)];
	assign in.r_last = r_in[USER_WIDTH + 0];
	assign in.r_user = r_in[USER_WIDTH - 1-:USER_WIDTH];
	spill_register_52F25_7B672 #(
		.T_DATA_WIDTH(DATA_WIDTH),
		.T_ID_WIDTH(ID_WIDTH),
		.T_USER_WIDTH(USER_WIDTH)
	) i_reg_r(
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
