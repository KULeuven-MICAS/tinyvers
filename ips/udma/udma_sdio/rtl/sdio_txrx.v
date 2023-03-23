module sdio_txrx (
	clk_i,
	rstn_i,
	clr_stat_i,
	cmd_start_i,
	cmd_op_i,
	cmd_arg_i,
	cmd_rsp_type_i,
	rsp_data_o,
	data_en_i,
	data_rwn_i,
	data_quad_i,
	data_block_size_i,
	data_block_num_i,
	eot_o,
	status_o,
	in_data_if_data_i,
	in_data_if_valid_i,
	in_data_if_ready_o,
	out_data_if_data_o,
	out_data_if_valid_o,
	out_data_if_ready_i,
	sdclk_o,
	sdcmd_i,
	sdcmd_o,
	sdcmd_oen_o,
	sddata_o,
	sddata_i,
	sddata_oen_o
);
	input wire clk_i;
	input wire rstn_i;
	input wire clr_stat_i;
	input wire cmd_start_i;
	input wire [5:0] cmd_op_i;
	input wire [31:0] cmd_arg_i;
	input wire [2:0] cmd_rsp_type_i;
	output wire [127:0] rsp_data_o;
	input wire data_en_i;
	input wire data_rwn_i;
	input wire data_quad_i;
	input wire [9:0] data_block_size_i;
	input wire [7:0] data_block_num_i;
	output wire eot_o;
	output wire [15:0] status_o;
	input wire [31:0] in_data_if_data_i;
	input wire in_data_if_valid_i;
	output wire in_data_if_ready_o;
	output wire [31:0] out_data_if_data_o;
	output wire out_data_if_valid_o;
	input wire out_data_if_ready_i;
	output wire sdclk_o;
	input wire sdcmd_i;
	output wire sdcmd_o;
	output wire sdcmd_oen_o;
	output wire [3:0] sddata_o;
	input wire [3:0] sddata_i;
	output wire [3:0] sddata_oen_o;
	wire s_start_write;
	wire s_start_read;
	wire s_cmd_eot;
	wire s_cmd_clk_en;
	wire s_cmd_start;
	wire [5:0] s_cmd_op;
	wire [31:0] s_cmd_arg;
	wire [2:0] s_cmd_rsp_type;
	wire [5:0] s_cmd_status;
	reg s_stopcmd_start;
	wire [5:0] s_stopcmd_op;
	wire [31:0] s_stopcmd_arg;
	wire [2:0] s_stopcmd_rsp_type;
	reg s_cmd_mux;
	wire s_eot;
	reg s_clear_eot;
	wire [5:0] s_data_status;
	wire s_data_start;
	wire s_data_eot;
	wire s_data_last;
	wire s_data_clk_en;
	reg r_cmd_eot;
	reg r_data_eot;
	reg s_sample_eot;
	reg s_sample_sb;
	reg s_single_block;
	reg r_single_block;
	wire s_clk_en;
	wire s_busy;
	reg [1:0] s_state;
	reg [1:0] r_state;
	assign s_stopcmd_op = 6'd12;
	assign s_stopcmd_arg = 32'h00000000;
	assign s_stopcmd_rsp_type = 3'h1;
	assign s_data_start = data_en_i & ((data_rwn_i & s_start_read) | (~data_rwn_i & s_start_write));
	assign s_cmd_start = (s_cmd_mux ? s_stopcmd_start : cmd_start_i);
	assign s_cmd_op = (s_cmd_mux ? s_stopcmd_op : cmd_op_i);
	assign s_cmd_arg = (s_cmd_mux ? s_stopcmd_arg : cmd_arg_i);
	assign s_cmd_rsp_type = (s_cmd_mux ? s_stopcmd_rsp_type : cmd_rsp_type_i);
	assign eot_o = (s_cmd_mux ? s_eot : s_cmd_eot);
	assign s_eot = r_cmd_eot & r_data_eot;
	always @(*) begin : proc_sm
		s_cmd_mux = 1'b0;
		s_stopcmd_start = 1'b0;
		s_clear_eot = 1'b0;
		s_sample_eot = 1'b0;
		s_state = r_state;
		s_sample_sb = 1'b0;
		s_single_block = 1'b0;
		case (r_state)
			2'd0:
				if ((cmd_start_i && data_en_i) && (data_block_num_i == 0)) begin
					s_state = 2'd2;
					s_single_block = 1'b1;
					s_sample_sb = 1'b1;
				end
				else if (cmd_start_i && data_en_i) begin
					s_state = 2'd1;
					s_single_block = 1'b0;
					s_sample_sb = 1'b1;
				end
			2'd1: begin
				s_cmd_mux = 1'b1;
				if (s_data_last) begin
					s_stopcmd_start = 1'b1;
					s_state = 2'd2;
				end
			end
			2'd2: begin
				s_cmd_mux = 1'b1;
				s_sample_eot = 1'b1;
				if ((r_single_block || r_cmd_eot) && r_data_eot) begin
					s_clear_eot = 1'b1;
					s_state = 2'd0;
				end
			end
		endcase
	end
	always @(posedge clk_i or negedge rstn_i) begin : proc_r_eot
		if (~rstn_i) begin
			r_cmd_eot <= 0;
			r_data_eot <= 0;
			r_single_block <= 0;
			r_state <= 2'd0;
		end
		else begin
			r_state <= s_state;
			if (s_clear_eot) begin
				r_cmd_eot <= 0;
				r_data_eot <= 0;
				r_single_block <= 0;
			end
			else begin
				if (s_sample_eot) begin
					if (s_cmd_eot)
						r_cmd_eot <= 1'b1;
					if (s_data_eot)
						r_data_eot <= 1'b1;
				end
				if (s_sample_sb)
					r_single_block <= s_single_block;
			end
		end
	end
	assign s_clk_en = s_cmd_clk_en | s_data_clk_en;
	pulp_clock_gating i_clk_gate_sdio(
		.clk_i(clk_i),
		.en_i(s_clk_en),
		.test_en_i(1'b0),
		.clk_o(sdclk_o)
	);
	sdio_txrx_cmd i_cmd_if(
		.clk_i(clk_i),
		.rstn_i(rstn_i),
		.busy_i(s_busy),
		.start_write_o(s_start_write),
		.start_read_o(s_start_read),
		.clr_stat_i(clr_stat_i),
		.cmd_start_i(s_cmd_start),
		.cmd_op_i(s_cmd_op),
		.cmd_arg_i(s_cmd_arg),
		.cmd_rsp_type_i(s_cmd_rsp_type),
		.rsp_data_o(rsp_data_o),
		.eot_o(s_cmd_eot),
		.status_o(s_cmd_status),
		.sdclk_en_o(s_cmd_clk_en),
		.sdcmd_o(sdcmd_o),
		.sdcmd_i(sdcmd_i),
		.sdcmd_oen_o(sdcmd_oen_o)
	);
	sdio_txrx_data i_data_if(
		.clk_i(clk_i),
		.rstn_i(rstn_i),
		.clr_stat_i(clr_stat_i),
		.status_o(s_data_status),
		.busy_o(s_busy),
		.sdclk_en_o(s_data_clk_en),
		.data_start_i(s_data_start),
		.data_block_size_i(data_block_size_i),
		.data_block_num_i(data_block_num_i),
		.data_rwn_i(data_rwn_i),
		.data_quad_i(data_quad_i),
		.data_last_o(s_data_last),
		.eot_o(s_data_eot),
		.in_data_if_data_i(in_data_if_data_i),
		.in_data_if_valid_i(in_data_if_valid_i),
		.in_data_if_ready_o(in_data_if_ready_o),
		.out_data_if_data_o(out_data_if_data_o),
		.out_data_if_valid_o(out_data_if_valid_o),
		.out_data_if_ready_i(out_data_if_ready_i),
		.sddata_o(sddata_o),
		.sddata_i(sddata_i),
		.sddata_oen_o(sddata_oen_o)
	);
	assign status_o = {2'b00, s_data_status, 2'b00, s_cmd_status};
endmodule
