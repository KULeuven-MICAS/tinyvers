module mac_top (
	clk_i,
	rst_ni,
	test_mode_i,
	evt_o,
	tcdm,
	periph,
	scan_en_in
);
	parameter [31:0] N_CORES = 2;
	parameter [31:0] MP = 4;
	parameter [31:0] ID = 10;
	input wire clk_i;
	input wire rst_ni;
	input wire test_mode_i;
	localparam [31:0] hwpe_ctrl_package_REGFILE_N_EVT = 2;
	output wire [(N_CORES * hwpe_ctrl_package_REGFILE_N_EVT) - 1:0] evt_o;
	output hwpe_stream_intf_tcdm.master [MP - 1:0] tcdm;
	output hwpe_ctrl_intf_periph.slave periph;
	input wire scan_en_in;
	wire [464:0] streamer_ctrl;
	wire [83:0] streamer_flags;
	localparam [31:0] mac_package_MAC_CNT_LEN = 1024;
	wire [25:0] engine_ctrl;
	wire [75:0] engine_flags;
	hwpe_stream_intf_stream #(.DATA_WIDTH(32)) a(.clk(clk_i));
	hwpe_stream_intf_stream #(.DATA_WIDTH(32)) b(.clk(clk_i));
	hwpe_stream_intf_stream #(.DATA_WIDTH(64)) c(.clk(clk_i));
	wire enable;
	cpu_wrapper i_engine(
		.clk(clk_i),
		.reset(rst_ni),
		.enable(enable),
		.wr_addr_ext(a.sink),
		.wr_data_ext(b.sink),
		.wr_output_data(c.source),
		.ctrl_i(engine_ctrl),
		.flags_o(engine_flags),
		.scan_en_in(scan_en_in)
	);
	wire clear;
	mac_streamer #(.MP(MP)) i_streamer(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.test_mode_i(test_mode_i),
		.enable_i(enable),
		.clear_i(clear),
		.a_o(a.source),
		.b_o(b.source),
		.c_i(c.sink),
		.tcdm(tcdm),
		.ctrl_i(streamer_ctrl),
		.flags_o(streamer_flags)
	);
	mac_ctrl #(
		.N_CORES(2),
		.N_CONTEXT(2),
		.N_IO_REGS(32),
		.ID(ID)
	) i_ctrl(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.test_mode_i(scan_en_in),
		.evt_o(evt_o),
		.clear_o(clear),
		.ctrl_streamer_o(streamer_ctrl),
		.flags_streamer_i(streamer_flags),
		.ctrl_engine_o(engine_ctrl),
		.flags_engine_i(engine_flags),
		.periph(periph)
	);
	assign enable = 1'b1;
endmodule
