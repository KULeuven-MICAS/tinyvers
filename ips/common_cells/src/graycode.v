module binary_to_gray (
	A,
	Z
);
	parameter signed [31:0] N = -1;
	input wire [N - 1:0] A;
	output wire [N - 1:0] Z;
	assign Z = A ^ (A >> 1);
endmodule
module gray_to_binary (
	A,
	Z
);
	parameter signed [31:0] N = -1;
	input wire [N - 1:0] A;
	output wire [N - 1:0] Z;
	genvar i;
	generate
		for (i = 0; i < N; i = i + 1) begin : genblk1
			assign Z[i] = ^A[N - 1:i];
		end
	endgenerate
endmodule
