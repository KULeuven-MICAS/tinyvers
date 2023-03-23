module sdio_txrx_cmd (
	clk_i,
	rstn_i,
	clr_stat_i,
	cmd_start_i,
	cmd_op_i,
	cmd_arg_i,
	cmd_rsp_type_i,
	rsp_data_o,
	busy_i,
	start_write_o,
	start_read_o,
	eot_o,
	status_o,
	sdclk_en_o,
	sdcmd_i,
	sdcmd_o,
	sdcmd_oen_o
);
	input wire clk_i;
	input wire rstn_i;
	input wire clr_stat_i;
	input wire cmd_start_i;
	input wire [5:0] cmd_op_i;
	input wire [31:0] cmd_arg_i;
	input wire [2:0] cmd_rsp_type_i;
	output wire [127:0] rsp_data_o;
	input wire busy_i;
	output wire start_write_o;
	output wire start_read_o;
	output wire eot_o;
	output wire [5:0] status_o;
	output wire sdclk_en_o;
	input wire sdcmd_i;
	output wire sdcmd_o;
	output wire sdcmd_oen_o;
	localparam STATUS_RSP_TIMEOUT = 6'b000001;
	localparam STATUS_RSP_WRONG_DIR = 6'b000010;
	localparam STATUS_RSP_BUSY_TIMEOUT = 6'b000100;
	localparam RSP_TYPE_NULL = 3'b000;
	localparam RSP_TYPE_48_CRC = 3'b001;
	localparam RSP_TYPE_48_NOCRC = 3'b010;
	localparam RSP_TYPE_136 = 3'b011;
	localparam RSP_TYPE_48_BSY = 3'b100;
	reg [3:0] s_state;
	reg [3:0] r_state;
	wire [6:0] s_crc;
	wire s_crc_in;
	wire s_crc_out;
	reg s_crc_en;
	reg s_crc_clr;
	reg s_crc_shift;
	reg s_crc_intx;
	reg s_clk_en;
	reg [37:0] r_cmd;
	reg [135:0] r_rsp;
	reg s_rsp_en;
	reg [7:0] s_rsp_len;
	reg s_rsp_crc;
	reg s_rsp_bsy;
	reg s_eot;
	reg s_sdcmd;
	reg s_sdcmd_oen;
	reg r_sdcmd;
	reg r_sdcmd_oen;
	reg s_shift_cmd;
	reg s_shift_resp;
	reg s_start_write;
	reg s_start_read;
	reg s_cnt_start;
	wire s_cnt_done;
	reg [7:0] s_cnt_target;
	reg [7:0] r_cnt;
	reg r_cnt_running;
	reg [5:0] s_status;
	reg [5:0] r_status;
	reg s_status_sample;
	assign s_crc_in = (s_crc_intx ? sdcmd_i : s_sdcmd);
	assign sdcmd_o = r_sdcmd;
	assign sdcmd_oen_o = r_sdcmd_oen;
	assign eot_o = s_eot;
	assign sdclk_en_o = s_clk_en;
	assign rsp_data_o = r_rsp[127:0];
	assign start_write_o = s_start_write;
	assign start_read_o = s_start_read;
	assign status_o = r_status;
	sdio_crc7 i_cmd_crc(
		.clk_i(clk_i),
		.rstn_i(rstn_i),
		.crc7_o(s_crc),
		.crc7_serial_o(s_crc_out),
		.data_i(s_crc_in),
		.shift_i(s_crc_shift),
		.clr_i(s_crc_clr),
		.sample_i(s_crc_en)
	);
	always @(*) begin
		s_rsp_en = 1'b0;
		s_rsp_crc = 1'b0;
		s_rsp_len = 8'hff;
		s_rsp_bsy = 1'b0;
		case (cmd_rsp_type_i)
			RSP_TYPE_48_CRC: begin
				s_rsp_en = 1'b1;
				s_rsp_crc = 1'b1;
				s_rsp_len = 8'd37;
			end
			RSP_TYPE_48_BSY: begin
				s_rsp_en = 1'b1;
				s_rsp_crc = 1'b1;
				s_rsp_len = 8'd37;
				s_rsp_bsy = 1'b1;
			end
			RSP_TYPE_48_NOCRC: begin
				s_rsp_en = 1'b1;
				s_rsp_crc = 1'b0;
				s_rsp_len = 8'd37;
			end
			RSP_TYPE_136: begin
				s_rsp_en = 1'b1;
				s_rsp_crc = 1'b0;
				s_rsp_len = 8'd133;
			end
		endcase
	end
	always @(*) begin
		s_sdcmd = 1'b1;
		s_sdcmd_oen = 1'b1;
		s_state = r_state;
		s_shift_cmd = 1'b0;
		s_shift_resp = 1'b0;
		s_crc_shift = 1'b0;
		s_crc_en = 1'b0;
		s_crc_intx = 1'b0;
		s_cnt_start = 1'b0;
		s_cnt_target = 8'h00;
		s_status = 'h0;
		s_status_sample = 1'b0;
		s_eot = 1'b0;
		s_crc_clr = 1'b0;
		s_clk_en = 1'b1;
		s_start_write = 1'b0;
		s_start_read = 1'b0;
		case (r_state)
			4'd0: begin
				s_clk_en = 1'b0;
				if (cmd_start_i) begin
					s_status_sample = 1'b1;
					s_state = 4'd3;
					s_clk_en = 1'b1;
				end
			end
			4'd3: begin
				s_sdcmd = 1'b0;
				s_sdcmd_oen = 1'b0;
				s_crc_clr = 1'b1;
				s_state = 4'd5;
			end
			4'd5: begin
				s_sdcmd = 1'b1;
				s_sdcmd_oen = 1'b0;
				s_crc_en = 1'b1;
				s_cnt_start = 1'b1;
				s_cnt_target = 8'd37;
				s_state = 4'd6;
			end
			4'd6: begin
				s_sdcmd = r_cmd[37];
				s_sdcmd_oen = 1'b0;
				s_shift_cmd = 1'b1;
				s_crc_en = 1'b1;
				if (s_cnt_done) begin
					s_state = 4'd7;
					s_cnt_start = 1'b1;
					s_cnt_target = 8'd6;
				end
			end
			4'd7: begin
				s_sdcmd = s_crc_out;
				s_sdcmd_oen = 1'b0;
				s_crc_shift = 1'b1;
				s_crc_en = 1'b1;
				if (s_cnt_done)
					s_state = 4'd4;
			end
			4'd4: begin
				s_sdcmd = 1'b1;
				s_sdcmd_oen = 1'b0;
				s_start_read = 1'b1;
				if (s_rsp_en) begin
					s_cnt_start = 1'b1;
					s_cnt_target = 8'd37;
					s_sdcmd_oen = 1'b1;
					s_state = 4'd8;
				end
				else begin
					s_cnt_start = 1'b1;
					s_cnt_target = 8'd7;
					s_state = 4'd1;
				end
			end
			4'd8: begin
				s_sdcmd_oen = 1'b1;
				if (!sdcmd_i)
					s_state = 4'd10;
				else if (s_cnt_done) begin
					s_status = r_status | STATUS_RSP_TIMEOUT;
					s_status_sample = 1'b1;
					s_state = 4'd0;
				end
			end
			4'd10: begin
				s_sdcmd_oen = 1'b1;
				if (!sdcmd_i) begin
					s_cnt_start = 1'b1;
					s_cnt_target = s_rsp_len;
					s_state = 4'd11;
				end
				else begin
					s_status = r_status | STATUS_RSP_WRONG_DIR;
					s_status_sample = 1'b1;
					s_state = 4'd0;
				end
			end
			4'd11: begin
				s_sdcmd_oen = 1'b1;
				s_shift_resp = 1'b1;
				s_crc_en = 1'b1;
				if (s_cnt_done)
					if (s_rsp_crc) begin
						s_state = 4'd12;
						s_cnt_start = 1'b1;
						s_cnt_target = 8'd7;
					end
					else if (s_rsp_bsy) begin
						s_cnt_start = 1'b1;
						s_cnt_target = 8'hff;
						s_state = 4'd2;
					end
					else begin
						s_cnt_start = 1'b1;
						s_cnt_target = 8'd7;
						s_state = 4'd1;
					end
			end
			4'd12: begin
				s_sdcmd_oen = 1'b1;
				if (s_cnt_done) begin
					s_cnt_start = 1'b1;
					s_cnt_target = 8'd7;
					s_state = 4'd1;
				end
			end
			4'd2: begin
				s_sdcmd_oen = 1'b1;
				if (!busy_i) begin
					s_cnt_start = 1'b1;
					s_cnt_target = 8'd7;
					s_state = 4'd1;
				end
				else if (s_cnt_done) begin
					s_status = r_status | STATUS_RSP_BUSY_TIMEOUT;
					s_status_sample = 1'b1;
					s_cnt_start = 1'b1;
					s_cnt_target = 8'd7;
					s_state = 4'd1;
				end
			end
			4'd1:
				if (s_cnt_done) begin
					s_eot = 1'b1;
					s_start_write = 1'b1;
					s_state = 4'd0;
				end
		endcase
	end
	assign s_cnt_done = r_cnt == 0;
	always @(posedge clk_i or negedge rstn_i) begin : proc_r_cnt
		if (~rstn_i) begin
			r_cnt <= 8'hff;
			r_cnt_running <= 0;
		end
		else if (s_cnt_start) begin
			r_cnt <= s_cnt_target;
			r_cnt_running <= 1'b1;
		end
		else if (s_cnt_done) begin
			r_cnt <= 8'hff;
			r_cnt_running <= 1'b0;
		end
		else if (r_cnt_running)
			r_cnt <= r_cnt - 1;
	end
	always @(posedge clk_i or negedge rstn_i) begin : ff_addr
		if (~rstn_i) begin
			r_state <= 4'd0;
			r_status <= 'h0;
			r_rsp <= 'h0;
			r_cmd <= 'h0;
		end
		else if (clr_stat_i) begin
			r_state <= 4'd0;
			r_status <= 'h0;
			r_rsp <= 'h0;
			r_cmd <= 'h0;
		end
		else begin
			r_state <= s_state;
			if (s_status_sample)
				r_status <= s_status;
			if (cmd_start_i)
				r_cmd <= {cmd_op_i, cmd_arg_i};
			else if (s_shift_cmd)
				r_cmd <= {r_cmd[36:0], 1'b0};
			if (s_shift_resp)
				r_rsp <= {r_rsp[134:0], sdcmd_i};
		end
	end
	always @(negedge clk_i or negedge rstn_i) begin : proc_sdcmd
		if (~rstn_i) begin
			r_sdcmd <= 1'b1;
			r_sdcmd_oen <= 1'b1;
		end
		else begin
			r_sdcmd <= s_sdcmd;
			r_sdcmd_oen <= s_sdcmd_oen;
		end
	end
endmodule
