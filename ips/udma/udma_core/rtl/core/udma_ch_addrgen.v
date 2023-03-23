module udma_ch_addrgen (
	clk_i,
	rstn_i,
	cfg_startaddr_i,
	cfg_size_i,
	cfg_continuous_i,
	cfg_en_i,
	cfg_stream_i,
	cfg_stream_id_i,
	cfg_clr_i,
	int_not_stall_i,
	int_datasize_i,
	int_ch_curr_addr_o,
	int_ch_bytes_left_o,
	int_ch_pending_o,
	int_ch_curr_bytes_o,
	int_ch_grant_i,
	int_ch_en_o,
	int_ch_en_prev_o,
	int_ch_events_o,
	int_ch_sot_o,
	int_stream_o,
	int_stream_id_o
);
	parameter L2_AWIDTH_NOAL = 18;
	parameter TRANS_SIZE = 16;
	parameter STREAM_ID_WIDTH = 3;
	input wire clk_i;
	input wire rstn_i;
	input wire [L2_AWIDTH_NOAL - 1:0] cfg_startaddr_i;
	input wire [TRANS_SIZE - 1:0] cfg_size_i;
	input wire cfg_continuous_i;
	input wire cfg_en_i;
	input wire [1:0] cfg_stream_i;
	input wire [STREAM_ID_WIDTH - 1:0] cfg_stream_id_i;
	input wire cfg_clr_i;
	input wire int_not_stall_i;
	input wire [1:0] int_datasize_i;
	output wire [L2_AWIDTH_NOAL - 1:0] int_ch_curr_addr_o;
	output wire [TRANS_SIZE - 1:0] int_ch_bytes_left_o;
	output wire int_ch_pending_o;
	output reg [1:0] int_ch_curr_bytes_o;
	input wire int_ch_grant_i;
	output wire int_ch_en_o;
	output wire int_ch_en_prev_o;
	output wire int_ch_events_o;
	output wire int_ch_sot_o;
	output wire [1:0] int_stream_o;
	output wire [STREAM_ID_WIDTH - 1:0] int_stream_id_o;
	reg [L2_AWIDTH_NOAL - 1:0] r_addresses;
	reg [TRANS_SIZE - 1:0] r_counters;
	reg [1:0] r_stream;
	reg [STREAM_ID_WIDTH - 1:0] r_stream_id;
	reg r_en;
	reg r_event;
	reg r_ch_en;
	reg [L2_AWIDTH_NOAL - 1:0] s_addresses;
	reg [TRANS_SIZE - 1:0] s_counters;
	reg [1:0] s_stream;
	reg [STREAM_ID_WIDTH - 1:0] s_stream_id;
	reg s_en;
	reg s_event;
	reg s_ch_en;
	reg r_sot;
	reg s_sot;
	wire s_compare;
	reg r_pending_en;
	reg s_pending_en;
	reg [TRANS_SIZE - 1:0] s_datasize_toadd;
	wire s_continuous;
	assign int_ch_en_o = r_en;
	assign int_ch_en_prev_o = s_en;
	assign int_ch_events_o = r_event;
	assign int_ch_sot_o = r_sot;
	assign int_ch_pending_o = r_pending_en;
	assign int_ch_curr_addr_o = r_addresses;
	assign int_ch_bytes_left_o = r_counters;
	assign int_stream_o = r_stream;
	assign int_stream_id_o = r_stream_id;
	assign s_compare = r_counters <= s_datasize_toadd;
	always @(*) begin : proc_curr_bytes
		case (int_datasize_i)
			2'b00: int_ch_curr_bytes_o = 'h0;
			2'b01:
				if (s_compare && (r_counters[1:0] == 2'h1))
					int_ch_curr_bytes_o = 'h0;
				else
					int_ch_curr_bytes_o = 'h1;
			2'b10:
				if (s_compare && (r_counters[1:0] == 2'h1))
					int_ch_curr_bytes_o = 'h0;
				else if (s_compare && (r_counters[1:0] == 2'h2))
					int_ch_curr_bytes_o = 'h1;
				else if (s_compare && (r_counters[1:0] == 2'h3))
					int_ch_curr_bytes_o = 'h2;
				else
					int_ch_curr_bytes_o = 'h3;
			default: int_ch_curr_bytes_o = 'h0;
		endcase
	end
	always @(*) begin : mux_datasize
		case (int_datasize_i)
			2'b00: s_datasize_toadd = 'h1;
			2'b01: s_datasize_toadd = 'h2;
			2'b10: s_datasize_toadd = 'h4;
			default: s_datasize_toadd = 1'sb0;
		endcase
	end
	always @(*) begin : proc_pending_en
		s_pending_en = r_pending_en;
		if ((cfg_en_i && (r_ch_en || r_en)) && (!s_compare || (s_compare && (!int_not_stall_i || ~int_ch_grant_i))))
			s_pending_en = 1'b1;
		else if (((r_en && int_ch_grant_i) && int_not_stall_i) && (r_counters <= s_datasize_toadd))
			s_pending_en = 1'b0;
	end
	always @(*) begin : proc_next_val
		s_counters = r_counters;
		s_addresses = r_addresses;
		s_en = r_en;
		s_ch_en = r_ch_en;
		s_event = r_event;
		s_stream = r_stream;
		s_stream_id = r_stream_id;
		s_sot = r_sot;
		if (cfg_en_i && !r_en) begin
			s_counters = cfg_size_i;
			s_addresses = cfg_startaddr_i;
			s_en = 1'b1;
			s_ch_en = 1'b0;
			s_event = 1'b0;
			s_sot = 1'b1;
			s_stream = cfg_stream_i;
			s_stream_id = cfg_stream_id_i;
		end
		else if (cfg_clr_i) begin
			s_counters = 1'sb0;
			s_addresses = 1'sb0;
			s_en = 1'b0;
			s_ch_en = 1'b0;
			s_event = 1'b0;
			s_sot = 1'b0;
			s_stream = 1'b0;
		end
		else if ((int_not_stall_i && r_en) && int_ch_grant_i) begin
			if (s_compare) begin
				s_event = 1'b1;
				if ((!cfg_continuous_i && !r_pending_en) && !cfg_en_i) begin
					s_en = 1'b0;
					s_ch_en = 1'b0;
					s_counters = 1'sb0;
					s_addresses = 1'sb0;
					s_stream = 1'b0;
					s_sot = 1'b0;
				end
				else begin
					s_counters = cfg_size_i;
					s_addresses = cfg_startaddr_i;
					s_stream = cfg_stream_i;
					s_stream_id = cfg_stream_id_i;
					s_en = 1'b1;
					s_ch_en = 1'b1;
					s_sot = 1'b1;
				end
			end
			else begin
				s_event = 1'b0;
				s_sot = 1'b0;
				s_ch_en = 1'b1;
				s_counters = r_counters - s_datasize_toadd;
				s_addresses = r_addresses + s_datasize_toadd;
			end
		end
		else begin
			s_event = 1'b0;
			s_sot = 1'b0;
		end
	end
	always @(posedge clk_i or negedge rstn_i) begin : ff_addr
		if (~rstn_i) begin
			r_addresses <= 1'sb0;
			r_counters <= 1'sb0;
			r_en <= 1'b0;
			r_ch_en <= 1'b0;
			r_event <= 1'b0;
			r_pending_en <= 1'b0;
			r_stream <= 1'b0;
			r_stream_id <= 'h0;
			r_sot <= 1'b0;
		end
		else begin
			r_event <= s_event;
			r_sot <= s_sot;
			r_pending_en <= s_pending_en;
			if (((cfg_en_i && !r_en) || cfg_clr_i) || ((cfg_en_i && s_compare) && int_not_stall_i)) begin
				r_counters <= s_counters;
				r_addresses <= s_addresses;
				r_en <= s_en;
				r_ch_en <= s_ch_en;
				r_stream <= s_stream;
				r_stream_id <= s_stream_id;
			end
			else if ((int_not_stall_i && r_en) && int_ch_grant_i)
				if (s_compare) begin
					r_counters <= s_counters;
					r_addresses <= s_addresses;
					r_stream <= s_stream;
					r_stream_id <= s_stream_id;
					if (!cfg_continuous_i && !r_pending_en) begin
						r_en <= s_en;
						r_ch_en <= s_ch_en;
					end
				end
				else begin
					r_ch_en <= s_ch_en;
					r_counters <= s_counters;
					r_addresses <= s_addresses;
				end
		end
	end
endmodule
