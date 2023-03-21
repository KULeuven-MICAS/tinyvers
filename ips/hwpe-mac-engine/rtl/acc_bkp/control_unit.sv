import parameters::*;

module control_unit 
(
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
  NUMBER_OF_ACTIVATION_CYCLES,
  SHIFT_FIXED_POINT,
  INPUT_TILE_SIZE,
  WEIGHT_TILE_SIZE,
  NB_INPUT_TILE,
  NB_WEIGHT_TILE,
  SPARSITY,
  FIFO_TCN_offset,
  FIFO_TCN_update_pointer,
  FIFO_TCN_total_blocks,
  FIFO_TCN_block_size,
  PADDED_C_X,
  mode
);

//IO
input clk, reset, enable;
input EXECUTION_FRAME_BY_FRAME;
input finished_activation;
input  [INSTRUCTION_MEMORY_WIDTH-1:0] instruction[INSTRUCTION_MEMORY_FIELDS-1:0];
input wr_en_ext_sparsity; // Writing to sparsity memory
input [BIT_WIDTH_EXTERNAL_PORT-1:0] wr_addr_ext_sparsity;
input [BIT_WIDTH_EXTERNAL_PORT-1:0] wr_data_ext_sparsity;
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
output reg FIFO_TCN_update_pointer;
output reg [INPUT_CHANNEL_ADDR_SIZE-1:0]  FIFO_TCN_block_size;
output reg [INPUT_CHANNEL_ADDR_SIZE-1:0]  FIFO_TCN_offset;
output reg [INPUT_CHANNEL_ADDR_SIZE-1:0]  FIFO_TCN_total_blocks;
output reg [15:0] NUMBER_OF_ACTIVATION_CYCLES;
output reg [15:0] INPUT_TILE_SIZE;
output reg [15:0] WEIGHT_TILE_SIZE;
output reg [7:0] NB_INPUT_TILE;
output reg [7:0] NB_WEIGHT_TILE;
output reg [31:0] PADDED_C_X;
output reg SPARSITY;
output reg enable_pooling;
output reg enable_sig_tanh;
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
                        STR_SPARSITY=23;
                        
// Low Level Configuration Registers
// counters
  // Higher than 16 bits
  wire [INPUT_CHANNEL_ADDR_SIZE-1:0] CONF_INPUT_MEMORY_POINTER;
  wire [INPUT_CHANNEL_ADDR_SIZE-1:0] CONF_OUTPUT_MEMORY_POINTER;
  
  // 16 bits
  wire  [15:0] CONF_C;    // Structural Sparsity FC    
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
  wire [7:0] CONF_NB_INPUT_TILE;
  wire [7:0] CONF_NB_WEIGHT_TILE;
  //4 bits
  wire [3:0] CONF_TYPE_NONLINEAR_FUNCTION;
  wire [3:0] CONF_MODE;
  wire [3:0] CONF_ACTIVATION_FUNCTION;
  // 1 bit
  wire [0:0]  CONF_STOP;
  wire [0:0] CONF_CAUSAL_CONVOLUTION;

  
  

//gen vars
//reg  signed [INSTRUCTION_MEMORY_WIDTH-1:0] im_file  [0:INSTRUCTION_MEMORY_SIZE*INSTRUCTION_MEMORY_FIELDS-1];


integer i;
integer j;
integer k;
integer l;
integer sp;


// structural sparsity
reg [9:0] sparsity[0: STR_SP_MEMORY_SIZE-1];

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
assign   CONF_NULL = instruction[22];
assign   CONF_STOP = instruction[23];
assign   CONF_SHIFT_FIXED_POINT = instruction[24];
assign   CONF_CAUSAL_CONVOLUTION= instruction[25];
assign   CONF_TYPE_NONLINEAR_FUNCTION=instruction[26];
assign   CONF_NB_INPUT_TILE=instruction[27];
assign   CONF_NB_WEIGHT_TILE=instruction[28];

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

//SPARSITY MEMORY FILLING
always @(posedge clk or negedge reset)
begin
    if (!reset)
     begin
      for (i=0; i<STR_SP_MEMORY_SIZE; i=i+1)
       sparsity[i]<=0;
      end 
    else
     begin 
      if (wr_en_ext_sparsity)
       sparsity[wr_addr_ext_sparsity] <= wr_data_ext_sparsity;
     end
end


///////////////////////////// LOW LEVEL FSM /////////////////////////////////////////////////////////////////////////////////////////////////////

