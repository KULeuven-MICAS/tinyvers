module udma_filter_bincu (
	clk_i,
	resetn_i,
	cfg_use_signed_i,
	cfg_out_enable_i,
	cfg_en_counter_i,
	cfg_threshold_i,
	cfg_counter_i,
	cfg_datasize_i,
	counter_val_o,
	cmd_start_i,
	act_event_o,
	input_data_i,
	input_datasize_i,
	input_valid_i,
	input_sof_i,
	input_eof_i,
	input_ready_o,
	output_data_o,
	output_datasize_o,
	output_valid_o,
	output_sof_o,
	output_eof_o,
	output_ready_i
);
	parameter DATA_WIDTH = 32;
	parameter TRANS_SIZE = 16;
	input wire clk_i;
	input wire resetn_i;
	input wire cfg_use_signed_i;
	input wire cfg_out_enable_i;
	input wire cfg_en_counter_i;
	input wire [DATA_WIDTH - 1:0] cfg_threshold_i;
	input wire [TRANS_SIZE - 1:0] cfg_counter_i;
	input wire [1:0] cfg_datasize_i;
	output wire [TRANS_SIZE - 1:0] counter_val_o;
	input wire cmd_start_i;
	output wire act_event_o;
	input wire [DATA_WIDTH - 1:0] input_data_i;
	input wire [1:0] input_datasize_i;
	input wire input_valid_i;
	input wire input_sof_i;
	input wire input_eof_i;
	output wire input_ready_o;
	output wire [DATA_WIDTH - 1:0] output_data_o;
	output wire [1:0] output_datasize_o;
	output wire output_valid_o;
	output wire output_sof_o;
	output wire output_eof_o;
	input wire output_ready_i;
	wire s_th_event;
	wire s_counter_of;
	reg r_count_of;
	reg [TRANS_SIZE - 1:0] r_counter;
	reg [DATA_WIDTH - 1:0] s_input_data;
	assign s_th_event = s_input_data > cfg_threshold_i;
	assign s_counter_of = r_counter == cfg_counter_i;
	assign act_event_o = (cfg_en_counter_i ? s_counter_of & ~r_count_of : 1'b0);
	assign output_data_o = (s_th_event ? 32'h00000001 : 32'h00000000);
	assign output_valid_o = input_valid_i;
	assign output_eof_o = input_eof_i;
	assign output_sof_o = input_sof_i;
	assign input_ready_o = (cfg_out_enable_i ? output_ready_i : 1'b1);
	assign counter_val_o = r_counter;
	always @(*) begin : proc_
		s_input_data = input_data_i;
		case (cfg_datasize_i)
			2'b00: s_input_data = $signed({input_data_i[7] & cfg_use_signed_i, input_data_i[7:0]});
			2'b01: s_input_data = $signed({input_data_i[15] & cfg_use_signed_i, input_data_i[15:0]});
		endcase
	end
	always @(posedge clk_i or negedge resetn_i) begin : proc_r_counter
		if (~resetn_i) begin
			r_counter <= 0;
			r_count_of <= 0;
		end
		else if (cmd_start_i) begin
			r_counter <= 0;
			r_count_of <= 1'b0;
		end
		else begin
			r_count_of <= s_counter_of;
			if ((cfg_en_counter_i && s_th_event) && input_valid_i)
				r_counter <= r_counter + 1;
		end
	end
endmodule
