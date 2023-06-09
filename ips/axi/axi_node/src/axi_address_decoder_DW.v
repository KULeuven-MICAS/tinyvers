module axi_address_decoder_DW (
	clk,
	rst_n,
	test_en_i,
	wvalid_i,
	wlast_i,
	wready_o,
	wvalid_o,
	wready_i,
	grant_FIFO_DEST_o,
	DEST_i,
	push_DEST_i,
	handle_error_i,
	wdata_error_completed_o
);
	parameter N_INIT_PORT = 4;
	parameter FIFO_DEPTH = 8;
	input wire clk;
	input wire rst_n;
	input wire test_en_i;
	input wire wvalid_i;
	input wire wlast_i;
	output reg wready_o;
	output reg [N_INIT_PORT - 1:0] wvalid_o;
	input wire [N_INIT_PORT - 1:0] wready_i;
	output wire grant_FIFO_DEST_o;
	input wire [N_INIT_PORT - 1:0] DEST_i;
	input wire push_DEST_i;
	input wire handle_error_i;
	output reg wdata_error_completed_o;
	wire valid_DEST;
	wire pop_from_DEST_FIFO;
	wire [N_INIT_PORT - 1:0] DEST_int;
	wire empty;
	wire full;
	fifo_v2 #(
		.FALL_THROUGH(1'b0),
		.DATA_WIDTH(N_INIT_PORT),
		.DEPTH(FIFO_DEPTH)
	) MASTER_ID_FIFO(
		.clk_i(clk),
		.rst_ni(rst_n),
		.testmode_i(test_en_i),
		.flush_i(1'b0),
		.alm_empty_o(),
		.alm_full_o(),
		.data_i(DEST_i),
		.push_i(push_DEST_i),
		.full_o(full),
		.data_o(DEST_int),
		.empty_o(empty),
		.pop_i(pop_from_DEST_FIFO)
	);
	assign grant_FIFO_DEST_o = ~full;
	assign valid_DEST = ~empty;
	assign pop_from_DEST_FIFO = ((wlast_i & wvalid_i) & wready_o) & valid_DEST;
	always @(*)
		if (handle_error_i) begin
			wready_o = 1'b1;
			wvalid_o = 1'sb0;
			wdata_error_completed_o = wlast_i & wvalid_i;
		end
		else begin
			wready_o = |(wready_i & DEST_int);
			wdata_error_completed_o = 1'b0;
			if (wvalid_i & valid_DEST)
				wvalid_o = {N_INIT_PORT {wvalid_i}} & DEST_int;
			else
				wvalid_o = 1'sb0;
		end
endmodule
