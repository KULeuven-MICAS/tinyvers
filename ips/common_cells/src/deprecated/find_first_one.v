module find_first_one (
	in_i,
	first_one_o,
	no_ones_o
);
	parameter signed [31:0] WIDTH = -1;
	parameter signed [31:0] FLIP = 0;
	input wire [WIDTH - 1:0] in_i;
	output wire [$clog2(WIDTH) - 1:0] first_one_o;
	output wire no_ones_o;
	localparam signed [31:0] NUM_LEVELS = $clog2(WIDTH);
	wire [(WIDTH * NUM_LEVELS) - 1:0] index_lut;
	wire [(2 ** NUM_LEVELS) - 1:0] sel_nodes;
	wire [((2 ** NUM_LEVELS) * NUM_LEVELS) - 1:0] index_nodes;
	wire [WIDTH - 1:0] in_tmp;
	genvar i;
	generate
		for (i = 0; i < WIDTH; i = i + 1) begin : genblk1
			assign in_tmp[i] = (FLIP ? in_i[(WIDTH - 1) - i] : in_i[i]);
		end
	endgenerate
	genvar j;
	generate
		for (j = 0; j < WIDTH; j = j + 1) begin : genblk2
			assign index_lut[j * NUM_LEVELS+:NUM_LEVELS] = j;
		end
	endgenerate
	genvar level;
	generate
		for (level = 0; level < NUM_LEVELS; level = level + 1) begin : genblk3
			if (level < (NUM_LEVELS - 1)) begin : genblk1
				genvar l;
				for (l = 0; l < (2 ** level); l = l + 1) begin : genblk1
					assign sel_nodes[((2 ** level) - 1) + l] = sel_nodes[((2 ** (level + 1)) - 1) + (l * 2)] | sel_nodes[(((2 ** (level + 1)) - 1) + (l * 2)) + 1];
					assign index_nodes[(((2 ** level) - 1) + l) * NUM_LEVELS+:NUM_LEVELS] = (sel_nodes[((2 ** (level + 1)) - 1) + (l * 2)] == 1'b1 ? index_nodes[(((2 ** (level + 1)) - 1) + (l * 2)) * NUM_LEVELS+:NUM_LEVELS] : index_nodes[((((2 ** (level + 1)) - 1) + (l * 2)) + 1) * NUM_LEVELS+:NUM_LEVELS]);
				end
			end
			if (level == (NUM_LEVELS - 1)) begin : genblk2
				genvar k;
				for (k = 0; k < (2 ** level); k = k + 1) begin : genblk1
					if ((k * 2) < (WIDTH - 1)) begin : genblk1
						assign sel_nodes[((2 ** level) - 1) + k] = in_tmp[k * 2] | in_tmp[(k * 2) + 1];
						assign index_nodes[(((2 ** level) - 1) + k) * NUM_LEVELS+:NUM_LEVELS] = (in_tmp[k * 2] == 1'b1 ? index_lut[(k * 2) * NUM_LEVELS+:NUM_LEVELS] : index_lut[((k * 2) + 1) * NUM_LEVELS+:NUM_LEVELS]);
					end
					if ((k * 2) == (WIDTH - 1)) begin : genblk2
						assign sel_nodes[((2 ** level) - 1) + k] = in_tmp[k * 2];
						assign index_nodes[(((2 ** level) - 1) + k) * NUM_LEVELS+:NUM_LEVELS] = index_lut[(k * 2) * NUM_LEVELS+:NUM_LEVELS];
					end
					if ((k * 2) > (WIDTH - 1)) begin : genblk3
						assign sel_nodes[((2 ** level) - 1) + k] = 1'b0;
						assign index_nodes[(((2 ** level) - 1) + k) * NUM_LEVELS+:NUM_LEVELS] = 1'sb0;
					end
				end
			end
		end
	endgenerate
	assign first_one_o = (NUM_LEVELS > 0 ? index_nodes[0+:NUM_LEVELS] : {$clog2(WIDTH) {1'sb0}});
	assign no_ones_o = (NUM_LEVELS > 0 ? ~sel_nodes[0] : 1'b1);
endmodule
