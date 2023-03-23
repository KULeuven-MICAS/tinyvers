module l2_ram_multi_bank (
	clk_i,
	rst_ni,
	init_ni,
	test_mode_i,
	mem_slave,
	mem_pri_slave
);
	parameter NB_BANKS = 4;
	parameter NB_BANKS_PRI = 2;
	parameter BANK_SIZE = 29184;
	parameter MEM_ADDR_WIDTH = 14;
	parameter MEM_ADDR_WIDTH_PRI = 13;
	input wire clk_i;
	input wire rst_ni;
	input wire init_ni;
	input wire test_mode_i;
	input UNICAD_MEM_BUS_32.Slave [NB_BANKS - 1:0] mem_slave;
	input UNICAD_MEM_BUS_32.Slave [NB_BANKS_PRI - 1:0] mem_pri_slave;
	localparam BANK_SIZE_PRI1 = 8192;
	localparam BANK_SIZE_PRI0_SRAM = 6144;
	localparam BANK_SIZE_PRI0_SCM = 2048;
	localparam BANK_SIZE_INTL_SRAM = 28672;
	localparam BANK_SIZE_INTL_SCM = 512;
	genvar i;
	genvar j;
	generate
		for (i = 0; i < NB_BANKS; i = i + 1) begin : CUTS
			model_sram_28672x32_scm_512x32 bank_i(
				.CLK(clk_i),
				.RSTN(rst_ni),
				.D(mem_slave[i].wdata),
				.A(mem_slave[i].add[MEM_ADDR_WIDTH - 1:0]),
				.CEN(mem_slave[i].csn),
				.WEN(mem_slave[i].wen),
				.BEN(~mem_slave[i].be),
				.Q(mem_slave[i].rdata)
			);
		end
	endgenerate
	generic_memory #(
		.ADDR_WIDTH(MEM_ADDR_WIDTH_PRI),
		.DATA_WIDTH(32)
	) bank_sram_pri1_i(
		.CLK(clk_i),
		.INITN(1'b1),
		.CEN(mem_pri_slave[1].csn),
		.BEN(~mem_pri_slave[1].be),
		.WEN(mem_pri_slave[1].wen),
		.A(mem_pri_slave[1].add[MEM_ADDR_WIDTH_PRI - 1:0]),
		.D(mem_pri_slave[1].wdata),
		.Q(mem_pri_slave[1].rdata)
	);
	generic_memory #(
		.ADDR_WIDTH(MEM_ADDR_WIDTH_PRI),
		.DATA_WIDTH(32)
	) bank_sram_pri0_i(
		.CLK(clk_i),
		.INITN(1'b1),
		.CEN(mem_pri_slave[0].csn),
		.BEN(~mem_pri_slave[0].be),
		.WEN(mem_pri_slave[0].wen),
		.A(mem_pri_slave[0].add[MEM_ADDR_WIDTH_PRI - 1:0]),
		.D(mem_pri_slave[0].wdata),
		.Q(mem_pri_slave[0].rdata)
	);
endmodule
