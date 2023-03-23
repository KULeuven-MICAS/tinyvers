module register_file_test_wrap (
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
	we_b_i,
	BIST,
	CSN_T,
	WEN_T,
	A_T,
	D_T,
	Q_T
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
	input wire BIST;
	input wire CSN_T;
	input wire WEN_T;
	input wire [ADDR_WIDTH - 1:0] A_T;
	input wire [DATA_WIDTH - 1:0] D_T;
	output wire [DATA_WIDTH - 1:0] Q_T;
	wire [ADDR_WIDTH - 1:0] ReadAddr_a_muxed;
	wire WriteEnable_a_muxed;
	wire [ADDR_WIDTH - 1:0] WriteAddr_a_muxed;
	wire [DATA_WIDTH - 1:0] WriteData_a_muxed;
	wire WriteEnable_b_muxed;
	wire [ADDR_WIDTH - 1:0] WriteAddr_b_muxed;
	wire [DATA_WIDTH - 1:0] WriteData_b_muxed;
	reg [ADDR_WIDTH - 1:0] TestReadAddr_Q;
	assign WriteData_a_muxed = (BIST ? D_T : wdata_a_i);
	assign WriteAddr_a_muxed = (BIST ? {1'b0, ~A_T[ADDR_WIDTH - 2:0]} : waddr_a_i);
	assign WriteEnable_a_muxed = (BIST ? (CSN_T == 1'b0) && (WEN_T == 1'b0) : we_a_i);
	assign WriteData_b_muxed = (BIST ? {DATA_WIDTH {1'sb0}} : wdata_b_i);
	assign WriteAddr_b_muxed = (BIST ? {ADDR_WIDTH {1'sb0}} : waddr_b_i);
	assign WriteEnable_b_muxed = (BIST ? 1'b0 : we_b_i);
	assign ReadAddr_a_muxed = (BIST ? TestReadAddr_Q : raddr_a_i);
	assign Q_T = rdata_a_o;
	always @(posedge clk or negedge rst_n) begin : proc_
		if (~rst_n)
			TestReadAddr_Q <= 1'sb0;
		else if ((CSN_T == 1'b0) && (WEN_T == 1'b1))
			TestReadAddr_Q <= {1'b0, ~A_T[ADDR_WIDTH - 2:0]};
	end
	riscv_register_file #(
		.ADDR_WIDTH(ADDR_WIDTH),
		.DATA_WIDTH(DATA_WIDTH),
		.FPU(FPU),
		.Zfinx(Zfinx)
	) riscv_register_file_i(
		.clk(clk),
		.rst_n(rst_n),
		.test_en_i(test_en_i),
		.raddr_a_i(ReadAddr_a_muxed),
		.rdata_a_o(rdata_a_o),
		.raddr_b_i(raddr_b_i),
		.rdata_b_o(rdata_b_o),
		.raddr_c_i(raddr_c_i),
		.rdata_c_o(rdata_c_o),
		.waddr_a_i(WriteAddr_a_muxed),
		.wdata_a_i(WriteData_a_muxed),
		.we_a_i(WriteEnable_a_muxed),
		.waddr_b_i(WriteAddr_b_muxed),
		.wdata_b_i(WriteData_b_muxed),
		.we_b_i(WriteEnable_b_muxed)
	);
endmodule
