module jtag_sync (
	clk_i,
	rst_ni,
	tosynch,
	synched
);
	input wire clk_i;
	input wire rst_ni;
	input wire tosynch;
	output reg synched;
	reg synch1;
	reg synch2;
	reg synch3;
	always @(posedge clk_i or negedge rst_ni)
		if (~rst_ni) begin
			synch1 <= 1'b0;
			synch2 <= 1'b0;
			synch3 <= 1'b0;
			synched <= 1'b0;
		end
		else begin
			synch1 <= tosynch;
			synch2 <= synch1;
			synch3 <= synch2;
			synched <= synch3;
		end
endmodule
