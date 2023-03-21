//`define DESIGN_V2

import parameters::*;

module cpu 
(
  clk,reset,enable,
  // wr ports
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
  
  //read ports
 rd_en_ext_act_mem,
rd_addr_ext_act_mem,
 rd_data_ext_act_mem,
 
   //Tile parameters
  INPUT_TILE_SIZE,
  WEIGHT_TILE_SIZE,
  NB_INPUT_TILE,
  NB_WEIGHT_TILE,

  //output signals
  MODE,
  SPARSITY,
  finished_network,
  wr_output_enable,
  wr_output_addr,
  wr_output_data
);

// CPU.
// Synchronous clock (clk), asynchronous reset (reset) and synchonous enable that starts the execution (enable)
//IO
input clk, reset, enable;
input wr_en_ext_lut;
input [31:0]wr_addr_ext_lut;
input signed [63:0] wr_data_ext_lut;
input wr_en_ext_conf_reg; // Writing of configuration registers
input [31:0] wr_addr_ext_conf_reg;
input [63:0] wr_data_ext_conf_reg;
input wr_en_ext_im; // Writing of instruction memory
input [31:0] wr_addr_ext_im;
input [63:0] wr_data_ext_im;
input rd_en_ext_act_mem;
input [31:0]  rd_addr_ext_act_mem;
output signed [ACT_DATA_WIDTH-1:0]   rd_data_ext_act_mem[N_DIM_ARRAY-1:0]; 
input wr_en_ext_sparsity; // Writing of sparsity memory
input [31:0] wr_addr_ext_sparsity;
input [63:0] wr_data_ext_sparsity;
input wr_en_ext_act_mem; // Writing of activation memory
input [31:0] wr_addr_ext_act_mem;
input signed [(ACT_DATA_WIDTH)-1:0] wr_data_ext_act_mem[N_DIM_ARRAY-1:0]; 
input wr_en_ext_fc_w; // Writing of FC weights
input [31:0] wr_addr_ext_fc_w;
input signed [(WEIGHT_DATA_WIDTH)-1:0] wr_data_ext_fc_w  [N_DIM_ARRAY-1:0];
input wr_en_ext_cnn_w; // Writing of CNN weights
input [31:0] wr_addr_ext_cnn_w;
input signed [(WEIGHT_DATA_WIDTH)-1:0] wr_data_ext_cnn_w [N_DIM_ARRAY-1:0];
output  wr_output_enable; // Output write enable asserted after every outputs has been computed
output  signed [ACT_DATA_WIDTH-1:0] wr_output_data[N_DIM_ARRAY-1:0]; // N Ouput data to be written
output  [31:0] wr_output_addr; // N Write addresses
output finished_network;
output reg [15:0] INPUT_TILE_SIZE;
output reg [15:0] WEIGHT_TILE_SIZE;
output reg [7:0] NB_INPUT_TILE;
output reg [7:0] NB_WEIGHT_TILE;
output reg [2:0] MODE;
output reg SPARSITY;
//signals
`ifdef DESIGN_V2
wire [1:0] cr_fifo;
wire enable_strided_conv;
wire enable_deconv;
wire odd_X_tile;
`endif
wire  signed [ACT_DATA_WIDTH-1:0] output_array[N_DIM_ARRAY-1:0]; // N_DIM_Array outputs from the PE array obtained through horizontal shifting
wire  signed [ACT_DATA_WIDTH-1:0] output_array_vertical[N_DIM_ARRAY-1:0]; // N_DIM_Array outputs from the PE array obtained through vertical shifting
reg signed  [ACT_DATA_WIDTH - 1:0] wr_input_word_activation [N_DIM_ARRAY-1:0]; // N_DIM_Array values to write intoActivation Memory from PE array or Nonlinear Function Generator
wire signed [ACT_DATA_WIDTH - 1:0] output_nonlinear_block[N_DIM_ARRAY-1:0]; // N_DIM_Array output values from Nonlinear Block generator
wire [2:0] mode; // FC (0) or CNN (1) mode
wire clear; // Clear status registers of the PE array 
reg signed [WEIGHT_DATA_WIDTH-1:0] cnn_weights_array[N_DIM_ARRAY-1:0]; // N_DIM_Array weights retrieved for CNN layers
reg signed [WEIGHT_DATA_WIDTH-1:0] cnn_input [N_DIM_ARRAY-1:0];  // New input activation for CNN computation
reg signed [WEIGHT_DATA_WIDTH-1:0] fc_weights_array[N_DIM_ARRAY-1:0][N_DIM_ARRAY-1:0]; // FC Weights for FC layers. NxN values
reg signed [WEIGHT_DATA_WIDTH-1:0] fc_input_array[N_DIM_ARRAY-1:0]; // N_DIM_ARRAY values from activation memory for FC computation
wire [NUMBER_OF_CR_SIGNALS-1:0] CR_PE_array[N_DIM_ARRAY-1:0][N_DIM_ARRAY-1:0]; // Control signals for PE array
reg [INPUT_CHANNEL_ADDR_SIZE-1:0] input_channel_rd_addr; // Read Address for Activation Memory
wire [INPUT_CHANNEL_ADDR_SIZE-1:0] input_channel_rd_addr_nl; // Read Address for Activation Memory
wire [INPUT_CHANNEL_ADDR_SIZE-1:0] input_channel_rd_addr_cu; // Read Address for Activation Memory
wire [INPUT_CHANNEL_ADDR_SIZE-1:0] input_channel_rd_addr_encoded; // Read Address for Activation Memory
wire [WEIGHT_MEMORY_ADDR_SIZE-1:0] weight_rd_addr; // Read Address for Weight Memory
wire signed  [INPUT_CHANNEL_DATA_WIDTH-1:0]  input_channel_read_word[N_DIM_ARRAY-1:0]; // N values retrieved from activation memory
wire signed [WEIGHT_DATA_WIDTH-1:0] weight_read_word[N_DIM_ARRAY-1:0][N_DIM_ARRAY-1:0]; // Matrix of weights (NXN) if it is a CNN only the 1/N of the maximum bandwidith is used
wire [INPUT_CHANNEL_ADDR_SIZE-1:0] output_memory_pointer; // Current memory pointer for saving values to the activation memory
wire [INPUT_CHANNEL_ADDR_SIZE-1:0] input_memory_pointer;  // Current memory pointer for reading values from the activation memory
wire [INPUT_CHANNEL_ADDR_SIZE-1:0] output_channel_size; // Size of the current output channel for CNNs
reg  [INPUT_CHANNEL_ADDR_SIZE-1:0] wr_addr; // N Write addresses for activation memory
wire  [INPUT_CHANNEL_ADDR_SIZE-1:0] wr_addr_nl; // N Write addresses for activation memory
wire  [INPUT_CHANNEL_ADDR_SIZE-1:0] wr_addr_cu; // N Write addresses for activation memory
wire  [INPUT_CHANNEL_ADDR_SIZE-1:0] wr_addr_encoded; // N Write addresses for activation memory
wire [WEIGHT_MEMORY_ADDR_SIZE-1:0] weight_memory_pointer; // Initial Memory pointer of weight memory for retrieving weights
wire wr_clear_index; // Initialize writing counter for activation memory keeping track of the current output pointer
wire [NUMBER_OF_NONLINEAR_FUNCTIONS_BITS-1:0] type_nonlinear_function; // Type of nonlinear function desired
wire [7:0] shift_fixed_point; // Position of the fixed point
wire [31:0] MEMORY_POINTER_FC; // Configurable First address of the FC weights. It divides the activation memory into 2 parts: A CNN memory and a FC memory
wire [31:0] FIRST_INDEX_FC_LOG; // This is Log2(MEMORY_POINTER_FC)
wire [31:0] EXECUTION_FRAME_BY_FRAME; // This is Log2(MEMORY_POINTER_FC)
wire [MAXIMUM_DILATION_BITS-1:0] shift_input_buffer;
wire [INPUT_CHANNEL_ADDR_SIZE-1:0] FIFO_TCN_block_size;
wire [INPUT_CHANNEL_ADDR_SIZE-1:0] FIFO_TCN_total_blocks;
wire [INPUT_CHANNEL_ADDR_SIZE-1:0]  FIFO_TCN_offset;
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
// generation variables
integer j;
integer k;
wire  [INSTRUCTION_MEMORY_WIDTH-1:0] instruction[INSTRUCTION_MEMORY_FIELDS-1:0];

