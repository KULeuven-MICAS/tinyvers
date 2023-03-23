module FanInPrimitive_Req_BRIDGE (
	RR_FLAG,
	data_wdata0_i,
	data_wdata1_i,
	data_add0_i,
	data_add1_i,
	data_req0_i,
	data_req1_i,
	data_wen0_i,
	data_wen1_i,
	data_be0_i,
	data_be1_i,
	data_ID0_i,
	data_ID1_i,
	data_aux0_i,
	data_aux1_i,
	data_gnt0_o,
	data_gnt1_o,
	data_wdata_o,
	data_add_o,
	data_req_o,
	data_ID_o,
	data_wen_o,
	data_be_o,
	data_aux_o,
	data_gnt_i
);
	parameter ADDR_WIDTH = 32;
	parameter ID_WIDTH = 16;
	parameter DATA_WIDTH = 32;
	parameter AUX_WIDTH = 32;
	parameter BE_WIDTH = DATA_WIDTH / 8;
	input wire RR_FLAG;
	input wire [DATA_WIDTH - 1:0] data_wdata0_i;
	input wire [DATA_WIDTH - 1:0] data_wdata1_i;
	input wire [ADDR_WIDTH - 1:0] data_add0_i;
	input wire [ADDR_WIDTH - 1:0] data_add1_i;
	input wire data_req0_i;
	input wire data_req1_i;
	input wire data_wen0_i;
	input wire data_wen1_i;
	input wire [BE_WIDTH - 1:0] data_be0_i;
	input wire [BE_WIDTH - 1:0] data_be1_i;
	input wire [ID_WIDTH - 1:0] data_ID0_i;
	input wire [ID_WIDTH - 1:0] data_ID1_i;
	input wire [AUX_WIDTH - 1:0] data_aux0_i;
	input wire [AUX_WIDTH - 1:0] data_aux1_i;
	output wire data_gnt0_o;
	output wire data_gnt1_o;
	output reg [DATA_WIDTH - 1:0] data_wdata_o;
	output reg [ADDR_WIDTH - 1:0] data_add_o;
	output wire data_req_o;
	output reg [ID_WIDTH - 1:0] data_ID_o;
	output reg data_wen_o;
	output reg [BE_WIDTH - 1:0] data_be_o;
	output reg [AUX_WIDTH - 1:0] data_aux_o;
	input wire data_gnt_i;
	wire SEL;
	assign data_req_o = data_req0_i | data_req1_i;
	assign SEL = ~data_req0_i | (RR_FLAG & data_req1_i);
	assign data_gnt0_o = ((data_req0_i & ~data_req1_i) | (data_req0_i & ~RR_FLAG)) & data_gnt_i;
	assign data_gnt1_o = ((~data_req0_i & data_req1_i) | (data_req1_i & RR_FLAG)) & data_gnt_i;
	always @(*) begin : FanIn_MUX2
		case (SEL)
			1'b0: begin
				data_wdata_o = data_wdata0_i;
				data_add_o = data_add0_i;
				data_wen_o = data_wen0_i;
				data_ID_o = data_ID0_i;
				data_be_o = data_be0_i;
				data_aux_o = data_aux0_i;
			end
			1'b1: begin
				data_wdata_o = data_wdata1_i;
				data_add_o = data_add1_i;
				data_wen_o = data_wen1_i;
				data_ID_o = data_ID1_i;
				data_be_o = data_be1_i;
				data_aux_o = data_aux1_i;
			end
		endcase
	end
endmodule
