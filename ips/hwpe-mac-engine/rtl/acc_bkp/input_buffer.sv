import parameters::*;

// Buffer for input activations implemented as a FIFO. 
// It can retrieve data from the FIFO or send the parallel input received directly
module input_buffer
(
  clk,reset,enable, 
  parallel_input_array, // N values to save
  loading_in_parallel, // binary signal to save in parallel
  shift_input_buffer,
  serial_input, // 1 element to save in FIFO
  mode, // FC or CNN
  clear, // clear FIFO
  output_array // Output of FIFO (passing parallel input or retrieving data from FIFO)
);

//IO
input clk, reset, clear, enable;
input loading_in_parallel;
input [2:0] mode;
input [MAXIMUM_DILATION_BITS-1:0] shift_input_buffer;
input signed [INPUT_CHANNEL_DATA_WIDTH-1:0] parallel_input_array[N_DIM_ARRAY-1:0];
input signed  [INPUT_CHANNEL_DATA_WIDTH-1:0] serial_input [N_DIM_ARRAY-1:0];
output reg signed [INPUT_CHANNEL_DATA_WIDTH-1:0] output_array[N_DIM_ARRAY-1:0];

//signals
reg signed  [INPUT_CHANNEL_DATA_WIDTH-1:0] FIFO[N_DIM_ARRAY-1:0];
reg signed  [INPUT_CHANNEL_DATA_WIDTH-1:0] FIFO_output[N_DIM_ARRAY-1:0];
reg [N_DIM_ARRAY_LOG-1:0] FIFO_POINTER;
reg loading_in_parallel_reg;
reg[N_DIM_ARRAY_LOG-1:0] index[N_DIM_ARRAY-1:0];
integer i;
integer j;

// Loading in parallel register
always @(posedge clk or negedge reset)
  if (!reset)
    loading_in_parallel_reg<=0;
  else
    loading_in_parallel_reg <= loading_in_parallel;
    
// Initialization and Writing process    
always @(posedge clk or negedge reset)
begin
  if (!reset)
    begin
       for (i=0; i<N_DIM_ARRAY; i=i+1)
        FIFO[i] <= 0;
    end
  else
     begin
      if (clear==1)
      begin
          for (i=0; i<N_DIM_ARRAY; i=i+1)
                    FIFO[i] <= 0;
      end
      else
      if (mode==MODE_CNN)
          begin
              if (loading_in_parallel_reg==1)
                begin
                  for (i=0; i<N_DIM_ARRAY; i=i+1)
                    FIFO[i] <= parallel_input_array[i];
                end
              else
                  begin
                    if (enable==1)
                      begin
                        for (i=0; i<N_DIM_ARRAY; i=i+1)
                               if (i ==  (FIFO_POINTER))  
                                   for (j=0; j<shift_input_buffer; j=j+1)
                                       FIFO[i+j] <= serial_input[j];
    
                       end
                    end    
          end
      end
end


                       
                       
                       
                       
always @(posedge clk or negedge reset)
begin
  if (!reset)
    begin
        FIFO_POINTER <= 0;
    end
   else
    begin
    if (clear==1)
      begin
        FIFO_POINTER <= 0;
      end
    else
          //// LOGIC OF UPDATE ////////////
          if (mode==MODE_CNN)
          if (loading_in_parallel_reg==1)
            FIFO_POINTER <=0;
          else
            if (enable)
              begin
                  FIFO_POINTER <= FIFO_POINTER+shift_input_buffer;
              end
          
      end
end



always @(*)
begin
 for (i=0; i<N_DIM_ARRAY; i=i+1)
    FIFO_output[i]=0;
  
            for (i=0; i<N_DIM_ARRAY; i=i+1)
              begin
              index[i]= i-FIFO_POINTER;
              FIFO_output[index[i]]=FIFO[i];
              end
end


//output reading
always @(*)
  begin
  // If it is a CNN or EWS network
    if ((mode == MODE_FC) || (mode==MODE_EWS))
      begin
        for (i=0; i<N_DIM_ARRAY; i=i+1)
          output_array[i] = parallel_input_array[i];
      end 
    else
      begin
        for (i=0; i<N_DIM_ARRAY; i=i+1)
          output_array[i] = FIFO_output[i];
      end
  end
  
endmodule