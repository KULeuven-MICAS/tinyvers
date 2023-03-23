module stream_delay (
	clk_i,
	rst_ni,
	payload_i,
	ready_o,
	valid_i,
	payload_o,
	ready_i,
	valid_o
);
	parameter [0:0] StallRandom = 0;
	parameter signed [31:0] FixedDelay = 1;
	input wire clk_i;
	input wire rst_ni;
	input wire payload_i;
	output reg ready_o;
	input wire valid_i;
	output wire payload_o;
	input wire ready_i;
	output reg valid_o;
	generate
		if ((FixedDelay == 0) && !StallRandom) begin : pass_through
			wire [1:1] sv2v_tmp_EBB74;
			assign sv2v_tmp_EBB74 = ready_i;
			always @(*) ready_o = sv2v_tmp_EBB74;
			wire [1:1] sv2v_tmp_17E50;
			assign sv2v_tmp_17E50 = valid_i;
			always @(*) valid_o = sv2v_tmp_17E50;
			assign payload_o = payload_i;
		end
		else begin : genblk1
			localparam COUNTER_BITS = 4;
			reg [1:0] state_d;
			reg [1:0] state_q;
			reg load;
			wire [3:0] count_out;
			reg en;
			wire [3:0] counter_load;
			assign payload_o = payload_i;
			always @(*) begin
				state_d = state_q;
				valid_o = 1'b0;
				ready_o = 1'b0;
				load = 1'b0;
				en = 1'b0;
				case (state_q)
					2'd0:
						if (valid_i) begin
							load = 1'b1;
							state_d = 2'd1;
							if ((FixedDelay == 1) || (StallRandom && (counter_load == 1)))
								state_d = 2'd2;
							if (StallRandom && (counter_load == 0)) begin
								valid_o = 1'b1;
								ready_o = ready_i;
								if (ready_i)
									state_d = 2'd0;
								else
									state_d = 2'd2;
							end
						end
					2'd1: begin
						en = 1'b1;
						if (count_out == 0)
							state_d = 2'd2;
					end
					2'd2: begin
						valid_o = 1'b1;
						ready_o = ready_i;
						if (ready_i)
							state_d = 2'd0;
					end
					default:
						;
				endcase
			end
			if (StallRandom) begin : random_stall
				lfsr_16bit #(.WIDTH(16)) i_lfsr_16bit(
					.clk_i(clk_i),
					.rst_ni(rst_ni),
					.en_i(load),
					.refill_way_oh(),
					.refill_way_bin(counter_load)
				);
			end
			else begin : genblk1
				assign counter_load = FixedDelay;
			end
			counter #(.WIDTH(COUNTER_BITS)) i_counter(
				.clk_i(clk_i),
				.rst_ni(rst_ni),
				.clear_i(1'b0),
				.en_i(en),
				.load_i(load),
				.down_i(1'b1),
				.d_i(counter_load),
				.q_o(count_out),
				.overflow_o()
			);
			always @(posedge clk_i or negedge rst_ni)
				if (~rst_ni)
					state_q <= 2'd0;
				else
					state_q <= state_d;
		end
	endgenerate
endmodule
