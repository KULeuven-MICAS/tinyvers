module cdc_fifo_2phase (
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
	reg [PTR_WIDTH - 1:0] src_wptr_q;
	wire [PTR_WIDTH - 1:0] dst_wptr;
	wire [PTR_WIDTH - 1:0] src_rptr;
	reg [PTR_WIDTH - 1:0] dst_rptr_q;
	always @(posedge src_clk_i or negedge src_rst_ni)
		if (!src_rst_ni)
			src_wptr_q <= 0;
		else if (src_valid_i && src_ready_o)
			src_wptr_q <= src_wptr_q + 1;
	always @(posedge dst_clk_i or negedge dst_rst_ni)
		if (!dst_rst_ni)
			dst_rptr_q <= 0;
		else if (dst_valid_o && dst_ready_i)
			dst_rptr_q <= dst_rptr_q + 1;
	assign src_ready_o = (src_wptr_q ^ src_rptr) != PTR_FULL;
	assign dst_valid_o = (dst_rptr_q ^ dst_wptr) != PTR_EMPTY;
	cdc_2phase_35A28_81E6F #(._PTR_WIDTH(PTR_WIDTH)) i_cdc_wptr(
		.src_rst_ni(src_rst_ni),
		.src_clk_i(src_clk_i),
		.src_data_i(src_wptr_q),
		.src_valid_i(1'b1),
		.src_ready_o(),
		.dst_rst_ni(dst_rst_ni),
		.dst_clk_i(dst_clk_i),
		.dst_data_o(dst_wptr),
		.dst_valid_o(),
		.dst_ready_i(1'b1)
	);
	cdc_2phase_35A28_81E6F #(._PTR_WIDTH(PTR_WIDTH)) i_cdc_rptr(
		.src_rst_ni(dst_rst_ni),
		.src_clk_i(dst_clk_i),
		.src_data_i(dst_rptr_q),
		.src_valid_i(1'b1),
		.src_ready_o(),
		.dst_rst_ni(src_rst_ni),
		.dst_clk_i(src_clk_i),
		.dst_data_o(src_rptr),
		.dst_valid_o(),
		.dst_ready_i(1'b1)
	);
	assign fifo_widx = src_wptr_q;
	assign fifo_wdata = src_data_i;
	assign fifo_write = src_valid_i && src_ready_o;
	assign fifo_ridx = dst_rptr_q;
	assign dst_data_o = fifo_rdata;
endmodule
