module stream_fork (
	clk_i,
	rst_ni,
	valid_i,
	ready_o,
	valid_o,
	ready_i
);
	parameter [31:0] N_OUP = 0;
	input wire clk_i;
	input wire rst_ni;
	input wire valid_i;
	output reg ready_o;
	output reg [N_OUP - 1:0] valid_o;
	input wire [N_OUP - 1:0] ready_i;
	reg [N_OUP - 1:0] oup_ready;
	wire [N_OUP - 1:0] all_ones;
	reg inp_state_d;
	reg inp_state_q;
	always @(*) begin
		inp_state_d = inp_state_q;
		case (inp_state_q)
			1'd0:
				if (valid_i) begin
					if ((valid_o == all_ones) && (ready_i == all_ones))
						ready_o = 1'b1;
					else begin
						ready_o = 1'b0;
						inp_state_d = 1'd1;
					end
				end
				else
					ready_o = 1'b0;
			1'd1:
				if (valid_i && (oup_ready == all_ones)) begin
					ready_o = 1'b1;
					inp_state_d = 1'd0;
				end
				else
					ready_o = 1'b0;
			default: begin
				inp_state_d = 1'd0;
				ready_o = 1'b0;
			end
		endcase
	end
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni)
			inp_state_q <= 1'd0;
		else
			inp_state_q <= inp_state_d;
	genvar i;
	generate
		for (i = 0; i < N_OUP; i = i + 1) begin : gen_oup_state
			reg oup_state_d;
			reg oup_state_q;
			always @(*) begin
				oup_ready[i] = 1'b1;
				valid_o[i] = 1'b0;
				oup_state_d = oup_state_q;
				case (oup_state_q)
					1'd0:
						if (valid_i) begin
							valid_o[i] = 1'b1;
							if (ready_i[i]) begin
								if (!ready_o)
									oup_state_d = 1'd1;
							end
							else
								oup_ready[i] = 1'b0;
						end
					1'd1:
						if (valid_i && ready_o)
							oup_state_d = 1'd0;
					default: oup_state_d = 1'd0;
				endcase
			end
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					oup_state_q <= 1'd0;
				else
					oup_state_q <= oup_state_d;
		end
	endgenerate
	assign all_ones = 1'sb1;
	initial begin : p_assertions
		
	end
endmodule
