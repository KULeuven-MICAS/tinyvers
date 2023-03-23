module jtag_rst_synch (
	clk_i,
	trst_ni,
	rst_sync,
	test_mode_i,
	rst_ni
);
	input wire clk_i;
	input wire trst_ni;
	output wire rst_sync;
	input wire test_mode_i;
	input wire rst_ni;
	reg trst1;
	reg trst2;
	reg trst3;
	reg trst4;
	reg trst5;
	always @(posedge clk_i or negedge trst_ni)
		if (~trst_ni) begin
			trst1 <= 1'b0;
			trst2 <= 1'b0;
			trst3 <= 1'b0;
			trst4 <= 1'b0;
			trst5 <= 1'b0;
		end
		else begin
			trst1 <= trst_ni;
			trst2 <= trst1;
			trst3 <= trst2;
			trst4 <= trst3;
			trst5 <= trst4;
		end
	assign rst_sync = (test_mode_i ? rst_ni : trst5 & trst_ni);
endmodule
