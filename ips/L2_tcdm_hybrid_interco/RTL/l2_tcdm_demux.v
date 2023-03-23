module l2_tcdm_demux (
	clk,
	rst_n,
	test_en_i,
	data_req_i,
	data_add_i,
	data_wen_i,
	data_wdata_i,
	data_be_i,
	data_aux_i,
	data_gnt_o,
	data_r_aux_o,
	data_r_valid_o,
	data_r_rdata_o,
	data_r_opc_o,
	data_req_o_TDCM,
	data_add_o_TDCM,
	data_wen_o_TDCM,
	data_wdata_o_TDCM,
	data_be_o_TDCM,
	data_gnt_i_TDCM,
	data_r_valid_i_TDCM,
	data_r_rdata_i_TDCM,
	data_req_o_PER,
	data_add_o_PER,
	data_wen_o_PER,
	data_wdata_o_PER,
	data_be_o_PER,
	data_aux_o_PER,
	data_gnt_i_PER,
	data_r_valid_i_PER,
	data_r_rdata_i_PER,
	data_r_opc_i_PER,
	data_r_aux_i_PER,
	PER_START_ADDR,
	PER_END_ADDR,
	TCDM_START_ADDR,
	TCDM_END_ADDR
);
	parameter ADDR_WIDTH = 32;
	parameter DATA_WIDTH = 32;
	parameter BE_WIDTH = DATA_WIDTH / 8;
	parameter AUX_WIDTH = 4;
	parameter [31:0] N_PERIPHS = 2;
	input wire clk;
	input wire rst_n;
	input wire test_en_i;
	input wire data_req_i;
	input wire [ADDR_WIDTH - 1:0] data_add_i;
	input wire data_wen_i;
	input wire [DATA_WIDTH - 1:0] data_wdata_i;
	input wire [BE_WIDTH - 1:0] data_be_i;
	input wire [AUX_WIDTH - 1:0] data_aux_i;
	output reg data_gnt_o;
	output reg [AUX_WIDTH - 1:0] data_r_aux_o;
	output reg data_r_valid_o;
	output reg [DATA_WIDTH - 1:0] data_r_rdata_o;
	output reg data_r_opc_o;
	output reg data_req_o_TDCM;
	output wire [ADDR_WIDTH - 1:0] data_add_o_TDCM;
	output wire data_wen_o_TDCM;
	output wire [DATA_WIDTH - 1:0] data_wdata_o_TDCM;
	output wire [BE_WIDTH - 1:0] data_be_o_TDCM;
	input wire data_gnt_i_TDCM;
	input wire data_r_valid_i_TDCM;
	input wire [DATA_WIDTH - 1:0] data_r_rdata_i_TDCM;
	output reg data_req_o_PER;
	output wire [ADDR_WIDTH - 1:0] data_add_o_PER;
	output wire data_wen_o_PER;
	output wire [DATA_WIDTH - 1:0] data_wdata_o_PER;
	output wire [BE_WIDTH - 1:0] data_be_o_PER;
	output wire [AUX_WIDTH - 1:0] data_aux_o_PER;
	input wire data_gnt_i_PER;
	input wire data_r_valid_i_PER;
	input wire [DATA_WIDTH - 1:0] data_r_rdata_i_PER;
	input wire data_r_opc_i_PER;
	input wire [AUX_WIDTH - 1:0] data_r_aux_i_PER;
	input wire [(N_PERIPHS * ADDR_WIDTH) - 1:0] PER_START_ADDR;
	input wire [(N_PERIPHS * ADDR_WIDTH) - 1:0] PER_END_ADDR;
	input wire [ADDR_WIDTH - 1:0] TCDM_START_ADDR;
	input wire [ADDR_WIDTH - 1:0] TCDM_END_ADDR;
	reg [1:0] CS;
	reg [1:0] NS;
	wire [(N_PERIPHS >= 0 ? ((N_PERIPHS + 1) * ADDR_WIDTH) - 1 : ((1 - N_PERIPHS) * ADDR_WIDTH) + ((N_PERIPHS * ADDR_WIDTH) - 1)):(N_PERIPHS >= 0 ? 0 : N_PERIPHS * ADDR_WIDTH)] ADDR_START;
	wire [(N_PERIPHS >= 0 ? ((N_PERIPHS + 1) * ADDR_WIDTH) - 1 : ((1 - N_PERIPHS) * ADDR_WIDTH) + ((N_PERIPHS * ADDR_WIDTH) - 1)):(N_PERIPHS >= 0 ? 0 : N_PERIPHS * ADDR_WIDTH)] ADDR_END;
	reg [N_PERIPHS:0] destination_OH;
	assign ADDR_START = {TCDM_START_ADDR, PER_START_ADDR};
	assign ADDR_END = {TCDM_END_ADDR, PER_END_ADDR};
	assign data_add_o_TDCM = data_add_i;
	assign data_wen_o_TDCM = data_wen_i;
	assign data_wdata_o_TDCM = data_wdata_i;
	assign data_be_o_TDCM = data_be_i;
	assign data_add_o_PER = data_add_i;
	assign data_wen_o_PER = data_wen_i;
	assign data_wdata_o_PER = data_wdata_i;
	assign data_be_o_PER = data_be_i;
	assign data_aux_o_PER = data_aux_i;
	reg sample_aux;
	reg [AUX_WIDTH - 1:0] sampled_data_aux;
	always @(*) begin
		destination_OH = 1'sb0;
		begin : sv2v_autoblock_1
			reg [31:0] x;
			for (x = 0; x < (N_PERIPHS + 1); x = x + 1)
				if ((data_add_i >= ADDR_START[(N_PERIPHS >= 0 ? x : N_PERIPHS - x) * ADDR_WIDTH+:ADDR_WIDTH]) && (data_add_i < ADDR_END[(N_PERIPHS >= 0 ? x : N_PERIPHS - x) * ADDR_WIDTH+:ADDR_WIDTH]))
					destination_OH[x] = 1'b1;
		end
	end
	always @(posedge clk or negedge rst_n)
		if (~rst_n) begin
			CS <= 2'd0;
			sampled_data_aux <= 1'sb0;
		end
		else begin
			CS <= NS;
			if (sample_aux)
				sampled_data_aux <= data_aux_i;
		end
	always @(*) begin
		data_req_o_TDCM = 1'b0;
		data_req_o_PER = 1'b0;
		data_gnt_o = 1'b0;
		sample_aux = 1'sb0;
		data_r_opc_o = 1'b0;
		data_r_valid_o = 1'b0;
		data_r_aux_o = sampled_data_aux;
		data_r_rdata_o = data_r_rdata_i_TDCM;
		case (CS)
			2'd0:
				if (data_req_i) begin
					if (destination_OH[N_PERIPHS] == 1'b1) begin
						data_req_o_TDCM = 1'b1;
						data_gnt_o = data_gnt_i_TDCM;
						sample_aux = data_gnt_i_TDCM;
						if (data_gnt_i_TDCM)
							NS = 2'd1;
						else
							NS = 2'd0;
					end
					else if (|destination_OH[N_PERIPHS - 1:0] == 1'b1) begin
						data_req_o_PER = 1'b1;
						data_gnt_o = data_gnt_i_PER;
						if (data_gnt_i_PER)
							NS = 2'd2;
						else
							NS = 2'd0;
					end
					else begin
						NS = 2'd3;
						data_gnt_o = 1'b1;
					end
				end
				else
					NS = 2'd0;
			2'd1: begin
				data_r_valid_o = 1'b1;
				data_r_aux_o = sampled_data_aux;
				data_r_rdata_o = data_r_rdata_i_TDCM;
				if (data_req_i) begin
					if (destination_OH[N_PERIPHS] == 1'b1) begin
						data_req_o_TDCM = 1'b1;
						data_gnt_o = data_gnt_i_TDCM;
						sample_aux = data_gnt_i_TDCM;
						if (data_gnt_i_TDCM)
							NS = 2'd1;
						else
							NS = 2'd0;
					end
					else if (|destination_OH[N_PERIPHS - 1:0] == 1'b1) begin
						data_req_o_PER = 1'b1;
						data_gnt_o = data_gnt_i_PER;
						if (data_gnt_i_PER)
							NS = 2'd2;
						else
							NS = 2'd0;
					end
					else begin
						NS = 2'd3;
						data_gnt_o = 1'b1;
						sample_aux = 1'b1;
					end
				end
				else
					NS = 2'd0;
			end
			2'd2: begin
				data_r_valid_o = data_r_valid_i_PER;
				data_r_aux_o = data_r_aux_i_PER;
				data_r_rdata_o = data_r_rdata_i_PER;
				data_r_opc_o = data_r_opc_i_PER;
				if (data_r_valid_i_PER) begin
					if (data_req_i) begin
						if (destination_OH[N_PERIPHS] == 1'b1) begin
							data_req_o_TDCM = 1'b1;
							data_gnt_o = data_gnt_i_TDCM;
							sample_aux = data_gnt_i_TDCM;
							if (data_gnt_i_TDCM)
								NS = 2'd1;
							else
								NS = 2'd0;
						end
						else if (|destination_OH[N_PERIPHS - 1:0] == 1'b1) begin
							data_req_o_PER = 1'b1;
							data_gnt_o = data_gnt_i_PER;
							if (data_gnt_i_PER)
								NS = 2'd2;
							else
								NS = 2'd0;
						end
						else begin
							NS = 2'd3;
							data_gnt_o = 1'b1;
						end
					end
					else
						NS = 2'd0;
				end
				else
					NS = 2'd2;
			end
			2'd3: begin
				data_r_valid_o = 1'b1;
				data_r_aux_o = sampled_data_aux;
				data_r_rdata_o = 32'hbadacce5;
				NS = 2'd0;
				data_r_opc_o = 1'b1;
			end
		endcase
	end
endmodule
