module prescaler (
	clk_i,
	rstn_i,
	ctrl_active_i,
	ctrl_update_i,
	ctrl_rst_i,
	cfg_presc_i,
	event_i,
	event_o
);
	input wire clk_i;
	input wire rstn_i;
	input wire ctrl_active_i;
	input wire ctrl_update_i;
	input wire ctrl_rst_i;
	input wire [7:0] cfg_presc_i;
	input wire event_i;
	output reg event_o;
	reg [7:0] r_presc;
	reg [7:0] r_counter;
	always @(posedge clk_i or negedge rstn_i) begin : proc_r_presc
		if (~rstn_i)
			r_presc <= 0;
		else if (ctrl_update_i)
			r_presc <= cfg_presc_i;
	end
	always @(posedge clk_i or negedge rstn_i) begin : proc_r_counter
		if (~rstn_i) begin
			r_counter <= 0;
			event_o <= 0;
		end
		else if (ctrl_rst_i) begin
			r_counter <= 0;
			event_o <= 0;
		end
		else if (ctrl_active_i) begin
			if (event_i) begin
				if (r_presc == 0)
					event_o <= 1'b1;
				else if (r_counter == r_presc) begin
					event_o <= 1'b1;
					r_counter <= 0;
				end
				else begin
					event_o <= 1'b0;
					r_counter <= r_counter + 1;
				end
			end
			else
				event_o <= 1'b0;
		end
		else begin
			r_counter <= 0;
			event_o <= 0;
		end
	end
endmodule
