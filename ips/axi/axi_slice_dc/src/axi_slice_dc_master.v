module axi_slice_dc_master (
	clk_i,
	rst_ni,
	test_cgbypass_i,
	axi_slave_aw_addr,
	axi_slave_aw_prot,
	axi_slave_aw_region,
	axi_slave_aw_len,
	axi_slave_aw_size,
	axi_slave_aw_burst,
	axi_slave_aw_lock,
	axi_slave_aw_cache,
	axi_slave_aw_qos,
	axi_slave_aw_id,
	axi_slave_aw_user,
	axi_slave_aw_writetoken,
	axi_slave_aw_readpointer,
	axi_slave_ar_addr,
	axi_slave_ar_prot,
	axi_slave_ar_region,
	axi_slave_ar_len,
	axi_slave_ar_size,
	axi_slave_ar_burst,
	axi_slave_ar_lock,
	axi_slave_ar_cache,
	axi_slave_ar_qos,
	axi_slave_ar_id,
	axi_slave_ar_user,
	axi_slave_ar_writetoken,
	axi_slave_ar_readpointer,
	axi_slave_w_data,
	axi_slave_w_strb,
	axi_slave_w_user,
	axi_slave_w_last,
	axi_slave_w_writetoken,
	axi_slave_w_readpointer,
	axi_slave_r_data,
	axi_slave_r_resp,
	axi_slave_r_last,
	axi_slave_r_id,
	axi_slave_r_user,
	axi_slave_r_writetoken,
	axi_slave_r_readpointer,
	axi_slave_b_resp,
	axi_slave_b_id,
	axi_slave_b_user,
	axi_slave_b_writetoken,
	axi_slave_b_readpointer,
	axi_master_aw_valid,
	axi_master_aw_addr,
	axi_master_aw_prot,
	axi_master_aw_region,
	axi_master_aw_len,
	axi_master_aw_size,
	axi_master_aw_burst,
	axi_master_aw_lock,
	axi_master_aw_cache,
	axi_master_aw_qos,
	axi_master_aw_id,
	axi_master_aw_user,
	axi_master_aw_ready,
	axi_master_ar_valid,
	axi_master_ar_addr,
	axi_master_ar_prot,
	axi_master_ar_region,
	axi_master_ar_len,
	axi_master_ar_size,
	axi_master_ar_burst,
	axi_master_ar_lock,
	axi_master_ar_cache,
	axi_master_ar_qos,
	axi_master_ar_id,
	axi_master_ar_user,
	axi_master_ar_ready,
	axi_master_w_valid,
	axi_master_w_data,
	axi_master_w_strb,
	axi_master_w_user,
	axi_master_w_last,
	axi_master_w_ready,
	axi_master_r_valid,
	axi_master_r_data,
	axi_master_r_resp,
	axi_master_r_last,
	axi_master_r_id,
	axi_master_r_user,
	axi_master_r_ready,
	axi_master_b_valid,
	axi_master_b_resp,
	axi_master_b_id,
	axi_master_b_user,
	axi_master_b_ready
);
	parameter AXI_ADDR_WIDTH = 32;
	parameter AXI_DATA_WIDTH = 64;
	parameter AXI_USER_WIDTH = 6;
	parameter AXI_ID_WIDTH = 6;
	parameter BUFFER_WIDTH = 8;
	input wire clk_i;
	input wire rst_ni;
	input wire test_cgbypass_i;
	input wire [AXI_ADDR_WIDTH - 1:0] axi_slave_aw_addr;
	input wire [2:0] axi_slave_aw_prot;
	input wire [3:0] axi_slave_aw_region;
	input wire [7:0] axi_slave_aw_len;
	input wire [2:0] axi_slave_aw_size;
	input wire [1:0] axi_slave_aw_burst;
	input wire axi_slave_aw_lock;
	input wire [3:0] axi_slave_aw_cache;
	input wire [3:0] axi_slave_aw_qos;
	input wire [AXI_ID_WIDTH - 1:0] axi_slave_aw_id;
	input wire [AXI_USER_WIDTH - 1:0] axi_slave_aw_user;
	input wire [BUFFER_WIDTH - 1:0] axi_slave_aw_writetoken;
	output wire [BUFFER_WIDTH - 1:0] axi_slave_aw_readpointer;
	input wire [AXI_ADDR_WIDTH - 1:0] axi_slave_ar_addr;
	input wire [2:0] axi_slave_ar_prot;
	input wire [3:0] axi_slave_ar_region;
	input wire [7:0] axi_slave_ar_len;
	input wire [2:0] axi_slave_ar_size;
	input wire [1:0] axi_slave_ar_burst;
	input wire axi_slave_ar_lock;
	input wire [3:0] axi_slave_ar_cache;
	input wire [3:0] axi_slave_ar_qos;
	input wire [AXI_ID_WIDTH - 1:0] axi_slave_ar_id;
	input wire [AXI_USER_WIDTH - 1:0] axi_slave_ar_user;
	input wire [BUFFER_WIDTH - 1:0] axi_slave_ar_writetoken;
	output wire [BUFFER_WIDTH - 1:0] axi_slave_ar_readpointer;
	input wire [AXI_DATA_WIDTH - 1:0] axi_slave_w_data;
	input wire [(AXI_DATA_WIDTH / 8) - 1:0] axi_slave_w_strb;
	input wire [AXI_USER_WIDTH - 1:0] axi_slave_w_user;
	input wire axi_slave_w_last;
	input wire [BUFFER_WIDTH - 1:0] axi_slave_w_writetoken;
	output wire [BUFFER_WIDTH - 1:0] axi_slave_w_readpointer;
	output wire [AXI_DATA_WIDTH - 1:0] axi_slave_r_data;
	output wire [1:0] axi_slave_r_resp;
	output wire axi_slave_r_last;
	output wire [AXI_ID_WIDTH - 1:0] axi_slave_r_id;
	output wire [AXI_USER_WIDTH - 1:0] axi_slave_r_user;
	output wire [BUFFER_WIDTH - 1:0] axi_slave_r_writetoken;
	input wire [BUFFER_WIDTH - 1:0] axi_slave_r_readpointer;
	output wire [1:0] axi_slave_b_resp;
	output wire [AXI_ID_WIDTH - 1:0] axi_slave_b_id;
	output wire [AXI_USER_WIDTH - 1:0] axi_slave_b_user;
	output wire [BUFFER_WIDTH - 1:0] axi_slave_b_writetoken;
	input wire [BUFFER_WIDTH - 1:0] axi_slave_b_readpointer;
	output wire axi_master_aw_valid;
	output wire [AXI_ADDR_WIDTH - 1:0] axi_master_aw_addr;
	output wire [2:0] axi_master_aw_prot;
	output wire [3:0] axi_master_aw_region;
	output wire [7:0] axi_master_aw_len;
	output wire [2:0] axi_master_aw_size;
	output wire [1:0] axi_master_aw_burst;
	output wire axi_master_aw_lock;
	output wire [3:0] axi_master_aw_cache;
	output wire [3:0] axi_master_aw_qos;
	output wire [AXI_ID_WIDTH - 1:0] axi_master_aw_id;
	output wire [AXI_USER_WIDTH - 1:0] axi_master_aw_user;
	input wire axi_master_aw_ready;
	output wire axi_master_ar_valid;
	output wire [AXI_ADDR_WIDTH - 1:0] axi_master_ar_addr;
	output wire [2:0] axi_master_ar_prot;
	output wire [3:0] axi_master_ar_region;
	output wire [7:0] axi_master_ar_len;
	output wire [2:0] axi_master_ar_size;
	output wire [1:0] axi_master_ar_burst;
	output wire axi_master_ar_lock;
	output wire [3:0] axi_master_ar_cache;
	output wire [3:0] axi_master_ar_qos;
	output wire [AXI_ID_WIDTH - 1:0] axi_master_ar_id;
	output wire [AXI_USER_WIDTH - 1:0] axi_master_ar_user;
	input wire axi_master_ar_ready;
	output wire axi_master_w_valid;
	output wire [AXI_DATA_WIDTH - 1:0] axi_master_w_data;
	output wire [(AXI_DATA_WIDTH / 8) - 1:0] axi_master_w_strb;
	output wire [AXI_USER_WIDTH - 1:0] axi_master_w_user;
	output wire axi_master_w_last;
	input wire axi_master_w_ready;
	input wire axi_master_r_valid;
	input wire [AXI_DATA_WIDTH - 1:0] axi_master_r_data;
	input wire [1:0] axi_master_r_resp;
	input wire axi_master_r_last;
	input wire [AXI_ID_WIDTH - 1:0] axi_master_r_id;
	input wire [AXI_USER_WIDTH - 1:0] axi_master_r_user;
	output wire axi_master_r_ready;
	input wire axi_master_b_valid;
	input wire [1:0] axi_master_b_resp;
	input wire [AXI_ID_WIDTH - 1:0] axi_master_b_id;
	input wire [AXI_USER_WIDTH - 1:0] axi_master_b_user;
	output wire axi_master_b_ready;
	localparam DATA_STRB_WIDTH = AXI_DATA_WIDTH + (AXI_DATA_WIDTH / 8);
	localparam DATA_USER_STRB_WIDTH = (AXI_DATA_WIDTH + (AXI_DATA_WIDTH / 8)) + AXI_USER_WIDTH;
	localparam DATA_ID_WIDTH = AXI_DATA_WIDTH + AXI_ID_WIDTH;
	localparam DATA_USER_ID_WIDTH = (AXI_DATA_WIDTH + AXI_USER_WIDTH) + AXI_ID_WIDTH;
	localparam ADDR_ID_WIDTH = AXI_ADDR_WIDTH + AXI_ID_WIDTH;
	localparam ADDR_USER_ID_WIDTH = (AXI_ADDR_WIDTH + AXI_USER_WIDTH) + AXI_ID_WIDTH;
	localparam USER_ID_WIDTH = AXI_USER_WIDTH + AXI_ID_WIDTH;
	localparam WIDTH_FIFO_AW = 30 + ADDR_USER_ID_WIDTH;
	localparam WIDTH_FIFO_AR = 30 + ADDR_USER_ID_WIDTH;
	localparam WIDTH_FIFO_W = 1 + DATA_USER_STRB_WIDTH;
	localparam WIDTH_FIFO_R = 3 + DATA_USER_ID_WIDTH;
	localparam WIDTH_FIFO_B = 2 + USER_ID_WIDTH;
	wire [WIDTH_FIFO_AW - 1:0] data_aw;
	wire [WIDTH_FIFO_AW - 1:0] data_aw_dc;
	wire [WIDTH_FIFO_AW - 1:0] data_async_aw;
	wire [WIDTH_FIFO_AR - 1:0] data_ar;
	wire [WIDTH_FIFO_AR - 1:0] data_ar_dc;
	wire [WIDTH_FIFO_AR - 1:0] data_async_ar;
	wire [WIDTH_FIFO_W - 1:0] data_w;
	wire [WIDTH_FIFO_W - 1:0] data_w_dc;
	wire [WIDTH_FIFO_W - 1:0] data_async_w;
	wire [WIDTH_FIFO_R - 1:0] data_r;
	wire [WIDTH_FIFO_R - 1:0] data_async_r;
	wire [WIDTH_FIFO_B - 1:0] data_b;
	wire [WIDTH_FIFO_B - 1:0] data_async_b;
	wire s_slave_aw_valid;
	wire s_slave_aw_ready;
	wire s_slave_ar_valid;
	wire s_slave_ar_ready;
	wire s_slave_w_valid;
	wire s_slave_w_ready;
	assign data_async_aw[3:0] = axi_slave_aw_cache;
	assign data_async_aw[6:4] = axi_slave_aw_prot;
	assign data_async_aw[7] = axi_slave_aw_lock;
	assign data_async_aw[8] = 1'b0;
	assign data_async_aw[10:9] = axi_slave_aw_burst;
	assign data_async_aw[13:11] = axi_slave_aw_size;
	assign data_async_aw[21:14] = axi_slave_aw_len;
	assign data_async_aw[25:22] = axi_slave_aw_region;
	assign data_async_aw[29:26] = axi_slave_aw_qos;
	assign data_async_aw[29 + AXI_ADDR_WIDTH:30] = axi_slave_aw_addr;
	assign data_async_aw[29 + ADDR_ID_WIDTH:30 + AXI_ADDR_WIDTH] = axi_slave_aw_id;
	assign data_async_aw[29 + ADDR_USER_ID_WIDTH:30 + ADDR_ID_WIDTH] = axi_slave_aw_user;
	assign axi_master_aw_cache = data_aw[3:0];
	assign axi_master_aw_prot = data_aw[6:4];
	assign axi_master_aw_lock = data_aw[7];
	assign axi_master_aw_burst = data_aw[10:9];
	assign axi_master_aw_size = data_aw[13:11];
	assign axi_master_aw_len = data_aw[21:14];
	assign axi_master_aw_region = data_aw[25:22];
	assign axi_master_aw_qos = data_aw[29:26];
	assign axi_master_aw_addr = data_aw[29 + AXI_ADDR_WIDTH:30];
	assign axi_master_aw_id = data_aw[29 + ADDR_ID_WIDTH:30 + AXI_ADDR_WIDTH];
	assign axi_master_aw_user = data_aw[29 + ADDR_USER_ID_WIDTH:30 + ADDR_ID_WIDTH];
	assign data_async_ar[3:0] = axi_slave_ar_cache;
	assign data_async_ar[6:4] = axi_slave_ar_prot;
	assign data_async_ar[7] = axi_slave_ar_lock;
	assign data_async_ar[8] = 1'b0;
	assign data_async_ar[10:9] = axi_slave_ar_burst;
	assign data_async_ar[13:11] = axi_slave_ar_size;
	assign data_async_ar[21:14] = axi_slave_ar_len;
	assign data_async_ar[25:22] = axi_slave_ar_region;
	assign data_async_ar[29:26] = axi_slave_ar_qos;
	assign data_async_ar[29 + AXI_ADDR_WIDTH:30] = axi_slave_ar_addr;
	assign data_async_ar[29 + ADDR_ID_WIDTH:30 + AXI_ADDR_WIDTH] = axi_slave_ar_id;
	assign data_async_ar[29 + ADDR_USER_ID_WIDTH:30 + ADDR_ID_WIDTH] = axi_slave_ar_user;
	assign axi_master_ar_cache = data_ar[3:0];
	assign axi_master_ar_prot = data_ar[6:4];
	assign axi_master_ar_lock = data_ar[7];
	assign axi_master_ar_burst = data_ar[10:9];
	assign axi_master_ar_size = data_ar[13:11];
	assign axi_master_ar_len = data_ar[21:14];
	assign axi_master_ar_region = data_ar[25:22];
	assign axi_master_ar_qos = data_ar[29:26];
	assign axi_master_ar_addr = data_ar[29 + AXI_ADDR_WIDTH:30];
	assign axi_master_ar_id = data_ar[29 + ADDR_ID_WIDTH:30 + AXI_ADDR_WIDTH];
	assign axi_master_ar_user = data_ar[29 + ADDR_USER_ID_WIDTH:30 + ADDR_ID_WIDTH];
	assign data_r[0] = axi_master_r_last;
	assign data_r[2:1] = axi_master_r_resp;
	assign data_r[2 + AXI_DATA_WIDTH:3] = axi_master_r_data;
	assign data_r[2 + DATA_ID_WIDTH:3 + AXI_DATA_WIDTH] = axi_master_r_id;
	assign data_r[2 + DATA_USER_ID_WIDTH:3 + DATA_ID_WIDTH] = axi_master_r_user;
	assign axi_slave_r_last = data_async_r[0];
	assign axi_slave_r_resp = data_async_r[2:1];
	assign axi_slave_r_data = data_async_r[2 + AXI_DATA_WIDTH:3];
	assign axi_slave_r_id = data_async_r[2 + DATA_ID_WIDTH:3 + AXI_DATA_WIDTH];
	assign axi_slave_r_user = data_async_r[2 + DATA_USER_ID_WIDTH:3 + DATA_ID_WIDTH];
	assign data_async_w[0] = axi_slave_w_last;
	assign data_async_w[AXI_DATA_WIDTH:1] = axi_slave_w_data;
	assign data_async_w[DATA_STRB_WIDTH:1 + AXI_DATA_WIDTH] = axi_slave_w_strb;
	assign data_async_w[DATA_USER_STRB_WIDTH:1 + DATA_STRB_WIDTH] = axi_slave_w_user;
	assign axi_master_w_last = data_w[0];
	assign axi_master_w_data = data_w[AXI_DATA_WIDTH:1];
	assign axi_master_w_strb = data_w[DATA_STRB_WIDTH:1 + AXI_DATA_WIDTH];
	assign axi_master_w_user = data_w[DATA_USER_STRB_WIDTH:1 + DATA_STRB_WIDTH];
	assign data_b[1:0] = axi_master_b_resp;
	assign data_b[1 + AXI_ID_WIDTH:2] = axi_master_b_id;
	assign data_b[1 + USER_ID_WIDTH:2 + AXI_ID_WIDTH] = axi_master_b_user;
	assign axi_slave_b_resp = data_async_b[1:0];
	assign axi_slave_b_id = data_async_b[1 + AXI_ID_WIDTH:2];
	assign axi_slave_b_user = data_async_b[1 + USER_ID_WIDTH:2 + AXI_ID_WIDTH];
	dc_token_ring_fifo_dout #(
		WIDTH_FIFO_AW,
		BUFFER_WIDTH
	) dc_awchan(
		.clk(clk_i),
		.rstn(rst_ni),
		.data(data_aw_dc),
		.valid(s_slave_aw_valid),
		.ready(s_slave_aw_ready),
		.write_token(axi_slave_aw_writetoken),
		.read_pointer(axi_slave_aw_readpointer),
		.data_async(data_async_aw)
	);
	axi_single_slice #(
		.DATA_WIDTH(WIDTH_FIFO_AW),
		.BUFFER_DEPTH(1)
	) buffer_awchan(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.testmode_i(test_cgbypass_i),
		.valid_i(s_slave_aw_valid),
		.ready_o(s_slave_aw_ready),
		.data_i(data_aw_dc),
		.ready_i(axi_master_aw_ready),
		.valid_o(axi_master_aw_valid),
		.data_o(data_aw)
	);
	dc_token_ring_fifo_dout #(
		WIDTH_FIFO_AR,
		BUFFER_WIDTH
	) dc_archan(
		.clk(clk_i),
		.rstn(rst_ni),
		.data(data_ar_dc),
		.valid(s_slave_ar_valid),
		.ready(s_slave_ar_ready),
		.write_token(axi_slave_ar_writetoken),
		.read_pointer(axi_slave_ar_readpointer),
		.data_async(data_async_ar)
	);
	axi_single_slice #(
		.DATA_WIDTH(WIDTH_FIFO_AR),
		.BUFFER_DEPTH(1)
	) buffer_archan(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.testmode_i(test_cgbypass_i),
		.valid_i(s_slave_ar_valid),
		.ready_o(s_slave_ar_ready),
		.data_i(data_ar_dc),
		.ready_i(axi_master_ar_ready),
		.valid_o(axi_master_ar_valid),
		.data_o(data_ar)
	);
	dc_token_ring_fifo_dout #(
		WIDTH_FIFO_W,
		BUFFER_WIDTH
	) dc_wchan(
		.clk(clk_i),
		.rstn(rst_ni),
		.data(data_w_dc),
		.valid(s_slave_w_valid),
		.ready(s_slave_w_ready),
		.write_token(axi_slave_w_writetoken),
		.read_pointer(axi_slave_w_readpointer),
		.data_async(data_async_w)
	);
	axi_single_slice #(
		.DATA_WIDTH(WIDTH_FIFO_W),
		.BUFFER_DEPTH(1)
	) buffer_wchan(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.testmode_i(test_cgbypass_i),
		.valid_i(s_slave_w_valid),
		.ready_o(s_slave_w_ready),
		.data_i(data_w_dc),
		.ready_i(axi_master_w_ready),
		.valid_o(axi_master_w_valid),
		.data_o(data_w)
	);
	dc_token_ring_fifo_din #(
		WIDTH_FIFO_R,
		BUFFER_WIDTH
	) dc_rchan(
		.clk(clk_i),
		.rstn(rst_ni),
		.data(data_r),
		.valid(axi_master_r_valid),
		.ready(axi_master_r_ready),
		.write_token(axi_slave_r_writetoken),
		.read_pointer(axi_slave_r_readpointer),
		.data_async(data_async_r)
	);
	dc_token_ring_fifo_din #(
		WIDTH_FIFO_B,
		BUFFER_WIDTH
	) dc_bchan(
		.clk(clk_i),
		.rstn(rst_ni),
		.data(data_b),
		.valid(axi_master_b_valid),
		.ready(axi_master_b_ready),
		.write_token(axi_slave_b_writetoken),
		.read_pointer(axi_slave_b_readpointer),
		.data_async(data_async_b)
	);
endmodule
