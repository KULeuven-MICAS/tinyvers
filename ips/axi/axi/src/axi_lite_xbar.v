module axi_lite_xbar (
	clk_i,
	rst_ni,
	master,
	slave,
	rules
);
	parameter signed [31:0] ADDR_WIDTH = -1;
	parameter signed [31:0] DATA_WIDTH = -1;
	parameter signed [31:0] NUM_MASTER = 1;
	parameter signed [31:0] NUM_SLAVE = 1;
	parameter signed [31:0] NUM_RULES = -1;
	input wire clk_i;
	input wire rst_ni;
	input AXI_LITE.Slave [0:NUM_MASTER - 1] master;
	input AXI_LITE.Master [0:NUM_SLAVE - 1] slave;
	input AXI_ROUTING_RULES.xbar rules;
	AXI_ARBITRATION #(.NUM_REQ(NUM_MASTER)) s_arb_rd();
	AXI_ARBITRATION #(.NUM_REQ(NUM_MASTER)) s_arb_wr();
	axi_lite_xbar_simple #(
		.ADDR_WIDTH(ADDR_WIDTH),
		.DATA_WIDTH(DATA_WIDTH),
		.NUM_MASTER(NUM_MASTER),
		.NUM_SLAVE(NUM_SLAVE),
		.NUM_RULES(NUM_RULES)
	) i_simple(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.master(master),
		.slave(slave),
		.rules(rules),
		.arb_rd(s_arb_rd.req),
		.arb_wr(s_arb_wr.req)
	);
	axi_arbiter #(.NUM_REQ(NUM_MASTER)) i_arb_rd(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.arb(s_arb_rd.arb)
	);
	axi_arbiter #(.NUM_REQ(NUM_MASTER)) i_arb_wr(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.arb(s_arb_wr.arb)
	);
