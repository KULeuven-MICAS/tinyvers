module axi2mem (
	clk_i,
	rst_ni,
	slave,
	req_o,
	we_o,
	addr_o,
	be_o,
	data_o,
	data_i
);
	parameter [31:0] AXI_ID_WIDTH = 10;
	parameter [31:0] AXI_ADDR_WIDTH = 64;
	parameter [31:0] AXI_DATA_WIDTH = 64;
	parameter [31:0] AXI_USER_WIDTH = 10;
	input wire clk_i;
	input wire rst_ni;
	input AXI_BUS.Slave slave;
	output reg req_o;
	output reg we_o;
	output reg [AXI_ADDR_WIDTH - 1:0] addr_o;
	output reg [(AXI_DATA_WIDTH / 8) - 1:0] be_o;
	output reg [AXI_DATA_WIDTH - 1:0] data_o;
	input wire [AXI_DATA_WIDTH - 1:0] data_i;
	localparam LOG_NR_BYTES = $clog2(AXI_DATA_WIDTH / 8);
	reg [2:0] state_d;
	reg [2:0] state_q;
	reg [(AXI_ID_WIDTH + AXI_ADDR_WIDTH) + 12:0] ax_req_d;
	reg [(AXI_ID_WIDTH + AXI_ADDR_WIDTH) + 12:0] ax_req_q;
	reg [AXI_ADDR_WIDTH - 1:0] req_addr_d;
	reg [AXI_ADDR_WIDTH - 1:0] req_addr_q;
	reg [7:0] cnt_d;
	reg [7:0] cnt_q;
	function automatic [AXI_ADDR_WIDTH - 1:0] get_wrap_bounadry;
		input reg [AXI_ADDR_WIDTH - 1:0] unaligned_address;
		input reg [7:0] len;
		reg [AXI_ADDR_WIDTH - 1:0] warp_address;
		begin
			warp_address = 1'sb0;
			if (len == 4'b0001)
				warp_address[AXI_ADDR_WIDTH - 1:1 + LOG_NR_BYTES] = unaligned_address[AXI_ADDR_WIDTH - 1:1 + LOG_NR_BYTES];
			else if (len == 4'b0011)
				warp_address[AXI_ADDR_WIDTH - 1:2 + LOG_NR_BYTES] = unaligned_address[AXI_ADDR_WIDTH - 1:2 + LOG_NR_BYTES];
			else if (len == 4'b0111)
				warp_address[AXI_ADDR_WIDTH - 1:3 + LOG_NR_BYTES] = unaligned_address[AXI_ADDR_WIDTH - 3:2 + LOG_NR_BYTES];
			else if (len == 4'b1111)
				warp_address[AXI_ADDR_WIDTH - 1:4 + LOG_NR_BYTES] = unaligned_address[AXI_ADDR_WIDTH - 3:4 + LOG_NR_BYTES];
			get_wrap_bounadry = warp_address;
		end
	endfunction
	reg [AXI_ADDR_WIDTH - 1:0] aligned_address;
	reg [AXI_ADDR_WIDTH - 1:0] wrap_boundary;
	reg [AXI_ADDR_WIDTH - 1:0] upper_wrap_boundary;
	reg [AXI_ADDR_WIDTH - 1:0] cons_addr;
	always @(*) begin
		aligned_address = {ax_req_q[(AXI_ADDR_WIDTH + 12) - ((AXI_ADDR_WIDTH - 1) - (AXI_ADDR_WIDTH - 1)):(AXI_ADDR_WIDTH + 12) - ((AXI_ADDR_WIDTH - 1) - LOG_NR_BYTES)], {{LOG_NR_BYTES} {1'b0}}};
		wrap_boundary = get_wrap_bounadry(ax_req_q[AXI_ADDR_WIDTH + 12-:((AXI_ADDR_WIDTH + 12) >= 13 ? AXI_ADDR_WIDTH + 0 : 14 - (AXI_ADDR_WIDTH + 12))], ax_req_q[12-:8]);
		upper_wrap_boundary = wrap_boundary + ((ax_req_q[12-:8] + 1) << LOG_NR_BYTES);
		cons_addr = aligned_address + (cnt_q << LOG_NR_BYTES);
		state_d = state_q;
		ax_req_d = ax_req_q;
		req_addr_d = req_addr_q;
		cnt_d = cnt_q;
		data_o = slave.w_data;
		be_o = slave.w_strb;
		we_o = 1'b0;
		req_o = 1'b0;
		addr_o = 1'sb0;
		slave.aw_ready = 1'b0;
		slave.ar_ready = 1'b0;
		slave.r_valid = 1'b0;
		slave.r_data = data_i;
		slave.r_resp = 1'sb0;
		slave.r_last = 1'sb0;
		slave.r_id = ax_req_q[AXI_ID_WIDTH + (AXI_ADDR_WIDTH + 12)-:((AXI_ID_WIDTH + (AXI_ADDR_WIDTH + 12)) >= (AXI_ADDR_WIDTH + 13) ? ((AXI_ID_WIDTH + (AXI_ADDR_WIDTH + 12)) - (AXI_ADDR_WIDTH + 13)) + 1 : ((AXI_ADDR_WIDTH + 13) - (AXI_ID_WIDTH + (AXI_ADDR_WIDTH + 12))) + 1)];
		slave.r_user = 1'sb0;
		slave.w_ready = 1'b0;
		slave.b_valid = 1'b0;
		slave.b_resp = 1'b0;
		slave.b_id = 1'b0;
		slave.b_user = 1'b0;
		case (state_q)
			3'd0:
				if (slave.ar_valid) begin
					slave.ar_ready = 1'b1;
					ax_req_d = {slave.ar_id, slave.ar_addr, slave.ar_len, slave.ar_size, slave.ar_burst};
					state_d = 3'd1;
					req_o = 1'b1;
					addr_o = slave.ar_addr;
					req_addr_d = slave.ar_addr;
					cnt_d = 1;
				end
				else if (slave.aw_valid) begin
					slave.aw_ready = 1'b1;
					slave.w_ready = 1'b1;
					addr_o = slave.aw_addr;
					ax_req_d = {slave.aw_id, slave.aw_addr, slave.aw_len, slave.aw_size, slave.aw_burst};
					if (slave.w_valid) begin
						req_o = 1'b1;
						we_o = 1'b1;
						state_d = (slave.w_last ? 3'd3 : 3'd2);
						cnt_d = 1;
					end
					else
						state_d = 3'd4;
				end
			3'd4: begin
				slave.w_ready = 1'b1;
				addr_o = ax_req_q[AXI_ADDR_WIDTH + 12-:((AXI_ADDR_WIDTH + 12) >= 13 ? AXI_ADDR_WIDTH + 0 : 14 - (AXI_ADDR_WIDTH + 12))];
				if (slave.w_valid) begin
					req_o = 1'b1;
					we_o = 1'b1;
					state_d = (slave.w_last ? 3'd3 : 3'd2);
					cnt_d = 1;
				end
			end
			3'd1: begin
				req_o = 1'b1;
				addr_o = req_addr_q;
				slave.r_valid = 1'b1;
				slave.r_data = data_i;
				slave.r_id = ax_req_q[AXI_ID_WIDTH + (AXI_ADDR_WIDTH + 12)-:((AXI_ID_WIDTH + (AXI_ADDR_WIDTH + 12)) >= (AXI_ADDR_WIDTH + 13) ? ((AXI_ID_WIDTH + (AXI_ADDR_WIDTH + 12)) - (AXI_ADDR_WIDTH + 13)) + 1 : ((AXI_ADDR_WIDTH + 13) - (AXI_ID_WIDTH + (AXI_ADDR_WIDTH + 12))) + 1)];
				slave.r_last = cnt_q == (ax_req_q[12-:8] + 1);
				if (slave.r_ready) begin
					case (ax_req_q[1-:2])
						2'b00, 2'b01: addr_o = cons_addr;
						2'b10:
							if (cons_addr == upper_wrap_boundary)
								addr_o = wrap_boundary;
							else if (cons_addr > upper_wrap_boundary)
								addr_o = ax_req_q[AXI_ADDR_WIDTH + 12-:((AXI_ADDR_WIDTH + 12) >= 13 ? AXI_ADDR_WIDTH + 0 : 14 - (AXI_ADDR_WIDTH + 12))] + ((cnt_q - ax_req_q[12-:8]) << LOG_NR_BYTES);
							else
								addr_o = cons_addr;
					endcase
					if (slave.r_last) begin
						state_d = 3'd0;
						req_o = 1'b0;
					end
					req_addr_d = addr_o;
					cnt_d = cnt_q + 1;
				end
			end
			3'd2: begin
				slave.w_ready = 1'b1;
				if (slave.w_valid) begin
					req_o = 1'b1;
					we_o = 1'b1;
					case (ax_req_q[1-:2])
						2'b00, 2'b01: addr_o = cons_addr;
						2'b10:
							if (cons_addr == upper_wrap_boundary)
								addr_o = wrap_boundary;
							else if (cons_addr > upper_wrap_boundary)
								addr_o = ax_req_q[AXI_ADDR_WIDTH + 12-:((AXI_ADDR_WIDTH + 12) >= 13 ? AXI_ADDR_WIDTH + 0 : 14 - (AXI_ADDR_WIDTH + 12))] + ((cnt_q - ax_req_q[12-:8]) << LOG_NR_BYTES);
							else
								addr_o = cons_addr;
					endcase
					req_addr_d = addr_o;
					cnt_d = cnt_q + 1;
					if (slave.w_last)
						state_d = 3'd3;
				end
			end
			3'd3: begin
				slave.b_valid = 1'b1;
				slave.b_id = ax_req_q[AXI_ID_WIDTH + (AXI_ADDR_WIDTH + 12)-:((AXI_ID_WIDTH + (AXI_ADDR_WIDTH + 12)) >= (AXI_ADDR_WIDTH + 13) ? ((AXI_ID_WIDTH + (AXI_ADDR_WIDTH + 12)) - (AXI_ADDR_WIDTH + 13)) + 1 : ((AXI_ADDR_WIDTH + 13) - (AXI_ID_WIDTH + (AXI_ADDR_WIDTH + 12))) + 1)];
				if (slave.b_ready)
					state_d = 3'd0;
			end
		endcase
	end
	always @(posedge clk_i or negedge rst_ni)
		if (~rst_ni) begin
			state_q <= 3'd0;
			ax_req_q <= 1'sb0;
			req_addr_q <= 1'sb0;
			cnt_q <= 1'sb0;
		end
		else begin
			state_q <= state_d;
			ax_req_q <= ax_req_d;
			req_addr_q <= req_addr_d;
			cnt_q <= cnt_d;
		end
endmodule
