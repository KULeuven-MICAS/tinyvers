module udma_rx_channels (
	clk_i,
	rstn_i,
	l2_req_o,
	l2_gnt_i,
	l2_be_o,
	l2_addr_o,
	l2_wdata_o,
	stream_data_o,
	stream_datasize_o,
	stream_valid_o,
	stream_sot_o,
	stream_eot_o,
	stream_ready_i,
	tx_ch_req_o,
	tx_ch_addr_o,
	tx_ch_datasize_o,
	tx_ch_gnt_i,
	tx_ch_valid_i,
	tx_ch_data_i,
	tx_ch_ready_o,
	lin_ch_valid_i,
	lin_ch_data_i,
	lin_ch_datasize_i,
	lin_ch_destination_i,
	lin_ch_ready_o,
	lin_ch_events_o,
	lin_ch_en_o,
	lin_ch_pending_o,
	lin_ch_curr_addr_o,
	lin_ch_bytes_left_o,
	lin_ch_cfg_startaddr_i,
	lin_ch_cfg_size_i,
	lin_ch_cfg_continuous_i,
	lin_ch_cfg_en_i,
	lin_ch_cfg_stream_i,
	lin_ch_cfg_stream_id_i,
	lin_ch_cfg_clr_i,
	ext_ch_addr_i,
	ext_ch_datasize_i,
	ext_ch_destination_i,
	ext_ch_stream_i,
	ext_ch_stream_id_i,
	ext_ch_sot_i,
	ext_ch_eot_i,
	ext_ch_valid_i,
	ext_ch_data_i,
	ext_ch_ready_o
);
	parameter TRANS_SIZE = 16;
	parameter L2_DATA_WIDTH = 64;
	parameter L2_AWIDTH_NOAL = 16;
	parameter DATA_WIDTH = 32;
	parameter DEST_SIZE = 2;
	parameter STREAM_ID_WIDTH = 2;
	parameter N_STREAMS = 4;
	parameter N_LIN_CHANNELS = 8;
	parameter N_EXT_CHANNELS = 8;
	input wire clk_i;
	input wire rstn_i;
	output wire l2_req_o;
	input wire l2_gnt_i;
	output wire [(L2_DATA_WIDTH / 8) - 1:0] l2_be_o;
	output reg [31:0] l2_addr_o;
	output reg [L2_DATA_WIDTH - 1:0] l2_wdata_o;
	output wire [(N_STREAMS * DATA_WIDTH) - 1:0] stream_data_o;
	output wire [(N_STREAMS * 2) - 1:0] stream_datasize_o;
	output wire [N_STREAMS - 1:0] stream_valid_o;
	output wire [N_STREAMS - 1:0] stream_sot_o;
	output wire [N_STREAMS - 1:0] stream_eot_o;
	input wire [N_STREAMS - 1:0] stream_ready_i;
	output wire [N_STREAMS - 1:0] tx_ch_req_o;
	output wire [(N_STREAMS * L2_AWIDTH_NOAL) - 1:0] tx_ch_addr_o;
	output wire [(N_STREAMS * 2) - 1:0] tx_ch_datasize_o;
	input wire [N_STREAMS - 1:0] tx_ch_gnt_i;
	input wire [N_STREAMS - 1:0] tx_ch_valid_i;
	input wire [(N_STREAMS * DATA_WIDTH) - 1:0] tx_ch_data_i;
	output wire [N_STREAMS - 1:0] tx_ch_ready_o;
	input wire [N_LIN_CHANNELS - 1:0] lin_ch_valid_i;
	input wire [(N_LIN_CHANNELS * DATA_WIDTH) - 1:0] lin_ch_data_i;
	input wire [(N_LIN_CHANNELS * 2) - 1:0] lin_ch_datasize_i;
	input wire [(N_LIN_CHANNELS * DEST_SIZE) - 1:0] lin_ch_destination_i;
	output reg [N_LIN_CHANNELS - 1:0] lin_ch_ready_o;
	output wire [N_LIN_CHANNELS - 1:0] lin_ch_events_o;
	output wire [N_LIN_CHANNELS - 1:0] lin_ch_en_o;
	output wire [N_LIN_CHANNELS - 1:0] lin_ch_pending_o;
	output wire [(N_LIN_CHANNELS * L2_AWIDTH_NOAL) - 1:0] lin_ch_curr_addr_o;
	output wire [(N_LIN_CHANNELS * TRANS_SIZE) - 1:0] lin_ch_bytes_left_o;
	input wire [(N_LIN_CHANNELS * L2_AWIDTH_NOAL) - 1:0] lin_ch_cfg_startaddr_i;
	input wire [(N_LIN_CHANNELS * TRANS_SIZE) - 1:0] lin_ch_cfg_size_i;
	input wire [N_LIN_CHANNELS - 1:0] lin_ch_cfg_continuous_i;
	input wire [N_LIN_CHANNELS - 1:0] lin_ch_cfg_en_i;
	input wire [(N_LIN_CHANNELS * 2) - 1:0] lin_ch_cfg_stream_i;
	input wire [(N_LIN_CHANNELS * STREAM_ID_WIDTH) - 1:0] lin_ch_cfg_stream_id_i;
	input wire [N_LIN_CHANNELS - 1:0] lin_ch_cfg_clr_i;
	input wire [(N_EXT_CHANNELS * L2_AWIDTH_NOAL) - 1:0] ext_ch_addr_i;
	input wire [(N_EXT_CHANNELS * 2) - 1:0] ext_ch_datasize_i;
	input wire [(N_EXT_CHANNELS * DEST_SIZE) - 1:0] ext_ch_destination_i;
	input wire [(N_EXT_CHANNELS * 2) - 1:0] ext_ch_stream_i;
	input wire [(N_EXT_CHANNELS * STREAM_ID_WIDTH) - 1:0] ext_ch_stream_id_i;
	input wire [N_EXT_CHANNELS - 1:0] ext_ch_sot_i;
	input wire [N_EXT_CHANNELS - 1:0] ext_ch_eot_i;
	input wire [N_EXT_CHANNELS - 1:0] ext_ch_valid_i;
	input wire [(N_EXT_CHANNELS * DATA_WIDTH) - 1:0] ext_ch_data_i;
	output reg [N_EXT_CHANNELS - 1:0] ext_ch_ready_o;
	localparam ALIGN_BITS = $clog2(L2_DATA_WIDTH / 8);
	localparam N_CHANNELS_RX = N_LIN_CHANNELS + N_EXT_CHANNELS;
	localparam LOG_N_CHANNELS = $clog2(N_CHANNELS_RX);
	localparam DATASIZE_BITS = 2;
	localparam SOT_EOT_BITS = 2;
	localparam CURR_BYTES_BITS = 2;
	localparam INTFIFO_L2_SIZE = (((((DATA_WIDTH + L2_AWIDTH_NOAL) + DATASIZE_BITS) + DEST_SIZE) + CURR_BYTES_BITS) + STREAM_ID_WIDTH) + 1;
	localparam INTFIFO_FILTER_SIZE = ((DATA_WIDTH + DATASIZE_BITS) + DEST_SIZE) + SOT_EOT_BITS;
	integer i;
	wire [(N_LIN_CHANNELS * L2_AWIDTH_NOAL) - 1:0] s_curr_addr;
	wire [(N_LIN_CHANNELS * 2) - 1:0] s_curr_bytes;
	wire [(N_LIN_CHANNELS * STREAM_ID_WIDTH) - 1:0] s_stream_id_cfg;
	wire [N_CHANNELS_RX - 1:0] s_grant;
	reg [N_CHANNELS_RX - 1:0] r_grant;
	wire [N_CHANNELS_RX - 1:0] s_req;
	reg [LOG_N_CHANNELS - 1:0] s_grant_log;
	wire [N_LIN_CHANNELS - 1:0] s_ch_en;
	wire s_anygrant;
	reg r_anygrant;
	reg [31:0] s_data;
	reg [31:0] r_data;
	reg [DEST_SIZE - 1:0] s_dest;
	reg [DEST_SIZE - 1:0] r_dest;
	reg [L2_AWIDTH_NOAL - 1:0] s_addr;
	reg [1:0] s_bytes;
	reg [1:0] s_default_bytes;
	reg [L2_AWIDTH_NOAL - 1:0] r_ext_addr;
	reg [1:0] r_ext_stream;
	reg [STREAM_ID_WIDTH - 1:0] r_ext_stream_id;
	reg r_ext_sot;
	reg r_ext_eot;
	reg [1:0] s_size;
	reg [1:0] r_size;
	wire [1:0] s_l2_transf_size;
	wire [DATA_WIDTH - 1:0] s_l2_data;
	wire [DEST_SIZE - 1:0] s_l2_dest;
	reg [(L2_DATA_WIDTH / 8) - 1:0] s_l2_be;
	wire [L2_AWIDTH_NOAL - 1:0] s_l2_addr;
	wire [(L2_AWIDTH_NOAL - ALIGN_BITS) - 1:0] s_l2_addr_na;
	wire [STREAM_ID_WIDTH - 1:0] s_l2_stream_id;
	wire [1:0] s_l2_bytes;
	wire [INTFIFO_L2_SIZE - 1:0] s_fifoin;
	wire [INTFIFO_L2_SIZE - 1:0] s_fifoout;
	wire [INTFIFO_FILTER_SIZE - 1:0] s_fifoin_stream;
	wire [INTFIFO_FILTER_SIZE - 1:0] s_fifoout_stream;
	wire s_sample_indata;
	wire s_sample_indata_l2;
	wire s_sample_indata_stream;
	wire [(N_LIN_CHANNELS * 2) - 1:0] s_stream_cfg;
	reg s_is_stream;
	reg s_stream_use_buff;
	reg [STREAM_ID_WIDTH - 1:0] s_stream_id;
	wire [N_STREAMS - 1:0] s_stream_ready;
	wire [DATA_WIDTH - 1:0] s_stream_data;
	wire [STREAM_ID_WIDTH - 1:0] s_stream_dest;
	wire [1:0] s_stream_size;
	wire s_stream_sot;
	wire s_stream_eot;
	wire s_stream_ready_demux;
	wire s_stream_storel2;
	wire [N_LIN_CHANNELS - 1:0] s_ch_events;
	wire [N_LIN_CHANNELS - 1:0] s_ch_sot;
	reg s_eot;
	reg s_sot;
	wire s_push_l2;
	wire s_push_filter;
	wire s_l2_req;
	reg s_l2_gnt;
	reg s_is_na;
	reg s_detect_na;
	reg r_rx_state;
	reg s_rx_state_next;
	assign lin_ch_events_o = s_ch_events;
	assign lin_ch_curr_addr_o = s_curr_addr;
	assign lin_ch_en_o = s_ch_en;
	assign s_fifoin = {s_bytes, s_stream_storel2, s_stream_id, r_dest, r_size, s_addr[L2_AWIDTH_NOAL - 1:0], r_data};
	assign s_fifoin_stream = {s_sot, s_eot, r_dest, r_size, r_data};
	assign s_l2_data = s_fifoout[DATA_WIDTH - 1:0];
	assign s_l2_addr = s_fifoout[(DATA_WIDTH + L2_AWIDTH_NOAL) - 1:DATA_WIDTH];
	assign s_l2_transf_size = s_fifoout[((DATA_WIDTH + L2_AWIDTH_NOAL) + DATASIZE_BITS) - 1:L2_AWIDTH_NOAL + DATA_WIDTH];
	assign s_l2_dest = s_fifoout[(((DATA_WIDTH + L2_AWIDTH_NOAL) + DATASIZE_BITS) + DEST_SIZE) - 1:(L2_AWIDTH_NOAL + DATA_WIDTH) + DATASIZE_BITS];
	assign s_l2_stream_id = s_fifoout[((((DATA_WIDTH + L2_AWIDTH_NOAL) + DATASIZE_BITS) + DEST_SIZE) + STREAM_ID_WIDTH) - 1:((DATA_WIDTH + L2_AWIDTH_NOAL) + DATASIZE_BITS) + DEST_SIZE];
	wire s_l2_is_stream;
	assign s_l2_is_stream = s_fifoout[(((DATA_WIDTH + L2_AWIDTH_NOAL) + DATASIZE_BITS) + DEST_SIZE) + STREAM_ID_WIDTH];
	assign s_l2_bytes = s_fifoout[INTFIFO_L2_SIZE - 1:INTFIFO_L2_SIZE - CURR_BYTES_BITS];
	assign s_req[N_LIN_CHANNELS - 1:0] = lin_ch_valid_i & s_ch_en;
	assign s_req[N_CHANNELS_RX - 1:N_LIN_CHANNELS] = ext_ch_valid_i;
	assign l2_be_o = s_l2_be;
	assign s_stream_sot = s_fifoout_stream[INTFIFO_FILTER_SIZE - 1];
	assign s_stream_eot = s_fifoout_stream[INTFIFO_FILTER_SIZE - 2];
	assign s_stream_dest = s_fifoout_stream[((DATA_WIDTH + DATASIZE_BITS) + STREAM_ID_WIDTH) - 1:DATA_WIDTH + DATASIZE_BITS];
	assign s_stream_size = s_fifoout_stream[(DATA_WIDTH + DATASIZE_BITS) - 1:DATA_WIDTH];
	assign s_stream_data = s_fifoout_stream[DATA_WIDTH - 1:0];
	assign s_stream_ready_demux = s_stream_ready[s_stream_dest];
	assign s_stream_storel2 = s_is_stream & s_stream_use_buff;
	wire s_stream_direct;
	assign s_stream_direct = s_is_stream & !s_stream_use_buff;
	wire s_target_l2;
	assign s_target_l2 = s_stream_storel2 | ~s_is_stream;
	wire s_target_stream;
	assign s_target_stream = s_stream_direct;
	assign s_sample_indata = s_sample_indata_stream & s_sample_indata_l2;
	assign s_push_l2 = r_anygrant & s_target_l2;
	assign s_push_filter = r_anygrant & s_target_stream;
	assign l2_req_o = s_l2_req;
	wire s_l2_req_stream;
	assign s_l2_req_stream = s_l2_req & s_l2_is_stream;
	assign s_l2_addr_na = s_l2_addr[L2_AWIDTH_NOAL - 1:ALIGN_BITS] + 1;
	always @(*) begin
		if (!s_is_na)
			l2_addr_o = {{32 - L2_AWIDTH_NOAL {1'b0}}, s_l2_addr[L2_AWIDTH_NOAL - 1:ALIGN_BITS], {ALIGN_BITS {1'b0}}};
		else
			l2_addr_o = {{32 - L2_AWIDTH_NOAL {1'b0}}, s_l2_addr_na, {ALIGN_BITS {1'b0}}};
		case (s_l2_dest)
			2'b00: l2_addr_o[31:24] = 8'h1c;
			2'b01: l2_addr_o[31:20] = 12'h1a1;
			2'b10: l2_addr_o[31:24] = 8'h10;
			default: l2_addr_o[31:24] = 8'h1c;
		endcase
	end
	udma_arbiter #(
		.N(N_CHANNELS_RX),
		.S(LOG_N_CHANNELS)
	) u_arbiter(
		.clk_i(clk_i),
		.rstn_i(rstn_i),
		.req_i(s_req),
		.grant_o(s_grant),
		.grant_ack_i(s_sample_indata),
		.anyGrant_o(s_anygrant)
	);
	io_generic_fifo #(
		.DATA_WIDTH(INTFIFO_L2_SIZE),
		.BUFFER_DEPTH(4)
	) u_fifo(
		.clk_i(clk_i),
		.rstn_i(rstn_i),
		.elements_o(),
		.clr_i(1'b0),
		.data_o(s_fifoout),
		.valid_o(s_l2_req),
		.ready_i(s_l2_gnt),
		.valid_i(s_push_l2),
		.data_i(s_fifoin),
		.ready_o(s_sample_indata_l2)
	);
	wire s_stream_valid;
	io_generic_fifo #(
		.DATA_WIDTH(INTFIFO_FILTER_SIZE),
		.BUFFER_DEPTH(4)
	) u_filter_fifo(
		.clk_i(clk_i),
		.rstn_i(rstn_i),
		.elements_o(),
		.clr_i(1'b0),
		.data_o(s_fifoout_stream),
		.valid_o(s_stream_valid),
		.ready_i(s_stream_ready_demux),
		.valid_i(s_push_filter),
		.data_i(s_fifoin_stream),
		.ready_o(s_sample_indata_stream)
	);
	genvar j;
	generate
		for (j = 0; j < N_LIN_CHANNELS; j = j + 1) begin : genblk1
			udma_ch_addrgen #(
				.L2_AWIDTH_NOAL(L2_AWIDTH_NOAL),
				.TRANS_SIZE(TRANS_SIZE),
				.STREAM_ID_WIDTH(STREAM_ID_WIDTH)
			) u_rx_ch_ctrl(
				.clk_i(clk_i),
				.rstn_i(rstn_i),
				.cfg_startaddr_i(lin_ch_cfg_startaddr_i[j * L2_AWIDTH_NOAL+:L2_AWIDTH_NOAL]),
				.cfg_size_i(lin_ch_cfg_size_i[j * TRANS_SIZE+:TRANS_SIZE]),
				.cfg_continuous_i(lin_ch_cfg_continuous_i[j]),
				.cfg_stream_i(lin_ch_cfg_stream_i[j * 2+:2]),
				.cfg_stream_id_i(lin_ch_cfg_stream_id_i[j * STREAM_ID_WIDTH+:STREAM_ID_WIDTH]),
				.cfg_en_i(lin_ch_cfg_en_i[j]),
				.cfg_clr_i(lin_ch_cfg_clr_i[j]),
				.int_datasize_i(r_size),
				.int_not_stall_i(s_sample_indata),
				.int_ch_curr_addr_o(s_curr_addr[j * L2_AWIDTH_NOAL+:L2_AWIDTH_NOAL]),
				.int_ch_curr_bytes_o(s_curr_bytes[j * 2+:2]),
				.int_ch_bytes_left_o(lin_ch_bytes_left_o[j * TRANS_SIZE+:TRANS_SIZE]),
				.int_ch_grant_i(r_grant[j]),
				.int_ch_en_prev_o(s_ch_en[j]),
				.int_ch_pending_o(lin_ch_pending_o[j]),
				.int_ch_sot_o(s_ch_sot[j]),
				.int_ch_events_o(s_ch_events[j]),
				.int_stream_o(s_stream_cfg[j * 2+:2]),
				.int_stream_id_o(s_stream_id_cfg[j * STREAM_ID_WIDTH+:STREAM_ID_WIDTH])
			);
		end
	endgenerate
	genvar k;
	generate
		for (k = 0; k < N_STREAMS; k = k + 1) begin : genblk2
			udma_stream_unit #(
				.L2_AWIDTH_NOAL(L2_AWIDTH_NOAL),
				.STREAM_ID_WIDTH(STREAM_ID_WIDTH),
				.INST_ID(k)
			) i_stream_unit(
				.clk_i(clk_i),
				.rstn_i(rstn_i),
				.cmd_clr_i(1'b0),
				.tx_ch_req_o(tx_ch_req_o[k]),
				.tx_ch_addr_o(tx_ch_addr_o[k * L2_AWIDTH_NOAL+:L2_AWIDTH_NOAL]),
				.tx_ch_datasize_o(tx_ch_datasize_o[k * 2+:2]),
				.tx_ch_gnt_i(tx_ch_gnt_i[k]),
				.tx_ch_valid_i(tx_ch_valid_i[k]),
				.tx_ch_data_i(tx_ch_data_i[k * DATA_WIDTH+:DATA_WIDTH]),
				.tx_ch_ready_o(tx_ch_ready_o[k]),
				.in_stream_dest_i(s_stream_dest),
				.in_stream_data_i(s_stream_data),
				.in_stream_datasize_i(s_stream_size),
				.in_stream_valid_i(s_stream_valid),
				.in_stream_sot_i(s_stream_sot),
				.in_stream_eot_i(s_stream_eot),
				.in_stream_ready_o(s_stream_ready[k]),
				.out_stream_data_o(stream_data_o[k * DATA_WIDTH+:DATA_WIDTH]),
				.out_stream_datasize_o(stream_datasize_o[k * 2+:2]),
				.out_stream_valid_o(stream_valid_o[k]),
				.out_stream_sot_o(stream_sot_o[k]),
				.out_stream_eot_o(stream_eot_o[k]),
				.out_stream_ready_i(stream_ready_i[k]),
				.spoof_addr_i(s_l2_addr),
				.spoof_dest_i(s_l2_stream_id),
				.spoof_datasize_i(s_l2_transf_size),
				.spoof_req_i(s_l2_req_stream),
				.spoof_gnt_i(s_l2_gnt)
			);
		end
	endgenerate
	always @(*) begin
		s_grant_log = 0;
		begin : sv2v_autoblock_1
			reg signed [31:0] i;
			for (i = 0; i < N_CHANNELS_RX; i = i + 1)
				if (r_grant[i])
					s_grant_log = i;
		end
	end
	always @(*) begin : default_bytes
		case (r_size)
			2'b00: s_default_bytes = 'h0;
			2'b01: s_default_bytes = 'h1;
			2'b10: s_default_bytes = 'h3;
			default: s_default_bytes = 'h0;
		endcase
	end
	always @(*) begin : inside_mux
		s_addr = 'h0;
		s_bytes = 'h0;
		s_stream_id = 'h0;
		s_is_stream = 1'b0;
		s_stream_use_buff = 1'b0;
		s_eot = 1'b0;
		s_sot = 1'b0;
		begin : sv2v_autoblock_2
			reg signed [31:0] i;
			for (i = 0; i < N_LIN_CHANNELS; i = i + 1)
				if (r_grant[i]) begin
					s_addr = s_curr_addr[i * L2_AWIDTH_NOAL+:L2_AWIDTH_NOAL];
					s_bytes = s_curr_bytes[i * 2+:2];
					s_is_stream = s_stream_cfg[(i * 2) + 1];
					s_stream_use_buff = s_stream_cfg[i * 2];
					s_stream_id = s_stream_id_cfg[i * STREAM_ID_WIDTH+:STREAM_ID_WIDTH];
					s_eot = s_ch_events[i];
					s_sot = s_ch_sot[i];
				end
		end
		begin : sv2v_autoblock_3
			reg signed [31:0] i;
			for (i = 0; i < N_EXT_CHANNELS; i = i + 1)
				if (r_grant[N_LIN_CHANNELS + i]) begin
					s_addr = r_ext_addr;
					s_bytes = s_default_bytes;
					s_is_stream = r_ext_stream[1];
					s_stream_use_buff = r_ext_stream[0];
					s_stream_id = r_ext_stream_id;
					s_sot = r_ext_sot;
					s_eot = r_ext_eot;
				end
		end
	end
	always @(*) begin : input_mux
		s_size = 0;
		s_data = 0;
		s_dest = 0;
		begin : sv2v_autoblock_4
			reg signed [31:0] i;
			for (i = 0; i < N_LIN_CHANNELS; i = i + 1)
				if (s_grant[i]) begin
					s_size = lin_ch_datasize_i[i * 2+:2];
					s_data = lin_ch_data_i[i * DATA_WIDTH+:DATA_WIDTH];
					s_dest = lin_ch_destination_i[i * DEST_SIZE+:DEST_SIZE];
					lin_ch_ready_o[i] = s_sample_indata;
				end
				else
					lin_ch_ready_o[i] = 1'b0;
		end
		begin : sv2v_autoblock_5
			reg signed [31:0] i;
			for (i = 0; i < N_EXT_CHANNELS; i = i + 1)
				if (s_grant[N_LIN_CHANNELS + i]) begin
					ext_ch_ready_o[i] = s_sample_indata;
					s_size = ext_ch_datasize_i[i * 2+:2];
					s_data = ext_ch_data_i[i * DATA_WIDTH+:DATA_WIDTH];
					s_dest = ext_ch_destination_i[i * DEST_SIZE+:DEST_SIZE];
				end
				else
					ext_ch_ready_o[i] = 1'b0;
		end
	end
	always @(*) begin
		s_detect_na = 1'b0;
		case (s_l2_transf_size)
			2'h1:
				if (s_l2_addr[1:0] == 2'b11)
					s_detect_na = 1'b1;
			2'h2:
				if (s_l2_addr[0] || s_l2_addr[1])
					s_detect_na = 1'b1;
		endcase
	end
	always @(*) begin : proc_RX_SM
		s_rx_state_next = r_rx_state;
		s_l2_gnt = 1'b0;
		s_is_na = 1'b0;
		case (r_rx_state)
			1'd0:
				if (s_detect_na) begin
					s_l2_gnt = 1'b0;
					if (l2_gnt_i)
						s_rx_state_next = 1'd1;
				end
				else
					s_l2_gnt = l2_gnt_i;
			1'd1: begin
				s_is_na = 1'b1;
				s_l2_gnt = l2_gnt_i;
				if (l2_gnt_i)
					s_rx_state_next = 1'd0;
			end
		endcase
	end
	always @(posedge clk_i or negedge rstn_i) begin : ff_data
		if (~rstn_i) begin
			r_data <= 'h0;
			r_grant <= 'h0;
			r_anygrant <= 'h0;
			r_size <= 'h0;
			r_dest <= 'h0;
			r_ext_addr <= 'h0;
			r_ext_stream <= 'h0;
			r_ext_stream_id <= 'h0;
			r_ext_sot <= 'h0;
			r_ext_eot <= 'h0;
			r_rx_state <= 1'd0;
		end
		else begin
			r_rx_state <= s_rx_state_next;
			if (s_sample_indata) begin
				r_data <= s_data;
				r_size <= s_size;
				r_grant <= s_grant;
				r_anygrant <= s_anygrant;
				r_dest <= s_dest;
				begin : sv2v_autoblock_6
					reg signed [31:0] i;
					for (i = 0; i < N_EXT_CHANNELS; i = i + 1)
						if (s_grant[N_LIN_CHANNELS + i]) begin
							r_ext_addr <= ext_ch_addr_i[i * L2_AWIDTH_NOAL+:L2_AWIDTH_NOAL];
							r_ext_stream <= ext_ch_stream_i[i * 2+:2];
							r_ext_stream_id <= ext_ch_stream_id_i[i * STREAM_ID_WIDTH+:STREAM_ID_WIDTH];
							r_ext_sot <= ext_ch_sot_i[i];
							r_ext_eot <= ext_ch_eot_i[i];
						end
				end
			end
		end
	end
	generate
		if (L2_DATA_WIDTH == 64) begin : genblk3
			always @(*)
				case (s_l2_transf_size)
					2'h0:
						if (s_l2_addr[2:0] == 3'b000)
							s_l2_be = 8'b00000001;
						else if (s_l2_addr[2:0] == 3'b001)
							s_l2_be = 8'b00000010;
						else if (s_l2_addr[2:0] == 3'b010)
							s_l2_be = 8'b00000100;
						else if (s_l2_addr[2:0] == 3'b011)
							s_l2_be = 8'b00001000;
						else if (s_l2_addr[2:0] == 3'b100)
							s_l2_be = 8'b00010000;
						else if (s_l2_addr[2:0] == 3'b101)
							s_l2_be = 8'b00100000;
						else if (s_l2_addr[2:0] == 3'b110)
							s_l2_be = 8'b01000000;
						else
							s_l2_be = 8'b10000000;
					2'h1:
						if (s_l2_addr[2:1] == 2'b00)
							s_l2_be = 8'b00000011;
						else if (s_l2_addr[2:1] == 2'b01)
							s_l2_be = 8'b00001100;
						else if (s_l2_addr[2:1] == 2'b10)
							s_l2_be = 8'b00110000;
						else
							s_l2_be = 8'b11000000;
					2'h2:
						if (s_l2_addr[2] == 1'b0)
							s_l2_be = 8'b00001111;
						else
							s_l2_be = 8'b11110000;
					default: s_l2_be = 8'b00000000;
				endcase
			always @(*)
				case (s_l2_be)
					8'b00001111: l2_wdata_o = {32'h00000000, s_l2_data[31:0]};
					8'b11110000: l2_wdata_o = {s_l2_data[31:0], 32'h00000000};
					8'b00000011: l2_wdata_o = {48'h000000000000, s_l2_data[15:0]};
					8'b00001100: l2_wdata_o = {32'h00000000, s_l2_data[15:0], 16'h0000};
					8'b00110000: l2_wdata_o = {16'h0000, s_l2_data[15:0], 32'h00000000};
					8'b11000000: l2_wdata_o = {s_l2_data[15:0], 48'h000000000000};
					8'b00000001: l2_wdata_o = {56'h00000000000000, s_l2_data[7:0]};
					8'b00000010: l2_wdata_o = {48'h000000000000, s_l2_data[7:0], 8'h00};
					8'b00000100: l2_wdata_o = {40'h0000000000, s_l2_data[7:0], 16'h0000};
					8'b00001000: l2_wdata_o = {32'h00000000, s_l2_data[7:0], 24'h000000};
					8'b00010000: l2_wdata_o = {24'h000000, s_l2_data[7:0], 32'h00000000};
					8'b00100000: l2_wdata_o = {16'h0000, s_l2_data[7:0], 40'h0000000000};
					8'b01000000: l2_wdata_o = {8'h00, s_l2_data[7:0], 48'h000000000000};
					8'b10000000: l2_wdata_o = {s_l2_data[7:0], 56'h00000000000000};
					default: l2_wdata_o = 64'hdeadabbadeadbeef;
				endcase
		end
		else if (L2_DATA_WIDTH == 32) begin : genblk3
			always @(*)
				case (s_l2_transf_size)
					2'h0:
						if (s_l2_addr[1:0] == 2'b00)
							s_l2_be = 4'b0001;
						else if (s_l2_addr[1:0] == 2'b01)
							s_l2_be = 4'b0010;
						else if (s_l2_addr[1:0] == 2'b10)
							s_l2_be = 4'b0100;
						else
							s_l2_be = 4'b1000;
					2'h1:
						if (s_l2_bytes == 2'h0) begin
							if (s_l2_addr[1:0] == 2'b00)
								s_l2_be = 4'b0001;
							else if (s_l2_addr[1:0] == 2'b01)
								s_l2_be = 4'b0010;
							else if (s_l2_addr[1:0] == 2'b10)
								s_l2_be = 4'b0100;
							else
								s_l2_be = (s_is_na ? 4'b0000 : 4'b1000);
						end
						else if (s_l2_addr[1:0] == 2'b00)
							s_l2_be = 4'b0011;
						else if (s_l2_addr[1:0] == 2'b01)
							s_l2_be = 4'b0110;
						else if (s_l2_addr[1:0] == 2'b10)
							s_l2_be = 4'b1100;
						else
							s_l2_be = (s_is_na ? 4'b0001 : 4'b1000);
					2'h2:
						if (s_l2_bytes == 2'h0) begin
							if (s_l2_addr[1:0] == 2'b00)
								s_l2_be = 4'b0001;
							else if (s_l2_addr[1:0] == 2'b01)
								s_l2_be = (s_is_na ? 4'b0000 : 4'b0010);
							else if (s_l2_addr[1:0] == 2'b10)
								s_l2_be = (s_is_na ? 4'b0000 : 4'b0100);
							else
								s_l2_be = (s_is_na ? 4'b0000 : 4'b1000);
						end
						else if (s_l2_bytes == 2'h1) begin
							if (s_l2_addr[1:0] == 2'b00)
								s_l2_be = 4'b0011;
							else if (s_l2_addr[1:0] == 2'b01)
								s_l2_be = (s_is_na ? 4'b0000 : 4'b0110);
							else if (s_l2_addr[1:0] == 2'b10)
								s_l2_be = (s_is_na ? 4'b0000 : 4'b1100);
							else
								s_l2_be = (s_is_na ? 4'b0001 : 4'b1000);
						end
						else if (s_l2_bytes == 2'h2) begin
							if (s_l2_addr[1:0] == 2'b00)
								s_l2_be = 4'b0111;
							else if (s_l2_addr[1:0] == 2'b01)
								s_l2_be = (s_is_na ? 4'b0000 : 4'b1110);
							else if (s_l2_addr[1:0] == 2'b10)
								s_l2_be = (s_is_na ? 4'b0001 : 4'b1100);
							else
								s_l2_be = (s_is_na ? 4'b0011 : 4'b1000);
						end
						else if (s_l2_addr[1:0] == 2'b00)
							s_l2_be = 4'b1111;
						else if (s_l2_addr[1:0] == 2'b01)
							s_l2_be = (s_is_na ? 4'b0001 : 4'b1110);
						else if (s_l2_addr[1:0] == 2'b10)
							s_l2_be = (s_is_na ? 4'b0011 : 4'b1100);
						else
							s_l2_be = (s_is_na ? 4'b0111 : 4'b1000);
					default: s_l2_be = 4'b0000;
				endcase
			always @(*)
				case (s_l2_transf_size)
					2'h0:
						if (s_l2_addr[1:0] == 2'b00)
							l2_wdata_o = {24'h000000, s_l2_data[7:0]};
						else if (s_l2_addr[1:0] == 2'b01)
							l2_wdata_o = {16'h0000, s_l2_data[7:0], 8'h00};
						else if (s_l2_addr[1:0] == 2'b10)
							l2_wdata_o = {8'h00, s_l2_data[7:0], 16'h0000};
						else
							l2_wdata_o = {s_l2_data[7:0], 24'h000000};
					2'h1:
						if (s_l2_addr[1:0] == 2'b00)
							l2_wdata_o = {16'h0000, s_l2_data[15:0]};
						else if (s_l2_addr[1:0] == 2'b01)
							l2_wdata_o = {8'h00, s_l2_data[15:0], 8'h00};
						else if (s_l2_addr[1:0] == 2'b10)
							l2_wdata_o = {s_l2_data[15:0], 16'h0000};
						else
							l2_wdata_o = (s_is_na ? {24'h000000, s_l2_data[15:8]} : {s_l2_data[7:0], 24'h000000});
					2'h2:
						if (s_l2_addr[1:0] == 2'b00)
							l2_wdata_o = s_l2_data[31:0];
						else if (s_l2_addr[1:0] == 2'b01)
							l2_wdata_o = (s_is_na ? {24'h000000, s_l2_data[31:24]} : {s_l2_data[23:0], 8'h00});
						else if (s_l2_addr[1:0] == 2'b10)
							l2_wdata_o = (s_is_na ? {16'h0000, s_l2_data[31:16]} : {s_l2_data[15:0], 16'h0000});
						else
							l2_wdata_o = (s_is_na ? {8'h00, s_l2_data[31:8]} : {s_l2_data[7:0], 24'h000000});
					default: l2_wdata_o = 32'hdeadbeef;
				endcase
		end
	endgenerate
endmodule
