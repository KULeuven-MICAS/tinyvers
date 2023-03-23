module pad_functional_h_pd (
	OEN,
	I,
	io_pwr_ok,
	pwr_ok,
	O,
	PEN,
	PAD
);
	input wire OEN;
	input wire I;
	inout wire io_pwr_ok;
	inout wire pwr_ok;
	output wire O;
	input wire PEN;
	inout wire PAD;
	LP_INLINE_IO_H pad_i(
		.DATA(I),
		.Y(O),
		.PAD(PAD),
		.IOPWROK(),
		.PWROK(),
		.NDIN(1'b0),
		.RXEN(OEN),
		.DRV(2'b11),
		.TRIEN(OEN),
		.PUEN(1'b0),
		.PDEN(1'b1),
		.RETC()
	);
endmodule
module pad_functional_v_pd (
	OEN,
	I,
	io_pwr_ok,
	pwr_ok,
	O,
	PEN,
	PAD
);
	input wire OEN;
	input wire I;
	inout wire io_pwr_ok;
	inout wire pwr_ok;
	output wire O;
	input wire PEN;
	inout wire PAD;
	LP_INLINE_IO_H pad_i(
		.DATA(I),
		.Y(O),
		.PAD(PAD),
		.IOPWROK(),
		.PWROK(),
		.NDIN(1'b0),
		.RXEN(OEN),
		.DRV(2'b11),
		.TRIEN(OEN),
		.PUEN(1'b0),
		.PDEN(1'b1),
		.RETC()
	);
endmodule
module pad_functional_h_pu (
	OEN,
	I,
	io_pwr_ok,
	pwr_ok,
	O,
	PEN,
	PAD
);
	input wire OEN;
	input wire I;
	inout wire io_pwr_ok;
	inout wire pwr_ok;
	output wire O;
	input wire PEN;
	inout wire PAD;
	LP_INLINE_IO_H pad_i(
		.DATA(I),
		.Y(O),
		.PAD(PAD),
		.IOPWROK(),
		.PWROK(),
		.NDIN(1'b0),
		.RXEN(OEN),
		.DRV(2'b11),
		.TRIEN(OEN),
		.PUEN(1'b1),
		.PDEN(1'b0),
		.RETC()
	);
endmodule
module pad_functional_v_pu (
	OEN,
	I,
	io_pwr_ok,
	pwr_ok,
	O,
	PEN,
	PAD
);
	input wire OEN;
	input wire I;
	inout wire io_pwr_ok;
	input wire pwr_ok;
	output wire O;
	input wire PEN;
	inout wire PAD;
	LP_INLINE_IO_H pad_i(
		.DATA(I),
		.Y(O),
		.PAD(PAD),
		.IOPWROK(),
		.PWROK(),
		.NDIN(1'b0),
		.RXEN(OEN),
		.DRV(2'b11),
		.TRIEN(OEN),
		.PUEN(1'b1),
		.PDEN(1'b0),
		.RETC()
	);
endmodule
