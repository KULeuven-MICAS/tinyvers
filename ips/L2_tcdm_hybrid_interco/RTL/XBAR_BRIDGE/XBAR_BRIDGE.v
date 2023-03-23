module XBAR_BRIDGE (
	data_req_i,
	data_add_i,
	data_wen_i,
	data_wdata_i,
	data_be_i,
	data_aux_i,
	data_gnt_o,
	data_r_valid_o,
	data_r_rdata_o,
	data_r_opc_o,
	data_r_aux_o,
	data_req_o,
	data_add_o,
	data_wen_o,
	data_wdata_o,
	data_be_o,
	data_ID_o,
	data_aux_o,
	data_gnt_i,
	data_r_rdata_i,
	data_r_valid_i,
	data_r_ID_i,
	data_r_opc_i,
	data_r_aux_i,
	clk,
	rst_n,
	START_ADDR,
	END_ADDR
);
	parameter N_CH0 = 5;
	parameter N_CH1 = 4;
	parameter N_SLAVE = 3;
	parameter ID_WIDTH = N_CH0 + N_CH1;
	parameter AUX_WIDTH = 8;
	parameter ADDR_WIDTH = 32;
	parameter DATA_WIDTH = 32;
	parameter BE_WIDTH = DATA_WIDTH / 8;
	input wire [(N_CH0 + N_CH1) - 1:0] data_req_i;
	input wire [((N_CH0 + N_CH1) * ADDR_WIDTH) - 1:0] data_add_i;
	input wire [(N_CH0 + N_CH1) - 1:0] data_wen_i;
	input wire [((N_CH0 + N_CH1) * DATA_WIDTH) - 1:0] data_wdata_i;
	input wire [((N_CH0 + N_CH1) * BE_WIDTH) - 1:0] data_be_i;
	input wire [((N_CH0 + N_CH1) * AUX_WIDTH) - 1:0] data_aux_i;
	output wire [(N_CH0 + N_CH1) - 1:0] data_gnt_o;
	output wire [(N_CH0 + N_CH1) - 1:0] data_r_valid_o;
	output wire [((N_CH0 + N_CH1) * DATA_WIDTH) - 1:0] data_r_rdata_o;
	output wire [(N_CH0 + N_CH1) - 1:0] data_r_opc_o;
	output wire [((N_CH0 + N_CH1) * AUX_WIDTH) - 1:0] data_r_aux_o;
	output wire [N_SLAVE - 1:0] data_req_o;
	output wire [(N_SLAVE * ADDR_WIDTH) - 1:0] data_add_o;
	output wire [N_SLAVE - 1:0] data_wen_o;
	output wire [(N_SLAVE * DATA_WIDTH) - 1:0] data_wdata_o;
	output wire [(N_SLAVE * BE_WIDTH) - 1:0] data_be_o;
	output wire [(N_SLAVE * ID_WIDTH) - 1:0] data_ID_o;
	output wire [(N_SLAVE * AUX_WIDTH) - 1:0] data_aux_o;
	input wire [N_SLAVE - 1:0] data_gnt_i;
	input wire [(N_SLAVE * DATA_WIDTH) - 1:0] data_r_rdata_i;
	input wire [N_SLAVE - 1:0] data_r_valid_i;
	input wire [(N_SLAVE * ID_WIDTH) - 1:0] data_r_ID_i;
	input wire [N_SLAVE - 1:0] data_r_opc_i;
	input wire [(N_SLAVE * AUX_WIDTH) - 1:0] data_r_aux_i;
	input wire clk;
	input wire rst_n;
	input wire [(N_SLAVE * ADDR_WIDTH) - 1:0] START_ADDR;
	input wire [(N_SLAVE * ADDR_WIDTH) - 1:0] END_ADDR;
	wire [((N_CH0 + N_CH1) * ID_WIDTH) - 1:0] data_ID;
	wire [(N_CH0 + N_CH1) - 1:0] data_gnt_from_MEM [N_SLAVE - 1:0];
	wire [N_SLAVE - 1:0] data_req_from_MASTER [(N_CH0 + N_CH1) - 1:0];
	wire [(N_CH0 + N_CH1) - 1:0] data_r_valid_from_MEM [N_SLAVE - 1:0];
	wire [N_SLAVE - 1:0] data_r_valid_to_MASTER [(N_CH0 + N_CH1) - 1:0];
	wire [(N_CH0 + N_CH1) - 1:0] data_req_to_MEM [N_SLAVE - 1:0];
	wire [N_SLAVE - 1:0] data_gnt_to_MASTER [(N_CH0 + N_CH1) - 1:0];
	reg [((N_CH0 + N_CH1) * N_SLAVE) - 1:0] destination_OH;
	initial begin
		$display("START_ADDR[0] = 0x%8h; END_ADDR[0] = 0X%8h", START_ADDR[0+:ADDR_WIDTH], END_ADDR[0+:ADDR_WIDTH]);
		$display("START_ADDR[1] = 0x%8h; END_ADDR[1] = 0X%8h", START_ADDR[ADDR_WIDTH+:ADDR_WIDTH], END_ADDR[ADDR_WIDTH+:ADDR_WIDTH]);
	end
	genvar j;
	genvar k;
	generate
		for (k = 0; k < (N_CH0 + N_CH1); k = k + 1) begin : genblk1
			always @(*) begin
				destination_OH[k * N_SLAVE+:N_SLAVE] = 1'sb0;
				begin : sv2v_autoblock_1
					reg [31:0] x;
					for (x = 0; x < N_SLAVE; x = x + 1)
						if ((data_add_i[k * ADDR_WIDTH+:ADDR_WIDTH] >= START_ADDR[x * ADDR_WIDTH+:ADDR_WIDTH]) && (data_add_i[k * ADDR_WIDTH+:ADDR_WIDTH] < END_ADDR[x * ADDR_WIDTH+:ADDR_WIDTH]))
							destination_OH[(k * N_SLAVE) + x] = 1'b1;
				end
			end
			for (j = 0; j < N_SLAVE; j = j + 1) begin : genblk1
				assign data_r_valid_to_MASTER[k][j] = data_r_valid_from_MEM[j][k];
				assign data_req_to_MEM[j][k] = data_req_from_MASTER[k][j];
				assign data_gnt_to_MASTER[k][j] = data_gnt_from_MEM[j][k];
			end
		end
		for (j = 0; j < N_SLAVE; j = j + 1) begin : RequestBlock
			if (N_CH1 != 0) begin : CH0_CH1
				RequestBlock2CH_BRIDGE #(
					.ADDR_WIDTH(ADDR_WIDTH),
					.N_CH0(N_CH0),
					.N_CH1(N_CH1),
					.ID_WIDTH(ID_WIDTH),
					.DATA_WIDTH(DATA_WIDTH),
					.AUX_WIDTH(AUX_WIDTH),
					.BE_WIDTH(BE_WIDTH)
				) i_RequestBlock2CH_BRIDGE(
					.data_req_CH0_i(data_req_to_MEM[j][N_CH0 - 1:0]),
					.data_add_CH0_i(data_add_i[ADDR_WIDTH * ((N_CH0 - 1) - (N_CH0 - 1))+:ADDR_WIDTH * N_CH0]),
					.data_wen_CH0_i(data_wen_i[N_CH0 - 1:0]),
					.data_wdata_CH0_i(data_wdata_i[DATA_WIDTH * ((N_CH0 - 1) - (N_CH0 - 1))+:DATA_WIDTH * N_CH0]),
					.data_be_CH0_i(data_be_i[BE_WIDTH * ((N_CH0 - 1) - (N_CH0 - 1))+:BE_WIDTH * N_CH0]),
					.data_ID_CH0_i(data_ID[ID_WIDTH * ((N_CH0 - 1) - (N_CH0 - 1))+:ID_WIDTH * N_CH0]),
					.data_aux_CH0_i(data_aux_i[AUX_WIDTH * ((N_CH0 - 1) - (N_CH0 - 1))+:AUX_WIDTH * N_CH0]),
					.data_gnt_CH0_o(data_gnt_from_MEM[j][N_CH0 - 1:0]),
					.data_req_CH1_i(data_req_to_MEM[j][(N_CH1 + N_CH0) - 1:N_CH0]),
					.data_add_CH1_i(data_add_i[ADDR_WIDTH * ((((N_CH1 + N_CH0) - 1) >= N_CH0 ? (N_CH1 + N_CH0) - 1 : (((N_CH1 + N_CH0) - 1) + (((N_CH1 + N_CH0) - 1) >= N_CH0 ? (((N_CH1 + N_CH0) - 1) - N_CH0) + 1 : (N_CH0 - ((N_CH1 + N_CH0) - 1)) + 1)) - 1) - ((((N_CH1 + N_CH0) - 1) >= N_CH0 ? (((N_CH1 + N_CH0) - 1) - N_CH0) + 1 : (N_CH0 - ((N_CH1 + N_CH0) - 1)) + 1) - 1))+:ADDR_WIDTH * (((N_CH1 + N_CH0) - 1) >= N_CH0 ? (((N_CH1 + N_CH0) - 1) - N_CH0) + 1 : (N_CH0 - ((N_CH1 + N_CH0) - 1)) + 1)]),
					.data_wen_CH1_i(data_wen_i[(N_CH1 + N_CH0) - 1:N_CH0]),
					.data_wdata_CH1_i(data_wdata_i[DATA_WIDTH * ((((N_CH1 + N_CH0) - 1) >= N_CH0 ? (N_CH1 + N_CH0) - 1 : (((N_CH1 + N_CH0) - 1) + (((N_CH1 + N_CH0) - 1) >= N_CH0 ? (((N_CH1 + N_CH0) - 1) - N_CH0) + 1 : (N_CH0 - ((N_CH1 + N_CH0) - 1)) + 1)) - 1) - ((((N_CH1 + N_CH0) - 1) >= N_CH0 ? (((N_CH1 + N_CH0) - 1) - N_CH0) + 1 : (N_CH0 - ((N_CH1 + N_CH0) - 1)) + 1) - 1))+:DATA_WIDTH * (((N_CH1 + N_CH0) - 1) >= N_CH0 ? (((N_CH1 + N_CH0) - 1) - N_CH0) + 1 : (N_CH0 - ((N_CH1 + N_CH0) - 1)) + 1)]),
					.data_be_CH1_i(data_be_i[BE_WIDTH * ((((N_CH1 + N_CH0) - 1) >= N_CH0 ? (N_CH1 + N_CH0) - 1 : (((N_CH1 + N_CH0) - 1) + (((N_CH1 + N_CH0) - 1) >= N_CH0 ? (((N_CH1 + N_CH0) - 1) - N_CH0) + 1 : (N_CH0 - ((N_CH1 + N_CH0) - 1)) + 1)) - 1) - ((((N_CH1 + N_CH0) - 1) >= N_CH0 ? (((N_CH1 + N_CH0) - 1) - N_CH0) + 1 : (N_CH0 - ((N_CH1 + N_CH0) - 1)) + 1) - 1))+:BE_WIDTH * (((N_CH1 + N_CH0) - 1) >= N_CH0 ? (((N_CH1 + N_CH0) - 1) - N_CH0) + 1 : (N_CH0 - ((N_CH1 + N_CH0) - 1)) + 1)]),
					.data_ID_CH1_i(data_ID[ID_WIDTH * ((((N_CH1 + N_CH0) - 1) >= N_CH0 ? (N_CH1 + N_CH0) - 1 : (((N_CH1 + N_CH0) - 1) + (((N_CH1 + N_CH0) - 1) >= N_CH0 ? (((N_CH1 + N_CH0) - 1) - N_CH0) + 1 : (N_CH0 - ((N_CH1 + N_CH0) - 1)) + 1)) - 1) - ((((N_CH1 + N_CH0) - 1) >= N_CH0 ? (((N_CH1 + N_CH0) - 1) - N_CH0) + 1 : (N_CH0 - ((N_CH1 + N_CH0) - 1)) + 1) - 1))+:ID_WIDTH * (((N_CH1 + N_CH0) - 1) >= N_CH0 ? (((N_CH1 + N_CH0) - 1) - N_CH0) + 1 : (N_CH0 - ((N_CH1 + N_CH0) - 1)) + 1)]),
					.data_aux_CH1_i(data_aux_i[AUX_WIDTH * ((((N_CH1 + N_CH0) - 1) >= N_CH0 ? (N_CH1 + N_CH0) - 1 : (((N_CH1 + N_CH0) - 1) + (((N_CH1 + N_CH0) - 1) >= N_CH0 ? (((N_CH1 + N_CH0) - 1) - N_CH0) + 1 : (N_CH0 - ((N_CH1 + N_CH0) - 1)) + 1)) - 1) - ((((N_CH1 + N_CH0) - 1) >= N_CH0 ? (((N_CH1 + N_CH0) - 1) - N_CH0) + 1 : (N_CH0 - ((N_CH1 + N_CH0) - 1)) + 1) - 1))+:AUX_WIDTH * (((N_CH1 + N_CH0) - 1) >= N_CH0 ? (((N_CH1 + N_CH0) - 1) - N_CH0) + 1 : (N_CH0 - ((N_CH1 + N_CH0) - 1)) + 1)]),
					.data_gnt_CH1_o(data_gnt_from_MEM[j][(N_CH1 + N_CH0) - 1:N_CH0]),
					.data_req_o(data_req_o[j]),
					.data_add_o(data_add_o[j * ADDR_WIDTH+:ADDR_WIDTH]),
					.data_wen_o(data_wen_o[j]),
					.data_wdata_o(data_wdata_o[j * DATA_WIDTH+:DATA_WIDTH]),
					.data_be_o(data_be_o[j * BE_WIDTH+:BE_WIDTH]),
					.data_ID_o(data_ID_o[j * ID_WIDTH+:ID_WIDTH]),
					.data_aux_o(data_aux_o[j * AUX_WIDTH+:AUX_WIDTH]),
					.data_gnt_i(data_gnt_i[j]),
					.data_r_valid_i(data_r_valid_i[j]),
					.data_r_ID_i(data_r_ID_i[j * ID_WIDTH+:ID_WIDTH]),
					.data_r_valid_CH0_o(data_r_valid_from_MEM[j][N_CH0 - 1:0]),
					.data_r_valid_CH1_o(data_r_valid_from_MEM[j][(N_CH0 + N_CH1) - 1:N_CH0]),
					.clk(clk),
					.rst_n(rst_n)
				);
			end
			else begin : CH0_ONLY
				RequestBlock1CH_BRIDGE #(
					.ADDR_WIDTH(ADDR_WIDTH),
					.N_CH0(N_CH0),
					.ID_WIDTH(ID_WIDTH),
					.DATA_WIDTH(DATA_WIDTH),
					.AUX_WIDTH(AUX_WIDTH),
					.BE_WIDTH(BE_WIDTH)
				) i_RequestBlock1CH_BRIDGE(
					.data_req_CH0_i(data_req_to_MEM[j]),
					.data_add_CH0_i(data_add_i),
					.data_wen_CH0_i(data_wen_i),
					.data_wdata_CH0_i(data_wdata_i),
					.data_be_CH0_i(data_be_i),
					.data_ID_CH0_i(data_ID),
					.data_aux_CH0_i(data_aux_i),
					.data_gnt_CH0_o(data_gnt_from_MEM[j]),
					.data_req_o(data_req_o[j]),
					.data_add_o(data_add_o[j * ADDR_WIDTH+:ADDR_WIDTH]),
					.data_wen_o(data_wen_o[j]),
					.data_wdata_o(data_wdata_o[j * DATA_WIDTH+:DATA_WIDTH]),
					.data_be_o(data_be_o[j * BE_WIDTH+:BE_WIDTH]),
					.data_ID_o(data_ID_o[j * ID_WIDTH+:ID_WIDTH]),
					.data_aux_o(data_aux_o[j * AUX_WIDTH+:AUX_WIDTH]),
					.data_gnt_i(data_gnt_i[j]),
					.data_r_valid_i(data_r_valid_i[j]),
					.data_r_ID_i(data_r_ID_i[j * ID_WIDTH+:ID_WIDTH]),
					.data_r_valid_CH0_o(data_r_valid_from_MEM[j]),
					.clk(clk),
					.rst_n(rst_n)
				);
			end
		end
		if (N_SLAVE == 1) begin : ResponseBlock_mono
			for (j = 0; j < (N_CH0 + N_CH1); j = j + 1) begin : WIRING
				assign data_r_rdata_o[j * DATA_WIDTH+:DATA_WIDTH] = data_r_rdata_i;
				assign data_r_opc_o[j] = data_r_opc_i;
				assign data_r_valid_o[j] = data_r_valid_to_MASTER[j];
				assign data_ID[j * ID_WIDTH+:ID_WIDTH] = 2 ** j;
				assign data_req_from_MASTER[j] = data_req_i[j];
				assign data_gnt_o[j] = data_gnt_to_MASTER[j];
			end
		end
		else begin : ResponseBlock_multi
			for (j = 0; j < (N_CH0 + N_CH1); j = j + 1) begin : ResponseBlock_PE_Block
				ResponseBlock_BRIDGE #(
					.ID(2 ** j),
					.ID_WIDTH(ID_WIDTH),
					.N_SLAVE(N_SLAVE),
					.AUX_WIDTH(AUX_WIDTH),
					.DATA_WIDTH(DATA_WIDTH)
				) i_ResponseBlock_BRIDGE(
					.data_r_valid_i(data_r_valid_to_MASTER[j]),
					.data_r_rdata_i(data_r_rdata_i),
					.data_r_opc_i(data_r_opc_i),
					.data_r_aux_i(data_r_aux_i),
					.data_r_valid_o(data_r_valid_o[j]),
					.data_r_rdata_o(data_r_rdata_o[j * DATA_WIDTH+:DATA_WIDTH]),
					.data_r_opc_o(data_r_opc_o[j]),
					.data_r_aux_o(data_r_aux_o[j * AUX_WIDTH+:AUX_WIDTH]),
					.data_req_i(data_req_i[j]),
					.destination_i(destination_OH[j * N_SLAVE+:N_SLAVE]),
					.data_gnt_o(data_gnt_o[j]),
					.data_gnt_i(data_gnt_to_MASTER[j]),
					.data_req_o(data_req_from_MASTER[j]),
					.data_ID_o(data_ID[j * ID_WIDTH+:ID_WIDTH])
				);
			end
		end
	endgenerate
endmodule
