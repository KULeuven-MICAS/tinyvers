module cpu_wrapper (
	clk,
	reset,
	enable,
	wr_addr_ext,
	wr_data_ext,
	wr_output_data,
	ctrl_i,
	flags_o,
	scan_en_in
);
	input wire clk;
	input wire reset;
	input wire enable;
	input hwpe_stream_intf_stream.sink wr_addr_ext;
	input hwpe_stream_intf_stream.sink wr_data_ext;
	input hwpe_stream_intf_stream.source wr_output_data;
	localparam [31:0] mac_package_MAC_CNT_LEN = 1024;
	input wire [25:0] ctrl_i;
	output wire [75:0] flags_o;
	input wire scan_en_in;
	wire acc_clk_o;
	reg wr_en_ext_lut_s;
	reg wr_en_ext_conf_reg_s;
	reg wr_en_ext_im_s;
	reg wr_en_ext_sparsity_s;
	reg wr_en_ext_act_mem_s;
	reg wr_en_ext_fc_w_s;
	reg wr_en_ext_cnn_w_s;
	reg [31:0] wr_addr_ext_lut_s;
	reg signed [31:0] wr_data_ext_lut_s;
	reg [31:0] wr_addr_ext_conf_reg_s;
	reg signed [31:0] wr_data_ext_conf_reg_s;
	reg [31:0] wr_addr_ext_im_s;
	reg signed [31:0] wr_data_ext_im_s;
	reg [31:0] wr_addr_ext_sparsity_s;
	reg signed [31:0] wr_data_ext_sparsity_s;
	reg [31:0] wr_addr_ext_act_mem_s;
	localparam integer parameters_ACT_DATA_WIDTH = 8;
	reg signed [(4 * parameters_ACT_DATA_WIDTH) - 1:0] wr_data_ext_act_mem_s;
	reg [31:0] wr_addr_ext_fc_w_s;
	localparam integer parameters_WEIGHT_DATA_WIDTH = 8;
	reg signed [(4 * parameters_WEIGHT_DATA_WIDTH) - 1:0] wr_data_ext_fc_w_s;
	reg [31:0] wr_addr_ext_cnn_w_s;
	reg signed [(4 * parameters_WEIGHT_DATA_WIDTH) - 1:0] wr_data_ext_cnn_w_s;
	wire rd_en_ext_act_mem_s;
	wire [31:0] rd_addr_ext_act_mem_s;
	localparam integer parameters_N_DIM_ARRAY = 8;
	wire signed [(parameters_N_DIM_ARRAY * parameters_ACT_DATA_WIDTH) - 1:0] rd_data_ext_act_mem_s;
	wire [31:0] wr_output_addr_s;
	wire signed [(parameters_N_DIM_ARRAY * parameters_ACT_DATA_WIDTH) - 1:0] wr_output_data_s;
	wire wr_output_enable_s;
	wire finished_network_s;
	wire [15:0] OUTPUT_TILE_SIZE_s;
	wire [15:0] WEIGHT_TILE_SIZE_s;
	wire [7:0] NB_INPUT_TILE_s;
	wire [7:0] NB_WEIGHT_TILE_s;
	wire [15:0] CONF_K_s;
	wire [2:0] MODE_s;
	wire SPARSITY_s;
	wire done_layer_s;
	localparam [31:0] mac_package_PANDA_FSM_SEL_ACTIVATION_MEMORY = 4;
	localparam [31:0] mac_package_PANDA_FSM_SEL_CONFIG_MEMORY = 0;
	localparam [31:0] mac_package_PANDA_FSM_SEL_INSTRUCTION_MEMORY = 1;
	localparam [31:0] mac_package_PANDA_FSM_SEL_LUT_MEMORY = 2;
	localparam [31:0] mac_package_PANDA_FSM_SEL_SPARSITY_MEMORY = 3;
	localparam [31:0] mac_package_PANDA_FSM_SEL_WEIGHT_CONV_MEMORY = 5;
	localparam [31:0] mac_package_PANDA_FSM_SEL_WEIGHT_FC_MEMORY = 6;
	function automatic signed [parameters_ACT_DATA_WIDTH - 1:0] sv2v_cast_9FD46_signed;
		input reg signed [parameters_ACT_DATA_WIDTH - 1:0] inp;
		sv2v_cast_9FD46_signed = inp;
	endfunction
	function automatic signed [parameters_WEIGHT_DATA_WIDTH - 1:0] sv2v_cast_D6CB9_signed;
		input reg signed [parameters_WEIGHT_DATA_WIDTH - 1:0] inp;
		sv2v_cast_D6CB9_signed = inp;
	endfunction
	always @(*) begin
		wr_en_ext_lut_s = 1'b0;
		wr_en_ext_conf_reg_s = 1'b0;
		wr_en_ext_im_s = 1'b0;
		wr_en_ext_sparsity_s = 1'b0;
		wr_en_ext_act_mem_s = 1'b0;
		wr_en_ext_fc_w_s = 1'b0;
		wr_en_ext_cnn_w_s = 1'b0;
		wr_addr_ext_lut_s = 1'sb0;
		wr_data_ext_lut_s = 1'sb0;
		wr_addr_ext_conf_reg_s = 1'sb0;
		wr_data_ext_conf_reg_s = 1'sb0;
		wr_addr_ext_im_s = 1'sb0;
		wr_data_ext_im_s = 1'sb0;
		wr_addr_ext_sparsity_s = 1'sb0;
		wr_data_ext_sparsity_s = 1'sb0;
		wr_addr_ext_act_mem_s = 1'sb0;
		wr_data_ext_act_mem_s = {sv2v_cast_9FD46_signed(1'sb0), sv2v_cast_9FD46_signed(1'sb0), sv2v_cast_9FD46_signed(1'sb0), sv2v_cast_9FD46_signed(1'sb0)};
		wr_addr_ext_fc_w_s = 1'sb0;
		wr_data_ext_fc_w_s = {sv2v_cast_D6CB9_signed(1'sb0), sv2v_cast_D6CB9_signed(1'sb0), sv2v_cast_D6CB9_signed(1'sb0), sv2v_cast_D6CB9_signed(1'sb0)};
		wr_addr_ext_cnn_w_s = 1'sb0;
		wr_data_ext_cnn_w_s = {sv2v_cast_D6CB9_signed(1'sb0), sv2v_cast_D6CB9_signed(1'sb0), sv2v_cast_D6CB9_signed(1'sb0), sv2v_cast_D6CB9_signed(1'sb0)};
		case (ctrl_i[4-:3])
			mac_package_PANDA_FSM_SEL_CONFIG_MEMORY: begin
				wr_en_ext_conf_reg_s = ctrl_i[1];
				wr_addr_ext_conf_reg_s = wr_addr_ext.data;
				wr_data_ext_conf_reg_s = wr_data_ext.data;
			end
			mac_package_PANDA_FSM_SEL_INSTRUCTION_MEMORY: begin
				wr_en_ext_im_s = ctrl_i[1];
				wr_addr_ext_im_s = wr_addr_ext.data;
				wr_data_ext_im_s = wr_data_ext.data;
			end
			mac_package_PANDA_FSM_SEL_LUT_MEMORY: begin
				wr_en_ext_lut_s = ctrl_i[1];
				wr_addr_ext_lut_s = wr_addr_ext.data;
				wr_data_ext_lut_s = wr_data_ext.data;
			end
			mac_package_PANDA_FSM_SEL_SPARSITY_MEMORY: begin
				wr_en_ext_sparsity_s = ctrl_i[1];
				wr_addr_ext_sparsity_s = wr_addr_ext.data;
				wr_data_ext_sparsity_s = wr_data_ext.data;
			end
			mac_package_PANDA_FSM_SEL_ACTIVATION_MEMORY: begin
				wr_en_ext_act_mem_s = ctrl_i[1];
				wr_addr_ext_act_mem_s = wr_addr_ext.data;
				wr_data_ext_act_mem_s[3 * parameters_ACT_DATA_WIDTH+:parameters_ACT_DATA_WIDTH] = wr_data_ext.data[7:0];
				wr_data_ext_act_mem_s[2 * parameters_ACT_DATA_WIDTH+:parameters_ACT_DATA_WIDTH] = wr_data_ext.data[15:8];
				wr_data_ext_act_mem_s[parameters_ACT_DATA_WIDTH+:parameters_ACT_DATA_WIDTH] = wr_data_ext.data[23:16];
				wr_data_ext_act_mem_s[0+:parameters_ACT_DATA_WIDTH] = wr_data_ext.data[31:24];
			end
			mac_package_PANDA_FSM_SEL_WEIGHT_FC_MEMORY: begin
				wr_en_ext_fc_w_s = ctrl_i[1];
				wr_addr_ext_fc_w_s = wr_addr_ext.data;
				wr_data_ext_fc_w_s[3 * parameters_WEIGHT_DATA_WIDTH+:parameters_WEIGHT_DATA_WIDTH] = wr_data_ext.data[7:0];
				wr_data_ext_fc_w_s[2 * parameters_WEIGHT_DATA_WIDTH+:parameters_WEIGHT_DATA_WIDTH] = wr_data_ext.data[15:8];
				wr_data_ext_fc_w_s[parameters_WEIGHT_DATA_WIDTH+:parameters_WEIGHT_DATA_WIDTH] = wr_data_ext.data[23:16];
				wr_data_ext_fc_w_s[0+:parameters_WEIGHT_DATA_WIDTH] = wr_data_ext.data[31:24];
			end
			mac_package_PANDA_FSM_SEL_WEIGHT_CONV_MEMORY: begin
				wr_en_ext_cnn_w_s = ctrl_i[1];
				wr_addr_ext_cnn_w_s = wr_addr_ext.data;
				wr_data_ext_cnn_w_s[3 * parameters_WEIGHT_DATA_WIDTH+:parameters_WEIGHT_DATA_WIDTH] = wr_data_ext.data[7:0];
				wr_data_ext_cnn_w_s[2 * parameters_WEIGHT_DATA_WIDTH+:parameters_WEIGHT_DATA_WIDTH] = wr_data_ext.data[15:8];
				wr_data_ext_cnn_w_s[parameters_WEIGHT_DATA_WIDTH+:parameters_WEIGHT_DATA_WIDTH] = wr_data_ext.data[23:16];
				wr_data_ext_cnn_w_s[0+:parameters_WEIGHT_DATA_WIDTH] = wr_data_ext.data[31:24];
			end
			default:
				;
		endcase
	end
	pulp_clock_gating i_clk_gate_acc(
		.clk_i(clk),
		.en_i(ctrl_i[23]),
		.test_en_i(scan_en_in),
		.clk_o(acc_clk_o)
	);
	cpu i_cpu(
		.clk(acc_clk_o),
		.reset(reset),
		.enable(ctrl_i[21]),
		.scan_en_in(scan_en_in),
		.wr_en_ext_lut(wr_en_ext_lut_s),
		.wr_addr_ext_lut(wr_addr_ext_lut_s),
		.wr_data_ext_lut(wr_data_ext_lut_s),
		.wr_en_ext_conf_reg(wr_en_ext_conf_reg_s),
		.wr_addr_ext_conf_reg(wr_addr_ext_conf_reg_s),
		.wr_data_ext_conf_reg(wr_data_ext_conf_reg_s),
		.wr_en_ext_im(wr_en_ext_im_s),
		.wr_addr_ext_im(wr_addr_ext_im_s),
		.wr_data_ext_im(wr_data_ext_im_s),
		.wr_en_ext_sparsity(wr_en_ext_sparsity_s),
		.wr_addr_ext_sparsity(wr_addr_ext_sparsity_s),
		.wr_data_ext_sparsity(wr_data_ext_sparsity_s),
		.wr_en_ext_act_mem(wr_en_ext_act_mem_s),
		.wr_addr_ext_act_mem(wr_addr_ext_act_mem_s),
		.wr_data_ext_act_mem(wr_data_ext_act_mem_s),
		.wr_en_ext_fc_w(wr_en_ext_fc_w_s),
		.wr_addr_ext_fc_w(wr_addr_ext_fc_w_s),
		.wr_data_ext_fc_w(wr_data_ext_fc_w_s),
		.wr_en_ext_cnn_w(wr_en_ext_cnn_w_s),
		.wr_addr_ext_cnn_w(wr_addr_ext_cnn_w_s),
		.wr_data_ext_cnn_w(wr_data_ext_cnn_w_s),
		.rd_en_ext_act_mem(rd_en_ext_act_mem_s),
		.rd_addr_ext_act_mem(rd_addr_ext_act_mem_s),
		.rd_data_ext_act_mem(rd_data_ext_act_mem_s),
		.OUTPUT_TILE_SIZE(OUTPUT_TILE_SIZE_s),
		.WEIGHT_TILE_SIZE(WEIGHT_TILE_SIZE_s),
		.NB_INPUT_TILE(NB_INPUT_TILE_s),
		.NB_WEIGHT_TILE(NB_WEIGHT_TILE_s),
		.MODE(MODE_s),
		.SPARSITY(SPARSITY_s),
		.CONF_K_o(CONF_K_s),
		.done_layer(done_layer_s),
		.finished_network(finished_network_s),
		.wr_output_enable(wr_output_enable_s),
		.wr_output_addr(wr_output_addr_s),
		.wr_output_data(wr_output_data_s)
	);
	always @(*) begin
		wr_output_data.data = {wr_output_data_s[4 * parameters_ACT_DATA_WIDTH+:parameters_ACT_DATA_WIDTH], wr_output_data_s[5 * parameters_ACT_DATA_WIDTH+:parameters_ACT_DATA_WIDTH], wr_output_data_s[6 * parameters_ACT_DATA_WIDTH+:parameters_ACT_DATA_WIDTH], wr_output_data_s[7 * parameters_ACT_DATA_WIDTH+:parameters_ACT_DATA_WIDTH], wr_output_data_s[0+:parameters_ACT_DATA_WIDTH], wr_output_data_s[parameters_ACT_DATA_WIDTH+:parameters_ACT_DATA_WIDTH], wr_output_data_s[2 * parameters_ACT_DATA_WIDTH+:parameters_ACT_DATA_WIDTH], wr_output_data_s[3 * parameters_ACT_DATA_WIDTH+:parameters_ACT_DATA_WIDTH]};
		wr_output_data.valid = wr_output_enable_s;
		wr_output_data.strb = 1'sb1;
	end
	assign flags_o[64] = finished_network_s;
	assign flags_o[63-:16] = OUTPUT_TILE_SIZE_s;
	assign flags_o[47-:16] = WEIGHT_TILE_SIZE_s;
	assign flags_o[31-:8] = NB_INPUT_TILE_s;
	assign flags_o[23-:8] = NB_WEIGHT_TILE_s;
	assign flags_o[15-:3] = MODE_s;
	assign flags_o[12-:8] = CONF_K_s;
	assign flags_o[4] = SPARSITY_s;
	assign flags_o[3] = done_layer_s;
	assign flags_o[2] = wr_addr_ext.valid;
	assign flags_o[1] = wr_data_ext.valid;
	assign flags_o[0] = wr_output_enable_s;
	assign wr_addr_ext.ready = ctrl_i[0];
	assign wr_data_ext.ready = ctrl_i[0];
endmodule
