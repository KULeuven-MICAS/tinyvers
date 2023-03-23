module apb_interrupt_cntrl (
	clk_i,
	rst_ni,
	test_mode_i,
	event_fifo_valid_i,
	event_fifo_fulln_o,
	event_fifo_data_i,
	events_i,
	core_irq_id_o,
	core_irq_req_o,
	core_irq_ack_i,
	core_irq_sec_o,
	core_irq_id_i,
	core_secure_mode_i,
	core_clock_en_o,
	fetch_en_o,
	apb_slave
);
	parameter PER_ID_WIDTH = 5;
	parameter EVT_ID_WIDTH = 8;
	parameter ENA_SEC_IRQ = 1;
	input wire clk_i;
	input wire rst_ni;
	input wire test_mode_i;
	input wire event_fifo_valid_i;
	output wire event_fifo_fulln_o;
	input wire [EVT_ID_WIDTH - 1:0] event_fifo_data_i;
	input wire [31:0] events_i;
	output reg [4:0] core_irq_id_o;
	output wire core_irq_req_o;
	input wire core_irq_ack_i;
	output wire core_irq_sec_o;
	input wire [4:0] core_irq_id_i;
	input wire core_secure_mode_i;
	output wire core_clock_en_o;
	output wire fetch_en_o;
	output APB_BUS.Slave apb_slave;
	wire [31:0] s_events;
	reg [31:0] s_ack_next;
	reg [31:0] r_ack;
	reg [31:0] s_int_next;
	reg [31:0] r_int;
	reg [31:0] s_mask_next;
	reg [31:0] r_mask;
	reg [EVT_ID_WIDTH - 1:0] r_fifo_event;
	wire [EVT_ID_WIDTH - 1:0] s_event_fifo_data;
	wire s_event_fifo_valid;
	wire s_event_fifo_ready;
	wire s_is_int_clr_fifo;
	wire s_is_int_fifo;
	wire [3:0] s_apb_addr;
	wire s_is_apb_write;
	wire s_is_apb_read;
	wire s_is_mask;
	wire s_is_mask_set;
	wire s_is_mask_clr;
	wire s_is_int;
	wire s_is_int_set;
	wire s_is_int_clr;
	wire s_is_ack;
	wire s_is_ack_set;
	wire s_is_ack_clr;
	wire s_is_fifo;
	wire s_is_event;
	assign core_clock_en_o = 1'b1;
	assign fetch_en_o = 1'b1;
	assign s_events = {events_i[31:27], s_event_fifo_valid, events_i[25:0]};
	assign s_is_apb_write = (apb_slave.psel & apb_slave.penable) & apb_slave.pwrite;
	assign s_is_apb_read = (apb_slave.psel & apb_slave.penable) & ~apb_slave.pwrite;
	assign s_is_int_clr_fifo = ((s_is_int_clr & apb_slave.psel) & apb_slave.penable) & (apb_slave.pwdata[26] == 1'b1);
	assign s_is_int_fifo = ((s_is_int & apb_slave.psel) & apb_slave.penable) & (apb_slave.pwdata[26] == 1'b0);
	assign s_event_fifo_ready = (core_irq_ack_i & (core_irq_id_i == 5'd26)) | (s_is_apb_write & (s_is_int_clr_fifo | s_is_int_fifo));
	assign s_apb_addr = apb_slave.paddr[5:2];
	assign s_is_mask = s_apb_addr == 4'b0000;
	assign s_is_mask_set = s_apb_addr == 4'b0001;
	assign s_is_mask_clr = s_apb_addr == 4'b0010;
	assign s_is_int = s_apb_addr == 4'b0011;
	assign s_is_int_set = s_apb_addr == 4'b0100;
	assign s_is_int_clr = s_apb_addr == 4'b0101;
	assign s_is_ack = s_apb_addr == 4'b0110;
	assign s_is_ack_set = s_apb_addr == 4'b0111;
	assign s_is_ack_clr = s_apb_addr == 4'b1000;
	assign s_is_fifo = s_apb_addr == 4'b1001;
	assign s_is_event = |s_events;
	assign core_irq_req_o = |(r_int & r_mask);
	generic_fifo #(
		.DATA_WIDTH(8),
		.DATA_DEPTH(4)
	) i_event_fifo(
		.clk(clk_i),
		.rst_n(rst_ni),
		.data_i(event_fifo_data_i),
		.valid_i(event_fifo_valid_i),
		.grant_o(event_fifo_fulln_o),
		.data_o(s_event_fifo_data),
		.valid_o(s_event_fifo_valid),
		.grant_i(s_event_fifo_ready),
		.test_mode_i(test_mode_i)
	);
	always @(*) begin : proc_mask
		s_mask_next = r_mask;
		if (s_is_apb_write)
			if (s_is_mask)
				s_mask_next = apb_slave.pwdata;
			else if (s_is_mask_set)
				s_mask_next = r_mask | apb_slave.pwdata;
			else if (s_is_mask_clr)
				s_mask_next = r_mask & ~apb_slave.pwdata;
	end
	always @(*) begin : proc_id
		core_irq_id_o = 1'sb0;
		begin : sv2v_autoblock_1
			reg signed [31:0] i;
			for (i = 0; i < 32; i = i + 1)
				if (r_int[i] && r_mask[i])
					core_irq_id_o = i;
		end
	end
	always @(*) begin : proc_int
		s_int_next = r_int;
		begin : sv2v_autoblock_2
			reg signed [31:0] i;
			for (i = 0; i < 32; i = i + 1)
				if (core_irq_ack_i && (core_irq_id_i == i))
					s_int_next[i] = 1'b0;
				else if (s_is_apb_write) begin
					if (s_is_int)
						s_int_next[i] = apb_slave.pwdata[i];
					else if (s_is_int_set)
						s_int_next[i] = (r_int[i] | s_events[i]) | apb_slave.pwdata[i];
					else if (s_is_int_clr)
						s_int_next[i] = (r_int[i] | s_events[i]) & ~apb_slave.pwdata[i];
					else if (s_events[i])
						s_int_next[i] = 1'b1;
				end
				else if (s_events[i])
					s_int_next[i] = 1'b1;
		end
	end
	always @(*) begin : proc_ack
		s_ack_next = r_ack;
		begin : sv2v_autoblock_3
			reg signed [31:0] i;
			for (i = 0; i < 32; i = i + 1)
				if (core_irq_ack_i && (core_irq_id_i == i))
					s_ack_next[i] = 1'b1;
				else if (s_is_apb_write)
					if (s_is_ack)
						s_ack_next[i] = apb_slave.pwdata[i];
					else if (s_is_ack_set)
						s_ack_next[i] = r_ack[i] | apb_slave.pwdata[i];
					else if (s_is_ack_clr)
						s_ack_next[i] = r_ack[i] & ~apb_slave.pwdata[i];
		end
	end
	always @(posedge clk_i or negedge rst_ni)
		if (~rst_ni) begin
			r_mask <= 1'sb0;
			r_int <= 1'sb0;
			r_ack <= 1'sb0;
			r_fifo_event <= 1'sb0;
		end
		else begin
			if ((s_is_mask_clr || s_is_mask_set) || s_is_mask)
				r_mask <= s_mask_next;
			if (((((s_is_int_clr || s_is_int_set) || s_is_int) || s_is_event) || core_irq_ack_i) || s_is_event)
				r_int <= s_int_next;
			if (((s_is_ack_clr || s_is_ack_set) || s_is_ack) || core_irq_ack_i)
				r_ack <= s_ack_next;
			if (s_event_fifo_valid && s_event_fifo_ready)
				r_fifo_event <= s_event_fifo_data;
		end
	always @(*) begin
		apb_slave.prdata = 1'sb0;
		if (s_is_apb_read)
			if (s_is_int)
				apb_slave.prdata = r_int;
			else if (s_is_ack)
				apb_slave.prdata = r_ack;
			else if (s_is_mask)
				apb_slave.prdata = r_mask;
			else if (s_is_fifo)
				apb_slave.prdata[EVT_ID_WIDTH - 1:0] = r_fifo_event;
	end
	assign apb_slave.pready = 1'b1;
	assign apb_slave.pslverr = 1'b0;
endmodule
