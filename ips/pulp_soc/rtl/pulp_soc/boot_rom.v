module boot_rom (
	clk_i,
	rst_ni,
	init_ni,
	scan_en_in,
	mem_slave,
	test_mode_i
);
	parameter ROM_ADDR_WIDTH = 13;
	input wire clk_i;
	input wire rst_ni;
	input wire init_ni;
	input wire scan_en_in;
	input UNICAD_MEM_BUS_32.Slave mem_slave;
	input wire test_mode_i;
	wire clk_gated;
	generic_rom #(
		.ADDR_WIDTH(ROM_ADDR_WIDTH - 2),
		.DATA_WIDTH(32)
	) rom_mem_i(
		.CLK(clk_gated),
		.CEN(mem_slave.csn),
		.A(mem_slave.add[ROM_ADDR_WIDTH - 1:2]),
		.Q(mem_slave.rdata)
	);
	pulp_clock_gating i_clk_gate_rom(
		.clk_i(clk_i),
		.en_i(~scan_en_in),
		.test_en_i(1'b0),
		.clk_o(clk_gated)
	);
endmodule
