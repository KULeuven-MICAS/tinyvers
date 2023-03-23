module RequestBlock_L2_2CH (
	data_req_CH0_i,
	data_add_CH0_i,
	data_wen_CH0_i,
	data_wdata_CH0_i,
	data_be_CH0_i,
	data_ID_CH0_i,
	data_gnt_CH0_o,
	data_req_CH1_i,
	data_add_CH1_i,
	data_wen_CH1_i,
	data_wdata_CH1_i,
	data_be_CH1_i,
	data_ID_CH1_i,
	data_gnt_CH1_o,
	data_req_o,
	data_add_o,
	data_wen_o,
	data_wdata_o,
	data_be_o,
	data_ID_o,
	data_gnt_i,
	data_r_valid_i,
	data_r_ID_i,
	data_r_valid_CH0_o,
	data_r_valid_CH1_o,
	clk,
	rst_n
);
	parameter ADDR_WIDTH = 32;
	parameter DATA_WIDTH = 64;
	parameter BE_WIDTH = DATA_WIDTH / 8;
	parameter N_CH0 = 5;
	parameter N_CH1 = 4;
	parameter ID_WIDTH = N_CH0 + N_CH1;
	input wire [N_CH0 - 1:0] data_req_CH0_i;
	input wire [(N_CH0 * ADDR_WIDTH) - 1:0] data_add_CH0_i;
	input wire [N_CH0 - 1:0] data_wen_CH0_i;
	input wire [(N_CH0 * DATA_WIDTH) - 1:0] data_wdata_CH0_i;
	input wire [(N_CH0 * BE_WIDTH) - 1:0] data_be_CH0_i;
	input wire [(N_CH0 * ID_WIDTH) - 1:0] data_ID_CH0_i;
	output wire [N_CH0 - 1:0] data_gnt_CH0_o;
	input wire [N_CH1 - 1:0] data_req_CH1_i;
	input wire [(N_CH1 * ADDR_WIDTH) - 1:0] data_add_CH1_i;
	input wire [N_CH1 - 1:0] data_wen_CH1_i;
	input wire [(N_CH1 * DATA_WIDTH) - 1:0] data_wdata_CH1_i;
	input wire [(N_CH1 * BE_WIDTH) - 1:0] data_be_CH1_i;
	input wire [(N_CH1 * ID_WIDTH) - 1:0] data_ID_CH1_i;
	output wire [N_CH1 - 1:0] data_gnt_CH1_o;
	output wire data_req_o;
	output wire [ADDR_WIDTH - 1:0] data_add_o;
	output wire data_wen_o;
	output wire [DATA_WIDTH - 1:0] data_wdata_o;
	output wire [BE_WIDTH - 1:0] data_be_o;
	output wire [ID_WIDTH - 1:0] data_ID_o;
	input wire data_gnt_i;
	input wire data_r_valid_i;
	input wire [ID_WIDTH - 1:0] data_r_ID_i;
	output wire [N_CH0 - 1:0] data_r_valid_CH0_o;
	output wire [N_CH1 - 1:0] data_r_valid_CH1_o;
	input wire clk;
	input wire rst_n;
	wire data_req_CH0;
	wire [ADDR_WIDTH - 1:0] data_add_CH0;
	wire data_wen_CH0;
	wire [DATA_WIDTH - 1:0] data_wdata_CH0;
	wire [BE_WIDTH - 1:0] data_be_CH0;
	wire [ID_WIDTH - 1:0] data_ID_CH0;
	wire data_gnt_CH0;
	wire data_req_CH1;
	wire [ADDR_WIDTH - 1:0] data_add_CH1;
	wire data_wen_CH1;
	wire [DATA_WIDTH - 1:0] data_wdata_CH1;
	wire [BE_WIDTH - 1:0] data_be_CH1;
	wire [ID_WIDTH - 1:0] data_ID_CH1;
	wire data_gnt_CH1;
	wire [(2 ** $clog2(N_CH0)) - 1:0] data_req_CH0_int;
	wire [((2 ** $clog2(N_CH0)) * ADDR_WIDTH) - 1:0] data_add_CH0_int;
	wire [(2 ** $clog2(N_CH0)) - 1:0] data_wen_CH0_int;
	wire [((2 ** $clog2(N_CH0)) * DATA_WIDTH) - 1:0] data_wdata_CH0_int;
	wire [((2 ** $clog2(N_CH0)) * BE_WIDTH) - 1:0] data_be_CH0_int;
	wire [((2 ** $clog2(N_CH0)) * ID_WIDTH) - 1:0] data_ID_CH0_int;
	wire [(2 ** $clog2(N_CH0)) - 1:0] data_gnt_CH0_int;
	wire [(2 ** $clog2(N_CH1)) - 1:0] data_req_CH1_int;
	wire [((2 ** $clog2(N_CH1)) * ADDR_WIDTH) - 1:0] data_add_CH1_int;
	wire [(2 ** $clog2(N_CH1)) - 1:0] data_wen_CH1_int;
	wire [((2 ** $clog2(N_CH1)) * DATA_WIDTH) - 1:0] data_wdata_CH1_int;
	wire [((2 ** $clog2(N_CH1)) * BE_WIDTH) - 1:0] data_be_CH1_int;
	wire [((2 ** $clog2(N_CH1)) * ID_WIDTH) - 1:0] data_ID_CH1_int;
	wire [(2 ** $clog2(N_CH1)) - 1:0] data_gnt_CH1_int;
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
			assign data_req_CH0_int = {data_req_CH0_dummy, data_req_CH0_i};
			assign data_add_CH0_int = {data_add_CH0_dummy, data_add_CH0_i};
			assign data_wen_CH0_int = {data_wen_CH0_dummy, data_wen_CH0_i};
			assign data_wdata_CH0_int = {data_wdata_CH0_dummy, data_wdata_CH0_i};
			assign data_be_CH0_int = {data_be_CH0_dummy, data_be_CH0_i};
			assign data_ID_CH0_int = {data_ID_CH0_dummy, data_ID_CH0_i};
			genvar j;
			for (j = 0; j < N_CH0; j = j + 1) begin : _MERGING_CH0_DUMMY_PORTS_OUT_
				assign data_gnt_CH0_o[j] = data_gnt_CH0_int[j];
			end
		end
		else begin : genblk1
			assign data_req_CH0_int = data_req_CH0_i;
			assign data_add_CH0_int = data_add_CH0_i;
			assign data_wen_CH0_int = data_wen_CH0_i;
			assign data_wdata_CH0_int = data_wdata_CH0_i;
			assign data_be_CH0_int = data_be_CH0_i;
			assign data_ID_CH0_int = data_ID_CH0_i;
			assign data_gnt_CH0_o = data_gnt_CH0_int;
		end
		if ((2 ** $clog2(N_CH1)) != N_CH1) begin : _DUMMY_CH1_PORTS_
			wire [((2 ** $clog2(N_CH1)) - N_CH1) - 1:0] data_req_CH1_dummy;
			wire [(((2 ** $clog2(N_CH1)) - N_CH1) * ADDR_WIDTH) - 1:0] data_add_CH1_dummy;
			wire [((2 ** $clog2(N_CH1)) - N_CH1) - 1:0] data_wen_CH1_dummy;
			wire [(((2 ** $clog2(N_CH1)) - N_CH1) * DATA_WIDTH) - 1:0] data_wdata_CH1_dummy;
			wire [(((2 ** $clog2(N_CH1)) - N_CH1) * BE_WIDTH) - 1:0] data_be_CH1_dummy;
			wire [(((2 ** $clog2(N_CH1)) - N_CH1) * ID_WIDTH) - 1:0] data_ID_CH1_dummy;
			wire [((2 ** $clog2(N_CH1)) - N_CH1) - 1:0] data_gnt_CH1_dummy;
			assign data_req_CH1_dummy = 1'sb0;
			assign data_add_CH1_dummy = 1'sb0;
			assign data_wen_CH1_dummy = 1'sb0;
			assign data_wdata_CH1_dummy = 1'sb0;
			assign data_be_CH1_dummy = 1'sb0;
			assign data_ID_CH1_dummy = 1'sb0;
			assign data_req_CH1_int = {data_req_CH1_dummy, data_req_CH1_i};
			assign data_add_CH1_int = {data_add_CH1_dummy, data_add_CH1_i};
			assign data_wen_CH1_int = {data_wen_CH1_dummy, data_wen_CH1_i};
			assign data_wdata_CH1_int = {data_wdata_CH1_dummy, data_wdata_CH1_i};
			assign data_be_CH1_int = {data_be_CH1_dummy, data_be_CH1_i};
			assign data_ID_CH1_int = {data_ID_CH1_dummy, data_ID_CH1_i};
			genvar j;
			for (j = 0; j < N_CH1; j = j + 1) begin : _MERGING_CH1_DUMMY_PORTS_OUT_
				assign data_gnt_CH1_o[j] = data_gnt_CH1_int[j];
			end
		end
		else begin : genblk2
			assign data_req_CH1_int = data_req_CH1_i;
			assign data_add_CH1_int = data_add_CH1_i;
			assign data_wen_CH1_int = data_wen_CH1_i;
			assign data_wdata_CH1_int = data_wdata_CH1_i;
			assign data_be_CH1_int = data_be_CH1_i;
			assign data_ID_CH1_int = data_ID_CH1_i;
			assign data_gnt_CH1_o = data_gnt_CH1_int;
		end
		if (N_CH0 > 1) begin : CH0_ARB_TREE
			ArbitrationTree_L2 #(
				.ADDR_WIDTH(ADDR_WIDTH),
				.ID_WIDTH(ID_WIDTH),
				.N_MASTER(2 ** $clog2(N_CH0)),
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
				.data_req_o(data_req_CH0),
				.data_add_o(data_add_CH0),
				.data_wen_o(data_wen_CH0),
				.data_wdata_o(data_wdata_CH0),
				.data_be_o(data_be_CH0),
				.data_ID_o(data_ID_CH0),
				.data_gnt_i(data_gnt_CH0)
			);
		end
		if (N_CH1 > 1) begin : CH1_ARB_TREE
			ArbitrationTree_L2 #(
				.ADDR_WIDTH(ADDR_WIDTH),
				.ID_WIDTH(ID_WIDTH),
				.N_MASTER(2 ** $clog2(N_CH1)),
				.DATA_WIDTH(DATA_WIDTH),
				.BE_WIDTH(BE_WIDTH),
				.MAX_COUNT(N_CH1 - 1)
			) CH1_ARB_TREE(
				.clk(clk),
				.rst_n(rst_n),
				.data_req_i(data_req_CH1_int),
				.data_add_i(data_add_CH1_int),
				.data_wen_i(data_wen_CH1_int),
				.data_wdata_i(data_wdata_CH1_int),
				.data_be_i(data_be_CH1_int),
				.data_ID_i(data_ID_CH1_int),
				.data_gnt_o(data_gnt_CH1_int),
				.data_req_o(data_req_CH1),
				.data_add_o(data_add_CH1),
				.data_wen_o(data_wen_CH1),
				.data_wdata_o(data_wdata_CH1),
				.data_be_o(data_be_CH1),
				.data_ID_o(data_ID_CH1),
				.data_gnt_i(data_gnt_CH1)
			);
		end
		if (N_CH1 == 1) begin : MONO_CH1
			if (N_CH0 == 1) begin : MONO_CH0
				MUX2_REQ_L2 #(
					.ID_WIDTH(ID_WIDTH),
					.ADDR_WIDTH(ADDR_WIDTH),
					.DATA_WIDTH(DATA_WIDTH),
					.BE_WIDTH(BE_WIDTH)
				) MUX2_CH0_CH1(
					.data_req_CH0_i(data_req_CH0_int),
					.data_add_CH0_i(data_add_CH0_int),
					.data_wen_CH0_i(data_wen_CH0_int),
					.data_wdata_CH0_i(data_wdata_CH0_int),
					.data_be_CH0_i(data_be_CH0_int),
					.data_ID_CH0_i(data_ID_CH0_int),
					.data_gnt_CH0_o(data_gnt_CH0_int),
					.data_req_CH1_i(data_req_CH1_int),
					.data_add_CH1_i(data_add_CH1_int),
					.data_wen_CH1_i(data_wen_CH1_int),
					.data_wdata_CH1_i(data_wdata_CH1_int),
					.data_be_CH1_i(data_be_CH1_int),
					.data_ID_CH1_i(data_ID_CH1_int),
					.data_gnt_CH1_o(data_gnt_CH1_int),
					.data_req_o(data_req_o),
					.data_add_o(data_add_o),
					.data_wen_o(data_wen_o),
					.data_wdata_o(data_wdata_o),
					.data_be_o(data_be_o),
					.data_ID_o(data_ID_o),
					.data_gnt_i(data_gnt_i),
					.clk(clk),
					.rst_n(rst_n)
				);
			end
			else begin : POLY_CH0
				MUX2_REQ_L2 #(
					.ID_WIDTH(ID_WIDTH),
					.ADDR_WIDTH(ADDR_WIDTH),
					.DATA_WIDTH(DATA_WIDTH),
					.BE_WIDTH(BE_WIDTH)
				) MUX2_CH0_CH1(
					.data_req_CH0_i(data_req_CH0),
					.data_add_CH0_i(data_add_CH0),
					.data_wen_CH0_i(data_wen_CH0),
					.data_wdata_CH0_i(data_wdata_CH0),
					.data_be_CH0_i(data_be_CH0),
					.data_ID_CH0_i(data_ID_CH0),
					.data_gnt_CH0_o(data_gnt_CH0),
					.data_req_CH1_i(data_req_CH1_int),
					.data_add_CH1_i(data_add_CH1_int),
					.data_wen_CH1_i(data_wen_CH1_int),
					.data_wdata_CH1_i(data_wdata_CH1_int),
					.data_be_CH1_i(data_be_CH1_int),
					.data_ID_CH1_i(data_ID_CH1_int),
					.data_gnt_CH1_o(data_gnt_CH1_int),
					.data_req_o(data_req_o),
					.data_add_o(data_add_o),
					.data_wen_o(data_wen_o),
					.data_wdata_o(data_wdata_o),
					.data_be_o(data_be_o),
					.data_ID_o(data_ID_o),
					.data_gnt_i(data_gnt_i),
					.clk(clk),
					.rst_n(rst_n)
				);
			end
		end
		else begin : POLY_CH1
			if (N_CH0 == 1) begin : MONO_CH0
				MUX2_REQ_L2 #(
					.ID_WIDTH(ID_WIDTH),
					.ADDR_WIDTH(ADDR_WIDTH),
					.DATA_WIDTH(DATA_WIDTH),
					.BE_WIDTH(BE_WIDTH)
				) MUX2_CH0_CH1(
					.data_req_CH0_i(data_req_CH0_int),
					.data_add_CH0_i(data_add_CH0_int),
					.data_wen_CH0_i(data_wen_CH0_int),
					.data_wdata_CH0_i(data_wdata_CH0_int),
					.data_be_CH0_i(data_be_CH0_int),
					.data_ID_CH0_i(data_ID_CH0_int),
					.data_gnt_CH0_o(data_gnt_CH0_int),
					.data_req_CH1_i(data_req_CH1),
					.data_add_CH1_i(data_add_CH1),
					.data_wen_CH1_i(data_wen_CH1),
					.data_wdata_CH1_i(data_wdata_CH1),
					.data_be_CH1_i(data_be_CH1),
					.data_ID_CH1_i(data_ID_CH1),
					.data_gnt_CH1_o(data_gnt_CH1),
					.data_req_o(data_req_o),
					.data_add_o(data_add_o),
					.data_wen_o(data_wen_o),
					.data_wdata_o(data_wdata_o),
					.data_be_o(data_be_o),
					.data_ID_o(data_ID_o),
					.data_gnt_i(data_gnt_i),
					.clk(clk),
					.rst_n(rst_n)
				);
			end
			else begin : POLY_CH0
				MUX2_REQ_L2 #(
					.ID_WIDTH(ID_WIDTH),
					.ADDR_WIDTH(ADDR_WIDTH),
					.DATA_WIDTH(DATA_WIDTH),
					.BE_WIDTH(BE_WIDTH)
				) MUX2_CH0_CH1(
					.data_req_CH0_i(data_req_CH0),
					.data_add_CH0_i(data_add_CH0),
					.data_wen_CH0_i(data_wen_CH0),
					.data_wdata_CH0_i(data_wdata_CH0),
					.data_be_CH0_i(data_be_CH0),
					.data_ID_CH0_i(data_ID_CH0),
					.data_gnt_CH0_o(data_gnt_CH0),
					.data_req_CH1_i(data_req_CH1),
					.data_add_CH1_i(data_add_CH1),
					.data_wen_CH1_i(data_wen_CH1),
					.data_wdata_CH1_i(data_wdata_CH1),
					.data_be_CH1_i(data_be_CH1),
					.data_ID_CH1_i(data_ID_CH1),
					.data_gnt_CH1_o(data_gnt_CH1),
					.data_req_o(data_req_o),
					.data_add_o(data_add_o),
					.data_wen_o(data_wen_o),
					.data_wdata_o(data_wdata_o),
					.data_be_o(data_be_o),
					.data_ID_o(data_ID_o),
					.data_gnt_i(data_gnt_i),
					.clk(clk),
					.rst_n(rst_n)
				);
			end
		end
	endgenerate
	AddressDecoder_Resp_L2 #(
		.ID_WIDTH(ID_WIDTH),
		.N_MASTER(N_CH0 + N_CH1)
	) ADDR_DEC_RESP(
		.data_r_valid_i(data_r_valid_i),
		.data_r_ID_i(data_r_ID_i),
		.data_r_valid_o({data_r_valid_CH1_o, data_r_valid_CH0_o})
	);
endmodule
