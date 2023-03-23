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
	localparam NUM_WORDS = 2 ** ADDR_WIDTH;
	reg [DATA_WIDTH - 1:0] MEM [NUM_WORDS - 1:0];
	reg [ADDR_WIDTH - 1:0] A_Q;
	initial $readmemb(FILE_NAME, MEM);
	always @(posedge CLK)
		if (CEN == 1'b0)
			A_Q <= A;
	assign Q = MEM[A_Q];
endmodule
