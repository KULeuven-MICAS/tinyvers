module riscv_register_file (
	clk,
	rst_n,
	test_en_i,
	raddr_a_i,
	rdata_a_o,
	raddr_b_i,
	rdata_b_o,
	raddr_c_i,
	rdata_c_o,
	waddr_a_i,
	wdata_a_i,
	we_a_i,
	waddr_b_i,
	wdata_b_i,
	we_b_i
);
	parameter ADDR_WIDTH = 5;
	parameter DATA_WIDTH = 32;
	parameter FPU = 0;
	parameter Zfinx = 0;
	input wire clk;
	input wire rst_n;
	input wire test_en_i;
	input wire [ADDR_WIDTH - 1:0] raddr_a_i;
	output wire [DATA_WIDTH - 1:0] rdata_a_o;
	input wire [ADDR_WIDTH - 1:0] raddr_b_i;
	output wire [DATA_WIDTH - 1:0] rdata_b_o;
	input wire [ADDR_WIDTH - 1:0] raddr_c_i;
	output wire [DATA_WIDTH - 1:0] rdata_c_o;
	input wire [ADDR_WIDTH - 1:0] waddr_a_i;
	input wire [DATA_WIDTH - 1:0] wdata_a_i;
	input wire we_a_i;
	input wire [ADDR_WIDTH - 1:0] waddr_b_i;
	input wire [DATA_WIDTH - 1:0] wdata_b_i;
	input wire we_b_i;
	localparam NUM_WORDS = 2 ** (ADDR_WIDTH - 1);
	localparam NUM_FP_WORDS = 2 ** (ADDR_WIDTH - 1);
	localparam NUM_TOT_WORDS = (FPU ? (Zfinx ? NUM_WORDS : NUM_WORDS + NUM_FP_WORDS) : NUM_WORDS);
	reg [(NUM_WORDS * DATA_WIDTH) - 1:0] mem;
	reg [(NUM_FP_WORDS * DATA_WIDTH) - 1:0] mem_fp;
	wire [ADDR_WIDTH - 1:0] waddr_a;
	wire [ADDR_WIDTH - 1:0] waddr_b;
	reg [NUM_TOT_WORDS - 1:0] we_a_dec;
	reg [NUM_TOT_WORDS - 1:0] we_b_dec;
	generate
		if ((FPU == 1) && (Zfinx == 0)) begin : genblk1
			assign rdata_a_o = (raddr_a_i[5] ? mem_fp[raddr_a_i[4:0] * DATA_WIDTH+:DATA_WIDTH] : mem[raddr_a_i[4:0] * DATA_WIDTH+:DATA_WIDTH]);
			assign rdata_b_o = (raddr_b_i[5] ? mem_fp[raddr_b_i[4:0] * DATA_WIDTH+:DATA_WIDTH] : mem[raddr_b_i[4:0] * DATA_WIDTH+:DATA_WIDTH]);
			assign rdata_c_o = (raddr_c_i[5] ? mem_fp[raddr_c_i[4:0] * DATA_WIDTH+:DATA_WIDTH] : mem[raddr_c_i[4:0] * DATA_WIDTH+:DATA_WIDTH]);
		end
		else begin : genblk1
			assign rdata_a_o = mem[raddr_a_i[4:0] * DATA_WIDTH+:DATA_WIDTH];
			assign rdata_b_o = mem[raddr_b_i[4:0] * DATA_WIDTH+:DATA_WIDTH];
			assign rdata_c_o = mem[raddr_c_i[4:0] * DATA_WIDTH+:DATA_WIDTH];
		end
	endgenerate
	assign waddr_a = waddr_a_i;
	assign waddr_b = waddr_b_i;
	always @(*) begin : we_a_decoder
		begin : sv2v_autoblock_1
			reg signed [31:0] i;
			for (i = 0; i < NUM_TOT_WORDS; i = i + 1)
				if (waddr_a == i)
					we_a_dec[i] = we_a_i;
				else
					we_a_dec[i] = 1'b0;
		end
	end
	always @(*) begin : we_b_decoder
		begin : sv2v_autoblock_2
			reg signed [31:0] i;
			for (i = 0; i < NUM_TOT_WORDS; i = i + 1)
				if (waddr_b == i)
					we_b_dec[i] = we_b_i;
				else
					we_b_dec[i] = 1'b0;
		end
	end
	genvar i;
	genvar l;
	always @(posedge clk or negedge rst_n)
		if (~rst_n)
			mem[0+:DATA_WIDTH] <= 32'b00000000000000000000000000000000;
		else
			mem[0+:DATA_WIDTH] <= 32'b00000000000000000000000000000000;
	generate
		for (i = 1; i < NUM_WORDS; i = i + 1) begin : rf_gen
			always @(posedge clk or negedge rst_n) begin : register_write_behavioral
				if (rst_n == 1'b0)
					mem[i * DATA_WIDTH+:DATA_WIDTH] <= 32'b00000000000000000000000000000000;
				else if (we_b_dec[i] == 1'b1)
					mem[i * DATA_WIDTH+:DATA_WIDTH] <= wdata_b_i;
				else if (we_a_dec[i] == 1'b1)
					mem[i * DATA_WIDTH+:DATA_WIDTH] <= wdata_a_i;
			end
		end
		if (FPU == 1) begin : genblk3
			for (l = 0; l < NUM_FP_WORDS; l = l + 1) begin : genblk1
				always @(posedge clk or negedge rst_n) begin : fp_regs
					if (rst_n == 1'b0)
						mem_fp[l * DATA_WIDTH+:DATA_WIDTH] <= 1'sb0;
					else if (we_b_dec[l + NUM_WORDS] == 1'b1)
						mem_fp[l * DATA_WIDTH+:DATA_WIDTH] <= wdata_b_i;
					else if (we_a_dec[l + NUM_WORDS] == 1'b1)
						mem_fp[l * DATA_WIDTH+:DATA_WIDTH] <= wdata_a_i;
				end
			end
		end
	endgenerate
endmodule
