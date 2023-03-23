module hwpe_ctrl_regfile (
	clk_i,
	rst_ni,
	clear_i,
	scan_en_in,
	regfile_in_i,
	regfile_out_o,
	flags_i,
	reg_file
);
	localparam [31:0] hwpe_ctrl_package_REGFILE_N_CONTEXT = 2;
	parameter [31:0] N_CONTEXT = hwpe_ctrl_package_REGFILE_N_CONTEXT;
	parameter [31:0] ID_WIDTH = 16;
	parameter [31:0] N_IO_REGS = 2;
	parameter [31:0] N_GENERIC_REGS = 0;
	input wire clk_i;
	input wire rst_ni;
	input wire clear_i;
	input wire scan_en_in;
	input wire [101:0] regfile_in_i;
	output wire [31:0] regfile_out_o;
	input wire [10:0] flags_i;
	localparam [31:0] hwpe_ctrl_package_REGFILE_N_MAX_GENERIC_REGS = 8;
	localparam [31:0] hwpe_ctrl_package_REGFILE_N_MAX_IO_REGS = 48;
	output wire [1791:0] reg_file;
	localparam signed [31:0] RESP_ANOTHER_PE_OFFLOADING = -2;
	localparam signed [31:0] RESP_ALL_CXT_BUSY = -1;
	localparam [31:0] LOG_CONTEXT = $clog2(N_CONTEXT);
	localparam [31:0] hwpe_ctrl_package_REGFILE_N_REGISTERS = 64;
	localparam [31:0] N_REGISTERS = hwpe_ctrl_package_REGFILE_N_REGISTERS;
	localparam [31:0] hwpe_ctrl_package_REGFILE_N_MANDATORY_REGS = 7;
	localparam [31:0] N_MANDATORY_REGS = hwpe_ctrl_package_REGFILE_N_MANDATORY_REGS;
	localparam [31:0] hwpe_ctrl_package_REGFILE_N_RESERVED_REGS = ((hwpe_ctrl_package_REGFILE_N_REGISTERS - hwpe_ctrl_package_REGFILE_N_MANDATORY_REGS) - hwpe_ctrl_package_REGFILE_N_MAX_GENERIC_REGS) - hwpe_ctrl_package_REGFILE_N_MAX_IO_REGS;
	localparam [31:0] N_RESERVED_REGS = hwpe_ctrl_package_REGFILE_N_RESERVED_REGS;
	localparam [31:0] N_MAX_IO_REGS = hwpe_ctrl_package_REGFILE_N_MAX_IO_REGS;
	localparam [31:0] N_MAX_GENERIC_REGS = hwpe_ctrl_package_REGFILE_N_MAX_GENERIC_REGS;
	localparam [31:0] LOG_REGS = 6;
	localparam [31:0] LOG_REGS_MC = LOG_REGS + LOG_CONTEXT;
	localparam [31:0] SCM_ADDR_WIDTH = $clog2(((N_CONTEXT * N_IO_REGS) + N_GENERIC_REGS) + 5);
	localparam [31:0] N_SCM_REGISTERS = 2 ** SCM_ADDR_WIDTH;
	wire [((63 >= ((32'd7 + N_RESERVED_REGS) + 32'd8) ? (N_CONTEXT * (64 - ((32'd7 + N_RESERVED_REGS) + 32'd8))) + ((32'd7 + N_RESERVED_REGS) + 7) : (N_CONTEXT * ((32'd7 + N_RESERVED_REGS) - 54)) + 62) >= (63 >= ((32'd7 + N_RESERVED_REGS) + 32'd8) ? (32'd7 + N_RESERVED_REGS) + 8 : 63) ? ((((63 >= ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) ? (N_CONTEXT * (64 - ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS))) + (((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) - 1) : (N_CONTEXT * (((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) - 62)) + 62) - (63 >= ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) ? ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) + 0 : 63)) + 1) * 32) + (((63 >= ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) ? ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) + 0 : 63) * 32) - 1) : ((((63 >= ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) ? ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) + 0 : 63) - (63 >= ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) ? (N_CONTEXT * (64 - ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS))) + (((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) - 1) : (N_CONTEXT * (((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) - 62)) + 62)) + 1) * 32) + (((63 >= ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) ? (N_CONTEXT * (64 - ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS))) + (((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) - 1) : (N_CONTEXT * (((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) - 62)) + 62) * 32) - 1)):((63 >= ((32'd7 + N_RESERVED_REGS) + 32'd8) ? (N_CONTEXT * (64 - ((32'd7 + N_RESERVED_REGS) + 32'd8))) + ((32'd7 + N_RESERVED_REGS) + 7) : (N_CONTEXT * ((32'd7 + N_RESERVED_REGS) - 54)) + 62) >= (63 >= ((32'd7 + N_RESERVED_REGS) + 32'd8) ? (32'd7 + N_RESERVED_REGS) + 8 : 63) ? (63 >= ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) ? ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) + 0 : 63) * 32 : (63 >= ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) ? (N_CONTEXT * (64 - ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS))) + (((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) - 1) : (N_CONTEXT * (((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) - 62)) + 62) * 32)] regfile_mem;
	reg [223:64] regfile_mem_mandatory;
	wire [((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_GENERIC_REGS) - 1) >= (N_MANDATORY_REGS + N_RESERVED_REGS) ? ((((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_GENERIC_REGS) - 1) - (N_MANDATORY_REGS + N_RESERVED_REGS)) + 1) * 32) + (((N_MANDATORY_REGS + N_RESERVED_REGS) * 32) - 1) : ((((N_MANDATORY_REGS + N_RESERVED_REGS) - (((N_MANDATORY_REGS + N_RESERVED_REGS) + N_GENERIC_REGS) - 1)) + 1) * 32) + (((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_GENERIC_REGS) - 1) * 32) - 1)):((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_GENERIC_REGS) - 1) >= (N_MANDATORY_REGS + N_RESERVED_REGS) ? (N_MANDATORY_REGS + N_RESERVED_REGS) * 32 : (((N_MANDATORY_REGS + N_RESERVED_REGS) + N_GENERIC_REGS) - 1) * 32)] regfile_mem_generic;
	wire [31:0] regfile_mem_dout;
	reg [31:0] regfile_out_rdata_int;
	reg [31:0] regfile_mem_mandatory_dout;
	wire [31:0] regfile_mem_generic_dout;
	wire [31:0] regfile_mem_io_dout;
	reg [7:0] offload_job_id;
	reg offload_job_id_incr;
	reg [7:0] running_job_id;
	reg running_job_id_incr;
	wire regfile_latch_re;
	reg [SCM_ADDR_WIDTH - 1:0] regfile_latch_rd_addr;
	reg [SCM_ADDR_WIDTH - 1:0] regfile_latch_wr_addr;
	wire [31:0] regfile_latch_rdata;
	wire regfile_latch_we;
	wire [31:0] regfile_latch_wdata;
	wire [3:0] regfile_latch_be;
	wire [(N_SCM_REGISTERS * 32) - 1:0] regfile_latch_mem;
	reg [1:0] r_finished_cnt;
	reg r_was_testset;
	reg r_was_mandatory;
	reg [2:0] r_first_startup;
	wire clear_first_startup;
	reg r_clear_first_startup;
	always @(posedge clk_i or negedge rst_ni)
		if (~rst_ni) begin
			r_first_startup <= 1'sb0;
			r_clear_first_startup <= 1'sb0;
		end
		else begin
			r_first_startup[0] <= 1'b1;
			r_first_startup[1] <= r_first_startup[0];
			r_first_startup[2] <= r_first_startup[1];
			r_clear_first_startup <= clear_first_startup;
		end
	assign clear_first_startup = |r_first_startup[1:0] & ~r_first_startup[2];
	genvar i;
	genvar j;
	genvar k;
	wire [N_CONTEXT - 1:0] wren_cxt;
	hwpe_ctrl_regfile_latch #(
		.ADDR_WIDTH(SCM_ADDR_WIDTH),
		.DATA_WIDTH(32)
	) i_regfile_latch(
		.clk(clk_i),
		.rst_n(rst_ni),
		.clear(clear_i | r_clear_first_startup),
		.ReadEnable(regfile_latch_re),
		.ReadAddr(regfile_latch_rd_addr),
		.ReadData(regfile_latch_rdata),
		.WriteAddr(regfile_latch_wr_addr),
		.WriteEnable(regfile_latch_we),
		.WriteData(regfile_latch_wdata),
		.WriteBE(regfile_latch_be),
		.scan_en_in(scan_en_in),
		.MemContent(regfile_latch_mem)
	);
	generate
		for (i = 0; i < N_CONTEXT; i = i + 1) begin : genblk1
			for (j = (N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS; j < (((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) + N_IO_REGS); j = j + 1) begin : genblk1
				assign regfile_mem[((63 >= ((32'd7 + N_RESERVED_REGS) + 32'd8) ? (N_CONTEXT * (64 - ((32'd7 + N_RESERVED_REGS) + 32'd8))) + ((32'd7 + N_RESERVED_REGS) + 7) : (N_CONTEXT * ((32'd7 + N_RESERVED_REGS) - 54)) + 62) >= (63 >= ((32'd7 + N_RESERVED_REGS) + 32'd8) ? (32'd7 + N_RESERVED_REGS) + 8 : 63) ? (i * (63 >= ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) ? 64 - ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) : ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) - 62)) + (63 >= ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) ? j : ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) - (j - 63)) : (63 >= ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) ? ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) + 0 : 63) - (((i * (63 >= ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) ? 64 - ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) : ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) - 62)) + (63 >= ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) ? j : ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) - (j - 63))) - (63 >= ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) ? (N_CONTEXT * (64 - ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS))) + (((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) - 1) : (N_CONTEXT * (((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) - 62)) + 62))) * 32+:32] = regfile_latch_mem[((((((i * N_IO_REGS) + j) - N_RESERVED_REGS) - N_MAX_GENERIC_REGS) + N_GENERIC_REGS) - N_MANDATORY_REGS) * 32+:32];
			end
		end
	endgenerate
	always @(posedge clk_i or negedge rst_ni)
		if (~rst_ni)
			regfile_mem_mandatory_dout <= 1'sb0;
		else if (clear_i)
			regfile_mem_mandatory_dout <= 1'sb0;
		else
			regfile_mem_mandatory_dout <= regfile_mem_mandatory[regfile_in_i[75:70] * 32+:32];
	assign regfile_mem_dout = (~r_was_mandatory ? regfile_latch_rdata : regfile_mem_mandatory_dout);
	assign regfile_latch_re = flags_i[7];
	assign regfile_latch_we = ~flags_i[8] & regfile_in_i[68];
	always @(*) begin : regfile_latch_addr_proc
		if (flags_i[6] == 1'b1) begin
			regfile_latch_rd_addr = ((((regfile_in_i[75:70] + (regfile_in_i[69 + LOG_REGS_MC:76] * N_IO_REGS)) - N_RESERVED_REGS) - N_MAX_GENERIC_REGS) + N_GENERIC_REGS) - N_MANDATORY_REGS;
			regfile_latch_wr_addr = ((((regfile_in_i[75:70] + (regfile_in_i[69 + LOG_REGS_MC:76] * N_IO_REGS)) - N_RESERVED_REGS) - N_MAX_GENERIC_REGS) + N_GENERIC_REGS) - N_MANDATORY_REGS;
		end
		else begin
			regfile_latch_rd_addr = (regfile_in_i[75:70] - N_RESERVED_REGS) - N_MANDATORY_REGS;
			regfile_latch_wr_addr = (regfile_in_i[75:70] - N_RESERVED_REGS) - N_MANDATORY_REGS;
		end
	end
	assign regfile_latch_be = regfile_in_i[3-:4];
	assign regfile_latch_wdata = regfile_in_i[67-:32];
	always @(posedge clk_i or negedge rst_ni)
		if (rst_ni == 0)
			offload_job_id <= 0;
		else if (clear_i == 1'b1)
			offload_job_id <= 0;
		else if (offload_job_id_incr == 1'b1)
			offload_job_id <= offload_job_id + 1;
		else
			offload_job_id <= offload_job_id;
	always @(posedge clk_i or negedge rst_ni)
		if (rst_ni == 1'b0)
			running_job_id_incr <= 1'b0;
		else if (clear_i == 1'b1)
			running_job_id_incr <= 1'b0;
		else
			running_job_id_incr <= flags_i[10];
	always @(posedge clk_i or negedge rst_ni)
		if (rst_ni == 0)
			running_job_id <= 0;
		else if (clear_i == 1'b1)
			running_job_id <= 0;
		else if (running_job_id_incr == 1'b1)
			running_job_id <= running_job_id + 1;
		else
			running_job_id <= running_job_id;
	always @(posedge clk_i or negedge rst_ni) begin : data_r_rdata_o_proc
		if (rst_ni == 0) begin
			offload_job_id_incr <= 1'b0;
			regfile_out_rdata_int <= 0;
		end
		else if (flags_i[4] | (flags_i[7] == 1'b1)) begin
			if (flags_i[4] == 1) begin
				if (flags_i[5] == 1) begin
					offload_job_id_incr <= 1'b0;
					regfile_out_rdata_int <= RESP_ANOTHER_PE_OFFLOADING;
				end
				else if (flags_i[9] == 1) begin
					offload_job_id_incr <= 1'b0;
					regfile_out_rdata_int <= RESP_ALL_CXT_BUSY;
				end
				else begin
					offload_job_id_incr <= 1'b1;
					regfile_out_rdata_int <= {24'b000000000000000000000000, offload_job_id};
				end
			end
			else
				offload_job_id_incr <= 1'b0;
		end
		else
			offload_job_id_incr <= 1'b0;
	end
	always @(posedge clk_i or negedge rst_ni)
		if (~rst_ni) begin
			r_was_testset <= 1'b0;
			r_was_mandatory <= 1'b0;
		end
		else if (clear_i == 1'b1) begin
			r_was_testset <= 1'b0;
			r_was_mandatory <= 1'b0;
		end
		else begin
			r_was_testset <= flags_i[4];
			r_was_mandatory <= flags_i[8];
		end
	assign regfile_out_o[31-:32] = (r_was_testset ? regfile_out_rdata_int : regfile_mem_dout);
	generate
		for (i = N_MANDATORY_REGS + N_RESERVED_REGS; i < ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_GENERIC_REGS); i = i + 1) begin : genblk2
			assign regfile_mem_generic[((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_GENERIC_REGS) - 1) >= (N_MANDATORY_REGS + N_RESERVED_REGS) ? i : (N_MANDATORY_REGS + N_RESERVED_REGS) - (i - (((N_MANDATORY_REGS + N_RESERVED_REGS) + N_GENERIC_REGS) - 1))) * 32+:32] = regfile_latch_mem[((i - N_RESERVED_REGS) - N_MANDATORY_REGS) * 32+:32];
		end
	endgenerate
	always @(posedge clk_i or negedge rst_ni) begin : write_mandatory_proc_word
		if (rst_ni == 0) begin
			regfile_mem_mandatory[128+:32] <= 0;
			regfile_mem_mandatory[160+:32] <= 0;
		end
		else if (clear_i == 1'b1) begin
			regfile_mem_mandatory[128+:32] <= 0;
			regfile_mem_mandatory[160+:32] <= 0;
		end
		else begin
			regfile_mem_mandatory[128+:32] <= {24'b000000000000000000000000, running_job_id};
			if ((regfile_in_i[68] == 1'b1) || (regfile_in_i[69] == 1'b1))
				regfile_mem_mandatory[160+:32] <= regfile_in_i[69 + LOG_REGS_MC:76];
		end
	end
	wire [32:1] sv2v_tmp_EA5D2;
	assign sv2v_tmp_EA5D2 = r_finished_cnt;
	always @(*) regfile_mem_mandatory[64+:32] = sv2v_tmp_EA5D2;
	reg [$clog2(ID_WIDTH) - 1:0] data_src_encoded;
	always @(*) begin : data_src_encoder
		data_src_encoded = {$clog2(ID_WIDTH) {1'b0}};
		begin : sv2v_autoblock_1
			reg signed [31:0] i;
			for (i = 0; i < ID_WIDTH; i = i + 1)
				if (regfile_in_i[3 + ID_WIDTH:4] == (i & {$clog2(ID_WIDTH) {1'b1}}))
					data_src_encoded = 1 << i;
		end
	end
	generate
		for (i = 0; i < N_CONTEXT; i = i + 1) begin : genblk3
			always @(posedge clk_i or negedge rst_ni) begin : write_mandatory_proc_byte
				if (rst_ni == 0) begin
					regfile_mem_mandatory[96 + ((((i + 1) * 8) - 1) >= (i * 8) ? ((i + 1) * 8) - 1 : ((((i + 1) * 8) - 1) + ((((i + 1) * 8) - 1) >= (i * 8) ? ((((i + 1) * 8) - 1) - (i * 8)) + 1 : ((i * 8) - (((i + 1) * 8) - 1)) + 1)) - 1)-:((((i + 1) * 8) - 1) >= (i * 8) ? ((((i + 1) * 8) - 1) - (i * 8)) + 1 : ((i * 8) - (((i + 1) * 8) - 1)) + 1)] <= 0;
					regfile_mem_mandatory[192 + ((((i + 1) * 8) - 1) >= (i * 8) ? ((i + 1) * 8) - 1 : ((((i + 1) * 8) - 1) + ((((i + 1) * 8) - 1) >= (i * 8) ? ((((i + 1) * 8) - 1) - (i * 8)) + 1 : ((i * 8) - (((i + 1) * 8) - 1)) + 1)) - 1)-:((((i + 1) * 8) - 1) >= (i * 8) ? ((((i + 1) * 8) - 1) - (i * 8)) + 1 : ((i * 8) - (((i + 1) * 8) - 1)) + 1)] <= 0;
				end
				else if (clear_i == 1'b1) begin
					regfile_mem_mandatory[96 + ((((i + 1) * 8) - 1) >= (i * 8) ? ((i + 1) * 8) - 1 : ((((i + 1) * 8) - 1) + ((((i + 1) * 8) - 1) >= (i * 8) ? ((((i + 1) * 8) - 1) - (i * 8)) + 1 : ((i * 8) - (((i + 1) * 8) - 1)) + 1)) - 1)-:((((i + 1) * 8) - 1) >= (i * 8) ? ((((i + 1) * 8) - 1) - (i * 8)) + 1 : ((i * 8) - (((i + 1) * 8) - 1)) + 1)] <= 0;
					regfile_mem_mandatory[192 + ((((i + 1) * 8) - 1) >= (i * 8) ? ((i + 1) * 8) - 1 : ((((i + 1) * 8) - 1) + ((((i + 1) * 8) - 1) >= (i * 8) ? ((((i + 1) * 8) - 1) - (i * 8)) + 1 : ((i * 8) - (((i + 1) * 8) - 1)) + 1)) - 1)-:((((i + 1) * 8) - 1) >= (i * 8) ? ((((i + 1) * 8) - 1) - (i * 8)) + 1 : ((i * 8) - (((i + 1) * 8) - 1)) + 1)] <= 0;
				end
				else if (flags_i[3] | (flags_i[10] == 1'b1))
					if (flags_i[1-:1] == i) begin
						if (flags_i[3] == 1) begin
							regfile_mem_mandatory[96 + ((((i + 1) * 8) - 1) >= (i * 8) ? ((i + 1) * 8) - 1 : ((((i + 1) * 8) - 1) + ((((i + 1) * 8) - 1) >= (i * 8) ? ((((i + 1) * 8) - 1) - (i * 8)) + 1 : ((i * 8) - (((i + 1) * 8) - 1)) + 1)) - 1)-:((((i + 1) * 8) - 1) >= (i * 8) ? ((((i + 1) * 8) - 1) - (i * 8)) + 1 : ((i * 8) - (((i + 1) * 8) - 1)) + 1)] <= 8'h01;
							regfile_mem_mandatory[192 + ((((i + 1) * 8) - 1) >= (i * 8) ? ((i + 1) * 8) - 1 : ((((i + 1) * 8) - 1) + ((((i + 1) * 8) - 1) >= (i * 8) ? ((((i + 1) * 8) - 1) - (i * 8)) + 1 : ((i * 8) - (((i + 1) * 8) - 1)) + 1)) - 1)-:((((i + 1) * 8) - 1) >= (i * 8) ? ((((i + 1) * 8) - 1) - (i * 8)) + 1 : ((i * 8) - (((i + 1) * 8) - 1)) + 1)] <= data_src_encoded + 1;
						end
						else if ((flags_i[10] == 1) && (flags_i[0-:1] == flags_i[1-:1])) begin
							regfile_mem_mandatory[96 + ((((i + 1) * 8) - 1) >= (i * 8) ? ((i + 1) * 8) - 1 : ((((i + 1) * 8) - 1) + ((((i + 1) * 8) - 1) >= (i * 8) ? ((((i + 1) * 8) - 1) - (i * 8)) + 1 : ((i * 8) - (((i + 1) * 8) - 1)) + 1)) - 1)-:((((i + 1) * 8) - 1) >= (i * 8) ? ((((i + 1) * 8) - 1) - (i * 8)) + 1 : ((i * 8) - (((i + 1) * 8) - 1)) + 1)] <= 8'h00;
							regfile_mem_mandatory[192 + ((((i + 1) * 8) - 1) >= (i * 8) ? ((i + 1) * 8) - 1 : ((((i + 1) * 8) - 1) + ((((i + 1) * 8) - 1) >= (i * 8) ? ((((i + 1) * 8) - 1) - (i * 8)) + 1 : ((i * 8) - (((i + 1) * 8) - 1)) + 1)) - 1)-:((((i + 1) * 8) - 1) >= (i * 8) ? ((((i + 1) * 8) - 1) - (i * 8)) + 1 : ((i * 8) - (((i + 1) * 8) - 1)) + 1)] <= regfile_mem_mandatory[192 + ((((i + 1) * 8) - 1) >= (i * 8) ? ((i + 1) * 8) - 1 : ((((i + 1) * 8) - 1) + ((((i + 1) * 8) - 1) >= (i * 8) ? ((((i + 1) * 8) - 1) - (i * 8)) + 1 : ((i * 8) - (((i + 1) * 8) - 1)) + 1)) - 1)-:((((i + 1) * 8) - 1) >= (i * 8) ? ((((i + 1) * 8) - 1) - (i * 8)) + 1 : ((i * 8) - (((i + 1) * 8) - 1)) + 1)];
						end
					end
					else if (flags_i[0-:1] == i)
						if (flags_i[10] == 1) begin
							regfile_mem_mandatory[96 + ((((i + 1) * 8) - 1) >= (i * 8) ? ((i + 1) * 8) - 1 : ((((i + 1) * 8) - 1) + ((((i + 1) * 8) - 1) >= (i * 8) ? ((((i + 1) * 8) - 1) - (i * 8)) + 1 : ((i * 8) - (((i + 1) * 8) - 1)) + 1)) - 1)-:((((i + 1) * 8) - 1) >= (i * 8) ? ((((i + 1) * 8) - 1) - (i * 8)) + 1 : ((i * 8) - (((i + 1) * 8) - 1)) + 1)] <= 8'h00;
							regfile_mem_mandatory[192 + ((((i + 1) * 8) - 1) >= (i * 8) ? ((i + 1) * 8) - 1 : ((((i + 1) * 8) - 1) + ((((i + 1) * 8) - 1) >= (i * 8) ? ((((i + 1) * 8) - 1) - (i * 8)) + 1 : ((i * 8) - (((i + 1) * 8) - 1)) + 1)) - 1)-:((((i + 1) * 8) - 1) >= (i * 8) ? ((((i + 1) * 8) - 1) - (i * 8)) + 1 : ((i * 8) - (((i + 1) * 8) - 1)) + 1)] <= regfile_mem_mandatory[192 + ((((i + 1) * 8) - 1) >= (i * 8) ? ((i + 1) * 8) - 1 : ((((i + 1) * 8) - 1) + ((((i + 1) * 8) - 1) >= (i * 8) ? ((((i + 1) * 8) - 1) - (i * 8)) + 1 : ((i * 8) - (((i + 1) * 8) - 1)) + 1)) - 1)-:((((i + 1) * 8) - 1) >= (i * 8) ? ((((i + 1) * 8) - 1) - (i * 8)) + 1 : ((i * 8) - (((i + 1) * 8) - 1)) + 1)];
						end
			end
		end
		if (N_CONTEXT < 4) begin : genblk4
			for (i = N_CONTEXT; i < 4; i = i + 1) begin : genblk1
				wire [((((i + 1) * 8) - 1) >= (i * 8) ? ((((i + 1) * 8) - 1) - (i * 8)) + 1 : ((i * 8) - (((i + 1) * 8) - 1)) + 1) * 1:1] sv2v_tmp_AB53A;
				assign sv2v_tmp_AB53A = 'b0;
				always @(*) regfile_mem_mandatory[96 + ((((i + 1) * 8) - 1) >= (i * 8) ? ((i + 1) * 8) - 1 : ((((i + 1) * 8) - 1) + ((((i + 1) * 8) - 1) >= (i * 8) ? ((((i + 1) * 8) - 1) - (i * 8)) + 1 : ((i * 8) - (((i + 1) * 8) - 1)) + 1)) - 1)-:((((i + 1) * 8) - 1) >= (i * 8) ? ((((i + 1) * 8) - 1) - (i * 8)) + 1 : ((i * 8) - (((i + 1) * 8) - 1)) + 1)] = sv2v_tmp_AB53A;
				wire [((((i + 1) * 8) - 1) >= (i * 8) ? ((((i + 1) * 8) - 1) - (i * 8)) + 1 : ((i * 8) - (((i + 1) * 8) - 1)) + 1) * 1:1] sv2v_tmp_BD312;
				assign sv2v_tmp_BD312 = 'b0;
				always @(*) regfile_mem_mandatory[192 + ((((i + 1) * 8) - 1) >= (i * 8) ? ((i + 1) * 8) - 1 : ((((i + 1) * 8) - 1) + ((((i + 1) * 8) - 1) >= (i * 8) ? ((((i + 1) * 8) - 1) - (i * 8)) + 1 : ((i * 8) - (((i + 1) * 8) - 1)) + 1)) - 1)-:((((i + 1) * 8) - 1) >= (i * 8) ? ((((i + 1) * 8) - 1) - (i * 8)) + 1 : ((i * 8) - (((i + 1) * 8) - 1)) + 1)] = sv2v_tmp_BD312;
			end
		end
	endgenerate
	assign reg_file[1791-:1536] = regfile_mem[32 * ((63 >= ((32'd7 + N_RESERVED_REGS) + 32'd8) ? (N_CONTEXT * (64 - ((32'd7 + N_RESERVED_REGS) + 32'd8))) + ((32'd7 + N_RESERVED_REGS) + 7) : (N_CONTEXT * ((32'd7 + N_RESERVED_REGS) - 54)) + 62) >= (63 >= ((32'd7 + N_RESERVED_REGS) + 32'd8) ? (32'd7 + N_RESERVED_REGS) + 8 : 63) ? ((63 >= ((32'd7 + N_RESERVED_REGS) + 32'd8) ? (N_CONTEXT * (64 - ((32'd7 + N_RESERVED_REGS) + 32'd8))) + ((32'd7 + N_RESERVED_REGS) + 7) : (N_CONTEXT * ((32'd7 + N_RESERVED_REGS) - 54)) + 62) >= (63 >= ((32'd7 + N_RESERVED_REGS) + 32'd8) ? (32'd7 + N_RESERVED_REGS) + 8 : 63) ? (63 >= ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) ? (flags_i[0-:1] * (63 >= ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) ? 64 - ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) : ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) - 62)) + (63 >= ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) ? (((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) + N_IO_REGS) - 1) >= ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) ? (((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) + N_IO_REGS) - 1 : (((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) + N_IO_REGS) - 1) + (((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) + N_IO_REGS) - 1) >= ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) ? (((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) + N_IO_REGS) - 1) - ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS)) + 1 : (((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) - ((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) + N_IO_REGS) - 1)) + 1)) - 1) : ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) - ((((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) + N_IO_REGS) - 1) >= ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) ? (((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) + N_IO_REGS) - 1 : (((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) + N_IO_REGS) - 1) + (((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) + N_IO_REGS) - 1) >= ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) ? (((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) + N_IO_REGS) - 1) - ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS)) + 1 : (((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) - ((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) + N_IO_REGS) - 1)) + 1)) - 1) - 63)) : (((flags_i[0-:1] * (63 >= ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) ? 64 - ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) : ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) - 62)) + (63 >= ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) ? (((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) + N_IO_REGS) - 1) >= ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) ? (((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) + N_IO_REGS) - 1 : (((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) + N_IO_REGS) - 1) + (((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) + N_IO_REGS) - 1) >= ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) ? (((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) + N_IO_REGS) - 1) - ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS)) + 1 : (((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) - ((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) + N_IO_REGS) - 1)) + 1)) - 1) : ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) - ((((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) + N_IO_REGS) - 1) >= ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) ? (((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) + N_IO_REGS) - 1 : (((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) + N_IO_REGS) - 1) + (((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) + N_IO_REGS) - 1) >= ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) ? (((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) + N_IO_REGS) - 1) - ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS)) + 1 : (((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) - ((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) + N_IO_REGS) - 1)) + 1)) - 1) - 63))) + (((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) + N_IO_REGS) - 1) >= ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) ? (((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) + N_IO_REGS) - 1) - ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS)) + 1 : (((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) - ((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) + N_IO_REGS) - 1)) + 1)) - 1) - ((((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) + N_IO_REGS) - 1) >= ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) ? (((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) + N_IO_REGS) - 1) - ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS)) + 1 : (((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) - ((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) + N_IO_REGS) - 1)) + 1) - 1) : (63 >= ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) ? (flags_i[0-:1] * (63 >= ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) ? 64 - ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) : ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) - 62)) + (63 >= ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) ? (((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) + N_IO_REGS) - 1) >= ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) ? (((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) + N_IO_REGS) - 1 : (((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) + N_IO_REGS) - 1) + (((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) + N_IO_REGS) - 1) >= ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) ? (((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) + N_IO_REGS) - 1) - ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS)) + 1 : (((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) - ((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) + N_IO_REGS) - 1)) + 1)) - 1) : ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) - ((((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) + N_IO_REGS) - 1) >= ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) ? (((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) + N_IO_REGS) - 1 : (((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) + N_IO_REGS) - 1) + (((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) + N_IO_REGS) - 1) >= ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) ? (((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) + N_IO_REGS) - 1) - ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS)) + 1 : (((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) - ((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) + N_IO_REGS) - 1)) + 1)) - 1) - 63)) : (((flags_i[0-:1] * (63 >= ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) ? 64 - ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) : ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) - 62)) + (63 >= ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) ? (((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) + N_IO_REGS) - 1) >= ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) ? (((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) + N_IO_REGS) - 1 : (((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) + N_IO_REGS) - 1) + (((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) + N_IO_REGS) - 1) >= ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) ? (((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) + N_IO_REGS) - 1) - ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS)) + 1 : (((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) - ((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) + N_IO_REGS) - 1)) + 1)) - 1) : ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) - ((((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) + N_IO_REGS) - 1) >= ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) ? (((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) + N_IO_REGS) - 1 : (((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) + N_IO_REGS) - 1) + (((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) + N_IO_REGS) - 1) >= ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) ? (((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) + N_IO_REGS) - 1) - ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS)) + 1 : (((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) - ((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) + N_IO_REGS) - 1)) + 1)) - 1) - 63))) + (((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) + N_IO_REGS) - 1) >= ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) ? (((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) + N_IO_REGS) - 1) - ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS)) + 1 : (((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) - ((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) + N_IO_REGS) - 1)) + 1)) - 1)) : (63 >= ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) ? ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) + 0 : 63) - (((63 >= ((32'd7 + N_RESERVED_REGS) + 32'd8) ? (N_CONTEXT * (64 - ((32'd7 + N_RESERVED_REGS) + 32'd8))) + ((32'd7 + N_RESERVED_REGS) + 7) : (N_CONTEXT * ((32'd7 + N_RESERVED_REGS) - 54)) + 62) >= (63 >= ((32'd7 + N_RESERVED_REGS) + 32'd8) ? (32'd7 + N_RESERVED_REGS) + 8 : 63) ? (63 >= ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) ? (flags_i[0-:1] * (63 >= ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) ? 64 - ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) : ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) - 62)) + (63 >= ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) ? (((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) + N_IO_REGS) - 1) >= ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) ? (((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) + N_IO_REGS) - 1 : (((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) + N_IO_REGS) - 1) + (((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) + N_IO_REGS) - 1) >= ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) ? (((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) + N_IO_REGS) - 1) - ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS)) + 1 : (((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) - ((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) + N_IO_REGS) - 1)) + 1)) - 1) : ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) - ((((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) + N_IO_REGS) - 1) >= ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) ? (((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) + N_IO_REGS) - 1 : (((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) + N_IO_REGS) - 1) + (((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) + N_IO_REGS) - 1) >= ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) ? (((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) + N_IO_REGS) - 1) - ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS)) + 1 : (((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) - ((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) + N_IO_REGS) - 1)) + 1)) - 1) - 63)) : (((flags_i[0-:1] * (63 >= ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) ? 64 - ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) : ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) - 62)) + (63 >= ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) ? (((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) + N_IO_REGS) - 1) >= ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) ? (((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) + N_IO_REGS) - 1 : (((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) + N_IO_REGS) - 1) + (((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) + N_IO_REGS) - 1) >= ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) ? (((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) + N_IO_REGS) - 1) - ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS)) + 1 : (((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) - ((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) + N_IO_REGS) - 1)) + 1)) - 1) : ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) - ((((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) + N_IO_REGS) - 1) >= ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) ? (((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) + N_IO_REGS) - 1 : (((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) + N_IO_REGS) - 1) + (((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) + N_IO_REGS) - 1) >= ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) ? (((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) + N_IO_REGS) - 1) - ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS)) + 1 : (((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) - ((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) + N_IO_REGS) - 1)) + 1)) - 1) - 63))) + (((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) + N_IO_REGS) - 1) >= ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) ? (((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) + N_IO_REGS) - 1) - ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS)) + 1 : (((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) - ((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) + N_IO_REGS) - 1)) + 1)) - 1) - ((((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) + N_IO_REGS) - 1) >= ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) ? (((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) + N_IO_REGS) - 1) - ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS)) + 1 : (((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) - ((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) + N_IO_REGS) - 1)) + 1) - 1) : (63 >= ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) ? (flags_i[0-:1] * (63 >= ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) ? 64 - ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) : ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) - 62)) + (63 >= ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) ? (((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) + N_IO_REGS) - 1) >= ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) ? (((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) + N_IO_REGS) - 1 : (((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) + N_IO_REGS) - 1) + (((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) + N_IO_REGS) - 1) >= ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) ? (((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) + N_IO_REGS) - 1) - ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS)) + 1 : (((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) - ((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) + N_IO_REGS) - 1)) + 1)) - 1) : ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) - ((((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) + N_IO_REGS) - 1) >= ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) ? (((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) + N_IO_REGS) - 1 : (((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) + N_IO_REGS) - 1) + (((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) + N_IO_REGS) - 1) >= ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) ? (((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) + N_IO_REGS) - 1) - ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS)) + 1 : (((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) - ((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) + N_IO_REGS) - 1)) + 1)) - 1) - 63)) : (((flags_i[0-:1] * (63 >= ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) ? 64 - ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) : ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) - 62)) + (63 >= ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) ? (((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) + N_IO_REGS) - 1) >= ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) ? (((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) + N_IO_REGS) - 1 : (((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) + N_IO_REGS) - 1) + (((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) + N_IO_REGS) - 1) >= ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) ? (((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) + N_IO_REGS) - 1) - ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS)) + 1 : (((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) - ((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) + N_IO_REGS) - 1)) + 1)) - 1) : ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) - ((((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) + N_IO_REGS) - 1) >= ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) ? (((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) + N_IO_REGS) - 1 : (((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) + N_IO_REGS) - 1) + (((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) + N_IO_REGS) - 1) >= ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) ? (((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) + N_IO_REGS) - 1) - ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS)) + 1 : (((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) - ((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) + N_IO_REGS) - 1)) + 1)) - 1) - 63))) + (((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) + N_IO_REGS) - 1) >= ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) ? (((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) + N_IO_REGS) - 1) - ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS)) + 1 : (((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) - ((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) + N_IO_REGS) - 1)) + 1)) - 1)) - (63 >= ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) ? (N_CONTEXT * (64 - ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS))) + (((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) - 1) : (N_CONTEXT * (((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) - 62)) + 62)))+:32 * (((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) + N_IO_REGS) - 1) >= ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) ? (((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) + N_IO_REGS) - 1) - ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS)) + 1 : (((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) - ((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_MAX_GENERIC_REGS) + N_IO_REGS) - 1)) + 1)];
	generate
		if (N_GENERIC_REGS > 0) begin : genblk5
			assign reg_file[255-:256] = regfile_mem_generic[32 * ((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_GENERIC_REGS) - 1) >= (N_MANDATORY_REGS + N_RESERVED_REGS) ? ((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_GENERIC_REGS) - 1) >= (N_MANDATORY_REGS + N_RESERVED_REGS) ? ((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_GENERIC_REGS) - 1) >= (N_MANDATORY_REGS + N_RESERVED_REGS) ? ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_GENERIC_REGS) - 1 : ((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_GENERIC_REGS) - 1) + ((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_GENERIC_REGS) - 1) >= (N_MANDATORY_REGS + N_RESERVED_REGS) ? ((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_GENERIC_REGS) - 1) - (N_MANDATORY_REGS + N_RESERVED_REGS)) + 1 : ((N_MANDATORY_REGS + N_RESERVED_REGS) - (((N_MANDATORY_REGS + N_RESERVED_REGS) + N_GENERIC_REGS) - 1)) + 1)) - 1) - (((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_GENERIC_REGS) - 1) >= (N_MANDATORY_REGS + N_RESERVED_REGS) ? ((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_GENERIC_REGS) - 1) - (N_MANDATORY_REGS + N_RESERVED_REGS)) + 1 : ((N_MANDATORY_REGS + N_RESERVED_REGS) - (((N_MANDATORY_REGS + N_RESERVED_REGS) + N_GENERIC_REGS) - 1)) + 1) - 1) : ((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_GENERIC_REGS) - 1) >= (N_MANDATORY_REGS + N_RESERVED_REGS) ? ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_GENERIC_REGS) - 1 : ((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_GENERIC_REGS) - 1) + ((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_GENERIC_REGS) - 1) >= (N_MANDATORY_REGS + N_RESERVED_REGS) ? ((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_GENERIC_REGS) - 1) - (N_MANDATORY_REGS + N_RESERVED_REGS)) + 1 : ((N_MANDATORY_REGS + N_RESERVED_REGS) - (((N_MANDATORY_REGS + N_RESERVED_REGS) + N_GENERIC_REGS) - 1)) + 1)) - 1)) : (N_MANDATORY_REGS + N_RESERVED_REGS) - (((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_GENERIC_REGS) - 1) >= (N_MANDATORY_REGS + N_RESERVED_REGS) ? ((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_GENERIC_REGS) - 1) >= (N_MANDATORY_REGS + N_RESERVED_REGS) ? ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_GENERIC_REGS) - 1 : ((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_GENERIC_REGS) - 1) + ((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_GENERIC_REGS) - 1) >= (N_MANDATORY_REGS + N_RESERVED_REGS) ? ((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_GENERIC_REGS) - 1) - (N_MANDATORY_REGS + N_RESERVED_REGS)) + 1 : ((N_MANDATORY_REGS + N_RESERVED_REGS) - (((N_MANDATORY_REGS + N_RESERVED_REGS) + N_GENERIC_REGS) - 1)) + 1)) - 1) - (((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_GENERIC_REGS) - 1) >= (N_MANDATORY_REGS + N_RESERVED_REGS) ? ((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_GENERIC_REGS) - 1) - (N_MANDATORY_REGS + N_RESERVED_REGS)) + 1 : ((N_MANDATORY_REGS + N_RESERVED_REGS) - (((N_MANDATORY_REGS + N_RESERVED_REGS) + N_GENERIC_REGS) - 1)) + 1) - 1) : ((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_GENERIC_REGS) - 1) >= (N_MANDATORY_REGS + N_RESERVED_REGS) ? ((N_MANDATORY_REGS + N_RESERVED_REGS) + N_GENERIC_REGS) - 1 : ((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_GENERIC_REGS) - 1) + ((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_GENERIC_REGS) - 1) >= (N_MANDATORY_REGS + N_RESERVED_REGS) ? ((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_GENERIC_REGS) - 1) - (N_MANDATORY_REGS + N_RESERVED_REGS)) + 1 : ((N_MANDATORY_REGS + N_RESERVED_REGS) - (((N_MANDATORY_REGS + N_RESERVED_REGS) + N_GENERIC_REGS) - 1)) + 1)) - 1)) - (((N_MANDATORY_REGS + N_RESERVED_REGS) + N_GENERIC_REGS) - 1)))+:32 * ((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_GENERIC_REGS) - 1) >= (N_MANDATORY_REGS + N_RESERVED_REGS) ? ((((N_MANDATORY_REGS + N_RESERVED_REGS) + N_GENERIC_REGS) - 1) - (N_MANDATORY_REGS + N_RESERVED_REGS)) + 1 : ((N_MANDATORY_REGS + N_RESERVED_REGS) - (((N_MANDATORY_REGS + N_RESERVED_REGS) + N_GENERIC_REGS) - 1)) + 1)];
		end
		else begin : genblk5
			assign reg_file[255-:256] = 'b0;
		end
	endgenerate
	always @(posedge clk_i or negedge rst_ni) begin : finished_counter
		if (~rst_ni)
			r_finished_cnt <= 1'sb0;
		else if (clear_i == 1'b1)
			r_finished_cnt <= 1'sb0;
		else if ((flags_i[8] == 1'b1) && (regfile_in_i[75:70] == 2))
			r_finished_cnt <= 1'sb0;
		else if ((flags_i[10] == 1'b1) && (r_finished_cnt < 2))
			r_finished_cnt <= r_finished_cnt + 1;
	end
endmodule
