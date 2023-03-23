module generic_LFSR_8bit (
	data_OH_o,
	data_BIN_o,
	enable_i,
	clk,
	rst_n
);
	parameter OH_WIDTH = 4;
	parameter BIN_WIDTH = $clog2(OH_WIDTH);
	parameter SEED = 8'b00000000;
	output reg [OH_WIDTH - 1:0] data_OH_o;
	output wire [BIN_WIDTH - 1:0] data_BIN_o;
	input wire enable_i;
	input wire clk;
	input wire rst_n;
	reg [7:0] out;
	wire linear_feedback;
	wire [BIN_WIDTH - 1:0] temp_ref_way;
	assign linear_feedback = !(((out[7] ^ out[3]) ^ out[2]) ^ out[1]);
	assign data_BIN_o = temp_ref_way;
	always @(posedge clk or negedge rst_n)
		if (rst_n == 1'b0)
			out <= SEED;
		else if (enable_i)
			out <= {out[6], out[5], out[4], out[3], out[2], out[1], out[0], linear_feedback};
	generate
		if (OH_WIDTH == 2) begin : genblk1
			assign temp_ref_way = out[1];
		end
		else begin : genblk1
			assign temp_ref_way = out[BIN_WIDTH:1];
		end
	endgenerate
	always @(*) begin
		data_OH_o = 1'sb0;
		data_OH_o[temp_ref_way] = 1'b1;
	end
endmodule
