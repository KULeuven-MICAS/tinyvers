module pulpemu_uart (
	mode_fmc_zynqn_i,
	clk,
	rst_n,
	apb_paddr,
	apb_penable,
	apb_prdata,
	apb_pready,
	apb_psel,
	apb_pslverr,
	apb_pwdata,
	apb_pwrite,
	uart_int_o,
	uart_rx_o,
	uart_tx_i,
	pads2pulp_uart_rx_i,
	pads2pulp_uart_tx_o
);
	parameter AXI_ADDR_WIDTH = 32;
	parameter AXI_DATA_WIDTH = 32;
	parameter AXI_USER_WIDTH = 1;
	parameter AXI_ID_WIDTH = 16;
	parameter BUFFER_DEPTH = 8;
	parameter DUMMY_CYCLES = 32;
	input wire mode_fmc_zynqn_i;
	input wire clk;
	input wire rst_n;
	input wire [31:0] apb_paddr;
	input wire apb_penable;
	output reg [31:0] apb_prdata;
	output wire [0:0] apb_pready;
	input wire [0:0] apb_psel;
	output wire [0:0] apb_pslverr;
	input wire [31:0] apb_pwdata;
	input wire apb_pwrite;
	output wire uart_int_o;
	output wire uart_rx_o;
	input wire uart_tx_i;
	input wire pads2pulp_uart_rx_i;
	output wire pads2pulp_uart_tx_o;
	wire [15:0] cfg_div;
	wire cfg_en;
	wire cfg_parity_en;
	wire [1:0] cfg_bits;
	wire cfg_stop_bits;
	wire busy;
	wire err;
	reg err_clr;
	wire [7:0] rx_data;
	wire rx_valid;
	wire rx_ready;
	wire [7:0] apb_data;
	wire apb_valid;
	wire apb_ready;
	reg [31:0] apb_config;
	wire [31:0] apb_status;
	wire zynq_pulp_uart_rx;
	wire zynq_pulp_uart_tx;
	udma_uart_rx uart_receiver_i(
		.clk_i(clk),
		.rstn_i(rst_n),
		.rx_i(zynq_pulp_uart_rx),
		.cfg_div_i(cfg_div),
		.cfg_en_i(cfg_en),
		.cfg_parity_en_i(cfg_parity_en),
		.cfg_bits_i(cfg_bits),
		.cfg_stop_bits_i(cfg_stop_bits),
		.busy_o(busy),
		.err_o(err),
		.err_clr_i(err_clr),
		.rx_data_o(rx_data),
		.rx_valid_o(rx_valid),
		.rx_ready_i(rx_ready)
	);
	generic_fifo #(
		.DATA_WIDTH(8),
		.DATA_DEPTH(1024)
	) uart_fifo_i(
		.clk(clk),
		.rst_n(rst_n),
		.data_i(rx_data),
		.valid_i(rx_valid),
		.grant_o(rx_ready),
		.data_o(apb_data),
		.valid_o(apb_valid),
		.grant_i(apb_ready),
		.test_mode_i(1'b0)
	);
	assign apb_pslverr = 1'sb0;
	assign apb_pready = 1'b1;
	assign apb_ready = (apb_penable & apb_psel) & (apb_paddr[4:0] == 5'h00 ? 1'b1 : 1'b0);
	always @(posedge clk or negedge rst_n)
		if (rst_n == 1'b0) begin
			apb_prdata <= 1'sb0;
			apb_config <= 1'sb0;
			err_clr <= 1'b0;
		end
		else if ((apb_psel & apb_pwrite) && (apb_paddr[4:0] == 5'h04)) begin
			apb_prdata <= apb_pwdata;
			apb_config <= apb_pwdata;
			err_clr <= 1'b0;
		end
		else if ((apb_psel & apb_pwrite) && (apb_paddr[4:0] == 5'h0c))
			err_clr <= 1'b1;
		else if (apb_psel && (apb_paddr[4:0] == 5'h00)) begin
			apb_prdata <= (apb_valid ? {24'h000000, apb_data} : {32 {1'sb0}});
			err_clr <= 1'b0;
		end
		else if (apb_psel && (apb_paddr[4:0] == 5'h04)) begin
			apb_prdata <= apb_config;
			err_clr <= 1'b0;
		end
		else if (apb_psel && (apb_paddr[4:0] == 5'h08)) begin
			apb_prdata <= apb_status;
			err_clr <= 1'b0;
		end
		else if (apb_psel && (apb_paddr[4:0] == 5'h10)) begin
			apb_prdata <= {31'h00000000, apb_valid};
			err_clr <= 1'b0;
		end
		else begin
			apb_prdata <= 1'sb0;
			err_clr <= 1'b0;
		end
	assign cfg_div = apb_config[31:16];
	assign cfg_en = apb_config[15];
	assign cfg_parity_en = apb_config[14];
	assign cfg_bits = apb_config[13:12];
	assign cfg_stop_bits = apb_config[11];
	assign apb_status = {29'h00000000, ~apb_valid, err, busy};
	assign pads2pulp_uart_tx_o = (mode_fmc_zynqn_i ? uart_tx_i : 1'b0);
	assign zynq_pulp_uart_rx = (mode_fmc_zynqn_i ? 1'b0 : pads2pulp_uart_rx_i);
	assign uart_rx_o = (mode_fmc_zynqn_i ? pads2pulp_uart_rx_i : 1'b0);
endmodule
