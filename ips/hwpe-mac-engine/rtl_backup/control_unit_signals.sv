

module control_unit 
(
`ifdef DESIGN_V2
  cr_fifo,
  odd_X_tile,
  enable_strided_conv,
  enable_deconv,
`endif
  finished_activation,
  PC,
   EXECUTION_FRAME_BY_FRAME,
  causal_convolution,
  clk, reset, enable,
  wr_en_ext_sparsity,
  wr_addr_ext_sparsity,
  wr_data_ext_sparsity,
  enable_pe_array,
  CR_PE_array,
  input_channel_rd_en,
  input_channel_rd_addr,
  wr_en_output_buffer,
  input_memory_pointer,
  output_memory_pointer,
  weight_memory_pointer,
  output_channel_size,
  wr_addr,
  weight_rd_en,
  weight_rd_addr,
    INPUT_TILE_SIZE,
  WEIGHT_TILE_SIZE,
  NB_INPUT_TILE,
  NB_WEIGHT_TILE,
  type_nonlinear_function,
  enable_nonlinear_block,
  enable_input_fifo,
  finished_network,
  shift_input_buffer,
  loading_in_parallel,
  instruction,
  enable_pooling,
  enable_sig_tanh,
  clear,
  enable_BUFFERED_OUTPUT,
  NUMBER_OF_ACTIVATION_CYCLES,
  INPUT_PRECISION,
  OUTPUT_PRECISION,
  SHIFT_FIXED_POINT,
  FIFO_TCN_offset,
  FIFO_TCN_update_pointer,
  FIFO_TCN_total_blocks,
  FIFO_TCN_block_size,
  enable_bias_32bits,
  addr_bias_32bits,
  PADDED_C_X,
  PADDED_O_X,
  mode
);

reg [STR_SP_MEMORY_WORD-1:0] next_sparse_val;
reg [STR_SP_MEMORY_WORD-1:0] sparse_val_sram;


`ifdef DESIGN_V2
output reg [1:0] cr_fifo;
output reg odd_X_tile;
output reg enable_strided_conv;
output reg enable_deconv;
`endif 
`ifdef DESIGN_V2
reg next_odd_X_tile;
`endif

//IO
input clk, reset, enable;
input EXECUTION_FRAME_BY_FRAME;
input finished_activation;
input  [INSTRUCTION_MEMORY_WIDTH-1:0] instruction[INSTRUCTION_MEMORY_FIELDS-1:0];
input wr_en_ext_sparsity; // Writing to sparsity memory
input [BIT_WIDTH_EXTERNAL_PORT-1:0] wr_addr_ext_sparsity;
input [BIT_WIDTH_EXTERNAL_PORT-1:0] wr_data_ext_sparsity;
output reg enable_bias_32bits;
output reg [1:0] addr_bias_32bits;
output reg [31:0] PC;
output reg causal_convolution;
output reg enable_nonlinear_block; //Enable the calculation of the nonlinear function
output reg [NUMBER_OF_NONLINEAR_FUNCTIONS_BITS-1:0] type_nonlinear_function; // Type of nonlinear function intended to execute
output reg wr_en_output_buffer; // Enable of the writing to the activation memory
output reg clear; // Clear the content of the input buffer and the registers in the PE array
output reg [INPUT_CHANNEL_ADDR_SIZE-1:0] input_channel_rd_addr; // Address to be read from the activation memory
output reg input_channel_rd_en; // Enable to read from the activation memory
output reg [WEIGHT_MEMORY_ADDR_SIZE-1:0] weight_rd_addr; // Address to be read from the weight memory
output reg weight_rd_en; // Read enable from the weight memory
output reg [2:0] mode; // Mode 1 for CNNs, otherwise 0
output reg [NUMBER_OF_CR_SIGNALS-1:0] CR_PE_array[N_DIM_ARRAY-1:0][N_DIM_ARRAY-1:0]; // Control signals sent to each PE
output reg enable_pe_array; // Enable the clock for the PEs
output reg enable_input_fifo; // Enable the clock for the FIFO of the input buffer
output reg loading_in_parallel; // Loads an input in paralle from the activation memory
output wire [WEIGHT_MEMORY_ADDR_SIZE-1:0] weight_memory_pointer; // Configurable weight memory offset to retrieve values from the weight memory
output reg [INPUT_CHANNEL_ADDR_SIZE-1:0] output_memory_pointer;// Configurable output memory offset to retrieve values from the weight memory
output reg [INPUT_CHANNEL_ADDR_SIZE-1:0] input_memory_pointer;// Configurable input memory offset to retrieve values from the weight memory
output wire [INPUT_CHANNEL_ADDR_SIZE-1:0] output_channel_size; // Size of the output channel for the current CNN layer
output reg [INPUT_CHANNEL_ADDR_SIZE-1:0] wr_addr; // Address to write each of the N values retrieved from the PE array
output reg [MAXIMUM_DILATION_BITS-1:0] shift_input_buffer;
output reg finished_network;
output reg [7:0] SHIFT_FIXED_POINT;
output reg [1:0] INPUT_PRECISION;
output reg [1:0] OUTPUT_PRECISION;
output reg FIFO_TCN_update_pointer;
output reg [INPUT_CHANNEL_ADDR_SIZE-1:0]  FIFO_TCN_block_size;
output reg [INPUT_CHANNEL_ADDR_SIZE-1:0]  FIFO_TCN_offset;
output reg [INPUT_CHANNEL_ADDR_SIZE-1:0]  FIFO_TCN_total_blocks;
output reg [31:0] NUMBER_OF_ACTIVATION_CYCLES;
output reg [31:0] PADDED_C_X;
output reg [31:0] PADDED_O_X;
output reg enable_pooling;
output reg enable_sig_tanh;
output reg enable_BUFFERED_OUTPUT;
output reg [15:0] INPUT_TILE_SIZE;
output reg [15:0] WEIGHT_TILE_SIZE;
output reg [7:0] NB_INPUT_TILE;
output reg [7:0] NB_WEIGHT_TILE;
///////////////////////Signals/////////////////////////////////////////////////////////////////////
reg [INPUT_CHANNEL_ADDR_SIZE-1:0] wr_addr_vertical [N_DIM_ARRAY-1:0]; // write addresses for data shifted vertically
reg finished_layer;
//reg [INSTRUCTION_MEMORY_WIDTH-1:0] instruction_memory[INSTRUCTION_MEMORY_SIZE-1:0][INSTRUCTION_MEMORY_FIELDS-1:0]; // 32 possible layers with 24 options of 16 bits


