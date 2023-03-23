module jtag_axi_wrap (
	update,
	axireg_i,
	axireg_o,
	clk_i,
	rst_ni,
	jtag_master
);
	input wire update;
	input wire [95:0] axireg_i;
	output reg [95:0] axireg_o;
	input wire clk_i;
	input wire rst_ni;
	input AXI_BUS.Master jtag_master;
	reg [2:0] state_dn;
	reg [2:0] state_dp;
	reg [63:0] axireg_n;
	reg [63:0] axireg_p;
	wire axi_request;
	wire loadstore;
	assign axi_request = axireg_i[0];
	assign loadstore = axireg_i[1];
	always @(*) begin
		state_dn = state_dp;
		axireg_n = axireg_p;
		axireg_o = {32'b00000000000000000000000000000000, axireg_p};
		jtag_master.aw_id = 1'sb0;
		jtag_master.aw_addr = 1'sb0;
		jtag_master.aw_lock = 1'sb0;
		jtag_master.aw_cache = 1'sb0;
		jtag_master.aw_prot = 1'sb0;
		jtag_master.aw_region = 1'sb0;
		jtag_master.aw_user = 1'sb0;
		jtag_master.aw_qos = 1'sb0;
		jtag_master.aw_valid = 1'sb0;
		jtag_master.ar_id = 1'sb0;
		jtag_master.ar_addr = 1'sb0;
		jtag_master.ar_lock = 1'sb0;
		jtag_master.ar_cache = 1'sb0;
		jtag_master.ar_prot = 1'sb0;
		jtag_master.ar_region = 1'sb0;
		jtag_master.ar_user = 1'sb0;
		jtag_master.ar_qos = 1'sb0;
		jtag_master.ar_valid = 1'sb0;
		jtag_master.w_data = 1'sb0;
		jtag_master.w_strb = 1'sb0;
		jtag_master.w_last = 1'sb0;
		jtag_master.w_user = 1'sb0;
		jtag_master.w_valid = 1'sb0;
		jtag_master.aw_burst = 1'b1;
		jtag_master.ar_burst = 1'b1;
		jtag_master.aw_size = 3'b011;
		jtag_master.ar_size = 3'b011;
		jtag_master.aw_len = 4'b0000;
		jtag_master.ar_len = 4'b0000;
		jtag_master.b_ready = 1'b1;
		jtag_master.r_ready = 1'sb0;
		case (state_dp)
			3'd0:
				if (update)
					state_dn = 3'd1;
			3'd1:
				if (axi_request) begin
					if (loadstore) begin
						jtag_master.aw_addr = {axireg_i[31:3], 3'b000};
						jtag_master.aw_valid = 1'b1;
						if (jtag_master.aw_ready)
							state_dn = 3'd3;
						else
							state_dn = 3'd1;
					end
					else begin
						jtag_master.ar_addr = {axireg_i[31:3], 3'b000};
						jtag_master.ar_valid = 1'b1;
						if (jtag_master.ar_ready)
							state_dn = 3'd2;
						else
							state_dn = 3'd1;
					end
				end
				else
					state_dn = 3'd0;
			3'd2: begin
				jtag_master.r_ready = 1'b1;
				if (jtag_master.r_valid & jtag_master.r_last) begin
					axireg_n = jtag_master.r_data;
					state_dn = 3'd0;
				end
				else
					state_dn = 3'd2;
			end
			3'd3: begin
				jtag_master.w_data = axireg_i[95:32];
				jtag_master.w_valid = 1'b1;
				jtag_master.w_last = 1'b1;
				jtag_master.w_strb = 8'hff;
				if (jtag_master.w_ready)
					state_dn = 3'd4;
				else
					state_dn = 3'd3;
			end
			3'd4:
				if (jtag_master.b_valid)
					state_dn = 3'd0;
				else
					state_dn = 3'd4;
		endcase
	end
	always @(posedge clk_i or negedge rst_ni)
		if (~rst_ni) begin
			state_dp <= 3'd0;
			axireg_p <= 64'b0000000000000000000000000000000000000000000000000000000000000000;
		end
		else begin
			state_dp <= state_dn;
			axireg_p <= axireg_n;
		end
endmodule
