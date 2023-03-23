module fc_demux (
	clk,
	rst_n,
	port_sel_i,
	slave_port,
	master_port0,
	master_port1
);
	input wire clk;
	input wire rst_n;
	input wire port_sel_i;
	input XBAR_TCDM_BUS.Slave slave_port;
	input XBAR_TCDM_BUS.Master master_port0;
	input UNICAD_MEM_BUS_32.Master master_port1;
	reg req_port1;
	reg [31:0] addr_port1;
	wire gnt_port1;
	wire rvalid_port1;
	reg wen_port1;
	reg [3:0] be_port1;
	wire [31:0] rdata_port1;
	reg [31:0] wdata_port1;
	reg req_port0;
	reg [31:0] addr_port0;
	wire gnt_port0;
	wire rvalid_port0;
	reg wen_port0;
	reg [3:0] be_port0;
	wire [31:0] rdata_port0;
	reg [31:0] wdata_port0;
	reg dest_q;
	wire req_slave;
	wire [31:0] addr_slave;
	reg gnt_slave;
	reg rvalid_slave;
	wire wen_slave;
	wire [3:0] be_slave;
	reg [31:0] rdata_slave;
	wire [31:0] wdata_slave;
	wire master_port1_gnt;
	reg master_port1_r_valid;
	assign req_slave = slave_port.req;
	assign addr_slave = slave_port.add;
	assign wen_slave = slave_port.wen;
	assign wdata_slave = slave_port.wdata;
	assign be_slave = slave_port.be;
	assign slave_port.gnt = gnt_slave;
	assign slave_port.r_rdata = rdata_slave;
	assign slave_port.r_valid = rvalid_slave;
	assign master_port0.req = req_port0;
	assign master_port0.add = addr_port0;
	assign master_port0.wen = wen_port0;
	assign master_port0.wdata = wdata_port0;
	assign master_port0.be = be_port0;
	assign gnt_port0 = master_port0.gnt;
	assign rdata_port0 = master_port0.r_rdata;
	assign rvalid_port0 = master_port0.r_valid;
	assign master_port1.csn = ~req_port1;
	assign master_port1.add = addr_port1;
	assign master_port1.wen = wen_port1;
	assign master_port1.wdata = wdata_port1;
	assign master_port1.be = be_port1;
	assign gnt_port1 = master_port1_gnt;
	assign rdata_port1 = master_port1.rdata;
	assign rvalid_port1 = master_port1_r_valid;
	assign master_port1_gnt = 1'b1;
	reg demux_state_q;
	always @(posedge clk or negedge rst_n)
		if (~rst_n) begin
			dest_q <= 0;
			demux_state_q <= 1'd0;
			master_port1_r_valid <= 1'b0;
		end
		else
			case (demux_state_q)
				1'd0:
					if (req_slave & gnt_slave) begin
						case (port_sel_i)
							1'b0: begin
								dest_q <= 0;
								master_port1_r_valid <= 1'b0;
							end
							1'b1: begin
								dest_q <= 1;
								master_port1_r_valid <= master_port1_gnt;
							end
						endcase
						demux_state_q <= 1'd1;
					end
				1'd1:
					if (rvalid_slave)
						if (req_slave & gnt_slave) begin
							case (port_sel_i)
								1'b0: begin
									dest_q <= 0;
									master_port1_r_valid <= 1'b0;
								end
								1'b1: begin
									dest_q <= 1;
									master_port1_r_valid <= master_port1_gnt;
								end
							endcase
							demux_state_q <= 1'd1;
						end
						else begin
							demux_state_q <= 1'd0;
							master_port1_r_valid <= 1'b0;
						end
			endcase
	always @(*) begin
		req_port0 = req_slave & ~port_sel_i;
		addr_port0 = addr_slave & {32 {~port_sel_i}};
		wen_port0 = wen_slave & {32 {~port_sel_i}};
		be_port0 = be_slave & {32 {~port_sel_i}};
		wdata_port0 = wdata_slave & {32 {~port_sel_i}};
		req_port1 = req_slave & port_sel_i;
		addr_port1 = addr_slave & {32 {port_sel_i}};
		wen_port1 = wen_slave & {32 {port_sel_i}};
		be_port1 = be_slave & {32 {port_sel_i}};
		wdata_port1 = wdata_slave & {32 {port_sel_i}};
		if (req_slave)
			gnt_slave = (port_sel_i ? gnt_port1 : gnt_port0);
		else
			gnt_slave = 1'b0;
		case (dest_q)
			0: {rvalid_slave, rdata_slave} = {rvalid_port0, rdata_port0};
			1: {rvalid_slave, rdata_slave} = {rvalid_port1, rdata_port1};
			default: {rvalid_slave, rdata_slave} = 1'sb0;
		endcase
	end
endmodule
