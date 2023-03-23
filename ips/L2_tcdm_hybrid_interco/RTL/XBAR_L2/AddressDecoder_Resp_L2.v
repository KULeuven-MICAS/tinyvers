module AddressDecoder_Resp_L2 (
	data_r_valid_i,
	data_r_ID_i,
	data_r_valid_o
);
	parameter N_MASTER = 8;
	parameter ID_WIDTH = N_MASTER;
	input wire data_r_valid_i;
	input wire [ID_WIDTH - 1:0] data_r_ID_i;
	output wire [N_MASTER - 1:0] data_r_valid_o;
	assign data_r_valid_o = {ID_WIDTH {data_r_valid_i}} & data_r_ID_i;
endmodule
