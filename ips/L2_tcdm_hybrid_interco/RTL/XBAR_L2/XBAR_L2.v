module XBAR_L2 (
	data_req_i,
	data_add_i,
	data_wen_i,
	data_wdata_i,
	data_be_i,
	data_gnt_o,
	data_r_valid_o,
	data_r_rdata_o,
	data_req_o,
	data_add_o,
	data_wen_o,
	data_wdata_o,
	data_be_o,
	data_ID_o,
	data_r_rdata_i,
	data_r_valid_i,
	data_r_ID_i,
	clk,
	rst_n
);
	parameter N_CH0 = 5;
	parameter N_CH1 = 4;
	parameter ADDR_MEM_WIDTH = 12;
	parameter N_SLAVE = 4;
	parameter DATA_WIDTH = 64;
	parameter BE_WIDTH = DATA_WIDTH / 8;
	parameter ID_WIDTH = N_CH0 + N_CH1;
	parameter N_MASTER = N_CH0 + N_CH1;
	parameter ADDR_IN_WIDTH = ADDR_MEM_WIDTH + $clog2(N_SLAVE);
	input wire [N_MASTER - 1:0] data_req_i;
	input wire [(N_MASTER * ADDR_IN_WIDTH) - 1:0] data_add_i;
	input wire [N_MASTER - 1:0] data_wen_i;
	input wire [(N_MASTER * DATA_WIDTH) - 1:0] data_wdata_i;
	input wire [(N_MASTER * BE_WIDTH) - 1:0] data_be_i;
	output wire [N_MASTER - 1:0] data_gnt_o;
	output wire [N_MASTER - 1:0] data_r_valid_o;
	output wire [(N_MASTER * DATA_WIDTH) - 1:0] data_r_rdata_o;
	output wire [N_SLAVE - 1:0] data_req_o;
	output wire [(N_SLAVE * ADDR_MEM_WIDTH) - 1:0] data_add_o;
	output wire [N_SLAVE - 1:0] data_wen_o;
	output wire [(N_SLAVE * DATA_WIDTH) - 1:0] data_wdata_o;
	output wire [(N_SLAVE * BE_WIDTH) - 1:0] data_be_o;
	output wire [(N_SLAVE * ID_WIDTH) - 1:0] data_ID_o;
	input wire [(N_SLAVE * DATA_WIDTH) - 1:0] data_r_rdata_i;
	input wire [N_SLAVE - 1:0] data_r_valid_i;
	input wire [(N_SLAVE * ID_WIDTH) - 1:0] data_r_ID_i;
	input wire clk;
	input wire rst_n;
	wire [(N_MASTER * ID_WIDTH) - 1:0] data_ID;
	wire [(N_MASTER * ADDR_MEM_WIDTH) - 1:0] data_add;
	wire [(N_MASTER * $clog2(N_SLAVE)) - 1:0] data_routing;
	wire [N_MASTER - 1:0] data_r_valid_from_MEM [N_SLAVE - 1:0];
	wire [N_SLAVE - 1:0] data_r_valid_to_MASTER [N_MASTER - 1:0];
	wire [N_SLAVE - 1:0] data_req_from_MASTER [N_MASTER - 1:0];
	wire [N_MASTER - 1:0] data_req_to_MEM [N_SLAVE - 1:0];
	wire [N_SLAVE - 1:0] data_gnt_to_MASTER [N_MASTER - 1:0];
	wire [N_MASTER - 1:0] data_gnt_from_MEM [N_SLAVE - 1:0];
	genvar i;
	genvar j;
	genvar k;
	generate
		for (k = 0; k < N_MASTER; k = k + 1) begin : wiring_req_rout
			if (N_SLAVE > 1) begin : genblk1
				assign data_add[k * ADDR_MEM_WIDTH+:ADDR_MEM_WIDTH] = {data_add_i[(k * ADDR_IN_WIDTH) + (((ADDR_MEM_WIDTH + $clog2(N_SLAVE)) - 1) >= $clog2(N_SLAVE) ? (ADDR_MEM_WIDTH + $clog2(N_SLAVE)) - 1 : (((ADDR_MEM_WIDTH + $clog2(N_SLAVE)) - 1) + (((ADDR_MEM_WIDTH + $clog2(N_SLAVE)) - 1) >= $clog2(N_SLAVE) ? (((ADDR_MEM_WIDTH + $clog2(N_SLAVE)) - 1) - $clog2(N_SLAVE)) + 1 : ($clog2(N_SLAVE) - ((ADDR_MEM_WIDTH + $clog2(N_SLAVE)) - 1)) + 1)) - 1)-:(((ADDR_MEM_WIDTH + $clog2(N_SLAVE)) - 1) >= $clog2(N_SLAVE) ? (((ADDR_MEM_WIDTH + $clog2(N_SLAVE)) - 1) - $clog2(N_SLAVE)) + 1 : ($clog2(N_SLAVE) - ((ADDR_MEM_WIDTH + $clog2(N_SLAVE)) - 1)) + 1)]};
			end
			else begin : genblk1
				assign data_add[k * ADDR_MEM_WIDTH+:ADDR_MEM_WIDTH] = data_add_i[k * ADDR_IN_WIDTH+:ADDR_IN_WIDTH];
			end
			if (N_SLAVE > 1) begin : genblk2
				assign data_routing[k * $clog2(N_SLAVE)+:$clog2(N_SLAVE)] = data_add_i[(k * ADDR_IN_WIDTH) + ($clog2(N_SLAVE) - 1)-:$clog2(N_SLAVE)];
			end
			else begin : genblk2
				assign data_routing[k * $clog2(N_SLAVE)+:$clog2(N_SLAVE)] = 1'b0;
			end
			for (j = 0; j < N_SLAVE; j = j + 1) begin : Wiring_flow_ctrl
				assign data_r_valid_to_MASTER[k][j] = data_r_valid_from_MEM[j][k];
				assign data_req_to_MEM[j][k] = data_req_from_MASTER[k][j];
				assign data_gnt_to_MASTER[k][j] = data_gnt_from_MEM[j][k];
			end
		end
		for (j = 0; j < N_SLAVE; j = j + 1) begin : genblk2
			if (N_CH1 == 0) begin : CH0_ONLY
				RequestBlock_L2_1CH #(
					.ADDR_WIDTH(ADDR_MEM_WIDTH),
					.N_CH0(N_CH0),
					.ID_WIDTH(ID_WIDTH),
					.DATA_WIDTH(DATA_WIDTH),
					.BE_WIDTH(BE_WIDTH)
				) REQ_BLOCK_CLUSTERS(
					.data_req_i(data_req_to_MEM[j]),
					.data_add_i(data_add),
					.data_wen_i(data_wen_i),
					.data_wdata_i(data_wdata_i),
					.data_be_i(data_be_i),
					.data_ID_i(data_ID),
					.data_gnt_o(data_gnt_from_MEM[j]),
					.data_req_o(data_req_o[j]),
					.data_add_o(data_add_o[j * ADDR_MEM_WIDTH+:ADDR_MEM_WIDTH]),
					.data_wen_o(data_wen_o[j]),
					.data_wdata_o(data_wdata_o[j * DATA_WIDTH+:DATA_WIDTH]),
					.data_be_o(data_be_o[j * BE_WIDTH+:BE_WIDTH]),
					.data_ID_o(data_ID_o[j * ID_WIDTH+:ID_WIDTH]),
					.data_gnt_i(1'b1),
					.data_r_valid_i(data_r_valid_i[j]),
					.data_r_ID_i(data_r_ID_i[j * ID_WIDTH+:ID_WIDTH]),
					.data_r_valid_o(data_r_valid_from_MEM[j]),
					.clk(clk),
					.rst_n(rst_n)
				);
			end
			else begin : CH0_CH1
				RequestBlock_L2_2CH #(
					.ADDR_WIDTH(ADDR_MEM_WIDTH),
					.N_CH0(N_CH0),
					.N_CH1(N_CH1),
					.ID_WIDTH(ID_WIDTH),
					.DATA_WIDTH(DATA_WIDTH),
					.BE_WIDTH(BE_WIDTH)
				) REQ_BLOCK_CLUSTERS_FC(
					.data_req_CH0_i(data_req_to_MEM[j][N_CH0 - 1:0]),
					.data_add_CH0_i(data_add[ADDR_MEM_WIDTH * ((N_CH0 - 1) - (N_CH0 - 1))+:ADDR_MEM_WIDTH * N_CH0]),
					.data_wen_CH0_i(data_wen_i[N_CH0 - 1:0]),
					.data_wdata_CH0_i(data_wdata_i[DATA_WIDTH * ((N_CH0 - 1) - (N_CH0 - 1))+:DATA_WIDTH * N_CH0]),
					.data_be_CH0_i(data_be_i[BE_WIDTH * ((N_CH0 - 1) - (N_CH0 - 1))+:BE_WIDTH * N_CH0]),
					.data_ID_CH0_i(data_ID[ID_WIDTH * ((N_CH0 - 1) - (N_CH0 - 1))+:ID_WIDTH * N_CH0]),
					.data_gnt_CH0_o(data_gnt_from_MEM[j][N_CH0 - 1:0]),
					.data_req_CH1_i(data_req_to_MEM[j][(N_CH0 + N_CH1) - 1:N_CH0]),
					.data_add_CH1_i(data_add[ADDR_MEM_WIDTH * ((((N_CH0 + N_CH1) - 1) >= N_CH0 ? (N_CH0 + N_CH1) - 1 : (((N_CH0 + N_CH1) - 1) + (((N_CH0 + N_CH1) - 1) >= N_CH0 ? (((N_CH0 + N_CH1) - 1) - N_CH0) + 1 : (N_CH0 - ((N_CH0 + N_CH1) - 1)) + 1)) - 1) - ((((N_CH0 + N_CH1) - 1) >= N_CH0 ? (((N_CH0 + N_CH1) - 1) - N_CH0) + 1 : (N_CH0 - ((N_CH0 + N_CH1) - 1)) + 1) - 1))+:ADDR_MEM_WIDTH * (((N_CH0 + N_CH1) - 1) >= N_CH0 ? (((N_CH0 + N_CH1) - 1) - N_CH0) + 1 : (N_CH0 - ((N_CH0 + N_CH1) - 1)) + 1)]),
					.data_wen_CH1_i(data_wen_i[(N_CH0 + N_CH1) - 1:N_CH0]),
					.data_wdata_CH1_i(data_wdata_i[DATA_WIDTH * ((((N_CH0 + N_CH1) - 1) >= N_CH0 ? (N_CH0 + N_CH1) - 1 : (((N_CH0 + N_CH1) - 1) + (((N_CH0 + N_CH1) - 1) >= N_CH0 ? (((N_CH0 + N_CH1) - 1) - N_CH0) + 1 : (N_CH0 - ((N_CH0 + N_CH1) - 1)) + 1)) - 1) - ((((N_CH0 + N_CH1) - 1) >= N_CH0 ? (((N_CH0 + N_CH1) - 1) - N_CH0) + 1 : (N_CH0 - ((N_CH0 + N_CH1) - 1)) + 1) - 1))+:DATA_WIDTH * (((N_CH0 + N_CH1) - 1) >= N_CH0 ? (((N_CH0 + N_CH1) - 1) - N_CH0) + 1 : (N_CH0 - ((N_CH0 + N_CH1) - 1)) + 1)]),
					.data_be_CH1_i(data_be_i[BE_WIDTH * ((((N_CH0 + N_CH1) - 1) >= N_CH0 ? (N_CH0 + N_CH1) - 1 : (((N_CH0 + N_CH1) - 1) + (((N_CH0 + N_CH1) - 1) >= N_CH0 ? (((N_CH0 + N_CH1) - 1) - N_CH0) + 1 : (N_CH0 - ((N_CH0 + N_CH1) - 1)) + 1)) - 1) - ((((N_CH0 + N_CH1) - 1) >= N_CH0 ? (((N_CH0 + N_CH1) - 1) - N_CH0) + 1 : (N_CH0 - ((N_CH0 + N_CH1) - 1)) + 1) - 1))+:BE_WIDTH * (((N_CH0 + N_CH1) - 1) >= N_CH0 ? (((N_CH0 + N_CH1) - 1) - N_CH0) + 1 : (N_CH0 - ((N_CH0 + N_CH1) - 1)) + 1)]),
					.data_ID_CH1_i(data_ID[ID_WIDTH * ((((N_CH0 + N_CH1) - 1) >= N_CH0 ? (N_CH0 + N_CH1) - 1 : (((N_CH0 + N_CH1) - 1) + (((N_CH0 + N_CH1) - 1) >= N_CH0 ? (((N_CH0 + N_CH1) - 1) - N_CH0) + 1 : (N_CH0 - ((N_CH0 + N_CH1) - 1)) + 1)) - 1) - ((((N_CH0 + N_CH1) - 1) >= N_CH0 ? (((N_CH0 + N_CH1) - 1) - N_CH0) + 1 : (N_CH0 - ((N_CH0 + N_CH1) - 1)) + 1) - 1))+:ID_WIDTH * (((N_CH0 + N_CH1) - 1) >= N_CH0 ? (((N_CH0 + N_CH1) - 1) - N_CH0) + 1 : (N_CH0 - ((N_CH0 + N_CH1) - 1)) + 1)]),
					.data_gnt_CH1_o(data_gnt_from_MEM[j][(N_CH0 + N_CH1) - 1:N_CH0]),
					.data_req_o(data_req_o[j]),
					.data_add_o(data_add_o[j * ADDR_MEM_WIDTH+:ADDR_MEM_WIDTH]),
					.data_wen_o(data_wen_o[j]),
					.data_wdata_o(data_wdata_o[j * DATA_WIDTH+:DATA_WIDTH]),
					.data_be_o(data_be_o[j * BE_WIDTH+:BE_WIDTH]),
					.data_ID_o(data_ID_o[j * ID_WIDTH+:ID_WIDTH]),
					.data_gnt_i(1'b1),
					.data_r_valid_i(data_r_valid_i[j]),
					.data_r_ID_i(data_r_ID_i[j * ID_WIDTH+:ID_WIDTH]),
					.data_r_valid_CH0_o(data_r_valid_from_MEM[j][N_CH0 - 1:0]),
					.data_r_valid_CH1_o(data_r_valid_from_MEM[j][(N_CH1 + N_CH0) - 1:N_CH0]),
					.clk(clk),
					.rst_n(rst_n)
				);
			end
		end
		if (N_SLAVE == 1) begin : genblk3
			for (j = 0; j < N_MASTER; j = j + 1) begin : WIRING
				assign data_r_rdata_o[j * DATA_WIDTH+:DATA_WIDTH] = data_r_rdata_i;
				assign data_r_valid_o[j] = data_r_valid_to_MASTER[j];
				assign data_ID[j * ID_WIDTH+:ID_WIDTH] = 2 ** j;
				assign data_req_from_MASTER[j] = data_req_i[j];
				assign data_gnt_o[j] = data_gnt_to_MASTER[j];
			end
		end
		else begin : genblk3
			for (j = 0; j < N_MASTER; j = j + 1) begin : ResponseBlock
				ResponseBlock_L2 #(
					.ID(2 ** j),
					.ID_WIDTH(ID_WIDTH),
					.N_SLAVE(N_SLAVE),
					.DATA_WIDTH(DATA_WIDTH)
				) RESP_BLOCK(
					.data_r_valid_i(data_r_valid_to_MASTER[j]),
					.data_r_rdata_i(data_r_rdata_i),
					.data_r_valid_o(data_r_valid_o[j]),
					.data_r_rdata_o(data_r_rdata_o[j * DATA_WIDTH+:DATA_WIDTH]),
					.data_req_i(data_req_i[j]),
					.routing_addr_i(data_routing[j * $clog2(N_SLAVE)+:$clog2(N_SLAVE)]),
					.data_gnt_o(data_gnt_o[j]),
					.data_req_o(data_req_from_MASTER[j]),
					.data_gnt_i(data_gnt_to_MASTER[j]),
					.data_ID_o(data_ID[j * ID_WIDTH+:ID_WIDTH])
				);
			end
		end
	endgenerate
endmodule
