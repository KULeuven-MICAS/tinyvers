module FanInPrimitive_Resp_BRIDGE (
	data_r_rdata0_i,
	data_r_rdata1_i,
	data_r_valid0_i,
	data_r_valid1_i,
	data_r_opc0_i,
	data_r_opc1_i,
	data_r_aux0_i,
	data_r_aux1_i,
	data_r_rdata_o,
	data_r_valid_o,
	data_r_opc_o,
	data_r_aux_o
);
	parameter DATA_WIDTH = 32;
	parameter AUX_WIDTH = 6;
	input wire [DATA_WIDTH - 1:0] data_r_rdata0_i;
	input wire [DATA_WIDTH - 1:0] data_r_rdata1_i;
	input wire data_r_valid0_i;
	input wire data_r_valid1_i;
	input wire data_r_opc0_i;
	input wire data_r_opc1_i;
	input wire [AUX_WIDTH - 1:0] data_r_aux0_i;
	input wire [AUX_WIDTH - 1:0] data_r_aux1_i;
	output reg [DATA_WIDTH - 1:0] data_r_rdata_o;
	output wire data_r_valid_o;
	output reg data_r_opc_o;
	output reg [AUX_WIDTH - 1:0] data_r_aux_o;
	wire SEL;
	assign data_r_valid_o = data_r_valid1_i | data_r_valid0_i;
	assign SEL = data_r_valid1_i;
	always @(*) begin : FanOut_MUX2
		case (SEL)
			1'b0: begin
				data_r_rdata_o = data_r_rdata0_i;
				data_r_opc_o = data_r_opc0_i;
				data_r_aux_o = data_r_aux0_i;
			end
			1'b1: begin
				data_r_rdata_o = data_r_rdata1_i;
				data_r_opc_o = data_r_opc1_i;
				data_r_aux_o = data_r_aux1_i;
			end
		endcase
	end
endmodule
