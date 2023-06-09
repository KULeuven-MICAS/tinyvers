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
		.D(D),
		.AS(A[10:9]),
		.AW(A[8:2]),
		.AC(A[1:0]),
		.CEN(CEB),
		.RDWEN(WEB),
		.BW(1'sb1),
		.Q(Q)
        );

endmodule
