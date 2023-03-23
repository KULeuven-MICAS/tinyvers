module register_file_1r_1w_test_wrap (
	clk,
	ReadEnable,
	ReadAddr,
	ReadData,
	WriteEnable,
	WriteAddr,
	WriteData,
	BIST,
	CSN_T,
	WEN_T,
	A_T,
	D_T,
	Q_T
);
	parameter ADDR_WIDTH = 5;
	parameter DATA_WIDTH = 32;
	input wire clk;
	input wire ReadEnable;
	input wire [ADDR_WIDTH - 1:0] ReadAddr;
	output wire [DATA_WIDTH - 1:0] ReadData;
	input wire WriteEnable;
	input wire [ADDR_WIDTH - 1:0] WriteAddr;
	input wire [DATA_WIDTH - 1:0] WriteData;
	input wire BIST;
	input wire CSN_T;
	input wire WEN_T;
	input wire [ADDR_WIDTH - 1:0] A_T;
	input wire [DATA_WIDTH - 1:0] D_T;
	output wire [DATA_WIDTH - 1:0] Q_T;
	reg ReadEnable_muxed;
	reg [ADDR_WIDTH - 1:0] ReadAddr_muxed;
	reg WriteEnable_muxed;
	reg [ADDR_WIDTH - 1:0] WriteAddr_muxed;
	reg [DATA_WIDTH - 1:0] WriteData_muxed;
	always @(*)
		if (BIST) begin
			ReadEnable_muxed = (CSN_T == 1'b0) && (WEN_T == 1'b1);
			ReadAddr_muxed = A_T;
			WriteEnable_muxed = (CSN_T == 1'b0) && (WEN_T == 1'b0);
			WriteAddr_muxed = A_T;
			WriteData_muxed = D_T;
		end
		else begin
			ReadEnable_muxed = ReadEnable;
			ReadAddr_muxed = ReadAddr;
			WriteEnable_muxed = WriteEnable;
			WriteAddr_muxed = WriteAddr;
			WriteData_muxed = WriteData;
		end
	assign Q_T = ReadData;
	register_file_1r_1w #(
		.ADDR_WIDTH(ADDR_WIDTH),
		.DATA_WIDTH(DATA_WIDTH)
	) register_file_1r_1w_i(
		.clk(clk),
		.ReadEnable(ReadEnable_muxed),
		.ReadAddr(ReadAddr_muxed),
		.ReadData(ReadData),
		.WriteEnable(WriteEnable_muxed),
		.WriteAddr(WriteAddr_muxed),
		.WriteData(WriteData_muxed)
	);
endmodule
