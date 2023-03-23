module prioarbiter (
	clk_i,
	rst_ni,
	flush_i,
	en_i,
	req_i,
	ack_o,
	vld_o,
	idx_o
);
	parameter [31:0] NUM_REQ = 13;
	parameter [31:0] LOCK_IN = 0;
	input wire clk_i;
	input wire rst_ni;
	input wire flush_i;
	input wire en_i;
	input wire [NUM_REQ - 1:0] req_i;
	output wire [NUM_REQ - 1:0] ack_o;
	output wire vld_o;
	output wire [$clog2(NUM_REQ) - 1:0] idx_o;
	localparam SEL_WIDTH = $clog2(NUM_REQ);
	wire [SEL_WIDTH - 1:0] arb_sel_lock_d;
	reg [SEL_WIDTH - 1:0] arb_sel_lock_q;
	wire lock_d;
	reg lock_q;
	wire [$clog2(NUM_REQ) - 1:0] idx;
	assign vld_o = |req_i & en_i;
	assign idx_o = (lock_q ? arb_sel_lock_q : idx);
	assign ack_o[0] = (req_i[0] ? en_i : 1'b0);
	genvar i;
	generate
		for (i = 1; i < NUM_REQ; i = i + 1) begin : gen_arb_req_ports
			assign ack_o[i] = (req_i[i] & ~(|ack_o[i - 1:0]) ? en_i : 1'b0);
		end
	endgenerate
	onehot_to_bin #(.ONEHOT_WIDTH(NUM_REQ)) i_onehot_to_bin(
		.onehot(ack_o),
		.bin(idx)
	);
	generate
		if (LOCK_IN) begin : gen_lock_in
			assign lock_d = |req_i & ~en_i;
			assign arb_sel_lock_d = idx_o;
		end
		else begin : genblk2
			assign lock_d = 1'sb0;
			assign arb_sel_lock_d = 1'sb0;
		end
	endgenerate
	always @(posedge clk_i or negedge rst_ni) begin : p_regs
		if (!rst_ni) begin
			lock_q <= 1'b0;
			arb_sel_lock_q <= 1'sb0;
		end
		else if (flush_i) begin
			lock_q <= 1'b0;
			arb_sel_lock_q <= 1'sb0;
		end
		else begin
			lock_q <= lock_d;
			arb_sel_lock_q <= arb_sel_lock_d;
		end
	end
endmodule
