module udma_sdio_reg_if (
	clk_i,
	rstn_i,
	cfg_data_i,
	cfg_addr_i,
	cfg_valid_i,
	cfg_rwn_i,
	cfg_data_o,
	cfg_ready_o,
	cfg_rx_startaddr_o,
	cfg_rx_size_o,
	cfg_rx_continuous_o,
	cfg_rx_en_o,
	cfg_rx_clr_o,
	cfg_rx_en_i,
	cfg_rx_pending_i,
	cfg_rx_curr_addr_i,
	cfg_rx_bytes_left_i,
	cfg_tx_startaddr_o,
	cfg_tx_size_o,
	cfg_tx_continuous_o,
	cfg_tx_en_o,
	cfg_tx_clr_o,
	cfg_tx_en_i,
	cfg_tx_pending_i,
	cfg_tx_curr_addr_i,
	cfg_tx_bytes_left_i,
	cfg_sdio_start_o,
	cfg_clk_div_data_o,
	cfg_clk_div_valid_o,
	cfg_clk_div_ack_i,
	txrx_status_i,
	txrx_eot_i,
	txrx_err_i,
	cfg_cmd_op_o,
	cfg_cmd_arg_o,
	cfg_cmd_rsp_type_o,
	cfg_rsp_data_i,
	cfg_data_en_o,
	cfg_data_rwn_o,
	cfg_data_quad_o,
	cfg_data_block_size_o,
	cfg_data_block_num_o
);
	parameter L2_AWIDTH_NOAL = 12;
	parameter TRANS_SIZE = 16;
	input wire clk_i;
	input wire rstn_i;
	input wire [31:0] cfg_data_i;
	input wire [4:0] cfg_addr_i;
	input wire cfg_valid_i;
	input wire cfg_rwn_i;
	output reg [31:0] cfg_data_o;
	output wire cfg_ready_o;
	output wire [L2_AWIDTH_NOAL - 1:0] cfg_rx_startaddr_o;
	output wire [TRANS_SIZE - 1:0] cfg_rx_size_o;
	output wire cfg_rx_continuous_o;
	output wire cfg_rx_en_o;
	output wire cfg_rx_clr_o;
	input wire cfg_rx_en_i;
	input wire cfg_rx_pending_i;
	input wire [L2_AWIDTH_NOAL - 1:0] cfg_rx_curr_addr_i;
	input wire [TRANS_SIZE - 1:0] cfg_rx_bytes_left_i;
	output wire [L2_AWIDTH_NOAL - 1:0] cfg_tx_startaddr_o;
	output wire [TRANS_SIZE - 1:0] cfg_tx_size_o;
	output wire cfg_tx_continuous_o;
	output wire cfg_tx_en_o;
	output wire cfg_tx_clr_o;
	input wire cfg_tx_en_i;
	input wire cfg_tx_pending_i;
	input wire [L2_AWIDTH_NOAL - 1:0] cfg_tx_curr_addr_i;
	input wire [TRANS_SIZE - 1:0] cfg_tx_bytes_left_i;
	output wire cfg_sdio_start_o;
	output wire [7:0] cfg_clk_div_data_o;
	output wire cfg_clk_div_valid_o;
	input wire cfg_clk_div_ack_i;
	input wire [15:0] txrx_status_i;
	input wire txrx_eot_i;
	input wire txrx_err_i;
	output wire [5:0] cfg_cmd_op_o;
	output wire [31:0] cfg_cmd_arg_o;
	output wire [2:0] cfg_cmd_rsp_type_o;
	input wire [127:0] cfg_rsp_data_i;
	output wire cfg_data_en_o;
	output wire cfg_data_rwn_o;
	output wire cfg_data_quad_o;
	output wire [9:0] cfg_data_block_size_o;
	output wire [7:0] cfg_data_block_num_o;
	reg [L2_AWIDTH_NOAL - 1:0] r_rx_startaddr;
	reg [TRANS_SIZE - 1:0] r_rx_size;
	reg r_rx_continuous;
	reg r_rx_en;
	reg r_rx_clr;
	reg [L2_AWIDTH_NOAL - 1:0] r_tx_startaddr;
	reg [TRANS_SIZE - 1:0] r_tx_size;
	reg r_tx_continuous;
	reg r_tx_en;
	reg r_tx_clr;
	wire [4:0] s_wr_addr;
	wire [4:0] s_rd_addr;
	reg [5:0] r_cmd_op;
	reg [31:0] r_cmd_arg;
	reg [2:0] r_cmd_rsp_type;
	reg [135:0] r_rsp_data;
	reg r_data_en;
	reg r_data_rwn;
	reg r_data_quad;
	reg [9:0] r_data_block_size;
	reg [7:0] r_data_block_num;
	reg r_sdio_start;
	reg r_clk_div_valid;
	reg [7:0] r_clk_div_data;
	reg [15:0] r_status;
	reg r_eot;
	reg r_err;
	assign s_wr_addr = (cfg_valid_i & ~cfg_rwn_i ? cfg_addr_i : 5'h00);
	assign s_rd_addr = (cfg_valid_i & cfg_rwn_i ? cfg_addr_i : 5'h00);
	assign cfg_rx_startaddr_o = r_rx_startaddr;
	assign cfg_rx_size_o = r_rx_size;
	assign cfg_rx_continuous_o = r_rx_continuous;
	assign cfg_rx_en_o = r_rx_en;
	assign cfg_rx_clr_o = r_rx_clr;
	assign cfg_tx_startaddr_o = r_tx_startaddr;
	assign cfg_tx_size_o = r_tx_size;
	assign cfg_tx_continuous_o = r_tx_continuous;
	assign cfg_tx_en_o = r_tx_en;
	assign cfg_tx_clr_o = r_tx_clr;
	assign cfg_cmd_op_o = r_cmd_op;
	assign cfg_cmd_arg_o = r_cmd_arg;
	assign cfg_cmd_rsp_type_o = r_cmd_rsp_type;
	assign cfg_data_en_o = r_data_en;
	assign cfg_data_rwn_o = r_data_rwn;
	assign cfg_data_quad_o = r_data_quad;
	assign cfg_data_block_size_o = r_data_block_size;
	assign cfg_data_block_num_o = r_data_block_num;
	assign cfg_sdio_start_o = r_sdio_start;
	assign cfg_clk_div_data_o = r_clk_div_data;
	edge_propagator_tx i_edgeprop_soc(
		.clk_i(clk_i),
		.rstn_i(rstn_i),
		.valid_i(r_clk_div_valid),
		.ack_i(cfg_clk_div_ack_i),
		.valid_o(cfg_clk_div_valid_o)
	);
	always @(posedge clk_i or negedge rstn_i)
		if (~rstn_i) begin
			r_rx_startaddr <= 'h0;
			r_rx_size <= 'h0;
			r_rx_continuous <= 'h0;
			r_rx_en = 'h0;
			r_rx_clr = 'h0;
			r_tx_startaddr <= 'h0;
			r_tx_size <= 'h0;
			r_tx_continuous <= 'h0;
			r_tx_en = 'h0;
			r_tx_clr = 'h0;
			r_cmd_op <= 'h0;
			r_cmd_arg <= 'h0;
			r_cmd_rsp_type <= 'h0;
			r_rsp_data <= 'h0;
			r_data_en <= 'h0;
			r_data_rwn <= 'h0;
			r_data_quad <= 'h0;
			r_data_block_size <= 'h0;
			r_data_block_num <= 'h0;
			r_sdio_start = 1'b0;
			r_clk_div_valid <= 1'b0;
			r_clk_div_data <= 'h0;
			r_status <= 'h0;
			r_eot <= 1'b0;
			r_err <= 1'b0;
		end
		else begin
			r_rx_en = 'h0;
			r_rx_clr = 'h0;
			r_tx_en = 'h0;
			r_tx_clr = 'h0;
			r_sdio_start = 1'b0;
			if (cfg_clk_div_ack_i)
				r_clk_div_valid <= 1'b0;
			if (txrx_eot_i) begin
				r_eot <= 1'b1;
				r_status <= txrx_status_i;
			end
			if (txrx_err_i) begin
				r_err <= 1'b1;
				r_status <= txrx_status_i;
			end
			if (cfg_valid_i & ~cfg_rwn_i)
				case (s_wr_addr)
					5'b00000: r_rx_startaddr <= cfg_data_i[L2_AWIDTH_NOAL - 1:0];
					5'b00001: r_rx_size <= cfg_data_i[TRANS_SIZE - 1:0];
					5'b00010: begin
						r_rx_clr = cfg_data_i[5];
						r_rx_en = cfg_data_i[4];
						r_rx_continuous <= cfg_data_i[0];
					end
					5'b00100: r_tx_startaddr <= cfg_data_i[L2_AWIDTH_NOAL - 1:0];
					5'b00101: r_tx_size <= cfg_data_i[TRANS_SIZE - 1:0];
					5'b00110: begin
						r_tx_clr = cfg_data_i[5];
						r_tx_en = cfg_data_i[4];
						r_tx_continuous <= cfg_data_i[0];
					end
					5'b01000: begin
						r_cmd_op <= cfg_data_i[13:8];
						r_cmd_rsp_type <= cfg_data_i[2:0];
					end
					5'b01001: r_cmd_arg <= cfg_data_i;
					5'b01010: begin
						r_data_en <= cfg_data_i[0];
						r_data_rwn <= cfg_data_i[1];
						r_data_quad <= cfg_data_i[2];
						r_data_block_num <= cfg_data_i[15:8];
						r_data_block_size <= cfg_data_i[25:16];
					end
					5'b01011: r_sdio_start = cfg_data_i[0];
					5'b10000: begin
						r_clk_div_valid <= cfg_data_i[8];
						r_clk_div_data <= cfg_data_i[7:0];
					end
					5'b10001: begin
						if (cfg_data_i[0])
							r_eot <= 1'b0;
						if (cfg_data_i[1])
							r_err <= 1'b0;
					end
				endcase
		end
	always @(*) begin
		cfg_data_o = 32'h00000000;
		case (s_rd_addr)
			5'b00000: cfg_data_o = cfg_rx_curr_addr_i;
			5'b00001: cfg_data_o[TRANS_SIZE - 1:0] = cfg_rx_bytes_left_i;
			5'b00010: cfg_data_o = {26'h0000000, cfg_rx_pending_i, cfg_rx_en_i, 3'h0, r_rx_continuous};
			5'b00100: cfg_data_o = cfg_tx_curr_addr_i;
			5'b00101: cfg_data_o[TRANS_SIZE - 1:0] = cfg_tx_bytes_left_i;
			5'b00110: cfg_data_o = {26'h0000000, cfg_tx_pending_i, cfg_tx_en_i, 3'h0, r_tx_continuous};
			5'b01100: cfg_data_o = cfg_rsp_data_i[31:0];
			5'b01101: cfg_data_o = cfg_rsp_data_i[63:32];
			5'b01110: cfg_data_o = cfg_rsp_data_i[95:64];
			5'b01111: cfg_data_o = cfg_rsp_data_i[127:96];
			5'b10000: cfg_data_o = {23'h000000, r_clk_div_valid, r_clk_div_data};
			5'b10001: cfg_data_o = {r_status, 14'h0000, r_err, r_eot};
			default: cfg_data_o = 'h0;
		endcase
	end
	assign cfg_ready_o = 1'b1;
endmodule
