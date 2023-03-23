module ResponseBlock_BRIDGE (
	data_r_valid_i,
	data_r_rdata_i,
	data_r_opc_i,
	data_r_aux_i,
	data_r_valid_o,
	data_r_rdata_o,
	data_r_opc_o,
	data_r_aux_o,
	data_req_i,
	destination_i,
	data_gnt_o,
	data_req_o,
	data_gnt_i,
	data_ID_o
);
	parameter ID = 1;
	parameter ID_WIDTH = 17;
	parameter N_SLAVE = 16;
	parameter AUX_WIDTH = 8;
	parameter DATA_WIDTH = 32;
	input wire [N_SLAVE - 1:0] data_r_valid_i;
	input wire [(N_SLAVE * DATA_WIDTH) - 1:0] data_r_rdata_i;
	input wire [N_SLAVE - 1:0] data_r_opc_i;
	input wire [(N_SLAVE * AUX_WIDTH) - 1:0] data_r_aux_i;
	output wire data_r_valid_o;
	output wire [DATA_WIDTH - 1:0] data_r_rdata_o;
	output wire data_r_opc_o;
	output wire [AUX_WIDTH - 1:0] data_r_aux_o;
	input wire data_req_i;
	input wire [N_SLAVE - 1:0] destination_i;
	output wire data_gnt_o;
	output wire [N_SLAVE - 1:0] data_req_o;
	input wire [N_SLAVE - 1:0] data_gnt_i;
	output wire [ID_WIDTH - 1:0] data_ID_o;
	wire [(2 ** $clog2(N_SLAVE)) - 1:0] data_r_valid_int;
	wire [((2 ** $clog2(N_SLAVE)) * DATA_WIDTH) - 1:0] data_r_rdata_int;
	wire [(2 ** $clog2(N_SLAVE)) - 1:0] data_r_opc_int;
	wire [((2 ** $clog2(N_SLAVE)) * AUX_WIDTH) - 1:0] data_r_aux_int;
	generate
		if ((2 ** $clog2(N_SLAVE)) != N_SLAVE) begin : _DUMMY_SLAVE_PORTS_
			wire [((2 ** $clog2(N_SLAVE)) - N_SLAVE) - 1:0] data_r_valid_dummy;
			wire [(((2 ** $clog2(N_SLAVE)) - N_SLAVE) * DATA_WIDTH) - 1:0] data_r_rdata_dummy;
			wire [((2 ** $clog2(N_SLAVE)) - N_SLAVE) - 1:0] data_r_opc_dummy;
			wire [(((2 ** $clog2(N_SLAVE)) - N_SLAVE) * AUX_WIDTH) - 1:0] data_r_aux_dummy;
			assign data_r_valid_dummy = 1'sb0;
			assign data_r_rdata_dummy = 1'sb0;
			assign data_r_opc_dummy = 1'sb0;
			assign data_r_aux_dummy = 1'sb0;
			assign data_r_valid_int = {data_r_valid_dummy, data_r_valid_i};
			assign data_r_rdata_int = {data_r_rdata_dummy, data_r_rdata_i};
			assign data_r_opc_int = {data_r_opc_dummy, data_r_opc_i};
			assign data_r_aux_int = {data_r_aux_dummy, data_r_aux_i};
		end
		else begin : genblk1
			assign data_r_valid_int = data_r_valid_i;
			assign data_r_rdata_int = data_r_rdata_i;
			assign data_r_opc_int = data_r_opc_i;
			assign data_r_aux_int = data_r_aux_i;
		end
	endgenerate
	ResponseTree_BRIDGE #(
		.N_SLAVE(2 ** $clog2(N_SLAVE)),
		.DATA_WIDTH(DATA_WIDTH),
		.AUX_WIDTH(AUX_WIDTH)
	) i_ResponseTree_BRIDGE(
		.data_r_valid_i(data_r_valid_int),
		.data_r_rdata_i(data_r_rdata_int),
		.data_r_opc_i(data_r_opc_int),
		.data_r_aux_i(data_r_aux_int),
		.data_r_valid_o(data_r_valid_o),
		.data_r_rdata_o(data_r_rdata_o),
		.data_r_opc_o(data_r_opc_o),
		.data_r_aux_o(data_r_aux_o)
	);
	AddressDecoder_Req_BRIDGE #(
		.ID_WIDTH(ID_WIDTH),
		.ID(ID),
		.N_SLAVE(N_SLAVE)
	) i_AddressDecoder_Req_BRIDGE(
		.data_req_i(data_req_i),
		.destination_i(destination_i),
		.data_gnt_o(data_gnt_o),
		.data_gnt_i(data_gnt_i),
		.data_req_o(data_req_o),
		.data_ID_o(data_ID_o)
	);
endmodule
