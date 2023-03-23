module timer_cntrl (
	clk_i,
	rstn_i,
	cfg_start_i,
	cfg_stop_i,
	cfg_rst_i,
	cfg_update_i,
	cfg_arm_i,
	ctrl_cnt_upd_o,
	ctrl_all_upd_o,
	ctrl_active_o,
	ctrl_rst_o,
	ctrl_arm_o,
	cnt_update_i,
	status_o
);
	input wire clk_i;
	input wire rstn_i;
	input wire cfg_start_i;
	input wire cfg_stop_i;
	input wire cfg_rst_i;
	input wire cfg_update_i;
	input wire cfg_arm_i;
	output reg ctrl_cnt_upd_o;
	output reg ctrl_all_upd_o;
	output wire ctrl_active_o;
	output reg ctrl_rst_o;
	output wire ctrl_arm_o;
	input wire cnt_update_i;
	output wire [7:0] status_o;
	reg r_active;
	reg r_pending;
	assign ctrl_arm_o = cfg_arm_i;
	assign status_o = {6'h00, r_pending};
	assign ctrl_active_o = r_active;
	always @(*) begin : proc_sm
		if (cfg_start_i && !r_active) begin
			ctrl_rst_o = 1'b1;
			ctrl_cnt_upd_o = 1'b1;
			ctrl_all_upd_o = 1'b1;
		end
		else begin
			ctrl_rst_o = cfg_rst_i;
			ctrl_cnt_upd_o = cfg_update_i;
			ctrl_all_upd_o = cnt_update_i;
		end
	end
	always @(posedge clk_i or negedge rstn_i) begin : proc_r_active
		if (~rstn_i) begin
			r_active <= 0;
			r_pending <= 0;
		end
		else begin
			if (cfg_start_i)
				r_active <= 1;
			else if (cfg_stop_i)
				r_active <= 0;
			if (cnt_update_i && !cfg_update_i)
				r_pending <= 0;
			else if (cfg_update_i)
				r_pending <= 1;
		end
	end
endmodule