reg  [INPUT_CHANNEL_ADDR_SIZE-1:0] output_channel_size_shifted; 
wire [INPUT_CHANNEL_ADDR_SIZE-1:0] wr_addr_plus_offset;
reg CNN_FINISHED_FX_LOOP;
reg CNN_FINISHED_FY_LOOP;    
reg CNN_FINISHED_C_LOOP;
reg CNN_FINISHED_K_LOOP;
reg CNN_FINISHED_X_LOOP;
reg CNN_FINISHED_Y_LOOP;
reg FC_FINISHED_K_LOOP;
reg FC_FINISHED_C_LOOP;
reg BIAS_ACC_FINISHED;
reg EWS_FINISHED;
reg ACT_FINISHED;
reg ACCUMULATION_PES_FINISHED;
//counters
reg [INPUT_CHANNEL_ADDR_SIZE-1:0] counter_activation_read_address, next_counter_activation_read_address;
reg [INPUT_CHANNEL_ADDR_SIZE-1:0] counter_current_channel_address, next_counter_current_channel_address;
reg [WEIGHT_MEMORY_ADDR_SIZE-1:0] counter_weight_address, next_counter_weight_address;
reg [INPUT_CHANNEL_ADDR_SIZE-1:0] counter_offset_input_channel, next_counter_offset_input_channel;
reg [INPUT_CHANNEL_ADDR_SIZE-1:0] counter_input_channel_address, next_counter_input_channel_address;
reg [INPUT_CHANNEL_ADDR_SIZE-1:0] counter_output_channel_address, next_counter_output_channel_address;

reg  [INPUT_CHANNEL_ADDR_SIZE-1:0] counter_weight_address_after_bias, next_counter_weight_address_after_bias;

reg [1:0] counter_acc_cnn_bias, next_counter_acc_cnn_bias; 
reg [15:0] counter_C, next_counter_C;
reg [15:0] counter_Y, next_counter_Y;
reg [15:0] counter_X, next_counter_X;
reg [15:0] counter_K, next_counter_K;
reg [15:0] counter_input_buffer_loading, next_counter_input_buffer_loading;
reg [15:0] counter_sparsity, next_counter_sparsity;
reg [7:0] counter_FY, next_counter_FY;
reg [7:0] counter_FX, next_counter_FX;
reg [7:0] counter_accumulation_pes, next_counter_accumulation_pes;
reg SPARSITY_SET;
reg [9:0] sparse_val;
reg [7:0] number_ones;

reg [10:0] A;
reg [10:0] sparse_addr;
reg [10:0] next_sparse_addr; 

