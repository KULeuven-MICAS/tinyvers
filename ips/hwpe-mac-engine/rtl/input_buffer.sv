`define DESIGN_V2
`define N_DIM_ARRAY_8

import parameters::*;

// Buffer for input activations implemented as a FIFO. 
// It can retrieve data from the FIFO or send the parallel input received directly


module input_buffer
(
`ifdef DESIGN_V2
  cr_fifo,
  enable_strided_conv,
  enable_deconv,
  odd_X_tile,
`endif
  clk,reset,enable, 
  parallel_input_array, // N values to save
  loading_in_parallel, // binary signal to save in parallel
  shift_input_buffer,
  serial_input, // 1 element to save in FIFO
  mode, // FC or CNN
  clear, // clear FIFO
  output_array // Output of FIFO (passing parallel input or retrieving data from FIFO)
);
`ifdef DESIGN_V2
input [1:0] cr_fifo;
input enable_strided_conv;
input enable_deconv;
input odd_X_tile;
`endif
//IO
input clk, reset, clear, enable;
input loading_in_parallel;
input [2:0] mode;
input [MAXIMUM_DILATION_BITS-1:0] shift_input_buffer;
input signed [INPUT_CHANNEL_DATA_WIDTH-1:0] parallel_input_array[N_DIM_ARRAY-1:0];
input signed  [INPUT_CHANNEL_DATA_WIDTH-1:0] serial_input [N_DIM_ARRAY-1:0];
output reg signed [INPUT_CHANNEL_DATA_WIDTH-1:0] output_array[N_DIM_ARRAY-1:0];

//signals
`ifdef DESIGN_V2
reg signed  [INPUT_CHANNEL_DATA_WIDTH-1:0] FIFO[2*N_DIM_ARRAY-1:0];
reg signed  [INPUT_CHANNEL_DATA_WIDTH-1:0] FIFO_output[2*N_DIM_ARRAY-1:0];
reg [N_DIM_ARRAY_LOG:0] FIFO_POINTER;
reg [N_DIM_ARRAY_LOG:0] index[2*N_DIM_ARRAY-1:0]; // N_DIM_ARRAY_LOG:0 and 2*N_DIM_ARRAY for strided conv
reg [$clog2(2*N_DIM_ARRAY)-1:0] index_FIFO [2*N_DIM_ARRAY-1:0];
reg [(2*N_DIM_ARRAY)-1:0] index_y[N_DIM_ARRAY-1:0];

`else
reg signed  [INPUT_CHANNEL_DATA_WIDTH-1:0] FIFO[N_DIM_ARRAY-1:0];
reg signed  [INPUT_CHANNEL_DATA_WIDTH-1:0] FIFO_output[N_DIM_ARRAY-1:0];
reg [N_DIM_ARRAY_LOG-1:0] FIFO_POINTER;
reg [N_DIM_ARRAY_LOG-1:0] index[N_DIM_ARRAY-1:0]; 
reg [$clog2(N_DIM_ARRAY)-1:0] index_FIFO [N_DIM_ARRAY-1:0];
reg [(N_DIM_ARRAY)-1:0] index_y[N_DIM_ARRAY-1:0];
`endif

reg loading_in_parallel_reg;

integer i;
integer j;
reg [N_DIM_ARRAY_LOG-1:0] index_0;
reg [N_DIM_ARRAY_LOG-1:0]  index_1;
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

`ifdef DESIGN_V2
       for (i=0; i<2*N_DIM_ARRAY; i=i+1)
`else
       for (i=0; i<N_DIM_ARRAY; i=i+1)
`endif
        FIFO[i] <= 0;
    end
  else
     begin
      if (clear==1)
      begin
`ifdef DESIGN_V2
       for (i=0; i<2*N_DIM_ARRAY; i=i+1)
`else
       for (i=0; i<N_DIM_ARRAY; i=i+1)
