module udma_filter_au (
	clk_i,
	resetn_i,
	cfg_use_signed_i,
	cfg_bypass_i,
	cfg_mode_i,
	cfg_shift_i,
	cfg_reg0_i,
	cfg_reg1_i,
	cmd_start_i,
	operanda_data_i,
	operanda_datasize_i,
	operanda_valid_i,
	operanda_sof_i,
	operanda_eof_i,
	operanda_ready_o,
	operandb_data_i,
	operandb_datasize_i,
	operandb_valid_i,
	operandb_ready_o,
	output_data_o,
	output_datasize_o,
	output_valid_o,
	output_ready_i
);
	parameter DATA_WIDTH = 32;
	input wire clk_i;
	input wire resetn_i;
	input wire cfg_use_signed_i;
	input wire cfg_bypass_i;
	input wire [3:0] cfg_mode_i;
	input wire [4:0] cfg_shift_i;
	input wire [31:0] cfg_reg0_i;
	input wire [31:0] cfg_reg1_i;
	input wire cmd_start_i;
	input wire [DATA_WIDTH - 1:0] operanda_data_i;
	input wire [1:0] operanda_datasize_i;
	input wire operanda_valid_i;
	input wire operanda_sof_i;
	input wire operanda_eof_i;
	output wire operanda_ready_o;
	input wire [DATA_WIDTH - 1:0] operandb_data_i;
	input wire [1:0] operandb_datasize_i;
	input wire operandb_valid_i;
	output wire operandb_ready_o;
	output wire [DATA_WIDTH - 1:0] output_data_o;
	output wire [1:0] output_datasize_o;
	output wire output_valid_o;
	input wire output_ready_i;
	wire [65:0] s_mac;
	reg [31:0] s_sum;
	wire [31:0] s_opa;
	reg [31:0] s_opb;
	reg [31:0] r_accumulator;
	wire [31:0] s_outpostshift;
	reg [31:0] r_operanda;
	reg [31:0] r_operandb;
	reg s_en_opb;
	reg s_mulb_opa;
	reg s_mulb_opb;
	reg s_mulb_reg;
	reg s_sum_acc;
	reg s_sum_reg;
	reg s_sum_opb;
	reg s_sum_inv;
	reg r_sample_dly;
	reg r_sample_out;
	wire s_sample_opa;
	wire s_sample_opb;
	reg [DATA_WIDTH - 1:0] s_in_opa;
	reg [DATA_WIDTH - 1:0] s_in_opb;
	reg r_sof;
	reg r_eof;
	reg r_accoutvalid;
	always @(*) begin
		s_in_opa = operanda_data_i;
		case (operanda_datasize_i)
			2'b00: s_in_opa = $signed({operanda_data_i[7] & cfg_use_signed_i, operanda_data_i[7:0]});
			2'b01: s_in_opa = $signed({operanda_data_i[15] & cfg_use_signed_i, operanda_data_i[15:0]});
		endcase
	end
	always @(*) begin
		s_in_opb = operandb_data_i;
		case (operandb_datasize_i)
			2'b00: s_in_opb = $signed({operandb_data_i[7] & cfg_use_signed_i, operandb_data_i[7:0]});
			2'b01: s_in_opb = $signed({operandb_data_i[15] & cfg_use_signed_i, operandb_data_i[15:0]});
		endcase
	end
	assign s_outpostshift = $signed(r_accumulator) >>> cfg_shift_i;
	assign output_data_o = s_outpostshift[31:0];
	assign output_valid_o = (s_sum_acc ? r_accoutvalid : r_sample_out);
	assign output_datasize_o = operanda_datasize_i;
	assign s_mac = ($signed(s_opa) * $signed(s_opb)) + $signed({s_sum[31] & cfg_use_signed_i, s_sum});
	assign s_sample_opa = output_ready_i & (operanda_valid_i & ((cfg_bypass_i | !s_en_opb) | (s_en_opb & operandb_valid_i)));
	assign s_sample_opb = output_ready_i & (operanda_valid_i & (s_en_opb & operandb_valid_i));
	assign operanda_ready_o = s_sample_opa;
	assign operandb_ready_o = s_sample_opb;
	assign s_opa = r_operanda;
	always @(*) begin : proc_opb_mux
		s_opb = 32'h00000001;
		if (cfg_bypass_i)
			s_opb = 32'h00000001;
		else if (s_mulb_opb)
			s_opb = r_operandb;
		else if (s_mulb_reg)
			s_opb = cfg_reg1_i;
		else if (s_mulb_opa)
			s_opb = r_operanda;
	end
	always @(*) begin : proc_sum_mux
		s_sum = 0;
		if (cfg_bypass_i)
			s_sum = 32'h00000000;
		else if (s_sum_opb)
			s_sum = r_operandb;
		else if (s_sum_reg)
			s_sum = cfg_reg0_i;
		else if (s_sum_acc & !r_sof)
			s_sum = r_accumulator;
	end
	always @(*) begin
		s_en_opb = 1'b1;
		s_mulb_opa = 1'b0;
		s_mulb_opb = 1'b0;
		s_mulb_reg = 1'b0;
		s_sum_acc = 1'b0;
		s_sum_reg = 1'b0;
		s_sum_opb = 1'b0;
		s_sum_inv = 1'b0;
		case (cfg_mode_i)
			0: s_mulb_opb = 1'b1;
			1: begin
				s_mulb_opb = 1'b1;
				s_sum_reg = 1'b1;
			end
			2: begin
				s_mulb_opb = 1'b1;
				s_sum_acc = 1'b1;
			end
			3: begin
				s_en_opb = 1'b0;
				s_mulb_opa = 1'b1;
			end
			4: begin
				s_mulb_opa = 1'b1;
				s_sum_opb = 1'b1;
			end
			5: begin
				s_mulb_opa = 1'b1;
				s_sum_opb = 1'b1;
				s_sum_inv = 1'b1;
			end
			6: begin
				s_en_opb = 1'b0;
				s_mulb_opa = 1'b1;
				s_sum_acc = 1'b1;
			end
			7: begin
				s_en_opb = 1'b0;
				s_mulb_opa = 1'b1;
				s_sum_reg = 1'b1;
			end
			8: begin
				s_en_opb = 1'b0;
				s_mulb_reg = 1'b1;
			end
			9: begin
				s_mulb_reg = 1'b1;
				s_sum_opb = 1'b1;
			end
			10: begin
				s_mulb_reg = 1'b1;
				s_sum_opb = 1'b1;
				s_sum_inv = 1'b1;
			end
			11: begin
				s_en_opb = 1'b0;
				s_mulb_reg = 1'b1;
				s_sum_reg = 1'b1;
			end
			12: begin
				s_en_opb = 1'b0;
				s_mulb_reg = 1'b1;
				s_sum_acc = 1'b1;
			end
			13: s_sum_opb = 1'b1;
			14: begin
				s_sum_opb = 1'b1;
				s_sum_inv = 1'b1;
			end
			15: begin
				s_en_opb = 1'b0;
				s_sum_reg = 1'b1;
			end
		endcase
	end
	always @(posedge clk_i or negedge resetn_i)
		if (~resetn_i) begin
			r_accumulator <= 0;
			r_sample_dly <= 1'b0;
			r_sample_out <= 1'b0;
			r_operanda <= 0;
			r_operandb <= 0;
			r_sof <= 1'b0;
			r_eof <= 1'b0;
			r_accoutvalid <= 0;
		end
		else if (cmd_start_i) begin
			r_sample_dly <= 1'b0;
			r_sample_out <= 1'b0;
			r_accoutvalid <= 1'b0;
			r_sof <= 1'b0;
			r_eof <= 1'b0;
		end
		else if (output_ready_i) begin
			r_sample_dly <= s_sample_opa;
			r_sample_out <= r_sample_dly;
			r_accoutvalid <= r_eof;
			r_sof <= operanda_sof_i & s_sample_opa;
			r_eof <= operanda_eof_i & s_sample_opa;
			if (r_sample_dly)
				r_accumulator <= s_mac[31:0];
			if (s_sample_opa)
				r_operanda <= s_in_opa;
			if (s_sample_opb)
				r_operandb <= s_in_opb;
		end
endmodule
