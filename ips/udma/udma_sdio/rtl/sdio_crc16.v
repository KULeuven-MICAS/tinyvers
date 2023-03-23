module sdio_crc16 (
	clk_i,
	rstn_i,
	crc16_o,
	crc16_serial_o,
	data_i,
	shift_i,
	clr_i,
	sample_i
);
	input wire clk_i;
	input wire rstn_i;
	output wire [15:0] crc16_o;
	output wire crc16_serial_o;
	input wire data_i;
	input wire shift_i;
	input wire clr_i;
	input wire sample_i;
	reg [15:0] r_crc;
	reg [15:0] s_crc;
	assign crc16_o = r_crc;
	assign crc16_serial_o = r_crc[15];
	always @(*) begin
		s_crc = r_crc;
		if (sample_i) begin
			s_crc[0] = data_i ^ r_crc[15];
			s_crc[1] = r_crc[0];
			s_crc[2] = r_crc[1];
			s_crc[3] = r_crc[2];
			s_crc[4] = r_crc[3];
			s_crc[5] = r_crc[4] ^ s_crc[0];
			s_crc[6] = r_crc[5];
			s_crc[7] = r_crc[6];
			s_crc[8] = r_crc[7];
			s_crc[9] = r_crc[8];
			s_crc[10] = r_crc[9];
			s_crc[11] = r_crc[10];
			s_crc[12] = r_crc[11] ^ s_crc[0];
			s_crc[13] = r_crc[12];
			s_crc[14] = r_crc[13];
			s_crc[15] = r_crc[14];
		end
		else if (clr_i)
			s_crc = 16'h0000;
		else if (shift_i)
			s_crc = {r_crc[14:0], 1'b0};
	end
	always @(posedge clk_i or negedge rstn_i) begin : ff_addr
		if (~rstn_i)
			r_crc <= 1'sb0;
		else if ((sample_i || clr_i) || shift_i)
			r_crc <= s_crc;
	end
endmodule
