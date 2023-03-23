module axi_address_resolver (
	rules,
	addr_i,
	match_idx_o,
	match_ok_o
);
	parameter signed [31:0] ADDR_WIDTH = -1;
	parameter signed [31:0] NUM_SLAVE = -1;
	parameter signed [31:0] NUM_RULES = -1;
	input AXI_ROUTING_RULES.xbar rules;
	input wire [ADDR_WIDTH - 1:0] addr_i;
	output wire [$clog2(NUM_SLAVE) - 1:0] match_idx_o;
	output wire match_ok_o;
	wire [(NUM_SLAVE * NUM_RULES) - 1:0] matched_rules;
	wire [NUM_SLAVE - 1:0] matched_slaves;
	genvar i;
	generate
		for (i = 0; i < NUM_SLAVE; i = i + 1) begin : g_slave
			genvar j;
			for (j = 0; j < NUM_RULES; j = j + 1) begin : g_rule
				wire [ADDR_WIDTH - 1:0] base;
				wire [ADDR_WIDTH - 1:0] mask;
				wire enabled;
				assign base = rules.rules[i][j].base;
				assign mask = rules.rules[i][j].mask;
				assign enabled = rules.rules[i][j].enabled;
				assign matched_rules[(i * NUM_RULES) + j] = enabled && ((addr_i & mask) == (base & mask));
			end
			assign matched_slaves[i] = |matched_rules[i * NUM_RULES+:NUM_RULES];
		end
	endgenerate
	assign match_ok_o = |matched_slaves;
	find_first_one #(
		.WIDTH(NUM_SLAVE),
		.FLIP(0)
	) i_lzc(
		.in_i(matched_slaves),
		.first_one_o(match_idx_o),
		.no_ones_o()
	);
	always @(matched_rules or matched_slaves)
		;
endmodule
