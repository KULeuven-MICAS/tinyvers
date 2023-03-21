import parameters::*;

// Nonlinear function generator and pooling operation
// Generates a vector of N values with N inputs
module sig_tanh(
   wr_en_ext_lut,
   wr_addr_ext_lut,
   wr_data_ext_lut,
clk, reset,
PRECISION,
NUMBER_OF_ACTIVATION_CYCLES,
SHIFT_FIXED_POINT,
enable_nonlinear_block, // Start execution of Nonlinear function
PADDED_C_X,
type_nonlinear_function, // Type of nonlinear function
input_channel_rd_addr,
input_channel_rd_en,
read_word, // N input values
wr_en_output_buffer_nl,
finished_activation,
wr_addr_nl,
output_word // N output values
);

// Types of Nonlinear function
// RELU=0;
// 1D POOLING=1;

// IO
input clk, reset;
input [1:0] PRECISION;
input enable_nonlinear_block;
input wr_en_ext_lut;
input [LUT_ADDR-1:0]wr_addr_ext_lut;
input signed [LUT_DATA_WIDTH-1:0] wr_data_ext_lut;
input [7:0] SHIFT_FIXED_POINT;
input [15:0] PADDED_C_X;
input [31:0] NUMBER_OF_ACTIVATION_CYCLES; 
input [NUMBER_OF_NONLINEAR_FUNCTIONS_BITS-1:0] type_nonlinear_function;
input signed [INPUT_CHANNEL_DATA_WIDTH-1:0]  read_word[N_DIM_ARRAY-1:0];
output reg [INPUT_CHANNEL_ADDR_SIZE-1:0] input_channel_rd_addr; // Address to be read from the activation memory
output reg input_channel_rd_en; // Enable to read from the activation memory
output reg wr_en_output_buffer_nl;
output reg [INPUT_CHANNEL_ADDR_SIZE-1:0] wr_addr_nl; // Address to write each of the N values retrieved from the PE array
output reg signed [INPUT_CHANNEL_DATA_WIDTH-1:0]  output_word[N_DIM_ARRAY-1:0];
output reg finished_activation;
// gen variables
integer j;
integer i;
integer k;
reg [3:0] state, next_state;
localparam      IDLE=0,
                        ACTIVATION_PRE_READING=1,
                        ACTIVATION_READING=2,
                        ACTIVATION_OPERATION=3,
                        ACTIVATION_WRITING=4;
                        
//number of comparisons
reg signed [INPUT_CHANNEL_DATA_WIDTH-1:0]  read_word_shifted[N_DIM_ARRAY-1:0];
reg [15:0] counter, next_counter;
reg [15:0] counter_row, next_counter_row;
reg [15:0] counter_X_dimension, next_counter_X_dimension;
reg [INPUT_CHANNEL_ADDR_SIZE-1:0] counter_wr_addr, next_counter_wr_addr;
reg signed [INPUT_CHANNEL_DATA_WIDTH-1:0]  output_relu [N_DIM_ARRAY-1:0];
reg signed [INPUT_CHANNEL_DATA_WIDTH-1:0]  output_act [N_DIM_ARRAY-1:0];
reg signed [INPUT_CHANNEL_DATA_WIDTH*2-1:0] MULT_A_X [N_DIM_ARRAY-1:0];
reg signed [INPUT_CHANNEL_DATA_WIDTH*2-1:0] B_SHIFTED  [N_DIM_ARRAY-1:0];
reg enable_relu;
// Nonlinear functions
reg signed [INPUT_CHANNEL_DATA_WIDTH-1:0] LUT[LUT_SIZE-1:0];


reg signed [INPUT_CHANNEL_DATA_WIDTH-1:0] A_sigmoid[7:0];
reg signed [INPUT_CHANNEL_DATA_WIDTH-1:0] B_sigmoid[7:0];
reg signed [INPUT_CHANNEL_DATA_WIDTH-1:0] X_initial_PWS_sigmoid[7:0];
reg signed [INPUT_CHANNEL_DATA_WIDTH-1:0] index_sigmoid[N_DIM_ARRAY-1:0];
reg signed [INPUT_CHANNEL_DATA_WIDTH-1:0] SHIFT_ADDRESS_sigmoid;
reg signed [INPUT_CHANNEL_DATA_WIDTH-1:0] X_MAX_sigmoid;
reg signed  [INPUT_CHANNEL_DATA_WIDTH-1:0] X_MIN_sigmoid;
reg signed [INPUT_CHANNEL_DATA_WIDTH-1:0] Y_MAX_sigmoid;
reg signed  [INPUT_CHANNEL_DATA_WIDTH-1:0] Y_MIN_sigmoid;

