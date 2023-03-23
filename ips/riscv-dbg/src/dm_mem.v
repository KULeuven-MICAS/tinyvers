module dm_mem (
	clk_i,
	rst_ni,
	debug_req_o,
	hartsel_i,
	haltreq_i,
	resumereq_i,
	clear_resumeack_i,
	halted_o,
	resuming_o,
	progbuf_i,
	data_i,
	data_o,
	data_valid_o,
	cmd_valid_i,
	cmd_i,
	cmderror_valid_o,
	cmderror_o,
	cmdbusy_o,
	req_i,
	we_i,
	addr_i,
	wdata_i,
	be_i,
	rdata_o
);
	parameter signed [31:0] NrHarts = -1;
	parameter signed [31:0] BusWidth = -1;
	parameter [NrHarts - 1:0] SelectableHarts = -1;
	input wire clk_i;
	input wire rst_ni;
	output wire [NrHarts - 1:0] debug_req_o;
	input wire [19:0] hartsel_i;
	input wire [NrHarts - 1:0] haltreq_i;
	input wire [NrHarts - 1:0] resumereq_i;
	input wire clear_resumeack_i;
	output wire [NrHarts - 1:0] halted_o;
	output wire [NrHarts - 1:0] resuming_o;
	localparam [4:0] dm_ProgBufSize = 5'h08;
	input wire [255:0] progbuf_i;
	localparam [3:0] dm_DataCount = 4'h2;
	input wire [63:0] data_i;
	output reg [63:0] data_o;
	output reg data_valid_o;
	input wire cmd_valid_i;
	input wire [31:0] cmd_i;
	output reg cmderror_valid_o;
	output reg [2:0] cmderror_o;
	output reg cmdbusy_o;
	input wire req_i;
	input wire we_i;
	input wire [BusWidth - 1:0] addr_i;
	input wire [BusWidth - 1:0] wdata_i;
	input wire [(BusWidth / 8) - 1:0] be_i;
	output reg [BusWidth - 1:0] rdata_o;
	localparam signed [31:0] HartSelLen = (NrHarts == 1 ? 1 : $clog2(NrHarts));
	localparam signed [31:0] MaxAar = (BusWidth == 64 ? 4 : 3);
	localparam DbgAddressBits = 12;
	localparam [11:0] dm_DataAddr = 12'h380;
	localparam [11:0] DataBase = dm_DataAddr;
	localparam [11:0] DataEnd = 904;
	localparam [11:0] ProgBufBase = 864;
	localparam [11:0] ProgBufEnd = 895;
	localparam [11:0] AbstractCmdBase = ProgBufBase - 40;
	localparam [11:0] AbstractCmdEnd = ProgBufBase - 1;
	localparam [11:0] WhereTo = 'h300;
	localparam [11:0] FlagsBase = 'h400;
	localparam [11:0] FlagsEnd = 'h7ff;
	localparam [11:0] Halted = 'h100;
	localparam [11:0] Going = 'h104;
	localparam [11:0] Resuming = 'h108;
	localparam [11:0] Exception = 'h10c;
	wire [255:0] progbuf;
	reg [319:0] abstract_cmd;
	reg [NrHarts - 1:0] halted_d;
	reg [NrHarts - 1:0] halted_q;
	reg [NrHarts - 1:0] resuming_d;
	reg [NrHarts - 1:0] resuming_q;
	reg resume;
	reg go;
	reg going;
	reg [NrHarts - 1:0] halted;
	wire [HartSelLen - 1:0] hart_sel;
	reg exception;
	reg unsupported_command;
	wire [63:0] rom_rdata;
	reg [63:0] rdata_d;
	reg [63:0] rdata_q;
	reg word_enable32_q;
	wire fwd_rom_d;
	reg fwd_rom_q;
	wire [23:0] ac_ar;
	function automatic [23:0] sv2v_cast_24;
		input reg [23:0] inp;
		sv2v_cast_24 = inp;
	endfunction
	assign ac_ar = sv2v_cast_24(cmd_i[23-:24]);
	assign hart_sel = wdata_i[HartSelLen - 1:0];
	assign debug_req_o = haltreq_i;
	assign halted_o = halted_q;
	assign resuming_o = resuming_q;
	assign progbuf = progbuf_i;
	reg [1:0] state_d;
	reg [1:0] state_q;
	always @(*) begin
		cmderror_valid_o = 1'b0;
		cmderror_o = 3'd0;
		state_d = state_q;
		go = 1'b0;
		resume = 1'b0;
		cmdbusy_o = 1'b1;
		case (state_q)
			2'd0: begin
				cmdbusy_o = 1'b0;
				if (cmd_valid_i && halted_q[hartsel_i])
					state_d = 2'd1;
				else if (cmd_valid_i) begin
					cmderror_valid_o = 1'b1;
					cmderror_o = 3'd4;
				end
				if (((resumereq_i[hartsel_i] && !resuming_q[hartsel_i]) && !haltreq_i[hartsel_i]) && halted_q[hartsel_i])
					state_d = 2'd2;
			end
			2'd1: begin
				cmdbusy_o = 1'b1;
				go = 1'b1;
				if (going)
					state_d = 2'd3;
			end
			2'd2: begin
				cmdbusy_o = 1'b1;
				resume = 1'b1;
				if (resuming_o[hartsel_i])
					state_d = 2'd0;
			end
			2'd3: begin
				cmdbusy_o = 1'b1;
				go = 1'b0;
				if (halted[hartsel_i])
					state_d = 2'd0;
			end
		endcase
		if (unsupported_command && cmd_valid_i) begin
			cmderror_valid_o = 1'b1;
			cmderror_o = 3'd2;
		end
		if (exception) begin
			cmderror_valid_o = 1'b1;
			cmderror_o = 3'd3;
		end
	end
	localparam [63:0] dm_HaltAddress = 64'h0000000000000800;
	localparam [63:0] dm_ResumeAddress = 2052;
	function automatic [31:0] dm_jal;
		input reg [4:0] rd;
		input reg [20:0] imm;
		dm_jal = {imm[20], imm[10:1], imm[11], imm[19:12], rd, 7'h6f};
	endfunction
	always @(*) begin : sv2v_autoblock_1
		reg [63:0] data_bits;
		halted_d = halted_q;
		resuming_d = resuming_q;
		rdata_o = (BusWidth == 64 ? (fwd_rom_q ? rom_rdata : rdata_q) : (word_enable32_q ? (fwd_rom_q ? rom_rdata[63:32] : rdata_q[63:32]) : (fwd_rom_q ? rom_rdata[31:0] : rdata_q[31:0])));
		rdata_d = rdata_q;
		data_bits = data_i;
		data_valid_o = 1'b0;
		exception = 1'b0;
		halted = 1'sb0;
		going = 1'b0;
		if (clear_resumeack_i)
			resuming_d[hartsel_i] = 1'b0;
		if (req_i)
			if (we_i) begin
				if (addr_i[11:0] == Halted) begin
					halted[hart_sel] = 1'b1;
					halted_d[hart_sel] = 1'b1;
				end
				else if (addr_i[11:0] == Going)
					going = 1'b1;
				else if (addr_i[11:0] == Resuming) begin
					halted_d[hart_sel] = 1'b0;
					resuming_d[hart_sel] = 1'b1;
				end
				else if (addr_i[11:0] == Exception)
					exception = 1'b1;
				else if ((dm_DataAddr <= addr_i[11:0]) && (DataEnd >= addr_i[11:0])) begin
					data_valid_o = 1'b1;
					begin : sv2v_autoblock_2
						reg signed [31:0] i;
						for (i = 0; i < (BusWidth / 8); i = i + 1)
							if (be_i[i])
								data_bits[i * 8+:8] = wdata_i[i * 8+:8];
					end
				end
			end
			else if (addr_i[11:0] == WhereTo) begin
				if (resumereq_i[hart_sel])
					rdata_d = {32'b00000000000000000000000000000000, dm_jal(1'sb0, dm_ResumeAddress[11:0] - WhereTo)};
				if (cmdbusy_o)
					if (((cmd_i[31-:8] == 8'h00) && !ac_ar[17]) && ac_ar[18])
						rdata_d = {32'b00000000000000000000000000000000, dm_jal(1'sb0, ProgBufBase - WhereTo)};
					else
						rdata_d = {32'b00000000000000000000000000000000, dm_jal(1'sb0, AbstractCmdBase - WhereTo)};
			end
			else if ((DataBase <= addr_i[11:0]) && (DataEnd >= addr_i[11:0]))
				rdata_d = {data_i[((addr_i[11:3] - DataBase[11:3]) + 1) * 32+:32], data_i[(addr_i[11:3] - DataBase[11:3]) * 32+:32]};
			else if ((ProgBufBase <= addr_i[11:0]) && (ProgBufEnd >= addr_i[11:0]))
				rdata_d = progbuf[(addr_i[11:3] - ProgBufBase[11:3]) * 64+:64];
			else if ((AbstractCmdBase <= addr_i[11:0]) && (AbstractCmdEnd >= addr_i[11:0]))
				rdata_d = abstract_cmd[(addr_i[11:3] - AbstractCmdBase[11:3]) * 64+:64];
			else if ((FlagsBase <= addr_i[11:0]) && (FlagsEnd >= addr_i[11:0])) begin : sv2v_autoblock_3
				reg [63:0] rdata;
				rdata = 1'sb0;
				if (({addr_i[11:3], 3'b000} - FlagsBase[11:0]) == {hartsel_i[11:3], 3'b000})
					rdata[hartsel_i[2:0] * 8+:8] = {6'b000000, resume, go};
				rdata_d = rdata;
			end
		data_o = data_bits;
	end
	function automatic [31:0] dm_auipc;
		input reg [4:0] rd;
		input reg [20:0] imm;
		dm_auipc = {imm[20], imm[10:1], imm[11], imm[19:12], rd, 7'h17};
	endfunction
	function automatic [31:0] dm_csrr;
		input reg [11:0] csr;
		input reg [4:0] dest;
		dm_csrr = {csr, 8'h02, dest, 7'h73};
	endfunction
	function automatic [31:0] dm_csrw;
		input reg [11:0] csr;
		input reg [4:0] rs1;
		dm_csrw = {csr, rs1, 15'h1073};
	endfunction
	function automatic [31:0] dm_ebreak;
		input reg _sv2v_unused;
		dm_ebreak = 32'h00100073;
	endfunction
	function automatic [31:0] dm_float_load;
		input reg [2:0] size;
		input reg [4:0] dest;
		input reg [4:0] base;
		input reg [11:0] offset;
		dm_float_load = {offset[11:0], base, size, dest, 7'b0000111};
	endfunction
	function automatic [31:0] dm_float_store;
		input reg [2:0] size;
		input reg [4:0] src;
		input reg [4:0] base;
		input reg [11:0] offset;
		dm_float_store = {offset[11:5], src, base, size, offset[4:0], 7'b0100111};
	endfunction
	function automatic [31:0] dm_illegal;
		input reg _sv2v_unused;
		dm_illegal = 32'h00000000;
	endfunction
	function automatic [31:0] dm_load;
		input reg [2:0] size;
		input reg [4:0] dest;
		input reg [4:0] base;
		input reg [11:0] offset;
		dm_load = {offset[11:0], base, size, dest, 7'h03};
	endfunction
	function automatic [31:0] dm_nop;
		input reg _sv2v_unused;
		dm_nop = 32'h00000013;
	endfunction
	function automatic [31:0] dm_slli;
		input reg [4:0] rd;
		input reg [4:0] rs1;
		input reg [5:0] shamt;
		dm_slli = {6'b000000, shamt[5:0], rs1, 3'h1, rd, 7'h13};
	endfunction
	function automatic [31:0] dm_srli;
		input reg [4:0] rd;
		input reg [4:0] rs1;
		input reg [5:0] shamt;
		dm_srli = {6'b000000, shamt[5:0], rs1, 3'h5, rd, 7'h13};
	endfunction
	function automatic [31:0] dm_store;
		input reg [2:0] size;
		input reg [4:0] src;
		input reg [4:0] base;
		input reg [11:0] offset;
		dm_store = {offset[11:5], src, base, size, offset[4:0], 7'h23};
	endfunction
	always @(*) begin : abstract_cmd_rom
		unsupported_command = 1'b0;
		abstract_cmd[31-:32] = dm_illegal(0);
		abstract_cmd[63-:32] = dm_auipc(5'd10, 1'sb0);
		abstract_cmd[95-:32] = dm_srli(5'd10, 5'd10, 6'd12);
		abstract_cmd[127-:32] = dm_slli(5'd10, 5'd10, 6'd12);
		abstract_cmd[159-:32] = dm_nop(0);
		abstract_cmd[191-:32] = dm_nop(0);
		abstract_cmd[223-:32] = dm_nop(0);
		abstract_cmd[255-:32] = dm_nop(0);
		abstract_cmd[287-:32] = dm_csrr(12'h7b3, 5'd10);
		abstract_cmd[319-:32] = dm_ebreak(0);
		case (cmd_i[31-:8])
			8'h00: begin
				if (((ac_ar[22-:3] < MaxAar) && ac_ar[17]) && ac_ar[16]) begin
					abstract_cmd[31-:32] = dm_csrw(12'h7b3, 5'd10);
					if (ac_ar[15:14] != {2 {1'sb0}}) begin
						abstract_cmd[31-:32] = dm_ebreak(0);
						unsupported_command = 1'b1;
					end
					else if ((ac_ar[12] && !ac_ar[5]) && (ac_ar[4:0] == 5'd10)) begin
						abstract_cmd[159-:32] = dm_csrw(12'h7b2, 5'd8);
						abstract_cmd[191-:32] = dm_load(ac_ar[22-:3], 5'd8, 5'd10, dm_DataAddr);
						abstract_cmd[223-:32] = dm_csrw(12'h7b3, 5'd8);
						abstract_cmd[255-:32] = dm_csrr(12'h7b2, 5'd8);
					end
					else if (ac_ar[12]) begin
						if (ac_ar[5])
							abstract_cmd[159-:32] = dm_float_load(ac_ar[22-:3], ac_ar[4:0], 5'd10, dm_DataAddr);
						else
							abstract_cmd[159-:32] = dm_load(ac_ar[22-:3], ac_ar[4:0], 5'd10, dm_DataAddr);
					end
					else begin
						abstract_cmd[159-:32] = dm_csrw(12'h7b2, 5'd8);
						abstract_cmd[191-:32] = dm_load(ac_ar[22-:3], 5'd8, 5'd10, dm_DataAddr);
						abstract_cmd[223-:32] = dm_csrw(ac_ar[11:0], 5'd8);
						abstract_cmd[255-:32] = dm_csrr(12'h7b2, 5'd8);
					end
				end
				else if (((ac_ar[22-:3] < MaxAar) && ac_ar[17]) && !ac_ar[16]) begin
					abstract_cmd[31-:32] = dm_csrw(12'h7b3, 5'd10);
					if (ac_ar[15:14] != {2 {1'sb0}}) begin
						abstract_cmd[31-:32] = dm_ebreak(0);
						unsupported_command = 1'b1;
					end
					else if ((ac_ar[12] && !ac_ar[5]) && (ac_ar[4:0] == 5'd10)) begin
						abstract_cmd[159-:32] = dm_csrw(12'h7b2, 5'd8);
						abstract_cmd[191-:32] = dm_csrr(12'h7b3, 5'd8);
						abstract_cmd[223-:32] = dm_store(ac_ar[22-:3], 5'd8, 5'd10, dm_DataAddr);
						abstract_cmd[255-:32] = dm_csrr(12'h7b2, 5'd8);
					end
					else if (ac_ar[12]) begin
						if (ac_ar[5])
							abstract_cmd[159-:32] = dm_float_store(ac_ar[22-:3], ac_ar[4:0], 5'd10, dm_DataAddr);
						else
							abstract_cmd[159-:32] = dm_store(ac_ar[22-:3], ac_ar[4:0], 5'd10, dm_DataAddr);
					end
					else begin
						abstract_cmd[159-:32] = dm_csrw(12'h7b2, 5'd8);
						abstract_cmd[191-:32] = dm_csrr(ac_ar[11:0], 5'd8);
						abstract_cmd[223-:32] = dm_store(ac_ar[22-:3], 5'd8, 5'd10, dm_DataAddr);
						abstract_cmd[255-:32] = dm_csrr(12'h7b2, 5'd8);
					end
				end
				else if ((ac_ar[22-:3] >= MaxAar) || (ac_ar[19] == 1'b1)) begin
					abstract_cmd[31-:32] = dm_ebreak(0);
					unsupported_command = 1'b1;
				end
				if (ac_ar[18] && !unsupported_command)
					abstract_cmd[319-:32] = dm_nop(0);
			end
			default: begin
				abstract_cmd[31-:32] = dm_ebreak(0);
				unsupported_command = 1'b1;
			end
		endcase
	end
	wire [63:0] rom_addr;
	function automatic [63:0] sv2v_cast_64;
		input reg [63:0] inp;
		sv2v_cast_64 = inp;
	endfunction
	assign rom_addr = sv2v_cast_64(addr_i);
	debug_rom i_debug_rom(
		.clk_i(clk_i),
		.req_i(req_i),
		.addr_i(rom_addr),
		.rdata_o(rom_rdata)
	);
	assign fwd_rom_d = (addr_i[11:0] >= dm_HaltAddress[11:0] ? 1'b1 : 1'b0);
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni) begin
			fwd_rom_q <= 1'b0;
			rdata_q <= 1'sb0;
			state_q <= 2'd0;
			word_enable32_q <= 1'b0;
		end
		else begin
			fwd_rom_q <= fwd_rom_d;
			rdata_q <= rdata_d;
			state_q <= state_d;
			word_enable32_q <= addr_i[2];
		end
	genvar k;
	generate
		for (k = 0; k < NrHarts; k = k + 1) begin : gen_halted
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni) begin
					halted_q[k] <= 1'b0;
					resuming_q[k] <= 1'b0;
				end
				else begin
					halted_q[k] <= (SelectableHarts[k] ? halted_d[k] : 1'b0);
					resuming_q[k] <= (SelectableHarts[k] ? resuming_d[k] : 1'b0);
				end
		end
	endgenerate
endmodule
