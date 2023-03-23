module axi_w_buffer (
	clk_i,
	rst_ni,
	test_en_i,
	slave_valid_i,
	slave_data_i,
	slave_strb_i,
	slave_user_i,
	slave_last_i,
	slave_ready_o,
	master_valid_o,
	master_data_o,
	master_strb_o,
	master_user_o,
	master_last_o,
	master_ready_i
);
	parameter signed [31:0] DATA_WIDTH = -1;
	parameter signed [31:0] USER_WIDTH = -1;
	parameter signed [31:0] BUFFER_DEPTH = -1;
	parameter signed [31:0] STRB_WIDTH = DATA_WIDTH / 8;
	input wire clk_i;
	input wire rst_ni;
	input wire test_en_i;
	input wire slave_valid_i;
	input wire [DATA_WIDTH - 1:0] slave_data_i;
	input wire [STRB_WIDTH - 1:0] slave_strb_i;
	input wire [USER_WIDTH - 1:0] slave_user_i;
	input wire slave_last_i;
	output wire slave_ready_o;
	output wire master_valid_o;
	output wire [DATA_WIDTH - 1:0] master_data_o;
	output wire [STRB_WIDTH - 1:0] master_strb_o;
	output wire [USER_WIDTH - 1:0] master_user_o;
	output wire master_last_o;
	input wire master_ready_i;
	wire [(DATA_WIDTH + STRB_WIDTH) + USER_WIDTH:0] s_data_in;
	wire [(DATA_WIDTH + STRB_WIDTH) + USER_WIDTH:0] s_data_out;
	assign s_data_in = {slave_user_i, slave_strb_i, slave_data_i, slave_last_i};
	assign {master_user_o, master_strb_o, master_data_o, master_last_o} = s_data_out;
	axi_single_slice #(
		.BUFFER_DEPTH(BUFFER_DEPTH),
		.DATA_WIDTH(((1 + DATA_WIDTH) + STRB_WIDTH) + USER_WIDTH)
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
