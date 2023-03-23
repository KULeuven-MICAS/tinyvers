module pulpemu_spi_slave (
	clk,
	rst_n,
	mode_fmc_zynqn_i,
	zynq2pulp_apb_paddr,
	zynq2pulp_apb_penable,
	zynq2pulp_apb_prdata,
	zynq2pulp_apb_pready,
	zynq2pulp_apb_psel,
	zynq2pulp_apb_pslverr,
	zynq2pulp_apb_pwdata,
	zynq2pulp_apb_pwrite,
	pulp_spi_clk_o,
	pulp_spi_csn0_o,
	pulp_spi_csn1_o,
	pulp_spi_csn2_o,
	pulp_spi_csn3_o,
	pulp_spi_mode_i,
	pulp_spi_sdo0_i,
	pulp_spi_sdo1_i,
	pulp_spi_sdo2_i,
	pulp_spi_sdo3_i,
	pulp_spi_sdi0_o,
	pulp_spi_sdi1_o,
	pulp_spi_sdi2_o,
	pulp_spi_sdi3_o,
	pads2pulp_spi_clk_i,
	pads2pulp_spi_csn_i,
	pads2pulp_spi_mode_o,
	pads2pulp_spi_sdo0_o,
	pads2pulp_spi_sdo1_o,
	pads2pulp_spi_sdo2_o,
	pads2pulp_spi_sdo3_o,
	pads2pulp_spi_sdi0_i,
	pads2pulp_spi_sdi1_i,
	pads2pulp_spi_sdi2_i,
	pads2pulp_spi_sdi3_i
);
	parameter AXI_ADDR_WIDTH = 32;
	parameter AXI_DATA_WIDTH = 32;
	parameter AXI_USER_WIDTH = 1;
	parameter AXI_ID_WIDTH = 16;
	parameter BUFFER_DEPTH = 8;
	parameter DUMMY_CYCLES = 32;
	input wire clk;
	input wire rst_n;
	input wire mode_fmc_zynqn_i;
	input wire [31:0] zynq2pulp_apb_paddr;
	input wire zynq2pulp_apb_penable;
	output wire [31:0] zynq2pulp_apb_prdata;
	output wire [0:0] zynq2pulp_apb_pready;
	input wire [0:0] zynq2pulp_apb_psel;
	output wire [0:0] zynq2pulp_apb_pslverr;
	input wire [31:0] zynq2pulp_apb_pwdata;
	input wire zynq2pulp_apb_pwrite;
	output wire pulp_spi_clk_o;
	output wire pulp_spi_csn0_o;
	output wire pulp_spi_csn1_o;
	output wire pulp_spi_csn2_o;
	output wire pulp_spi_csn3_o;
	input wire pulp_spi_mode_i;
	input wire pulp_spi_sdo0_i;
	input wire pulp_spi_sdo1_i;
	input wire pulp_spi_sdo2_i;
	input wire pulp_spi_sdo3_i;
	output wire pulp_spi_sdi0_o;
	output wire pulp_spi_sdi1_o;
	output wire pulp_spi_sdi2_o;
	output wire pulp_spi_sdi3_o;
	input wire pads2pulp_spi_clk_i;
	input wire pads2pulp_spi_csn_i;
	output wire pads2pulp_spi_mode_o;
	output wire pads2pulp_spi_sdo0_o;
	output wire pads2pulp_spi_sdo1_o;
	output wire pads2pulp_spi_sdo2_o;
	output wire pads2pulp_spi_sdo3_o;
	input wire pads2pulp_spi_sdi0_i;
	input wire pads2pulp_spi_sdi1_i;
	input wire pads2pulp_spi_sdi2_i;
	input wire pads2pulp_spi_sdi3_i;
	wire zynq_pulp_spi_clk;
	wire zynq_pulp_spi_csn0;
	wire zynq_pulp_spi_csn1;
	wire zynq_pulp_spi_csn2;
	wire zynq_pulp_spi_csn3;
	wire zynq_pulp_spi_sdo0;
	wire zynq_pulp_spi_sdo1;
	wire zynq_pulp_spi_sdo2;
	wire zynq_pulp_spi_sdo3;
	wire zynq_pulp_spi_sdi0;
	wire zynq_pulp_spi_sdi1;
	wire zynq_pulp_spi_sdi2;
	wire zynq_pulp_spi_sdi3;
	apb_spi_master #(
		.BUFFER_DEPTH(64),
		.APB_ADDR_WIDTH(12)
	) apb_spi_master_i(
		.HCLK(clk),
		.HRESETn(rst_n),
		.PADDR(zynq2pulp_apb_paddr[11:0]),
		.PENABLE(zynq2pulp_apb_penable),
		.PRDATA(zynq2pulp_apb_prdata),
		.PREADY(zynq2pulp_apb_pready),
		.PSEL(zynq2pulp_apb_psel),
		.PSLVERR(zynq2pulp_apb_pslverr),
		.PWDATA(zynq2pulp_apb_pwdata),
		.PWRITE(zynq2pulp_apb_pwrite),
		.events_o(),
		.spi_clk(zynq_pulp_spi_clk),
		.spi_csn0(zynq_pulp_spi_csn0),
		.spi_csn1(zynq_pulp_spi_csn1),
		.spi_csn2(zynq_pulp_spi_csn2),
		.spi_csn3(zynq_pulp_spi_csn3),
		.spi_mode(),
		.spi_sdo0(zynq_pulp_spi_sdo0),
		.spi_sdo1(zynq_pulp_spi_sdo1),
		.spi_sdo2(zynq_pulp_spi_sdo2),
		.spi_sdo3(zynq_pulp_spi_sdo3),
		.spi_sdi0(zynq_pulp_spi_sdi0),
		.spi_sdi1(zynq_pulp_spi_sdi1),
		.spi_sdi2(zynq_pulp_spi_sdi2),
		.spi_sdi3(zynq_pulp_spi_sdi3)
	);
	assign pulp_spi_clk_o = (mode_fmc_zynqn_i == 1'b0 ? zynq_pulp_spi_clk : pads2pulp_spi_clk_i);
	assign pulp_spi_csn0_o = (mode_fmc_zynqn_i == 1'b0 ? zynq_pulp_spi_csn0 : pads2pulp_spi_csn_i);
	assign pulp_spi_csn1_o = (mode_fmc_zynqn_i == 1'b0 ? zynq_pulp_spi_csn1 : 1'b1);
	assign pulp_spi_csn2_o = (mode_fmc_zynqn_i == 1'b0 ? zynq_pulp_spi_csn2 : 1'b1);
	assign pulp_spi_csn3_o = (mode_fmc_zynqn_i == 1'b0 ? zynq_pulp_spi_csn3 : 1'b1);
	assign pulp_spi_sdi0_o = (mode_fmc_zynqn_i == 1'b0 ? zynq_pulp_spi_sdo0 : pads2pulp_spi_sdi0_i);
	assign pulp_spi_sdi1_o = (mode_fmc_zynqn_i == 1'b0 ? zynq_pulp_spi_sdo1 : pads2pulp_spi_sdi1_i);
	assign pulp_spi_sdi2_o = (mode_fmc_zynqn_i == 1'b0 ? zynq_pulp_spi_sdo2 : pads2pulp_spi_sdi2_i);
	assign pulp_spi_sdi3_o = (mode_fmc_zynqn_i == 1'b0 ? zynq_pulp_spi_sdo3 : pads2pulp_spi_sdi3_i);
	assign zynq_pulp_spi_sdi0 = (mode_fmc_zynqn_i == 1'b0 ? pulp_spi_sdo0_i : 1'b0);
	assign zynq_pulp_spi_sdi1 = (mode_fmc_zynqn_i == 1'b0 ? pulp_spi_sdo1_i : 1'b0);
	assign zynq_pulp_spi_sdi2 = (mode_fmc_zynqn_i == 1'b0 ? pulp_spi_sdo2_i : 1'b0);
	assign zynq_pulp_spi_sdi3 = (mode_fmc_zynqn_i == 1'b0 ? pulp_spi_sdo3_i : 1'b0);
	assign pads2pulp_spi_mode_o = (mode_fmc_zynqn_i == 1'b0 ? 'h0 : pulp_spi_mode_i);
	assign pads2pulp_spi_sdo0_o = (mode_fmc_zynqn_i == 1'b0 ? 1'b0 : pulp_spi_sdo0_i);
	assign pads2pulp_spi_sdo1_o = (mode_fmc_zynqn_i == 1'b0 ? 1'b0 : pulp_spi_sdo1_i);
	assign pads2pulp_spi_sdo2_o = (mode_fmc_zynqn_i == 1'b0 ? 1'b0 : pulp_spi_sdo2_i);
	assign pads2pulp_spi_sdo3_o = (mode_fmc_zynqn_i == 1'b0 ? 1'b0 : pulp_spi_sdo3_i);
endmodule
