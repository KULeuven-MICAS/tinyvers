module axi_lite_to_axi (
	in,
	out
);
	input AXI_LITE.Slave in;
	input AXI_BUS.Master out;
	assign out.aw_id = 1'sb0;
	assign out.aw_addr = in.aw_addr;
	assign out.aw_len = 1'sb0;
	assign out.aw_size = $unsigned($clog2($bits(type(out.w_data)) / 8));
	localparam axi_pkg_BURST_FIXED = 2'b00;
	assign out.aw_burst = axi_pkg_BURST_FIXED;
	assign out.aw_lock = 1'sb0;
	assign out.aw_cache = 1'sb0;
	assign out.aw_prot = 1'sb0;
	assign out.aw_qos = 1'sb0;
	assign out.aw_region = 1'sb0;
	assign out.aw_atop = 1'sb0;
	assign out.aw_user = 1'sb0;
	assign out.aw_valid = in.aw_valid;
	assign in.aw_ready = out.aw_ready;
	assign out.w_data = in.w_data;
	assign out.w_strb = in.w_strb;
	assign out.w_last = 1'sb1;
	assign out.w_user = 1'sb0;
	assign out.w_valid = in.w_valid;
	assign in.w_ready = out.w_ready;
	assign in.b_resp = out.b_resp;
	assign in.b_valid = out.b_valid;
	assign out.b_ready = in.b_ready;
	assign out.ar_id = 1'sb0;
	assign out.ar_addr = in.ar_addr;
	assign out.ar_len = 1'sb0;
	assign out.ar_size = $unsigned($clog2($bits(type(out.r_data)) / 8));
	assign out.ar_burst = axi_pkg_BURST_FIXED;
	assign out.ar_lock = 1'sb0;
	assign out.ar_cache = 1'sb0;
	assign out.ar_prot = 1'sb0;
	assign out.ar_qos = 1'sb0;
	assign out.ar_region = 1'sb0;
	assign out.ar_user = 1'sb0;
	assign out.ar_valid = in.ar_valid;
	assign in.ar_ready = out.ar_ready;
	assign in.r_data = out.r_data;
	assign in.r_resp = out.r_resp;
	assign in.r_valid = out.r_valid;
	assign out.r_ready = in.r_ready;
endmodule
