module popcount (
	data_i,
	popcount_o
);
	parameter [31:0] INPUT_WIDTH = 256;
	localparam POPCOUNT_WIDTH = $clog2(INPUT_WIDTH) + 1;
	input wire [INPUT_WIDTH - 1:0] data_i;
	output wire [POPCOUNT_WIDTH - 1:0] popcount_o;
	localparam [31:0] PADDED_WIDTH = 1 << $clog2(INPUT_WIDTH);
	reg [PADDED_WIDTH - 1:0] padded_input;
	wire [POPCOUNT_WIDTH - 2:0] left_child_result;
	wire [POPCOUNT_WIDTH - 2:0] right_child_result;
	always @(*) begin
		padded_input = 1'sb0;
		padded_input[INPUT_WIDTH - 1:0] = data_i;
	end
	generate
		if (INPUT_WIDTH == 2) begin : leaf_node
			assign left_child_result = padded_input[1];
			assign right_child_result = padded_input[0];
		end
		else begin : non_leaf_node
			popcount #(.INPUT_WIDTH(PADDED_WIDTH / 2)) left_child(
				.data_i(padded_input[PADDED_WIDTH - 1:PADDED_WIDTH / 2]),
				.popcount_o(left_child_result)
			);
			popcount #(.INPUT_WIDTH(PADDED_WIDTH / 2)) right_child(
				.data_i(padded_input[(PADDED_WIDTH / 2) - 1:0]),
				.popcount_o(right_child_result)
			);
		end
	endgenerate
	assign popcount_o = left_child_result + right_child_result;
endmodule
