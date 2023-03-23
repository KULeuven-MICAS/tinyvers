module axi_cdc (
	clk_slave_i,
	rst_slave_ni,
	axi_slave,
	isolate_slave_i,
	test_cgbypass_i,
	clk_master_i,
	rst_master_ni,
	axi_master,
	isolate_master_i,
	clock_down_master_i,
	incoming_req_master_o
);
	parameter [31:0] AXI_ADDR_WIDTH = 32;
	parameter [31:0] AXI_DATA_WIDTH = 64;
	parameter [31:0] AXI_USER_WIDTH = 6;
	parameter [31:0] AXI_ID_WIDTH = 6;
	parameter [31:0] AXI_BUFFER_WIDTH = 8;
	input wire clk_slave_i;
	input wire rst_slave_ni;
	input AXI_BUS.Slave axi_slave;
	input wire isolate_slave_i;
	input wire test_cgbypass_i;
	input wire clk_master_i;
	input wire rst_master_ni;
	input AXI_BUS.Master axi_master;
	input wire isolate_master_i;
	input wire clock_down_master_i;
	output wire incoming_req_master_o;
	AXI_BUS_ASYNC #(
		.AXI_ADDR_WIDTH(AXI_ADDR_WIDTH),
		.AXI_DATA_WIDTH(AXI_DATA_WIDTH),
		.AXI_ID_WIDTH(AXI_ID_WIDTH),
		.AXI_USER_WIDTH(AXI_USER_WIDTH),
		.BUFFER_WIDTH(AXI_BUFFER_WIDTH)
	) axi_async();
	axi_slice_dc_slave_wrap #(
		.AXI_ADDR_WIDTH(AXI_ADDR_WIDTH),
		.AXI_DATA_WIDTH(AXI_DATA_WIDTH),
		.AXI_USER_WIDTH(AXI_USER_WIDTH),
		.AXI_ID_WIDTH(AXI_ID_WIDTH),
		.BUFFER_WIDTH(AXI_BUFFER_WIDTH)
	) i_axi_slave(
		.clk_i(clk_slave_i),
		.rst_ni(rst_slave_ni),
		.test_cgbypass_i(test_cgbypass_i),
		.isolate_i(isolate_slave_i),
		.axi_slave(axi_slave),
		.axi_master_async(axi_async)
	);
	axi_slice_dc_master_wrap #(
		.AXI_ADDR_WIDTH(AXI_ADDR_WIDTH),
		.AXI_DATA_WIDTH(AXI_DATA_WIDTH),
		.AXI_USER_WIDTH(AXI_USER_WIDTH),
		.AXI_ID_WIDTH(AXI_ID_WIDTH),
		.BUFFER_WIDTH(AXI_BUFFER_WIDTH)
	) i_axi_master(
		.clk_i(clk_master_i),
		.rst_ni(rst_master_ni),
		.test_cgbypass_i(test_cgbypass_i),
		.isolate_i(isolate_master_i),
		.clock_down_i(clock_down_master_i),
		.incoming_req_o(incoming_req_master_o),
		.axi_slave_async(axi_async),
		.axi_master(axi_master)
	);
endmodule
