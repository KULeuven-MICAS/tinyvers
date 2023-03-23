module udma_i2c_control (
	clk_i,
	rstn_i,
	ext_events_i,
	data_tx_i,
	data_tx_valid_i,
	data_tx_ready_o,
	data_rx_o,
	data_rx_valid_o,
	data_rx_ready_i,
	sw_rst_i,
	err_o,
	scl_i,
	scl_o,
	scl_oe,
	sda_i,
	sda_o,
	sda_oe
);
	input wire clk_i;
	input wire rstn_i;
	input wire [3:0] ext_events_i;
	input wire [7:0] data_tx_i;
	input wire data_tx_valid_i;
	output wire data_tx_ready_o;
	output wire [7:0] data_rx_o;
	output wire data_rx_valid_o;
	input wire data_rx_ready_i;
	input wire sw_rst_i;
	output wire err_o;
	input wire scl_i;
	output wire scl_o;
	output wire scl_oe;
	input wire sda_i;
	output wire sda_o;
	output wire sda_oe;
	reg [3:0] CS;
	reg [3:0] NS;
	wire s_cmd_start;
	wire s_cmd_stop;
	wire s_cmd_rd_ack;
	wire s_cmd_rd_nack;
	wire s_cmd_wr;
	wire s_cmd_wait;
	wire s_cmd_wait_ev;
	wire s_cmd_rpt;
	wire s_cmd_cfg;
	reg s_en_decode;
	reg s_sample_div;
	reg s_sample_rpt;
	reg s_sample_ev;
	reg [15:0] s_div_num;
	reg [15:0] r_div_num;
	reg [6:0] s_rpt_num;
	reg [6:0] r_rpt_num;
	reg [7:0] s_data;
	reg [7:0] r_data;
	reg [7:0] s_bits;
	reg [7:0] r_bits;
	wire s_core_txd;
	wire s_core_rxd;
	reg r_sample_wd;
	reg s_sample_wd;
	reg r_rd_ack;
	reg s_rd_ack;
	reg [2:0] s_bus_if_cmd;
	reg s_bus_if_cmd_valid;
	reg s_en_bus_ctrl;
	wire s_scl_oen;
	wire s_sda_oen;
	wire s_cmd_done;
	wire s_busy;
	wire s_busy_rise;
	reg r_busy;
	wire s_al;
	wire s_al_rise;
	reg r_al;
	wire s_do_rst;
	reg s_data_tx_ready;
	reg s_data_rx_valid;
	wire [1:0] s_ev_sel;
	reg [1:0] r_ev_sel;
	reg s_event;
	assign s_busy_rise = ~r_busy & s_busy;
	assign s_al_rise = ~r_al & s_al;
	assign err_o = s_busy_rise | s_al_rise;
	assign s_do_rst = sw_rst_i;
	assign s_cmd_start = (s_en_decode ? data_tx_i[7:4] == 4'h0 : 1'b0);
	assign s_cmd_stop = (s_en_decode ? data_tx_i[7:4] == 4'h2 : 1'b0);
	assign s_cmd_rd_ack = (s_en_decode ? data_tx_i[7:4] == 4'h4 : 1'b0);
	assign s_cmd_rd_nack = (s_en_decode ? data_tx_i[7:4] == 4'h6 : 1'b0);
	assign s_cmd_wr = (s_en_decode ? data_tx_i[7:4] == 4'h8 : 1'b0);
	assign s_cmd_wait = (s_en_decode ? data_tx_i[7:4] == 4'ha : 1'b0);
	assign s_cmd_wait_ev = (s_en_decode ? data_tx_i[7:4] == 4'h1 : 1'b0);
	assign s_cmd_rpt = (s_en_decode ? data_tx_i[7:4] == 4'hc : 1'b0);
	assign s_cmd_cfg = (s_en_decode ? data_tx_i[7:4] == 4'he : 1'b0);
	assign s_ev_sel = data_tx_i[1:0];
	assign s_core_txd = (CS == 4'd3 ? r_rd_ack : s_data[7]);
	assign data_rx_o = r_data;
	assign data_rx_valid_o = (s_do_rst ? 1'b1 : s_data_rx_valid);
	assign data_tx_ready_o = (s_do_rst ? 1'b1 : s_data_tx_ready);
	assign scl_oe = ~s_scl_oen;
	assign sda_oe = ~s_sda_oen;
	always @(*) begin : proc_s_event
		s_event = 1'b0;
		begin : sv2v_autoblock_1
			reg signed [31:0] i;
			for (i = 0; i < 4; i = i + 1)
				if (r_ev_sel == i)
					s_event = ext_events_i[i];
		end
	end
	udma_i2c_bus_ctrl bus_controller(
		.clk_i(clk_i),
		.rstn_i(rstn_i),
		.sw_rst_i(s_do_rst),
		.ena_i(s_en_bus_ctrl),
		.clk_cnt_i(r_div_num),
		.cmd_i(s_bus_if_cmd),
		.cmd_valid_i(s_bus_if_cmd_valid),
		.cmd_ack_o(s_cmd_done),
		.busy_o(s_busy),
		.al_o(s_al),
		.din_i(s_core_txd),
		.dout_o(s_core_rxd),
		.scl_i(scl_i),
		.scl_o(scl_o),
		.scl_oen(s_scl_oen),
		.sda_i(sda_i),
		.sda_o(sda_o),
		.sda_oen(s_sda_oen)
	);
	always @(*) begin
		NS = CS;
		s_data_tx_ready = 1'b0;
		s_data_rx_valid = 1'b0;
		s_bus_if_cmd = 3'b000;
		s_bus_if_cmd_valid = 1'b0;
		s_rd_ack = r_rd_ack;
		s_sample_wd = r_sample_wd;
		s_rpt_num = r_rpt_num;
		s_bits = r_bits;
		s_data = r_data;
		s_en_bus_ctrl = 1'b1;
		s_en_decode = 1'b0;
		s_div_num = r_div_num;
		s_sample_div = 1'b0;
		s_sample_rpt = 1'b0;
		s_sample_ev = 1'b0;
		case (CS)
			4'd0: begin
				s_en_bus_ctrl = 1'b0;
				s_data_tx_ready = 1'b1;
				s_en_bus_ctrl = 1'b1;
				if (data_tx_valid_i) begin
					s_en_decode = 1'b1;
					if (s_cmd_start) begin
						s_bus_if_cmd = 3'b001;
						s_bus_if_cmd_valid = 1'b1;
						NS = 4'd2;
					end
					else if (s_cmd_stop) begin
						s_bus_if_cmd = 3'b010;
						s_bus_if_cmd_valid = 1'b1;
						NS = 4'd2;
					end
					else if (s_cmd_wait)
						NS = 4'd8;
					else if (s_cmd_wait_ev) begin
						s_sample_ev = 1'b1;
						NS = 4'd1;
					end
					else if (s_cmd_rd_ack) begin
						s_bus_if_cmd = 3'b100;
						s_bus_if_cmd_valid = 1'b1;
						s_rd_ack = 1'b0;
						s_bits = 8'h08;
						NS = 4'd3;
					end
					else if (s_cmd_rd_nack) begin
						s_bus_if_cmd = 3'b100;
						s_bus_if_cmd_valid = 1'b1;
						s_rd_ack = 1'b1;
						s_bits = 8'h08;
						NS = 4'd3;
					end
					else if (s_cmd_wr)
						NS = 4'd7;
					else if (s_cmd_rpt)
						NS = 4'd10;
					else if (s_cmd_cfg)
						NS = 4'd11;
				end
			end
			4'd2:
				if (s_cmd_done && (r_bits == 'h0))
					NS = 4'd0;
				else if (s_cmd_done && (r_bits != 'h0)) begin
					s_bus_if_cmd = 3'b101;
					s_bus_if_cmd_valid = 1'b1;
					s_bits = r_bits - 1;
					NS = 4'd2;
				end
			4'd1:
				if (s_event && (r_bits == 'h0))
					NS = 4'd0;
				else if (s_event && (r_bits != 'h0)) begin
					s_bits = r_bits - 1;
					NS = 4'd1;
				end
			4'd3:
				if (s_cmd_done && (r_bits == 'h1)) begin
					s_bus_if_cmd = 3'b011;
					s_bus_if_cmd_valid = 1'b1;
					s_bits = r_bits - 1;
					s_data = {r_data[6:0], s_core_rxd};
					NS = 4'd3;
				end
				else if (s_cmd_done && (r_bits != 'h0)) begin
					s_bus_if_cmd = 3'b100;
					s_bus_if_cmd_valid = 1'b1;
					s_bits = r_bits - 1;
					s_data = {r_data[6:0], s_core_rxd};
					NS = 4'd3;
				end
				else if (s_cmd_done && (r_bits == 'h0))
					NS = 4'd5;
			4'd5: begin
				s_data_rx_valid = 1'b1;
				if (data_rx_ready_i)
					if (r_rpt_num == 'h0)
						NS = 4'd0;
					else begin
						s_bus_if_cmd = 3'b100;
						s_bus_if_cmd_valid = 1'b1;
						s_bits = 'h8;
						s_sample_rpt = 1'b1;
						s_rpt_num = r_rpt_num - 1;
						NS = 4'd3;
					end
			end
			4'd7: begin
				s_data_tx_ready = 1'b1;
				if (data_tx_valid_i) begin
					s_bus_if_cmd = 3'b011;
					s_bus_if_cmd_valid = 1'b1;
					s_data = data_tx_i;
					s_bits = 8'h08;
					NS = 4'd4;
				end
			end
			4'd6: begin
				s_data_tx_ready = 1'b1;
				NS = 4'd0;
			end
			4'd10: begin
				s_data_tx_ready = 1'b1;
				if (data_tx_valid_i) begin
					s_sample_rpt = 1'b1;
					if (data_tx_i == 'h0) begin
						s_rpt_num = 'h0;
						NS = 4'd6;
					end
					else begin
						s_rpt_num = data_tx_i - 1;
						NS = 4'd0;
					end
				end
			end
			4'd11: begin
				s_data_tx_ready = 1'b1;
				if (data_tx_valid_i) begin
					s_sample_div = 1'b1;
					s_div_num[15:8] = data_tx_i;
					NS = 4'd12;
				end
			end
			4'd12: begin
				s_data_tx_ready = 1'b1;
				if (data_tx_valid_i) begin
					s_sample_div = 1'b1;
					s_div_num[7:0] = data_tx_i;
					NS = 4'd0;
				end
			end
			4'd8: begin
				s_data_tx_ready = 1'b1;
				if (data_tx_valid_i) begin
					s_bus_if_cmd = 3'b101;
					s_bus_if_cmd_valid = 1'b1;
					s_bits = data_tx_i;
					NS = 4'd2;
				end
			end
			4'd4:
				if (s_cmd_done && (r_bits == 'h1)) begin
					s_bus_if_cmd = 3'b100;
					s_bus_if_cmd_valid = 1'b1;
					s_data = {r_data[6:0], 1'b0};
					s_bits = r_bits - 1;
					NS = 4'd4;
				end
				else if (s_cmd_done && (r_bits != 'h0)) begin
					s_bus_if_cmd = 3'b011;
					s_bus_if_cmd_valid = 1'b1;
					s_data = {r_data[6:0], 1'b0};
					s_bits = r_bits - 1;
					NS = 4'd4;
				end
				else if ((s_cmd_done && (r_bits == 'h0)) && (r_rpt_num != 'h0)) begin
					s_bits = 'h8;
					s_sample_rpt = 1'b1;
					s_rpt_num = r_rpt_num - 1;
					NS = 4'd7;
				end
				else if ((s_cmd_done && (r_bits == 'h0)) && (r_rpt_num == 'h0))
					NS = 4'd0;
			default: begin
				NS = 4'd0;
				s_en_bus_ctrl = 1'b0;
				s_data_tx_ready = 1'b0;
				s_bus_if_cmd = 3'b000;
				s_bus_if_cmd_valid = 1'b0;
				s_rd_ack = r_rd_ack;
				s_sample_wd = r_sample_wd;
				s_rpt_num = r_rpt_num;
				s_bits = r_bits;
				s_data = r_data;
			end
		endcase
	end
	always @(posedge clk_i or negedge rstn_i)
		if (!rstn_i) begin
			CS <= 4'd0;
			r_sample_wd <= 1'b0;
			r_rpt_num <= 'h0;
			r_data <= 'h0;
			r_bits <= 'h0;
			r_rd_ack <= 1'b0;
			r_div_num <= 16'h0100;
			r_busy <= 1'b0;
			r_al <= 1'b0;
			r_ev_sel <= 'h0;
		end
		else if (s_do_rst) begin
			CS <= 4'd0;
			r_sample_wd <= 1'b0;
			r_rpt_num <= 'h0;
			r_data <= 'h0;
			r_bits <= 'h0;
			r_rd_ack <= 1'b0;
			r_div_num <= 16'h0100;
			r_busy <= 1'b0;
			r_al <= 1'b0;
			r_ev_sel <= 'h0;
		end
		else begin
			CS <= NS;
			r_sample_wd <= s_sample_wd;
			r_data <= s_data;
			r_bits <= s_bits;
			r_rd_ack <= s_rd_ack;
			r_busy <= s_busy;
			r_al <= s_al;
			if (s_sample_rpt)
				r_rpt_num <= s_rpt_num;
			if (s_sample_div)
				r_div_num <= s_div_num;
			if (s_sample_ev)
				r_ev_sel <= s_ev_sel;
		end
endmodule
