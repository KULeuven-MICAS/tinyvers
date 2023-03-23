module camera_reg_if (
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
	cfg_rx_datasize_o,
	cfg_rx_continuous_o,
	cfg_rx_en_o,
	cfg_rx_clr_o,
	cfg_rx_en_i,
	cfg_rx_pending_i,
	cfg_rx_curr_addr_i,
	cfg_rx_bytes_left_i,
	cfg_cam_ip_en_i,
	cfg_cam_vsync_polarity_o,
	cfg_cam_cfg_o,
	cfg_cam_cfg_ll_o,
	cfg_cam_cfg_ur_o,
	cfg_cam_cfg_size_o,
	cfg_cam_cfg_filter_o
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
	output wire [1:0] cfg_rx_datasize_o;
	output wire cfg_rx_continuous_o;
	output wire cfg_rx_en_o;
	output wire cfg_rx_clr_o;
	input wire cfg_rx_en_i;
	input wire cfg_rx_pending_i;
	input wire [L2_AWIDTH_NOAL - 1:0] cfg_rx_curr_addr_i;
	input wire [TRANS_SIZE - 1:0] cfg_rx_bytes_left_i;
	input wire cfg_cam_ip_en_i;
	output wire cfg_cam_vsync_polarity_o;
	output wire [31:0] cfg_cam_cfg_o;
	output wire [31:0] cfg_cam_cfg_ll_o;
	output wire [31:0] cfg_cam_cfg_ur_o;
	output wire [31:0] cfg_cam_cfg_size_o;
	output wire [31:0] cfg_cam_cfg_filter_o;
	reg [L2_AWIDTH_NOAL - 1:0] r_rx_startaddr;
	reg [TRANS_SIZE - 1:0] r_rx_size;
	reg [1:0] r_rx_datasize;
	reg r_rx_continuous;
	reg r_rx_en;
	reg r_rx_clr;
	reg [31:0] r_cam_cfg;
	reg [31:0] r_cam_cfg_ll;
	reg [31:0] r_cam_cfg_ur;
	reg [31:0] r_cam_cfg_size;
	reg [31:0] r_cam_cfg_filter;
	reg r_cam_vsync_polarity;
	wire [4:0] s_wr_addr;
	wire [4:0] s_rd_addr;
	assign s_wr_addr = (cfg_valid_i & ~cfg_rwn_i ? cfg_addr_i : 5'h00);
	assign s_rd_addr = (cfg_valid_i & cfg_rwn_i ? cfg_addr_i : 5'h00);
	assign cfg_rx_startaddr_o = r_rx_startaddr;
	assign cfg_rx_size_o = r_rx_size;
	assign cfg_rx_datasize_o = r_rx_datasize;
	assign cfg_rx_continuous_o = r_rx_continuous;
	assign cfg_rx_en_o = r_rx_en;
	assign cfg_rx_clr_o = r_rx_clr;
	assign cfg_cam_cfg_o = r_cam_cfg;
	assign cfg_cam_cfg_ll_o = r_cam_cfg_ll;
	assign cfg_cam_cfg_ur_o = r_cam_cfg_ur;
	assign cfg_cam_cfg_size_o = r_cam_cfg_size;
	assign cfg_cam_cfg_filter_o = r_cam_cfg_filter;
	assign cfg_cam_vsync_polarity_o = r_cam_vsync_polarity;
	always @(posedge clk_i or negedge rstn_i)
		if (~rstn_i) begin
			r_rx_startaddr <= 'h0;
			r_rx_size <= 'h0;
			r_rx_continuous <= 'h0;
			r_rx_en = 'h0;
			r_rx_clr = 'h0;
			r_rx_datasize <= 'b0;
			r_cam_cfg <= 'h0;
			r_cam_cfg_ll <= 'h0;
			r_cam_cfg_ur <= 'h0;
			r_cam_cfg_size <= 'h0;
			r_cam_cfg_filter <= 'h0;
			r_cam_vsync_polarity <= 1'b0;
		end
		else begin
			r_rx_en = 'h0;
			r_rx_clr = 'h0;
			if (cfg_valid_i & ~cfg_rwn_i)
				case (s_wr_addr)
					5'b00000: r_rx_startaddr <= cfg_data_i[L2_AWIDTH_NOAL - 1:0];
					5'b00001: r_rx_size <= cfg_data_i[TRANS_SIZE - 1:0];
					5'b00010: begin
						r_rx_clr = cfg_data_i[6];
						r_rx_en = cfg_data_i[4];
						r_rx_datasize <= cfg_data_i[2:1];
						r_rx_continuous <= cfg_data_i[0];
					end
					5'b01000: r_cam_cfg <= cfg_data_i;
					5'b01001: r_cam_cfg_ll <= cfg_data_i;
					5'b01010: r_cam_cfg_ur <= cfg_data_i;
					5'b01011: r_cam_cfg_size <= cfg_data_i;
					5'b01100: r_cam_cfg_filter <= cfg_data_i;
					5'b01101: r_cam_vsync_polarity <= cfg_data_i[0];
				endcase
		end
	always @(*) begin
		cfg_data_o = 32'h00000000;
		case (s_rd_addr)
			5'b00000: cfg_data_o = cfg_rx_curr_addr_i;
			5'b00001: cfg_data_o[TRANS_SIZE - 1:0] = cfg_rx_bytes_left_i;
			5'b00010: cfg_data_o = {26'h0000000, cfg_rx_pending_i, cfg_rx_en_i, 1'b0, r_rx_datasize, r_rx_continuous};
			5'b01000: cfg_data_o = {cfg_cam_ip_en_i, r_cam_cfg[30:0]};
			5'b01001: cfg_data_o = r_cam_cfg_ll;
			5'b01010: cfg_data_o = r_cam_cfg_ur;
			5'b01011: cfg_data_o = r_cam_cfg_size;
			5'b01100: cfg_data_o = r_cam_cfg_filter;
			5'b01101: cfg_data_o = {31'h00000000, r_cam_vsync_polarity};
			default: cfg_data_o = 'h0;
		endcase
	end
	assign cfg_ready_o = 1'b1;
endmodule
