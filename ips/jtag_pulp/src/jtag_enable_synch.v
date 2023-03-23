module jtag_enable_synch (
	clk_i,
	rst_ni,
	tck,
	enable
);
	input wire clk_i;
	input wire rst_ni;
	input wire tck;
	output wire enable;
	reg tck1;
	reg tck2;
	reg tck3;
	always @(negedge rst_ni or posedge clk_i)
		if (~rst_ni) begin
			tck1 <= 1'b0;
			tck2 <= 1'b0;
			tck3 <= 1'b0;
		end
		else begin
			tck1 <= tck;
			tck2 <= tck1;
			tck3 <= tck2;
		end
	assign enable = ~tck3 & tck2;
endmodule
