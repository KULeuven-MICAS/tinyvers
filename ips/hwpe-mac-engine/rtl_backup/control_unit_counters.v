
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
         for (sp=1; sp<STR_SP_MEMORY_WORD; sp=sp+1)
          begin
            if (next_sparse_val[sp] == 1  && next_sparse_val[sp-1] == 1) 
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
        if (CNN_FINISHED_C_LOOP || FC_FINISHED_C_LOOP)
          begin
           next_counter_X = counter_X;
           next_counter_Y = counter_Y;
           next_counter_FX =  0;
           next_counter_offset_input_channel=counter_offset_input_channel;
           next_counter_C = 0;
           next_counter_sparsity = 0;
           next_counter_accumulation_pes= counter_accumulation_pes;
           next_counter_weight_address =counter_weight_address;
           next_counter_input_channel_address = counter_offset_input_channel;
           next_counter_FY = 0;
           if (CONF_MODE == 1)
             next_counter_K = counter_K +1;
           else
             next_counter_K = counter_K;
           next_sparse_val = sparse_val_sram;
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
      SPARSITY_SET = 0;
      next_sparse_val = sparse_val >> (next_counter_sparsity + 1);      
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
      next_sparse_val = sparse_val >> (next_counter_sparsity + 1);
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
                            next_counter_sparsity = 0;
                            

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
                            
                            if (counter_FX == CONF_FX-2)
                              next_sparse_val = sparse_val >> (next_counter_sparsity + 1); 
                              
                              
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
      SPARSITY_SET = 0;
      next_counter_sparsity = 0;
      
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
        begin
          if (next_state == STR_SPARSITY) begin
            next_counter_C = counter_C;
            next_counter_weight_address = counter_weight_address;
            next_sparse_val = sparse_val >> (next_counter_sparsity + 1);
          end else begin
            next_counter_C = counter_C+1;
            next_counter_weight_address = counter_weight_address+1;
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
