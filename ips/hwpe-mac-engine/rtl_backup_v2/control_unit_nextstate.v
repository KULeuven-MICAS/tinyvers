 
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
       if (CONF_CAUSAL_CONVOLUTION==0)
        next_state=   CONV_FILLING_INPUT_FIFO;
       else
        next_state=   CONV_PADDING_FILLING_INPUT_FIFO;
      end else if (CONF_MODE == 0)
        next_state = FC_PRE_MAC;//CONV_MAC;
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
            next_state = CONV_ADD_BIAS_ACC; 
          else
         // If the FX loop is finished only
            if (CNN_FINISHED_FX_LOOP)
              if (sparse_val[0] == 1 && CONF_STR_SPARSITY == 1)
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
                if (sparse_val[counter_C%STR_SP_MEMORY_WORD] == 0 || CONF_STR_SPARSITY == 0)   
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
      if (sparse_val[counter_C] == 1 && CONF_STR_SPARSITY == 1)
        next_state = STR_SPARSITY;
      else
        next_state = FC_MAC;
     end
     
     
    
  FC_MAC: // Run the MAC operations
      begin
        if (FC_FINISHED_C_LOOP)
          next_state = FC_PRE_ACCUMULATE_MACS;
        else
          if (sparse_val[counter_C%STR_SP_MEMORY_WORD] == 1 && CONF_STR_SPARSITY == 1) 
            next_state = STR_SPARSITY;
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
          if (sparse_val[counter_C%STR_SP_MEMORY_WORD] == 0 || CONF_STR_SPARSITY == 0) 
            next_state = FC_PRE_MAC;
          else
            next_state = STR_SPARSITY;
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