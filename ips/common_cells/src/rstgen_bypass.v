module rstgen_bypass (
	clk_i,
	rst_ni,
	rst_test_mode_ni,
	test_mode_i,
	rst_no,
	init_no
);
	parameter NumRegs = 4;
	input wire clk_i;
	input wire rst_ni;
	input wire rst_test_mode_ni;
	input wire test_mode_i;
	output reg rst_no;
	output reg init_no;
	reg rst_n;
	reg [NumRegs - 1:0] synch_regs_q;
	always @(*)
		if (test_mode_i == 1'b0) begin
			rst_n = rst_ni;
			rst_no = synch_regs_q[NumRegs - 1];
			init_no = synch_regs_q[NumRegs - 1];
		end
		else begin
			rst_n = rst_test_mode_ni;
			rst_no = rst_test_mode_ni;
			init_no = 1'b1;
		end
	always @(posedge clk_i or negedge rst_n)
		if (~rst_n)
			synch_regs_q <= 0;
		else
			synch_regs_q <= {synch_regs_q[NumRegs - 2:0], 1'b1};
	initial begin : p_assertions
		if (NumRegs < 1)
			$fatal(1, "At least one register is required.");
	end
endmodule
