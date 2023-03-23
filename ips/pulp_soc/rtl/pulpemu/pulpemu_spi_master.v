module pulpemu_spi_master (
	mode_fmc_zynqn_i,
	zynq_clk,
	zynq_rst_n,
	zynq_axi_aw_valid_o,
	zynq_axi_aw_addr_o,
	zynq_axi_aw_prot_o,
	zynq_axi_aw_region_o,
	zynq_axi_aw_len_o,
	zynq_axi_aw_size_o,
	zynq_axi_aw_burst_o,
	zynq_axi_aw_lock_o,
	zynq_axi_aw_cache_o,
	zynq_axi_aw_qos_o,
	zynq_axi_aw_id_o,
	zynq_axi_aw_user_o,
	zynq_axi_aw_ready_i,
	zynq_axi_ar_valid_o,
	zynq_axi_ar_addr_o,
	zynq_axi_ar_prot_o,
	zynq_axi_ar_region_o,
	zynq_axi_ar_len_o,
	zynq_axi_ar_size_o,
	zynq_axi_ar_burst_o,
	zynq_axi_ar_lock_o,
	zynq_axi_ar_cache_o,
	zynq_axi_ar_qos_o,
	zynq_axi_ar_id_o,
	zynq_axi_ar_user_o,
	zynq_axi_ar_ready_i,
	zynq_axi_w_valid_o,
	zynq_axi_w_data_o,
	zynq_axi_w_strb_o,
	zynq_axi_w_user_o,
	zynq_axi_w_last_o,
	zynq_axi_w_ready_i,
	zynq_axi_r_valid_i,
	zynq_axi_r_data_i,
	zynq_axi_r_resp_i,
	zynq_axi_r_last_i,
	zynq_axi_r_id_i,
	zynq_axi_r_user_i,
	zynq_axi_r_ready_o,
	zynq_axi_b_valid_i,
	zynq_axi_b_resp_i,
	zynq_axi_b_id_i,
	zynq_axi_b_user_i,
	zynq_axi_b_ready_o,
	pulp_spi_clk_i,
	pulp_spi_csn_i,
	pulp_spi_mode_i,
	pulp_spi_sdo0_i,
	pulp_spi_sdo1_i,
	pulp_spi_sdo2_i,
	pulp_spi_sdo3_i,
	pulp_spi_sdi0_o,
	pulp_spi_sdi1_o,
	pulp_spi_sdi2_o,
	pulp_spi_sdi3_o,
	pads2pulp_spi_clk_o,
	pads2pulp_spi_csn_o,
	pads2pulp_spi_mode_o,
	pads2pulp_spi_sdo0_o,
	pads2pulp_spi_sdo1_o,
	pads2pulp_spi_sdo2_o,
	pads2pulp_spi_sdo3_o,
	pads2pulp_spi_sdi0_i,
	pads2pulp_spi_sdi1_i,
	pads2pulp_spi_sdi2_i,
	pads2pulp_spi_sdi3_i
);
	parameter AXI_ADDR_WIDTH = 32;
	parameter AXI_DATA_WIDTH = 32;
	parameter AXI_USER_WIDTH = 0;
	parameter AXI_ID_WIDTH = 16;
	parameter BUFFER_DEPTH = 8;
	parameter DUMMY_CYCLES = 32;
	parameter SWITCH_ENDIANNESS = 1;
	input wire mode_fmc_zynqn_i;
	input wire zynq_clk;
	input wire zynq_rst_n;
	output wire zynq_axi_aw_valid_o;
	output wire [AXI_ADDR_WIDTH - 1:0] zynq_axi_aw_addr_o;
	output wire [2:0] zynq_axi_aw_prot_o;
	output wire [3:0] zynq_axi_aw_region_o;
	output wire [7:0] zynq_axi_aw_len_o;
	output wire [2:0] zynq_axi_aw_size_o;
	output wire [1:0] zynq_axi_aw_burst_o;
	output wire zynq_axi_aw_lock_o;
	output wire [3:0] zynq_axi_aw_cache_o;
	output wire [3:0] zynq_axi_aw_qos_o;
	output wire [AXI_ID_WIDTH - 1:0] zynq_axi_aw_id_o;
	output wire [AXI_USER_WIDTH - 1:0] zynq_axi_aw_user_o;
	input wire zynq_axi_aw_ready_i;
	output wire zynq_axi_ar_valid_o;
	output wire [AXI_ADDR_WIDTH - 1:0] zynq_axi_ar_addr_o;
	output wire [2:0] zynq_axi_ar_prot_o;
	output wire [3:0] zynq_axi_ar_region_o;
	output wire [7:0] zynq_axi_ar_len_o;
	output wire [2:0] zynq_axi_ar_size_o;
	output wire [1:0] zynq_axi_ar_burst_o;
	output wire zynq_axi_ar_lock_o;
	output wire [3:0] zynq_axi_ar_cache_o;
	output wire [3:0] zynq_axi_ar_qos_o;
	output wire [AXI_ID_WIDTH - 1:0] zynq_axi_ar_id_o;
	output wire [AXI_USER_WIDTH - 1:0] zynq_axi_ar_user_o;
	input wire zynq_axi_ar_ready_i;
	output wire zynq_axi_w_valid_o;
	output wire [AXI_DATA_WIDTH - 1:0] zynq_axi_w_data_o;
	output wire [(AXI_DATA_WIDTH / 8) - 1:0] zynq_axi_w_strb_o;
	output wire [AXI_USER_WIDTH - 1:0] zynq_axi_w_user_o;
	output wire zynq_axi_w_last_o;
	input wire zynq_axi_w_ready_i;
	input wire zynq_axi_r_valid_i;
	input wire [AXI_DATA_WIDTH - 1:0] zynq_axi_r_data_i;
	input wire [1:0] zynq_axi_r_resp_i;
	input wire zynq_axi_r_last_i;
	input wire [AXI_ID_WIDTH - 1:0] zynq_axi_r_id_i;
	input wire [AXI_USER_WIDTH - 1:0] zynq_axi_r_user_i;
	output wire zynq_axi_r_ready_o;
	input wire zynq_axi_b_valid_i;
	input wire [1:0] zynq_axi_b_resp_i;
	input wire [AXI_ID_WIDTH - 1:0] zynq_axi_b_id_i;
	input wire [AXI_USER_WIDTH - 1:0] zynq_axi_b_user_i;
	output wire zynq_axi_b_ready_o;
	input wire pulp_spi_clk_i;
	input wire pulp_spi_csn_i;
	input wire [1:0] pulp_spi_mode_i;
	input wire pulp_spi_sdo0_i;
	input wire pulp_spi_sdo1_i;
	input wire pulp_spi_sdo2_i;
	input wire pulp_spi_sdo3_i;
	output wire pulp_spi_sdi0_o;
	output wire pulp_spi_sdi1_o;
	output wire pulp_spi_sdi2_o;
	output wire pulp_spi_sdi3_o;
	output wire pads2pulp_spi_clk_o;
	output wire pads2pulp_spi_csn_o;
	output wire [1:0] pads2pulp_spi_mode_o;
	output wire pads2pulp_spi_sdo0_o;
	output wire pads2pulp_spi_sdo1_o;
	output wire pads2pulp_spi_sdo2_o;
	output wire pads2pulp_spi_sdo3_o;
	input wire pads2pulp_spi_sdi0_i;
	input wire pads2pulp_spi_sdi1_i;
	input wire pads2pulp_spi_sdi2_i;
	input wire pads2pulp_spi_sdi3_i;
	wire zynq_axi_aw_valid_s;
	wire zynq_axi_ar_valid_s;
	wire zynq_axi_w_valid_s;
	wire zynq_axi_b_ready_s;
	wire zynq_axi_r_ready_s;
	wire zynq_pulp_spi_clk;
	wire zynq_pulp_spi_csn;
	wire zynq_pulp_spi_sdi0;
	wire zynq_pulp_spi_sdi1;
	wire zynq_pulp_spi_sdi2;
	wire zynq_pulp_spi_sdi3;
	wire zynq_pulp_spi_sdo0;
	wire zynq_pulp_spi_sdo1;
	wire zynq_pulp_spi_sdo2;
	wire zynq_pulp_spi_sdo3;
	wire [AXI_ADDR_WIDTH - 1:0] zynq_axi_aw_addr_int;
	wire [AXI_ADDR_WIDTH - 1:0] zynq_axi_ar_addr_int;
	wire [AXI_ADDR_WIDTH - 1:0] zynq_axi_w_data_int;
	wire [AXI_ADDR_WIDTH - 1:0] zynq_axi_r_data_int;
	axi_spi_slave #(
		.AXI_ADDR_WIDTH(AXI_ADDR_WIDTH),
		.AXI_DATA_WIDTH(AXI_DATA_WIDTH),
		.AXI_USER_WIDTH(AXI_USER_WIDTH),
		.AXI_ID_WIDTH(AXI_ID_WIDTH),
		.DUMMY_CYCLES(DUMMY_CYCLES)
	) axi_spi_slave_i(
		.test_mode(1'b0),
		.spi_sclk(zynq_pulp_spi_clk),
		.spi_cs(zynq_pulp_spi_csn),
		.spi_mode(),
		.spi_sdi0(zynq_pulp_spi_sdi0),
		.spi_sdi1(zynq_pulp_spi_sdi1),
		.spi_sdi2(zynq_pulp_spi_sdi2),
		.spi_sdi3(zynq_pulp_spi_sdi3),
		.spi_sdo0(zynq_pulp_spi_sdo0),
		.spi_sdo1(zynq_pulp_spi_sdo1),
		.spi_sdo2(zynq_pulp_spi_sdo2),
		.spi_sdo3(zynq_pulp_spi_sdo3),
		.axi_aclk(zynq_clk),
		.axi_aresetn(zynq_rst_n),
		.axi_master_aw_valid(zynq_axi_aw_valid_s),
		.axi_master_aw_addr(zynq_axi_aw_addr_int),
		.axi_master_aw_prot(zynq_axi_aw_prot_o),
		.axi_master_aw_region(zynq_axi_aw_region_o),
		.axi_master_aw_len(zynq_axi_aw_len_o),
		.axi_master_aw_size(zynq_axi_aw_size_o),
		.axi_master_aw_burst(zynq_axi_aw_burst_o),
		.axi_master_aw_lock(zynq_axi_aw_lock_o),
		.axi_master_aw_cache(zynq_axi_aw_cache_o),
		.axi_master_aw_qos(zynq_axi_aw_qos_o),
		.axi_master_aw_id(zynq_axi_aw_id_o),
		.axi_master_aw_user(zynq_axi_aw_user_o),
		.axi_master_aw_ready(zynq_axi_aw_ready_i),
		.axi_master_ar_valid(zynq_axi_ar_valid_s),
		.axi_master_ar_addr(zynq_axi_ar_addr_int),
		.axi_master_ar_prot(zynq_axi_ar_prot_o),
		.axi_master_ar_region(zynq_axi_ar_region_o),
		.axi_master_ar_len(zynq_axi_ar_len_o),
		.axi_master_ar_size(zynq_axi_ar_size_o),
		.axi_master_ar_burst(zynq_axi_ar_burst_o),
		.axi_master_ar_lock(zynq_axi_ar_lock_o),
		.axi_master_ar_cache(zynq_axi_ar_cache_o),
		.axi_master_ar_qos(zynq_axi_ar_qos_o),
		.axi_master_ar_id(zynq_axi_ar_id_o),
		.axi_master_ar_user(zynq_axi_ar_user_o),
		.axi_master_ar_ready(zynq_axi_ar_ready_i),
		.axi_master_w_valid(zynq_axi_w_valid_s),
		.axi_master_w_data(zynq_axi_w_data_int),
		.axi_master_w_strb(zynq_axi_w_strb_o),
		.axi_master_w_user(zynq_axi_w_user_o),
		.axi_master_w_last(zynq_axi_w_last_o),
		.axi_master_w_ready(zynq_axi_w_ready_i),
		.axi_master_r_valid(zynq_axi_r_valid_i),
		.axi_master_r_data(zynq_axi_r_data_int),
		.axi_master_r_resp(zynq_axi_r_resp_i),
		.axi_master_r_last(zynq_axi_r_last_i),
		.axi_master_r_id(zynq_axi_r_id_i),
		.axi_master_r_user(zynq_axi_r_user_i),
		.axi_master_r_ready(zynq_axi_r_ready_s),
		.axi_master_b_valid(zynq_axi_b_valid_i),
		.axi_master_b_resp(zynq_axi_b_resp_i),
		.axi_master_b_id(zynq_axi_b_id_i),
		.axi_master_b_user(zynq_axi_b_user_i),
		.axi_master_b_ready(zynq_axi_b_ready_s)
	);
	generate
		if (SWITCH_ENDIANNESS) begin : switch_endianness_gen
			assign zynq_axi_r_data_int = {zynq_axi_r_data_i[7:0], zynq_axi_r_data_i[15:8], zynq_axi_r_data_i[23:16], zynq_axi_r_data_i[31:24]};
			assign zynq_axi_w_data_o = {zynq_axi_w_data_int[7:0], zynq_axi_w_data_int[15:8], zynq_axi_w_data_int[23:16], zynq_axi_w_data_int[31:24]};
			assign zynq_axi_aw_addr_o = {zynq_axi_aw_addr_int[7:0], zynq_axi_aw_addr_int[15:8], zynq_axi_aw_addr_int[23:16], zynq_axi_aw_addr_int[31:24]};
			assign zynq_axi_ar_addr_o = {zynq_axi_ar_addr_int[7:0], zynq_axi_ar_addr_int[15:8], zynq_axi_ar_addr_int[23:16], zynq_axi_ar_addr_int[31:24]};
		end
		else begin : no_switch_endianness_gen
			assign zynq_axi_r_data_int = zynq_axi_r_data_i;
			assign zynq_axi_w_data_o = zynq_axi_w_data_int;
			assign zynq_axi_aw_addr_o = zynq_axi_aw_addr_int;
			assign zynq_axi_ar_addr_o = zynq_axi_ar_addr_int;
		end
	endgenerate
	assign zynq_axi_aw_valid_o = (mode_fmc_zynqn_i == 1'b0 ? zynq_axi_aw_valid_s : 1'b0);
	assign zynq_axi_ar_valid_o = (mode_fmc_zynqn_i == 1'b0 ? zynq_axi_ar_valid_s : 1'b0);
	assign zynq_axi_w_valid_o = (mode_fmc_zynqn_i == 1'b0 ? zynq_axi_w_valid_s : 1'b0);
	assign zynq_axi_b_ready_o = (mode_fmc_zynqn_i == 1'b0 ? zynq_axi_b_ready_s : 1'b0);
	assign zynq_axi_r_ready_o = (mode_fmc_zynqn_i == 1'b0 ? zynq_axi_r_ready_s : 1'b0);
	assign pulp_spi_sdi0_o = (mode_fmc_zynqn_i == 1'b0 ? zynq_pulp_spi_sdo0 : pads2pulp_spi_sdi0_i);
	assign pulp_spi_sdi1_o = (mode_fmc_zynqn_i == 1'b0 ? zynq_pulp_spi_sdo1 : pads2pulp_spi_sdi1_i);
	assign pulp_spi_sdi2_o = (mode_fmc_zynqn_i == 1'b0 ? zynq_pulp_spi_sdo2 : pads2pulp_spi_sdi2_i);
	assign pulp_spi_sdi3_o = (mode_fmc_zynqn_i == 1'b0 ? zynq_pulp_spi_sdo3 : pads2pulp_spi_sdi3_i);
	assign zynq_pulp_spi_clk = (mode_fmc_zynqn_i == 1'b0 ? pulp_spi_clk_i : 1'b0);
	assign zynq_pulp_spi_csn = (mode_fmc_zynqn_i == 1'b0 ? pulp_spi_csn_i : 1'b1);
	assign zynq_pulp_spi_sdi0 = (mode_fmc_zynqn_i == 1'b0 ? pulp_spi_sdo0_i : 1'b0);
	assign zynq_pulp_spi_sdi1 = (mode_fmc_zynqn_i == 1'b0 ? pulp_spi_sdo1_i : 1'b0);
	assign zynq_pulp_spi_sdi2 = (mode_fmc_zynqn_i == 1'b0 ? pulp_spi_sdo2_i : 1'b0);
	assign zynq_pulp_spi_sdi3 = (mode_fmc_zynqn_i == 1'b0 ? pulp_spi_sdo3_i : 1'b0);
	assign pads2pulp_spi_clk_o = (mode_fmc_zynqn_i == 1'b0 ? 1'b0 : pulp_spi_clk_i);
	assign pads2pulp_spi_csn_o = (mode_fmc_zynqn_i == 1'b0 ? 1'b1 : pulp_spi_csn_i);
	assign pads2pulp_spi_mode_o = (mode_fmc_zynqn_i == 1'b0 ? 'h0 : pulp_spi_mode_i);
	assign pads2pulp_spi_sdo0_o = (mode_fmc_zynqn_i == 1'b0 ? 1'b0 : pulp_spi_sdo0_i);
	assign pads2pulp_spi_sdo1_o = (mode_fmc_zynqn_i == 1'b0 ? 1'b0 : pulp_spi_sdo1_i);
	assign pads2pulp_spi_sdo2_o = (mode_fmc_zynqn_i == 1'b0 ? 1'b0 : pulp_spi_sdo2_i);
	assign pads2pulp_spi_sdo3_o = (mode_fmc_zynqn_i == 1'b0 ? 1'b0 : pulp_spi_sdo3_i);
endmodule
