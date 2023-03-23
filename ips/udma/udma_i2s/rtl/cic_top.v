module varcic (
	clk_i,
	rstn_i,
	cfg_en_i,
	cfg_ch_num_i,
	cfg_decimation_i,
	cfg_shift_i,
	data_i,
	data_valid_i,
	data_o,
	data_valid_o
);
	parameter STAGES = 5;
	parameter ACC_WIDTH = 51;
	input wire clk_i;
	input wire rstn_i;
	input wire cfg_en_i;
	input wire [1:0] cfg_ch_num_i;
	input wire [9:0] cfg_decimation_i;
	input wire [2:0] cfg_shift_i;
	input wire data_i;
	input wire data_valid_i;
	output reg [15:0] data_o;
	output wire data_valid_o;
	wire [ACC_WIDTH - 1:0] integrator_data [0:STAGES];
	wire [ACC_WIDTH - 1:0] comb_data [0:STAGES];
	reg [9:0] r_sample_nr;
	reg [1:0] r_ch_nr;
	reg r_en;
	wire s_clr;
	assign s_clr = cfg_en_i & !r_en;
	always @(posedge clk_i or negedge rstn_i)
		if (~rstn_i)
			r_en <= 'h0;
		else
			r_en <= cfg_en_i;
	always @(posedge clk_i or negedge rstn_i)
		if (~rstn_i) begin
			r_sample_nr <= 'h0;
			r_ch_nr <= 'h0;
		end
		else if (s_clr) begin
			r_sample_nr <= 0;
			r_ch_nr <= 0;
		end
		else if (data_valid_i)
			if (r_ch_nr == cfg_ch_num_i) begin
				r_ch_nr <= 'h0;
				if (r_sample_nr == cfg_decimation_i)
					r_sample_nr <= 0;
				else
					r_sample_nr <= r_sample_nr + 1;
			end
			else
				r_ch_nr <= r_ch_nr + 1;
	wire s_out_data_valid;
	assign s_out_data_valid = data_valid_i & (r_sample_nr == cfg_decimation_i);
	assign data_valid_o = s_out_data_valid;
	assign integrator_data[0] = (data_i ? 'h1 : {ACC_WIDTH {1'b1}});
	assign comb_data[0] = integrator_data[STAGES];
	genvar i;
	generate
		for (i = 0; i < STAGES; i = i + 1) begin : cic_stages
			cic_integrator #(.WIDTH(ACC_WIDTH)) cic_integrator_inst(
				.clk_i(clk_i),
				.rstn_i(rstn_i),
				.clr_i(s_clr),
				.sel_i(r_ch_nr),
				.en_i(data_valid_i),
				.data_i(integrator_data[i]),
				.data_o(integrator_data[i + 1])
			);
			cic_comb #(.WIDTH(ACC_WIDTH)) cic_comb_inst(
				.clk_i(clk_i),
				.rstn_i(rstn_i),
				.clr_i(s_clr),
				.sel_i(r_ch_nr),
				.en_i(s_out_data_valid),
				.data_i(comb_data[i]),
				.data_o(comb_data[i + 1])
			);
		end
	endgenerate
	always @(*) begin : proc_data_o
		data_o = 'h0;
		case (cfg_shift_i)
			0: data_o = comb_data[STAGES][ACC_WIDTH - 1:ACC_WIDTH - 16];
			1: data_o = comb_data[STAGES][ACC_WIDTH - 6:ACC_WIDTH - 21];
			2: data_o = comb_data[STAGES][ACC_WIDTH - 11:ACC_WIDTH - 26];
			3: data_o = comb_data[STAGES][ACC_WIDTH - 16:ACC_WIDTH - 31];
			4: data_o = comb_data[STAGES][ACC_WIDTH - 21:ACC_WIDTH - 36];
			5: data_o = comb_data[STAGES][ACC_WIDTH - 26:ACC_WIDTH - 41];
			6: data_o = comb_data[STAGES][ACC_WIDTH - 31:ACC_WIDTH - 46];
			7: data_o = comb_data[STAGES][ACC_WIDTH - 36:ACC_WIDTH - 51];
			default: data_o = comb_data[STAGES][ACC_WIDTH - 1:ACC_WIDTH - 16];
		endcase
	end
endmodule
