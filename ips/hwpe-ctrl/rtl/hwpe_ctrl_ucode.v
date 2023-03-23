module hwpe_ctrl_ucode (
	clk_i,
	rst_ni,
	test_mode_i,
	clear_i,
	ctrl_i,
	flags_o,
	ucode_i,
	registers_read_i
);
	localparam [31:0] hwpe_ctrl_package_UCODE_NB_LOOPS = 6;
	parameter [31:0] LENGTH = hwpe_ctrl_package_UCODE_NB_LOOPS;
	localparam [31:0] hwpe_ctrl_package_UCODE_LENGTH = 16;
	parameter [31:0] NB_LOOPS = hwpe_ctrl_package_UCODE_LENGTH;
	localparam [31:0] hwpe_ctrl_package_UCODE_NB_RO_REG = 28;
	parameter [31:0] NB_RO_REG = hwpe_ctrl_package_UCODE_NB_RO_REG;
	localparam [31:0] hwpe_ctrl_package_UCODE_NB_REG = 4;
	parameter [31:0] NB_REG = hwpe_ctrl_package_UCODE_NB_REG;
	localparam [31:0] hwpe_ctrl_package_UCODE_REG_WIDTH = 32;
	parameter [31:0] REG_WIDTH = hwpe_ctrl_package_UCODE_REG_WIDTH;
	localparam [31:0] hwpe_ctrl_package_UCODE_CNT_WIDTH = 12;
	parameter [31:0] CNT_WIDTH = hwpe_ctrl_package_UCODE_CNT_WIDTH;
	input wire clk_i;
	input wire rst_ni;
	input wire test_mode_i;
	input wire clear_i;
	input wire [4:0] ctrl_i;
	output reg [(130 + (hwpe_ctrl_package_UCODE_NB_LOOPS * hwpe_ctrl_package_UCODE_CNT_WIDTH)) + 0:0] flags_o;
	input wire [(224 + (hwpe_ctrl_package_UCODE_NB_LOOPS * hwpe_ctrl_package_UCODE_CNT_WIDTH)) - 1:0] ucode_i;
	input wire [(NB_RO_REG * REG_WIDTH) - 1:0] registers_read_i;
	reg [2:0] curr_op;
	reg [2:0] next_op;
	reg [$clog2(LENGTH) - 1:0] curr_addr;
	reg [$clog2(LENGTH) - 1:0] next_addr;
	reg [$clog2(NB_LOOPS) - 1:0] curr_loop;
	reg [$clog2(NB_LOOPS) - 1:0] next_loop;
	reg [(NB_LOOPS * CNT_WIDTH) - 1:0] curr_idx;
	reg [(NB_LOOPS * CNT_WIDTH) - 1:0] next_idx;
	reg [(NB_REG * REG_WIDTH) - 1:0] registers;
	reg [(NB_REG * REG_WIDTH) - 1:0] next_registers;
	wire [((NB_RO_REG + NB_REG) * REG_WIDTH) - 1:0] registers_read;
	wire [REG_WIDTH - 1:0] ucode_execute_add;
	wire [REG_WIDTH - 1:0] ucode_execute;
	reg busy_int;
	reg busy_sticky;
	wire accum_int;
	reg [31:0] curr_accum_state;
	reg [31:0] next_accum_state;
	reg done_int;
	reg done_sticky;
	reg exec_int;
	always @(posedge clk_i or negedge rst_ni)
		if (~rst_ni) begin
			busy_sticky <= 1'sb0;
			done_sticky <= 1'sb0;
			flags_o[129 + ((hwpe_ctrl_package_UCODE_NB_LOOPS * hwpe_ctrl_package_UCODE_CNT_WIDTH) + 0)] <= 1'sb0;
		end
		else if (clear_i | ctrl_i[3]) begin
			busy_sticky <= 1'sb0;
			done_sticky <= 1'sb0;
			flags_o[129 + ((hwpe_ctrl_package_UCODE_NB_LOOPS * hwpe_ctrl_package_UCODE_CNT_WIDTH) + 0)] <= 1'sb0;
		end
		else begin
			flags_o[129 + ((hwpe_ctrl_package_UCODE_NB_LOOPS * hwpe_ctrl_package_UCODE_CNT_WIDTH) + 0)] <= busy_sticky & ~busy_int;
			if (~busy_int)
				busy_sticky <= 1'b0;
			else if (ctrl_i[4])
				busy_sticky <= 1'b1;
			if (done_int)
				done_sticky <= 1'b1;
			else if (flags_o[129 + ((hwpe_ctrl_package_UCODE_NB_LOOPS * hwpe_ctrl_package_UCODE_CNT_WIDTH) + 0)])
				done_sticky <= 1'b0;
		end
	wire [1:1] sv2v_tmp_09F38;
	assign sv2v_tmp_09F38 = done_int | done_sticky;
	always @(*) flags_o[130 + ((hwpe_ctrl_package_UCODE_NB_LOOPS * hwpe_ctrl_package_UCODE_CNT_WIDTH) + 0)] = sv2v_tmp_09F38;
	assign accum_int = (curr_loop == ctrl_i[2-:3] ? 1'b1 : 1'b0);
	always @(posedge clk_i or negedge rst_ni) begin : accum_flag_fsm_seq
		if (~rst_ni)
			curr_accum_state <= 32'd0;
		else if (clear_i | ctrl_i[3])
			curr_accum_state <= 32'd0;
		else
			curr_accum_state <= next_accum_state;
	end
	always @(*) begin : accum_flag_fsm_comb
		next_accum_state = curr_accum_state;
		case (curr_accum_state)
			32'd0:
				if (accum_int)
					next_accum_state = 32'd1;
			32'd1:
				if (flags_o[129 + ((hwpe_ctrl_package_UCODE_NB_LOOPS * hwpe_ctrl_package_UCODE_CNT_WIDTH) + 0)])
					next_accum_state = 32'd2;
			32'd2:
				if (accum_int & flags_o[129 + ((hwpe_ctrl_package_UCODE_NB_LOOPS * hwpe_ctrl_package_UCODE_CNT_WIDTH) + 0)])
					next_accum_state = 32'd2;
				else if (accum_int)
					next_accum_state = 32'd1;
				else if (flags_o[129 + ((hwpe_ctrl_package_UCODE_NB_LOOPS * hwpe_ctrl_package_UCODE_CNT_WIDTH) + 0)])
					next_accum_state = 32'd0;
		endcase
	end
	wire [1:1] sv2v_tmp_84F6A;
	assign sv2v_tmp_84F6A = (next_accum_state == 32'd0 ? 1'b0 : 1'b1);
	always @(*) flags_o[0] = sv2v_tmp_84F6A;
	string str = "";
	always @(posedge clk_i or negedge rst_ni)
		if (rst_ni)
			if (ctrl_i[4])
				$display("@%d [%d, %d, %d, %d, %d, %d]%s", curr_addr, curr_idx[5 * CNT_WIDTH+:CNT_WIDTH], curr_idx[4 * CNT_WIDTH+:CNT_WIDTH], curr_idx[3 * CNT_WIDTH+:CNT_WIDTH], curr_idx[2 * CNT_WIDTH+:CNT_WIDTH], curr_idx[CNT_WIDTH+:CNT_WIDTH], curr_idx[0+:CNT_WIDTH], str);
	always @(*) begin : ucode_fetch_comb
		next_addr = curr_addr;
		next_loop = curr_loop;
		next_op = curr_op;
		next_idx = curr_idx;
		done_int = 1'b0;
		busy_int = 1'b0;
		exec_int = 1'b0;
		if ((curr_idx[curr_loop * CNT_WIDTH+:CNT_WIDTH] < (ucode_i[((hwpe_ctrl_package_UCODE_NB_LOOPS * hwpe_ctrl_package_UCODE_CNT_WIDTH) - 1) - (((hwpe_ctrl_package_UCODE_NB_LOOPS * hwpe_ctrl_package_UCODE_CNT_WIDTH) - 1) - (curr_loop * hwpe_ctrl_package_UCODE_CNT_WIDTH))+:hwpe_ctrl_package_UCODE_CNT_WIDTH] - 1)) && (curr_op < (ucode_i[(48 + ((hwpe_ctrl_package_UCODE_NB_LOOPS * hwpe_ctrl_package_UCODE_CNT_WIDTH) + 175)) - (47 - ((curr_loop * 8) + 2))-:3] - 1))) begin
			str = " UPDATE CURRENT LOOP                      ";
			next_addr = curr_addr + 1;
			next_op = curr_op + 1;
			busy_int = 1'b1;
			exec_int = 1'b1;
		end
		else if ((curr_idx[curr_loop * CNT_WIDTH+:CNT_WIDTH] < (ucode_i[((hwpe_ctrl_package_UCODE_NB_LOOPS * hwpe_ctrl_package_UCODE_CNT_WIDTH) - 1) - (((hwpe_ctrl_package_UCODE_NB_LOOPS * hwpe_ctrl_package_UCODE_CNT_WIDTH) - 1) - (curr_loop * hwpe_ctrl_package_UCODE_CNT_WIDTH))+:hwpe_ctrl_package_UCODE_CNT_WIDTH] - 1)) && (curr_loop > 0)) begin
			str = " ITERATE CURRENT LOOP & GOTO LOOP 0       ";
			next_loop = 0;
			begin : sv2v_autoblock_1
				reg signed [31:0] j;
				for (j = 0; j < NB_LOOPS; j = j + 1)
					if (curr_loop > j)
						next_idx[j * CNT_WIDTH+:CNT_WIDTH] = 0;
					else if (curr_loop == j)
						next_idx[j * CNT_WIDTH+:CNT_WIDTH] = curr_idx[curr_loop * CNT_WIDTH+:CNT_WIDTH] + 1;
			end
			next_addr = ucode_i[(48 + ((hwpe_ctrl_package_UCODE_NB_LOOPS * hwpe_ctrl_package_UCODE_CNT_WIDTH) + 175)) - 40-:5];
			next_op = 1'sb0;
			exec_int = 1'b1;
		end
		else if (curr_idx[curr_loop * CNT_WIDTH+:CNT_WIDTH] < (ucode_i[((hwpe_ctrl_package_UCODE_NB_LOOPS * hwpe_ctrl_package_UCODE_CNT_WIDTH) - 1) - (((hwpe_ctrl_package_UCODE_NB_LOOPS * hwpe_ctrl_package_UCODE_CNT_WIDTH) - 1) - (curr_loop * hwpe_ctrl_package_UCODE_CNT_WIDTH))+:hwpe_ctrl_package_UCODE_CNT_WIDTH] - 1)) begin
			str = " ITERATE CURRENT LOOP                     ";
			next_addr = ucode_i[(48 + ((hwpe_ctrl_package_UCODE_NB_LOOPS * hwpe_ctrl_package_UCODE_CNT_WIDTH) + 175)) - (47 - ((curr_loop * 8) + 7))-:5];
			next_op = 1'sb0;
			next_idx[curr_loop * CNT_WIDTH+:CNT_WIDTH] = curr_idx + 1;
			exec_int = 1'b1;
		end
		else if (curr_loop < (NB_LOOPS - 1)) begin
			str = " GOTO NEXT LOOP                           ";
			next_loop = curr_loop + 1;
			next_addr = ucode_i[(48 + ((hwpe_ctrl_package_UCODE_NB_LOOPS * hwpe_ctrl_package_UCODE_CNT_WIDTH) + 175)) - (47 - (((curr_loop + 1) * 8) + 7))-:5];
			next_op = 1'sb0;
		end
		else begin
			str = " TERMINATE                                ";
			next_loop = 1'sb0;
			next_addr = 1'sb0;
			next_op = 1'sb0;
			next_idx = 1'sb0;
			done_int = 1'b1;
		end
	end
	always @(posedge clk_i or negedge rst_ni) begin : ucode_fetch_seq
		if (~rst_ni) begin
			curr_addr <= 1'sb0;
			curr_loop <= 1'sb0;
			curr_op <= 1'sb0;
			curr_idx <= 1'sb0;
		end
		else if (clear_i | ctrl_i[3]) begin
			curr_addr <= 1'sb0;
			curr_loop <= 1'sb0;
			curr_op <= 1'sb0;
			curr_idx <= 1'sb0;
		end
		else if (ctrl_i[4]) begin
			curr_addr <= next_addr;
			curr_loop <= next_loop;
			curr_op <= next_op;
			curr_idx <= next_idx;
		end
	end
	assign registers_read[REG_WIDTH * ((NB_REG - 1) - (NB_REG - 1))+:REG_WIDTH * NB_REG] = registers;
	assign registers_read[REG_WIDTH * ((((NB_RO_REG + NB_REG) - 1) >= NB_REG ? (NB_RO_REG + NB_REG) - 1 : (((NB_RO_REG + NB_REG) - 1) + (((NB_RO_REG + NB_REG) - 1) >= NB_REG ? (((NB_RO_REG + NB_REG) - 1) - NB_REG) + 1 : (NB_REG - ((NB_RO_REG + NB_REG) - 1)) + 1)) - 1) - ((((NB_RO_REG + NB_REG) - 1) >= NB_REG ? (((NB_RO_REG + NB_REG) - 1) - NB_REG) + 1 : (NB_REG - ((NB_RO_REG + NB_REG) - 1)) + 1) - 1))+:REG_WIDTH * (((NB_RO_REG + NB_REG) - 1) >= NB_REG ? (((NB_RO_REG + NB_REG) - 1) - NB_REG) + 1 : (NB_REG - ((NB_RO_REG + NB_REG) - 1)) + 1)] = registers_read_i;
	assign ucode_execute_add = registers_read[ucode_i[((hwpe_ctrl_package_UCODE_NB_LOOPS * hwpe_ctrl_package_UCODE_CNT_WIDTH) + 175) - (175 - ((curr_addr * 11) + 9))-:5] * REG_WIDTH+:REG_WIDTH] + registers_read[ucode_i[((hwpe_ctrl_package_UCODE_NB_LOOPS * hwpe_ctrl_package_UCODE_CNT_WIDTH) + 175) - (175 - ((curr_addr * 11) + 4))-:5] * REG_WIDTH+:REG_WIDTH];
	assign ucode_execute = (ucode_i[((32'd6 * 32'd12) + 175) - (175 - ((curr_addr * 11) + 10))] ? ucode_execute_add : registers_read[ucode_i[((hwpe_ctrl_package_UCODE_NB_LOOPS * hwpe_ctrl_package_UCODE_CNT_WIDTH) + 175) - (175 - ((curr_addr * 11) + 4))-:5] * REG_WIDTH+:REG_WIDTH]);
	always @(*) begin : ucode_execute_comb
		next_registers = registers;
		if (exec_int)
			next_registers[ucode_i[((hwpe_ctrl_package_UCODE_NB_LOOPS * hwpe_ctrl_package_UCODE_CNT_WIDTH) + 175) - (175 - ((curr_addr * 11) + 9))-:5] * REG_WIDTH+:REG_WIDTH] = ucode_execute;
	end
	always @(posedge clk_i or negedge rst_ni) begin : ucode_execute_sel
		if (~rst_ni)
			registers <= 1'sb0;
		else if (clear_i | ctrl_i[3])
			registers <= 1'sb0;
		else if (ctrl_i[4])
			registers <= next_registers;
	end
	genvar i;
	generate
		for (i = 0; i < NB_REG; i = i + 1) begin : flags_reg_assign
			wire [32:1] sv2v_tmp_96182;
			assign sv2v_tmp_96182 = registers[i * REG_WIDTH+:REG_WIDTH];
			always @(*) flags_o[(128 + ((hwpe_ctrl_package_UCODE_NB_LOOPS * hwpe_ctrl_package_UCODE_CNT_WIDTH) + 0)) - (127 - (i * 32))+:32] = sv2v_tmp_96182;
		end
		for (i = 0; i < NB_LOOPS; i = i + 1) begin : flags_idx_assign
			wire [12:1] sv2v_tmp_FD4D7;
			assign sv2v_tmp_FD4D7 = curr_idx[i * CNT_WIDTH+:CNT_WIDTH];
			always @(*) flags_o[((hwpe_ctrl_package_UCODE_NB_LOOPS * hwpe_ctrl_package_UCODE_CNT_WIDTH) + 0) - (((hwpe_ctrl_package_UCODE_NB_LOOPS * hwpe_ctrl_package_UCODE_CNT_WIDTH) - 1) - (i * hwpe_ctrl_package_UCODE_CNT_WIDTH))+:hwpe_ctrl_package_UCODE_CNT_WIDTH] = sv2v_tmp_FD4D7;
		end
	endgenerate
endmodule
