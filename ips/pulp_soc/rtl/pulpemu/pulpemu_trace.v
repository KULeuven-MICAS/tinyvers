module pulpemu_trace (
	ref_clk_i,
	rst_ni,
	fetch_en_i,
	instr_trace_cycles,
	instr_trace_instr,
	instr_trace_pc,
	instr_trace_valid,
	trace_flushed,
	trace_wait,
	cg_clken,
	trace_master_clk,
	trace_master_addr,
	trace_master_din,
	trace_master_dout,
	trace_master_we
);
	parameter NB_CORES = 4;
	parameter TRACE_BUFFER_DIM = 1024;
	input wire ref_clk_i;
	input wire rst_ni;
	input wire fetch_en_i;
	input wire [(NB_CORES * 64) - 1:0] instr_trace_cycles;
	input wire [(NB_CORES * 32) - 1:0] instr_trace_instr;
	input wire [(NB_CORES * 32) - 1:0] instr_trace_pc;
	input wire [NB_CORES - 1:0] instr_trace_valid;
	input wire trace_flushed;
	output wire trace_wait;
	input wire cg_clken;
	input wire trace_master_clk;
	input wire [31:0] trace_master_addr;
	input wire [31:0] trace_master_din;
	output wire [31:0] trace_master_dout;
	input wire trace_master_we;
	localparam TRACE_THRESHOLD = 1000;
	localparam TRACE_ADDR_HIGH = $clog2(TRACE_BUFFER_DIM);
	reg [15:0] counter;
	wire [15:0] gen_add;
	reg trace_wait_r;
	wire fifo_valid_o;
	wire [((NB_CORES * 4) * 32) - 1:0] fifo_data_i;
	wire [((NB_CORES * 4) * 32) - 1:0] fifo_data_o;
	reg [(NB_CORES * 64) - 1:0] instr_trace_cycles_r;
	reg [(NB_CORES * 32) - 1:0] instr_trace_instr_r;
	reg [(NB_CORES * 32) - 1:0] instr_trace_pc_r;
	reg [NB_CORES - 1:0] instr_trace_valid_r;
	wire [31:0] trace_slave_addr;
	wire [511:0] trace_slave_din;
	wire [31:0] trace_slave_dout;
	wire trace_slave_we;
	wire trace_master_int_clk;
	wire [$clog2(TRACE_BUFFER_DIM) - 1:0] trace_master_int_addr;
	wire [511:0] trace_master_int_din;
	wire [511:0] trace_master_int_dout;
	wire trace_master_int_we;
	assign trace_slave_addr = gen_add;
	assign trace_slave_we = fifo_valid_o;
	genvar i;
	generate
		for (i = 0; i < NB_CORES; i = i + 1) begin : gen_fifo_data
			assign fifo_data_i[(i * 4) * 32+:32] = instr_trace_cycles_r[(i * 64) + 31-:32];
			assign fifo_data_i[(((i * 4) + 1) * 32) + 27-:28] = instr_trace_cycles_r[(i * 64) + 59-:28];
			assign fifo_data_i[(((i * 4) + 1) * 32) + 31-:4] = instr_trace_valid_r;
			assign fifo_data_i[((i * 4) + 2) * 32+:32] = instr_trace_instr_r[i * 32+:32];
			assign fifo_data_i[((i * 4) + 3) * 32+:32] = instr_trace_pc_r[i * 32+:32];
			assign trace_slave_din[((i * 32) * 4) + 31:((i * 32) * 4) + 0] = fifo_data_o[(i * 4) * 32+:32];
			assign trace_slave_din[((i * 32) * 4) + 63:((i * 32) * 4) + 32] = fifo_data_o[((i * 4) + 1) * 32+:32];
			assign trace_slave_din[((i * 32) * 4) + 95:((i * 32) * 4) + 64] = fifo_data_o[((i * 4) + 2) * 32+:32];
			assign trace_slave_din[((i * 32) * 4) + 127:((i * 32) * 4) + 96] = fifo_data_o[((i * 4) + 3) * 32+:32];
		end
	endgenerate
	generic_fifo #(
		.DATA_WIDTH(((32 * NB_CORES) * 4) + 16),
		.DATA_DEPTH(4)
	) fifo_i(
		.clk(ref_clk_i),
		.rst_n(rst_ni),
		.data_i({fifo_data_i, counter}),
		.valid_i(|instr_trace_valid_r),
		.grant_o(),
		.data_o({fifo_data_o, gen_add}),
		.valid_o(fifo_valid_o),
		.grant_i(~trace_wait_r),
		.test_mode_i(1'b0)
	);
	always @(posedge ref_clk_i or negedge rst_ni)
		if (rst_ni == 1'b0)
			trace_wait_r = 1'b0;
		else if (trace_flushed == 1'b1)
			trace_wait_r = 1'b0;
		else if (counter >= TRACE_THRESHOLD)
			trace_wait_r = 1'b1;
	assign trace_wait = trace_wait_r;
	always @(posedge ref_clk_i or negedge rst_ni)
		if (rst_ni == 1'b0)
			counter = 16'h0000;
		else if (fetch_en_i == 1'b0)
			counter = 16'h0000;
		else if (trace_flushed == 1'b1)
			counter = 16'h0000;
		else if ((cg_clken == 1'b1) && (|instr_trace_valid_r == 1'b1))
			counter = counter + 16'h0001;
	always @(posedge ref_clk_i or negedge rst_ni)
		if (rst_ni == 1'b0) begin
			instr_trace_cycles_r = 0;
			instr_trace_instr_r = 0;
			instr_trace_pc_r = 0;
			instr_trace_valid_r = 0;
		end
		else begin
			instr_trace_cycles_r = instr_trace_cycles;
			instr_trace_instr_r = instr_trace_instr;
			instr_trace_pc_r = instr_trace_pc;
			instr_trace_valid_r = instr_trace_valid;
		end
	xilinx_trace_mem xilinx_trace_mem_i(
		.clka(ref_clk_i),
		.wea(trace_slave_we),
		.addra(trace_slave_addr),
		.dina(trace_slave_din),
		.douta(trace_slave_dout),
		.clkb(trace_master_clk),
		.web(trace_master_int_we),
		.addrb(trace_master_int_addr),
		.dinb(trace_master_int_din),
		.doutb(trace_master_int_dout)
	);
	assign trace_master_int_addr = trace_master_addr[$clog2(TRACE_BUFFER_DIM) + 3:4];
	assign trace_master_dout = (trace_master_addr[5:2] == 4'h0 ? trace_master_int_dout[31:0] : (trace_master_addr[5:2] == 4'h1 ? trace_master_int_dout[63:32] : (trace_master_addr[5:2] == 4'h2 ? trace_master_int_dout[95:64] : (trace_master_addr[5:2] == 4'h3 ? trace_master_int_dout[127:96] : (trace_master_addr[5:2] == 4'h4 ? trace_master_int_dout[159:128] : (trace_master_addr[5:2] == 4'h5 ? trace_master_int_dout[191:160] : (trace_master_addr[5:2] == 4'h6 ? trace_master_int_dout[223:192] : (trace_master_addr[5:2] == 4'h7 ? trace_master_int_dout[255:224] : (trace_master_addr[5:2] == 4'h8 ? trace_master_int_dout[287:256] : (trace_master_addr[5:2] == 4'h9 ? trace_master_int_dout[319:288] : (trace_master_addr[5:2] == 4'ha ? trace_master_int_dout[351:320] : (trace_master_addr[5:2] == 4'hb ? trace_master_int_dout[383:352] : (trace_master_addr[5:2] == 4'hc ? trace_master_int_dout[415:384] : (trace_master_addr[5:2] == 4'hd ? trace_master_int_dout[447:416] : (trace_master_addr[5:2] == 4'he ? trace_master_int_dout[479:448] : trace_master_int_dout[511:480])))))))))))))));
	assign trace_master_int_we = trace_master_we;
	generate
		for (i = 0; i < 16; i = i + 1) begin : genblk2
			assign trace_master_int_din[((i + 1) * 32) - 1:i * 32] = (trace_master_addr[5:2] == i ? trace_master_din : trace_master_int_dout[((i + 1) * 32) - 1:i * 32]);
		end
	endgenerate
endmodule
