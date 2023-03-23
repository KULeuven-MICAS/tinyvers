module apb_gpio (
	HCLK,
	HRESETn,
	dft_cg_enable_i,
	PADDR,
	PWDATA,
	PWRITE,
	PSEL,
	PENABLE,
	PRDATA,
	PREADY,
	PSLVERR,
	gpio_in,
	gpio_in_sync,
	gpio_out,
	gpio_dir,
	gpio_padcfg,
	interrupt
);
	parameter APB_ADDR_WIDTH = 12;
	parameter PAD_NUM = 32;
	input wire HCLK;
	input wire HRESETn;
	input wire dft_cg_enable_i;
	input wire [APB_ADDR_WIDTH - 1:0] PADDR;
	input wire [31:0] PWDATA;
	input wire PWRITE;
	input wire PSEL;
	input wire PENABLE;
	output reg [31:0] PRDATA;
	output wire PREADY;
	output wire PSLVERR;
	input wire [PAD_NUM - 1:0] gpio_in;
	output wire [PAD_NUM - 1:0] gpio_in_sync;
	output wire [PAD_NUM - 1:0] gpio_out;
	output wire [PAD_NUM - 1:0] gpio_dir;
	output wire [(PAD_NUM * 4) - 1:0] gpio_padcfg;
	output wire interrupt;
	reg [PAD_NUM - 1:0] r_gpio_inten;
	reg [63:0] s_gpio_inten;
	reg [(PAD_NUM * 2) - 1:0] r_gpio_inttype;
	reg [127:0] s_gpio_inttype;
	reg [PAD_NUM - 1:0] r_gpio_out;
	reg [63:0] s_gpio_out;
	reg [PAD_NUM - 1:0] r_gpio_dir;
	reg [63:0] s_gpio_dir;
	reg [(PAD_NUM * 4) - 1:0] r_gpio_padcfg;
	reg [255:0] s_gpio_padcfg;
	reg [PAD_NUM - 1:0] r_gpio_sync0;
	reg [PAD_NUM - 1:0] r_gpio_sync1;
	reg [PAD_NUM - 1:0] r_gpio_in;
	reg [PAD_NUM - 1:0] r_gpio_en;
	reg [63:0] s_gpio_en;
	reg [63:0] s_cg_en;
	wire [PAD_NUM - 1:0] s_gpio_rise;
	wire [PAD_NUM - 1:0] s_gpio_fall;
	reg [PAD_NUM - 1:0] s_is_int_rise;
	reg [PAD_NUM - 1:0] s_is_int_rifa;
	reg [PAD_NUM - 1:0] s_is_int_fall;
	wire [PAD_NUM - 1:0] s_is_int_all;
	wire s_rise_int;
	wire [4:0] s_apb_addr;
	reg [PAD_NUM - 1:0] r_status;
	reg [15:0] s_clk_en;
	reg [63:0] s_write_cfg;
	reg [63:0] s_write_inttype;
	reg [63:0] s_write_dir;
	reg [63:0] s_write_out;
	reg [63:0] s_write_inten;
	reg [63:0] s_write_gpen;
	reg s_write;
	genvar i;
	generate
		for (i = 0; i < PAD_NUM; i = i + 1) begin : genblk1
			assign gpio_padcfg[i * 4+:4] = r_gpio_padcfg[i * 4+:4];
		end
	endgenerate
	assign s_apb_addr = PADDR[6:2];
	assign gpio_in_sync = r_gpio_sync1;
	assign s_gpio_rise = r_gpio_sync1 & ~r_gpio_in;
	assign s_gpio_fall = ~r_gpio_sync1 & r_gpio_in;
	always @(*) begin : sv2v_autoblock_1
		reg signed [31:0] i;
		for (i = 0; i < PAD_NUM; i = i + 1)
			begin
				s_is_int_fall[i] = (~r_gpio_inttype[(i * 2) + 1] & ~r_gpio_inttype[i * 2]) & s_gpio_fall[i];
				s_is_int_rise[i] = (~r_gpio_inttype[(i * 2) + 1] & r_gpio_inttype[i * 2]) & s_gpio_rise[i];
				s_is_int_rifa[i] = (r_gpio_inttype[(i * 2) + 1] & ~r_gpio_inttype[i * 2]) & (s_gpio_rise[i] | s_gpio_fall[i]);
			end
	end
	assign s_is_int_all = (r_gpio_inten & r_gpio_en) & ((s_is_int_rise | s_is_int_fall) | s_is_int_rifa);
	assign s_rise_int = |s_is_int_all;
	assign interrupt = s_rise_int;
	always @(posedge HCLK or negedge HRESETn)
		if (~HRESETn)
			r_status <= 'h0;
		else if (s_rise_int)
			r_status <= r_status | s_is_int_all;
		else if (((PSEL && PENABLE) && !PWRITE) && (s_apb_addr == 5'b01001)) begin : sv2v_autoblock_2
			reg signed [31:0] i;
			for (i = 0; i < 32; i = i + 1)
				if (i < PAD_NUM)
					r_status[i] <= 1'b0;
		end
		else if (((PSEL && PENABLE) && !PWRITE) && (s_apb_addr == 5'b10111)) begin : sv2v_autoblock_3
			reg signed [31:0] i;
			for (i = 32; i < 64; i = i + 1)
				if (i < PAD_NUM)
					r_status[i] <= 1'b0;
		end
	always @(*) begin : proc_cg_en
		begin : sv2v_autoblock_4
			reg signed [31:0] i;
			for (i = 0; i < 64; i = i + 1)
				if (i < PAD_NUM)
					s_cg_en[i] = r_gpio_en[i];
				else
					s_cg_en[i] = 1'b0;
		end
	end
	always @(*) begin : proc_clk_en
		begin : sv2v_autoblock_5
			reg signed [31:0] i;
			for (i = 0; i < 16; i = i + 1)
				s_clk_en[i] = ((s_cg_en[i * 4] | s_cg_en[(i * 4) + 1]) | s_cg_en[(i * 4) + 2]) | s_cg_en[(i * 4) + 3];
		end
	end
	always @(posedge HCLK or negedge HRESETn)
		if (~HRESETn) begin : sv2v_autoblock_6
			reg signed [31:0] j;
			for (j = 0; j < PAD_NUM; j = j + 1)
				begin
					r_gpio_in[j] <= 1'b0;
					r_gpio_sync1[j] <= 1'b0;
					r_gpio_sync0[j] <= 1'b0;
				end
		end
		else begin : sv2v_autoblock_7
			reg signed [31:0] j;
			for (j = 0; j < PAD_NUM; j = j + 1)
				if (s_clk_en[j / 4]) begin
					r_gpio_sync0[j] <= gpio_in[j];
					r_gpio_sync1[j] <= r_gpio_sync0[j];
					r_gpio_in[j] <= r_gpio_sync1[j];
				end
		end
	always @(posedge HCLK or negedge HRESETn)
		if (~HRESETn) begin : sv2v_autoblock_8
			reg signed [31:0] i;
			for (i = 0; i < PAD_NUM; i = i + 1)
				begin
					r_gpio_padcfg[i * 4+:4] <= 4'b0000;
					r_gpio_inttype[i * 2+:2] <= 2'b00;
					r_gpio_dir[i] <= 1'b0;
					r_gpio_out[i] <= 1'b0;
					r_gpio_inten[i] <= 1'b0;
					r_gpio_en[i] <= 1'b0;
				end
		end
		else begin : sv2v_autoblock_9
			reg signed [31:0] i;
			for (i = 0; i < PAD_NUM; i = i + 1)
				if (s_write) begin
					if (s_write_cfg[i])
						r_gpio_padcfg[i * 4+:4] <= s_gpio_padcfg[i * 4+:4];
					if (s_write_inttype[i])
						r_gpio_inttype[i * 2+:2] <= s_gpio_inttype[i * 2+:2];
					if (s_write_dir[i])
						r_gpio_dir[i] <= s_gpio_dir[i];
					if (s_write_out[i])
						r_gpio_out[i] <= s_gpio_out[i];
					if (s_write_inten[i])
						r_gpio_inten[i] <= s_gpio_inten[i];
					if (s_write_gpen[i])
						r_gpio_en[i] <= s_gpio_en[i];
				end
		end
	always @(*) begin
		s_write = 1'b0;
		s_write_dir = 64'h0000000000000000;
		s_write_out = 64'h0000000000000000;
		s_write_cfg = 64'h0000000000000000;
		s_write_inten = 64'h0000000000000000;
		s_write_gpen = 64'h0000000000000000;
		s_write_inttype = 64'h0000000000000000;
		begin : sv2v_autoblock_10
			reg signed [31:0] i;
			for (i = 0; i < 64; i = i + 1)
				if (i < PAD_NUM) begin
					s_gpio_padcfg[i * 4+:4] = r_gpio_padcfg[i * 4+:4];
					s_gpio_inttype[i * 2+:2] = r_gpio_inttype[i * 2+:2];
					s_gpio_dir[i] = r_gpio_dir[i];
					s_gpio_out[i] = r_gpio_out[i];
					s_gpio_inten[i] = r_gpio_inten[i];
					s_gpio_en[i] = r_gpio_en[i];
				end
				else begin
					s_gpio_padcfg[i * 4+:4] = 4'b0000;
					s_gpio_inttype[i * 2+:2] = 2'b00;
					s_gpio_dir[i] = 1'b0;
					s_gpio_out[i] = 1'b0;
					s_gpio_inten[i] = 1'b0;
					s_gpio_en[i] = 1'b0;
				end
		end
		if ((PSEL && PENABLE) && PWRITE) begin
			s_write = 1'b1;
			case (s_apb_addr)
				5'b00000: begin
					s_write_dir[31:0] = 32'hffffffff;
					s_gpio_dir[31:0] = PWDATA;
				end
				5'b01110: begin
					s_write_dir[63:32] = 32'hffffffff;
					s_gpio_dir[63:32] = PWDATA;
				end
				5'b00011: begin
					s_write_out[31:0] = 32'hffffffff;
					s_gpio_out[31:0] = PWDATA;
				end
				5'b10001: begin
					s_write_out[63:32] = 32'hffffffff;
					s_gpio_out[63:32] = PWDATA;
				end
				5'b00100: begin
					s_write_out[31:0] = 32'hffffffff;
					begin : sv2v_autoblock_11
						reg signed [31:0] i;
						for (i = 0; i < 32; i = i + 1)
							if (i < PAD_NUM)
								s_gpio_out[i] = r_gpio_out[i] | PWDATA[i];
					end
				end
				5'b10010: begin
					s_write_out[63:32] = 32'hffffffff;
					begin : sv2v_autoblock_12
						reg signed [31:0] i;
						for (i = 32; i < 64; i = i + 1)
							if (i < PAD_NUM)
								s_gpio_out[i] = r_gpio_out[i] | PWDATA[i - 32];
					end
				end
				5'b00101: begin
					s_write_out[31:0] = 32'hffffffff;
					begin : sv2v_autoblock_13
						reg signed [31:0] i;
						for (i = 0; i < 32; i = i + 1)
							if (i < PAD_NUM)
								s_gpio_out[i] = r_gpio_out[i] & ~PWDATA[i];
					end
				end
				5'b10011: begin
					s_write_out[63:32] = 32'hffffffff;
					begin : sv2v_autoblock_14
						reg signed [31:0] i;
						for (i = 32; i < 64; i = i + 1)
							if (i < PAD_NUM)
								s_gpio_out[i] = r_gpio_out[i] & ~PWDATA[i - 32];
					end
				end
				5'b00110: begin
					s_write_inten[31:0] = 32'hffffffff;
					s_gpio_inten[31:0] = PWDATA;
				end
				5'b10100: begin
					s_write_inten[63:32] = 32'hffffffff;
					s_gpio_inten[63:32] = PWDATA;
				end
				5'b00111: begin
					s_write_inttype[15:0] = 16'hffff;
					s_gpio_inttype[0+:2] = PWDATA[1:0];
					s_gpio_inttype[2+:2] = PWDATA[3:2];
					s_gpio_inttype[4+:2] = PWDATA[5:4];
					s_gpio_inttype[6+:2] = PWDATA[7:6];
					s_gpio_inttype[8+:2] = PWDATA[9:8];
					s_gpio_inttype[10+:2] = PWDATA[11:10];
					s_gpio_inttype[12+:2] = PWDATA[13:12];
					s_gpio_inttype[14+:2] = PWDATA[15:14];
					s_gpio_inttype[16+:2] = PWDATA[17:16];
					s_gpio_inttype[18+:2] = PWDATA[19:18];
					s_gpio_inttype[20+:2] = PWDATA[21:20];
					s_gpio_inttype[22+:2] = PWDATA[23:22];
					s_gpio_inttype[24+:2] = PWDATA[25:24];
					s_gpio_inttype[26+:2] = PWDATA[27:26];
					s_gpio_inttype[28+:2] = PWDATA[29:28];
					s_gpio_inttype[30+:2] = PWDATA[31:30];
				end
				5'b01000: begin
					s_write_inttype[31:16] = 16'hffff;
					s_gpio_inttype[32+:2] = PWDATA[1:0];
					s_gpio_inttype[34+:2] = PWDATA[3:2];
					s_gpio_inttype[36+:2] = PWDATA[5:4];
					s_gpio_inttype[38+:2] = PWDATA[7:6];
					s_gpio_inttype[40+:2] = PWDATA[9:8];
					s_gpio_inttype[42+:2] = PWDATA[11:10];
					s_gpio_inttype[44+:2] = PWDATA[13:12];
					s_gpio_inttype[46+:2] = PWDATA[15:14];
					s_gpio_inttype[48+:2] = PWDATA[17:16];
					s_gpio_inttype[50+:2] = PWDATA[19:18];
					s_gpio_inttype[52+:2] = PWDATA[21:20];
					s_gpio_inttype[54+:2] = PWDATA[23:22];
					s_gpio_inttype[56+:2] = PWDATA[25:24];
					s_gpio_inttype[58+:2] = PWDATA[27:26];
					s_gpio_inttype[60+:2] = PWDATA[29:28];
					s_gpio_inttype[62+:2] = PWDATA[31:30];
				end
				5'b10101: begin
					s_write_inttype[47:32] = 16'hffff;
					s_gpio_inttype[64+:2] = PWDATA[1:0];
					s_gpio_inttype[66+:2] = PWDATA[3:2];
					s_gpio_inttype[68+:2] = PWDATA[5:4];
					s_gpio_inttype[70+:2] = PWDATA[7:6];
					s_gpio_inttype[72+:2] = PWDATA[9:8];
					s_gpio_inttype[74+:2] = PWDATA[11:10];
					s_gpio_inttype[76+:2] = PWDATA[13:12];
					s_gpio_inttype[78+:2] = PWDATA[15:14];
					s_gpio_inttype[80+:2] = PWDATA[17:16];
					s_gpio_inttype[82+:2] = PWDATA[19:18];
					s_gpio_inttype[84+:2] = PWDATA[21:20];
					s_gpio_inttype[86+:2] = PWDATA[23:22];
					s_gpio_inttype[88+:2] = PWDATA[25:24];
					s_gpio_inttype[90+:2] = PWDATA[27:26];
					s_gpio_inttype[92+:2] = PWDATA[29:28];
					s_gpio_inttype[94+:2] = PWDATA[31:30];
				end
				5'b10110: begin
					s_write_inttype[63:48] = 16'hffff;
					s_gpio_inttype[96+:2] = PWDATA[1:0];
					s_gpio_inttype[98+:2] = PWDATA[3:2];
					s_gpio_inttype[100+:2] = PWDATA[5:4];
					s_gpio_inttype[102+:2] = PWDATA[7:6];
					s_gpio_inttype[104+:2] = PWDATA[9:8];
					s_gpio_inttype[106+:2] = PWDATA[11:10];
					s_gpio_inttype[108+:2] = PWDATA[13:12];
					s_gpio_inttype[110+:2] = PWDATA[15:14];
					s_gpio_inttype[112+:2] = PWDATA[17:16];
					s_gpio_inttype[114+:2] = PWDATA[19:18];
					s_gpio_inttype[116+:2] = PWDATA[21:20];
					s_gpio_inttype[118+:2] = PWDATA[23:22];
					s_gpio_inttype[120+:2] = PWDATA[25:24];
					s_gpio_inttype[122+:2] = PWDATA[27:26];
					s_gpio_inttype[124+:2] = PWDATA[29:28];
					s_gpio_inttype[126+:2] = PWDATA[31:30];
				end
				5'b00001: begin
					s_write_gpen[31:0] = 32'hffffffff;
					s_gpio_en[31:0] = PWDATA;
				end
				5'b01111: begin
					s_write_gpen[63:32] = 32'hffffffff;
					s_gpio_en[63:32] = PWDATA;
				end
				5'b01010: begin
					s_write_cfg[7:0] = 8'hff;
					s_gpio_padcfg[0+:4] = PWDATA[3:0];
					s_gpio_padcfg[4+:4] = PWDATA[7:4];
					s_gpio_padcfg[8+:4] = PWDATA[11:8];
					s_gpio_padcfg[12+:4] = PWDATA[15:12];
					s_gpio_padcfg[16+:4] = PWDATA[19:16];
					s_gpio_padcfg[20+:4] = PWDATA[23:20];
					s_gpio_padcfg[24+:4] = PWDATA[27:24];
					s_gpio_padcfg[28+:4] = PWDATA[31:28];
				end
				5'b01011: begin
					s_write_cfg[15:8] = 8'hff;
					s_gpio_padcfg[32+:4] = PWDATA[3:0];
					s_gpio_padcfg[36+:4] = PWDATA[7:4];
					s_gpio_padcfg[40+:4] = PWDATA[11:8];
					s_gpio_padcfg[44+:4] = PWDATA[15:12];
					s_gpio_padcfg[48+:4] = PWDATA[19:16];
					s_gpio_padcfg[52+:4] = PWDATA[23:20];
					s_gpio_padcfg[56+:4] = PWDATA[27:24];
					s_gpio_padcfg[60+:4] = PWDATA[31:28];
				end
				5'b01100: begin
					s_write_cfg[23:16] = 8'hff;
					s_gpio_padcfg[64+:4] = PWDATA[3:0];
					s_gpio_padcfg[68+:4] = PWDATA[7:4];
					s_gpio_padcfg[72+:4] = PWDATA[11:8];
					s_gpio_padcfg[76+:4] = PWDATA[15:12];
					s_gpio_padcfg[80+:4] = PWDATA[19:16];
					s_gpio_padcfg[84+:4] = PWDATA[23:20];
					s_gpio_padcfg[88+:4] = PWDATA[27:24];
					s_gpio_padcfg[92+:4] = PWDATA[31:28];
				end
				5'b01101: begin
					s_write_cfg[31:24] = 8'hff;
					s_gpio_padcfg[96+:4] = PWDATA[3:0];
					s_gpio_padcfg[100+:4] = PWDATA[7:4];
					s_gpio_padcfg[104+:4] = PWDATA[11:8];
					s_gpio_padcfg[108+:4] = PWDATA[15:12];
					s_gpio_padcfg[112+:4] = PWDATA[19:16];
					s_gpio_padcfg[116+:4] = PWDATA[23:20];
					s_gpio_padcfg[120+:4] = PWDATA[27:24];
					s_gpio_padcfg[124+:4] = PWDATA[31:28];
				end
				5'b11000: begin
					s_write_cfg[39:32] = 8'hff;
					s_gpio_padcfg[128+:4] = PWDATA[3:0];
					s_gpio_padcfg[132+:4] = PWDATA[7:4];
					s_gpio_padcfg[136+:4] = PWDATA[11:8];
					s_gpio_padcfg[140+:4] = PWDATA[15:12];
					s_gpio_padcfg[144+:4] = PWDATA[19:16];
					s_gpio_padcfg[148+:4] = PWDATA[23:20];
					s_gpio_padcfg[152+:4] = PWDATA[27:24];
					s_gpio_padcfg[156+:4] = PWDATA[31:28];
				end
				5'b11001: begin
					s_write_cfg[47:40] = 8'hff;
					s_gpio_padcfg[160+:4] = PWDATA[3:0];
					s_gpio_padcfg[164+:4] = PWDATA[7:4];
					s_gpio_padcfg[168+:4] = PWDATA[11:8];
					s_gpio_padcfg[172+:4] = PWDATA[15:12];
					s_gpio_padcfg[176+:4] = PWDATA[19:16];
					s_gpio_padcfg[180+:4] = PWDATA[23:20];
					s_gpio_padcfg[184+:4] = PWDATA[27:24];
					s_gpio_padcfg[188+:4] = PWDATA[31:28];
				end
				5'b11010: begin
					s_write_cfg[55:48] = 8'hff;
					s_gpio_padcfg[192+:4] = PWDATA[3:0];
					s_gpio_padcfg[196+:4] = PWDATA[7:4];
					s_gpio_padcfg[200+:4] = PWDATA[11:8];
					s_gpio_padcfg[204+:4] = PWDATA[15:12];
					s_gpio_padcfg[208+:4] = PWDATA[19:16];
					s_gpio_padcfg[212+:4] = PWDATA[23:20];
					s_gpio_padcfg[216+:4] = PWDATA[27:24];
					s_gpio_padcfg[220+:4] = PWDATA[31:28];
				end
				5'b11011: begin
					s_write_cfg[63:56] = 8'hff;
					s_gpio_padcfg[224+:4] = PWDATA[3:0];
					s_gpio_padcfg[228+:4] = PWDATA[7:4];
					s_gpio_padcfg[232+:4] = PWDATA[11:8];
					s_gpio_padcfg[236+:4] = PWDATA[15:12];
					s_gpio_padcfg[240+:4] = PWDATA[19:16];
					s_gpio_padcfg[244+:4] = PWDATA[23:20];
					s_gpio_padcfg[248+:4] = PWDATA[27:24];
					s_gpio_padcfg[252+:4] = PWDATA[31:28];
				end
			endcase
		end
	end
	always @(*)
		if ((PSEL && PENABLE) && !PWRITE)
			case (s_apb_addr)
				5'b00000: begin : sv2v_autoblock_15
					reg signed [31:0] i;
					for (i = 0; i < 32; i = i + 1)
						if (i < PAD_NUM)
							PRDATA[i] = r_gpio_dir[i];
						else
							PRDATA[i] = 1'b0;
				end
				5'b01110: begin : sv2v_autoblock_16
					reg signed [31:0] i;
					for (i = 32; i < 64; i = i + 1)
						if (i < PAD_NUM)
							PRDATA[i - 32] = r_gpio_dir[i];
						else
							PRDATA[i - 32] = 1'b0;
				end
				5'b00010: begin : sv2v_autoblock_17
					reg signed [31:0] i;
					for (i = 0; i < 32; i = i + 1)
						if (i < PAD_NUM)
							PRDATA[i] = r_gpio_in[i];
						else
							PRDATA[i] = 1'b0;
				end
				5'b10000: begin : sv2v_autoblock_18
					reg signed [31:0] i;
					for (i = 32; i < 64; i = i + 1)
						if (i < PAD_NUM)
							PRDATA[i - 32] = r_gpio_in[i];
						else
							PRDATA[i - 32] = 1'b0;
				end
				5'b00011: begin : sv2v_autoblock_19
					reg signed [31:0] i;
					for (i = 0; i < 32; i = i + 1)
						if (i < PAD_NUM)
							PRDATA[i] = r_gpio_out[i];
						else
							PRDATA[i] = 1'b0;
				end
				5'b10001: begin : sv2v_autoblock_20
					reg signed [31:0] i;
					for (i = 32; i < 64; i = i + 1)
						if (i < PAD_NUM)
							PRDATA[i - 32] = r_gpio_out[i];
						else
							PRDATA[i - 32] = 1'b0;
				end
				5'b00110: begin : sv2v_autoblock_21
					reg signed [31:0] i;
					for (i = 0; i < 32; i = i + 1)
						if (i < PAD_NUM)
							PRDATA[i] = r_gpio_inten[i];
						else
							PRDATA[i] = 1'b0;
				end
				5'b10100: begin : sv2v_autoblock_22
					reg signed [31:0] i;
					for (i = 32; i < 64; i = i + 1)
						if (i < PAD_NUM)
							PRDATA[i - 32] = r_gpio_inten[i];
						else
							PRDATA[i - 32] = 1'b0;
				end
				5'b00111: begin : sv2v_autoblock_23
					reg signed [31:0] i;
					for (i = 0; i < 16; i = i + 1)
						if (i < PAD_NUM)
							PRDATA[2 * i+:2] = r_gpio_inttype[i * 2+:2];
						else
							PRDATA[2 * i+:2] = 2'b00;
				end
				5'b01000: begin : sv2v_autoblock_24
					reg signed [31:0] i;
					for (i = 16; i < 32; i = i + 1)
						if (i < PAD_NUM)
							PRDATA[2 * (i - 16)+:2] = r_gpio_inttype[i * 2+:2];
						else
							PRDATA[2 * (i - 16)+:2] = 2'b00;
				end
				5'b10101: begin : sv2v_autoblock_25
					reg signed [31:0] i;
					for (i = 32; i < 48; i = i + 1)
						if (i < PAD_NUM)
							PRDATA[2 * (i - 32)+:2] = r_gpio_inttype[i * 2+:2];
						else
							PRDATA[2 * (i - 32)+:2] = 2'b00;
				end
				5'b10110: begin : sv2v_autoblock_26
					reg signed [31:0] i;
					for (i = 48; i < 64; i = i + 1)
						if (i < PAD_NUM)
							PRDATA[2 * (i - 48)+:2] = r_gpio_inttype[i * 2+:2];
						else
							PRDATA[2 * (i - 48)+:2] = 2'b00;
				end
				5'b01001: begin : sv2v_autoblock_27
					reg signed [31:0] i;
					for (i = 0; i < 32; i = i + 1)
						if (i < PAD_NUM)
							PRDATA[i] = r_status[i];
						else
							PRDATA[i] = 1'b0;
				end
				5'b10111: begin : sv2v_autoblock_28
					reg signed [31:0] i;
					for (i = 32; i < 64; i = i + 1)
						if (i < PAD_NUM)
							PRDATA[i - 32] = r_status[i];
						else
							PRDATA[i - 32] = 1'b0;
				end
				5'b00001: begin : sv2v_autoblock_29
					reg signed [31:0] i;
					for (i = 0; i < 32; i = i + 1)
						if (i < PAD_NUM)
							PRDATA[i] = r_gpio_en[i];
						else
							PRDATA[i] = 1'b0;
				end
				5'b01111: begin : sv2v_autoblock_30
					reg signed [31:0] i;
					for (i = 32; i < 64; i = i + 1)
						if (i < PAD_NUM)
							PRDATA[i - 32] = r_gpio_en[i];
						else
							PRDATA[i - 32] = 1'b0;
				end
				5'b01010: begin : sv2v_autoblock_31
					reg signed [31:0] i;
					for (i = 0; i < 8; i = i + 1)
						if (i < PAD_NUM)
							PRDATA[4 * i+:4] = r_gpio_padcfg[i * 4+:4];
						else
							PRDATA[4 * i+:4] = 4'h0;
				end
				5'b01011: begin : sv2v_autoblock_32
					reg signed [31:0] i;
					for (i = 8; i < 16; i = i + 1)
						if (i < PAD_NUM)
							PRDATA[4 * (i - 8)+:4] = r_gpio_padcfg[i * 4+:4];
						else
							PRDATA[4 * (i - 8)+:4] = 4'h0;
				end
				5'b01100: begin : sv2v_autoblock_33
					reg signed [31:0] i;
					for (i = 16; i < 24; i = i + 1)
						if (i < PAD_NUM)
							PRDATA[4 * (i - 16)+:4] = r_gpio_padcfg[i * 4+:4];
						else
							PRDATA[4 * (i - 16)+:4] = 4'h0;
				end
				5'b01101: begin : sv2v_autoblock_34
					reg signed [31:0] i;
					for (i = 24; i < 32; i = i + 1)
						if (i < PAD_NUM)
							PRDATA[4 * (i - 24)+:4] = r_gpio_padcfg[i * 4+:4];
						else
							PRDATA[4 * (i - 24)+:4] = 4'h0;
				end
				5'b11000: begin : sv2v_autoblock_35
					reg signed [31:0] i;
					for (i = 32; i < 40; i = i + 1)
						if (i < PAD_NUM)
							PRDATA[4 * (i - 32)+:4] = r_gpio_padcfg[i * 4+:4];
						else
							PRDATA[4 * (i - 32)+:4] = 4'h0;
				end
				5'b11001: begin : sv2v_autoblock_36
					reg signed [31:0] i;
					for (i = 40; i < 48; i = i + 1)
						if (i < PAD_NUM)
							PRDATA[4 * (i - 40)+:4] = r_gpio_padcfg[i * 4+:4];
						else
							PRDATA[4 * (i - 40)+:4] = 4'h0;
				end
				5'b11010: begin : sv2v_autoblock_37
					reg signed [31:0] i;
					for (i = 48; i < 56; i = i + 1)
						if (i < PAD_NUM)
							PRDATA[4 * (i - 48)+:4] = r_gpio_padcfg[i * 4+:4];
						else
							PRDATA[4 * (i - 48)+:4] = 4'h0;
				end
				5'b11011: begin : sv2v_autoblock_38
					reg signed [31:0] i;
					for (i = 56; i < 64; i = i + 1)
						if (i < PAD_NUM)
							PRDATA[4 * (i - 56)+:4] = r_gpio_padcfg[i * 4+:4];
						else
							PRDATA[4 * (i - 56)+:4] = 4'h0;
				end
				default: PRDATA = 'h0;
			endcase
		else
			PRDATA = 'h0;
	assign gpio_out = r_gpio_out;
	assign gpio_dir = r_gpio_dir;
	assign PREADY = 1'b1;
	assign PSLVERR = 1'b0;
endmodule
