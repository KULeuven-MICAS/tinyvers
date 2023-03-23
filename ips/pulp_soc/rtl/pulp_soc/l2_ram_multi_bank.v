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
				.scan_en_in(test_mode_i),
				.D(mem_slave[i].wdata),
				.A(mem_slave[i].add[MEM_ADDR_WIDTH - 1:0]),
				.CEN(mem_slave[i].csn),
				.WEN(mem_slave[i].wen),
				.BEN(~mem_slave[i].be),
				.Q(mem_slave[i].rdata)
			);
		end
	endgenerate
	wire [31:0] mask_pri1;
	wire [31:0] mask_pri0;
	assign mask_pri1[31] = ~mem_pri_slave[1].be[3];
	assign mask_pri1[30] = ~mem_pri_slave[1].be[3];
	assign mask_pri1[29] = ~mem_pri_slave[1].be[3];
	assign mask_pri1[28] = ~mem_pri_slave[1].be[3];
	assign mask_pri1[27] = ~mem_pri_slave[1].be[3];
	assign mask_pri1[26] = ~mem_pri_slave[1].be[3];
	assign mask_pri1[25] = ~mem_pri_slave[1].be[3];
	assign mask_pri1[24] = ~mem_pri_slave[1].be[3];
	assign mask_pri1[23] = ~mem_pri_slave[1].be[2];
	assign mask_pri1[22] = ~mem_pri_slave[1].be[2];
	assign mask_pri1[21] = ~mem_pri_slave[1].be[2];
	assign mask_pri1[20] = ~mem_pri_slave[1].be[2];
	assign mask_pri1[19] = ~mem_pri_slave[1].be[2];
	assign mask_pri1[18] = ~mem_pri_slave[1].be[2];
	assign mask_pri1[17] = ~mem_pri_slave[1].be[2];
	assign mask_pri1[16] = ~mem_pri_slave[1].be[2];
	assign mask_pri1[15] = ~mem_pri_slave[1].be[1];
	assign mask_pri1[14] = ~mem_pri_slave[1].be[1];
	assign mask_pri1[13] = ~mem_pri_slave[1].be[1];
	assign mask_pri1[12] = ~mem_pri_slave[1].be[1];
	assign mask_pri1[11] = ~mem_pri_slave[1].be[1];
	assign mask_pri1[10] = ~mem_pri_slave[1].be[1];
	assign mask_pri1[9] = ~mem_pri_slave[1].be[1];
	assign mask_pri1[8] = ~mem_pri_slave[1].be[1];
	assign mask_pri1[7] = ~mem_pri_slave[1].be[0];
	assign mask_pri1[6] = ~mem_pri_slave[1].be[0];
	assign mask_pri1[5] = ~mem_pri_slave[1].be[0];
	assign mask_pri1[4] = ~mem_pri_slave[1].be[0];
	assign mask_pri1[3] = ~mem_pri_slave[1].be[0];
	assign mask_pri1[2] = ~mem_pri_slave[1].be[0];
	assign mask_pri1[1] = ~mem_pri_slave[1].be[0];
	assign mask_pri1[0] = ~mem_pri_slave[1].be[0];
	assign mask_pri0[31] = ~mem_pri_slave[0].be[3];
	assign mask_pri0[30] = ~mem_pri_slave[0].be[3];
	assign mask_pri0[29] = ~mem_pri_slave[0].be[3];
	assign mask_pri0[28] = ~mem_pri_slave[0].be[3];
	assign mask_pri0[27] = ~mem_pri_slave[0].be[3];
	assign mask_pri0[26] = ~mem_pri_slave[0].be[3];
	assign mask_pri0[25] = ~mem_pri_slave[0].be[3];
	assign mask_pri0[24] = ~mem_pri_slave[0].be[3];
	assign mask_pri0[23] = ~mem_pri_slave[0].be[2];
	assign mask_pri0[22] = ~mem_pri_slave[0].be[2];
	assign mask_pri0[21] = ~mem_pri_slave[0].be[2];
	assign mask_pri0[20] = ~mem_pri_slave[0].be[2];
	assign mask_pri0[19] = ~mem_pri_slave[0].be[2];
	assign mask_pri0[18] = ~mem_pri_slave[0].be[2];
	assign mask_pri0[17] = ~mem_pri_slave[0].be[2];
	assign mask_pri0[16] = ~mem_pri_slave[0].be[2];
	assign mask_pri0[15] = ~mem_pri_slave[0].be[1];
	assign mask_pri0[14] = ~mem_pri_slave[0].be[1];
	assign mask_pri0[13] = ~mem_pri_slave[0].be[1];
	assign mask_pri0[12] = ~mem_pri_slave[0].be[1];
	assign mask_pri0[11] = ~mem_pri_slave[0].be[1];
	assign mask_pri0[10] = ~mem_pri_slave[0].be[1];
	assign mask_pri0[9] = ~mem_pri_slave[0].be[1];
	assign mask_pri0[8] = ~mem_pri_slave[0].be[1];
	assign mask_pri0[7] = ~mem_pri_slave[0].be[0];
	assign mask_pri0[6] = ~mem_pri_slave[0].be[0];
	assign mask_pri0[5] = ~mem_pri_slave[0].be[0];
	assign mask_pri0[4] = ~mem_pri_slave[0].be[0];
	assign mask_pri0[3] = ~mem_pri_slave[0].be[0];
	assign mask_pri0[2] = ~mem_pri_slave[0].be[0];
	assign mask_pri0[1] = ~mem_pri_slave[0].be[0];
	assign mask_pri0[0] = ~mem_pri_slave[0].be[0];
	model_8192x32_memory bank_sram_pri1_i(
		.CLK(clk_i),
		.RSTN(rst_ni),
		.scan_en_in(test_mode_i),
		.INITN(1'b1),
		.D(mem_pri_slave[1].wdata),
		.A(mem_pri_slave[1].add[MEM_ADDR_WIDTH_PRI - 1:0]),
		.CSN(mem_pri_slave[1].csn),
		.WEN(mem_pri_slave[1].wen),
		.M(mask_pri1),
		.Q(mem_pri_slave[1].rdata)
	);
	model_8192x32_memory bank_sram_pri0_i(
		.CLK(clk_i),
		.RSTN(rst_ni),
		.scan_en_in(test_mode_i),
		.INITN(1'b1),
		.D(mem_pri_slave[0].wdata),
		.A(mem_pri_slave[0].add[MEM_ADDR_WIDTH_PRI - 1:0]),
		.CSN(mem_pri_slave[0].csn),
		.WEN(mem_pri_slave[0].wen),
		.M(mask_pri0),
		.Q(mem_pri_slave[0].rdata)
	);
endmodule
