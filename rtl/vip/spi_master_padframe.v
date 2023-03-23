module generic_pad (
	in_i,
	out_o,
	pad,
	en_i
);
	input wire in_i;
	output wire out_o;
	inout wire pad;
	input wire en_i;
	assign out_o = pad;
	assign pad = (en_i ? in_i : 1'bz);
endmodule
module spi_master_padframe (
	padmode_spi_master,
	spi_master_csn,
	spi_master_sck,
	spi_master_sdi0,
	spi_master_sdi1,
	spi_master_sdi2,
	spi_master_sdi3,
	spi_master_sdo0,
	spi_master_sdo1,
	spi_master_sdo2,
	spi_master_sdo3,
	MSPI_SIO0_PAD,
	MSPI_SIO1_PAD,
	MSPI_SIO2_PAD,
	MSPI_SIO3_PAD,
	MSPI_CSN_PAD,
	MSPI_SCK_PAD
);
	input wire [1:0] padmode_spi_master;
	input wire spi_master_csn;
	input wire spi_master_sck;
	output reg spi_master_sdi0;
	output reg spi_master_sdi1;
	output reg spi_master_sdi2;
	output reg spi_master_sdi3;
	input wire spi_master_sdo0;
	input wire spi_master_sdo1;
	input wire spi_master_sdo2;
	input wire spi_master_sdo3;
	inout wire MSPI_SIO0_PAD;
	inout wire MSPI_SIO1_PAD;
	inout wire MSPI_SIO2_PAD;
	inout wire MSPI_SIO3_PAD;
	inout wire MSPI_CSN_PAD;
	inout wire MSPI_SCK_PAD;
	reg master_dio0_en;
	reg master_dio1_en;
	reg master_dio2_en;
	reg master_dio3_en;
	reg master_output;
	wire master_cs_in;
	wire master_sck_in;
	wire master_dio0_in;
	wire master_dio1_in;
	wire master_dio2_in;
	wire master_dio3_in;
	reg master_cs_out;
	reg master_sck_out;
	reg master_dio0_out;
	reg master_dio1_out;
	reg master_dio2_out;
	reg master_dio3_out;
	wire always_input;
	wire always_output;
	generic_pad I_spi_master_sdio0_IO(
		.out_o(master_dio0_in),
		.in_i(master_dio0_out),
		.en_i(master_dio0_en),
		.pad(MSPI_SIO0_PAD)
	);
	generic_pad I_spi_master_sdio1_IO(
		.out_o(master_dio1_in),
		.in_i(master_dio1_out),
		.en_i(master_dio1_en),
		.pad(MSPI_SIO1_PAD)
	);
	generic_pad I_spi_master_sdio2_IO(
		.out_o(master_dio2_in),
		.in_i(master_dio2_out),
		.en_i(master_dio2_en),
		.pad(MSPI_SIO2_PAD)
	);
	generic_pad I_spi_master_sdio3_IO(
		.out_o(master_dio3_in),
		.in_i(master_dio3_out),
		.en_i(master_dio3_en),
		.pad(MSPI_SIO3_PAD)
	);
	generic_pad I_spi_master_csn_IO(
		.out_o(master_cs_in),
		.in_i(master_cs_out),
		.en_i(master_output),
		.pad(MSPI_CSN_PAD)
	);
	generic_pad I_spi_master_sck_IO(
		.out_o(master_sck_in),
		.in_i(master_sck_out),
		.en_i(master_output),
		.pad(MSPI_SCK_PAD)
	);
	assign always_input = 1'b0;
	assign always_output = ~always_input;
	always @(*) begin
		master_cs_out = spi_master_csn;
		master_sck_out = spi_master_sck;
		case (padmode_spi_master)
			2'b00: begin
				master_dio0_en = always_output;
				master_dio1_en = always_input;
				master_dio2_en = always_input;
				master_dio3_en = always_input;
				master_output = always_output;
				spi_master_sdi0 = master_dio1_in;
				spi_master_sdi1 = 1'b0;
				spi_master_sdi2 = 1'b0;
				spi_master_sdi3 = 1'b0;
				master_dio0_out = spi_master_sdo0;
				master_dio1_out = 1'b0;
				master_dio2_out = 1'b0;
				master_dio3_out = 1'b0;
			end
			2'b01: begin
				master_dio0_en = always_output;
				master_dio1_en = always_output;
				master_dio2_en = always_output;
				master_dio3_en = always_output;
				master_output = always_output;
				spi_master_sdi0 = 1'b0;
				spi_master_sdi1 = 1'b0;
				spi_master_sdi2 = 1'b0;
				spi_master_sdi3 = 1'b0;
				master_dio0_out = spi_master_sdo0;
				master_dio1_out = spi_master_sdo1;
				master_dio2_out = spi_master_sdo2;
				master_dio3_out = spi_master_sdo3;
			end
			2'b10: begin
				master_dio0_en = always_input;
				master_dio1_en = always_input;
				master_dio2_en = always_input;
				master_dio3_en = always_input;
				master_output = always_output;
				spi_master_sdi0 = master_dio0_in;
				spi_master_sdi1 = master_dio1_in;
				spi_master_sdi2 = master_dio2_in;
				spi_master_sdi3 = master_dio3_in;
				master_dio0_out = 1'b0;
				master_dio1_out = 1'b0;
				master_dio2_out = 1'b0;
				master_dio3_out = 1'b0;
			end
			default: begin
				master_dio0_en = always_input;
				master_dio1_en = always_input;
				master_dio2_en = always_input;
				master_dio3_en = always_input;
				master_output = always_output;
				spi_master_sdi0 = 1'b0;
				spi_master_sdi1 = 1'b0;
				spi_master_sdi2 = 1'b0;
				spi_master_sdi3 = 1'b0;
				master_dio0_out = 1'b0;
				master_dio1_out = 1'b0;
				master_dio2_out = 1'b0;
				master_dio3_out = 1'b0;
			end
		endcase
	end
endmodule
