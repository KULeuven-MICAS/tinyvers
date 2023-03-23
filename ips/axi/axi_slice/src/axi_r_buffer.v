module axi_r_buffer (
	clk_i,
	rst_ni,
	test_en_i,
	slave_valid_i,
	slave_data_i,
	slave_resp_i,
	slave_user_i,
	slave_id_i,
	slave_last_i,
	slave_ready_o,
	master_valid_o,
	master_data_o,
	master_resp_o,
	master_user_o,
	master_id_o,
	master_last_o,
	master_ready_i
);
	parameter ID_WIDTH = 4;
	parameter DATA_WIDTH = 64;
	parameter USER_WIDTH = 6;
	parameter BUFFER_DEPTH = 8;
	parameter STRB_WIDTH = DATA_WIDTH / 8;
	input wire clk_i;
	input wire rst_ni;
	input wire test_en_i;
	input wire slave_valid_i;
	input wire [DATA_WIDTH - 1:0] slave_data_i;
	input wire [1:0] slave_resp_i;
	input wire [USER_WIDTH - 1:0] slave_user_i;
	input wire [ID_WIDTH - 1:0] slave_id_i;
	input wire slave_last_i;
	output wire slave_ready_o;
	output wire master_valid_o;
	output wire [DATA_WIDTH - 1:0] master_data_o;
	output wire [1:0] master_resp_o;
	output wire [USER_WIDTH - 1:0] master_user_o;
	output wire [ID_WIDTH - 1:0] master_id_o;
	output wire master_last_o;
	input wire master_ready_i;
	wire [((2 + DATA_WIDTH) + USER_WIDTH) + ID_WIDTH:0] s_data_in;
	wire [((2 + DATA_WIDTH) + USER_WIDTH) + ID_WIDTH:0] s_data_out;
	assign s_data_in = {slave_id_i, slave_user_i, slave_data_i, slave_resp_i, slave_last_i};
	assign {master_id_o, master_user_o, master_data_o, master_resp_o, master_last_o} = s_data_out;
	axi_single_slice #(
		.BUFFER_DEPTH(BUFFER_DEPTH),
		.DATA_WIDTH(((3 + DATA_WIDTH) + USER_WIDTH) + ID_WIDTH)
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
