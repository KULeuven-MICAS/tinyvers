module stream_filter (
	valid_i,
	ready_o,
	drop_i,
	valid_o,
	ready_i
);
	input wire valid_i;
	output wire ready_o;
	input wire drop_i;
	output wire valid_o;
	input wire ready_i;
	assign valid_o = (drop_i ? 1'b0 : valid_i);
	assign ready_o = (drop_i ? 1'b1 : ready_i);
endmodule
