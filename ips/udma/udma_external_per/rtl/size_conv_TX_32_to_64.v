module size_conv_TX_32_to_64 (
	clk,
	rst_n,
	data_tx_wdata_i,
	data_tx_valid_i,
	data_tx_ready_o,
	push_cmd_req_i,
	push_cmd_gnt_o,
	data_tx_addr_i,
	data_tx_size_i,
	data_tx_wdata_o,
	data_tx_addr_o,
	data_tx_req_o,
	data_tx_eot_o,
	data_tx_gnt_i,
	pending_o,
	tx_done_o,
	trim_cfg_done_o,
	erase_addr_i,
	erase_size_i,
	erase_done_o,
	erase_pending_o,
	ref_line_pending_o,
	ref_line_done_o,
	mram_mode_i,
	mram_mode_o,
	mram_SHIFT_o,
	mram_SUPD_o,
	mram_SDI_o,
	mram_SCLK_o,
	mram_SDO_i,
	NVR_i,
	TMEN_i,
	AREF_i,
	mram_NVR_o,
	mram_TMEN_o,
	mram_AREF_o
);
	parameter TRANS_SIZE = 16;
	parameter NUM_TRIM_BYTE = 532;
	parameter NUM_CYCLE_STROBE = 3;
	parameter NUM_CYCLE_GO_SUP = 6;
	input wire clk;
	input wire rst_n;
	input wire [31:0] data_tx_wdata_i;
	input wire data_tx_valid_i;
	output reg data_tx_ready_o;
	input wire push_cmd_req_i;
	output wire push_cmd_gnt_o;
	input wire [15:0] data_tx_addr_i;
	input wire [TRANS_SIZE - 1:0] data_tx_size_i;
	output reg [77:0] data_tx_wdata_o;
	output reg [15:0] data_tx_addr_o;
	output reg data_tx_req_o;
	output reg data_tx_eot_o;
	input wire data_tx_gnt_i;
	output wire pending_o;
	output reg tx_done_o;
	output reg trim_cfg_done_o;
	input wire [15:0] erase_addr_i;
	input wire [9:0] erase_size_i;
	output reg erase_done_o;
	output reg erase_pending_o;
	output reg ref_line_pending_o;
	output reg ref_line_done_o;
	input wire [7:0] mram_mode_i;
	output wire [7:0] mram_mode_o;
	output reg mram_SHIFT_o;
	output reg mram_SUPD_o;
	output reg mram_SDI_o;
	output reg mram_SCLK_o;
	input wire mram_SDO_i;
	input wire NVR_i;
	input wire TMEN_i;
	input wire AREF_i;
	output reg mram_NVR_o;
	output reg mram_TMEN_o;
	output reg mram_AREF_o;
	reg [4:0] NS;
	reg [4:0] CS;
	localparam CMD_TRIM_CFG = 8'b00000001;
	localparam CMD_NORMAL_TX = 8'b00000010;
	localparam CMD_ERASE_CHIP = 8'b00000100;
	localparam CMD_ERASE_SECT = 8'b00001000;
	localparam CMD_ERASE_WORD = 8'b00010000;
	localparam CMD_PWDN = 8'b00100000;
	localparam CMD_READ_RX = 8'b01000000;
	localparam CMD_REF_LINE_P = 8'b10000000;
	localparam CMD_REF_LINE_AP = 8'b11000000;
	wire [15:0] data_tx_addr_int;
	wire [TRANS_SIZE - 1:0] data_tx_size_int;
	wire valid_cmd;
	reg save_addr;
	reg update_addr;
	reg clear_1;
	reg clear_2;
	reg update_1;
	reg update_2;
	reg shift_1;
	reg mram_SCLK_int;
	reg [2:0] counter_CS;
	reg [2:0] counter_NS;
	reg [4:0] shift_cnt_CS;
	reg [4:0] shift_cnt_NS;
	reg [11:0] word_cnt_CS;
	reg [11:0] word_cnt_NS;
	reg [63:0] data_tx_wdata_Q;
	reg [19:0] data_tx_addr_Q;
	reg [TRANS_SIZE - 1:0] data_tx_size_Q;
	reg [7:0] mram_mode_Q;
	reg save_erase_info;
	reg update_erase_info;
	reg [15:0] erase_addr_Q;
	reg [9:0] erase_size_Q;
	reg clear_mram_signal;
	reg save_mram_signal;
	assign {data_tx_size_int, data_tx_addr_int} = {data_tx_size_i, data_tx_addr_i};
	assign valid_cmd = push_cmd_req_i;
	assign push_cmd_gnt_o = save_addr;
	assign mram_mode_o = mram_mode_Q;
	assign pending_o = (valid_cmd == 1'b1) || (CS != 5'd0);
	always @(posedge clk or negedge rst_n) begin : proc_FSM_Seq
		if (~rst_n) begin
			CS <= 5'd0;
			counter_CS <= 1'sb0;
			shift_cnt_CS <= 1'sb0;
			word_cnt_CS <= 1'sb0;
			mram_SCLK_o <= 1'sb0;
			data_tx_wdata_Q <= 1'sb0;
			data_tx_addr_Q <= 1'sb0;
			data_tx_size_Q <= 1'sb0;
			erase_addr_Q <= 1'sb0;
			erase_size_Q <= 1'sb0;
			mram_mode_Q <= 1'sb0;
			mram_AREF_o <= 1'b0;
			mram_TMEN_o <= 1'b0;
			mram_NVR_o <= 1'b0;
		end
		else begin
			CS <= NS;
			counter_CS <= counter_NS;
			shift_cnt_CS <= shift_cnt_NS;
			word_cnt_CS <= word_cnt_NS;
			mram_SCLK_o <= mram_SCLK_int;
			if (clear_mram_signal) begin
				mram_AREF_o <= 1'sb0;
				mram_TMEN_o <= 1'sb0;
				mram_NVR_o <= 1'sb0;
			end
			else if (save_mram_signal) begin
				mram_AREF_o <= AREF_i;
				mram_TMEN_o <= TMEN_i;
				mram_NVR_o <= NVR_i;
			end
			if (save_addr)
				mram_mode_Q <= mram_mode_i;
			else if (CS == 5'd0)
				mram_mode_Q <= 1'sb0;
			if (save_erase_info) begin
				erase_addr_Q <= erase_addr_i;
				erase_size_Q <= erase_size_i;
			end
			else if (update_erase_info) begin
				erase_addr_Q <= (mram_mode_Q == CMD_ERASE_WORD ? erase_addr_Q + 1 : {erase_addr_Q[15:8] + 1, 8'b00000000});
				erase_size_Q <= erase_size_Q - 1;
			end
			if (clear_1)
				data_tx_wdata_Q[0+:32] <= 1'sb0;
			else if (update_1)
				data_tx_wdata_Q[0+:32] <= data_tx_wdata_i;
			else if (shift_1) begin
				data_tx_wdata_Q[30-:31] <= data_tx_wdata_Q[31-:31];
				data_tx_wdata_Q[31] <= 1'bx;
			end
			if (clear_2)
				data_tx_wdata_Q[32+:32] <= 1'sb0;
			else if (update_2)
				data_tx_wdata_Q[32+:32] <= data_tx_wdata_i;
			if (save_addr) begin
				data_tx_addr_Q <= {data_tx_addr_int, 1'b0};
				data_tx_size_Q <= data_tx_size_int - 4;
			end
			else if (update_addr) begin
				data_tx_addr_Q <= data_tx_addr_Q + 1;
				data_tx_size_Q <= data_tx_size_Q - 4;
			end
		end
	end
	always @(*) begin : proc_FSM_comb
		data_tx_addr_o = data_tx_addr_Q[19:1];
		save_addr = 1'b0;
		update_addr = 1'b0;
		update_1 = 1'b0;
		update_2 = 1'b0;
		clear_2 = 1'b0;
		clear_1 = 1'b0;
		data_tx_req_o = 1'b0;
		data_tx_ready_o = 1'b0;
		shift_1 = 1'b0;
		mram_SHIFT_o = 1'b0;
		mram_SUPD_o = 1'b0;
		mram_SDI_o = 1'b0;
		mram_SCLK_int = 1'b0;
		counter_NS = counter_CS;
		word_cnt_NS = word_cnt_CS;
		shift_cnt_NS = shift_cnt_CS;
		trim_cfg_done_o = 1'b0;
		erase_pending_o = 1'b0;
		erase_done_o = 1'b0;
		data_tx_eot_o = 1'b0;
		save_erase_info = 1'b0;
		update_erase_info = 1'b0;
		data_tx_wdata_o = {14'h0000, ~data_tx_wdata_Q};
		ref_line_pending_o = 1'sb0;
		ref_line_done_o = 1'sb0;
		save_mram_signal = 1'b0;
		clear_mram_signal = 1'b0;
		tx_done_o = 1'b0;
		case (CS)
			5'd0:
				if (push_cmd_req_i)
					case (mram_mode_i)
						CMD_TRIM_CFG: begin
							data_tx_ready_o = 1'b1;
							save_addr = data_tx_valid_i;
							save_mram_signal = data_tx_valid_i;
							if (data_tx_valid_i) begin
								NS = 5'd5;
								update_1 = 1'b1;
								shift_cnt_NS = 31;
								word_cnt_NS = (NUM_TRIM_BYTE / 4) - 1;
							end
							else
								NS = 5'd0;
						end
						CMD_NORMAL_TX: begin
							data_tx_ready_o = 1'b1;
							save_addr = data_tx_valid_i;
							update_1 = data_tx_valid_i;
							data_tx_addr_o = data_tx_addr_int;
							save_mram_signal = data_tx_valid_i;
							if (data_tx_valid_i) begin
								if (data_tx_size_int <= 4) begin
									NS = 5'd4;
									clear_2 = 1'b1;
								end
								else
									NS = 5'd1;
							end
							else
								NS = 5'd0;
						end
						CMD_ERASE_SECT, CMD_ERASE_CHIP, CMD_ERASE_WORD: begin
							save_addr = 1'b1;
							NS = 5'd11;
							save_erase_info = 1'b1;
							save_mram_signal = 1'b1;
						end
						CMD_REF_LINE_P: begin
							NS = 5'd13;
							word_cnt_NS = 1'sb0;
							save_mram_signal = 1'b1;
							save_addr = 1'b1;
						end
						CMD_REF_LINE_AP: begin
							NS = 5'd15;
							word_cnt_NS = 1'sb0;
							save_mram_signal = 1'b1;
							save_addr = 1'b1;
						end
						default: begin
							NS = 5'd0;
							save_addr = 1'b1;
						end
					endcase
				else
					NS = 5'd0;
			5'd13: begin
				ref_line_pending_o = 1'b1;
				data_tx_wdata_o = 1'sb1;
				data_tx_addr_o[15:7] = word_cnt_CS;
				data_tx_addr_o[6:0] = 7'h00;
				data_tx_req_o = 1'b1;
				if (data_tx_gnt_i)
					NS = 5'd14;
				else
					NS = 5'd13;
			end
			5'd14: begin
				ref_line_pending_o = 1'b1;
				data_tx_wdata_o = 1'sb1;
				data_tx_addr_o[15:7] = word_cnt_CS;
				data_tx_addr_o[6:0] = 7'h60;
				data_tx_req_o = 1'b1;
				data_tx_eot_o = &word_cnt_CS;
				if (data_tx_gnt_i) begin
					word_cnt_NS = word_cnt_CS + 1'b1;
					if (word_cnt_CS == {12 {1'sb1}})
						NS = 5'd17;
					else
						NS = 5'd13;
				end
				else
					NS = 5'd14;
			end
			5'd15: begin
				ref_line_pending_o = 1'b1;
				data_tx_wdata_o = 1'sb1;
				data_tx_addr_o[15:7] = word_cnt_CS;
				data_tx_addr_o[6:0] = 7'h20;
				data_tx_req_o = 1'b1;
				if (data_tx_gnt_i)
					NS = 5'd16;
				else
					NS = 5'd15;
			end
			5'd16: begin
				ref_line_pending_o = 1'b1;
				data_tx_wdata_o = 1'sb1;
				data_tx_addr_o[15:7] = word_cnt_CS;
				data_tx_addr_o[6:0] = 7'h40;
				data_tx_req_o = 1'b1;
				data_tx_eot_o = &word_cnt_CS;
				if (data_tx_gnt_i) begin
					word_cnt_NS = word_cnt_CS + 1'b1;
					if (word_cnt_CS == {12 {1'sb1}})
						NS = 5'd17;
					else
						NS = 5'd15;
				end
				else
					NS = 5'd16;
			end
			5'd17: begin
				ref_line_done_o = 1'b1;
				NS = 5'd0;
			end
			5'd11: begin
				erase_pending_o = 1'b1;
				data_tx_wdata_o = 1'sb1;
				data_tx_req_o = 1'b1;
				data_tx_addr_o = erase_addr_Q;
				update_erase_info = data_tx_gnt_i;
				if (data_tx_gnt_i)
					case (mram_mode_Q)
						CMD_ERASE_CHIP: begin
							NS = 5'd12;
							data_tx_eot_o = 1'b1;
						end
						default:
							if (erase_size_Q > 0)
								NS = 5'd11;
							else begin
								NS = 5'd12;
								data_tx_eot_o = 1'b1;
							end
					endcase
				else
					NS = 5'd11;
			end
			5'd12: begin
				erase_done_o = 1'b1;
				NS = 5'd0;
			end
			5'd1: begin
				update_2 = data_tx_valid_i;
				update_addr = data_tx_valid_i;
				data_tx_ready_o = 1'b1;
				if (data_tx_valid_i) begin
					if (data_tx_size_Q <= 4)
						NS = 5'd4;
					else
						NS = 5'd2;
				end
				else
					NS = 5'd1;
			end
			5'd2: begin
				data_tx_req_o = 1'b1;
				data_tx_ready_o = data_tx_gnt_i;
				if (data_tx_gnt_i) begin
					update_1 = data_tx_valid_i;
					update_addr = data_tx_valid_i;
					if (data_tx_valid_i) begin
						if (data_tx_size_Q <= 4) begin
							NS = 5'd4;
							clear_2 = 1'b1;
						end
						else
							NS = 5'd1;
					end
					else
						NS = 5'd3;
				end
				else
					NS = 5'd2;
			end
			5'd3: begin
				update_1 = data_tx_valid_i;
				update_addr = data_tx_valid_i;
				data_tx_ready_o = 1'b1;
				if (data_tx_valid_i) begin
					if (data_tx_size_Q <= 4) begin
						NS = 5'd4;
						clear_2 = 1'b1;
					end
					else
						NS = 5'd1;
				end
				else
					NS = 5'd3;
			end
			5'd4: begin
				data_tx_eot_o = 1'b1;
				data_tx_req_o = 1'b1;
				data_tx_ready_o = 1'b0;
				if (data_tx_gnt_i) begin
					NS = 5'd0;
					tx_done_o = 1'b1;
				end
				else
					NS = 5'd4;
			end
			5'd5: begin
				data_tx_ready_o = 1'b0;
				mram_SHIFT_o = 1'b1;
				mram_SDI_o = data_tx_wdata_Q[0];
				mram_SCLK_int = 1'b0;
				counter_NS = 1'sb0;
				shift_1 = 1'b0;
				NS = 5'd6;
			end
			5'd6: begin
				mram_SHIFT_o = 1'b1;
				mram_SCLK_int = 1'b1;
				counter_NS = counter_CS + 1'b1;
				mram_SDI_o = data_tx_wdata_Q[0];
				if (counter_CS < (NUM_CYCLE_STROBE - 1))
					NS = 5'd6;
				else begin
					NS = 5'd7;
					counter_NS = 1'sb0;
				end
			end
			5'd7: begin
				mram_SHIFT_o = 1'b1;
				mram_SCLK_int = 1'b0;
				mram_SDI_o = data_tx_wdata_Q[0];
				counter_NS = counter_CS + 1'b1;
				if (counter_CS < (NUM_CYCLE_STROBE - 1))
					NS = 5'd7;
				else if (word_cnt_CS == 0) begin
					counter_NS = 1'sb0;
					if (shift_cnt_CS == 4)
						NS = 5'd8;
					else begin
						NS = 5'd6;
						shift_1 = 1'b1;
						shift_cnt_NS = shift_cnt_CS - 1'b1;
					end
				end
				else if (shift_cnt_CS == 0) begin
					word_cnt_NS = word_cnt_CS - 1;
					data_tx_ready_o = 1'b1;
					if (data_tx_valid_i) begin
						update_1 = 1'b1;
						shift_cnt_NS = 31;
						counter_NS = 1'sb0;
						NS = 5'd6;
					end
					else
						NS = 5'd7;
				end
				else begin
					NS = 5'd6;
					counter_NS = 1'sb0;
					shift_1 = 1'b1;
					shift_cnt_NS = shift_cnt_CS - 1'b1;
				end
			end
			5'd8:
				if (counter_CS <= NUM_CYCLE_GO_SUP) begin
					NS = 5'd8;
					counter_NS = counter_CS + 1'b1;
				end
				else begin
					NS = 5'd9;
					counter_NS = 1'sb0;
				end
			5'd9: begin
				mram_SUPD_o = 1'b1;
				if (counter_CS <= NUM_CYCLE_GO_SUP) begin
					NS = 5'd9;
					counter_NS = counter_CS + 1'b1;
				end
				else begin
					NS = 5'd10;
					counter_NS = 1'sb0;
				end
			end
			5'd10: begin
				trim_cfg_done_o = 1'b1;
				NS = 5'd0;
			end
			default: NS = 5'd0;
		endcase
	end
endmodule
