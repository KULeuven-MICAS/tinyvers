module dummy_fll (
	fll_cfg_clk,
	rstn_glob_i,
	fll_slave_req_i,
	fll_slave_wrn_i,
	fll_slave_add_i,
	fll_slave_data_i,
	fll_slave_ack_o,
	fll_slave_r_data_o,
	fll_slave_lock_o
);
	input wire fll_cfg_clk;
	input wire rstn_glob_i;
	input wire fll_slave_req_i;
	input wire fll_slave_wrn_i;
	input wire [1:0] fll_slave_add_i;
	input wire [31:0] fll_slave_data_i;
	output reg fll_slave_ack_o;
	output wire [31:0] fll_slave_r_data_o;
	output wire fll_slave_lock_o;
	always @(posedge fll_cfg_clk or negedge rstn_glob_i)
		if (~rstn_glob_i)
			fll_slave_ack_o = 1'sb0;
		else
			fll_slave_ack_o = fll_slave_req_i;
	assign fll_slave_r_data_o = 32'hdeadbeaf;
	assign fll_slave_lock_o = 1'b1;
endmodule
module soc_clk_rst_gen (
	ref_clk_i,
	clk_soc_ext_i,
	clk_per_ext_i,
	test_clk_i,
	rstn_glob_i,
	test_mode_i,
	sel_fll_clk_i,
	shift_enable_i,
	soc_fll_slave_req_i,
	soc_fll_slave_wrn_i,
	soc_fll_slave_add_i,
	soc_fll_slave_data_i,
	soc_fll_slave_ack_o,
	soc_fll_slave_r_data_o,
	soc_fll_slave_lock_o,
	per_fll_slave_req_i,
	per_fll_slave_wrn_i,
	per_fll_slave_add_i,
	per_fll_slave_data_i,
	per_fll_slave_ack_o,
	per_fll_slave_r_data_o,
	per_fll_slave_lock_o,
	cluster_fll_slave_req_i,
	cluster_fll_slave_wrn_i,
	cluster_fll_slave_add_i,
	cluster_fll_slave_data_i,
	cluster_fll_slave_ack_o,
	cluster_fll_slave_r_data_o,
	cluster_fll_slave_lock_o,
	rstn_soc_sync_o,
	rstn_cluster_sync_o,
	clk_soc_o,
	clk_per_o,
	clk_cluster_o
);
	input wire ref_clk_i;
	input wire clk_soc_ext_i;
	input wire clk_per_ext_i;
	input wire test_clk_i;
	input wire rstn_glob_i;
	input wire test_mode_i;
	input wire sel_fll_clk_i;
	input wire shift_enable_i;
	input wire soc_fll_slave_req_i;
	input wire soc_fll_slave_wrn_i;
	input wire [1:0] soc_fll_slave_add_i;
	input wire [31:0] soc_fll_slave_data_i;
	output wire soc_fll_slave_ack_o;
	output wire [31:0] soc_fll_slave_r_data_o;
	output wire soc_fll_slave_lock_o;
	input wire per_fll_slave_req_i;
	input wire per_fll_slave_wrn_i;
	input wire [1:0] per_fll_slave_add_i;
	input wire [31:0] per_fll_slave_data_i;
	output wire per_fll_slave_ack_o;
	output wire [31:0] per_fll_slave_r_data_o;
	output wire per_fll_slave_lock_o;
	input wire cluster_fll_slave_req_i;
	input wire cluster_fll_slave_wrn_i;
	input wire [1:0] cluster_fll_slave_add_i;
	input wire [31:0] cluster_fll_slave_data_i;
	output wire cluster_fll_slave_ack_o;
	output wire [31:0] cluster_fll_slave_r_data_o;
	output wire cluster_fll_slave_lock_o;
	output wire rstn_soc_sync_o;
	output wire rstn_cluster_sync_o;
	output wire clk_soc_o;
	output wire clk_per_o;
	output wire clk_cluster_o;
	wire s_clk_soc;
	wire s_clk_per;
	wire s_clk_cluster;
	wire s_clk_fll_soc;
	wire s_clk_fll_per;
	wire s_clk_fll_cluster;
	wire s_rstn_soc;
	wire s_rstn_soc_sync;
	wire s_rstn_cluster_sync;
	freq_meter #(
		.FLL_NAME("SOC_FLL"),
		.MAX_SAMPLE(4096)
	) SOC_METER(.clk(s_clk_fll_soc));
	freq_meter #(
		.FLL_NAME("PER_FLL"),
		.MAX_SAMPLE(4096)
	) PER_METER(.clk(s_clk_fll_per));
	freq_meter #(
		.FLL_NAME("CLUSTER_FLL"),
		.MAX_SAMPLE(4096)
	) CLUSTER_METER(.clk(s_clk_fll_cluster));
	dummy_fll i_fll_soc(
		.fll_cfg_clk(s_clk_soc),
		.rstn_glob_i(rstn_glob_i),
		.fll_slave_req_i(soc_fll_slave_req_i),
		.fll_slave_wrn_i(soc_fll_slave_wrn_i),
		.fll_slave_add_i(soc_fll_slave_add_i),
		.fll_slave_data_i(soc_fll_slave_data_i),
		.fll_slave_ack_o(soc_fll_slave_ack_o),
		.fll_slave_r_data_o(soc_fll_slave_r_data_o),
		.fll_slave_lock_o(soc_fll_slave_lock_o)
	);
	assign s_clk_fll_soc = clk_soc_ext_i;
	dummy_fll i_fll_per(
		.fll_cfg_clk(s_clk_soc),
		.rstn_glob_i(rstn_glob_i),
		.fll_slave_req_i(per_fll_slave_req_i),
		.fll_slave_wrn_i(per_fll_slave_wrn_i),
		.fll_slave_add_i(per_fll_slave_add_i),
		.fll_slave_data_i(per_fll_slave_data_i),
		.fll_slave_ack_o(per_fll_slave_ack_o),
		.fll_slave_r_data_o(per_fll_slave_r_data_o),
		.fll_slave_lock_o(per_fll_slave_lock_o)
	);
	assign s_clk_fll_per = clk_per_ext_i;
	dummy_fll i_fll_cluster(
		.fll_cfg_clk(s_clk_soc),
		.rstn_glob_i(rstn_glob_i),
		.fll_slave_req_i(cluster_fll_slave_req_i),
		.fll_slave_wrn_i(cluster_fll_slave_wrn_i),
		.fll_slave_add_i(cluster_fll_slave_add_i),
		.fll_slave_data_i(cluster_fll_slave_data_i),
		.fll_slave_ack_o(cluster_fll_slave_ack_o),
		.fll_slave_r_data_o(cluster_fll_slave_r_data_o),
		.fll_slave_lock_o(cluster_fll_slave_lock_o)
	);
	assign s_clk_fll_cluster = s_clk_fll_soc;
	assign s_clk_soc = s_clk_fll_soc;
	assign s_clk_cluster = s_clk_fll_cluster;
	assign s_clk_per = s_clk_fll_per;
	assign s_rstn_soc = rstn_glob_i;
	rstgen i_soc_rstgen(
		.clk_i(clk_soc_o),
		.rst_ni(s_rstn_soc),
		.test_mode_i(test_mode_i),
		.rst_no(s_rstn_soc_sync),
		.init_no()
	);
	rstgen i_cluster_rstgen(
		.clk_i(clk_cluster_o),
		.rst_ni(s_rstn_soc),
		.test_mode_i(test_mode_i),
		.rst_no(s_rstn_cluster_sync),
		.init_no()
	);
	assign clk_soc_o = s_clk_soc;
	assign clk_per_o = s_clk_per;
	assign clk_cluster_o = s_clk_cluster;
	assign rstn_soc_sync_o = s_rstn_soc_sync;
	assign rstn_cluster_sync_o = s_rstn_cluster_sync;
endmodule
