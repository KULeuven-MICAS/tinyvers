module stream_arbiter (
	clk_i,
	rst_ni,
	inp_data_i,
	inp_valid_i,
	inp_ready_o,
	oup_data_o,
	oup_valid_o,
	oup_ready_i
);
	parameter integer N_INP = -1;
	parameter ARBITER = "rr";
	input wire clk_i;
	input wire rst_ni;
	input wire [N_INP - 1:0] inp_data_i;
	input wire [N_INP - 1:0] inp_valid_i;
	output wire [N_INP - 1:0] inp_ready_o;
	output wire oup_data_o;
	output wire oup_valid_o;
	input wire oup_ready_i;
	stream_arbiter_flushable_9919D #(
		.N_INP(N_INP),
		.ARBITER(ARBITER)
	) i_arb(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.flush_i(1'b0),
		.inp_data_i(inp_data_i),
		.inp_valid_i(inp_valid_i),
		.inp_ready_o(inp_ready_o),
		.oup_data_o(oup_data_o),
		.oup_valid_o(oup_valid_o),
		.oup_ready_i(oup_ready_i)
	);
endmodule
