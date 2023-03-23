module apb_node_wrap (
	clk_i,
	rst_ni,
	apb_slave,
	apb_masters,
	start_addr_i,
	end_addr_i
);
	parameter [31:0] NB_MASTER = 8;
	parameter [31:0] APB_DATA_WIDTH = 32;
	parameter [31:0] APB_ADDR_WIDTH = 32;
	input wire clk_i;
	input wire rst_ni;
	input APB_BUS.Slave apb_slave;
	input APB_BUS.Master [NB_MASTER - 1:0] apb_masters;
	input wire [(NB_MASTER * APB_ADDR_WIDTH) - 1:0] start_addr_i;
	input wire [(NB_MASTER * APB_ADDR_WIDTH) - 1:0] end_addr_i;
	wire [NB_MASTER - 1:0] penable;
	wire [NB_MASTER - 1:0] pwrite;
	wire [(NB_MASTER * APB_ADDR_WIDTH) - 1:0] paddr;
	wire [NB_MASTER - 1:0] psel;
	wire [(NB_MASTER * APB_DATA_WIDTH) - 1:0] pwdata;
	wire [(NB_MASTER * APB_DATA_WIDTH) - 1:0] prdata;
	wire [NB_MASTER - 1:0] pready;
	wire [NB_MASTER - 1:0] pslverr;
	genvar i;
	generate
		for (i = 0; i < NB_MASTER; i = i + 1) begin : genblk1
			assign apb_masters[i].penable = penable[i];
			assign apb_masters[i].pwrite = pwrite[i];
			assign apb_masters[i].paddr = paddr[i * APB_ADDR_WIDTH+:APB_ADDR_WIDTH];
			assign apb_masters[i].psel = psel[i];
			assign apb_masters[i].pwdata = pwdata[i * APB_DATA_WIDTH+:APB_DATA_WIDTH];
			assign prdata[i * APB_DATA_WIDTH+:APB_DATA_WIDTH] = apb_masters[i].prdata;
			assign pready[i] = apb_masters[i].pready;
			assign pslverr[i] = apb_masters[i].pslverr;
		end
	endgenerate
	apb_node #(
		.NB_MASTER(NB_MASTER),
		.APB_DATA_WIDTH(APB_DATA_WIDTH),
		.APB_ADDR_WIDTH(APB_ADDR_WIDTH)
	) apb_node_i(
		.penable_i(apb_slave.penable),
		.pwrite_i(apb_slave.pwrite),
		.paddr_i(apb_slave.paddr),
		.psel_i(apb_slave.psel),
		.pwdata_i(apb_slave.pwdata),
		.prdata_o(apb_slave.prdata),
		.pready_o(apb_slave.pready),
		.pslverr_o(apb_slave.pslverr),
		.penable_o(penable),
		.pwrite_o(pwrite),
		.paddr_o(paddr),
		.psel_o(psel),
		.pwdata_o(pwdata),
		.prdata_i(prdata),
		.pready_i(pready),
		.pslverr_i(pslverr),
		.START_ADDR_i(start_addr_i),
		.END_ADDR_i(end_addr_i)
	);
endmodule
