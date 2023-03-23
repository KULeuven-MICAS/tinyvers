module out_filter (
	clk_i,
	rstn_i,
	ctrl_active_i,
	ctrl_update_i,
	cfg_mode_i,
	signal_i,
	signal_o
);
	input wire clk_i;
	input wire rstn_i;
	input wire ctrl_active_i;
	input wire ctrl_update_i;
	input wire [1:0] cfg_mode_i;
	input wire signal_i;
	output reg signal_o;
	wire s_rise;
	wire s_fall;
	wire r_active;
	reg r_oldval;
	reg [1:0] r_mode;
	assign s_rise = ~r_oldval & signal_i;
	assign s_fall = r_oldval & ~signal_i;
	always @(posedge clk_i or negedge rstn_i) begin : proc_r_mode
		if (~rstn_i)
			r_mode <= 0;
		else if (ctrl_update_i)
			r_mode <= cfg_mode_i;
	end
	always @(*) begin : proc_signal_o
		case (r_mode)
			2'b00: signal_o = signal_i;
			2'b01: signal_o = s_rise;
			2'b10: signal_o = s_fall;
			2'b11: signal_o = s_rise | s_fall;
		endcase
	end
	always @(posedge clk_i or negedge rstn_i) begin : proc_r_oldval
		if (~rstn_i)
			r_oldval <= 0;
		else if (ctrl_active_i)
			r_oldval <= signal_i;
	end
endmodule
