module mac_engine (
	clk_i,
	rst_ni,
	test_mode_i,
	a_i,
	b_i,
	c_i,
	d_o,
	ctrl_i,
	flags_o
);
	input wire clk_i;
	input wire rst_ni;
	input wire test_mode_i;
	input hwpe_stream_intf_stream.sink a_i;
	input hwpe_stream_intf_stream.sink b_i;
	input hwpe_stream_intf_stream.sink c_i;
	input hwpe_stream_intf_stream.source d_o;
	localparam [31:0] mac_package_MAC_CNT_LEN = 1024;
	input wire [25:0] ctrl_i;
	output wire [75:0] flags_o;
	reg [10:0] cnt;
	reg [10:0] r_cnt;
	reg signed [63:0] c_shifted;
	reg signed [63:0] mult;
	reg signed [63:0] r_mult;
	reg r_mult_valid;
	wire r_mult_ready;
	reg signed [73:0] r_acc;
	reg r_acc_valid;
	wire r_acc_ready;
	reg signed [73:0] d_nonshifted;
	reg d_nonshifted_valid;
	always @(*) begin : shift_c
		c_shifted = $signed(c_i.data <<< ctrl_i[20-:5]);
	end
	always @(*) begin : mult_a_X_b
		mult = $signed(a_i.data) * $signed(b_i.data);
	end
	always @(posedge clk_i or negedge rst_ni) begin : mult_pipe_data
		if (~rst_ni)
			r_mult <= 1'sb0;
		else if (ctrl_i[25])
			r_mult <= 1'sb0;
		else if (ctrl_i[24])
			if (((a_i.valid & b_i.valid) & a_i.ready) & b_i.ready)
				r_mult <= mult;
	end
	always @(posedge clk_i or negedge rst_ni) begin : mult_pipe_valid
		if (~rst_ni)
			r_mult_valid <= 1'sb0;
		else if (ctrl_i[25])
			r_mult_valid <= 1'sb0;
		else if (ctrl_i[24])
			if ((a_i.valid & b_i.valid) | (r_mult_valid & r_mult_ready))
				r_mult_valid <= a_i.valid & b_i.valid;
	end
	always @(posedge clk_i or negedge rst_ni) begin : accumulator
		if (~rst_ni)
			r_acc <= 1'sb0;
		else if (ctrl_i[25])
			r_acc <= 1'sb0;
		else if (ctrl_i[24])
			if (((r_mult_valid & r_mult_ready) & c_i.valid) & c_i.ready)
				r_acc <= $signed(c_shifted + r_mult);
			else if (c_i.valid & c_i.ready)
				r_acc <= $signed(c_shifted);
			else if (r_mult_valid & r_mult_ready)
				r_acc <= $signed(r_acc + r_mult);
	end
	always @(posedge clk_i or negedge rst_ni) begin : accumulator_valid
		if (~rst_ni)
			r_acc_valid <= 1'sb0;
		else if (ctrl_i[25])
			r_acc_valid <= 1'sb0;
		else if (ctrl_i[24])
			if ((r_cnt == ctrl_i[15-:11]) | (r_acc_valid & r_acc_ready))
				r_acc_valid <= r_cnt == ctrl_i[15-:11];
	end
	always @(*) begin : d_nonshifted_comb
		if (ctrl_i[22]) begin
			d_nonshifted = $signed(r_mult);
			d_nonshifted_valid = r_mult_valid;
		end
		else begin
			d_nonshifted = r_acc;
			d_nonshifted_valid = r_acc_valid;
		end
	end
	always @(*) begin
		d_o.data = $signed(d_nonshifted >>> ctrl_i[20-:5]);
		d_o.valid = ctrl_i[24] & d_nonshifted_valid;
		d_o.strb = 1'sb1;
	end
	always @(*) cnt = r_cnt + 1;
	always @(posedge clk_i or negedge rst_ni)
		if (~rst_ni)
			r_cnt <= 1'sb0;
		else if (ctrl_i[25])
			r_cnt <= 1'sb0;
		else if (ctrl_i[24])
			if ((ctrl_i[21] == 1'b1) || (((r_cnt > 0) && (r_cnt < ctrl_i[15-:11])) && (r_mult_valid & (r_mult_ready == 1'b1))))
				r_cnt <= cnt;
	assign flags_o[75-:11] = r_cnt;
	assign r_acc_ready = d_o.ready | ~r_acc_valid;
	assign r_mult_ready = (ctrl_i[22] ? d_o.ready | ~r_mult_valid : r_acc_ready | ~r_mult_valid);
	assign a_i.ready = ((r_mult_ready & a_i.valid) & b_i.valid) | (~a_i.valid & ~b_i.valid);
	assign b_i.ready = ((r_mult_ready & a_i.valid) & b_i.valid) | (~a_i.valid & ~b_i.valid);
	assign c_i.ready = r_acc_ready | ~c_i.valid;
endmodule