// FSM states.
reg [HL_FSM_bits-1:0] HL_state; // High Level state
reg [HL_FSM_bits-1:0] HL_next_state;
reg HL_enable; // High Level state signal that enables the execution of the Low Level State machine
localparam      HL_IDLE=0,
                        HL_RUN=1,
                        HL_RUNNING=2,
                        HL_FINISHED_LAYER=3,
                        HL_END=4;
reg [LL_FSM_bits-1:0] state;
reg [LL_FSM_bits-1:0] next_state;
localparam      INITIAL=0,
                        CONV_FILLING_INPUT_FIFO=1,
                        CONV_PADDING_FILLING_INPUT_FIFO=2,
                        CONV_PRE_MAC=3,
                        CONV_MAC=4,
                        CONV_ADD_BIAS=5,
                        CONV_PRE_PASSING_OUTPUTS_VERTICAL= 6,
                        CONV_PASSING_OUTPUTS_VERTICAL= 7,
                        CONV_CLEAR_MAC=8,
                        CONV_PRE_MAC_2=9,
                        FC_PRE_MAC=10,
                        FC_MAC=11,
                        FC_PRE_BIAS=12,
                        FC_BIAS=13,
                        FC_PRE_ACCUMULATE_MACS=14,
                        FC_ACCUMULATE_MACS=15,
                        FC_SAVE_OUTPUTS_MACS=16,
                        EWS_PRE_MAC=17,
                        EWS_MAC_0=18,
                        EWS_MAC_1=19,
                        EWS_SAVE_MAC=20,
                        ACTIVATION=21,
                        FINISHED_LAYER=22,
                        FC_BIAS_32b_0= 23,
                        CONV_ADD_BIAS_ACC=24,
                        CONV_ADD_BIAS_OPERATION=25,
                        CONV_ADD_BIAS_SHIFTING=26,
                        
                        `ifdef DESIGN_V2
                        STR_SPARSITY=27,
                        CONV_FILLING_INPUT_FIFO_2=28;
`                       else
                        STR_SPARSITY=27;
`    endif
                        
// Low Level Configuration Registers
// counters
  // Higher than 16 bits
  wire [INPUT_CHANNEL_ADDR_SIZE-1:0] CONF_INPUT_MEMORY_POINTER;
  wire [INPUT_CHANNEL_ADDR_SIZE-1:0] CONF_OUTPUT_MEMORY_POINTER;
  
  // 16 bits
  wire  [31:0] CONF_C;    // Structural Sparsity FC      It is used as a 32 bits since it is also used for calculating the number of cycles for activation
  wire [15:0] CONF_K ;
  wire [15:0] CONF_C_X;
  wire [15:0] CONF_C_Y;
  wire [15:0] CONF_PADDED_C_X;
  wire [15:0] CONF_PADDED_C_Y;
  wire [15:0] CONF_O_X;
  wire [15:0] CONF_O_Y;
  wire [15:0] CONF_SIZE_CHANNEL;
  wire [15:0] CONF_WYdivN;
  wire [15:0] CONF_WXdivN;
  wire [15:0] CONF_STR_SPARSITY;
  wire [15:0] CONF_TCN_TOTAL_BLOCKS;
  wire [15:0] CONF_TCN_BLOCK_SIZE;
  wire [15:0] CONF_FIFO_TCN_offset;
  wire [15:0] CONF_OUTPUT_CHANNEL_SIZE;
  // 8 bits
  wire [7:0] CONF_DILATION;
  wire [7:0] CONF_FX;
  wire [7:0] CONF_FY;
  wire [7:0] CONF_SHIFT_FIXED_POINT;
  //4 bits
  wire [3:0] CONF_TYPE_NONLINEAR_FUNCTION;
  wire [3:0] CONF_MODE;
  wire [3:0] CONF_ACTIVATION_FUNCTION;
  // 1 bit
  wire [0:0]  CONF_STOP;
  wire [0:0] CONF_CAUSAL_CONVOLUTION;
  wire [1:0] CONF_INPUT_PRECISION;
  wire [1:0] CONF_OUTPUT_PRECISION;
  
  
  // CONF extra
  wire [7:0] CONF_NB_INPUT_TILE;
  wire [7:0] CONF_NB_WEIGHT_TILE;
  wire [0:0] CONF_CONV_STRIDED;
  wire [0:0] CONF_CONV_DECONV;
  wire [1:0] CONF_NORM; 
  
  
  
  
  
//gen vars
//reg  signed [INSTRUCTION_MEMORY_WIDTH-1:0] im_file  [0:INSTRUCTION_MEMORY_SIZE*INSTRUCTION_MEMORY_FIELDS-1];


integer i;
integer j;
integer k;
integer l;
integer sp;


// structural sparsity
reg [9:0] sparsity[0: STR_SP_MEMORY_SIZE-1];