// Signals to acknowledge the end of a loop
always @(*)
begin
CNN_FINISHED_FX_LOOP =  (counter_FX == (CONF_FX-1));
CNN_FINISHED_FY_LOOP=(counter_FY == (CONF_FY-1));    
CNN_FINISHED_C_LOOP=(counter_C == (CONF_C-1));
CNN_FINISHED_K_LOOP=(counter_K == (CONF_K-1));
CNN_FINISHED_X_LOOP=(counter_X == (CONF_O_X-1));
CNN_FINISHED_Y_LOOP=(counter_Y == ((CONF_O_Y-1)));
FC_FINISHED_K_LOOP=(counter_K == (CONF_K-1));
EWS_FINISHED = (counter_C == ((CONF_C)));
ACCUMULATION_PES_FINISHED = (counter_accumulation_pes == (N_DIM_ARRAY-1));

// Execution frame by frame
if ((CONF_TCN_BLOCK_SIZE!=0) && (EXECUTION_FRAME_BY_FRAME==1)) //if execution frame by frame is activated and tcn block size is different to 1
  FC_FINISHED_C_LOOP=(counter_C == ((CONF_C)-(((CONF_TCN_BLOCK_SIZE)*CONF_DILATION)-1)));
else
  FC_FINISHED_C_LOOP = (counter_C == ((CONF_C)-CONF_DILATION));
  
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
    end
   else
   begin
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
   end 
