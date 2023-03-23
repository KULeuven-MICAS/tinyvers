module pulpemu_i2c (
	mode_fmc_zynqn_i,
	pulp_i2c_scl_i,
	pulp_i2c_scl_o,
	pulp_i2c_scl_oe,
	pulp_i2c_sda_i,
	pulp_i2c_sda_o,
	pulp_i2c_sda_oe,
	fmc_i2c_scl,
	fmc_i2c_sda
);
	input wire mode_fmc_zynqn_i;
	output wire pulp_i2c_scl_i;
	input wire pulp_i2c_scl_o;
	input wire pulp_i2c_scl_oe;
	output wire pulp_i2c_sda_i;
	input wire pulp_i2c_sda_o;
	input wire pulp_i2c_sda_oe;
	inout wire fmc_i2c_scl;
	inout wire fmc_i2c_sda;
	IOBUF iobuf_i2c_scl_i(
		.T(~pulp_i2c_scl_oe),
		.I(pulp_i2c_scl_o),
		.O(pulp_i2c_scl_i),
		.IO(fmc_i2c_scl)
	);
	IOBUF iobuf_i2c_sda_i(
		.T(~pulp_i2c_sda_oe),
		.I(pulp_i2c_sda_o),
		.O(pulp_i2c_sda_i),
		.IO(fmc_i2c_sda)
	);
endmodule
