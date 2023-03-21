

import parameters::*;

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
  OUTPUT_TILE_SIZE,
  WEIGHT_TILE_SIZE,
  NB_INPUT_TILE,
  NB_WEIGHT_TILE,
  SPARSITY,
  done_layer,
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
output reg SPARSITY;
output reg enable_pooling;
output reg enable_sig_tanh;
output reg enable_BUFFERED_OUTPUT;
output reg [15:0] OUTPUT_TILE_SIZE;
output reg [15:0] WEIGHT_TILE_SIZE;
output reg [7:0] NB_INPUT_TILE;
output reg [7:0] NB_WEIGHT_TILE;
output reg done_layer;
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
reg [STR_SP_MEMORY_WORD-1:0] sparse_val;
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
  wire [31:0] CONF_WEIGHT_TILE_SIZE;
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


//SRAM sparsity
SRAM_2048x32_equivalent sparsity_mem(
                       .CLK(clk), .CEB('0), .WEB(~wr_en_ext_sparsity),
                       .A(A), .D(wr_data_ext_sparsity), 
                       .Q(sparse_val_sram)
);

//assign sparse_val_sram=0;

// Configuration Register for current layer
assign   CONF_MODE= instruction[0];
assign   weight_memory_pointer = instruction[1];
assign   CONF_INPUT_MEMORY_POINTER =instruction[2]; 
assign   CONF_OUTPUT_MEMORY_POINTER =instruction[3];
assign   CONF_C = instruction[4];
assign   CONF_K= instruction[5];
assign   CONF_C_X= instruction[6];
assign   CONF_C_Y= instruction[7];
assign   CONF_PADDED_C_X =  instruction[8];
assign   CONF_PADDED_C_Y =  instruction[9];
assign   CONF_SIZE_CHANNEL= instruction[10];
assign   CONF_FX= instruction[11];
assign   CONF_FY= instruction[12];
assign   CONF_O_X= instruction[13];
assign   CONF_O_Y= instruction[14];
assign   CONF_TCN_TOTAL_BLOCKS=instruction[15];
assign   CONF_TCN_BLOCK_SIZE=instruction[16];
assign   CONF_ACTIVATION_FUNCTION=instruction[17];
assign   CONF_FIFO_TCN_offset = instruction[18];
assign   CONF_OUTPUT_CHANNEL_SIZE = instruction[19];
assign   CONF_STR_SPARSITY=instruction[20];
assign   CONF_DILATION= instruction[21];

assign   CONF_STOP = instruction[22];
assign   CONF_SHIFT_FIXED_POINT = instruction[23];
assign   CONF_CAUSAL_CONVOLUTION= instruction[24];
assign   CONF_TYPE_NONLINEAR_FUNCTION=instruction[25];
///assign   CONF_NB_INPUT_TILE=instruction[26];
//// ADDED BY SEBASTIAN april 24 ///////////////////////////77
assign   CONF_WEIGHT_TILE_SIZE=instruction[26];
assign   CONF_NB_WEIGHT_TILE=instruction[27];

 /// FOR VIKRAM: CHECK THE CORRECTNESS OF THE FOLLOWING STATENMENTS TAKING INTO CONSIDERATION THE NEW INSTRUCTION FIELDS
`ifdef DESIGN_V2
assign   CONF_CONV_STRIDED = instruction[28];
assign   CONF_CONV_DECONV = instruction[29];
assign   CONF_NORM = instruction[30];
`endif
assign   CONF_OUTPUT_PRECISION=instruction[31];
assign   CONF_INPUT_PRECISION=instruction[31];
assign   done_layer=finished_layer;





////////////////////////////// HIGH LEVEL FSM ///////////////////////////////////////////////////////////////////////////////////

//Program Counter Update
always @(posedge clk or negedge reset)
begin
  if (!reset)
    PC <= 0;
    else
      // If the network has finished go to PC=0
      if (finished_network)
      PC <= 0;
      else
        // If one layer has finished go to the next instruction
        if (finished_layer)
          PC <= PC+1;
end

always @(posedge clk or negedge reset)
begin
  if (!reset)
    HL_state <= HL_IDLE;
  else
    HL_state <= HL_next_state;
end

always @(*)
begin
  HL_next_state =HL_state;
  case(HL_state)
    HL_IDLE:
      if (enable)
        HL_next_state = HL_RUN;
     HL_RUN:
      HL_next_state =HL_RUNNING;
    HL_RUNNING:
      if (finished_layer)
        HL_next_state = HL_FINISHED_LAYER;
    HL_FINISHED_LAYER:  
      if (CONF_STOP==1)
        HL_next_state = HL_END;
      else
        HL_next_state = HL_RUN;  
    HL_END:
        HL_next_state = HL_IDLE;
  endcase
end

always @(*)
begin
  finished_network=0;
  case(HL_state)
    HL_IDLE:
    begin
    HL_enable =0;
    end
    HL_RUN:
      begin
      HL_enable =1;
      end
    HL_RUNNING:
      begin
      HL_enable =0;
      end
    HL_FINISHED_LAYER:
      begin
      HL_enable =0;
      end
    HL_END:
    begin
    finished_network=1;
    HL_enable =0;
    end
    default:
     begin
      HL_enable=0;
     end
  endcase
end

always @(*)
begin
  if (HL_state != 0)
    A = sparse_addr;
  else
    A = wr_addr_ext_sparsity;
end

///////////////////////////// LOW LEVEL FSM /////////////////////////////////////////////////////////////////////////////////////////////////////

// Signals to acknowledge the end of a loop
always @(*)
begin
BIAS_ACC_FINISHED = (counter_acc_cnn_bias== 3); // 4 sub-parts of the bias accumulated
CNN_FINISHED_FX_LOOP =  (counter_FX == (CONF_FX-1));
CNN_FINISHED_FY_LOOP=(counter_FY == (CONF_FY-1));    
CNN_FINISHED_C_LOOP=(counter_C == (CONF_C-1));
CNN_FINISHED_K_LOOP=(counter_K == (CONF_K-1));
`ifdef DESIGN_V2
//Update the CNN_FINISHED_X AND Y based on striding (divide by two) or deconv
//(multiply by two)
if (CONF_CONV_STRIDED) begin
  CNN_FINISHED_X_LOOP=(counter_X == ((CONF_O_X-1)>>CONF_CONV_STRIDED));
  CNN_FINISHED_Y_LOOP=(counter_Y == ((CONF_O_Y-1)>>CONF_CONV_STRIDED));
end else if (CONF_CONV_DECONV) begin
  CNN_FINISHED_X_LOOP=(counter_X == ((CONF_O_X-1)<<CONF_CONV_DECONV));
  CNN_FINISHED_Y_LOOP=(counter_Y == ((CONF_O_Y-1)<<CONF_CONV_DECONV));
end else begin
  CNN_FINISHED_X_LOOP=(counter_X == (CONF_O_X-1));
  CNN_FINISHED_Y_LOOP=(counter_Y == (CONF_O_Y-1));
end
`else
CNN_FINISHED_X_LOOP=(counter_X == (CONF_O_X-1));
 CNN_FINISHED_Y_LOOP=(counter_Y == (CONF_O_Y-1));
`endif 

FC_FINISHED_K_LOOP=(counter_K == (CONF_K-1));
EWS_FINISHED = (counter_C == ((CONF_C)));

ACCUMULATION_PES_FINISHED = (counter_accumulation_pes == (N_DIM_ARRAY-1));

// Execution frame by frame
if ((CONF_TCN_BLOCK_SIZE!=0) && (EXECUTION_FRAME_BY_FRAME==1)) //if execution frame by frame is activated and tcn block size is different to 1
  FC_FINISHED_C_LOOP=(counter_C == ((CONF_C)-(((CONF_TCN_BLOCK_SIZE)*CONF_DILATION)-1)));
else

//BUG FIXING JUNE 12, 2020. AD HOC FIXING BUG FOR WORKING WITH C=1. Otherwise the execution is stalled.
//  FC_FINISHED_C_LOOP = (counter_C == ((CONF_C)-CONF_DILATION));

  if (CONF_C>1)
   FC_FINISHED_C_LOOP = (counter_C == ((CONF_C)-CONF_DILATION));
  else //If the input vector fits completely on the array
   FC_FINISHED_C_LOOP = (counter_C==1);

  
end

 //Initialization Counters
always @(posedge clk or negedge reset)
begin
  if (!reset)
    begin
    counter_FX <= 0;
    counter_FY <= 0;
    counter_X <= 0;
    counter_Y <= 0;
    counter_C <= 0;
    counter_K <= 0;
    
    counter_input_channel_address <= 0;
    counter_weight_address <= 0;
    counter_accumulation_pes <= 0;
    counter_offset_input_channel <= 0;
    counter_activation_read_address <= 0;
    counter_output_channel_address <= 0;
    counter_sparsity <= 0;
    counter_current_channel_address <= 0;
    counter_input_buffer_loading <= 0;
    counter_acc_cnn_bias <= 0;
    counter_weight_address_after_bias <= 0;
    sparse_val <= 0;
    sparse_addr <= 0;
`ifdef DESIGN_V2
    odd_X_tile <= 0;
`endif
    end
   else
   begin
    counter_weight_address_after_bias <= next_counter_weight_address_after_bias;
    counter_X <= next_counter_X;
    counter_Y <= next_counter_Y;
    counter_FX <= next_counter_FX;
    counter_FY <= next_counter_FY;
    counter_input_channel_address <= next_counter_input_channel_address;
    counter_weight_address <= next_counter_weight_address;
    counter_accumulation_pes <= next_counter_accumulation_pes;
    counter_C <=  next_counter_C;
    counter_offset_input_channel <= next_counter_offset_input_channel;
    counter_K <= next_counter_K;
    counter_activation_read_address <=  next_counter_activation_read_address;
    counter_output_channel_address <= next_counter_output_channel_address;
    counter_sparsity <= next_counter_sparsity;
    counter_current_channel_address <= next_counter_current_channel_address;
    counter_input_buffer_loading <= next_counter_input_buffer_loading;
    counter_acc_cnn_bias <= next_counter_acc_cnn_bias;
    
    sparse_val <= next_sparse_val;
    sparse_addr <= next_sparse_addr;
`ifdef DESIGN_V2
    odd_X_tile <= next_odd_X_tile;
`endif
   end 
end




 //update counters
 always @(*)
 begin
  //default
      next_counter_acc_cnn_bias = counter_acc_cnn_bias;
      next_counter_X = counter_X;
      next_counter_Y = counter_Y;
      next_counter_offset_input_channel=counter_offset_input_channel;
      next_counter_FX = counter_FX;
      next_counter_C=counter_C;
      next_counter_input_channel_address = counter_input_channel_address;
      next_counter_weight_address = counter_weight_address;
      next_counter_accumulation_pes=counter_accumulation_pes;
      next_counter_FY = counter_FY;
      next_counter_K = counter_K;
      next_counter_activation_read_address = counter_activation_read_address;
      next_counter_output_channel_address= counter_output_channel_address;
      next_counter_sparsity = counter_sparsity;
      next_counter_current_channel_address = counter_current_channel_address;
      next_counter_input_buffer_loading = counter_input_buffer_loading;
      next_counter_weight_address_after_bias = counter_weight_address_after_bias;
      number_ones=0;
      next_sparse_val = sparse_val;
      next_sparse_addr = sparse_addr;
`ifdef DESIGN_V2
      next_odd_X_tile = 0;
`endif

  case(state)
    INITIAL:    // Initial state for the system
      begin
      next_counter_X = 0;
      next_counter_Y = 0;
      next_counter_offset_input_channel=0;
      next_counter_FX = 0;
      next_counter_C=0;
      next_counter_input_channel_address = 0;
      next_counter_weight_address = 0;
      next_counter_accumulation_pes=0;
      next_counter_FY = 0;
      next_counter_K = 0;
      next_counter_activation_read_address = 0;
      next_counter_output_channel_address = 0;
      next_counter_sparsity = 0;
      SPARSITY_SET = 0;
      next_sparse_val = sparse_val_sram;
      next_sparse_addr = (counter_K>>BLOCK_SPARSE)+(counter_C>>STR_SP_MEMORY_WORD_LOG);
      ///////////////////////////////////////////////////////
      number_ones = 0;
`ifdef DESIGN_V2
      next_odd_X_tile = 0;
`endif
      end

     STR_SPARSITY:
      begin
      next_counter_X = counter_X;
      next_counter_Y = counter_Y;
      next_counter_offset_input_channel=counter_offset_input_channel;
      next_counter_C = counter_C;
      next_counter_accumulation_pes=0;
      next_counter_weight_address =counter_weight_address;
      next_counter_input_channel_address = counter_input_channel_address;
      next_counter_K = counter_K;
      if (next_sparse_val[0] == 1)
       begin
        if (next_sparse_val[1] == 1) 
        begin
         for (sp=0; sp<4; sp=sp+1)
          begin
            if (next_sparse_val[sp] == 1  && next_sparse_val[sp+1] == 1) 
              begin
                number_ones = number_ones + 1;
                  if (number_ones > next_counter_sparsity)
                    next_counter_sparsity = number_ones;
              end
          end
        end
        else
          begin
           next_counter_sparsity = 0;
          end
        SPARSITY_SET = 1;


	if (CNN_FINISHED_C_LOOP & CNN_FINISHED_K_LOOP & CNN_FINISHED_X_LOOP & CNN_FINISHED_Y_LOOP)
          begin
            next_counter_X = counter_X;
            next_counter_Y = counter_Y+1;
            next_counter_FX = 0;
            next_counter_offset_input_channel=0;
            next_counter_C = 0;
            next_counter_accumulation_pes=counter_accumulation_pes;
            next_counter_weight_address =counter_weight_address+1;
            next_counter_weight_address_after_bias= 0;
            next_counter_input_channel_address =0 ;
            next_counter_FY = 0;
            next_counter_K =0 ;
        end else if (CNN_FINISHED_C_LOOP & CNN_FINISHED_K_LOOP & CNN_FINISHED_X_LOOP)
          begin
            next_counter_X = 0;
            next_counter_Y = counter_Y+1;
            next_counter_FX = 0;

            `ifdef DESIGN_V2
            if (CONF_CONV_STRIDED) begin
              next_counter_offset_input_channel =counter_offset_input_channel + 2*8; // It adds 8 for getting the next row
              next_counter_input_channel_address =counter_offset_input_channel + 2*8;  // It adds 8 for getting the next row
            end
            else if (CONF_CONV_DECONV) begin
              next_counter_offset_input_channel =counter_offset_input_channel + 8; // It adds 8 for getting the next row
              next_counter_input_channel_address =counter_offset_input_channel + 8;  // It adds 8 for getting the next row
            end
            else begin
              next_counter_offset_input_channel =counter_offset_input_channel + 8; // It adds 8 for getting the next row
              next_counter_input_channel_address =counter_offset_input_channel + 8;  // It adds 8 for getting the next row
            end
`else
            next_counter_offset_input_channel =counter_offset_input_channel + 8; // It adds 8 for getting the next row
            next_counter_input_channel_address =counter_offset_input_channel + 8;  // It adds 8 for getting the next row
`endif

            next_counter_C = 0 ;
            next_counter_accumulation_pes=counter_accumulation_pes;
            next_counter_weight_address =counter_weight_address+1;
            next_counter_weight_address_after_bias=0;
`ifdef DESIGN_V2
            if (CONF_CONV_DECONV == 1) begin
              if ((counter_Y+1)%2 == 0)
                next_counter_FY = 0;
              else
                next_counter_FY = 2;
            end else begin
              next_counter_FY = 0;
            end
`else
            next_counter_FY = 0;
`endif
            next_counter_K =0 ;

        end else if (CNN_FINISHED_C_LOOP & CNN_FINISHED_K_LOOP) begin
            next_counter_X =counter_X+1 ;
            next_counter_Y =counter_Y ;
            next_counter_FX = 0;
            next_counter_C = 0;
            next_counter_accumulation_pes=counter_accumulation_pes;
            next_counter_weight_address =counter_weight_address+1;
            next_counter_weight_address_after_bias=0;
            next_counter_FY = 0;
            next_counter_K = 0;
            next_sparse_val = sparse_val_sram;
            //next_sparse_addr = (next_counter_K>>BLOCK_SPARSE)+(next_counter_C>>STR_SP_MEMORY_WORD_LOG)+4;

           `ifdef DESIGN_V2
            if (CONF_CONV_STRIDED) begin
                next_counter_offset_input_channel=counter_offset_input_channel + (2*N_DIM_ARRAY);
                next_counter_input_channel_address =counter_offset_input_channel + (2*N_DIM_ARRAY) ;
            end
            else if (CONF_CONV_DECONV) begin
                if ((counter_X+1)%2 == 0) begin
                    next_counter_offset_input_channel=counter_offset_input_channel+N_DIM_ARRAY;
                    next_counter_input_channel_address =counter_offset_input_channel+N_DIM_ARRAY;
                end
                else begin
                    next_counter_offset_input_channel=counter_offset_input_channel;
                    next_counter_input_channel_address =counter_offset_input_channel;
                end
            end
            else begin
                next_counter_offset_input_channel=counter_offset_input_channel + (N_DIM_ARRAY);
                next_counter_input_channel_address =counter_offset_input_channel + (N_DIM_ARRAY) ;
            end
`else
                next_counter_offset_input_channel=counter_offset_input_channel + (N_DIM_ARRAY);
                next_counter_input_channel_address =counter_offset_input_channel + (N_DIM_ARRAY) ;
`endif 

        end else if (CNN_FINISHED_C_LOOP || FC_FINISHED_C_LOOP)
          begin
           next_counter_X = counter_X;
           next_counter_Y = counter_Y;
           next_counter_FX =  0;
           next_counter_offset_input_channel=counter_offset_input_channel;
           next_counter_C = 0;
           next_counter_sparsity = 0;
           next_counter_accumulation_pes= counter_accumulation_pes;
           next_counter_weight_address =counter_weight_address;
	   next_counter_weight_address_after_bias= counter_weight_address +4;
           next_counter_input_channel_address = counter_offset_input_channel;
           next_counter_FY = 0;
           if (CONF_MODE == 1)
             next_counter_K = counter_K +1;
           else
             next_counter_K = counter_K;
           //next_sparse_val = sparse_val_sram;
	   next_sparse_val = sparse_val >> (next_counter_sparsity + 1);
           next_sparse_addr = (next_counter_K>>BLOCK_SPARSE)+(next_counter_C>>STR_SP_MEMORY_WORD_LOG);

          end
        else //if (CNN_FINISHED_FX_LOOP & CNN_FINISHED_FY_LOOP)
         begin
           next_counter_X = counter_X;
           next_counter_Y = counter_Y;
           next_counter_FX = 0 ;
           next_counter_offset_input_channel=counter_offset_input_channel;
           next_counter_C = counter_C+next_counter_sparsity+1;
           next_counter_accumulation_pes= counter_accumulation_pes;
           next_counter_weight_address = counter_weight_address;
           //next_counter_input_channel_address =(CONF_SIZE_CHANNEL)*(next_counter_C);
           next_counter_FY =0 ;
           next_counter_K = counter_K;
	   next_sparse_val = sparse_val >> (next_counter_sparsity + 1);
           next_counter_input_channel_address =counter_offset_input_channel + counter_current_channel_address + ((CONF_SIZE_CHANNEL)*(next_counter_sparsity+1));
           next_counter_current_channel_address =counter_current_channel_address + ((CONF_SIZE_CHANNEL)*(next_counter_sparsity+1));
         end
       end
      else
       begin
       
        next_counter_sparsity = 0;
        next_counter_C = counter_C;
        next_counter_FX = 0;
        next_counter_FY = counter_FY;
        SPARSITY_SET = 0;
       end
      end
      

     CONV_PADDING_FILLING_INPUT_FIFO: // Padding with zeros equal to N_DIM_ARRAY
      begin
      
      next_counter_X = counter_X;
      next_counter_Y = counter_Y;
      next_counter_FX = 0;
      next_counter_offset_input_channel=counter_offset_input_channel;
      next_counter_C = counter_C;
      next_counter_accumulation_pes=0;
      next_counter_weight_address =counter_weight_address;
      next_counter_input_channel_address = counter_input_channel_address;
      next_counter_FY = counter_FY;
      next_counter_K = counter_K;
      SPARSITY_SET = 0;
      //next_sparse_val = sparse_val >> (next_counter_sparsity + 1);      
      number_ones = 0;
`ifdef DESIGN_V2
      //Deconvolution
      if (CONF_CONV_DECONV) begin
        if ((counter_X)%2 == 0)
          next_odd_X_tile = 0;
        else
          next_odd_X_tile = 1;
      end
`endif
      end  
      
    CONV_FILLING_INPUT_FIFO: // Retrieve a N_DIM_ARRAY vector from the activation memory and save it to the FIFO. Update counter input channel address
      begin
      
      next_counter_X = counter_X;
      next_counter_Y = counter_Y;
      next_counter_FX = 0;
      next_counter_offset_input_channel=counter_offset_input_channel;
      next_counter_C = counter_C;
      next_counter_accumulation_pes=0;
      next_counter_weight_address =counter_weight_address;
      next_counter_input_channel_address = counter_input_channel_address+ N_DIM_ARRAY;
      next_counter_FY = counter_FY;
      next_counter_K = counter_K;
      SPARSITY_SET = 0;
      //next_sparse_val = sparse_val >> (next_counter_sparsity + 1);
      number_ones = 0;
`ifdef DESIGN_V2
      //Deconvolution
      if (CONF_CONV_DECONV) begin
        if ((counter_X)%2 == 0)
          next_odd_X_tile = 0;
        else
          next_odd_X_tile = 1;
      end
`endif
      end 
      
  
`ifdef DESIGN_V2 
    CONV_FILLING_INPUT_FIFO_2: // Retrieve a N_DIM_ARRAY vector from the activation memory and save it to the FIFO. Update counter input channel address
      begin

      next_counter_X = counter_X;
      next_counter_Y = counter_Y;
      next_counter_FX = 0;
      next_counter_offset_input_channel=counter_offset_input_channel;
      next_counter_C = counter_C;
      next_counter_accumulation_pes=0;
      
      
      if (CONF_CONV_DECONV) begin
        if (counter_Y%2 == 0)
          next_counter_weight_address =counter_weight_address;
        else
          next_counter_weight_address =counter_weight_address+(CONF_FX);
      end else begin
        next_counter_weight_address =counter_weight_address;
      end
      //Deconvolution
      if (CONF_CONV_DECONV) begin
        next_counter_input_channel_address = counter_input_channel_address-(N_DIM_ARRAY>>1);
        if ((counter_X)%2 == 0)
          next_odd_X_tile = 0;
        else
          next_odd_X_tile = 1;
      end else begin
        next_counter_input_channel_address = counter_input_channel_address+N_DIM_ARRAY;
      end
      next_counter_FY = counter_FY;
      next_counter_K = counter_K;
      SPARSITY_SET = 0;
      number_ones = 0;
      end  
`endif 


      
    CONV_PRE_MAC: //Retrieve data from WM and retrieve data from activation memory taking into account dilation
      begin
      next_counter_input_buffer_loading=0;
      next_counter_X = counter_X;
      next_counter_Y = counter_Y;
      next_counter_FX = 0;
      next_counter_offset_input_channel=counter_offset_input_channel;
      next_counter_C = counter_C;
      next_counter_accumulation_pes=0;
      next_counter_weight_address = counter_weight_address+1;
      next_counter_FY = counter_FY;
      next_counter_K = counter_K; 
      
            next_counter_sparsity = 0;
      //next_sparse_val = sparse_val_sram;
`ifdef DESIGN_V2
      //Deconvolution
      if (CONF_CONV_DECONV) begin
        if ((counter_X)%2 == 0)
          next_odd_X_tile = 0;
        else
          next_odd_X_tile = 1;
      end
      //Strided convolution or Deconvolution
      if (CONF_CONV_STRIDED || CONF_CONV_DECONV) begin
        next_counter_input_channel_address = counter_input_channel_address;
      end
      else begin
        next_counter_input_channel_address = counter_input_channel_address+CONF_DILATION;
      end
`else
      next_counter_input_channel_address = counter_input_channel_address+CONF_DILATION;
`endif
      end

      
      CONV_PRE_MAC_2: // State used after initial preloading of data 
      begin
      next_counter_input_buffer_loading=0;
      next_counter_X = counter_X;
      next_counter_Y = counter_Y;
      next_counter_FX = 0;
      next_counter_offset_input_channel=counter_offset_input_channel;
      next_counter_C = counter_C;
      next_counter_accumulation_pes=0;
      next_counter_weight_address = counter_weight_address+1;
      next_counter_FY = counter_FY;
      next_counter_K = counter_K;
      
`ifdef DESIGN_V2
      //Deconvolution
      if (CONF_CONV_DECONV) begin
        if ((counter_X)%2 == 0)
          next_odd_X_tile = 0;
        else
          next_odd_X_tile = 1;
      end
      //Strided convolution or Deconvolution
      if (CONF_CONV_STRIDED || CONF_CONV_DECONV) begin
        next_counter_input_channel_address = counter_input_channel_address;
      end else begin
        next_counter_input_channel_address = counter_input_channel_address+CONF_DILATION+N_DIM_ARRAY;
      end
`else
      next_counter_input_channel_address = counter_input_channel_address+CONF_DILATION+N_DIM_ARRAY;
`endif 

      end 
      CONV_MAC: // MAC operation
      begin
            
`ifdef DESIGN_V2
      //Deconvolution
      if (CONF_CONV_DECONV) begin
        if ((counter_X)%2 == 0)
          next_odd_X_tile = 0;
        else
          next_odd_X_tile = 1;
      end
`endif
      
      // If  the whole input map has been processed
      if (CNN_FINISHED_FX_LOOP & CNN_FINISHED_FY_LOOP & CNN_FINISHED_C_LOOP & CNN_FINISHED_K_LOOP & CNN_FINISHED_X_LOOP & CNN_FINISHED_Y_LOOP)
      begin
                            next_counter_X = counter_X;
                            next_counter_Y = counter_Y+1;
                            next_counter_FX = 0;
                            next_counter_offset_input_channel=0;
                            next_counter_C = 0;
                            next_counter_accumulation_pes=counter_accumulation_pes;
                            next_counter_weight_address =counter_weight_address+1;
                            next_counter_weight_address_after_bias= 0;
                            next_counter_input_channel_address =0 ;
                            next_counter_FY = 0;
                            next_counter_K =0 ;
      end
      // If a whole block row has been processed
      else if (CNN_FINISHED_FX_LOOP & CNN_FINISHED_FY_LOOP & CNN_FINISHED_C_LOOP & CNN_FINISHED_K_LOOP & CNN_FINISHED_X_LOOP)
      begin
                            next_counter_X = 0;
                            next_counter_Y = counter_Y+1;
                            next_counter_FX = 0;
                            
                            `ifdef DESIGN_V2
                            if (CONF_CONV_STRIDED) begin
                              next_counter_offset_input_channel =counter_offset_input_channel + 2*8; // It adds 8 for getting the next row
                              next_counter_input_channel_address =counter_offset_input_channel + 2*8;  // It adds 8 for getting the next row
                            end
                            else if (CONF_CONV_DECONV) begin
                              next_counter_offset_input_channel =counter_offset_input_channel + 8; // It adds 8 for getting the next row
                              next_counter_input_channel_address =counter_offset_input_channel + 8;  // It adds 8 for getting the next row
                            end
                            else begin
                              next_counter_offset_input_channel =counter_offset_input_channel + 8; // It adds 8 for getting the next row
                              next_counter_input_channel_address =counter_offset_input_channel + 8;  // It adds 8 for getting the next row
                            end
`else
                            next_counter_offset_input_channel =counter_offset_input_channel + 8; // It adds 8 for getting the next row
                            next_counter_input_channel_address =counter_offset_input_channel + 8;  // It adds 8 for getting the next row
`endif
   
                            next_counter_C = 0 ;
                            next_counter_accumulation_pes=counter_accumulation_pes;
                            next_counter_weight_address =counter_weight_address+1;
                            next_counter_weight_address_after_bias=0;
`ifdef DESIGN_V2
                            if (CONF_CONV_DECONV == 1) begin
                              if ((counter_Y+1)%2 == 0) 
                                next_counter_FY = 0;
                              else
                                next_counter_FY = 2;
                            end else begin
                              next_counter_FY = 0;
                            end
`else
                            next_counter_FY = 0;
`endif
                            next_counter_K =0 ; 
      end
      
      // If all the filters of a patch have been processed
      else if (CNN_FINISHED_FX_LOOP & CNN_FINISHED_FY_LOOP & CNN_FINISHED_C_LOOP & CNN_FINISHED_K_LOOP)
      begin
                            next_counter_X =counter_X+1 ;
                            next_counter_Y =counter_Y ;
                            next_counter_FX = 0;
                            next_counter_C = 0;
                            next_counter_accumulation_pes=counter_accumulation_pes;
                            next_counter_weight_address =counter_weight_address+1;
                            next_counter_weight_address_after_bias=0;
                            next_counter_FY = 0;
                            next_counter_K = 0;
                            
                            `ifdef DESIGN_V2
                            if (CONF_CONV_STRIDED) begin
                              next_counter_offset_input_channel=counter_offset_input_channel + (2*N_DIM_ARRAY);
                              next_counter_input_channel_address =counter_offset_input_channel + (2*N_DIM_ARRAY) ;
                            end
                            else if (CONF_CONV_DECONV) begin
                              if ((counter_X+1)%2 == 0) begin
                                next_counter_offset_input_channel=counter_offset_input_channel+N_DIM_ARRAY;
                                next_counter_input_channel_address =counter_offset_input_channel+N_DIM_ARRAY;
                              end
                              else begin 
                                next_counter_offset_input_channel=counter_offset_input_channel;
                                next_counter_input_channel_address =counter_offset_input_channel;
                              end
                            end
                            else begin
                              next_counter_offset_input_channel=counter_offset_input_channel + (N_DIM_ARRAY);
                              next_counter_input_channel_address =counter_offset_input_channel + (N_DIM_ARRAY) ;
                            end
`else
                            next_counter_offset_input_channel=counter_offset_input_channel + (N_DIM_ARRAY);
                            next_counter_input_channel_address =counter_offset_input_channel + (N_DIM_ARRAY) ;
`endif
                            
      end 
      
      // If all the chanells of a patch have been processed
      else if (CNN_FINISHED_FX_LOOP & CNN_FINISHED_FY_LOOP & CNN_FINISHED_C_LOOP)
      begin
                            next_counter_X = counter_X;
                            next_counter_Y = counter_Y;
                            next_counter_FX =  0;
                            next_counter_offset_input_channel=counter_offset_input_channel;
                            next_counter_C = 0;
                            next_counter_accumulation_pes= counter_accumulation_pes;

                            next_counter_weight_address =counter_weight_address+1;
                            next_counter_weight_address_after_bias= counter_weight_address +4; 
                            next_counter_input_channel_address = counter_offset_input_channel;
                            next_counter_FY = 0;
                            next_counter_K = counter_K +1;  
      end
      
      // If  a 2D filter has been finished
      else if (CNN_FINISHED_FX_LOOP & CNN_FINISHED_FY_LOOP)
      begin
                            next_counter_X = counter_X;
                            next_counter_Y = counter_Y;
                            next_counter_FX = 0 ;
                            next_counter_offset_input_channel=counter_offset_input_channel;
                            next_counter_C = counter_C+1;
                            next_counter_accumulation_pes= counter_accumulation_pes;
                            next_counter_weight_address = counter_weight_address;
                            next_counter_weight_address_after_bias=counter_weight_address_after_bias;
                            next_counter_input_channel_address =counter_offset_input_channel + counter_current_channel_address + (CONF_SIZE_CHANNEL);
                            next_counter_current_channel_address =counter_current_channel_address + (CONF_SIZE_CHANNEL);
                            next_counter_FY =0 ;
                            next_counter_K = counter_K;  
                            next_sparse_val = sparse_val >> (counter_sparsity + 1);
                            next_counter_sparsity = 0;
                            if (next_counter_C == CONF_C-1)
                              next_sparse_addr = CONF_K;
	 
      end 
      
      // If a filter row has been processed
      else if (CNN_FINISHED_FX_LOOP)
      begin
                            next_counter_X = counter_X;
                            next_counter_Y = counter_Y;
                            next_counter_FX = 0;
                            next_counter_offset_input_channel=counter_offset_input_channel;
                            next_counter_C = counter_C;
                            next_counter_accumulation_pes= counter_accumulation_pes;
                            next_counter_weight_address_after_bias=counter_weight_address_after_bias;
      
                            
                            `ifdef DESIGN_V2
                            //Strided conv
                            if (CONF_CONV_STRIDED)
                              next_counter_input_channel_address =counter_input_channel_address + N_DIM_ARRAY;
                            //Deconvolution
                            else if (CONF_CONV_DECONV)
                              next_counter_input_channel_address =counter_input_channel_address - (N_DIM_ARRAY>>1);
                            else
                              next_counter_input_channel_address =counter_input_channel_address + (CONF_PADDED_C_X  - CONF_FX -N_DIM_ARRAY) ;
`else
                            next_counter_input_channel_address =counter_input_channel_address + (CONF_PADDED_C_X  - CONF_FX -N_DIM_ARRAY) ;
`endif
       
          
                            next_counter_K = counter_K;  
                            
                            
                            `ifdef DESIGN_V2
                            if (CONF_CONV_DECONV) begin
                              next_counter_weight_address =counter_weight_address+3;
                              if (counter_Y%2 == 0)
                                next_counter_FY = counter_FY+2;
                              else
                                next_counter_FY = counter_FY+1;
                            end else begin
                              next_counter_weight_address =counter_weight_address;
                              next_counter_FY = counter_FY+1;
                            end
`else
                            next_counter_weight_address =counter_weight_address;
                            next_counter_FY = counter_FY+1;
`endif
                           
      end
      
      // Otherwise
      else if (!CNN_FINISHED_FX_LOOP)
      begin
                            next_counter_X = counter_X;
                            next_counter_Y = counter_Y;
                            next_counter_FX = counter_FX+1;
                            next_counter_offset_input_channel=counter_offset_input_channel;
                            next_counter_C = counter_C;
                            next_counter_accumulation_pes= counter_accumulation_pes ;
                            next_counter_FY =counter_FY ;
                            next_counter_K = counter_K;  
                            
                            //if (counter_FX == CONF_FX-2)
                            //  next_sparse_val = sparse_val >> (next_counter_sparsity + 1); 
                              
                              
                              `ifdef DESIGN_V2
                            //Strided conv
                            if (CONF_CONV_STRIDED) begin
                              next_counter_weight_address =counter_weight_address+1;
                              if (counter_FX == 0)
                                next_counter_input_channel_address =counter_input_channel_address + (CONF_PADDED_C_X  - 2*CONF_FX-2);
                              else
                                next_counter_input_channel_address =counter_input_channel_address + N_DIM_ARRAY;
                            end
                            else if (CONF_CONV_DECONV) begin
                              if (counter_FX == 0) begin
                                next_counter_input_channel_address =counter_input_channel_address + (CONF_PADDED_C_X  -2);
                                next_counter_weight_address =counter_weight_address+1;
                              end else begin
                                next_counter_input_channel_address =counter_input_channel_address + N_DIM_ARRAY;
                                if (counter_Y%2 == 0)
                                  next_counter_weight_address =counter_weight_address+1;
                                else
                                  next_counter_weight_address =counter_weight_address+4;
                              end   
                            end
                            else begin
                              next_counter_input_channel_address =counter_input_channel_address + CONF_DILATION;
                              next_counter_weight_address =counter_weight_address+1;
                            end
`else
                            next_counter_input_channel_address =counter_input_channel_address + CONF_DILATION;
                            next_counter_weight_address =counter_weight_address+1;
`endif
                           
      end 
      
      
      //Input channel address logic. If CONF_FX is different from 1
     // If it is a 1x1 filter,  
      if (CONF_FX==1)
        next_counter_input_buffer_loading=0;
     else
      begin
       if (counter_input_buffer_loading != ((CONF_FX-1)-1))
          begin
            next_counter_input_buffer_loading = counter_input_buffer_loading+1;
          end
        else
          begin
            next_counter_input_buffer_loading = counter_input_buffer_loading;
         end
      end 
      
     end
     
     
    
    // Add bias
     CONV_ADD_BIAS_ACC:
     begin
        next_counter_X = counter_X;
        next_counter_Y = counter_Y;
        next_counter_FX = 0;
        next_counter_offset_input_channel=counter_offset_input_channel;
        next_counter_C = counter_C;
        next_counter_accumulation_pes=0;
        if (BIAS_ACC_FINISHED)
          next_counter_weight_address = counter_weight_address;
        else
          next_counter_weight_address = counter_weight_address+1;
        next_counter_input_channel_address = counter_input_channel_address;
        next_counter_FY = counter_FY;
        next_counter_K = counter_K;
        next_counter_acc_cnn_bias=counter_acc_cnn_bias+1;
     end 
              // Add bias
     CONV_ADD_BIAS_OPERATION:
     begin
        next_counter_X = counter_X;
        next_counter_Y = counter_Y;
        next_counter_FX = 0;
        next_counter_offset_input_channel=counter_offset_input_channel;
        next_counter_C = counter_C;
        next_counter_accumulation_pes=0;
        next_counter_weight_address = counter_weight_address_after_bias;
        next_counter_input_channel_address = counter_input_channel_address;
        next_counter_FY = counter_FY;
        next_counter_K = counter_K;
         
        next_sparse_addr = (next_counter_K>>BLOCK_SPARSE)+(next_counter_C>>STR_SP_MEMORY_WORD_LOG);
`ifdef DESIGN_V2
        if (CONF_CONV_DECONV) begin
          if ((counter_X)%2 == 0)
            next_odd_X_tile = 0;
          else
            next_odd_X_tile = 1;
        end
`endif
     end
     
     CONV_ADD_BIAS_SHIFTING:
     begin
        next_counter_X = counter_X;
        next_counter_Y = counter_Y;
        next_counter_FX = 0;
        next_counter_offset_input_channel=counter_offset_input_channel;
        next_counter_C = counter_C;
        next_counter_accumulation_pes=0;
        next_counter_weight_address = counter_weight_address;
        next_counter_input_channel_address = counter_input_channel_address;
        next_counter_FY = counter_FY;
        next_counter_K = counter_K;
        
        
     end
      // Passing data between PEs for writing
      CONV_PRE_PASSING_OUTPUTS_VERTICAL:
      begin
        next_counter_X = counter_X;
        next_counter_Y = counter_Y;
        next_counter_FX = 0;
        next_counter_offset_input_channel=counter_offset_input_channel;
        next_counter_weight_address = counter_weight_address;
        next_counter_accumulation_pes=counter_accumulation_pes+1;
        next_counter_input_channel_address = counter_input_channel_address; 
 `ifdef DESIGN_V2
        if (CONF_CONV_DECONV) begin
          if ((counter_Y)%2 == 0)  
            next_counter_FY = 0;
          else
            next_counter_FY = 2;
        end else begin 
          next_counter_FY = 0;
        end
`else
        next_counter_FY = 0;
`endif
        next_counter_K = counter_K;
        if (counter_K==0) //  if all the K kernels have finished
            next_counter_output_channel_address = counter_output_channel_address+1;
            
       `ifdef DESIGN_V2
        if (CONF_CONV_DECONV) begin
          if ((counter_X)%2 == 0)
            next_odd_X_tile = 0;
          else
            next_odd_X_tile = 1;
        end
`endif
      end
     
    CONV_PASSING_OUTPUTS_VERTICAL:
      begin
        next_counter_X = counter_X;
        next_counter_Y = counter_Y;
        next_counter_FX = 0;
        next_counter_offset_input_channel=counter_offset_input_channel;
        next_counter_weight_address = counter_weight_address;
        next_counter_accumulation_pes=counter_accumulation_pes+1;
        next_counter_input_channel_address = counter_input_channel_address;
	next_sparse_val = sparse_val_sram;
`ifdef DESIGN_V2
        if (CONF_CONV_DECONV) begin
          if ((counter_Y)%2 == 0)
            next_counter_FY = 0;
          else
            next_counter_FY = 2;
        end else begin
          next_counter_FY = 0;
        end
`else
        next_counter_FY = 0;
`endif
        next_counter_K = counter_K;
        if (counter_K==0)  //if all the K kernels have finished
            next_counter_output_channel_address = counter_output_channel_address+1;
            
 `ifdef DESIGN_V2
        if (CONF_CONV_DECONV) begin
          if ((counter_X)%2 == 0)
            next_odd_X_tile = 0;
          else
            next_odd_X_tile = 1;
        end
`endif
      end
      
      // Clear all the macs for a new computation
      CONV_CLEAR_MAC:
      begin
        next_counter_FX = 0;
        next_counter_offset_input_channel=counter_offset_input_channel;
        next_counter_weight_address = counter_weight_address;
        next_counter_accumulation_pes=counter_accumulation_pes;
        next_counter_input_channel_address = counter_input_channel_address; 
        next_counter_current_channel_address = 0;
        `ifdef DESIGN_V2
        if (CONF_CONV_DECONV) begin
          if ((counter_Y)%2 == 0)
            next_counter_FY = 0;
          else
            next_counter_FY = 2;
        end else begin
          next_counter_FY = 0;
        end
`else
        next_counter_FY = 0;
`endif
        next_counter_K = counter_K;
        
        `ifdef DESIGN_V2
        if (CONF_CONV_DECONV) begin
          if ((counter_X)%2 == 0)
            next_odd_X_tile = 0;
          else
            next_odd_X_tile = 1;
        end
`endif
      end
     

     // FC
     FC_PRE_MAC:
      begin
      next_counter_accumulation_pes=0;
      next_counter_weight_address = counter_weight_address+1;
      next_counter_Y = 0;
      next_counter_offset_input_channel=0;
      next_counter_FX = 0;
      next_counter_FY = 0;
      next_counter_input_channel_address = 0;
      next_counter_K = counter_K;
      SPARSITY_SET = 0;


       // If execution frame by frame is asserted, use the counter X to iterate over each sub-vector and C to save the current address of the vector    
      if (!EXECUTION_FRAME_BY_FRAME)
        begin
            next_counter_X= 0;
            next_counter_C = counter_C+1;
            next_sparse_val = sparse_val >> (next_counter_sparsity + 1);
        end 
      else
        begin
             //Counter X logic
              if (counter_X== (CONF_TCN_BLOCK_SIZE-1))
                next_counter_X=0;
              else
                next_counter_X=counter_X+1;
              // Counter C logic  
               if (counter_X==(CONF_TCN_BLOCK_SIZE-1)) //if a whole vector has been processed
                    if (CONF_DILATION==1)
                      next_counter_C = counter_C+1;
                    else
                      if (CONF_TCN_BLOCK_SIZE==1)
                        next_counter_C =counter_C+(CONF_DILATION);
                      else
                        next_counter_C =counter_C+((CONF_TCN_BLOCK_SIZE)*CONF_DILATION)-1;
                      
                      
                     // next_counter_C =counter_C+((CONF_TCN_BLOCK_SIZE)*CONF_DILATION);
              else
                next_counter_C =counter_C+1;
        end
      end

    FC_MAC:
      begin
      next_counter_accumulation_pes=counter_accumulation_pes;
      next_counter_Y= 0;
      next_counter_weight_address = counter_weight_address+1;
      next_counter_offset_input_channel=0;
      next_counter_FY = 0;
      next_counter_input_channel_address = 0;
      next_counter_K = counter_K;
      if (!EXECUTION_FRAME_BY_FRAME)
        next_counter_X= 0;
      else
        if (counter_X== (CONF_TCN_BLOCK_SIZE-1))
          next_counter_X=0;
        else
          next_counter_X=counter_X+1;
      //Counter C logic
      if (FC_FINISHED_C_LOOP)
        next_counter_C = 0;
      else
        begin
         if (!EXECUTION_FRAME_BY_FRAME)
        begin
          if (next_state == STR_SPARSITY) begin
            next_counter_C = counter_C;
            //next_counter_weight_address = counter_weight_address;

            next_sparse_val = sparse_val >> (next_counter_sparsity + 1);
          end else begin
            next_counter_C = counter_C+1;
            //next_counter_weight_address = counter_weight_address+1;
            
            next_sparse_val = sparse_val >> (next_counter_sparsity + 1);

            if ((counter_C%STR_SP_MEMORY_WORD) == STR_SP_MEMORY_WORD-3)
              next_sparse_addr = sparse_addr + 1;
            if ((counter_C%STR_SP_MEMORY_WORD) == STR_SP_MEMORY_WORD-1)
              next_sparse_val = sparse_val_sram;
          end
        
        end
        
        else
        if (counter_X==(CONF_TCN_BLOCK_SIZE-1)) //if a whole vector has been processed
          if (CONF_DILATION==1)
                      next_counter_C = counter_C+1;
                    else
                      if (CONF_TCN_BLOCK_SIZE==1)
                       next_counter_C =counter_C+(CONF_DILATION);
                      else
                        next_counter_C =counter_C+((CONF_TCN_BLOCK_SIZE)*CONF_DILATION)-1;
        else
          next_counter_C =counter_C+1;
        end

      end
     
     FC_PRE_BIAS:
      begin
        next_counter_accumulation_pes=counter_accumulation_pes;
        next_counter_X=0;
        next_counter_Y=0;
        next_counter_weight_address = counter_weight_address+1;
        next_counter_offset_input_channel=0;
      next_counter_FX = 0;
      next_counter_FY = 0;
      next_counter_C = counter_C;
      next_counter_input_channel_address = 0;
      //next_counter_K = 0;
      next_counter_K=counter_K;
      end 
     FC_BIAS:
      begin
        next_counter_accumulation_pes=counter_accumulation_pes;
        next_counter_X= 0;
        next_counter_Y = 0;
        next_counter_weight_address = counter_weight_address ;
        next_counter_offset_input_channel=0;
      next_counter_FX = 0;
      next_counter_FY = 0;
      next_counter_C=counter_C;
      next_counter_input_channel_address = 0;
      next_counter_K=counter_K;
      end
      
     FC_PRE_ACCUMULATE_MACS:
      begin
      next_counter_weight_address = counter_weight_address;
      next_counter_accumulation_pes=counter_accumulation_pes+1;
      next_counter_Y = 0;
      next_counter_X=0;
      next_counter_offset_input_channel=0;
      next_counter_FX = 0;
      next_counter_FY = 0;
      next_counter_C = counter_C;
      next_counter_input_channel_address = 0;
      next_counter_K = counter_K;
      next_sparse_val = sparse_val_sram;
      end 
      
    FC_ACCUMULATE_MACS:
      begin
      next_counter_weight_address = counter_weight_address;
      next_counter_accumulation_pes=counter_accumulation_pes+1;
      next_counter_Y = 0;
      next_counter_X=0;
      next_counter_offset_input_channel=0;
      next_counter_FX = 0;
      next_counter_FY = 0;
      next_counter_C =counter_C;
      next_counter_input_channel_address = 0;
      next_counter_K=counter_K;
      end
      
     FC_SAVE_OUTPUTS_MACS:
     begin
        next_counter_accumulation_pes=counter_accumulation_pes;
        next_counter_X= 0;
        next_counter_Y =0;
        next_counter_weight_address = counter_weight_address;
          next_counter_K= counter_K+1;  
        next_counter_offset_input_channel=0;
        next_counter_FX = 0;
        next_counter_FY = 0;
        next_counter_C=counter_C;
        next_counter_input_channel_address = 0;
        
        if (counter_K==0) //if all the K kernels have finished
            next_counter_output_channel_address = counter_output_channel_address+1;
     end
     
     // Activation
     ACTIVATION:
     begin
      next_counter_C=counter_C;
     end
     
     
      // Element wise operation
          EWS_PRE_MAC:
     begin
      next_counter_C = counter_C;
     end 
          EWS_MAC_0:
     begin
      next_counter_C = counter_C+N_DIM_ARRAY;
     end 
     
     EWS_MAC_1:
     begin
      next_counter_C = counter_C;
     end
     
     EWS_SAVE_MAC:
     begin
        next_counter_C = counter_C;
     end 

     
  endcase
 end 

// Low Level FSM state equations
always @(posedge clk or negedge reset)
 begin
  if (!reset)
    state <= INITIAL;
  else
    state <= next_state;
 end
 
 // next state logic
 always @(*)
 begin
      next_state=state;
     case(state)
     INITIAL:
      begin
      // If the High Level FSM initiate the execution of Low Level FSM
        if (HL_enable==1)
          begin
                  case(CONF_MODE)
                    MODE_EWS:next_state = EWS_PRE_MAC;
                    MODE_ACTIVATION:next_state= ACTIVATION;
                    MODE_CNN:

                              
                              begin
                            // If the CNN is causal, execute padding zeros otherwise not
                            if (CONF_STR_SPARSITY == 1)
                              next_state = STR_SPARSITY;
                            else
                              if (CONF_CAUSAL_CONVOLUTION==0)
                                next_state=   CONV_FILLING_INPUT_FIFO;
                              else
                                next_state=   CONV_PADDING_FILLING_INPUT_FIFO; 
                              end
                    MODE_FC: if (CONF_STR_SPARSITY == 1)
                              next_state = STR_SPARSITY;
                            else
                              next_state=   FC_PRE_MAC;
                    default: next_state =INITIAL;
                  endcase
         end     
         else
              next_state =INITIAL;
      end

       
    STR_SPARSITY:
     begin
      if (CONF_MODE == MODE_CNN) begin
         if (CNN_FINISHED_X_LOOP && (next_counter_Y == ((CONF_O_Y)))) // If all the convolutions have been processed
           next_state =FINISHED_LAYER;
         else
           if (sparse_val[0] == 0)
             if (CONF_CAUSAL_CONVOLUTION==0)
               next_state=   CONV_FILLING_INPUT_FIFO;
             else
               next_state=   CONV_PADDING_FILLING_INPUT_FIFO;
           else
             next_state = state; 
      end else if (CONF_MODE == MODE_FC)
          if (next_sparse_val[0] == 0)
            next_state = FC_PRE_MAC;//CONV_MAC;
          else
            next_state = state;
     end    
     
 
     
     
     CONV_FILLING_INPUT_FIFO:  // Fill the input buffer
     begin
`ifdef DESIGN_V2
        //Strided conv or Deconvolution
        if (CONF_CONV_STRIDED || CONF_CONV_DECONV)
          next_state = CONV_FILLING_INPUT_FIFO_2; 
        else
          next_state = CONV_PRE_MAC;
`else
       next_state = CONV_PRE_MAC;
`endif
     end 
     
    `ifdef DESIGN_V2
     CONV_FILLING_INPUT_FIFO_2:  // Fill the second half of input buffer
     begin
        next_state = CONV_PRE_MAC;
     end
`endif 

     CONV_FILLING_INPUT_FIFO:  // Fill the input buffer
     begin
        next_state = CONV_PRE_MAC;
     end
      
     CONV_PRE_MAC: // Wait for input buffer loaded and initiate weight request (only running in the initial execution of a filter)
     begin
      next_state = CONV_MAC;
     end
      CONV_PRE_MAC_2:  // Wait for input buffer loaded and initiate weight request
      begin
          next_state = CONV_MAC;
      end
     
  
      
      
      CONV_MAC: // Main MAC operation
      begin
        // Adding bias after finishing FX loop, FY loop, and C loop
          if (CNN_FINISHED_FX_LOOP  && CNN_FINISHED_FY_LOOP  && CNN_FINISHED_C_LOOP) // If MAC cycling is finished
          begin
            next_state = CONV_ADD_BIAS_ACC; 
          end else if (CNN_FINISHED_FX_LOOP && CNN_FINISHED_FY_LOOP)
          begin
             // MODIFIED BY SEBASTIAN, JUNE 4, 2020
            //if (next_sparse_val[0] == 1 && CONF_STR_SPARSITY == 1)
            //  next_state = STR_SPARSITY;
            //else
            //  next_state = CONV_PRE_MAC_2;
           if (CONF_STR_SPARSITY==1)
                begin
                  if (next_sparse_val[0] == 1)
                       next_state=STR_SPARSITY;
                  else
                       next_state= CONV_PRE_MAC_2;
                end
           else
		next_state=CONV_PRE_MAC_2;

          end else begin
         // If the FX loop is finished only
            if (CNN_FINISHED_FX_LOOP)
                next_state = CONV_PRE_MAC_2;
            else
              next_state=state;
          end
      end
     CONV_ADD_BIAS: // Add bias
          begin
          next_state = CONV_PRE_PASSING_OUTPUTS_VERTICAL;
          end 
      CONV_ADD_BIAS_ACC: // Add bias
          begin
            if (BIAS_ACC_FINISHED)
              next_state = CONV_ADD_BIAS_OPERATION;
            else
              next_state =CONV_ADD_BIAS_ACC;
          end  

       CONV_ADD_BIAS_OPERATION: // Add bias
          begin
          next_state = CONV_ADD_BIAS_SHIFTING;
          end  
          
       CONV_ADD_BIAS_SHIFTING: // Add bias
          begin
          next_state = CONV_PRE_PASSING_OUTPUTS_VERTICAL;
          end 
          
      CONV_PRE_PASSING_OUTPUTS_VERTICAL: // Initial cycle for passing data vertically after output computation
      begin
            next_state = CONV_PASSING_OUTPUTS_VERTICAL;
      end 
      
     CONV_PASSING_OUTPUTS_VERTICAL: // Rest of cycles for passing data vertically after output computation
      begin
       if (ACCUMULATION_PES_FINISHED)
            next_state = CONV_CLEAR_MAC;
        else
            next_state = CONV_PASSING_OUTPUTS_VERTICAL;      
      end
      
     
 
 CONV_CLEAR_MAC: // Clearing MACs after saving the outputs to ACT memory
      begin
        if (CNN_FINISHED_X_LOOP && (counter_Y == ((CONF_O_Y)))) // If all the convolutions have been processed
            next_state =FINISHED_LAYER;
        else
                // MODIFIED BY SEBASTIAN, JUNE 4th
                //if (sparse_val[counter_C%STR_SP_MEMORY_WORD] == 0 || CONF_STR_SPARSITY == 0)   
                //  if (CONF_CAUSAL_CONVOLUTION==0)  // Initiate new round of convolutions
                //  next_state= CONV_FILLING_INPUT_FIFO;
                //  else
                //  next_state= CONV_PADDING_FILLING_INPUT_FIFO; 
                //else
                //  next_state= STR_SPARSITY;
                if (CONF_STR_SPARSITY==0)
                begin
                  if (CONF_CAUSAL_CONVOLUTION==0)  // Initiate new round of convolutions
                   next_state= CONV_FILLING_INPUT_FIFO;
                  else
                   next_state= CONV_PADDING_FILLING_INPUT_FIFO;

		end 
                else
		begin
                   if (sparse_val[counter_C%STR_SP_MEMORY_WORD] == 0)
                        begin
                          if (CONF_CAUSAL_CONVOLUTION==0)  // Initiate new round of convolutions
                            next_state= CONV_FILLING_INPUT_FIFO;
                          else
                            next_state= CONV_PADDING_FILLING_INPUT_FIFO;

			end                
                  else
                      next_state=STR_SPARSITY;
                end           
      
      end
 //FC       
 
     FC_PRE_MAC: // Initiate the request of data from Weight and activation memory
     begin
      // MODIFIED BY SEBASTIAN, JUNE 4, 2020
      //if (next_sparse_val[0] == 1 && CONF_STR_SPARSITY == 1)
      //  next_state = STR_SPARSITY;
      //else
      //  next_state = FC_MAC;
  
             if (CONF_STR_SPARSITY==1)
		begin
                     if (next_sparse_val[0] == 1)
			next_state=STR_SPARSITY;
		     else
                        next_state=FC_MAC;
		end
             else
                next_state=FC_MAC;

     end
     
     
    
  FC_MAC: // Run the MAC operations
      begin
        if (FC_FINISHED_C_LOOP)
          next_state = FC_PRE_ACCUMULATE_MACS;
        else
          // MODIFIED BY SEBASTIAN, JUNE 4, 2020
          //if (next_sparse_val[0] == 1 && CONF_STR_SPARSITY == 1) 
          //  next_state = STR_SPARSITY;
          //else
          //  next_state=state;
          begin
             if (CONF_STR_SPARSITY==1)
                begin
                    if (next_sparse_val[0] == 1 )
                       next_state = STR_SPARSITY;
                    else
                       next_state= state;
		end
             else
              next_state=state;
          end
      end
  
  // Accumulate values between PEs
     FC_PRE_ACCUMULATE_MACS:
      begin
            next_state= FC_ACCUMULATE_MACS;
      end
      
     FC_ACCUMULATE_MACS:
      begin
        if (counter_accumulation_pes !=  ((N_DIM_ARRAY-1)))
          next_state = FC_ACCUMULATE_MACS;
        else
            next_state = FC_PRE_BIAS;
      end      
 
 // Adding BIAS
      FC_PRE_BIAS: // Add BIAS
     begin
        next_state =  FC_BIAS;
     end
     
     FC_BIAS: 
        begin
          next_state= FC_SAVE_OUTPUTS_MACS;
        end 
 
      // Saving data to Act Memory
      FC_SAVE_OUTPUTS_MACS:
      begin
        if (FC_FINISHED_K_LOOP)
            next_state= FINISHED_LAYER;
        else 
          //MODIFIED BY SEBASTIAN, JUNE 4, 2020
          //if (next_sparse_val[0] == 0 || CONF_STR_SPARSITY == 0) 
          //  next_state = FC_PRE_MAC;
          //else
          //  next_state = STR_SPARSITY;
          begin
            if (CONF_STR_SPARSITY==0)
             next_state=FC_PRE_MAC;
            else
             begin
                if (next_sparse_val[0]==0)
                      next_state=FC_PRE_MAC;
                else
                      next_state = STR_SPARSITY;
             end

          end
      end
 
 ///////////////////// ACTIVATION BLOCK //////////////////////////////////////////////////////////////////
      ACTIVATION:
      begin
      if (!finished_activation)
        next_state=ACTIVATION;
      else
        next_state= FINISHED_LAYER;
      end

////////////////////// Element wise operation /////////////////////////////////////////////////////////
     EWS_PRE_MAC:
      begin
       if (EWS_FINISHED)
          next_state = FINISHED_LAYER;
         else
        next_state = EWS_MAC_0;
      end
     EWS_MAC_0:
      begin
       //if (EWS_FINISHED)
       //   next_state = FINISHED_LAYER;
      //   else
        next_state = EWS_MAC_1;
      end
      EWS_MAC_1:
      begin
      // if (EWS_FINISHED)
     //     next_state = FINISHED_LAYER;
     //    else
        next_state = EWS_SAVE_MAC;
      end
     EWS_SAVE_MAC:
      begin
      //  if (EWS_FINISHED)
      //    next_state = FINISHED_LAYER;
     //    else
          next_state =EWS_PRE_MAC;
      end

     
     ///////////////
      FINISHED_LAYER:
      begin
        next_state=INITIAL;
      end
      
      default:
       begin
        next_state =state;
       end
     endcase

 end

 //Datapath signals
 always @(*)
 begin
  //default
  OUTPUT_TILE_SIZE=CONF_OUTPUT_CHANNEL_SIZE;
 
  //// BUG FIXING - SEBASTIAN ////////////////////////////////////////////////////////
 //  WEIGHT_TILE_SIZE=(CONF_FX*CONF_FY*CONF_C*CONF_K) + CONF_K;
//NB_INPUT_TILE=CONF_NB_INPUT_TILE;
  WEIGHT_TILE_SIZE=CONF_WEIGHT_TILE_SIZE;
  NB_INPUT_TILE=0;
  /////////////////////////////////////////////////////////////////////////////////////
  NB_WEIGHT_TILE=CONF_NB_WEIGHT_TILE; 
`ifdef DESIGN_V2
  cr_fifo=0;
  enable_strided_conv=CONF_CONV_STRIDED;
  enable_deconv=CONF_CONV_DECONV;
  
`endif
  enable_BUFFERED_OUTPUT=0;
  INPUT_PRECISION=CONF_INPUT_PRECISION[1:0];
  OUTPUT_PRECISION=CONF_OUTPUT_PRECISION[1:0];
  PADDED_C_X=CONF_PADDED_C_X;
  PADDED_O_X=CONF_O_X;
  NUMBER_OF_ACTIVATION_CYCLES=CONF_C;
  SPARSITY=CONF_STR_SPARSITY;
  mode=CONF_MODE;
  causal_convolution = CONF_CAUSAL_CONVOLUTION[0];
  SHIFT_FIXED_POINT=CONF_SHIFT_FIXED_POINT[7:0];
  finished_layer=0;
  enable_input_fifo=0;
  loading_in_parallel=0;
  input_memory_pointer=CONF_INPUT_MEMORY_POINTER;
  output_memory_pointer=CONF_OUTPUT_MEMORY_POINTER;
  clear = 0;
  enable_pe_array=0;
  enable_nonlinear_block = 0;
  input_channel_rd_addr =0 ;
  input_channel_rd_en=0;
  weight_rd_addr=0;
  weight_rd_en=0;
  wr_en_output_buffer=0;
  enable_pooling=0;
  enable_sig_tanh=0;
  type_nonlinear_function=CONF_TYPE_NONLINEAR_FUNCTION;
  shift_input_buffer=CONF_DILATION;
  FIFO_TCN_total_blocks= CONF_TCN_TOTAL_BLOCKS;
  FIFO_TCN_block_size=CONF_TCN_BLOCK_SIZE;
  FIFO_TCN_offset = CONF_FIFO_TCN_offset;
  wr_addr=0;
  
  enable_bias_32bits=0;
  addr_bias_32bits=0;
  for (i=0; i<(N_DIM_ARRAY); i=i+1) 
    for (j=0; j < (N_DIM_ARRAY); j=j+1) 
      CR_PE_array[i][j] = 17'b000000000010;
  case(state)
  
  /////////////////////
    INITIAL:    
          begin
          `ifdef DESIGN_V2
          cr_fifo=0;
`endif
          enable_input_fifo=0;
          loading_in_parallel=0;
          // BUG FIXING MAY 20, 2020
          //clear = 0;
          clear=1;
          enable_pe_array=0;
          for (i=0; i<(N_DIM_ARRAY); i=i+1) 
            for (j=0; j < (N_DIM_ARRAY); j=j+1) 
              CR_PE_array[i][j] =17'b00000010;
          input_channel_rd_addr =0 ;
          input_channel_rd_en=0;
          weight_rd_addr=0;
          weight_rd_en=0;
          wr_en_output_buffer=0;
          end

    STR_SPARSITY:
          begin
          `ifdef DESIGN_V2
          cr_fifo=0;
`endif
          enable_input_fifo=0;
          loading_in_parallel=0;
          clear = 0;
          enable_pe_array=0;
          for (i=0; i<(N_DIM_ARRAY); i=i+1)
            for (j=0; j < (N_DIM_ARRAY); j=j+1)
              CR_PE_array[i][j] = 17'b00000010;
          input_channel_rd_addr =0 ;
          input_channel_rd_en=0;
          weight_rd_addr=0;
          weight_rd_en=0;
          wr_en_output_buffer=0;
          end
          
     //cnn 
    CONV_FILLING_INPUT_FIFO:    
          begin
          `ifdef DESIGN_V2
          cr_fifo=0;
`endif
          
          enable_input_fifo=0;
          loading_in_parallel=1;
          clear = 0;
          enable_pe_array=1;
          for (i=0; i<(N_DIM_ARRAY); i=i+1) 
            for (j=0; j < (N_DIM_ARRAY); j=j+1) 
              CR_PE_array[i][j] = 17'b00000010;
          input_channel_rd_addr =counter_input_channel_address ;
          input_channel_rd_en=1;
          weight_rd_addr=counter_weight_address;
          weight_rd_en=0;
          wr_en_output_buffer=0;
          end    
          `ifdef DESIGN_V2
    CONV_FILLING_INPUT_FIFO_2:
          begin
          enable_input_fifo=0;
          cr_fifo=2'b01;
          loading_in_parallel=1;
          clear = 0;
          enable_pe_array=1;
          for (i=0; i<(N_DIM_ARRAY); i=i+1)
            for (j=0; j < (N_DIM_ARRAY); j=j+1)
              CR_PE_array[i][j] = 17'b00000010;
          input_channel_rd_addr =counter_input_channel_address ;
          input_channel_rd_en=1;
          weight_rd_addr=counter_weight_address;
          weight_rd_en=0;
          wr_en_output_buffer=0;
          end
`endif
    CONV_PADDING_FILLING_INPUT_FIFO:    
          begin
          `ifdef DESIGN_V2
          cr_fifo=0;
`endif
          enable_input_fifo=0;
          loading_in_parallel=0;
          clear = 1;
          enable_pe_array=0;
          for (i=0; i<(N_DIM_ARRAY); i=i+1) 
            for (j=0; j < (N_DIM_ARRAY); j=j+1) 
              CR_PE_array[i][j] = 17'b00000010;
          input_channel_rd_addr =counter_input_channel_address ;
          input_channel_rd_en=1;
          weight_rd_addr=counter_weight_address;
          weight_rd_en=0;
          wr_en_output_buffer=0; 
          end       
          
    CONV_PRE_MAC:
          begin
          `ifdef DESIGN_V2
          //Strided conv or Deconvolution
          if (CONF_CONV_STRIDED || CONF_CONV_DECONV)
            loading_in_parallel=1;
          else
            loading_in_parallel=0;
          cr_fifo=2'b01;
`else
          loading_in_parallel=0;
`endif
          enable_input_fifo=1;
          clear = 0;
          enable_pe_array=1;
          for (i=0; i<(N_DIM_ARRAY); i=i+1) 
            for (j=0; j < (N_DIM_ARRAY); j=j+1) 
              CR_PE_array[i][j] = 17'b00000010;
          input_channel_rd_addr =counter_input_channel_address;
          input_channel_rd_en=1;
          weight_rd_addr=counter_weight_address;
          weight_rd_en=1;
          wr_en_output_buffer=0;
          end
          
   
          
          CONV_PRE_MAC_2:
          begin


          for (i=0; i<(N_DIM_ARRAY); i=i+1) 
            for (j=0; j < (N_DIM_ARRAY); j=j+1) 
              CR_PE_array[i][j] = 17'b00000010;
          // Take into account the N_DIM_ARRAY elements loaded at the end of CONV_MAC state
          input_channel_rd_en=1;
          weight_rd_addr=counter_weight_address;
          weight_rd_en=1;
          wr_en_output_buffer=0;
          
          
          `ifdef DESIGN_V2
          //Strided conv or Deconvolution
          if (CONF_CONV_STRIDED || CONF_CONV_DECONV)
            loading_in_parallel=1;
          else
            loading_in_parallel=0;
            cr_fifo=2'b01;
`else
          loading_in_parallel=0;
`endif
          enable_input_fifo=1;
          clear = 0;
          enable_pe_array=1;

          // Take into account the N_DIM_ARRAY elements loaded at the end of CONV_MAC state
`ifdef DESIGN_V2
          //Strided conv or Deconvolution
          if (CONF_CONV_STRIDED || CONF_CONV_DECONV)
            input_channel_rd_addr =counter_input_channel_address;
          else
            input_channel_rd_addr =counter_input_channel_address+N_DIM_ARRAY;
`else
          input_channel_rd_addr =counter_input_channel_address+N_DIM_ARRAY;
`endif
          end 


      CONV_MAC:
          begin
         
          clear = 0;
          enable_pe_array=1;
          weight_rd_addr= counter_weight_address;
          for (i=0;i<N_DIM_ARRAY;i=i+1)
            for (j=0; j < (N_DIM_ARRAY); j=j+1) 
              CR_PE_array[i][j] = 17'b00100000;
          // If there is the need to load a new word
          if (counter_input_buffer_loading != ((CONF_FX-1)-1))
          begin
          input_channel_rd_addr =counter_input_channel_address;
          input_channel_rd_en=1;

`ifdef DESIGN_V2
          cr_fifo=2'b01;
`endif

          end 
     
          else

        
begin
          `ifdef DESIGN_V2
          //Strided conv or Deconvolution
          if (CONF_CONV_STRIDED || CONF_CONV_DECONV) begin
            if (counter_FY == CONF_FY-1) begin
              input_channel_rd_addr =0;
              input_channel_rd_en=0;
            end else begin
              input_channel_rd_addr =counter_input_channel_address; 
              input_channel_rd_en=1;
            end
          end else begin
            input_channel_rd_addr =0; 
            input_channel_rd_en=0;
          end
          cr_fifo=2'b10;
`else
          input_channel_rd_addr =0;
          input_channel_rd_en=0;
`endif
          end
          
          // If this cycle is the last mac, don't retrieve data from weight memory and load a new vector for CNN processing
          if (next_state == CONV_PRE_MAC_2)
            begin
                weight_rd_en=0;
                `ifdef DESIGN_V2
                //Strided conv or Deconvolution
                if (CONF_CONV_STRIDED || CONF_CONV_DECONV)
                  input_channel_rd_addr =counter_input_channel_address;
                else
                  input_channel_rd_addr =next_counter_input_channel_address;
`else
                input_channel_rd_addr =next_counter_input_channel_address;
`endif
                input_channel_rd_en=1;
                loading_in_parallel=1;
                enable_input_fifo=0; 
            end 
          else
            begin
                weight_rd_en=1;   
                loading_in_parallel=0;
                enable_input_fifo=1; 
            end       
          wr_en_output_buffer=0;
          end
          
     CONV_ADD_BIAS:
          begin
          loading_in_parallel=0;
          enable_input_fifo=0;
          clear = 0;
          enable_pe_array=1;
          for (i=0; i<(N_DIM_ARRAY); i=i+1) 
            for (j=0; j < (N_DIM_ARRAY); j=j+1) 
              CR_PE_array[i][j] = 17'b101100000;
          input_channel_rd_addr =counter_input_channel_address;
          input_channel_rd_en=0;
          weight_rd_addr=counter_weight_address;
          weight_rd_en=1;
          wr_en_output_buffer=0;
          end     
     
     CONV_ADD_BIAS_ACC:
          begin
          loading_in_parallel=0;
          enable_input_fifo=0;
          clear = 0;
          enable_pe_array=1;
          for (i=0; i<(N_DIM_ARRAY); i=i+1) 
            for (j=0; j < (N_DIM_ARRAY); j=j+1) 
              CR_PE_array[i][j] =17'b00000010;
          input_channel_rd_addr =counter_input_channel_address;
          input_channel_rd_en=0;
          weight_rd_addr=counter_weight_address;
          if (BIAS_ACC_FINISHED) // if it is accumulated, dont retrieve more data
            weight_rd_en=0;
          else
            weight_rd_en=1;
          wr_en_output_buffer=0;
          enable_bias_32bits=1;
          addr_bias_32bits=counter_acc_cnn_bias;
          end     
      
     
     CONV_ADD_BIAS_OPERATION:
          begin
          loading_in_parallel=0;
          enable_input_fifo=0;
          clear = 0;
          enable_pe_array=1;
          for (i=0; i<(N_DIM_ARRAY); i=i+1) 
            for (j=0; j < (N_DIM_ARRAY); j=j+1) 
              CR_PE_array[i][j] =17'b0010_0000_0110_0000; //for 32 bias
          input_channel_rd_addr =counter_input_channel_address;
          input_channel_rd_en=0;
          weight_rd_addr=counter_weight_address;
          weight_rd_en=0;
          wr_en_output_buffer=0;
          enable_bias_32bits=0;
          addr_bias_32bits=0;
          end     
          
     CONV_ADD_BIAS_SHIFTING:
          begin
          loading_in_parallel=0;
          enable_input_fifo=0;
          clear = 0;
          enable_pe_array=1;
          for (i=0; i<(N_DIM_ARRAY); i=i+1) 
            for (j=0; j < (N_DIM_ARRAY); j=j+1) 
              //CR_PE_array[i][j] = 17'b101100000;
              CR_PE_array[i][j] = 17'b0000_0001_0000_0010;
              //CR_PE_array[i][j] =17'b0100_0001_0000_0010; //for 32 bias
          input_channel_rd_addr =counter_input_channel_address;
          input_channel_rd_en=0;
          weight_rd_addr=counter_weight_address;
          weight_rd_en=0;
          wr_en_output_buffer=0;
          enable_bias_32bits=0;
          addr_bias_32bits=0;
          end  
     
     CONV_PRE_PASSING_OUTPUTS_VERTICAL:
          begin
          
          if (CONF_OUTPUT_PRECISION==0) // if it is set to 8 bit parameters
            enable_BUFFERED_OUTPUT=0;
          else
            enable_BUFFERED_OUTPUT=1; 
            
          loading_in_parallel=0;
          enable_input_fifo=0;
          clear = 0;
          enable_pe_array=1;
          for (i=0; i<(N_DIM_ARRAY); i=i+1) 
            for (j=0; j < (N_DIM_ARRAY); j=j+1) 
              if (CONF_ACTIVATION_FUNCTION==1) // IF RELU
                CR_PE_array[i][j] = 17'b0000_0110;
              else
                CR_PE_array[i][j] = 17'b0000_0010;
          input_channel_rd_addr =counter_input_channel_address ;
          input_channel_rd_en=0;
          weight_rd_addr=counter_weight_address;
          weight_rd_en=0;
          
              if (counter_K ==0)
              wr_addr = ((counter_output_channel_address + (counter_accumulation_pes>> CONF_OUTPUT_PRECISION )*CONF_OUTPUT_CHANNEL_SIZE + (((CONF_K-1))* (CONF_OUTPUT_CHANNEL_SIZE>>CONF_OUTPUT_PRECISION)<<(N_DIM_ARRAY_LOG)))>> (N_DIM_ARRAY_LOG));
              else
              wr_addr= ((counter_output_channel_address + (counter_accumulation_pes>> CONF_OUTPUT_PRECISION )*CONF_OUTPUT_CHANNEL_SIZE  + (((counter_K-1))* (CONF_OUTPUT_CHANNEL_SIZE>>CONF_OUTPUT_PRECISION)<<(N_DIM_ARRAY_LOG))) >> (N_DIM_ARRAY_LOG));

            
            
            
          if (CONF_OUTPUT_PRECISION==0)   
            wr_en_output_buffer=1;
          else if (CONF_OUTPUT_PRECISION==1)  
            if (counter_accumulation_pes[0]==1)
              wr_en_output_buffer=1;
            else
              wr_en_output_buffer=0;
          else // (CONF_OUTPUT_PRECISION==2) for 2 bits  
            if (counter_accumulation_pes[1:0]==2'b11)
              wr_en_output_buffer=1;
            else
              wr_en_output_buffer=0;


          end     
          
          
    CONV_PASSING_OUTPUTS_VERTICAL:
          begin
          if (CONF_OUTPUT_PRECISION==0) // if it is set to 8 bit parameters
            enable_BUFFERED_OUTPUT=0;
          else
            enable_BUFFERED_OUTPUT=1;
           
          loading_in_parallel=0;
          enable_input_fifo=0;
          clear = 0;
          enable_pe_array=1;
          for (i=0; i<(N_DIM_ARRAY); i=i+1) 
            for (j=0; j < (N_DIM_ARRAY); j=j+1) 
              if (CONF_ACTIVATION_FUNCTION==1) // IF RELU
              CR_PE_array[i][j] = 17'b1000_0000_0110;
             
              else
              CR_PE_array[i][j] = 13'b1000_0000_0010;
              //CR_PE_array[i][j] = 17'b1000_0000_0010;
          input_channel_rd_addr =counter_input_channel_address ;
          input_channel_rd_en=0;
          weight_rd_addr=counter_weight_address;
          weight_rd_en=0;
          
           // If all the filters have been processed
            if (counter_K ==0)
              wr_addr =((counter_output_channel_address + (counter_accumulation_pes >> CONF_OUTPUT_PRECISION)*CONF_OUTPUT_CHANNEL_SIZE + (((CONF_K-1))* (CONF_OUTPUT_CHANNEL_SIZE>>CONF_OUTPUT_PRECISION)<<(N_DIM_ARRAY_LOG)))>> (N_DIM_ARRAY_LOG)); 
              else
              wr_addr = ((counter_output_channel_address + (counter_accumulation_pes >> CONF_OUTPUT_PRECISION)*CONF_OUTPUT_CHANNEL_SIZE  + (((counter_K-1))* (CONF_OUTPUT_CHANNEL_SIZE>>CONF_OUTPUT_PRECISION)<<(N_DIM_ARRAY_LOG))) >> (N_DIM_ARRAY_LOG));

          if (CONF_OUTPUT_PRECISION==0)   
            wr_en_output_buffer=1;
          else if (CONF_OUTPUT_PRECISION==1)  
            if (counter_accumulation_pes[0]==1)
              wr_en_output_buffer=1;
            else
              wr_en_output_buffer=0;
          else // (CONF_OUTPUT_PRECISION==2) for 2 bits  
            if (counter_accumulation_pes[1:0]==2'b11)
              wr_en_output_buffer=1;
            else
              wr_en_output_buffer=0;
              
              

              
          end
     
     
     CONV_CLEAR_MAC:
          begin
          loading_in_parallel=0;
          enable_input_fifo=0;
          clear = 1;
          enable_pe_array=1;
           for (i=0; i<(N_DIM_ARRAY); i=i+1) 
            for (j=0; j < (N_DIM_ARRAY); j=j+1) 
              CR_PE_array[i][j] = 17'b00000010;
          input_channel_rd_addr =counter_input_channel_address;
          `ifdef DESIGN_V2
          //Strided conv or Deconvolution
          if (CONF_CONV_STRIDED || CONF_CONV_DECONV)
            input_channel_rd_en=1;
          else
            input_channel_rd_en=0;
`else
          input_channel_rd_en=0;
`endif
          weight_rd_addr=counter_weight_address;
          weight_rd_en=0;
          wr_en_output_buffer=0;
          end     
       // FC    
    
       
       FC_PRE_MAC:
          begin
          if (counter_C == 0)
            clear = 1;
          else
            clear = 0;
          enable_pe_array=1;
              
         `ifdef DESIGN_V2
          for (i=0; i<(N_DIM_ARRAY); i=i+1) begin
            for (j=0; j < (N_DIM_ARRAY); j=j+1) begin
              if (CONF_NORM == 00 || CONF_NORM == 11)
              
                /// FOR VIKRAM: CHECK THE CORRECTNESS OF THE FOLLOWING STATENMENTS TAKING INTO CONSIDERATION THE PE SIGNALS ADDED BY SEBASTIAN
                CR_PE_array[i][j] = 17'b00000010;
              else if (CONF_NORM == 01) // L2 norm
                CR_PE_array[i][j] = 17'b01000_0000_0000_0010;
              else if (CONF_NORM == 10) // L1 norm
                CR_PE_array[i][j] = 17'b10000_0000_0000_0010;
            end
          end
`else
          for (i=0; i<(N_DIM_ARRAY); i=i+1)
            for (j=0; j < (N_DIM_ARRAY); j=j+1)   
              CR_PE_array[i][j] = 17'b00000010;
`endif 


          input_channel_rd_addr =counter_C;
          input_channel_rd_en=1;
          weight_rd_addr=counter_weight_address;
          weight_rd_en=1;
          wr_en_output_buffer=0;
          enable_input_fifo=0;
          loading_in_parallel=0;
          end
    FC_MAC:
          begin
          clear = 0;
          enable_pe_array=1;
          
          
           /// FOR VIKRAM: CHECK THE CORRECTNESS OF THE FOLLOWING STATENMENTS TAKING INTO CONSIDERATION THE PE SIGNALS ADDED BY SEBASTIAN
          `ifdef DESIGN_V2
          for (i=0; i<(N_DIM_ARRAY); i=i+1) begin
            for (j=0; j < (N_DIM_ARRAY); j=j+1) begin
              if (CONF_NORM == 00 || CONF_NORM == 11)
                CR_PE_array[i][j] = 17'b00100000;
              else if (CONF_NORM == 01) // L2 norm
                CR_PE_array[i][j] = 17'b01000_0000_0010_0000;
              else if (CONF_NORM == 10) // L1 norm
                CR_PE_array[i][j] = 17'b10000_0000_0010_0000;
            end
          end
`else
          for (i=0; i<(N_DIM_ARRAY); i=i+1) 
            for (j=0; j < (N_DIM_ARRAY); j=j+1)       
              CR_PE_array[i][j] = 17'b00100000;
`endif

          input_channel_rd_addr =counter_C;
          input_channel_rd_en=1;
          weight_rd_addr=counter_weight_address;
          weight_rd_en=1;
          wr_en_output_buffer=0;
                         
          enable_input_fifo=0;
          loading_in_parallel=0;
          end
          
   
          
    FC_PRE_ACCUMULATE_MACS:
          begin
          clear = 0;
          enable_pe_array=1;
          
  
            /// FOR VIKRAM: CHECK THE CORRECTNESS OF THE FOLLOWING STATENMENTS TAKING INTO CONSIDERATION THE PE SIGNALS ADDED BY SEBASTIAN
      
         /* `ifdef DESIGN_V2
          for (i=0; i<(N_DIM_ARRAY); i=i+1) begin 
            for (j=0; j < (N_DIM_ARRAY); j=j+1) begin
              if (j== 0) begin
                if (CONF_NORM == 00 || CONF_NORM == 11)
                  CR_PE_array[i][j] =17'b0010_0001;
                else if (CONF_NORM == 01) // L2 norm
                  CR_PE_array[i][j] =17'b01000_0000_0010_0001;
                else if (CONF_NORM == 10) // L1 norm
                  CR_PE_array[i][j] =17'b10000_0000_0010_0001;
              end else begin
                if (CONF_NORM == 00 || CONF_NORM == 11)
                  CR_PE_array[i][j] =17'b10_0000_1000; 
                else if (CONF_NORM == 01) // L2 norm
                  CR_PE_array[i][j] =17'b01000_0010_0000_1000;
                else if (CONF_NORM == 10) // L1 norm
                  CR_PE_array[i][j] =17'b10000_0010_0000_1000;
              end
            end
          end
`else
          for (i=0; i<(N_DIM_ARRAY); i=i+1)
            for (j=0; j < (N_DIM_ARRAY); j=j+1)
              if (j== 0)
                CR_PE_array[i][j] =17'b0010_0001;
              else
                  CR_PE_array[i][j] =17'b10_0000_1000;
`endif   */
 
       
          /// BUG FIXING MAY 20, 2020. Added to solvie issue with accumulation of FC MACs. 

          `ifdef DESIGN_V2
          for (i=0; i<(N_DIM_ARRAY); i=i+1) begin
            for (j=0; j < (N_DIM_ARRAY); j=j+1) begin
              if (CONF_NORM == 00 || CONF_NORM == 11)
                CR_PE_array[i][j] = 17'b00100000;
              else if (CONF_NORM == 01) // L2 norm
                CR_PE_array[i][j] = 17'b01000_0000_0010_0000;
              else if (CONF_NORM == 10) // L1 norm
                CR_PE_array[i][j] = 17'b10000_0000_0010_0000;
            end
          end
`else
          for (i=0; i<(N_DIM_ARRAY); i=i+1)
            for (j=0; j < (N_DIM_ARRAY); j=j+1)
              CR_PE_array[i][j] = 17'b00100000;
`endif


                  
          input_channel_rd_addr =counter_C ;
          input_channel_rd_en=0;
          weight_rd_addr=counter_weight_address;
          weight_rd_en=0;
          wr_en_output_buffer=0;
          enable_input_fifo=0;
          loading_in_parallel=0;
          end 
          
          
    FC_ACCUMULATE_MACS:
          begin
          clear = 0;
          enable_pe_array=1;
          
           /// FOR VIKRAM: CHECK THE CORRECTNESS OF THE FOLLOWING STATENMENTS TAKING INTO CONSIDERATION THE PE SIGNALS ADDED BY SEBASTIAN
      
          `ifdef DESIGN_V2
          for (i=0; i<(N_DIM_ARRAY); i=i+1) begin
            for (j=0; j < (N_DIM_ARRAY); j=j+1) begin
              if (j== 0) begin
                if (CONF_NORM == 00 || CONF_NORM == 11)
                  CR_PE_array[i][j] =17'b0010_0001;
                else if (CONF_NORM == 01) // L2 norm
                  CR_PE_array[i][j] =17'b01000_0000_0010_0001;
                else if (CONF_NORM == 10) // L1 norm
                  CR_PE_array[i][j] =17'b10000_0000_0010_0001;
              end else begin
                if (CONF_NORM == 00 || CONF_NORM == 11)
                  CR_PE_array[i][j] =17'b10_0000_1000;
                else if (CONF_NORM == 01) // L2 norm
                  CR_PE_array[i][j] =17'b01000_0010_0000_1000;
                else if (CONF_NORM == 10) // L1 norm
                  CR_PE_array[i][j] =17'b10000_0010_0000_1000;
              end
            end
          end
`else
          for (i=0; i<(N_DIM_ARRAY); i=i+1)
            for (j=0; j < (N_DIM_ARRAY); j=j+1)
              if (j== 0)
                CR_PE_array[i][j] =17'b00100001;
              else
                  CR_PE_array[i][j] =17'b1000001000;
`endif 




          input_channel_rd_addr =counter_C ;
          input_channel_rd_en=0;
          
          wr_en_output_buffer=0;
          enable_input_fifo=0;
          loading_in_parallel=0;
          
          // Initiate the loading of the BIAS before finishing the accumulation
          weight_rd_addr=counter_weight_address;
          weight_rd_en=0;
          end
     FC_PRE_BIAS:
          begin
          clear = 0;
          enable_pe_array=1;
          
            /// FOR VIKRAM: CHECK THE CORRECTNESS OF THE FOLLOWING STATENMENTS TAKING INTO CONSIDERATION THE PE SIGNALS ADDED BY SEBASTIAN
      
          `ifdef DESIGN_V2
          for (i=0; i<(N_DIM_ARRAY); i=i+1) begin
            for (j=0; j < (N_DIM_ARRAY); j=j+1) begin
              if (CONF_NORM == 00 || CONF_NORM == 11)
                //CR_PE_array[i][j] = 17'b00100000;
                /// BUG FIXING MAY 20,2020 SEBASTIAN
        		      if (j== 0)
                		CR_PE_array[i][j] =17'b00100001;
              		      else
                  		CR_PE_array[i][j] =17'b1000001000;

              else if (CONF_NORM == 01) // L2 norm
                CR_PE_array[i][j] = 17'b01000_0000_0010_0000;
              else if (CONF_NORM == 10) // L1 norm
                CR_PE_array[i][j] = 17'b10000_0000_0010_0000;
              else
                CR_PE_array[i][j] = 17'b00100000;
            end
          end
`else
          for (i=0; i<(N_DIM_ARRAY); i=i+1)
            for (j=0; j < (N_DIM_ARRAY); j=j+1)
               //CR_PE_array[i][j] = 17'b00100000;
               // BUG FIXING MAY 20,2020 SEBASTIAN
                              if (j== 0)
                                CR_PE_array[i][j] =17'b00100001;
                              else
                                CR_PE_array[i][j] =17'b1000001000;

`endif 



          input_channel_rd_addr =counter_C;
          input_channel_rd_en=0;
          weight_rd_addr=counter_weight_address;
          weight_rd_en=1;
          wr_en_output_buffer=0;
          enable_input_fifo=0;
          loading_in_parallel=0;
          end  
          
          
            /// FOR VIKRAM: CHECK THE CORRECTNESS OF THE FOLLOWING STATENMENTS TAKING INTO CONSIDERATION THE PE SIGNALS ADDED BY SEBASTIAN
      
    FC_BIAS:
          begin
          clear = 0;
          enable_pe_array=1;
          
          `ifdef DESIGN_V2
          for (i=0; i<(N_DIM_ARRAY); i=i+1) begin
            for (j=0; j < (N_DIM_ARRAY); j=j+1) begin
              if (j== 0) begin
                if (CONF_NORM == 00 || CONF_NORM == 11)
                  CR_PE_array[i][j] =17'b0010_0000_0110_0000; //for 32 bias
                else if (CONF_NORM == 01) // L2 norm
                  CR_PE_array[i][j] =17'b01000_0001_0110_0000;
                else if (CONF_NORM == 10) // L1 norm
                  CR_PE_array[i][j] =17'b10000_0001_0110_0000;
              end else begin
                if (CONF_NORM == 00 || CONF_NORM == 11)
                  CR_PE_array[i][j] =17'b00000010;
                else if (CONF_NORM == 01) // L2 norm
                  CR_PE_array[i][j] =17'b01000_0000_0000_0010;
                else if (CONF_NORM == 10) // L1 norm
                  CR_PE_array[i][j] =17'b10000_0000_0000_0010;
              end
            end
          end
`else
           for (i=0; i<(N_DIM_ARRAY); i=i+1) 
            for (j=0; j < (N_DIM_ARRAY); j=j+1) 
              if (j == 0)
                CR_PE_array[i][j] =17'b0010_0000_0110_0000; //for 32 bias
              else
                CR_PE_array[i][j]= 17'b00000010;
`endif 



                
                
          input_channel_rd_addr =counter_C;
          input_channel_rd_en=0;
          weight_rd_addr=counter_weight_address;
          weight_rd_en=0;
          wr_en_output_buffer=0;
          enable_input_fifo=0;
          loading_in_parallel=0;
          end           
       FC_SAVE_OUTPUTS_MACS:
          begin 
          if (CONF_OUTPUT_PRECISION==0)
            enable_BUFFERED_OUTPUT=0;
          else
            enable_BUFFERED_OUTPUT=1;
            
          clear = 0;
          enable_pe_array=1;
          
          
          
          `ifdef DESIGN_V2
          for (i=0; i<(N_DIM_ARRAY); i=i+1) begin
            for (j=0; j < (N_DIM_ARRAY); j=j+1) begin
              if (CONF_NORM == 00 || CONF_NORM == 11)
                // BUG FIXING MAY 15, ADDING RELU FOR FC LAYER
                if (CONF_ACTIVATION_FUNCTION==0) // IF RELU 
                 CR_PE_array[i][j] =17'b0100_0000_0000_0010; //32 bias
                else
                 CR_PE_array[i][j] =17'b0100_0000_0000_0110; //32 bias 
              else if (CONF_NORM == 01) // L2 norm
                CR_PE_array[i][j] = 17'b01000_0000_0000_0010;
              else if (CONF_NORM == 10) // L1 norm
                CR_PE_array[i][j] = 17'b10000_0000_0000_0010;
            end
          end
`else
          for (i=0; i<(N_DIM_ARRAY); i=i+1) 
            for (j=0; j < (N_DIM_ARRAY); j=j+1)
               begin 
              //CR_PE_array[i][j] =17'b0100_0000_0000_0010; //32 bias
                if (CONF_ACTIVATION_FUNCTION==0) // IF RELU
                 CR_PE_array[i][j] =17'b0100_0000_0000_0010; //32 bias
                else
                 CR_PE_array[i][j] =17'b0100_0000_0000_0110; //32 bias
                end
`endif 


          
          input_channel_rd_addr =counter_C ;
          input_channel_rd_en=0;
          weight_rd_addr=counter_weight_address;
          weight_rd_en=0;
          
           if (CONF_OUTPUT_PRECISION==0)
              wr_en_output_buffer=1;
            else if (CONF_OUTPUT_PRECISION==1)
              if ((counter_K[0])==1)
                wr_en_output_buffer=1;
              else
                wr_en_output_buffer=0;
            else // (CONF_OUTPUT_PRECISION==2)
              if ((counter_K[1:0])==2'b11)
                wr_en_output_buffer=1;
              else
                wr_en_output_buffer=0;
          
          enable_input_fifo=0;
          loading_in_parallel=0;
          
          wr_addr = counter_K>>CONF_OUTPUT_PRECISION;
              
              
          end        
              
  
          // ACTIVATION
          ACTIVATION:
            begin
              enable_nonlinear_block=1;
              enable_sig_tanh=0;
              enable_pooling=0;
                case(type_nonlinear_function)
                  0:enable_sig_tanh=1; //relu
                  1:enable_pooling=1; //pool 1d
                  2: enable_pooling=1; //pool 2d
                  3:  enable_sig_tanh=1; // sigmoid
                  4: enable_sig_tanh=1; //tanh
                 endcase
            end

                    // EWS
          EWS_PRE_MAC:
          begin
           clear = 1;
          enable_pe_array=1;
          input_memory_pointer = CONF_INPUT_MEMORY_POINTER;
          for (i=0; i<(N_DIM_ARRAY); i=i+1) 
                CR_PE_array[0][i] =17'b0_0000_0000_0010;
            input_channel_rd_addr =counter_C;
            input_channel_rd_en=1;
            wr_en_output_buffer=0;
          end

          EWS_MAC_0:
          begin
            clear = 0;
            enable_pe_array=1;
            input_memory_pointer = CONF_OUTPUT_MEMORY_POINTER;
            for (i=0; i<(N_DIM_ARRAY); i=i+1) 
                CR_PE_array[0][i] =17'b1_0000_0010_0000;
                
            input_channel_rd_addr =counter_C;
            input_channel_rd_en=1;
            wr_en_output_buffer=0;
          end
       EWS_MAC_1:
          begin
          clear = 0;
            enable_pe_array=1;
            input_memory_pointer = CONF_OUTPUT_MEMORY_POINTER;
            
            // If it is a element wise sum
            if (CONF_TYPE_NONLINEAR_FUNCTION==0)
            begin
            for (i=0; i<(N_DIM_ARRAY); i=i+1) 
                CR_PE_array[0][i] =17'b1_0000_0010_0000;
            end
            else //If it is a element wise multiplication
            begin
            for (i=0; i<(N_DIM_ARRAY); i=i+1) 
                CR_PE_array[0][i] =17'b0_0000_1001_0000;
            end
            input_memory_pointer = 0;
            input_channel_rd_addr =counter_C;
            input_channel_rd_en=0;
            wr_en_output_buffer=0;
          end
          
          EWS_SAVE_MAC:
          begin
          clear = 0;
            enable_pe_array=1;
            input_memory_pointer = CONF_OUTPUT_MEMORY_POINTER;
            for (i=0; i<(N_DIM_ARRAY); i=i+1) 
                CR_PE_array[0][i] =17'b00000010;
            input_channel_rd_addr =counter_C;
            input_channel_rd_en=0;
            wr_en_output_buffer=1;
          end
          
       FINISHED_LAYER:
        finished_layer = 1;
  endcase
 end
 
 
 // Sending update of pointer for incremental execution
always @(*)
begin
FIFO_TCN_update_pointer=finished_network && EXECUTION_FRAME_BY_FRAME;
end
endmodule
