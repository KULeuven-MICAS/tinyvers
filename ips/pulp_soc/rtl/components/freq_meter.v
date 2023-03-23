module freq_meter (clk);
	parameter FLL_NAME = "CLK_FLL";
	parameter MAX_SAMPLE = 1024;
	input clk;
	real past_time;
	real current_time;
	real PERIOD;
	real SAMPLES [0:MAX_SAMPLE - 1];
	real TOTAL_PERIOD;
	reg [31:0] counter_SAMPLES;
	reg print_freq;
	reg rstn;
	integer FILE;
	string filename = {FLL_NAME, ".log"};
	initial begin
		FILE = $fopen(filename, "w");
		rstn = 0;
		#(10) rstn = 1;
	end
	always @(posedge clk or negedge rstn)
		if (!rstn) begin
			current_time <= 0;
			past_time <= 0;
		end
		else begin
			current_time <= $time();
			past_time <= current_time;
		end
	always @(*) PERIOD = current_time - past_time;
	always @(posedge clk or negedge rstn)
		if (!rstn) begin
			print_freq <= 0;
			counter_SAMPLES <= 'h0;
		end
		else begin
			SAMPLES[counter_SAMPLES] <= PERIOD;
			if (counter_SAMPLES < (MAX_SAMPLE - 1)) begin
				counter_SAMPLES <= counter_SAMPLES + 1;
				print_freq <= 1'b0;
			end
			else begin
				print_freq <= 1'b1;
				counter_SAMPLES <= 0;
			end
		end
	always @(*)
		if (print_freq) begin
			TOTAL_PERIOD = 0;
			begin : sv2v_autoblock_1
				reg signed [31:0] i;
				for (i = 0; i < MAX_SAMPLE; i = i + 1)
					TOTAL_PERIOD = TOTAL_PERIOD + SAMPLES[i];
			end
			$fdisplay(FILE, "[%s  Frequecy]  is %f [MHz]\t @ %t [ns]", FLL_NAME, ((1000.0 * 1000.0) * MAX_SAMPLE) / TOTAL_PERIOD, $time() / 1000.0);
			$fflush(FILE);
		end
endmodule
