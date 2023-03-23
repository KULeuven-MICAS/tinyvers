module udma_filter (
	clk_i,
	resetn_i,
	cfg_data_i,
	cfg_addr_i,
	cfg_valid_i,
	cfg_rwn_i,
	cfg_data_o,
	cfg_ready_o,
	eot_event_o,
	act_event_o,
	filter_tx_ch0_req_o,
	filter_tx_ch0_addr_o,
	filter_tx_ch0_datasize_o,
	filter_tx_ch0_gnt_i,
	filter_tx_ch0_valid_i,
	filter_tx_ch0_data_i,
	filter_tx_ch0_ready_o,
	filter_tx_ch1_req_o,
	filter_tx_ch1_addr_o,
	filter_tx_ch1_datasize_o,
	filter_tx_ch1_gnt_i,
	filter_tx_ch1_valid_i,
	filter_tx_ch1_data_i,
	filter_tx_ch1_ready_o,
	filter_rx_ch_addr_o,
	filter_rx_ch_datasize_o,
	filter_rx_ch_valid_o,
	filter_rx_ch_data_o,
	filter_rx_ch_ready_i,
	filter_id_i,
	filter_data_i,
	filter_datasize_i,
	filter_valid_i,
	filter_sof_i,
	filter_eof_i,
	filter_ready_o
);
	parameter DATA_WIDTH = 32;
	parameter FILTID_WIDTH = 8;
	parameter L2_AWIDTH_NOAL = 15;
	parameter TRANS_SIZE = 16;
	input wire clk_i;
	input wire resetn_i;
	input wire [31:0] cfg_data_i;
	input wire [4:0] cfg_addr_i;
	input wire cfg_valid_i;
	input wire cfg_rwn_i;
	output wire [31:0] cfg_data_o;
	output wire cfg_ready_o;
	output wire eot_event_o;
	output wire act_event_o;
	output wire filter_tx_ch0_req_o;
	output wire [L2_AWIDTH_NOAL - 1:0] filter_tx_ch0_addr_o;
	output wire [1:0] filter_tx_ch0_datasize_o;
	input wire filter_tx_ch0_gnt_i;
	input wire filter_tx_ch0_valid_i;
	input wire [DATA_WIDTH - 1:0] filter_tx_ch0_data_i;
	output wire filter_tx_ch0_ready_o;
	output wire filter_tx_ch1_req_o;
	output wire [L2_AWIDTH_NOAL - 1:0] filter_tx_ch1_addr_o;
	output wire [1:0] filter_tx_ch1_datasize_o;
	input wire filter_tx_ch1_gnt_i;
	input wire filter_tx_ch1_valid_i;
	input wire [DATA_WIDTH - 1:0] filter_tx_ch1_data_i;
	output wire filter_tx_ch1_ready_o;
	output wire [L2_AWIDTH_NOAL - 1:0] filter_rx_ch_addr_o;
	output wire [1:0] filter_rx_ch_datasize_o;
	output wire filter_rx_ch_valid_o;
	output wire [DATA_WIDTH - 1:0] filter_rx_ch_data_o;
	input wire filter_rx_ch_ready_i;
	input wire [FILTID_WIDTH - 1:0] filter_id_i;
	input wire [DATA_WIDTH - 1:0] filter_data_i;
	input wire [1:0] filter_datasize_i;
	input wire filter_valid_i;
	input wire filter_sof_i;
	input wire filter_eof_i;
	output wire filter_ready_o;
	wire [DATA_WIDTH - 1:0] s_porta_data;
	wire [1:0] s_porta_datasize;
	wire s_porta_valid;
	wire s_porta_sof;
	wire s_porta_eof;
	wire s_porta_ready;
	wire [DATA_WIDTH - 1:0] s_portb_data;
	wire [1:0] s_portb_datasize;
	wire s_portb_valid;
	wire s_portb_sof;
	wire s_portb_eof;
	wire s_portb_ready;
	wire [DATA_WIDTH - 1:0] s_operanda_data;
	wire [1:0] s_operanda_datasize;
	wire s_operanda_valid;
	wire s_operanda_sof;
	wire s_operanda_eof;
	wire s_operanda_ready;
	wire [DATA_WIDTH - 1:0] s_operandb_data;
	wire [1:0] s_operandb_datasize;
	wire s_operandb_valid;
	wire s_operandb_ready;
	wire [DATA_WIDTH - 1:0] s_au_out_data;
	wire [1:0] s_au_out_datasize;
	wire s_au_out_valid;
	wire s_au_out_ready;
	wire [DATA_WIDTH - 1:0] s_bincu_in_data;
	wire [1:0] s_bincu_in_datasize;
	wire s_bincu_in_valid;
	wire s_bincu_in_ready;
	wire [DATA_WIDTH - 1:0] s_bincu_out_data;
	wire s_bincu_out_valid;
	wire s_bincu_out_ready;
	wire s_bincu_outenable;
	wire [DATA_WIDTH - 1:0] s_udma_out_data;
	wire s_udma_out_valid;
	wire s_udma_out_ready;
	reg s_sel_out;
	reg s_sel_out_valid;
	reg s_sel_opa;
	reg s_sel_opa_valid;
	reg s_sel_opb_valid;
	reg s_sel_bincu;
	reg s_sel_bincu_valid;
	wire s_start_cha;
	wire s_start_chb;
	wire s_start_out;
	wire s_start_bcu;
	wire [2:0] s_status;
	reg [2:0] r_status;
	wire s_done_cha;
	wire s_done_chb;
	wire s_done_out;
	wire s_done;
	reg r_done;
	wire s_event;
	wire s_filter_ready;
	wire [3:0] s_cfg_filter_mode;
	wire s_cfg_filter_start;
	wire [(2 * L2_AWIDTH_NOAL) - 1:0] s_cfg_filter_tx_start_addr;
	wire [3:0] s_cfg_filter_tx_datasize;
	wire [3:0] s_cfg_filter_tx_mode;
	wire [(2 * TRANS_SIZE) - 1:0] s_cfg_filter_tx_len0;
	wire [(2 * TRANS_SIZE) - 1:0] s_cfg_filter_tx_len1;
	wire [(2 * TRANS_SIZE) - 1:0] s_cfg_filter_tx_len2;
	wire [L2_AWIDTH_NOAL - 1:0] s_cfg_filter_rx_start_addr;
	wire [1:0] s_cfg_filter_rx_datasize;
	wire [1:0] s_cfg_filter_rx_mode;
	wire [TRANS_SIZE - 1:0] s_cfg_filter_rx_len0;
	wire [TRANS_SIZE - 1:0] s_cfg_filter_rx_len1;
	wire [TRANS_SIZE - 1:0] s_cfg_filter_rx_len2;
	wire s_cfg_au_use_signed;
	wire s_cfg_au_bypass;
	wire [3:0] s_cfg_au_mode;
	wire [4:0] s_cfg_au_shift;
	wire [31:0] s_cfg_au_reg0;
	wire [31:0] s_cfg_au_reg1;
	wire [31:0] s_cfg_bincu_threshold;
	wire [1:0] s_cfg_bincu_datasize;
	wire [TRANS_SIZE - 1:0] s_cfg_bincu_counter;
	wire [TRANS_SIZE - 1:0] s_cfg_bincu_counter_val;
	wire s_cfg_bincu_en_cnt;
	assign s_start_out = s_cfg_filter_start & s_sel_out_valid;
	assign s_start_cha = s_cfg_filter_start & s_sel_opa_valid;
	assign s_start_chb = s_cfg_filter_start & s_sel_opb_valid;
	assign s_start_bcu = s_cfg_filter_start & s_sel_bincu_valid;
	assign s_udma_out_data = (s_sel_out ? s_au_out_data : s_bincu_out_data);
	assign s_udma_out_valid = s_sel_out_valid & (s_sel_out ? s_au_out_valid : s_bincu_out_valid);
	assign s_bincu_in_data = (s_sel_bincu ? s_au_out_data : filter_data_i);
	assign s_bincu_in_valid = s_sel_bincu_valid & (s_sel_bincu ? s_au_out_valid : filter_valid_i);
	assign s_bincu_in_datasize = (s_sel_bincu ? s_au_out_datasize : filter_datasize_i);
	assign s_operanda_data = (s_sel_opa ? s_porta_data : filter_data_i);
	assign s_operanda_datasize = (s_sel_opa ? s_porta_datasize : filter_datasize_i);
	assign s_operanda_sof = (s_sel_opa ? s_porta_sof : filter_sof_i);
	assign s_operanda_eof = (s_sel_opa ? s_porta_eof : filter_eof_i);
	assign s_operanda_valid = s_sel_opa_valid & (s_sel_opa ? s_porta_valid : filter_valid_i);
	assign s_operandb_data = s_portb_data;
	assign s_operandb_valid = s_portb_valid;
	assign s_operandb_datasize = s_portb_datasize;
	assign s_au_out_ready = ((s_sel_out_valid & s_sel_out) & s_udma_out_ready) | ((s_sel_bincu_valid & s_sel_bincu) & s_bincu_in_ready);
	assign s_porta_ready = (s_sel_opa_valid & s_sel_opa) & s_operanda_ready;
	assign s_portb_ready = s_operandb_ready;
	assign s_filter_ready = ((s_sel_opa_valid & !s_sel_opa) & s_operanda_ready) | ((s_sel_bincu_valid & !s_sel_bincu) & s_bincu_in_ready);
	assign s_bincu_out_ready = (s_sel_out_valid & !s_sel_out) & s_udma_out_ready;
	assign filter_ready_o = s_filter_ready;
	assign s_status = r_status | {!s_sel_out_valid, !s_sel_opb_valid, !s_sel_opa_valid};
	assign s_done = &s_status;
	assign s_event = s_done & ~r_done;
	assign eot_event_o = s_event;
	assign s_bincu_outenable = s_sel_out_valid & ~s_sel_out;
	always @(*) begin
		s_sel_out = 1'b0;
		s_sel_out_valid = 1'b0;
		s_sel_bincu = 1'b0;
		s_sel_bincu_valid = 1'b0;
		s_sel_opa = 1'b0;
		s_sel_opa_valid = 1'b0;
		s_sel_opb_valid = 1'b0;
		case (s_cfg_filter_mode)
			0: begin
				s_sel_opa = 1'b1;
				s_sel_opa_valid = 1'b1;
				s_sel_opb_valid = 1'b1;
				s_sel_out = 1'b1;
				s_sel_out_valid = 1'b1;
			end
			1: begin
				s_sel_opa = 1'b0;
				s_sel_opa_valid = 1'b1;
				s_sel_opb_valid = 1'b1;
				s_sel_out = 1'b1;
				s_sel_out_valid = 1'b1;
			end
			2: begin
				s_sel_opa = 1'b1;
				s_sel_opa_valid = 1'b1;
				s_sel_out = 1'b1;
				s_sel_out_valid = 1'b1;
			end
			3: begin
				s_sel_opa = 1'b0;
				s_sel_opa_valid = 1'b1;
				s_sel_out = 1'b1;
				s_sel_out_valid = 1'b1;
			end
			4: begin
				s_sel_opa = 1'b1;
				s_sel_opa_valid = 1'b1;
				s_sel_opb_valid = 1'b1;
				s_sel_bincu = 1'b1;
				s_sel_bincu_valid = 1'b1;
			end
			5: begin
				s_sel_opa = 1'b0;
				s_sel_opa_valid = 1'b1;
				s_sel_opb_valid = 1'b1;
				s_sel_bincu = 1'b1;
				s_sel_bincu_valid = 1'b1;
			end
			6: begin
				s_sel_opa = 1'b1;
				s_sel_opa_valid = 1'b1;
				s_sel_bincu = 1'b1;
				s_sel_bincu_valid = 1'b1;
			end
			7: begin
				s_sel_opa = 1'b0;
				s_sel_opa_valid = 1'b1;
				s_sel_bincu = 1'b1;
				s_sel_bincu_valid = 1'b1;
			end
			8: begin
				s_sel_opa = 1'b1;
				s_sel_opa_valid = 1'b1;
				s_sel_opb_valid = 1'b1;
				s_sel_out = 1'b0;
				s_sel_out_valid = 1'b1;
				s_sel_bincu = 1'b1;
				s_sel_bincu_valid = 1'b1;
			end
			9: begin
				s_sel_opa = 1'b0;
				s_sel_opa_valid = 1'b1;
				s_sel_opb_valid = 1'b1;
				s_sel_out = 1'b0;
				s_sel_out_valid = 1'b1;
				s_sel_bincu = 1'b1;
				s_sel_bincu_valid = 1'b1;
			end
			10: begin
				s_sel_opa = 1'b1;
				s_sel_opa_valid = 1'b1;
				s_sel_out = 1'b0;
				s_sel_out_valid = 1'b1;
				s_sel_bincu = 1'b1;
				s_sel_bincu_valid = 1'b1;
			end
			11: begin
				s_sel_opa = 1'b0;
				s_sel_opa_valid = 1'b1;
				s_sel_out = 1'b0;
				s_sel_out_valid = 1'b1;
				s_sel_bincu = 1'b1;
				s_sel_bincu_valid = 1'b1;
			end
			12: begin
				s_sel_bincu = 1'b0;
				s_sel_bincu_valid = 1'b1;
			end
			13: begin
				s_sel_out = 1'b0;
				s_sel_out_valid = 1'b1;
				s_sel_bincu = 1'b0;
				s_sel_bincu_valid = 1'b1;
			end
		endcase
	end
	always @(posedge clk_i or negedge resetn_i) begin : proc_status
		if (~resetn_i) begin
			r_status <= 0;
			r_done <= 0;
		end
		else begin
			r_done <= s_done;
			if (s_cfg_filter_start)
				r_status <= 0;
			else begin
				if (s_done_cha)
					r_status[0] <= 1'b1;
				if (s_done_chb)
					r_status[1] <= 1'b1;
				if (s_done_out)
					r_status[2] <= 1'b1;
			end
		end
	end
	udma_filter_reg_if #(
		.L2_AWIDTH_NOAL(L2_AWIDTH_NOAL),
		.TRANS_SIZE(TRANS_SIZE)
	) i_reg_if(
		.clk_i(clk_i),
		.rstn_i(resetn_i),
		.cfg_data_i(cfg_data_i),
		.cfg_addr_i(cfg_addr_i),
		.cfg_valid_i(cfg_valid_i),
		.cfg_rwn_i(cfg_rwn_i),
		.cfg_data_o(cfg_data_o),
		.cfg_ready_o(cfg_ready_o),
		.cfg_filter_mode_o(s_cfg_filter_mode),
		.cfg_filter_start_o(s_cfg_filter_start),
		.cfg_filter_tx_start_addr_o(s_cfg_filter_tx_start_addr),
		.cfg_filter_tx_datasize_o(s_cfg_filter_tx_datasize),
		.cfg_filter_tx_mode_o(s_cfg_filter_tx_mode),
		.cfg_filter_tx_len0_o(s_cfg_filter_tx_len0),
		.cfg_filter_tx_len1_o(s_cfg_filter_tx_len1),
		.cfg_filter_tx_len2_o(s_cfg_filter_tx_len2),
		.cfg_filter_rx_start_addr_o(s_cfg_filter_rx_start_addr),
		.cfg_filter_rx_datasize_o(s_cfg_filter_rx_datasize),
		.cfg_filter_rx_mode_o(s_cfg_filter_rx_mode),
		.cfg_filter_rx_len0_o(s_cfg_filter_rx_len0),
		.cfg_filter_rx_len1_o(s_cfg_filter_rx_len1),
		.cfg_filter_rx_len2_o(s_cfg_filter_rx_len2),
		.cfg_au_use_signed_o(s_cfg_au_use_signed),
		.cfg_au_bypass_o(s_cfg_au_bypass),
		.cfg_au_mode_o(s_cfg_au_mode),
		.cfg_au_shift_o(s_cfg_au_shift),
		.cfg_au_reg0_o(s_cfg_au_reg0),
		.cfg_au_reg1_o(s_cfg_au_reg1),
		.cfg_bincu_threshold_o(s_cfg_bincu_threshold),
		.cfg_bincu_datasize_o(s_cfg_bincu_datasize),
		.cfg_bincu_counter_o(s_cfg_bincu_counter),
		.cfg_bincu_en_counter_o(s_cfg_bincu_en_cnt),
		.bincu_counter_i(s_cfg_bincu_counter_val),
		.filter_done_i(s_event)
	);
	udma_filter_tx_datafetch #(
		.DATA_WIDTH(DATA_WIDTH),
		.L2_AWIDTH_NOAL(L2_AWIDTH_NOAL),
		.TRANS_SIZE(TRANS_SIZE)
	) u_tx_ch_opa(
		.clk_i(clk_i),
		.resetn_i(resetn_i),
		.tx_ch_req_o(filter_tx_ch0_req_o),
		.tx_ch_addr_o(filter_tx_ch0_addr_o),
		.tx_ch_datasize_o(filter_tx_ch0_datasize_o),
		.tx_ch_gnt_i(filter_tx_ch0_gnt_i),
		.tx_ch_valid_i(filter_tx_ch0_valid_i),
		.tx_ch_data_i(filter_tx_ch0_data_i),
		.tx_ch_ready_o(filter_tx_ch0_ready_o),
		.cmd_start_i(s_start_cha),
		.cmd_done_o(s_done_cha),
		.cfg_start_addr_i(s_cfg_filter_tx_start_addr[0+:L2_AWIDTH_NOAL]),
		.cfg_datasize_i(s_cfg_filter_tx_datasize[0+:2]),
		.cfg_mode_i(s_cfg_filter_tx_mode[0+:2]),
		.cfg_len0_i(s_cfg_filter_tx_len0[0+:TRANS_SIZE]),
		.cfg_len1_i(s_cfg_filter_tx_len1[0+:TRANS_SIZE]),
		.cfg_len2_i(s_cfg_filter_tx_len2[0+:TRANS_SIZE]),
		.stream_data_o(s_porta_data),
		.stream_datasize_o(s_porta_datasize),
		.stream_sof_o(s_porta_sof),
		.stream_eof_o(s_porta_eof),
		.stream_valid_o(s_porta_valid),
		.stream_ready_i(s_porta_ready)
	);
	udma_filter_tx_datafetch #(
		.DATA_WIDTH(DATA_WIDTH),
		.L2_AWIDTH_NOAL(L2_AWIDTH_NOAL),
		.TRANS_SIZE(TRANS_SIZE)
	) u_tx_ch_opb(
		.clk_i(clk_i),
		.resetn_i(resetn_i),
		.tx_ch_req_o(filter_tx_ch1_req_o),
		.tx_ch_addr_o(filter_tx_ch1_addr_o),
		.tx_ch_datasize_o(filter_tx_ch1_datasize_o),
		.tx_ch_gnt_i(filter_tx_ch1_gnt_i),
		.tx_ch_valid_i(filter_tx_ch1_valid_i),
		.tx_ch_data_i(filter_tx_ch1_data_i),
		.tx_ch_ready_o(filter_tx_ch1_ready_o),
		.cmd_start_i(s_start_chb),
		.cmd_done_o(s_done_chb),
		.cfg_start_addr_i(s_cfg_filter_tx_start_addr[L2_AWIDTH_NOAL+:L2_AWIDTH_NOAL]),
		.cfg_datasize_i(s_cfg_filter_tx_datasize[2+:2]),
		.cfg_mode_i(s_cfg_filter_tx_mode[2+:2]),
		.cfg_len0_i(s_cfg_filter_tx_len0[TRANS_SIZE+:TRANS_SIZE]),
		.cfg_len1_i(s_cfg_filter_tx_len1[TRANS_SIZE+:TRANS_SIZE]),
		.cfg_len2_i(s_cfg_filter_tx_len2[TRANS_SIZE+:TRANS_SIZE]),
		.stream_data_o(s_portb_data),
		.stream_datasize_o(s_portb_datasize),
		.stream_sof_o(s_portb_sof),
		.stream_eof_o(s_portb_eof),
		.stream_valid_o(s_portb_valid),
		.stream_ready_i(s_portb_ready)
	);
	udma_filter_au #(.DATA_WIDTH(DATA_WIDTH)) u_filter_au(
		.clk_i(clk_i),
		.resetn_i(resetn_i),
		.cfg_use_signed_i(s_cfg_au_use_signed),
		.cfg_bypass_i(s_cfg_au_bypass),
		.cfg_mode_i(s_cfg_au_mode),
		.cfg_shift_i(s_cfg_au_shift),
		.cfg_reg0_i(s_cfg_au_reg0),
		.cfg_reg1_i(s_cfg_au_reg1),
		.cmd_start_i(s_cfg_filter_start),
		.operanda_data_i(s_operanda_data),
		.operanda_datasize_i(s_operanda_datasize),
		.operanda_valid_i(s_operanda_valid),
		.operanda_sof_i(s_operanda_sof),
		.operanda_eof_i(s_operanda_eof),
		.operanda_ready_o(s_operanda_ready),
		.operandb_data_i(s_operandb_data),
		.operandb_datasize_i(s_operandb_datasize),
		.operandb_valid_i(s_operandb_valid),
		.operandb_ready_o(s_operandb_ready),
		.output_data_o(s_au_out_data),
		.output_datasize_o(s_au_out_datasize),
		.output_valid_o(s_au_out_valid),
		.output_ready_i(s_au_out_ready)
	);
	udma_filter_bincu #(
		.DATA_WIDTH(DATA_WIDTH),
		.TRANS_SIZE(TRANS_SIZE)
	) u_filter_bincu(
		.clk_i(clk_i),
		.resetn_i(resetn_i),
		.cfg_use_signed_i(s_cfg_au_use_signed),
		.cfg_en_counter_i(s_cfg_bincu_en_cnt),
		.cfg_out_enable_i(s_bincu_outenable),
		.cfg_threshold_i(s_cfg_bincu_threshold),
		.cfg_counter_i(s_cfg_bincu_counter),
		.cfg_datasize_i(s_cfg_bincu_datasize),
		.counter_val_o(s_cfg_bincu_counter_val),
		.cmd_start_i(s_start_bcu),
		.act_event_o(act_event_o),
		.input_data_i(s_bincu_in_data),
		.input_datasize_i(s_bincu_in_datasize),
		.input_valid_i(s_bincu_in_valid),
		.input_sof_i(1'b0),
		.input_eof_i(1'b0),
		.input_ready_o(s_bincu_in_ready),
		.output_data_o(s_bincu_out_data),
		.output_valid_o(s_bincu_out_valid),
		.output_ready_i(s_bincu_out_ready)
	);
	udma_filter_rx_dataout #(
		.DATA_WIDTH(DATA_WIDTH),
		.FILTID_WIDTH(FILTID_WIDTH),
		.L2_AWIDTH_NOAL(L2_AWIDTH_NOAL),
		.TRANS_SIZE(TRANS_SIZE)
	) u_rx_ch(
		.clk_i(clk_i),
		.resetn_i(resetn_i),
		.rx_ch_addr_o(filter_rx_ch_addr_o),
		.rx_ch_datasize_o(filter_rx_ch_datasize_o),
		.rx_ch_valid_o(filter_rx_ch_valid_o),
		.rx_ch_data_o(filter_rx_ch_data_o),
		.rx_ch_ready_i(filter_rx_ch_ready_i),
		.cmd_start_i(s_start_out),
		.cmd_done_o(s_done_out),
		.cfg_start_addr_i(s_cfg_filter_rx_start_addr),
		.cfg_datasize_i(s_cfg_filter_rx_datasize),
		.cfg_mode_i(s_cfg_filter_rx_mode),
		.cfg_len0_i(s_cfg_filter_rx_len0),
		.cfg_len1_i(s_cfg_filter_rx_len1),
		.cfg_len2_i(s_cfg_filter_rx_len2),
		.stream_data_i(s_udma_out_data),
		.stream_valid_i(s_udma_out_valid),
		.stream_ready_o(s_udma_out_ready)
	);
endmodule
