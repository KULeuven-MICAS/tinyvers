module lint_2_apb (
	clk,
	rst_n,
	data_req_i,
	data_add_i,
	data_wen_i,
	data_wdata_i,
	data_be_i,
	data_aux_i,
	data_ID_i,
	data_gnt_o,
	data_r_valid_o,
	data_r_rdata_o,
	data_r_opc_o,
	data_r_aux_o,
	data_r_ID_o,
	master_PADDR,
	master_PWDATA,
	master_PWRITE,
	master_PSEL,
	master_PENABLE,
	master_PRDATA,
	master_PREADY,
	master_PSLVERR
);
	parameter ADDR_WIDTH = 32;
	parameter DATA_WIDTH = 32;
	parameter BE_WIDTH = DATA_WIDTH / 8;
	parameter ID_WIDTH = 10;
	parameter AUX_WIDTH = 8;
	input wire clk;
	input wire rst_n;
	input wire data_req_i;
	input wire [ADDR_WIDTH - 1:0] data_add_i;
	input wire data_wen_i;
	input wire [DATA_WIDTH - 1:0] data_wdata_i;
	input wire [BE_WIDTH - 1:0] data_be_i;
	input wire [AUX_WIDTH - 1:0] data_aux_i;
	input wire [ID_WIDTH - 1:0] data_ID_i;
	output reg data_gnt_o;
	output reg data_r_valid_o;
	output reg [DATA_WIDTH - 1:0] data_r_rdata_o;
	output reg data_r_opc_o;
	output reg [AUX_WIDTH - 1:0] data_r_aux_o;
	output reg [ID_WIDTH - 1:0] data_r_ID_o;
	output wire [ADDR_WIDTH - 1:0] master_PADDR;
	output wire [DATA_WIDTH - 1:0] master_PWDATA;
	output wire master_PWRITE;
	output reg master_PSEL;
	output reg master_PENABLE;
	input wire [DATA_WIDTH - 1:0] master_PRDATA;
	input wire master_PREADY;
	input wire master_PSLVERR;
	reg [1:0] CS;
	reg [1:0] NS;
	reg sample_req_info;
	reg sample_rdata;
	reg data_r_valid_NS;
	reg [ADDR_WIDTH - 1:0] master_PADDR_Q;
	reg [DATA_WIDTH - 1:0] master_PWDATA_Q;
	reg master_PWRITE_Q;
	assign master_PADDR = master_PADDR_Q;
	assign master_PWDATA = master_PWDATA_Q;
	assign master_PWRITE = master_PWRITE_Q;
	always @(posedge clk or negedge rst_n)
		if (~rst_n) begin
			CS <= 2'd0;
			data_r_aux_o <= 1'sb0;
			data_r_ID_o <= 1'sb0;
			master_PADDR_Q <= 1'sb0;
			master_PWDATA_Q <= 1'sb0;
			master_PWRITE_Q <= 1'sb0;
			data_r_rdata_o <= 1'sb0;
			data_r_opc_o <= 1'sb0;
			data_r_valid_o <= 1'b0;
		end
		else begin
			CS <= NS;
			if (sample_req_info) begin
				data_r_aux_o <= data_aux_i;
				data_r_ID_o <= data_ID_i;
				master_PADDR_Q <= data_add_i;
				master_PWDATA_Q <= data_wdata_i;
				master_PWRITE_Q <= ~data_wen_i;
			end
			if (sample_rdata) begin
				data_r_rdata_o <= master_PRDATA;
				data_r_opc_o <= master_PSLVERR;
			end
			data_r_valid_o <= data_r_valid_NS;
		end
	always @(*) begin
		master_PSEL = 1'b0;
		master_PENABLE = 1'b0;
		sample_req_info = 1'b0;
		data_gnt_o = 1'b0;
		sample_rdata = 1'b0;
		data_r_valid_NS = 1'b0;
		case (CS)
			2'd0: begin
				data_gnt_o = 1'b1;
				data_r_valid_NS = 1'b0;
				if (data_req_i) begin
					sample_req_info = 1'b1;
					NS = 2'd1;
				end
				else
					NS = 2'd0;
			end
			2'd1: begin
				master_PSEL = 1'b1;
				master_PENABLE = 1'b1;
				sample_rdata = master_PREADY;
				data_r_valid_NS = master_PREADY;
				if (master_PREADY)
					NS = 2'd2;
				else
					NS = 2'd1;
			end
			2'd2: begin
				NS = 2'd0;
				data_gnt_o = 1'b0;
			end
			default: NS = 2'd0;
		endcase
	end
endmodule
