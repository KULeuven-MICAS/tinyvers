module shift_reg (
	clk_i,
	rst_ni,
	d_i,
	d_o
);
	parameter [31:0] Depth = 1;
	input wire clk_i;
	input wire rst_ni;
	input wire d_i;
	output reg d_o;
	generate
		if (Depth == 0) begin : genblk1
			wire [1:1] sv2v_tmp_021F4;
			assign sv2v_tmp_021F4 = d_i;
			always @(*) d_o = sv2v_tmp_021F4;
		end
		else if (Depth == 1) begin : genblk1
			always @(posedge clk_i or negedge rst_ni)
				if (~rst_ni)
					d_o <= 1'sb0;
				else
					d_o <= d_i;
		end
		else if (Depth > 1) begin : genblk1
			wire [Depth - 1:0] reg_d;
			reg [Depth - 1:0] reg_q;
			wire [1:1] sv2v_tmp_D887A;
			assign sv2v_tmp_D887A = reg_q[Depth - 1];
			always @(*) d_o = sv2v_tmp_D887A;
			assign reg_d = {reg_q[Depth - 2:0], d_i};
			always @(posedge clk_i or negedge rst_ni)
				if (~rst_ni)
					reg_q <= 1'sb0;
				else
					reg_q <= reg_d;
		end
	endgenerate
endmodule
