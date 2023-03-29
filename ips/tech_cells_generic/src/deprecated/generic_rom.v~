module generic_rom (
	CLK,
	CEN,
	A,
	Q
);
	parameter ADDR_WIDTH = 11;
	parameter DATA_WIDTH = 32;
	parameter FILE_NAME = "./boot/boot_code.cde";
	input wire CLK;
	input wire CEN;
	input wire [ADDR_WIDTH - 1:0] A;
	output wire [DATA_WIDTH - 1:0] Q;
	MEMROMIU_FUN_wrapper rom_mem_i(
		.CLK(CLK),
		.AS(A[5]),
		.AW(A[10:6]),
		.AC(A[4:0]),
		.CEN(CEN),
		.Q(Q)
	);
endmodule
