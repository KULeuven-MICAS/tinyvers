module stream_demux (
	inp_valid_i,
	inp_ready_o,
	oup_sel_i,
	oup_valid_o,
	oup_ready_i
);
	parameter integer N_OUP = 1;
	localparam integer LOG_N_OUP = $clog2(N_OUP);
	input wire inp_valid_i;
	output wire inp_ready_o;
	input wire [LOG_N_OUP - 1:0] oup_sel_i;
	output reg [N_OUP - 1:0] oup_valid_o;
	input wire [N_OUP - 1:0] oup_ready_i;
	always @(*) begin
		oup_valid_o = 1'sb0;
		oup_valid_o[oup_sel_i] = inp_valid_i;
	end
	assign inp_ready_o = oup_ready_i[oup_sel_i];
endmodule
