module register_file_1w_64b_1r_32b (
	clk,
	rst_n,
	ReadEnable,
	ReadAddr,
	ReadData,
	WriteEnable,
	WriteAddr,
	WriteData
);
	parameter WADDR_WIDTH = 5;
	parameter WDATA_WIDTH = 64;
	parameter RDATA_WIDTH = 32;
	parameter RADDR_WIDTH = WADDR_WIDTH + $clog2(WDATA_WIDTH / RDATA_WIDTH);
	parameter W_N_ROWS = 2 ** WADDR_WIDTH;
	input wire clk;
	input wire rst_n;
	input wire ReadEnable;
	input wire [RADDR_WIDTH - 1:0] ReadAddr;
	output wire [RDATA_WIDTH - 1:0] ReadData;
	input wire WriteEnable;
	input wire [WADDR_WIDTH - 1:0] WriteAddr;
	input wire [WDATA_WIDTH - 1:0] WriteData;
	wire [RDATA_WIDTH - 1:0] ReadData_lo;
	wire [RDATA_WIDTH - 1:0] ReadData_hi;
	reg DEST;
	wire [31:0] j;
	genvar i;
	always @(posedge clk or negedge rst_n)
		if (~rst_n)
			DEST <= 0;
		else
			DEST <= ReadAddr[0];
	assign ReadData = (DEST == 1'b0 ? ReadData_lo : ReadData_hi);
	generate
		if (W_N_ROWS == 1) begin : genblk1
			register_file_1r_1w_1row #(
				.ADDR_WIDTH(WADDR_WIDTH),
				.DATA_WIDTH(RDATA_WIDTH)
			) bram_cut_lo(
				.clk(clk),
				.ReadEnable(ReadEnable),
				.ReadAddr(ReadAddr[RADDR_WIDTH - 1:1]),
				.ReadData(ReadData_lo),
				.WriteAddr(WriteAddr),
				.WriteEnable(WriteEnable),
				.WriteData(WriteData[31:0])
			);
			register_file_1r_1w_1row #(
				.ADDR_WIDTH(WADDR_WIDTH),
				.DATA_WIDTH(RDATA_WIDTH)
			) bram_cut_hi(
				.clk(clk),
				.ReadEnable(ReadEnable),
				.ReadAddr(ReadAddr[RADDR_WIDTH - 1:1]),
				.ReadData(ReadData_hi),
				.WriteAddr(WriteAddr),
				.WriteEnable(WriteEnable),
				.WriteData(WriteData[63:32])
			);
		end
		else begin : genblk1
			register_file_1r_1w #(
				.ADDR_WIDTH(WADDR_WIDTH),
				.DATA_WIDTH(RDATA_WIDTH)
			) bram_cut_lo(
				.clk(clk),
				.ReadEnable(ReadEnable),
				.ReadAddr(ReadAddr[RADDR_WIDTH - 1:1]),
				.ReadData(ReadData_lo),
				.WriteAddr(WriteAddr),
				.WriteEnable(WriteEnable),
				.WriteData(WriteData[31:0])
			);
			register_file_1r_1w #(
				.ADDR_WIDTH(WADDR_WIDTH),
				.DATA_WIDTH(RDATA_WIDTH)
			) bram_cut_hi(
				.clk(clk),
				.ReadEnable(ReadEnable),
				.ReadAddr(ReadAddr[RADDR_WIDTH - 1:1]),
				.ReadData(ReadData_hi),
				.WriteAddr(WriteAddr),
				.WriteEnable(WriteEnable),
				.WriteData(WriteData[63:32])
			);
		end
	endgenerate
endmodule
