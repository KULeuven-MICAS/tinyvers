module FanInPrimitive_Resp_L2 (
	data_r_rdata0_i,
	data_r_rdata1_i,
	data_r_valid0_i,
	data_r_valid1_i,
	data_r_rdata_o,
	data_r_valid_o
);
	parameter DATA_WIDTH = 64;
	input wire [DATA_WIDTH - 1:0] data_r_rdata0_i;
	input wire [DATA_WIDTH - 1:0] data_r_rdata1_i;
	input wire data_r_valid0_i;
	input wire data_r_valid1_i;
	output reg [DATA_WIDTH - 1:0] data_r_rdata_o;
	output wire data_r_valid_o;
	wire SEL;
	assign data_r_valid_o = data_r_valid1_i | data_r_valid0_i;
	assign SEL = data_r_valid1_i;
	always @(*) begin : FanOut_MUX2
		case (SEL)
			1'b0: data_r_rdata_o = data_r_rdata0_i;
			1'b1: data_r_rdata_o = data_r_rdata1_i;
		endcase
	end
endmodule
