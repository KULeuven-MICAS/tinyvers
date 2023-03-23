module pulpemu_gpio (
	mode_fmc_zynqn_i,
	pulp_gpio_out,
	pulp_gpio_in,
	pulp_gpio_dir,
	fmc_gpio0,
	fmc_gpio1,
	fmc_gpio2,
	fmc_gpio3,
	fmc_gpio4,
	fmc_gpio5,
	fmc_gpio6,
	fmc_gpio7
);
	input wire mode_fmc_zynqn_i;
	input wire [31:0] pulp_gpio_out;
	output wire [31:0] pulp_gpio_in;
	input wire [31:0] pulp_gpio_dir;
	inout wire fmc_gpio0;
	inout wire fmc_gpio1;
	inout wire fmc_gpio2;
	inout wire fmc_gpio3;
	inout wire fmc_gpio4;
	inout wire fmc_gpio5;
	inout wire fmc_gpio6;
	inout wire fmc_gpio7;
	IOBUF iobuf_fmc_gpio0_i(
		.T(~pulp_gpio_dir[0]),
		.I(pulp_gpio_out[0]),
		.O(pulp_gpio_in[0]),
		.IO(fmc_gpio0)
	);
	IOBUF iobuf_fmc_gpio1_i(
		.T(~pulp_gpio_dir[1]),
		.I(pulp_gpio_out[1]),
		.O(pulp_gpio_in[1]),
		.IO(fmc_gpio1)
	);
	IOBUF iobuf_fmc_gpio2_i(
		.T(~pulp_gpio_dir[2]),
		.I(pulp_gpio_out[2]),
		.O(pulp_gpio_in[2]),
		.IO(fmc_gpio2)
	);
	IOBUF iobuf_fmc_gpio3_i(
		.T(~pulp_gpio_dir[3]),
		.I(pulp_gpio_out[3]),
		.O(pulp_gpio_in[3]),
		.IO(fmc_gpio3)
	);
	IOBUF iobuf_fmc_gpio4_i(
		.T(~pulp_gpio_dir[4]),
		.I(pulp_gpio_out[4]),
		.O(pulp_gpio_in[4]),
		.IO(fmc_gpio4)
	);
	IOBUF iobuf_fmc_gpio5_i(
		.T(~pulp_gpio_dir[5]),
		.I(pulp_gpio_out[5]),
		.O(pulp_gpio_in[5]),
		.IO(fmc_gpio5)
	);
	IOBUF iobuf_fmc_gpio6_i(
		.T(~pulp_gpio_dir[6]),
		.I(pulp_gpio_out[6]),
		.O(pulp_gpio_in[6]),
		.IO(fmc_gpio6)
	);
	IOBUF iobuf_fmc_gpio7_i(
		.T(~pulp_gpio_dir[7]),
		.I(pulp_gpio_out[7]),
		.O(pulp_gpio_in[7]),
		.IO(fmc_gpio7)
	);
endmodule
