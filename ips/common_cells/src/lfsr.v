module lfsr (
	clk_i,
	rst_ni,
	en_i,
	out_o
);
	parameter [31:0] LfsrWidth = 64;
	parameter [31:0] OutWidth = 8;
	parameter [LfsrWidth - 1:0] RstVal = 1'sb1;
	parameter [31:0] CipherLayers = 0;
	parameter [0:0] CipherReg = 1'b1;
	input wire clk_i;
	input wire rst_ni;
	input wire en_i;
	output wire [OutWidth - 1:0] out_o;
	localparam [4159:256] masks = 3904'hc000000000000001e0000000000000039000000000000007e00000000000000fa00000000000001fd00000000000003fc000000000000064b0000000000000d8f0000000000001296000000000000249600000000000043570000000000008679000000000001030e00000000000206cd00000000000403fe00000000000807b800000000001004b200000000002006a800000000004004b20000000000800b8700000000010004f3000000000200072d00000000040006ae00000000080009e300000000100005830000000020000c9200000000400005b60000000080000ea600000001000007a30000000200000abf0000000400000842000000080000123e000000100000074e0000002000000ae9000000400000086a0000008000001213000001000000077e000002000000123b0000040000000877000008000000108d0000100000000ae90000200000000e9f00004000000008a6000080000000191e000100000000090e0002000000000fb30004000000000d7d00080000000016a50010000000000b4b00200000000010af0040000000000dde008000000000181a0100000000000b65020000000000102d0400000000000cd508000000000024c11000000000000ef620000000000013634000000000000fcd80000000000019e2;
	localparam [63:0] sbox4 = 64'h21748fe3da09b65c;
	localparam [383:0] perm = 384'hfef7cffae78ef6d74df2c70ceeb6cbeaa68ae69649e28608de75c7da6586d65545d24504ce34c3ca2482c61441c20400;
	function automatic [63:0] sbox4_layer;
		input reg [63:0] in;
		reg [63:0] out;
		begin
			out[0+:4] = sbox4[in[0+:4] * 4+:4];
			out[4+:4] = sbox4[in[4+:4] * 4+:4];
			out[8+:4] = sbox4[in[8+:4] * 4+:4];
			out[12+:4] = sbox4[in[12+:4] * 4+:4];
			out[16+:4] = sbox4[in[16+:4] * 4+:4];
			out[20+:4] = sbox4[in[20+:4] * 4+:4];
			out[24+:4] = sbox4[in[24+:4] * 4+:4];
			out[28+:4] = sbox4[in[28+:4] * 4+:4];
			out[32+:4] = sbox4[in[32+:4] * 4+:4];
			out[36+:4] = sbox4[in[36+:4] * 4+:4];
			out[40+:4] = sbox4[in[40+:4] * 4+:4];
			out[44+:4] = sbox4[in[44+:4] * 4+:4];
			out[48+:4] = sbox4[in[48+:4] * 4+:4];
			out[52+:4] = sbox4[in[52+:4] * 4+:4];
			out[56+:4] = sbox4[in[56+:4] * 4+:4];
			out[60+:4] = sbox4[in[60+:4] * 4+:4];
			sbox4_layer = out;
		end
	endfunction
	function automatic [63:0] perm_layer;
		input reg [63:0] in;
		reg [63:0] out;
		begin
			out[perm[0+:6]] = in[0];
			out[perm[6+:6]] = in[1];
			out[perm[12+:6]] = in[2];
			out[perm[18+:6]] = in[3];
			out[perm[24+:6]] = in[4];
			out[perm[30+:6]] = in[5];
			out[perm[36+:6]] = in[6];
			out[perm[42+:6]] = in[7];
			out[perm[48+:6]] = in[8];
			out[perm[54+:6]] = in[9];
			out[perm[60+:6]] = in[10];
			out[perm[66+:6]] = in[11];
			out[perm[72+:6]] = in[12];
			out[perm[78+:6]] = in[13];
			out[perm[84+:6]] = in[14];
			out[perm[90+:6]] = in[15];
			out[perm[96+:6]] = in[16];
			out[perm[102+:6]] = in[17];
			out[perm[108+:6]] = in[18];
			out[perm[114+:6]] = in[19];
			out[perm[120+:6]] = in[20];
			out[perm[126+:6]] = in[21];
			out[perm[132+:6]] = in[22];
			out[perm[138+:6]] = in[23];
			out[perm[144+:6]] = in[24];
			out[perm[150+:6]] = in[25];
			out[perm[156+:6]] = in[26];
			out[perm[162+:6]] = in[27];
			out[perm[168+:6]] = in[28];
			out[perm[174+:6]] = in[29];
			out[perm[180+:6]] = in[30];
			out[perm[186+:6]] = in[31];
			out[perm[192+:6]] = in[32];
			out[perm[198+:6]] = in[33];
			out[perm[204+:6]] = in[34];
			out[perm[210+:6]] = in[35];
			out[perm[216+:6]] = in[36];
			out[perm[222+:6]] = in[37];
			out[perm[228+:6]] = in[38];
			out[perm[234+:6]] = in[39];
			out[perm[240+:6]] = in[40];
			out[perm[246+:6]] = in[41];
			out[perm[252+:6]] = in[42];
			out[perm[258+:6]] = in[43];
			out[perm[264+:6]] = in[44];
			out[perm[270+:6]] = in[45];
			out[perm[276+:6]] = in[46];
			out[perm[282+:6]] = in[47];
			out[perm[288+:6]] = in[48];
			out[perm[294+:6]] = in[49];
			out[perm[300+:6]] = in[50];
			out[perm[306+:6]] = in[51];
			out[perm[312+:6]] = in[52];
			out[perm[318+:6]] = in[53];
			out[perm[324+:6]] = in[54];
			out[perm[330+:6]] = in[55];
			out[perm[336+:6]] = in[56];
			out[perm[342+:6]] = in[57];
			out[perm[348+:6]] = in[58];
			out[perm[354+:6]] = in[59];
			out[perm[360+:6]] = in[60];
			out[perm[366+:6]] = in[61];
			out[perm[372+:6]] = in[62];
			out[perm[378+:6]] = in[63];
			perm_layer = out;
		end
	endfunction
	wire [LfsrWidth - 1:0] lfsr_d;
	reg [LfsrWidth - 1:0] lfsr_q;
	assign lfsr_d = (en_i ? (lfsr_q >> 1) ^ ({LfsrWidth {lfsr_q[0]}} & masks[((68 - LfsrWidth) * 64) + (LfsrWidth - 1)-:LfsrWidth]) : lfsr_q);
	function automatic [LfsrWidth - 1:0] sv2v_cast_774EC;
		input reg [LfsrWidth - 1:0] inp;
		sv2v_cast_774EC = inp;
	endfunction
	always @(posedge clk_i or negedge rst_ni) begin : p_regs
		if (!rst_ni)
			lfsr_q <= sv2v_cast_774EC(RstVal);
		else
			lfsr_q <= lfsr_d;
	end
	function automatic [63:0] sv2v_cast_64;
		input reg [63:0] inp;
		sv2v_cast_64 = inp;
	endfunction
	generate
		if (CipherLayers > $unsigned(0)) begin : g_cipher_layers
			reg [63:0] ciph_layer;
			localparam [31:0] NumRepl = (64 + LfsrWidth) / LfsrWidth;
			always @(*) begin : p_ciph_layer
				reg [63:0] tmp;
				tmp = sv2v_cast_64({NumRepl {lfsr_q}});
				begin : sv2v_autoblock_1
					reg [31:0] k;
					for (k = 0; k < CipherLayers; k = k + 1)
						tmp = perm_layer(sbox4_layer(tmp));
				end
				ciph_layer = tmp;
			end
			if (CipherReg) begin : g_cipher_reg
				wire [OutWidth - 1:0] out_d;
				reg [OutWidth - 1:0] out_q;
				assign out_d = (en_i ? ciph_layer[OutWidth - 1:0] : out_q);
				assign out_o = out_q[OutWidth - 1:0];
				always @(posedge clk_i or negedge rst_ni) begin : p_regs
					if (!rst_ni)
						out_q <= 1'sb0;
					else
						out_q <= out_d;
				end
			end
			else begin : g_no_out_reg
				assign out_o = ciph_layer[OutWidth - 1:0];
			end
		end
		else begin : g_no_cipher_layers
			assign out_o = lfsr_q[OutWidth - 1:0];
		end
	endgenerate
endmodule
