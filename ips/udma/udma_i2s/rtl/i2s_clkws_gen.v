module i2s_clkws_gen (
	clk_i,
	rstn_i,
	dft_test_mode_i,
	dft_cg_enable_i,
	pad_slave_sck_i,
	pad_slave_sck_o,
	pad_slave_sck_oe,
	pad_slave_ws_i,
	pad_slave_ws_o,
	pad_slave_ws_oe,
	pad_master_sck_i,
	pad_master_sck_o,
	pad_master_sck_oe,
	pad_master_ws_i,
	pad_master_ws_o,
	pad_master_ws_oe,
	master_en_i,
	slave_en_i,
	pdm_en_i,
	pdm_clk_i,
	cfg_div_0_i,
	cfg_div_1_i,
	cfg_word_size_0_i,
	cfg_word_num_0_i,
	cfg_word_size_1_i,
	cfg_word_num_1_i,
	sel_master_num_i,
	sel_master_ext_i,
	sel_slave_num_i,
	sel_slave_ext_i,
	clk_master_o,
	clk_slave_o,
	ws_master_o,
	ws_slave_o
);
	input wire clk_i;
	input wire rstn_i;
	input wire dft_test_mode_i;
	input wire dft_cg_enable_i;
	input wire pad_slave_sck_i;
	output wire pad_slave_sck_o;
	output wire pad_slave_sck_oe;
	input wire pad_slave_ws_i;
	output wire pad_slave_ws_o;
	output wire pad_slave_ws_oe;
	input wire pad_master_sck_i;
	output wire pad_master_sck_o;
	output wire pad_master_sck_oe;
	input wire pad_master_ws_i;
	output wire pad_master_ws_o;
	output wire pad_master_ws_oe;
	input wire master_en_i;
	input wire slave_en_i;
	input wire pdm_en_i;
	input wire pdm_clk_i;
	input wire [15:0] cfg_div_0_i;
	input wire [15:0] cfg_div_1_i;
	input wire [4:0] cfg_word_size_0_i;
	input wire [2:0] cfg_word_num_0_i;
	input wire [4:0] cfg_word_size_1_i;
	input wire [2:0] cfg_word_num_1_i;
	input wire sel_master_num_i;
	input wire sel_master_ext_i;
	input wire sel_slave_num_i;
	input wire sel_slave_ext_i;
	output wire clk_master_o;
	output wire clk_slave_o;
	output wire ws_master_o;
	output wire ws_slave_o;
	wire s_clk_gen_0;
	wire s_clk_gen_1;
	wire s_clk_gen_0_en;
	wire s_clk_gen_1_en;
	wire s_clk_int_master;
	wire s_clk_int_slave;
	wire s_clk_ext_master;
	wire s_clk_ext_slave;
	wire s_clk_master;
	wire s_clk_slave;
	wire s_ws_int_master;
	wire s_ws_int_slave;
	wire s_ws_ext_master;
	wire s_ws_ext_slave;
	wire s_ws_master;
	wire s_ws_slave;
	assign pad_slave_sck_oe = ~sel_slave_ext_i;
	assign pad_slave_ws_oe = ~sel_slave_ext_i;
	assign pad_slave_ws_o = s_ws_slave;
	assign pad_master_sck_oe = ~sel_master_ext_i;
	assign pad_master_sck_o = s_clk_master;
	assign pad_master_ws_oe = ~sel_master_ext_i;
	assign pad_master_ws_o = s_ws_master;
	assign s_clk_gen_0_en = (master_en_i | slave_en_i) & ((~sel_master_num_i & ~sel_master_ext_i) | (~sel_slave_num_i & ~sel_slave_ext_i));
	assign s_clk_gen_1_en = (master_en_i | slave_en_i) & ((sel_master_num_i & ~sel_master_ext_i) | (sel_slave_num_i & ~sel_slave_ext_i));
	i2s_clk_gen i_clkgen0(
		.clk_i(clk_i),
		.rstn_i(rstn_i),
		.test_mode_i(dft_test_mode_i),
		.sck_o(s_clk_gen_0),
		.cfg_clk_en_i(s_clk_gen_0_en),
		.cfg_div_i(cfg_div_0_i)
	);
	i2s_clk_gen i_clkgen1(
		.clk_i(clk_i),
		.rstn_i(rstn_i),
		.test_mode_i(dft_test_mode_i),
		.sck_o(s_clk_gen_1),
		.cfg_clk_en_i(s_clk_gen_1_en),
		.cfg_div_i(cfg_div_1_i)
	);
	pulp_clock_mux2 i_clk_slave_out(
		.clk0_i(s_clk_slave),
		.clk1_i(pdm_clk_i),
		.clk_sel_i(pdm_en_i),
		.clk_o(pad_slave_sck_o)
	);
	pulp_clock_mux2 i_clock_int_master(
		.clk0_i(s_clk_gen_0),
		.clk1_i(s_clk_gen_1),
		.clk_sel_i(sel_master_num_i),
		.clk_o(s_clk_int_master)
	);
	pulp_clock_mux2 i_clock_int_slave(
		.clk0_i(s_clk_gen_0),
		.clk1_i(s_clk_gen_1),
		.clk_sel_i(sel_slave_num_i),
		.clk_o(s_clk_int_slave)
	);
	pulp_clock_mux2 i_clock_ext_master(
		.clk0_i(pad_master_sck_i),
		.clk1_i(pad_slave_sck_i),
		.clk_sel_i(sel_master_num_i),
		.clk_o(s_clk_ext_master)
	);
	pulp_clock_mux2 i_clock_ext_slave(
		.clk0_i(pad_master_sck_i),
		.clk1_i(pad_slave_sck_i),
		.clk_sel_i(sel_slave_num_i),
		.clk_o(s_clk_ext_slave)
	);
	pulp_clock_mux2 i_clock_master(
		.clk0_i(s_clk_int_master),
		.clk1_i(s_clk_ext_master),
		.clk_sel_i(sel_master_ext_i),
		.clk_o(s_clk_master)
	);
	pulp_clock_mux2 i_clock_slave(
		.clk0_i(s_clk_int_slave),
		.clk1_i(s_clk_ext_slave),
		.clk_sel_i(sel_slave_ext_i),
		.clk_o(s_clk_slave)
	);
	pulp_clock_gating i_master_cg(
		.clk_i(s_clk_master),
		.en_i(master_en_i),
		.test_en_i(dft_cg_enable_i),
		.clk_o(clk_master_o)
	);
	pulp_clock_gating i_slave_cg(
		.clk_i(s_clk_slave),
		.en_i(slave_en_i),
		.test_en_i(dft_cg_enable_i),
		.clk_o(clk_slave_o)
	);
	wire s_ws_gen_0_en;
	pulp_sync #(2) i_master_en_sync(
		.clk_i(s_clk_master),
		.rstn_i(rstn_i),
		.serial_i(master_en_i),
		.serial_o(s_ws_gen_0_en)
	);
	wire s_ws_gen_1_en;
	pulp_sync #(2) i_slave_en_sync(
		.clk_i(s_clk_slave),
		.rstn_i(rstn_i),
		.serial_i(slave_en_i),
		.serial_o(s_ws_gen_1_en)
	);
	wire s_ws_int_0;
	i2s_ws_gen i_ws_gen_0(
		.sck_i(s_clk_master),
		.rstn_i(rstn_i),
		.cfg_ws_en_i(s_ws_gen_0_en),
		.ws_o(s_ws_int_0),
		.cfg_data_size_i(cfg_word_size_0_i),
		.cfg_word_num_i(cfg_word_num_0_i)
	);
	wire s_ws_int_1;
	i2s_ws_gen i_ws_gen_1(
		.sck_i(s_clk_slave),
		.rstn_i(rstn_i),
		.cfg_ws_en_i(s_ws_gen_1_en),
		.ws_o(s_ws_int_1),
		.cfg_data_size_i(cfg_word_size_1_i),
		.cfg_word_num_i(cfg_word_num_1_i)
	);
	assign s_ws_int_master = (sel_master_num_i ? s_ws_int_1 : s_ws_int_0);
	assign s_ws_int_slave = (sel_slave_num_i ? s_ws_int_1 : s_ws_int_0);
	assign s_ws_ext_master = (sel_master_num_i ? pad_slave_ws_i : pad_master_ws_i);
	assign s_ws_ext_slave = (sel_slave_num_i ? pad_slave_ws_i : pad_master_ws_i);
	assign s_ws_master = (sel_master_ext_i ? s_ws_ext_master : s_ws_int_master);
	assign s_ws_slave = (sel_slave_ext_i ? s_ws_ext_slave : s_ws_int_slave);
	assign ws_master_o = s_ws_master;
	assign ws_slave_o = s_ws_slave;
endmodule