//Configuration registers
configuration_registers CONFIGURATION_REGISTERS(
  .clk(clk), .reset(reset),
   .wr_en_ext(wr_en_ext_conf_reg),
   .wr_addr_ext(wr_addr_ext_conf_reg),
   .wr_data_ext(wr_data_ext_conf_reg),
  .MEMORY_POINTER_FC(MEMORY_POINTER_FC),
  .EXECUTION_FRAME_BY_FRAME(EXECUTION_FRAME_BY_FRAME),
  .FIRST_INDEX_FC_LOG(FIRST_INDEX_FC_LOG)
);
// Instruction Memory
instruction_memory INSTRUCTION_MEMORY(
  .clk(clk), .reset(reset), .PC(PC),
.wr_addr_ext_im(wr_addr_ext_im),
.wr_data_ext_im(wr_data_ext_im),
.wr_en_ext_im(wr_en_ext_im),
.instruction(instruction)
); 

// Control Unit
control_unit CONTROL_UNIT(
`ifdef DESIGN_V2
  .cr_fifo(cr_fifo),
  .enable_strided_conv(enable_strided_conv),
  .enable_deconv(enable_deconv),
  .odd_X_tile(odd_X_tile),
`endif
  .clk(clk), .reset(reset), .enable(enable), 
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
  //.SPARSITY(SPARSITY),
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



// Weight memory
weight_memory WRAPPER_WEIGHT_MEMORY(
  .wr_en_ext_fc_w(wr_en_ext_fc_w),
   .wr_addr_ext_fc_w(wr_addr_ext_fc_w[WEIGHT_MEMORY_ADDR_SIZE-1:0]),
   .wr_data_ext_fc_w(wr_data_ext_fc_w),
   .wr_en_ext_cnn_w(wr_en_ext_cnn_w),
   .wr_addr_ext_cnn_w(wr_addr_ext_cnn_w[WEIGHT_MEMORY_ADDR_SIZE-1:0]),
   .wr_data_ext_cnn_w(wr_data_ext_cnn_w),
  .mode(mode),
  .weight_memory_pointer(weight_memory_pointer),
  .FIRST_INDEX_FC_LOG(FIRST_INDEX_FC_LOG),
  .MEMORY_POINTER_FC(MEMORY_POINTER_FC),
.clk(clk), .reset(reset), .enable(enable), .rd_en(weight_rd_en), .rd_addr(weight_rd_addr), .read_word(weight_read_word)
);

// Encoding the read/write port to the activation memory to simulate a FIFO structure for TCN frame-by-frame execution
encoder_FIFO ENCODER_FIFO_0(
.clk(clk), .reset(reset),
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

// Activation Memory
activation_memory ACTIVATION_MEMORY(
   .wr_en_ext(wr_en_ext_act_mem),
   .wr_addr_ext(wr_addr_ext_act_mem[INPUT_CHANNEL_ADDR_SIZE-1:0]),
   .wr_data_ext(wr_data_ext_act_mem),
     .rd_en_ext(rd_en_ext_act_mem),
  .rd_addr_ext(rd_addr_ext_act_mem[INPUT_CHANNEL_ADDR_SIZE-1:0] ),
  .rd_data_ext(rd_data_ext_act_mem),
  .mode(mode),
  .loading_in_parallel(loading_in_parallel),
  .clk(clk), .reset(reset), 
  .rd_en(input_channel_rd_en), 
  .rd_addr(input_channel_rd_addr_encoded), 
  .read_word(input_channel_read_word),
  .wr_en(wr_en_output_buffer), 
  .wr_addr_input(wr_addr_encoded),
  .wr_input_word(wr_input_word_activation), 
  .input_memory_pointer(input_memory_pointer),
  .output_memory_pointer(output_memory_pointer)
);

// Nonlinear Function Generator
nonlinear_block NONLINEAR_BLOCK(
    .clk(clk), .reset(reset),
    .PRECISION(INPUT_PRECISION),
      .wr_en_ext_lut(wr_en_ext_lut),
   .wr_addr_ext_lut(wr_addr_ext_lut[LUT_ADDR-1:0]),
   .wr_data_ext_lut(wr_data_ext_lut[LUT_DATA_WIDTH-1:0]),
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

// Array of PEs (with input buffer)
array_pes ARRAY_PES(
 `ifdef DESIGN_V2
  .cr_fifo(cr_fifo),
  .enable_strided_conv(enable_strided_conv),
  .enable_deconv(enable_deconv),
  .odd_X_tile(odd_X_tile),
`endif
  .enable_BUFFERED_OUTPUT(enable_BUFFERED_OUTPUT),
  .INPUT_PRECISION(INPUT_PRECISION),
  .OUTPUT_PRECISION(OUTPUT_PRECISION),
  .enable_bias_32bits(enable_bias_32bits),
  .addr_bias_32bits(addr_bias_32bits),
  .clk(clk), .reset(reset),
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

// Multiplexing activation and weights depending if a CNN or FC is being processed
always @(*)
begin
    for (j=0; j < N_DIM_ARRAY; j =j+1)
              for (k=0; k < N_DIM_ARRAY; k=k+1)
                begin
                  fc_weights_array[j][k] = weight_read_word[j][k];
                end  
    for (j=0; j < N_DIM_ARRAY; j =j+1)
           begin
               fc_input_array[j] = input_channel_read_word[j];
               cnn_weights_array[j]=weight_read_word[0][j];
            end
       cnn_input = input_channel_read_word;
 end
 
//Multiplexing writing to Activation Memory from NONLINEAR BLOCK or ARRAY_PES
always @(*)
begin   
  if (enable_nonlinear_block==0) // if enable nonlinear block is not activated
    begin
    input_channel_rd_addr=input_channel_rd_addr_cu;
    input_channel_rd_en = input_channel_rd_en_cu;
    wr_input_word_activation = output_array;
    wr_addr = wr_addr_cu;
    wr_en_output_buffer = wr_en_output_buffer_cu;
    end
  else
    begin
    input_channel_rd_addr=input_channel_rd_addr_nl;
    input_channel_rd_en = input_channel_rd_en_nl;
    wr_addr= wr_addr_nl;
    wr_input_word_activation = output_nonlinear_block;
    wr_en_output_buffer = wr_en_output_buffer_nl;
    end
end


//Outputs
assign MODE = mode;
assign wr_output_enable = wr_en_output_buffer;
assign wr_output_data = wr_input_word_activation;
assign wr_output_addr = {{(32-INPUT_CHANNEL_ADDR_SIZE){1'b0}},{wr_addr_encoded}};
endmodule
