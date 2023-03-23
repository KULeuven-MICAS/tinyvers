module udma_uart_top (
	sys_clk_i,
	periph_clk_i,
	rstn_i,
	uart_rx_i,
	uart_tx_o,
	rx_char_event_o,
	err_event_o,
	cfg_data_i,
	cfg_addr_i,
	cfg_valid_i,
	cfg_rwn_i,
	cfg_ready_o,
	cfg_data_o,
	cfg_rx_startaddr_o,
	cfg_rx_size_o,
	cfg_rx_datasize_o,
	cfg_rx_continuous_o,
	cfg_rx_en_o,
	cfg_rx_clr_o,
	cfg_rx_en_i,
	cfg_rx_pending_i,
	cfg_rx_curr_addr_i,
	cfg_rx_bytes_left_i,
	cfg_tx_startaddr_o,
	cfg_tx_size_o,
	cfg_tx_datasize_o,
	cfg_tx_continuous_o,
	cfg_tx_en_o,
	cfg_tx_clr_o,
	cfg_tx_en_i,
	cfg_tx_pending_i,
	cfg_tx_curr_addr_i,
	cfg_tx_bytes_left_i,
	data_tx_req_o,
	data_tx_gnt_i,
	data_tx_datasize_o,
	data_tx_i,
	data_tx_valid_i,
	data_tx_ready_o,
	data_rx_datasize_o,
	data_rx_o,
	data_rx_valid_o,
	data_rx_ready_i
);
	parameter L2_AWIDTH_NOAL = 12;
	parameter TRANS_SIZE = 16;
	input wire sys_clk_i;
	input wire periph_clk_i;
	input wire rstn_i;
	input wire uart_rx_i;
	output wire uart_tx_o;
	output wire rx_char_event_o;
	output wire err_event_o;
	input wire [31:0] cfg_data_i;
	input wire [4:0] cfg_addr_i;
	input wire cfg_valid_i;
	input wire cfg_rwn_i;
	output wire cfg_ready_o;
	output wire [31:0] cfg_data_o;
	output wire [L2_AWIDTH_NOAL - 1:0] cfg_rx_startaddr_o;
	output wire [TRANS_SIZE - 1:0] cfg_rx_size_o;
	output wire [1:0] cfg_rx_datasize_o;
	output wire cfg_rx_continuous_o;
	output wire cfg_rx_en_o;
	output wire cfg_rx_clr_o;
	input wire cfg_rx_en_i;
	input wire cfg_rx_pending_i;
	input wire [L2_AWIDTH_NOAL - 1:0] cfg_rx_curr_addr_i;
	input wire [TRANS_SIZE - 1:0] cfg_rx_bytes_left_i;
	output wire [L2_AWIDTH_NOAL - 1:0] cfg_tx_startaddr_o;
	output wire [TRANS_SIZE - 1:0] cfg_tx_size_o;
	output wire [1:0] cfg_tx_datasize_o;
	output wire cfg_tx_continuous_o;
	output wire cfg_tx_en_o;
	output wire cfg_tx_clr_o;
	input wire cfg_tx_en_i;
	input wire cfg_tx_pending_i;
	input wire [L2_AWIDTH_NOAL - 1:0] cfg_tx_curr_addr_i;
	input wire [TRANS_SIZE - 1:0] cfg_tx_bytes_left_i;
	output wire data_tx_req_o;
	input wire data_tx_gnt_i;
	output wire [1:0] data_tx_datasize_o;
	input wire [31:0] data_tx_i;
	input wire data_tx_valid_i;
	output wire data_tx_ready_o;
	output wire [1:0] data_rx_datasize_o;
	output wire [31:0] data_rx_o;
	output wire data_rx_valid_o;
	input wire data_rx_ready_i;
	wire [1:0] s_uart_status;
	wire s_uart_stop_bits;
	wire s_uart_parity_en;
	wire [15:0] s_uart_div;
	wire [1:0] s_uart_bits;
	wire s_uart_rx_clean_fifo;
	wire s_uart_rx_polling_en;
	wire s_uart_rx_irq_en;
	wire s_uart_err_irq_en;
	wire s_uart_en_rx;
	wire s_uart_en_tx;
	wire s_data_rx_ready_mux;
	wire s_data_rx_ready;
	wire s_data_tx_valid;
	wire s_data_tx_ready;
	wire [7:0] s_data_tx;
	wire s_data_tx_dc_valid;
	wire s_data_tx_dc_ready;
	wire [7:0] s_data_tx_dc;
	wire s_data_rx_dc_valid;
	wire s_data_rx_dc_ready;
	wire [7:0] s_data_rx_dc;
	reg r_uart_stop_bits;
	reg r_uart_parity_en;
	reg [15:0] r_uart_div;
	reg [1:0] r_uart_bits;
	reg [2:0] r_uart_en_rx_sync;
	reg [2:0] r_uart_en_tx_sync;
	wire s_uart_tx_sample;
	wire s_uart_rx_sample;
	reg [3:0] r_status_sync;
	wire s_err_rx_overflow;
	wire s_err_rx_overflow_sync;
	wire s_err_rx_parity;
	wire s_err_rx_parity_sync;
	wire s_rx_char_event;
	wire s_rx_char_event_sync;
	assign cfg_tx_datasize_o = 2'b00;
	assign cfg_rx_datasize_o = 2'b00;
	assign data_tx_datasize_o = 2'b00;
	assign data_rx_datasize_o = 2'b00;
	assign err_event_o = (s_err_rx_overflow_sync | s_err_rx_parity_sync) & s_uart_err_irq_en;
	assign rx_char_event_o = (s_rx_char_event_sync & s_uart_rx_irq_en) & ~s_uart_rx_polling_en;
	udma_uart_reg_if #(
		.L2_AWIDTH_NOAL(L2_AWIDTH_NOAL),
		.TRANS_SIZE(TRANS_SIZE)
	) u_reg_if(
		.clk_i(sys_clk_i),
		.rstn_i(rstn_i),
		.cfg_data_i(cfg_data_i),
		.cfg_addr_i(cfg_addr_i),
		.cfg_valid_i(cfg_valid_i),
		.cfg_rwn_i(cfg_rwn_i),
		.cfg_ready_o(cfg_ready_o),
		.cfg_data_o(cfg_data_o),
		.cfg_rx_startaddr_o(cfg_rx_startaddr_o),
		.cfg_rx_size_o(cfg_rx_size_o),
		.cfg_rx_continuous_o(cfg_rx_continuous_o),
		.cfg_rx_en_o(cfg_rx_en_o),
		.cfg_rx_clr_o(cfg_rx_clr_o),
		.cfg_rx_en_i(cfg_rx_en_i),
		.cfg_rx_pending_i(cfg_rx_pending_i),
		.cfg_rx_curr_addr_i(cfg_rx_curr_addr_i),
		.cfg_rx_bytes_left_i(cfg_rx_bytes_left_i),
		.cfg_tx_startaddr_o(cfg_tx_startaddr_o),
		.cfg_tx_size_o(cfg_tx_size_o),
		.cfg_tx_continuous_o(cfg_tx_continuous_o),
		.cfg_tx_en_o(cfg_tx_en_o),
		.cfg_tx_clr_o(cfg_tx_clr_o),
		.cfg_tx_en_i(cfg_tx_en_i),
		.cfg_tx_pending_i(cfg_tx_pending_i),
		.cfg_tx_curr_addr_i(cfg_tx_curr_addr_i),
		.cfg_tx_bytes_left_i(cfg_tx_bytes_left_i),
		.rx_data_i(data_rx_o[7:0]),
		.rx_valid_i(data_rx_valid_o),
		.rx_ready_o(s_data_rx_ready),
		.status_i(r_status_sync[2+:2]),
		.err_parity_i(s_err_rx_parity_sync),
		.err_overflow_i(s_err_rx_overflow_sync),
		.stop_bits_o(s_uart_stop_bits),
		.parity_en_o(s_uart_parity_en),
		.divider_o(s_uart_div),
		.num_bits_o(s_uart_bits),
		.rx_clean_fifo_o(s_uart_rx_clean_fifo),
		.rx_polling_en_o(s_uart_rx_polling_en),
		.rx_irq_en_o(s_uart_rx_irq_en),
		.err_irq_en_o(s_uart_err_irq_en),
		.en_rx_o(s_uart_en_rx),
		.en_tx_o(s_uart_en_tx)
	);
	io_tx_fifo #(
		.DATA_WIDTH(8),
		.BUFFER_DEPTH(2)
	) u_fifo(
		.clk_i(sys_clk_i),
		.rstn_i(rstn_i),
		.clr_i(1'b0),
		.data_o(s_data_tx),
		.valid_o(s_data_tx_valid),
		.ready_i(s_data_tx_ready),
		.req_o(data_tx_req_o),
		.gnt_i(data_tx_gnt_i),
		.valid_i(data_tx_valid_i),
		.data_i(data_tx_i[7:0]),
		.ready_o(data_tx_ready_o)
	);
	udma_dc_fifo #(
		8,
		4
	) u_dc_fifo_tx(
		.src_clk_i(sys_clk_i),
		.src_rstn_i(rstn_i),
		.src_data_i(s_data_tx),
		.src_valid_i(s_data_tx_valid),
		.src_ready_o(s_data_tx_ready),
		.dst_clk_i(periph_clk_i),
		.dst_rstn_i(rstn_i),
		.dst_data_o(s_data_tx_dc),
		.dst_valid_o(s_data_tx_dc_valid),
		.dst_ready_i(s_data_tx_dc_ready)
	);
	udma_uart_tx u_uart_tx(
		.clk_i(periph_clk_i),
		.rstn_i(rstn_i),
		.tx_o(uart_tx_o),
		.busy_o(s_uart_status[0]),
		.cfg_en_i(r_uart_en_tx_sync[2]),
		.cfg_div_i(r_uart_div),
		.cfg_parity_en_i(r_uart_parity_en),
		.cfg_bits_i(r_uart_bits),
		.cfg_stop_bits_i(r_uart_stop_bits),
		.tx_data_i(s_data_tx_dc),
		.tx_valid_i(s_data_tx_dc_valid),
		.tx_ready_o(s_data_tx_dc_ready)
	);
	udma_dc_fifo #(
		8,
		4
	) u_dc_fifo_rx(
		.src_clk_i(periph_clk_i),
		.src_rstn_i(rstn_i & ~s_uart_rx_clean_fifo),
		.src_data_i(s_data_rx_dc),
		.src_valid_i(s_data_rx_dc_valid),
		.src_ready_o(s_data_rx_dc_ready),
		.dst_clk_i(sys_clk_i),
		.dst_rstn_i(rstn_i & ~s_uart_rx_clean_fifo),
		.dst_data_o(data_rx_o[7:0]),
		.dst_valid_o(data_rx_valid_o),
		.dst_ready_i(s_data_rx_ready_mux)
	);
	assign s_data_rx_ready_mux = (s_uart_rx_irq_en | s_uart_rx_polling_en ? s_data_rx_ready : data_rx_ready_i);
	udma_uart_rx u_uart_rx(
		.clk_i(periph_clk_i),
		.rstn_i(rstn_i),
		.rx_i(uart_rx_i),
		.busy_o(s_uart_status[1]),
		.cfg_en_i(r_uart_en_rx_sync[2]),
		.cfg_div_i(r_uart_div),
		.cfg_parity_en_i(r_uart_parity_en),
		.cfg_bits_i(r_uart_bits),
		.cfg_stop_bits_i(r_uart_stop_bits),
		.err_parity_o(s_err_rx_parity),
		.err_overflow_o(s_err_rx_overflow),
		.char_event_o(s_rx_char_event),
		.rx_data_o(s_data_rx_dc),
		.rx_valid_o(s_data_rx_dc_valid),
		.rx_ready_i(s_data_rx_dc_ready)
	);
	edge_propagator i_ep_err_overflow(
		.clk_tx_i(periph_clk_i),
		.rstn_tx_i(rstn_i),
		.edge_i(s_err_rx_overflow),
		.clk_rx_i(sys_clk_i),
		.rstn_rx_i(rstn_i),
		.edge_o(s_err_rx_overflow_sync)
	);
	edge_propagator i_ep_err_parity(
		.clk_tx_i(periph_clk_i),
		.rstn_tx_i(rstn_i),
		.edge_i(s_err_rx_parity),
		.clk_rx_i(sys_clk_i),
		.rstn_rx_i(rstn_i),
		.edge_o(s_err_rx_parity_sync)
	);
	edge_propagator i_ep_event(
		.clk_tx_i(periph_clk_i),
		.rstn_tx_i(rstn_i),
		.edge_i(s_rx_char_event),
		.clk_rx_i(sys_clk_i),
		.rstn_rx_i(rstn_i),
		.edge_o(s_rx_char_event_sync)
	);
	assign s_uart_tx_sample = r_uart_en_tx_sync[1] & !r_uart_en_tx_sync[2];
	assign s_uart_rx_sample = r_uart_en_rx_sync[1] & !r_uart_en_rx_sync[2];
	always @(posedge sys_clk_i or negedge rstn_i)
		if (~rstn_i)
			r_status_sync <= 0;
		else begin
			r_status_sync[0+:2] <= s_uart_status;
			r_status_sync[2+:2] <= r_status_sync[0+:2];
		end
	always @(posedge periph_clk_i or negedge rstn_i)
		if (~rstn_i) begin
			r_uart_en_tx_sync <= 0;
			r_uart_en_rx_sync <= 0;
			r_uart_div <= 0;
			r_uart_parity_en <= 0;
			r_uart_bits <= 0;
			r_uart_stop_bits <= 0;
		end
		else begin
			r_uart_en_tx_sync <= {r_uart_en_tx_sync[1:0], s_uart_en_tx};
			r_uart_en_rx_sync <= {r_uart_en_rx_sync[1:0], s_uart_en_rx};
			if (s_uart_tx_sample || s_uart_rx_sample) begin
				r_uart_div <= s_uart_div;
				r_uart_parity_en <= s_uart_parity_en;
				r_uart_bits <= s_uart_bits;
				r_uart_stop_bits <= s_uart_stop_bits;
			end
		end
	assign data_rx_o[31:8] = 'h0;
endmodule
