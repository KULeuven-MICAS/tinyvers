module apb_soc_ctrl (
	HCLK,
	HRESETn,
	PADDR,
	PWDATA,
	PWRITE,
	PSEL,
	PENABLE,
	PRDATA,
	PREADY,
	PSLVERR,
	sel_fll_clk_i,
	boot_l2_i,
	bootsel_i,
	pad_cfg,
	pad_mux,
	soc_jtag_reg_i,
	soc_jtag_reg_o,
	fc_bootaddr_o,
	fc_fetchen_o,
	sel_hyper_axi_o,
	cluster_pow_o,
	cluster_byp_o,
	cluster_boot_addr_o,
	cluster_fetch_enable_o,
	cluster_rstn_o,
	cluster_irq_o
);
	parameter APB_ADDR_WIDTH = 12;
	parameter NB_CLUSTERS = 0;
	parameter NB_CORES = 4;
	parameter JTAG_REG_SIZE = 8;
	input wire HCLK;
	input wire HRESETn;
	input wire [APB_ADDR_WIDTH - 1:0] PADDR;
	input wire [31:0] PWDATA;
	input wire PWRITE;
	input wire PSEL;
	input wire PENABLE;
	output reg [31:0] PRDATA;
	output wire PREADY;
	output wire PSLVERR;
	input wire sel_fll_clk_i;
	input wire boot_l2_i;
	input wire bootsel_i;
	output reg [383:0] pad_cfg;
	output reg [127:0] pad_mux;
	input wire [JTAG_REG_SIZE - 1:0] soc_jtag_reg_i;
	output wire [JTAG_REG_SIZE - 1:0] soc_jtag_reg_o;
	output wire [31:0] fc_bootaddr_o;
	output wire fc_fetchen_o;
	output wire sel_hyper_axi_o;
	output wire cluster_pow_o;
	output wire cluster_byp_o;
	output wire [63:0] cluster_boot_addr_o;
	output wire cluster_fetch_enable_o;
	output wire cluster_rstn_o;
	output wire cluster_irq_o;
	reg [31:0] r_pwr_reg;
	reg [31:0] r_corestatus;
	wire [6:0] s_apb_addr;
	wire [15:0] n_cores;
	wire [15:0] n_clusters;
	reg [63:0] r_pad_fun0;
	reg [63:0] r_pad_fun1;
	reg [63:0] r_cluster_boot;
	reg r_cluster_fetch_enable;
	reg r_cluster_rstn;
	reg [JTAG_REG_SIZE - 1:0] r_jtag_rego;
	reg [JTAG_REG_SIZE - 1:0] r_jtag_regi_sync [1:0];
	reg r_cluster_byp;
	reg r_cluster_pow;
	reg [31:0] r_bootaddr;
	reg r_fetchen;
	reg r_cluster_irq;
	reg r_sel_hyper_axi;
	reg [1:0] r_bootsel;
	wire s_apb_write;
	assign soc_jtag_reg_o = r_jtag_rego;
	assign fc_bootaddr_o = r_bootaddr;
	assign fc_fetchen_o = r_fetchen;
	assign cluster_pow_o = r_cluster_pow;
	assign sel_hyper_axi_o = r_sel_hyper_axi;
	assign s_apb_write = (PSEL && PENABLE) && PWRITE;
	assign cluster_rstn_o = r_cluster_rstn;
	assign cluster_boot_addr_o = r_cluster_boot;
	assign cluster_fetch_enable_o = r_cluster_fetch_enable;
	assign cluster_byp_o = r_cluster_byp;
	assign cluster_irq_o = r_cluster_irq;
	always @(*) begin : sv2v_autoblock_1
		reg signed [31:0] i;
		for (i = 0; i < 64; i = i + 1)
			begin
				pad_mux[i * 2] = r_pad_fun0[i];
				pad_mux[(i * 2) + 1] = r_pad_fun1[i];
			end
	end
	assign s_apb_addr = PADDR[8:2];
	always @(posedge HCLK or negedge HRESETn)
		if (~HRESETn) begin
			r_corestatus <= 1'sb0;
			r_pwr_reg <= 1'sb0;
			r_pad_fun0 <= 1'sb0;
			r_pad_fun1 <= 1'sb0;
			r_jtag_regi_sync[0] <= 'h0;
			r_jtag_regi_sync[1] <= 'h0;
			r_jtag_rego <= 'h0;
			r_bootaddr <= 32'h1a000080;
			r_fetchen <= 'h1;
			r_cluster_pow <= 1'b0;
			r_cluster_byp <= 1'b1;
			pad_cfg <= {64 {6'b111111}};
			r_sel_hyper_axi <= 1'b0;
			r_cluster_fetch_enable <= 1'b0;
			r_cluster_boot <= 1'sb0;
			r_cluster_rstn <= 1'b1;
			r_cluster_irq <= 1'b0;
		end
		else begin
			r_jtag_regi_sync[1] <= soc_jtag_reg_i;
			r_jtag_regi_sync[0] <= r_jtag_regi_sync[1];
			if ((PSEL && PENABLE) && PWRITE)
				case (s_apb_addr)
					7'b0000001: r_bootaddr <= PWDATA;
					7'b0000010: r_fetchen <= PWDATA[0];
					7'b0000100: begin : sv2v_autoblock_2
						reg signed [31:0] i;
						for (i = 0; i < 16; i = i + 1)
							begin
								r_pad_fun0[i] <= PWDATA[i * 2];
								r_pad_fun1[i] <= PWDATA[(i * 2) + 1];
							end
					end
					7'b0000101: begin : sv2v_autoblock_3
						reg signed [31:0] i;
						for (i = 0; i < 16; i = i + 1)
							begin
								r_pad_fun0[16 + i] <= PWDATA[i * 2];
								r_pad_fun1[16 + i] <= PWDATA[(i * 2) + 1];
							end
					end
					7'b0000110: begin : sv2v_autoblock_4
						reg signed [31:0] i;
						for (i = 0; i < 16; i = i + 1)
							begin
								r_pad_fun0[32 + i] <= PWDATA[i * 2];
								r_pad_fun1[32 + i] <= PWDATA[(i * 2) + 1];
							end
					end
					7'b0000111: begin : sv2v_autoblock_5
						reg signed [31:0] i;
						for (i = 0; i < 16; i = i + 1)
							begin
								r_pad_fun0[48 + i] <= PWDATA[i * 2];
								r_pad_fun1[48 + i] <= PWDATA[(i * 2) + 1];
							end
					end
					7'b0001000: begin
						pad_cfg[0+:6] <= PWDATA[5:0];
						pad_cfg[6+:6] <= PWDATA[13:8];
						pad_cfg[12+:6] <= PWDATA[21:16];
						pad_cfg[18+:6] <= PWDATA[29:24];
					end
					7'b0001001: begin
						pad_cfg[24+:6] <= PWDATA[5:0];
						pad_cfg[30+:6] <= PWDATA[13:8];
						pad_cfg[36+:6] <= PWDATA[21:16];
						pad_cfg[42+:6] <= PWDATA[29:24];
					end
					7'b0001010: begin
						pad_cfg[48+:6] <= PWDATA[5:0];
						pad_cfg[54+:6] <= PWDATA[13:8];
						pad_cfg[60+:6] <= PWDATA[21:16];
						pad_cfg[66+:6] <= PWDATA[29:24];
					end
					7'b0001011: begin
						pad_cfg[72+:6] <= PWDATA[5:0];
						pad_cfg[78+:6] <= PWDATA[13:8];
						pad_cfg[84+:6] <= PWDATA[21:16];
						pad_cfg[90+:6] <= PWDATA[29:24];
					end
					7'b0001100: begin
						pad_cfg[96+:6] <= PWDATA[5:0];
						pad_cfg[102+:6] <= PWDATA[13:8];
						pad_cfg[108+:6] <= PWDATA[21:16];
						pad_cfg[114+:6] <= PWDATA[29:24];
					end
					7'b0001101: begin
						pad_cfg[120+:6] <= PWDATA[5:0];
						pad_cfg[126+:6] <= PWDATA[13:8];
						pad_cfg[132+:6] <= PWDATA[21:16];
						pad_cfg[138+:6] <= PWDATA[29:24];
					end
					7'b0001110: begin
						pad_cfg[144+:6] <= PWDATA[5:0];
						pad_cfg[150+:6] <= PWDATA[13:8];
						pad_cfg[156+:6] <= PWDATA[21:16];
						pad_cfg[162+:6] <= PWDATA[29:24];
					end
					7'b0001111: begin
						pad_cfg[168+:6] <= PWDATA[5:0];
						pad_cfg[174+:6] <= PWDATA[13:8];
						pad_cfg[180+:6] <= PWDATA[21:16];
						pad_cfg[186+:6] <= PWDATA[29:24];
					end
					7'b0010000: begin
						pad_cfg[192+:6] <= PWDATA[5:0];
						pad_cfg[198+:6] <= PWDATA[13:8];
						pad_cfg[204+:6] <= PWDATA[21:16];
						pad_cfg[210+:6] <= PWDATA[29:24];
					end
					7'b0010001: begin
						pad_cfg[216+:6] <= PWDATA[5:0];
						pad_cfg[222+:6] <= PWDATA[13:8];
						pad_cfg[228+:6] <= PWDATA[21:16];
						pad_cfg[234+:6] <= PWDATA[29:24];
					end
					7'b0010010: begin
						pad_cfg[240+:6] <= PWDATA[5:0];
						pad_cfg[246+:6] <= PWDATA[13:8];
						pad_cfg[252+:6] <= PWDATA[21:16];
						pad_cfg[258+:6] <= PWDATA[29:24];
					end
					7'b0010011: begin
						pad_cfg[264+:6] <= PWDATA[5:0];
						pad_cfg[270+:6] <= PWDATA[13:8];
						pad_cfg[276+:6] <= PWDATA[21:16];
						pad_cfg[282+:6] <= PWDATA[29:24];
					end
					7'b0010100: begin
						pad_cfg[288+:6] <= PWDATA[5:0];
						pad_cfg[294+:6] <= PWDATA[13:8];
						pad_cfg[300+:6] <= PWDATA[21:16];
						pad_cfg[306+:6] <= PWDATA[29:24];
					end
					7'b0010101: begin
						pad_cfg[312+:6] <= PWDATA[5:0];
						pad_cfg[318+:6] <= PWDATA[13:8];
						pad_cfg[324+:6] <= PWDATA[21:16];
						pad_cfg[330+:6] <= PWDATA[29:24];
					end
					7'b0010110: begin
						pad_cfg[336+:6] <= PWDATA[5:0];
						pad_cfg[342+:6] <= PWDATA[13:8];
						pad_cfg[348+:6] <= PWDATA[21:16];
						pad_cfg[354+:6] <= PWDATA[29:24];
					end
					7'b0010111: begin
						pad_cfg[360+:6] <= PWDATA[5:0];
						pad_cfg[366+:6] <= PWDATA[13:8];
						pad_cfg[372+:6] <= PWDATA[21:16];
						pad_cfg[378+:6] <= PWDATA[29:24];
					end
					7'b0011101: r_jtag_rego <= PWDATA[JTAG_REG_SIZE - 1:0];
					7'b0101000: r_corestatus <= PWDATA[31:0];
					7'b0011100: begin
						r_cluster_byp <= PWDATA[0];
						r_cluster_pow <= PWDATA[1];
						r_cluster_fetch_enable <= PWDATA[2];
						r_cluster_rstn <= PWDATA[3];
					end
					7'b0011110:
						;
					7'b0011111: r_cluster_irq <= PWDATA[0];
					7'b0100000: r_cluster_boot[31:0] <= PWDATA;
					7'b0100001: r_cluster_boot[63:32] <= PWDATA;
					default:
						;
				endcase
		end
	always @(*) begin
		PRDATA = 1'sb0;
		case (s_apb_addr)
			7'b0000100: begin : sv2v_autoblock_6
				reg signed [31:0] i;
				for (i = 0; i < 16; i = i + 1)
					begin
						PRDATA[i * 2] = r_pad_fun0[i];
						PRDATA[(i * 2) + 1] = r_pad_fun1[i];
					end
			end
			7'b0000101: begin : sv2v_autoblock_7
				reg signed [31:0] i;
				for (i = 0; i < 16; i = i + 1)
					begin
						PRDATA[i * 2] = r_pad_fun0[16 + i];
						PRDATA[(i * 2) + 1] = r_pad_fun1[16 + i];
					end
			end
			7'b0000110: begin : sv2v_autoblock_8
				reg signed [31:0] i;
				for (i = 0; i < 16; i = i + 1)
					begin
						PRDATA[i * 2] = r_pad_fun0[32 + i];
						PRDATA[(i * 2) + 1] = r_pad_fun1[32 + i];
					end
			end
			7'b0000111: begin : sv2v_autoblock_9
				reg signed [31:0] i;
				for (i = 0; i < 16; i = i + 1)
					begin
						PRDATA[i * 2] = r_pad_fun0[48 + i];
						PRDATA[(i * 2) + 1] = r_pad_fun1[48 + i];
					end
			end
			7'b0001000: PRDATA = {2'b00, pad_cfg[18+:6], 2'b00, pad_cfg[12+:6], 2'b00, pad_cfg[6+:6], 2'b00, pad_cfg[0+:6]};
			7'b0001001: PRDATA = {2'b00, pad_cfg[42+:6], 2'b00, pad_cfg[36+:6], 2'b00, pad_cfg[30+:6], 2'b00, pad_cfg[24+:6]};
			7'b0001010: PRDATA = {2'b00, pad_cfg[66+:6], 2'b00, pad_cfg[60+:6], 2'b00, pad_cfg[54+:6], 2'b00, pad_cfg[48+:6]};
			7'b0001011: PRDATA = {2'b00, pad_cfg[90+:6], 2'b00, pad_cfg[84+:6], 2'b00, pad_cfg[78+:6], 2'b00, pad_cfg[72+:6]};
			7'b0001100: PRDATA = {2'b00, pad_cfg[114+:6], 2'b00, pad_cfg[108+:6], 2'b00, pad_cfg[102+:6], 2'b00, pad_cfg[96+:6]};
			7'b0001101: PRDATA = {2'b00, pad_cfg[138+:6], 2'b00, pad_cfg[132+:6], 2'b00, pad_cfg[126+:6], 2'b00, pad_cfg[120+:6]};
			7'b0001110: PRDATA = {2'b00, pad_cfg[162+:6], 2'b00, pad_cfg[156+:6], 2'b00, pad_cfg[150+:6], 2'b00, pad_cfg[144+:6]};
			7'b0001111: PRDATA = {2'b00, pad_cfg[186+:6], 2'b00, pad_cfg[180+:6], 2'b00, pad_cfg[174+:6], 2'b00, pad_cfg[168+:6]};
			7'b0010000: PRDATA = {2'b00, pad_cfg[210+:6], 2'b00, pad_cfg[204+:6], 2'b00, pad_cfg[198+:6], 2'b00, pad_cfg[192+:6]};
			7'b0010001: PRDATA = {2'b00, pad_cfg[234+:6], 2'b00, pad_cfg[228+:6], 2'b00, pad_cfg[222+:6], 2'b00, pad_cfg[216+:6]};
			7'b0010010: PRDATA = {2'b00, pad_cfg[258+:6], 2'b00, pad_cfg[252+:6], 2'b00, pad_cfg[246+:6], 2'b00, pad_cfg[240+:6]};
			7'b0010011: PRDATA = {2'b00, pad_cfg[282+:6], 2'b00, pad_cfg[276+:6], 2'b00, pad_cfg[270+:6], 2'b00, pad_cfg[264+:6]};
			7'b0010100: PRDATA = {2'b00, pad_cfg[306+:6], 2'b00, pad_cfg[300+:6], 2'b00, pad_cfg[294+:6], 2'b00, pad_cfg[288+:6]};
			7'b0010101: PRDATA = {2'b00, pad_cfg[330+:6], 2'b00, pad_cfg[324+:6], 2'b00, pad_cfg[318+:6], 2'b00, pad_cfg[312+:6]};
			7'b0010110: PRDATA = {2'b00, pad_cfg[354+:6], 2'b00, pad_cfg[348+:6], 2'b00, pad_cfg[342+:6], 2'b00, pad_cfg[336+:6]};
			7'b0010111: PRDATA = {2'b00, pad_cfg[378+:6], 2'b00, pad_cfg[372+:6], 2'b00, pad_cfg[366+:6], 2'b00, pad_cfg[360+:6]};
			7'b0000001: PRDATA = r_bootaddr;
			7'b0000000: PRDATA = {n_cores, n_clusters};
			7'b0101000: PRDATA = r_corestatus;
			7'b0110000: PRDATA = r_corestatus;
			7'b0110001: PRDATA = {30'h00000000, r_bootsel};
			7'b0110010: PRDATA = {31'h00000000, sel_fll_clk_i};
			7'b0011100: PRDATA = {29'h00000000, r_cluster_rstn, r_cluster_fetch_enable, r_cluster_pow, r_cluster_byp};
			7'b0011101: PRDATA = {16'h0000, r_jtag_regi_sync[0], r_jtag_rego};
			7'b0011110: PRDATA = {31'b0000000000000000000000000000000, r_sel_hyper_axi};
			7'b0011111: PRDATA = {31'b0000000000000000000000000000000, r_cluster_irq};
			7'b0100000: PRDATA = r_cluster_boot[31:0];
			7'b0100001: PRDATA = r_cluster_boot[63:32];
			default: PRDATA = 'h0;
		endcase
	end
	always @(posedge HCLK or negedge HRESETn)
		if (~HRESETn)
			r_bootsel <= 2'b00;
		else
			r_bootsel <= {r_bootsel[0], bootsel_i};
	assign n_cores = NB_CORES;
	assign n_clusters = NB_CLUSTERS;
	assign PREADY = 1'b1;
	assign PSLVERR = 1'b0;
endmodule
