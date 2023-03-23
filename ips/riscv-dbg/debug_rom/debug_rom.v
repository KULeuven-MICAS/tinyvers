module debug_rom (
	clk_i,
	req_i,
	addr_i,
	rdata_o
);
	input wire clk_i;
	input wire req_i;
	input wire [63:0] addr_i;
	output wire [63:0] rdata_o;
	localparam signed [31:0] RomSize = 19;
	reg [1215:0] mem = 1216'h7b2000737b3025737b20247310852423f1402473a85ff06f7b3025737b20247310052223001000737b3025731005262300c5151300c55513000005177b351073fd5ff06ffa041ce3002474134004440300a40433f140247302041c63001474134004440300a4043310852023f140247300c5151300c55513000005177b3510737b2410730ff0000f04c0006f07c0006f00c0006f;
	reg [4:0] addr_q;
	always @(posedge clk_i)
		if (req_i)
			addr_q <= addr_i[7:3];
	assign rdata_o = (addr_q < RomSize ? mem[addr_q * 64+:64] : {64 {1'sb0}});
endmodule
