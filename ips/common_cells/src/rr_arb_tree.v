module rr_arb_tree (
	clk_i,
	rst_ni,
	flush_i,
	rr_i,
	req_i,
	gnt_o,
	data_i,
	gnt_i,
	req_o,
	data_o,
	idx_o
);
	parameter [31:0] NumIn = 64;
	parameter [31:0] DataWidth = 32;
	parameter [0:0] ExtPrio = 1'b0;
	parameter [0:0] AxiVldRdy = 1'b0;
	parameter [0:0] LockIn = 1'b0;
	input wire clk_i;
	input wire rst_ni;
	input wire flush_i;
	input wire [$clog2(NumIn) - 1:0] rr_i;
	input wire [NumIn - 1:0] req_i;
	output wire [NumIn - 1:0] gnt_o;
	input wire [(NumIn * DataWidth) - 1:0] data_i;
	input wire gnt_i;
	output wire req_o;
	output wire [DataWidth - 1:0] data_o;
	output wire [$clog2(NumIn) - 1:0] idx_o;
	function automatic [DataWidth - 1:0] sv2v_cast_4AF59;
		input reg [DataWidth - 1:0] inp;
		sv2v_cast_4AF59 = inp;
	endfunction
	generate
		if (NumIn == $unsigned(1)) begin : genblk1
			assign req_o = req_i[0];
			assign gnt_o[0] = gnt_i;
			assign data_o = data_i[0+:DataWidth];
			assign idx_o = 1'sb0;
		end
		else begin : genblk1
			localparam [31:0] NumLevels = $clog2(NumIn);
			wire [(((2 ** NumLevels) - 2) >= 0 ? (((2 ** NumLevels) - 1) * NumLevels) - 1 : ((3 - (2 ** NumLevels)) * NumLevels) + ((((2 ** NumLevels) - 2) * NumLevels) - 1)):(((2 ** NumLevels) - 2) >= 0 ? 0 : ((2 ** NumLevels) - 2) * NumLevels)] index_nodes;
			wire [(((2 ** NumLevels) - 2) >= 0 ? (((2 ** NumLevels) - 1) * DataWidth) - 1 : ((3 - (2 ** NumLevels)) * DataWidth) + ((((2 ** NumLevels) - 2) * DataWidth) - 1)):(((2 ** NumLevels) - 2) >= 0 ? 0 : ((2 ** NumLevels) - 2) * DataWidth)] data_nodes;
			wire [(2 ** NumLevels) - 2:0] gnt_nodes;
			wire [(2 ** NumLevels) - 2:0] req_nodes;
			reg [NumLevels - 1:0] rr_q;
			wire [NumIn - 1:0] req_d;
			assign req_o = req_nodes[0];
			assign data_o = data_nodes[(((2 ** NumLevels) - 2) >= 0 ? 0 : (2 ** NumLevels) - 2) * DataWidth+:DataWidth];
			assign idx_o = index_nodes[(((2 ** NumLevels) - 2) >= 0 ? 0 : (2 ** NumLevels) - 2) * NumLevels+:NumLevels];
			if (ExtPrio) begin : gen_ext_rr
				wire [NumLevels:1] sv2v_tmp_4C2F0;
				assign sv2v_tmp_4C2F0 = rr_i;
				always @(*) rr_q = sv2v_tmp_4C2F0;
				assign req_d = req_i;
			end
			else begin : gen_int_rr
				wire [NumLevels - 1:0] rr_d;
				if (LockIn) begin : gen_lock
					wire lock_d;
					reg lock_q;
					reg [NumIn - 1:0] req_q;
					assign lock_d = req_o & ~gnt_i;
					assign req_d = (lock_q ? req_q : req_i);
					always @(posedge clk_i or negedge rst_ni) begin : p_lock_reg
						if (!rst_ni)
							lock_q <= 1'sb0;
						else if (flush_i)
							lock_q <= 1'sb0;
						else
							lock_q <= lock_d;
					end
					wire [NumIn - 1:0] req_tmp;
					assign req_tmp = req_q & req_i;
					always @(posedge clk_i or negedge rst_ni) begin : p_req_regs
						if (!rst_ni)
							req_q <= 1'sb0;
						else if (flush_i)
							req_q <= 1'sb0;
						else
							req_q <= req_d;
					end
				end
				else begin : gen_no_lock
					assign req_d = req_i;
				end
				function automatic [NumLevels - 1:0] sv2v_cast_5699A;
					input reg [NumLevels - 1:0] inp;
					sv2v_cast_5699A = inp;
				endfunction
				assign rr_d = (gnt_i && req_o ? (rr_q == sv2v_cast_5699A(NumIn - 1) ? {NumLevels {1'sb0}} : rr_q + 1'b1) : rr_q);
				always @(posedge clk_i or negedge rst_ni) begin : p_rr_regs
					if (!rst_ni)
						rr_q <= 1'sb0;
					else if (flush_i)
						rr_q <= 1'sb0;
					else
						rr_q <= rr_d;
				end
			end
			assign gnt_nodes[0] = gnt_i;
			genvar level;
			for (level = 0; $unsigned(level) < NumLevels; level = level + 1) begin : gen_levels
				genvar l;
				for (l = 0; l < (2 ** level); l = l + 1) begin : gen_level
					wire sel;
					localparam [31:0] idx0 = ((2 ** level) - 1) + l;
					localparam [31:0] idx1 = ((2 ** (level + 1)) - 1) + (l * 2);
					if ($unsigned(level) == (NumLevels - 1)) begin : gen_first_level
						if (($unsigned(l) * 2) < (NumIn - 1)) begin : genblk1
							assign req_nodes[idx0] = req_d[l * 2] | req_d[(l * 2) + 1];
							assign sel = ~req_d[l * 2] | (req_d[(l * 2) + 1] & rr_q[(NumLevels - 1) - level]);
							function automatic [NumLevels - 1:0] sv2v_cast_5699A;
								input reg [NumLevels - 1:0] inp;
								sv2v_cast_5699A = inp;
							endfunction
							assign index_nodes[(((2 ** NumLevels) - 2) >= 0 ? idx0 : ((2 ** NumLevels) - 2) - idx0) * NumLevels+:NumLevels] = sv2v_cast_5699A(sel);
							assign data_nodes[(((2 ** NumLevels) - 2) >= 0 ? idx0 : ((2 ** NumLevels) - 2) - idx0) * DataWidth+:DataWidth] = (sel ? data_i[((l * 2) + 1) * DataWidth+:DataWidth] : data_i[(l * 2) * DataWidth+:DataWidth]);
							assign gnt_o[l * 2] = (gnt_nodes[idx0] & (AxiVldRdy | req_d[l * 2])) & ~sel;
							assign gnt_o[(l * 2) + 1] = (gnt_nodes[idx0] & (AxiVldRdy | req_d[(l * 2) + 1])) & sel;
						end
						if (($unsigned(l) * 2) == (NumIn - 1)) begin : genblk2
							assign req_nodes[idx0] = req_d[l * 2];
							assign index_nodes[(((2 ** NumLevels) - 2) >= 0 ? idx0 : ((2 ** NumLevels) - 2) - idx0) * NumLevels+:NumLevels] = 1'sb0;
							assign data_nodes[(((2 ** NumLevels) - 2) >= 0 ? idx0 : ((2 ** NumLevels) - 2) - idx0) * DataWidth+:DataWidth] = data_i[(l * 2) * DataWidth+:DataWidth];
							assign gnt_o[l * 2] = gnt_nodes[idx0] & (AxiVldRdy | req_d[l * 2]);
						end
						if (($unsigned(l) * 2) > (NumIn - 1)) begin : genblk3
							assign req_nodes[idx0] = 1'b0;
							assign index_nodes[(((2 ** NumLevels) - 2) >= 0 ? idx0 : ((2 ** NumLevels) - 2) - idx0) * NumLevels+:NumLevels] = sv2v_cast_4AF59(1'sb0);
							assign data_nodes[(((2 ** NumLevels) - 2) >= 0 ? idx0 : ((2 ** NumLevels) - 2) - idx0) * DataWidth+:DataWidth] = sv2v_cast_4AF59(1'sb0);
						end
					end
					else begin : gen_other_levels
						assign req_nodes[idx0] = req_nodes[idx1] | req_nodes[idx1 + 1];
						assign sel = ~req_nodes[idx1] | (req_nodes[idx1 + 1] & rr_q[(NumLevels - 1) - level]);
						function automatic [NumLevels - 1:0] sv2v_cast_5699A;
							input reg [NumLevels - 1:0] inp;
							sv2v_cast_5699A = inp;
						endfunction
						assign index_nodes[(((2 ** NumLevels) - 2) >= 0 ? idx0 : ((2 ** NumLevels) - 2) - idx0) * NumLevels+:NumLevels] = (sel ? sv2v_cast_5699A({1'b1, index_nodes[((((2 ** NumLevels) - 2) >= 0 ? idx1 + 1 : ((2 ** NumLevels) - 2) - (idx1 + 1)) * NumLevels) + (((NumLevels - $unsigned(level)) - 2) >= 0 ? (NumLevels - $unsigned(level)) - 2 : (((NumLevels - $unsigned(level)) - 2) + (((NumLevels - $unsigned(level)) - 2) >= 0 ? (NumLevels - $unsigned(level)) - 1 : 3 - (NumLevels - $unsigned(level)))) - 1)-:(((NumLevels - $unsigned(level)) - 2) >= 0 ? (NumLevels - $unsigned(level)) - 1 : 3 - (NumLevels - $unsigned(level)))]}) : sv2v_cast_5699A({1'b0, index_nodes[((((2 ** NumLevels) - 2) >= 0 ? idx1 : ((2 ** NumLevels) - 2) - idx1) * NumLevels) + (((NumLevels - $unsigned(level)) - 2) >= 0 ? (NumLevels - $unsigned(level)) - 2 : (((NumLevels - $unsigned(level)) - 2) + (((NumLevels - $unsigned(level)) - 2) >= 0 ? (NumLevels - $unsigned(level)) - 1 : 3 - (NumLevels - $unsigned(level)))) - 1)-:(((NumLevels - $unsigned(level)) - 2) >= 0 ? (NumLevels - $unsigned(level)) - 1 : 3 - (NumLevels - $unsigned(level)))]}));
						assign data_nodes[(((2 ** NumLevels) - 2) >= 0 ? idx0 : ((2 ** NumLevels) - 2) - idx0) * DataWidth+:DataWidth] = (sel ? data_nodes[(((2 ** NumLevels) - 2) >= 0 ? idx1 + 1 : ((2 ** NumLevels) - 2) - (idx1 + 1)) * DataWidth+:DataWidth] : data_nodes[(((2 ** NumLevels) - 2) >= 0 ? idx1 : ((2 ** NumLevels) - 2) - idx1) * DataWidth+:DataWidth]);
						assign gnt_nodes[idx1] = gnt_nodes[idx0] & ~sel;
						assign gnt_nodes[idx1 + 1] = gnt_nodes[idx0] & sel;
					end
				end
			end
			initial begin : p_assert
				
			end
		end
	endgenerate
endmodule
