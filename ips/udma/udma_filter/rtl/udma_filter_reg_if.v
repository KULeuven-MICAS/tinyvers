module udma_filter_reg_if (
	clk_i,
	rstn_i,
	cfg_data_i,
	cfg_addr_i,
	cfg_valid_i,
	cfg_rwn_i,
	cfg_data_o,
	cfg_ready_o,
	cfg_filter_mode_o,
	cfg_filter_start_o,
	cfg_filter_tx_start_addr_o,
	cfg_filter_tx_datasize_o,
	cfg_filter_tx_mode_o,
	cfg_filter_tx_len0_o,
	cfg_filter_tx_len1_o,
	cfg_filter_tx_len2_o,
	cfg_filter_rx_start_addr_o,
	cfg_filter_rx_datasize_o,
	cfg_filter_rx_mode_o,
	cfg_filter_rx_len0_o,
	cfg_filter_rx_len1_o,
	cfg_filter_rx_len2_o,
	cfg_au_use_signed_o,
	cfg_au_bypass_o,
	cfg_au_mode_o,
	cfg_au_shift_o,
	cfg_au_reg0_o,
	cfg_au_reg1_o,
	cfg_bincu_threshold_o,
	cfg_bincu_counter_o,
	cfg_bincu_en_counter_o,
	cfg_bincu_datasize_o,
	bincu_counter_i,
	filter_done_i
);
	parameter L2_AWIDTH_NOAL = 15;
	parameter TRANS_SIZE = 15;
	input wire clk_i;
	input wire rstn_i;
	input wire [31:0] cfg_data_i;
	input wire [4:0] cfg_addr_i;
	input wire cfg_valid_i;
	input wire cfg_rwn_i;
	output reg [31:0] cfg_data_o;
	output wire cfg_ready_o;
	output wire [3:0] cfg_filter_mode_o;
	output reg cfg_filter_start_o;
	output wire [(2 * L2_AWIDTH_NOAL) - 1:0] cfg_filter_tx_start_addr_o;
	output wire [3:0] cfg_filter_tx_datasize_o;
	output wire [3:0] cfg_filter_tx_mode_o;
	output wire [(2 * TRANS_SIZE) - 1:0] cfg_filter_tx_len0_o;
	output wire [(2 * TRANS_SIZE) - 1:0] cfg_filter_tx_len1_o;
	output wire [(2 * TRANS_SIZE) - 1:0] cfg_filter_tx_len2_o;
	output wire [L2_AWIDTH_NOAL - 1:0] cfg_filter_rx_start_addr_o;
	output wire [1:0] cfg_filter_rx_datasize_o;
	output wire [1:0] cfg_filter_rx_mode_o;
	output wire [TRANS_SIZE - 1:0] cfg_filter_rx_len0_o;
	output wire [TRANS_SIZE - 1:0] cfg_filter_rx_len1_o;
	output wire [TRANS_SIZE - 1:0] cfg_filter_rx_len2_o;
	output wire cfg_au_use_signed_o;
	output wire cfg_au_bypass_o;
	output wire [3:0] cfg_au_mode_o;
	output wire [4:0] cfg_au_shift_o;
	output wire [31:0] cfg_au_reg0_o;
	output wire [31:0] cfg_au_reg1_o;
	output wire [31:0] cfg_bincu_threshold_o;
	output wire [TRANS_SIZE - 1:0] cfg_bincu_counter_o;
	output wire cfg_bincu_en_counter_o;
	output wire [1:0] cfg_bincu_datasize_o;
	input wire [TRANS_SIZE - 1:0] bincu_counter_i;
	input wire filter_done_i;
	reg [(2 * L2_AWIDTH_NOAL) - 1:0] r_filter_tx_start_addr;
	reg [3:0] r_filter_tx_datasize;
	reg [3:0] r_filter_tx_mode;
	reg [(2 * TRANS_SIZE) - 1:0] r_filter_tx_len0;
	reg [(2 * TRANS_SIZE) - 1:0] r_filter_tx_len1;
	reg [(2 * TRANS_SIZE) - 1:0] r_filter_tx_len2;
	reg [L2_AWIDTH_NOAL - 1:0] r_filter_rx_start_addr;
	reg [1:0] r_filter_rx_datasize;
	reg [1:0] r_filter_rx_mode;
	reg [TRANS_SIZE - 1:0] r_filter_rx_len0;
	reg [TRANS_SIZE - 1:0] r_filter_rx_len1;
	reg [TRANS_SIZE - 1:0] r_filter_rx_len2;
	reg r_au_use_signed;
	reg r_au_bypass;
	reg [3:0] r_au_mode;
	reg [4:0] r_au_shift;
	reg [31:0] r_au_reg0;
	reg [31:0] r_au_reg1;
	reg [31:0] r_bincu_threshold;
	reg [TRANS_SIZE - 1:0] r_bincu_counter;
	reg [1:0] r_bincu_datasize;
	reg r_bincu_en_counter;
	reg [3:0] r_filter_mode;
	reg [(2 * L2_AWIDTH_NOAL) - 1:0] r_commit_filter_tx_start_addr;
	reg [3:0] r_commit_filter_tx_datasize;
	reg [3:0] r_commit_filter_tx_mode;
	reg [(2 * TRANS_SIZE) - 1:0] r_commit_filter_tx_len0;
	reg [(2 * TRANS_SIZE) - 1:0] r_commit_filter_tx_len1;
	reg [(2 * TRANS_SIZE) - 1:0] r_commit_filter_tx_len2;
	reg [L2_AWIDTH_NOAL - 1:0] r_commit_filter_rx_start_addr;
	reg [1:0] r_commit_filter_rx_datasize;
	reg [1:0] r_commit_filter_rx_mode;
	reg [TRANS_SIZE - 1:0] r_commit_filter_rx_len0;
	reg [TRANS_SIZE - 1:0] r_commit_filter_rx_len1;
	reg [TRANS_SIZE - 1:0] r_commit_filter_rx_len2;
	reg r_commit_au_use_signed;
	reg r_commit_au_bypass;
	reg [3:0] r_commit_au_mode;
	reg [4:0] r_commit_au_shift;
	reg [31:0] r_commit_au_reg0;
	reg [31:0] r_commit_au_reg1;
	reg [31:0] r_commit_bincu_threshold;
	reg [TRANS_SIZE - 1:0] r_commit_bincu_counter;
	reg [1:0] r_commit_bincu_datasize;
	reg r_commit_bincu_en_counter;
	reg [3:0] r_commit_filter_mode;
	reg r_filter_start;
	reg r_filter_done;
	wire [4:0] s_wr_addr;
	wire [4:0] s_rd_addr;
	reg s_sample_commit;
	reg s_set_pending;
	reg s_clr_pending;
	reg r_pending;
	reg [1:0] r_state;
	reg [1:0] s_state;
	assign s_wr_addr = (cfg_valid_i & ~cfg_rwn_i ? cfg_addr_i : 5'h00);
	assign s_rd_addr = (cfg_valid_i & cfg_rwn_i ? cfg_addr_i : 5'h00);
	assign cfg_filter_tx_start_addr_o = r_commit_filter_tx_start_addr;
	assign cfg_filter_tx_datasize_o = r_commit_filter_tx_datasize;
	assign cfg_filter_tx_mode_o = r_commit_filter_tx_mode;
	assign cfg_filter_tx_len0_o = r_commit_filter_tx_len0;
	assign cfg_filter_tx_len1_o = r_commit_filter_tx_len1;
	assign cfg_filter_tx_len2_o = r_commit_filter_tx_len2;
	assign cfg_filter_rx_start_addr_o = r_commit_filter_rx_start_addr;
	assign cfg_filter_rx_datasize_o = r_commit_filter_rx_datasize;
	assign cfg_filter_rx_mode_o = r_commit_filter_rx_mode;
	assign cfg_filter_rx_len0_o = r_commit_filter_rx_len0;
	assign cfg_filter_rx_len1_o = r_commit_filter_rx_len1;
	assign cfg_filter_rx_len2_o = r_commit_filter_rx_len2;
	assign cfg_filter_mode_o = r_commit_filter_mode;
	assign cfg_au_use_signed_o = r_commit_au_use_signed;
	assign cfg_au_bypass_o = r_commit_au_bypass;
	assign cfg_au_mode_o = r_commit_au_mode;
	assign cfg_au_shift_o = r_commit_au_shift;
	assign cfg_au_reg0_o = r_commit_au_reg0;
	assign cfg_au_reg1_o = r_commit_au_reg1;
	assign cfg_bincu_counter_o = r_commit_bincu_counter;
	assign cfg_bincu_threshold_o = r_commit_bincu_threshold;
	assign cfg_bincu_en_counter_o = r_commit_bincu_en_counter;
	assign cfg_bincu_datasize_o = r_commit_bincu_datasize;
	always @(*) begin : proc_pending
		s_sample_commit = 1'b0;
		s_set_pending = 1'b0;
		s_clr_pending = 1'b0;
		s_state = r_state;
		cfg_filter_start_o = 1'b0;
		case (r_state)
			2'd0:
				if (r_filter_start) begin
					s_sample_commit = 1'b1;
					s_state = 2'd1;
				end
			2'd1: begin
				cfg_filter_start_o = 1'b1;
				s_state = 2'd2;
			end
			2'd2:
				if (r_filter_start) begin
					if (filter_done_i) begin
						s_sample_commit = 1'b1;
						s_state = 2'd1;
					end
					else
						s_set_pending = 1'b1;
				end
				else if (filter_done_i)
					if (r_pending) begin
						s_sample_commit = 1'b1;
						s_state = 2'd1;
						s_clr_pending = 1'b1;
					end
					else
						s_state = 2'd0;
		endcase
	end
	always @(posedge clk_i or negedge rstn_i)
		if (~rstn_i)
			r_state <= 2'd0;
		else
			r_state <= s_state;
	always @(posedge clk_i or negedge rstn_i)
		if (~rstn_i) begin
			r_pending <= 0;
			r_commit_filter_tx_start_addr[0+:L2_AWIDTH_NOAL] <= 0;
			r_commit_filter_tx_datasize[0+:2] <= 0;
			r_commit_filter_tx_mode[0+:2] <= 0;
			r_commit_filter_tx_len0[0+:TRANS_SIZE] <= 0;
			r_commit_filter_tx_len1[0+:TRANS_SIZE] <= 0;
			r_commit_filter_tx_len2[0+:TRANS_SIZE] <= 0;
			r_commit_filter_tx_start_addr[L2_AWIDTH_NOAL+:L2_AWIDTH_NOAL] <= 0;
			r_commit_filter_tx_datasize[2+:2] <= 0;
			r_commit_filter_tx_mode[2+:2] <= 0;
			r_commit_filter_tx_len0[TRANS_SIZE+:TRANS_SIZE] <= 0;
			r_commit_filter_tx_len1[TRANS_SIZE+:TRANS_SIZE] <= 0;
			r_commit_filter_tx_len2[TRANS_SIZE+:TRANS_SIZE] <= 0;
			r_commit_filter_rx_start_addr <= 0;
			r_commit_filter_rx_datasize <= 0;
			r_commit_filter_rx_mode <= 0;
			r_commit_filter_rx_len0 <= 0;
			r_commit_filter_rx_len1 <= 0;
			r_commit_filter_rx_len2 <= 0;
			r_commit_au_use_signed <= 0;
			r_commit_au_bypass <= 0;
			r_commit_au_mode <= 0;
			r_commit_au_shift <= 0;
			r_commit_au_reg0 <= 0;
			r_commit_au_reg1 <= 0;
			r_commit_bincu_threshold <= 0;
			r_commit_bincu_counter <= 0;
			r_commit_bincu_datasize <= 0;
			r_commit_bincu_en_counter <= 0;
			r_commit_filter_mode <= 0;
		end
		else begin
			if (s_sample_commit) begin
				r_commit_filter_tx_start_addr[0+:L2_AWIDTH_NOAL] <= r_filter_tx_start_addr[0+:L2_AWIDTH_NOAL];
				r_commit_filter_tx_datasize[0+:2] <= r_filter_tx_datasize[0+:2];
				r_commit_filter_tx_mode[0+:2] <= r_filter_tx_mode[0+:2];
				r_commit_filter_tx_len0[0+:TRANS_SIZE] <= r_filter_tx_len0[0+:TRANS_SIZE];
				r_commit_filter_tx_len1[0+:TRANS_SIZE] <= r_filter_tx_len1[0+:TRANS_SIZE];
				r_commit_filter_tx_len2[0+:TRANS_SIZE] <= r_filter_tx_len2[0+:TRANS_SIZE];
				r_commit_filter_tx_start_addr[L2_AWIDTH_NOAL+:L2_AWIDTH_NOAL] <= r_filter_tx_start_addr[L2_AWIDTH_NOAL+:L2_AWIDTH_NOAL];
				r_commit_filter_tx_datasize[2+:2] <= r_filter_tx_datasize[2+:2];
				r_commit_filter_tx_mode[2+:2] <= r_filter_tx_mode[2+:2];
				r_commit_filter_tx_len0[TRANS_SIZE+:TRANS_SIZE] <= r_filter_tx_len0[TRANS_SIZE+:TRANS_SIZE];
				r_commit_filter_tx_len1[TRANS_SIZE+:TRANS_SIZE] <= r_filter_tx_len1[TRANS_SIZE+:TRANS_SIZE];
				r_commit_filter_tx_len2[TRANS_SIZE+:TRANS_SIZE] <= r_filter_tx_len2[TRANS_SIZE+:TRANS_SIZE];
				r_commit_filter_rx_start_addr <= r_filter_rx_start_addr;
				r_commit_filter_rx_datasize <= r_filter_rx_datasize;
				r_commit_filter_rx_mode <= r_filter_rx_mode;
				r_commit_filter_rx_len0 <= r_filter_rx_len0;
				r_commit_filter_rx_len1 <= r_filter_rx_len1;
				r_commit_filter_rx_len2 <= r_filter_rx_len2;
				r_commit_au_use_signed <= r_au_use_signed;
				r_commit_au_bypass <= r_au_bypass;
				r_commit_au_mode <= r_au_mode;
				r_commit_au_shift <= r_au_shift;
				r_commit_au_reg0 <= r_au_reg0;
				r_commit_au_reg1 <= r_au_reg1;
				r_commit_bincu_threshold <= r_bincu_threshold;
				r_commit_bincu_counter <= r_bincu_counter;
				r_commit_bincu_datasize <= r_bincu_datasize;
				r_commit_bincu_en_counter <= r_bincu_en_counter;
				r_commit_filter_mode <= r_filter_mode;
			end
			if (s_clr_pending)
				r_pending <= 1'b0;
			else if (s_set_pending)
				r_pending <= 1'b1;
		end
	always @(posedge clk_i or negedge rstn_i)
		if (~rstn_i) begin
			r_filter_tx_start_addr[0+:L2_AWIDTH_NOAL] <= 0;
			r_filter_tx_datasize[0+:2] <= 0;
			r_filter_tx_mode[0+:2] <= 0;
			r_filter_tx_len0[0+:TRANS_SIZE] <= 0;
			r_filter_tx_len1[0+:TRANS_SIZE] <= 0;
			r_filter_tx_len2[0+:TRANS_SIZE] <= 0;
			r_filter_tx_start_addr[L2_AWIDTH_NOAL+:L2_AWIDTH_NOAL] <= 0;
			r_filter_tx_datasize[2+:2] <= 0;
			r_filter_tx_mode[2+:2] <= 0;
			r_filter_tx_len0[TRANS_SIZE+:TRANS_SIZE] <= 0;
			r_filter_tx_len1[TRANS_SIZE+:TRANS_SIZE] <= 0;
			r_filter_tx_len2[TRANS_SIZE+:TRANS_SIZE] <= 0;
			r_filter_rx_start_addr <= 0;
			r_filter_rx_datasize <= 0;
			r_filter_rx_mode <= 0;
			r_filter_rx_len0 <= 0;
			r_filter_rx_len1 <= 0;
			r_filter_rx_len2 <= 0;
			r_au_use_signed <= 0;
			r_au_bypass <= 0;
			r_au_mode <= 0;
			r_au_shift <= 0;
			r_au_reg0 <= 0;
			r_au_reg1 <= 0;
			r_bincu_threshold <= 0;
			r_bincu_counter <= 0;
			r_bincu_datasize <= 0;
			r_bincu_en_counter <= 0;
			r_filter_mode <= 0;
			r_filter_start <= 0;
			r_filter_done <= 1'b0;
		end
		else begin
			if (filter_done_i)
				r_filter_done <= 1'b1;
			if (((cfg_valid_i && !cfg_rwn_i) && (s_wr_addr == 5'b10111)) && cfg_data_i[0])
				r_filter_start <= 1'b1;
			else
				r_filter_start <= 1'b0;
			if (cfg_valid_i & ~cfg_rwn_i)
				case (s_wr_addr)
					5'b00000: r_filter_tx_start_addr[0+:L2_AWIDTH_NOAL] <= cfg_data_i[L2_AWIDTH_NOAL - 1:0];
					5'b00001: begin
						r_filter_tx_datasize[0+:2] <= cfg_data_i[1:0];
						r_filter_tx_mode[0+:2] <= cfg_data_i[9:8];
					end
					5'b00010: r_filter_tx_len0[0+:TRANS_SIZE] <= cfg_data_i[TRANS_SIZE - 1:0];
					5'b00011: r_filter_tx_len1[0+:TRANS_SIZE] <= cfg_data_i[TRANS_SIZE - 1:0];
					5'b00100: r_filter_tx_len2[0+:TRANS_SIZE] <= cfg_data_i[TRANS_SIZE - 1:0];
					5'b00101: r_filter_tx_start_addr[L2_AWIDTH_NOAL+:L2_AWIDTH_NOAL] <= cfg_data_i[L2_AWIDTH_NOAL - 1:0];
					5'b00110: begin
						r_filter_tx_datasize[2+:2] <= cfg_data_i[1:0];
						r_filter_tx_mode[2+:2] <= cfg_data_i[9:8];
					end
					5'b00111: r_filter_tx_len0[TRANS_SIZE+:TRANS_SIZE] <= cfg_data_i[TRANS_SIZE - 1:0];
					5'b01000: r_filter_tx_len1[TRANS_SIZE+:TRANS_SIZE] <= cfg_data_i[TRANS_SIZE - 1:0];
					5'b01001: r_filter_tx_len2[TRANS_SIZE+:TRANS_SIZE] <= cfg_data_i[TRANS_SIZE - 1:0];
					5'b01010: r_filter_rx_start_addr <= cfg_data_i[L2_AWIDTH_NOAL - 1:0];
					5'b01011: begin
						r_filter_rx_datasize <= cfg_data_i[1:0];
						r_filter_rx_mode <= cfg_data_i[9:8];
					end
					5'b01100: r_filter_rx_len0 <= cfg_data_i[15:0];
					5'b01101: r_filter_rx_len1 <= cfg_data_i[15:0];
					5'b01110: r_filter_rx_len2 <= cfg_data_i[15:0];
					5'b01111: begin
						r_au_use_signed <= cfg_data_i[0];
						r_au_bypass <= cfg_data_i[1];
						r_au_mode <= cfg_data_i[11:8];
						r_au_shift <= cfg_data_i[20:16];
					end
					5'b10000: r_au_reg0 <= cfg_data_i;
					5'b10001: r_au_reg1 <= cfg_data_i;
					5'b10010: r_bincu_threshold <= cfg_data_i;
					5'b10100: r_bincu_datasize <= cfg_data_i[1:0];
					5'b10011: begin
						r_bincu_counter <= cfg_data_i[TRANS_SIZE - 1:0];
						r_bincu_en_counter <= cfg_data_i[31];
					end
					5'b10110: r_filter_mode <= cfg_data_i[3:0];
					5'b11000:
						if (cfg_data_i[0])
							r_filter_done <= 1'b0;
				endcase
		end
	always @(*) begin
		cfg_data_o = 32'h00000000;
		case (s_rd_addr)
			5'b00000: cfg_data_o[L2_AWIDTH_NOAL - 1:0] = r_commit_filter_tx_start_addr[0+:L2_AWIDTH_NOAL];
			5'b00001: begin
				cfg_data_o[9:8] = r_commit_filter_tx_mode[0+:2];
				cfg_data_o[1:0] = r_commit_filter_tx_datasize[0+:2];
			end
			5'b00010: cfg_data_o[TRANS_SIZE - 1:0] = r_commit_filter_tx_len0[0+:TRANS_SIZE];
			5'b00011: cfg_data_o[TRANS_SIZE - 1:0] = r_commit_filter_tx_len1[0+:TRANS_SIZE];
			5'b00100: cfg_data_o[TRANS_SIZE - 1:0] = r_commit_filter_tx_len2[0+:TRANS_SIZE];
			5'b00101: cfg_data_o[L2_AWIDTH_NOAL - 1:0] = r_commit_filter_tx_start_addr[L2_AWIDTH_NOAL+:L2_AWIDTH_NOAL];
			5'b00110: begin
				cfg_data_o[1:0] = r_commit_filter_tx_datasize[2+:2];
				cfg_data_o[9:8] = r_commit_filter_tx_mode[2+:2];
			end
			5'b00111: cfg_data_o[TRANS_SIZE - 1:0] = r_commit_filter_tx_len0[TRANS_SIZE+:TRANS_SIZE];
			5'b01000: cfg_data_o[TRANS_SIZE - 1:0] = r_commit_filter_tx_len1[TRANS_SIZE+:TRANS_SIZE];
			5'b01001: cfg_data_o[TRANS_SIZE - 1:0] = r_commit_filter_tx_len2[TRANS_SIZE+:TRANS_SIZE];
			5'b01010: cfg_data_o[L2_AWIDTH_NOAL - 1:0] = r_commit_filter_rx_start_addr[1];
			5'b01011: begin
				cfg_data_o[1:0] = r_commit_filter_rx_datasize[1];
				cfg_data_o[9:8] = r_commit_filter_rx_mode[1];
			end
			5'b01100: cfg_data_o[15:0] = r_commit_filter_rx_len0[1];
			5'b01101: cfg_data_o[15:0] = r_commit_filter_rx_len1[1];
			5'b01110: cfg_data_o[15:0] = r_commit_filter_rx_len2[1];
			5'b01111: begin
				cfg_data_o[0] = r_commit_au_use_signed;
				cfg_data_o[1] = r_commit_au_bypass;
				cfg_data_o[11:8] = r_commit_au_mode;
				cfg_data_o[20:16] = r_commit_au_shift;
			end
			5'b10000: cfg_data_o = r_commit_au_reg0;
			5'b10001: cfg_data_o = r_commit_au_reg1;
			5'b10010: cfg_data_o = r_commit_bincu_threshold;
			5'b10100: cfg_data_o[1:0] = r_commit_bincu_datasize;
			5'b10101: cfg_data_o[TRANS_SIZE - 1:0] = bincu_counter_i;
			5'b10011: begin
				cfg_data_o[TRANS_SIZE - 1:0] = r_commit_bincu_counter;
				cfg_data_o[31] = r_commit_bincu_en_counter;
			end
			5'b10110: cfg_data_o[3:0] = r_commit_filter_mode;
			5'b11000: cfg_data_o[0] = r_filter_done;
			default: cfg_data_o = 'h0;
		endcase
	end
	assign cfg_ready_o = 1'b1;
endmodule
