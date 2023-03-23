module cdc_2phase (
	src_rst_ni,
	src_clk_i,
	src_data_i,
	src_valid_i,
	src_ready_o,
	dst_rst_ni,
	dst_clk_i,
	dst_data_o,
	dst_valid_o,
	dst_ready_i
);
	input wire src_rst_ni;
	input wire src_clk_i;
	input wire src_data_i;
	input wire src_valid_i;
	output wire src_ready_o;
	input wire dst_rst_ni;
	input wire dst_clk_i;
	output wire dst_data_o;
	output wire dst_valid_o;
	input wire dst_ready_i;
	(* dont_touch = "true" *) wire async_req;
	(* dont_touch = "true" *) wire async_ack;
	(* dont_touch = "true" *) wire async_data;
	cdc_2phase_src_DB24D i_src(
		.rst_ni(src_rst_ni),
		.clk_i(src_clk_i),
		.data_i(src_data_i),
		.valid_i(src_valid_i),
		.ready_o(src_ready_o),
		.async_req_o(async_req),
		.async_ack_i(async_ack),
		.async_data_o(async_data)
	);
	cdc_2phase_dst_80C32 i_dst(
		.rst_ni(dst_rst_ni),
		.clk_i(dst_clk_i),
		.data_o(dst_data_o),
		.valid_o(dst_valid_o),
		.ready_i(dst_ready_i),
		.async_req_i(async_req),
		.async_ack_o(async_ack),
		.async_data_i(async_data)
	);
endmodule
module cdc_2phase_src_DB24D (
	rst_ni,
	clk_i,
	data_i,
	valid_i,
	ready_o,
	async_req_o,
	async_ack_i,
	async_data_o
);
	input wire rst_ni;
	input wire clk_i;
	input wire data_i;
	input wire valid_i;
	output wire ready_o;
	output wire async_req_o;
	input wire async_ack_i;
	output wire async_data_o;
	(* dont_touch = "true" *) reg req_src_q;
	(* dont_touch = "true" *) reg ack_src_q;
	(* dont_touch = "true" *) reg ack_q;
	(* dont_touch = "true" *) reg data_src_q;
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni) begin
			req_src_q <= 0;
			data_src_q <= 1'sb0;
		end
		else if (valid_i && ready_o) begin
			req_src_q <= ~req_src_q;
			data_src_q <= data_i;
		end
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni) begin
			ack_src_q <= 0;
			ack_q <= 0;
		end
		else begin
			ack_src_q <= async_ack_i;
			ack_q <= ack_src_q;
		end
	assign ready_o = req_src_q == ack_q;
	assign async_req_o = req_src_q;
	assign async_data_o = data_src_q;
endmodule
module cdc_2phase_dst_80C32 (
	rst_ni,
	clk_i,
	data_o,
	valid_o,
	ready_i,
	async_req_i,
	async_ack_o,
	async_data_i
);
	input wire rst_ni;
	input wire clk_i;
	output wire data_o;
	output wire valid_o;
	input wire ready_i;
	input wire async_req_i;
	output wire async_ack_o;
	input wire async_data_i;
	(* dont_touch = "true" *) (* async_reg = "true" *) reg req_dst_q;
	(* dont_touch = "true" *) (* async_reg = "true" *) reg req_q0;
	(* dont_touch = "true" *) (* async_reg = "true" *) reg req_q1;
	(* dont_touch = "true" *) (* async_reg = "true" *) reg ack_dst_q;
	(* dont_touch = "true" *) reg data_dst_q;
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni)
			ack_dst_q <= 0;
		else if (valid_o && ready_i)
			ack_dst_q <= ~ack_dst_q;
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni)
			data_dst_q <= 1'sb0;
		else if ((req_q0 != req_q1) && !valid_o)
			data_dst_q <= async_data_i;
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni) begin
			req_dst_q <= 0;
			req_q0 <= 0;
			req_q1 <= 0;
		end
		else begin
			req_dst_q <= async_req_i;
			req_q0 <= req_dst_q;
			req_q1 <= req_q0;
		end
	assign valid_o = ack_dst_q != req_q1;
	assign data_o = data_dst_q;
	assign async_ack_o = ack_dst_q;
endmodule
