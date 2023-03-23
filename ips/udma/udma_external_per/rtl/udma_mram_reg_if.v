module udma_mram_reg_if (
	clk_i,
	rstn_i,
	cfg_data_i,
	cfg_addr_i,
	cfg_valid_i,
	cfg_rwn_i,
	cfg_data_o,
	cfg_ready_o,
	cfg_rx_startaddr_o,
	cfg_rx_dest_addr_o,
	cfg_rx_size_o,
	cfg_rx_continuous_o,
	cfg_rx_en_o,
	cfg_rx_clr_o,
	cfg_rx_en_i,
	cfg_rx_pending_i,
	cfg_rx_curr_addr_i,
	cfg_rx_bytes_left_i,
	cfg_rx_busy_i,
	cfg_tx_startaddr_o,
	cfg_tx_dest_addr_o,
	cfg_tx_size_o,
	cfg_tx_continuous_o,
	cfg_tx_en_o,
	cfg_tx_clr_o,
	cfg_tx_en_i,
	cfg_tx_pending_i,
	cfg_tx_curr_addr_i,
	cfg_tx_bytes_left_i,
	cfg_tx_busy_i,
	mram_mode_o,
	mram_erase_addr_o,
	mram_erase_size_o,
	mram_erase_pending_i,
	mram_ref_line_pending_i,
	mram_event_done_i,
	mram_rx_ecc_error_i,
	cfg_clkdiv_data_o,
	cfg_clkdiv_valid_o,
	cfg_clkdiv_ack_i,
	mram_push_tx_req_o,
	mram_push_tx_ack_i,
	mram_irq_enable_o,
	mram_push_rx_req_o,
	mram_push_rx_ack_i
);
	parameter L2_AWIDTH_NOAL = 12;
	parameter TRANS_SIZE = 16;
	parameter MRAM_ADDR_WIDTH = 20;
	input wire clk_i;
	input wire rstn_i;
	input wire [31:0] cfg_data_i;
	input wire [4:0] cfg_addr_i;
	input wire cfg_valid_i;
	input wire cfg_rwn_i;
	output reg [31:0] cfg_data_o;
	output reg cfg_ready_o;
	output wire [L2_AWIDTH_NOAL - 1:0] cfg_rx_startaddr_o;
	output wire [MRAM_ADDR_WIDTH - 1:0] cfg_rx_dest_addr_o;
	output wire [TRANS_SIZE - 1:0] cfg_rx_size_o;
	output wire cfg_rx_continuous_o;
	output wire cfg_rx_en_o;
	output wire cfg_rx_clr_o;
	input wire cfg_rx_en_i;
	input wire cfg_rx_pending_i;
	input wire [L2_AWIDTH_NOAL - 1:0] cfg_rx_curr_addr_i;
	input wire [TRANS_SIZE - 1:0] cfg_rx_bytes_left_i;
	input wire cfg_rx_busy_i;
	output wire [L2_AWIDTH_NOAL - 1:0] cfg_tx_startaddr_o;
	output wire [MRAM_ADDR_WIDTH - 1:0] cfg_tx_dest_addr_o;
	output wire [TRANS_SIZE - 1:0] cfg_tx_size_o;
	output wire cfg_tx_continuous_o;
	output wire cfg_tx_en_o;
	output wire cfg_tx_clr_o;
	input wire cfg_tx_en_i;
	input wire cfg_tx_pending_i;
	input wire [L2_AWIDTH_NOAL - 1:0] cfg_tx_curr_addr_i;
	input wire [TRANS_SIZE - 1:0] cfg_tx_bytes_left_i;
	input wire cfg_tx_busy_i;
	output wire [31:0] mram_mode_o;
	output wire [15:0] mram_erase_addr_o;
	output wire [9:0] mram_erase_size_o;
	input wire mram_erase_pending_i;
	input wire mram_ref_line_pending_i;
	input wire [3:0] mram_event_done_i;
	input wire [1:0] mram_rx_ecc_error_i;
	output wire [7:0] cfg_clkdiv_data_o;
	output wire cfg_clkdiv_valid_o;
	input wire cfg_clkdiv_ack_i;
	output wire mram_push_tx_req_o;
	input wire mram_push_tx_ack_i;
	output wire [3:0] mram_irq_enable_o;
	output wire mram_push_rx_req_o;
	input wire mram_push_rx_ack_i;
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
	wire [4:0] s_wr_addr;
	wire [4:0] s_rd_addr;
	reg [MRAM_ADDR_WIDTH - 1:0] r_cfg_tx_dest_addr;
	reg [MRAM_ADDR_WIDTH - 1:0] r_cfg_rx_dest_addr;
	reg [31:0] r_mram_mode;
	reg [15:0] r_mram_erase_addr;
	reg [9:0] r_mram_erase_size;
	reg [7:0] r_clk_div_data;
	reg r_clk_div_valid;
	reg r_mram_trigger;
	reg [3:0] r_mram_irq_enable;
	reg [3:0] r_mram_irq_clean;
	reg [3:0] r_mram_event_done;
	reg [1:0] r_mram_ecc_error;
	assign cfg_tx_dest_addr_o = r_cfg_tx_dest_addr;
	assign cfg_rx_dest_addr_o = r_cfg_rx_dest_addr;
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
	assign mram_mode_o = r_mram_mode;
	assign mram_erase_addr_o = r_mram_erase_addr;
	assign mram_erase_size_o = r_mram_erase_size;
	assign cfg_clkdiv_data_o = r_clk_div_data;
	genvar i;
	always @(posedge clk_i or negedge rstn_i)
		if (~rstn_i)
			r_mram_event_done <= 'h0;
		else begin : sv2v_autoblock_1
			reg signed [31:0] i;
			for (i = 0; i < 4; i = i + 1)
				if (r_mram_irq_clean[i])
					r_mram_event_done[i] <= 1'b0;
				else if (mram_event_done_i[i])
					r_mram_event_done[i] <= 1'b1;
				else
					r_mram_event_done[i] <= r_mram_event_done[i];
		end
	edge_propagator_tx i_edgeprop_soc(
		.clk_i(clk_i),
		.rstn_i(rstn_i),
		.valid_i(r_clk_div_valid),
		.ack_i(cfg_clkdiv_ack_i),
		.valid_o(cfg_clkdiv_valid_o)
	);
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
			r_cfg_tx_dest_addr <= 'h0;
			r_cfg_rx_dest_addr <= 'h0;
			r_mram_mode <= 1'sb0;
			r_mram_erase_addr <= 1'sb0;
			r_mram_erase_size <= 1'sb0;
			r_clk_div_data <= 1'sb0;
			r_clk_div_valid <= 1'sb0;
			r_mram_trigger <= 1'b0;
			r_mram_irq_enable <= 1'b0;
			r_mram_ecc_error <= 2'h0;
			r_mram_irq_clean <= 'h0;
		end
		else begin
			r_rx_en = 'h0;
			r_rx_clr = 'h0;
			r_tx_en = 'h0;
			r_tx_clr = 'h0;
			r_mram_trigger <= (r_mram_trigger ? 1'b0 : r_mram_trigger);
			if (mram_rx_ecc_error_i)
				r_mram_ecc_error <= mram_rx_ecc_error_i;
			if (cfg_clkdiv_ack_i)
				r_clk_div_valid <= 1'b0;
			begin : sv2v_autoblock_2
				reg signed [31:0] i;
				for (i = 0; i < 4; i = i + 1)
					if (r_mram_irq_clean[i])
						r_mram_irq_clean[i] <= 1'b0;
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
					5'b01000: r_cfg_tx_dest_addr <= cfg_data_i[MRAM_ADDR_WIDTH - 1:0];
					5'b01001: r_cfg_rx_dest_addr <= cfg_data_i[MRAM_ADDR_WIDTH - 1:0];
					5'b01010:
						if (cfg_data_i[5:4] == 2'h0)
							r_mram_ecc_error <= 2'h0;
					5'b01011: r_mram_mode <= cfg_data_i;
					5'b01100: r_mram_erase_addr <= cfg_data_i[15:0];
					5'b01101: r_mram_erase_size <= cfg_data_i[9:0];
					5'b01110: begin
						r_clk_div_valid <= cfg_data_i[8];
						r_clk_div_data <= cfg_data_i[7:0];
					end
					5'b01111: r_mram_trigger <= cfg_data_i[0];
					5'b10001: r_mram_irq_enable <= cfg_data_i[3:0];
					5'b10010: r_mram_irq_clean <= cfg_data_i[3:0];
				endcase
		end
	assign mram_push_tx_req_o = r_mram_trigger;
	assign mram_irq_enable_o = r_mram_irq_enable;
	always @(*) begin
		cfg_ready_o = 1'b1;
		cfg_data_o = 32'h00000000;
		case (s_rd_addr)
			5'b00000: cfg_data_o = cfg_rx_curr_addr_i;
			5'b00001: cfg_data_o[TRANS_SIZE - 1:0] = cfg_rx_bytes_left_i;
			5'b00010: cfg_data_o = {26'h0000000, cfg_rx_pending_i, cfg_rx_en_i, 3'h0, r_rx_continuous};
			5'b00100: cfg_data_o = cfg_tx_curr_addr_i;
			5'b00101: cfg_data_o[TRANS_SIZE - 1:0] = cfg_tx_bytes_left_i;
			5'b00110: cfg_data_o = {26'h0000000, cfg_tx_pending_i, cfg_tx_en_i, 3'h0, r_tx_continuous};
			5'b01000: cfg_data_o = {12'h000, r_cfg_tx_dest_addr[MRAM_ADDR_WIDTH - 1:0]};
			5'b01001: cfg_data_o = {12'h000, r_cfg_rx_dest_addr[MRAM_ADDR_WIDTH - 1:0]};
			5'b01010: cfg_data_o = {r_mram_ecc_error, mram_ref_line_pending_i, cfg_rx_busy_i | cfg_rx_en_i, cfg_tx_busy_i | cfg_tx_en_i, mram_erase_pending_i};
			5'b01011: cfg_data_o = r_mram_mode;
			5'b01100: cfg_data_o = {13'h0000, r_mram_erase_addr};
			5'b01101: cfg_data_o = {22'h000000, r_mram_erase_size};
			5'b10000: cfg_data_o = {28'h0000000, r_mram_event_done};
			5'b10001: cfg_data_o = {28'h0000000, r_mram_irq_enable};
			5'b01110: cfg_data_o = {23'h000000, r_clk_div_valid, r_clk_div_data};
			default: cfg_data_o = 'h0;
		endcase
	end
endmodule
