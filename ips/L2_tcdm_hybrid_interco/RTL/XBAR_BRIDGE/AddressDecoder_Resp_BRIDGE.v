module AddressDecoder_Resp_BRIDGE (
	data_r_valid_i,
	data_ID_i,
	data_r_valid_o
);
	parameter ID_WIDTH = 20;
	parameter N_MASTER = 20;
	input wire data_r_valid_i;
	input wire [ID_WIDTH - 1:0] data_ID_i;
	output wire [N_MASTER - 1:0] data_r_valid_o;
	assign data_r_valid_o = {ID_WIDTH {data_r_valid_i}} & data_ID_i;
endmodule
