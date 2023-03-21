import parameters::*;

// Nonlinear function generator and pooling operation
// Generates a vector of N values with N inputs
module pooling(
clk, reset,
NUMBER_OF_ACTIVATION_CYCLES,
PRECISION,
SHIFT_FIXED_POINT,
enable_nonlinear_block, // Start execution of Nonlinear function
PADDED_C_X,
PADDED_O_X,
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
input [7:0] SHIFT_FIXED_POINT;
input [15:0] PADDED_C_X;
input [15:0] PADDED_O_X;
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
                        POOLING_1D_PRE_READING=5,
                        POOLING_1D_READING=6,
                        POOLING_1D_OPERATION=7,
                        POOLING_1D_WRITING=8,
                        POOLING_2D_PRE_READING=9,
                        POOLING_2D_READING_1=10,
                        POOLING_2D_OPERATION=11,
                        POOLING_2D_WRITING=12;
                        
//number of comparisons
reg signed [INPUT_CHANNEL_DATA_WIDTH-1:0] max_value [(N_DIM_ARRAY-1):0];
reg signed [INPUT_CHANNEL_DATA_WIDTH-1:0] max_value_1d[N_DIM_ARRAY/4-1:0];
reg signed [INPUT_CHANNEL_DATA_WIDTH-1:0]  max_value_2d [N_DIM_ARRAY/2-1:0];
reg [15:0] counter, next_counter;
reg [15:0] counter_row, next_counter_row;
reg [15:0] counter_X_dimension, next_counter_X_dimension;
reg [INPUT_CHANNEL_ADDR_SIZE-1:0] counter_wr_addr, next_counter_wr_addr;
reg signed [INPUT_CHANNEL_DATA_WIDTH-1:0] pooling_calculation [(N_DIM_ARRAY-1):0];
reg signed [INPUT_CHANNEL_DATA_WIDTH-1:0] next_pooling_calculation [(N_DIM_ARRAY-1):0]; 
reg signed [INPUT_CHANNEL_DATA_WIDTH-1:0]  input_0[N_DIM_ARRAY-1:0], next_input_0[N_DIM_ARRAY-1:0];
reg signed [INPUT_CHANNEL_DATA_WIDTH-1:0]  input_1[N_DIM_ARRAY-1:0], next_input_1[N_DIM_ARRAY-1:0];
wire FINISHED_ROW_1D, FINISHED_ROW_2D;
reg enable_pooling_1d;
reg enable_pooling_2d;
reg signed [INPUT_CHANNEL_DATA_WIDTH-1:0]  input_pooling[N_DIM_ARRAY-1:0];
reg signed [INPUT_CHANNEL_DATA_WIDTH/2-1:0]  input_pooling_subword_0[N_DIM_ARRAY-1:0];
reg signed [INPUT_CHANNEL_DATA_WIDTH/2-1:0]  input_pooling_subword_1[N_DIM_ARRAY-1:0];
reg signed [INPUT_CHANNEL_DATA_WIDTH/2-1:0]  input_0_subword_0  [N_DIM_ARRAY-1:0];
reg signed [INPUT_CHANNEL_DATA_WIDTH/2-1:0]  input_0_subword_1  [N_DIM_ARRAY-1:0];
reg signed [INPUT_CHANNEL_DATA_WIDTH/2-1:0]  read_word_subword_0[N_DIM_ARRAY-1:0];
reg signed [INPUT_CHANNEL_DATA_WIDTH/2-1:0]  read_word_subword_1[N_DIM_ARRAY-1:0];
reg signed [INPUT_CHANNEL_DATA_WIDTH/2-1:0]  max_value_2d_subword_0[N_DIM_ARRAY/2-1:0];
reg signed [INPUT_CHANNEL_DATA_WIDTH/2-1:0]  max_value_2d_subword_1[N_DIM_ARRAY/2-1:0];
reg signed [INPUT_CHANNEL_DATA_WIDTH/2-1:0] max_value_1d_subword_0[N_DIM_ARRAY/4-1:0];
reg signed [INPUT_CHANNEL_DATA_WIDTH/2-1:0] max_value_1d_subword_1[N_DIM_ARRAY/4-1:0];

reg signed [INPUT_CHANNEL_DATA_WIDTH/4-1:0]  max_value_2d_subword_0_0[N_DIM_ARRAY/2-1:0];
reg signed [INPUT_CHANNEL_DATA_WIDTH/4-1:0]  max_value_2d_subword_0_1[N_DIM_ARRAY/2-1:0];
reg signed [INPUT_CHANNEL_DATA_WIDTH/4-1:0]  max_value_2d_subword_1_0[N_DIM_ARRAY/2-1:0];
reg signed [INPUT_CHANNEL_DATA_WIDTH/4-1:0]  max_value_2d_subword_1_1[N_DIM_ARRAY/2-1:0];

reg signed [INPUT_CHANNEL_DATA_WIDTH/4-1:0] max_value_1d_subword_0_0[N_DIM_ARRAY/4-1:0];
reg signed [INPUT_CHANNEL_DATA_WIDTH/4-1:0] max_value_1d_subword_0_1[N_DIM_ARRAY/4-1:0]; 
reg signed [INPUT_CHANNEL_DATA_WIDTH/4-1:0] max_value_1d_subword_1_0[N_DIM_ARRAY/4-1:0];
reg signed [INPUT_CHANNEL_DATA_WIDTH/4-1:0] max_value_1d_subword_1_1[N_DIM_ARRAY/4-1:0]; 

reg signed [INPUT_CHANNEL_DATA_WIDTH/4-1:0]  input_pooling_subword_0_0[N_DIM_ARRAY-1:0];
reg signed [INPUT_CHANNEL_DATA_WIDTH/4-1:0]  input_pooling_subword_0_1[N_DIM_ARRAY-1:0];
reg signed [INPUT_CHANNEL_DATA_WIDTH/4-1:0]  input_pooling_subword_1_0[N_DIM_ARRAY-1:0];
reg signed [INPUT_CHANNEL_DATA_WIDTH/4-1:0]  input_pooling_subword_1_1[N_DIM_ARRAY-1:0];
reg signed [INPUT_CHANNEL_DATA_WIDTH/4-1:0]  input_0_subword_0_0  [N_DIM_ARRAY-1:0];
reg signed [INPUT_CHANNEL_DATA_WIDTH/4-1:0]  input_0_subword_0_1  [N_DIM_ARRAY-1:0];
reg signed [INPUT_CHANNEL_DATA_WIDTH/4-1:0]  input_0_subword_1_0  [N_DIM_ARRAY-1:0];
reg signed [INPUT_CHANNEL_DATA_WIDTH/4-1:0]  input_0_subword_1_1  [N_DIM_ARRAY-1:0];
reg signed [INPUT_CHANNEL_DATA_WIDTH/4-1:0]  read_word_subword_0_0[N_DIM_ARRAY-1:0];
reg signed [INPUT_CHANNEL_DATA_WIDTH/4-1:0]  read_word_subword_0_1[N_DIM_ARRAY-1:0]; 
reg signed [INPUT_CHANNEL_DATA_WIDTH/4-1:0]  read_word_subword_1_0[N_DIM_ARRAY-1:0];
reg signed [INPUT_CHANNEL_DATA_WIDTH/4-1:0]  read_word_subword_1_1[N_DIM_ARRAY-1:0]; 


assign finished_activation = (counter == (NUMBER_OF_ACTIVATION_CYCLES));
// BUG FIXING SEBASTIAN MAY 28, 2020 1D POOLING WAS NOT WORKING
assign FINISHED_ROW_1D = (counter_row == (4-1));
assign FINISHED_ROW_2D =  (counter_row == (2-1));


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
            1:next_state = POOLING_1D_PRE_READING; //pool 1d
            2: next_state = POOLING_2D_PRE_READING; // pool 2d
            default: next_state=state;
            endcase
           
    POOLING_1D_PRE_READING:       
        //if (enable_nonlinear_block)
          next_state=POOLING_1D_READING;
    POOLING_1D_READING:       
        //if (enable_nonlinear_block)
          next_state=POOLING_1D_OPERATION;
   POOLING_1D_OPERATION:
        //if (enable_nonlinear_block)
          begin
           if (FINISHED_ROW_1D==1)
            next_state=POOLING_1D_WRITING;
           else
            next_state = POOLING_1D_PRE_READING;
          end
    POOLING_1D_WRITING:     
       //if (enable_nonlinear_block)
       begin
       if (!finished_activation)
          next_state = POOLING_1D_PRE_READING;         
       else
          next_state = IDLE;   
        end
   
   
    POOLING_2D_PRE_READING:       
          next_state=POOLING_2D_READING_1;
    POOLING_2D_READING_1:       
          next_state=POOLING_2D_OPERATION;
   POOLING_2D_OPERATION:
        //if (enable_nonlinear_block)
          begin
           if (FINISHED_ROW_2D==1)
            next_state=POOLING_2D_WRITING;
           else
            next_state = POOLING_2D_PRE_READING;
          end
    POOLING_2D_WRITING:     
       //if (enable_nonlinear_block)
       begin
       if (!finished_activation)
          next_state = POOLING_2D_PRE_READING;         
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
      for (j=0; j < (N_DIM_ARRAY); j=j+1)
      input_0[j]<=0;
      for (j=0; j < (N_DIM_ARRAY); j=j+1)
      input_1[j] <= 0;
      end
    else
      begin
      counter <= next_counter;
      counter_row <= next_counter_row;
      counter_X_dimension <= next_counter_X_dimension;
      counter_wr_addr <= next_counter_wr_addr;
      input_0<=next_input_0;
      input_1 <= next_input_1;
      end
end

always @(*)
begin
next_counter=counter;
next_counter_row=counter_row;
next_counter_X_dimension = counter_X_dimension;
next_input_0=input_0;
next_input_1 =input_1;
next_counter_wr_addr = counter_wr_addr;

  case(state)
    IDLE: begin
    next_counter=0;
    next_counter_row= 0;
    next_counter_X_dimension=0;
    for (j=0; j < (N_DIM_ARRAY); j=j+1)
      next_input_0[j]=0;
      for (j=0; j < (N_DIM_ARRAY); j=j+1)
      next_input_1[j] = 0;
    next_counter_wr_addr=0;
    end
    
    
    POOLING_1D_READING:
    begin
    next_input_0=read_word;
    
    end
    POOLING_1D_OPERATION: 
    begin
    //next_counter=counter+ N_DIM_ARRAY;
    // BUG FIXING SEBASTIAN MAY 28, 2020 1D POOLING WAS NOT WORKING
    //if (counter_row==(N_DIM_ARRAY-1))   


     if ((counter_X_dimension == (PADDED_O_X-N_DIM_ARRAY)) )
      begin
      //Adjust the counter by the increased increment because of padding the output
      next_counter=counter - (PADDED_O_X-PADDED_C_X)+N_DIM_ARRAY;
      end
    else
       begin
       next_counter=counter+ N_DIM_ARRAY;
       end

       if ((counter_X_dimension == (PADDED_O_X-N_DIM_ARRAY)))
        next_counter_X_dimension = 0;
       else
            next_counter_X_dimension = counter_X_dimension+N_DIM_ARRAY;
        

    if (counter_row==(4-1))
    next_counter_row=0;
    else
    next_counter_row= counter_row + 1;
    end 
    
    POOLING_1D_WRITING:
    begin
    next_counter_wr_addr = counter_wr_addr + 1;
       if (counter_row==(N_DIM_ARRAY-1))     
                begin
                    next_counter_row= 0;
                end
    end
    
    
    
    
    // 2d pooling
    POOLING_2D_READING_1:
    begin
    next_input_0=read_word;
    end
    

    
    POOLING_2D_OPERATION: 
    begin
    
    
    if (counter_row==(2-1))   
    next_counter_row=0;
    else
    next_counter_row= counter_row + 1;
    
    
    if ((counter_X_dimension == (PADDED_O_X-N_DIM_ARRAY)) )
      begin
      //Adjust the counter by the increased increment because of padding the output
      next_counter=counter+ (PADDED_C_X)- (PADDED_O_X-PADDED_C_X)+N_DIM_ARRAY;
      end
    else
       begin
       next_counter=counter+ N_DIM_ARRAY;
       end
       
       if ((counter_X_dimension == (PADDED_O_X-N_DIM_ARRAY)))
        next_counter_X_dimension = 0;
       else
            next_counter_X_dimension = counter_X_dimension+N_DIM_ARRAY;
    end 
    
    POOLING_2D_WRITING:
    begin
      next_counter_wr_addr = counter_wr_addr + 1;
       if (counter_row==(N_DIM_ARRAY-1))     
                begin
                    next_counter_row= 0;
                end
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

enable_pooling_1d=0;
enable_pooling_2d=0;
wr_en_output_buffer_nl=0;
            input_channel_rd_addr =0;
            input_channel_rd_en=0;
            wr_addr_nl =0;
for (j=0; j < (N_DIM_ARRAY); j=j+1)            
            input_pooling[j] = 0;
case(state)
        IDLE:
        begin
            wr_en_output_buffer_nl=0;
            input_channel_rd_addr =0;
            input_channel_rd_en=0;
        end
         
          //pooling 1d
          POOLING_1D_PRE_READING:
          begin
            input_channel_rd_addr =counter;
            input_channel_rd_en=1;
          end
          POOLING_1D_READING:
          begin
            input_channel_rd_addr =counter;
            input_channel_rd_en=1;
          end

       POOLING_1D_OPERATION:
          begin
            input_pooling=input_0;
            enable_pooling_1d=1;
            input_channel_rd_addr =counter;
            input_channel_rd_en=0;
          end
         POOLING_1D_WRITING:
          begin
             output_word=pooling_calculation;
            wr_en_output_buffer_nl =1;
            wr_addr_nl= counter_wr_addr;
            input_channel_rd_addr =counter;
            input_channel_rd_en=0;
          end
          
          
           //pooling 2d
          POOLING_2D_PRE_READING:
          begin
            input_channel_rd_addr =counter;
            input_channel_rd_en=1;
          end
          POOLING_2D_READING_1:
          begin
            input_channel_rd_addr =counter+PADDED_C_X;
            input_channel_rd_en=1;
          end

       POOLING_2D_OPERATION:
          begin
            input_pooling=input_0;
            enable_pooling_2d=1;
            input_channel_rd_addr =counter;
            input_channel_rd_en=0;
          end
         POOLING_2D_WRITING:
          begin
             output_word=pooling_calculation;
            wr_en_output_buffer_nl =1;
            wr_addr_nl= counter_wr_addr;
            input_channel_rd_addr =counter;
            input_channel_rd_en=0;
          end
          
 endcase         
end






//calculation of pooling
always @(posedge clk or negedge reset)
begin
  if (!reset)
    for (j=0; j < (N_DIM_ARRAY); j=j+1)
      pooling_calculation[j] <=0;
  else
    begin
   case(state)
   
   IDLE:
   for (j=0; j < (N_DIM_ARRAY); j=j+1)
      pooling_calculation[j] <=0;
  POOLING_1D_OPERATION:
    begin
        
        for (k=0; k < N_DIM_ARRAY/4; k=k+1)
          begin
              pooling_calculation[(N_DIM_ARRAY/4)*counter_row+k] <= max_value_1d[k];
          end
          
      end
      
   POOLING_2D_OPERATION:
    begin
      if (counter_row==0)
          for (j=0; j < (N_DIM_ARRAY/2); j=j+1)
              pooling_calculation[j] <= max_value_2d[j];

      else      
            for (j=0; j < (N_DIM_ARRAY/2); j=j+1)
              pooling_calculation[(N_DIM_ARRAY/2)+j] <= max_value_2d[j];
      end   
    endcase
    end 
end



//Pooling 1d
always @(*)
begin
//default
for (k=0; k < N_DIM_ARRAY/4; k=k+1)
  max_value_1d[k] =0;
for (k=0; k < N_DIM_ARRAY/4; k=k+1)
  max_value_1d_subword_0[k] =input_pooling_subword_0[4*k];
for (k=0; k < N_DIM_ARRAY/4; k=k+1)
  max_value_1d_subword_1[k] =input_pooling_subword_1[4*k];
for (k=0; k < N_DIM_ARRAY/4; k=k+1)  
  max_value_1d_subword_0_0[k]=input_0_subword_0_0[4*k];
for (k=0; k < N_DIM_ARRAY/4; k=k+1)  
  max_value_1d_subword_0_1[k]=input_0_subword_0_1[4*k];
for (k=0; k < N_DIM_ARRAY/4; k=k+1)  
  max_value_1d_subword_1_0[k]=input_0_subword_1_0[4*k];
for (k=0; k < N_DIM_ARRAY/4; k=k+1)  
  max_value_1d_subword_1_1[k]=input_0_subword_1_1[4*k];
/////////////////////////
case(PRECISION)
0:
begin
for (k=0; k < N_DIM_ARRAY/4; k=k+1)
  max_value_1d[k] =input_pooling[4*k];
if (enable_pooling_1d)
begin
for (k=0; k < N_DIM_ARRAY/4; k=k+1)
for (j=0; j < 4; j=j+1)
  begin
    if (input_pooling[4*k+j] >= max_value_1d[k])
      max_value_1d[k] = input_pooling[4*k+j];
    else
      max_value_1d[k] = max_value_1d[k];
  end
end
end

1:
begin
//subword_0
for (k=0; k < N_DIM_ARRAY/4; k=k+1)
  max_value_1d_subword_0[k] =input_pooling_subword_0[4*k];
if (enable_pooling_1d)
begin
for (k=0; k < N_DIM_ARRAY/4; k=k+1)
for (j=0; j < 4; j=j+1)
  begin
    if (input_pooling_subword_0[4*k+j] >= max_value_1d_subword_0[k])
      max_value_1d_subword_0[k] = input_pooling_subword_0[4*k+j];
    else
      max_value_1d_subword_0[k] = max_value_1d_subword_0[k];
  end
end
//subword_1
for (k=0; k < N_DIM_ARRAY/4; k=k+1)
  max_value_1d_subword_1[k] =input_pooling_subword_1[4*k];
if (enable_pooling_1d)
begin
for (k=0; k < N_DIM_ARRAY/4; k=k+1)
for (j=0; j < 4; j=j+1)
  begin
    if (input_pooling_subword_1[4*k+j] >= max_value_1d_subword_1[k])
      max_value_1d_subword_1[k] = input_pooling_subword_1[4*k+j];
    else
      max_value_1d_subword_1[k] = max_value_1d_subword_1[k];
  end
end

 for (k=0; k < N_DIM_ARRAY/4; k=k+1)
    max_value_1d[k]={{max_value_1d_subword_1[k]},{max_value_1d_subword_0[k]}};

end


2:
begin
//subword_0_0
for (k=0; k < N_DIM_ARRAY/4; k=k+1)
  max_value_1d_subword_0_0[k] =input_pooling_subword_0_0[4*k];
if (enable_pooling_1d)
begin
for (k=0; k < N_DIM_ARRAY/4; k=k+1)
for (j=0; j < 4; j=j+1)
  begin
    if (input_pooling_subword_0_0[4*k+j] >= max_value_1d_subword_0_0[k])
      max_value_1d_subword_0_0[k] = input_pooling_subword_0_0[4*k+j];
    else
      max_value_1d_subword_0_0[k] = max_value_1d_subword_0_0[k];
  end
end

//subword_0_1
for (k=0; k < N_DIM_ARRAY/4; k=k+1)
  max_value_1d_subword_0_1[k] =input_pooling_subword_0_1[4*k];
if (enable_pooling_1d)
begin
for (k=0; k < N_DIM_ARRAY/4; k=k+1)
for (j=0; j < 4; j=j+1)
  begin
    if (input_pooling_subword_0_1[4*k+j] >= max_value_1d_subword_0_1[k])
      max_value_1d_subword_0_1[k] = input_pooling_subword_0_1[4*k+j];
    else
      max_value_1d_subword_0_1[k] = max_value_1d_subword_0_1[k];
  end
end

//subword_1_0 
for (k=0; k < N_DIM_ARRAY/4; k=k+1)
  max_value_1d_subword_1_0[k] =input_pooling_subword_1_0[4*k];
if (enable_pooling_1d)
begin
for (k=0; k < N_DIM_ARRAY/4; k=k+1)
for (j=0; j < 4; j=j+1)
  begin
    if (input_pooling_subword_1_0[4*k+j] >= max_value_1d_subword_1_0[k])
      max_value_1d_subword_1_0[k] = input_pooling_subword_1_0[4*k+j];
    else
      max_value_1d_subword_1_0[k] = max_value_1d_subword_1_0[k];
  end
end
//subword_1_1

for (k=0; k < N_DIM_ARRAY/4; k=k+1)
  max_value_1d_subword_1_1[k] =input_pooling_subword_1_1[4*k];
if (enable_pooling_1d)
begin
for (k=0; k < N_DIM_ARRAY/4; k=k+1)
for (j=0; j < 4; j=j+1)
  begin
    if (input_pooling_subword_1_1[4*k+j] >= max_value_1d_subword_1_1[k])
      max_value_1d_subword_1_1[k] = input_pooling_subword_1_1[4*k+j];
    else
      max_value_1d_subword_1_1[k] = max_value_1d_subword_1_1[k];
  end
end  

 for (k=0; k < N_DIM_ARRAY/4; k=k+1)
    max_value_1d[k]={{max_value_1d_subword_1_1[k]},{max_value_1d_subword_1_0[k]},{max_value_1d_subword_0_1[k]},{max_value_1d_subword_0_0[k]}};

end 
endcase
end


// Pooling 2d
always @(*)
begin
//default values
for (j=0; j < (N_DIM_ARRAY/2); j=j+1)
  max_value_2d[j]=input_0[j*2];
for (j=0; j < (N_DIM_ARRAY/2); j=j+1)
  max_value_2d_subword_0[j]=input_0_subword_0[j*2];  
for (j=0; j < (N_DIM_ARRAY/2); j=j+1)
  max_value_2d_subword_1[j]=input_0_subword_1[j*2];  
  
for (j=0; j < (N_DIM_ARRAY/2); j=j+1)
  max_value_2d_subword_0_0[j]=input_0_subword_0_0[j*2];  
for (j=0; j < (N_DIM_ARRAY/2); j=j+1)
  max_value_2d_subword_0_1[j]=input_0_subword_0_1[j*2];  
  for (j=0; j < (N_DIM_ARRAY/2); j=j+1)
  max_value_2d_subword_1_0[j]=input_0_subword_1_0[j*2];  
  for (j=0; j < (N_DIM_ARRAY/2); j=j+1)
  max_value_2d_subword_1_1[j]=input_0_subword_1_1[j*2];  
  
if (enable_pooling_2d)
  begin
  
      case(PRECISION)
      
      0: 
      begin
        for (j=0; j < (N_DIM_ARRAY/2); j=j+1)
        begin
          // Comparison with second vector
             for (k=0; k < 2; k=k+1)
              begin
                  if (read_word[j*2+k] > max_value_2d[j])
                      max_value_2d[j] = read_word[j*2+k];
              end 
        end

        for (j=0; j < (N_DIM_ARRAY/2); j=j+1)
        begin
          // Comparison with first vector
            for (k=0; k < 2; k=k+1)
              begin
                  if (input_0[j*2+k] > max_value_2d[j])
                      max_value_2d[j] = input_0[j*2+k];
              end    
        end
       end 
       
       1: 
       
      
       begin
       
        //subword_0
       for (j=0; j < (N_DIM_ARRAY/2); j=j+1)
        begin
          // Comparison with second vector
             for (k=0; k < 2; k=k+1)
              begin
                  if (read_word_subword_0[j*2+k] > max_value_2d_subword_0[j])
                      max_value_2d_subword_0[j] = read_word_subword_0[j*2+k];
              end 
        end

        for (j=0; j < (N_DIM_ARRAY/2); j=j+1)
        begin
          // Comparison with first vector
            for (k=0; k < 2; k=k+1)
              begin
                  if (input_0_subword_0[j*2+k] > max_value_2d_subword_0[j])
                      max_value_2d_subword_0[j] = input_0_subword_0[j*2+k];
              end    
        end
        
        //subword_1
       for (j=0; j < (N_DIM_ARRAY/2); j=j+1)
        begin
          // Comparison with second vector
             for (k=0; k < 2; k=k+1)
              begin
                  if (read_word_subword_1[j*2+k] > max_value_2d_subword_1[j])
                      max_value_2d_subword_1[j] = read_word_subword_1[j*2+k];
              end 
        end

        for (j=0; j < (N_DIM_ARRAY/2); j=j+1)
        begin
          // Comparison with first vector
            for (k=0; k < 2; k=k+1)
              begin
                  if (input_0_subword_1[j*2+k] > max_value_2d_subword_1[j])
                      max_value_2d_subword_1[j] = input_0_subword_1[j*2+k];
              end    
        end
        
        //concatenation of subwords
        for (j=0; j < (N_DIM_ARRAY/2); j=j+1)
              max_value_2d[j]={{max_value_2d_subword_1[j]},{max_value_2d_subword_0[j]}}; 
       end 
       
              2: 
       
      
       begin
       
        //subword_0_0
       for (j=0; j < (N_DIM_ARRAY/2); j=j+1)
        begin
          // Comparison with second vector
             for (k=0; k < 2; k=k+1)
              begin
                  if (read_word_subword_0_0[j*2+k] > max_value_2d_subword_0_0[j])
                      max_value_2d_subword_0_0[j] = read_word_subword_0_0[j*2+k];
              end 
        end

        for (j=0; j < (N_DIM_ARRAY/2); j=j+1)
        begin
          // Comparison with first vector
            for (k=0; k < 2; k=k+1)
              begin
                  if (input_0_subword_0_0[j*2+k] > max_value_2d_subword_0_0[j])
                      max_value_2d_subword_0_0[j] = input_0_subword_0_0[j*2+k];
              end    
        end
        
        //subword_0_1
       for (j=0; j < (N_DIM_ARRAY/2); j=j+1)
        begin
          // Comparison with second vector
             for (k=0; k < 2; k=k+1)
              begin
                  if (read_word_subword_0_1[j*2+k] > max_value_2d_subword_0_1[j])
                      max_value_2d_subword_0_1[j] = read_word_subword_0_1[j*2+k];
              end 
        end

        for (j=0; j < (N_DIM_ARRAY/2); j=j+1)
        begin
          // Comparison with first vector
            for (k=0; k < 2; k=k+1)
              begin
                  if (input_0_subword_0_1[j*2+k] > max_value_2d_subword_0_1[j])
                      max_value_2d_subword_0_1[j] = input_0_subword_0_1[j*2+k];
              end    
        end
         //subword_1_0
       for (j=0; j < (N_DIM_ARRAY/2); j=j+1)
        begin
          // Comparison with second vector
             for (k=0; k < 2; k=k+1)
              begin
                  if (read_word_subword_1_0[j*2+k] > max_value_2d_subword_1_0[j])
                      max_value_2d_subword_1_0[j] = read_word_subword_1_0[j*2+k];
              end 
        end

        for (j=0; j < (N_DIM_ARRAY/2); j=j+1)
        begin
          // Comparison with first vector
            for (k=0; k < 2; k=k+1)
              begin
                  if (input_0_subword_1_0[j*2+k] > max_value_2d_subword_1_0[j])
                      max_value_2d_subword_1_0[j] = input_0_subword_1_0[j*2+k];
              end    
        end 
        
         //subword_1_1
       for (j=0; j < (N_DIM_ARRAY/2); j=j+1)
        begin
          // Comparison with second vector
             for (k=0; k < 2; k=k+1)
              begin
                  if (read_word_subword_1_1[j*2+k] > max_value_2d_subword_1_1[j])
                      max_value_2d_subword_1_1[j] = read_word_subword_1_1[j*2+k];
              end 
        end

        for (j=0; j < (N_DIM_ARRAY/2); j=j+1)
        begin
          // Comparison with first vector
            for (k=0; k < 2; k=k+1)
              begin
                  if (input_0_subword_1_1[j*2+k] > max_value_2d_subword_1_1[j])
                      max_value_2d_subword_1_1[j] = input_0_subword_1_1[j*2+k];
              end    
        end
        //concatenation of subwords
        for (j=0; j < (N_DIM_ARRAY/2); j=j+1)
              max_value_2d[j]={{max_value_2d_subword_1_1[j]},{max_value_2d_subword_1_0[j]},{max_value_2d_subword_0_1[j]},{max_value_2d_subword_0_0[j]}}; 
       end 
       
       endcase
  end
  
 
end



always @(*)
begin
    for (j=0; j < (N_DIM_ARRAY); j=j+1)
      begin
      
      // 4 bits
      input_0_subword_1[j]= input_0[j][INPUT_CHANNEL_DATA_WIDTH-1:INPUT_CHANNEL_DATA_WIDTH/2];
      input_0_subword_0[j]=input_0[j][INPUT_CHANNEL_DATA_WIDTH/2-1:0];
      read_word_subword_1[j]=read_word[j][INPUT_CHANNEL_DATA_WIDTH-1:INPUT_CHANNEL_DATA_WIDTH/2];
      read_word_subword_0[j]=read_word[j][INPUT_CHANNEL_DATA_WIDTH/2-1:0];
      input_pooling_subword_1[j]=input_pooling[j][INPUT_CHANNEL_DATA_WIDTH-1:INPUT_CHANNEL_DATA_WIDTH/2];
       input_pooling_subword_0[j]=input_pooling[j][INPUT_CHANNEL_DATA_WIDTH/2-1:0];
     
     //2 bits
     input_0_subword_1_1[j]= input_0[j][7:6];
      input_0_subword_1_0[j]=input_0[j][5:4];
       input_0_subword_0_1[j]= input_0[j][3:2];
      input_0_subword_0_0[j]=input_0[j][1:0];
      read_word_subword_1_1[j]=read_word[j][7:6];
      read_word_subword_1_0[j]=read_word[j][5:4];
      read_word_subword_0_1[j]=read_word[j][3:2];
      read_word_subword_0_0[j]=read_word[j][1:0];
      input_pooling_subword_1_1[j]=input_pooling[j][7:6];
      input_pooling_subword_1_0[j]=input_pooling[j][5:4];
       input_pooling_subword_0_1[j]=input_pooling[j][3:2];
       input_pooling_subword_0_0[j]=input_pooling[j][1:0];
      end
end

endmodule
