
 //Datapath signals
 always @(*)
 begin
  //default
  INPUT_TILE_SIZE=CONF_SIZE_CHANNEL;
  WEIGHT_TILE_SIZE=(CONF_FX*CONF_FY*CONF_C*CONF_K) + CONF_K;
  NB_INPUT_TILE=CONF_NB_INPUT_TILE;
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
          clear = 0;
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
          clear = 1;
          enable_pe_array=1;
          for (i=0; i<(N_DIM_ARRAY); i=i+1) 
            for (j=0; j < (N_DIM_ARRAY); j=j+1) 
              CR_PE_array[i][j] = 17'b00000010;
              
              
         `ifdef DESIGN_V2
          for (i=0; i<(N_DIM_ARRAY); i=i+1) begin
            for (j=0; j < (N_DIM_ARRAY); j=j+1) begin
              if (CONF_NORM == 00 || CONF_NORM == 11)
              
                /// FOR VIKRAM: CHECK THE CORRECTNESS OF THE FOLLOWING STATENMENTS TAKING INTO CONSIDERATION THE PE SIGNALS ADDED BY SEBASTIAN
                CR_PE_array[i][j] = 17'b00000010;
              else if (CONF_NORM == 01) // L2 norm
                CR_PE_array[i][j] = 17'b001000_0000_0000_0010;
              else if (CONF_NORM == 10) // L1 norm
                CR_PE_array[i][j] = 17'b010000_0000_0000_0010;
              else
                CR_PE_array[i][j] = 17'b00000010;
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
              else
                CR_PE_array[i][j] = 17'b00100000;
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
      
          `ifdef DESIGN_V2
          for (i=0; i<(N_DIM_ARRAY); i=i+1) begin 
            for (j=0; j < (N_DIM_ARRAY); j=j+1) begin
              if (j== 0) begin
                if (CONF_NORM == 00 || CONF_NORM == 11)
                  CR_PE_array[i][j] =17'b00100001;
                else if (CONF_NORM == 01) // L2 norm
                  CR_PE_array[i][j] =17'b01000_0000_0010_0001;
                else if (CONF_NORM == 10) // L1 norm
                  CR_PE_array[i][j] =17'b10000_0000_0010_0001;
                else 
                  CR_PE_array[i][j] =17'b0010_0001;
              end else begin
                if (CONF_NORM == 00 || CONF_NORM == 11)
                  CR_PE_array[i][j] =17'b10_0000_1000; 
                else if (CONF_NORM == 01) // L2 norm
                  CR_PE_array[i][j] =17'b01000_0010_0000_1000;
                else if (CONF_NORM == 10) // L1 norm
                  CR_PE_array[i][j] =17'b10000_0010_0000_1000;
                else
                  CR_PE_array[i][j] =17'b10_0000_1000;
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
                else 
                  CR_PE_array[i][j] =17'b00100001;
              end else begin
                if (CONF_NORM == 00 || CONF_NORM == 11)
                  CR_PE_array[i][j] =17'b10_0000_1000;
                else if (CONF_NORM == 01) // L2 norm
                  CR_PE_array[i][j] =17'b01000_0010_0000_1000;
                else if (CONF_NORM == 10) // L1 norm
                  CR_PE_array[i][j] =17'b10000_0010_0000_1000;
                else
                  CR_PE_array[i][j] =17'b1000001000;
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
                CR_PE_array[i][j] = 17'b00100000;
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
              CR_PE_array[i][j] = 17'b00100000;
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
                  CR_PE_array[i][j] =17'b101100000;
                else if (CONF_NORM == 01) // L2 norm
                  CR_PE_array[i][j] =17'b01000_0001_0110_0000;
                else if (CONF_NORM == 10) // L1 norm
                  CR_PE_array[i][j] =17'b10000_0001_0110_0000;
                else
                  CR_PE_array[i][j] =17'b0010_0000_0110_0000; //for 32 bias
              end else begin
                if (CONF_NORM == 00 || CONF_NORM == 11)
                  CR_PE_array[i][j] =17'b00000010;
                else if (CONF_NORM == 01) // L2 norm
                  CR_PE_array[i][j] =17'b01000_0000_0000_0010;
                else if (CONF_NORM == 10) // L1 norm
                  CR_PE_array[i][j] =17'b10000_0000_0000_0010;
                else
                  CR_PE_array[i][j]= 17'b00000010;
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
                CR_PE_array[i][j] = 17'b00000010;
              else if (CONF_NORM == 01) // L2 norm
                CR_PE_array[i][j] = 17'b01000_0000_0000_0010;
              else if (CONF_NORM == 10) // L1 norm
                CR_PE_array[i][j] = 17'b10000_0000_0000_0010;
              else
                CR_PE_array[i][j] =17'b0100_0000_0000_0010; //32 bias
            end
          end
`else
          for (i=0; i<(N_DIM_ARRAY); i=i+1) 
            for (j=0; j < (N_DIM_ARRAY); j=j+1) 
              CR_PE_array[i][j] =17'b0100_0000_0000_0010; //32 bias
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
