module i2s_vip_channel (
	rst,
	enable_i,
	pdm_ddr_i,
	pdm_en_i,
	lsb_first_i,
	transf_size_i,
	i2s_snap_enable_i,
	mode_i,
	sck_i,
	ws_i,
	data_o,
	sck_o,
	ws_o
);
	parameter I2S_CHAN = 4'h1;
	parameter COUNT_WIDTH = 10;
	parameter FILENAME = "i2s_buffer.hex";
	parameter BUFFER_SIZE = 4096;
	parameter PACKET_SIZE = 32;
	parameter SCK_PERIOD = 20;
	input wire rst;
	input wire enable_i;
	input wire pdm_ddr_i;
	input wire pdm_en_i;
	input wire lsb_first_i;
	input wire [1:0] transf_size_i;
	input wire i2s_snap_enable_i;
	input wire mode_i;
	input wire sck_i;
	input wire ws_i;
	output reg data_o;
	output reg sck_o;
	output reg ws_o;
	localparam PACKET_LOG_2 = $clog2(PACKET_SIZE);
	localparam ROW_SIZE = $clog2(BUFFER_SIZE);
	localparam DELAY_INT_MASTER = SCK_PERIOD;
	localparam DELAY_INT_SLAVE = 375;
	localparam NUM_TRANSFER = 128;
	localparam TRASF_ORDER = "LSB_FIRST";
	localparam TRASF_SIZE = 16;
	localparam DDR_MODE = "FALSE";
	reg [31:0] SIGNATURE_32;
	reg [31:0] SIGNATURE_8;
	reg [31:0] SIGNATURE_16;
	reg [31:0] SIGNATURE_8_DDR;
	reg [31:0] SIGNATURE_16_DDR;
	reg [31:0] index;
	wire [31:0] i;
	wire [31:0] j;
	wire [31:0] k;
	wire [PACKET_SIZE - 1:0] DATA_STD;
	wire [PACKET_SIZE - 1:0] DATA_PDM;
	wire [PACKET_SIZE - 1:0] DATA_SNAP;
	reg [PACKET_SIZE - 1:0] SHIFT_REG_STD;
	reg [PACKET_SIZE - 1:0] SHIFT_REG_PDM;
	wire [PACKET_SIZE - 1:0] SHIFT_REG_SNAP;
	reg [PACKET_LOG_2 - 1:0] BIT_POINTER;
	reg WSQ;
	reg WSQQ;
	wire WSP;
	reg [ROW_SIZE - 1:0] COUNTER_ROW_STD;
	reg [ROW_SIZE - 1:0] COUNTER_ROW_PDM;
	reg do_load;
	wire sck;
	wire ws;
	reg sck_int = 1'b0;
	reg ws_int;
	reg [((BUFFER_SIZE * (PACKET_SIZE / 8)) * 8) - 1:0] my_memory;
	reg [31:0] my_memory_16 [0:BUFFER_SIZE - 1];
	reg [31:0] my_memory_8 [0:BUFFER_SIZE - 1];
	reg [(BUFFER_SIZE * 32) - 1:0] my_memory_32;
	wire [((PACKET_SIZE / 8) * 8) - 1:0] my_memory_ddr_L [0:BUFFER_SIZE - 1];
	wire [((PACKET_SIZE / 8) * 8) - 1:0] my_memory_ddr_R [0:BUFFER_SIZE - 1];
	reg [15:0] my_memory_16_ddr_L [0:BUFFER_SIZE - 1];
	reg [15:0] my_memory_16_ddr_R [0:BUFFER_SIZE - 1];
	reg [31:0] my_memory_Merged_16 [0:BUFFER_SIZE - 1];
	reg [7:0] my_memory_8_ddr_L [0:BUFFER_SIZE - 1];
	reg [7:0] my_memory_8_ddr_R [0:BUFFER_SIZE - 1];
	reg [31:0] my_memory_Merged_8 [0:BUFFER_SIZE - 1];
	wire [31:0] my_memory_8_ddr [0:BUFFER_SIZE - 1];
	reg [31:0] COUNT_BIT_STD;
	reg [31:0] COUNT_PACKET;
	reg [2:0] CS_SNAP;
	reg [2:0] NS_SNAP;
	reg [31:0] COUNTER_SNAP_CS;
	reg [31:0] COUNTER_SNAP_NS;
	reg [31:0] COUNTER_ROW_SNAP_CS;
	reg [31:0] COUNTER_ROW_SNAP_NS;
	reg ws_snap;
	wire clk_snap;
	reg data_snap_int;
	reg clk_gen;
	reg clk_snap_en;
	initial begin
		WSQ = 0;
		WSQQ = 1'sb0;
		COUNTER_ROW_STD = 1'sb0;
		COUNTER_ROW_PDM = 1'sb0;
		SIGNATURE_32 = 1'sb0;
		SIGNATURE_16 = 1'sb0;
		SIGNATURE_16_DDR = 1'sb0;
		SIGNATURE_8 = 1'sb0;
		SIGNATURE_8_DDR = 1'sb0;
		do_load = 1'sb0;
		$readmemh(FILENAME, my_memory);
		my_memory_32 = my_memory;
		for (index = 0; index < NUM_TRANSFER; index = index + 1)
			case (TRASF_SIZE)
				16: begin
					if (TRASF_ORDER == "MSB_FIRST") begin
						my_memory_16[index >> 1][index[0] * 16+:16] = my_memory[8 * ((((BUFFER_SIZE - 1) - index) * (PACKET_SIZE / 8)) + 2)+:16];
						my_memory_16_ddr_L[index] = {my_memory_32[(((BUFFER_SIZE - 1) - (2 * index)) * 32) + 31], my_memory_32[(((BUFFER_SIZE - 1) - (2 * index)) * 32) + 29], my_memory_32[(((BUFFER_SIZE - 1) - (2 * index)) * 32) + 27], my_memory_32[(((BUFFER_SIZE - 1) - (2 * index)) * 32) + 25], my_memory_32[(((BUFFER_SIZE - 1) - (2 * index)) * 32) + 23], my_memory_32[(((BUFFER_SIZE - 1) - (2 * index)) * 32) + 21], my_memory_32[(((BUFFER_SIZE - 1) - (2 * index)) * 32) + 19], my_memory_32[(((BUFFER_SIZE - 1) - (2 * index)) * 32) + 17], my_memory_32[(((BUFFER_SIZE - 1) - ((2 * index) + 1)) * 32) + 31], my_memory_32[(((BUFFER_SIZE - 1) - ((2 * index) + 1)) * 32) + 29], my_memory_32[(((BUFFER_SIZE - 1) - ((2 * index) + 1)) * 32) + 27], my_memory_32[(((BUFFER_SIZE - 1) - ((2 * index) + 1)) * 32) + 25], my_memory_32[(((BUFFER_SIZE - 1) - ((2 * index) + 1)) * 32) + 23], my_memory_32[(((BUFFER_SIZE - 1) - ((2 * index) + 1)) * 32) + 21], my_memory_32[(((BUFFER_SIZE - 1) - ((2 * index) + 1)) * 32) + 19], my_memory_32[(((BUFFER_SIZE - 1) - ((2 * index) + 1)) * 32) + 17]};
						my_memory_16_ddr_R[index] = {my_memory_32[(((BUFFER_SIZE - 1) - (2 * index)) * 32) + 30], my_memory_32[(((BUFFER_SIZE - 1) - (2 * index)) * 32) + 28], my_memory_32[(((BUFFER_SIZE - 1) - (2 * index)) * 32) + 26], my_memory_32[(((BUFFER_SIZE - 1) - (2 * index)) * 32) + 24], my_memory_32[(((BUFFER_SIZE - 1) - (2 * index)) * 32) + 22], my_memory_32[(((BUFFER_SIZE - 1) - (2 * index)) * 32) + 20], my_memory_32[(((BUFFER_SIZE - 1) - (2 * index)) * 32) + 18], my_memory_32[(((BUFFER_SIZE - 1) - (2 * index)) * 32) + 16], my_memory_32[(((BUFFER_SIZE - 1) - ((2 * index) + 1)) * 32) + 30], my_memory_32[(((BUFFER_SIZE - 1) - ((2 * index) + 1)) * 32) + 28], my_memory_32[(((BUFFER_SIZE - 1) - ((2 * index) + 1)) * 32) + 26], my_memory_32[(((BUFFER_SIZE - 1) - ((2 * index) + 1)) * 32) + 24], my_memory_32[(((BUFFER_SIZE - 1) - ((2 * index) + 1)) * 32) + 22], my_memory_32[(((BUFFER_SIZE - 1) - ((2 * index) + 1)) * 32) + 20], my_memory_32[(((BUFFER_SIZE - 1) - ((2 * index) + 1)) * 32) + 18], my_memory_32[(((BUFFER_SIZE - 1) - ((2 * index) + 1)) * 32) + 16]};
					end
					else
						my_memory_16[index >> 1][index[0] * 16+:16] = my_memory[8 * ((((BUFFER_SIZE - 1) - index) * (PACKET_SIZE / 8)) + 0)+:16];
					my_memory_16_ddr_L[index] = {my_memory_32[(((BUFFER_SIZE - 1) - (2 * index)) * 32) + 15], my_memory_32[(((BUFFER_SIZE - 1) - (2 * index)) * 32) + 13], my_memory_32[(((BUFFER_SIZE - 1) - (2 * index)) * 32) + 11], my_memory_32[(((BUFFER_SIZE - 1) - (2 * index)) * 32) + 9], my_memory_32[(((BUFFER_SIZE - 1) - (2 * index)) * 32) + 7], my_memory_32[(((BUFFER_SIZE - 1) - (2 * index)) * 32) + 5], my_memory_32[(((BUFFER_SIZE - 1) - (2 * index)) * 32) + 3], my_memory_32[(((BUFFER_SIZE - 1) - (2 * index)) * 32) + 1], my_memory_32[(((BUFFER_SIZE - 1) - ((2 * index) + 1)) * 32) + 15], my_memory_32[(((BUFFER_SIZE - 1) - ((2 * index) + 1)) * 32) + 13], my_memory_32[(((BUFFER_SIZE - 1) - ((2 * index) + 1)) * 32) + 11], my_memory_32[(((BUFFER_SIZE - 1) - ((2 * index) + 1)) * 32) + 9], my_memory_32[(((BUFFER_SIZE - 1) - ((2 * index) + 1)) * 32) + 7], my_memory_32[(((BUFFER_SIZE - 1) - ((2 * index) + 1)) * 32) + 5], my_memory_32[(((BUFFER_SIZE - 1) - ((2 * index) + 1)) * 32) + 3], my_memory_32[(((BUFFER_SIZE - 1) - ((2 * index) + 1)) * 32) + 1]};
					my_memory_16_ddr_R[index] = {my_memory_32[(((BUFFER_SIZE - 1) - (2 * index)) * 32) + 14], my_memory_32[(((BUFFER_SIZE - 1) - (2 * index)) * 32) + 12], my_memory_32[(((BUFFER_SIZE - 1) - (2 * index)) * 32) + 10], my_memory_32[(((BUFFER_SIZE - 1) - (2 * index)) * 32) + 8], my_memory_32[(((BUFFER_SIZE - 1) - (2 * index)) * 32) + 6], my_memory_32[(((BUFFER_SIZE - 1) - (2 * index)) * 32) + 4], my_memory_32[(((BUFFER_SIZE - 1) - (2 * index)) * 32) + 2], my_memory_32[((BUFFER_SIZE - 1) - (2 * index)) * 32], my_memory_32[(((BUFFER_SIZE - 1) - ((2 * index) + 1)) * 32) + 14], my_memory_32[(((BUFFER_SIZE - 1) - ((2 * index) + 1)) * 32) + 12], my_memory_32[(((BUFFER_SIZE - 1) - ((2 * index) + 1)) * 32) + 10], my_memory_32[(((BUFFER_SIZE - 1) - ((2 * index) + 1)) * 32) + 8], my_memory_32[(((BUFFER_SIZE - 1) - ((2 * index) + 1)) * 32) + 6], my_memory_32[(((BUFFER_SIZE - 1) - ((2 * index) + 1)) * 32) + 4], my_memory_32[(((BUFFER_SIZE - 1) - ((2 * index) + 1)) * 32) + 2], my_memory_32[((BUFFER_SIZE - 1) - ((2 * index) + 1)) * 32]};
				end
				8:
					if (TRASF_ORDER == "MSB_FIRST") begin
						my_memory_8[index >> 2][index[1:0] * 8+:8] = my_memory[((((BUFFER_SIZE - 1) - index) * (PACKET_SIZE / 8)) + 3) * 8+:8];
						my_memory_8_ddr_L[index] = {my_memory_32[(((BUFFER_SIZE - 1) - (2 * index)) * 32) + 31], my_memory_32[(((BUFFER_SIZE - 1) - (2 * index)) * 32) + 29], my_memory_32[(((BUFFER_SIZE - 1) - (2 * index)) * 32) + 27], my_memory_32[(((BUFFER_SIZE - 1) - (2 * index)) * 32) + 25], my_memory_32[(((BUFFER_SIZE - 1) - ((2 * index) + 1)) * 32) + 31], my_memory_32[(((BUFFER_SIZE - 1) - ((2 * index) + 1)) * 32) + 29], my_memory_32[(((BUFFER_SIZE - 1) - ((2 * index) + 1)) * 32) + 27], my_memory_32[(((BUFFER_SIZE - 1) - ((2 * index) + 1)) * 32) + 25]};
						my_memory_8_ddr_R[index] = {my_memory_32[(((BUFFER_SIZE - 1) - (2 * index)) * 32) + 30], my_memory_32[(((BUFFER_SIZE - 1) - (2 * index)) * 32) + 28], my_memory_32[(((BUFFER_SIZE - 1) - (2 * index)) * 32) + 26], my_memory_32[(((BUFFER_SIZE - 1) - (2 * index)) * 32) + 24], my_memory_32[(((BUFFER_SIZE - 1) - ((2 * index) + 1)) * 32) + 30], my_memory_32[(((BUFFER_SIZE - 1) - ((2 * index) + 1)) * 32) + 28], my_memory_32[(((BUFFER_SIZE - 1) - ((2 * index) + 1)) * 32) + 26], my_memory_32[(((BUFFER_SIZE - 1) - ((2 * index) + 1)) * 32) + 24]};
					end
					else begin
						my_memory_8[index >> 2][index[1:0] * 8+:8] = my_memory[(((BUFFER_SIZE - 1) - index) * (PACKET_SIZE / 8)) * 8+:8];
						my_memory_8_ddr_L[index] = {my_memory_32[(((BUFFER_SIZE - 1) - (2 * index)) * 32) + 7], my_memory_32[(((BUFFER_SIZE - 1) - (2 * index)) * 32) + 5], my_memory_32[(((BUFFER_SIZE - 1) - (2 * index)) * 32) + 3], my_memory_32[(((BUFFER_SIZE - 1) - (2 * index)) * 32) + 1], my_memory_32[(((BUFFER_SIZE - 1) - ((2 * index) + 1)) * 32) + 7], my_memory_32[(((BUFFER_SIZE - 1) - ((2 * index) + 1)) * 32) + 5], my_memory_32[(((BUFFER_SIZE - 1) - ((2 * index) + 1)) * 32) + 3], my_memory_32[(((BUFFER_SIZE - 1) - ((2 * index) + 1)) * 32) + 1], my_memory_32[(((BUFFER_SIZE - 1) - ((2 * index) + 2)) * 32) + 7]};
						my_memory_8_ddr_R[index] = {my_memory_32[(((BUFFER_SIZE - 1) - (2 * index)) * 32) + 6], my_memory_32[(((BUFFER_SIZE - 1) - (2 * index)) * 32) + 4], my_memory_32[(((BUFFER_SIZE - 1) - (2 * index)) * 32) + 2], my_memory_32[((BUFFER_SIZE - 1) - (2 * index)) * 32], my_memory_32[(((BUFFER_SIZE - 1) - ((2 * index) + 1)) * 32) + 6], my_memory_32[(((BUFFER_SIZE - 1) - ((2 * index) + 1)) * 32) + 4], my_memory_32[(((BUFFER_SIZE - 1) - ((2 * index) + 1)) * 32) + 2], my_memory_32[((BUFFER_SIZE - 1) - ((2 * index) + 1)) * 32]};
					end
				default:
					;
			endcase
		for (index = 0; index < NUM_TRANSFER; index = index + 1)
			case (TRASF_SIZE)
				32:
					;
				16:
					if (TRASF_ORDER == "MSB_FIRST") begin
						my_memory_Merged_16[index][31:16] = my_memory_16_ddr_R[index];
						my_memory_Merged_16[index][15:0] = my_memory_16_ddr_L[index];
					end
					else begin
						my_memory_Merged_16[index][31:16] = my_memory_16_ddr_R[index];
						my_memory_Merged_16[index][15:0] = my_memory_16_ddr_L[index];
					end
				8:
					if (TRASF_ORDER == "MSB_FIRST") begin
						my_memory_Merged_8[index][31:24] = my_memory_8_ddr_R[(2 * index) + 1];
						my_memory_Merged_8[index][23:16] = my_memory_8_ddr_L[(2 * index) + 1];
						my_memory_Merged_8[index][15:8] = my_memory_8_ddr_R[2 * index];
						my_memory_Merged_8[index][7:0] = my_memory_8_ddr_L[2 * index];
					end
					else begin
						my_memory_Merged_8[index][31:24] = my_memory_8_ddr_R[(2 * index) + 1];
						my_memory_Merged_8[index][23:16] = my_memory_8_ddr_L[(2 * index) + 1];
						my_memory_Merged_8[index][15:8] = my_memory_8_ddr_R[2 * index];
						my_memory_Merged_8[index][7:0] = my_memory_8_ddr_L[2 * index];
					end
			endcase
		case (TRASF_SIZE)
			16:
				for (index = 1; index < 64; index = index + 1)
					begin
						SIGNATURE_16_DDR = my_memory_Merged_16[index] ^ SIGNATURE_16_DDR;
						SIGNATURE_16 = my_memory_16[index] ^ SIGNATURE_16;
					end
			8:
				for (index = 1; index < 32; index = index + 1)
					begin
						SIGNATURE_8_DDR = my_memory_Merged_8[index] ^ SIGNATURE_8_DDR;
						SIGNATURE_8 = my_memory_8[index] ^ SIGNATURE_8;
					end
			default:
				for (index = 1; index < NUM_TRANSFER; index = index + 1)
					SIGNATURE_32 = my_memory[8 * (((BUFFER_SIZE - 1) - index) * (PACKET_SIZE / 8))+:8 * (PACKET_SIZE / 8)] ^ SIGNATURE_32;
		endcase
	end
	assign sck = (mode_i ? sck_i : sck_int);
	assign ws = (mode_i ? ws_i : ws_int);
	always begin
		#(SCK_PERIOD / 2)
			;
		sck_int = (rst ? 1'b0 : (~sck_int & ~mode_i) & enable_i);
	end
	always @(*)
		if (enable_i)
			if ((i2s_snap_enable_i & ~pdm_en_i) & ~mode_i) begin
				sck_o = clk_snap;
				ws_o = ws_snap;
			end
			else if (mode_i) begin
				sck_o = 1'bz;
				ws_o = 1'bz;
			end
			else begin
				sck_o = sck_int;
				ws_o = ws_int;
			end
	always @(*)
		case (transf_size_i)
			2'b00: COUNT_PACKET = 8;
			2'b10: COUNT_PACKET = 16;
			2'b11: COUNT_PACKET = 32;
		endcase
	assign DATA_STD = (WSP ? my_memory[8 * (((BUFFER_SIZE - 1) - (COUNTER_ROW_STD + 1)) * (PACKET_SIZE / 8))+:8 * (PACKET_SIZE / 8)] : my_memory[8 * (((BUFFER_SIZE - 1) - COUNTER_ROW_STD) * (PACKET_SIZE / 8))+:8 * (PACKET_SIZE / 8)]);
	assign DATA_PDM = my_memory[8 * (((BUFFER_SIZE - 1) - COUNTER_ROW_PDM) * (PACKET_SIZE / 8))+:8 * (PACKET_SIZE / 8)];
	always @(negedge sck or posedge rst)
		if (rst) begin
			COUNTER_ROW_STD <= 0;
			COUNT_BIT_STD <= 0;
			ws_int <= 1'b0;
		end
		else
			case ({mode_i, enable_i, pdm_en_i})
				3'b110: begin
					ws_int <= 1'b0;
					if (WSP) begin
						COUNT_BIT_STD <= 0;
						COUNTER_ROW_STD <= COUNTER_ROW_STD + 1;
					end
					else
						COUNT_BIT_STD <= COUNT_BIT_STD + 1;
				end
				3'b010: begin
					ws_int <= 1'b0;
					if (COUNT_BIT_STD < (COUNT_PACKET - 1)) begin
						COUNT_BIT_STD <= COUNT_BIT_STD + 1;
						if (COUNT_BIT_STD == (COUNT_PACKET - 2))
							ws_int <= ~ws_int;
						else
							ws_int <= ws_int;
					end
					else if (COUNT_BIT_STD == (COUNT_PACKET - 1)) begin
						COUNT_BIT_STD <= 0;
						COUNTER_ROW_STD <= COUNTER_ROW_STD + 1;
						ws_int <= ws_int;
					end
				end
			endcase
	always @(negedge sck or posedge rst) begin : _COMPUTE_WSP_
		if (rst) begin
			WSQ <= 0;
			WSQQ <= 0;
		end
		else begin
			WSQ <= ws;
			WSQQ <= WSQ;
		end
	end
	assign #(1) WSP = ws ^ WSQ;
	wire rst_dly;
	assign #(1.2) rst_dly = rst;
	always @(negedge sck or posedge rst_dly) begin : _SHIFT_REG_STD_
		if (rst) begin : _RESET_SR_
			SHIFT_REG_STD <= DATA_STD;
		end
		else if (pdm_en_i == 1'b0) begin
			if (WSP) begin : _LOAD_SR_STD_
				SHIFT_REG_STD <= DATA_STD;
			end
			else begin : _SHIFT_
				if (lsb_first_i) begin : _PUSH_LSB_FIRST_STD_
					SHIFT_REG_STD[PACKET_SIZE - 2:0] <= SHIFT_REG_STD[PACKET_SIZE - 1:1];
					SHIFT_REG_STD[PACKET_SIZE - 1] <= 0;
				end
				else begin : _PUSH_MSB_FIRST_STD_
					SHIFT_REG_STD[PACKET_SIZE - 1:1] <= SHIFT_REG_STD[PACKET_SIZE - 2:0];
					SHIFT_REG_STD[0] <= 0;
				end
			end
		end
		else
			SHIFT_REG_STD <= 1'sb0;
	end
	always @(posedge sck or posedge rst) begin : _SW_SR_
		if (rst) begin : _RESET_BIT_CNT_
			BIT_POINTER <= 0;
			COUNTER_ROW_PDM <= 1'sb0;
		end
		else if (pdm_en_i) begin
			if (pdm_ddr_i) begin
				if (BIT_POINTER == ((COUNT_PACKET / 2) - 1)) begin : _CLEAR_BIT_CNT_DDR_
					BIT_POINTER <= 1'sb0;
				end
				else if (BIT_POINTER == ((COUNT_PACKET / 2) - 2)) begin
					COUNTER_ROW_PDM <= COUNTER_ROW_PDM + 1'b1;
					BIT_POINTER <= BIT_POINTER + 1;
				end
				else begin : _INCR_BIT_CNT_DDR_
					BIT_POINTER <= BIT_POINTER + 1;
				end
			end
			else if (BIT_POINTER == (COUNT_PACKET - 1)) begin : _CLEAR_BIT_CNT_
				BIT_POINTER <= 1'sb0;
				COUNTER_ROW_PDM <= COUNTER_ROW_PDM + 1'b1;
			end
			else begin : _INCR_BIT_CNT_
				BIT_POINTER <= BIT_POINTER + 1;
			end
		end
		else begin
			BIT_POINTER <= 1'sb0;
			COUNTER_ROW_PDM <= 1'sb0;
		end
	end
	always @(posedge sck or posedge rst) begin : proc_do_load
		if (rst)
			do_load <= 0;
		else if (((pdm_ddr_i == 1'b1) && (BIT_POINTER == ((COUNT_PACKET / 2) - 1))) || ((pdm_ddr_i == 1'b0) && (BIT_POINTER == (COUNT_PACKET - 1)))) begin : _LOAD_SR_PDM_
			do_load <= 1'b1;
		end
		else
			do_load <= 1'b0;
	end
	always @(negedge sck or posedge sck or posedge rst) begin : _SHIFT_REG_PDM_
		if (rst) begin : _RESET_SR_PDM_
			begin : _SDR_LOAD_
				SHIFT_REG_PDM[PACKET_SIZE - 1:0] <= DATA_PDM;
			end
		end
		else if (do_load & ~sck) begin : _LOAD_PDM_
			SHIFT_REG_PDM <= DATA_PDM;
		end
		else begin : _SHIFT_PDM_
			if (pdm_ddr_i) begin : _PDM_DDR_
				if (lsb_first_i) begin : _PUSH_LSB_FIRST_
					SHIFT_REG_PDM[PACKET_SIZE - 2:0] <= SHIFT_REG_PDM[PACKET_SIZE - 1:1];
					SHIFT_REG_PDM[PACKET_SIZE - 1] <= 0;
				end
				else begin : _PUSH_MSB_FIRST_
					SHIFT_REG_PDM[PACKET_SIZE - 1:1] <= SHIFT_REG_PDM[PACKET_SIZE - 2:0];
					SHIFT_REG_PDM[0] <= 0;
				end
			end
			else begin : _PDM_SDR_
				if (sck == 1'b0)
					if (lsb_first_i) begin : _PUSH_LSB_FIRST_
						SHIFT_REG_PDM[PACKET_SIZE - 2:0] <= SHIFT_REG_PDM[PACKET_SIZE - 1:1];
					end
					else begin : _PUSH_MSB_FIRST_
						SHIFT_REG_PDM[PACKET_SIZE - 1:1] <= SHIFT_REG_PDM[PACKET_SIZE - 2:0];
					end
			end
		end
	end
	always @(*) begin : proc_data_o
		if (pdm_en_i) begin
			if (pdm_ddr_i) begin
				if (mode_i == 1'b1)
					#(DELAY_INT_SLAVE / 4.0) data_o = (lsb_first_i ? SHIFT_REG_PDM[0] : SHIFT_REG_PDM[PACKET_SIZE - 1]);
				else
					#(DELAY_INT_MASTER / 4.0) data_o = (lsb_first_i ? SHIFT_REG_PDM[0] : SHIFT_REG_PDM[PACKET_SIZE - 1]);
			end
			else if (mode_i == 1'b1)
				data_o = (lsb_first_i ? SHIFT_REG_PDM[0] : SHIFT_REG_PDM[PACKET_SIZE - 1]);
			else
				data_o = (lsb_first_i ? SHIFT_REG_PDM[0] : SHIFT_REG_PDM[PACKET_SIZE - 1]);
		end
		else if (mode_i == 1'b1)
			data_o = (lsb_first_i ? SHIFT_REG_STD[0] : SHIFT_REG_STD[PACKET_SIZE - 1]);
		else if (i2s_snap_enable_i)
			data_o = data_snap_int;
		else
			data_o = (lsb_first_i ? SHIFT_REG_STD[0] : SHIFT_REG_STD[PACKET_SIZE - 1]);
	end
	assign DATA_SNAP = my_memory[8 * (((BUFFER_SIZE - 1) - COUNTER_ROW_SNAP_CS) * (PACKET_SIZE / 8))+:8 * (PACKET_SIZE / 8)];
	initial clk_gen = 0;
	always #(20) clk_gen = ~clk_gen;
	assign clk_snap = (clk_snap_en ? clk_gen : 1'b0);
	always @(negedge clk_gen or posedge rst)
		if (rst) begin
			CS_SNAP <= 3'd0;
			COUNTER_SNAP_CS <= 1'sb0;
			COUNTER_ROW_SNAP_CS <= 1'sb0;
		end
		else begin
			CS_SNAP <= NS_SNAP;
			COUNTER_SNAP_CS <= COUNTER_SNAP_NS;
			COUNTER_ROW_SNAP_CS <= COUNTER_ROW_SNAP_NS;
		end
	always @(*) begin
		ws_snap = 1'b1;
		COUNTER_ROW_SNAP_NS = COUNTER_ROW_SNAP_CS;
		data_snap_int = 1'sb0;
		COUNTER_SNAP_NS = COUNTER_SNAP_CS;
		NS_SNAP = CS_SNAP;
		clk_snap_en = 1'b0;
		case (CS_SNAP)
			3'd0: begin
				if (((enable_i & ~mode_i) & ~pdm_en_i) & i2s_snap_enable_i)
					NS_SNAP = 3'd1;
				else
					NS_SNAP = 3'd0;
				COUNTER_SNAP_NS = 1'sb0;
				ws_snap = 1'b1;
				COUNTER_ROW_SNAP_NS = 1'sb0;
				clk_snap_en = 1'b0;
			end
			3'd1: begin
				NS_SNAP = 3'd2;
				COUNTER_SNAP_NS = 1'sb0;
				ws_snap = 1'b1;
				COUNTER_ROW_SNAP_NS = 0;
				clk_snap_en = 1'b1;
			end
			3'd2: begin
				NS_SNAP = 3'd3;
				COUNTER_SNAP_NS = 1'sb0;
				ws_snap = 1'b0;
				COUNTER_ROW_SNAP_NS = 0;
				clk_snap_en = 1'b1;
			end
			3'd3: begin
				if (lsb_first_i)
					data_snap_int = DATA_SNAP[COUNTER_SNAP_CS];
				else
					data_snap_int = DATA_SNAP[(PACKET_SIZE - COUNTER_SNAP_CS) - 1];
				clk_snap_en = 1'b1;
				if (COUNTER_SNAP_NS == (COUNT_PACKET - 1)) begin
					COUNTER_SNAP_NS = 0;
					NS_SNAP = 3'd4;
					ws_snap = 1'b1;
				end
				else begin
					COUNTER_SNAP_NS = COUNTER_SNAP_CS + 1;
					ws_snap = 1'b0;
				end
			end
			3'd4: begin
				clk_snap_en = 1'b1;
				ws_snap = 1'b0;
				NS_SNAP = 3'd3;
				COUNTER_ROW_SNAP_NS = COUNTER_ROW_SNAP_CS + 1;
			end
			default: NS_SNAP = 3'd0;
		endcase
	end
endmodule
