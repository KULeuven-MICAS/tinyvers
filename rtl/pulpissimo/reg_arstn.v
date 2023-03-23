module reg_arstn (
	clk,
	arst_n,
	din,
	dout,
	wen
);
	parameter integer DATA_W = 20;
	parameter integer PRESET_VAL = 'b0;
	input clk;
	input arst_n;
	input [DATA_W - 1:0] din;
	output wire [DATA_W - 1:0] dout;
	input wen;
	reg [DATA_W - 1:0] r;
	reg [DATA_W - 1:0] nxt;
	always @(posedge clk or negedge arst_n)
		if (arst_n == 0)
			r <= PRESET_VAL;
		else if (wen)
			r <= nxt;
	always @(*) nxt = din;
	assign dout = r;
endmodule
