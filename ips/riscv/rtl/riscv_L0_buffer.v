module riscv_L0_buffer (
	clk,
	rst_n,
	prefetch_i,
	prefetch_addr_i,
	branch_i,
	branch_addr_i,
	hwlp_i,
	hwlp_addr_i,
	fetch_gnt_o,
	fetch_valid_o,
	valid_o,
	rdata_o,
	addr_o,
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
	input wire prefetch_i;
	input wire [31:0] prefetch_addr_i;
	input wire branch_i;
	input wire [31:0] branch_addr_i;
	input wire hwlp_i;
	input wire [31:0] hwlp_addr_i;
	output wire fetch_gnt_o;
	output reg fetch_valid_o;
	output wire valid_o;
	output wire [((RDATA_IN_WIDTH / 32) * 32) - 1:0] rdata_o;
	output wire [31:0] addr_o;
	output reg instr_req_o;
	output wire [31:0] instr_addr_o;
	input wire instr_gnt_i;
	input wire instr_rvalid_i;
	input wire [((RDATA_IN_WIDTH / 32) * 32) - 1:0] instr_rdata_i;
	output wire busy_o;
	reg [2:0] CS;
	reg [2:0] NS;
	reg [127:0] L0_buffer;
	reg [31:0] addr_q;
	reg [31:0] instr_addr_int;
	reg valid;
	always @(*) begin
		NS = CS;
		valid = 1'b0;
		instr_req_o = 1'b0;
		instr_addr_int = 1'sb0;
		fetch_valid_o = 1'b0;
		case (CS)
			3'd0: begin
				if (branch_i)
					instr_addr_int = branch_addr_i;
				else if (hwlp_i)
					instr_addr_int = hwlp_addr_i;
				else
					instr_addr_int = prefetch_addr_i;
				if ((branch_i | hwlp_i) | prefetch_i) begin
					instr_req_o = 1'b1;
					if (instr_gnt_i)
						NS = 3'd3;
					else
						NS = 3'd2;
				end
			end
			3'd2: begin
				if (branch_i)
					instr_addr_int = branch_addr_i;
				else if (hwlp_i)
					instr_addr_int = hwlp_addr_i;
				else
					instr_addr_int = addr_q;
				if (branch_i) begin
					instr_req_o = 1'b1;
					if (instr_gnt_i)
						NS = 3'd3;
					else
						NS = 3'd2;
				end
				else begin
					instr_req_o = 1'b1;
					if (instr_gnt_i)
						NS = 3'd3;
					else
						NS = 3'd2;
				end
			end
			3'd3: begin
				valid = instr_rvalid_i;
				if (branch_i)
					instr_addr_int = branch_addr_i;
				else if (hwlp_i)
					instr_addr_int = hwlp_addr_i;
				else
					instr_addr_int = prefetch_addr_i;
				if (branch_i) begin
					if (instr_rvalid_i) begin
						fetch_valid_o = 1'b1;
						instr_req_o = 1'b1;
						if (instr_gnt_i)
							NS = 3'd3;
						else
							NS = 3'd2;
					end
					else
						NS = 3'd4;
				end
				else if (instr_rvalid_i) begin
					fetch_valid_o = 1'b1;
					if (prefetch_i | hwlp_i) begin
						instr_req_o = 1'b1;
						if (instr_gnt_i)
							NS = 3'd3;
						else
							NS = 3'd2;
					end
					else
						NS = 3'd1;
				end
			end
			3'd1: begin
				valid = 1'b1;
				if (branch_i)
					instr_addr_int = branch_addr_i;
				else if (hwlp_i)
					instr_addr_int = hwlp_addr_i;
				else
					instr_addr_int = prefetch_addr_i;
				if ((branch_i | hwlp_i) | prefetch_i) begin
					instr_req_o = 1'b1;
					if (instr_gnt_i)
						NS = 3'd3;
					else
						NS = 3'd2;
				end
			end
			3'd4: begin
				if (branch_i)
					instr_addr_int = branch_addr_i;
				else
					instr_addr_int = addr_q;
				if (instr_rvalid_i) begin
					instr_req_o = 1'b1;
					if (instr_gnt_i)
						NS = 3'd3;
					else
						NS = 3'd2;
				end
			end
			default: NS = 3'd0;
		endcase
	end
	always @(posedge clk or negedge rst_n)
		if (~rst_n) begin
			CS <= 3'd0;
			L0_buffer <= 1'sb0;
			addr_q <= 1'sb0;
		end
		else begin
			CS <= NS;
			if (instr_rvalid_i)
				L0_buffer <= instr_rdata_i;
			if ((branch_i | hwlp_i) | prefetch_i)
				addr_q <= instr_addr_int;
		end
	assign instr_addr_o = {instr_addr_int[31:4], 4'b0000};
	assign rdata_o = (instr_rvalid_i ? instr_rdata_i : L0_buffer);
	assign addr_o = addr_q;
	assign valid_o = valid & ~branch_i;
	assign busy_o = ((CS != 3'd0) && (CS != 3'd1)) || instr_req_o;
	assign fetch_gnt_o = instr_gnt_i;
endmodule
