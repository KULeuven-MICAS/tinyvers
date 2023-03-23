module udma_spim_ctrl (
	clk_i,
	rstn_i,
	eot_o,
	event_i,
	cfg_cpol_o,
	cfg_cpha_o,
	cfg_clkdiv_data_o,
	cfg_clkdiv_valid_o,
	cfg_clkdiv_ack_i,
	tx_start_o,
	tx_size_o,
	tx_bitsword_o,
	tx_wordtransf_o,
	tx_lsbfirst_o,
	tx_qpi_o,
	tx_done_i,
	tx_data_o,
	tx_data_valid_o,
	tx_data_ready_i,
	rx_start_o,
	rx_size_o,
	rx_bitsword_o,
	rx_wordtransf_o,
	rx_lsbfirst_o,
	rx_qpi_o,
	rx_done_i,
	rx_data_i,
	rx_data_valid_i,
	rx_data_ready_o,
	udma_cmd_i,
	udma_cmd_valid_i,
	udma_cmd_ready_o,
	udma_tx_data_i,
	udma_tx_data_valid_i,
	udma_tx_data_ready_o,
	udma_rx_data_o,
	udma_rx_data_valid_o,
	udma_rx_data_ready_i,
	spi_csn0_o,
	spi_csn1_o,
	spi_csn2_o,
	spi_csn3_o,
	status_o
);
	parameter REPLAY_BUFFER_DEPTH = 5;
	input wire clk_i;
	input wire rstn_i;
	output reg eot_o;
	input wire [3:0] event_i;
	output wire cfg_cpol_o;
	output wire cfg_cpha_o;
	output wire [7:0] cfg_clkdiv_data_o;
	output wire cfg_clkdiv_valid_o;
	input wire cfg_clkdiv_ack_i;
	output reg tx_start_o;
	output reg [15:0] tx_size_o;
	output reg [4:0] tx_bitsword_o;
	output reg [1:0] tx_wordtransf_o;
	output reg tx_lsbfirst_o;
	output reg tx_qpi_o;
	input wire tx_done_i;
	output reg [31:0] tx_data_o;
	output reg tx_data_valid_o;
	input wire tx_data_ready_i;
	output reg rx_start_o;
	output reg [15:0] rx_size_o;
	output reg [4:0] rx_bitsword_o;
	output reg [1:0] rx_wordtransf_o;
	output reg rx_lsbfirst_o;
	output reg rx_qpi_o;
	input wire rx_done_i;
	input wire [31:0] rx_data_i;
	input wire rx_data_valid_i;
	output reg rx_data_ready_o;
	input wire [31:0] udma_cmd_i;
	input wire udma_cmd_valid_i;
	output reg udma_cmd_ready_o;
	input wire [31:0] udma_tx_data_i;
	input wire udma_tx_data_valid_i;
	output reg udma_tx_data_ready_o;
	output reg [31:0] udma_rx_data_o;
	output reg udma_rx_data_valid_o;
	input wire udma_rx_data_ready_i;
	output reg spi_csn0_o;
	output reg spi_csn1_o;
	output reg spi_csn2_o;
	output reg spi_csn3_o;
	output wire [1:0] status_o;
	reg [2:0] state;
	reg [2:0] state_next;
	reg [1:0] s_status;
	reg [1:0] r_status;
	reg r_cfg_cpol;
	reg r_cfg_cpha;
	reg [7:0] r_cfg_clkdiv;
	reg s_update_cfg;
	reg r_update_cfg;
	reg s_update_qpi;
	reg s_update_cs;
	reg s_update_evt;
	reg s_update_chk;
	reg s_clear_cs;
	reg s_event;
	reg [1:0] r_evt_sel;
	wire [3:0] s_cmd;
	reg is_cmd_cfg;
	reg is_cmd_sot;
	reg is_cmd_snc;
	reg is_cmd_dum;
	reg is_cmd_wai;
	reg is_cmd_txd;
	reg is_cmd_rxd;
	reg is_cmd_rxc;
	reg is_cmd_rpt;
	reg is_cmd_rpe;
	reg is_cmd_eot;
	reg is_cmd_ful;
	wire is_cmd_wcy;
	reg is_cmd_uca;
	reg is_cmd_ucs;
	wire s_cd_cfg_cpol;
	wire s_cd_cfg_cpha;
	wire [7:0] s_cd_cfg_clkdiv;
	wire s_cd_cfg_lsb;
	wire s_cd_cfg_qpi;
	wire [1:0] s_cd_cs;
	wire [15:0] s_cd_cfg_check;
	wire [15:0] s_cd_size_long;
	wire [15:0] s_cd_cmd_data;
	wire [4:0] s_cd_size;
	wire s_cd_eot_evt;
	wire s_cd_eot_keep_cs;
	wire [1:0] s_cd_cfg_chk_type;
	wire [7:0] s_cd_cs_wait;
	wire [1:0] s_cd_wait_typ;
	wire [1:0] s_cd_wait_evt;
	wire [7:0] s_cd_wait_cyc;
	wire [1:0] s_cs;
	reg s_qpi;
	reg r_qpi;
	reg [15:0] r_chk;
	reg [1:0] r_chk_type;
	reg s_is_dummy;
	reg r_is_dummy;
	reg [15:0] r_rpt_num;
	reg [15:0] s_rpt_num;
	reg s_setup_replay;
	reg s_is_replay;
	reg s_is_ful;
	reg r_is_ful;
	wire s_done;
	reg r_tx_done;
	reg r_rx_done;
	reg s_update_chk_result;
	reg s_chk_result;
	reg r_chk_result;
	reg s_update_status;
	wire [32:0] s_replay_buffer_out;
	reg s_replay_buffer_out_ready;
	wire s_replay_buffer_out_valid;
	wire [32:0] s_replay_buffer_in;
	wire s_replay_buffer_in_ready;
	wire s_replay_buffer_in_valid;
	reg s_update_rpt;
	reg r_is_replay;
	reg s_clr_rpt_buf;
	wire s_first_replay;
	reg r_first_replay;
	reg s_set_first_reply;
	reg s_clr_first_reply;
	reg [1:0] s_wordstransf;
	wire [1:0] s_cd_wordstransf;
	wire [4:0] s_cd_wordsize;
	assign s_cmd = (r_is_replay ? s_replay_buffer_out[31:28] : udma_cmd_i[31:28]);
	assign s_cd_cfg_cpol = (r_is_replay ? s_replay_buffer_out[9] : udma_cmd_i[9]);
	assign s_cd_cfg_cpha = (r_is_replay ? s_replay_buffer_out[8] : udma_cmd_i[8]);
	assign s_cd_cfg_clkdiv = (r_is_replay ? s_replay_buffer_out[7:0] : udma_cmd_i[7:0]);
	assign s_cd_cs = (r_is_replay ? s_replay_buffer_out[1:0] : udma_cmd_i[1:0]);
	assign s_cd_cs_wait = (r_is_replay ? s_replay_buffer_out[15:8] : udma_cmd_i[15:8]);
	assign s_cd_cfg_qpi = (r_is_replay ? s_replay_buffer_out[27] : udma_cmd_i[27]);
	assign s_cd_cfg_lsb = (r_is_replay ? s_replay_buffer_out[26] : udma_cmd_i[26]);
	assign s_cd_wordstransf = (r_is_replay ? s_replay_buffer_out[22:21] : udma_cmd_i[22:21]);
	assign s_cd_wordsize = (r_is_replay ? s_replay_buffer_out[20:16] : udma_cmd_i[20:16]);
	assign s_cd_size_long = (r_is_replay ? s_replay_buffer_out[15:0] : udma_cmd_i[15:0]);
	assign s_cd_cmd_data = (r_is_replay ? s_replay_buffer_out[15:0] : udma_cmd_i[15:0]);
	assign s_cd_eot_evt = (r_is_replay ? s_replay_buffer_out[0] : udma_cmd_i[0]);
	assign s_cd_eot_keep_cs = (r_is_replay ? s_replay_buffer_out[1] : udma_cmd_i[1]);
	assign s_cd_cfg_check = (r_is_replay ? s_replay_buffer_out[15:0] : udma_cmd_i[15:0]);
	assign s_cd_cfg_chk_type = (r_is_replay ? s_replay_buffer_out[25:24] : udma_cmd_i[25:24]);
	assign s_cd_wait_evt = (r_is_replay ? s_replay_buffer_out[1:0] : udma_cmd_i[1:0]);
	assign s_cd_wait_cyc = (r_is_replay ? s_replay_buffer_out[7:0] : udma_cmd_i[7:0]);
	assign s_cd_wait_typ = (r_is_replay ? s_replay_buffer_out[9:8] : udma_cmd_i[9:8]);
	assign s_first_replay = s_replay_buffer_out[32];
	assign cfg_cpol_o = r_cfg_cpol;
	assign cfg_cpha_o = r_cfg_cpha;
	assign cfg_clkdiv_data_o = r_cfg_clkdiv;
	assign status_o = r_status;
	assign s_done = (r_is_ful ? (tx_done_i | r_tx_done) & (rx_done_i | r_rx_done) : tx_done_i | rx_done_i);
	always @(*) begin : proc_s_wordstransf
		case (s_cd_wordstransf)
			2'b00: s_wordstransf = 2'h0;
			2'b01: s_wordstransf = 2'h1;
			2'b10: s_wordstransf = 2'h3;
			default: s_wordstransf = 2'h0;
		endcase
	end
	edge_propagator_tx i_edgeprop(
		.clk_i(clk_i),
		.rstn_i(rstn_i),
		.valid_i(r_update_cfg),
		.ack_i(cfg_clkdiv_ack_i),
		.valid_o(cfg_clkdiv_valid_o)
	);
	reg [1:0] r_cnt_state;
	reg [1:0] s_cnt_state_next;
	reg s_cnt_done;
	reg s_cnt_start;
	reg s_cnt_update;
	reg [7:0] s_cnt_target;
	reg [7:0] r_cnt_target;
	reg [7:0] r_cnt;
	reg [7:0] s_cnt_next;
	io_generic_fifo #(
		.DATA_WIDTH(33),
		.BUFFER_DEPTH(REPLAY_BUFFER_DEPTH)
	) i_reply_buffer(
		.clk_i(clk_i),
		.rstn_i(rstn_i),
		.clr_i(s_clr_rpt_buf),
		.elements_o(),
		.data_o(s_replay_buffer_out),
		.valid_o(s_replay_buffer_out_valid),
		.ready_i(s_replay_buffer_out_ready),
		.data_i(s_replay_buffer_in),
		.valid_i(s_replay_buffer_in_valid),
		.ready_o(s_replay_buffer_in_ready)
	);
	assign s_replay_buffer_in = (r_is_replay ? s_replay_buffer_out : {r_first_replay, udma_cmd_i});
	assign s_replay_buffer_in_valid = (s_setup_replay ? udma_cmd_valid_i : r_is_replay & (s_replay_buffer_out_ready & s_replay_buffer_out_valid));
	always @(posedge clk_i or negedge rstn_i)
		if (~rstn_i) begin
			r_cnt_state <= 2'd0;
			r_cnt <= 'h0;
			r_cnt_target <= 'h0;
		end
		else begin
			if (s_cnt_start)
				r_cnt_target <= s_cnt_target;
			if (s_cnt_start || s_cnt_done)
				r_cnt_state <= s_cnt_state_next;
			if (s_cnt_update)
				r_cnt <= s_cnt_next;
		end
	always @(*) begin
		s_cnt_update = 1'b0;
		s_cnt_state_next = r_cnt_state;
		s_cnt_done = 1'b0;
		s_cnt_next = r_cnt;
		case (r_cnt_state)
			2'd0:
				if (s_cnt_start)
					s_cnt_state_next = 2'd1;
			2'd1: begin
				s_cnt_update = 1'b1;
				if (r_cnt_target == r_cnt) begin
					s_cnt_next = 'h0;
					s_cnt_done = 1'b1;
					if (~s_cnt_start)
						s_cnt_state_next = 2'd0;
				end
				else
					s_cnt_next = r_cnt + 1;
			end
		endcase
	end
	always @(*) begin
		is_cmd_cfg = 1'b0;
		is_cmd_sot = 1'b0;
		is_cmd_snc = 1'b0;
		is_cmd_dum = 1'b0;
		is_cmd_wai = 1'b0;
		is_cmd_txd = 1'b0;
		is_cmd_rxd = 1'b0;
		is_cmd_rxc = 1'b0;
		is_cmd_rpt = 1'b0;
		is_cmd_eot = 1'b0;
		is_cmd_rpe = 1'b0;
		is_cmd_ful = 1'b0;
		is_cmd_uca = 1'b0;
		is_cmd_ucs = 1'b0;
		case (s_cmd)
			4'b0000: is_cmd_cfg = 1'b1;
			4'b0001: is_cmd_sot = 1'b1;
			4'b0010: is_cmd_snc = 1'b1;
			4'b0100: is_cmd_dum = 1'b1;
			4'b0101: is_cmd_wai = 1'b1;
			4'b0110: is_cmd_txd = 1'b1;
			4'b0111: is_cmd_rxd = 1'b1;
			4'b1011: is_cmd_rxc = 1'b1;
			4'b1000: is_cmd_rpt = 1'b1;
			4'b1010: is_cmd_rpe = 1'b1;
			4'b1001: is_cmd_eot = 1'b1;
			4'b1100: is_cmd_ful = 1'b1;
			4'b1101: is_cmd_uca = 1'b1;
			4'b1110: is_cmd_ucs = 1'b1;
		endcase
	end
	always @(*) begin : proc_s_event
		s_event = 1'b0;
		begin : sv2v_autoblock_1
			reg signed [31:0] i;
			for (i = 0; i < 4; i = i + 1)
				if (r_evt_sel == i)
					s_event = event_i[i];
		end
	end
	always @(*) begin
		state_next = state;
		udma_tx_data_ready_o = 1'b0;
		udma_cmd_ready_o = 1'b0;
		udma_rx_data_o = 'h0;
		udma_rx_data_valid_o = 1'b0;
		rx_data_ready_o = 1'b0;
		s_update_chk = 1'b0;
		s_update_cfg = 1'b0;
		s_update_cs = 1'b0;
		s_update_qpi = 1'b0;
		s_update_evt = 1'b0;
		s_clear_cs = 1'b0;
		tx_size_o = 'h0;
		rx_size_o = 'h0;
		tx_qpi_o = r_qpi;
		rx_qpi_o = r_qpi;
		tx_start_o = 1'b0;
		rx_start_o = 1'b0;
		tx_data_o = 'h0;
		tx_data_valid_o = 1'b0;
		tx_wordtransf_o = 'h0;
		tx_bitsword_o = 'h0;
		tx_lsbfirst_o = 1'b0;
		rx_wordtransf_o = 'h0;
		rx_bitsword_o = 'h0;
		rx_lsbfirst_o = 1'b0;
		eot_o = 1'b0;
		s_is_dummy = r_is_dummy;
		s_qpi = r_qpi;
		s_is_ful = r_is_ful;
		s_update_chk_result = 1'b0;
		s_chk_result = 1'b0;
		s_is_replay = r_is_replay;
		s_setup_replay = 1'b0;
		s_rpt_num = r_rpt_num;
		s_update_rpt = 1'b0;
		s_clr_rpt_buf = 1'b0;
		s_cnt_start = 1'b0;
		s_cnt_target = 'h0;
		s_replay_buffer_out_ready = 1'b0;
		s_set_first_reply = 1'b0;
		s_clr_first_reply = 1'b0;
		s_update_status = 1'b0;
		s_status = r_status;
		case (state)
			3'd0: begin
				s_is_ful = 1'b0;
				if ((r_is_replay && s_replay_buffer_out_valid) || (!r_is_replay && udma_cmd_valid_i)) begin
					if (!s_is_replay)
						udma_cmd_ready_o = 1'b1;
					else begin
						s_replay_buffer_out_ready = 1'b1;
						if (((r_rpt_num == 0) && s_first_replay) || r_chk_result) begin
							s_update_status = 1'b1;
							if (r_chk_result)
								s_status = 2'd1;
							else
								s_status = 2'd2;
							s_update_chk_result = 1'b1;
							s_chk_result = 1'b0;
							s_is_replay = 1'b0;
						end
						else if (s_first_replay) begin
							s_update_rpt = 1'b1;
							s_rpt_num = r_rpt_num - 1;
						end
					end
					if (is_cmd_cfg) begin
						s_update_cfg = 1'b1;
						s_cnt_start = 1'b1;
						s_cnt_target = 8'h01;
						state_next = 3'd5;
					end
					else if (is_cmd_sot) begin
						s_update_cs = 1'b1;
						s_cnt_start = 1'b1;
						s_cnt_target = s_cd_wait_cyc;
						state_next = 3'd5;
					end
					else if (is_cmd_snc) begin
						s_update_qpi = 1'b1;
						tx_start_o = 1'b1;
						tx_qpi_o = s_cd_cfg_qpi;
						s_qpi = s_cd_cfg_qpi;
						tx_size_o = 'h0;
						tx_wordtransf_o = 'h0;
						tx_bitsword_o = s_cd_wordsize;
						tx_lsbfirst_o = 1'b0;
						state_next = 3'd1;
						tx_data_valid_o = 1'b1;
						tx_data_o = {16'h0000, s_cd_cmd_data};
					end
					else if (is_cmd_wai) begin
						if (s_cd_wait_typ == 2'b00) begin
							s_update_evt = 1'b1;
							state_next = 3'd3;
						end
						else if (s_cd_wait_typ == 2'b01) begin
							s_cnt_start = 1'b1;
							s_cnt_target = s_cd_wait_cyc;
							state_next = 3'd5;
						end
					end
					else if (is_cmd_dum) begin
						s_update_qpi = 1'b1;
						rx_start_o = 1'b1;
						rx_qpi_o = s_cd_cfg_qpi;
						s_qpi = s_cd_cfg_qpi;
						rx_size_o = 'h0;
						rx_wordtransf_o = 'h0;
						rx_bitsword_o = s_cd_wordsize;
						state_next = 3'd1;
						s_is_dummy = 1'b1;
					end
					else if (is_cmd_txd) begin
						s_update_qpi = 1'b1;
						tx_start_o = 1'b1;
						tx_lsbfirst_o = s_cd_cfg_lsb;
						tx_size_o = s_cd_size_long;
						tx_wordtransf_o = s_wordstransf;
						tx_bitsword_o = s_cd_wordsize;
						tx_qpi_o = s_cd_cfg_qpi;
						s_qpi = s_cd_cfg_qpi;
						tx_size_o = s_cd_size_long;
						state_next = 3'd1;
					end
					else if (is_cmd_rxd) begin
						s_update_qpi = 1'b1;
						rx_start_o = 1'b1;
						rx_lsbfirst_o = s_cd_cfg_lsb;
						rx_size_o = s_cd_size_long;
						rx_wordtransf_o = s_wordstransf;
						rx_bitsword_o = s_cd_wordsize;
						rx_qpi_o = s_cd_cfg_qpi;
						s_qpi = s_cd_cfg_qpi;
						state_next = 3'd1;
					end
					else if (is_cmd_ful) begin
						s_is_ful = 1'b1;
						s_update_qpi = 1'b1;
						rx_start_o = 1'b1;
						tx_start_o = 1'b1;
						s_qpi = 1'b0;
						rx_qpi_o = 1'b0;
						tx_qpi_o = 1'b0;
						rx_size_o = s_cd_size_long;
						tx_size_o = s_cd_size_long;
						rx_bitsword_o = s_cd_wordsize;
						tx_bitsword_o = s_cd_wordsize;
						rx_lsbfirst_o = s_cd_cfg_lsb;
						tx_lsbfirst_o = s_cd_cfg_lsb;
						rx_wordtransf_o = s_wordstransf;
						tx_wordtransf_o = s_wordstransf;
						state_next = 3'd1;
					end
					else if (is_cmd_rxc) begin
						s_update_qpi = 1'b1;
						s_update_chk = 1'b1;
						rx_start_o = 1'b1;
						rx_qpi_o = s_cd_cfg_qpi;
						s_qpi = s_cd_cfg_qpi;
						rx_size_o = 'h0;
						rx_wordtransf_o = 'h0;
						rx_bitsword_o = {1'b0, s_cd_wordsize[3:0]};
						rx_lsbfirst_o = s_cd_cfg_lsb;
						state_next = 3'd2;
					end
					else if (is_cmd_rpt) begin
						s_update_rpt = 1'b1;
						s_clr_rpt_buf = 1'b1;
						s_rpt_num = s_cd_size_long;
						s_set_first_reply = 1'b1;
						state_next = 3'd4;
						s_update_status = 1'b1;
						s_status = 2'd0;
					end
					else if (is_cmd_eot) begin
						eot_o = s_cd_eot_evt;
						if (s_cd_eot_keep_cs)
							state_next = 3'd0;
						else
							state_next = 3'd6;
					end
				end
			end
			3'd4:
				if (udma_cmd_valid_i) begin
					s_clr_first_reply = 1'b1;
					udma_cmd_ready_o = 1'b1;
					if (is_cmd_rpe) begin
						s_setup_replay = 1'b0;
						s_is_replay = 1'b1;
						state_next = 3'd0;
					end
					else
						s_setup_replay = 1'b1;
				end
			3'd1: begin
				if (s_done) begin
					state_next = 3'd0;
					s_is_dummy = 1'b0;
				end
				tx_data_o = udma_tx_data_i;
				tx_data_valid_o = udma_tx_data_valid_i;
				udma_tx_data_ready_o = tx_data_ready_i;
				udma_rx_data_o = rx_data_i;
				udma_rx_data_valid_o = (r_is_dummy ? 1'b0 : rx_data_valid_i);
				rx_data_ready_o = udma_rx_data_ready_i;
			end
			3'd2: begin
				if (rx_done_i) begin
					state_next = 3'd0;
					s_is_dummy = 1'b0;
				end
				if (rx_data_valid_i) begin
					s_update_chk_result = 1'b1;
					case (r_chk_type)
						2'b00:
							if (rx_data_i[15:0] == r_chk)
								s_chk_result = 1'b1;
						2'b01:
							if ((rx_data_i[15:0] & r_chk) == r_chk)
								s_chk_result = 1'b1;
						2'b10:
							if ((~rx_data_i[15:0] & ~r_chk) == ~r_chk)
								s_chk_result = 1'b1;
						2'b11:
							if ((rx_data_i[15:0] & r_chk) != r_chk)
								s_chk_result = 1'b1;
						default: s_chk_result = 1'b0;
					endcase
				end
				rx_data_ready_o = 1'b1;
			end
			3'd3:
				if (s_event)
					state_next = 3'd0;
			3'd5:
				if (s_cnt_done)
					state_next = 3'd0;
			3'd6: begin
				s_clear_cs = 1'b1;
				state_next = 3'd0;
			end
			default: state_next = 3'd0;
		endcase
	end
	always @(posedge clk_i or negedge rstn_i) begin : proc_r_chk_result
		if (~rstn_i)
			r_chk_result <= 0;
		else if (s_update_chk_result)
			r_chk_result <= s_chk_result;
	end
	always @(posedge clk_i or negedge rstn_i)
		if (rstn_i == 1'b0)
			state <= 3'd0;
		else
			state <= state_next;
	always @(posedge clk_i or negedge rstn_i)
		if (rstn_i == 1'b0) begin
			r_cfg_cpol <= 1'b0;
			r_cfg_cpha <= 1'b0;
			r_cfg_clkdiv <= 'h0;
		end
		else if (s_update_cfg) begin
			r_cfg_cpol <= s_cd_cfg_cpol;
			r_cfg_cpha <= s_cd_cfg_cpha;
			r_cfg_clkdiv <= s_cd_cfg_clkdiv;
		end
	always @(posedge clk_i or negedge rstn_i) begin : proc_r_update_cfg
		if (~rstn_i)
			r_update_cfg <= 0;
		else
			r_update_cfg <= s_update_cfg;
	end
	always @(posedge clk_i or negedge rstn_i)
		if (rstn_i == 1'b0) begin
			r_qpi <= 1'b0;
			r_is_dummy <= 1'b0;
			r_evt_sel <= 'h0;
			r_is_ful <= 1'b0;
			r_tx_done <= 1'b0;
			r_rx_done <= 1'b0;
			r_chk_type <= 0;
			r_chk <= 0;
			r_is_replay <= 0;
			r_first_replay <= 1'b0;
			r_status <= 2'd0;
		end
		else begin
			r_is_ful <= s_is_ful;
			r_tx_done <= tx_done_i;
			r_rx_done <= rx_done_i;
			r_is_replay <= s_is_replay;
			if (s_set_first_reply)
				r_first_replay <= 1'b1;
			if (s_clr_first_reply)
				r_first_replay <= 1'b0;
			if (s_update_status)
				r_status <= s_status;
			if (s_update_chk) begin
				r_chk_type <= s_cd_cfg_chk_type;
				r_chk <= s_cd_cfg_check;
			end
			if (s_update_qpi)
				r_qpi <= s_qpi;
			if (s_update_evt)
				r_evt_sel <= s_cd_wait_evt;
			r_is_dummy <= s_is_dummy;
		end
	always @(posedge clk_i or negedge rstn_i) begin : proc_rpt
		if (~rstn_i)
			r_rpt_num <= 0;
		else if (s_update_rpt)
			r_rpt_num <= s_rpt_num;
	end
	assign s_cs = s_cd_cs;
	always @(posedge clk_i or negedge rstn_i)
		if (rstn_i == 1'b0) begin
			spi_csn0_o <= 1'b1;
			spi_csn1_o <= 1'b1;
			spi_csn2_o <= 1'b1;
			spi_csn3_o <= 1'b1;
		end
		else if (s_update_cs)
			case (s_cs)
				2'b00: spi_csn0_o <= 1'b0;
				2'b01: spi_csn1_o <= 1'b0;
				2'b10: spi_csn2_o <= 1'b0;
				2'b11: spi_csn3_o <= 1'b0;
			endcase
		else if (s_clear_cs) begin
			spi_csn0_o <= 1'b1;
			spi_csn1_o <= 1'b1;
			spi_csn2_o <= 1'b1;
			spi_csn3_o <= 1'b1;
		end
endmodule