reg signed [INPUT_CHANNEL_DATA_WIDTH-1:0] A_tanh[7:0];
reg signed [INPUT_CHANNEL_DATA_WIDTH-1:0] B_tanh[7:0];
reg signed [INPUT_CHANNEL_DATA_WIDTH-1:0] X_initial_PWS_tanh[7:0];
reg signed [INPUT_CHANNEL_DATA_WIDTH-1:0] index_tanh[N_DIM_ARRAY-1:0];
reg signed [INPUT_CHANNEL_DATA_WIDTH-1:0] SHIFT_ADDRESS_tanh;
reg signed [INPUT_CHANNEL_DATA_WIDTH-1:0] X_MAX_tanh;
reg signed  [INPUT_CHANNEL_DATA_WIDTH-1:0] X_MIN_tanh;
reg signed [INPUT_CHANNEL_DATA_WIDTH-1:0] Y_MAX_tanh;
reg signed  [INPUT_CHANNEL_DATA_WIDTH-1:0] Y_MIN_tanh;


reg signed [INPUT_CHANNEL_DATA_WIDTH-1:0] A[7:0];
reg signed [INPUT_CHANNEL_DATA_WIDTH-1:0] B[7:0];
reg signed [INPUT_CHANNEL_DATA_WIDTH-1:0] X_initial_PWS[7:0];
reg signed [INPUT_CHANNEL_DATA_WIDTH-1:0] index[N_DIM_ARRAY-1:0];
reg signed [INPUT_CHANNEL_DATA_WIDTH-1:0] SHIFT_ADDRESS;
reg signed [INPUT_CHANNEL_DATA_WIDTH-1:0] X_MAX;
reg signed  [INPUT_CHANNEL_DATA_WIDTH-1:0] X_MIN;
reg signed [INPUT_CHANNEL_DATA_WIDTH-1:0] Y_MAX;
reg signed  [INPUT_CHANNEL_DATA_WIDTH-1:0] Y_MIN;

assign finished_activation = (counter == (NUMBER_OF_ACTIVATION_CYCLES));

// LUT WRITING
always @(posedge clk or negedge reset)
  begin
    if (!reset)
        for (i=0; i< LUT_SIZE; i=i+1)
          LUT[i] <= 0;
    else
      if (wr_en_ext_lut)
        LUT[wr_addr_ext_lut] <= wr_data_ext_lut;
  end
  
  

// LUT loading
always @(*)
begin
  //sigmoid
  for (i=0; i<LUT_SIZE; i=i+1)
  begin
      //sigmoid
      if (i<8)
        X_initial_PWS_sigmoid[i] = LUT[i];
      else if (i<16)
        A_sigmoid[i-8] = LUT[i];
      else if (i<24)
        B_sigmoid[i-16]=LUT[i];
      else if (i<32)
        X_initial_PWS_sigmoid[i-24] = LUT[i];
      else if (i<40)
        A_sigmoid[i-32] = LUT[i];
      else if (i<48)
        B_sigmoid[i-40]=LUT[i];
        
      else if (i==48)
        SHIFT_ADDRESS_sigmoid = LUT[i];
      else if (i==49)
        X_MIN_sigmoid= LUT[i];
       else if (i==50)
        X_MAX_sigmoid= LUT[i];
      else if (i==51)
        Y_MIN_sigmoid= LUT[i];
       else if (i==52)
        Y_MAX_sigmoid= LUT[i];
        
        
        //tanh
      else if (i<60)
        X_initial_PWS_tanh[i-52] = LUT[i];
      else if (i<68)
        A_tanh[i-60] = LUT[i];
      else if (i<76)
        B_tanh[i-68]=LUT[i];
      else if (i<84)
        X_initial_PWS_tanh[i-76] = LUT[i];
      else if (i<92)
        A_tanh[i-84] = LUT[i];
      else if (i<100)
        B_tanh[i-92]=LUT[i];
        
      else if (i==101)
        SHIFT_ADDRESS_tanh = LUT[i];
      else if (i==102)
        X_MIN_tanh= LUT[i];
       else if (i==103)
        X_MAX_tanh= LUT[i];
      else if (i==104)
        Y_MIN_tanh= LUT[i];
       else if (i==105)
        Y_MAX_tanh= LUT[i];
  end

  
   
end

//next state logic 
always @(posedge clk or negedge reset)
  begin
  if (!reset)
    state <= IDLE;
   else 
   state <= next_state;
  end

 always @(*)
 begin
  next_state = state;

  case(state)
    IDLE:
      if (enable_nonlinear_block)
            case(type_nonlinear_function)
            0:next_state= ACTIVATION_PRE_READING; // RELU
            3: next_state= ACTIVATION_PRE_READING; // SIGMOID
            4: next_state= ACTIVATION_PRE_READING; // TANH
            default: next_state=state;
            endcase
            
    ACTIVATION_PRE_READING:       
          next_state=ACTIVATION_READING;
    ACTIVATION_READING:       
          next_state=ACTIVATION_OPERATION;
   ACTIVATION_OPERATION:
          next_state=ACTIVATION_WRITING;
    ACTIVATION_WRITING:     
      begin
       if (!finished_activation)
          next_state = ACTIVATION_PRE_READING;
      else
          next_state = IDLE;   
      end
   endcase
 end 


