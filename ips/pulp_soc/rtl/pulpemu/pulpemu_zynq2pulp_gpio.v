module pulpemu_zynq2pulp_gpio (
	clk,
	rst_n,
	pulp2zynq_gpio,
	zynq2pulp_gpio,
	stdout_flushed,
	trace_flushed,
	cg_clken,
	fetch_en,
	mode_fmc_zynqn,
	fault_en,
	pulp_soc_rst_n,
	stdout_wait,
	trace_wait,
	eoc,
	return_val,
	zynq_safen_spis_o,
	zynq_safen_spim_o,
	zynq_safen_uart_o
);
	input wire clk;
	input wire rst_n;
	output reg [31:0] pulp2zynq_gpio;
	input wire [31:0] zynq2pulp_gpio;
	output reg stdout_flushed;
	output reg trace_flushed;
	output reg cg_clken;
	output reg fetch_en;
	output reg mode_fmc_zynqn;
	output reg fault_en;
	output reg pulp_soc_rst_n;
	input wire stdout_wait;
	input wire trace_wait;
	input wire eoc;
	input wire [1:0] return_val;
	output reg zynq_safen_spis_o;
	output reg zynq_safen_spim_o;
	output reg zynq_safen_uart_o;
	always @(posedge clk or negedge rst_n)
		if (rst_n == 1'b0)
			pulp2zynq_gpio <= 1'sb0;
		else begin
			pulp2zynq_gpio[3] = stdout_wait;
			pulp2zynq_gpio[4] = trace_wait;
			pulp2zynq_gpio[0] = eoc;
			pulp2zynq_gpio[2:1] = return_val;
		end
	always @(posedge clk or negedge rst_n)
		if (rst_n == 1'b0) begin
			stdout_flushed <= 1'b0;
			trace_flushed <= 1'b0;
			cg_clken <= 1'b0;
			fetch_en <= 1'b0;
			mode_fmc_zynqn <= 1'b0;
			fault_en <= 1'b0;
			pulp_soc_rst_n <= 1'b0;
			zynq_safen_spis_o <= 1'b1;
			zynq_safen_spim_o <= 1'b1;
			zynq_safen_uart_o <= 1'b1;
		end
		else begin
			stdout_flushed <= zynq2pulp_gpio[3];
			trace_flushed <= zynq2pulp_gpio[4];
			cg_clken <= zynq2pulp_gpio[30];
			fetch_en <= zynq2pulp_gpio[0];
			mode_fmc_zynqn <= zynq2pulp_gpio[2];
			fault_en <= zynq2pulp_gpio[29];
			pulp_soc_rst_n <= zynq2pulp_gpio[31];
			zynq_safen_spis_o <= zynq2pulp_gpio[8];
			zynq_safen_spim_o <= zynq2pulp_gpio[7];
			zynq_safen_uart_o <= zynq2pulp_gpio[6];
		end
endmodule
