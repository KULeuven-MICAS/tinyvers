module udma_uart_reg_if (
	clk_i,
	rstn_i,
	cfg_data_i,
	cfg_addr_i,
	cfg_valid_i,
	cfg_rwn_i,
	cfg_data_o,
	cfg_ready_o,
	cfg_rx_startaddr_o,
	cfg_rx_size_o,
	cfg_rx_continuous_o,
	cfg_rx_en_o,
	cfg_rx_clr_o,
	cfg_rx_en_i,
	cfg_rx_pending_i,
	cfg_rx_curr_addr_i,
	cfg_rx_bytes_left_i,
	cfg_tx_startaddr_o,
	cfg_tx_size_o,
	cfg_tx_continuous_o,
	cfg_tx_en_o,
	cfg_tx_clr_o,
	cfg_tx_en_i,
	cfg_tx_pending_i,
	cfg_tx_curr_addr_i,
	cfg_tx_bytes_left_i,
	status_i,
	err_parity_i,
	err_overflow_i,
	rx_data_i,
	rx_valid_i,
	rx_ready_o,
	stop_bits_o,
	parity_en_o,
	divider_o,
	num_bits_o,
	rx_clean_fifo_o,
	rx_polling_en_o,
	rx_irq_en_o,
	err_irq_en_o,
	en_rx_o,
	en_tx_o
);
	parameter L2_AWIDTH_NOAL = 12;
	parameter TRANS_SIZE = 16;
	input wire clk_i;
	input wire rstn_i;
	input wire [31:0] cfg_data_i;
	input wire [4:0] cfg_addr_i;
	input wire cfg_valid_i;
	input wire cfg_rwn_i;
	output reg [31:0] cfg_data_o;
	output wire cfg_ready_o;
	output wire [L2_AWIDTH_NOAL - 1:0] cfg_rx_startaddr_o;
	output wire [TRANS_SIZE - 1:0] cfg_rx_size_o;
	output wire cfg_rx_continuous_o;
	output wire cfg_rx_en_o;
	output wire cfg_rx_clr_o;
	input wire cfg_rx_en_i;
	input wire cfg_rx_pending_i;
	input wire [L2_AWIDTH_NOAL - 1:0] cfg_rx_curr_addr_i;
	input wire [TRANS_SIZE - 1:0] cfg_rx_bytes_left_i;
	output wire [L2_AWIDTH_NOAL - 1:0] cfg_tx_startaddr_o;
	output wire [TRANS_SIZE - 1:0] cfg_tx_size_o;
	output wire cfg_tx_continuous_o;
	output wire cfg_tx_en_o;
	output wire cfg_tx_clr_o;
	input wire cfg_tx_en_i;
	input wire cfg_tx_pending_i;
	input wire [L2_AWIDTH_NOAL - 1:0] cfg_tx_curr_addr_i;
	input wire [TRANS_SIZE - 1:0] cfg_tx_bytes_left_i;
	input wire [1:0] status_i;
	input wire err_parity_i;
	input wire err_overflow_i;
	input wire [7:0] rx_data_i;
	input wire rx_valid_i;
	output wire rx_ready_o;
	output wire stop_bits_o;
	output wire parity_en_o;
	output wire [15:0] divider_o;
	output wire [1:0] num_bits_o;
	output wire rx_clean_fifo_o;
	output wire rx_polling_en_o;
	output wire rx_irq_en_o;
	output wire err_irq_en_o;
	output wire en_rx_o;
	output wire en_tx_o;
	reg [L2_AWIDTH_NOAL - 1:0] r_rx_startaddr;
	reg [TRANS_SIZE - 1:0] r_rx_size;
	reg r_rx_continuous;
	reg r_rx_en;
	reg r_rx_clr;
	reg [L2_AWIDTH_NOAL - 1:0] r_tx_startaddr;
	reg [TRANS_SIZE - 1:0] r_tx_size;
	reg r_tx_continuous;
	reg r_tx_en;
	reg r_tx_clr;
	reg r_uart_en_tx;
	reg r_uart_en_rx;
	reg [15:0] r_uart_div;
	reg r_uart_stop_bits;
	reg [1:0] r_uart_bits;
	reg r_uart_parity_en;
	wire [4:0] s_wr_addr;
	wire [4:0] s_rd_addr;
	reg s_err_clr;
	reg s_rx_valid_clr;
	reg r_err_parity;
	reg r_err_overflow;
	reg r_uart_rx_clean_fifo;
	reg r_uart_rx_polling_en;
	reg r_uart_err_irq_en;
	reg r_uart_rx_irq_en;
	reg [7:0] r_uart_rx_data;
	reg r_uart_rx_data_valid;
	assign rx_ready_o = s_rx_valid_clr;
	assign s_wr_addr = (cfg_valid_i & ~cfg_rwn_i ? cfg_addr_i : 5'h00);
	assign s_rd_addr = (cfg_valid_i & cfg_rwn_i ? cfg_addr_i : 5'h00);
	assign cfg_rx_startaddr_o = r_rx_startaddr;
	assign cfg_rx_size_o = r_rx_size;
	assign cfg_rx_continuous_o = r_rx_continuous;
	assign cfg_rx_en_o = r_rx_en;
	assign cfg_rx_clr_o = r_rx_clr;
	assign cfg_tx_startaddr_o = r_tx_startaddr;
	assign cfg_tx_size_o = r_tx_size;
	assign cfg_tx_continuous_o = r_tx_continuous;
	assign cfg_tx_en_o = r_tx_en;
	assign cfg_tx_clr_o = r_tx_clr;
	assign en_tx_o = r_uart_en_tx;
	assign en_rx_o = r_uart_en_rx;
	assign divider_o = r_uart_div;
	assign num_bits_o = r_uart_bits;
	assign parity_en_o = r_uart_parity_en;
	assign stop_bits_o = r_uart_stop_bits;
	assign rx_clean_fifo_o = r_uart_rx_clean_fifo;
	assign rx_polling_en_o = r_uart_rx_polling_en;
	assign rx_irq_en_o = r_uart_rx_irq_en;
	assign err_irq_en_o = r_uart_err_irq_en;
	always @(posedge clk_i or negedge rstn_i)
		if (~rstn_i) begin
			r_rx_startaddr <= 'h0;
			r_rx_size <= 'h0;
			r_rx_continuous <= 'h0;
			r_rx_en = 'h0;
			r_rx_clr = 'h0;
			r_tx_startaddr <= 'h0;
			r_tx_size <= 'h0;
			r_tx_continuous <= 'h0;
			r_tx_en = 'h0;
			r_tx_clr = 'h0;
			r_uart_div <= 'h0;
			r_uart_stop_bits <= 'h0;
			r_uart_bits <= 'h0;
			r_uart_parity_en <= 'h0;
			r_uart_en_tx <= 'h0;
			r_uart_en_rx <= 'h0;
			r_err_parity <= 'h0;
			r_err_overflow <= 'h0;
			r_uart_rx_clean_fifo <= 'h0;
			r_uart_rx_polling_en <= 'h0;
			r_uart_rx_irq_en <= 'h0;
			r_uart_err_irq_en <= 'h0;
			r_uart_rx_data <= 'h0;
			r_uart_rx_data_valid <= 'h0;
		end
		else begin
			r_rx_en = 'h0;
			r_rx_clr = 'h0;
			r_tx_en = 'h0;
			r_tx_clr = 'h0;
			if (err_overflow_i)
				r_err_overflow <= 1'b1;
			else if (s_err_clr)
				r_err_overflow <= 1'b0;
			if (err_parity_i)
				r_err_parity <= 1'b1;
			else if (s_err_clr)
				r_err_parity <= 1'b0;
			if (r_uart_rx_polling_en | r_uart_rx_irq_en) begin
				if (rx_valid_i & ~s_rx_valid_clr) begin
					r_uart_rx_data <= rx_data_i;
					r_uart_rx_data_valid <= rx_valid_i;
				end
				else if (s_rx_valid_clr) begin
					r_uart_rx_data <= r_uart_rx_data;
					r_uart_rx_data_valid <= 1'b0;
				end
				else begin
					r_uart_rx_data <= r_uart_rx_data;
					r_uart_rx_data_valid <= r_uart_rx_data_valid;
				end
			end
			else begin
				r_uart_rx_data <= r_uart_rx_data;
				r_uart_rx_data_valid <= 1'b0;
			end
			if (cfg_valid_i & ~cfg_rwn_i)
				case (s_wr_addr)
					5'b00000: r_rx_startaddr <= cfg_data_i[L2_AWIDTH_NOAL - 1:0];
					5'b00001: r_rx_size <= cfg_data_i[TRANS_SIZE - 1:0];
					5'b00010: begin
						r_rx_clr = cfg_data_i[6];
						r_rx_en = cfg_data_i[4];
						r_rx_continuous <= cfg_data_i[0];
					end
					5'b00100: r_tx_startaddr <= cfg_data_i[L2_AWIDTH_NOAL - 1:0];
					5'b00101: r_tx_size <= cfg_data_i[TRANS_SIZE - 1:0];
					5'b00110: begin
						r_tx_clr = cfg_data_i[6];
						r_tx_en = cfg_data_i[4];
						r_tx_continuous <= cfg_data_i[0];
					end
					5'b01001: begin
						r_uart_div <= cfg_data_i[31:16];
						r_uart_en_rx <= cfg_data_i[9];
						r_uart_en_tx <= cfg_data_i[8];
						r_uart_rx_clean_fifo <= cfg_data_i[5];
						r_uart_rx_polling_en <= cfg_data_i[4];
						r_uart_stop_bits <= cfg_data_i[3];
						r_uart_bits <= cfg_data_i[2:1];
						r_uart_parity_en <= cfg_data_i[0];
					end
					5'b01011: begin
						r_uart_err_irq_en <= cfg_data_i[1];
						r_uart_rx_irq_en <= cfg_data_i[0];
					end
				endcase
		end
	always @(*) begin
		cfg_data_o = 32'h00000000;
		s_err_clr = 1'b0;
		s_rx_valid_clr = 1'b0;
		case (s_rd_addr)
			5'b00000: cfg_data_o = cfg_rx_curr_addr_i;
			5'b00001: cfg_data_o[TRANS_SIZE - 1:0] = cfg_rx_bytes_left_i;
			5'b00010: cfg_data_o = {26'h0000000, cfg_rx_pending_i, cfg_rx_en_i, 3'h0, r_rx_continuous};
			5'b00100: cfg_data_o = cfg_tx_curr_addr_i;
			5'b00101: cfg_data_o[TRANS_SIZE - 1:0] = cfg_tx_bytes_left_i;
			5'b00110: cfg_data_o = {26'h0000000, cfg_tx_pending_i, cfg_tx_en_i, 3'h0, r_tx_continuous};
			5'b01001: cfg_data_o = {r_uart_div, 6'h00, r_uart_en_rx, r_uart_en_tx, 2'h0, r_uart_rx_clean_fifo, r_uart_rx_polling_en, r_uart_stop_bits, r_uart_bits, r_uart_parity_en};
			5'b01000: cfg_data_o = {30'h00000000, status_i};
			5'b01010: begin
				cfg_data_o = {30'h00000000, r_err_parity, r_err_overflow};
				s_err_clr = 1'b1;
			end
			5'b01011: cfg_data_o = {30'h00000000, r_uart_err_irq_en, r_uart_rx_irq_en};
			5'b01100: cfg_data_o = {31'h00000000, r_uart_rx_data_valid};
			5'b01101: begin
				cfg_data_o = {24'h000000, r_uart_rx_data};
				s_rx_valid_clr = 1'b1;
			end
			default: cfg_data_o = 'h0;
		endcase
	end
	assign cfg_ready_o = 1'b1;
endmodule
