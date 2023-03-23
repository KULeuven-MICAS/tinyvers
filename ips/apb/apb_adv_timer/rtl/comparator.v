module comparator (
	clk_i,
	rstn_i,
	ctrl_active_i,
	ctrl_update_i,
	ctrl_rst_i,
	cfg_comp_i,
	cfg_comp_op_i,
	timer_end_i,
	timer_valid_i,
	timer_sawtooth_i,
	timer_count_i,
	result_o
);
	parameter NUM_BITS = 16;
	input wire clk_i;
	input wire rstn_i;
	input wire ctrl_active_i;
	input wire ctrl_update_i;
	input wire ctrl_rst_i;
	input wire [NUM_BITS - 1:0] cfg_comp_i;
	input wire [2:0] cfg_comp_op_i;
	input wire timer_end_i;
	input wire timer_valid_i;
	input wire timer_sawtooth_i;
	input wire [NUM_BITS - 1:0] timer_count_i;
	output wire result_o;
	reg [NUM_BITS - 1:0] r_comp;
	reg [2:0] r_comp_op;
	reg r_value;
	wire r_active;
	reg r_is_2nd_event;
	wire s_match;
	wire s_2nd_event;
	assign s_match = timer_valid_i & (r_comp == timer_count_i);
	assign s_2nd_event = (timer_sawtooth_i ? timer_end_i : s_match);
	assign result_o = r_value;
	always @(posedge clk_i or negedge rstn_i) begin : proc_r_comp
		if (~rstn_i) begin
			r_comp <= 0;
			r_comp_op <= 0;
		end
		else if (ctrl_update_i) begin
			r_comp <= cfg_comp_i;
			r_comp_op <= cfg_comp_op_i;
		end
	end
	always @(posedge clk_i or negedge rstn_i) begin : proc_r_value
		if (~rstn_i) begin
			r_value <= 0;
			r_is_2nd_event <= 1'b0;
		end
		else if (ctrl_rst_i) begin
			r_value <= 1'b0;
			r_is_2nd_event <= 1'b0;
		end
		else if (timer_valid_i && ctrl_active_i)
			case (r_comp_op)
				3'b000: r_value <= (s_match ? 1'b1 : r_value);
				3'b001:
					if (timer_sawtooth_i) begin
						if (s_match)
							r_value <= ~r_value;
						else if (s_2nd_event)
							r_value <= 1'b0;
					end
					else if (s_match && !r_is_2nd_event) begin
						r_value <= ~r_value;
						r_is_2nd_event <= 1'b1;
					end
					else if (s_match && r_is_2nd_event) begin
						r_value <= 1'b0;
						r_is_2nd_event <= 1'b0;
					end
				3'b010:
					if (timer_sawtooth_i) begin
						if (s_match)
							r_value <= 1'b1;
						else if (s_2nd_event)
							r_value <= 1'b0;
					end
					else if (s_match && !r_is_2nd_event) begin
						r_value <= 1'b1;
						r_is_2nd_event <= 1'b1;
					end
					else if (s_match && r_is_2nd_event) begin
						r_value <= 1'b0;
						r_is_2nd_event <= 1'b0;
					end
				3'b011: r_value <= (s_match ? ~r_value : r_value);
				3'b100: r_value <= (s_match ? 1'b0 : r_value);
				3'b101:
					if (timer_sawtooth_i) begin
						if (s_match)
							r_value <= ~r_value;
						else if (s_2nd_event)
							r_value <= 1'b1;
					end
					else if (s_match && !r_is_2nd_event) begin
						r_value <= ~r_value;
						r_is_2nd_event <= 1'b1;
					end
					else if (s_match && r_is_2nd_event) begin
						r_value <= 1'b1;
						r_is_2nd_event <= 1'b0;
					end
				3'b110:
					if (timer_sawtooth_i) begin
						if (s_match)
							r_value <= 1'b0;
						else if (s_2nd_event)
							r_value <= 1'b1;
					end
					else if (s_match && !r_is_2nd_event) begin
						r_value <= 1'b0;
						r_is_2nd_event <= 1'b1;
					end
					else if (s_match && r_is_2nd_event) begin
						r_value <= 1'b1;
						r_is_2nd_event <= 1'b0;
					end
				default: begin
					r_value <= r_value;
					r_is_2nd_event <= 1'b0;
				end
			endcase
	end
endmodule
