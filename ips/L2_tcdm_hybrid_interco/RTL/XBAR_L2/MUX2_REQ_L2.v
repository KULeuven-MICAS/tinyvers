module MUX2_REQ_L2 (
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
	clk,
	rst_n
);
	parameter ID_WIDTH = 20;
	parameter ADDR_WIDTH = 32;
	parameter DATA_WIDTH = 64;
	parameter BE_WIDTH = DATA_WIDTH / 8;
	input wire data_req_CH0_i;
	input wire [ADDR_WIDTH - 1:0] data_add_CH0_i;
	input wire data_wen_CH0_i;
	input wire [DATA_WIDTH - 1:0] data_wdata_CH0_i;
	input wire [BE_WIDTH - 1:0] data_be_CH0_i;
	input wire [ID_WIDTH - 1:0] data_ID_CH0_i;
	output wire data_gnt_CH0_o;
	input wire data_req_CH1_i;
	input wire [ADDR_WIDTH - 1:0] data_add_CH1_i;
	input wire data_wen_CH1_i;
	input wire [DATA_WIDTH - 1:0] data_wdata_CH1_i;
	input wire [BE_WIDTH - 1:0] data_be_CH1_i;
	input wire [ID_WIDTH - 1:0] data_ID_CH1_i;
	output wire data_gnt_CH1_o;
	output wire data_req_o;
	output reg [ADDR_WIDTH - 1:0] data_add_o;
	output reg data_wen_o;
	output reg [DATA_WIDTH - 1:0] data_wdata_o;
	output reg [BE_WIDTH - 1:0] data_be_o;
	output reg [ID_WIDTH - 1:0] data_ID_o;
	input wire data_gnt_i;
	input wire clk;
	input wire rst_n;
	wire SEL;
	reg RR_FLAG;
	assign data_req_o = data_req_CH0_i | data_req_CH1_i;
	assign SEL = ~data_req_CH0_i | (RR_FLAG & data_req_CH1_i);
	assign data_gnt_CH0_o = ((data_req_CH0_i & ~data_req_CH1_i) | (data_req_CH0_i & ~RR_FLAG)) & data_gnt_i;
	assign data_gnt_CH1_o = ((~data_req_CH0_i & data_req_CH1_i) | (data_req_CH1_i & RR_FLAG)) & data_gnt_i;
	always @(posedge clk or negedge rst_n)
		if (rst_n == 1'b0)
			RR_FLAG <= 1'b0;
		else if ((data_req_o == 1'b1) && (data_gnt_i == 1'b1))
			RR_FLAG <= ~RR_FLAG;
	always @(*) begin : MUX2_REQ_COMB
		case (SEL)
			1'b0: begin
				data_add_o = data_add_CH0_i;
				data_wen_o = data_wen_CH0_i;
				data_wdata_o = data_wdata_CH0_i;
				data_be_o = data_be_CH0_i;
				data_ID_o = data_ID_CH0_i;
			end
			1'b1: begin
				data_add_o = data_add_CH1_i;
				data_wen_o = data_wen_CH1_i;
				data_wdata_o = data_wdata_CH1_i;
				data_be_o = data_be_CH1_i;
				data_ID_o = data_ID_CH1_i;
			end
		endcase
	end
endmodule