//COUNTERs
always @(posedge clk or negedge reset)
begin
    if (!reset)
      begin
      counter <= 0;
      counter_row <= 0;
      counter_X_dimension <= 0;
      counter_wr_addr <=0;
      end
    else
      begin
      counter <= next_counter;
      counter_row <= next_counter_row;
      counter_X_dimension <= next_counter_X_dimension;
      counter_wr_addr <= next_counter_wr_addr;
      end
end

always @(*)
begin
next_counter=counter;
next_counter_row=counter_row;
next_counter_X_dimension = counter_X_dimension;
next_counter_wr_addr = counter_wr_addr;

  case(state)
    IDLE: begin
    next_counter=0;
    next_counter_row= 0;
    next_counter_X_dimension=0;
    next_counter_wr_addr=0;
    end
    ACTIVATION_READING: 
    begin
    next_counter=counter+N_DIM_ARRAY;
    next_counter_row= 0;
    end 
    default: 
    begin 
    next_counter=counter;
    next_counter_row=counter_row;
    end
  endcase
end


//output logic
always @(*)
begin
for (j=0; j < (N_DIM_ARRAY); j=j+1)
output_word[j] = 0;
enable_relu=0;
wr_en_output_buffer_nl=0;
            input_channel_rd_addr =0;
            input_channel_rd_en=0;
            wr_addr_nl =0;
case(state)
        IDLE:
        begin
            wr_en_output_buffer_nl=0;
            input_channel_rd_addr =0;
            input_channel_rd_en=0;
        end
         ACTIVATION_PRE_READING:
          begin
            input_channel_rd_addr =counter;
            input_channel_rd_en=1;
          end
          // ACTIVATION
          ACTIVATION_READING:
          begin
            input_channel_rd_addr =counter;
            input_channel_rd_en=1;
          end
       ACTIVATION_OPERATION:
          begin
            case(type_nonlinear_function)
            0:output_word = output_relu;
            3: output_word = output_act;
            4: output_word = output_act;
            endcase
            enable_relu=1;
            input_channel_rd_addr =counter;
            input_channel_rd_en=0;
          end
          ACTIVATION_WRITING:
          begin
            input_channel_rd_addr =counter;
            input_channel_rd_en=0;
          end
          
 endcase         
end






//RELU
always @(*)
begin
 for( j=0; j<N_DIM_ARRAY; j=j+1)
 output_relu[j] = 0;
   
    //if (enable_relu)
      for( j=0; j<N_DIM_ARRAY; j=j+1)
              if (read_word[j] > 0)
                output_relu[j] = read_word[j];
              else
                output_relu[j] = 0;
end

// Select between sig and tanh
always @(*)
begin
  if (type_nonlinear_function==3) //sigmoid
    begin
      A = A_sigmoid;
      B = B_sigmoid;
      X_initial_PWS= X_initial_PWS_sigmoid;
      SHIFT_ADDRESS=SHIFT_ADDRESS_sigmoid;
      X_MAX = X_MAX_sigmoid;
      X_MIN= X_MIN_sigmoid;
      Y_MAX = Y_MAX_sigmoid;
      Y_MIN=Y_MIN_sigmoid;
    end
  else if (type_nonlinear_function==4) //tanh
    begin
      A = A_tanh;
      B = B_tanh;
      X_initial_PWS= X_initial_PWS_tanh;
      SHIFT_ADDRESS=SHIFT_ADDRESS_tanh;
      X_MAX = X_MAX_tanh;
      X_MIN= X_MIN_tanh;
      Y_MAX = Y_MAX_tanh;
      Y_MIN=Y_MIN_tanh;
    end
  else
    begin
      A = A_sigmoid;
      B = B_sigmoid;
      X_initial_PWS= X_initial_PWS_sigmoid;
      SHIFT_ADDRESS=SHIFT_ADDRESS_sigmoid;
      X_MAX = X_MAX_sigmoid;
      X_MIN= X_MIN_sigmoid;
      Y_MAX = Y_MAX_sigmoid;
      Y_MIN=Y_MIN_sigmoid;
    end

end
//Sigmoid/Tanh processing
always @(*)
begin
       for( j=0; j<N_DIM_ARRAY; j=j+1)
        index[j] =0;
        
       for( j=0; j<N_DIM_ARRAY; j=j+1)
                begin
                //default values
                  //////////////////
                read_word_shifted[j] = read_word[j] >> SHIFT_ADDRESS;
                for( i=0; i<8; i=i+1)
                    if (read_word_shifted[j]== (X_initial_PWS[i]>> SHIFT_ADDRESS) )
                      index[j] =i;
                      
                if (read_word[j] <= X_MIN)
                  output_act[j] = Y_MIN;
                else if (read_word[j] >= X_MAX)
                  output_act[j] = Y_MAX;
                else
                  begin
                  MULT_A_X[j]= A[index[j]]*read_word[j];
                  B_SHIFTED[j] = ({{INPUT_CHANNEL_DATA_WIDTH{B[index[j]][INPUT_CHANNEL_DATA_WIDTH-1]}},{B[index[j]]}})<< SHIFT_FIXED_POINT;
                  output_act[j] = ((MULT_A_X[j])+ (B_SHIFTED[j]))>> SHIFT_FIXED_POINT;
                  end
                end
end


endmodule
