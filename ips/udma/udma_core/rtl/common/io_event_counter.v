module io_event_counter (
	clk_i,
	rstn_i,
	event_i,
	counter_rst_i,
	counter_target_i,
	counter_value_o,
	counter_trig_o
);
	parameter COUNTER_WIDTH = 6;
	input wire clk_i;
	input wire rstn_i;
	input wire event_i;
	input wire counter_rst_i;
	input wire [COUNTER_WIDTH - 1:0] counter_target_i;
	output wire [COUNTER_WIDTH - 1:0] counter_value_o;
	output wire counter_trig_o;
	reg [COUNTER_WIDTH - 1:0] counter;
	reg [COUNTER_WIDTH - 1:0] counter_next;
	reg trigger;
	reg trigger_old;
	always @(*)
		if (counter_rst_i)
			counter_next = 'h0;
		else if (event_i) begin
			if (counter == counter_target_i)
				counter_next = 'h1;
			else
				counter_next = counter + 1;
		end
		else
			counter_next = counter;
	always @(*)
		if (counter == counter_target_i)
			trigger = 1'b1;
		else
			trigger = 1'b0;
	always @(posedge clk_i or negedge rstn_i)
		if (rstn_i == 1'b0) begin
			trigger_old <= 1'b0;
			counter <= 'h0;
		end
		else begin
			trigger_old <= trigger;
			counter <= counter_next;
		end
	assign counter_value_o = counter;
	assign counter_trig_o = ~trigger_old & trigger;
endmodule
