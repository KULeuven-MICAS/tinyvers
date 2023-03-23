module pdm_top (
	clk_i,
	rstn_i,
	pdm_clk_o,
	cfg_pdm_ch_mode_i,
	cfg_pdm_decimation_i,
	cfg_pdm_shift_i,
	cfg_pdm_en_i,
	pdm_ch0_i,
	pdm_ch1_i,
	pcm_data_o,
	pcm_data_valid_o,
	pcm_data_ready_i
);
	input wire clk_i;
	input wire rstn_i;
	output wire pdm_clk_o;
	input wire [1:0] cfg_pdm_ch_mode_i;
	input wire [9:0] cfg_pdm_decimation_i;
	input wire [2:0] cfg_pdm_shift_i;
	input wire cfg_pdm_en_i;
	input wire pdm_ch0_i;
	input wire pdm_ch1_i;
	output wire [15:0] pcm_data_o;
	output wire pcm_data_valid_o;
	input wire pcm_data_ready_i;
	reg [1:0] s_ch_target;
	reg s_data;
	wire s_data_valid;
	reg r_store_ch0;
	reg r_store_ch1;
	reg r_store_ch2;
	reg r_store_ch3;
	reg r_send_ch0;
	reg r_send_ch1;
	reg r_send_ch2;
	reg r_send_ch3;
	reg r_data_ch0;
	reg r_data_ch1;
	reg r_data_ch2;
	reg r_data_ch3;
	wire r_valid;
	reg r_clk;
	reg r_clk_dly;
	assign pdm_clk_o = r_clk;
	varcic #(
		.STAGES(5),
		.ACC_WIDTH(51)
	) i_varcic(
		.clk_i(clk_i),
		.rstn_i(rstn_i),
		.cfg_en_i(cfg_pdm_en_i),
		.cfg_ch_num_i(s_ch_target),
		.cfg_decimation_i(cfg_pdm_decimation_i),
		.cfg_shift_i(cfg_pdm_shift_i),
		.data_i(s_data),
		.data_valid_i(s_data_valid),
		.data_o(pcm_data_o),
		.data_valid_o(pcm_data_valid_o)
	);
	always @(*) begin : proc_s_ch_target
		s_ch_target = 0;
		case (cfg_pdm_ch_mode_i)
			2'b00: s_ch_target = 0;
			2'b01: s_ch_target = 1;
			2'b10: s_ch_target = 1;
			2'b11: s_ch_target = 3;
		endcase
	end
	always @(posedge clk_i or negedge rstn_i) begin : proc_r_store
		if (~rstn_i) begin
			r_store_ch0 <= 1;
			r_store_ch1 <= 0;
			r_store_ch2 <= 0;
			r_store_ch3 <= 0;
			r_send_ch0 <= 0;
			r_send_ch1 <= 0;
			r_send_ch2 <= 0;
			r_send_ch3 <= 0;
			r_data_ch0 <= 0;
			r_data_ch1 <= 0;
			r_data_ch2 <= 0;
			r_data_ch3 <= 0;
			r_clk <= 0;
			r_clk_dly <= 0;
		end
		else if (cfg_pdm_en_i)
			case (cfg_pdm_ch_mode_i)
				2'b00: begin
					r_store_ch0 <= ~r_store_ch0;
					r_send_ch0 <= ~r_send_ch0;
					if (r_store_ch0)
						r_data_ch0 <= pdm_ch0_i;
					r_clk <= ~r_clk;
				end
				2'b01: begin
					r_store_ch0 <= ~r_store_ch0;
					r_send_ch0 <= ~r_send_ch0;
					r_store_ch1 <= ~r_store_ch1;
					r_send_ch1 <= r_send_ch0;
					if (r_store_ch0)
						r_data_ch0 <= pdm_ch0_i;
					if (r_store_ch1)
						r_data_ch1 <= pdm_ch0_i;
					r_clk <= ~r_clk;
				end
				2'b10: begin
					r_store_ch0 <= ~r_store_ch0;
					r_send_ch0 <= ~r_send_ch0;
					r_send_ch1 <= r_send_ch0;
					if (r_store_ch0) begin
						r_data_ch0 <= pdm_ch0_i;
						r_data_ch1 <= pdm_ch1_i;
					end
					r_clk <= ~r_clk;
				end
				2'b11: begin
					r_store_ch0 <= r_clk_dly & ~r_clk;
					r_store_ch2 <= ~r_clk_dly & r_clk;
					r_send_ch0 <= r_store_ch0;
					r_send_ch1 <= r_send_ch0;
					r_send_ch2 <= r_send_ch1;
					r_send_ch3 <= r_send_ch2;
					if (r_store_ch0) begin
						r_data_ch0 <= pdm_ch0_i;
						r_data_ch1 <= pdm_ch1_i;
					end
					if (r_store_ch2) begin
						r_data_ch2 <= pdm_ch0_i;
						r_data_ch3 <= pdm_ch1_i;
					end
					r_clk <= ~r_clk_dly;
					r_clk_dly <= r_clk;
				end
			endcase
		else begin
			r_store_ch0 <= 1'b1;
			r_store_ch1 <= 0;
			r_store_ch2 <= 0;
			r_store_ch3 <= 0;
			r_send_ch0 <= 0;
			r_send_ch1 <= 0;
			r_send_ch2 <= 0;
			r_send_ch3 <= 0;
			r_clk <= 0;
			r_clk_dly <= 0;
		end
	end
	always @(*) begin : proc_s_data
		if (r_send_ch0)
			s_data = r_data_ch0;
		else if (r_send_ch1)
			s_data = r_data_ch1;
		else if (r_send_ch2)
			s_data = r_data_ch2;
		else
			s_data = r_data_ch3;
	end
	assign s_data_valid = ((r_send_ch0 | r_send_ch1) | r_send_ch2) | r_send_ch3;
endmodule