end




 //update counters
 always @(*)
 begin
  //default
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
      number_ones=0;
      sparse_val = sparsity[counter_K>>BLOCK_SPARSE];
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
      sparse_val = sparsity[counter_K>>BLOCK_SPARSE];
      number_ones = 0;
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
      if (sparsity[counter_K>>BLOCK_SPARSE][counter_C] == 1)
       begin
        if (sparsity[counter_K>>BLOCK_SPARSE][counter_C+1] == 1) begin
         for (sp=1; sp<10; sp=sp+1)
          begin
            if (sparse_val[sp] == 1  && sparse_val[sp-1] == 1) 
              begin
                //next_counter_sparsity = next_counter_sparsity + 1;
                // BUG FOUND
                //number_ones = number_ones + 1;
                number_ones = 1;
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
        if (CNN_FINISHED_FX_LOOP & CNN_FINISHED_FY_LOOP & CNN_FINISHED_C_LOOP)
          begin
           next_counter_X = counter_X;
           next_counter_Y = counter_Y;
           next_counter_FX =  0;
           next_counter_offset_input_channel=counter_offset_input_channel;
           // BUG FIX
           //counter_C = 0;
           next_counter_C = 0;
           next_counter_sparsity = 0;
           next_counter_accumulation_pes= counter_accumulation_pes;
           next_counter_weight_address =counter_weight_address;
           next_counter_input_channel_address = counter_offset_input_channel;
           next_counter_FY = 0;
           next_counter_K = counter_K +1;
           sparse_val = sparsity[counter_K>>BLOCK_SPARSE];

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
           next_counter_input_channel_address =counter_offset_input_channel + counter_current_channel_address + ((CONF_SIZE_CHANNEL)*(next_counter_C));
           next_counter_current_channel_address =counter_current_channel_address + ((CONF_SIZE_CHANNEL)*(next_counter_C));
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
      //next_counter_sparsity = 0;
      SPARSITY_SET = 0;
      //sparse_val = sparse_val >> (counter_sparsity + 1);
      number_ones = 0;
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
      //next_counter_sparsity = 0;
      SPARSITY_SET = 0;
      //sparse_val = sparse_val >> (counter_sparsity + 1);
      number_ones = 0;
      end 
      

      
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
      next_counter_input_channel_address = counter_input_channel_address +CONF_DILATION ;
      next_counter_FY = counter_FY;
      next_counter_K = counter_K;
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
      next_counter_input_channel_address = counter_input_channel_address +CONF_DILATION+N_DIM_ARRAY;
      next_counter_FY = counter_FY;
      next_counter_K = counter_K;
      end 
      CONV_MAC: // MAC operation
      begin
      
      // If  the whole input map has been processed
      if (CNN_FINISHED_FX_LOOP & CNN_FINISHED_FY_LOOP & CNN_FINISHED_C_LOOP & CNN_FINISHED_K_LOOP & CNN_FINISHED_X_LOOP & CNN_FINISHED_Y_LOOP)
      begin
                            next_counter_X = counter_X;
                            next_counter_Y = counter_Y+1;
                            next_counter_FX = 0;
                            next_counter_offset_input_channel=0;
                            next_counter_C = 0;
                            next_counter_accumulation_pes=counter_accumulation_pes;
                            next_counter_weight_address =0;
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
                            next_counter_offset_input_channel =counter_offset_input_channel + 8; // It adds 8 for getting the next row
                            next_counter_C = 0 ;
                            next_counter_accumulation_pes=counter_accumulation_pes;
                            next_counter_weight_address =0;
                            next_counter_input_channel_address =counter_offset_input_channel + 8;  // It adds 8 for getting the next row
                            next_counter_FY = 0;
                            next_counter_K =0 ; 
      end
      
      // If all the filters of a patch have been processed
      else if (CNN_FINISHED_FX_LOOP & CNN_FINISHED_FY_LOOP & CNN_FINISHED_C_LOOP & CNN_FINISHED_K_LOOP)
      begin
                            next_counter_X =counter_X+1 ;
                            next_counter_Y =counter_Y ;
                            next_counter_FX = 0;
                            next_counter_offset_input_channel=counter_offset_input_channel + (N_DIM_ARRAY);
                            next_counter_C = 0;
                            next_counter_accumulation_pes=counter_accumulation_pes;
                            next_counter_weight_address =0;
                            next_counter_input_channel_address =counter_offset_input_channel + (N_DIM_ARRAY) ;
                            next_counter_FY = 0;
                            next_counter_K = 0;  
                            
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
                            next_counter_input_channel_address =counter_offset_input_channel + counter_current_channel_address + (CONF_SIZE_CHANNEL);
                            next_counter_current_channel_address =counter_current_channel_address + (CONF_SIZE_CHANNEL);
                            next_counter_FY =0 ;
                            next_counter_K = counter_K;  
                            next_counter_sparsity = 0;
                            
                            // BUG FOUND
                            sparse_val = sparse_val >> (next_counter_sparsity + 1);

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
                            next_counter_weight_address =counter_weight_address;
                            next_counter_input_channel_address =counter_input_channel_address + (CONF_PADDED_C_X  - CONF_FX -N_DIM_ARRAY) ;
                            next_counter_FY = counter_FY+1;
                            next_counter_K = counter_K;  
                           
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
                            next_counter_weight_address =counter_weight_address+1;
                            next_counter_input_channel_address =counter_input_channel_address + CONF_DILATION;
                            next_counter_FY =counter_FY ;
                            next_counter_K = counter_K;  
                           
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
     CONV_ADD_BIAS:
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
        next_counter_FY = 0;
        next_counter_K = counter_K;
        if (counter_K==0) //  if all the K kernels have finished
            next_counter_output_channel_address = counter_output_channel_address+1;
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
        next_counter_FY = 0;
        next_counter_K = counter_K;
        if (counter_K==0)  //if all the K kernels have finished
            next_counter_output_channel_address = counter_output_channel_address+1;
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
        next_counter_FY = 0;
        next_counter_K = counter_K;
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
      
       // If execution frame by frame is asserted, use the counter X to iterate over each sub-vector and C to save the current address of the vector    
      if (!EXECUTION_FRAME_BY_FRAME)
        begin
            next_counter_X= 0;
            next_counter_C = counter_C+1;
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
      
      
      //Counter X logic
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
        next_counter_C = counter_C+1;
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
                    MODE_FC: next_state=   FC_PRE_MAC;
                    default: next_state =INITIAL;
                  endcase
         end     
         else
              next_state =INITIAL;
      end

   STR_SPARSITY:
     begin
      //if (SPARSITY_SET == 0)
       if (CONF_CAUSAL_CONVOLUTION==0)
        next_state=   CONV_FILLING_INPUT_FIFO;
       else
        next_state=   CONV_PADDING_FILLING_INPUT_FIFO;
      //else
       //next_state = state;//CONV_MAC;
     end        
              
    CONV_PADDING_FILLING_INPUT_FIFO: //Delay to fill the fifo with 0s
     begin
        next_state = CONV_PRE_MAC;
     end 
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
            next_state = CONV_ADD_BIAS; 
          else
         // If the FX loop is finished only
            if (CNN_FINISHED_FX_LOOP)
              if (sparsity[counter_K>>BLOCK_SPARSE][counter_C+1] == 1)
                next_state = STR_SPARSITY;
              else
                next_state = CONV_PRE_MAC_2;
            else
              next_state=state;
      end
      
     CONV_ADD_BIAS: // Add bias
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
                if (sparsity[counter_K>>BLOCK_SPARSE][counter_C] == 0 || CONF_STR_SPARSITY == 0)   
                  if (CONF_CAUSAL_CONVOLUTION==0)  // Initiate new round of convolutions
                  next_state= CONV_FILLING_INPUT_FIFO;
                  else
                  next_state= CONV_PADDING_FILLING_INPUT_FIFO; 
                else
                  next_state= STR_SPARSITY;
      end
 
 //FC       
     FC_PRE_MAC: // Initiate the request of data from Weight and activation memory
     begin
      next_state = FC_MAC;
     end
     
    FC_MAC: // Run the MAC operations
      begin
        if (FC_FINISHED_C_LOOP)
          next_state = FC_PRE_ACCUMULATE_MACS;
        else
          next_state=state;
      end
  
  // Accumulate values between PEs
     FC_PRE_ACCUMULATE_MACS:
      begin
            next_state= FC_ACCUMULATE_MACS;
      end
      
     FC_ACCUMULATE_MACS:
      begin
        if (counter_accumulation_pes !=  ((N_DIM_ARRAY-1)-1))
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
          next_state = FC_PRE_MAC;
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
  PADDED_C_X=CONF_PADDED_C_X;
  NUMBER_OF_ACTIVATION_CYCLES=CONF_C;
  INPUT_TILE_SIZE=CONF_SIZE_CHANNEL;
  WEIGHT_TILE_SIZE=(CONF_FX*CONF_FY*CONF_C*CONF_K) + CONF_K;
  NB_INPUT_TILE=CONF_NB_INPUT_TILE;
  NB_WEIGHT_TILE=CONF_NB_WEIGHT_TILE;
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
  for (i=0; i<(N_DIM_ARRAY); i=i+1) 
    for (j=0; j < (N_DIM_ARRAY); j=j+1) 
      CR_PE_array[i][j] = 13'b000000000010;
  case(state)
  
  /////////////////////
    INITIAL:    
          begin
          enable_input_fifo=0;
          loading_in_parallel=0;
          clear = 0;
          enable_pe_array=0;
          for (i=0; i<(N_DIM_ARRAY); i=i+1) 
            for (j=0; j < (N_DIM_ARRAY); j=j+1) 
              CR_PE_array[i][j] =13'b00000010;
          input_channel_rd_addr =0 ;
          input_channel_rd_en=0;
          weight_rd_addr=0;
          weight_rd_en=0;
          wr_en_output_buffer=0;
          end

    STR_SPARSITY:
          begin
          enable_input_fifo=0;
          loading_in_parallel=0;
          clear = 0;
          enable_pe_array=0;
          for (i=0; i<(N_DIM_ARRAY); i=i+1)
            for (j=0; j < (N_DIM_ARRAY); j=j+1)
              CR_PE_array[i][j] = 13'b00000010;
          input_channel_rd_addr =0 ;
          input_channel_rd_en=0;
          weight_rd_addr=0;
          weight_rd_en=0;
          wr_en_output_buffer=0;
          end
      
     //cnn 
    CONV_FILLING_INPUT_FIFO:    
          begin
          enable_input_fifo=0;
          loading_in_parallel=1;
          clear = 0;
          enable_pe_array=1;
          for (i=0; i<(N_DIM_ARRAY); i=i+1) 
            for (j=0; j < (N_DIM_ARRAY); j=j+1) 
              CR_PE_array[i][j] = 13'b00000010;
          input_channel_rd_addr =counter_input_channel_address ;
          input_channel_rd_en=1;
          weight_rd_addr=counter_weight_address;
          weight_rd_en=0;
          wr_en_output_buffer=0;
          end       
    CONV_PADDING_FILLING_INPUT_FIFO:    
          begin
          enable_input_fifo=0;
          loading_in_parallel=0;
          clear = 1;
          enable_pe_array=0;
          for (i=0; i<(N_DIM_ARRAY); i=i+1) 
            for (j=0; j < (N_DIM_ARRAY); j=j+1) 
              CR_PE_array[i][j] = 13'b00000010;
          input_channel_rd_addr =counter_input_channel_address ;
          input_channel_rd_en=1;
          weight_rd_addr=counter_weight_address;
          weight_rd_en=0;
          wr_en_output_buffer=0; 
          end       
          
    CONV_PRE_MAC:
          begin
          loading_in_parallel=0;
          enable_input_fifo=1;
          clear = 0;
          enable_pe_array=1;
          for (i=0; i<(N_DIM_ARRAY); i=i+1) 
            for (j=0; j < (N_DIM_ARRAY); j=j+1) 
              CR_PE_array[i][j] = 13'b00000010;
          input_channel_rd_addr =counter_input_channel_address;
          input_channel_rd_en=1;
          weight_rd_addr=counter_weight_address;
          weight_rd_en=1;
          wr_en_output_buffer=0;
          end
          
    CONV_PRE_MAC_2:
          begin
          loading_in_parallel=0;
          enable_input_fifo=1;
          clear = 0;
          enable_pe_array=1;
          for (i=0; i<(N_DIM_ARRAY); i=i+1) 
            for (j=0; j < (N_DIM_ARRAY); j=j+1) 
              CR_PE_array[i][j] = 13'b00000010;
          // Take into account the N_DIM_ARRAY elements loaded at the end of CONV_MAC state
          input_channel_rd_addr =counter_input_channel_address+N_DIM_ARRAY;
          input_channel_rd_en=1;
          weight_rd_addr=counter_weight_address;
          weight_rd_en=1;
          wr_en_output_buffer=0;
          end 

      CONV_MAC:
          begin
          
          clear = 0;
          enable_pe_array=1;
          weight_rd_addr=counter_weight_address;    
          for (i=0; i<(N_DIM_ARRAY); i=i+1) 
            for (j=0; j < (N_DIM_ARRAY); j=j+1) 
              CR_PE_array[i][j] = 13'b00100000;
          // If there is the need to load a new word
          if (counter_input_buffer_loading != ((CONF_FX-1)-1))
          begin
          input_channel_rd_addr =counter_input_channel_address;
          input_channel_rd_en=1;
          end 
          else
          begin
          input_channel_rd_addr =0;
          input_channel_rd_en=0;
          end
          
          // If this cycle is the last mac, don't retrieve data from weight memory and load a new vector for CNN processing
          if (next_state == CONV_PRE_MAC_2)
            begin
                weight_rd_en=0;
                input_channel_rd_addr =next_counter_input_channel_address;
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
              CR_PE_array[i][j] = 13'b101100000;
          input_channel_rd_addr =counter_input_channel_address;
          input_channel_rd_en=0;
          weight_rd_addr=counter_weight_address;
          weight_rd_en=1;
          wr_en_output_buffer=0;
          end     
     
     CONV_PRE_PASSING_OUTPUTS_VERTICAL:
          begin
          loading_in_parallel=0;
          enable_input_fifo=0;
          clear = 0;
          enable_pe_array=1;
          for (i=0; i<(N_DIM_ARRAY); i=i+1) 
            for (j=0; j < (N_DIM_ARRAY); j=j+1) 
              if (CONF_ACTIVATION_FUNCTION==1) // IF RELU
              CR_PE_array[i][j] = 13'b0000_0110;
              else
              CR_PE_array[i][j] = 13'b0000_0010;
          input_channel_rd_addr =counter_input_channel_address ;
          input_channel_rd_en=0;
          weight_rd_addr=counter_weight_address;
          weight_rd_en=0;
          
          // If all the filters have been processed
          if (counter_K ==0)
            wr_addr = ((counter_output_channel_address + counter_accumulation_pes*CONF_OUTPUT_CHANNEL_SIZE + ((CONF_K-1)* (CONF_OUTPUT_CHANNEL_SIZE)<<(N_DIM_ARRAY_LOG)))>> (N_DIM_ARRAY_LOG));
            else
            wr_addr= ((counter_output_channel_address + counter_accumulation_pes*CONF_OUTPUT_CHANNEL_SIZE  + ((counter_K-1)* (CONF_OUTPUT_CHANNEL_SIZE)<<(N_DIM_ARRAY_LOG))) >> (N_DIM_ARRAY_LOG));
  
          wr_en_output_buffer=1;
          end     
          
          
    CONV_PASSING_OUTPUTS_VERTICAL:
          begin
          loading_in_parallel=0;
          enable_input_fifo=0;
          clear = 0;
          enable_pe_array=1;
          for (i=0; i<(N_DIM_ARRAY); i=i+1) 
            for (j=0; j < (N_DIM_ARRAY); j=j+1) 
              if (CONF_ACTIVATION_FUNCTION==1) // IF RELU
              CR_PE_array[i][j] = 13'b1000_0000_0110;
              else
              CR_PE_array[i][j] = 13'b1000_0000_0010;
          input_channel_rd_addr =counter_input_channel_address ;
          input_channel_rd_en=0;
          weight_rd_addr=counter_weight_address;
          weight_rd_en=0;
          
           // If all the filters have been processed
          if (counter_K ==0)
             wr_addr =((counter_output_channel_address + counter_accumulation_pes*CONF_OUTPUT_CHANNEL_SIZE + ((CONF_K-1)* (CONF_OUTPUT_CHANNEL_SIZE)<<(N_DIM_ARRAY_LOG)))>> (N_DIM_ARRAY_LOG)); 
            else
             wr_addr = ((counter_output_channel_address + counter_accumulation_pes*CONF_OUTPUT_CHANNEL_SIZE  + ((counter_K-1)* (CONF_OUTPUT_CHANNEL_SIZE)<<(N_DIM_ARRAY_LOG))) >> (N_DIM_ARRAY_LOG));
             
          wr_en_output_buffer=1;
          end
     
     
     CONV_CLEAR_MAC:
          begin
          loading_in_parallel=0;
          enable_input_fifo=0;
          clear = 1;
          enable_pe_array=1;
           for (i=0; i<(N_DIM_ARRAY); i=i+1) 
            for (j=0; j < (N_DIM_ARRAY); j=j+1) 
              CR_PE_array[i][j] = 13'b00000010;
          input_channel_rd_addr =counter_input_channel_address;
          input_channel_rd_en=0;
          weight_rd_addr=counter_weight_address;
          weight_rd_en=0;
          wr_en_output_buffer=0;
          end     
       // FC    
    
       
       FC_PRE_MAC:
          begin
          clear = 1;
          enable_pe_array=1;
          for (i=0; i<(N_DIM_ARRAY); i=i+1) 
            for (j=0; j < (N_DIM_ARRAY); j=j+1) 
              CR_PE_array[i][j] = 13'b00000010;
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
          for (i=0; i<(N_DIM_ARRAY); i=i+1) 
            for (j=0; j < (N_DIM_ARRAY); j=j+1) 
              CR_PE_array[i][j] = 13'b00100000;
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
          for (i=0; i<(N_DIM_ARRAY); i=i+1) 
            for (j=0; j < (N_DIM_ARRAY); j=j+1) 
              if (j== 0)
                CR_PE_array[i][j] =13'b00100001;
              else
                  CR_PE_array[i][j] =13'b1000001000; 
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
          for (i=0; i<(N_DIM_ARRAY); i=i+1) 
            for (j=0; j < (N_DIM_ARRAY); j=j+1) 
              if (j== 0)
                CR_PE_array[i][j] =13'b00100001;
              else
                  CR_PE_array[i][j] =13'b1000001000; 

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
          for (i=0; i<(N_DIM_ARRAY); i=i+1) 
            for (j=0; j < (N_DIM_ARRAY); j=j+1) 
              CR_PE_array[i][j] = 13'b00100000;
          input_channel_rd_addr =counter_C;
          input_channel_rd_en=0;
          weight_rd_addr=counter_weight_address;
          weight_rd_en=1;
          wr_en_output_buffer=0;
          enable_input_fifo=0;
          loading_in_parallel=0;
          end  
          
    FC_BIAS:
          begin
          clear = 0;
          enable_pe_array=1;
          for (i=0; i<(N_DIM_ARRAY); i=i+1) 
            for (j=0; j < (N_DIM_ARRAY); j=j+1) 
              if (j == 0)
                CR_PE_array[i][j] =13'b101100000;
              else
                CR_PE_array[i][j]= 13'b00000010;
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
          clear = 0;
          enable_pe_array=1;
          for (i=0; i<(N_DIM_ARRAY); i=i+1) 
            for (j=0; j < (N_DIM_ARRAY); j=j+1) 
              CR_PE_array[i][j] =13'b00000010;
          input_channel_rd_addr =counter_C ;
          input_channel_rd_en=0;
          weight_rd_addr=counter_weight_address;
          weight_rd_en=0;
          wr_en_output_buffer=1;
          
          enable_input_fifo=0;
          loading_in_parallel=0;
          
          wr_addr = counter_K;
              
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
                CR_PE_array[0][i] =13'b0_0000_0000_0010;
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
                CR_PE_array[0][i] =13'b1_0000_0010_0000;
                
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
                CR_PE_array[0][i] =13'b1_0000_0010_0000;
            end
            else //If it is a element wise multiplication
            begin
            for (i=0; i<(N_DIM_ARRAY); i=i+1) 
                CR_PE_array[0][i] =13'b0_0000_1001_0000;
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
                CR_PE_array[0][i] =13'b00000010;
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
