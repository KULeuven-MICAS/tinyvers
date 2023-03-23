module udma_tx_channels (
	clk_i,
	rstn_i,
	l2_req_o,
	l2_gnt_i,
	l2_addr_o,
	l2_rdata_i,
	l2_rvalid_i,
	ext_req_i,
	ext_addr_i,
	ext_datasize_i,
	ext_destination_i,
	ext_gnt_o,
	ext_valid_o,
	ext_data_o,
	ext_ready_i,
	lin_datasize_i,
	lin_destination_i,
	lin_req_i,
	lin_gnt_o,
	lin_valid_o,
	lin_data_o,
	lin_ready_i,
	lin_events_o,
	lin_en_o,
	lin_pending_o,
	lin_curr_addr_o,
	lin_bytes_left_o,
	lin_cfg_startaddr_i,
	lin_cfg_size_i,
	lin_cfg_continuous_i,
	lin_cfg_en_i,
	lin_cfg_clr_i
);
	parameter L2_AWIDTH_NOAL = 20;
	parameter L2_DATA_WIDTH = 64;
	parameter DATA_WIDTH = 32;
	parameter N_LIN_CHANNELS = 8;
	parameter N_EXT_CHANNELS = 8;
	parameter TRANS_SIZE = 16;
	parameter STREAM_ID_WIDTH = 1;
	input wire clk_i;
	input wire rstn_i;
	output wire l2_req_o;
	input wire l2_gnt_i;
	output reg [31:0] l2_addr_o;
	input wire [L2_DATA_WIDTH - 1:0] l2_rdata_i;
	input wire l2_rvalid_i;
	input wire [N_EXT_CHANNELS - 1:0] ext_req_i;
	input wire [(N_EXT_CHANNELS * L2_AWIDTH_NOAL) - 1:0] ext_addr_i;
	input wire [(N_EXT_CHANNELS * 2) - 1:0] ext_datasize_i;
	input wire [(N_EXT_CHANNELS * 2) - 1:0] ext_destination_i;
	output wire [N_EXT_CHANNELS - 1:0] ext_gnt_o;
	output reg [N_EXT_CHANNELS - 1:0] ext_valid_o;
	output reg [(N_EXT_CHANNELS * DATA_WIDTH) - 1:0] ext_data_o;
	input wire [N_EXT_CHANNELS - 1:0] ext_ready_i;
	input wire [(N_LIN_CHANNELS * 2) - 1:0] lin_datasize_i;
	input wire [(N_LIN_CHANNELS * 2) - 1:0] lin_destination_i;
	input wire [N_LIN_CHANNELS - 1:0] lin_req_i;
	output wire [N_LIN_CHANNELS - 1:0] lin_gnt_o;
	output reg [N_LIN_CHANNELS - 1:0] lin_valid_o;
	output reg [(N_LIN_CHANNELS * DATA_WIDTH) - 1:0] lin_data_o;
	input wire [N_LIN_CHANNELS - 1:0] lin_ready_i;
	output wire [N_LIN_CHANNELS - 1:0] lin_events_o;
	output wire [N_LIN_CHANNELS - 1:0] lin_en_o;
	output wire [N_LIN_CHANNELS - 1:0] lin_pending_o;
	output wire [(N_LIN_CHANNELS * L2_AWIDTH_NOAL) - 1:0] lin_curr_addr_o;
	output wire [(N_LIN_CHANNELS * TRANS_SIZE) - 1:0] lin_bytes_left_o;
	input wire [(N_LIN_CHANNELS * L2_AWIDTH_NOAL) - 1:0] lin_cfg_startaddr_i;
	input wire [(N_LIN_CHANNELS * TRANS_SIZE) - 1:0] lin_cfg_size_i;
	input wire [N_LIN_CHANNELS - 1:0] lin_cfg_continuous_i;
	input wire [N_LIN_CHANNELS - 1:0] lin_cfg_en_i;
	input wire [N_LIN_CHANNELS - 1:0] lin_cfg_clr_i;
	localparam DATASIZE_WIDTH = 2;
	localparam DEST_WIDTH = 2;
	localparam N_CHANNELS_TX = N_LIN_CHANNELS + N_EXT_CHANNELS;
	localparam ALIGN_BITS = $clog2(L2_DATA_WIDTH / 8);
	localparam LOG_N_CHANNELS = $clog2(N_CHANNELS_TX);
	localparam INTFIFO_SIZE = ((L2_AWIDTH_NOAL + LOG_N_CHANNELS) + DATASIZE_WIDTH) + DEST_WIDTH;
	integer i;
	wire [N_CHANNELS_TX - 1:0] s_grant;
	reg [N_CHANNELS_TX - 1:0] r_grant;
	wire [N_CHANNELS_TX - 1:0] s_req;
	wire [N_CHANNELS_TX - 1:0] s_gnt;
	reg [LOG_N_CHANNELS - 1:0] s_grant_log;
	wire [N_CHANNELS_TX - 1:0] s_ch_ready;
	wire [N_LIN_CHANNELS - 1:0] s_ch_en;
	reg [LOG_N_CHANNELS - 1:0] r_resp;
	reg [LOG_N_CHANNELS - 1:0] r_resp_dly;
	reg r_valid;
	wire s_anygrant;
	reg r_anygrant;
	wire s_send_req;
	reg [L2_AWIDTH_NOAL - 1:0] s_addr;
	wire [(N_CHANNELS_TX * L2_AWIDTH_NOAL) - 1:0] s_curr_addr;
	reg [L2_AWIDTH_NOAL - 1:0] r_in_addr;
	wire [1:0] s_size;
	reg [DATA_WIDTH - 1:0] s_data;
	reg [1:0] r_size;
	reg [DATA_WIDTH - 1:0] r_data;
	reg [ALIGN_BITS - 1:0] r_addr;
	reg [1:0] s_in_size;
	reg [1:0] r_in_size;
	reg [1:0] s_in_dest;
	reg [1:0] r_in_dest;
	wire [INTFIFO_SIZE - 1:0] s_fifoin;
	wire [INTFIFO_SIZE - 1:0] s_fifoout;
	wire [ALIGN_BITS - 1:0] s_fifo_addr_lsb;
	wire [L2_AWIDTH_NOAL - 1:0] s_fifo_l2_addr;
	wire [1:0] s_fifo_l2_dest;
	wire [1:0] s_fifo_trans_size;
	wire [LOG_N_CHANNELS - 1:0] s_fifo_resp;
	wire [(L2_AWIDTH_NOAL - ALIGN_BITS) - 1:0] s_l2_addr_na;
	wire s_l2_req;
	reg s_l2_gnt;
	wire s_stall;
	wire s_sample_indata;
	reg s_is_na;
	reg r_is_na;
	reg s_detect_na;
	reg r_tx_state;
	reg s_tx_state_next;
	assign lin_curr_addr_o = s_curr_addr;
	assign lin_en_o = s_ch_en;
	assign s_fifoin = {r_in_dest, s_grant_log, r_in_size, s_addr[L2_AWIDTH_NOAL - 1:0]};
	assign s_fifo_l2_addr = s_fifoout[L2_AWIDTH_NOAL - 1:0];
	assign s_fifo_addr_lsb = s_fifoout[ALIGN_BITS - 1:0];
	assign s_fifo_trans_size = s_fifoout[(L2_AWIDTH_NOAL + DATASIZE_WIDTH) - 1:L2_AWIDTH_NOAL];
	assign s_fifo_resp = s_fifoout[((L2_AWIDTH_NOAL + DATASIZE_WIDTH) + LOG_N_CHANNELS) - 1:L2_AWIDTH_NOAL + DATASIZE_WIDTH];
	assign s_fifo_l2_dest = s_fifoout[INTFIFO_SIZE - 1:(L2_AWIDTH_NOAL + DATASIZE_WIDTH) + LOG_N_CHANNELS];
	assign s_l2_addr_na = s_fifo_l2_addr[L2_AWIDTH_NOAL - 1:ALIGN_BITS] + 1;
	assign s_req[N_LIN_CHANNELS - 1:0] = lin_req_i & s_ch_en;
	assign s_req[N_CHANNELS_TX - 1:N_LIN_CHANNELS] = ext_req_i;
	assign s_gnt = (s_sample_indata ? s_grant : 'h0);
	assign s_send_req = r_anygrant;
	assign l2_req_o = s_l2_req & ~s_stall;
	assign lin_gnt_o = s_gnt[N_LIN_CHANNELS - 1:0];
	assign ext_gnt_o = s_gnt[N_CHANNELS_TX - 1:N_LIN_CHANNELS];
	always @(*) begin
		if (!s_is_na)
			l2_addr_o = {{32 - L2_AWIDTH_NOAL {1'b0}}, s_fifo_l2_addr[L2_AWIDTH_NOAL - 1:ALIGN_BITS], {ALIGN_BITS {1'b0}}};
		else
			l2_addr_o = {{32 - L2_AWIDTH_NOAL {1'b0}}, s_l2_addr_na, {ALIGN_BITS {1'b0}}};
		case (s_fifo_l2_dest)
			2'b00: l2_addr_o[31:24] = 8'h1c;
			2'b01: l2_addr_o[31:20] = 12'h1a1;
			2'b10: l2_addr_o[31:24] = 8'h10;
			default: l2_addr_o[31:24] = 8'h1c;
		endcase
	end
	udma_arbiter #(
		.N(N_CHANNELS_TX),
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
		.DATA_WIDTH(INTFIFO_SIZE),
		.BUFFER_DEPTH(4)
	) u_fifo(
		.clk_i(clk_i),
		.rstn_i(rstn_i),
		.elements_o(),
		.clr_i(1'b0),
		.data_o(s_fifoout),
		.valid_o(s_l2_req),
		.ready_i(s_l2_gnt),
		.valid_i(s_send_req),
		.data_i(s_fifoin),
		.ready_o(s_sample_indata)
	);
	genvar j;
	generate
		for (j = 0; j < N_LIN_CHANNELS; j = j + 1) begin : genblk1
			udma_ch_addrgen #(
				.L2_AWIDTH_NOAL(L2_AWIDTH_NOAL),
				.TRANS_SIZE(TRANS_SIZE),
				.STREAM_ID_WIDTH(STREAM_ID_WIDTH)
			) u_tx_ch_ctrl(
				.clk_i(clk_i),
				.rstn_i(rstn_i),
				.cfg_startaddr_i(lin_cfg_startaddr_i[j * L2_AWIDTH_NOAL+:L2_AWIDTH_NOAL]),
				.cfg_size_i(lin_cfg_size_i[j * TRANS_SIZE+:TRANS_SIZE]),
				.cfg_continuous_i(lin_cfg_continuous_i[j]),
				.cfg_stream_i(2'b00),
				.cfg_stream_id_i({STREAM_ID_WIDTH {1'b0}}),
				.cfg_en_i(lin_cfg_en_i[j]),
				.cfg_clr_i(lin_cfg_clr_i[j]),
				.int_datasize_i(r_in_size),
				.int_not_stall_i(s_sample_indata),
				.int_ch_curr_addr_o(s_curr_addr[j * L2_AWIDTH_NOAL+:L2_AWIDTH_NOAL]),
				.int_ch_bytes_left_o(lin_bytes_left_o[j * TRANS_SIZE+:TRANS_SIZE]),
				.int_ch_grant_i(r_grant[j]),
				.int_ch_en_prev_o(s_ch_en[j]),
				.int_ch_pending_o(lin_pending_o[j]),
				.int_ch_events_o(lin_events_o[j])
			);
		end
	endgenerate
	always @(*) begin
		s_grant_log = 0;
		begin : sv2v_autoblock_1
			reg signed [31:0] i;
			for (i = 0; i < N_CHANNELS_TX; i = i + 1)
				if (r_grant[i])
					s_grant_log = i;
		end
	end
	always @(*) begin : inside_mux
		s_addr = 'h0;
		begin : sv2v_autoblock_2
			reg signed [31:0] i;
			for (i = 0; i < N_LIN_CHANNELS; i = i + 1)
				if (r_grant[i])
					s_addr = s_curr_addr[i * L2_AWIDTH_NOAL+:L2_AWIDTH_NOAL];
		end
		begin : sv2v_autoblock_3
			reg signed [31:0] i;
			for (i = 0; i < N_EXT_CHANNELS; i = i + 1)
				if (r_grant[N_LIN_CHANNELS + i])
					s_addr = r_in_addr;
		end
	end
	always @(*) begin : gen_size
		s_in_size = 0;
		s_in_dest = 0;
		begin : sv2v_autoblock_4
			reg signed [31:0] i;
			for (i = 0; i < N_LIN_CHANNELS; i = i + 1)
				if (s_grant[i]) begin
					s_in_size = lin_datasize_i[i * 2+:2];
					s_in_dest = lin_destination_i[i * 2+:2];
				end
		end
		begin : sv2v_autoblock_5
			reg signed [31:0] i;
			for (i = 0; i < N_EXT_CHANNELS; i = i + 1)
				if (s_grant[N_LIN_CHANNELS + i]) begin
					s_in_size = ext_datasize_i[i * 2+:2];
					s_in_dest = ext_destination_i[i * 2+:2];
				end
		end
	end
	always @(*) begin : demux_data
		begin : sv2v_autoblock_6
			reg signed [31:0] i;
			for (i = 0; i < N_LIN_CHANNELS; i = i + 1)
				if (r_resp_dly == i) begin
					lin_valid_o[i] = r_valid;
					lin_data_o[i * DATA_WIDTH+:DATA_WIDTH] = r_data;
				end
				else begin
					lin_valid_o[i] = 1'b0;
					lin_data_o[i * DATA_WIDTH+:DATA_WIDTH] = 'hdeadbeef;
				end
		end
		begin : sv2v_autoblock_7
			reg signed [31:0] i;
			for (i = 0; i < N_EXT_CHANNELS; i = i + 1)
				if (r_resp_dly == (N_LIN_CHANNELS + i)) begin
					ext_valid_o[i] = r_valid;
					ext_data_o[i * DATA_WIDTH+:DATA_WIDTH] = r_data;
				end
				else begin
					ext_valid_o[i] = 1'b0;
					ext_data_o[i * DATA_WIDTH+:DATA_WIDTH] = 'hdeadbeef;
				end
		end
	end
	assign s_ch_ready[N_LIN_CHANNELS - 1:0] = lin_ready_i;
	assign s_ch_ready[N_CHANNELS_TX - 1:N_LIN_CHANNELS] = ext_ready_i;
	assign s_stall = |(~s_ch_ready & r_resp) & r_valid;
	always @(posedge clk_i or negedge rstn_i) begin : ff_data
		if (~rstn_i) begin
			r_grant <= 1'sb0;
			r_anygrant <= 1'sb0;
			r_resp <= 1'sb0;
			r_resp_dly <= 1'sb0;
			r_valid <= 1'sb0;
			r_in_size <= 1'sb0;
			r_in_dest <= 1'sb0;
			r_size <= 1'sb0;
			r_addr <= 1'sb0;
			r_data <= 1'sb0;
			r_in_addr <= 1'sb0;
			r_is_na <= 1'sb0;
			r_tx_state <= 1'd0;
		end
		else begin
			r_tx_state <= s_tx_state_next;
			r_valid <= l2_rvalid_i & ~s_is_na;
			r_resp_dly <= r_resp;
			r_is_na <= s_is_na;
			if (l2_rvalid_i)
				r_data <= s_data;
			if ((s_l2_req && l2_gnt_i) && !s_is_na) begin
				r_resp <= s_fifo_resp;
				r_size <= s_fifo_trans_size;
				r_addr <= s_fifo_addr_lsb;
			end
			if (s_sample_indata) begin
				r_in_size <= s_in_size;
				r_in_dest <= s_in_dest;
				r_grant <= s_grant;
				r_anygrant <= s_anygrant;
				begin : sv2v_autoblock_8
					reg signed [31:0] i;
					for (i = 0; i < N_EXT_CHANNELS; i = i + 1)
						if (s_grant[N_LIN_CHANNELS + i])
							r_in_addr <= ext_addr_i[i * L2_AWIDTH_NOAL+:L2_AWIDTH_NOAL];
				end
			end
		end
	end
	always @(*) begin : proc_TX_SM
		s_tx_state_next = r_tx_state;
		s_l2_gnt = 1'b0;
		s_is_na = 1'b0;
		case (r_tx_state)
			1'd0:
				if (s_detect_na) begin
					s_l2_gnt = 1'b0;
					if (l2_gnt_i)
						s_tx_state_next = 1'd1;
				end
				else
					s_l2_gnt = l2_gnt_i;
			1'd1: begin
				s_is_na = 1'b1;
				s_l2_gnt = l2_gnt_i;
				if (l2_gnt_i)
					s_tx_state_next = 1'd0;
			end
		endcase
	end
	always @(*) begin
		s_detect_na = 1'b0;
		case (s_fifo_trans_size)
			2'h1:
				if (s_fifo_addr_lsb == 2'b11)
					s_detect_na = 1'b1;
			2'h2:
				if (s_fifo_addr_lsb[0] || s_fifo_addr_lsb[1])
					s_detect_na = 1'b1;
		endcase
	end
	generate
		if (L2_DATA_WIDTH == 64) begin : genblk2
			always @(*)
				case (r_size)
					2'h0:
						if (r_addr == 3'b000)
							s_data = {24'h000000, l2_rdata_i[7:0]};
						else if (r_addr == 3'b001)
							s_data = {24'h000000, l2_rdata_i[15:8]};
						else if (r_addr == 3'b010)
							s_data = {24'h000000, l2_rdata_i[23:16]};
						else if (r_addr == 3'b011)
							s_data = {24'h000000, l2_rdata_i[31:24]};
						else if (r_addr == 3'b100)
							s_data = {24'h000000, l2_rdata_i[39:32]};
						else if (r_addr == 3'b101)
							s_data = {24'h000000, l2_rdata_i[47:40]};
						else if (r_addr == 3'b110)
							s_data = {24'h000000, l2_rdata_i[55:48]};
						else
							s_data = {24'h000000, l2_rdata_i[63:56]};
					2'h1:
						if (r_addr[2:1] == 2'b00)
							s_data = {16'h0000, l2_rdata_i[15:0]};
						else if (r_addr[2:1] == 2'b01)
							s_data = {16'h0000, l2_rdata_i[31:16]};
						else if (r_addr[2:1] == 2'b10)
							s_data = {16'h0000, l2_rdata_i[47:32]};
						else
							s_data = {16'h0000, l2_rdata_i[63:48]};
					2'h2:
						if (r_addr[2] == 1'b0)
							s_data = l2_rdata_i[31:0];
						else
							s_data = l2_rdata_i[63:32];
					default: s_data = 32'hdeadbeef;
				endcase
		end
		else if (L2_DATA_WIDTH == 32) begin : genblk2
			always @(*) begin
				s_data = r_data;
				case (r_size)
					2'h0:
						if (r_addr[1:0] == 2'b00)
							s_data = {24'h000000, l2_rdata_i[7:0]};
						else if (r_addr[1:0] == 2'b01)
							s_data = {24'h000000, l2_rdata_i[15:8]};
						else if (r_addr[1:0] == 2'b10)
							s_data = {24'h000000, l2_rdata_i[23:16]};
						else
							s_data = {24'h000000, l2_rdata_i[31:24]};
					2'h1:
						if (s_is_na)
							s_data = {24'h000000, l2_rdata_i[31:24]};
						else if (r_is_na)
							s_data[15:8] = l2_rdata_i[7:0];
						else if (r_addr[1:0] == 2'b00)
							s_data = {16'h0000, l2_rdata_i[15:0]};
						else if (r_addr[1:0] == 2'b01)
							s_data = {16'h0000, l2_rdata_i[23:8]};
						else
							s_data = {16'h0000, l2_rdata_i[31:16]};
					2'h2:
						if (s_is_na) begin
							if (r_addr[1:0] == 2'b01)
								s_data = {8'h00, l2_rdata_i[31:8]};
							else if (r_addr[1:0] == 2'b10)
								s_data = {16'h0000, l2_rdata_i[31:16]};
							else
								s_data = {24'h000000, l2_rdata_i[31:24]};
						end
						else if (r_is_na) begin
							if (r_addr[1:0] == 2'b01)
								s_data[31:24] = l2_rdata_i[7:0];
							else if (r_addr[1:0] == 2'b10)
								s_data[31:16] = l2_rdata_i[15:0];
							else
								s_data[31:8] = l2_rdata_i[23:0];
						end
						else
							s_data = l2_rdata_i;
					default: s_data = 32'hdeadbeef;
				endcase
			end
		end
	endgenerate
endmodule
