module udma_i2s_reg_if (
	clk_i,
	periph_clk_i,
	rstn_i,
	cfg_data_i,
	cfg_addr_i,
	cfg_valid_i,
	cfg_rwn_i,
	cfg_data_o,
	cfg_ready_o,
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
	cfg_master_clk_en_o,
	cfg_slave_clk_en_o,
	cfg_pdm_clk_en_o,
	cfg_master_sel_num_o,
	cfg_master_sel_ext_o,
	cfg_slave_sel_num_o,
	cfg_slave_sel_ext_o,
	cfg_slave_i2s_en_o,
	cfg_slave_i2s_lsb_first_o,
	cfg_slave_i2s_2ch_o,
	cfg_slave_i2s_bits_word_o,
	cfg_slave_i2s_words_o,
	cfg_slave_pdm_en_o,
	cfg_slave_pdm_mode_o,
	cfg_slave_pdm_decimation_o,
	cfg_slave_pdm_shift_o,
	cfg_master_i2s_en_o,
	cfg_master_i2s_lsb_first_o,
	cfg_master_i2s_2ch_o,
	cfg_master_i2s_bits_word_o,
	cfg_master_i2s_words_o,
	cfg_slave_gen_clk_en_o,
	cfg_slave_gen_clk_en_i,
	cfg_slave_gen_clk_div_o,
	cfg_master_gen_clk_en_o,
	cfg_master_gen_clk_en_i,
	cfg_master_gen_clk_div_o
);
	parameter L2_AWIDTH_NOAL = 12;
	parameter TRANS_SIZE = 16;
	input wire clk_i;
	input wire periph_clk_i;
	input wire rstn_i;
	input wire [31:0] cfg_data_i;
	input wire [4:0] cfg_addr_i;
	input wire cfg_valid_i;
	input wire cfg_rwn_i;
	output reg [31:0] cfg_data_o;
	output wire cfg_ready_o;
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
	output wire cfg_master_clk_en_o;
	output wire cfg_slave_clk_en_o;
	output wire cfg_pdm_clk_en_o;
	output wire cfg_master_sel_num_o;
	output wire cfg_master_sel_ext_o;
	output wire cfg_slave_sel_num_o;
	output wire cfg_slave_sel_ext_o;
	output wire cfg_slave_i2s_en_o;
	output wire cfg_slave_i2s_lsb_first_o;
	output wire cfg_slave_i2s_2ch_o;
	output wire [4:0] cfg_slave_i2s_bits_word_o;
	output wire [2:0] cfg_slave_i2s_words_o;
	output wire cfg_slave_pdm_en_o;
	output wire [1:0] cfg_slave_pdm_mode_o;
	output wire [9:0] cfg_slave_pdm_decimation_o;
	output wire [2:0] cfg_slave_pdm_shift_o;
	output wire cfg_master_i2s_en_o;
	output wire cfg_master_i2s_lsb_first_o;
	output wire cfg_master_i2s_2ch_o;
	output wire [4:0] cfg_master_i2s_bits_word_o;
	output wire [2:0] cfg_master_i2s_words_o;
	output wire cfg_slave_gen_clk_en_o;
	input wire cfg_slave_gen_clk_en_i;
	output wire [15:0] cfg_slave_gen_clk_div_o;
	output wire cfg_master_gen_clk_en_o;
	input wire cfg_master_gen_clk_en_i;
	output wire [15:0] cfg_master_gen_clk_div_o;
	localparam MAX_CHANNELS = 4;
	reg [L2_AWIDTH_NOAL - 1:0] r_rx_startaddr;
	reg [TRANS_SIZE - 1:0] r_rx_size;
	reg [1:0] r_rx_datasize;
	reg r_rx_continuous;
	reg r_rx_en;
	reg r_rx_clr;
	reg [L2_AWIDTH_NOAL - 1:0] r_tx_startaddr;
	reg [TRANS_SIZE - 1:0] r_tx_size;
	reg [1:0] r_tx_datasize;
	reg r_tx_continuous;
	reg r_tx_en;
	reg r_tx_clr;
	reg r_master_clk_en;
	reg r_slave_clk_en;
	reg r_per_master_clk_en;
	reg r_per_slave_clk_en;
	reg r_master_sel_num;
	reg r_master_sel_ext;
	reg r_slave_sel_num;
	reg r_slave_sel_ext;
	reg r_per_master_sel_num;
	reg r_per_master_sel_ext;
	reg r_per_slave_sel_num;
	reg r_per_slave_sel_ext;
	reg r_slave_i2s_en;
	reg r_slave_i2s_lsb_first;
	reg r_slave_i2s_2ch;
	reg [4:0] r_slave_i2s_bits_word;
	reg [2:0] r_slave_i2s_words;
	reg r_slave_pdm_en;
	reg [1:0] r_slave_pdm_mode;
	reg [9:0] r_slave_pdm_decimation;
	reg [2:0] r_slave_pdm_shift;
	reg r_master_i2s_en;
	reg r_master_i2s_lsb_first;
	reg r_master_i2s_2ch;
	reg [4:0] r_master_i2s_bits_word;
	reg [2:0] r_master_i2s_words;
	reg [7:0] r_common_gen_clk_div;
	reg [7:0] r_slave_gen_clk_div;
	reg [7:0] r_master_gen_clk_div;
	reg [7:0] r_per_common_gen_clk_div;
	reg [7:0] r_per_slave_gen_clk_div;
	reg [7:0] r_per_master_gen_clk_div;
	reg r_pdm_clk_en;
	reg r_per_pdm_clk_en;
	wire [4:0] s_wr_addr;
	wire [4:0] s_rd_addr;
	wire s_update_clk;
	reg r_update_clk;
	assign s_wr_addr = (cfg_valid_i & ~cfg_rwn_i ? cfg_addr_i : 5'h00);
	assign s_rd_addr = (cfg_valid_i & cfg_rwn_i ? cfg_addr_i : 5'h00);
	assign s_update_clk = (cfg_valid_i & ~cfg_rwn_i) & (s_wr_addr == 5'b01000);
	wire cfg_update_clk_o;
	assign cfg_update_clk_o = r_update_clk;
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
	assign cfg_master_sel_num_o = r_per_master_sel_num;
	assign cfg_master_sel_ext_o = r_per_master_sel_ext;
	assign cfg_slave_sel_num_o = r_per_slave_sel_num;
	assign cfg_slave_sel_ext_o = r_per_slave_sel_ext;
	assign cfg_slave_i2s_en_o = r_slave_i2s_en;
	assign cfg_slave_i2s_lsb_first_o = r_slave_i2s_lsb_first;
	assign cfg_slave_i2s_2ch_o = r_slave_i2s_2ch;
	assign cfg_slave_i2s_bits_word_o = r_slave_i2s_bits_word;
	assign cfg_slave_i2s_words_o = r_slave_i2s_words;
	assign cfg_slave_pdm_en_o = r_slave_pdm_en;
	assign cfg_slave_pdm_mode_o = r_slave_pdm_mode;
	assign cfg_slave_pdm_decimation_o = r_slave_pdm_decimation;
	assign cfg_slave_pdm_shift_o = r_slave_pdm_shift;
	assign cfg_master_i2s_en_o = r_master_i2s_en;
	assign cfg_master_i2s_lsb_first_o = r_master_i2s_lsb_first;
	assign cfg_master_i2s_2ch_o = r_master_i2s_2ch;
	assign cfg_master_i2s_bits_word_o = r_master_i2s_bits_word;
	assign cfg_master_i2s_words_o = r_master_i2s_words;
	assign cfg_slave_gen_clk_div_o = {r_per_common_gen_clk_div, r_per_slave_gen_clk_div};
	assign cfg_master_gen_clk_div_o = {r_per_common_gen_clk_div, r_per_master_gen_clk_div};
	assign cfg_master_clk_en_o = r_per_master_clk_en;
	assign cfg_slave_clk_en_o = r_per_slave_clk_en;
	assign cfg_pdm_clk_en_o = r_pdm_clk_en;
	wire s_update;
	edge_propagator i_edgeprop(
		.clk_tx_i(clk_i),
		.rstn_tx_i(rstn_i),
		.edge_i(r_update_clk),
		.clk_rx_i(periph_clk_i),
		.rstn_rx_i(rstn_i),
		.edge_o(s_update)
	);
	always @(posedge periph_clk_i or negedge rstn_i)
		if (~rstn_i) begin
			r_per_master_clk_en <= 'h0;
			r_per_slave_clk_en <= 'h0;
			r_per_pdm_clk_en <= 'h0;
			r_per_master_sel_num <= 'h0;
			r_per_master_sel_ext <= 'h0;
			r_per_slave_sel_num <= 'h0;
			r_per_slave_sel_ext <= 'h0;
			r_per_common_gen_clk_div <= 'h0;
			r_per_slave_gen_clk_div <= 'h0;
			r_per_master_gen_clk_div <= 'h0;
		end
		else if (s_update) begin
			r_per_pdm_clk_en <= r_pdm_clk_en;
			r_per_master_clk_en <= r_master_clk_en;
			r_per_slave_clk_en <= r_slave_clk_en;
			r_per_master_sel_num <= r_master_sel_num;
			r_per_master_sel_ext <= r_master_sel_ext;
			r_per_slave_sel_num <= r_slave_sel_num;
			r_per_slave_sel_ext <= r_slave_sel_ext;
			r_per_common_gen_clk_div <= r_common_gen_clk_div;
			r_per_slave_gen_clk_div <= r_slave_gen_clk_div;
			r_per_master_gen_clk_div <= r_master_gen_clk_div;
		end
	always @(posedge clk_i or negedge rstn_i)
		if (~rstn_i)
			r_update_clk <= 1'b0;
		else
			r_update_clk <= s_update_clk;
	always @(posedge clk_i or negedge rstn_i)
		if (~rstn_i) begin
			r_rx_startaddr <= 'h0;
			r_rx_size <= 'h0;
			r_rx_datasize <= 'h2;
			r_rx_continuous <= 'h0;
			r_rx_en = 'h0;
			r_rx_clr = 'h0;
			r_tx_startaddr <= 'h0;
			r_tx_size <= 'h0;
			r_tx_datasize <= 'h2;
			r_tx_continuous <= 'h0;
			r_tx_en = 'h0;
			r_tx_clr = 'h0;
			r_master_sel_num <= 'h0;
			r_master_sel_ext <= 'h0;
			r_slave_sel_num <= 'h0;
			r_slave_sel_ext <= 'h0;
			r_master_clk_en <= 'h0;
			r_pdm_clk_en <= 'h0;
			r_slave_clk_en <= 'h0;
			r_slave_i2s_en <= 'h0;
			r_slave_i2s_lsb_first <= 'h0;
			r_slave_i2s_2ch <= 'h0;
			r_slave_i2s_bits_word <= 'h0;
			r_slave_i2s_words <= 'h0;
			r_slave_pdm_en <= 'h0;
			r_slave_pdm_mode <= 'h0;
			r_slave_pdm_decimation <= 'h0;
			r_slave_pdm_shift <= 'h0;
			r_master_i2s_en <= 'h0;
			r_master_i2s_lsb_first <= 'h0;
			r_master_i2s_2ch <= 'h0;
			r_master_i2s_bits_word <= 'h0;
			r_master_i2s_words <= 'h0;
			r_common_gen_clk_div <= 'h0;
			r_slave_gen_clk_div <= 'h0;
			r_master_gen_clk_div <= 'h0;
		end
		else begin
			r_rx_en = 'h0;
			r_rx_clr = 'h0;
			r_tx_en = 'h0;
			r_tx_clr = 'h0;
			if (cfg_valid_i & ~cfg_rwn_i)
				case (s_wr_addr)
					5'b00000: r_rx_startaddr <= cfg_data_i[L2_AWIDTH_NOAL - 1:0];
					5'b00001: r_rx_size <= cfg_data_i[TRANS_SIZE - 1:0];
					5'b00010: begin
						r_rx_clr = cfg_data_i[5];
						r_rx_en = cfg_data_i[4];
						r_rx_datasize <= cfg_data_i[2:1];
						r_rx_continuous <= cfg_data_i[0];
					end
					5'b00100: r_tx_startaddr <= cfg_data_i[L2_AWIDTH_NOAL - 1:0];
					5'b00101: r_tx_size <= cfg_data_i[TRANS_SIZE - 1:0];
					5'b00110: begin
						r_tx_clr = cfg_data_i[5];
						r_tx_en = cfg_data_i[4];
						r_tx_datasize <= cfg_data_i[2:1];
						r_tx_continuous <= cfg_data_i[0];
					end
					5'b01000: begin
						r_master_sel_num <= cfg_data_i[31];
						r_master_sel_ext <= cfg_data_i[30];
						r_slave_sel_num <= cfg_data_i[29];
						r_slave_sel_ext <= cfg_data_i[28];
						r_pdm_clk_en <= cfg_data_i[26];
						r_master_clk_en <= cfg_data_i[25];
						r_slave_clk_en <= cfg_data_i[24];
						r_common_gen_clk_div <= cfg_data_i[23:16];
						r_slave_gen_clk_div <= cfg_data_i[15:8];
						r_master_gen_clk_div <= cfg_data_i[7:0];
					end
					5'b01001:
						if (!r_slave_clk_en) begin
							r_slave_i2s_en <= cfg_data_i[31];
							r_slave_i2s_2ch <= cfg_data_i[17];
							r_slave_i2s_lsb_first <= cfg_data_i[16];
							r_slave_i2s_bits_word <= cfg_data_i[12:8];
							r_slave_i2s_words <= cfg_data_i[2:0];
						end
					5'b01010:
						if (!r_master_clk_en) begin
							r_master_i2s_en <= cfg_data_i[31];
							r_master_i2s_2ch <= cfg_data_i[17];
							r_master_i2s_lsb_first <= cfg_data_i[16];
							r_master_i2s_bits_word <= cfg_data_i[12:8];
							r_master_i2s_words <= cfg_data_i[2:0];
						end
					5'b01011:
						if (!r_slave_clk_en) begin
							r_slave_pdm_en <= cfg_data_i[31];
							r_slave_pdm_mode <= cfg_data_i[14:13];
							r_slave_pdm_decimation <= cfg_data_i[12:3];
							r_slave_pdm_shift <= cfg_data_i[2:0];
						end
				endcase
		end
	always @(*) begin
		cfg_data_o = 32'h00000000;
		case (s_rd_addr)
			5'b00000: cfg_data_o = cfg_rx_curr_addr_i;
			5'b00001: cfg_data_o[TRANS_SIZE - 1:0] = cfg_rx_bytes_left_i;
			5'b00010: cfg_data_o = {26'h0000000, cfg_rx_pending_i, cfg_rx_en_i, 1'b0, r_rx_datasize, r_rx_continuous};
			5'b00100: cfg_data_o = cfg_tx_curr_addr_i;
			5'b00101: cfg_data_o[TRANS_SIZE - 1:0] = cfg_tx_bytes_left_i;
			5'b00110: cfg_data_o = {26'h0000000, cfg_tx_pending_i, cfg_tx_en_i, 1'b0, r_tx_datasize, r_tx_continuous};
			5'b01000: cfg_data_o = {r_master_sel_num, r_master_sel_ext, r_slave_sel_num, r_slave_sel_ext, 2'b00, r_master_clk_en, r_slave_clk_en, r_common_gen_clk_div, r_slave_gen_clk_div, r_master_gen_clk_div};
			5'b01001: cfg_data_o = {r_slave_i2s_en, 13'h0000, r_slave_i2s_2ch, r_slave_i2s_lsb_first, 3'h0, r_slave_i2s_bits_word, 5'h00, r_slave_i2s_words};
			5'b01010: cfg_data_o = {r_master_i2s_en, 13'h0000, r_master_i2s_2ch, r_master_i2s_lsb_first, 3'h0, r_master_i2s_bits_word, 5'h00, r_master_i2s_words};
			5'b01011: cfg_data_o = {r_slave_pdm_en, 17'h00000, r_slave_pdm_mode, r_slave_pdm_decimation, r_slave_pdm_shift};
			default: cfg_data_o = 'h0;
		endcase
	end
	assign cfg_ready_o = 1'b1;
endmodule
