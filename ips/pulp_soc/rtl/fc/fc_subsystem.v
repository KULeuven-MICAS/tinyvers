module fc_subsystem (
	clk_i,
	rst_ni,
	test_en_i,
	l2_data_master,
	l2_instr_master,
	l2_hwpe_master,
	apb_slave_eu,
	apb_slave_hwpe,
	fetch_en_i,
	boot_addr_i,
	debug_req_i,
	event_fifo_valid_i,
	event_fifo_fulln_o,
	event_fifo_data_i,
	events_i,
	hwpe_events_o,
	supervisor_mode_o,
	scan_en_in
);
	parameter CORE_TYPE = 0;
	parameter USE_FPU = 1;
	parameter USE_HWPE = 1;
	parameter N_EXT_PERF_COUNTERS = 1;
	parameter EVENT_ID_WIDTH = 8;
	parameter PER_ID_WIDTH = 32;
	parameter NB_HWPE_PORTS = 4;
	parameter PULP_SECURE = 1;
	parameter TB_RISCV = 0;
	parameter CORE_ID = 4'h0;
	parameter CLUSTER_ID = 6'h1f;
	input wire clk_i;
	input wire rst_ni;
	input wire test_en_i;
	input XBAR_TCDM_BUS.Master l2_data_master;
	input XBAR_TCDM_BUS.Master l2_instr_master;
	input XBAR_TCDM_BUS.Master [NB_HWPE_PORTS - 1:0] l2_hwpe_master;
	input APB_BUS.Slave apb_slave_eu;
	input APB_BUS.Slave apb_slave_hwpe;
	input wire fetch_en_i;
	input wire [31:0] boot_addr_i;
	input wire debug_req_i;
	input wire event_fifo_valid_i;
	output wire event_fifo_fulln_o;
	input wire [EVENT_ID_WIDTH - 1:0] event_fifo_data_i;
	input wire [31:0] events_i;
	output wire [1:0] hwpe_events_o;
	output wire supervisor_mode_o;
	input wire scan_en_in;
	localparam USE_IBEX = (CORE_TYPE == 1) || (CORE_TYPE == 2);
	localparam IBEX_RV32M = CORE_TYPE == 1;
	localparam IBEX_RV32E = CORE_TYPE == 2;
	wire core_irq_req;
	wire core_irq_sec;
	wire [4:0] core_irq_id;
	reg [4:0] core_irq_ack_id;
	wire core_irq_ack;
	reg [14:0] core_irq_fast;
	wire [3:0] irq_ack_id;
	wire [31:0] boot_addr;
	wire fetch_en_int;
	wire core_busy_int;
	wire perf_counters_int;
	wire [31:0] hart_id;
	wire core_clock_en;
	wire fetch_en_eu;
	wire [31:0] core_instr_addr;
	wire [31:0] core_instr_rdata;
	wire core_instr_req;
	wire core_instr_gnt;
	wire core_instr_rvalid;
	wire core_instr_err;
	wire [31:0] core_data_addr;
	wire [31:0] core_data_rdata;
	wire [31:0] core_data_wdata;
	wire core_data_req;
	wire core_data_gnt;
	wire core_data_rvalid;
	wire core_data_err;
	wire core_data_we;
	wire [3:0] core_data_be;
	wire is_scm_instr_req;
	wire is_scm_data_req;
	assign perf_counters_int = 1'b0;
	assign fetch_en_int = fetch_en_eu & fetch_en_i;
	assign hart_id = {21'b000000000000000000000, CLUSTER_ID[5:0], 1'b0, CORE_ID[3:0]};
	XBAR_TCDM_BUS core_data_bus();
	XBAR_TCDM_BUS core_instr_bus();
	assign l2_data_master.req = core_data_req;
	assign l2_data_master.add = core_data_addr;
	assign l2_data_master.wen = ~core_data_we;
	assign l2_data_master.wdata = core_data_wdata;
	assign l2_data_master.be = core_data_be;
	assign core_data_gnt = l2_data_master.gnt;
	assign core_data_rvalid = l2_data_master.r_valid;
	assign core_data_rdata = l2_data_master.r_rdata;
	assign core_data_err = l2_data_master.r_opc;
	assign l2_instr_master.req = core_instr_req;
	assign l2_instr_master.add = core_instr_addr;
	assign l2_instr_master.wen = 1'b1;
	assign l2_instr_master.wdata = 1'sb0;
	assign l2_instr_master.be = 4'b1111;
	assign core_instr_gnt = l2_instr_master.gnt;
	assign core_instr_rvalid = l2_instr_master.r_valid;
	assign core_instr_rdata = l2_instr_master.r_rdata;
	assign core_instr_err = l2_instr_master.r_opc;
	generate
		if (USE_IBEX == 0) begin : FC_CORE
			assign boot_addr = boot_addr_i;
			riscv_core #(
				.N_EXT_PERF_COUNTERS(N_EXT_PERF_COUNTERS),
				.PULP_SECURE(1),
				.PULP_CLUSTER(0),
				.FPU(USE_FPU),
				.FP_DIVSQRT(USE_FPU),
				.SHARED_FP(0),
				.SHARED_FP_DIVSQRT(2)
			) lFC_CORE(
				.clk_i(clk_i),
				.rst_ni(rst_ni),
				.clock_en_i(core_clock_en),
				.test_en_i(test_en_i),
				.boot_addr_i(boot_addr),
				.core_id_i(CORE_ID),
				.cluster_id_i(CLUSTER_ID),
				.instr_addr_o(core_instr_addr),
				.instr_req_o(core_instr_req),
				.instr_rdata_i(core_instr_rdata),
				.instr_gnt_i(core_instr_gnt),
				.instr_rvalid_i(core_instr_rvalid),
				.data_addr_o(core_data_addr),
				.data_req_o(core_data_req),
				.data_be_o(core_data_be),
				.data_rdata_i(core_data_rdata),
				.data_we_o(core_data_we),
				.data_gnt_i(core_data_gnt),
				.data_wdata_o(core_data_wdata),
				.data_rvalid_i(core_data_rvalid),
				.apu_master_req_o(),
				.apu_master_ready_o(),
				.apu_master_gnt_i(1'b1),
				.apu_master_operands_o(),
				.apu_master_op_o(),
				.apu_master_type_o(),
				.apu_master_flags_o(),
				.apu_master_valid_i(1'sb0),
				.apu_master_result_i(1'sb0),
				.apu_master_flags_i(1'sb0),
				.irq_i(core_irq_req),
				.irq_id_i(core_irq_id),
				.irq_ack_o(core_irq_ack),
				.irq_id_o(core_irq_ack_id),
				.irq_sec_i(1'b0),
				.sec_lvl_o(),
				.debug_req_i(debug_req_i),
				.fetch_enable_i(fetch_en_int),
				.core_busy_o(),
				.ext_perf_counters_i(perf_counters_int),
				.fregfile_disable_i(1'b0)
			);
		end
		else begin : FC_CORE
			assign boot_addr = boot_addr_i & 32'hffffff00;
			ibex_core #(
				.PMPEnable(0),
				.MHPMCounterNum(8),
				.MHPMCounterWidth(40),
				.RV32E(IBEX_RV32E),
				.RV32M(IBEX_RV32M),
				.DmHaltAddr(32'h1a110800),
				.DmExceptionAddr(32'h1a110808)
			) lFC_CORE(
				.clk_i(clk_i),
				.rst_ni(rst_ni),
				.test_en_i(test_en_i),
				.hart_id_i(hart_id),
				.boot_addr_i(boot_addr),
				.instr_addr_o(core_instr_addr),
				.instr_req_o(core_instr_req),
				.instr_rdata_i(core_instr_rdata),
				.instr_gnt_i(core_instr_gnt),
				.instr_rvalid_i(core_instr_rvalid),
				.instr_err_i(core_instr_err),
				.data_addr_o(core_data_addr),
				.data_req_o(core_data_req),
				.data_be_o(core_data_be),
				.data_rdata_i(core_data_rdata),
				.data_we_o(core_data_we),
				.data_gnt_i(core_data_gnt),
				.data_wdata_o(core_data_wdata),
				.data_rvalid_i(core_data_rvalid),
				.data_err_i(core_data_err),
				.irq_software_i(1'b0),
				.irq_timer_i(1'b0),
				.irq_external_i(1'b0),
				.irq_fast_i(core_irq_fast),
				.irq_nm_i(1'b0),
				.irq_ack_o(core_irq_ack),
				.irq_ack_id_o(irq_ack_id),
				.debug_req_i(debug_req_i),
				.fetch_enable_i(fetch_en_int),
				.core_sleep_o()
			);
		end
	endgenerate
	assign supervisor_mode_o = 1'b1;
	generate
		if (USE_IBEX == 1) begin : convert_irqs
			always @(*) begin : gen_core_irq_fast
				core_irq_fast = 1'sb0;
				if (core_irq_req && (core_irq_id == 26))
					core_irq_fast[10] = 1'b1;
				else if (core_irq_req && (core_irq_id < 15))
					core_irq_fast[core_irq_id] = 1'b1;
			end
			always @(*) begin : gen_core_irq_ack_id
				if (irq_ack_id == 10)
					core_irq_ack_id = 26;
				else
					core_irq_ack_id = {1'b0, irq_ack_id};
			end
		end
	endgenerate
	apb_interrupt_cntrl #(.PER_ID_WIDTH(PER_ID_WIDTH)) fc_eu_i(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.test_mode_i(scan_en_in),
		.events_i(events_i),
		.event_fifo_valid_i(event_fifo_valid_i),
		.event_fifo_fulln_o(event_fifo_fulln_o),
		.event_fifo_data_i(event_fifo_data_i),
		.core_secure_mode_i(1'b0),
		.core_irq_id_o(core_irq_id),
		.core_irq_req_o(core_irq_req),
		.core_irq_ack_i(core_irq_ack),
		.core_irq_id_i(core_irq_ack_id),
		.core_irq_sec_o(),
		.core_clock_en_o(core_clock_en),
		.fetch_en_o(fetch_en_eu),
		.apb_slave(apb_slave_eu)
	);
	generate
		if (USE_HWPE) begin : fc_hwpe_gen
			fc_hwpe #(
				.N_MASTER_PORT(NB_HWPE_PORTS),
				.ID_WIDTH(2)
			) i_fc_hwpe(
				.clk_i(clk_i),
				.rst_ni(rst_ni),
				.test_mode_i(test_en_i),
				.hwacc_xbar_master(l2_hwpe_master),
				.hwacc_cfg_slave(apb_slave_hwpe),
				.evt_o(hwpe_events_o),
				.scan_en_in(scan_en_in)
			);
		end
		else begin : no_fc_hwpe_gen
			assign hwpe_events_o = 1'sb0;
			assign apb_slave_hwpe.prdata = 1'sb0;
			assign apb_slave_hwpe.pready = 1'sb0;
			assign apb_slave_hwpe.pslverr = 1'sb0;
			genvar ii;
			for (ii = 0; ii < NB_HWPE_PORTS; ii = ii + 1) begin : genblk1
				assign l2_hwpe_master[ii].req = 1'sb0;
				assign l2_hwpe_master[ii].wen = 1'sb0;
				assign l2_hwpe_master[ii].wdata = 1'sb0;
				assign l2_hwpe_master[ii].be = 1'sb0;
				assign l2_hwpe_master[ii].add = 1'sb0;
			end
		end
	endgenerate
endmodule