`endif
         FIFO[i] <= 0;
      end
      else
      if (mode==MODE_CNN)
          begin
          
          
             `ifdef DESIGN_V2
              if (enable_strided_conv == 1 && loading_in_parallel==1)
                begin
                  if (cr_fifo[0] == 0) begin
                    for (i=0; i<N_DIM_ARRAY; i=i+1)
                      FIFO[i] <= parallel_input_array[i];
                  end 
                  else if (cr_fifo[0] == 1) begin
                    for (i=N_DIM_ARRAY; i<2*N_DIM_ARRAY; i=i+1)
                      FIFO[i] <= parallel_input_array[i-N_DIM_ARRAY];
                  end
                end
              else if (enable_deconv == 1 && loading_in_parallel==1)
                begin
                  if (cr_fifo[0] == 0) begin
                    if (odd_X_tile == 0) begin
                      FIFO[0] <= parallel_input_array[0];
                      FIFO[1] <= 0;
                      FIFO[2] <= 0;
                      FIFO[3] <= parallel_input_array[1];
                      FIFO[4] <= parallel_input_array[1];
                      FIFO[5] <= 0;
                      FIFO[6] <= 0;
                      FIFO[7] <= parallel_input_array[2];
`ifdef N_DIM_ARRAY_8
                      FIFO[8]  <= parallel_input_array[2];
                      FIFO[9]  <= 0;
                      FIFO[10] <= 0;
                      FIFO[11] <= parallel_input_array[3];
                      FIFO[12] <= parallel_input_array[3];
                      FIFO[13] <= 0;
                      FIFO[14] <= 0;
                      FIFO[15] <= parallel_input_array[4];
`endif
                    end else begin
                      if (N_DIM_ARRAY == 4) begin
                        FIFO[0] <= parallel_input_array[2];
                        FIFO[1] <= 0;
                        FIFO[2] <= 0;
                        FIFO[3] <= parallel_input_array[3];
                        FIFO[4] <= parallel_input_array[3];
                        FIFO[5] <= 0;
                        FIFO[6] <= 0;
                      end else if (N_DIM_ARRAY == 8) begin
                        FIFO[0] <= parallel_input_array[4];
                        FIFO[1] <= 0;
                        FIFO[2] <= 0;
                        FIFO[3] <= parallel_input_array[5];
                        FIFO[4] <= parallel_input_array[5];
                        FIFO[5] <= 0;
                        FIFO[6] <= 0;
                      end
`ifdef N_DIM_ARRAY_8
                      FIFO[7]  <= parallel_input_array[6];
                      FIFO[8]  <= parallel_input_array[6];
                      FIFO[9]  <= 0;
                      FIFO[10] <= 0;
                      FIFO[11] <= parallel_input_array[7];
                      FIFO[12] <= parallel_input_array[7];
                      FIFO[13] <= 0;
                      FIFO[14] <= 0;
`endif
                    end
                  end
                  else if (cr_fifo[0] == 1) begin
                    if (odd_X_tile == 1)
                       // MODIFIED BY SEBASTIAN, JUNE 3, 2020, BUG FIXING
                      //if (N_DIM_ARRAY == 4)
                      //  FIFO[7] <= parallel_input_array[0];
`ifdef N_DIM_ARRAY_8
                      FIFO[15] <= parallel_input_array[0];
`else // N_DIM_ARRAY_8
         FIFO[7] <= parallel_input_array[0];
`endif
                  end
                end

              else if ((enable_deconv == 0 && enable_strided_conv == 0) && loading_in_parallel_reg==1)
                begin
                  if (cr_fifo[0] == 1) begin
                    for (i=0; i<N_DIM_ARRAY; i=i+1)
                      FIFO[i] <= parallel_input_array[i];
                  end
                end

              else if (loading_in_parallel_reg==0)
                  begin
                    if (enable==1)
                      begin
                        if (enable_deconv == 1) begin
                          for (j=0; j<N_DIM_ARRAY; j=j+1) begin
                              if (j<shift_input_buffer) begin
                                FIFO[index_FIFO[j]] <= 0;
                              end
                           end
                        end else begin
                          for (j=0; j<N_DIM_ARRAY; j=j+1) begin
                            if (j<shift_input_buffer) begin
                                FIFO[index_FIFO[j]] <= serial_input[j];
                            end
                          end
                        end
                       end
                    end
`else // DESIGN_V2
             if (loading_in_parallel_reg==1)
                begin
                  for (i=0; i<N_DIM_ARRAY; i=i+1)
                    FIFO[i] <= parallel_input_array[i];
                end
              else
                  begin
                    if (enable==1)
                      begin
                      //  for (i=0; i<N_DIM_ARRAY; i=i+1)
                      //         if (i ==  (FIFO_POINTER))
                      //             for (j=0; j<shift_input_buffer; j=j+1)
                      //                  begin         
                      //                   FIFO[i+j] <= serial_input[j];
                      //                     end
                                               

                                  // MODIFIED BY SEBASTIAN, JUNE 3, 2020. Error in the questa output
                                   for (j=0; j<N_DIM_ARRAY; j=j+1)
                                        begin
                                         if (j<shift_input_buffer)
                                         begin
                                           FIFO[index_FIFO[j]] <= serial_input[j];
		       		         end 
                                        end                             
                                //for (i=0; i<N_DIM_ARRAY; i=i+1)
                                // if (i ==  (FIFO_POINTER))
                                //  begin
                                //   for (j=0; j<shift_input_buffer; j=j+1)
                                //       FIFO[i+j] <= serial_input[j];
                                //  end

                       end
                    end            
