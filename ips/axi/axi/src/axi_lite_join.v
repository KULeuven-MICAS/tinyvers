module axi_lite_join (
	in,
	out
);
	input AXI_LITE.Slave in;
	input AXI_LITE.Master out;
	assign out.aw_addr = in.aw_addr;
	assign out.aw_valid = in.aw_valid;
	assign out.w_data = in.w_data;
	assign out.w_strb = in.w_strb;
	assign out.w_valid = in.w_valid;
	assign out.b_ready = in.b_ready;
	assign out.ar_addr = in.ar_addr;
	assign out.ar_valid = in.ar_valid;
	assign out.r_ready = in.r_ready;
	assign in.aw_ready = out.aw_ready;
	assign in.w_ready = out.w_ready;
	assign in.b_resp = out.b_resp;
	assign in.b_valid = out.b_valid;
	assign in.ar_ready = out.ar_ready;
	assign in.r_data = out.r_data;
	assign in.r_resp = out.r_resp;
	assign in.r_valid = out.r_valid;
endmodule
