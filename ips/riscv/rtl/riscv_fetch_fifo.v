module riscv_fetch_fifo (
	clk,
	rst_n,
	clear_i,
	in_addr_i,
	in_rdata_i,
	in_valid_i,
	in_ready_o,
	in_replace2_i,
	in_is_hwlp_i,
	out_valid_o,
	out_ready_i,
	out_rdata_o,
	out_addr_o,
	unaligned_is_compressed_o,
	out_valid_stored_o,
	out_is_hwlp_o
);
	input wire clk;
	input wire rst_n;
	input wire clear_i;
	input wire [31:0] in_addr_i;
	input wire [31:0] in_rdata_i;
	input wire in_valid_i;
	output wire in_ready_o;
	input wire in_replace2_i;
	input wire in_is_hwlp_i;
	output reg out_valid_o;
	input wire out_ready_i;
	output reg [31:0] out_rdata_o;
	output wire [31:0] out_addr_o;
	output wire unaligned_is_compressed_o;
	output reg out_valid_stored_o;
	output wire out_is_hwlp_o;
	localparam DEPTH = 4;
	reg [127:0] addr_n;
	reg [127:0] addr_int;
	reg [127:0] addr_Q;
	reg [127:0] rdata_n;
	reg [127:0] rdata_int;
	reg [127:0] rdata_Q;
	reg [0:3] valid_n;
	reg [0:3] valid_int;
	reg [0:3] valid_Q;
	reg [0:1] is_hwlp_n;
	reg [0:1] is_hwlp_int;
	reg [0:1] is_hwlp_Q;
	wire [31:0] addr_next;
	wire [31:0] rdata;
	wire [31:0] rdata_unaligned;
	wire valid;
	wire valid_unaligned;
	wire aligned_is_compressed;
	wire unaligned_is_compressed;
	wire aligned_is_compressed_st;
	wire unaligned_is_compressed_st;
	assign rdata = (valid_Q[0] ? rdata_Q[96+:32] : in_rdata_i & {32 {in_valid_i}});
	assign valid = (valid_Q[0] || in_valid_i) || is_hwlp_Q[1];
	assign rdata_unaligned = (valid_Q[1] ? {rdata_Q[79-:16], rdata[31:16]} : {in_rdata_i[15:0], rdata[31:16]});
	assign valid_unaligned = valid_Q[1] || (valid_Q[0] && in_valid_i);
	assign unaligned_is_compressed_o = unaligned_is_compressed;
	assign unaligned_is_compressed = rdata[17:16] != 2'b11;
	assign aligned_is_compressed = rdata[1:0] != 2'b11;
	assign unaligned_is_compressed_st = valid_Q[0] && (rdata_Q[113-:2] != 2'b11);
	assign aligned_is_compressed_st = valid_Q[0] && (rdata_Q[97-:2] != 2'b11);
	always @(*)
		if (out_addr_o[1] && ~is_hwlp_Q[1]) begin
			out_rdata_o = rdata_unaligned;
			if (unaligned_is_compressed)
				out_valid_o = valid;
			else
				out_valid_o = valid_unaligned;
		end
		else begin
			out_rdata_o = rdata;
			out_valid_o = valid;
		end
	assign out_addr_o = (valid_Q[0] ? addr_Q[96+:32] : in_addr_i);
	assign out_is_hwlp_o = (valid_Q[0] ? is_hwlp_Q[0] : in_is_hwlp_i);
	always @(*) begin
		out_valid_stored_o = 1'b1;
		if (out_addr_o[1] && ~is_hwlp_Q[1]) begin
			if (unaligned_is_compressed_st)
				out_valid_stored_o = 1'b1;
			else
				out_valid_stored_o = valid_Q[1];
		end
		else
			out_valid_stored_o = valid_Q[0];
	end
	assign in_ready_o = ~valid_Q[2];
	always @(*) begin : sv2v_autoblock_1
		reg [0:1] _sv2v_jump;
		_sv2v_jump = 2'b00;
		addr_int = addr_Q;
		rdata_int = rdata_Q;
		valid_int = valid_Q;
		is_hwlp_int = is_hwlp_Q;
		if (in_valid_i) begin
			begin : sv2v_autoblock_2
				reg signed [31:0] j;
				begin : sv2v_autoblock_3
					reg signed [31:0] _sv2v_value_on_break;
					for (j = 0; j < DEPTH; j = j + 1)
						if (_sv2v_jump < 2'b10) begin
							_sv2v_jump = 2'b00;
							if (~valid_Q[j]) begin
								addr_int[(3 - j) * 32+:32] = in_addr_i;
								rdata_int[(3 - j) * 32+:32] = in_rdata_i;
								valid_int[j] = 1'b1;
								_sv2v_jump = 2'b10;
							end
							_sv2v_value_on_break = j;
						end
					if (!(_sv2v_jump < 2'b10))
						j = _sv2v_value_on_break;
					if (_sv2v_jump != 2'b11)
						_sv2v_jump = 2'b00;
				end
			end
			if (_sv2v_jump == 2'b00)
				if (in_replace2_i)
					if (valid_Q[0]) begin
						addr_int[64+:32] = in_addr_i;
						rdata_int[96+:32] = out_rdata_o;
						rdata_int[64+:32] = in_rdata_i;
						valid_int[1] = 1'b1;
						valid_int[2:3] = 1'sb0;
						is_hwlp_int[1] = in_is_hwlp_i;
					end
					else
						is_hwlp_int[0] = in_is_hwlp_i;
		end
	end
	assign addr_next = {addr_int[127-:30], 2'b00} + 32'h00000004;
	always @(*) begin
		addr_n = addr_int;
		rdata_n = rdata_int;
		valid_n = valid_int;
		is_hwlp_n = is_hwlp_int;
		if (out_ready_i && out_valid_o) begin
			is_hwlp_n = {is_hwlp_int[1], 1'b0};
			if (is_hwlp_int[1]) begin
				addr_n[96+:32] = addr_int[95-:32];
				begin : sv2v_autoblock_4
					reg signed [31:0] i;
					for (i = 0; i < 3; i = i + 1)
						rdata_n[(3 - i) * 32+:32] = rdata_int[(3 - (i + 1)) * 32+:32];
				end
				rdata_n[0+:32] = 32'b00000000000000000000000000000000;
				valid_n = {valid_int[1:3], 1'b0};
			end
			else if (addr_int[97]) begin
				if (unaligned_is_compressed)
					addr_n[96+:32] = {addr_next[31:2], 2'b00};
				else
					addr_n[96+:32] = {addr_next[31:2], 2'b10};
				begin : sv2v_autoblock_5
					reg signed [31:0] i;
					for (i = 0; i < 3; i = i + 1)
						rdata_n[(3 - i) * 32+:32] = rdata_int[(3 - (i + 1)) * 32+:32];
				end
				rdata_n[0+:32] = 32'b00000000000000000000000000000000;
				valid_n = {valid_int[1:3], 1'b0};
			end
			else if (aligned_is_compressed)
				addr_n[96+:32] = {addr_int[127-:30], 2'b10};
			else begin
				addr_n[96+:32] = {addr_next[31:2], 2'b00};
				begin : sv2v_autoblock_6
					reg signed [31:0] i;
					for (i = 0; i < 3; i = i + 1)
						rdata_n[(3 - i) * 32+:32] = rdata_int[(3 - (i + 1)) * 32+:32];
				end
				rdata_n[0+:32] = 32'b00000000000000000000000000000000;
				valid_n = {valid_int[1:3], 1'b0};
			end
		end
	end
	always @(posedge clk or negedge rst_n)
		if (rst_n == 1'b0) begin
			addr_Q <= {DEPTH {32'b00000000000000000000000000000000}};
			rdata_Q <= {DEPTH {32'b00000000000000000000000000000000}};
			valid_Q <= 1'sb0;
			is_hwlp_Q <= 1'sb0;
		end
		else if (clear_i) begin
			valid_Q <= 1'sb0;
			is_hwlp_Q <= 1'sb0;
		end
		else begin
			addr_Q <= addr_n;
			rdata_Q <= rdata_n;
			valid_Q <= valid_n;
			is_hwlp_Q <= is_hwlp_n;
		end
endmodule
