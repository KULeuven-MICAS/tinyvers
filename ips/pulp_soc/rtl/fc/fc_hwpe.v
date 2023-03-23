module fc_hwpe (
	clk_i,
	rst_ni,
	test_mode_i,
	hwacc_xbar_master,
	hwacc_cfg_slave,
	evt_o,
	busy_o,
	scan_en_in
);
	parameter N_MASTER_PORT = 4;
	parameter ID_WIDTH = 8;
	parameter APB_ADDR_WIDTH = 32;
	input wire clk_i;
	input wire rst_ni;
	input wire test_mode_i;
	input XBAR_TCDM_BUS.Master [N_MASTER_PORT - 1:0] hwacc_xbar_master;
	input APB_BUS.Slave hwacc_cfg_slave;
	output wire [1:0] evt_o;
	output wire busy_o;
	input wire scan_en_in;
	wire [N_MASTER_PORT - 1:0] tcdm_req;
	wire [N_MASTER_PORT - 1:0] tcdm_gnt;
	wire [(N_MASTER_PORT * 32) - 1:0] tcdm_add;
	wire [N_MASTER_PORT - 1:0] tcdm_wen;
	wire [(N_MASTER_PORT * 4) - 1:0] tcdm_be;
	wire [(N_MASTER_PORT * 32) - 1:0] tcdm_wdata;
	wire [(N_MASTER_PORT * 32) - 1:0] tcdm_r_rdata;
	wire [N_MASTER_PORT - 1:0] tcdm_r_valid;
	wire periph_req;
	wire periph_gnt;
	wire [31:0] periph_add;
	wire periph_we;
	wire [3:0] periph_be;
	wire [31:0] periph_wdata;
	wire [ID_WIDTH - 1:0] periph_id;
	wire [31:0] periph_r_rdata;
	wire periph_r_valid;
	wire [ID_WIDTH - 1:0] periph_r_id;
	wire [3:0] s_evt;
	wire periph_r_opc;
	apb2per #(
		.PER_ADDR_WIDTH(32),
		.APB_ADDR_WIDTH(APB_ADDR_WIDTH)
	) i_apb2per(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.PADDR(hwacc_cfg_slave.paddr),
		.PWDATA(hwacc_cfg_slave.pwdata),
		.PWRITE(hwacc_cfg_slave.pwrite),
		.PSEL(hwacc_cfg_slave.psel),
		.PENABLE(hwacc_cfg_slave.penable),
		.PRDATA(hwacc_cfg_slave.prdata),
		.PREADY(hwacc_cfg_slave.pready),
		.PSLVERR(hwacc_cfg_slave.pslverr),
		.per_master_req_o(periph_req),
		.per_master_add_o(periph_add),
		.per_master_we_o(periph_we),
		.per_master_wdata_o(periph_wdata),
		.per_master_be_o(periph_be),
		.per_master_gnt_i(periph_gnt),
		.per_master_r_valid_i(periph_r_valid),
		.per_master_r_opc_i(periph_r_opc),
		.per_master_r_rdata_i(periph_r_rdata)
	);
	mac_top_wrap #(.ID(ID_WIDTH)) i_mac_top_wrap(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.test_mode_i(test_mode_i),
		.tcdm_req(tcdm_req),
		.tcdm_gnt(tcdm_gnt),
		.tcdm_add(tcdm_add),
		.tcdm_wen(tcdm_wen),
		.tcdm_be(tcdm_be),
		.tcdm_data(tcdm_wdata),
		.tcdm_r_data(tcdm_r_rdata),
		.tcdm_r_valid(tcdm_r_valid),
		.periph_req(periph_req),
		.periph_gnt(periph_gnt),
		.periph_add(periph_add),
		.periph_wen(~periph_we),
		.periph_be(periph_be),
		.periph_data(periph_wdata),
		.periph_id(1'sb0),
		.periph_r_data(periph_r_rdata),
		.periph_r_valid(periph_r_valid),
		.periph_r_id(periph_r_id),
		.evt_o(s_evt),
		.scan_en_in(scan_en_in)
	);
	assign busy_o = 1'b1;
	assign evt_o = s_evt[0];
	genvar i;
	generate
		for (i = 0; i < 4; i = i + 1) begin : hwacc_binding
			assign hwacc_xbar_master[i].req = tcdm_req[i];
			assign hwacc_xbar_master[i].add = tcdm_add[i * 32+:32];
			assign hwacc_xbar_master[i].wen = tcdm_wen[i];
			assign hwacc_xbar_master[i].wdata = tcdm_wdata[i * 32+:32];
			assign hwacc_xbar_master[i].be = tcdm_be[i * 4+:4];
			assign tcdm_gnt[i] = hwacc_xbar_master[i].gnt;
			assign tcdm_r_rdata[i * 32+:32] = hwacc_xbar_master[i].r_rdata;
			assign tcdm_r_valid[i] = hwacc_xbar_master[i].r_valid;
		end
	endgenerate
endmodule
