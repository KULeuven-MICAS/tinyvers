module exp_backoff (
	clk_i,
	rst_ni,
	set_i,
	clr_i,
	is_zero_o
);
	parameter [31:0] Seed = 'hffff;
	parameter [31:0] MaxExp = 16;
	input wire clk_i;
	input wire rst_ni;
	input wire set_i;
	input wire clr_i;
	output wire is_zero_o;
	localparam WIDTH = 16;
	wire [15:0] lfsr_d;
	reg [15:0] lfsr_q;
	wire [15:0] cnt_d;
	reg [15:0] cnt_q;
	wire [15:0] mask_d;
	reg [15:0] mask_q;
	wire lfsr;
	assign lfsr = ((lfsr_q[0] ^ lfsr_q[2]) ^ lfsr_q[3]) ^ lfsr_q[5];
	assign lfsr_d = (set_i ? {lfsr, lfsr_q[15:1]} : lfsr_q);
	assign mask_d = (clr_i ? {16 {1'sb0}} : (set_i ? {{WIDTH - MaxExp {1'b0}}, mask_q[MaxExp - 2:0], 1'b1} : mask_q));
	assign cnt_d = (clr_i ? {16 {1'sb0}} : (set_i ? mask_q & lfsr_q : (!is_zero_o ? cnt_q - 1'b1 : {16 {1'sb0}})));
	assign is_zero_o = cnt_q == {16 {1'sb0}};
	function automatic [15:0] sv2v_cast_16;
		input reg [15:0] inp;
		sv2v_cast_16 = inp;
	endfunction
	always @(posedge clk_i or negedge rst_ni) begin : p_regs
		if (!rst_ni) begin
			lfsr_q <= sv2v_cast_16(Seed);
			mask_q <= 1'sb0;
			cnt_q <= 1'sb0;
		end
		else begin
			lfsr_q <= lfsr_d;
			mask_q <= mask_d;
			cnt_q <= cnt_d;
		end
	end
endmodule
