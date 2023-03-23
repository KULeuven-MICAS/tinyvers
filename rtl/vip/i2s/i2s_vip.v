module i2s_vip (
	A0,
	A1,
	SDA,
	SCL,
	sck_i,
	ws_i,
	data_o,
	sck_o,
	ws_o
);
	parameter I2S_CHAN = 4'h1;
	parameter FILENAME = "i2s_buffer.hex";
	input wire A0;
	input wire A1;
	inout wire SDA;
	input wire SCL;
	input wire sck_i;
	input wire ws_i;
	output wire data_o;
	output wire sck_o;
	output wire ws_o;
	wire s_i2s_rst;
	wire s_pdm_ddr;
	wire s_pdm_en;
	wire s_lsb_first;
	wire s_i2s_mode;
	wire s_i2s_enable;
	wire [1:0] s_transf_size;
	wire s_i2s_snap_enable;
	i2s_vip_channel #(
		.I2S_CHAN(I2S_CHAN),
		.FILENAME(FILENAME)
	) i2s_vip_channel_i(
		.rst(s_i2s_rst),
		.pdm_ddr_i(s_pdm_ddr),
		.pdm_en_i(s_pdm_en),
		.lsb_first_i(s_lsb_first),
		.mode_i(s_i2s_mode),
		.enable_i(s_i2s_enable),
		.transf_size_i(s_transf_size),
		.i2s_snap_enable_i(s_i2s_snap_enable),
		.sck_i(sck_i),
		.ws_i(ws_i),
		.data_o(data_o),
		.sck_o(sck_o),
		.ws_o(ws_o)
	);
	i2c_if i2c_if_i(
		.A0(A0),
		.A1(A1),
		.A2(1'b1),
		.WP(1'b0),
		.SDA(SDA),
		.SCL(SCL),
		.RESET(1'b0),
		.pdm_ddr(s_pdm_ddr),
		.pdm_en(s_pdm_en),
		.lsb_first(s_lsb_first),
		.i2s_rst(s_i2s_rst),
		.i2s_mode(s_i2s_mode),
		.i2s_enable(s_i2s_enable),
		.transf_size(s_transf_size),
		.i2s_snap_enable(s_i2s_snap_enable)
	);
endmodule
