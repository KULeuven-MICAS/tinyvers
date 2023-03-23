module stream_arbiter_flushable (
	clk_i,
	rst_ni,
	flush_i,
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
	input wire flush_i;
	input wire [N_INP - 1:0] inp_data_i;
	input wire [N_INP - 1:0] inp_valid_i;
	output wire [N_INP - 1:0] inp_ready_o;
	output wire oup_data_o;
	output wire oup_valid_o;
	input wire oup_ready_i;
	generate
		if (ARBITER == "rr") begin : gen_rr_arb
			rr_arb_tree_25AF9 #(
				.NumIn(N_INP),
				.ExtPrio(1'b0),
				.AxiVldRdy(1'b1),
				.LockIn(1'b1)
			) i_arbiter(
				.clk_i(clk_i),
				.rst_ni(rst_ni),
				.flush_i(flush_i),
				.rr_i(1'sb0),
				.req_i(inp_valid_i),
				.gnt_o(inp_ready_o),
				.data_i(inp_data_i),
				.gnt_i(oup_ready_i),
				.req_o(oup_valid_o),
				.data_o(oup_data_o),
				.idx_o()
			);
		end
		else if (ARBITER == "prio") begin : gen_prio_arb
			rr_arb_tree_25AF9 #(
				.NumIn(N_INP),
				.ExtPrio(1'b1),
				.AxiVldRdy(1'b1),
				.LockIn(1'b1)
			) i_arbiter(
				.clk_i(clk_i),
				.rst_ni(rst_ni),
				.flush_i(flush_i),
				.rr_i(1'sb0),
				.req_i(inp_valid_i),
				.gnt_o(inp_ready_o),
				.data_i(inp_data_i),
				.gnt_i(oup_ready_i),
				.req_o(oup_valid_o),
				.data_o(oup_data_o),
				.idx_o()
			);
		end
		else begin : gen_arb_error
			$fatal(1, "Invalid value for parameter 'ARBITER'!");
		end
	endgenerate
endmodule
