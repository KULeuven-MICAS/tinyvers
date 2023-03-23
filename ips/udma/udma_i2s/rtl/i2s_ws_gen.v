module i2s_ws_gen (
	sck_i,
	rstn_i,
	cfg_ws_en_i,
	ws_o,
	cfg_data_size_i,
	cfg_word_num_i
);
	input wire sck_i;
	input wire rstn_i;
	input wire cfg_ws_en_i;
	output reg ws_o;
	input wire [4:0] cfg_data_size_i;
	input wire [2:0] cfg_word_num_i;
	reg [4:0] r_counter;
	reg [2:0] r_word_counter;
	always @(posedge sck_i or negedge rstn_i)
		if (rstn_i == 1'b0) begin
			r_counter <= 'h0;
			r_word_counter <= 'h0;
		end
		else if (cfg_ws_en_i)
			if (r_counter == cfg_data_size_i) begin
				r_counter <= 'h0;
				if (r_word_counter == cfg_word_num_i)
					r_word_counter <= 'h0;
				else
					r_word_counter <= r_word_counter + 1;
			end
			else
				r_counter <= r_counter + 1;
	always @(negedge sck_i or negedge rstn_i)
		if (rstn_i == 1'b0)
			ws_o <= 1'b0;
		else if (cfg_ws_en_i)
			if ((r_counter == cfg_data_size_i) && (r_word_counter == cfg_word_num_i))
				ws_o <= ~ws_o;
endmodule
