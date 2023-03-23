module lfsr_8bit (
	clk_i,
	rst_ni,
	en_i,
	refill_way_oh,
	refill_way_bin
);
	parameter [7:0] SEED = 8'b00000000;
	parameter [31:0] WIDTH = 8;
	input wire clk_i;
	input wire rst_ni;
	input wire en_i;
	output reg [WIDTH - 1:0] refill_way_oh;
	output reg [$clog2(WIDTH) - 1:0] refill_way_bin;
	localparam [31:0] LOG_WIDTH = $clog2(WIDTH);
	reg [7:0] shift_d;
	reg [7:0] shift_q;
	always @(*) begin : sv2v_autoblock_1
		reg shift_in;
		shift_in = !(((shift_q[7] ^ shift_q[3]) ^ shift_q[2]) ^ shift_q[1]);
		shift_d = shift_q;
		if (en_i)
			shift_d = {shift_q[6:0], shift_in};
		refill_way_oh = 'b0;
		refill_way_oh[shift_q[LOG_WIDTH - 1:0]] = 1'b1;
		refill_way_bin = shift_q;
	end
	always @(posedge clk_i or negedge rst_ni) begin : proc_
		if (~rst_ni)
			shift_q <= SEED;
		else
			shift_q <= shift_d;
	end
endmodule
