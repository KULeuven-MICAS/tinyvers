module riscv_hwloop_controller (
	current_pc_i,
	hwlp_start_addr_i,
	hwlp_end_addr_i,
	hwlp_counter_i,
	hwlp_dec_cnt_o,
	hwlp_dec_cnt_id_i,
	hwlp_jump_o,
	hwlp_targ_addr_o
);
	parameter N_REGS = 2;
	input wire [31:0] current_pc_i;
	input wire [(N_REGS * 32) - 1:0] hwlp_start_addr_i;
	input wire [(N_REGS * 32) - 1:0] hwlp_end_addr_i;
	input wire [(N_REGS * 32) - 1:0] hwlp_counter_i;
	output reg [N_REGS - 1:0] hwlp_dec_cnt_o;
	input wire [N_REGS - 1:0] hwlp_dec_cnt_id_i;
	output wire hwlp_jump_o;
	output reg [31:0] hwlp_targ_addr_o;
	reg [N_REGS - 1:0] pc_is_end_addr;
	integer j;
	genvar i;
	generate
		for (i = 0; i < N_REGS; i = i + 1) begin : genblk1
			always @(*) begin
				pc_is_end_addr[i] = 1'b0;
				if (current_pc_i == hwlp_end_addr_i[i * 32+:32])
					if (hwlp_counter_i[(i * 32) + 31-:30] != 30'h00000000)
						pc_is_end_addr[i] = 1'b1;
					else
						case (hwlp_counter_i[(i * 32) + 1-:2])
							2'b11: pc_is_end_addr[i] = 1'b1;
							2'b10: pc_is_end_addr[i] = ~hwlp_dec_cnt_id_i[i];
							2'b01, 2'b00: pc_is_end_addr[i] = 1'b0;
						endcase
			end
		end
	endgenerate
	always @(*) begin : sv2v_autoblock_1
		reg [0:1] _sv2v_jump;
		_sv2v_jump = 2'b00;
		hwlp_targ_addr_o = 1'sb0;
		hwlp_dec_cnt_o = 1'sb0;
		begin : sv2v_autoblock_2
			integer _sv2v_value_on_break;
			for (j = 0; j < N_REGS; j = j + 1)
				if (_sv2v_jump < 2'b10) begin
					_sv2v_jump = 2'b00;
					if (pc_is_end_addr[j]) begin
						hwlp_targ_addr_o = hwlp_start_addr_i[j * 32+:32];
						hwlp_dec_cnt_o[j] = 1'b1;
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
	assign hwlp_jump_o = |pc_is_end_addr;
endmodule
