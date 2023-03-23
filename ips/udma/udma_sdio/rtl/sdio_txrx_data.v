module sdio_txrx_data (
	clk_i,
	rstn_i,
	clr_stat_i,
	status_o,
	busy_o,
	sdclk_en_o,
	data_start_i,
	data_block_size_i,
	data_block_num_i,
	data_rwn_i,
	data_quad_i,
	data_last_o,
	eot_o,
	in_data_if_data_i,
	in_data_if_valid_i,
	in_data_if_ready_o,
	out_data_if_data_o,
	out_data_if_valid_o,
	out_data_if_ready_i,
	sddata_o,
	sddata_i,
	sddata_oen_o
);
	input wire clk_i;
	input wire rstn_i;
	input wire clr_stat_i;
	output wire [5:0] status_o;
	output wire busy_o;
	output wire sdclk_en_o;
	input wire data_start_i;
	input wire [9:0] data_block_size_i;
	input wire [7:0] data_block_num_i;
	input wire data_rwn_i;
	input wire data_quad_i;
	output wire data_last_o;
	output wire eot_o;
	input wire [31:0] in_data_if_data_i;
	input wire in_data_if_valid_i;
	output wire in_data_if_ready_o;
	output wire [31:0] out_data_if_data_o;
	output wire out_data_if_valid_o;
	input wire out_data_if_ready_i;
	output wire [3:0] sddata_o;
	input wire [3:0] sddata_i;
	output wire [3:0] sddata_oen_o;
	localparam STATUS_RSP_TIMEOUT = 6'h01;
	localparam RSP_TYPE_NULL = 3'b000;
	localparam RSP_TYPE_48_CRC = 3'b001;
	localparam RSP_TYPE_48_NOCRC = 3'b010;
	localparam RSP_TYPE_136 = 3'b011;
	localparam RSP_TYPE_48_BSY = 3'b100;
	reg [4:0] s_state;
	reg [4:0] r_state;
	wire [63:0] s_crc;
	wire [3:0] s_crc_block_en;
	wire [3:0] s_crc_block_clr;
	wire [3:0] s_crc_block_shift;
	wire [3:0] s_crc_in;
	wire [3:0] s_crc_out;
	reg s_crc_en;
	reg s_crc_clr;
	reg s_crc_shift;
	reg s_crc_intx;
	reg [31:0] r_data;
	reg s_eot;
	reg [3:0] r_sddata;
	reg [3:0] s_sddata;
	reg s_sddata_oen;
	reg s_shift_data;
	reg s_cnt_start;
	wire s_cnt_done;
	reg [8:0] s_cnt_target;
	reg [8:0] r_cnt;
	reg r_cnt_running;
	reg [5:0] s_status;
	reg [5:0] r_status;
	reg s_status_sample;
	reg [2:0] r_bit_cnt;
	wire [2:0] s_bit_cnt_target;
	reg [7:0] r_cnt_block;
	reg [7:0] s_cnt_block;
	reg s_cnt_block_upd;
	wire s_cnt_block_done;
	wire s_cnt_byte_evnt;
	reg s_cnt_byte;
	reg r_cnt_byte;
	reg [1:0] r_byte_in_word;
	reg [3:0] s_dataout;
	reg [31:0] s_datain;
	reg s_busy;
	reg s_in_data_ready;
	wire s_lastbitofword;
	reg s_clk_en;
	reg s_rx_en;
	reg s_out_data_valid;
	assign s_crc_in = (s_crc_intx ? sddata_i : s_sddata);
	assign s_crc_block_en[0] = s_crc_en;
	assign s_crc_block_en[1] = data_quad_i & s_crc_en;
	assign s_crc_block_en[2] = data_quad_i & s_crc_en;
	assign s_crc_block_en[3] = data_quad_i & s_crc_en;
	assign s_crc_block_clr[0] = s_crc_clr;
	assign s_crc_block_clr[1] = data_quad_i & s_crc_clr;
	assign s_crc_block_clr[2] = data_quad_i & s_crc_clr;
	assign s_crc_block_clr[3] = data_quad_i & s_crc_clr;
	assign s_crc_block_shift[0] = s_crc_shift;
	assign s_crc_block_shift[1] = data_quad_i & s_crc_shift;
	assign s_crc_block_shift[2] = data_quad_i & s_crc_shift;
	assign s_crc_block_shift[3] = data_quad_i & s_crc_shift;
	assign sddata_o = r_sddata;
	assign sddata_oen_o[0] = s_sddata_oen;
	assign sddata_oen_o[1] = (data_quad_i ? s_sddata_oen : 1'b1);
	assign sddata_oen_o[2] = (data_quad_i ? s_sddata_oen : 1'b1);
	assign sddata_oen_o[3] = (data_quad_i ? s_sddata_oen : 1'b1);
	assign data_last_o = s_busy & s_cnt_block_done;
	assign busy_o = s_busy;
	assign sdclk_en_o = s_clk_en;
	assign in_data_if_ready_o = s_in_data_ready;
	assign out_data_if_valid_o = s_out_data_valid;
	assign out_data_if_data_o = s_datain;
	assign eot_o = s_eot;
	assign status_o = r_status;
	genvar i;
	generate
		for (i = 0; i < 4; i = i + 1) begin : genblk1
			sdio_crc16 i_data_crc(
				.clk_i(clk_i),
				.rstn_i(rstn_i),
				.crc16_o(s_crc[i * 16+:16]),
				.crc16_serial_o(s_crc_out[i]),
				.data_i(s_crc_in[i]),
				.shift_i(s_crc_block_shift[i]),
				.clr_i(s_crc_block_clr[i]),
				.sample_i(s_crc_block_en[i])
			);
		end
	endgenerate
	always @(*) begin : proc_data_in
		s_datain = r_data;
		if (data_quad_i)
			case (r_byte_in_word)
				0:
					if (r_bit_cnt == 0)
						s_datain[7:4] = sddata_i;
					else
						s_datain[3:0] = sddata_i;
				1:
					if (r_bit_cnt == 0)
						s_datain[15:12] = sddata_i;
					else
						s_datain[11:8] = sddata_i;
				2:
					if (r_bit_cnt == 0)
						s_datain[23:20] = sddata_i;
					else
						s_datain[19:16] = sddata_i;
				3:
					if (r_bit_cnt == 0)
						s_datain[31:28] = sddata_i;
					else
						s_datain[27:24] = sddata_i;
			endcase
		else
			case (r_byte_in_word)
				0:
					case (r_bit_cnt)
						0: s_datain[7] = sddata_i[0];
						1: s_datain[6] = sddata_i[0];
						2: s_datain[5] = sddata_i[0];
						3: s_datain[4] = sddata_i[0];
						4: s_datain[3] = sddata_i[0];
						5: s_datain[2] = sddata_i[0];
						6: s_datain[1] = sddata_i[0];
						7: s_datain[0] = sddata_i[0];
					endcase
				1:
					case (r_bit_cnt)
						0: s_datain[15] = sddata_i[0];
						1: s_datain[14] = sddata_i[0];
						2: s_datain[13] = sddata_i[0];
						3: s_datain[12] = sddata_i[0];
						4: s_datain[11] = sddata_i[0];
						5: s_datain[10] = sddata_i[0];
						6: s_datain[9] = sddata_i[0];
						7: s_datain[8] = sddata_i[0];
					endcase
				2:
					case (r_bit_cnt)
						0: s_datain[23] = sddata_i[0];
						1: s_datain[22] = sddata_i[0];
						2: s_datain[21] = sddata_i[0];
						3: s_datain[20] = sddata_i[0];
						4: s_datain[19] = sddata_i[0];
						5: s_datain[18] = sddata_i[0];
						6: s_datain[17] = sddata_i[0];
						7: s_datain[16] = sddata_i[0];
					endcase
				3:
					case (r_bit_cnt)
						0: s_datain[31] = sddata_i[0];
						1: s_datain[30] = sddata_i[0];
						2: s_datain[29] = sddata_i[0];
						3: s_datain[28] = sddata_i[0];
						4: s_datain[27] = sddata_i[0];
						5: s_datain[26] = sddata_i[0];
						6: s_datain[25] = sddata_i[0];
						7: s_datain[24] = sddata_i[0];
					endcase
			endcase
	end
	always @(*) begin : proc_data_out
		s_dataout = 4'b0000;
		if (data_quad_i)
			case (r_byte_in_word)
				0: s_dataout = (r_bit_cnt == 0 ? r_data[7:4] : r_data[3:0]);
				1: s_dataout = (r_bit_cnt == 0 ? r_data[15:12] : r_data[11:8]);
				2: s_dataout = (r_bit_cnt == 0 ? r_data[23:20] : r_data[19:16]);
				3: s_dataout = (r_bit_cnt == 0 ? r_data[31:28] : r_data[27:24]);
			endcase
		else
			case (r_byte_in_word)
				0:
					case (r_bit_cnt)
						0: s_dataout[0] = r_data[7];
						1: s_dataout[0] = r_data[6];
						2: s_dataout[0] = r_data[5];
						3: s_dataout[0] = r_data[4];
						4: s_dataout[0] = r_data[3];
						5: s_dataout[0] = r_data[2];
						6: s_dataout[0] = r_data[1];
						7: s_dataout[0] = r_data[0];
					endcase
				1:
					case (r_bit_cnt)
						0: s_dataout[0] = r_data[15];
						1: s_dataout[0] = r_data[14];
						2: s_dataout[0] = r_data[13];
						3: s_dataout[0] = r_data[12];
						4: s_dataout[0] = r_data[11];
						5: s_dataout[0] = r_data[10];
						6: s_dataout[0] = r_data[9];
						7: s_dataout[0] = r_data[8];
					endcase
				2:
					case (r_bit_cnt)
						0: s_dataout[0] = r_data[23];
						1: s_dataout[0] = r_data[22];
						2: s_dataout[0] = r_data[21];
						3: s_dataout[0] = r_data[20];
						4: s_dataout[0] = r_data[19];
						5: s_dataout[0] = r_data[18];
						6: s_dataout[0] = r_data[17];
						7: s_dataout[0] = r_data[16];
					endcase
				3:
					case (r_bit_cnt)
						0: s_dataout[0] = r_data[31];
						1: s_dataout[0] = r_data[30];
						2: s_dataout[0] = r_data[29];
						3: s_dataout[0] = r_data[28];
						4: s_dataout[0] = r_data[27];
						5: s_dataout[0] = r_data[26];
						6: s_dataout[0] = r_data[25];
						7: s_dataout[0] = r_data[24];
					endcase
			endcase
	end
	always @(*) begin
		s_sddata = 4'b0000;
		s_sddata_oen = 1'b1;
		s_state = r_state;
		s_shift_data = 1'b0;
		s_crc_shift = 1'b0;
		s_crc_en = 1'b1;
		s_crc_clr = 1'b0;
		s_crc_intx = 1'b0;
		s_cnt_start = 1'b0;
		s_cnt_target = 9'h000;
		s_cnt_byte = 1'b0;
		s_status = 'h0;
		s_status_sample = 1'b0;
		s_busy = 1'b1;
		s_clk_en = 1'b1;
		s_rx_en = 1'b0;
		s_eot = 1'b0;
		s_cnt_block_upd = 1'b0;
		s_cnt_block = r_cnt_block;
		s_in_data_ready = 1'b0;
		s_out_data_valid = 1'b0;
		case (r_state)
			5'd0: begin
				s_busy = 1'b0;
				s_clk_en = 1'b0;
				if (data_start_i) begin
					s_status_sample = 1'b1;
					s_clk_en = 1'b1;
					s_cnt_block_upd = 1'b1;
					s_cnt_block = data_block_num_i;
					if (data_rwn_i)
						s_state = 5'd9;
					else
						s_state = 5'd2;
				end
			end
			5'd2: begin
				s_sddata = 4'b0000;
				s_sddata_oen = 1'b1;
				s_state = 5'd4;
				s_cnt_start = 1'b1;
				s_cnt_byte = 1'b1;
				s_cnt_target = data_block_size_i;
				s_in_data_ready = 1'b1;
			end
			5'd4: begin
				s_in_data_ready = s_lastbitofword;
				s_sddata = s_dataout;
				s_sddata_oen = 1'b0;
				s_shift_data = 1'b1;
				s_crc_en = 1'b1;
				if (s_cnt_done) begin
					s_in_data_ready = 1'b0;
					s_state = 5'd5;
					s_cnt_start = 1'b1;
					s_cnt_target = 8'd15;
				end
			end
			5'd5: begin
				s_sddata = s_crc_out;
				s_sddata_oen = 1'b0;
				s_crc_shift = 1'b1;
				s_crc_en = 1'b0;
				if (s_cnt_done)
					s_state = 5'd6;
			end
			5'd6: begin
				s_sddata = 4'hf;
				s_sddata_oen = 1'b0;
				s_crc_shift = 1'b0;
				s_crc_en = 1'b0;
				s_state = 5'd7;
				s_cnt_start = 1'b1;
				s_cnt_target = 8'd7;
			end
			5'd7: begin
				s_sddata_oen = 1'b1;
				if (s_cnt_done) begin
					s_cnt_start = 1'b1;
					s_cnt_target = 9'h1ff;
					s_state = 5'd8;
				end
			end
			5'd8: begin
				s_sddata_oen = 1'b1;
				if (s_cnt_done)
					s_state = 5'd0;
				else if (sddata_i[0])
					if (s_cnt_block_done) begin
						s_eot = 1'b1;
						s_state = 5'd0;
					end
					else begin
						s_cnt_block_upd = 1'b1;
						s_cnt_block = r_cnt_block - 1;
						s_state = 5'd2;
					end
			end
			5'd9:
				if (!sddata_i[0]) begin
					s_cnt_start = 1'b1;
					s_cnt_byte = 1'b1;
					s_cnt_target = data_block_size_i;
					s_state = 5'd11;
				end
				else if (s_cnt_done) begin
					s_status = r_status | STATUS_RSP_TIMEOUT;
					s_status_sample = 1'b1;
					s_state = 5'd0;
				end
			5'd11: begin
				s_rx_en = 1'b1;
				s_out_data_valid = s_lastbitofword;
				s_crc_en = 1'b1;
				s_crc_intx = 1'b1;
				if (s_cnt_done) begin
					s_state = 5'd12;
					s_cnt_start = 1'b1;
					s_cnt_target = 8'd15;
				end
			end
			5'd12: begin
				s_out_data_valid = s_lastbitofword;
				s_crc_en = 1'b1;
				s_crc_intx = 1'b1;
				if (s_cnt_done)
					if (s_cnt_block_done) begin
						s_eot = 1'b1;
						s_state = 5'd0;
					end
					else begin
						s_cnt_block_upd = 1'b1;
						s_cnt_block = r_cnt_block - 1;
						s_state = 5'd9;
					end
			end
			5'd1:
				if (s_cnt_done) begin
					s_eot = 1'b1;
					s_state = 5'd0;
				end
		endcase
	end
	assign s_cnt_done = (r_cnt_byte ? (r_cnt == 0) && s_cnt_byte_evnt : r_cnt == 0);
	always @(posedge clk_i or negedge rstn_i) begin : proc_r_cnt
		if (~rstn_i) begin
			r_cnt <= 9'h1ff;
			r_cnt_running <= 0;
			r_cnt_byte <= 0;
			r_cnt_block <= 0;
			r_byte_in_word <= 0;
		end
		else begin
			if (s_cnt_block_upd)
				r_cnt_block <= s_cnt_block;
			if (s_cnt_start) begin
				r_cnt <= s_cnt_target;
				r_cnt_running <= 1'b1;
				r_byte_in_word <= 0;
				r_cnt_byte <= s_cnt_byte;
			end
			else if (s_cnt_done) begin
				r_cnt <= 9'h1ff;
				r_cnt_running <= 1'b0;
				r_cnt_byte <= 1'b0;
				r_byte_in_word <= 0;
			end
			else if (r_cnt_running && (!r_cnt_byte || s_cnt_byte_evnt)) begin
				r_cnt <= r_cnt - 1;
				if (r_cnt_byte)
					r_byte_in_word <= r_byte_in_word + 1;
			end
		end
	end
	assign s_lastbitofword = s_cnt_byte_evnt & (r_byte_in_word == 2'b11);
	assign s_cnt_block_done = r_cnt_block == 0;
	assign s_bit_cnt_target = (data_quad_i ? 3'h1 : 3'h7);
	assign s_cnt_byte_evnt = r_bit_cnt == s_bit_cnt_target;
	always @(posedge clk_i or negedge rstn_i) begin : proc_r_bit_cnt
		if (~rstn_i)
			r_bit_cnt <= 3'h0;
		else if (r_cnt_byte)
			if (s_cnt_byte_evnt)
				r_bit_cnt <= 3'h0;
			else
				r_bit_cnt <= r_bit_cnt + 1;
	end
	always @(posedge clk_i or negedge rstn_i)
		if (~rstn_i) begin
			r_state <= 5'd0;
			r_status <= 'h0;
			r_data <= 'h0;
		end
		else if (clr_stat_i) begin
			r_state <= 5'd0;
			r_status <= 'h0;
			r_data <= 'h0;
		end
		else begin
			r_state <= s_state;
			if (s_status_sample)
				r_status <= s_status;
			if (s_in_data_ready)
				r_data <= in_data_if_data_i;
			else if (s_rx_en)
				r_data <= s_datain;
		end
	always @(negedge clk_i or negedge rstn_i) begin : proc_sddata
		if (~rstn_i)
			r_sddata <= 4'h0;
		else
			r_sddata <= s_sddata;
	end
endmodule