endmodule
module axi_lite_xbar_simple (
	clk_i,
	rst_ni,
	master,
	slave,
	rules,
	arb_rd,
	arb_wr
);
	parameter signed [31:0] ADDR_WIDTH = -1;
	parameter signed [31:0] DATA_WIDTH = -1;
	parameter signed [31:0] NUM_MASTER = 1;
	parameter signed [31:0] NUM_SLAVE = 1;
	parameter signed [31:0] NUM_RULES = -1;
	input wire clk_i;
	input wire rst_ni;
	input AXI_LITE.Slave [0:NUM_MASTER - 1] master;
	input AXI_LITE.Master [0:NUM_SLAVE - 1] slave;
	input AXI_ROUTING_RULES.xbar rules;
	input AXI_ARBITRATION.req arb_rd;
	input AXI_ARBITRATION.req arb_wr;
	genvar i;
	reg [($clog2(NUM_MASTER) + $clog2(NUM_SLAVE)) - 1:0] tag_rd_d;
	reg [($clog2(NUM_MASTER) + $clog2(NUM_SLAVE)) - 1:0] tag_wr_d;
	reg [($clog2(NUM_MASTER) + $clog2(NUM_SLAVE)) - 1:0] tag_rd_q;
	reg [($clog2(NUM_MASTER) + $clog2(NUM_SLAVE)) - 1:0] tag_wr_q;
	reg [31:0] state_rd_d;
	reg [31:0] state_rd_q;
	reg [31:0] state_wr_d;
	reg [31:0] state_wr_q;
	always @(posedge clk_i or negedge rst_ni)
		if (~rst_ni) begin
			state_rd_q <= 32'd0;
			state_wr_q <= 32'd0;
			tag_rd_q <= 1'sb0;
			tag_wr_q <= 1'sb0;
		end
		else begin
			state_rd_q <= state_rd_d;
			state_wr_q <= state_wr_d;
			tag_rd_q <= tag_rd_d;
			tag_wr_q <= tag_wr_d;
		end
	reg [$clog2(NUM_MASTER) - 1:0] master_sel_rd;
	reg [$clog2(NUM_MASTER) - 1:0] master_sel_wr;
	wire [(NUM_MASTER * ADDR_WIDTH) - 1:0] master_araddr_pack;
	wire [NUM_MASTER - 1:0] master_rready_pack;
	wire [(NUM_MASTER * ADDR_WIDTH) - 1:0] master_awaddr_pack;
	wire [(NUM_MASTER * DATA_WIDTH) - 1:0] master_wdata_pack;
	wire [(NUM_MASTER * (DATA_WIDTH / 8)) - 1:0] master_wstrb_pack;
	wire [NUM_MASTER - 1:0] master_wvalid_pack;
	wire [NUM_MASTER - 1:0] master_bready_pack;
	wire [ADDR_WIDTH - 1:0] master_araddr;
	reg master_arready;
	reg [DATA_WIDTH - 1:0] master_rdata;
	reg [1:0] master_rresp;
	reg master_rvalid;
	wire master_rready;
	wire [ADDR_WIDTH - 1:0] master_awaddr;
	reg master_awready;
	wire [DATA_WIDTH - 1:0] master_wdata;
	wire [(DATA_WIDTH / 8) - 1:0] master_wstrb;
	wire master_wvalid;
	reg master_wready;
	reg [1:0] master_bresp;
	reg master_bvalid;
	wire master_bready;
	generate
		for (i = 0; i < NUM_MASTER; i = i + 1) begin : genblk3
			assign master_araddr_pack[i * ADDR_WIDTH+:ADDR_WIDTH] = master[i].ar_addr;
			assign master[i].ar_ready = master_arready && (i == master_sel_rd);
			assign master[i].r_data = master_rdata;
			assign master[i].r_resp = master_rresp;
			assign master[i].r_valid = master_rvalid && (i == master_sel_rd);
			assign master_rready_pack[i] = master[i].r_ready;
			assign master_awaddr_pack[i * ADDR_WIDTH+:ADDR_WIDTH] = master[i].aw_addr;
			assign master[i].aw_ready = master_awready && (i == master_sel_wr);
			assign master_wdata_pack[i * DATA_WIDTH+:DATA_WIDTH] = master[i].w_data;
			assign master_wstrb_pack[i * (DATA_WIDTH / 8)+:DATA_WIDTH / 8] = master[i].w_strb;
			assign master_wvalid_pack[i] = master[i].w_valid;
			assign master[i].w_ready = master_wready && (i == master_sel_wr);
			assign master[i].b_resp = master_bresp;
			assign master_bready_pack[i] = master[i].b_ready;
			assign master[i].b_valid = master_bvalid && (i == master_sel_wr);
		end
	endgenerate
	assign master_araddr = master_araddr_pack[master_sel_rd * ADDR_WIDTH+:ADDR_WIDTH];
	assign master_rready = master_rready_pack[master_sel_rd];
	assign master_awaddr = master_awaddr_pack[master_sel_wr * ADDR_WIDTH+:ADDR_WIDTH];
	assign master_wdata = master_wdata_pack[master_sel_wr * DATA_WIDTH+:DATA_WIDTH];
	assign master_wstrb = master_wstrb_pack[master_sel_wr * (DATA_WIDTH / 8)+:DATA_WIDTH / 8];
	assign master_wvalid = master_wvalid_pack[master_sel_wr];
	assign master_bready = master_bready_pack[master_sel_wr];
	reg [$clog2(NUM_SLAVE) - 1:0] slave_sel_rd;
	reg [$clog2(NUM_SLAVE) - 1:0] slave_sel_wr;
	wire [NUM_SLAVE - 1:0] slave_arready_pack;
	wire [(NUM_SLAVE * DATA_WIDTH) - 1:0] slave_rdata_pack;
	wire [(NUM_SLAVE * 2) - 1:0] slave_rresp_pack;
	wire [NUM_SLAVE - 1:0] slave_rvalid_pack;
	wire [NUM_SLAVE - 1:0] slave_awready_pack;
	wire [NUM_SLAVE - 1:0] slave_wready_pack;
	wire [(NUM_SLAVE * 2) - 1:0] slave_bresp_pack;
	wire [NUM_SLAVE - 1:0] slave_bvalid_pack;
	reg [ADDR_WIDTH - 1:0] slave_araddr;
	reg slave_arvalid;
	wire slave_arready;
	wire [DATA_WIDTH - 1:0] slave_rdata;
	wire [1:0] slave_rresp;
	wire slave_rvalid;
	reg slave_rready;
	reg [ADDR_WIDTH - 1:0] slave_awaddr;
	reg slave_awvalid;
	wire slave_awready;
	reg [DATA_WIDTH - 1:0] slave_wdata;
	reg [(DATA_WIDTH / 8) - 1:0] slave_wstrb;
	reg slave_wvalid;
	wire slave_wready;
	wire [1:0] slave_bresp;
	wire slave_bvalid;
	reg slave_bready;
	generate
		for (i = 0; i < NUM_SLAVE; i = i + 1) begin : genblk4
			assign slave[i].ar_addr = slave_araddr;
			assign slave[i].ar_valid = slave_arvalid && (i == slave_sel_rd);
			assign slave_arready_pack[i] = slave[i].ar_ready;
			assign slave_rdata_pack[i * DATA_WIDTH+:DATA_WIDTH] = slave[i].r_data;
			assign slave_rresp_pack[i * 2+:2] = slave[i].r_resp;
			assign slave_rvalid_pack[i] = slave[i].r_valid;
			assign slave[i].r_ready = slave_rready && (i == slave_sel_rd);
			assign slave[i].aw_addr = slave_awaddr;
			assign slave[i].aw_valid = slave_awvalid && (i == slave_sel_wr);
			assign slave_awready_pack[i] = slave[i].aw_ready;
			assign slave[i].w_data = slave_wdata;
			assign slave[i].w_strb = slave_wstrb;
			assign slave[i].w_valid = slave_wvalid && (i == slave_sel_wr);
			assign slave_wready_pack[i] = slave[i].w_ready;
			assign slave_bresp_pack[i * 2+:2] = slave[i].b_resp;
			assign slave_bvalid_pack[i] = slave[i].b_valid;
			assign slave[i].b_ready = slave_bready && (i == slave_sel_wr);
		end
	endgenerate
	assign slave_arready = slave_arready_pack[slave_sel_rd];
	assign slave_rdata = slave_rdata_pack[slave_sel_rd * DATA_WIDTH+:DATA_WIDTH];
	assign slave_rresp = slave_rresp_pack[slave_sel_rd * 2+:2];
	assign slave_rvalid = slave_rvalid_pack[slave_sel_rd];
	assign slave_awready = slave_awready_pack[slave_sel_wr];
	assign slave_wready = slave_wready_pack[slave_sel_wr];
	assign slave_bresp = slave_bresp_pack[slave_sel_wr * 2+:2];
	assign slave_bvalid = slave_bvalid_pack[slave_sel_wr];
	generate
		for (i = 0; i < NUM_MASTER; i = i + 1) begin : genblk5
			assign arb_rd.in_req[i] = master[i].ar_valid;
			assign arb_wr.in_req[i] = master[i].aw_valid;
		end
	endgenerate
	reg [ADDR_WIDTH - 1:0] rd_resolve_addr;
	reg [ADDR_WIDTH - 1:0] wr_resolve_addr;
	wire [$clog2(NUM_SLAVE) - 1:0] rd_match_idx;
	wire [$clog2(NUM_SLAVE) - 1:0] wr_match_idx;
	wire rd_match_ok;
	wire wr_match_ok;
	axi_address_resolver #(
		.ADDR_WIDTH(ADDR_WIDTH),
		.NUM_SLAVE(NUM_SLAVE),
		.NUM_RULES(NUM_RULES)
	) i_rd_resolver(
		.rules(rules),
		.addr_i(rd_resolve_addr),
		.match_idx_o(rd_match_idx),
		.match_ok_o(rd_match_ok)
	);
	axi_address_resolver #(
		.ADDR_WIDTH(ADDR_WIDTH),
		.NUM_SLAVE(NUM_SLAVE),
		.NUM_RULES(NUM_RULES)
	) i_wr_resolver(
		.rules(rules),
		.addr_i(wr_resolve_addr),
		.match_idx_o(wr_match_idx),
		.match_ok_o(wr_match_ok)
	);
	localparam axi_pkg_RESP_DECERR = 2'b11;
	always @(*) begin
		state_rd_d = state_rd_q;
		tag_rd_d = tag_rd_q;
		arb_rd.out_ack = 0;
		master_sel_rd = tag_rd_q[$clog2(NUM_MASTER) + ($clog2(NUM_SLAVE) - 1)-:(($clog2(NUM_MASTER) + ($clog2(NUM_SLAVE) - 1)) >= ($clog2(NUM_SLAVE) + 0) ? (($clog2(NUM_MASTER) + ($clog2(NUM_SLAVE) - 1)) - ($clog2(NUM_SLAVE) + 0)) + 1 : (($clog2(NUM_SLAVE) + 0) - ($clog2(NUM_MASTER) + ($clog2(NUM_SLAVE) - 1))) + 1)];
		slave_sel_rd = tag_rd_q[$clog2(NUM_SLAVE) - 1-:$clog2(NUM_SLAVE)];
		rd_resolve_addr = master_araddr;
		slave_araddr = master_araddr;
		slave_arvalid = 0;
		master_arready = 0;
		master_rdata = slave_rdata;
		master_rresp = slave_rresp;
		master_rvalid = 0;
		slave_rready = 0;
		case (state_rd_q)
			32'd0: begin
				master_sel_rd = arb_rd.out_sel;
				if (arb_rd.out_req) begin
					arb_rd.out_ack = 1;
					tag_rd_d[$clog2(NUM_MASTER) + ($clog2(NUM_SLAVE) - 1)-:(($clog2(NUM_MASTER) + ($clog2(NUM_SLAVE) - 1)) >= ($clog2(NUM_SLAVE) + 0) ? (($clog2(NUM_MASTER) + ($clog2(NUM_SLAVE) - 1)) - ($clog2(NUM_SLAVE) + 0)) + 1 : (($clog2(NUM_SLAVE) + 0) - ($clog2(NUM_MASTER) + ($clog2(NUM_SLAVE) - 1))) + 1)] = arb_rd.out_sel;
					state_rd_d = 32'd1;
				end
			end
			32'd1: begin
				slave_sel_rd = rd_match_idx;
				tag_rd_d[$clog2(NUM_SLAVE) - 1-:$clog2(NUM_SLAVE)] = rd_match_idx;
				if (rd_match_ok) begin
					slave_arvalid = 1;
					if (slave_arready) begin
						state_rd_d = 32'd2;
						master_arready = 1;
					end
				end
				else begin
					state_rd_d = 32'd3;
					master_arready = 1;
				end
			end
			32'd2: begin
				master_rvalid = slave_rvalid;
				slave_rready = master_rready;
				if (slave_rvalid && master_rready)
					state_rd_d = 32'd0;
			end
			32'd3: begin
				master_rresp = axi_pkg_RESP_DECERR;
				master_rvalid = 1;
				if (master_rready)
					state_rd_d = 32'd0;
			end
			default: state_rd_d = 32'd0;
		endcase
	end
	always @(*) begin
		state_wr_d = state_wr_q;
		tag_wr_d = tag_wr_q;
		arb_wr.out_ack = 0;
		master_sel_wr = tag_wr_q[$clog2(NUM_MASTER) + ($clog2(NUM_SLAVE) - 1)-:(($clog2(NUM_MASTER) + ($clog2(NUM_SLAVE) - 1)) >= ($clog2(NUM_SLAVE) + 0) ? (($clog2(NUM_MASTER) + ($clog2(NUM_SLAVE) - 1)) - ($clog2(NUM_SLAVE) + 0)) + 1 : (($clog2(NUM_SLAVE) + 0) - ($clog2(NUM_MASTER) + ($clog2(NUM_SLAVE) - 1))) + 1)];
		slave_sel_wr = tag_wr_q[$clog2(NUM_SLAVE) - 1-:$clog2(NUM_SLAVE)];
		wr_resolve_addr = master_awaddr;
		slave_awaddr = master_awaddr;
		slave_awvalid = 0;
		master_awready = 0;
		slave_wdata = master_wdata;
		slave_wstrb = master_wstrb;
		slave_wvalid = 0;
		master_wready = 0;
		master_bresp = slave_bresp;
		master_bvalid = 0;
		slave_bready = 0;
		case (state_wr_q)
			32'd0: begin
				master_sel_wr = arb_wr.out_sel;
				if (arb_wr.out_req) begin
					arb_wr.out_ack = 1;
					tag_wr_d[$clog2(NUM_MASTER) + ($clog2(NUM_SLAVE) - 1)-:(($clog2(NUM_MASTER) + ($clog2(NUM_SLAVE) - 1)) >= ($clog2(NUM_SLAVE) + 0) ? (($clog2(NUM_MASTER) + ($clog2(NUM_SLAVE) - 1)) - ($clog2(NUM_SLAVE) + 0)) + 1 : (($clog2(NUM_SLAVE) + 0) - ($clog2(NUM_MASTER) + ($clog2(NUM_SLAVE) - 1))) + 1)] = arb_wr.out_sel;
					state_wr_d = 32'd1;
				end
			end
			32'd1: begin
				slave_sel_wr = wr_match_idx;
				tag_wr_d[$clog2(NUM_SLAVE) - 1-:$clog2(NUM_SLAVE)] = wr_match_idx;
				if (wr_match_ok) begin
					slave_awvalid = 1;
					if (slave_awready) begin
						state_wr_d = 32'd2;
						master_awready = 1;
					end
				end
				else begin
					state_wr_d = 32'd4;
					master_awready = 1;
				end
			end
			32'd2: begin
				master_wready = slave_wready;
				slave_wvalid = master_wvalid;
				if (slave_wvalid && master_wready)
					state_wr_d = 32'd3;
			end
			32'd3: begin
				master_bvalid = slave_bvalid;
				slave_bready = master_bready;
				if (slave_bvalid && master_bready)
					state_wr_d = 32'd0;
			end
			32'd4: begin
				master_wready = 1;
				if (master_wvalid)
					state_wr_d = 32'd5;
			end
			32'd5: begin
				master_bresp = axi_pkg_RESP_DECERR;
				master_bvalid = 1;
				if (master_bready)
					state_wr_d = 32'd0;
			end
			default: state_wr_d = 32'd0;
		endcase
	end
endmodule
