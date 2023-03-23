module dc_data_buffer (
	clk,
	rstn,
	write_enable,
	write_pointer,
	write_data,
	read_pointer,
	read_data
);
	parameter DATA_WIDTH = 32;
	parameter BUFFER_DEPTH = 8;
	input wire clk;
	input wire rstn;
	input wire write_enable;
	input wire [BUFFER_DEPTH - 1:0] write_pointer;
	input wire [DATA_WIDTH - 1:0] write_data;
	input wire [BUFFER_DEPTH - 1:0] read_pointer;
	output wire [DATA_WIDTH - 1:0] read_data;
	reg [(BUFFER_DEPTH * DATA_WIDTH) - 1:0] data;
	wire [$clog2(BUFFER_DEPTH) - 1:0] write_pointer_bin;
	wire [$clog2(BUFFER_DEPTH) - 1:0] read_pointer_bin;
	onehot_to_bin #(.ONEHOT_WIDTH(BUFFER_DEPTH)) WPRT_OH_BIN(
		.onehot(write_pointer),
		.bin(write_pointer_bin)
	);
	onehot_to_bin #(.ONEHOT_WIDTH(BUFFER_DEPTH)) RPRT_OH_BIN(
		.onehot(read_pointer),
		.bin(read_pointer_bin)
	);
	always @(posedge clk or negedge rstn) begin : read_write_data
		if (rstn == 1'b0)
			data <= 1'sb0;
		else if (write_enable)
			data[write_pointer_bin * DATA_WIDTH+:DATA_WIDTH] <= write_data;
	end
	assign read_data = data[read_pointer_bin * DATA_WIDTH+:DATA_WIDTH];
endmodule
