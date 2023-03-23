module ArbitrationTree_BRIDGE (
	clk,
	rst_n,
	data_req_i,
	data_add_i,
	data_wen_i,
	data_wdata_i,
	data_be_i,
	data_ID_i,
	data_aux_i,
	data_gnt_o,
	data_req_o,
	data_add_o,
	data_wen_o,
	data_wdata_o,
	data_be_o,
	data_ID_o,
	data_aux_o,
	data_gnt_i
);
	parameter ADDR_WIDTH = 32;
	parameter ID_WIDTH = 20;
	parameter N_MASTER = 16;
	parameter DATA_WIDTH = 32;
	parameter BE_WIDTH = DATA_WIDTH / 8;
	parameter AUX_WIDTH = 6;
	parameter MAX_COUNT = N_MASTER;
	input wire clk;
	input wire rst_n;
	input wire [N_MASTER - 1:0] data_req_i;
	input wire [(N_MASTER * ADDR_WIDTH) - 1:0] data_add_i;
	input wire [N_MASTER - 1:0] data_wen_i;
	input wire [(N_MASTER * DATA_WIDTH) - 1:0] data_wdata_i;
	input wire [(N_MASTER * BE_WIDTH) - 1:0] data_be_i;
	input wire [(N_MASTER * ID_WIDTH) - 1:0] data_ID_i;
	input wire [(N_MASTER * AUX_WIDTH) - 1:0] data_aux_i;
	output wire [N_MASTER - 1:0] data_gnt_o;
	output wire data_req_o;
	output wire [ADDR_WIDTH - 1:0] data_add_o;
	output wire data_wen_o;
	output wire [DATA_WIDTH - 1:0] data_wdata_o;
	output wire [BE_WIDTH - 1:0] data_be_o;
	output wire [ID_WIDTH - 1:0] data_ID_o;
	output wire [AUX_WIDTH - 1:0] data_aux_o;
	input wire data_gnt_i;
	localparam LOG_MASTER = $clog2(N_MASTER);
	localparam N_WIRE = N_MASTER - 2;
	wire [LOG_MASTER - 1:0] RR_FLAG;
	genvar j;
	genvar k;
	generate
		case (N_MASTER)
			1: ;
			2: begin : DUAL_MASTER
				FanInPrimitive_Req_BRIDGE #(
					.ADDR_WIDTH(ADDR_WIDTH),
					.ID_WIDTH(ID_WIDTH),
					.DATA_WIDTH(DATA_WIDTH),
					.AUX_WIDTH(AUX_WIDTH),
					.BE_WIDTH(BE_WIDTH)
				) i_FanInPrimitive_Req_BRIDGE(
					.RR_FLAG(RR_FLAG),
					.data_wdata0_i(data_wdata_i[0+:DATA_WIDTH]),
					.data_wdata1_i(data_wdata_i[DATA_WIDTH+:DATA_WIDTH]),
					.data_add0_i(data_add_i[0+:ADDR_WIDTH]),
					.data_add1_i(data_add_i[ADDR_WIDTH+:ADDR_WIDTH]),
					.data_req0_i(data_req_i[0]),
					.data_req1_i(data_req_i[1]),
					.data_wen0_i(data_wen_i[0]),
					.data_wen1_i(data_wen_i[1]),
					.data_ID0_i(data_ID_i[0+:ID_WIDTH]),
					.data_ID1_i(data_ID_i[ID_WIDTH+:ID_WIDTH]),
					.data_be0_i(data_be_i[0+:BE_WIDTH]),
					.data_be1_i(data_be_i[BE_WIDTH+:BE_WIDTH]),
					.data_aux0_i(data_aux_i[0+:AUX_WIDTH]),
					.data_aux1_i(data_aux_i[AUX_WIDTH+:AUX_WIDTH]),
					.data_gnt0_o(data_gnt_o[0]),
					.data_gnt1_o(data_gnt_o[1]),
					.data_wdata_o(data_wdata_o),
					.data_add_o(data_add_o),
					.data_req_o(data_req_o),
					.data_wen_o(data_wen_o),
					.data_ID_o(data_ID_o),
					.data_be_o(data_be_o),
					.data_aux_o(data_aux_o),
					.data_gnt_i(data_gnt_i)
				);
			end
			default: begin : BINARY_TREE
				wire [DATA_WIDTH - 1:0] data_wdata_LEVEL [N_WIRE - 1:0];
				wire [ADDR_WIDTH - 1:0] data_add_LEVEL [N_WIRE - 1:0];
				wire data_req_LEVEL [N_WIRE - 1:0];
				wire data_wen_LEVEL [N_WIRE - 1:0];
				wire [ID_WIDTH - 1:0] data_ID_LEVEL [N_WIRE - 1:0];
				wire [BE_WIDTH - 1:0] data_be_LEVEL [N_WIRE - 1:0];
				wire [AUX_WIDTH - 1:0] data_aux_LEVEL [N_WIRE - 1:0];
				wire data_gnt_LEVEL [N_WIRE - 1:0];
				for (j = 0; j < LOG_MASTER; j = j + 1) begin : STAGE
					for (k = 0; k < (2 ** j); k = k + 1) begin : INCR_VERT
						if (j == 0) begin : LAST_NODE
							FanInPrimitive_Req_BRIDGE #(
								.ADDR_WIDTH(ADDR_WIDTH),
								.ID_WIDTH(ID_WIDTH),
								.DATA_WIDTH(DATA_WIDTH),
								.AUX_WIDTH(AUX_WIDTH),
								.BE_WIDTH(BE_WIDTH)
							) i_FanInPrimitive_Req_BRIDGE(
								.RR_FLAG(RR_FLAG[(LOG_MASTER - j) - 1]),
								.data_wdata0_i(data_wdata_LEVEL[2 * k]),
								.data_wdata1_i(data_wdata_LEVEL[(2 * k) + 1]),
								.data_add0_i(data_add_LEVEL[2 * k]),
								.data_add1_i(data_add_LEVEL[(2 * k) + 1]),
								.data_req0_i(data_req_LEVEL[2 * k]),
								.data_req1_i(data_req_LEVEL[(2 * k) + 1]),
								.data_wen0_i(data_wen_LEVEL[2 * k]),
								.data_wen1_i(data_wen_LEVEL[(2 * k) + 1]),
								.data_ID0_i(data_ID_LEVEL[2 * k]),
								.data_ID1_i(data_ID_LEVEL[(2 * k) + 1]),
								.data_be0_i(data_be_LEVEL[2 * k]),
								.data_be1_i(data_be_LEVEL[(2 * k) + 1]),
								.data_aux0_i(data_aux_LEVEL[2 * k]),
								.data_aux1_i(data_aux_LEVEL[(2 * k) + 1]),
								.data_gnt0_o(data_gnt_LEVEL[2 * k]),
								.data_gnt1_o(data_gnt_LEVEL[(2 * k) + 1]),
								.data_wdata_o(data_wdata_o),
								.data_add_o(data_add_o),
								.data_req_o(data_req_o),
								.data_wen_o(data_wen_o),
								.data_ID_o(data_ID_o),
								.data_be_o(data_be_o),
								.data_aux_o(data_aux_o),
								.data_gnt_i(data_gnt_i)
							);
						end
						else if (j < (LOG_MASTER - 1)) begin : MIDDLE_NODES
							FanInPrimitive_Req_BRIDGE #(
								.ADDR_WIDTH(ADDR_WIDTH),
								.ID_WIDTH(ID_WIDTH),
								.DATA_WIDTH(DATA_WIDTH),
								.AUX_WIDTH(AUX_WIDTH),
								.BE_WIDTH(BE_WIDTH)
							) i_FanInPrimitive_Req_BRIDGE(
								.RR_FLAG(RR_FLAG[(LOG_MASTER - j) - 1]),
								.data_wdata0_i(data_wdata_LEVEL[(((2 ** j) * 2) - 2) + (2 * k)]),
								.data_wdata1_i(data_wdata_LEVEL[((((2 ** j) * 2) - 2) + (2 * k)) + 1]),
								.data_add0_i(data_add_LEVEL[(((2 ** j) * 2) - 2) + (2 * k)]),
								.data_add1_i(data_add_LEVEL[((((2 ** j) * 2) - 2) + (2 * k)) + 1]),
								.data_req0_i(data_req_LEVEL[(((2 ** j) * 2) - 2) + (2 * k)]),
								.data_req1_i(data_req_LEVEL[((((2 ** j) * 2) - 2) + (2 * k)) + 1]),
								.data_wen0_i(data_wen_LEVEL[(((2 ** j) * 2) - 2) + (2 * k)]),
								.data_wen1_i(data_wen_LEVEL[((((2 ** j) * 2) - 2) + (2 * k)) + 1]),
								.data_ID0_i(data_ID_LEVEL[(((2 ** j) * 2) - 2) + (2 * k)]),
								.data_ID1_i(data_ID_LEVEL[((((2 ** j) * 2) - 2) + (2 * k)) + 1]),
								.data_be0_i(data_be_LEVEL[(((2 ** j) * 2) - 2) + (2 * k)]),
								.data_be1_i(data_be_LEVEL[((((2 ** j) * 2) - 2) + (2 * k)) + 1]),
								.data_aux0_i(data_aux_LEVEL[(((2 ** j) * 2) - 2) + (2 * k)]),
								.data_aux1_i(data_aux_LEVEL[((((2 ** j) * 2) - 2) + (2 * k)) + 1]),
								.data_gnt0_o(data_gnt_LEVEL[(((2 ** j) * 2) - 2) + (2 * k)]),
								.data_gnt1_o(data_gnt_LEVEL[((((2 ** j) * 2) - 2) + (2 * k)) + 1]),
								.data_wdata_o(data_wdata_LEVEL[(((2 ** (j - 1)) * 2) - 2) + k]),
								.data_add_o(data_add_LEVEL[(((2 ** (j - 1)) * 2) - 2) + k]),
								.data_req_o(data_req_LEVEL[(((2 ** (j - 1)) * 2) - 2) + k]),
								.data_wen_o(data_wen_LEVEL[(((2 ** (j - 1)) * 2) - 2) + k]),
								.data_ID_o(data_ID_LEVEL[(((2 ** (j - 1)) * 2) - 2) + k]),
								.data_be_o(data_be_LEVEL[(((2 ** (j - 1)) * 2) - 2) + k]),
								.data_aux_o(data_aux_LEVEL[(((2 ** (j - 1)) * 2) - 2) + k]),
								.data_gnt_i(data_gnt_LEVEL[(((2 ** (j - 1)) * 2) - 2) + k])
							);
						end
						else begin : LEAF_NODES
							FanInPrimitive_Req_BRIDGE #(
								.ADDR_WIDTH(ADDR_WIDTH),
								.ID_WIDTH(ID_WIDTH),
								.DATA_WIDTH(DATA_WIDTH),
								.AUX_WIDTH(AUX_WIDTH),
								.BE_WIDTH(BE_WIDTH)
							) i_FanInPrimitive_Req_BRIDGE(
								.RR_FLAG(RR_FLAG[(LOG_MASTER - j) - 1]),
								.data_wdata0_i(data_wdata_i[(2 * k) * DATA_WIDTH+:DATA_WIDTH]),
								.data_wdata1_i(data_wdata_i[((2 * k) + 1) * DATA_WIDTH+:DATA_WIDTH]),
								.data_add0_i(data_add_i[(2 * k) * ADDR_WIDTH+:ADDR_WIDTH]),
								.data_add1_i(data_add_i[((2 * k) + 1) * ADDR_WIDTH+:ADDR_WIDTH]),
								.data_req0_i(data_req_i[2 * k]),
								.data_req1_i(data_req_i[(2 * k) + 1]),
								.data_wen0_i(data_wen_i[2 * k]),
								.data_wen1_i(data_wen_i[(2 * k) + 1]),
								.data_ID0_i(data_ID_i[(2 * k) * ID_WIDTH+:ID_WIDTH]),
								.data_ID1_i(data_ID_i[((2 * k) + 1) * ID_WIDTH+:ID_WIDTH]),
								.data_be0_i(data_be_i[(2 * k) * BE_WIDTH+:BE_WIDTH]),
								.data_be1_i(data_be_i[((2 * k) + 1) * BE_WIDTH+:BE_WIDTH]),
								.data_aux0_i(data_aux_i[(2 * k) * AUX_WIDTH+:AUX_WIDTH]),
								.data_aux1_i(data_aux_i[((2 * k) + 1) * AUX_WIDTH+:AUX_WIDTH]),
								.data_gnt0_o(data_gnt_o[2 * k]),
								.data_gnt1_o(data_gnt_o[(2 * k) + 1]),
								.data_wdata_o(data_wdata_LEVEL[(((2 ** (j - 1)) * 2) - 2) + k]),
								.data_add_o(data_add_LEVEL[(((2 ** (j - 1)) * 2) - 2) + k]),
								.data_req_o(data_req_LEVEL[(((2 ** (j - 1)) * 2) - 2) + k]),
								.data_wen_o(data_wen_LEVEL[(((2 ** (j - 1)) * 2) - 2) + k]),
								.data_ID_o(data_ID_LEVEL[(((2 ** (j - 1)) * 2) - 2) + k]),
								.data_be_o(data_be_LEVEL[(((2 ** (j - 1)) * 2) - 2) + k]),
								.data_aux_o(data_aux_LEVEL[(((2 ** (j - 1)) * 2) - 2) + k]),
								.data_gnt_i(data_gnt_LEVEL[(((2 ** (j - 1)) * 2) - 2) + k])
							);
						end
					end
				end
			end
		endcase
	endgenerate
	RR_Flag_Req_BRIDGE #(
		.WIDTH(LOG_MASTER),
		.MAX_COUNT(MAX_COUNT)
	) RR_REQ(
		.clk(clk),
		.rst_n(rst_n),
		.RR_FLAG_o(RR_FLAG),
		.data_req_i(data_req_o),
		.data_gnt_i(data_gnt_i)
	);
endmodule
