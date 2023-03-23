module RequestBlock_L2_1CH (
	data_req_i,
	data_add_i,
	data_wen_i,
	data_wdata_i,
	data_be_i,
	data_ID_i,
	data_gnt_o,
	data_req_o,
	data_add_o,
	data_wen_o,
	data_wdata_o,
	data_be_o,
	data_ID_o,
	data_gnt_i,
	data_r_valid_i,
	data_r_ID_i,
	data_r_valid_o,
	clk,
	rst_n
);
	parameter ADDR_WIDTH = 32;
	parameter DATA_WIDTH = 64;
	parameter BE_WIDTH = DATA_WIDTH / 8;
	parameter N_CH0 = 16;
	parameter ID_WIDTH = N_CH0;
	input wire [N_CH0 - 1:0] data_req_i;
	input wire [(N_CH0 * ADDR_WIDTH) - 1:0] data_add_i;
	input wire [N_CH0 - 1:0] data_wen_i;
	input wire [(N_CH0 * DATA_WIDTH) - 1:0] data_wdata_i;
	input wire [(N_CH0 * BE_WIDTH) - 1:0] data_be_i;
	input wire [(N_CH0 * ID_WIDTH) - 1:0] data_ID_i;
	output wire [N_CH0 - 1:0] data_gnt_o;
	output wire data_req_o;
	output wire [ADDR_WIDTH - 1:0] data_add_o;
	output wire data_wen_o;
	output wire [DATA_WIDTH - 1:0] data_wdata_o;
	output wire [BE_WIDTH - 1:0] data_be_o;
	output wire [ID_WIDTH - 1:0] data_ID_o;
	input wire data_gnt_i;
	input wire data_r_valid_i;
	input wire [ID_WIDTH - 1:0] data_r_ID_i;
	output wire [N_CH0 - 1:0] data_r_valid_o;
	input wire clk;
	input wire rst_n;
	wire [(2 ** $clog2(N_CH0)) - 1:0] data_req_CH0_int;
	wire [((2 ** $clog2(N_CH0)) * ADDR_WIDTH) - 1:0] data_add_CH0_int;
	wire [(2 ** $clog2(N_CH0)) - 1:0] data_wen_CH0_int;
	wire [((2 ** $clog2(N_CH0)) * DATA_WIDTH) - 1:0] data_wdata_CH0_int;
	wire [((2 ** $clog2(N_CH0)) * BE_WIDTH) - 1:0] data_be_CH0_int;
	wire [((2 ** $clog2(N_CH0)) * ID_WIDTH) - 1:0] data_ID_CH0_int;
	wire [(2 ** $clog2(N_CH0)) - 1:0] data_gnt_CH0_int;
	generate
		if ((2 ** $clog2(N_CH0)) != N_CH0) begin : _DUMMY_CH0_PORTS_
			wire [((2 ** $clog2(N_CH0)) - N_CH0) - 1:0] data_req_CH0_dummy;
			wire [(((2 ** $clog2(N_CH0)) - N_CH0) * ADDR_WIDTH) - 1:0] data_add_CH0_dummy;
			wire [((2 ** $clog2(N_CH0)) - N_CH0) - 1:0] data_wen_CH0_dummy;
			wire [(((2 ** $clog2(N_CH0)) - N_CH0) * DATA_WIDTH) - 1:0] data_wdata_CH0_dummy;
			wire [(((2 ** $clog2(N_CH0)) - N_CH0) * BE_WIDTH) - 1:0] data_be_CH0_dummy;
			wire [(((2 ** $clog2(N_CH0)) - N_CH0) * ID_WIDTH) - 1:0] data_ID_CH0_dummy;
			wire [((2 ** $clog2(N_CH0)) - N_CH0) - 1:0] data_gnt_CH0_dummy;
			assign data_req_CH0_dummy = 1'sb0;
			assign data_add_CH0_dummy = 1'sb0;
			assign data_wen_CH0_dummy = 1'sb0;
			assign data_wdata_CH0_dummy = 1'sb0;
			assign data_be_CH0_dummy = 1'sb0;
			assign data_ID_CH0_dummy = 1'sb0;
			assign data_req_CH0_int = {data_req_CH0_dummy, data_req_i};
			assign data_add_CH0_int = {data_add_CH0_dummy, data_add_i};
			assign data_wen_CH0_int = {data_wen_CH0_dummy, data_wen_i};
			assign data_wdata_CH0_int = {data_wdata_CH0_dummy, data_wdata_i};
			assign data_be_CH0_int = {data_be_CH0_dummy, data_be_i};
			assign data_ID_CH0_int = {data_ID_CH0_dummy, data_ID_i};
			genvar j;
			for (j = 0; j < N_CH0; j = j + 1) begin : _MERGING_CH0_DUMMY_PORTS_OUT_
				assign data_gnt_o[j] = data_gnt_CH0_int[j];
			end
		end
		else begin : genblk1
			assign data_req_CH0_int = data_req_i;
			assign data_add_CH0_int = data_add_i;
			assign data_wen_CH0_int = data_wen_i;
			assign data_wdata_CH0_int = data_wdata_i;
			assign data_be_CH0_int = data_be_i;
			assign data_ID_CH0_int = data_ID_i;
			assign data_gnt_o = data_gnt_CH0_int;
		end
		if (N_CH0 > 1) begin : POLY_CH0
			ArbitrationTree_L2 #(
				.ADDR_WIDTH(ADDR_WIDTH),
				.ID_WIDTH(ID_WIDTH),
				.N_MASTER(N_CH0),
				.DATA_WIDTH(DATA_WIDTH),
				.BE_WIDTH(BE_WIDTH),
				.MAX_COUNT(N_CH0 - 1)
			) CH0_ARB_TREE(
				.clk(clk),
				.rst_n(rst_n),
				.data_req_i(data_req_CH0_int),
				.data_add_i(data_add_CH0_int),
				.data_wen_i(data_wen_CH0_int),
				.data_wdata_i(data_wdata_CH0_int),
				.data_be_i(data_be_CH0_int),
				.data_ID_i(data_ID_CH0_int),
				.data_gnt_o(data_gnt_CH0_int),
				.data_req_o(data_req_o),
				.data_add_o(data_add_o),
				.data_wen_o(data_wen_o),
				.data_wdata_o(data_wdata_o),
				.data_be_o(data_be_o),
				.data_ID_o(data_ID_o),
				.data_gnt_i(data_gnt_i)
			);
		end
		else begin : MONO_CH0
			assign data_req_o = data_req_CH0_int;
			assign data_add_o = data_add_CH0_int;
			assign data_wen_o = data_wen_CH0_int;
			assign data_wdata_o = data_wdata_CH0_int;
			assign data_be_o = data_be_CH0_int;
			assign data_ID_o = data_ID_CH0_int;
			assign data_gnt_CH0_int = data_gnt_i;
		end
	endgenerate
	AddressDecoder_Resp_L2 #(
		.ID_WIDTH(ID_WIDTH),
		.N_MASTER(N_CH0)
	) ADDR_DEC_RESP(
		.data_r_valid_i(data_r_valid_i),
		.data_r_ID_i(data_r_ID_i),
		.data_r_valid_o(data_r_valid_o)
	);
endmodule
