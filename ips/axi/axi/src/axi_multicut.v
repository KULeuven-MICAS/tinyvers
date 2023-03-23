module axi_multicut (
	clk_i,
	rst_ni,
	in,
	out
);
	parameter signed [31:0] ADDR_WIDTH = -1;
	parameter signed [31:0] DATA_WIDTH = -1;
	parameter signed [31:0] ID_WIDTH = -1;
	parameter signed [31:0] USER_WIDTH = -1;
	parameter signed [31:0] NUM_CUTS = 0;
	input wire clk_i;
	input wire rst_ni;
	input AXI_BUS.Slave in;
	input AXI_BUS.Master out;
	AXI_BUS #(
		.AXI_ADDR_WIDTH(ADDR_WIDTH),
		.AXI_DATA_WIDTH(DATA_WIDTH),
		.AXI_ID_WIDTH(ID_WIDTH),
		.AXI_USER_WIDTH(USER_WIDTH)
	) s_cut[NUM_CUTS:0]();
	axi_join i_join_in(
		.in(in),
		.out(s_cut[0].Master)
	);
	genvar i;
	generate
		for (i = 0; i < NUM_CUTS; i = i + 1) begin : g_cuts
			axi_cut #(
				.ADDR_WIDTH(ADDR_WIDTH),
				.DATA_WIDTH(DATA_WIDTH),
				.ID_WIDTH(ID_WIDTH),
				.USER_WIDTH(USER_WIDTH)
			) i_cut(
				.clk_i(clk_i),
				.rst_ni(rst_ni),
				.in(s_cut[i].Slave),
				.out(s_cut[i + 1].Master)
			);
		end
	endgenerate
	axi_join i_join_out(
		.in(s_cut[NUM_CUTS].Slave),
		.out(out)
	);
endmodule
