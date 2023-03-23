module RR_Flag_Req_L2 (
	clk,
	rst_n,
	RR_FLAG_o,
	data_req_i,
	data_gnt_i
);
	parameter WIDTH = 3;
	parameter MAX_COUNT = (2 ** WIDTH) - 1;
	input wire clk;
	input wire rst_n;
	output reg [WIDTH - 1:0] RR_FLAG_o;
	input wire data_req_i;
	input wire data_gnt_i;
	always @(posedge clk or negedge rst_n) begin : RR_Flag_Req_SEQ
		if (rst_n == 1'b0)
			RR_FLAG_o <= 1'sb0;
		else if (data_req_i & data_gnt_i)
			if (RR_FLAG_o < MAX_COUNT)
				RR_FLAG_o <= RR_FLAG_o + 1'b1;
			else
				RR_FLAG_o <= 1'sb0;
	end
endmodule
