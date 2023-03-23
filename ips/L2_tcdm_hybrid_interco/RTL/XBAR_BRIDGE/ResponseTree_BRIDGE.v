module ResponseTree_BRIDGE (
	data_r_valid_i,
	data_r_rdata_i,
	data_r_opc_i,
	data_r_aux_i,
	data_r_valid_o,
	data_r_rdata_o,
	data_r_opc_o,
	data_r_aux_o
);
	parameter N_SLAVE = 16;
	parameter DATA_WIDTH = 32;
	parameter AUX_WIDTH = 8;
	input wire [N_SLAVE - 1:0] data_r_valid_i;
	input wire [(N_SLAVE * DATA_WIDTH) - 1:0] data_r_rdata_i;
	input wire [N_SLAVE - 1:0] data_r_opc_i;
	input wire [(N_SLAVE * AUX_WIDTH) - 1:0] data_r_aux_i;
	output wire data_r_valid_o;
	output wire [DATA_WIDTH - 1:0] data_r_rdata_o;
	output wire data_r_opc_o;
	output wire [AUX_WIDTH - 1:0] data_r_aux_o;
	localparam LOG_SLAVE = $clog2(N_SLAVE);
	localparam N_WIRE = N_SLAVE - 2;
	genvar j;
	genvar k;
	generate
		case (N_SLAVE)
			1: begin : MONO_SLAVE
				assign data_r_rdata_o = data_r_rdata_i;
				assign data_r_valid_o = data_r_valid_i;
				assign data_r_opc_o = data_r_opc_i;
				assign data_r_aux_o = data_r_aux_i;
			end
			2: begin : DUAL_SLAVE
				FanInPrimitive_Resp_BRIDGE #(
					.DATA_WIDTH(DATA_WIDTH),
					.AUX_WIDTH(AUX_WIDTH)
				) i_FanInPrimitive_Resp_BRIDGE(
					.data_r_rdata0_i(data_r_rdata_i[0+:DATA_WIDTH]),
					.data_r_rdata1_i(data_r_rdata_i[DATA_WIDTH+:DATA_WIDTH]),
					.data_r_valid0_i(data_r_valid_i[0]),
					.data_r_valid1_i(data_r_valid_i[1]),
					.data_r_opc0_i(data_r_opc_i[0]),
					.data_r_opc1_i(data_r_opc_i[1]),
					.data_r_aux0_i(data_r_aux_i[0+:AUX_WIDTH]),
					.data_r_aux1_i(data_r_aux_i[AUX_WIDTH+:AUX_WIDTH]),
					.data_r_rdata_o(data_r_rdata_o),
					.data_r_valid_o(data_r_valid_o),
					.data_r_opc_o(data_r_opc_o),
					.data_r_aux_o(data_r_aux_o)
				);
			end
			default: begin : BINARY_TREE
				wire [DATA_WIDTH - 1:0] data_r_rdata_LEVEL [N_WIRE - 1:0];
				wire data_r_valid_LEVEL [N_WIRE - 1:0];
				wire data_r_opc_LEVEL [N_WIRE - 1:0];
				wire [AUX_WIDTH - 1:0] data_r_aux_LEVEL [N_WIRE - 1:0];
				for (j = 0; j < LOG_SLAVE; j = j + 1) begin : STAGE
					for (k = 0; k < (2 ** j); k = k + 1) begin : INCR_VERT
						if (j == 0) begin : LAST_NODE
							FanInPrimitive_Resp_BRIDGE #(
								.DATA_WIDTH(DATA_WIDTH),
								.AUX_WIDTH(AUX_WIDTH)
							) i_FanInPrimitive_Resp_BRIDGE(
								.data_r_rdata0_i(data_r_rdata_LEVEL[2 * k]),
								.data_r_rdata1_i(data_r_rdata_LEVEL[(2 * k) + 1]),
								.data_r_valid0_i(data_r_valid_LEVEL[2 * k]),
								.data_r_valid1_i(data_r_valid_LEVEL[(2 * k) + 1]),
								.data_r_opc0_i(data_r_opc_LEVEL[2 * k]),
								.data_r_opc1_i(data_r_opc_LEVEL[(2 * k) + 1]),
								.data_r_aux0_i(data_r_aux_LEVEL[2 * k]),
								.data_r_aux1_i(data_r_aux_LEVEL[(2 * k) + 1]),
								.data_r_rdata_o(data_r_rdata_o),
								.data_r_valid_o(data_r_valid_o),
								.data_r_opc_o(data_r_opc_o),
								.data_r_aux_o(data_r_aux_o)
							);
						end
						else if (j < (LOG_SLAVE - 1)) begin : MIDDLE_NODES
							FanInPrimitive_Resp_BRIDGE #(
								.DATA_WIDTH(DATA_WIDTH),
								.AUX_WIDTH(AUX_WIDTH)
							) i_FanInPrimitive_Resp_BRIDGE(
								.data_r_rdata0_i(data_r_rdata_LEVEL[(((2 ** j) * 2) - 2) + (2 * k)]),
								.data_r_rdata1_i(data_r_rdata_LEVEL[((((2 ** j) * 2) - 2) + (2 * k)) + 1]),
								.data_r_valid0_i(data_r_valid_LEVEL[(((2 ** j) * 2) - 2) + (2 * k)]),
								.data_r_valid1_i(data_r_valid_LEVEL[((((2 ** j) * 2) - 2) + (2 * k)) + 1]),
								.data_r_opc0_i(data_r_opc_LEVEL[(((2 ** j) * 2) - 2) + (2 * k)]),
								.data_r_opc1_i(data_r_opc_LEVEL[((((2 ** j) * 2) - 2) + (2 * k)) + 1]),
								.data_r_aux0_i(data_r_aux_LEVEL[(((2 ** j) * 2) - 2) + (2 * k)]),
								.data_r_aux1_i(data_r_aux_LEVEL[((((2 ** j) * 2) - 2) + (2 * k)) + 1]),
								.data_r_rdata_o(data_r_rdata_LEVEL[(((2 ** (j - 1)) * 2) - 2) + k]),
								.data_r_valid_o(data_r_valid_LEVEL[(((2 ** (j - 1)) * 2) - 2) + k]),
								.data_r_opc_o(data_r_opc_LEVEL[(((2 ** (j - 1)) * 2) - 2) + k]),
								.data_r_aux_o(data_r_aux_LEVEL[(((2 ** (j - 1)) * 2) - 2) + k])
							);
						end
						else begin : LEAF_NODES
							FanInPrimitive_Resp_BRIDGE #(
								.DATA_WIDTH(DATA_WIDTH),
								.AUX_WIDTH(AUX_WIDTH)
							) i_FanInPrimitive_Resp_BRIDGE(
								.data_r_rdata0_i(data_r_rdata_i[(2 * k) * DATA_WIDTH+:DATA_WIDTH]),
								.data_r_rdata1_i(data_r_rdata_i[((2 * k) + 1) * DATA_WIDTH+:DATA_WIDTH]),
								.data_r_valid0_i(data_r_valid_i[2 * k]),
								.data_r_valid1_i(data_r_valid_i[(2 * k) + 1]),
								.data_r_opc0_i(data_r_opc_i[2 * k]),
								.data_r_opc1_i(data_r_opc_i[(2 * k) + 1]),
								.data_r_aux0_i(data_r_aux_i[(2 * k) * AUX_WIDTH+:AUX_WIDTH]),
								.data_r_aux1_i(data_r_aux_i[((2 * k) + 1) * AUX_WIDTH+:AUX_WIDTH]),
								.data_r_rdata_o(data_r_rdata_LEVEL[(((2 ** (j - 1)) * 2) - 2) + k]),
								.data_r_valid_o(data_r_valid_LEVEL[(((2 ** (j - 1)) * 2) - 2) + k]),
								.data_r_opc_o(data_r_opc_LEVEL[(((2 ** (j - 1)) * 2) - 2) + k]),
								.data_r_aux_o(data_r_aux_LEVEL[(((2 ** (j - 1)) * 2) - 2) + k])
							);
						end
					end
				end
			end
		endcase
	endgenerate
endmodule
