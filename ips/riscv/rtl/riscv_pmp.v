module riscv_pmp (
	clk,
	rst_n,
	pmp_privil_mode_i,
	pmp_addr_i,
	pmp_cfg_i,
	data_req_i,
	data_addr_i,
	data_we_i,
	data_gnt_o,
	data_req_o,
	data_gnt_i,
	data_addr_o,
	data_err_o,
	data_err_ack_i,
	instr_req_i,
	instr_addr_i,
	instr_gnt_o,
	instr_req_o,
	instr_gnt_i,
	instr_addr_o,
	instr_err_o
);
	parameter N_PMP_ENTRIES = 16;
	input wire clk;
	input wire rst_n;
	input wire [1:0] pmp_privil_mode_i;
	input wire [(N_PMP_ENTRIES * 32) - 1:0] pmp_addr_i;
	input wire [(N_PMP_ENTRIES * 8) - 1:0] pmp_cfg_i;
	input wire data_req_i;
	input wire [31:0] data_addr_i;
	input wire data_we_i;
	output reg data_gnt_o;
	output reg data_req_o;
	input wire data_gnt_i;
	output wire [31:0] data_addr_o;
	output reg data_err_o;
	input wire data_err_ack_i;
	input wire instr_req_i;
	input wire [31:0] instr_addr_i;
	output reg instr_gnt_o;
	output reg instr_req_o;
	input wire instr_gnt_i;
	output wire [31:0] instr_addr_o;
	output reg instr_err_o;
	reg [N_PMP_ENTRIES - 1:0] EN_rule;
	wire [N_PMP_ENTRIES - 1:0] R_rule;
	wire [N_PMP_ENTRIES - 1:0] W_rule;
	wire [N_PMP_ENTRIES - 1:0] X_rule;
	wire [(N_PMP_ENTRIES * 2) - 1:0] MODE_rule;
	wire [(N_PMP_ENTRIES * 2) - 1:0] WIRI_rule;
	wire [(N_PMP_ENTRIES * 2) - 1:0] LOCK_rule;
	reg [(N_PMP_ENTRIES * 32) - 1:0] mask_addr;
	reg [(N_PMP_ENTRIES * 32) - 1:0] start_addr;
	reg [(N_PMP_ENTRIES * 32) - 1:0] stop_addr;
	reg [N_PMP_ENTRIES - 1:0] data_match_region;
	reg [N_PMP_ENTRIES - 1:0] instr_match_region;
	reg data_err_int;
	genvar i;
	reg [31:0] j;
	reg [31:0] k;
	generate
		for (i = 0; i < N_PMP_ENTRIES; i = i + 1) begin : CFG_EXP
			assign {LOCK_rule[i * 2+:2], WIRI_rule[i * 2+:2], MODE_rule[i * 2+:2], X_rule[i], W_rule[i], R_rule[i]} = pmp_cfg_i[i * 8+:8];
		end
		for (i = 0; i < N_PMP_ENTRIES; i = i + 1) begin : ADDR_EXP
			always @(*) begin
				start_addr[i * 32+:32] = 1'sb0;
				stop_addr[i * 32+:32] = 1'sb0;
				mask_addr[i * 32+:32] = 32'hffffffff;
				case (MODE_rule[i * 2+:2])
					2'b00: begin : DISABLED
						EN_rule[i] = 1'b0;
					end
					2'b01: begin : TOR_MODE
						EN_rule[i] = 1'b1;
						if (i == 0)
							start_addr[i * 32+:32] = 0;
						else
							start_addr[i * 32+:32] = pmp_addr_i[(i - 1) * 32+:32];
						stop_addr[i * 32+:32] = pmp_addr_i[i * 32+:32];
					end
					2'b10: begin : NA4_MODE
						EN_rule[i] = 1'b1;
						stop_addr[i * 32+:32] = pmp_addr_i[i * 32+:32];
						start_addr[i * 32+:32] = pmp_addr_i[i * 32+:32];
					end
					2'b11: begin : NAPOT_MODE
						EN_rule[i] = 1'b1;
						mask_addr[i * 32+:32] = 32'hffffffff;
						stop_addr[i * 32+:32] = pmp_addr_i[i * 32+:32];
						start_addr[i * 32+:32] = pmp_addr_i[i * 32+:32];
						casex (pmp_addr_i[i * 32+:32])
							32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx0: begin : BYTE_ALIGN_8B
								mask_addr[i * 32+:32] = 32'hfffffffe;
								start_addr[i * 32+:32] = pmp_addr_i[i * 32+:32] & mask_addr[i * 32+:32];
								stop_addr[i * 32+:32] = pmp_addr_i[i * 32+:32];
							end
							32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx01: begin : BYTE_ALIGN_16B
								mask_addr[i * 32+:32] = 32'hfffffffc;
								start_addr[i * 32+:32] = pmp_addr_i[i * 32+:32] & mask_addr[i * 32+:32];
								stop_addr[i * 32+:32] = pmp_addr_i[i * 32+:32];
							end
							32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxx011: begin : BYTE_ALIGN_32B
								mask_addr[i * 32+:32] = 32'hfffffff8;
								start_addr[i * 32+:32] = pmp_addr_i[i * 32+:32] & mask_addr[i * 32+:32];
								stop_addr[i * 32+:32] = pmp_addr_i[i * 32+:32];
							end
							32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxx0111: begin : BYTE_ALIGN_64B
								mask_addr[i * 32+:32] = 32'hfffffff0;
								start_addr[i * 32+:32] = pmp_addr_i[i * 32+:32] & mask_addr[i * 32+:32];
								stop_addr[i * 32+:32] = pmp_addr_i[i * 32+:32];
							end
							32'bxxxxxxxxxxxxxxxxxxxxxxxxxxx01111: begin : BYTE_ALIGN_128B
								mask_addr[i * 32+:32] = 32'hffffffe0;
								start_addr[i * 32+:32] = pmp_addr_i[i * 32+:32] & 32'hffffffe0;
								stop_addr[i * 32+:32] = pmp_addr_i[i * 32+:32];
							end
							32'bxxxxxxxxxxxxxxxxxxxxxxxxxx011111: begin : BYTE_ALIGN_256B
								mask_addr[i * 32+:32] = 32'hffffffc0;
								start_addr[i * 32+:32] = pmp_addr_i[i * 32+:32] & mask_addr[i * 32+:32];
								stop_addr[i * 32+:32] = pmp_addr_i[i * 32+:32];
							end
							32'bxxxxxxxxxxxxxxxxxxxxxxxxx0111111: begin : BYTE_ALIGN_512B
								mask_addr[i * 32+:32] = 32'hffffff80;
								start_addr[i * 32+:32] = pmp_addr_i[i * 32+:32] & mask_addr[i * 32+:32];
								stop_addr[i * 32+:32] = pmp_addr_i[i * 32+:32];
							end
							32'bxxxxxxxxxxxxxxxxxxxxxxxx01111111: begin : BYTE_ALIGN_1KB
								mask_addr[i * 32+:32] = 32'hffffff00;
								start_addr[i * 32+:32] = pmp_addr_i[i * 32+:32] & mask_addr[i * 32+:32];
								stop_addr[i * 32+:32] = pmp_addr_i[i * 32+:32];
							end
							32'bxxxxxxxxxxxxxxxxxxxxxxx011111111: begin : BYTE_ALIGN_2KB
								mask_addr[i * 32+:32] = 32'hfffffe00;
								start_addr[i * 32+:32] = pmp_addr_i[i * 32+:32] & mask_addr[i * 32+:32];
								stop_addr[i * 32+:32] = pmp_addr_i[i * 32+:32];
							end
							32'bxxxxxxxxxxxxxxxxxxxxxx0111111111: begin : BYTE_ALIGN_4KB
								mask_addr[i * 32+:32] = 32'hfffffc00;
								start_addr[i * 32+:32] = pmp_addr_i[i * 32+:32] & mask_addr[i * 32+:32];
								stop_addr[i * 32+:32] = pmp_addr_i[i * 32+:32];
							end
							32'bxxxxxxxxxxxxxxxxxxxxx01111111111: begin : BYTE_ALIGN_8KB
								mask_addr[i * 32+:32] = 32'hfffff800;
								start_addr[i * 32+:32] = pmp_addr_i[i * 32+:32] & mask_addr[i * 32+:32];
								stop_addr[i * 32+:32] = pmp_addr_i[i * 32+:32];
							end
							32'bxxxxxxxxxxxxxxxxxxxx011111111111: begin : BYTE_ALIGN_16KB
								mask_addr[i * 32+:32] = 32'hfffff000;
								start_addr[i * 32+:32] = pmp_addr_i[i * 32+:32] & mask_addr[i * 32+:32];
								stop_addr[i * 32+:32] = pmp_addr_i[i * 32+:32];
							end
							32'bxxxxxxxxxxxxxxxxxxx0111111111111: begin : BYTE_ALIGN_32KB
								mask_addr[i * 32+:32] = 32'hffffe000;
								start_addr[i * 32+:32] = pmp_addr_i[i * 32+:32] & mask_addr[i * 32+:32];
								stop_addr[i * 32+:32] = pmp_addr_i[i * 32+:32];
							end
							32'bxxxxxxxxxxxxxxxxxx01111111111111: begin : BYTE_ALIGN_64KB
								mask_addr[i * 32+:32] = 32'hffffc000;
								start_addr[i * 32+:32] = pmp_addr_i[i * 32+:32] & mask_addr[i * 32+:32];
								stop_addr[i * 32+:32] = pmp_addr_i[i * 32+:32];
							end
							32'bxxxxxxxxxxxxxxxxx011111111111111: begin : BYTE_ALIGN_128KB
								mask_addr[i * 32+:32] = 32'hffff8000;
								start_addr[i * 32+:32] = pmp_addr_i[i * 32+:32] & mask_addr[i * 32+:32];
								stop_addr[i * 32+:32] = pmp_addr_i[i * 32+:32];
							end
							32'bxxxxxxxxxxxxxxxx0111111111111111: begin : BYTE_ALIGN_256KB
								mask_addr[i * 32+:32] = 32'hffff0000;
								start_addr[i * 32+:32] = pmp_addr_i[i * 32+:32] & mask_addr[i * 32+:32];
								stop_addr[i * 32+:32] = pmp_addr_i[i * 32+:32];
							end
							default: begin : INVALID_RULE
								EN_rule[i] = 1'b0;
								start_addr[i * 32+:32] = 1'sb0;
								stop_addr[i * 32+:32] = 1'sb0;
							end
						endcase
					end
					default: begin : DEFAULT_DISABLED
						EN_rule[i] = 1'b0;
						start_addr[i * 32+:32] = 1'sb0;
						stop_addr[i * 32+:32] = 1'sb0;
					end
				endcase
			end
		end
	endgenerate
	always @(*)
		for (j = 0; j < N_PMP_ENTRIES; j = j + 1)
			if (EN_rule[j] & ((~data_we_i & R_rule[j]) | (data_we_i & W_rule[j])))
				case (MODE_rule[j * 2+:2])
					2'b01: begin : TOR_CHECK_DATA
						if ((data_addr_i[31:2] >= start_addr[j * 32+:32]) && (data_addr_i[31:2] < stop_addr[j * 32+:32]))
							data_match_region[j] = 1'b1;
						else
							data_match_region[j] = 1'b0;
					end
					2'b10: begin : NA4_CHECK_DATA
						if (data_addr_i[31:2] == start_addr[(j * 32) + 29-:30])
							data_match_region[j] = 1'b1;
						else
							data_match_region[j] = 1'b0;
					end
					2'b11: begin : NAPOT_CHECK_DATA
						if ((data_addr_i[31:2] & mask_addr[(j * 32) + 29-:30]) == start_addr[(j * 32) + 29-:30])
							data_match_region[j] = 1'b1;
						else
							data_match_region[j] = 1'b0;
					end
					default: data_match_region[j] = 1'b0;
				endcase
			else
				data_match_region[j] = 1'b0;
	assign data_addr_o = data_addr_i;
	always @(*)
		if (pmp_privil_mode_i == 2'b11) begin
			data_req_o = data_req_i;
			data_gnt_o = data_gnt_i;
			data_err_int = 1'b0;
		end
		else if (|data_match_region == 1'b0) begin
			data_req_o = 1'b0;
			data_err_int = data_req_i;
			data_gnt_o = 1'b0;
		end
		else begin
			data_req_o = data_req_i;
			data_err_int = 1'b0;
			data_gnt_o = data_gnt_i;
		end
	reg data_err_state_q;
	reg data_err_state_n;
	always @(*) begin
		data_err_o = 1'b0;
		data_err_state_n = data_err_state_q;
		case (data_err_state_q)
			1'd0:
				if (data_err_int)
					data_err_state_n = 1'd1;
			1'd1: begin
				data_err_o = 1'b1;
				if (data_err_ack_i)
					data_err_state_n = 1'd0;
			end
		endcase
	end
	always @(posedge clk or negedge rst_n)
		if (~rst_n)
			data_err_state_q <= 1'd0;
		else
			data_err_state_q <= data_err_state_n;
	always @(*)
		for (k = 0; k < N_PMP_ENTRIES; k = k + 1)
			if (EN_rule[k] & X_rule[k])
				case (MODE_rule[k * 2+:2])
					2'b01: begin : TOR_CHECK
						if ((instr_addr_i[31:2] >= start_addr[k * 32+:32]) && (instr_addr_i[31:2] < stop_addr[k * 32+:32]))
							instr_match_region[k] = 1'b1;
						else
							instr_match_region[k] = 1'b0;
					end
					2'b10: begin : NA4_CHECK
						if (instr_addr_i[31:2] == start_addr[(k * 32) + 29-:30])
							instr_match_region[k] = 1'b1;
						else
							instr_match_region[k] = 1'b0;
					end
					2'b11:
						if ((instr_addr_i[31:2] & mask_addr[(k * 32) + 29-:30]) == start_addr[(k * 32) + 29-:30])
							instr_match_region[k] = 1'b1;
						else
							instr_match_region[k] = 1'b0;
					default: instr_match_region[k] = 1'b0;
				endcase
			else
				instr_match_region[k] = 1'b0;
	assign instr_addr_o = instr_addr_i;
	always @(*)
		if (pmp_privil_mode_i == 2'b11) begin
			instr_req_o = instr_req_i;
			instr_gnt_o = instr_gnt_i;
			instr_err_o = 1'b0;
		end
		else if (|instr_match_region == 1'b0) begin
			instr_req_o = 1'b0;
			instr_err_o = instr_req_i;
			instr_gnt_o = 1'b0;
		end
		else begin
			instr_req_o = instr_req_i;
			instr_err_o = 1'b0;
			instr_gnt_o = instr_gnt_i;
		end
endmodule
