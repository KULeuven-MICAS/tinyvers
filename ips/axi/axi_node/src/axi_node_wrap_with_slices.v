module axi_node_wrap_with_slices (
	clk,
	rst_n,
	test_en_i,
	slave,
	master,
	start_addr_i,
	end_addr_i
);
	parameter NB_MASTER = 4;
	parameter NB_SLAVE = 4;
	parameter AXI_ADDR_WIDTH = 32;
	parameter AXI_DATA_WIDTH = 32;
	parameter AXI_ID_WIDTH = 10;
	parameter AXI_USER_WIDTH = 0;
	parameter MASTER_SLICE_DEPTH = 1;
	parameter SLAVE_SLICE_DEPTH = 1;
	input wire clk;
	input wire rst_n;
	input wire test_en_i;
	input AXI_BUS.Slave [NB_SLAVE - 1:0] slave;
	input AXI_BUS.Master [NB_MASTER - 1:0] master;
	input wire [(NB_MASTER * AXI_ADDR_WIDTH) - 1:0] start_addr_i;
	input wire [(NB_MASTER * AXI_ADDR_WIDTH) - 1:0] end_addr_i;
	localparam AXI_ID_OUT = AXI_ID_WIDTH + $clog2(NB_SLAVE);
	AXI_BUS #(
		.AXI_ADDR_WIDTH(AXI_ADDR_WIDTH),
		.AXI_DATA_WIDTH(AXI_DATA_WIDTH),
		.AXI_ID_WIDTH(AXI_ID_WIDTH),
		.AXI_USER_WIDTH(AXI_USER_WIDTH)
	) axi_slave[NB_SLAVE - 1:0]();
	AXI_BUS #(
		.AXI_ADDR_WIDTH(AXI_ADDR_WIDTH),
		.AXI_DATA_WIDTH(AXI_DATA_WIDTH),
		.AXI_ID_WIDTH(AXI_ID_OUT),
		.AXI_USER_WIDTH(AXI_USER_WIDTH)
	) axi_master[NB_MASTER - 1:0]();
	axi_node_intf_wrap #(
		.NB_MASTER(NB_MASTER),
		.NB_SLAVE(NB_SLAVE),
		.AXI_ADDR_WIDTH(AXI_ADDR_WIDTH),
		.AXI_DATA_WIDTH(AXI_DATA_WIDTH),
		.AXI_ID_WIDTH(AXI_ID_WIDTH),
		.AXI_USER_WIDTH(AXI_USER_WIDTH)
	) i_axi_node_intf_wrap(
		.clk(clk),
		.rst_n(rst_n),
		.test_en_i(test_en_i),
		.slave(axi_slave),
		.master(axi_master),
		.start_addr_i(start_addr_i),
		.end_addr_i(end_addr_i)
	);
	genvar i;
	generate
		for (i = 0; i < NB_MASTER; i = i + 1) begin : axi_slice_master_port
			axi_multicut #(
				.ADDR_WIDTH(AXI_ADDR_WIDTH),
				.DATA_WIDTH(AXI_DATA_WIDTH),
				.USER_WIDTH(AXI_USER_WIDTH),
				.ID_WIDTH(AXI_ID_OUT),
				.NUM_CUTS(MASTER_SLICE_DEPTH)
			) i_axi_slice_wrap_master(
				.clk_i(clk),
				.rst_ni(rst_n),
				.in(axi_master[i]),
				.out(master[i])
			);
		end
		for (i = 0; i < NB_SLAVE; i = i + 1) begin : axi_slice_slave_port
			axi_multicut #(
				.ADDR_WIDTH(AXI_ADDR_WIDTH),
				.DATA_WIDTH(AXI_DATA_WIDTH),
				.USER_WIDTH(AXI_USER_WIDTH),
				.ID_WIDTH(AXI_ID_WIDTH),
				.NUM_CUTS(SLAVE_SLICE_DEPTH)
			) i_axi_slice_wrap_slave(
				.clk_i(clk),
				.rst_ni(rst_n),
				.in(slave[i]),
				.out(axi_slave[i])
			);
		end
	endgenerate
endmodule
