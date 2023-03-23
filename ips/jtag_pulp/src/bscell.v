module bscell (
	clk_i,
	rst_ni,
	mode_i,
	enable_i,
	shift_dr_i,
	capture_dr_i,
	update_dr_i,
	scan_in_i,
	jtagreg_in_i,
	scan_out_o,
	jtagreg_out_o
);
	input wire clk_i;
	input wire rst_ni;
	input wire mode_i;
	input wire enable_i;
	input wire shift_dr_i;
	input wire capture_dr_i;
	input wire update_dr_i;
	input wire scan_in_i;
	input wire jtagreg_in_i;
	output wire scan_out_o;
	output wire jtagreg_out_o;
	reg r_dataout;
	reg r_datasample;
	wire s_datasample_next;
	always @(negedge rst_ni or posedge clk_i)
		if (~rst_ni) begin
			r_datasample <= 1'b0;
			r_dataout <= 1'b0;
		end
		else begin
			if ((shift_dr_i | capture_dr_i) & enable_i)
				r_datasample <= s_datasample_next;
			if (update_dr_i & enable_i)
				r_dataout <= r_datasample;
		end
	assign s_datasample_next = (shift_dr_i ? scan_in_i : jtagreg_in_i);
	assign jtagreg_out_o = (mode_i ? r_dataout : jtagreg_in_i);
	assign scan_out_o = r_datasample;
endmodule
