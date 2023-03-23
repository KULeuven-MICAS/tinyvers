module axi_aw_buffer (
	clk_i,
	rst_ni,
	test_en_i,
	slave_valid_i,
	slave_addr_i,
	slave_prot_i,
	slave_region_i,
	slave_len_i,
	slave_size_i,
	slave_burst_i,
	slave_lock_i,
	slave_cache_i,
	slave_qos_i,
	slave_id_i,
	slave_user_i,
	slave_ready_o,
	master_valid_o,
	master_addr_o,
	master_prot_o,
	master_region_o,
	master_len_o,
	master_size_o,
	master_burst_o,
	master_lock_o,
	master_cache_o,
	master_qos_o,
	master_id_o,
	master_user_o,
	master_ready_i
);
	parameter signed [31:0] ID_WIDTH = -1;
	parameter signed [31:0] ADDR_WIDTH = -1;
	parameter signed [31:0] USER_WIDTH = -1;
	parameter signed [31:0] BUFFER_DEPTH = -1;
	input wire clk_i;
	input wire rst_ni;
	input wire test_en_i;
	input wire slave_valid_i;
	input wire [ADDR_WIDTH - 1:0] slave_addr_i;
	input wire [2:0] slave_prot_i;
	input wire [3:0] slave_region_i;
	input wire [7:0] slave_len_i;
	input wire [2:0] slave_size_i;
	input wire [1:0] slave_burst_i;
	input wire slave_lock_i;
	input wire [3:0] slave_cache_i;
	input wire [3:0] slave_qos_i;
	input wire [ID_WIDTH - 1:0] slave_id_i;
	input wire [USER_WIDTH - 1:0] slave_user_i;
	output wire slave_ready_o;
	output wire master_valid_o;
	output wire [ADDR_WIDTH - 1:0] master_addr_o;
	output wire [2:0] master_prot_o;
	output wire [3:0] master_region_o;
	output wire [7:0] master_len_o;
	output wire [2:0] master_size_o;
	output wire [1:0] master_burst_o;
	output wire master_lock_o;
	output wire [3:0] master_cache_o;
	output wire [3:0] master_qos_o;
	output wire [ID_WIDTH - 1:0] master_id_o;
	output wire [USER_WIDTH - 1:0] master_user_o;
	input wire master_ready_i;
	wire [(((29 + ADDR_WIDTH) + USER_WIDTH) + ID_WIDTH) - 1:0] s_data_in;
	wire [(((29 + ADDR_WIDTH) + USER_WIDTH) + ID_WIDTH) - 1:0] s_data_out;
	assign s_data_in = {slave_cache_i, slave_prot_i, slave_lock_i, slave_burst_i, slave_size_i, slave_len_i, slave_qos_i, slave_region_i, slave_addr_i, slave_user_i, slave_id_i};
	assign {master_cache_o, master_prot_o, master_lock_o, master_burst_o, master_size_o, master_len_o, master_qos_o, master_region_o, master_addr_o, master_user_o, master_id_o} = s_data_out;
	axi_single_slice #(
		.BUFFER_DEPTH(BUFFER_DEPTH),
		.DATA_WIDTH(((29 + ADDR_WIDTH) + USER_WIDTH) + ID_WIDTH)
	) i_axi_single_slice(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.testmode_i(test_en_i),
		.valid_i(slave_valid_i),
		.ready_o(slave_ready_o),
		.data_i(s_data_in),
		.ready_i(master_ready_i),
		.valid_o(master_valid_o),
		.data_o(s_data_out)
	);
endmodule
