module axi_arbiter (
	clk_i,
	rst_ni,
	arb
);
	parameter signed [31:0] NUM_REQ = -1;
	input wire clk_i;
	input wire rst_ni;
	input AXI_ARBITRATION.arb arb;
	wire [$clog2(NUM_REQ) - 1:0] count_d;
	reg [$clog2(NUM_REQ) - 1:0] count_q;
	localparam signed [31:0] sv2v_uu_i_tree_ID_WIDTH = 0;
	localparam signed [31:0] sv2v_uu_i_tree_NUM_REQ = NUM_REQ;
	localparam [(sv2v_uu_i_tree_NUM_REQ * sv2v_uu_i_tree_ID_WIDTH) - 1:0] sv2v_uu_i_tree_ext_in_id_i_0 = 1'sb0;
	axi_arbiter_tree #(
		.NUM_REQ(NUM_REQ),
		.ID_WIDTH(0)
	) i_tree(
		.in_req_i(arb.in_req),
		.in_ack_o(arb.in_ack),
		.in_id_i(sv2v_uu_i_tree_ext_in_id_i_0),
		.out_req_o(arb.out_req),
		.out_ack_i(arb.out_ack),
		.out_id_o(arb.out_sel),
		.shift_i(count_q)
	);
	always @(posedge clk_i or negedge rst_ni)
		if (~rst_ni)
			count_q <= 1'sb0;
		else if (arb.out_req && arb.out_ack)
			count_q <= (count_d == NUM_REQ ? {$clog2(NUM_REQ) {1'sb0}} : count_d);
	assign count_d = count_q + 1;
endmodule
module axi_arbiter_tree (
	in_req_i,
	in_ack_o,
	in_id_i,
	out_req_o,
	out_ack_i,
	out_id_o,
	shift_i
);
	parameter signed [31:0] NUM_REQ = -1;
	parameter signed [31:0] ID_WIDTH = -1;
	input wire [NUM_REQ - 1:0] in_req_i;
	output wire [NUM_REQ - 1:0] in_ack_o;
	input wire [(NUM_REQ * ID_WIDTH) - 1:0] in_id_i;
	output wire out_req_o;
	input wire out_ack_i;
	output wire [(ID_WIDTH + $clog2(NUM_REQ)) - 1:0] out_id_o;
	input wire [$clog2(NUM_REQ) - 1:0] shift_i;
	localparam signed [31:0] NUM_INNER_REQ = (NUM_REQ > 0 ? 2 ** ($clog2(NUM_REQ) - 1) : 0);
	localparam [ID_WIDTH:0] ID_MASK = (1 << ID_WIDTH) - 1;
	wire shift_bit;
	assign shift_bit = shift_i[$clog2(NUM_REQ) - 1];
	wire [NUM_INNER_REQ - 1:0] inner_req;
	wire [NUM_INNER_REQ - 1:0] inner_ack;
	wire [(ID_WIDTH >= 0 ? (NUM_INNER_REQ * (ID_WIDTH + 1)) - 1 : (NUM_INNER_REQ * (1 - ID_WIDTH)) + (ID_WIDTH - 1)):(ID_WIDTH >= 0 ? 0 : ID_WIDTH + 0)] inner_id;
	genvar i;
	generate
		for (i = 0; i < NUM_INNER_REQ; i = i + 1) begin : g_head
			localparam iA = i * 2;
			localparam iB = (i * 2) + 1;
			if (iB < NUM_REQ) begin : genblk1
				reg sel;
				always @(*)
					if (in_req_i[iA] && in_req_i[iB])
						sel = shift_bit;
					else if (in_req_i[iA])
						sel = 0;
					else if (in_req_i[iB])
						sel = 1;
					else
						sel = 0;
				assign inner_req[i] = in_req_i[iA] | in_req_i[iB];
				assign in_ack_o[iA] = inner_ack[i] && (sel == 0);
				assign in_ack_o[iB] = inner_ack[i] && (sel == 1);
				assign inner_id[(ID_WIDTH >= 0 ? 0 : ID_WIDTH) + (i * (ID_WIDTH >= 0 ? ID_WIDTH + 1 : 1 - ID_WIDTH))+:(ID_WIDTH >= 0 ? ID_WIDTH + 1 : 1 - ID_WIDTH)] = (sel << ID_WIDTH) | ((sel ? in_id_i[iB * ID_WIDTH+:ID_WIDTH] : in_id_i[iA * ID_WIDTH+:ID_WIDTH]) & ID_MASK);
			end
			else if (iA < NUM_REQ) begin : genblk1
				assign inner_req[i] = in_req_i[iA];
				assign in_ack_o[iA] = inner_ack[i];
				assign inner_id[(ID_WIDTH >= 0 ? 0 : ID_WIDTH) + (i * (ID_WIDTH >= 0 ? ID_WIDTH + 1 : 1 - ID_WIDTH))+:(ID_WIDTH >= 0 ? ID_WIDTH + 1 : 1 - ID_WIDTH)] = in_id_i[iA * ID_WIDTH+:ID_WIDTH] & ID_MASK;
			end
		end
		if (NUM_INNER_REQ > 1) begin : g_tail
			axi_arbiter_tree #(
				.NUM_REQ(NUM_INNER_REQ),
				.ID_WIDTH(ID_WIDTH + 1)
			) i_tail(
				.in_req_i(inner_req),
				.in_ack_o(inner_ack),
				.in_id_i(inner_id),
				.out_req_o(out_req_o),
				.out_ack_i(out_ack_i),
				.out_id_o(out_id_o),
				.shift_i(shift_i[$clog2(NUM_REQ) - 2:0])
			);
		end
		else if (NUM_INNER_REQ == 1) begin : g_tail
			assign out_req_o = inner_req;
			assign inner_ack = out_ack_i;
			assign out_id_o = inner_id[(ID_WIDTH >= 0 ? 0 : ID_WIDTH) + 0+:(ID_WIDTH >= 0 ? ID_WIDTH + 1 : 1 - ID_WIDTH)];
		end
		else begin : g_tail
			assign out_req_o = in_req_i[0];
			assign in_ack_o[0] = out_ack_i;
			assign out_id_o = in_id_i[0+:ID_WIDTH];
		end
	endgenerate
endmodule
