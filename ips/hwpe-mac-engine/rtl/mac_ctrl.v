module mac_ctrl (
	clk_i,
	rst_ni,
	test_mode_i,
	clear_o,
	evt_o,
	ctrl_streamer_o,
	flags_streamer_i,
	ctrl_engine_o,
	flags_engine_i,
	periph
);
	parameter [31:0] N_CORES = 2;
	parameter [31:0] N_CONTEXT = 2;
	parameter [31:0] N_IO_REGS = 16;
	parameter [31:0] ID = 10;
	parameter [31:0] UCODE_HARDWIRED = 0;
	input wire clk_i;
	input wire rst_ni;
	input wire test_mode_i;
	output wire clear_o;
	localparam [31:0] hwpe_ctrl_package_REGFILE_N_EVT = 2;
	output wire [(N_CORES * hwpe_ctrl_package_REGFILE_N_EVT) - 1:0] evt_o;
	output wire [464:0] ctrl_streamer_o;
	input wire [83:0] flags_streamer_i;
	localparam [31:0] mac_package_MAC_CNT_LEN = 1024;
	output wire [25:0] ctrl_engine_o;
	input wire [75:0] flags_engine_i;
	input hwpe_ctrl_intf_periph.slave periph;
	wire [1:0] slave_ctrl;
	localparam [31:0] hwpe_ctrl_package_REGFILE_N_CORES = 8;
	wire [(1 + (hwpe_ctrl_package_REGFILE_N_CORES * hwpe_ctrl_package_REGFILE_N_EVT)) + 2:0] slave_flags;
	localparam [31:0] hwpe_ctrl_package_REGFILE_N_MAX_GENERIC_REGS = 8;
	localparam [31:0] hwpe_ctrl_package_REGFILE_N_MAX_IO_REGS = 48;
	wire [1791:0] reg_file;
	wire [31:0] static_reg_nb_iter;
	wire [31:0] static_reg_len_iter;
	wire [31:0] static_reg_vectstride;
	wire [31:0] static_reg_onestride;
	wire [15:0] static_reg_shift;
	wire static_reg_simplemul;
	wire [223:0] ucode_flat;
	localparam [31:0] hwpe_ctrl_package_UCODE_CNT_WIDTH = 12;
	localparam [31:0] hwpe_ctrl_package_UCODE_LENGTH = 16;
	localparam [31:0] hwpe_ctrl_package_UCODE_NB_LOOPS = 6;
	wire [(224 + (hwpe_ctrl_package_UCODE_NB_LOOPS * hwpe_ctrl_package_UCODE_CNT_WIDTH)) - 1:0] ucode;
	wire [4:0] ucode_ctrl;
	localparam [31:0] hwpe_ctrl_package_UCODE_NB_REG = 4;
	wire [(130 + (hwpe_ctrl_package_UCODE_NB_LOOPS * hwpe_ctrl_package_UCODE_CNT_WIDTH)) + 0:0] ucode_flags;
	wire [383:0] ucode_registers_read;
	wire [16:0] fsm_ctrl;
	hwpe_ctrl_slave #(
		.N_CORES(N_CORES),
		.N_CONTEXT(N_CONTEXT),
		.N_IO_REGS(N_IO_REGS),
		.N_GENERIC_REGS((1 - UCODE_HARDWIRED) * 8),
		.ID_WIDTH(ID)
	) i_slave(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.clear_o(clear_o),
		.scan_en_in(test_mode_i),
		.cfg(periph),
		.ctrl_i(slave_ctrl),
		.flags_o(slave_flags),
		.reg_file(reg_file)
	);
	assign evt_o = slave_flags[(hwpe_ctrl_package_REGFILE_N_CORES * hwpe_ctrl_package_REGFILE_N_EVT) + 2-:(((hwpe_ctrl_package_REGFILE_N_CORES * hwpe_ctrl_package_REGFILE_N_EVT) + 2) >= 3 ? (hwpe_ctrl_package_REGFILE_N_CORES * hwpe_ctrl_package_REGFILE_N_EVT) + 0 : 4 - ((hwpe_ctrl_package_REGFILE_N_CORES * hwpe_ctrl_package_REGFILE_N_EVT) + 2))];
	panda_fsm i_fsm(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.test_mode_i(test_mode_i),
		.clear_i(clear_o),
		.ctrl_streamer_o(ctrl_streamer_o),
		.flags_streamer_i(flags_streamer_i),
		.ctrl_engine_o(ctrl_engine_o),
		.flags_engine_i(flags_engine_i),
		.ctrl_slave_o(slave_ctrl),
		.flags_slave_i(slave_flags),
		.reg_file_i(reg_file)
	);
endmodule
