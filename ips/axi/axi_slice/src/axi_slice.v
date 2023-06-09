module axi_slice (
	clk_i,
	rst_ni,
	test_en_i,
	axi_slave_aw_valid_i,
	axi_slave_aw_addr_i,
	axi_slave_aw_prot_i,
	axi_slave_aw_region_i,
	axi_slave_aw_len_i,
	axi_slave_aw_size_i,
	axi_slave_aw_burst_i,
	axi_slave_aw_lock_i,
	axi_slave_aw_cache_i,
	axi_slave_aw_qos_i,
	axi_slave_aw_id_i,
	axi_slave_aw_user_i,
	axi_slave_aw_ready_o,
	axi_slave_ar_valid_i,
	axi_slave_ar_addr_i,
	axi_slave_ar_prot_i,
	axi_slave_ar_region_i,
	axi_slave_ar_len_i,
	axi_slave_ar_size_i,
	axi_slave_ar_burst_i,
	axi_slave_ar_lock_i,
	axi_slave_ar_cache_i,
	axi_slave_ar_qos_i,
	axi_slave_ar_id_i,
	axi_slave_ar_user_i,
	axi_slave_ar_ready_o,
	axi_slave_w_valid_i,
	axi_slave_w_data_i,
	axi_slave_w_strb_i,
	axi_slave_w_user_i,
	axi_slave_w_last_i,
	axi_slave_w_ready_o,
	axi_slave_r_valid_o,
	axi_slave_r_data_o,
	axi_slave_r_resp_o,
	axi_slave_r_last_o,
	axi_slave_r_id_o,
	axi_slave_r_user_o,
	axi_slave_r_ready_i,
	axi_slave_b_valid_o,
	axi_slave_b_resp_o,
	axi_slave_b_id_o,
	axi_slave_b_user_o,
	axi_slave_b_ready_i,
	axi_master_aw_valid_o,
	axi_master_aw_addr_o,
	axi_master_aw_prot_o,
	axi_master_aw_region_o,
	axi_master_aw_len_o,
	axi_master_aw_size_o,
	axi_master_aw_burst_o,
	axi_master_aw_lock_o,
	axi_master_aw_cache_o,
	axi_master_aw_qos_o,
	axi_master_aw_id_o,
	axi_master_aw_user_o,
	axi_master_aw_ready_i,
	axi_master_ar_valid_o,
	axi_master_ar_addr_o,
	axi_master_ar_prot_o,
	axi_master_ar_region_o,
	axi_master_ar_len_o,
	axi_master_ar_size_o,
	axi_master_ar_burst_o,
	axi_master_ar_lock_o,
	axi_master_ar_cache_o,
	axi_master_ar_qos_o,
	axi_master_ar_id_o,
	axi_master_ar_user_o,
	axi_master_ar_ready_i,
	axi_master_w_valid_o,
	axi_master_w_data_o,
	axi_master_w_strb_o,
	axi_master_w_user_o,
	axi_master_w_last_o,
	axi_master_w_ready_i,
	axi_master_r_valid_i,
	axi_master_r_data_i,
	axi_master_r_resp_i,
	axi_master_r_last_i,
	axi_master_r_id_i,
	axi_master_r_user_i,
	axi_master_r_ready_o,
	axi_master_b_valid_i,
	axi_master_b_resp_i,
	axi_master_b_id_i,
	axi_master_b_user_i,
	axi_master_b_ready_o
);
	parameter AXI_ADDR_WIDTH = 32;
	parameter AXI_DATA_WIDTH = 64;
	parameter AXI_USER_WIDTH = 6;
	parameter AXI_ID_WIDTH = 3;
	parameter SLICE_DEPTH = 2;
	parameter AXI_STRB_WIDTH = AXI_DATA_WIDTH / 8;
	input wire clk_i;
	input wire rst_ni;
	input wire test_en_i;
	input wire axi_slave_aw_valid_i;
	input wire [AXI_ADDR_WIDTH - 1:0] axi_slave_aw_addr_i;
	input wire [2:0] axi_slave_aw_prot_i;
	input wire [3:0] axi_slave_aw_region_i;
	input wire [7:0] axi_slave_aw_len_i;
	input wire [2:0] axi_slave_aw_size_i;
	input wire [1:0] axi_slave_aw_burst_i;
	input wire axi_slave_aw_lock_i;
	input wire [3:0] axi_slave_aw_cache_i;
	input wire [3:0] axi_slave_aw_qos_i;
	input wire [AXI_ID_WIDTH - 1:0] axi_slave_aw_id_i;
	input wire [AXI_USER_WIDTH - 1:0] axi_slave_aw_user_i;
	output wire axi_slave_aw_ready_o;
	input wire axi_slave_ar_valid_i;
	input wire [AXI_ADDR_WIDTH - 1:0] axi_slave_ar_addr_i;
	input wire [2:0] axi_slave_ar_prot_i;
	input wire [3:0] axi_slave_ar_region_i;
	input wire [7:0] axi_slave_ar_len_i;
	input wire [2:0] axi_slave_ar_size_i;
	input wire [1:0] axi_slave_ar_burst_i;
	input wire axi_slave_ar_lock_i;
	input wire [3:0] axi_slave_ar_cache_i;
	input wire [3:0] axi_slave_ar_qos_i;
	input wire [AXI_ID_WIDTH - 1:0] axi_slave_ar_id_i;
	input wire [AXI_USER_WIDTH - 1:0] axi_slave_ar_user_i;
	output wire axi_slave_ar_ready_o;
	input wire axi_slave_w_valid_i;
	input wire [AXI_DATA_WIDTH - 1:0] axi_slave_w_data_i;
	input wire [AXI_STRB_WIDTH - 1:0] axi_slave_w_strb_i;
	input wire [AXI_USER_WIDTH - 1:0] axi_slave_w_user_i;
	input wire axi_slave_w_last_i;
	output wire axi_slave_w_ready_o;
	output wire axi_slave_r_valid_o;
	output wire [AXI_DATA_WIDTH - 1:0] axi_slave_r_data_o;
	output wire [1:0] axi_slave_r_resp_o;
	output wire axi_slave_r_last_o;
	output wire [AXI_ID_WIDTH - 1:0] axi_slave_r_id_o;
	output wire [AXI_USER_WIDTH - 1:0] axi_slave_r_user_o;
	input wire axi_slave_r_ready_i;
	output wire axi_slave_b_valid_o;
	output wire [1:0] axi_slave_b_resp_o;
	output wire [AXI_ID_WIDTH - 1:0] axi_slave_b_id_o;
	output wire [AXI_USER_WIDTH - 1:0] axi_slave_b_user_o;
	input wire axi_slave_b_ready_i;
	output wire axi_master_aw_valid_o;
	output wire [AXI_ADDR_WIDTH - 1:0] axi_master_aw_addr_o;
	output wire [2:0] axi_master_aw_prot_o;
	output wire [3:0] axi_master_aw_region_o;
	output wire [7:0] axi_master_aw_len_o;
	output wire [2:0] axi_master_aw_size_o;
	output wire [1:0] axi_master_aw_burst_o;
	output wire axi_master_aw_lock_o;
	output wire [3:0] axi_master_aw_cache_o;
	output wire [3:0] axi_master_aw_qos_o;
	output wire [AXI_ID_WIDTH - 1:0] axi_master_aw_id_o;
	output wire [AXI_USER_WIDTH - 1:0] axi_master_aw_user_o;
	input wire axi_master_aw_ready_i;
	output wire axi_master_ar_valid_o;
	output wire [AXI_ADDR_WIDTH - 1:0] axi_master_ar_addr_o;
	output wire [2:0] axi_master_ar_prot_o;
	output wire [3:0] axi_master_ar_region_o;
	output wire [7:0] axi_master_ar_len_o;
	output wire [2:0] axi_master_ar_size_o;
	output wire [1:0] axi_master_ar_burst_o;
	output wire axi_master_ar_lock_o;
	output wire [3:0] axi_master_ar_cache_o;
	output wire [3:0] axi_master_ar_qos_o;
	output wire [AXI_ID_WIDTH - 1:0] axi_master_ar_id_o;
	output wire [AXI_USER_WIDTH - 1:0] axi_master_ar_user_o;
	input wire axi_master_ar_ready_i;
	output wire axi_master_w_valid_o;
	output wire [AXI_DATA_WIDTH - 1:0] axi_master_w_data_o;
	output wire [AXI_STRB_WIDTH - 1:0] axi_master_w_strb_o;
	output wire [AXI_USER_WIDTH - 1:0] axi_master_w_user_o;
	output wire axi_master_w_last_o;
	input wire axi_master_w_ready_i;
	input wire axi_master_r_valid_i;
	input wire [AXI_DATA_WIDTH - 1:0] axi_master_r_data_i;
	input wire [1:0] axi_master_r_resp_i;
	input wire axi_master_r_last_i;
	input wire [AXI_ID_WIDTH - 1:0] axi_master_r_id_i;
	input wire [AXI_USER_WIDTH - 1:0] axi_master_r_user_i;
	output wire axi_master_r_ready_o;
	input wire axi_master_b_valid_i;
	input wire [1:0] axi_master_b_resp_i;
	input wire [AXI_ID_WIDTH - 1:0] axi_master_b_id_i;
	input wire [AXI_USER_WIDTH - 1:0] axi_master_b_user_i;
	output wire axi_master_b_ready_o;
	axi_aw_buffer #(
		.ID_WIDTH(AXI_ID_WIDTH),
		.ADDR_WIDTH(AXI_ADDR_WIDTH),
		.USER_WIDTH(AXI_USER_WIDTH),
		.BUFFER_DEPTH(SLICE_DEPTH)
	) aw_buffer_i(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.test_en_i(test_en_i),
		.slave_valid_i(axi_slave_aw_valid_i),
		.slave_addr_i(axi_slave_aw_addr_i),
		.slave_prot_i(axi_slave_aw_prot_i),
		.slave_region_i(axi_slave_aw_region_i),
		.slave_len_i(axi_slave_aw_len_i),
		.slave_size_i(axi_slave_aw_size_i),
		.slave_burst_i(axi_slave_aw_burst_i),
		.slave_lock_i(axi_slave_aw_lock_i),
		.slave_cache_i(axi_slave_aw_cache_i),
		.slave_qos_i(axi_slave_aw_qos_i),
		.slave_id_i(axi_slave_aw_id_i),
		.slave_user_i(axi_slave_aw_user_i),
		.slave_ready_o(axi_slave_aw_ready_o),
		.master_valid_o(axi_master_aw_valid_o),
		.master_addr_o(axi_master_aw_addr_o),
		.master_prot_o(axi_master_aw_prot_o),
		.master_region_o(axi_master_aw_region_o),
		.master_len_o(axi_master_aw_len_o),
		.master_size_o(axi_master_aw_size_o),
		.master_burst_o(axi_master_aw_burst_o),
		.master_lock_o(axi_master_aw_lock_o),
		.master_cache_o(axi_master_aw_cache_o),
		.master_qos_o(axi_master_aw_qos_o),
		.master_id_o(axi_master_aw_id_o),
		.master_user_o(axi_master_aw_user_o),
		.master_ready_i(axi_master_aw_ready_i)
	);
	axi_ar_buffer #(
		.ID_WIDTH(AXI_ID_WIDTH),
		.ADDR_WIDTH(AXI_ADDR_WIDTH),
		.USER_WIDTH(AXI_USER_WIDTH),
		.BUFFER_DEPTH(SLICE_DEPTH)
	) ar_buffer_i(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.test_en_i(test_en_i),
		.slave_valid_i(axi_slave_ar_valid_i),
		.slave_addr_i(axi_slave_ar_addr_i),
		.slave_prot_i(axi_slave_ar_prot_i),
		.slave_region_i(axi_slave_ar_region_i),
		.slave_len_i(axi_slave_ar_len_i),
		.slave_size_i(axi_slave_ar_size_i),
		.slave_burst_i(axi_slave_ar_burst_i),
		.slave_lock_i(axi_slave_ar_lock_i),
		.slave_cache_i(axi_slave_ar_cache_i),
		.slave_qos_i(axi_slave_ar_qos_i),
		.slave_id_i(axi_slave_ar_id_i),
		.slave_user_i(axi_slave_ar_user_i),
		.slave_ready_o(axi_slave_ar_ready_o),
		.master_valid_o(axi_master_ar_valid_o),
		.master_addr_o(axi_master_ar_addr_o),
		.master_prot_o(axi_master_ar_prot_o),
		.master_region_o(axi_master_ar_region_o),
		.master_len_o(axi_master_ar_len_o),
		.master_size_o(axi_master_ar_size_o),
		.master_burst_o(axi_master_ar_burst_o),
		.master_lock_o(axi_master_ar_lock_o),
		.master_cache_o(axi_master_ar_cache_o),
		.master_qos_o(axi_master_ar_qos_o),
		.master_id_o(axi_master_ar_id_o),
		.master_user_o(axi_master_ar_user_o),
		.master_ready_i(axi_master_ar_ready_i)
	);
	axi_w_buffer #(
		.DATA_WIDTH(AXI_DATA_WIDTH),
		.USER_WIDTH(AXI_USER_WIDTH),
		.BUFFER_DEPTH(SLICE_DEPTH)
	) w_buffer_i(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.test_en_i(test_en_i),
		.slave_valid_i(axi_slave_w_valid_i),
		.slave_data_i(axi_slave_w_data_i),
		.slave_strb_i(axi_slave_w_strb_i),
		.slave_user_i(axi_slave_w_user_i),
		.slave_last_i(axi_slave_w_last_i),
		.slave_ready_o(axi_slave_w_ready_o),
		.master_valid_o(axi_master_w_valid_o),
		.master_data_o(axi_master_w_data_o),
		.master_strb_o(axi_master_w_strb_o),
		.master_user_o(axi_master_w_user_o),
		.master_last_o(axi_master_w_last_o),
		.master_ready_i(axi_master_w_ready_i)
	);
	axi_r_buffer #(
		.ID_WIDTH(AXI_ID_WIDTH),
		.DATA_WIDTH(AXI_DATA_WIDTH),
		.USER_WIDTH(AXI_USER_WIDTH),
		.BUFFER_DEPTH(SLICE_DEPTH)
	) r_buffer_i(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.test_en_i(test_en_i),
		.slave_valid_i(axi_master_r_valid_i),
		.slave_data_i(axi_master_r_data_i),
		.slave_resp_i(axi_master_r_resp_i),
		.slave_user_i(axi_master_r_user_i),
		.slave_id_i(axi_master_r_id_i),
		.slave_last_i(axi_master_r_last_i),
		.slave_ready_o(axi_master_r_ready_o),
		.master_valid_o(axi_slave_r_valid_o),
		.master_data_o(axi_slave_r_data_o),
		.master_resp_o(axi_slave_r_resp_o),
		.master_user_o(axi_slave_r_user_o),
		.master_id_o(axi_slave_r_id_o),
		.master_last_o(axi_slave_r_last_o),
		.master_ready_i(axi_slave_r_ready_i)
	);
	axi_b_buffer #(
		.ID_WIDTH(AXI_ID_WIDTH),
		.USER_WIDTH(AXI_USER_WIDTH),
		.BUFFER_DEPTH(SLICE_DEPTH)
	) b_buffer_i(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.test_en_i(test_en_i),
		.slave_valid_i(axi_master_b_valid_i),
		.slave_resp_i(axi_master_b_resp_i),
		.slave_id_i(axi_master_b_id_i),
		.slave_user_i(axi_master_b_user_i),
		.slave_ready_o(axi_master_b_ready_o),
		.master_valid_o(axi_slave_b_valid_o),
		.master_resp_o(axi_slave_b_resp_o),
		.master_id_o(axi_slave_b_id_o),
		.master_user_o(axi_slave_b_user_o),
		.master_ready_i(axi_slave_b_ready_i)
	);
endmodule
