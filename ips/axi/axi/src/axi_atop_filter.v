module axi_atop_filter (
	clk_i,
	rst_ni,
	mst,
	slv
);
	parameter [31:0] AXI_ID_WIDTH = 0;
	parameter [31:0] AXI_MAX_WRITE_TXNS = 0;
	input wire clk_i;
	input wire rst_ni;
	input AXI_BUS.Master mst;
	input AXI_BUS.Slave slv;
	reg [$clog2(AXI_MAX_WRITE_TXNS + 1) - 1:0] w_cnt_d;
	reg [$clog2(AXI_MAX_WRITE_TXNS + 1) - 1:0] w_cnt_q;
	reg [2:0] w_state_d;
	reg [2:0] w_state_q;
	reg r_state_d;
	reg r_state_q;
	reg [AXI_ID_WIDTH - 1:0] id_d;
	reg [AXI_ID_WIDTH - 1:0] id_q;
	reg [7:0] r_beats_d;
	reg [7:0] r_beats_q;
	wire [7:0] r_resp_cmd_push;
	wire [7:0] r_resp_cmd_pop;
	reg r_resp_cmd_push_valid;
	wire r_resp_cmd_push_ready;
	wire r_resp_cmd_pop_valid;
	reg r_resp_cmd_pop_ready;
	localparam axi_pkg_ATOP_ATOMICSTORE = 2'b01;
	localparam axi_pkg_ATOP_NONE = 2'b00;
	localparam axi_pkg_RESP_SLVERR = 2'b10;
	always @(*) begin
		mst.aw_valid = 1'b0;
		slv.aw_ready = 1'b0;
		mst.w_valid = 1'b0;
		slv.w_ready = 1'b0;
		mst.b_ready = slv.b_ready;
		slv.b_valid = mst.b_valid;
		slv.b_id = mst.b_id;
		slv.b_resp = mst.b_resp;
		slv.b_user = mst.b_user;
		id_d = id_q;
		r_resp_cmd_push_valid = 1'b0;
		w_state_d = w_state_q;
		case (w_state_q)
			3'd0: begin
				if (w_cnt_q < AXI_MAX_WRITE_TXNS) begin
					mst.aw_valid = slv.aw_valid;
					slv.aw_ready = mst.aw_ready;
				end
				if (w_cnt_q > 0) begin
					mst.w_valid = slv.w_valid;
					slv.w_ready = mst.w_ready;
				end
				if (slv.aw_valid && (slv.aw_atop[5:4] != axi_pkg_ATOP_NONE)) begin
					mst.aw_valid = 1'b0;
					slv.aw_ready = 1'b1;
					id_d = slv.aw_id;
					if (slv.aw_atop[5:4] != axi_pkg_ATOP_ATOMICSTORE)
						r_resp_cmd_push_valid = 1'b1;
					if (w_cnt_q > 0)
						w_state_d = 3'd1;
					else begin
						mst.w_valid = 1'b0;
						slv.w_ready = 1'b1;
						if (slv.w_valid && slv.w_last)
							w_state_d = 3'd3;
						else
							w_state_d = 3'd2;
					end
				end
			end
			3'd1:
				if (w_cnt_q > 0) begin
					mst.w_valid = slv.w_valid;
					slv.w_ready = mst.w_ready;
				end
				else begin
					slv.w_ready = 1'b1;
					if (slv.w_valid && slv.w_last)
						w_state_d = 3'd3;
					else
						w_state_d = 3'd2;
				end
			3'd2: begin
				slv.w_ready = 1'b1;
				if (slv.w_valid && slv.w_last)
					w_state_d = 3'd3;
			end
			3'd3: begin
				mst.b_ready = 1'b0;
				slv.b_id = id_q;
				slv.b_resp = axi_pkg_RESP_SLVERR;
				slv.b_user = 1'sb0;
				slv.b_valid = 1'b1;
				if (slv.b_ready)
					if (r_resp_cmd_pop_valid && !r_resp_cmd_pop_ready)
						w_state_d = 3'd4;
					else
						w_state_d = 3'd0;
			end
			3'd4:
				if (!r_resp_cmd_pop_valid)
					w_state_d = 3'd0;
			default: w_state_d = 3'd0;
		endcase
	end
	always @(*) begin
		slv.r_valid = mst.r_valid;
		mst.r_ready = slv.r_ready;
		slv.r_id = mst.r_id;
		slv.r_data = mst.r_data;
		slv.r_resp = mst.r_resp;
		slv.r_last = mst.r_last;
		slv.r_user = mst.r_user;
		r_resp_cmd_pop_ready = 1'b0;
		r_beats_d = r_beats_q;
		r_state_d = r_state_q;
		case (r_state_q)
			1'd0:
				if (r_resp_cmd_pop_valid) begin
					r_beats_d = r_resp_cmd_pop[7-:8];
					r_state_d = 1'd1;
				end
			1'd1: begin
				mst.r_ready = 1'b0;
				slv.r_id = id_q;
				slv.r_data = 1'sb0;
				slv.r_resp = axi_pkg_RESP_SLVERR;
				slv.r_user = 1'sb0;
				slv.r_valid = 1'b1;
				slv.r_last = r_beats_q == {8 {1'sb0}};
				if (slv.r_ready)
					if (slv.r_last) begin
						r_resp_cmd_pop_ready = 1'b1;
						r_state_d = 1'd0;
					end
					else
						r_beats_d = r_beats_d - 1;
			end
			default: r_state_d = 1'd0;
		endcase
	end
	assign mst.aw_atop = 1'sb0;
	assign mst.aw_id = slv.aw_id;
	assign mst.aw_addr = slv.aw_addr;
	assign mst.aw_len = slv.aw_len;
	assign mst.aw_size = slv.aw_size;
	assign mst.aw_burst = slv.aw_burst;
	assign mst.aw_lock = slv.aw_lock;
	assign mst.aw_cache = slv.aw_cache;
	assign mst.aw_prot = slv.aw_prot;
	assign mst.aw_qos = slv.aw_qos;
	assign mst.aw_region = slv.aw_region;
	assign mst.aw_user = slv.aw_user;
	assign mst.w_data = slv.w_data;
	assign mst.w_strb = slv.w_strb;
	assign mst.w_last = slv.w_last;
	assign mst.w_user = slv.w_user;
	assign mst.ar_id = slv.ar_id;
	assign mst.ar_addr = slv.ar_addr;
	assign mst.ar_len = slv.ar_len;
	assign mst.ar_size = slv.ar_size;
	assign mst.ar_burst = slv.ar_burst;
	assign mst.ar_lock = slv.ar_lock;
	assign mst.ar_cache = slv.ar_cache;
	assign mst.ar_prot = slv.ar_prot;
	assign mst.ar_qos = slv.ar_qos;
	assign mst.ar_region = slv.ar_region;
	assign mst.ar_user = slv.ar_user;
	assign mst.ar_valid = slv.ar_valid;
	assign slv.ar_ready = mst.ar_ready;
	always @(*) begin
		w_cnt_d = w_cnt_q;
		if (mst.aw_valid && mst.aw_ready)
			w_cnt_d = w_cnt_d + 1;
		if ((mst.w_valid && mst.w_ready) && mst.w_last)
			w_cnt_d = w_cnt_d - 1;
	end
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni) begin
			id_q <= 1'sb0;
			r_beats_q <= 1'sb0;
			r_state_q <= 1'd0;
			w_cnt_q <= 1'sb0;
			w_state_q <= 3'd0;
		end
		else begin
			id_q <= id_d;
			r_beats_q <= r_beats_d;
			r_state_q <= r_state_d;
			w_cnt_q <= w_cnt_d;
			w_state_q <= w_state_d;
		end
	stream_register_DD1B0 r_resp_cmd(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.clr_i(1'b0),
		.testmode_i(1'b0),
		.valid_i(r_resp_cmd_push_valid),
		.ready_o(r_resp_cmd_push_ready),
		.data_i(r_resp_cmd_push),
		.valid_o(r_resp_cmd_pop_valid),
		.ready_i(r_resp_cmd_pop_ready),
		.data_o(r_resp_cmd_pop)
	);
	assign r_resp_cmd_push[7-:8] = slv.aw_len;
	initial begin : p_assertions
		
	end
endmodule
