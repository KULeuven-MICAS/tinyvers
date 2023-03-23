module axi64_2_lint32 (
	clk,
	rst_n,
	test_en_i,
	AW_ADDR_i,
	AW_PROT_i,
	AW_REGION_i,
	AW_LEN_i,
	AW_SIZE_i,
	AW_BURST_i,
	AW_LOCK_i,
	AW_CACHE_i,
	AW_QOS_i,
	AW_ID_i,
	AW_USER_i,
	AW_VALID_i,
	AW_READY_o,
	AR_ADDR_i,
	AR_PROT_i,
	AR_REGION_i,
	AR_LEN_i,
	AR_SIZE_i,
	AR_BURST_i,
	AR_LOCK_i,
	AR_CACHE_i,
	AR_QOS_i,
	AR_ID_i,
	AR_USER_i,
	AR_VALID_i,
	AR_READY_o,
	W_USER_i,
	W_DATA_i,
	W_STRB_i,
	W_LAST_i,
	W_VALID_i,
	W_READY_o,
	B_ID_o,
	B_RESP_o,
	B_USER_o,
	B_VALID_o,
	B_READY_i,
	R_ID_o,
	R_USER_o,
	R_DATA_o,
	R_RESP_o,
	R_LAST_o,
	R_VALID_o,
	R_READY_i,
	data_W_req_o,
	data_W_gnt_i,
	data_W_wdata_o,
	data_W_add_o,
	data_W_wen_o,
	data_W_be_o,
	data_W_aux_o,
	data_W_r_valid_i,
	data_W_r_rdata_i,
	data_W_r_aux_i,
	data_W_r_opc_i,
	data_R_req_o,
	data_R_gnt_i,
	data_R_wdata_o,
	data_R_add_o,
	data_R_wen_o,
	data_R_be_o,
	data_R_aux_o,
	data_R_r_valid_i,
	data_R_r_rdata_i,
	data_R_r_aux_i,
	data_R_r_opc_i
);
	parameter AXI_ADDR_WIDTH = 32;
	parameter AXI_DATA_WIDTH = 64;
	parameter AXI_STRB_WIDTH = 8;
	parameter AXI_USER_WIDTH = 6;
	parameter AXI_ID_WIDTH = 7;
	parameter BUFF_DEPTH_SLICES = 4;
	parameter DATA_WIDTH = 32;
	parameter BE_WIDTH = DATA_WIDTH / 8;
	parameter ADDR_WIDTH = 32;
	parameter AUX_WIDTH = 4;
	input wire clk;
	input wire rst_n;
	input wire test_en_i;
	input wire [AXI_ADDR_WIDTH - 1:0] AW_ADDR_i;
	input wire [2:0] AW_PROT_i;
	input wire [3:0] AW_REGION_i;
	input wire [7:0] AW_LEN_i;
	input wire [2:0] AW_SIZE_i;
	input wire [1:0] AW_BURST_i;
	input wire AW_LOCK_i;
	input wire [3:0] AW_CACHE_i;
	input wire [3:0] AW_QOS_i;
	input wire [AXI_ID_WIDTH - 1:0] AW_ID_i;
	input wire [AXI_USER_WIDTH - 1:0] AW_USER_i;
	input wire AW_VALID_i;
	output wire AW_READY_o;
	input wire [AXI_ADDR_WIDTH - 1:0] AR_ADDR_i;
	input wire [2:0] AR_PROT_i;
	input wire [3:0] AR_REGION_i;
	input wire [7:0] AR_LEN_i;
	input wire [2:0] AR_SIZE_i;
	input wire [1:0] AR_BURST_i;
	input wire AR_LOCK_i;
	input wire [3:0] AR_CACHE_i;
	input wire [3:0] AR_QOS_i;
	input wire [AXI_ID_WIDTH - 1:0] AR_ID_i;
	input wire [AXI_USER_WIDTH - 1:0] AR_USER_i;
	input wire AR_VALID_i;
	output wire AR_READY_o;
	input wire [AXI_USER_WIDTH - 1:0] W_USER_i;
	input wire [AXI_DATA_WIDTH - 1:0] W_DATA_i;
	input wire [AXI_STRB_WIDTH - 1:0] W_STRB_i;
	input wire W_LAST_i;
	input wire W_VALID_i;
	output wire W_READY_o;
	output wire [AXI_ID_WIDTH - 1:0] B_ID_o;
	output wire [1:0] B_RESP_o;
	output wire [AXI_USER_WIDTH - 1:0] B_USER_o;
	output wire B_VALID_o;
	input wire B_READY_i;
	output wire [AXI_ID_WIDTH - 1:0] R_ID_o;
	output wire [AXI_USER_WIDTH - 1:0] R_USER_o;
	output wire [AXI_DATA_WIDTH - 1:0] R_DATA_o;
	output wire [1:0] R_RESP_o;
	output wire R_LAST_o;
	output wire R_VALID_o;
	input wire R_READY_i;
	output wire [1:0] data_W_req_o;
	input wire [1:0] data_W_gnt_i;
	output wire [(2 * DATA_WIDTH) - 1:0] data_W_wdata_o;
	output wire [(2 * ADDR_WIDTH) - 1:0] data_W_add_o;
	output wire [1:0] data_W_wen_o;
	output wire [(2 * BE_WIDTH) - 1:0] data_W_be_o;
	output wire [(2 * AUX_WIDTH) - 1:0] data_W_aux_o;
	input wire [1:0] data_W_r_valid_i;
	input wire [(2 * DATA_WIDTH) - 1:0] data_W_r_rdata_i;
	input wire [(2 * AUX_WIDTH) - 1:0] data_W_r_aux_i;
	input wire [1:0] data_W_r_opc_i;
	output wire [1:0] data_R_req_o;
	input wire [1:0] data_R_gnt_i;
	output wire [(2 * DATA_WIDTH) - 1:0] data_R_wdata_o;
	output wire [(2 * ADDR_WIDTH) - 1:0] data_R_add_o;
	output wire [1:0] data_R_wen_o;
	output wire [(2 * BE_WIDTH) - 1:0] data_R_be_o;
	output wire [(2 * AUX_WIDTH) - 1:0] data_R_aux_o;
	input wire [1:0] data_R_r_valid_i;
	input wire [(2 * DATA_WIDTH) - 1:0] data_R_r_rdata_i;
	input wire [(2 * AUX_WIDTH) - 1:0] data_R_r_aux_i;
	input wire [1:0] data_R_r_opc_i;
	localparam ADDR_OFFSET = $clog2(DATA_WIDTH) - 3;
	wire [AXI_ADDR_WIDTH - 1:0] AW_ADDR_int;
	wire [2:0] AW_PROT_int;
	wire [3:0] AW_REGION_int;
	wire [7:0] AW_LEN_int;
	wire [2:0] AW_SIZE_int;
	wire [1:0] AW_BURST_int;
	wire AW_LOCK_int;
	wire [3:0] AW_CACHE_int;
	wire [3:0] AW_QOS_int;
	wire [AXI_ID_WIDTH - 1:0] AW_ID_int;
	wire [AXI_USER_WIDTH - 1:0] AW_USER_int;
	wire AW_VALID_int;
	wire AW_READY_int;
	wire [AXI_ADDR_WIDTH - 1:0] AR_ADDR_int;
	wire [2:0] AR_PROT_int;
	wire [3:0] AR_REGION_int;
	wire [7:0] AR_LEN_int;
	wire [2:0] AR_SIZE_int;
	wire [1:0] AR_BURST_int;
	wire AR_LOCK_int;
	wire [3:0] AR_CACHE_int;
	wire [3:0] AR_QOS_int;
	wire [AXI_ID_WIDTH - 1:0] AR_ID_int;
	wire [AXI_USER_WIDTH - 1:0] AR_USER_int;
	wire AR_VALID_int;
	wire AR_READY_int;
	wire [AXI_USER_WIDTH - 1:0] W_USER_int;
	wire [AXI_DATA_WIDTH - 1:0] W_DATA_int;
	wire [AXI_STRB_WIDTH - 1:0] W_STRB_int;
	wire W_LAST_int;
	wire W_VALID_int;
	wire W_READY_int;
	wire [AXI_ID_WIDTH - 1:0] B_ID_int;
	wire [1:0] B_RESP_int;
	wire [AXI_USER_WIDTH - 1:0] B_USER_int;
	wire B_VALID_int;
	wire B_READY_int;
	wire [AXI_ID_WIDTH - 1:0] R_ID_int;
	wire [AXI_USER_WIDTH - 1:0] R_USER_int;
	wire [AXI_DATA_WIDTH - 1:0] R_DATA_int;
	wire [1:0] R_RESP_int;
	wire R_LAST_int;
	wire R_VALID_int;
	wire R_READY_int;
	wire data_W_req_int;
	wire data_W_gnt_int;
	wire [63:0] data_W_wdata_int;
	wire [31:0] data_W_add_int;
	wire data_W_wen_int;
	wire [7:0] data_W_be_int;
	wire data_W_r_valid_int;
	wire [63:0] data_W_r_rdata_int;
	wire data_R_req_int;
	wire data_R_gnt_int;
	wire [63:0] data_R_wdata_int;
	wire [31:0] data_R_add_int;
	wire data_R_wen_int;
	wire [7:0] data_R_be_int;
	wire data_R_r_valid_int;
	wire [63:0] data_R_r_rdata_int;
	assign data_R_aux_o = 1'sb0;
	assign data_W_aux_o = 1'sb0;
	axi_aw_buffer #(
		.ID_WIDTH(AXI_ID_WIDTH),
		.ADDR_WIDTH(AXI_ADDR_WIDTH),
		.USER_WIDTH(AXI_USER_WIDTH),
		.BUFFER_DEPTH(BUFF_DEPTH_SLICES)
	) Slave_aw_buffer(
		.clk_i(clk),
		.rst_ni(rst_n),
		.test_en_i(test_en_i),
		.slave_valid_i(AW_VALID_i),
		.slave_addr_i(AW_ADDR_i),
		.slave_prot_i(AW_PROT_i),
		.slave_region_i(AW_REGION_i),
		.slave_len_i(AW_LEN_i),
		.slave_size_i(AW_SIZE_i),
		.slave_burst_i(AW_BURST_i),
		.slave_lock_i(AW_LOCK_i),
		.slave_cache_i(AW_CACHE_i),
		.slave_qos_i(AW_QOS_i),
		.slave_id_i(AW_ID_i),
		.slave_user_i(AW_USER_i),
		.slave_ready_o(AW_READY_o),
		.master_valid_o(AW_VALID_int),
		.master_addr_o(AW_ADDR_int),
		.master_prot_o(AW_PROT_int),
		.master_region_o(AW_REGION_int),
		.master_len_o(AW_LEN_int),
		.master_size_o(AW_SIZE_int),
		.master_burst_o(AW_BURST_int),
		.master_lock_o(AW_LOCK_int),
		.master_cache_o(AW_CACHE_int),
		.master_qos_o(AW_QOS_int),
		.master_id_o(AW_ID_int),
		.master_user_o(AW_USER_int),
		.master_ready_i(AW_READY_int)
	);
	axi_ar_buffer #(
		.ID_WIDTH(AXI_ID_WIDTH),
		.ADDR_WIDTH(AXI_ADDR_WIDTH),
		.USER_WIDTH(AXI_USER_WIDTH),
		.BUFFER_DEPTH(BUFF_DEPTH_SLICES)
	) Slave_ar_buffer(
		.clk_i(clk),
		.rst_ni(rst_n),
		.test_en_i(test_en_i),
		.slave_valid_i(AR_VALID_i),
		.slave_addr_i(AR_ADDR_i),
		.slave_prot_i(AR_PROT_i),
		.slave_region_i(AR_REGION_i),
		.slave_len_i(AR_LEN_i),
		.slave_size_i(AR_SIZE_i),
		.slave_burst_i(AR_BURST_i),
		.slave_lock_i(AR_LOCK_i),
		.slave_cache_i(AR_CACHE_i),
		.slave_qos_i(AR_QOS_i),
		.slave_id_i(AR_ID_i),
		.slave_user_i(AR_USER_i),
		.slave_ready_o(AR_READY_o),
		.master_valid_o(AR_VALID_int),
		.master_addr_o(AR_ADDR_int),
		.master_prot_o(AR_PROT_int),
		.master_region_o(AR_REGION_int),
		.master_len_o(AR_LEN_int),
		.master_size_o(AR_SIZE_int),
		.master_burst_o(AR_BURST_int),
		.master_lock_o(AR_LOCK_int),
		.master_cache_o(AR_CACHE_int),
		.master_qos_o(AR_QOS_int),
		.master_id_o(AR_ID_int),
		.master_user_o(AR_USER_int),
		.master_ready_i(AR_READY_int)
	);
	axi_w_buffer #(
		.DATA_WIDTH(AXI_DATA_WIDTH),
		.USER_WIDTH(AXI_USER_WIDTH),
		.BUFFER_DEPTH(BUFF_DEPTH_SLICES)
	) Slave_w_buffer(
		.clk_i(clk),
		.rst_ni(rst_n),
		.test_en_i(test_en_i),
		.slave_valid_i(W_VALID_i),
		.slave_data_i(W_DATA_i),
		.slave_strb_i(W_STRB_i),
		.slave_user_i(W_USER_i),
		.slave_last_i(W_LAST_i),
		.slave_ready_o(W_READY_o),
		.master_valid_o(W_VALID_int),
		.master_data_o(W_DATA_int),
		.master_strb_o(W_STRB_int),
		.master_user_o(W_USER_int),
		.master_last_o(W_LAST_int),
		.master_ready_i(W_READY_int)
	);
	axi_r_buffer #(
		.ID_WIDTH(AXI_ID_WIDTH),
		.DATA_WIDTH(AXI_DATA_WIDTH),
		.USER_WIDTH(AXI_USER_WIDTH),
		.BUFFER_DEPTH(BUFF_DEPTH_SLICES)
	) Slave_r_buffer(
		.clk_i(clk),
		.rst_ni(rst_n),
		.test_en_i(test_en_i),
		.slave_valid_i(R_VALID_int),
		.slave_data_i(R_DATA_int),
		.slave_resp_i(R_RESP_int),
		.slave_user_i(R_USER_int),
		.slave_id_i(R_ID_int),
		.slave_last_i(R_LAST_int),
		.slave_ready_o(R_READY_int),
		.master_valid_o(R_VALID_o),
		.master_data_o(R_DATA_o),
		.master_resp_o(R_RESP_o),
		.master_user_o(R_USER_o),
		.master_id_o(R_ID_o),
		.master_last_o(R_LAST_o),
		.master_ready_i(R_READY_i)
	);
	axi_b_buffer #(
		.ID_WIDTH(AXI_ID_WIDTH),
		.USER_WIDTH(AXI_USER_WIDTH),
		.BUFFER_DEPTH(BUFF_DEPTH_SLICES)
	) Slave_b_buffer(
		.clk_i(clk),
		.rst_ni(rst_n),
		.test_en_i(test_en_i),
		.slave_valid_i(B_VALID_int),
		.slave_resp_i(B_RESP_int),
		.slave_id_i(B_ID_int),
		.slave_user_i(B_USER_int),
		.slave_ready_o(B_READY_int),
		.master_valid_o(B_VALID_o),
		.master_resp_o(B_RESP_o),
		.master_id_o(B_ID_o),
		.master_user_o(B_USER_o),
		.master_ready_i(B_READY_i)
	);
	wire data_W_size_int;
	wire data_R_size_int;
	localparam sv2v_uu_i_axi_write_ctrl_AXI4_RDATA_WIDTH = AXI_DATA_WIDTH;
	localparam [sv2v_uu_i_axi_write_ctrl_AXI4_RDATA_WIDTH - 1:0] sv2v_uu_i_axi_write_ctrl_ext_MEM_Q_i_0 = 1'sb0;
	axi_write_ctrl #(
		.AXI4_ADDRESS_WIDTH(AXI_ADDR_WIDTH),
		.AXI4_RDATA_WIDTH(AXI_DATA_WIDTH),
		.AXI4_WDATA_WIDTH(AXI_DATA_WIDTH),
		.AXI4_ID_WIDTH(AXI_ID_WIDTH),
		.AXI4_USER_WIDTH(AXI_USER_WIDTH),
		.AXI_NUMBYTES(AXI_STRB_WIDTH),
		.MEM_ADDR_WIDTH(ADDR_WIDTH)
	) i_axi_write_ctrl(
		.clk(clk),
		.rst_n(rst_n),
		.AWID_i(AW_ID_int),
		.AWADDR_i(AW_ADDR_int),
		.AWLEN_i(AW_LEN_int),
		.AWSIZE_i(AW_SIZE_int),
		.AWBURST_i(AW_BURST_int),
		.AWLOCK_i(AW_LOCK_int),
		.AWCACHE_i(AW_CACHE_int),
		.AWPROT_i(AW_PROT_int),
		.AWREGION_i(AW_REGION_int),
		.AWUSER_i(AW_USER_int),
		.AWQOS_i(AW_QOS_int),
		.AWVALID_i(AW_VALID_int),
		.AWREADY_o(AW_READY_int),
		.WDATA_i(W_DATA_int),
		.WSTRB_i(W_STRB_int),
		.WLAST_i(W_LAST_int),
		.WUSER_i(W_USER_int),
		.WVALID_i(W_VALID_int),
		.WREADY_o(W_READY_int),
		.BID_o(B_ID_int),
		.BRESP_o(B_RESP_int),
		.BVALID_o(B_VALID_int),
		.BUSER_o(B_USER_int),
		.BREADY_i(B_READY_int),
		.MEM_WEN_o(data_W_wen_int),
		.MEM_A_o(data_W_add_int),
		.MEM_D_o(data_W_wdata_int),
		.MEM_BE_o(data_W_be_int),
		.MEM_Q_i(sv2v_uu_i_axi_write_ctrl_ext_MEM_Q_i_0),
		.MEM_size_o(data_W_size_int),
		.grant_i(data_W_gnt_int),
		.valid_o(data_W_req_int)
	);
	lint64_to_32 parallel_lint_write(
		.clk(clk),
		.rst_n(rst_n),
		.data_req_i(data_W_req_int),
		.data_gnt_o(data_W_gnt_int),
		.data_wdata_i(data_W_wdata_int),
		.data_add_i(data_W_add_int),
		.data_wen_i(data_W_wen_int),
		.data_be_i(data_W_be_int),
		.data_size_i(data_W_size_int),
		.data_r_valid_o(data_W_r_valid_int),
		.data_r_rdata_o(data_W_r_rdata_int),
		.data_req_o(data_W_req_o),
		.data_gnt_i(data_W_gnt_i),
		.data_wdata_o(data_W_wdata_o),
		.data_add_o(data_W_add_o),
		.data_wen_o(data_W_wen_o),
		.data_be_o(data_W_be_o),
		.data_r_valid_i(data_W_r_valid_i),
		.data_r_rdata_i(data_W_r_rdata_i)
	);
	axi_read_ctrl #(
		.AXI4_ADDRESS_WIDTH(AXI_ADDR_WIDTH),
		.AXI4_RDATA_WIDTH(AXI_DATA_WIDTH),
		.AXI4_WDATA_WIDTH(AXI_DATA_WIDTH),
		.AXI4_ID_WIDTH(AXI_ID_WIDTH),
		.AXI4_USER_WIDTH(AXI_USER_WIDTH),
		.AXI_NUMBYTES(AXI_STRB_WIDTH),
		.MEM_ADDR_WIDTH(ADDR_WIDTH)
	) i_axi_read_ctrl(
		.clk(clk),
		.rst_n(rst_n),
		.ARID_i(AR_ID_int),
		.ARADDR_i(AR_ADDR_int),
		.ARLEN_i(AR_LEN_int),
		.ARSIZE_i(AR_SIZE_int),
		.ARBURST_i(AR_BURST_int),
		.ARLOCK_i(AR_LOCK_int),
		.ARCACHE_i(AR_CACHE_int),
		.ARPROT_i(AR_PROT_int),
		.ARREGION_i(AR_REGION_int),
		.ARUSER_i(AR_USER_int),
		.ARQOS_i(AR_QOS_int),
		.ARVALID_i(AR_VALID_int),
		.ARREADY_o(AR_READY_int),
		.RID_o(R_ID_int),
		.RDATA_o(R_DATA_int),
		.RRESP_o(R_RESP_int),
		.RLAST_o(R_LAST_int),
		.RUSER_o(R_USER_int),
		.RVALID_o(R_VALID_int),
		.RREADY_i(R_READY_int),
		.MEM_WEN_o(data_R_wen_int),
		.MEM_A_o(data_R_add_int),
		.MEM_D_o(data_R_wdata_int),
		.MEM_BE_o(data_R_be_int),
		.MEM_Q_i(data_R_r_rdata_int),
		.grant_i(data_R_gnt_int),
		.valid_o(data_R_req_int),
		.r_valid_i(data_R_r_valid_int),
		.MEM_size_o(data_R_size_int)
	);
	lint64_to_32 parallel_lint_read(
		.clk(clk),
		.rst_n(rst_n),
		.data_req_i(data_R_req_int),
		.data_gnt_o(data_R_gnt_int),
		.data_wdata_i(data_R_wdata_int),
		.data_add_i(data_R_add_int),
		.data_wen_i(data_R_wen_int),
		.data_be_i(data_R_be_int),
		.data_r_valid_o(data_R_r_valid_int),
		.data_r_rdata_o(data_R_r_rdata_int),
		.data_size_i(data_R_size_int),
		.data_req_o(data_R_req_o),
		.data_gnt_i(data_R_gnt_i),
		.data_wdata_o(data_R_wdata_o),
		.data_add_o(data_R_add_o),
		.data_wen_o(data_R_wen_o),
		.data_be_o(data_R_be_o),
		.data_r_valid_i(data_R_r_valid_i),
		.data_r_rdata_i(data_R_r_rdata_i)
	);
endmodule
