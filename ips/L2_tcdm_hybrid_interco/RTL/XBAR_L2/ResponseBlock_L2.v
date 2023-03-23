module ResponseBlock_L2 (
	data_r_valid_i,
	data_r_rdata_i,
	data_r_valid_o,
	data_r_rdata_o,
	data_req_i,
	routing_addr_i,
	data_gnt_o,
	data_gnt_i,
	data_req_o,
	data_ID_o
);
	parameter ID = 1;
	parameter ID_WIDTH = 20;
	parameter N_SLAVE = 2;
	parameter DATA_WIDTH = 64;
	parameter ROUT_WIDTH = $clog2(N_SLAVE);
	input wire [N_SLAVE - 1:0] data_r_valid_i;
	input wire [(N_SLAVE * DATA_WIDTH) - 1:0] data_r_rdata_i;
	output wire data_r_valid_o;
	output wire [DATA_WIDTH - 1:0] data_r_rdata_o;
	input wire data_req_i;
	input wire [ROUT_WIDTH - 1:0] routing_addr_i;
	output wire data_gnt_o;
	input wire [N_SLAVE - 1:0] data_gnt_i;
	output wire [N_SLAVE - 1:0] data_req_o;
	output wire [ID_WIDTH - 1:0] data_ID_o;
	ResponseTree_L2 #(
		.N_SLAVE(N_SLAVE),
		.DATA_WIDTH(DATA_WIDTH)
	) MEM_RESP_TREE(
		.data_r_valid_i(data_r_valid_i),
		.data_r_rdata_i(data_r_rdata_i),
		.data_r_valid_o(data_r_valid_o),
		.data_r_rdata_o(data_r_rdata_o)
	);
	AddressDecoder_Req_L2 #(
		.ID_WIDTH(ID_WIDTH),
		.ID(ID),
		.N_SLAVE(N_SLAVE)
	) ADDR_DEC_REQ(
		.data_req_i(data_req_i),
		.routing_addr_i(routing_addr_i),
		.data_gnt_o(data_gnt_o),
		.data_gnt_i(data_gnt_i),
		.data_req_o(data_req_o),
		.data_ID_o(data_ID_o)
	);
endmodule
