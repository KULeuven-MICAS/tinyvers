module plru_tree (
	clk_i,
	rst_ni,
	used_i,
	plru_o
);
	parameter [31:0] ENTRIES = 16;
	input wire clk_i;
	input wire rst_ni;
	input wire [ENTRIES - 1:0] used_i;
	output reg [ENTRIES - 1:0] plru_o;
	localparam LOG_ENTRIES = $clog2(ENTRIES);
	reg [(2 * (ENTRIES - 1)) - 1:0] plru_tree_q;
	reg [(2 * (ENTRIES - 1)) - 1:0] plru_tree_d;
	always @(*) begin : plru_replacement
		plru_tree_d = plru_tree_q;
		begin : sv2v_autoblock_1
			reg [31:0] i;
			for (i = 0; i < ENTRIES; i = i + 1)
				begin : sv2v_autoblock_2
					reg [31:0] idx_base;
					reg [31:0] shift;
					reg [31:0] new_index;
					if (used_i[i]) begin : sv2v_autoblock_3
						reg [31:0] lvl;
						for (lvl = 0; lvl < LOG_ENTRIES; lvl = lvl + 1)
							begin
								idx_base = $unsigned((2 ** lvl) - 1);
								shift = LOG_ENTRIES - lvl;
								new_index = ~((i >> (shift - 1)) & 32'b00000000000000000000000000000001);
								plru_tree_d[idx_base + (i >> shift)] = new_index[0];
							end
					end
				end
		end
		begin : sv2v_autoblock_4
			reg [31:0] i;
			for (i = 0; i < ENTRIES; i = i + 1)
				begin : sv2v_autoblock_5
					reg en;
					reg [31:0] idx_base;
					reg [31:0] shift;
					reg [31:0] new_index;
					en = 1'b1;
					begin : sv2v_autoblock_6
						reg [31:0] lvl;
						for (lvl = 0; lvl < LOG_ENTRIES; lvl = lvl + 1)
							begin
								idx_base = $unsigned((2 ** lvl) - 1);
								shift = LOG_ENTRIES - lvl;
								new_index = (i >> (shift - 1)) & 32'b00000000000000000000000000000001;
								if (new_index[0])
									en = en & plru_tree_q[idx_base + (i >> shift)];
								else
									en = en & ~plru_tree_q[idx_base + (i >> shift)];
							end
					end
					plru_o[i] = en;
				end
		end
	end
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni)
			plru_tree_q <= 1'sb0;
		else
			plru_tree_q <= plru_tree_d;
endmodule
