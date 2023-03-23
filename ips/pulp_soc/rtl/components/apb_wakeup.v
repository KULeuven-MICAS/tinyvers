module apb_wakeup (
	HCLK,
	clk_soc_ext_i,
	hold_wu,
	step_wu,
	wu_bypass_en,
	wu_bypass_data_in,
	wu_bypass_shift,
	wu_bypass_mux,
	wu_bypass_data_out,
	ext_pg_logic,
	ext_pg_l2,
	ext_pg_l2_udma,
	ext_pg_l1,
	ext_pg_udma,
	ext_pg_mram,
	HRESETn,
	PADDR,
	PWDATA,
	PWRITE,
	PSEL,
	PENABLE,
	PRDATA,
	PREADY,
	PSLVERR,
	ref_clk_i,
	rstn_i,
	clk_en_system,
	pg_logic_rstn_o,
	pg_udma_rstn_o,
	pg_ram_rom_rstn_o,
	VDDA_out,
	VDD_out,
	VREF_out,
	PORb,
	RETb,
	RSTb,
	TRIM,
	DPD,
	CEb_HIGH
);
	parameter APB_ADDR_WIDTH = 12;
	input wire HCLK;
	input wire clk_soc_ext_i;
	input wire hold_wu;
	input wire step_wu;
	input wire wu_bypass_en;
	input wire wu_bypass_data_in;
	input wire wu_bypass_shift;
	input wire wu_bypass_mux;
	output wire wu_bypass_data_out;
	input wire ext_pg_logic;
	input wire ext_pg_l2;
	input wire ext_pg_l2_udma;
	input wire ext_pg_l1;
	input wire ext_pg_udma;
	input wire ext_pg_mram;
	input wire HRESETn;
	input wire [APB_ADDR_WIDTH - 1:0] PADDR;
	input wire [31:0] PWDATA;
	input wire PWRITE;
	input wire PSEL;
	input wire PENABLE;
	output reg [31:0] PRDATA;
	output wire PREADY;
	output wire PSLVERR;
	input wire ref_clk_i;
	input wire rstn_i;
	output wire clk_en_system;
	output wire pg_logic_rstn_o;
	output wire pg_udma_rstn_o;
	output wire pg_ram_rom_rstn_o;
	output wire VDDA_out;
	output wire VDD_out;
	output wire VREF_out;
	output wire PORb;
	output wire RETb;
	output wire RSTb;
	output wire TRIM;
	output wire DPD;
	output wire CEb_HIGH;
	wire s_apb_write;
	wire [3:0] s_apb_addr;
	wire [31:0] reg_signature;
	reg [31:0] reg_scratch;
	wire [31:0] reg_scratch_pmu;
	reg reg_pmu_en;
	reg [31:0] reg_pmu_mode;
	wire [31:0] reg_pmu_mode_pmu;
	reg r_restore;
	wire s_pmu_ack;
	wire s_pmu_ack_sync;
	wire s_pmu_write_en;
	reg s_pmu_req;
	reg r_pmu_req;
	reg s_fsm_pready;
	wire pg_logic_rstn_unsyncd;
	wire pg_udma_rstn_unsyncd;
	wire pg_ram_rom_rstn_unsyncd;
	reg [31:0] curr_state;
	reg [31:0] next_state;
	assign s_apb_write = (PSEL && PENABLE) && PWRITE;
	assign s_apb_addr = PADDR[3:0];
	assign reg_signature = 24'hda41de;
	always @(posedge HCLK or negedge HRESETn)
		if (~HRESETn) begin
			reg_scratch <= 1'sb0;
			reg_pmu_en <= 1'b0;
			reg_pmu_mode <= 1'sb0;
			r_restore <= 1'b1;
		end
		else if (r_restore) begin
			r_restore <= 1'b0;
			reg_scratch <= reg_scratch_pmu;
			reg_pmu_mode <= reg_pmu_mode_pmu;
		end
		else if (s_apb_write)
			case (s_apb_addr)
				8'h04: reg_scratch <= PWDATA;
				8'h08: reg_pmu_en <= PWDATA;
				8'h0c: reg_pmu_mode <= PWDATA;
			endcase
	always @(*) begin
		PRDATA = 1'sb0;
		case (s_apb_addr)
			8'h00: PRDATA = reg_signature;
			8'h04: PRDATA = reg_scratch;
			8'h08: PRDATA = reg_pmu_en;
			8'h0c: PRDATA = reg_pmu_mode;
			default: PRDATA = 1'sb0;
		endcase
	end
	assign PREADY = s_fsm_pready;
	assign PSLVERR = 1'b0;
	always @(posedge HCLK or negedge HRESETn)
		if (~HRESETn)
			curr_state <= 32'd0;
		else begin
			curr_state <= next_state;
			r_pmu_req <= s_pmu_req;
		end
	always @(*) begin
		next_state = curr_state;
		s_pmu_req = 0;
		s_fsm_pready = 0;
		case (curr_state)
			32'd0:
				if (s_apb_write) begin
					next_state = 32'd1;
					s_fsm_pready = 0;
				end
				else
					s_fsm_pready = 1;
			32'd1:
				if (s_pmu_ack_sync)
					next_state = 32'd2;
				else begin
					s_pmu_req = 1;
					next_state = 32'd1;
				end
			32'd2:
				if (s_pmu_ack_sync)
					next_state = 32'd2;
				else
					next_state = 32'd3;
			32'd3: begin
				s_fsm_pready = 1'b1;
				next_state = 32'd0;
			end
		endcase
	end
	pulp_sync_wedge #(2) i_pmu_write_sync(
		.r_edge_o(s_pmu_write_en),
		.f_edge_o(),
		.serial_o(s_pmu_ack),
		.clk_i(ref_clk_i),
		.rstn_i(HRESETn),
		.en_i(1'b1),
		.serial_i(s_pmu_req)
	);
	pulp_sync_wedge #(2) i_pmu_ack_sync(
		.r_edge_o(),
		.f_edge_o(),
		.serial_o(s_pmu_ack_sync),
		.clk_i(HCLK),
		.rstn_i(HRESETn),
		.en_i(1'b1),
		.serial_i(s_pmu_ack)
	);
	pulp_sync_n #(2) i_pg_logic_rstn_sync(
		.serial_o(pg_logic_rstn_o),
		.clk_i(clk_soc_ext_i),
		.serial_i(pg_logic_rstn_unsyncd)
	);
	pulp_sync_n #(2) i_pg_udma_rstn_sync(
		.serial_o(pg_udma_rstn_o),
		.clk_i(clk_soc_ext_i),
		.serial_i(pg_udma_rstn_unsyncd)
	);
	pulp_sync_n #(2) i_pg_ram_rom_rstn_sync(
		.serial_o(pg_ram_rom_rstn_o),
		.clk_i(clk_soc_ext_i),
		.serial_i(pg_ram_rom_rstn_unsyncd)
	);
	wire sleep_send_LOGIC;
	wire sleep_send_L2;
	wire sleep_send_L2_UDMA;
	wire sleep_send_L1;
	wire sleep_send_UDMA;
	wire sleep_ack_LOGIC;
	wire sleep_ack_L2;
	wire sleep_ack_L2_UDMA;
	wire sleep_ack_L1;
	wire sleep_ack_UDMA;
	power_gating_shift i_power_gating_shift(
		.sleep_send_LOGIC(sleep_send_LOGIC),
		.sleep_send_L2(sleep_send_L2),
		.sleep_send_L2_UDMA(sleep_send_L2_UDMA),
		.sleep_send_L1(sleep_send_L1),
		.sleep_send_UDMA(sleep_send_UDMA),
		.sleep_ack_LOGIC(sleep_ack_LOGIC),
		.sleep_ack_L2(sleep_ack_L2),
		.sleep_ack_L2_UDMA(sleep_ack_L2_UDMA),
		.sleep_ack_L1(sleep_ack_L1),
		.sleep_ack_UDMA(sleep_ack_UDMA)
	);
	wire rstn_pg;
	apb_wakeup_counter i_apb_wakeup_counter(
		.clk_i(ref_clk_i),
		.rstn_i(rstn_i),
		.hold_wu(hold_wu),
		.step_wu(step_wu),
		.wu_bypass_en(wu_bypass_en),
		.wu_bypass_data_in(wu_bypass_data_in),
		.wu_bypass_shift(wu_bypass_shift),
		.wu_bypass_mux(wu_bypass_mux),
		.wu_bypass_data_out(wu_bypass_data_out),
		.ext_pg_logic(ext_pg_logic),
		.ext_pg_l2(ext_pg_l2),
		.ext_pg_l2_udma(ext_pg_l2_udma),
		.ext_pg_l1(ext_pg_l1),
		.ext_pg_udma(ext_pg_udma),
		.ext_pg_mram(ext_pg_mram),
		.sleep_send_LOGIC(sleep_send_LOGIC),
		.sleep_send_L2(sleep_send_L2),
		.sleep_send_L2_UDMA(sleep_send_L2_UDMA),
		.sleep_send_L1(sleep_send_L1),
		.sleep_send_UDMA(sleep_send_UDMA),
		.sleep_ack_LOGIC(sleep_ack_LOGIC),
		.sleep_ack_L2(sleep_ack_L2),
		.sleep_ack_L2_UDMA(sleep_ack_L2_UDMA),
		.sleep_ack_L1(sleep_ack_L1),
		.sleep_ack_UDMA(sleep_ack_UDMA),
		.reg_scratch_i(reg_scratch),
		.reg_pmu_en_i(reg_pmu_en),
		.reg_pmu_mode_i(reg_pmu_mode),
		.wen_i(s_pmu_write_en),
		.reg_scratch_o(reg_scratch_pmu),
		.reg_pmu_mode_o(reg_pmu_mode_pmu),
		.rstn_pg(rstn_pg),
		.clk_en_system(clk_en_system),
		.pg_logic_rstn_o(pg_logic_rstn_unsyncd),
		.pg_udma_rstn_o(pg_udma_rstn_unsyncd),
		.pg_ram_rom_rstn_o(pg_ram_rom_rstn_unsyncd),
		.VDDA_out(VDDA_out),
		.VDD_out(VDD_out),
		.VREF_out(VREF_out),
		.PORb(PORb),
		.RETb(RETb),
		.RSTb(RSTb),
		.TRIM(TRIM),
		.DPD(DPD),
		.CEb_HIGH(CEb_HIGH)
	);
endmodule
