module edge_propagator_tx (
	clk_i,
	rstn_i,
	valid_i,
	ack_i,
	valid_o
);
	input wire clk_i;
	input wire rstn_i;
	input wire valid_i;
	input wire ack_i;
	output wire valid_o;
	reg [1:0] sync_a;
	reg r_input_reg;
	wire s_input_reg_next;
	assign s_input_reg_next = valid_i | (r_input_reg & ~sync_a[0]);
	always @(negedge rstn_i or posedge clk_i)
		if (~rstn_i) begin
			r_input_reg <= 1'b0;
			sync_a <= 2'b00;
		end
		else begin
			r_input_reg <= s_input_reg_next;
			sync_a <= {ack_i, sync_a[1]};
		end
	assign valid_o = r_input_reg;
endmodule
