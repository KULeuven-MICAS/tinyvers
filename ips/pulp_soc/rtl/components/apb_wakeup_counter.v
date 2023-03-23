module apb_wakeup_counter (
	clk_i,
	rstn_i,
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
	sleep_send_LOGIC,
	sleep_send_L2,
	sleep_send_L2_UDMA,
	sleep_send_L1,
	sleep_send_UDMA,
	sleep_ack_LOGIC,
	sleep_ack_L2,
	sleep_ack_L2_UDMA,
	sleep_ack_L1,
	sleep_ack_UDMA,
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
	output wire sleep_send_LOGIC;
	output wire sleep_send_L2;
	output wire sleep_send_L2_UDMA;
	output wire sleep_send_L1;
	output wire sleep_send_UDMA;
	input wire sleep_ack_LOGIC;
	input wire sleep_ack_L2;
	input wire sleep_ack_L2_UDMA;
	input wire sleep_ack_L1;
	input wire sleep_ack_UDMA;
	input wire [31:0] reg_scratch_i;
	input wire reg_pmu_en_i;
	input wire [31:0] reg_pmu_mode_i;
	input wire wen_i;
	output wire [31:0] reg_scratch_o;
	output wire [31:0] reg_pmu_mode_o;
	output wire rstn_pg;
	output reg clk_en_system;
	output reg pg_logic_rstn_o;
	output reg pg_udma_rstn_o;
	output wire pg_ram_rom_rstn_o;
	output reg VDDA_out;
	output reg VDD_out;
	output reg VREF_out;
	output reg PORb;
	output reg RETb;
	output reg RSTb;
	output reg TRIM;
	output reg DPD;
	output reg CEb_HIGH;
	reg [31:0] curr_state;
	reg [31:0] next_state;
	reg [5:0] loopcount;
	wire one_msec;
	wire s_power;
	reg [31:0] msec_count;
	reg [31:0] reg_scratch_reg;
	reg [31:0] reg_pmu_mode_reg;
	wire sleep_send_IO;
	wire sleep_ack_IO;
	reg s_power_logic;
	reg s_power_mem;
	reg s_power_mem_udma;
	reg s_power_io;
	reg s_power_udma;
	reg s_power_mram;
	wire done_logic;
	wire done_mem;
	wire done_io;
	wire done_udma;
	wire done_l2_udma;
	wire done_mram;
	wire done_l1;
	wire sleep_ack_io;
	wire sleep_ack_ram_rom;
	wire sleep_ack_logic;
	wire sleep_ack_udma;
	reg is_sleeping;
	wire wakeup_alarm;
	wire clk_en_system_l2_udma;
	wire clk_en_system_l2;
	wire s_sleep_udma_en;
	wire s_sleep_l2_en;
	wire s_sleep_l2_udma_en;
	wire s_sleep_mram_en;
	wire s_sleep_io_en;
	wire s_sleep_operation;
	wire s_deep_sleep;
	wire s_pd_mram_active;
	wire s_pd_mram_sleep;
	wire s_pd_l2;
	wire s_pd_l2_udma;
	reg s_sleep_send_LOGIC;
	reg s_sleep_send_L2;
	reg s_sleep_send_L2_UDMA;
	reg s_sleep_send_L1;
	reg s_sleep_send_UDMA;
	reg s_isolate_LOGIC;
	reg s_isolate_L2;
	reg s_isolate_L2_UDMA;
	reg s_isolate_L1;
	reg s_isolate_UDMA;
	reg s_isolate_MRAM;
	wire s_clk_en_system;
	wire s_pg_logic_rstn_o;
	wire s_pg_udma_rstn_o;
	wire s_VDDA_out;
	wire s_VDD_out;
	wire s_VREF_out;
	wire s_PORb;
	wire s_RETb;
	wire s_RSTb;
	wire s_TRIM;
	wire s_DPD;
	wire s_CEb_HIGH;
	wire s_bypass_sleep_send_LOGIC;
	wire s_bypass_sleep_send_L2;
	wire s_bypass_sleep_send_L2_UDMA;
	wire s_bypass_sleep_send_L1;
	wire s_bypass_sleep_send_UDMA;
	wire s_bypass_isolate_LOGIC;
	wire s_bypass_isolate_L2;
	wire s_bypass_isolate_L2_UDMA;
	wire s_bypass_isolate_L1;
	wire s_bypass_isolate_UDMA;
	wire s_bypass_isolate_MRAM;
	wire s_bypass_clk_en_system;
	wire s_bypass_pg_logic_rstn_o;
	wire s_bypass_pg_udma_rstn_o;
	wire s_bypass_VDDA_out;
	wire s_bypass_VDD_out;
	wire s_bypass_VREF_out;
	wire s_bypass_PORb;
	wire s_bypass_RETb;
	wire s_bypass_RSTb;
	wire s_bypass_TRIM;
	wire s_bypass_DPD;
	wire s_bypass_CEb_HIGH;
	assign s_clk_en_system = clk_en_system_l2_udma || clk_en_system_l2;
	assign rstn_pg = !is_sleeping;
	assign s_sleep_operation = reg_pmu_mode_reg[0];
	assign s_pd_l2_udma = reg_pmu_mode_reg[1];
	assign s_pd_l2 = reg_pmu_mode_reg[2];
	assign s_pd_mram_sleep = reg_pmu_mode_reg[3];
	assign s_pd_mram_active = reg_pmu_mode_reg[4];
	assign s_sleep_udma_en = s_sleep_operation;
	assign s_sleep_l2_en = s_sleep_operation && !s_pd_l2;
	assign s_sleep_mram_en = s_sleep_operation && !s_pd_mram_sleep;
	assign s_sleep_l2_udma_en = s_sleep_operation && !s_pd_l2_udma;
	always @(posedge clk_i or negedge rstn_i) begin : main_fsm_seq
		if (~rstn_i)
			curr_state <= 32'd5;
		else
			curr_state <= next_state;
	end
	always @(*) begin : power_down_fsm
		next_state = 32'd0;
		case (curr_state)
			32'd5:
				if (~s_power || hold_wu) begin
					if (step_wu)
						next_state = 32'd6;
					else
						next_state = curr_state;
				end
				else if (s_power && ~hold_wu)
					next_state = 32'd2;
			32'd6:
				if (step_wu)
					next_state = curr_state;
				else
					next_state = 32'd2;
			32'd2:
				if ((~done_mem && ~done_l2_udma) || hold_wu) begin
					if (step_wu)
						next_state = 32'd7;
					else
						next_state = curr_state;
				end
				else if ((done_mem && done_l2_udma) && ~hold_wu)
					next_state = 32'd3;
			32'd7:
				if (step_wu)
					next_state = curr_state;
				else
					next_state = 32'd3;
			32'd3:
				if (~done_udma || hold_wu) begin
					if (step_wu)
						next_state = 32'd8;
					else
						next_state = curr_state;
				end
				else if (done_udma && ~hold_wu)
					next_state = 32'd1;
			32'd8:
				if (step_wu)
					next_state = curr_state;
				else
					next_state = 32'd1;
			32'd1:
				if (~done_mram || hold_wu) begin
					if (step_wu)
						next_state = 32'd9;
					else
						next_state = curr_state;
				end
				else if (done_mram && ~hold_wu)
					next_state = 32'd4;
			32'd9:
				if (step_wu)
					next_state = curr_state;
				else
					next_state = 32'd4;
			32'd4:
				if ((~done_logic && ~done_l1) || hold_wu) begin
					if (step_wu)
						next_state = 32'd10;
					else
						next_state = curr_state;
				end
				else if ((done_logic && done_l1) && ~hold_wu)
					next_state = 32'd0;
			32'd10:
				if (step_wu)
					next_state = curr_state;
				else
					next_state = 32'd0;
			32'd0:
				if (s_power || hold_wu) begin
					if (step_wu)
						next_state = 32'd11;
					else
						next_state = curr_state;
				end
				else if (~s_power && ~hold_wu)
					next_state = 32'd5;
			32'd11:
				if (step_wu)
					next_state = curr_state;
				else
					next_state = 32'd5;
			default: next_state = 32'd0;
		endcase
	end
	always @(*) begin
		s_power_io = 1'b0;
		s_power_mram = 1'b0;
		s_power_mem = 1'b0;
		s_power_mem_udma = 1'b0;
		s_power_udma = 1'b0;
		s_power_logic = 1'b0;
		case (curr_state)
			32'd0: begin
				s_power_io = 1'b1;
				s_power_mram = !s_pd_mram_active;
				s_power_mem = 1'b1;
				s_power_mem_udma = 1'b1;
				s_power_udma = 1'b1;
				s_power_logic = 1'b1;
			end
			32'd11: begin
				s_power_io = 1'b1;
				s_power_mram = !s_pd_mram_active;
				s_power_mem = 1'b1;
				s_power_mem_udma = 1'b1;
				s_power_udma = 1'b1;
				s_power_logic = 1'b1;
			end
			32'd1: begin
				s_power_io = 1'b1;
				s_power_mram = 1'b1;
				s_power_mem = 1'b1;
				s_power_mem_udma = 1'b1;
				s_power_udma = 1'b1;
				s_power_logic = 1'b0;
			end
			32'd9: begin
				s_power_io = 1'b1;
				s_power_mram = 1'b1;
				s_power_mem = 1'b1;
				s_power_mem_udma = 1'b1;
				s_power_udma = 1'b1;
				s_power_logic = 1'b0;
			end
			32'd2: begin
				s_power_io = 1'b1;
				s_power_mram = s_sleep_mram_en;
				s_power_mem = 1'b1;
				s_power_mem_udma = 1'b1;
				s_power_udma = s_sleep_udma_en;
				s_power_logic = 1'b0;
			end
			32'd7: begin
				s_power_io = 1'b1;
				s_power_mram = s_sleep_mram_en;
				s_power_mem = 1'b1;
				s_power_mem_udma = 1'b1;
				s_power_udma = s_sleep_udma_en;
				s_power_logic = 1'b0;
			end
			32'd3: begin
				s_power_io = 1'b1;
				s_power_mram = s_sleep_mram_en;
				s_power_mem = 1'b1;
				s_power_mem_udma = 1'b1;
				s_power_udma = 1'b1;
				s_power_logic = 1'b0;
			end
			32'd8: begin
				s_power_io = 1'b1;
				s_power_mram = s_sleep_mram_en;
				s_power_mem = 1'b1;
				s_power_mem_udma = 1'b1;
				s_power_udma = 1'b1;
				s_power_logic = 1'b0;
			end
			32'd4: begin
				s_power_io = 1'b1;
				s_power_mram = 1'b1;
				s_power_mem = 1'b1;
				s_power_mem_udma = 1'b1;
				s_power_udma = 1'b1;
				s_power_logic = 1'b1;
			end
			32'd10: begin
				s_power_io = 1'b1;
				s_power_mram = 1'b1;
				s_power_mem = 1'b1;
				s_power_mem_udma = 1'b1;
				s_power_udma = 1'b1;
				s_power_logic = 1'b1;
			end
			32'd5: begin
				s_power_io = 1'b0;
				s_power_mram = s_sleep_mram_en;
				s_power_mem = s_sleep_l2_en;
				s_power_mem_udma = s_sleep_l2_udma_en;
				s_power_udma = s_sleep_udma_en;
				s_power_logic = 1'b0;
			end
			32'd6: begin
				s_power_io = 1'b0;
				s_power_mram = s_sleep_mram_en;
				s_power_mem = s_sleep_l2_en;
				s_power_mem_udma = s_sleep_l2_udma_en;
				s_power_udma = s_sleep_udma_en;
				s_power_logic = 1'b0;
			end
			default: begin
				s_power_io = 1'b0;
				s_power_mram = 1'b0;
				s_power_mem = 1'b0;
				s_power_mem_udma = 1'b0;
				s_power_udma = 1'b0;
				s_power_logic = 1'b0;
			end
		endcase
	end
	PowerGateFSM PD_LOGIC(
		.clk(clk_i),
		.rst(rstn_i),
		.power(s_power_logic),
		.external_pg(ext_pg_logic),
		.sleep_send_byp(s_sleep_send_LOGIC),
		.sleep_send(sleep_send_LOGIC),
		.sleep_ack(sleep_ack_LOGIC),
		.reset(s_pg_logic_rstn_o),
		.isolate(),
		.wu_bypass_mux(wu_bypass_mux),
		.isolate_byp(s_isolate_LOGIC),
		.clk_en(),
		.done(done_logic)
	);
	PowerGateFSM PD_L2(
		.clk(clk_i),
		.rst(rstn_i),
		.power(s_power_mem),
		.external_pg(ext_pg_l2),
		.sleep_send_byp(s_sleep_send_L2),
		.sleep_send(sleep_send_L2),
		.sleep_ack(sleep_ack_L2),
		.reset(),
		.isolate(),
		.wu_bypass_mux(wu_bypass_mux),
		.isolate_byp(s_isolate_L2),
		.clk_en(clk_en_system_l2),
		.done(done_mem)
	);
	PowerGateFSM PD_L2_UDMA(
		.clk(clk_i),
		.rst(rstn_i),
		.power(s_power_mem_udma),
		.external_pg(ext_pg_l2_udma),
		.sleep_send_byp(s_sleep_send_L2_UDMA),
		.sleep_send(sleep_send_L2_UDMA),
		.sleep_ack(sleep_ack_L2_UDMA),
		.reset(),
		.isolate(),
		.wu_bypass_mux(wu_bypass_mux),
		.isolate_byp(s_isolate_L2_UDMA),
		.clk_en(clk_en_system_l2_udma),
		.done(done_l2_udma)
	);
	PowerGateFSM PD_L1(
		.clk(clk_i),
		.rst(rstn_i),
		.power(s_power_logic),
		.external_pg(ext_pg_l1),
		.sleep_send_byp(s_sleep_send_L1),
		.sleep_send(sleep_send_L1),
		.sleep_ack(sleep_ack_L1),
		.reset(),
		.isolate(),
		.wu_bypass_mux(wu_bypass_mux),
		.isolate_byp(s_isolate_L1),
		.clk_en(),
		.done(done_l1)
	);
	PowerGateFSM PD_UDMA(
		.clk(clk_i),
		.rst(rstn_i),
		.power(s_power_udma),
		.external_pg(ext_pg_udma),
		.sleep_send_byp(s_sleep_send_UDMA),
		.sleep_send(sleep_send_UDMA),
		.sleep_ack(sleep_ack_UDMA),
		.reset(s_pg_udma_rstn_o),
		.isolate(),
		.wu_bypass_mux(wu_bypass_mux),
		.isolate_byp(s_isolate_UDMA),
		.clk_en(),
		.done(done_udma)
	);
	PowerGateFSM_MRAM PD_MRAM(
		.clk(clk_i),
		.rst(rstn_i),
		.power(s_power_mram),
		.external_pg(ext_pg_mram),
		.VDDA_out(s_VDDA_out),
		.VDD_out(s_VDD_out),
		.VREF_out(s_VREF_out),
		.PORb(s_PORb),
		.RETb(s_RETb),
		.RSTb(s_RSTb),
		.TRIM(s_TRIM),
		.DPD(s_DPD),
		.CEb_HIGH(s_CEb_HIGH),
		.isolate(),
		.wu_bypass_mux(wu_bypass_mux),
		.isolate_byp(s_isolate_MRAM),
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
	bypass_register i_bypass_register(
		.clk_i(clk_i),
		.rstn_i(rstn_i),
		.wu_bypass_data_in(wu_bypass_data_in),
		.wu_bypass_en(wu_bypass_en),
		.wu_bypass_shift(wu_bypass_shift),
		.wu_bypass_data_out(wu_bypass_data_out),
		.bypass_sleep_send_LOGIC(s_bypass_sleep_send_LOGIC),
		.bypass_sleep_send_L2(s_bypass_sleep_send_L2),
		.bypass_sleep_send_L2_UDMA(s_bypass_sleep_send_L2_UDMA),
		.bypass_sleep_send_L1(s_bypass_sleep_send_L1),
		.bypass_sleep_send_UDMA(s_bypass_sleep_send_UDMA),
		.bypass_isolate_LOGIC(s_bypass_isolate_LOGIC),
		.bypass_isolate_L2(s_bypass_isolate_L2),
		.bypass_isolate_L2_UDMA(s_bypass_isolate_L2_UDMA),
		.bypass_isolate_L1(s_bypass_isolate_L1),
		.bypass_isolate_UDMA(s_bypass_isolate_UDMA),
		.bypass_isolate_MRAM(s_bypass_isolate_MRAM),
		.bypass_clk_en_system(s_bypass_clk_en_system),
		.bypass_pg_logic_rstn_o(s_bypass_pg_logic_rstn_o),
		.bypass_pg_udma_rstn_o(s_bypass_pg_udma_rstn_o),
		.bypass_VDDA_out(s_bypass_VDDA_out),
		.bypass_VDD_out(s_bypass_VDD_out),
		.bypass_VREF_out(s_bypass_VREF_out),
		.bypass_PORb(s_bypass_PORb),
		.bypass_RETb(s_bypass_RETb),
		.bypass_RSTb(s_bypass_RSTb),
		.bypass_TRIM(s_bypass_TRIM),
		.bypass_DPD(s_bypass_DPD),
		.bypass_CEb_HIGH(s_bypass_CEb_HIGH)
	);
	always @(*)
		if (wu_bypass_mux) begin
			s_sleep_send_LOGIC = s_bypass_sleep_send_LOGIC;
			s_sleep_send_L2 = s_bypass_sleep_send_L2;
			s_sleep_send_L2_UDMA = s_bypass_sleep_send_L2_UDMA;
			s_sleep_send_L1 = s_bypass_sleep_send_L1;
			s_sleep_send_UDMA = s_bypass_sleep_send_UDMA;
			s_isolate_LOGIC = s_bypass_isolate_LOGIC;
			s_isolate_L2 = s_bypass_isolate_L2;
			s_isolate_L2_UDMA = s_bypass_isolate_L2_UDMA;
			s_isolate_L1 = s_bypass_isolate_L1;
			s_isolate_UDMA = s_bypass_isolate_UDMA;
			s_isolate_MRAM = s_bypass_isolate_MRAM;
			clk_en_system = s_bypass_clk_en_system;
			pg_logic_rstn_o = s_bypass_pg_logic_rstn_o;
			pg_udma_rstn_o = s_bypass_pg_udma_rstn_o;
			VDDA_out = s_bypass_VDDA_out;
			VDD_out = s_bypass_VDD_out;
			VREF_out = s_bypass_VREF_out;
			PORb = s_bypass_PORb;
			RETb = s_bypass_RETb;
			RSTb = s_bypass_RSTb;
			TRIM = s_bypass_TRIM;
			DPD = s_bypass_DPD;
			CEb_HIGH = s_bypass_CEb_HIGH;
		end
		else begin
			s_sleep_send_LOGIC = 1;
			s_sleep_send_L2 = 1;
			s_sleep_send_L2_UDMA = 1;
			s_sleep_send_L1 = 1;
			s_sleep_send_UDMA = 1;
			s_isolate_LOGIC = 1;
			s_isolate_L2 = 1;
			s_isolate_L2_UDMA = 1;
			s_isolate_L1 = 1;
			s_isolate_UDMA = 1;
			s_isolate_MRAM = 1;
			clk_en_system = s_clk_en_system;
			pg_logic_rstn_o = s_pg_logic_rstn_o;
			pg_udma_rstn_o = s_pg_udma_rstn_o;
			VDDA_out = s_VDDA_out;
			VDD_out = s_VDD_out;
			VREF_out = s_VREF_out;
			PORb = s_PORb;
			RETb = s_RETb;
			RSTb = s_RSTb;
			TRIM = s_TRIM;
			DPD = s_DPD;
			CEb_HIGH = s_CEb_HIGH;
		end
endmodule
