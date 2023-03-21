import parameters::*;

// Nonlinear function generator and pooling operation
// Generates a vector of N values with N inputs
module pooling(
clk, reset,
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
input enable_nonlinear_block;
input [7:0] SHIFT_FIXED_POINT;
input [15:0] PADDED_C_X;
input [15:0] NUMBER_OF_ACTIVATION_CYCLES; 
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
                        POOLING_2D_READING_2=11,
                        POOLING_2D_OPERATION=12,
                        POOLING_2D_WRITING=13;
                        
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


assign finished_activation = (counter == (NUMBER_OF_ACTIVATION_CYCLES));
assign FINISHED_ROW_1D = (counter_row == (N_DIM_ARRAY-1));
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
    POOLING_2D_READING_2:       
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
    next_counter=counter+ N_DIM_ARRAY;
    if (counter_row==(N_DIM_ARRAY-1))   
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
    
    
    if ((counter_X_dimension == (PADDED_C_X-N_DIM_ARRAY)) )
      begin
      next_counter=counter+ (PADDED_C_X)+N_DIM_ARRAY;
      end
    else
       begin
       next_counter=counter+ N_DIM_ARRAY;
       end
       
       if ((counter_X_dimension == (PADDED_C_X-N_DIM_ARRAY)))
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
          POOLING_2D_READING_2:
          begin
            input_channel_rd_addr =counter ;
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

/////////////////////////
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
//////////////////////////

for (j=0; j < (N_DIM_ARRAY); j=j+1)
  max_value[j]=input_pooling[j];
  
if (enable_pooling_1d)
  for (j=0; j < (N_DIM_ARRAY); j=j+1)
                begin
                   if (j>0)
                   begin
                    if (input_pooling[j] >= max_value[j-1])
                      max_value[j]=input_pooling[j];
                    else
                      max_value[j]=max_value[j-1];
                   end 
                end
end


// Pooling 2d
always @(*)
begin
for (j=0; j < (N_DIM_ARRAY/2); j=j+1)
  max_value_2d[j]=input_0[j*2];
  
if (enable_pooling_2d)
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
  
 
end


endmodule