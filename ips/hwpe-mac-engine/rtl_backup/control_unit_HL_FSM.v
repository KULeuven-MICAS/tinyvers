
//SRAM sparsity
SRAM_2048x32_equivalent sparsity_mem(
                       .CLK(clk), .CEB('0), .WEB(~wr_en_ext_sparsity),
                       .A(A), .D(wr_data_ext_sparsity), 
                       .Q(sparse_val_sram)
);


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
assign   CONF_NB_INPUT_TILE=instruction[26];
assign   CONF_NB_WEIGHT_TILE=instruction[27];

 /// FOR VIKRAM: CHECK THE CORRECTNESS OF THE FOLLOWING STATENMENTS TAKING INTO CONSIDERATION THE NEW INSTRUCTION FIELDS
`ifdef DESIGN_V2
assign   CONF_CONV_STRIDED = instruction[28];
assign   CONF_CONV_DECONV = instruction[29];
assign   CONF_NORM = instruction[30];
`endif
assign   CONF_OUTPUT_PRECISION=instruction[31];
assign   CONF_INPUT_PRECISION=instruction[31];






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