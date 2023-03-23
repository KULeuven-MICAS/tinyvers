module AddressDecoder_Req_L2 (
	data_req_i,
	routing_addr_i,
	data_gnt_o,
	data_gnt_i,
	data_req_o,
	data_ID_o
);
	parameter ID_WIDTH = 5;
	parameter ID = 1;
	parameter N_SLAVE = 8;
	parameter ROUT_WIDTH = $clog2(N_SLAVE);
	input wire data_req_i;
	input wire [ROUT_WIDTH - 1:0] routing_addr_i;
	output reg data_gnt_o;
	input wire [N_SLAVE - 1:0] data_gnt_i;
	output reg [N_SLAVE - 1:0] data_req_o;
	output wire [ID_WIDTH - 1:0] data_ID_o;
	assign data_ID_o = ID;
	always @(*) begin : Combinational_ADDR_DEC_REQ
		data_req_o = 1'sb0;
		data_req_o[routing_addr_i] = data_req_i;
		data_gnt_o = data_gnt_i[routing_addr_i];
	end
endmodule
