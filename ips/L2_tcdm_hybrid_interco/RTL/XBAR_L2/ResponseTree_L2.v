module ResponseTree_L2 (
	data_r_valid_i,
	data_r_rdata_i,
	data_r_valid_o,
	data_r_rdata_o
);
	parameter N_SLAVE = 4;
	parameter DATA_WIDTH = 64;
	input wire [N_SLAVE - 1:0] data_r_valid_i;
	input wire [(N_SLAVE * DATA_WIDTH) - 1:0] data_r_rdata_i;
	output wire data_r_valid_o;
	output wire [DATA_WIDTH - 1:0] data_r_rdata_o;
	localparam LOG_SLAVE = $clog2(N_SLAVE);
	localparam N_WIRE = N_SLAVE - 2;
	genvar j;
	genvar k;
	generate
		case (N_SLAVE)
			1: begin : MONO_SLAVE
				assign data_r_rdata_o = data_r_rdata_i;
				assign data_r_valid_o = data_r_valid_i;
			end
			2: begin : DUAL_SLAVE
				FanInPrimitive_Resp_L2 #(.DATA_WIDTH(DATA_WIDTH)) FAN_IN_RESP(
					.data_r_rdata0_i(data_r_rdata_i[0+:DATA_WIDTH]),
					.data_r_rdata1_i(data_r_rdata_i[DATA_WIDTH+:DATA_WIDTH]),
					.data_r_valid0_i(data_r_valid_i[0]),
					.data_r_valid1_i(data_r_valid_i[1]),
					.data_r_rdata_o(data_r_rdata_o),
					.data_r_valid_o(data_r_valid_o)
				);
			end
			default: begin : MULTI_SLAVE
				wire [DATA_WIDTH - 1:0] data_r_rdata_LEVEL [N_WIRE - 1:0];
				wire data_r_valid_LEVEL [N_WIRE - 1:0];
				for (j = 0; j < LOG_SLAVE; j = j + 1) begin : STAGE
					for (k = 0; k < (2 ** j); k = k + 1) begin : INCR_VERT
						if (j == 0) begin : LAST_NODE
							FanInPrimitive_Resp_L2 #(.DATA_WIDTH(DATA_WIDTH)) FAN_IN_RESP(
								.data_r_rdata0_i(data_r_rdata_LEVEL[2 * k]),
								.data_r_rdata1_i(data_r_rdata_LEVEL[(2 * k) + 1]),
								.data_r_valid0_i(data_r_valid_LEVEL[2 * k]),
								.data_r_valid1_i(data_r_valid_LEVEL[(2 * k) + 1]),
								.data_r_rdata_o(data_r_rdata_o),
								.data_r_valid_o(data_r_valid_o)
							);
						end
						else if (j < (LOG_SLAVE - 1)) begin : MIDDLE_NODES
							FanInPrimitive_Resp_L2 #(.DATA_WIDTH(DATA_WIDTH)) FAN_IN_RESP(
								.data_r_rdata0_i(data_r_rdata_LEVEL[(((2 ** j) * 2) - 2) + (2 * k)]),
								.data_r_rdata1_i(data_r_rdata_LEVEL[((((2 ** j) * 2) - 2) + (2 * k)) + 1]),
								.data_r_valid0_i(data_r_valid_LEVEL[(((2 ** j) * 2) - 2) + (2 * k)]),
								.data_r_valid1_i(data_r_valid_LEVEL[((((2 ** j) * 2) - 2) + (2 * k)) + 1]),
								.data_r_rdata_o(data_r_rdata_LEVEL[(((2 ** (j - 1)) * 2) - 2) + k]),
								.data_r_valid_o(data_r_valid_LEVEL[(((2 ** (j - 1)) * 2) - 2) + k])
							);
						end
						else begin : LEAF_NODES
							FanInPrimitive_Resp_L2 #(.DATA_WIDTH(DATA_WIDTH)) FAN_IN_RESP(
								.data_r_rdata0_i(data_r_rdata_i[(2 * k) * DATA_WIDTH+:DATA_WIDTH]),
								.data_r_rdata1_i(data_r_rdata_i[((2 * k) + 1) * DATA_WIDTH+:DATA_WIDTH]),
								.data_r_valid0_i(data_r_valid_i[2 * k]),
								.data_r_valid1_i(data_r_valid_i[(2 * k) + 1]),
								.data_r_rdata_o(data_r_rdata_LEVEL[(((2 ** (j - 1)) * 2) - 2) + k]),
								.data_r_valid_o(data_r_valid_LEVEL[(((2 ** (j - 1)) * 2) - 2) + k])
							);
						end
					end
				end
			end
		endcase
	endgenerate
endmodule