`endif     
             
             
             
             
              
          end
      end
end


always @(*)
begin 

 for (j=0; j<N_DIM_ARRAY; j=j+1)
  begin
                                    if (j<shift_input_buffer)
                                         begin
                                         index_y[j]=j;
                                         index_FIFO[j]=(FIFO_POINTER+index_y[j]);
                                         end
                                         else
                                          begin
                                          index_y[j]=0;
                                         index_FIFO[j]=0;
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
            `ifdef DESIGN_V2
            if (enable_deconv == 1) begin
              if (enable == 1 && loading_in_parallel_reg == 0)
                begin
                  FIFO_POINTER <= FIFO_POINTER+shift_input_buffer+1;
                end
              end
            else begin
              if (enable == 1 && loading_in_parallel == 0)
                begin
                  FIFO_POINTER <= FIFO_POINTER+shift_input_buffer;
                end
              end
`else
            if (enable)
              begin
                  FIFO_POINTER <= FIFO_POINTER+shift_input_buffer;
              end
`endif           
          
      end
end



always @(*)
begin
 `ifdef DESIGN_V2
 for (i=0; i<2*N_DIM_ARRAY; i=i+1) 
   begin
    FIFO_output[i]=0;
    index[i]=0;
   end
  
            for (i=0; i<2*N_DIM_ARRAY; i=i+1)
              begin
                if (enable_strided_conv || enable_deconv) begin
                  index[i]= i-FIFO_POINTER;
                  FIFO_output[index[i]]=FIFO[i];
                end else begin
                  if (i < N_DIM_ARRAY) begin
                    index[i][N_DIM_ARRAY_LOG-1:0]= i-FIFO_POINTER;
                    FIFO_output[index[i]]=FIFO[i];
                  end
                end
              end
`else
 for (i=0; i<N_DIM_ARRAY; i=i+1)
    FIFO_output[i]=0;

            for (i=0; i<N_DIM_ARRAY; i=i+1)
              begin
              index[i]= i-FIFO_POINTER;
              FIFO_output[index[i]]=FIFO[i];
              end
`endif
end


//output reading
always @(*)
  begin
	  //default values
  for (i=0; i<N_DIM_ARRAY; i=i+1)
          output_array[i] = 0;

  // If it is a CNN or EWS network
    if ((mode == MODE_FC) || (mode==MODE_EWS))
      begin
        for (i=0; i<N_DIM_ARRAY; i=i+1)
          output_array[i] = parallel_input_array[i];
      end 
    else
      `ifdef DESIGN_V2
        if (enable_strided_conv || enable_deconv) begin
          if (cr_fifo[1] == 0) begin
            for (i=0; i<N_DIM_ARRAY; i=i+1)
              output_array[i] = FIFO_output[i<<1];
          end
          else if (cr_fifo[1] == 1) begin
            for (i=0; i<N_DIM_ARRAY; i=i+1)
              output_array[i] = FIFO_output[(i<<1)+1];
          end
        end else begin
          for (i=0; i<N_DIM_ARRAY; i=i+1)
            output_array[i] = FIFO_output[i];
        end
`else
        for (i=0; i<N_DIM_ARRAY; i=i+1)
          output_array[i] = FIFO_output[i];
`endif
  end
  
endmodule

