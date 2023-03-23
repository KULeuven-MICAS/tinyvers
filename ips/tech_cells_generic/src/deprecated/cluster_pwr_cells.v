module cluster_level_shifter_in (
	in_i,
	out_o
);
	input wire in_i;
	output wire out_o;
	assign out_o = in_i;
endmodule
module cluster_level_shifter_in_clamp (
	in_i,
	out_o,
	clamp_i
);
	input wire in_i;
	output wire out_o;
	input wire clamp_i;
	assign out_o = (clamp_i ? 1'b0 : in_i);
endmodule
module cluster_level_shifter_inout (
	data_i,
	data_o
);
	input wire data_i;
	output wire data_o;
	assign data_o = data_i;
endmodule
module cluster_level_shifter_out (
	in_i,
	out_o
);
	input wire in_i;
	output wire out_o;
	assign out_o = in_i;
endmodule
module cluster_level_shifter_out_clamp (
	in_i,
	out_o,
	clamp_i
);
	input wire in_i;
	output wire out_o;
	input wire clamp_i;
	assign out_o = (clamp_i ? 1'b0 : in_i);
endmodule
