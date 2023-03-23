module scm_512x32 (
	CLK,
	RSTN,
	CEN,
	WEN,
	BE,
	A,
	D,
	Q
);
	input wire CLK;
	input wire RSTN;
	input wire CEN;
	input wire WEN;
	input wire [3:0] BE;
	input wire [8:0] A;
	input wire [31:0] D;
	output wire [31:0] Q;
	wire read_en;
	wire write_en;
	assign read_en = ~CEN & WEN;
	assign write_en = ~CEN & ~WEN;
	register_file_1r_1w_be #(
		.ADDR_WIDTH(9),
		.DATA_WIDTH(32),
		.NUM_BYTE(4)
	) scm_i(
		.clk(CLK),
		.ReadEnable(read_en),
		.ReadAddr(A),
		.ReadData(Q),
		.WriteEnable(write_en),
		.WriteAddr(A),
		.WriteData(D),
		.WriteBE(BE)
	);
endmodule
