module udma_spim_reg_if (
	clk_i,
	rstn_i,
	cfg_data_i,
	cfg_addr_i,
	cfg_valid_i,
	cfg_rwn_i,
	cfg_data_o,
	cfg_ready_o,
	cfg_cmd_startaddr_o,
	cfg_cmd_size_o,
	cfg_cmd_datasize_o,
	cfg_cmd_continuous_o,
	cfg_cmd_en_o,
	cfg_cmd_clr_o,
	cfg_cmd_en_i,
	cfg_cmd_pending_i,
	cfg_cmd_curr_addr_i,
	cfg_cmd_bytes_left_i,
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
	status_i,
	udma_cmd_i,
	udma_cmd_valid_i,
	udma_cmd_ready_i
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
	output wire [L2_AWIDTH_NOAL - 1:0] cfg_cmd_startaddr_o;
	output wire [TRANS_SIZE - 1:0] cfg_cmd_size_o;
	output wire [1:0] cfg_cmd_datasize_o;
	output wire cfg_cmd_continuous_o;
	output wire cfg_cmd_en_o;
	output wire cfg_cmd_clr_o;
	input wire cfg_cmd_en_i;
	input wire cfg_cmd_pending_i;
	input wire [L2_AWIDTH_NOAL - 1:0] cfg_cmd_curr_addr_i;
	input wire [TRANS_SIZE - 1:0] cfg_cmd_bytes_left_i;
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
	input wire [1:0] status_i;
	input wire [31:0] udma_cmd_i;
	input wire udma_cmd_valid_i;
	input wire udma_cmd_ready_i;
	reg [L2_AWIDTH_NOAL - 1:0] r_cmd_startaddr;
	reg [TRANS_SIZE - 1:0] r_cmd_size;
	reg r_cmd_continuous;
	reg r_cmd_en;
	reg r_cmd_clr;
	reg [L2_AWIDTH_NOAL - 1:0] r_rx_startaddr;
	reg [TRANS_SIZE - 1:0] r_rx_size;
	reg [1:0] r_rx_datasize;
	reg r_rx_continuous;
	reg r_rx_en;
	reg r_rx_clr;
	reg [L2_AWIDTH_NOAL - 1:0] r_tx_startaddr;
	reg [TRANS_SIZE - 1:0] r_tx_size;
	reg r_tx_continuous;
	reg [1:0] r_tx_datasize;
	reg r_tx_en;
	reg r_tx_clr;
	wire [4:0] s_wr_addr;
	wire [4:0] s_rd_addr;
	wire [1:0] r_cnt_state;
	wire [1:0] s_cnt_state_next;
	wire s_cnt_done;
	wire s_cnt_start;
	wire s_cnt_update;
	wire [7:0] s_cnt_target;
	wire [7:0] r_cnt_target;
	wire [7:0] r_cnt;
	wire [7:0] s_cnt_next;
	wire [3:0] s_cmd;
	wire [L2_AWIDTH_NOAL - 1:0] s_cmd_decode_addr;
	wire [TRANS_SIZE - 1:0] s_cmd_decode_size;
	wire s_cmd_decode_txrxn;
	wire [1:0] s_cmd_decode_ds;
	wire s_is_cmd_uca;
	wire s_is_cmd_ucs;
	assign s_cmd = udma_cmd_i[31:28];
	assign s_cmd_decode_txrxn = udma_cmd_i[27];
	assign s_cmd_decode_ds = udma_cmd_i[26:25];
	assign s_cmd_decode_size = udma_cmd_i[TRANS_SIZE - 1:0];
	assign s_cmd_decode_addr = udma_cmd_i[L2_AWIDTH_NOAL - 1:0];
	assign s_is_cmd_uca = s_cmd == 4'b1101;
	assign s_is_cmd_ucs = s_cmd == 4'b1110;
	assign s_wr_addr = (cfg_valid_i & ~cfg_rwn_i ? cfg_addr_i : 5'h00);
	assign s_rd_addr = (cfg_valid_i & cfg_rwn_i ? cfg_addr_i : 5'h00);
	assign cfg_cmd_startaddr_o = r_cmd_startaddr;
	assign cfg_cmd_size_o = r_cmd_size;
	assign cfg_cmd_datasize_o = 2'b10;
	assign cfg_cmd_continuous_o = r_cmd_continuous;
	assign cfg_cmd_en_o = r_cmd_en;
	assign cfg_cmd_clr_o = r_cmd_clr;
	assign cfg_rx_startaddr_o = r_rx_startaddr;
	assign cfg_rx_size_o = r_rx_size;
	assign cfg_rx_datasize_o = r_rx_datasize;
	assign cfg_rx_continuous_o = r_rx_continuous;
	assign cfg_rx_en_o = r_rx_en;
	assign cfg_rx_clr_o = r_rx_clr;
	assign cfg_tx_startaddr_o = r_tx_startaddr;
	assign cfg_tx_size_o = r_tx_size;
	assign cfg_tx_datasize_o = r_tx_datasize;
	assign cfg_tx_continuous_o = r_tx_continuous;
	assign cfg_tx_en_o = r_tx_en;
	assign cfg_tx_clr_o = r_tx_clr;
	always @(posedge clk_i or negedge rstn_i)
		if (~rstn_i) begin
			r_cmd_startaddr <= 'h0;
			r_cmd_size <= 'h0;
			r_cmd_continuous <= 'h0;
			r_cmd_en = 'h0;
			r_cmd_clr = 'h0;
			r_rx_startaddr <= 'h0;
			r_rx_size <= 'h0;
			r_rx_continuous <= 'h0;
			r_rx_en = 'h0;
			r_rx_clr = 'h0;
			r_rx_datasize <= 2'b10;
			r_tx_datasize <= 2'b10;
			r_tx_startaddr <= 'h0;
			r_tx_size <= 'h0;
			r_tx_continuous <= 'h0;
			r_tx_en = 'h0;
			r_tx_clr = 'h0;
		end
		else begin
			r_cmd_en = 'h0;
			r_cmd_clr = 'h0;
			r_rx_en = 'h0;
			r_rx_clr = 'h0;
			r_tx_en = 'h0;
			r_tx_clr = 'h0;
			if ((udma_cmd_valid_i && udma_cmd_ready_i) && (s_is_cmd_ucs || s_is_cmd_uca)) begin
				if (s_is_cmd_uca) begin
					if (s_cmd_decode_txrxn)
						r_tx_startaddr <= s_cmd_decode_addr;
					else
						r_rx_startaddr <= s_cmd_decode_addr;
				end
				else if (s_cmd_decode_txrxn) begin
					r_tx_size <= s_cmd_decode_size;
					r_tx_datasize <= s_cmd_decode_ds;
					r_tx_en = 1'b1;
				end
				else begin
					r_rx_size <= s_cmd_decode_size;
					r_rx_en = 1'b1;
					r_rx_datasize <= s_cmd_decode_ds;
				end
			end
			else if (cfg_valid_i & ~cfg_rwn_i)
				case (s_wr_addr)
					5'b01000: r_cmd_startaddr <= cfg_data_i[L2_AWIDTH_NOAL - 1:0];
					5'b01001: r_cmd_size <= cfg_data_i[TRANS_SIZE - 1:0];
					5'b01010: begin
						r_cmd_clr = cfg_data_i[6];
						r_cmd_en = cfg_data_i[4];
						r_cmd_continuous <= cfg_data_i[0];
					end
					5'b00000: r_rx_startaddr <= cfg_data_i[L2_AWIDTH_NOAL - 1:0];
					5'b00001: r_rx_size <= cfg_data_i[TRANS_SIZE - 1:0];
					5'b00010: begin
						r_rx_clr = cfg_data_i[6];
						r_rx_en = cfg_data_i[4];
						r_rx_datasize <= cfg_data_i[2:1];
						r_rx_continuous <= cfg_data_i[0];
					end
					5'b00100: r_tx_startaddr <= cfg_data_i[L2_AWIDTH_NOAL - 1:0];
					5'b00101: r_tx_size <= cfg_data_i[TRANS_SIZE - 1:0];
					5'b00110: begin
						r_tx_clr = cfg_data_i[6];
						r_tx_en = cfg_data_i[4];
						r_tx_datasize <= cfg_data_i[2:1];
						r_tx_continuous <= cfg_data_i[0];
					end
				endcase
		end
	always @(*) begin
		cfg_data_o = 32'h00000000;
		case (s_rd_addr)
			5'b01000: cfg_data_o = cfg_cmd_curr_addr_i;
			5'b01001: cfg_data_o[TRANS_SIZE - 1:0] = cfg_cmd_bytes_left_i;
			5'b01010: cfg_data_o = {26'h0000000, cfg_cmd_pending_i, cfg_cmd_en_i, 3'b010, r_cmd_continuous};
			5'b00000: cfg_data_o = cfg_rx_curr_addr_i;
			5'b00001: cfg_data_o[TRANS_SIZE - 1:0] = cfg_rx_bytes_left_i;
			5'b00010: cfg_data_o = {26'h0000000, cfg_rx_pending_i, cfg_rx_en_i, 1'b0, r_rx_datasize, r_rx_continuous};
			5'b00100: cfg_data_o = cfg_tx_curr_addr_i;
			5'b00101: cfg_data_o[TRANS_SIZE - 1:0] = cfg_tx_bytes_left_i;
			5'b00110: cfg_data_o = {26'h0000000, cfg_tx_pending_i, cfg_tx_en_i, 3'b000, r_tx_continuous};
			5'b01100: cfg_data_o = {30'h00000000, status_i};
			default: cfg_data_o = 'h0;
		endcase
	end
	assign cfg_ready_o = 1'b1;
endmodule
