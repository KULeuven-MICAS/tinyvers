module cdc_fifo_gray (
	src_rst_ni,
	src_clk_i,
	src_data_i,
	src_valid_i,
	src_ready_o,
	dst_rst_ni,
	dst_clk_i,
	dst_data_o,
	dst_valid_o,
	dst_ready_i
);
	parameter signed [31:0] LOG_DEPTH = 3;
	input wire src_rst_ni;
	input wire src_clk_i;
	input wire src_data_i;
	input wire src_valid_i;
	output wire src_ready_o;
	input wire dst_rst_ni;
	input wire dst_clk_i;
	output wire dst_data_o;
	output wire dst_valid_o;
	input wire dst_ready_i;
	localparam signed [31:0] PTR_WIDTH = LOG_DEPTH + 1;
	localparam [PTR_WIDTH - 1:0] PTR_FULL = 1 << LOG_DEPTH;
	localparam [PTR_WIDTH - 1:0] PTR_EMPTY = 1'sb0;
	wire [LOG_DEPTH - 1:0] fifo_widx;
	wire [LOG_DEPTH - 1:0] fifo_ridx;
	wire fifo_write;
	wire fifo_wdata;
	wire fifo_rdata;
	reg fifo_data_q [0:(2 ** LOG_DEPTH) - 1];
	assign fifo_rdata = fifo_data_q[fifo_ridx];
	genvar i;
	generate
		for (i = 0; i < (2 ** LOG_DEPTH); i = i + 1) begin : g_word
			always @(posedge src_clk_i or negedge src_rst_ni)
				if (!src_rst_ni)
					fifo_data_q[i] <= 1'sb0;
				else if (fifo_write && (fifo_widx == i))
					fifo_data_q[i] <= fifo_wdata;
		end
	endgenerate
	reg [PTR_WIDTH - 1:0] src_wptr_bin_q;
	reg [PTR_WIDTH - 1:0] src_wptr_gray_q;
	reg [PTR_WIDTH - 1:0] dst_rptr_bin_q;
	reg [PTR_WIDTH - 1:0] dst_rptr_gray_q;
	wire [PTR_WIDTH - 1:0] src_wptr_bin_d;
	wire [PTR_WIDTH - 1:0] src_wptr_gray_d;
	wire [PTR_WIDTH - 1:0] dst_rptr_bin_d;
	wire [PTR_WIDTH - 1:0] dst_rptr_gray_d;
	assign src_wptr_bin_d = src_wptr_bin_q + 1;
	assign dst_rptr_bin_d = dst_rptr_bin_q + 1;
	binary_to_gray #(PTR_WIDTH) i_src_b2g(
		src_wptr_bin_d,
		src_wptr_gray_d
	);
	binary_to_gray #(PTR_WIDTH) i_dst_b2g(
		dst_rptr_bin_d,
		dst_rptr_gray_d
	);
	always @(posedge src_clk_i or negedge src_rst_ni)
		if (!src_rst_ni) begin
			src_wptr_bin_q <= 1'sb0;
			src_wptr_gray_q <= 1'sb0;
		end
		else if (src_valid_i && src_ready_o) begin
			src_wptr_bin_q <= src_wptr_bin_d;
			src_wptr_gray_q <= src_wptr_gray_d;
		end
	always @(posedge dst_clk_i or negedge dst_rst_ni)
		if (!dst_rst_ni) begin
			dst_rptr_bin_q <= 1'sb0;
			dst_rptr_gray_q <= 1'sb0;
		end
		else if (dst_valid_o && dst_ready_i) begin
			dst_rptr_bin_q <= dst_rptr_bin_d;
			dst_rptr_gray_q <= dst_rptr_gray_d;
		end
	reg [PTR_WIDTH - 1:0] src_rptr_gray_q;
	reg [PTR_WIDTH - 1:0] src_rptr_gray_q2;
	reg [PTR_WIDTH - 1:0] dst_wptr_gray_q;
	reg [PTR_WIDTH - 1:0] dst_wptr_gray_q2;
	always @(posedge src_clk_i or negedge src_rst_ni)
		if (!src_rst_ni) begin
			src_rptr_gray_q <= 1'sb0;
			src_rptr_gray_q2 <= 1'sb0;
		end
		else begin
			src_rptr_gray_q <= dst_rptr_gray_q;
			src_rptr_gray_q2 <= src_rptr_gray_q;
		end
	always @(posedge dst_clk_i or negedge dst_rst_ni)
		if (!dst_rst_ni) begin
			dst_wptr_gray_q <= 1'sb0;
			dst_wptr_gray_q2 <= 1'sb0;
		end
		else begin
			dst_wptr_gray_q <= src_wptr_gray_q;
			dst_wptr_gray_q2 <= dst_wptr_gray_q;
		end
	wire [PTR_WIDTH - 1:0] src_rptr_bin;
	wire [PTR_WIDTH - 1:0] dst_wptr_bin;
	gray_to_binary #(PTR_WIDTH) i_src_g2b(
		src_rptr_gray_q2,
		src_rptr_bin
	);
	gray_to_binary #(PTR_WIDTH) i_dst_g2b(
		dst_wptr_gray_q2,
		dst_wptr_bin
	);
	assign src_ready_o = (src_wptr_bin_q ^ src_rptr_bin) != PTR_FULL;
	assign dst_valid_o = (dst_rptr_bin_q ^ dst_wptr_bin) != PTR_EMPTY;
	assign fifo_widx = src_wptr_bin_q;
	assign fifo_wdata = src_data_i;
	assign fifo_write = src_valid_i && src_ready_o;
	assign fifo_ridx = dst_rptr_bin_q;
	assign dst_data_o = fifo_rdata;
endmodule
