module riscv_prefetch_buffer (
	clk,
	rst_n,
	req_i,
	branch_i,
	addr_i,
	hwloop_i,
	hwloop_target_i,
	hwlp_branch_o,
	ready_i,
	valid_o,
	rdata_o,
	addr_o,
	is_hwlp_o,
	instr_req_o,
	instr_gnt_i,
	instr_addr_o,
	instr_rdata_i,
	instr_rvalid_i,
	instr_err_pmp_i,
	fetch_failed_o,
	busy_o
);
	input wire clk;
	input wire rst_n;
	input wire req_i;
	input wire branch_i;
	input wire [31:0] addr_i;
	input wire hwloop_i;
	input wire [31:0] hwloop_target_i;
	output wire hwlp_branch_o;
	input wire ready_i;
	output wire valid_o;
	output wire [31:0] rdata_o;
	output wire [31:0] addr_o;
	output wire is_hwlp_o;
	output reg instr_req_o;
	input wire instr_gnt_i;
	output reg [31:0] instr_addr_o;
	input wire [31:0] instr_rdata_i;
	input wire instr_rvalid_i;
	input wire instr_err_pmp_i;
	output reg fetch_failed_o;
	output wire busy_o;
	reg [2:0] CS;
	reg [2:0] NS;
	reg [2:0] hwlp_CS;
	reg [2:0] hwlp_NS;
	reg [31:0] instr_addr_q;
	wire [31:0] fetch_addr;
	reg fetch_is_hwlp;
	reg addr_valid;
	reg fifo_valid;
	wire fifo_ready;
	reg fifo_clear;
	reg fifo_hwlp;
	wire valid_stored;
	reg hwlp_masked;
	reg hwlp_branch;
	reg hwloop_speculative;
	wire unaligned_is_compressed;
	assign busy_o = (CS != 3'd0) || instr_req_o;
	riscv_fetch_fifo fifo_i(
		.clk(clk),
		.rst_n(rst_n),
		.clear_i(fifo_clear),
		.in_addr_i(instr_addr_q),
		.in_rdata_i(instr_rdata_i),
		.in_valid_i(fifo_valid),
		.in_ready_o(fifo_ready),
		.in_replace2_i(fifo_hwlp),
		.in_is_hwlp_i(fifo_hwlp),
		.out_valid_o(valid_o),
		.out_ready_i(ready_i),
		.out_rdata_o(rdata_o),
		.out_addr_o(addr_o),
		.unaligned_is_compressed_o(unaligned_is_compressed),
		.out_valid_stored_o(valid_stored),
		.out_is_hwlp_o(is_hwlp_o)
	);
	assign fetch_addr = {instr_addr_q[31:2], 2'b00} + 32'd4;
	assign hwlp_branch_o = hwlp_branch;
	always @(*) begin
		hwlp_NS = hwlp_CS;
		fifo_hwlp = 1'b0;
		fifo_clear = 1'b0;
		hwlp_branch = 1'b0;
		hwloop_speculative = 1'b0;
		hwlp_masked = 1'b0;
		case (hwlp_CS)
			3'd0:
				if (hwloop_i) begin
					hwlp_masked = ~instr_addr_q[1];
					if ((valid_o & unaligned_is_compressed) & instr_addr_q[1]) begin
						hwlp_NS = 3'd4;
						hwloop_speculative = 1'b1;
					end
					else if (instr_addr_q[1] && ~valid_o) begin
						hwlp_NS = 3'd5;
						hwloop_speculative = 1'b1;
					end
					else if (fetch_is_hwlp)
						hwlp_NS = 3'd2;
					else
						hwlp_NS = 3'd1;
					if (ready_i)
						fifo_clear = 1'b1;
				end
				else
					hwlp_masked = 1'b0;
			3'd5: begin
				hwlp_masked = 1'b1;
				if (valid_o) begin
					hwlp_NS = 3'd2;
					if (ready_i)
						fifo_clear = 1'b1;
				end
			end
			3'd4: begin
				hwlp_branch = 1'b1;
				hwlp_NS = 3'd2;
				fifo_clear = 1'b1;
			end
			3'd1: begin
				hwlp_masked = 1'b1;
				if (fetch_is_hwlp)
					hwlp_NS = 3'd2;
				if (ready_i)
					fifo_clear = 1'b1;
			end
			3'd2: begin
				hwlp_masked = 1'b0;
				fifo_hwlp = 1'b1;
				if (instr_rvalid_i & (CS != 3'd3)) begin
					if (valid_o & is_hwlp_o)
						hwlp_NS = 3'd0;
					else
						hwlp_NS = 3'd3;
				end
				else if (ready_i)
					fifo_clear = 1'b1;
			end
			3'd3: begin
				hwlp_masked = 1'b0;
				if (valid_o & is_hwlp_o)
					hwlp_NS = 3'd0;
			end
			default: begin
				hwlp_masked = 1'b0;
				hwlp_NS = 3'd0;
			end
		endcase
		if (branch_i) begin
			hwlp_NS = 3'd0;
			fifo_clear = 1'b1;
		end
	end
	always @(*) begin
		instr_req_o = 1'b0;
		instr_addr_o = fetch_addr;
		fifo_valid = 1'b0;
		addr_valid = 1'b0;
		fetch_is_hwlp = 1'b0;
		fetch_failed_o = 1'b0;
		NS = CS;
		case (CS)
			3'd0: begin
				instr_addr_o = fetch_addr;
				instr_req_o = 1'b0;
				if (branch_i | hwlp_branch)
					instr_addr_o = (branch_i ? addr_i : instr_addr_q);
				else if (hwlp_masked & valid_stored)
					instr_addr_o = hwloop_target_i;
				if (req_i & (((fifo_ready | branch_i) | hwlp_branch) | (hwlp_masked & valid_stored))) begin
					instr_req_o = 1'b1;
					addr_valid = 1'b1;
					if (hwlp_masked & valid_stored)
						fetch_is_hwlp = 1'b1;
					if (instr_gnt_i)
						NS = 3'd2;
					else
						NS = 3'd1;
					if (instr_err_pmp_i)
						NS = 3'd4;
				end
			end
			3'd4: begin
				instr_req_o = 1'b0;
				fetch_failed_o = valid_o == 1'b0;
				if (branch_i) begin
					instr_addr_o = addr_i;
					addr_valid = 1'b1;
					instr_req_o = 1'b1;
					fetch_failed_o = 1'b0;
					if (instr_gnt_i)
						NS = 3'd2;
					else
						NS = 3'd1;
				end
			end
			3'd1: begin
				instr_addr_o = instr_addr_q;
				instr_req_o = 1'b1;
				if (branch_i | hwlp_branch) begin
					instr_addr_o = (branch_i ? addr_i : instr_addr_q);
					addr_valid = 1'b1;
				end
				else if (hwlp_masked & valid_stored) begin
					instr_addr_o = hwloop_target_i;
					addr_valid = 1'b1;
					fetch_is_hwlp = 1'b1;
				end
				if (instr_gnt_i)
					NS = 3'd2;
				else
					NS = 3'd1;
				if (instr_err_pmp_i)
					NS = 3'd4;
			end
			3'd2: begin
				instr_addr_o = fetch_addr;
				if (branch_i | hwlp_branch)
					instr_addr_o = (branch_i ? addr_i : instr_addr_q);
				else if (hwlp_masked)
					instr_addr_o = hwloop_target_i;
				if (req_i & (((fifo_ready | branch_i) | hwlp_branch) | hwlp_masked)) begin
					if (instr_rvalid_i) begin
						instr_req_o = 1'b1;
						fifo_valid = 1'b1;
						addr_valid = 1'b1;
						if (hwlp_masked)
							fetch_is_hwlp = 1'b1;
						if (instr_gnt_i)
							NS = 3'd2;
						else
							NS = 3'd1;
						if (instr_err_pmp_i)
							NS = 3'd4;
					end
					else if (branch_i | hwlp_branch) begin
						addr_valid = 1'b1;
						NS = 3'd3;
					end
					else if (hwlp_masked & valid_o) begin
						addr_valid = 1'b1;
						fetch_is_hwlp = 1'b1;
						NS = 3'd3;
					end
				end
				else if (instr_rvalid_i) begin
					fifo_valid = 1'b1;
					NS = 3'd0;
				end
			end
			3'd3: begin
				instr_addr_o = instr_addr_q;
				if (branch_i | hwlp_branch) begin
					instr_addr_o = (branch_i ? addr_i : instr_addr_q);
					addr_valid = 1'b1;
				end
				if (instr_rvalid_i) begin
					instr_req_o = 1'b1;
					if (instr_gnt_i)
						NS = 3'd2;
					else
						NS = 3'd1;
					if (instr_err_pmp_i)
						NS = 3'd4;
				end
			end
			default: begin
				NS = 3'd0;
				instr_req_o = 1'b0;
			end
		endcase
	end
	always @(posedge clk or negedge rst_n)
		if (rst_n == 1'b0) begin
			CS <= 3'd0;
			hwlp_CS <= 3'd0;
			instr_addr_q <= 1'sb0;
		end
		else begin
			CS <= NS;
			hwlp_CS <= hwlp_NS;
			if (addr_valid)
				instr_addr_q <= (hwloop_speculative & ~branch_i ? hwloop_target_i : instr_addr_o);
		end
endmodule
