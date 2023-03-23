module udma_spim_txrx (
	clk_i,
	rstn_i,
	cfg_cpol_i,
	cfg_cpha_i,
	tx_start_i,
	tx_size_i,
	tx_qpi_i,
	tx_bitsword_i,
	tx_wordtransf_i,
	tx_lsbfirst_i,
	tx_done_o,
	tx_data_i,
	tx_data_valid_i,
	tx_data_ready_o,
	rx_start_i,
	rx_size_i,
	rx_qpi_i,
	rx_bitsword_i,
	rx_wordtransf_i,
	rx_lsbfirst_i,
	rx_done_o,
	rx_data_o,
	rx_data_valid_o,
	rx_data_ready_i,
	spi_clk_o,
	spi_oen0_o,
	spi_oen1_o,
	spi_oen2_o,
	spi_oen3_o,
	spi_sdo0_o,
	spi_sdo1_o,
	spi_sdo2_o,
	spi_sdo3_o,
	spi_sdi0_i,
	spi_sdi1_i,
	spi_sdi2_i,
	spi_sdi3_i
);
	input wire clk_i;
	input wire rstn_i;
	input wire cfg_cpol_i;
	input wire cfg_cpha_i;
	input wire tx_start_i;
	input wire [15:0] tx_size_i;
	input wire tx_qpi_i;
	input wire [4:0] tx_bitsword_i;
	input wire [1:0] tx_wordtransf_i;
	input wire tx_lsbfirst_i;
	output reg tx_done_o;
	input wire [31:0] tx_data_i;
	input wire tx_data_valid_i;
	output reg tx_data_ready_o;
	input wire rx_start_i;
	input wire [15:0] rx_size_i;
	input wire rx_qpi_i;
	input wire [4:0] rx_bitsword_i;
	input wire [1:0] rx_wordtransf_i;
	input wire rx_lsbfirst_i;
	output reg rx_done_o;
	output reg [31:0] rx_data_o;
	output reg rx_data_valid_o;
	input wire rx_data_ready_i;
	output wire spi_clk_o;
	output reg spi_oen0_o;
	output reg spi_oen1_o;
	output reg spi_oen2_o;
	output reg spi_oen3_o;
	output reg spi_sdo0_o;
	output reg spi_sdo1_o;
	output reg spi_sdo2_o;
	output reg spi_sdo3_o;
	input wire spi_sdi0_i;
	input wire spi_sdi1_i;
	input wire spi_sdi2_i;
	input wire spi_sdi3_i;
	reg [3:0] tx_state;
	reg [3:0] tx_state_next;
	reg [3:0] rx_state;
	reg [3:0] rx_state_next;
	reg [15:0] s_tx_counter_hi;
	reg [15:0] s_rx_counter_hi;
	reg [15:0] r_counter_hi;
	reg s_tx_sample_hi;
	reg s_rx_sample_hi;
	reg [31:0] s_tx_shift_reg;
	reg [31:0] r_tx_shift_reg;
	reg [31:0] s_rx_shift_reg;
	reg [31:0] r_rx_shift_reg;
	reg s_tx_clken;
	reg s_rx_clken;
	reg r_rx_clken;
	reg r_tx_is_last;
	reg r_rx_is_last;
	reg s_tx_is_last;
	reg s_rx_is_last;
	reg s_tx_sample_in;
	reg s_sample_rx_in;
	reg s_tx_driving;
	reg s_spi_sdo0;
	reg s_spi_sdo1;
	reg s_spi_sdo2;
	reg s_spi_sdo3;
	reg [1:0] s_tx_mode;
	reg [1:0] s_rx_mode;
	wire [1:0] s_spi_mode;
	reg [1:0] r_spi_mode;
	wire s_bits_done;
	reg s_rx_idle;
	reg s_tx_idle;
	wire s_is_ful;
	reg r_is_ful;
	wire s_spi_clk;
	wire s_spi_clk_inv;
	wire s_clken;
	reg r_lsbfirst;
	reg [4:0] r_bitsword;
	reg [1:0] r_wordtransf;
	reg [4:0] s_tx_counter_bits;
	reg [4:0] s_rx_counter_bits;
	reg [4:0] r_counter_bits;
	reg s_tx_sample_bits;
	reg s_rx_sample_bits;
	reg [1:0] s_tx_counter_transf;
	reg [1:0] s_rx_counter_transf;
	reg [1:0] r_counter_transf;
	reg s_tx_sample_transf;
	reg s_rx_sample_transf;
	wire s_spi_clk_cpha0;
	wire s_clk_inv;
	wire s_spi_clk_cpha1;
	reg [4:0] s_bit_index;
	reg [4:0] s_bit_offset_add;
	reg [4:0] r_bit_offset;
	reg [31:0] s_data_rx;
	wire s_transf_done;
	always @(*) begin : proc_spi_mode
		case (r_spi_mode)
			2'b11: begin
				spi_oen0_o = 1'b1;
				spi_oen1_o = 1'b1;
				spi_oen2_o = 1'b1;
				spi_oen3_o = 1'b1;
			end
			2'b10: begin
				spi_oen0_o = 1'b0;
				spi_oen1_o = 1'b0;
				spi_oen2_o = 1'b0;
				spi_oen3_o = 1'b0;
			end
			2'b00: begin
				spi_oen0_o = 1'b0;
				spi_oen1_o = 1'b1;
				spi_oen2_o = 1'b1;
				spi_oen3_o = 1'b1;
			end
			default: begin
				spi_oen0_o = 1'b1;
				spi_oen1_o = 1'b1;
				spi_oen2_o = 1'b1;
				spi_oen3_o = 1'b1;
			end
		endcase
	end
	always @(*) begin : proc_offset
		case (r_wordtransf)
			2'b00: s_bit_offset_add = 5'h00;
			2'b01: s_bit_offset_add = 5'h10;
			2'b10: s_bit_offset_add = 5'h08;
			2'b11: s_bit_offset_add = 5'h08;
		endcase
	end
	always @(*) begin : proc_index
		if (r_lsbfirst)
			s_bit_index = r_bit_offset + r_counter_bits;
		else
			s_bit_index = (r_bit_offset + r_bitsword) - r_counter_bits;
	end
	always @(*) begin : proc_outputs
		if (s_tx_idle) begin
			s_spi_sdo0 = 1'b0;
			s_spi_sdo1 = 1'b0;
			s_spi_sdo2 = 1'b0;
			s_spi_sdo3 = 1'b0;
		end
		else if (tx_qpi_i) begin
			if (r_lsbfirst) begin
				s_spi_sdo0 = r_tx_shift_reg[s_bit_index - 3];
				s_spi_sdo1 = r_tx_shift_reg[s_bit_index - 2];
				s_spi_sdo2 = r_tx_shift_reg[s_bit_index - 1];
				s_spi_sdo3 = r_tx_shift_reg[s_bit_index];
			end
			else begin
				s_spi_sdo0 = r_tx_shift_reg[s_bit_index];
				s_spi_sdo1 = r_tx_shift_reg[s_bit_index + 1];
				s_spi_sdo2 = r_tx_shift_reg[s_bit_index + 2];
				s_spi_sdo3 = r_tx_shift_reg[s_bit_index + 3];
			end
		end
		else begin
			s_spi_sdo0 = r_tx_shift_reg[s_bit_index];
			s_spi_sdo1 = 1'b0;
			s_spi_sdo2 = 1'b0;
			s_spi_sdo3 = 1'b0;
		end
	end
	always @(*) begin : proc_input
		s_data_rx = r_rx_shift_reg;
		if (rx_qpi_i) begin
			if (r_lsbfirst) begin
				s_data_rx[s_bit_index] = spi_sdi0_i;
				s_data_rx[s_bit_index + 1] = spi_sdi1_i;
				s_data_rx[s_bit_index + 2] = spi_sdi2_i;
				s_data_rx[s_bit_index + 3] = spi_sdi3_i;
			end
			else begin
				s_data_rx[s_bit_index] = spi_sdi0_i;
				s_data_rx[s_bit_index + 1] = spi_sdi1_i;
				s_data_rx[s_bit_index + 2] = spi_sdi2_i;
				s_data_rx[s_bit_index + 3] = spi_sdi3_i;
			end
		end
		else
			s_data_rx[s_bit_index] = spi_sdi1_i;
	end
	assign s_clken = (s_is_ful ? s_tx_clken : s_tx_clken | s_rx_clken);
	assign s_spi_mode = (s_tx_driving ? s_tx_mode : s_rx_mode);
	assign s_bits_done = r_counter_bits == r_bitsword;
	assign s_transf_done = r_counter_transf == r_wordtransf;
	assign s_is_ful = (tx_start_i & rx_start_i) | r_is_ful;
	pulp_clock_gating u_outclkgte_cpol(
		.clk_i(clk_i),
		.en_i(s_clken),
		.test_en_i(1'b0),
		.clk_o(s_spi_clk_cpha0)
	);
	pulp_clock_inverter u_clkinv_cpha(
		.clk_i(clk_i),
		.clk_o(s_clk_inv)
	);
	pulp_clock_gating u_outclkgte_cpha(
		.clk_i(s_clk_inv),
		.en_i(s_clken),
		.test_en_i(1'b0),
		.clk_o(s_spi_clk_cpha1)
	);
	pulp_clock_mux2 u_clockmux_cpha(
		.clk0_i(s_spi_clk_cpha0),
		.clk1_i(s_spi_clk_cpha1),
		.clk_sel_i(cfg_cpha_i),
		.clk_o(s_spi_clk)
	);
	pulp_clock_inverter u_clkinv_cpol(
		.clk_i(s_spi_clk),
		.clk_o(s_spi_clk_inv)
	);
	pulp_clock_mux2 u_clockmux_cpol(
		.clk0_i(s_spi_clk),
		.clk1_i(s_spi_clk_inv),
		.clk_sel_i(cfg_cpol_i),
		.clk_o(spi_clk_o)
	);
	always @(*) begin : proc_TX_SM
		tx_state_next = tx_state;
		tx_data_ready_o = 1'b0;
		tx_done_o = 1'b0;
		s_tx_clken = 1'b0;
		s_tx_sample_in = 1'b0;
		s_tx_shift_reg = r_tx_shift_reg;
		s_tx_driving = 1'b0;
		s_tx_mode = 2'b11;
		s_tx_idle = 1'b0;
		s_tx_is_last = r_tx_is_last;
		s_tx_counter_hi = r_counter_hi;
		s_tx_counter_bits = r_counter_bits;
		s_tx_counter_transf = r_counter_transf;
		s_tx_sample_hi = 1'b0;
		s_tx_sample_bits = 1'b0;
		s_tx_sample_transf = 1'b0;
		case (tx_state)
			4'd0:
				if (tx_start_i) begin
					s_tx_counter_bits = (tx_qpi_i ? 'h3 : 'h0);
					s_tx_sample_bits = 1'b1;
					if (tx_size_i == 0)
						s_tx_is_last = 1'b1;
					else
						s_tx_is_last = 1'b0;
					s_tx_driving = 1'b1;
					s_tx_sample_in = 1'b1;
					if (tx_data_valid_i) begin
						tx_data_ready_o = 1'b1;
						tx_state_next = 4'd1;
						s_tx_shift_reg = tx_data_i;
					end
					else
						tx_state_next = 4'd2;
				end
				else
					s_tx_idle = 1'b1;
			4'd1: begin
				s_tx_driving = 1'b1;
				s_tx_clken = 1'b1;
				s_tx_mode = (tx_qpi_i ? 2'b10 : 2'b00);
				s_tx_sample_bits = 1'b1;
				if (s_bits_done) begin
					if (tx_qpi_i)
						s_tx_counter_bits = 'h3;
					else
						s_tx_counter_bits = 'h0;
				end
				else if (tx_qpi_i)
					s_tx_counter_bits = r_counter_bits + 4;
				else
					s_tx_counter_bits = r_counter_bits + 1;
				if (s_bits_done) begin
					s_tx_sample_transf = 1'b1;
					if (s_transf_done)
						s_tx_counter_transf = 'h0;
					else
						s_tx_counter_transf = r_counter_transf + 1;
				end
				if (s_bits_done && (r_counter_hi == 0)) begin
					if (r_tx_is_last) begin
						s_tx_is_last = 1'b0;
						tx_done_o = 1'b1;
						if (tx_start_i) begin
							s_tx_sample_in = 1'b1;
							if (tx_data_valid_i) begin
								tx_data_ready_o = 1'b1;
								tx_state_next = 4'd1;
								s_tx_shift_reg = tx_data_i;
							end
							else
								tx_state_next = 4'd2;
						end
						else
							tx_state_next = 4'd0;
					end
					else begin
						s_tx_is_last = 1'b1;
						if (s_transf_done)
							if (tx_data_valid_i) begin
								tx_data_ready_o = 1'b1;
								tx_state_next = 4'd1;
								s_tx_shift_reg = tx_data_i;
							end
							else
								tx_state_next = 4'd2;
					end
				end
				else if (s_bits_done) begin
					s_tx_sample_hi = 1'b1;
					s_tx_counter_hi = r_counter_hi - 1;
					if (s_transf_done)
						if (tx_data_valid_i) begin
							tx_data_ready_o = 1'b1;
							tx_state_next = 4'd1;
							s_tx_shift_reg = tx_data_i;
						end
						else
							tx_state_next = 4'd2;
				end
			end
			4'd2: begin
				s_tx_driving = 1'b1;
				s_tx_mode = (tx_qpi_i ? 2'b10 : 2'b00);
				if (tx_data_valid_i) begin
					tx_data_ready_o = 1'b1;
					tx_state_next = 4'd1;
					s_tx_shift_reg = tx_data_i;
				end
			end
		endcase
	end
	always @(*) begin : proc_RX_SM
		rx_state_next = rx_state;
		s_rx_clken = 1'b0;
		rx_done_o = 1'b0;
		rx_data_o = 'h0;
		rx_data_valid_o = 1'b0;
		s_rx_mode = 2'b11;
		s_sample_rx_in = 1'b0;
		s_rx_counter_hi = r_counter_hi;
		s_rx_counter_bits = r_counter_bits;
		s_rx_counter_transf = r_counter_transf;
		s_rx_shift_reg = r_rx_shift_reg;
		s_rx_idle = 1'b0;
		s_rx_is_last = r_rx_is_last;
		s_rx_sample_hi = 1'b0;
		s_rx_sample_bits = 1'b0;
		s_rx_sample_transf = 1'b0;
		case (rx_state)
			4'd0:
				if (rx_start_i) begin
					s_rx_mode = (rx_qpi_i ? 2'b11 : 2'b00);
					s_sample_rx_in = 1'b1;
					rx_state_next = 4'd1;
					s_rx_shift_reg = r_rx_shift_reg;
					s_rx_counter_bits = (rx_qpi_i ? 'h3 : 'h0);
					s_rx_sample_bits = 1'b1;
					if (rx_size_i == 0)
						s_rx_is_last = 1'b1;
					else
						s_rx_is_last = 1'b0;
				end
				else
					s_rx_idle = 1'b1;
			4'd1: begin
				s_rx_mode = (rx_qpi_i ? 2'b11 : 2'b00);
				s_rx_clken = 1'b1;
				s_rx_sample_bits = 1'b1;
				s_rx_shift_reg = s_data_rx;
				if (!s_is_ful || (s_is_ful && s_tx_clken)) begin
					if (s_bits_done) begin
						if (rx_qpi_i)
							s_rx_counter_bits = 'h3;
						else
							s_rx_counter_bits = 'h0;
					end
					else if (rx_qpi_i)
						s_rx_counter_bits = r_counter_bits + 4;
					else
						s_rx_counter_bits = r_counter_bits + 1;
					if (r_rx_clken) begin
						if (s_bits_done) begin
							s_rx_sample_transf = 1'b1;
							if (r_counter_transf == r_wordtransf) begin
								rx_data_o = s_rx_shift_reg;
								rx_data_valid_o = 1'b1;
								s_rx_counter_transf = 0;
							end
							else
								s_rx_counter_transf = r_counter_transf + 1;
						end
						if (s_bits_done && (r_counter_hi == 0)) begin
							if (r_rx_is_last) begin
								s_rx_is_last = 1'b0;
								rx_done_o = 1'b1;
								if (rx_start_i) begin
									s_sample_rx_in = 1'b1;
									rx_state_next = 4'd1;
								end
								else
									rx_state_next = 4'd0;
							end
							else
								s_rx_is_last = 1'b1;
						end
						else if (s_bits_done) begin
							s_rx_sample_hi = 1'b1;
							s_rx_counter_hi = r_counter_hi - 1;
						end
					end
				end
			end
		endcase
	end
	always @(posedge clk_i or negedge rstn_i)
		if (rstn_i == 1'b0) begin
			rx_state <= 4'd0;
			tx_state <= 4'd0;
		end
		else begin
			rx_state <= rx_state_next;
			tx_state <= tx_state_next;
		end
	always @(posedge clk_i or negedge rstn_i)
		if (rstn_i == 1'b0) begin
			r_rx_is_last <= 1'b0;
			r_tx_is_last <= 1'b0;
		end
		else begin
			r_rx_is_last <= s_rx_is_last;
			r_tx_is_last <= s_tx_is_last;
		end
	always @(posedge clk_i or negedge rstn_i)
		if (rstn_i == 1'b0) begin
			r_tx_shift_reg <= 'h0;
			r_rx_shift_reg <= 'h0;
			r_counter_hi <= 'h0;
			r_counter_bits <= 'h0;
			r_counter_transf <= 'h0;
			r_rx_clken <= 1'b0;
			r_is_ful <= 1'b0;
			r_lsbfirst <= 1'b0;
			r_bitsword <= 'h0;
			r_wordtransf <= 'h0;
			r_bit_offset <= 'h0;
		end
		else begin
			r_rx_clken <= s_rx_clken;
			r_rx_shift_reg <= s_rx_shift_reg;
			r_tx_shift_reg <= s_tx_shift_reg;
			if (s_tx_sample_bits)
				r_counter_bits <= s_tx_counter_bits;
			else if (s_rx_sample_bits)
				r_counter_bits <= s_rx_counter_bits;
			if (s_tx_sample_transf)
				r_counter_transf <= s_tx_counter_transf;
			else if (s_rx_sample_transf)
				r_counter_transf <= s_rx_counter_transf;
			if (tx_start_i || rx_start_i)
				r_bit_offset <= 'h0;
			else if (s_tx_sample_transf || s_rx_sample_transf)
				r_bit_offset <= r_bit_offset + s_bit_offset_add;
			if (tx_start_i && rx_start_i)
				r_is_ful <= 1'b1;
			else if (s_tx_idle && s_rx_idle)
				r_is_ful <= 1'b0;
			if (s_tx_sample_in) begin
				r_lsbfirst <= tx_lsbfirst_i;
				r_wordtransf <= tx_wordtransf_i;
				r_bitsword <= tx_bitsword_i;
			end
			else if (s_sample_rx_in) begin
				r_lsbfirst <= rx_lsbfirst_i;
				r_wordtransf <= rx_wordtransf_i;
				r_bitsword <= rx_bitsword_i;
			end
			if (s_tx_sample_in) begin
				if (tx_size_i == 0)
					r_counter_hi <= 'h0;
				else
					r_counter_hi <= tx_size_i - 1;
			end
			else if (s_sample_rx_in) begin
				if (rx_size_i == 0)
					r_counter_hi <= 'h0;
				else
					r_counter_hi <= rx_size_i - 1;
			end
			else if (s_tx_sample_hi)
				r_counter_hi <= s_tx_counter_hi;
			else if (s_rx_sample_hi)
				r_counter_hi <= s_rx_counter_hi;
		end
	always @(negedge clk_i or negedge rstn_i)
		if (rstn_i == 1'b0) begin
			spi_sdo0_o <= 1'b0;
			spi_sdo1_o <= 1'b0;
			spi_sdo2_o <= 1'b0;
			spi_sdo3_o <= 1'b0;
			r_spi_mode <= 2'b00;
		end
		else begin
			spi_sdo0_o <= s_spi_sdo0;
			if (tx_qpi_i) begin
				spi_sdo1_o <= s_spi_sdo1;
				spi_sdo2_o <= s_spi_sdo2;
				spi_sdo3_o <= s_spi_sdo3;
			end
			r_spi_mode <= s_spi_mode;
		end
endmodule
