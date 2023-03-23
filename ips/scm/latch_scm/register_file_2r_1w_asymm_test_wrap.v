module register_file_2r_1w_asymm_test_wrap (
	clk,
	ReadEnable_a,
	ReadAddr_a,
	ReadData_a,
	ReadEnable_b,
	ReadAddr_b,
	ReadData_b,
	WriteEnable,
	WriteAddr,
	WriteData,
	WriteBE,
	BIST,
	CSN_T,
	WEN_T,
	A_T,
	D_T,
	BE_T,
	Q_T
);
	parameter ADDR_WIDTH = 5;
	parameter DATA_WIDTH = 32;
	parameter NUM_BYTE = DATA_WIDTH / 8;
	parameter ASYMM_FACTOR = 3;
	input wire clk;
	input wire ReadEnable_a;
	input wire [ADDR_WIDTH - 1:0] ReadAddr_a;
	output wire [DATA_WIDTH - 1:0] ReadData_a;
	input wire ReadEnable_b;
	input wire [ADDR_WIDTH - 1:0] ReadAddr_b;
	output wire [(ASYMM_FACTOR * DATA_WIDTH) - 1:0] ReadData_b;
	input wire WriteEnable;
	input wire [ADDR_WIDTH - 1:0] WriteAddr;
	input wire [(NUM_BYTE * 8) - 1:0] WriteData;
	input wire [NUM_BYTE - 1:0] WriteBE;
	input wire BIST;
	input wire CSN_T;
	input wire WEN_T;
	input wire [ADDR_WIDTH - 1:0] A_T;
	input wire [DATA_WIDTH - 1:0] D_T;
	input wire [NUM_BYTE - 1:0] BE_T;
	output wire [DATA_WIDTH - 1:0] Q_T;
	reg ReadEnable_muxed;
	reg [ADDR_WIDTH - 1:0] ReadAddr_muxed;
	reg WriteEnable_muxed;
	reg [ADDR_WIDTH - 1:0] WriteAddr_muxed;
	reg [DATA_WIDTH - 1:0] WriteData_muxed;
	reg [NUM_BYTE - 1:0] WriteBE_muxed;
	always @(*)
		if (BIST) begin
			ReadEnable_muxed = (CSN_T == 1'b0) && (WEN_T == 1'b1);
			ReadAddr_muxed = A_T;
			WriteEnable_muxed = (CSN_T == 1'b0) && (WEN_T == 1'b0);
			WriteAddr_muxed = A_T;
			WriteData_muxed = D_T;
			WriteBE_muxed = BE_T;
		end
		else begin
			ReadEnable_muxed = ReadEnable_a;
			ReadAddr_muxed = ReadAddr_a;
			WriteEnable_muxed = WriteEnable;
			WriteAddr_muxed = WriteAddr;
			WriteData_muxed = WriteData;
			WriteBE_muxed = WriteBE;
		end
	assign Q_T = ReadData_a;
	register_file_2r_1w_asymm #(
		.ADDR_WIDTH(ADDR_WIDTH),
		.DATA_WIDTH(DATA_WIDTH),
		.NUM_BYTE(NUM_BYTE),
		.ASYMM_FACTOR(ASYMM_FACTOR)
	) register_file_2r_1w_asymm_test_wrap_i(
		.clk(clk),
		.ReadEnable_a(ReadEnable_muxed),
		.ReadAddr_a(ReadAddr_muxed),
		.ReadData_a(ReadData_a),
		.ReadEnable_b(ReadEnable_b),
		.ReadAddr_b(ReadAddr_b),
		.ReadData_b(ReadData_b),
		.WriteEnable(WriteEnable_muxed),
		.WriteAddr(WriteAddr_muxed),
		.WriteData(WriteData_muxed),
		.WriteBE(WriteBE_muxed)
	);
endmodule
