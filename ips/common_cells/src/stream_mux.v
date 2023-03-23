module stream_mux (
	inp_data_i,
	inp_valid_i,
	inp_ready_o,
	inp_sel_i,
	oup_data_o,
	oup_valid_o,
	oup_ready_i
);
	parameter integer N_INP = 0;
	localparam integer LOG_N_INP = $clog2(N_INP);
	input wire [N_INP - 1:0] inp_data_i;
	input wire [N_INP - 1:0] inp_valid_i;
	output reg [N_INP - 1:0] inp_ready_o;
	input wire [LOG_N_INP - 1:0] inp_sel_i;
	output wire oup_data_o;
	output wire oup_valid_o;
	input wire oup_ready_i;
	always @(*) begin
		inp_ready_o = 1'sb0;
		inp_ready_o[inp_sel_i] = oup_ready_i;
	end
	assign oup_data_o = inp_data_i[inp_sel_i];
	assign oup_valid_o = inp_valid_i[inp_sel_i];
	initial begin : p_assertions
		
	end
endmodule
