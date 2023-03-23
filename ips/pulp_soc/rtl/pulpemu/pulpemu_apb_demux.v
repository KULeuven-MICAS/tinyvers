module pulpemu_apb_demux (
	clk,
	rst_n,
	zynq2pulp_apb_paddr,
	zynq2pulp_apb_penable,
	zynq2pulp_apb_prdata,
	zynq2pulp_apb_pready,
	zynq2pulp_apb_psel,
	zynq2pulp_apb_pslverr,
	zynq2pulp_apb_pwdata,
	zynq2pulp_apb_pwrite,
	zynq2pulp_spi_slave_paddr,
	zynq2pulp_spi_slave_penable,
	zynq2pulp_spi_slave_prdata,
	zynq2pulp_spi_slave_pready,
	zynq2pulp_spi_slave_psel,
	zynq2pulp_spi_slave_pslverr,
	zynq2pulp_spi_slave_pwdata,
	zynq2pulp_spi_slave_pwrite,
	zynq2pulp_uart_paddr,
	zynq2pulp_uart_penable,
	zynq2pulp_uart_prdata,
	zynq2pulp_uart_pready,
	zynq2pulp_uart_psel,
	zynq2pulp_uart_pslverr,
	zynq2pulp_uart_pwdata,
	zynq2pulp_uart_pwrite
);
	input wire clk;
	input wire rst_n;
	input wire [31:0] zynq2pulp_apb_paddr;
	input wire zynq2pulp_apb_penable;
	output wire [31:0] zynq2pulp_apb_prdata;
	output wire zynq2pulp_apb_pready;
	input wire zynq2pulp_apb_psel;
	output wire zynq2pulp_apb_pslverr;
	input wire [31:0] zynq2pulp_apb_pwdata;
	input wire zynq2pulp_apb_pwrite;
	output wire [31:0] zynq2pulp_spi_slave_paddr;
	output wire zynq2pulp_spi_slave_penable;
	input wire [31:0] zynq2pulp_spi_slave_prdata;
	input wire zynq2pulp_spi_slave_pready;
	output wire zynq2pulp_spi_slave_psel;
	input wire zynq2pulp_spi_slave_pslverr;
	output wire [31:0] zynq2pulp_spi_slave_pwdata;
	output wire zynq2pulp_spi_slave_pwrite;
	output wire [31:0] zynq2pulp_uart_paddr;
	output wire zynq2pulp_uart_penable;
	input wire [31:0] zynq2pulp_uart_prdata;
	input wire zynq2pulp_uart_pready;
	output wire zynq2pulp_uart_psel;
	input wire zynq2pulp_uart_pslverr;
	output wire [31:0] zynq2pulp_uart_pwdata;
	output wire zynq2pulp_uart_pwrite;
	reg last_sel;
	always @(posedge clk or negedge rst_n)
		if (rst_n == 1'b0)
			last_sel <= 1'b0;
		else if (zynq2pulp_apb_psel == 1'b1)
			if (zynq2pulp_apb_paddr[15:14] == 2'b00)
				last_sel <= 1'b0;
			else if (zynq2pulp_apb_paddr[15:14] == 2'b01)
				last_sel <= 1'b1;
	assign zynq2pulp_spi_slave_psel = zynq2pulp_apb_psel & (zynq2pulp_apb_paddr[15:14] == 2'b00);
	assign zynq2pulp_uart_psel = zynq2pulp_apb_psel & (zynq2pulp_apb_paddr[15:14] == 2'b01);
	assign zynq2pulp_apb_prdata = (last_sel == 1'b0 ? zynq2pulp_spi_slave_prdata : (last_sel == 1'b1 ? zynq2pulp_uart_prdata : zynq2pulp_spi_slave_prdata));
	assign zynq2pulp_apb_pslverr = (last_sel == 1'b0 ? zynq2pulp_spi_slave_pslverr : (last_sel == 1'b1 ? zynq2pulp_uart_pslverr : zynq2pulp_spi_slave_pslverr));
	assign zynq2pulp_apb_pready = zynq2pulp_spi_slave_pready | zynq2pulp_uart_pready;
	assign zynq2pulp_spi_slave_paddr = zynq2pulp_apb_paddr;
	assign zynq2pulp_spi_slave_penable = zynq2pulp_apb_penable;
	assign zynq2pulp_spi_slave_pwdata = zynq2pulp_apb_pwdata;
	assign zynq2pulp_spi_slave_pwrite = zynq2pulp_apb_pwrite;
	assign zynq2pulp_uart_paddr = zynq2pulp_apb_paddr;
	assign zynq2pulp_uart_penable = zynq2pulp_apb_penable;
	assign zynq2pulp_uart_pwdata = zynq2pulp_apb_pwdata;
	assign zynq2pulp_uart_pwrite = zynq2pulp_apb_pwrite;
endmodule
