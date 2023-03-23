module onehot_to_bin (
	onehot,
	bin
);
	parameter [31:0] ONEHOT_WIDTH = 16;
	parameter [31:0] BIN_WIDTH = $clog2(ONEHOT_WIDTH);
	input wire [ONEHOT_WIDTH - 1:0] onehot;
	output wire [BIN_WIDTH - 1:0] bin;
	genvar j;
	generate
		for (j = 0; j < BIN_WIDTH; j = j + 1) begin : jl
			wire [ONEHOT_WIDTH - 1:0] tmp_mask;
			genvar i;
			for (i = 0; i < ONEHOT_WIDTH; i = i + 1) begin : il
				wire [BIN_WIDTH - 1:0] tmp_i;
				assign tmp_i = i;
				assign tmp_mask[i] = tmp_i[j];
			end
			assign bin[j] = |(tmp_mask & onehot);
		end
	endgenerate
endmodule
