module udma_ctrl (
	clk_i,
	rstn_i,
	cfg_data_i,
	cfg_addr_i,
	cfg_valid_i,
	cfg_rwn_i,
	cfg_data_o,
	cfg_ready_o,
	rst_value_o,
	cg_value_o,
	cg_core_o,
	event_valid_i,
	event_data_i,
	event_ready_o,
	event_o
);
	parameter L2_AWIDTH_NOAL = 15;
	parameter TRANS_SIZE = 15;
	parameter N_PERIPHS = 6;
	input wire clk_i;
	input wire rstn_i;
	input wire [31:0] cfg_data_i;
	input wire [4:0] cfg_addr_i;
	input wire cfg_valid_i;
	input wire cfg_rwn_i;
	output reg [31:0] cfg_data_o;
	output wire cfg_ready_o;
	output wire [N_PERIPHS - 1:0] rst_value_o;
	output wire [N_PERIPHS - 1:0] cg_value_o;
	output wire cg_core_o;
	input wire event_valid_i;
	input wire [7:0] event_data_i;
	output wire event_ready_o;
	output reg [3:0] event_o;
	reg [N_PERIPHS - 1:0] r_cg;
	reg [N_PERIPHS - 1:0] r_rst;
	reg [31:0] r_cmp_evt;
	wire [4:0] s_wr_addr;
	wire [4:0] s_rd_addr;
	wire s_sample_commit;
	wire s_set_pending;
	wire s_clr_pending;
	wire r_pending;
	wire [1:0] r_state;
	wire [1:0] s_state;
	assign s_wr_addr = (cfg_valid_i & ~cfg_rwn_i ? cfg_addr_i : 5'h00);
	assign s_rd_addr = (cfg_valid_i & cfg_rwn_i ? cfg_addr_i : 5'h00);
	assign cg_value_o = r_cg;
	assign cg_core_o = |r_cg;
	assign rst_value_o = r_rst;
	assign event_ready_o = 1'b1;
	always @(*) begin : proc_event_o
		event_o = 4'h0;
		begin : sv2v_autoblock_1
			reg signed [31:0] i;
			for (i = 0; i < 4; i = i + 1)
				event_o[i] = event_valid_i & (event_data_i == r_cmp_evt[i * 8+:8]);
		end
	end
	always @(posedge clk_i or negedge rstn_i)
		if (~rstn_i) begin
			r_cg <= 'h0;
			r_cmp_evt <= 'h0;
			r_rst <= 'h0;
		end
		else if (cfg_valid_i & ~cfg_rwn_i)
			case (s_wr_addr)
				5'b00000: r_cg <= cfg_data_i[N_PERIPHS - 1:0];
				5'b00010: r_rst <= cfg_data_i[N_PERIPHS - 1:0];
				5'b00001: begin
					r_cmp_evt[0+:8] <= cfg_data_i[7:0];
					r_cmp_evt[8+:8] <= cfg_data_i[15:8];
					r_cmp_evt[16+:8] <= cfg_data_i[23:16];
					r_cmp_evt[24+:8] <= cfg_data_i[31:24];
				end
			endcase
	always @(*) begin
		cfg_data_o = 32'h00000000;
		case (s_rd_addr)
			5'b00000: cfg_data_o[N_PERIPHS - 1:0] = r_cg;
			5'b00010: cfg_data_o[N_PERIPHS - 1:0] = r_rst;
			5'b00001: cfg_data_o = {r_cmp_evt[24+:8], r_cmp_evt[16+:8], r_cmp_evt[8+:8], r_cmp_evt[0+:8]};
			default: cfg_data_o = 'h0;
		endcase
	end
	assign cfg_ready_o = 1'b1;
endmodule
