module udma_mram_top_wrapper (
	sys_clk_i,
	periph_clk_i,
	rstn_i,
	dft_test_mode_i,
	dft_cg_enable_i,
	cfg_data_i,
	cfg_addr_i,
	cfg_valid_i,
	cfg_rwn_i,
	cfg_ready_o,
	cfg_data_o,
	cfg_rx_startaddr_o,
	cfg_rx_size_o,
	cfg_rx_continuous_o,
	cfg_rx_en_o,
	cfg_rx_clr_o,
	cfg_rx_en_i,
	cfg_rx_pending_i,
	cfg_rx_curr_addr_i,
	cfg_rx_bytes_left_i,
	cfg_tx_startaddr_o,
	cfg_tx_size_o,
	cfg_tx_continuous_o,
	cfg_tx_en_o,
	cfg_tx_clr_o,
	cfg_tx_en_i,
	cfg_tx_pending_i,
	cfg_tx_curr_addr_i,
	cfg_tx_bytes_left_i,
	data_tx_req_o,
	data_tx_gnt_i,
	data_tx_datasize_o,
	data_tx_i,
	data_tx_valid_i,
	data_tx_ready_o,
	data_rx_datasize_o,
	data_rx_o,
	data_rx_valid_o,
	data_rx_ready_i,
	erase_done_event_o,
	ref_line_done_event_o,
	trim_cfg_done_event_o,
	tx_done_event_o,
	VDDA_i,
	VDD_i,
	VREF_i,
	PORb_i,
	RETb_i,
	RSTb_i,
	TRIM_i,
	DPD_i,
	CEb_HIGH_i
);
	parameter L2_AWIDTH_NOAL = 12;
	parameter TRANS_SIZE = 16;
	parameter MRAM_ADDR_WIDTH = 16;
	parameter TX_CMD_WIDTH = (MRAM_ADDR_WIDTH + TRANS_SIZE) + 11;
	parameter TX_DATA_WIDTH = 32;
	parameter TX_DC_FIFO_DEPTH = 4;
	parameter RX_CMD_WIDTH = (MRAM_ADDR_WIDTH + TRANS_SIZE) + 11;
	parameter RX_DATA_WIDTH = 64;
	parameter RX_DC_FIFO_DEPTH = 4;
	input wire sys_clk_i;
	input wire periph_clk_i;
	input wire rstn_i;
	input wire dft_test_mode_i;
	input wire dft_cg_enable_i;
	input wire [31:0] cfg_data_i;
	input wire [4:0] cfg_addr_i;
	input wire cfg_valid_i;
	input wire cfg_rwn_i;
	output wire cfg_ready_o;
	output wire [31:0] cfg_data_o;
	output wire [L2_AWIDTH_NOAL - 1:0] cfg_rx_startaddr_o;
	output wire [TRANS_SIZE - 1:0] cfg_rx_size_o;
	output wire cfg_rx_continuous_o;
	output wire cfg_rx_en_o;
	output wire cfg_rx_clr_o;
	input wire cfg_rx_en_i;
	input wire cfg_rx_pending_i;
	input wire [L2_AWIDTH_NOAL - 1:0] cfg_rx_curr_addr_i;
	input wire [TRANS_SIZE - 1:0] cfg_rx_bytes_left_i;
	output wire [L2_AWIDTH_NOAL - 1:0] cfg_tx_startaddr_o;
	output wire [TRANS_SIZE - 1:0] cfg_tx_size_o;
	output wire cfg_tx_continuous_o;
	output wire cfg_tx_en_o;
	output wire cfg_tx_clr_o;
	input wire cfg_tx_en_i;
	input wire cfg_tx_pending_i;
	input wire [L2_AWIDTH_NOAL - 1:0] cfg_tx_curr_addr_i;
	input wire [TRANS_SIZE - 1:0] cfg_tx_bytes_left_i;
	output wire data_tx_req_o;
	input wire data_tx_gnt_i;
	output wire [1:0] data_tx_datasize_o;
	input wire [31:0] data_tx_i;
	input wire data_tx_valid_i;
	output wire data_tx_ready_o;
	output wire [1:0] data_rx_datasize_o;
	output wire [31:0] data_rx_o;
	output wire data_rx_valid_o;
	input wire data_rx_ready_i;
	output wire erase_done_event_o;
	output wire ref_line_done_event_o;
	output wire trim_cfg_done_event_o;
	output wire tx_done_event_o;
	input wire VDDA_i;
	input wire VDD_i;
	input wire VREF_i;
	input wire PORb_i;
	input wire RETb_i;
	input wire RSTb_i;
	input wire TRIM_i;
	input wire DPD_i;
	input wire CEb_HIGH_i;
	wire tx_busy;
	wire rx_busy;
	wire tx_done;
	wire [1:0] rx_error;
	wire trim_cfg_done;
	wire erase_pending;
	wire erase_done;
	wire ref_line_pending;
	wire ref_line_done;
	wire [TX_DC_FIFO_DEPTH - 1:0] data_tx_write_token;
	wire [TX_DC_FIFO_DEPTH - 1:0] data_tx_read_pointer;
	wire [TX_DATA_WIDTH - 1:0] data_tx_asynch;
	wire [TX_DC_FIFO_DEPTH - 1:0] cmd_tx_write_token;
	wire [TX_DC_FIFO_DEPTH - 1:0] cmd_tx_read_pointer;
	wire [TX_CMD_WIDTH - 1:0] cmd_tx_asynch;
	wire [RX_DC_FIFO_DEPTH - 1:0] data_rx_write_token;
	wire [RX_DC_FIFO_DEPTH - 1:0] data_rx_read_pointer;
	wire [RX_DATA_WIDTH - 1:0] data_rx_asynch;
	wire [RX_DC_FIFO_DEPTH - 1:0] cmd_rx_write_token;
	wire [RX_DC_FIFO_DEPTH - 1:0] cmd_rx_read_pointer;
	wire [RX_CMD_WIDTH - 1:0] cmd_rx_asynch;
	wire [4:0] mram_mode_static;
	wire rstn_dcfifo;
	wire mram_clk;
	wire mram_clk_en;
	wire [15:0] mram_erase_addr;
	wire [9:0] mram_erase_size;
	udma_mram_top #(
		.L2_AWIDTH_NOAL(L2_AWIDTH_NOAL),
		.TRANS_SIZE(TRANS_SIZE),
		.MRAM_ADDR_WIDTH(MRAM_ADDR_WIDTH),
		.TX_CMD_WIDTH(TX_CMD_WIDTH),
		.TX_DATA_WIDTH(TX_DATA_WIDTH),
		.TX_DC_FIFO_DEPTH(TX_DC_FIFO_DEPTH),
		.RX_CMD_WIDTH(RX_CMD_WIDTH),
		.RX_DATA_WIDTH(RX_DATA_WIDTH),
		.RX_DC_FIFO_DEPTH(RX_DC_FIFO_DEPTH)
	) udma_mram_top_i(
		.sys_clk_i(sys_clk_i),
		.periph_clk_i(periph_clk_i),
		.rstn_i(rstn_i),
		.dft_test_mode_i(dft_test_mode_i),
		.dft_cg_enable_i(dft_cg_enable_i),
		.cfg_data_i(cfg_data_i),
		.cfg_addr_i(cfg_addr_i),
		.cfg_valid_i(cfg_valid_i),
		.cfg_rwn_i(cfg_rwn_i),
		.cfg_ready_o(cfg_ready_o),
		.cfg_data_o(cfg_data_o),
		.cfg_rx_startaddr_o(cfg_rx_startaddr_o),
		.cfg_rx_size_o(cfg_rx_size_o),
		.cfg_rx_continuous_o(cfg_rx_continuous_o),
		.cfg_rx_en_o(cfg_rx_en_o),
		.cfg_rx_clr_o(cfg_rx_clr_o),
		.cfg_rx_en_i(cfg_rx_en_i),
		.cfg_rx_pending_i(cfg_rx_pending_i),
		.cfg_rx_curr_addr_i(cfg_rx_curr_addr_i),
		.cfg_rx_bytes_left_i(cfg_rx_bytes_left_i),
		.cfg_tx_startaddr_o(cfg_tx_startaddr_o),
		.cfg_tx_size_o(cfg_tx_size_o),
		.cfg_tx_continuous_o(cfg_tx_continuous_o),
		.cfg_tx_en_o(cfg_tx_en_o),
		.cfg_tx_clr_o(cfg_tx_clr_o),
		.cfg_tx_en_i(cfg_tx_en_i),
		.cfg_tx_pending_i(cfg_tx_pending_i),
		.cfg_tx_curr_addr_i(cfg_tx_curr_addr_i),
		.cfg_tx_bytes_left_i(cfg_tx_bytes_left_i),
		.data_tx_req_o(data_tx_req_o),
		.data_tx_gnt_i(data_tx_gnt_i),
		.data_tx_datasize_o(data_tx_datasize_o),
		.data_tx_i(data_tx_i),
		.data_tx_valid_i(data_tx_valid_i),
		.data_tx_ready_o(data_tx_ready_o),
		.data_rx_datasize_o(data_rx_datasize_o),
		.data_rx_o(data_rx_o),
		.data_rx_valid_o(data_rx_valid_o),
		.data_rx_ready_i(data_rx_ready_i),
		.erase_done_event_o(erase_done_event_o),
		.ref_line_done_event_o(ref_line_done_event_o),
		.trim_cfg_done_event_o(trim_cfg_done_event_o),
		.tx_done_event_o(tx_done_event_o),
		.tx_busy_i(tx_busy),
		.rx_busy_i(rx_busy),
		.tx_done_i(tx_done),
		.rx_error_i(rx_error),
		.trim_cfg_done_i(trim_cfg_done),
		.erase_pending_i(erase_pending),
		.erase_done_i(erase_done),
		.ref_line_pending_i(ref_line_pending),
		.ref_line_done_i(ref_line_done),
		.data_tx_write_token_o(data_tx_write_token),
		.data_tx_read_pointer_i(data_tx_read_pointer),
		.data_tx_asynch_o(data_tx_asynch),
		.cmd_tx_write_token_o(cmd_tx_write_token),
		.cmd_tx_read_pointer_i(cmd_tx_read_pointer),
		.cmd_tx_asynch_o(cmd_tx_asynch),
		.data_rx_write_token_i(data_rx_write_token),
		.data_rx_read_pointer_o(data_rx_read_pointer),
		.data_rx_asynch_i(data_rx_asynch),
		.cmd_rx_write_token_o(cmd_rx_write_token),
		.cmd_rx_read_pointer_i(cmd_rx_read_pointer),
		.cmd_rx_asynch_o(cmd_rx_asynch),
		.mram_mode_static_o(mram_mode_static),
		.rstn_dcfifo_i(rstn_dcfifo),
		.mram_clk_o(mram_clk),
		.mram_clk_en_i(mram_clk_en),
		.mram_erase_addr_o(mram_erase_addr),
		.mram_erase_size_o(mram_erase_size)
	);
	udma_mram_domain #(
		.TRANS_SIZE(TRANS_SIZE),
		.MRAM_ADDR_WIDTH(MRAM_ADDR_WIDTH),
		.TX_CMD_WIDTH(TX_CMD_WIDTH),
		.TX_DATA_WIDTH(TX_DATA_WIDTH),
		.TX_DC_FIFO_DEPTH(TX_DC_FIFO_DEPTH),
		.RX_CMD_WIDTH(RX_CMD_WIDTH),
		.RX_DATA_WIDTH(RX_DATA_WIDTH),
		.RX_DC_FIFO_DEPTH(RX_DC_FIFO_DEPTH)
	) udma_mram_domain_i(
		.mram_clk_i(mram_clk),
		.rstn_i(rstn_i),
		.tx_busy_o(tx_busy),
		.rx_busy_o(rx_busy),
		.tx_done_o(tx_done),
		.rx_error_o(rx_error),
		.trim_cfg_done_o(trim_cfg_done),
		.erase_pending_o(erase_pending),
		.erase_done_o(erase_done),
		.ref_line_pending_o(ref_line_pending),
		.ref_line_done_o(ref_line_done),
		.data_tx_write_token_i(data_tx_write_token),
		.data_tx_read_pointer_o(data_tx_read_pointer),
		.data_tx_asynch_i(data_tx_asynch),
		.cmd_tx_write_token_i(cmd_tx_write_token),
		.cmd_tx_read_pointer_o(cmd_tx_read_pointer),
		.cmd_tx_asynch_i(cmd_tx_asynch),
		.data_rx_write_token_o(data_rx_write_token),
		.data_rx_read_pointer_i(data_rx_read_pointer),
		.data_rx_asynch_o(data_rx_asynch),
		.cmd_rx_write_token_i(cmd_rx_write_token),
		.cmd_rx_read_pointer_o(cmd_rx_read_pointer),
		.cmd_rx_asynch_i(cmd_rx_asynch),
		.mram_mode_static_i(mram_mode_static),
		.mram_erase_addr_i(mram_erase_addr),
		.mram_erase_size_i(mram_erase_size),
		.mram_clk_en_o(mram_clk_en),
		.rstn_dcfifo_o(rstn_dcfifo),
		.dft_test_mode_i(dft_test_mode_i),
		.VDDA_i(VDDA_i),
		.VDD_i(VDD_i),
		.VREF_i(VREF_i),
		.PORb_i(PORb_i),
		.RETb_i(RETb_i),
		.RSTb_i(RSTb_i),
		.TRIM_i(TRIM_i),
		.DPD_i(DPD_i),
		.CEb_HIGH_i(CEb_HIGH_i)
	);
endmodule
