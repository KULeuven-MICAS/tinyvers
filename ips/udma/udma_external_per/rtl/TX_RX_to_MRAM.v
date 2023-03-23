module TX_RX_to_MRAM (
	clk,
	rst_n,
	scan_en_in,
	mram_mode_tx_i,
	mram_mode_rx_i,
	data_tx_wdata_i,
	data_tx_addr_i,
	data_tx_req_i,
	data_tx_eot_i,
	data_tx_gnt_o,
	NVR_tx_i,
	TMEN_tx_i,
	AREF_tx_i,
	data_rx_raddr_i,
	data_rx_clk_en_i,
	data_rx_req_i,
	data_rx_eot_i,
	data_rx_gnt_o,
	data_rx_rdata_o,
	data_rx_error_o,
	NVR_rx_i,
	TMEN_rx_i,
	AREF_rx_i,
	CEb_o,
	A_o,
	DIN_o,
	RDEN_o,
	WEb_o,
	PROGEN_o,
	PROG_o,
	ERASE_o,
	CHIP_o,
	DONE_i,
	DOUT_i,
	CLK_o,
	EC_i,
	UE_i,
	NVR_o,
	TMEN_o,
	AREF_o
);
	input wire clk;
	input wire rst_n;
	input wire scan_en_in;
	input wire [7:0] mram_mode_tx_i;
	input wire [7:0] mram_mode_rx_i;
	input wire [77:0] data_tx_wdata_i;
	input wire [15:0] data_tx_addr_i;
	input wire data_tx_req_i;
	input wire data_tx_eot_i;
	output reg data_tx_gnt_o;
	input wire NVR_tx_i;
	input wire TMEN_tx_i;
	input wire AREF_tx_i;
	input wire [15:0] data_rx_raddr_i;
	input wire data_rx_clk_en_i;
	input wire data_rx_req_i;
	input wire data_rx_eot_i;
	output reg data_rx_gnt_o;
	output wire [63:0] data_rx_rdata_o;
	output reg [1:0] data_rx_error_o;
	input wire NVR_rx_i;
	input wire TMEN_rx_i;
	input wire AREF_rx_i;
	output wire CEb_o;
	output wire [15:0] A_o;
	output wire [77:0] DIN_o;
	output wire RDEN_o;
	output wire WEb_o;
	output wire PROGEN_o;
	output wire PROG_o;
	output wire ERASE_o;
	output wire CHIP_o;
	input wire DONE_i;
	input wire [77:0] DOUT_i;
	output wire CLK_o;
	input wire EC_i;
	input wire UE_i;
	output wire NVR_o;
	output wire TMEN_o;
	output wire AREF_o;
	localparam CLK_PERIOD = 25;
	localparam tPROG_COUNT = 8;
	localparam tPGS_COUNT = 800;
	localparam tADS_COUNT = 4;
	localparam tRW_COUNT = 120;
	localparam tAREF_COUNT = 4;
	localparam CMD_TRIM_CFG = 8'b00000001;
	localparam CMD_NORMAL_TX = 8'b00000010;
	localparam CMD_ERASE_CHIP = 8'b00000100;
	localparam CMD_ERASE_SECT = 8'b00001000;
	localparam CMD_ERASE_WORD = 8'b00010000;
	localparam CMD_PWDN = 8'b00100000;
	localparam CMD_READ_RX = 8'b01000000;
	localparam CMD_REF_LINE_P = 8'b10000000;
	localparam CMD_REF_LINE_AP = 8'b11000000;
	reg [4:0] CS;
	reg [4:0] NS;
	wire DONE_synch;
	reg [15:0] Counter_CS;
	reg [15:0] Counter_NS;
	reg [15:0] Counter_Program;
	reg start_next_prog_timeout;
	wire next_prog_timeout;
	reg is_erase_CS;
	reg is_erase_NS;
	reg is_chip_erase_NS;
	reg is_chip_erase_CS;
	reg CEb_int;
	reg [15:0] A_int;
	reg [77:0] DIN_int;
	reg RDEN_int;
	reg WEb_int;
	reg PROGEN_int;
	reg PROG_int;
	reg ERASE_int;
	reg CHIP_int;
	wire CLK_int;
	wire en_clock_Q;
	assign data_rx_rdata_o = DOUT_i;
	assign CEb_o = CEb_int;
	assign A_o = A_int;
	assign DIN_o = DIN_int;
	assign RDEN_o = RDEN_int;
	assign WEb_o = WEb_int;
	assign PROGEN_o = PROGEN_int;
	assign PROG_o = PROG_int;
	assign ERASE_o = ERASE_int;
	assign CHIP_o = CHIP_int;
	assign en_clock_Q = data_rx_clk_en_i;
	pulp_sync i_DONE_synchronizer(
		.clk_i(clk),
		.rstn_i(rst_n),
		.serial_i(DONE_i),
		.serial_o(DONE_synch)
	);
	cluster_clock_gating i_CLK_out_CG(
		.clk_i(clk),
		.en_i(en_clock_Q && ~scan_en_in),
		.test_en_i(1'b0),
		.clk_o(CLK_o)
	);
	assign next_prog_timeout = Counter_Program == 0;
	always @(posedge clk or negedge rst_n) begin : proc_seq_CNTs
		if (~rst_n) begin
			Counter_CS <= 1'sb0;
			Counter_Program <= tRW_COUNT;
		end
		else begin
			Counter_CS <= Counter_NS;
			if (start_next_prog_timeout == 1'b1)
				Counter_Program <= tRW_COUNT;
			else if (Counter_Program > 0)
				Counter_Program <= Counter_Program - 1'b1;
		end
	end
	always @(posedge clk or negedge rst_n) begin : proc_seq_FSM
		if (~rst_n) begin
			CS <= 5'd7;
			is_erase_CS = 1'b0;
			is_chip_erase_CS = 1'b0;
		end
		else begin
			CS <= NS;
			is_erase_CS = is_erase_NS;
			is_chip_erase_CS = is_chip_erase_NS;
		end
	end
	assign NVR_o = (CS == 5'd7 ? 1'b0 : ((CS == 5'd10) | (CS == 5'd11) ? NVR_rx_i : NVR_tx_i));
	assign TMEN_o = (CS == 5'd7 ? 1'b0 : ((CS == 5'd10) | (CS == 5'd11) ? TMEN_rx_i : TMEN_tx_i));
	assign AREF_o = (CS == 5'd7 ? 1'b0 : ((CS == 5'd10) | (CS == 5'd11) ? AREF_rx_i : AREF_tx_i));
	always @(*) begin
		CEb_int = 1'b1;
		WEb_int = 1'b1;
		A_int = 1'sb0;
		PROGEN_int = 1'b0;
		PROG_int = 1'b0;
		ERASE_int = 1'b0;
		CHIP_int = 1'b0;
		DIN_int = 1'sb0;
		RDEN_int = 1'b0;
		data_tx_gnt_o = 1'b0;
		data_rx_gnt_o = 1'b0;
		data_rx_error_o = 2'b00;
		start_next_prog_timeout = 1'b0;
		Counter_NS = Counter_CS;
		NS = CS;
		is_erase_NS = is_erase_CS;
		is_chip_erase_NS = is_chip_erase_CS;
		case (CS)
			5'd7: begin
				Counter_NS = 1'sb0;
				if (data_tx_req_i) begin
					NS = (next_prog_timeout ? 5'd3 : 5'd6);
					is_erase_NS = (((mram_mode_tx_i == CMD_ERASE_CHIP) || (mram_mode_tx_i == CMD_ERASE_SECT)) || (mram_mode_tx_i == CMD_ERASE_WORD)) || (mram_mode_tx_i == CMD_REF_LINE_AP);
					is_chip_erase_NS = mram_mode_tx_i == CMD_ERASE_CHIP;
				end
				else if (data_rx_req_i) begin
					data_rx_gnt_o = 1'b0;
					NS = 5'd11;
				end
				else
					NS = 5'd7;
			end
			5'd6: begin
				data_tx_gnt_o = 1'b0;
				Counter_NS = 1'sb0;
				if (next_prog_timeout)
					NS = 5'd2;
				else
					NS = 5'd6;
			end
			5'd11: begin
				CEb_int = 1'b0;
				WEb_int = 1'b1;
				A_int = data_rx_raddr_i;
				RDEN_int = data_rx_req_i;
				data_rx_gnt_o = 1'b1;
				data_rx_error_o = {EC_i, UE_i};
				if (data_rx_eot_i)
					NS = 5'd10;
				else
					NS = 5'd11;
			end
			5'd10: begin
				data_rx_gnt_o = 1'b0;
				CEb_int = 1'b0;
				WEb_int = 1'b1;
				RDEN_int = 1'b0;
				data_rx_error_o = {EC_i, UE_i};
				NS = 5'd7;
			end
			5'd3: begin
				CHIP_int = is_chip_erase_CS;
				if (Counter_CS < tAREF_COUNT) begin
					Counter_NS = Counter_CS + 1'b1;
					NS = 5'd3;
				end
				else begin
					Counter_NS = 1'sb0;
					NS = 5'd2;
				end
			end
			5'd2: begin
				CHIP_int = is_chip_erase_CS;
				CEb_int = 1'b0;
				Counter_NS = 1'sb0;
				NS = 5'd0;
			end
			5'd0: begin
				CEb_int = 1'b0;
				WEb_int = 1'b0;
				PROG_int = ~is_erase_CS;
				ERASE_int = is_erase_CS;
				CHIP_int = is_chip_erase_CS;
				A_int = data_tx_addr_i;
				DIN_int = data_tx_wdata_i;
				if (Counter_CS < tPGS_COUNT) begin
					Counter_NS = Counter_CS + 1'b1;
					NS = 5'd0;
				end
				else begin
					Counter_NS = 1'sb0;
					NS = 5'd4;
				end
			end
			5'd4: begin
				CEb_int = 1'b0;
				WEb_int = 1'b0;
				PROG_int = ~is_erase_CS;
				ERASE_int = is_erase_CS;
				CHIP_int = is_chip_erase_CS;
				A_int = data_tx_addr_i;
				DIN_int = data_tx_wdata_i;
				PROGEN_int = 1'b1;
				NS = 5'd5;
			end
			5'd5: begin
				CEb_int = 1'b0;
				WEb_int = 1'b0;
				PROG_int = ~is_erase_CS;
				ERASE_int = is_erase_CS;
				CHIP_int = is_chip_erase_CS;
				A_int = data_tx_addr_i;
				DIN_int = data_tx_wdata_i;
				PROGEN_int = 1'b1;
				Counter_NS = 1'sb0;
				NS = 5'd1;
			end
			5'd1: begin
				CEb_int = 1'b0;
				WEb_int = 1'b0;
				PROG_int = ~is_erase_CS;
				ERASE_int = is_erase_CS;
				CHIP_int = is_chip_erase_CS;
				A_int = data_tx_addr_i;
				DIN_int = data_tx_wdata_i;
				PROGEN_int = 1'b1;
				Counter_NS = 1'sb0;
				data_tx_gnt_o = DONE_synch;
				if (DONE_synch) begin
					if (data_tx_eot_i) begin
						NS = 5'd9;
						is_erase_NS = 1'b0;
						start_next_prog_timeout = 1'b1;
					end
					else
						NS = 5'd13;
				end
				else
					NS = 5'd1;
			end
			5'd13: begin
				CEb_int = 1'b0;
				WEb_int = 1'b0;
				PROG_int = ~is_erase_CS;
				ERASE_int = is_erase_CS;
				CHIP_int = is_chip_erase_CS;
				A_int = data_tx_addr_i;
				DIN_int = data_tx_wdata_i;
				Counter_NS = 1'sb0;
				if (data_tx_req_i)
					NS = 5'd12;
				else
					NS = 5'd13;
			end
			5'd12: begin
				CEb_int = 1'b0;
				WEb_int = 1'b0;
				PROG_int = ~is_erase_CS;
				ERASE_int = is_erase_CS;
				CHIP_int = is_chip_erase_CS;
				A_int = data_tx_addr_i;
				DIN_int = data_tx_wdata_i;
				if (Counter_CS < tADS_COUNT) begin
					Counter_NS = Counter_CS + 1'b1;
					NS = 5'd12;
				end
				else begin
					Counter_NS = 1'sb0;
					NS = 5'd4;
				end
			end
			5'd9: begin
				CEb_int = 1'b0;
				WEb_int = 1'b1;
				is_erase_NS = 1'b0;
				is_chip_erase_NS = 1'b0;
				CHIP_int = 1'b0;
				PROG_int = 1'b0;
				ERASE_int = 1'b0;
				A_int = data_tx_addr_i;
				DIN_int = data_tx_wdata_i;
				PROGEN_int = 1'b0;
				if (Counter_CS < tAREF_COUNT) begin
					Counter_NS = Counter_CS + 1'b1;
					NS = 5'd9;
				end
				else begin
					Counter_NS = 1'sb0;
					NS = 5'd7;
				end
			end
		endcase
	end
endmodule
