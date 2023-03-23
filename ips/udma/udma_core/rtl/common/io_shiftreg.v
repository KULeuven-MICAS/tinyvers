module io_shiftreg (
	data_i,
	data_o,
	serial_i,
	serial_o,
	load_i,
	shift_i,
	lsbfirst_i,
	clk_i,
	rstn_i
);
	parameter DATA_WIDTH = 32;
	input wire [DATA_WIDTH - 1:0] data_i;
	output wire [DATA_WIDTH - 1:0] data_o;
	input wire serial_i;
	output wire serial_o;
	input wire load_i;
	input wire shift_i;
	input wire lsbfirst_i;
	input wire clk_i;
	input wire rstn_i;
	reg [DATA_WIDTH - 1:0] shift_reg;
	reg [DATA_WIDTH - 1:0] shift_reg_next;
	always @(*)
		if (load_i) begin
			if (shift_i) begin
				if (lsbfirst_i)
					shift_reg_next = {serial_i, data_i[DATA_WIDTH - 1:1]};
				else
					shift_reg_next = {data_i[DATA_WIDTH - 2:0], serial_i};
			end
			else
				shift_reg_next = data_i[DATA_WIDTH - 1:0];
		end
		else if (shift_i) begin
			if (lsbfirst_i)
				shift_reg_next = {serial_i, shift_reg[DATA_WIDTH - 1:1]};
			else
				shift_reg_next = {shift_reg[DATA_WIDTH - 2:0], serial_i};
		end
		else
			shift_reg_next = shift_reg;
	always @(posedge clk_i or negedge rstn_i)
		if (rstn_i == 1'b0)
			shift_reg <= 'h0;
		else
			shift_reg <= shift_reg_next;
	assign data_o = shift_reg;
	assign serial_o = (lsbfirst_i ? shift_reg[0] : shift_reg[DATA_WIDTH - 1]);
endmodule
