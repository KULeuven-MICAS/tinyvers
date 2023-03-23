module RX_serializer (
	sys_clk,
	rst_n,
	data_rx_rdata_i,
	data_rx_valid_i,
	data_rx_ready_o,
	data_rx_rdata_o,
	data_rx_valid_o,
	data_rx_ready_i
);
	parameter TRANS_SIZE = 16;
	input wire sys_clk;
	input wire rst_n;
	input wire [63:0] data_rx_rdata_i;
	input wire data_rx_valid_i;
	output reg data_rx_ready_o;
	output reg [31:0] data_rx_rdata_o;
	output reg data_rx_valid_o;
	input wire data_rx_ready_i;
	reg NS_SER;
	reg CS_SER;
	always @(posedge sys_clk or negedge rst_n)
		if (~rst_n)
			CS_SER <= 1'd0;
		else
			CS_SER <= NS_SER;
	always @(*) begin : proc_serializer_rdata
		data_rx_ready_o = 1'b0;
		data_rx_valid_o = 0;
		data_rx_rdata_o = data_rx_rdata_i[31:0];
		case (CS_SER)
			1'd0: begin
				data_rx_valid_o = data_rx_valid_i;
				data_rx_ready_o = 1'b0;
				if (data_rx_valid_i & data_rx_ready_i)
					NS_SER = 1'd1;
				else
					NS_SER = 1'd0;
			end
			1'd1: begin
				data_rx_valid_o = 1'b1;
				data_rx_ready_o = data_rx_ready_i;
				data_rx_rdata_o = data_rx_rdata_i[63:32];
				if (data_rx_ready_i)
					NS_SER = 1'd0;
				else
					NS_SER = 1'd1;
			end
		endcase
	end
endmodule
