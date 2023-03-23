module lzc (
	in_i,
	cnt_o,
	empty_o
);
	parameter [31:0] WIDTH = 2;
	parameter [0:0] MODE = 1'b0;
	input wire [WIDTH - 1:0] in_i;
	output wire [$clog2(WIDTH) - 1:0] cnt_o;
	output wire empty_o;
	localparam [31:0] NUM_LEVELS = $clog2(WIDTH);
	wire [(WIDTH * NUM_LEVELS) - 1:0] index_lut;
	wire [(2 ** NUM_LEVELS) - 1:0] sel_nodes;
	wire [((2 ** NUM_LEVELS) * NUM_LEVELS) - 1:0] index_nodes;
	reg [WIDTH - 1:0] in_tmp;
	always @(*) begin : flip_vector
		begin : sv2v_autoblock_1
			reg [31:0] i;
			for (i = 0; i < WIDTH; i = i + 1)
				in_tmp[i] = (MODE ? in_i[(WIDTH - 1) - i] : in_i[i]);
		end
	end
	genvar j;
	function automatic [NUM_LEVELS - 1:0] sv2v_cast_7179C;
		input reg [NUM_LEVELS - 1:0] inp;
		sv2v_cast_7179C = inp;
	endfunction
	generate
		for (j = 0; $unsigned(j) < WIDTH; j = j + 1) begin : g_index_lut
			assign index_lut[j * NUM_LEVELS+:NUM_LEVELS] = sv2v_cast_7179C($unsigned(j));
		end
	endgenerate
	genvar level;
	generate
		for (level = 0; $unsigned(level) < NUM_LEVELS; level = level + 1) begin : g_levels
			if ($unsigned(level) == (NUM_LEVELS - 1)) begin : g_last_level
				genvar k;
				for (k = 0; k < (2 ** level); k = k + 1) begin : g_level
					if (($unsigned(k) * 2) < (WIDTH - 1)) begin : genblk1
						assign sel_nodes[((2 ** level) - 1) + k] = in_tmp[k * 2] | in_tmp[(k * 2) + 1];
						assign index_nodes[(((2 ** level) - 1) + k) * NUM_LEVELS+:NUM_LEVELS] = (in_tmp[k * 2] == 1'b1 ? index_lut[(k * 2) * NUM_LEVELS+:NUM_LEVELS] : index_lut[((k * 2) + 1) * NUM_LEVELS+:NUM_LEVELS]);
					end
					if (($unsigned(k) * 2) == (WIDTH - 1)) begin : genblk2
						assign sel_nodes[((2 ** level) - 1) + k] = in_tmp[k * 2];
						assign index_nodes[(((2 ** level) - 1) + k) * NUM_LEVELS+:NUM_LEVELS] = index_lut[(k * 2) * NUM_LEVELS+:NUM_LEVELS];
					end
					if (($unsigned(k) * 2) > (WIDTH - 1)) begin : genblk3
						assign sel_nodes[((2 ** level) - 1) + k] = 1'b0;
						assign index_nodes[(((2 ** level) - 1) + k) * NUM_LEVELS+:NUM_LEVELS] = 1'sb0;
					end
				end
			end
			else begin : genblk1
				genvar l;
				for (l = 0; l < (2 ** level); l = l + 1) begin : g_level
					assign sel_nodes[((2 ** level) - 1) + l] = sel_nodes[((2 ** (level + 1)) - 1) + (l * 2)] | sel_nodes[(((2 ** (level + 1)) - 1) + (l * 2)) + 1];
					assign index_nodes[(((2 ** level) - 1) + l) * NUM_LEVELS+:NUM_LEVELS] = (sel_nodes[((2 ** (level + 1)) - 1) + (l * 2)] == 1'b1 ? index_nodes[(((2 ** (level + 1)) - 1) + (l * 2)) * NUM_LEVELS+:NUM_LEVELS] : index_nodes[((((2 ** (level + 1)) - 1) + (l * 2)) + 1) * NUM_LEVELS+:NUM_LEVELS]);
				end
			end
		end
	endgenerate
	function automatic signed [$clog2(WIDTH) - 1:0] sv2v_cast_D3735_signed;
		input reg signed [$clog2(WIDTH) - 1:0] inp;
		sv2v_cast_D3735_signed = inp;
	endfunction
	assign cnt_o = (NUM_LEVELS > $unsigned(0) ? index_nodes[0+:NUM_LEVELS] : sv2v_cast_D3735_signed(0));
	assign empty_o = (NUM_LEVELS > $unsigned(0) ? ~sel_nodes[0] : ~(|in_i));
endmodule
