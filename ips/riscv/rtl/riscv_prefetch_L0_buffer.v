module riscv_prefetch_L0_buffer (
	clk,
	rst_n,
	req_i,
	branch_i,
	addr_i,
	hwloop_i,
	hwloop_target_i,
	ready_i,
	valid_o,
	rdata_o,
	addr_o,
	is_hwlp_o,
	instr_req_o,
	instr_addr_o,
	instr_gnt_i,
	instr_rvalid_i,
	instr_rdata_i,
	busy_o
);
	parameter RDATA_IN_WIDTH = 128;
	input wire clk;
	input wire rst_n;
	input wire req_i;
	input wire branch_i;
	input wire [31:0] addr_i;
	input wire hwloop_i;
	input wire [31:0] hwloop_target_i;
	input wire ready_i;
	output wire valid_o;
	output wire [31:0] rdata_o;
	output wire [31:0] addr_o;
	output wire is_hwlp_o;
	output wire instr_req_o;
	output wire [31:0] instr_addr_o;
	input wire instr_gnt_i;
	input wire instr_rvalid_i;
	input wire [((RDATA_IN_WIDTH / 32) * 32) - 1:0] instr_rdata_i;
	output wire busy_o;
	wire busy_L0;
	reg [3:0] CS;
	reg [3:0] NS;
	reg do_fetch;
	reg do_hwlp;
	reg do_hwlp_int;
	reg use_last;
	reg save_rdata_last;
	reg use_hwlp;
	reg save_rdata_hwlp;
	reg valid;
	wire hwlp_is_crossword;
	wire is_crossword;
	wire next_is_crossword;
	wire next_valid;
	wire next_upper_compressed;
	wire fetch_possible;
	wire upper_is_compressed;
	reg [31:0] addr_q;
	reg [31:0] addr_n;
	reg [31:0] addr_int;
	wire [31:0] addr_aligned_next;
	wire [31:0] addr_real_next;
	reg is_hwlp_q;
	reg is_hwlp_n;
	reg [31:0] rdata_last_q;
	wire valid_L0;
	wire [((RDATA_IN_WIDTH / 32) * 32) - 1:0] rdata_L0;
	wire [31:0] addr_L0;
	wire fetch_valid;
	wire fetch_gnt;
	wire [31:0] rdata;
	reg [31:0] rdata_unaligned;
	wire aligned_is_compressed;
	wire unaligned_is_compressed;
	wire hwlp_aligned_is_compressed;
	wire hwlp_unaligned_is_compressed;
	riscv_L0_buffer #(.RDATA_IN_WIDTH(RDATA_IN_WIDTH)) L0_buffer_i(
		.clk(clk),
		.rst_n(rst_n),
		.prefetch_i(do_fetch),
		.prefetch_addr_i(addr_real_next),
		.branch_i(branch_i),
		.branch_addr_i(addr_i),
		.hwlp_i(do_hwlp | do_hwlp_int),
		.hwlp_addr_i(hwloop_target_i),
		.fetch_gnt_o(fetch_gnt),
		.fetch_valid_o(fetch_valid),
		.valid_o(valid_L0),
		.rdata_o(rdata_L0),
		.addr_o(addr_L0),
		.instr_req_o(instr_req_o),
		.instr_addr_o(instr_addr_o),
		.instr_gnt_i(instr_gnt_i),
		.instr_rvalid_i(instr_rvalid_i),
		.instr_rdata_i(instr_rdata_i),
		.busy_o(busy_L0)
	);
	assign rdata = (use_last || use_hwlp ? rdata_last_q : rdata_L0[addr_o[3:2] * 32+:32]);
	wire [16:1] sv2v_tmp_34AB2;
	assign sv2v_tmp_34AB2 = rdata[31:16];
	always @(*) rdata_unaligned[15:0] = sv2v_tmp_34AB2;
	always @(*)
		case (addr_o[3:2])
			2'b00: rdata_unaligned[31:16] = rdata_L0[47-:16];
			2'b01: rdata_unaligned[31:16] = rdata_L0[79-:16];
			2'b10: rdata_unaligned[31:16] = rdata_L0[111-:16];
			2'b11: rdata_unaligned[31:16] = rdata_L0[15-:16];
		endcase
	assign unaligned_is_compressed = rdata[17:16] != 2'b11;
	assign aligned_is_compressed = rdata[1:0] != 2'b11;
	assign upper_is_compressed = rdata_L0[113-:2] != 2'b11;
	assign is_crossword = (addr_o[3:1] == 3'b111) && ~upper_is_compressed;
	assign next_is_crossword = (((addr_o[3:1] == 3'b110) && aligned_is_compressed) && ~upper_is_compressed) || (((addr_o[3:1] == 3'b101) && ~unaligned_is_compressed) && ~upper_is_compressed);
	assign next_upper_compressed = (((addr_o[3:1] == 3'b110) && aligned_is_compressed) && upper_is_compressed) || (((addr_o[3:1] == 3'b101) && ~unaligned_is_compressed) && upper_is_compressed);
	assign next_valid = (((addr_o[3:2] != 2'b11) || next_upper_compressed) && ~next_is_crossword) && valid;
	assign fetch_possible = addr_o[3:2] == 2'b11;
	assign addr_aligned_next = {addr_o[31:2], 2'b00} + 32'h00000004;
	assign addr_real_next = (next_is_crossword ? {addr_o[31:4], 4'b0000} + 32'h00000016 : {addr_o[31:2], 2'b00} + 32'h00000004);
	assign hwlp_unaligned_is_compressed = rdata_L0[81-:2] != 2'b11;
	assign hwlp_aligned_is_compressed = rdata_L0[97-:2] != 2'b11;
	assign hwlp_is_crossword = (hwloop_target_i[3:1] == 3'b111) && ~upper_is_compressed;
	always @(*) begin
		addr_int = addr_o;
		if (ready_i)
			if (addr_o[1]) begin
				if (unaligned_is_compressed)
					addr_int = {addr_aligned_next[31:2], 2'b00};
				else
					addr_int = {addr_aligned_next[31:2], 2'b10};
			end
			else if (aligned_is_compressed)
				addr_int = {addr_o[31:2], 2'b10};
			else
				addr_int = {addr_aligned_next[31:2], 2'b00};
	end
	always @(*) begin
		NS = CS;
		do_fetch = 1'b0;
		do_hwlp = 1'b0;
		do_hwlp_int = 1'b0;
		use_last = 1'b0;
		use_hwlp = 1'b0;
		save_rdata_last = 1'b0;
		save_rdata_hwlp = 1'b0;
		valid = 1'b0;
		addr_n = addr_int;
		is_hwlp_n = is_hwlp_q;
		if (ready_i)
			is_hwlp_n = 1'b0;
		case (CS)
			4'd0:
				;
			4'd1: begin
				valid = 1'b0;
				do_fetch = fetch_possible;
				if (fetch_valid && ~is_crossword)
					valid = 1'b1;
				if (ready_i) begin
					if (hwloop_i) begin
						addr_n = addr_o;
						NS = 4'd2;
					end
					else if (next_valid) begin
						if (fetch_gnt) begin
							save_rdata_last = 1'b1;
							NS = 4'd12;
						end
						else
							NS = 4'd10;
					end
					else if (next_is_crossword) begin
						if (fetch_gnt) begin
							save_rdata_last = 1'b1;
							NS = 4'd9;
						end
						else
							NS = 4'd8;
					end
					else if (fetch_gnt)
						NS = 4'd7;
					else
						NS = 4'd6;
				end
				else if (fetch_valid)
					if (is_crossword) begin
						save_rdata_last = 1'b1;
						if (fetch_gnt)
							NS = 4'd9;
						else
							NS = 4'd8;
					end
					else if (fetch_gnt) begin
						save_rdata_last = 1'b1;
						NS = 4'd12;
					end
					else
						NS = 4'd10;
			end
			4'd6: begin
				do_fetch = 1'b1;
				if (fetch_gnt)
					NS = 4'd7;
			end
			4'd7: begin
				valid = fetch_valid;
				do_hwlp = hwloop_i;
				if (fetch_valid)
					NS = 4'd10;
			end
			4'd8: begin
				do_fetch = 1'b1;
				if (fetch_gnt) begin
					save_rdata_last = 1'b1;
					NS = 4'd9;
				end
			end
			4'd9: begin
				valid = fetch_valid;
				use_last = 1'b1;
				do_hwlp = hwloop_i;
				if (fetch_valid)
					if (ready_i)
						NS = 4'd10;
					else
						NS = 4'd11;
			end
			4'd10: begin
				valid = 1'b1;
				do_fetch = fetch_possible;
				do_hwlp = hwloop_i;
				if (ready_i) begin
					if (next_is_crossword) begin
						do_fetch = 1'b1;
						if (fetch_gnt) begin
							save_rdata_last = 1'b1;
							NS = 4'd9;
						end
						else
							NS = 4'd8;
					end
					else if (~next_valid) begin
						if (fetch_gnt)
							NS = 4'd7;
						else
							NS = 4'd6;
					end
					else if (fetch_gnt)
						if (next_upper_compressed) begin
							save_rdata_last = 1'b1;
							NS = 4'd12;
						end
				end
				else if (fetch_gnt) begin
					save_rdata_last = 1'b1;
					NS = 4'd12;
				end
			end
			4'd11: begin
				valid = 1'b1;
				use_last = 1'b1;
				do_hwlp = hwloop_i;
				if (ready_i)
					NS = 4'd10;
			end
			4'd12: begin
				valid = 1'b1;
				use_last = 1'b1;
				do_hwlp = hwloop_i;
				if (ready_i) begin
					if (fetch_valid) begin
						if (next_is_crossword)
							NS = 4'd11;
						else if (next_upper_compressed)
							NS = 4'd13;
						else
							NS = 4'd10;
					end
					else if (next_is_crossword)
						NS = 4'd9;
					else if (next_upper_compressed)
						NS = 4'd12;
					else
						NS = 4'd7;
				end
				else if (fetch_valid)
					NS = 4'd13;
			end
			4'd13: begin
				valid = 1'b1;
				use_last = 1'b1;
				do_hwlp = hwloop_i;
				if (ready_i)
					if (next_is_crossword)
						NS = 4'd11;
					else if (next_upper_compressed)
						NS = 4'd13;
					else
						NS = 4'd10;
			end
			4'd2: begin
				do_hwlp_int = 1'b1;
				if (fetch_gnt) begin
					is_hwlp_n = 1'b1;
					addr_n = hwloop_target_i;
					NS = 4'd1;
				end
			end
			4'd3: begin
				valid = 1'b1;
				use_hwlp = 1'b1;
				if (ready_i) begin
					addr_n = hwloop_target_i;
					if (fetch_valid) begin
						is_hwlp_n = 1'b1;
						if (hwlp_is_crossword)
							NS = 4'd8;
						else
							NS = 4'd10;
					end
					else
						NS = 4'd4;
				end
				else if (fetch_valid)
					NS = 4'd5;
			end
			4'd4: begin
				use_hwlp = 1'b1;
				if (fetch_valid) begin
					is_hwlp_n = 1'b1;
					if ((addr_L0[3:1] == 3'b111) && ~upper_is_compressed)
						NS = 4'd8;
					else
						NS = 4'd10;
				end
			end
			4'd5: begin
				valid = 1'b1;
				use_hwlp = 1'b1;
				if (ready_i) begin
					is_hwlp_n = 1'b1;
					addr_n = hwloop_target_i;
					if (hwlp_is_crossword)
						NS = 4'd8;
					else
						NS = 4'd10;
				end
			end
		endcase
		if (branch_i) begin
			is_hwlp_n = 1'b0;
			addr_n = addr_i;
			NS = 4'd1;
		end
		else if (hwloop_i)
			if (do_hwlp)
				if (ready_i) begin
					if (fetch_gnt) begin
						is_hwlp_n = 1'b1;
						addr_n = hwloop_target_i;
						NS = 4'd1;
					end
					else begin
						addr_n = addr_o;
						NS = 4'd2;
					end
				end
				else if (fetch_gnt) begin
					save_rdata_hwlp = 1'b1;
					NS = 4'd3;
				end
	end
	always @(posedge clk or negedge rst_n)
		if (~rst_n) begin
			addr_q <= 1'sb0;
			is_hwlp_q <= 1'b0;
			CS <= 4'd0;
			rdata_last_q <= 1'sb0;
		end
		else begin
			addr_q <= addr_n;
			is_hwlp_q <= is_hwlp_n;
			CS <= NS;
			if (save_rdata_hwlp)
				rdata_last_q <= rdata_o;
			else if (save_rdata_last)
				if (ready_i)
					rdata_last_q <= rdata_L0[96+:32];
				else
					rdata_last_q <= rdata;
		end
	assign rdata_o = (~addr_o[1] || use_hwlp ? rdata : rdata_unaligned);
	assign valid_o = valid & ~branch_i;
	assign addr_o = addr_q;
	assign is_hwlp_o = is_hwlp_q & ~branch_i;
	assign busy_o = busy_L0;
endmodule
