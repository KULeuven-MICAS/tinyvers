module lut_4x4 (
	clk_i,
	rstn_i,
	cfg_en_i,
	cfg_update_i,
	cfg_lut_i,
	signal_i,
	signal_o
);
	input wire clk_i;
	input wire rstn_i;
	input wire cfg_en_i;
	input wire cfg_update_i;
	input wire [15:0] cfg_lut_i;
	input wire [3:0] signal_i;
	output reg signal_o;
	reg r_active;
	reg [15:0] r_lut;
	always @(posedge clk_i or negedge rstn_i) begin : proc_r_lut
		if (~rstn_i)
			r_lut <= 0;
		else if ((cfg_en_i && !r_active) || cfg_update_i)
			r_lut <= cfg_lut_i;
	end
	always @(posedge clk_i or negedge rstn_i) begin : proc_r_active
		if (~rstn_i)
			r_active <= 0;
		else if (cfg_en_i && !r_active)
			r_active <= 1'b1;
		else if (!cfg_en_i && r_active)
			r_active <= 1'b0;
	end
	always @(*) begin : proc_signal_o
		signal_o = 1'b0;
		begin : sv2v_autoblock_1
			reg signed [31:0] i;
			for (i = 0; i < 16; i = i + 1)
				if (i == signal_i)
					signal_o = r_lut[i];
		end
	end
endmodule
