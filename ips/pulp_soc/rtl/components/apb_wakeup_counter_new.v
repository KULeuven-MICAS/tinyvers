module apb_wakeup_counter (
	clk_i,
	rstn_i,
	reg_scratch_i,
	reg_pmu_en_i,
	reg_pmu_mode_i,
	wen_i,
	reg_scratch_o,
	reg_pmu_mode_o,
	rstn_pg,
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
	input wire clk_i;
	input wire rstn_i;
	input wire [31:0] reg_scratch_i;
	input wire reg_pmu_en_i;
	input wire [31:0] reg_pmu_mode_i;
	input wire wen_i;
	output wire [31:0] reg_scratch_o;
	output wire [31:0] reg_pmu_mode_o;
	output wire rstn_pg;
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
	reg [31:0] curr_state;
	reg [31:0] next_state;
	reg [5:0] loopcount;
	wire one_msec;
	wire s_power;
	reg [31:0] msec_count;
	reg [31:0] reg_scratch_reg;
	reg [31:0] reg_pmu_mode_reg;
	wire [2:0] enable_PD_send_LOGIC;
	wire [2:0] enable_PD_send_L2;
	wire [2:0] enable_PD_send_L1;
	wire [2:0] enable_PD_send_IO;
	wire [2:0] enable_PD_send_UDMA;
	wire [2:0] enable_PD_ack_LOGIC;
	wire [2:0] enable_PD_ack_L2;
	wire [2:0] enable_PD_ack_L1;
	wire [2:0] enable_PD_ack_IO;
	wire [2:0] enable_PD_ack_UDMA;
	reg s_power_logic;
	reg s_power_mem;
	reg s_power_io;
	reg s_power_udma;
	reg s_power_mram;
	wire done_logic;
	wire done_mem;
	wire done_io;
	wire done_udma;
	wire done_mram;
	wire done_l1;
	wire sleep_ack_io;
	wire sleep_ack_ram_rom;
	wire sleep_ack_logic;
	wire sleep_ack_udma;
	reg is_sleeping;
	wire wakeup_alarm;
	wire s_sleep_udma_en;
	wire s_sleep_l2_en;
	wire s_sleep_mram_en;
	wire s_sleep_io_en;
	wire s_sleep_operation;
	wire s_deep_sleep;
	wire s_pd_mram;
	wire s_pd_l2;
	assign rstn_pg = !is_sleeping;
	assign s_sleep_operation = reg_pmu_mode_reg[0];
	wire s_pd_io;
	assign s_pd_io = reg_pmu_mode_reg[1];
	assign s_pd_l2 = reg_pmu_mode_reg[2];
	assign s_pd_mram = reg_pmu_mode_reg[3];
	assign s_sleep_udma_en = (s_sleep_l2_en || s_sleep_mram_en) && !s_deep_sleep;
	assign s_sleep_l2_en = (s_sleep_operation && !s_pd_l2) && !s_deep_sleep;
	assign s_sleep_mram_en = (s_sleep_operation && !s_pd_mram) && !s_deep_sleep;
	assign s_sleep_io_en = (s_sleep_operation && !s_pd_io) && !s_deep_sleep;
	assign done_io = 1;
	always @(posedge clk_i or negedge rstn_i) begin : main_fsm_seq
		if (~rstn_i)
			curr_state <= 32'd6;
		else
			curr_state <= next_state;
	end
	always @(*) begin : power_down_fsm
		next_state = 32'd0;
		case (curr_state)
			32'd6:
				if (~s_power)
					next_state = curr_state;
				else
					next_state = 32'd1;
			32'd1:
				if (~done_io)
					next_state = curr_state;
				else
					next_state = 32'd2;
			32'd2:
				if (~done_mram)
					next_state = curr_state;
				else
					next_state = 32'd3;
			32'd3:
				if (~done_mem)
					next_state = curr_state;
				else
					next_state = 32'd4;
			32'd4:
				if (~done_udma)
					next_state = curr_state;
				else
					next_state = 32'd5;
			32'd5:
				if (~done_logic && ~done_l1)
					next_state = curr_state;
				else
					next_state = 32'd0;
			32'd0:
				if (s_power)
					next_state = curr_state;
				else
					next_state = 32'd6;
			default: next_state = 32'd0;
		endcase
	end
	always @(*) begin
		s_power_io = 1'b0;
		s_power_mram = 1'b0;
		s_power_mem = 1'b0;
		s_power_udma = 1'b0;
		s_power_logic = 1'b0;
		case (curr_state)
			32'd0: begin
				s_power_io = 1'b1;
				s_power_mram = !s_pd_mram;
				s_power_mem = 1'b1;
				s_power_udma = 1'b1;
				s_power_logic = 1'b1;
			end
			32'd1: begin
				s_power_io = 1'b1;
				s_power_mram = s_sleep_mram_en;
				s_power_mem = s_sleep_l2_en;
				s_power_udma = s_sleep_udma_en;
				s_power_logic = 1'b0;
			end
			32'd2: begin
				s_power_io = 1'b1;
				s_power_mram = 1'b1;
				s_power_mem = s_sleep_l2_en;
				s_power_udma = s_sleep_udma_en;
				s_power_logic = 1'b0;
			end
			32'd3: begin
				s_power_io = 1'b1;
				s_power_mram = 1'b1;
				s_power_mem = 1'b1;
				s_power_udma = s_sleep_udma_en;
				s_power_logic = 1'b0;
			end
			32'd4: begin
				s_power_io = 1'b1;
				s_power_mram = 1'b1;
				s_power_mem = 1'b1;
				s_power_udma = 1'b1;
				s_power_logic = 1'b0;
			end
			32'd5: begin
				s_power_io = 1'b1;
				s_power_mram = 1'b1;
				s_power_mem = 1'b1;
				s_power_udma = 1'b1;
				s_power_logic = 1'b1;
			end
			32'd6: begin
				s_power_io = s_sleep_io_en;
				s_power_mram = s_sleep_mram_en;
				s_power_mem = s_sleep_l2_en;
				s_power_udma = s_sleep_udma_en;
				s_power_logic = 1'b0;
			end
			default: begin
				s_power_io = 1'b0;
				s_power_mram = 1'b0;
				s_power_mem = 1'b0;
				s_power_udma = 1'b0;
				s_power_logic = 1'b0;
			end
		endcase
	end
	APC_wrapper PD_LOGIC(
		.clk(clk_i),
		.rst(rstn_i),
		.power(s_power_logic),
		.enable_PD_send(enable_PD_send_LOGIC),
		.enable_PD_ack(enable_PD_ack_LOGIC),
		.reset(pg_logic_rstn_o),
		.isolate(),
		.clk_en(),
		.done(done_logic)
	);
	DOMAIN_LOGIC_ring i_logic_ring(
		.VDD(),
		.VSS(),
		.VSS_SW(),
		.in(enable_PD_send_LOGIC),
		.out(enable_PD_ack_LOGIC)
	);
	APC_wrapper PD_L2(
		.clk(clk_i),
		.rst(rstn_i),
		.power(s_power_mem),
		.enable_PD_send(enable_PD_send_L2),
		.enable_PD_ack(enable_PD_ack_L2),
		.reset(),
		.isolate(),
		.clk_en(clk_en_system),
		.done(done_mem)
	);
	DOMAIN_L2_ring i_l2_ring(
		.VDD(),
		.VSS(),
		.VSS_SW(),
		.in(enable_PD_send_L2),
		.out(enable_PD_ack_L2)
	);
	APC_wrapper PD_L1(
		.clk(clk_i),
		.rst(rstn_i),
		.power(s_power_logic),
		.enable_PD_send(enable_PD_send_L1),
		.enable_PD_ack(enable_PD_ack_L1),
		.reset(),
		.isolate(),
		.clk_en(),
		.done(done_l1)
	);
	DOMAIN_L1_ring i_l1_ring(
		.VDD(),
		.VSS(),
		.VSS_SW(),
		.in(enable_PD_send_L1),
		.out(enable_PD_ack_L1)
	);
	APC_wrapper PD_UDMA(
		.clk(clk_i),
		.rst(rstn_i),
		.power(s_power_udma),
		.enable_PD_send(enable_PD_send_UDMA),
		.enable_PD_ack(enable_PD_ack_UDMA),
		.reset(pg_udma_rstn_o),
		.isolate(),
		.clk_en(),
		.done(done_udma)
	);
	DOMAIN_DMA_ring i_dma_ring(
		.VDD(),
		.VSS(),
		.VSS_SW(),
		.in(enable_PD_send_UDMA),
		.out(enable_PD_ack_UDMA)
	);
	PowerGateFSM_MRAM PD_MRAM(
		.clk(clk_i),
		.rst(rstn_i),
		.power(s_power_mram),
		.VDDA_out(VDDA_out),
		.VDD_out(VDD_out),
		.VREF_out(VREF_out),
		.PORb(PORb),
		.RETb(RETb),
		.RSTb(RSTb),
		.TRIM(TRIM),
		.DPD(DPD),
		.CEb_HIGH(CEb_HIGH),
		.isolate(),
		.done(done_mram)
	);
	assign one_msec = loopcount[5];
	assign s_power = !is_sleeping;
	always @(posedge clk_i or negedge rstn_i)
		if (~rstn_i)
			is_sleeping <= 1'sb0;
		else begin
			is_sleeping <= is_sleeping;
			case (is_sleeping)
				1'b0: is_sleeping <= wen_i && reg_pmu_en_i;
				1'b1: is_sleeping <= !wakeup_alarm;
			endcase
		end
	always @(posedge clk_i or negedge rstn_i)
		if (~rstn_i) begin
			reg_scratch_reg <= 1'sb0;
			reg_pmu_mode_reg <= 1'sb0;
		end
		else if (wen_i == 1'b1) begin
			reg_scratch_reg <= reg_scratch_i;
			reg_pmu_mode_reg <= reg_pmu_mode_i;
		end
	assign reg_scratch_o = reg_scratch_reg;
	assign reg_pmu_mode_o = reg_pmu_mode_reg;
	always @(posedge clk_i or negedge rstn_i)
		if (~rstn_i)
			loopcount <= 1'sb0;
		else if (~is_sleeping || one_msec)
			loopcount <= 1'sb0;
		else if (is_sleeping)
			loopcount <= loopcount + 1;
	always @(posedge clk_i or negedge rstn_i)
		if (~rstn_i)
			msec_count <= 1'sb0;
		else if (is_sleeping) begin
			if (one_msec)
				msec_count <= msec_count + 1;
		end
		else
			msec_count <= 1'sb0;
	assign wakeup_alarm = msec_count >= reg_scratch_reg;
	assign s_deep_sleep = msec_count >= reg_pmu_mode_reg[31:4];
endmodule
