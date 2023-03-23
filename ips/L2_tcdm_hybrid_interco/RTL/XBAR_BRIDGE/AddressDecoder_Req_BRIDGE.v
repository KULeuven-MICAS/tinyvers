module AddressDecoder_Req_BRIDGE (
	data_req_i,
	destination_i,
	data_gnt_o,
	data_gnt_i,
	data_req_o,
	data_ID_o
);
	parameter ID_WIDTH = 17;
	parameter ID = 1;
	parameter N_SLAVE = 16;
	parameter ADDR_WIDTH = 32;
	input wire data_req_i;
	input wire [N_SLAVE - 1:0] destination_i;
	output reg data_gnt_o;
	input wire [N_SLAVE - 1:0] data_gnt_i;
	output reg [N_SLAVE - 1:0] data_req_o;
	output wire [ID_WIDTH - 1:0] data_ID_o;
	assign data_ID_o = ID;
	always @(*) begin : Combinational_ADDR_DEC_REQ
		data_req_o = {N_SLAVE {data_req_i}} & destination_i;
		data_gnt_o = |(data_gnt_i & destination_i) & data_req_i;
	end
endmodule
