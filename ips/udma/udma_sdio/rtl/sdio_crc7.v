module sdio_crc7 (
	clk_i,
	rstn_i,
	crc7_o,
	crc7_serial_o,
	data_i,
	shift_i,
	clr_i,
	sample_i
);
	input wire clk_i;
	input wire rstn_i;
	output wire [6:0] crc7_o;
	output wire crc7_serial_o;
	input wire data_i;
	input wire shift_i;
	input wire clr_i;
	input wire sample_i;
	reg [6:0] r_crc;
	reg [6:0] s_crc;
	assign crc7_o = r_crc;
	assign crc7_serial_o = r_crc[6];
	always @(*) begin
		s_crc = r_crc;
		if (sample_i) begin
			s_crc[0] = data_i ^ r_crc[6];
			s_crc[1] = r_crc[0];
			s_crc[2] = r_crc[1];
			s_crc[3] = r_crc[2] ^ s_crc[0];
			s_crc[4] = r_crc[3];
			s_crc[5] = r_crc[4];
			s_crc[6] = r_crc[5];
		end
		else if (clr_i)
			s_crc = 7'h00;
		else if (shift_i)
			s_crc = {r_crc[5:0], 1'b0};
	end
	always @(posedge clk_i or negedge rstn_i) begin : ff_addr
		if (~rstn_i)
			r_crc <= 1'sb0;
		else if ((sample_i || clr_i) || shift_i)
			r_crc <= s_crc;
	end
endmodule
