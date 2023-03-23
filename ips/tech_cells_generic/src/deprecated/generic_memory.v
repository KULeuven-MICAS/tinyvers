module generic_memory (
	CLK,
	INITN,
	CEN,
	A,
	WEN,
	D,
	BEN,
	Q
);
	parameter ADDR_WIDTH = 12;
	parameter DATA_WIDTH = 32;
	parameter BE_WIDTH = DATA_WIDTH / 8;
	input wire CLK;
	input wire INITN;
	input wire CEN;
	input wire [ADDR_WIDTH - 1:0] A;
	input wire WEN;
	input wire [DATA_WIDTH - 1:0] D;
	input wire [BE_WIDTH - 1:0] BEN;
	output reg [DATA_WIDTH - 1:0] Q;
	localparam NUM_WORDS = 2 ** ADDR_WIDTH;
	reg [DATA_WIDTH - 1:0] MEM [NUM_WORDS - 1:0];
	wire [DATA_WIDTH - 1:0] M;
	genvar i;
	genvar j;
	generate
		for (i = 0; i < BE_WIDTH; i = i + 1) begin : genblk1
			for (j = 0; j < 8; j = j + 1) begin : genblk1
				assign M[(i * 8) + j] = BEN[i];
			end
		end
		for (i = 0; i < DATA_WIDTH; i = i + 1) begin : genblk2
			always @(posedge CLK)
				if (INITN == 1'b1)
					if (CEN == 1'b0)
						if (WEN == 1'b0) begin
							if (M[i] == 1'b0)
								MEM[A][i] <= D[i];
						end
						else if (WEN == 1'b1)
							Q[i] <= MEM[A][i];
		end
	endgenerate
endmodule
