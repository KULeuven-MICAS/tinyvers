module size_conv_RX_64_to_32 (
	clk,
	rst_n,
	data_rx_rdata_o,
	data_rx_valid_o,
	data_rx_ready_i,
	push_cmd_req_i,
	push_cmd_gnt_o,
	data_rx_addr_i,
	data_rx_size_i,
	data_rx_raddr_o,
	data_rx_clk_en_o,
	data_rx_req_o,
	data_rx_eot_o,
	data_rx_gnt_i,
	data_rx_rdata_i,
	pending_o,
	mram_mode_i,
	NVR_i,
	TMEN_i,
	AREF_i,
	mram_NVR_o,
	mram_TMEN_o,
	mram_AREF_o
);
	parameter TRANS_SIZE = 16;
	input wire clk;
	input wire rst_n;
	output wire [63:0] data_rx_rdata_o;
	output reg data_rx_valid_o;
	input wire data_rx_ready_i;
	input wire push_cmd_req_i;
	output wire push_cmd_gnt_o;
	input wire [15:0] data_rx_addr_i;
	input wire [TRANS_SIZE - 1:0] data_rx_size_i;
	output reg [15:0] data_rx_raddr_o;
	output wire data_rx_clk_en_o;
	output reg data_rx_req_o;
	output reg data_rx_eot_o;
	input wire data_rx_gnt_i;
	input wire [63:0] data_rx_rdata_i;
	output wire pending_o;
	input wire [7:0] mram_mode_i;
	input wire NVR_i;
	input wire TMEN_i;
	input wire AREF_i;
	output reg mram_NVR_o;
	output reg mram_TMEN_o;
	output reg mram_AREF_o;
	reg [15:0] data_rx_addr_Q;
	reg [TRANS_SIZE - 1:0] data_rx_size_Q;
	wire [15:0] data_rx_addr_int;
	wire [TRANS_SIZE - 1:0] data_rx_size_int;
	wire valid_cmd;
	reg save_addr;
	reg update_addr;
	reg en_clock;
	reg [2:0] NS;
	reg [2:0] CS;
	assign pending_o = ((valid_cmd == 1'b1) || (CS != 3'd0)) || (data_rx_valid_o == 1'b1);
	assign data_rx_clk_en_o = en_clock;
	assign {data_rx_size_int, data_rx_addr_int} = {data_rx_size_i, data_rx_addr_i};
	assign valid_cmd = push_cmd_req_i;
	assign push_cmd_gnt_o = save_addr;
	always @(posedge clk or negedge rst_n)
		if (~rst_n) begin
			CS <= 3'd0;
			data_rx_addr_Q <= 1'sb0;
			data_rx_size_Q <= 1'sb0;
			mram_AREF_o <= 1'b0;
			mram_TMEN_o <= 1'b0;
			mram_NVR_o <= 1'b0;
		end
		else begin
			CS <= NS;
			if (save_addr) begin
				data_rx_addr_Q <= data_rx_addr_int + 1;
				data_rx_size_Q <= data_rx_size_int - 8;
				mram_AREF_o <= AREF_i;
				mram_TMEN_o <= TMEN_i;
				mram_NVR_o <= NVR_i;
			end
			else if (update_addr) begin
				data_rx_addr_Q <= data_rx_addr_Q + 1;
				data_rx_size_Q <= data_rx_size_Q - 8;
			end
		end
	always @(*) begin
		en_clock = 1'b0;
		data_rx_raddr_o = 1'sb0;
		data_rx_req_o = 1'sb0;
		data_rx_eot_o = 1'b0;
		save_addr = 1'b0;
		update_addr = 1'b0;
		data_rx_valid_o = 1'b0;
		NS = CS;
		case (CS)
			3'd0: begin
				en_clock = valid_cmd & data_rx_gnt_i;
				save_addr = valid_cmd & data_rx_gnt_i;
				data_rx_req_o = valid_cmd;
				data_rx_raddr_o = data_rx_addr_int;
				if (data_rx_req_o & data_rx_gnt_i)
					NS = (data_rx_size_int <= 8 ? 3'd2 : 3'd1);
				else
					NS = 3'd0;
			end
			3'd1: begin
				data_rx_valid_o = 1'b1;
				en_clock = data_rx_ready_i & data_rx_gnt_i;
				data_rx_req_o = (data_rx_ready_i ? data_rx_size_Q > 0 : 1'b0);
				data_rx_raddr_o = data_rx_addr_Q;
				update_addr = (data_rx_ready_i & data_rx_gnt_i ? data_rx_size_Q > 0 : 1'b0);
				if (data_rx_ready_i) begin
					if (data_rx_gnt_i)
						NS = (data_rx_size_Q <= 8 ? 3'd2 : 3'd1);
					else
						NS = 3'd3;
				end
				else
					NS = 3'd1;
			end
			3'd3: begin
				data_rx_valid_o = 1'b0;
				en_clock = data_rx_gnt_i;
				data_rx_req_o = data_rx_size_Q > 0;
				data_rx_raddr_o = data_rx_addr_Q;
				update_addr = (data_rx_gnt_i ? data_rx_size_Q > 0 : 1'b0);
				if (data_rx_req_o & data_rx_gnt_i)
					NS = (data_rx_size_int <= 8 ? 3'd2 : 3'd1);
				else
					NS = 3'd3;
			end
			3'd2: begin
				data_rx_raddr_o = 1'sb0;
				update_addr = 1'b0;
				data_rx_req_o = 1'b0;
				data_rx_eot_o = 1'b1;
				data_rx_valid_o = 1'b1;
				if (data_rx_ready_i)
					NS = 3'd0;
				else
					NS = 3'd2;
			end
		endcase
	end
	assign data_rx_rdata_o = data_rx_rdata_i;
endmodule
