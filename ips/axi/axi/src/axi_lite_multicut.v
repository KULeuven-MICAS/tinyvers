module axi_lite_multicut (
	clk_i,
	rst_ni,
	in,
	out
);
	parameter signed [31:0] ADDR_WIDTH = -1;
	parameter signed [31:0] DATA_WIDTH = -1;
	parameter signed [31:0] NUM_CUTS = 0;
	input wire clk_i;
	input wire rst_ni;
	input AXI_LITE.Slave in;
	input AXI_LITE.Master out;
	generate
		if (NUM_CUTS == 0) begin : g_cuts
			axi_lite_join i_join(
				.in(in),
				.out(out)
			);
		end
		else if (NUM_CUTS == 1) begin : g_cuts
			axi_lite_cut #(
				.ADDR_WIDTH(ADDR_WIDTH),
				.DATA_WIDTH(DATA_WIDTH)
			) i_cut(
				.clk_i(clk_i),
				.rst_ni(rst_ni),
				.in(in),
				.out(out)
			);
		end
		else begin : g_cuts
			AXI_LITE #(
				.AXI_ADDR_WIDTH(ADDR_WIDTH),
				.AXI_DATA_WIDTH(DATA_WIDTH)
			) s_cut[NUM_CUTS - 1:0]();
			axi_lite_cut #(
				.ADDR_WIDTH(ADDR_WIDTH),
				.DATA_WIDTH(DATA_WIDTH)
			) i_first(
				.clk_i(clk_i),
				.rst_ni(rst_ni),
				.in(in),
				.out(s_cut[0].Master)
			);
			genvar i;
			for (i = 1; i < (NUM_CUTS - 1); i = i + 1) begin : genblk1
				axi_lite_cut #(
					.ADDR_WIDTH(ADDR_WIDTH),
					.DATA_WIDTH(DATA_WIDTH)
				) i_middle(
					.clk_i(clk_i),
					.rst_ni(rst_ni),
					.in(s_cut[i - 1].Slave),
					.out(s_cut[i].Master)
				);
			end
			axi_lite_cut #(
				.ADDR_WIDTH(ADDR_WIDTH),
				.DATA_WIDTH(DATA_WIDTH)
			) i_last(
				.clk_i(clk_i),
				.rst_ni(rst_ni),
				.in(s_cut[NUM_CUTS - 2].Slave),
				.out(out)
			);
		end
	endgenerate
endmodule
