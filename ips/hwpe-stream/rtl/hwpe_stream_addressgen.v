module hwpe_stream_addressgen (
	clk_i,
	rst_ni,
	test_mode_i,
	enable_i,
	clear_i,
	gen_addr_o,
	gen_strb_o,
	ctrl_i,
	flags_o
);
	localparam [31:0] hwpe_stream_package_HWPE_STREAM_REALIGN_SOURCE = 0;
	parameter [31:0] REALIGN_TYPE = hwpe_stream_package_HWPE_STREAM_REALIGN_SOURCE;
	parameter [31:0] STEP = 4;
	parameter [31:0] CNT = 10;
	parameter [31:0] DELAY_FLAGS = 0;
	input wire clk_i;
	input wire rst_ni;
	input wire test_mode_i;
	input wire enable_i;
	input wire clear_i;
	output wire [31:0] gen_addr_o;
	output wire [STEP - 1:0] gen_strb_o;
	input wire [153:0] ctrl_i;
	output wire [24:0] flags_o;
	wire [31:0] base_addr;
	wire [31:0] trans_size_m2;
	wire signed [15:0] line_stride;
	wire [15:0] line_length_m1;
	wire signed [15:0] feat_stride;
	wire [15:0] feat_length_m1;
	wire [15:0] feat_roll_m1;
	reg misalignment;
	reg misalignment_first;
	reg misalignment_last;
	wire [31:0] gen_addr_int;
	wire enable_int;
	wire last_packet;
	reg [15:0] overall_counter;
	reg [CNT - 1:0] word_counter;
	reg [CNT - 1:0] line_counter;
	reg [CNT - 1:0] feat_counter;
	reg [31:0] word_addr;
	reg [31:0] line_addr;
	reg [31:0] feat_addr;
	reg [STEP - 1:0] gen_strb_int;
	reg [STEP - 1:0] gen_strb_r;
	reg [24:0] flags;
	assign base_addr = ctrl_i[153-:32];
	assign trans_size_m2 = (misalignment == 1'b0 ? ctrl_i[121-:32] - 2 : ctrl_i[121-:32] - 1);
	assign line_stride = ctrl_i[89-:16];
	assign line_length_m1 = (misalignment == 1'b0 ? ctrl_i[73-:16] - 1 : ctrl_i[73-:16]);
	assign feat_stride = ctrl_i[57-:16];
	assign feat_length_m1 = ctrl_i[41-:16] - 1;
	assign feat_roll_m1 = ctrl_i[25-:16] - 1;
	localparam [31:0] hwpe_stream_package_HWPE_STREAM_REALIGN_SINK = 1;
	generate
		if (REALIGN_TYPE == hwpe_stream_package_HWPE_STREAM_REALIGN_SINK) begin : last_packet_sink_gen
			assign last_packet = ((misalignment == 1'b1) && (overall_counter == trans_size_m2) ? 1'b1 : 1'b0);
		end
		else begin : last_packet_source_gen
			assign last_packet = 1'b0;
		end
	endgenerate
	assign enable_int = enable_i | last_packet;
	always @(posedge clk_i or negedge rst_ni)
		if (~rst_ni)
			flags[20] <= 1'sb0;
		else if (clear_i)
			flags[20] <= 1'sb0;
		else if (enable_int)
			flags[20] <= ((misalignment == 1'b1) && (overall_counter == trans_size_m2) ? 1'b1 : 1'b0);
	always @(*)
		if (enable_int == 1'b1) begin
			if (word_counter < line_length_m1) begin
				flags[3] = 1'b1;
				flags[2] = 1'b0;
				flags[1] = 1'b0;
			end
			else if (line_counter < feat_length_m1) begin
				flags[3] = 1'b1;
				flags[2] = 1'b1;
				flags[1] = 1'b0;
			end
			else begin
				flags[3] = 1'b1;
				flags[2] = 1'b1;
				flags[1] = 1'b1;
			end
		end
		else begin
			flags[3] = 1'b0;
			flags[2] = 1'b0;
			flags[1] = 1'b0;
		end
	always @(*) begin : misalignment_last_flags_comb
		if (word_counter < line_length_m1)
			misalignment_last <= 1'sb0;
		else
			misalignment_last <= 1'sb1;
	end
	always @(*) begin : misalignment_first_flags_comb
		misalignment_first = 1'sb0;
		if (word_counter == {CNT {1'sb0}})
			misalignment_first = 1'sb1;
	end
	always @(posedge clk_i or negedge rst_ni) begin : address_gen_counters_proc
		if (rst_ni == 1'b0) begin
			word_addr <= 1'sb0;
			line_addr <= 1'sb0;
			feat_addr <= 1'sb0;
			word_counter <= 1'sb0;
			line_counter <= 1'sb0;
			feat_counter <= 1'sb0;
			overall_counter <= 1'sb0;
		end
		else if (clear_i == 1'b1) begin
			word_addr <= 1'sb0;
			line_addr <= 1'sb0;
			feat_addr <= 1'sb0;
			word_counter <= 1'sb0;
			line_counter <= 1'sb0;
			feat_counter <= 1'sb0;
			overall_counter <= 1'sb0;
		end
		else if (enable_int == 1'b0) begin
			word_addr <= word_addr;
			line_addr <= line_addr;
			feat_addr <= feat_addr;
			word_counter <= word_counter;
			line_counter <= line_counter;
			feat_counter <= feat_counter;
			overall_counter <= overall_counter;
		end
		else begin
			if (word_counter < line_length_m1) begin
				word_addr <= word_addr + STEP;
				line_addr <= line_addr;
				feat_addr <= feat_addr;
				word_counter <= word_counter + 1;
				line_counter <= line_counter;
				feat_counter <= feat_counter;
			end
			else if (line_counter < feat_length_m1) begin
				word_addr <= 1'sb0;
				line_addr <= line_addr + {{16 {line_stride[15]}}, line_stride};
				feat_addr <= feat_addr;
				word_counter <= 1'sb0;
				line_counter <= line_counter + 1;
				feat_counter <= feat_counter;
			end
			else if ((ctrl_i[9] == 1'b1) && ((feat_counter == feat_roll_m1) || (ctrl_i[25-:16] == {16 {1'sb0}}))) begin
				word_addr <= 1'sb0;
				line_addr <= 1'sb0;
				feat_addr <= feat_addr + {{16 {feat_stride[15]}}, feat_stride};
				word_counter <= 1'sb0;
				line_counter <= 1'sb0;
				feat_counter <= 1'sb0;
			end
			else if ((ctrl_i[9] == 1'b1) && ((feat_counter < feat_roll_m1) || (ctrl_i[25-:16] == {16 {1'sb0}}))) begin
				word_addr <= 1'sb0;
				line_addr <= 1'sb0;
				feat_addr <= feat_addr;
				word_counter <= 1'sb0;
				line_counter <= 1'sb0;
				feat_counter <= feat_counter + 1;
			end
			else if ((ctrl_i[9] == 1'b0) && ((feat_counter < feat_roll_m1) || (ctrl_i[25-:16] == {16 {1'sb0}}))) begin
				word_addr <= 1'sb0;
				line_addr <= 1'sb0;
				feat_addr <= feat_addr + {{16 {feat_stride[15]}}, feat_stride};
				word_counter <= 1'sb0;
				line_counter <= 1'sb0;
				feat_counter <= feat_counter + 1;
			end
			else begin
				word_addr <= 1'sb0;
				line_addr <= 1'sb0;
				feat_addr <= 1'sb0;
				word_counter <= 1'sb0;
				line_counter <= 1'sb0;
				feat_counter <= 1'sb0;
			end
			if (~misalignment | ~misalignment_first)
				overall_counter <= overall_counter + 1;
		end
	end
	generate
		if (REALIGN_TYPE == hwpe_stream_package_HWPE_STREAM_REALIGN_SOURCE) begin : genblk2
			always @(posedge clk_i or negedge rst_ni)
				if (rst_ni == 1'b0)
					flags[0] <= 1'b1;
				else if (clear_i == 1'b1)
					flags[0] <= 1'b1;
				else if (trans_size_m2 == {32 {1'sb1}})
					flags[0] <= 1'b0;
				else if (overall_counter < trans_size_m2)
					flags[0] <= 1'b1;
				else if ((overall_counter == trans_size_m2) && (enable_int == 1'b0))
					flags[0] <= 1'b1;
				else
					flags[0] <= 1'b0;
		end
		else begin : genblk2
			always @(posedge clk_i or negedge rst_ni)
				if (rst_ni == 1'b0)
					flags[0] <= 1'b1;
				else if (clear_i == 1'b1)
					flags[0] <= 1'b1;
				else if (trans_size_m2 == {32 {1'sb1}})
					flags[0] <= (overall_counter == {16 {1'sb0}} ? 1'b1 : 1'b0);
				else if (overall_counter < trans_size_m2)
					flags[0] <= 1'b1;
				else if ((overall_counter == trans_size_m2) && (enable_int == 1'b0))
					flags[0] <= 1'b1;
				else
					flags[0] <= 1'b0;
		end
	endgenerate
	assign gen_addr_int = ((base_addr + feat_addr) + line_addr) + word_addr;
	always @(posedge clk_i or negedge rst_ni)
		if (~rst_ni)
			misalignment <= 1'b0;
		else if (clear_i)
			misalignment <= 1'b0;
		else
			misalignment <= (base_addr[1:0] != {2 {1'sb0}} ? 1'b1 : (line_stride[1:0] != {2 {1'sb0}} ? 1'b1 : (feat_stride[1:0] != {2 {1'sb0}} ? 1'b1 : 1'b0)));
	assign gen_addr_o = {gen_addr_int[31:2], 2'b00};
	wire [1:1] sv2v_tmp_8DB3E;
	assign sv2v_tmp_8DB3E = misalignment;
	always @(*) flags[24] = sv2v_tmp_8DB3E;
	wire [1:1] sv2v_tmp_C5F1D;
	assign sv2v_tmp_C5F1D = misalignment;
	always @(*) flags[23] = sv2v_tmp_C5F1D;
	wire [1:1] sv2v_tmp_8789D;
	assign sv2v_tmp_8789D = misalignment_first;
	always @(*) flags[22] = sv2v_tmp_8789D;
	wire [1:1] sv2v_tmp_147B1;
	assign sv2v_tmp_147B1 = misalignment_last;
	always @(*) flags[21] = sv2v_tmp_147B1;
	wire [16:1] sv2v_tmp_48A05;
	assign sv2v_tmp_48A05 = ctrl_i[73-:16];
	always @(*) flags[19-:16] = sv2v_tmp_48A05;
	reg [24:0] aux;
	generate
		if (REALIGN_TYPE == hwpe_stream_package_HWPE_STREAM_REALIGN_SOURCE) begin : genblk3
			always @(*) begin
				gen_strb_int = 1'sb1;
				if (misalignment) begin
					if (misalignment_first)
						gen_strb_int = gen_strb_int << gen_addr_int[$clog2(STEP) - 1:0];
					if (misalignment_last)
						gen_strb_int = ~(gen_strb_int << gen_addr_int[$clog2(STEP) - 1:0]);
				end
			end
			assign flags_o[24-:21] = aux[24-:21];
			assign gen_strb_o = gen_strb_r;
		end
		else begin : genblk3
			reg [STEP - 1:0] line_length_remainder_strb;
			genvar ii;
			for (ii = 0; ii < STEP; ii = ii + 1) begin : line_length_remainder_strb_gen
				always @(*)
					if (ctrl_i[7-:8] >= ii)
						line_length_remainder_strb[ii] = 1'b1;
					else
						line_length_remainder_strb[ii] = 1'b0;
			end
			always @(*) begin
				gen_strb_int = 1'sb1;
				if (misalignment)
					if (misalignment_first)
						gen_strb_int = gen_strb_int << gen_addr_int[$clog2(STEP) - 1:0];
				if (misalignment_last & (misalignment | (ctrl_i[7-:8] != {8 {1'sb0}}))) begin
					gen_strb_int = line_length_remainder_strb;
					gen_strb_int = ~(gen_strb_int << gen_addr_int[$clog2(STEP) - 1:0]);
				end
			end
			assign flags_o[24-:21] = flags[24-:21];
			assign gen_strb_o = gen_strb_int;
		end
	endgenerate
	assign flags_o[3] = aux[3];
	assign flags_o[2] = aux[2];
	assign flags_o[1] = aux[1];
	assign flags_o[0] = aux[0];
	generate
		if (DELAY_FLAGS) begin : delay_flags_gen
			always @(posedge clk_i or negedge rst_ni)
				if (~rst_ni) begin
					aux <= 1'sb0;
					gen_strb_r <= 1'sb0;
				end
				else if (clear_i) begin
					aux <= 1'sb0;
					gen_strb_r <= 1'sb0;
				end
				else begin
					aux <= flags;
					gen_strb_r <= gen_strb_int;
				end
		end
		else begin : no_delay_flags_gen
			wire [25:1] sv2v_tmp_94057;
			assign sv2v_tmp_94057 = flags;
			always @(*) aux = sv2v_tmp_94057;
			wire [STEP:1] sv2v_tmp_3A529;
			assign sv2v_tmp_3A529 = gen_strb_int;
			always @(*) gen_strb_r = sv2v_tmp_3A529;
		end
	endgenerate
endmodule
