module input_buffer (
	cr_fifo,
	enable_strided_conv,
	enable_deconv,
	odd_X_tile,
	clk,
	reset,
	enable,
	parallel_input_array,
	loading_in_parallel,
	shift_input_buffer,
	serial_input,
	mode,
	clear,
	output_array
);
	input [1:0] cr_fifo;
	input enable_strided_conv;
	input enable_deconv;
	input odd_X_tile;
	input clk;
	input reset;
	input clear;
	input enable;
	input loading_in_parallel;
	input [2:0] mode;
	localparam parameters_MAXIMUM_DILATION_BITS = 8;
	input [7:0] shift_input_buffer;
	localparam integer parameters_INPUT_CHANNEL_DATA_WIDTH = 8;
	localparam integer parameters_N_DIM_ARRAY = 8;
	input signed [(parameters_N_DIM_ARRAY * parameters_INPUT_CHANNEL_DATA_WIDTH) - 1:0] parallel_input_array;
	input signed [(parameters_N_DIM_ARRAY * parameters_INPUT_CHANNEL_DATA_WIDTH) - 1:0] serial_input;
	output reg signed [(parameters_N_DIM_ARRAY * parameters_INPUT_CHANNEL_DATA_WIDTH) - 1:0] output_array;
	reg signed [parameters_INPUT_CHANNEL_DATA_WIDTH - 1:0] FIFO [(2 * parameters_N_DIM_ARRAY) - 1:0];
	reg signed [parameters_INPUT_CHANNEL_DATA_WIDTH - 1:0] FIFO_output [(2 * parameters_N_DIM_ARRAY) - 1:0];
	localparam integer parameters_N_DIM_ARRAY_LOG = 3;
	reg [parameters_N_DIM_ARRAY_LOG:0] FIFO_POINTER;
	reg [parameters_N_DIM_ARRAY_LOG:0] index [(2 * parameters_N_DIM_ARRAY) - 1:0];
	reg [2:0] index_FIFO [parameters_N_DIM_ARRAY - 1:0];
	reg [parameters_N_DIM_ARRAY - 1:0] index_y;
	reg loading_in_parallel_reg;
	integer i;
	integer j;
	reg [parameters_N_DIM_ARRAY_LOG - 1:0] index_0;
	reg [parameters_N_DIM_ARRAY_LOG - 1:0] index_1;
	always @(posedge clk or negedge reset)
		if (!reset)
			loading_in_parallel_reg <= 0;
		else
			loading_in_parallel_reg <= loading_in_parallel;
	localparam integer parameters_MODE_CNN = 1;
	always @(posedge clk or negedge reset)
		if (!reset) begin
			for (i = 0; i < (2 * parameters_N_DIM_ARRAY); i = i + 1)
				FIFO[i] <= 0;
		end
		else if (clear == 1) begin
			for (i = 0; i < (2 * parameters_N_DIM_ARRAY); i = i + 1)
				FIFO[i] <= 0;
		end
		else if (mode == parameters_MODE_CNN)
			if ((enable_strided_conv == 1) && (loading_in_parallel == 1)) begin
				if (cr_fifo[0] == 0) begin
					for (i = 0; i < parameters_N_DIM_ARRAY; i = i + 1)
						FIFO[i] <= parallel_input_array[i * parameters_INPUT_CHANNEL_DATA_WIDTH+:parameters_INPUT_CHANNEL_DATA_WIDTH];
				end
				else if (cr_fifo[0] == 1)
					for (i = parameters_N_DIM_ARRAY; i < (2 * parameters_N_DIM_ARRAY); i = i + 1)
						FIFO[i] <= parallel_input_array[(i - parameters_N_DIM_ARRAY) * parameters_INPUT_CHANNEL_DATA_WIDTH+:parameters_INPUT_CHANNEL_DATA_WIDTH];
			end
			else if ((enable_deconv == 1) && (loading_in_parallel == 1)) begin
				if (cr_fifo[0] == 0) begin
					if (odd_X_tile == 0) begin
						FIFO[0] <= parallel_input_array[0+:parameters_INPUT_CHANNEL_DATA_WIDTH];
						FIFO[1] <= 0;
						FIFO[2] <= 0;
						FIFO[3] <= parallel_input_array[parameters_INPUT_CHANNEL_DATA_WIDTH+:parameters_INPUT_CHANNEL_DATA_WIDTH];
						FIFO[4] <= parallel_input_array[parameters_INPUT_CHANNEL_DATA_WIDTH+:parameters_INPUT_CHANNEL_DATA_WIDTH];
						FIFO[5] <= 0;
						FIFO[6] <= 0;
						FIFO[7] <= parallel_input_array[2 * parameters_INPUT_CHANNEL_DATA_WIDTH+:parameters_INPUT_CHANNEL_DATA_WIDTH];
					end
					else if (parameters_N_DIM_ARRAY == 4) begin
						FIFO[0] <= parallel_input_array[2 * parameters_INPUT_CHANNEL_DATA_WIDTH+:parameters_INPUT_CHANNEL_DATA_WIDTH];
						FIFO[1] <= 0;
						FIFO[2] <= 0;
						FIFO[3] <= parallel_input_array[3 * parameters_INPUT_CHANNEL_DATA_WIDTH+:parameters_INPUT_CHANNEL_DATA_WIDTH];
						FIFO[4] <= parallel_input_array[3 * parameters_INPUT_CHANNEL_DATA_WIDTH+:parameters_INPUT_CHANNEL_DATA_WIDTH];
						FIFO[5] <= 0;
						FIFO[6] <= 0;
					end
					else if (parameters_N_DIM_ARRAY == 8) begin
						FIFO[0] <= parallel_input_array[4 * parameters_INPUT_CHANNEL_DATA_WIDTH+:parameters_INPUT_CHANNEL_DATA_WIDTH];
						FIFO[1] <= 0;
						FIFO[2] <= 0;
						FIFO[3] <= parallel_input_array[5 * parameters_INPUT_CHANNEL_DATA_WIDTH+:parameters_INPUT_CHANNEL_DATA_WIDTH];
						FIFO[4] <= parallel_input_array[5 * parameters_INPUT_CHANNEL_DATA_WIDTH+:parameters_INPUT_CHANNEL_DATA_WIDTH];
						FIFO[5] <= 0;
						FIFO[6] <= 0;
					end
				end
				else if (cr_fifo[0] == 1)
					if (odd_X_tile == 1)
						if (parameters_N_DIM_ARRAY == 4)
							FIFO[7] <= parallel_input_array[0+:parameters_INPUT_CHANNEL_DATA_WIDTH];
			end
			else if (((enable_deconv == 0) && (enable_strided_conv == 0)) && (loading_in_parallel_reg == 1)) begin
				if (cr_fifo[0] == 1)
					for (i = 0; i < parameters_N_DIM_ARRAY; i = i + 1)
						FIFO[i] <= parallel_input_array[i * parameters_INPUT_CHANNEL_DATA_WIDTH+:parameters_INPUT_CHANNEL_DATA_WIDTH];
			end
			else if (loading_in_parallel_reg == 0)
				if (enable == 1)
					for (i = 0; i < parameters_N_DIM_ARRAY; i = i + 1)
						if (i == FIFO_POINTER)
							if (enable_deconv == 1) begin
								for (j = 0; j < shift_input_buffer; j = j + 1)
									FIFO[i + j] <= 0;
							end
							else
								for (j = 0; j < shift_input_buffer; j = j + 1)
									FIFO[i + j] <= serial_input[j * parameters_INPUT_CHANNEL_DATA_WIDTH+:parameters_INPUT_CHANNEL_DATA_WIDTH];
	always @(*)
		for (j = 0; j < parameters_N_DIM_ARRAY; j = j + 1)
			if (j < shift_input_buffer) begin
				index_y[j] = j;
				index_FIFO[j] = FIFO_POINTER + index_y[j];
			end
			else begin
				index_y[j] = 0;
				index_FIFO[j] = 0;
			end
	always @(posedge clk or negedge reset)
		if (!reset)
			FIFO_POINTER <= 0;
		else if (clear == 1)
			FIFO_POINTER <= 0;
		else if (mode == parameters_MODE_CNN)
			if (loading_in_parallel_reg == 1)
				FIFO_POINTER <= 0;
			else if (enable_deconv == 1) begin
				if ((enable == 1) && (loading_in_parallel_reg == 0))
					FIFO_POINTER <= (FIFO_POINTER + shift_input_buffer) + 1;
			end
			else if ((enable == 1) && (loading_in_parallel == 0))
				FIFO_POINTER <= FIFO_POINTER + shift_input_buffer;
	always @(*) begin
		for (i = 0; i < (2 * parameters_N_DIM_ARRAY); i = i + 1)
			begin
				FIFO_output[i] = 0;
				index[i] = 0;
			end
		for (i = 0; i < (2 * parameters_N_DIM_ARRAY); i = i + 1)
			if (enable_strided_conv || enable_deconv) begin
				index[i] = i - FIFO_POINTER;
				FIFO_output[index[i]] = FIFO[i];
			end
			else if (i < parameters_N_DIM_ARRAY) begin
				index[i][parameters_N_DIM_ARRAY_LOG - 1:0] = i - FIFO_POINTER;
				FIFO_output[index[i]] = FIFO[i];
			end
	end
	localparam integer parameters_MODE_EWS = 3;
	localparam integer parameters_MODE_FC = 0;
	always @(*) begin
		for (i = 0; i < parameters_N_DIM_ARRAY; i = i + 1)
			output_array[i * parameters_INPUT_CHANNEL_DATA_WIDTH+:parameters_INPUT_CHANNEL_DATA_WIDTH] = 0;
		if ((mode == parameters_MODE_FC) || (mode == parameters_MODE_EWS)) begin
			for (i = 0; i < parameters_N_DIM_ARRAY; i = i + 1)
				output_array[i * parameters_INPUT_CHANNEL_DATA_WIDTH+:parameters_INPUT_CHANNEL_DATA_WIDTH] = parallel_input_array[i * parameters_INPUT_CHANNEL_DATA_WIDTH+:parameters_INPUT_CHANNEL_DATA_WIDTH];
		end
		else if (enable_strided_conv || enable_deconv) begin
			if (cr_fifo[1] == 0) begin
				for (i = 0; i < parameters_N_DIM_ARRAY; i = i + 1)
					output_array[i * parameters_INPUT_CHANNEL_DATA_WIDTH+:parameters_INPUT_CHANNEL_DATA_WIDTH] = FIFO_output[i << 1];
			end
			else if (cr_fifo[1] == 1)
				for (i = 0; i < parameters_N_DIM_ARRAY; i = i + 1)
					output_array[i * parameters_INPUT_CHANNEL_DATA_WIDTH+:parameters_INPUT_CHANNEL_DATA_WIDTH] = FIFO_output[(i << 1) + 1];
		end
		else
			for (i = 0; i < parameters_N_DIM_ARRAY; i = i + 1)
				output_array[i * parameters_INPUT_CHANNEL_DATA_WIDTH+:parameters_INPUT_CHANNEL_DATA_WIDTH] = FIFO_output[i];
	end
endmodule
