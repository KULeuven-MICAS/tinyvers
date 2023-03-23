module hwpe_ctrl_seq_mult (
	clk_i,
	rst_ni,
	clear_i,
	start_i,
	a_i,
	b_i,
	valid_o,
	prod_o
);
	parameter [31:0] AW = 8;
	parameter [31:0] BW = 8;
	input wire clk_i;
	input wire rst_ni;
	input wire clear_i;
	input wire start_i;
	input wire [AW - 1:0] a_i;
	input wire [BW - 1:0] b_i;
	output wire valid_o;
	output reg [(AW + BW) - 1:0] prod_o;
	reg [$clog2(AW + 1) - 1:0] cnt;
	wire [(AW + BW) - 1:0] shifted;
	always @(posedge clk_i or negedge rst_ni) begin : counter
		if (~rst_ni)
			cnt <= 1'sb0;
		else if (clear_i)
			cnt <= 1'sb0;
		else if (cnt == (AW - 1))
			cnt <= 0;
		else if ((start_i == 1'b1) || (cnt > 0))
			cnt <= cnt + 1;
	end
	assign valid_o = (cnt == 0 ? 1'b1 : 1'b0);
	assign shifted = ({BW {a_i[cnt]}} & b_i) << cnt;
	always @(posedge clk_i or negedge rst_ni) begin : product
		if (~rst_ni)
			prod_o <= 1'sb0;
		else if (clear_i)
			prod_o <= 1'sb0;
		else if (start_i)
			prod_o <= shifted;
		else if (cnt > 0)
			prod_o <= prod_o + shifted;
	end
endmodule
