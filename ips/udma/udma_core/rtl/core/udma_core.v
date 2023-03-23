module udma_core (
	sys_clk_i,
	per_clk_i,
	dft_cg_enable_i,
	HRESETn,
	PADDR,
	PWDATA,
	PWRITE,
	PSEL,
	PENABLE,
	PRDATA,
	PREADY,
	PSLVERR,
	event_valid_i,
	event_data_i,
	event_ready_o,
	event_o,
	periph_per_clk_o,
	periph_sys_clk_o,
	periph_data_to_o,
	periph_addr_o,
	periph_rwn_o,
	periph_data_from_i,
	periph_valid_o,
	periph_ready_i,
	rx_l2_req_o,
	rx_l2_gnt_i,
	rx_l2_addr_o,
	rx_l2_be_o,
	rx_l2_wdata_o,
	tx_l2_req_o,
	tx_l2_gnt_i,
	tx_l2_addr_o,
	tx_l2_rdata_i,
	tx_l2_rvalid_i,
	stream_data_o,
	stream_datasize_o,
	stream_valid_o,
	stream_sot_o,
	stream_eot_o,
	stream_ready_i,
	rx_lin_valid_i,
	rx_lin_data_i,
	rx_lin_datasize_i,
	rx_lin_destination_i,
	rx_lin_ready_o,
	rx_lin_events_o,
	rx_lin_en_o,
	rx_lin_pending_o,
	rx_lin_curr_addr_o,
	rx_lin_bytes_left_o,
	rx_lin_cfg_startaddr_i,
	rx_lin_cfg_size_i,
	rx_lin_cfg_continuous_i,
	rx_lin_cfg_en_i,
	rx_lin_cfg_stream_i,
	rx_lin_cfg_stream_id_i,
	rx_lin_cfg_clr_i,
	rx_ext_addr_i,
	rx_ext_datasize_i,
	rx_ext_destination_i,
	rx_ext_stream_i,
	rx_ext_stream_id_i,
	rx_ext_sot_i,
	rx_ext_eot_i,
	rx_ext_valid_i,
	rx_ext_data_i,
	rx_ext_ready_o,
	tx_lin_req_i,
	tx_lin_gnt_o,
	tx_lin_valid_o,
	tx_lin_data_o,
	tx_lin_ready_i,
	tx_lin_datasize_i,
	tx_lin_destination_i,
	tx_lin_events_o,
	tx_lin_en_o,
	tx_lin_pending_o,
	tx_lin_curr_addr_o,
	tx_lin_bytes_left_o,
	tx_lin_cfg_startaddr_i,
	tx_lin_cfg_size_i,
	tx_lin_cfg_continuous_i,
	tx_lin_cfg_en_i,
	tx_lin_cfg_clr_i,
	tx_ext_req_i,
	tx_ext_datasize_i,
	tx_ext_destination_i,
	tx_ext_addr_i,
	tx_ext_gnt_o,
	tx_ext_valid_o,
	tx_ext_data_o,
	tx_ext_ready_i
);
	parameter L2_DATA_WIDTH = 64;
	parameter L2_AWIDTH_NOAL = 16;
	parameter DATA_WIDTH = 32;
	parameter APB_ADDR_WIDTH = 12;
	parameter N_RX_LIN_CHANNELS = 8;
	parameter N_RX_EXT_CHANNELS = 8;
	parameter N_TX_LIN_CHANNELS = 8;
	parameter N_TX_EXT_CHANNELS = 8;
	parameter N_PERIPHS = 8;
	parameter N_STREAMS = 4;
	parameter DEST_SIZE = 2;
	parameter STREAM_ID_WIDTH = 3;
	parameter TRANS_SIZE = 16;
	input wire sys_clk_i;
	input wire per_clk_i;
	input wire dft_cg_enable_i;
	input wire HRESETn;
	input wire [APB_ADDR_WIDTH - 1:0] PADDR;
	input wire [31:0] PWDATA;
	input wire PWRITE;
	input wire PSEL;
	input wire PENABLE;
	output wire [31:0] PRDATA;
	output wire PREADY;
	output wire PSLVERR;
	input wire event_valid_i;
	input wire [7:0] event_data_i;
	output wire event_ready_o;
	output wire [3:0] event_o;
	output wire [N_PERIPHS - 1:0] periph_per_clk_o;
	output wire [N_PERIPHS - 1:0] periph_sys_clk_o;
	output wire [31:0] periph_data_to_o;
	output wire [4:0] periph_addr_o;
	output wire periph_rwn_o;
	input wire [(N_PERIPHS * 32) - 1:0] periph_data_from_i;
	output wire [N_PERIPHS - 1:0] periph_valid_o;
	input wire [N_PERIPHS - 1:0] periph_ready_i;
	output wire rx_l2_req_o;
	input wire rx_l2_gnt_i;
	output wire [31:0] rx_l2_addr_o;
	output wire [(L2_DATA_WIDTH / 8) - 1:0] rx_l2_be_o;
	output wire [L2_DATA_WIDTH - 1:0] rx_l2_wdata_o;
	output wire tx_l2_req_o;
	input wire tx_l2_gnt_i;
	output wire [31:0] tx_l2_addr_o;
	input wire [L2_DATA_WIDTH - 1:0] tx_l2_rdata_i;
	input wire tx_l2_rvalid_i;
	output wire [(N_STREAMS * DATA_WIDTH) - 1:0] stream_data_o;
	output wire [(N_STREAMS * 2) - 1:0] stream_datasize_o;
	output wire [N_STREAMS - 1:0] stream_valid_o;
	output wire [N_STREAMS - 1:0] stream_sot_o;
	output wire [N_STREAMS - 1:0] stream_eot_o;
	input wire [N_STREAMS - 1:0] stream_ready_i;
	input wire [N_RX_LIN_CHANNELS - 1:0] rx_lin_valid_i;
	input wire [(N_RX_LIN_CHANNELS * DATA_WIDTH) - 1:0] rx_lin_data_i;
	input wire [(N_RX_LIN_CHANNELS * 2) - 1:0] rx_lin_datasize_i;
	input wire [(N_RX_LIN_CHANNELS * DEST_SIZE) - 1:0] rx_lin_destination_i;
	output wire [N_RX_LIN_CHANNELS - 1:0] rx_lin_ready_o;
	output wire [N_RX_LIN_CHANNELS - 1:0] rx_lin_events_o;
	output wire [N_RX_LIN_CHANNELS - 1:0] rx_lin_en_o;
	output wire [N_RX_LIN_CHANNELS - 1:0] rx_lin_pending_o;
	output wire [(N_RX_LIN_CHANNELS * L2_AWIDTH_NOAL) - 1:0] rx_lin_curr_addr_o;
	output wire [(N_RX_LIN_CHANNELS * TRANS_SIZE) - 1:0] rx_lin_bytes_left_o;
	input wire [(N_RX_LIN_CHANNELS * L2_AWIDTH_NOAL) - 1:0] rx_lin_cfg_startaddr_i;
	input wire [(N_RX_LIN_CHANNELS * TRANS_SIZE) - 1:0] rx_lin_cfg_size_i;
	input wire [N_RX_LIN_CHANNELS - 1:0] rx_lin_cfg_continuous_i;
	input wire [N_RX_LIN_CHANNELS - 1:0] rx_lin_cfg_en_i;
	input wire [(N_RX_LIN_CHANNELS * 2) - 1:0] rx_lin_cfg_stream_i;
	input wire [(N_RX_LIN_CHANNELS * STREAM_ID_WIDTH) - 1:0] rx_lin_cfg_stream_id_i;
	input wire [N_RX_LIN_CHANNELS - 1:0] rx_lin_cfg_clr_i;
	input wire [(N_RX_EXT_CHANNELS * L2_AWIDTH_NOAL) - 1:0] rx_ext_addr_i;
	input wire [(N_RX_EXT_CHANNELS * 2) - 1:0] rx_ext_datasize_i;
	input wire [(N_RX_EXT_CHANNELS * DEST_SIZE) - 1:0] rx_ext_destination_i;
	input wire [(N_RX_EXT_CHANNELS * 2) - 1:0] rx_ext_stream_i;
	input wire [(N_RX_EXT_CHANNELS * STREAM_ID_WIDTH) - 1:0] rx_ext_stream_id_i;
	input wire [N_RX_EXT_CHANNELS - 1:0] rx_ext_sot_i;
	input wire [N_RX_EXT_CHANNELS - 1:0] rx_ext_eot_i;
	input wire [N_RX_EXT_CHANNELS - 1:0] rx_ext_valid_i;
	input wire [(N_RX_EXT_CHANNELS * DATA_WIDTH) - 1:0] rx_ext_data_i;
	output wire [N_RX_EXT_CHANNELS - 1:0] rx_ext_ready_o;
	input wire [N_TX_LIN_CHANNELS - 1:0] tx_lin_req_i;
	output wire [N_TX_LIN_CHANNELS - 1:0] tx_lin_gnt_o;
	output wire [N_TX_LIN_CHANNELS - 1:0] tx_lin_valid_o;
	output wire [(N_TX_LIN_CHANNELS * DATA_WIDTH) - 1:0] tx_lin_data_o;
	input wire [N_TX_LIN_CHANNELS - 1:0] tx_lin_ready_i;
	input wire [(N_TX_LIN_CHANNELS * 2) - 1:0] tx_lin_datasize_i;
	input wire [(N_TX_LIN_CHANNELS * 2) - 1:0] tx_lin_destination_i;
	output wire [N_TX_LIN_CHANNELS - 1:0] tx_lin_events_o;
	output wire [N_TX_LIN_CHANNELS - 1:0] tx_lin_en_o;
	output wire [N_TX_LIN_CHANNELS - 1:0] tx_lin_pending_o;
	output wire [(N_TX_LIN_CHANNELS * L2_AWIDTH_NOAL) - 1:0] tx_lin_curr_addr_o;
	output wire [(N_TX_LIN_CHANNELS * TRANS_SIZE) - 1:0] tx_lin_bytes_left_o;
	input wire [(N_TX_LIN_CHANNELS * L2_AWIDTH_NOAL) - 1:0] tx_lin_cfg_startaddr_i;
	input wire [(N_TX_LIN_CHANNELS * TRANS_SIZE) - 1:0] tx_lin_cfg_size_i;
	input wire [N_TX_LIN_CHANNELS - 1:0] tx_lin_cfg_continuous_i;
	input wire [N_TX_LIN_CHANNELS - 1:0] tx_lin_cfg_en_i;
	input wire [N_TX_LIN_CHANNELS - 1:0] tx_lin_cfg_clr_i;
	input wire [N_TX_EXT_CHANNELS - 1:0] tx_ext_req_i;
	input wire [(N_TX_EXT_CHANNELS * 2) - 1:0] tx_ext_datasize_i;
	input wire [(N_TX_EXT_CHANNELS * 2) - 1:0] tx_ext_destination_i;
	input wire [(N_TX_EXT_CHANNELS * L2_AWIDTH_NOAL) - 1:0] tx_ext_addr_i;
	output reg [N_TX_EXT_CHANNELS - 1:0] tx_ext_gnt_o;
	output reg [N_TX_EXT_CHANNELS - 1:0] tx_ext_valid_o;
	output reg [(N_TX_EXT_CHANNELS * DATA_WIDTH) - 1:0] tx_ext_data_o;
	input wire [N_TX_EXT_CHANNELS - 1:0] tx_ext_ready_i;
	localparam N_REAL_TX_EXT_CHANNELS = N_TX_EXT_CHANNELS + N_STREAMS;
	localparam N_REAL_PERIPHS = N_PERIPHS + 1;
	wire [N_STREAMS - 1:0] s_tx_ch_req;
	wire [(N_STREAMS * L2_AWIDTH_NOAL) - 1:0] s_tx_ch_addr;
	wire [(N_STREAMS * 2) - 1:0] s_tx_ch_datasize;
	reg [N_STREAMS - 1:0] s_tx_ch_gnt;
	reg [N_STREAMS - 1:0] s_tx_ch_valid;
	reg [(N_STREAMS * DATA_WIDTH) - 1:0] s_tx_ch_data;
	wire [N_STREAMS - 1:0] s_tx_ch_ready;
	wire [N_STREAMS - 1:0] s_cfg_en;
	wire [(N_STREAMS * L2_AWIDTH_NOAL) - 1:0] s_cfg_addr;
	wire [(N_STREAMS * TRANS_SIZE) - 1:0] s_cfg_buffsize;
	wire [(N_STREAMS * 2) - 1:0] s_cfg_datasize;
	reg [N_REAL_TX_EXT_CHANNELS - 1:0] s_tx_ext_req;
	reg [(N_REAL_TX_EXT_CHANNELS * 2) - 1:0] s_tx_ext_datasize;
	reg [(N_REAL_TX_EXT_CHANNELS * 2) - 1:0] s_tx_ext_dest;
	reg [(N_REAL_TX_EXT_CHANNELS * L2_AWIDTH_NOAL) - 1:0] s_tx_ext_addr;
	wire [N_REAL_TX_EXT_CHANNELS - 1:0] s_tx_ext_gnt;
	wire [N_REAL_TX_EXT_CHANNELS - 1:0] s_tx_ext_valid;
	wire [(N_REAL_TX_EXT_CHANNELS * DATA_WIDTH) - 1:0] s_tx_ext_data;
	reg [N_REAL_TX_EXT_CHANNELS - 1:0] s_tx_ext_ready;
	wire [N_REAL_TX_EXT_CHANNELS - 1:0] s_tx_ext_events;
	wire [31:0] s_periph_data_to;
	wire [4:0] s_periph_addr;
	wire s_periph_rwn;
	wire [(N_REAL_PERIPHS * 32) - 1:0] s_periph_data_from;
	wire [N_REAL_PERIPHS - 1:0] s_periph_valid;
	wire [N_REAL_PERIPHS - 1:0] s_periph_ready;
	wire s_periph_ready_from_cgunit;
	wire [31:0] s_periph_data_from_cgunit;
	wire [N_PERIPHS - 1:0] s_cg_value;
	wire s_clk_core;
	wire s_clk_core_en;
	assign periph_data_to_o = s_periph_data_to;
	assign periph_addr_o = s_periph_addr;
	assign periph_rwn_o = s_periph_rwn;
	assign periph_valid_o = s_periph_valid[N_REAL_PERIPHS - 1:1];
	assign s_periph_ready[0] = s_periph_ready_from_cgunit;
	assign s_periph_data_from[0+:32] = s_periph_data_from_cgunit;
	assign s_periph_ready[N_REAL_PERIPHS - 1:1] = periph_ready_i;
	assign s_periph_data_from[32 * (((N_REAL_PERIPHS - 1) >= 1 ? N_REAL_PERIPHS - 1 : ((N_REAL_PERIPHS - 1) + ((N_REAL_PERIPHS - 1) >= 1 ? N_REAL_PERIPHS - 1 : 3 - N_REAL_PERIPHS)) - 1) - (((N_REAL_PERIPHS - 1) >= 1 ? N_REAL_PERIPHS - 1 : 3 - N_REAL_PERIPHS) - 1))+:32 * ((N_REAL_PERIPHS - 1) >= 1 ? N_REAL_PERIPHS - 1 : 3 - N_REAL_PERIPHS)] = periph_data_from_i;
	always @(*) begin
		begin : sv2v_autoblock_1
			reg signed [31:0] i;
			for (i = 0; i < N_TX_EXT_CHANNELS; i = i + 1)
				begin
					s_tx_ext_req[i] = tx_ext_req_i[i];
					s_tx_ext_datasize[i * 2+:2] = tx_ext_datasize_i[i * 2+:2];
					s_tx_ext_dest[i * 2+:2] = tx_ext_destination_i[i * 2+:2];
					s_tx_ext_addr[i * L2_AWIDTH_NOAL+:L2_AWIDTH_NOAL] = tx_ext_addr_i[i * L2_AWIDTH_NOAL+:L2_AWIDTH_NOAL];
					tx_ext_gnt_o[i] = s_tx_ext_gnt[i];
					tx_ext_valid_o[i] = s_tx_ext_valid[i];
					tx_ext_data_o[i * DATA_WIDTH+:DATA_WIDTH] = s_tx_ext_data[i * DATA_WIDTH+:DATA_WIDTH];
					s_tx_ext_ready[i] = tx_ext_ready_i[i];
				end
		end
		begin : sv2v_autoblock_2
			reg signed [31:0] i;
			for (i = 0; i < N_STREAMS; i = i + 1)
				begin
					s_tx_ext_req[N_TX_EXT_CHANNELS + i] = s_tx_ch_req[i];
					s_tx_ext_datasize[(N_TX_EXT_CHANNELS + i) * 2+:2] = s_tx_ch_datasize[i * 2+:2];
					s_tx_ext_dest[(N_TX_EXT_CHANNELS + i) * 2+:2] = 2'b00;
					s_tx_ext_addr[(N_TX_EXT_CHANNELS + i) * L2_AWIDTH_NOAL+:L2_AWIDTH_NOAL] = s_tx_ch_addr[i * L2_AWIDTH_NOAL+:L2_AWIDTH_NOAL];
					s_tx_ch_gnt[i] = s_tx_ext_gnt[N_TX_EXT_CHANNELS + i];
					s_tx_ch_valid[i] = s_tx_ext_valid[N_TX_EXT_CHANNELS + i];
					s_tx_ch_data[i * DATA_WIDTH+:DATA_WIDTH] = s_tx_ext_data[(N_TX_EXT_CHANNELS + i) * DATA_WIDTH+:DATA_WIDTH];
					s_tx_ext_ready[N_TX_EXT_CHANNELS + i] = s_tx_ch_ready[i];
				end
		end
	end
	udma_tx_channels #(
		.L2_DATA_WIDTH(L2_DATA_WIDTH),
		.L2_AWIDTH_NOAL(L2_AWIDTH_NOAL),
		.DATA_WIDTH(32),
		.N_LIN_CHANNELS(N_TX_LIN_CHANNELS),
		.N_EXT_CHANNELS(N_REAL_TX_EXT_CHANNELS),
		.TRANS_SIZE(TRANS_SIZE)
	) u_tx_channels(
		.clk_i(s_clk_core),
		.rstn_i(HRESETn),
		.l2_req_o(tx_l2_req_o),
		.l2_gnt_i(tx_l2_gnt_i),
		.l2_addr_o(tx_l2_addr_o),
		.l2_rdata_i(tx_l2_rdata_i),
		.l2_rvalid_i(tx_l2_rvalid_i),
		.lin_req_i(tx_lin_req_i),
		.lin_gnt_o(tx_lin_gnt_o),
		.lin_valid_o(tx_lin_valid_o),
		.lin_data_o(tx_lin_data_o),
		.lin_ready_i(tx_lin_ready_i),
		.lin_datasize_i(tx_lin_datasize_i),
		.lin_destination_i(tx_lin_destination_i),
		.lin_events_o(tx_lin_events_o),
		.lin_en_o(tx_lin_en_o),
		.lin_pending_o(tx_lin_pending_o),
		.lin_curr_addr_o(tx_lin_curr_addr_o),
		.lin_bytes_left_o(tx_lin_bytes_left_o),
		.lin_cfg_startaddr_i(tx_lin_cfg_startaddr_i),
		.lin_cfg_size_i(tx_lin_cfg_size_i),
		.lin_cfg_continuous_i(tx_lin_cfg_continuous_i),
		.lin_cfg_en_i(tx_lin_cfg_en_i),
		.lin_cfg_clr_i(tx_lin_cfg_clr_i),
		.ext_req_i(s_tx_ext_req),
		.ext_datasize_i(s_tx_ext_datasize),
		.ext_destination_i(s_tx_ext_dest),
		.ext_addr_i(s_tx_ext_addr),
		.ext_gnt_o(s_tx_ext_gnt),
		.ext_valid_o(s_tx_ext_valid),
		.ext_data_o(s_tx_ext_data),
		.ext_ready_i(s_tx_ext_ready)
	);
	udma_rx_channels #(
		.L2_DATA_WIDTH(L2_DATA_WIDTH),
		.L2_AWIDTH_NOAL(L2_AWIDTH_NOAL),
		.DATA_WIDTH(32),
		.N_STREAMS(N_STREAMS),
		.N_LIN_CHANNELS(N_RX_LIN_CHANNELS),
		.N_EXT_CHANNELS(N_RX_EXT_CHANNELS),
		.STREAM_ID_WIDTH(STREAM_ID_WIDTH),
		.TRANS_SIZE(TRANS_SIZE)
	) u_rx_channels(
		.clk_i(s_clk_core),
		.rstn_i(HRESETn),
		.l2_req_o(rx_l2_req_o),
		.l2_addr_o(rx_l2_addr_o),
		.l2_be_o(rx_l2_be_o),
		.l2_wdata_o(rx_l2_wdata_o),
		.l2_gnt_i(rx_l2_gnt_i),
		.stream_data_o(stream_data_o),
		.stream_datasize_o(stream_datasize_o),
		.stream_valid_o(stream_valid_o),
		.stream_sot_o(stream_sot_o),
		.stream_eot_o(stream_eot_o),
		.stream_ready_i(stream_ready_i),
		.tx_ch_req_o(s_tx_ch_req),
		.tx_ch_addr_o(s_tx_ch_addr),
		.tx_ch_datasize_o(s_tx_ch_datasize),
		.tx_ch_gnt_i(s_tx_ch_gnt),
		.tx_ch_valid_i(s_tx_ch_valid),
		.tx_ch_data_i(s_tx_ch_data),
		.tx_ch_ready_o(s_tx_ch_ready),
		.lin_ch_valid_i(rx_lin_valid_i),
		.lin_ch_data_i(rx_lin_data_i),
		.lin_ch_ready_o(rx_lin_ready_o),
		.lin_ch_datasize_i(rx_lin_datasize_i),
		.lin_ch_destination_i(rx_lin_destination_i),
		.lin_ch_events_o(rx_lin_events_o),
		.lin_ch_en_o(rx_lin_en_o),
		.lin_ch_pending_o(rx_lin_pending_o),
		.lin_ch_curr_addr_o(rx_lin_curr_addr_o),
		.lin_ch_bytes_left_o(rx_lin_bytes_left_o),
		.lin_ch_cfg_startaddr_i(rx_lin_cfg_startaddr_i),
		.lin_ch_cfg_size_i(rx_lin_cfg_size_i),
		.lin_ch_cfg_continuous_i(rx_lin_cfg_continuous_i),
		.lin_ch_cfg_en_i(rx_lin_cfg_en_i),
		.lin_ch_cfg_stream_i(rx_lin_cfg_stream_i),
		.lin_ch_cfg_stream_id_i(rx_lin_cfg_stream_id_i),
		.lin_ch_cfg_clr_i(rx_lin_cfg_clr_i),
		.ext_ch_addr_i(rx_ext_addr_i),
		.ext_ch_datasize_i(rx_ext_datasize_i),
		.ext_ch_destination_i(rx_ext_destination_i),
		.ext_ch_stream_i(rx_ext_stream_i),
		.ext_ch_stream_id_i(rx_ext_stream_id_i),
		.ext_ch_sot_i(rx_ext_sot_i),
		.ext_ch_eot_i(rx_ext_eot_i),
		.ext_ch_valid_i(rx_ext_valid_i),
		.ext_ch_data_i(rx_ext_data_i),
		.ext_ch_ready_o(rx_ext_ready_o)
	);
	udma_apb_if #(
		.APB_ADDR_WIDTH(APB_ADDR_WIDTH),
		.N_PERIPHS(N_REAL_PERIPHS)
	) u_apb_if(
		.PADDR(PADDR),
		.PWDATA(PWDATA),
		.PWRITE(PWRITE),
		.PSEL(PSEL),
		.PENABLE(PENABLE),
		.PRDATA(PRDATA),
		.PREADY(PREADY),
		.PSLVERR(PSLVERR),
		.periph_data_o(s_periph_data_to),
		.periph_addr_o(s_periph_addr),
		.periph_data_i(s_periph_data_from),
		.periph_ready_i(s_periph_ready),
		.periph_valid_o(s_periph_valid),
		.periph_rwn_o(s_periph_rwn)
	);
	udma_ctrl #(
		.L2_AWIDTH_NOAL(L2_AWIDTH_NOAL),
		.TRANS_SIZE(TRANS_SIZE),
		.N_PERIPHS(N_PERIPHS)
	) u_udma_ctrl(
		.clk_i(sys_clk_i),
		.rstn_i(HRESETn),
		.cfg_data_i(s_periph_data_to),
		.cfg_addr_i(s_periph_addr),
		.cfg_valid_i(s_periph_valid[0]),
		.cfg_rwn_i(s_periph_rwn),
		.cfg_data_o(s_periph_data_from_cgunit),
		.cfg_ready_o(s_periph_ready_from_cgunit),
		.cg_value_o(s_cg_value),
		.cg_core_o(s_clk_core_en),
		.rst_value_o(),
		.event_valid_i(event_valid_i),
		.event_data_i(event_data_i),
		.event_ready_o(event_ready_o),
		.event_o(event_o)
	);
	pulp_clock_gating i_clk_gate_sys_udma(
		.clk_i(sys_clk_i),
		.en_i(s_clk_core_en),
		.test_en_i(dft_cg_enable_i),
		.clk_o(s_clk_core)
	);
	genvar i;
	generate
		for (i = 0; i < N_PERIPHS; i = i + 1) begin : genblk1
			pulp_clock_gating_async i_clk_gate_per(
				.clk_i(per_clk_i),
				.rstn_i(HRESETn),
				.en_async_i(s_cg_value[i]),
				.en_ack_o(),
				.test_en_i(dft_cg_enable_i),
				.clk_o(periph_per_clk_o[i])
			);
			pulp_clock_gating i_clk_gate_sys(
				.clk_i(s_clk_core),
				.en_i(s_cg_value[i]),
				.test_en_i(dft_cg_enable_i),
				.clk_o(periph_sys_clk_o[i])
			);
		end
	endgenerate
endmodule
