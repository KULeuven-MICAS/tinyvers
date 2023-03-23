module camera_if (
	clk_i,
	rstn_i,
	dft_test_mode_i,
	dft_cg_enable_i,
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
	data_rx_datasize_o,
	data_rx_data_o,
	data_rx_valid_o,
	data_rx_ready_i,
	cam_clk_i,
	cam_data_i,
	cam_hsync_i,
	cam_vsync_i
);
	parameter L2_AWIDTH_NOAL = 12;
	parameter TRANS_SIZE = 16;
	parameter DATA_WIDTH = 12;
	parameter BUFFER_WIDTH = 8;
	input wire clk_i;
	input wire rstn_i;
	input wire dft_test_mode_i;
	input wire dft_cg_enable_i;
	input wire [31:0] cfg_data_i;
	input wire [4:0] cfg_addr_i;
	input wire cfg_valid_i;
	input wire cfg_rwn_i;
	output wire [31:0] cfg_data_o;
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
	output wire [1:0] data_rx_datasize_o;
	output wire [15:0] data_rx_data_o;
	output wire data_rx_valid_o;
	input wire data_rx_ready_i;
	input wire cam_clk_i;
	input wire [DATA_WIDTH - 1:0] cam_data_i;
	input wire cam_hsync_i;
	input wire cam_vsync_i;
	reg [15:0] r_rowcounter;
	reg [15:0] r_colcounter;
	reg [5:0] r_framecounter;
	reg r_sample_msb;
	reg [7:0] r_data_msb;
	reg s_pixel_valid;
	reg r_vsync;
	reg r_enable;
	reg [1:0] r_en_sync;
	reg [15:0] udma_tx_data;
	reg udma_tx_valid;
	wire udma_tx_valid_flush;
	wire udma_tx_ready;
	wire [15:0] s_cfg_rowlen;
	wire [7:0] s_cfg_r_coeff;
	wire [7:0] s_cfg_g_coeff;
	wire [7:0] s_cfg_b_coeff;
	reg [7:0] s_r_pix;
	reg [7:0] s_g_pix;
	reg [7:0] s_b_pix;
	reg [15:0] s_yuv_pix;
	reg [15:0] r_yuv_pix;
	reg r_yuv_data_valid;
	reg [7:0] r_r_pix;
	reg [7:0] r_g_pix;
	reg [7:0] r_b_pix;
	wire [15:0] s_r_filt;
	wire [15:0] s_g_filt;
	wire [15:0] s_b_filt;
	reg [15:0] s_data_filter_shift;
	wire [16:0] s_data_filter;
	reg [16:0] r_data_filter;
	reg r_data_filter_valid;
	reg r_tx_valid;
	wire s_cam_vsync;
	wire s_cam_vsync_polarity;
	wire [31:0] s_cfg_glob;
	wire [31:0] s_cfg_ll;
	wire [31:0] s_cfg_ur;
	wire [31:0] s_cfg_filter;
	wire [31:0] s_cfg_size;
	wire s_cfg_framedrop_en;
	wire [5:0] s_cfg_framedrop_val;
	wire s_cfg_frameslice_en;
	wire [2:0] s_cfg_format;
	wire [3:0] s_cfg_shift;
	wire s_cam_clk_dft;
	wire s_cfg_en;
	wire [15:0] s_cfg_frameslice_llx;
	wire [15:0] s_cfg_frameslice_lly;
	wire [15:0] s_cfg_frameslice_urx;
	wire [15:0] s_cfg_frameslice_ury;
	wire s_sof;
	wire s_framevalid;
	wire s_tx_valid;
	wire s_data_rx_ready;
	assign s_r_filt = r_r_pix * s_cfg_r_coeff;
	assign s_g_filt = r_g_pix * s_cfg_g_coeff;
	assign s_b_filt = r_b_pix * s_cfg_b_coeff;
	assign s_data_filter = (s_r_filt + s_g_filt) + s_b_filt;
	assign s_cfg_framedrop_en = s_cfg_glob[0];
	assign s_cfg_framedrop_val = s_cfg_glob[6:1];
	assign s_cfg_frameslice_en = s_cfg_glob[7];
	assign s_cfg_format = s_cfg_glob[10:8];
	assign s_cfg_shift = s_cfg_glob[14:11];
	assign s_cfg_en = s_cfg_glob[31];
	assign s_cfg_rowlen = s_cfg_size[31:16];
	assign s_cfg_frameslice_llx = s_cfg_ll[15:0];
	assign s_cfg_frameslice_lly = s_cfg_ll[31:16];
	assign s_cfg_frameslice_urx = s_cfg_ur[15:0];
	assign s_cfg_frameslice_ury = s_cfg_ur[31:16];
	assign s_cfg_r_coeff = s_cfg_filter[23:16];
	assign s_cfg_g_coeff = s_cfg_filter[15:8];
	assign s_cfg_b_coeff = s_cfg_filter[7:0];
	assign s_cam_vsync = (s_cam_vsync_polarity ? ~cam_vsync_i : cam_vsync_i);
	assign s_sof = ~r_vsync & s_cam_vsync;
	assign s_framevalid = r_framecounter == 0;
	assign s_tx_valid = (cam_hsync_i & s_pixel_valid) & ~r_sample_msb;
	camera_reg_if #(
		.L2_AWIDTH_NOAL(L2_AWIDTH_NOAL),
		.TRANS_SIZE(TRANS_SIZE)
	) u_reg_if(
		.clk_i(clk_i),
		.rstn_i(rstn_i),
		.cfg_data_i(cfg_data_i),
		.cfg_addr_i(cfg_addr_i),
		.cfg_valid_i(cfg_valid_i),
		.cfg_rwn_i(cfg_rwn_i),
		.cfg_ready_o(cfg_ready_o),
		.cfg_data_o(cfg_data_o),
		.cfg_rx_startaddr_o(cfg_rx_startaddr_o),
		.cfg_rx_size_o(cfg_rx_size_o),
		.cfg_rx_datasize_o(data_rx_datasize_o),
		.cfg_rx_continuous_o(cfg_rx_continuous_o),
		.cfg_rx_en_o(cfg_rx_en_o),
		.cfg_rx_clr_o(cfg_rx_clr_o),
		.cfg_rx_en_i(cfg_rx_en_i),
		.cfg_rx_pending_i(cfg_rx_pending_i),
		.cfg_rx_curr_addr_i(cfg_rx_curr_addr_i),
		.cfg_rx_bytes_left_i(cfg_rx_bytes_left_i),
		.cfg_cam_ip_en_i(1'b0),
		.cfg_cam_vsync_polarity_o(s_cam_vsync_polarity),
		.cfg_cam_cfg_o(s_cfg_glob),
		.cfg_cam_cfg_ll_o(s_cfg_ll),
		.cfg_cam_cfg_ur_o(s_cfg_ur),
		.cfg_cam_cfg_size_o(s_cfg_size),
		.cfg_cam_cfg_filter_o(s_cfg_filter)
	);
	assign s_cam_clk_dft = cam_clk_i;
	assign s_data_rx_ready = (s_cfg_en == 1'b0 ? 1'b1 : data_rx_ready_i);
	assign udma_tx_valid_flush = (s_cfg_en == 1'b0 ? 1'b0 : udma_tx_valid);
	udma_dc_fifo #(
		16,
		BUFFER_WIDTH
	) u_dc_fifo(
		.dst_clk_i(clk_i),
		.dst_rstn_i(rstn_i),
		.dst_data_o(data_rx_data_o),
		.dst_valid_o(data_rx_valid_o),
		.dst_ready_i(s_data_rx_ready),
		.src_clk_i(s_cam_clk_dft),
		.src_rstn_i(rstn_i),
		.src_data_i(udma_tx_data),
		.src_valid_i(udma_tx_valid_flush),
		.src_ready_o(udma_tx_ready)
	);
	always @(*) begin : proc_format
		s_r_pix = 'h0;
		s_g_pix = 'h0;
		s_b_pix = 'h0;
		s_yuv_pix = 'h0;
		case (s_cfg_format)
			3'b000: begin
				s_r_pix = {r_data_msb[7:3], 3'b000};
				s_g_pix = {r_data_msb[2:0], cam_data_i[7:5], 2'b00};
				s_b_pix = {cam_data_i[4:0], 3'b000};
			end
			3'b001: begin
				s_r_pix = {r_data_msb[6:2], 3'b000};
				s_g_pix = {r_data_msb[1:0], cam_data_i[7:5], 3'b000};
				s_b_pix = {cam_data_i[4:0], 3'b000};
			end
			3'b010: begin
				s_r_pix = {r_data_msb[3:0], 4'b0000};
				s_g_pix = {cam_data_i[7:4], 4'b0000};
				s_b_pix = {cam_data_i[3:0], 4'b0000};
			end
			3'b100: s_yuv_pix = {r_data_msb[7:0], cam_data_i[7:0]};
			3'b101: s_yuv_pix = {cam_data_i[7:0], r_data_msb[7:0]};
		endcase
	end
	always @(*) begin : proc_sfilter_shift
		case (s_cfg_shift)
			0: s_data_filter_shift = r_data_filter[15:0];
			1: s_data_filter_shift = r_data_filter[16:1];
			2: s_data_filter_shift = {1'h0, r_data_filter[16:2]};
			3: s_data_filter_shift = {2'h0, r_data_filter[16:3]};
			4: s_data_filter_shift = {3'h0, r_data_filter[16:4]};
			5: s_data_filter_shift = {4'h0, r_data_filter[16:5]};
			6: s_data_filter_shift = {5'h00, r_data_filter[16:6]};
			7: s_data_filter_shift = {6'h00, r_data_filter[16:7]};
			8: s_data_filter_shift = {7'h00, r_data_filter[16:8]};
			9: s_data_filter_shift = {8'h00, r_data_filter[16:9]};
			default: s_data_filter_shift = r_data_filter[15:0];
		endcase
	end
	always @(posedge s_cam_clk_dft or negedge rstn_i) begin : proc_pix
		if (~rstn_i) begin
			r_r_pix <= 0;
			r_g_pix <= 0;
			r_b_pix <= 0;
			r_yuv_pix <= 0;
			r_tx_valid <= 1'b0;
			udma_tx_data <= 'h0;
			r_yuv_data_valid <= 1'b0;
			udma_tx_valid <= 1'b0;
			r_data_filter <= 'h0;
			r_data_filter_valid <= 1'b0;
		end
		else begin
			if (s_tx_valid) begin
				if (s_cfg_format[2] != 1'b1) begin
					r_r_pix <= s_r_pix;
					r_g_pix <= s_g_pix;
					r_b_pix <= s_b_pix;
					r_tx_valid <= 1'b1;
				end
				else begin
					r_yuv_pix <= s_yuv_pix;
					r_yuv_data_valid <= 1'b1;
				end
			end
			else begin
				r_tx_valid <= 1'b0;
				r_yuv_data_valid <= 1'b0;
			end
			if (r_tx_valid) begin
				r_data_filter <= s_data_filter;
				r_data_filter_valid <= 1'b1;
			end
			else
				r_data_filter_valid <= 1'b0;
			if (r_data_filter_valid || r_yuv_data_valid) begin
				udma_tx_data <= (r_data_filter_valid ? s_data_filter_shift : r_yuv_pix);
				udma_tx_valid <= 1'b1;
			end
			else
				udma_tx_valid <= 1'b0;
		end
	end
	always @(*) begin : proc_sampledata
		if (s_framevalid && r_enable) begin
			if (s_cfg_frameslice_en) begin
				if ((((r_rowcounter >= s_cfg_frameslice_lly) && (r_rowcounter <= s_cfg_frameslice_ury)) && (r_colcounter >= s_cfg_frameslice_llx)) && (r_colcounter <= s_cfg_frameslice_urx))
					s_pixel_valid = 1'b1;
				else
					s_pixel_valid = 1'b0;
			end
			else
				s_pixel_valid = 1'b1;
		end
		else
			s_pixel_valid = 1'b0;
	end
	always @(posedge s_cam_clk_dft or negedge rstn_i) begin : proc_vsync
		if (~rstn_i)
			r_vsync <= 0;
		else if (r_en_sync[1])
			r_vsync <= s_cam_vsync;
	end
	always @(posedge s_cam_clk_dft or negedge rstn_i) begin : proc_en_sync
		if (~rstn_i)
			r_en_sync <= 0;
		else
			r_en_sync <= {r_en_sync[0], s_cfg_en};
	end
	always @(posedge s_cam_clk_dft or negedge rstn_i) begin : proc_sample_lsb
		if (~rstn_i)
			r_sample_msb <= 1'b1;
		else if (~r_enable | ~cam_hsync_i)
			r_sample_msb <= 1'b1;
		else if (cam_hsync_i & r_enable)
			r_sample_msb <= ~r_sample_msb;
	end
	always @(posedge s_cam_clk_dft or negedge rstn_i) begin : proc_data
		if (~rstn_i) begin
			r_data_msb <= 'h0;
			r_rowcounter <= 'h0;
			r_colcounter <= 'h0;
			r_enable <= 1'b0;
		end
		else if (s_sof) begin
			r_rowcounter <= 'h0;
			r_colcounter <= 'h0;
			r_enable <= r_en_sync[1];
		end
		else if (~s_sof & ~r_en_sync[1]) begin
			r_rowcounter <= 'h0;
			r_colcounter <= 'h0;
			r_enable <= r_en_sync[1];
		end
		else if (cam_hsync_i & r_enable) begin
			if (r_sample_msb)
				r_data_msb <= cam_data_i;
			if (!r_sample_msb && s_cfg_frameslice_en)
				if (r_colcounter == s_cfg_rowlen) begin
					r_colcounter <= 'h0;
					r_rowcounter <= r_rowcounter + 1;
				end
				else
					r_colcounter <= r_colcounter + 1;
		end
	end
	always @(posedge s_cam_clk_dft or negedge rstn_i) begin : proc_framecount
		if (~rstn_i)
			r_framecounter <= 'h0;
		else if (s_sof && r_enable)
			if (s_cfg_framedrop_en) begin
				if (r_framecounter == s_cfg_framedrop_val)
					r_framecounter <= 'h0;
				else
					r_framecounter <= r_framecounter + 1;
			end
			else
				r_framecounter <= 'h0;
	end
endmodule
