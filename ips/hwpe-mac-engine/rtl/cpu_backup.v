module cpu (
	clk,
	reset,
	enable,
	wr_en_ext_lut,
	wr_addr_ext_lut,
	wr_data_ext_lut,
	wr_en_ext_conf_reg,
	wr_addr_ext_conf_reg,
	wr_data_ext_conf_reg,
	wr_en_ext_im,
	wr_addr_ext_im,
	wr_data_ext_im,
	wr_en_ext_sparsity,
	wr_addr_ext_sparsity,
	wr_data_ext_sparsity,
	wr_en_ext_act_mem,
	wr_addr_ext_act_mem,
	wr_data_ext_act_mem,
	wr_en_ext_fc_w,
	wr_addr_ext_fc_w,
	wr_data_ext_fc_w,
	wr_en_ext_cnn_w,
	wr_addr_ext_cnn_w,
	wr_data_ext_cnn_w,
	rd_en_ext_act_mem,
	rd_addr_ext_act_mem,
	rd_data_ext_act_mem,
	INPUT_TILE_SIZE,
	WEIGHT_TILE_SIZE,
	NB_INPUT_TILE,
	NB_WEIGHT_TILE,
	MODE,
	SPARSITY,
	finished_network,
	wr_output_enable,
	wr_output_addr,
	wr_output_data
);
	input clk;
	input reset;
	input enable;
	input wr_en_ext_lut;
	input [31:0] wr_addr_ext_lut;
	input signed [63:0] wr_data_ext_lut;
	input wr_en_ext_conf_reg;
	input [31:0] wr_addr_ext_conf_reg;
	input [63:0] wr_data_ext_conf_reg;
	input wr_en_ext_im;
	input [31:0] wr_addr_ext_im;
	input [63:0] wr_data_ext_im;
	input rd_en_ext_act_mem;
	input [31:0] rd_addr_ext_act_mem;
	localparam integer parameters_ACT_DATA_WIDTH = 8;
	localparam integer parameters_N_DIM_ARRAY = 8;
	output wire signed [(parameters_N_DIM_ARRAY * parameters_ACT_DATA_WIDTH) - 1:0] rd_data_ext_act_mem;
	input wr_en_ext_sparsity;
	input [31:0] wr_addr_ext_sparsity;
	input [63:0] wr_data_ext_sparsity;
	input wr_en_ext_act_mem;
	input [31:0] wr_addr_ext_act_mem;
	input signed [(parameters_N_DIM_ARRAY * parameters_ACT_DATA_WIDTH) - 1:0] wr_data_ext_act_mem;
	input wr_en_ext_fc_w;
	input [31:0] wr_addr_ext_fc_w;
	localparam integer parameters_WEIGHT_DATA_WIDTH = 8;
	input signed [(parameters_N_DIM_ARRAY * parameters_WEIGHT_DATA_WIDTH) - 1:0] wr_data_ext_fc_w;
	input wr_en_ext_cnn_w;
	input [31:0] wr_addr_ext_cnn_w;
	input signed [(parameters_N_DIM_ARRAY * parameters_WEIGHT_DATA_WIDTH) - 1:0] wr_data_ext_cnn_w;
	output wire wr_output_enable;
	output wire signed [(parameters_N_DIM_ARRAY * parameters_ACT_DATA_WIDTH) - 1:0] wr_output_data;
	output wire [31:0] wr_output_addr;
	output wire finished_network;
	output reg [15:0] INPUT_TILE_SIZE;
	output reg [15:0] WEIGHT_TILE_SIZE;
	output reg [7:0] NB_INPUT_TILE;
	output reg [7:0] NB_WEIGHT_TILE;
	output reg [2:0] MODE;
	output reg SPARSITY;
	wire [1:0] cr_fifo;
	wire enable_strided_conv;
	wire enable_deconv;
	wire odd_X_tile;
	wire signed [(parameters_N_DIM_ARRAY * parameters_ACT_DATA_WIDTH) - 1:0] output_array;
	wire signed [(parameters_N_DIM_ARRAY * parameters_ACT_DATA_WIDTH) - 1:0] output_array_vertical;
	reg signed [(parameters_N_DIM_ARRAY * parameters_ACT_DATA_WIDTH) - 1:0] wr_input_word_activation;
	wire signed [(parameters_N_DIM_ARRAY * parameters_ACT_DATA_WIDTH) - 1:0] output_nonlinear_block;
	wire [2:0] mode;
	wire clear;
	reg signed [(parameters_N_DIM_ARRAY * parameters_WEIGHT_DATA_WIDTH) - 1:0] cnn_weights_array;
	reg signed [(parameters_N_DIM_ARRAY * parameters_WEIGHT_DATA_WIDTH) - 1:0] cnn_input;
	reg signed [((parameters_N_DIM_ARRAY * parameters_N_DIM_ARRAY) * parameters_WEIGHT_DATA_WIDTH) - 1:0] fc_weights_array;
	reg signed [(parameters_N_DIM_ARRAY * parameters_WEIGHT_DATA_WIDTH) - 1:0] fc_input_array;
	localparam integer parameters_NUMBER_OF_CR_SIGNALS = 18;
	wire [((parameters_N_DIM_ARRAY * parameters_N_DIM_ARRAY) * parameters_NUMBER_OF_CR_SIGNALS) - 1:0] CR_PE_array;
	localparam integer parameters_TOTAL_ACTIVATION_MEMORY_SIZE = 65536;
	localparam integer parameters_INPUT_CHANNEL_ADDR_SIZE = 16;
	reg [parameters_INPUT_CHANNEL_ADDR_SIZE - 1:0] input_channel_rd_addr;
	wire [parameters_INPUT_CHANNEL_ADDR_SIZE - 1:0] input_channel_rd_addr_nl;
	wire [parameters_INPUT_CHANNEL_ADDR_SIZE - 1:0] input_channel_rd_addr_cu;
	wire [parameters_INPUT_CHANNEL_ADDR_SIZE - 1:0] input_channel_rd_addr_encoded;
	localparam integer parameters_TOTAL_WEIGHT_MEMORY_SIZE = 65536;
	localparam integer parameters_WEIGHT_MEMORY_ADDR_SIZE = 16;
	wire [parameters_WEIGHT_MEMORY_ADDR_SIZE - 1:0] weight_rd_addr;
	localparam integer parameters_INPUT_CHANNEL_DATA_WIDTH = 8;
	wire signed [(parameters_N_DIM_ARRAY * parameters_INPUT_CHANNEL_DATA_WIDTH) - 1:0] input_channel_read_word;
	wire signed [((parameters_N_DIM_ARRAY * parameters_N_DIM_ARRAY) * parameters_WEIGHT_DATA_WIDTH) - 1:0] weight_read_word;
	wire [parameters_INPUT_CHANNEL_ADDR_SIZE - 1:0] output_memory_pointer;
	wire [parameters_INPUT_CHANNEL_ADDR_SIZE - 1:0] input_memory_pointer;
	wire [parameters_INPUT_CHANNEL_ADDR_SIZE - 1:0] output_channel_size;
	reg [parameters_INPUT_CHANNEL_ADDR_SIZE - 1:0] wr_addr;
	wire [parameters_INPUT_CHANNEL_ADDR_SIZE - 1:0] wr_addr_nl;
	wire [parameters_INPUT_CHANNEL_ADDR_SIZE - 1:0] wr_addr_cu;
	wire [parameters_INPUT_CHANNEL_ADDR_SIZE - 1:0] wr_addr_encoded;
	wire [parameters_WEIGHT_MEMORY_ADDR_SIZE - 1:0] weight_memory_pointer;
	wire wr_clear_index;
	localparam integer parameters_NUMBER_OF_NONLINEAR_FUNCTIONS_BITS = 3;
	wire [parameters_NUMBER_OF_NONLINEAR_FUNCTIONS_BITS - 1:0] type_nonlinear_function;
	wire [7:0] shift_fixed_point;
	wire [31:0] MEMORY_POINTER_FC;
	wire [31:0] FIRST_INDEX_FC_LOG;
	wire [31:0] EXECUTION_FRAME_BY_FRAME;
	localparam parameters_MAXIMUM_DILATION_BITS = 8;
	wire [7:0] shift_input_buffer;
	wire [parameters_INPUT_CHANNEL_ADDR_SIZE - 1:0] FIFO_TCN_block_size;
	wire [parameters_INPUT_CHANNEL_ADDR_SIZE - 1:0] FIFO_TCN_total_blocks;
	wire [parameters_INPUT_CHANNEL_ADDR_SIZE - 1:0] FIFO_TCN_offset;
	wire FIFO_TCN_update_pointer;
	wire causal_convolution;
	reg wr_en_output_buffer;
	wire wr_en_output_buffer_nl;
	wire wr_en_output_buffer_cu;
	reg input_channel_rd_en;
	wire input_channel_rd_en_cu;
	wire input_channel_rd_en_nl;
	wire [31:0] NUMBER_OF_ACTIVATION_CYCLES;
	wire [15:0] C_X;
	wire [31:0] PADDED_C_X;
	wire [31:0] PADDED_O_X;
	wire [1:0] INPUT_PRECISION;
	wire [1:0] OUTPUT_PRECISION;
	reg [31:0] PC;
	wire enable_bias_32bits;
	wire [1:0] addr_bias_32bits;
	integer j;
	integer k;
	localparam integer parameters_INSTRUCTION_MEMORY_FIELDS = 32;
	localparam integer parameters_INSTRUCTION_MEMORY_WIDTH = 32;
	wire [(parameters_INSTRUCTION_MEMORY_FIELDS * parameters_INSTRUCTION_MEMORY_WIDTH) - 1:0] instruction;
	configuration_registers CONFIGURATION_REGISTERS(
		.clk(clk),
		.reset(reset),
		.wr_en_ext(wr_en_ext_conf_reg),
		.wr_addr_ext(wr_addr_ext_conf_reg),
		.wr_data_ext(wr_data_ext_conf_reg),
		.MEMORY_POINTER_FC(MEMORY_POINTER_FC),
		.EXECUTION_FRAME_BY_FRAME(EXECUTION_FRAME_BY_FRAME),
		.FIRST_INDEX_FC_LOG(FIRST_INDEX_FC_LOG)
	);
	instruction_memory INSTRUCTION_MEMORY(
		.clk(clk),
		.reset(reset),
		.PC(PC),
		.wr_addr_ext_im(wr_addr_ext_im),
		.wr_data_ext_im(wr_data_ext_im),
		.wr_en_ext_im(wr_en_ext_im),
		.instruction(instruction)
	);
	wire finished_activation;
	wire loading_in_parallel;
	wire enable_input_fifo;
	wire weight_rd_en;
	wire enable_pooling;
	wire enable_sig_tanh;
	wire enable_nonlinear_block;
	wire enable_BUFFERED_OUTPUT;
	wire enable_pe_array;
	control_unit CONTROL_UNIT(
		.cr_fifo(cr_fifo),
		.enable_strided_conv(enable_strided_conv),
		.enable_deconv(enable_deconv),
		.odd_X_tile(odd_X_tile),
		.clk(clk),
		.reset(reset),
		.enable(enable),
		.PC(PC),
		.instruction(instruction),
		.wr_en_ext_sparsity(wr_en_ext_sparsity),
		.wr_addr_ext_sparsity(wr_addr_ext_sparsity),
		.wr_data_ext_sparsity(wr_data_ext_sparsity),
		.enable_bias_32bits(enable_bias_32bits),
		.addr_bias_32bits(addr_bias_32bits),
		.EXECUTION_FRAME_BY_FRAME(EXECUTION_FRAME_BY_FRAME[0]),
		.NUMBER_OF_ACTIVATION_CYCLES(NUMBER_OF_ACTIVATION_CYCLES),
		.INPUT_TILE_SIZE(INPUT_TILE_SIZE),
		.WEIGHT_TILE_SIZE(WEIGHT_TILE_SIZE),
		.NB_INPUT_TILE(NB_INPUT_TILE),
		.NB_WEIGHT_TILE(NB_WEIGHT_TILE),
		.finished_activation(finished_activation),
		.clear(clear),
		.loading_in_parallel(loading_in_parallel),
		.CR_PE_array(CR_PE_array),
		.enable_input_fifo(enable_input_fifo),
		.input_channel_rd_en(input_channel_rd_en_cu),
		.input_channel_rd_addr(input_channel_rd_addr_cu),
		.weight_rd_en(weight_rd_en),
		.wr_en_output_buffer(wr_en_output_buffer_cu),
		.causal_convolution(causal_convolution),
		.wr_addr(wr_addr_cu),
		.weight_memory_pointer(weight_memory_pointer),
		.input_memory_pointer(input_memory_pointer),
		.output_memory_pointer(output_memory_pointer),
		.output_channel_size(output_channel_size),
		.weight_rd_addr(weight_rd_addr),
		.finished_network(finished_network),
		.type_nonlinear_function(type_nonlinear_function),
		.enable_pooling(enable_pooling),
		.enable_sig_tanh(enable_sig_tanh),
		.enable_nonlinear_block(enable_nonlinear_block),
		.PADDED_C_X(PADDED_C_X),
		.enable_BUFFERED_OUTPUT(enable_BUFFERED_OUTPUT),
		.INPUT_PRECISION(INPUT_PRECISION),
		.OUTPUT_PRECISION(OUTPUT_PRECISION),
		.PADDED_O_X(PADDED_O_X),
		.enable_pe_array(enable_pe_array),
		.shift_input_buffer(shift_input_buffer),
		.SHIFT_FIXED_POINT(shift_fixed_point),
		.FIFO_TCN_total_blocks(FIFO_TCN_total_blocks),
		.FIFO_TCN_block_size(FIFO_TCN_block_size),
		.FIFO_TCN_offset(FIFO_TCN_offset),
		.FIFO_TCN_update_pointer(FIFO_TCN_update_pointer),
		.mode(mode)
	);
	weight_memory WRAPPER_WEIGHT_MEMORY(
		.wr_en_ext_fc_w(wr_en_ext_fc_w),
		.wr_addr_ext_fc_w(wr_addr_ext_fc_w[parameters_WEIGHT_MEMORY_ADDR_SIZE - 1:0]),
		.wr_data_ext_fc_w(wr_data_ext_fc_w),
		.wr_en_ext_cnn_w(wr_en_ext_cnn_w),
		.wr_addr_ext_cnn_w(wr_addr_ext_cnn_w[parameters_WEIGHT_MEMORY_ADDR_SIZE - 1:0]),
		.wr_data_ext_cnn_w(wr_data_ext_cnn_w),
		.mode(mode),
		.weight_memory_pointer(weight_memory_pointer),
		.FIRST_INDEX_FC_LOG(FIRST_INDEX_FC_LOG),
		.MEMORY_POINTER_FC(MEMORY_POINTER_FC),
		.clk(clk),
		.reset(reset),
		.enable(enable),
		.rd_en(weight_rd_en),
		.rd_addr(weight_rd_addr),
		.read_word(weight_read_word)
	);
	encoder_FIFO ENCODER_FIFO_0(
		.clk(clk),
		.reset(reset),
		.input_rd_address(input_channel_rd_addr),
		.input_wr_address(wr_addr),
		.FIFO_TCN_active(EXECUTION_FRAME_BY_FRAME[0]),
		.FIFO_TCN_update_pointer(FIFO_TCN_update_pointer),
		.rd_enable(input_channel_rd_en),
		.wr_enable(wr_en_output_buffer),
		.FIFO_TCN_total_blocks(FIFO_TCN_total_blocks),
		.FIFO_TCN_block_size(FIFO_TCN_block_size),
		.FIFO_TCN_offset(FIFO_TCN_offset),
		.output_rd_address(input_channel_rd_addr_encoded),
		.output_wr_address(wr_addr_encoded)
	);
	activation_memory ACTIVATION_MEMORY(
		.wr_en_ext(wr_en_ext_act_mem),
		.wr_addr_ext(wr_addr_ext_act_mem[parameters_INPUT_CHANNEL_ADDR_SIZE - 1:0]),
		.wr_data_ext(wr_data_ext_act_mem),
		.rd_en_ext(rd_en_ext_act_mem),
		.rd_addr_ext(rd_addr_ext_act_mem[parameters_INPUT_CHANNEL_ADDR_SIZE - 1:0]),
		.rd_data_ext(rd_data_ext_act_mem),
		.mode(mode),
		.loading_in_parallel(loading_in_parallel),
		.clk(clk),
		.reset(reset),
		.rd_en(input_channel_rd_en),
		.rd_addr(input_channel_rd_addr_encoded),
		.read_word(input_channel_read_word),
		.wr_en(wr_en_output_buffer),
		.wr_addr_input(wr_addr_encoded),
		.wr_input_word(wr_input_word_activation),
		.input_memory_pointer(input_memory_pointer),
		.output_memory_pointer(output_memory_pointer)
	);
	localparam integer parameters_LUT_SIZE = 128;
	localparam integer parameters_LUT_ADDR = 7;
	localparam integer parameters_LUT_DATA_WIDTH = 8;
	nonlinear_block NONLINEAR_BLOCK(
		.clk(clk),
		.reset(reset),
		.PRECISION(INPUT_PRECISION),
		.wr_en_ext_lut(wr_en_ext_lut),
		.wr_addr_ext_lut(wr_addr_ext_lut[parameters_LUT_ADDR - 1:0]),
		.wr_data_ext_lut(wr_data_ext_lut[parameters_LUT_DATA_WIDTH - 1:0]),
		.NUMBER_OF_ACTIVATION_CYCLES(NUMBER_OF_ACTIVATION_CYCLES),
		.PADDED_C_X(PADDED_C_X[15:0]),
		.PADDED_O_X(PADDED_O_X[15:0]),
		.SHIFT_FIXED_POINT(shift_fixed_point),
		.finished_activation(finished_activation),
		.enable_pooling(enable_pooling),
		.enable_sig_tanh(enable_sig_tanh),
		.input_channel_rd_addr(input_channel_rd_addr_nl),
		.input_channel_rd_en(input_channel_rd_en_nl),
		.wr_en_output_buffer_nl(wr_en_output_buffer_nl),
		.wr_addr_nl(wr_addr_nl),
		.read_word(input_channel_read_word),
		.output_word(output_nonlinear_block),
		.type_nonlinear_function(type_nonlinear_function),
		.enable_nonlinear_block(enable_nonlinear_block)
	);
	array_pes ARRAY_PES(
		.cr_fifo(cr_fifo),
		.enable_strided_conv(enable_strided_conv),
		.enable_deconv(enable_deconv),
		.odd_X_tile(odd_X_tile),
		.enable_BUFFERED_OUTPUT(enable_BUFFERED_OUTPUT),
		.INPUT_PRECISION(INPUT_PRECISION),
		.OUTPUT_PRECISION(OUTPUT_PRECISION),
		.enable_bias_32bits(enable_bias_32bits),
		.addr_bias_32bits(addr_bias_32bits),
		.clk(clk),
		.reset(reset),
		.shift_input_buffer(shift_input_buffer),
		.enable(enable_pe_array),
		.shift_fixed_point(shift_fixed_point),
		.loading_in_parallel(loading_in_parallel),
		.enable_input_fifo(enable_input_fifo),
		.clear(clear),
		.mode(mode),
		.CR_PE_array(CR_PE_array),
		.cnn_weights_array(cnn_weights_array),
		.fc_weights_array(fc_weights_array),
		.cnn_input(cnn_input),
		.fc_input_array(fc_input_array),
		.output_array(output_array),
		.output_array_vertical(output_array_vertical)
	);
	always @(*) begin
		for (j = 0; j < parameters_N_DIM_ARRAY; j = j + 1)
			for (k = 0; k < parameters_N_DIM_ARRAY; k = k + 1)
				fc_weights_array[((j * parameters_N_DIM_ARRAY) + k) * parameters_WEIGHT_DATA_WIDTH+:parameters_WEIGHT_DATA_WIDTH] = weight_read_word[((j * parameters_N_DIM_ARRAY) + k) * parameters_WEIGHT_DATA_WIDTH+:parameters_WEIGHT_DATA_WIDTH];
		for (j = 0; j < parameters_N_DIM_ARRAY; j = j + 1)
			begin
				fc_input_array[j * parameters_WEIGHT_DATA_WIDTH+:parameters_WEIGHT_DATA_WIDTH] = input_channel_read_word[j * parameters_INPUT_CHANNEL_DATA_WIDTH+:parameters_INPUT_CHANNEL_DATA_WIDTH];
				cnn_weights_array[j * parameters_WEIGHT_DATA_WIDTH+:parameters_WEIGHT_DATA_WIDTH] = weight_read_word[(0 + j) * parameters_WEIGHT_DATA_WIDTH+:parameters_WEIGHT_DATA_WIDTH];
			end
		cnn_input = input_channel_read_word;
	end
	always @(*)
		if (enable_nonlinear_block == 0) begin
			input_channel_rd_addr = input_channel_rd_addr_cu;
			input_channel_rd_en = input_channel_rd_en_cu;
			wr_input_word_activation = output_array;
			wr_addr = wr_addr_cu;
			wr_en_output_buffer = wr_en_output_buffer_cu;
		end
		else begin
			input_channel_rd_addr = input_channel_rd_addr_nl;
			input_channel_rd_en = input_channel_rd_en_nl;
			wr_addr = wr_addr_nl;
			wr_input_word_activation = output_nonlinear_block;
			wr_en_output_buffer = wr_en_output_buffer_nl;
		end
	wire [3:1] sv2v_tmp_11826;
	assign sv2v_tmp_11826 = mode;
	always @(*) MODE = sv2v_tmp_11826;
	assign wr_output_enable = wr_en_output_buffer;
	assign wr_output_data = wr_input_word_activation;
	assign wr_output_addr = {{32 - parameters_INPUT_CHANNEL_ADDR_SIZE {1'b0}}, wr_addr_encoded};
endmodule
