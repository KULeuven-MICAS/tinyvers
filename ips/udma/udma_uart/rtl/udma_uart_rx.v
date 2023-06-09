module udma_uart_rx (
	clk_i,
	rstn_i,
	rx_i,
	cfg_div_i,
	cfg_en_i,
	cfg_parity_en_i,
	cfg_bits_i,
	cfg_stop_bits_i,
	busy_o,
	err_parity_o,
	err_overflow_o,
	char_event_o,
	rx_data_o,
	rx_valid_o,
	rx_ready_i
);
	input wire clk_i;
	input wire rstn_i;
	input wire rx_i;
	input wire [15:0] cfg_div_i;
	input wire cfg_en_i;
	input wire cfg_parity_en_i;
	input wire [1:0] cfg_bits_i;
	input wire cfg_stop_bits_i;
	output wire busy_o;
	output reg err_parity_o;
	output reg err_overflow_o;
	output reg char_event_o;
	output wire [7:0] rx_data_o;
	output reg rx_valid_o;
	input wire rx_ready_i;
	reg [2:0] CS;
	reg [2:0] NS;
	reg [7:0] reg_data;
	reg [7:0] reg_data_next;
	reg [2:0] reg_rx_sync;
	reg [2:0] reg_bit_count;
	reg [2:0] reg_bit_count_next;
	reg [2:0] s_target_bits;
	reg parity_bit;
	reg parity_bit_next;
	reg s_sample_data;
	reg [15:0] baud_cnt;
	reg baudgen_en;
	reg bit_done;
	reg start_bit;
	wire s_rx_fall;
	reg s_set_error_parity;
	reg r_error_parity;
	reg s_err_clear;
	assign busy_o = CS != 3'd0;
	always @(*)
		case (cfg_bits_i)
			2'b00: s_target_bits = 3'h4;
			2'b01: s_target_bits = 3'h5;
			2'b10: s_target_bits = 3'h6;
			2'b11: s_target_bits = 3'h7;
		endcase
	always @(*) begin
		NS = CS;
		s_sample_data = 1'b0;
		reg_bit_count_next = reg_bit_count;
		reg_data_next = reg_data;
		rx_valid_o = 1'b0;
		baudgen_en = 1'b0;
		start_bit = 1'b0;
		parity_bit_next = parity_bit;
		err_parity_o = 1'b0;
		err_overflow_o = 1'b0;
		char_event_o = 1'b0;
		s_set_error_parity = 1'b0;
		s_err_clear = 1'b0;
		case (CS)
			3'd0:
				if (s_rx_fall) begin
					NS = 3'd1;
					baudgen_en = 1'b1;
					start_bit = 1'b1;
					s_err_clear = 1'b1;
				end
			3'd1: begin
				parity_bit_next = 1'b0;
				baudgen_en = 1'b1;
				start_bit = 1'b1;
				if (bit_done)
					NS = 3'd2;
			end
			3'd2: begin
				baudgen_en = 1'b1;
				parity_bit_next = parity_bit ^ reg_rx_sync[2];
				case (cfg_bits_i)
					2'b00: reg_data_next = {3'b000, reg_rx_sync[2], reg_data[4:1]};
					2'b01: reg_data_next = {2'b00, reg_rx_sync[2], reg_data[5:1]};
					2'b10: reg_data_next = {1'b0, reg_rx_sync[2], reg_data[6:1]};
					2'b11: reg_data_next = {reg_rx_sync[2], reg_data[7:1]};
				endcase
				if (bit_done) begin
					s_sample_data = 1'b1;
					if (reg_bit_count == s_target_bits) begin
						reg_bit_count_next = 'h0;
						if (cfg_parity_en_i)
							NS = 3'd3;
						else
							NS = 3'd4;
					end
					else
						reg_bit_count_next = reg_bit_count + 1;
				end
			end
			3'd3: begin
				baudgen_en = 1'b1;
				if (bit_done) begin
					if (parity_bit != reg_rx_sync[2])
						s_set_error_parity = 1'b1;
					NS = 3'd4;
				end
			end
			3'd4: begin
				baudgen_en = 1'b1;
				if (bit_done) begin
					NS = 3'd0;
					if (!r_error_parity) begin
						rx_valid_o = 1'b1;
						if (!rx_ready_i)
							err_overflow_o = 1'b1;
						else
							char_event_o = 1'b1;
					end
					else
						err_parity_o = 1'b1;
				end
			end
			default: NS = 3'd0;
		endcase
	end
	always @(posedge clk_i or negedge rstn_i)
		if (rstn_i == 1'b0) begin
			CS <= 3'd0;
			reg_data <= 8'hff;
			reg_bit_count <= 'h0;
			parity_bit <= 1'b0;
		end
		else begin
			if (bit_done)
				parity_bit <= parity_bit_next;
			if (s_sample_data)
				reg_data <= reg_data_next;
			reg_bit_count <= reg_bit_count_next;
			if (cfg_en_i)
				CS <= NS;
			else
				CS <= 3'd0;
		end
	assign s_rx_fall = ~reg_rx_sync[1] & reg_rx_sync[2];
	always @(posedge clk_i or negedge rstn_i)
		if (rstn_i == 1'b0)
			reg_rx_sync <= 3'b111;
		else if (cfg_en_i)
			reg_rx_sync <= {reg_rx_sync[1:0], rx_i};
		else
			reg_rx_sync <= 3'b111;
	always @(posedge clk_i or negedge rstn_i)
		if (rstn_i == 1'b0) begin
			baud_cnt <= 'h0;
			bit_done <= 1'b0;
		end
		else if (baudgen_en) begin
			if (!start_bit && (baud_cnt == cfg_div_i)) begin
				baud_cnt <= 'h0;
				bit_done <= 1'b1;
			end
			else if (start_bit && (baud_cnt == {1'b0, cfg_div_i[15:1]})) begin
				baud_cnt <= 'h0;
				bit_done <= 1'b1;
			end
			else begin
				baud_cnt <= baud_cnt + 1;
				bit_done <= 1'b0;
			end
		end
		else begin
			baud_cnt <= 'h0;
			bit_done <= 1'b0;
		end
	always @(posedge clk_i or negedge rstn_i)
		if (rstn_i == 1'b0)
			r_error_parity <= 1'b0;
		else if (s_err_clear)
			r_error_parity <= 1'b0;
		else if (s_set_error_parity)
			r_error_parity <= 1'b1;
	assign rx_data_o = reg_data;
endmodule
