module sram (
	clk_i,
	req_i,
	we_i,
	addr_i,
	wdata_i,
	be_i,
	rdata_o
);
	parameter [31:0] DATA_WIDTH = 64;
	parameter [31:0] NUM_WORDS = 1024;
	input wire clk_i;
	input wire req_i;
	input wire we_i;
	input wire [$clog2(NUM_WORDS) - 1:0] addr_i;
	input wire [DATA_WIDTH - 1:0] wdata_i;
	input wire [DATA_WIDTH - 1:0] be_i;
	output wire [DATA_WIDTH - 1:0] rdata_o;
	localparam ADDR_WIDTH = $clog2(NUM_WORDS);
	reg [DATA_WIDTH - 1:0] ram [NUM_WORDS - 1:0];
	reg [ADDR_WIDTH - 1:0] raddr_q;
	always @(posedge clk_i)
		if (req_i)
			if (!we_i)
				raddr_q <= addr_i;
			else begin : sv2v_autoblock_1
				reg signed [31:0] i;
				for (i = 0; i < DATA_WIDTH; i = i + 1)
					if (be_i[i])
						ram[addr_i][i] <= wdata_i[i];
			end
	assign rdata_o = ram[raddr_q];
endmodule
