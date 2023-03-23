module udma_i2c_bus_ctrl (
	clk_i,
	rstn_i,
	ena_i,
	sw_rst_i,
	clk_cnt_i,
	cmd_i,
	cmd_valid_i,
	cmd_ack_o,
	busy_o,
	al_o,
	din_i,
	dout_o,
	scl_i,
	scl_o,
	scl_oen,
	sda_i,
	sda_o,
	sda_oen
);
	input wire clk_i;
	input wire rstn_i;
	input wire ena_i;
	input wire sw_rst_i;
	input wire [15:0] clk_cnt_i;
	input wire [2:0] cmd_i;
	input wire cmd_valid_i;
	output reg cmd_ack_o;
	output reg busy_o;
	output reg al_o;
	input wire din_i;
	output reg dout_o;
	input wire scl_i;
	output wire scl_o;
	output reg scl_oen;
	input wire sda_i;
	output wire sda_o;
	output reg sda_oen;
	reg [1:0] r_sync_scl;
	reg [1:0] r_sync_sda;
	reg [2:0] r_filter_scl;
	reg [2:0] r_filter_sda;
	reg sSCL;
	reg sSDA;
	reg dSCL;
	reg dSDA;
	reg dscl_oen;
	reg sda_chk;
	reg clk_en;
	reg slave_wait;
	reg [15:0] cnt;
	reg [13:0] r_filter_cnt;
	wire scl_sync;
	reg r_start;
	reg r_stop;
	reg r_cmd_stop;
	reg [4:0] CS;
	assign scl_o = 1'b0;
	assign sda_o = 1'b0;
	always @(posedge clk_i or negedge rstn_i)
		if (rstn_i == 1'b0)
			dscl_oen <= 1'b1;
		else
			dscl_oen <= scl_oen;
	always @(posedge clk_i or negedge rstn_i)
		if (!rstn_i)
			slave_wait <= 1'b0;
		else if (sw_rst_i)
			slave_wait <= 1'b0;
		else
			slave_wait <= ((scl_oen & ~dscl_oen) & ~sSCL) | (slave_wait & ~sSCL);
	assign scl_sync = (dSCL & ~sSCL) & scl_oen;
	always @(posedge clk_i or negedge rstn_i)
		if (~rstn_i) begin
			cnt <= 16'h0000;
			clk_en <= 1'b1;
		end
		else if (sw_rst_i) begin
			cnt <= 16'h0000;
			clk_en <= 1'b1;
		end
		else if ((~|cnt || !ena_i) || scl_sync) begin
			cnt <= clk_cnt_i;
			clk_en <= 1'b1;
		end
		else if (slave_wait) begin
			cnt <= cnt;
			clk_en <= 1'b0;
		end
		else begin
			cnt <= cnt - 16'h0001;
			clk_en <= 1'b0;
		end
	always @(posedge clk_i or negedge rstn_i)
		if (!rstn_i) begin
			r_sync_scl <= 2'b00;
			r_sync_sda <= 2'b00;
		end
		else if (sw_rst_i) begin
			r_sync_scl <= 2'b00;
			r_sync_sda <= 2'b00;
		end
		else begin
			r_sync_scl <= {r_sync_scl[0], scl_i};
			r_sync_sda <= {r_sync_sda[0], sda_i};
		end
	function automatic [13:0] sv2v_cast_14;
		input reg [13:0] inp;
		sv2v_cast_14 = inp;
	endfunction
	always @(posedge clk_i or negedge rstn_i)
		if (!rstn_i)
			r_filter_cnt <= 'h0;
		else if (!ena_i || sw_rst_i)
			r_filter_cnt <= 'h0;
		else if (r_filter_cnt == 'h0)
			r_filter_cnt <= sv2v_cast_14(clk_cnt_i >> 2);
		else
			r_filter_cnt <= r_filter_cnt - 1;
	always @(posedge clk_i or negedge rstn_i)
		if (!rstn_i) begin
			r_filter_scl <= 3'b111;
			r_filter_sda <= 3'b111;
		end
		else if (sw_rst_i) begin
			r_filter_scl <= 3'b111;
			r_filter_sda <= 3'b111;
		end
		else if (r_filter_cnt == 'h0) begin
			r_filter_scl <= {r_filter_scl[1:0], r_sync_scl[1]};
			r_filter_sda <= {r_filter_sda[1:0], r_sync_sda[1]};
		end
	always @(posedge clk_i or negedge rstn_i)
		if (~rstn_i) begin
			sSCL <= 1'b1;
			sSDA <= 1'b1;
			dSCL <= 1'b1;
			dSDA <= 1'b1;
		end
		else if (sw_rst_i) begin
			sSCL <= 1'b1;
			sSDA <= 1'b1;
			dSCL <= 1'b1;
			dSDA <= 1'b1;
		end
		else begin
			sSCL <= (&r_filter_scl[2:1] | &r_filter_scl[1:0]) | (r_filter_scl[2] & r_filter_scl[0]);
			sSDA <= (&r_filter_sda[2:1] | &r_filter_sda[1:0]) | (r_filter_sda[2] & r_filter_sda[0]);
			dSCL <= sSCL;
			dSDA <= sSDA;
		end
	always @(posedge clk_i or negedge rstn_i)
		if (~rstn_i) begin
			r_start <= 1'b0;
			r_stop <= 1'b0;
		end
		else if (sw_rst_i) begin
			r_start <= 1'b0;
			r_stop <= 1'b0;
		end
		else begin
			r_start <= (~sSDA & dSDA) & sSCL;
			r_stop <= (sSDA & ~dSDA) & sSCL;
		end
	always @(posedge clk_i or negedge rstn_i)
		if (!rstn_i)
			busy_o <= 1'b0;
		else if (sw_rst_i)
			busy_o <= 1'b0;
		else
			busy_o <= (r_start | busy_o) & ~r_stop;
	always @(posedge clk_i or negedge rstn_i)
		if (~rstn_i)
			r_cmd_stop <= 1'b0;
		else if (sw_rst_i)
			r_cmd_stop <= 1'b0;
		else if (cmd_valid_i)
			r_cmd_stop <= cmd_i == 3'b010;
	always @(posedge clk_i or negedge rstn_i)
		if (~rstn_i)
			al_o <= 1'b0;
		else if (sw_rst_i)
			al_o <= 1'b0;
		else
			al_o <= ((sda_chk & ~sSDA) & sda_oen) | (((CS != 5'd0) & r_stop) & ~r_cmd_stop);
	always @(posedge clk_i or negedge rstn_i)
		if (rstn_i == 1'b0)
			dout_o <= 1'b1;
		else if (sSCL & ~dSCL)
			dout_o <= sSDA;
	always @(posedge clk_i or negedge rstn_i)
		if (!rstn_i) begin
			CS <= 5'd0;
			cmd_ack_o <= 1'b0;
			scl_oen <= 1'b1;
			sda_oen <= 1'b1;
			sda_chk <= 1'b0;
		end
		else if (al_o || sw_rst_i) begin
			CS <= 5'd0;
			cmd_ack_o <= 1'b0;
			scl_oen <= 1'b1;
			sda_oen <= 1'b1;
			sda_chk <= 1'b0;
		end
		else
			case (CS)
				5'd0: begin
					if (cmd_valid_i)
						case (cmd_i)
							3'b001: CS <= 5'd1;
							3'b010: CS <= 5'd5;
							3'b011: CS <= 5'd17;
							3'b100: CS <= 5'd9;
							3'b101: CS <= 5'd13;
							default: CS <= 5'd0;
						endcase
					scl_oen <= scl_oen;
					sda_oen <= sda_oen;
					sda_chk <= 1'b0;
					cmd_ack_o <= 1'b0;
				end
				5'd13: begin
					if (clk_en)
						CS <= 5'd14;
					scl_oen <= 1'b1;
					sda_oen <= 1'b1;
					sda_chk <= 1'b0;
					cmd_ack_o <= 1'b0;
				end
				5'd14: begin
					if (clk_en)
						CS <= 5'd15;
					scl_oen <= 1'b1;
					sda_oen <= 1'b1;
					sda_chk <= 1'b0;
					cmd_ack_o <= 1'b0;
				end
				5'd15: begin
					if (clk_en)
						CS <= 5'd16;
					scl_oen <= 1'b1;
					sda_oen <= 1'b1;
					sda_chk <= 1'b0;
					cmd_ack_o <= 1'b0;
				end
				5'd16: begin
					if (clk_en) begin
						CS <= 5'd0;
						cmd_ack_o <= 1'b1;
					end
					else
						cmd_ack_o <= 1'b0;
					scl_oen <= 1'b1;
					sda_oen <= 1'b1;
					sda_chk <= 1'b0;
				end
				5'd1: begin
					if (clk_en)
						CS <= 5'd2;
					scl_oen <= scl_oen;
					sda_oen <= 1'b1;
					sda_chk <= 1'b0;
					cmd_ack_o <= 1'b0;
				end
				5'd2: begin
					if (clk_en)
						CS <= 5'd3;
					scl_oen <= 1'b1;
					sda_oen <= 1'b1;
					sda_chk <= 1'b0;
					cmd_ack_o <= 1'b0;
				end
				5'd3: begin
					if (clk_en)
						CS <= 5'd4;
					scl_oen <= 1'b1;
					sda_oen <= 1'b0;
					sda_chk <= 1'b0;
					cmd_ack_o <= 1'b0;
				end
				5'd4: begin
					if (clk_en) begin
						CS <= 5'd0;
						cmd_ack_o <= 1'b1;
					end
					else
						cmd_ack_o <= 1'b0;
					scl_oen <= 1'b0;
					sda_oen <= 1'b0;
					sda_chk <= 1'b0;
				end
				5'd5: begin
					if (clk_en)
						CS <= 5'd6;
					scl_oen <= 1'b0;
					sda_oen <= 1'b0;
					sda_chk <= 1'b0;
					cmd_ack_o <= 1'b0;
				end
				5'd6: begin
					if (clk_en)
						CS <= 5'd7;
					scl_oen <= 1'b1;
					sda_oen <= 1'b0;
					sda_chk <= 1'b0;
					cmd_ack_o <= 1'b0;
				end
				5'd7: begin
					if (clk_en)
						CS <= 5'd8;
					scl_oen <= 1'b1;
					sda_oen <= 1'b0;
					sda_chk <= 1'b0;
					cmd_ack_o <= 1'b0;
				end
				5'd8: begin
					if (clk_en) begin
						CS <= 5'd0;
						cmd_ack_o <= 1'b1;
					end
					else
						cmd_ack_o <= 1'b0;
					scl_oen <= 1'b1;
					sda_oen <= 1'b1;
					sda_chk <= 1'b0;
				end
				5'd9: begin
					if (clk_en)
						CS <= 5'd10;
					scl_oen <= 1'b0;
					sda_oen <= 1'b1;
					sda_chk <= 1'b0;
					cmd_ack_o <= 1'b0;
				end
				5'd10: begin
					if (clk_en)
						CS <= 5'd11;
					scl_oen <= 1'b1;
					sda_oen <= 1'b1;
					sda_chk <= 1'b0;
					cmd_ack_o <= 1'b0;
				end
				5'd11: begin
					if (clk_en)
						CS <= 5'd12;
					scl_oen <= 1'b1;
					sda_oen <= 1'b1;
					sda_chk <= 1'b0;
					cmd_ack_o <= 1'b0;
				end
				5'd12: begin
					if (clk_en) begin
						CS <= 5'd0;
						cmd_ack_o <= 1'b1;
					end
					else
						cmd_ack_o <= 1'b0;
					scl_oen <= 1'b0;
					sda_oen <= 1'b1;
					sda_chk <= 1'b0;
				end
				5'd17: begin
					if (clk_en)
						CS <= 5'd18;
					scl_oen <= 1'b0;
					sda_oen <= din_i;
					sda_chk <= 1'b0;
					cmd_ack_o <= 1'b0;
				end
				5'd18: begin
					if (clk_en)
						CS <= 5'd19;
					scl_oen <= 1'b1;
					sda_oen <= din_i;
					sda_chk <= 1'b0;
					cmd_ack_o <= 1'b0;
				end
				5'd19: begin
					if (clk_en)
						CS <= 5'd20;
					scl_oen <= 1'b1;
					sda_oen <= din_i;
					sda_chk <= 1'b1;
					cmd_ack_o <= 1'b0;
				end
				5'd20: begin
					if (clk_en) begin
						CS <= 5'd0;
						cmd_ack_o <= 1'b1;
					end
					else
						cmd_ack_o <= 1'b0;
					scl_oen <= 1'b0;
					sda_oen <= din_i;
					sda_chk <= 1'b0;
				end
				default: begin
					CS <= 5'd0;
					cmd_ack_o <= 1'b0;
					scl_oen <= 1'b1;
					sda_oen <= 1'b1;
					sda_chk <= 1'b0;
				end
			endcase
endmodule
