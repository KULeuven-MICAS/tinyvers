`define DESIGN_V2

import parameters::*;

// Processing element
// Computes MAC operations based on control signals

module pe 
(
  clk,reset,enable_mac,
  passing_data_between_pes_cnn,
  PRECISION,
  clear_mac, // Clear signal
  input_adder_tree,
  input_bias,
  input_activation, // Activation input
  input_weight, // Weight activation
  input_neighbour_pe, // Input from neighboor PE
  input_vertical,
  cr_0,cr_1,cr_2,cr_3,cr_4,cr_5, cr_6, cr_7,cr_8,cr_9, cr_10, cr_11,cr_12,cr_13,cr_14,  cr_15_design_v2, cr_16_design_v2,// Control signals
  cr_17,
  out_vertical,
  shift_fixed_point,
  out // output
);

//inputs,outputs
input clk,reset;
input [1:0] PRECISION;
input passing_data_between_pes_cnn;
input signed [INPUT_CHANNEL_DATA_WIDTH -1:0] input_activation;
input signed [ACC_DATA_WIDTH-1:0] input_bias;
input signed [INPUT_CHANNEL_DATA_WIDTH-1:0] input_weight;
input signed [ACC_DATA_WIDTH-1:0] input_neighbour_pe;
input signed [ACC_DATA_WIDTH-1:0] input_vertical;
input signed [ACC_DATA_WIDTH-1:0] input_adder_tree;
input cr_0,cr_1,cr_2,cr_3,cr_4,cr_5,cr_6,cr_7,cr_8,cr_9, cr_10,cr_11,cr_12,cr_13,cr_14,cr_15_design_v2, cr_16_design_v2, cr_17;
input enable_mac, clear_mac;
input [7:0] shift_fixed_point;
output reg signed [ACC_DATA_WIDTH-1:0] out;
output reg signed [ACC_DATA_WIDTH-1:0] out_vertical;
//signals
reg signed [ACC_DATA_WIDTH-1:0] input_neighbour_pe_OR_input_adder_tree;
reg signed [ACC_DATA_WIDTH-1:0] acc_output_shifted;
 reg signed [ACC_DATA_WIDTH-1:0] acc_output_shifted_temp;
reg signed [ACC_DATA_WIDTH -1:0] input_neighbour_pe_reg;
reg signed [ACC_DATA_WIDTH -1:0] input_vertical_reg;
reg signed [ACC_DATA_WIDTH -1:0] next_input_vertical;

reg  signed [INPUT_CHANNEL_DATA_WIDTH -1:0] mult_1, mult_1_muxed_with_design_v2, mult_0, mult_0_muxed_with_design_v2,mult_1_reordered;
reg  signed [INPUT_CHANNEL_DATA_WIDTH -1:0] pre_mult_1;
reg signed [2*INPUT_CHANNEL_DATA_WIDTH -1:0] mult_out, mult_out_temp;
//reg signed [2*INPUT_CHANNEL_DATA_WIDTH -1:0] sum_1;
reg signed [ACC_DATA_WIDTH -1:0] sum_1;
reg signed [ACC_DATA_WIDTH -1:0] sum_0;
reg signed [ACC_DATA_WIDTH -1:0] sum_0_muxed_with_design_v2;
reg signed [ACC_DATA_WIDTH -1:0] pre_sum_0;
reg signed [ACC_DATA_WIDTH-1:0] pre_sum_1;
wire signed [ACC_DATA_WIDTH-1:0] sum_out;
reg signed  [ACC_DATA_WIDTH-1:0] acc_input;
reg signed [ACC_DATA_WIDTH-1:0] acc_output;
reg signed [ACC_DATA_WIDTH-1:0] next_acc_output;

reg signed [ACC_DATA_WIDTH-1:0] acc_output_muxed;
reg signed [ACC_DATA_WIDTH-1:0]  input_relu;
reg signed [ACC_DATA_WIDTH-1:0]  output_relu;
reg signed  [ACC_DATA_WIDTH-1:0]  activation;
reg signed  [ACC_DATA_WIDTH-1:0] pre_out;
reg signed  [ACC_DATA_WIDTH-1:0] pre_out_vertical;
reg overflow_p;
reg overflow_n;
reg overflow_p_0;
reg overflow_p_1;
reg overflow_n_0;
reg overflow_n_1;
`ifdef DESIGN_V2
reg signed [INPUT_CHANNEL_DATA_WIDTH -1:0] mult_00, mult_01, mult_10, mult_11;
reg signed [INPUT_CHANNEL_DATA_WIDTH -1:0] mult_act, mult_wt, sub_out_round;
reg signed [INPUT_CHANNEL_DATA_WIDTH:0] sub_0, sub_out, in_abs, out_abs_0;
reg signed [2*INPUT_CHANNEL_DATA_WIDTH -1:0] out_abs;
reg signed [ACC_DATA_WIDTH -1:0] sum_00;
`endif
reg overflow_p_0_0;
reg overflow_p_0_1;
reg overflow_p_1_0;
reg overflow_p_1_1;
reg overflow_n_0_0;
reg overflow_n_0_1;
reg overflow_n_1_0;
reg overflow_n_1_1;

reg [ACT_DATA_WIDTH -1:0] MAX_value;
reg [ACT_DATA_WIDTH -1:0]  MIN_value;
reg [2:0]mode_precision_layer;
reg [2:0]mode_precision_mult;
reg [2:0]mode_precision_adder;
integer i;

//Clock gate passing data between pes
always @(*)
begin
      for (i=0; i< ACC_DATA_WIDTH; i=i+1)
          if (i>shift_fixed_point)
             acc_output_shifted_temp[ACC_DATA_WIDTH-1-i]=acc_output[ACC_DATA_WIDTH-1-i+shift_fixed_point];
           else
             acc_output_shifted_temp[ACC_DATA_WIDTH-1-i]=acc_output[ACC_DATA_WIDTH-1];
end 

always @(*) begin

case (cr_17)
	//Delete the use input neighbour
	//0: input_neighbour_pe_OR_input_adder_tree= input_neighbour_pe;
	 0: input_neighbour_pe_OR_input_adder_tree= input_adder_tree;

	1: input_neighbour_pe_OR_input_adder_tree = input_adder_tree;
endcase
case(cr_14)
      1'b0: acc_output_shifted = acc_output;
      1'b1: acc_output_shifted=acc_output_shifted_temp;
endcase

 case(cr_8)
  1'b0: acc_output_muxed = acc_output;
  1'b1:  acc_output_muxed=acc_output_shifted_temp;
  endcase 
  case(cr_4)
  1'b0: pre_mult_1= input_weight;
  1'b1:   
      begin
            if (overflow_n == 1)
            pre_mult_1=$signed(MIN_value);
          else if (overflow_p ==1)
            pre_mult_1 = $signed(MAX_value);
          else
            pre_mult_1 = acc_output_muxed[INPUT_CHANNEL_DATA_WIDTH-1:0];
      end 
   default: pre_mult_1= input_weight;

endcase

case(cr_6)
  1'b0: mult_0 = input_activation;
  1'b1: mult_0= 1;
endcase
 
case(cr_5)

  1'b0: pre_sum_1 = input_neighbour_pe;
  1'b1: pre_sum_1 = acc_output_muxed;
 endcase   
 
  
 case(cr_7)
  1'b0: sum_1=pre_sum_1;
  1'b1: sum_1 = 0;
 endcase 
  
case(cr_12)
  1'b0:mult_1=pre_mult_1;
  1'b1:
        if (mode_precision_adder==3'b100) //if the adder is set to 8 bits mode
          mult_1=1;
        else if (mode_precision_adder==3'b010)
          mult_1 = {{4'b1},{4'b1}};
        else 
          mult_1 = {{2'b1},{2'b1},{2'b1},{2'b1}};
 endcase

`ifdef DESIGN_V2
        mult_00 = 0;
        mult_01 = 0;
        mult_10 = 0;
        mult_11 = 0;
        mult_act = 0;
        mult_wt  = 0;
        sub_out = 0;
        in_abs = 0;

 case(cr_15_design_v2)
  1'b0: begin
        mult_00 = 0;
        mult_01 = 0;
        mult_act = mult_0;
        mult_wt  = mult_1;
        end
  1'b1: begin
        mult_00 = mult_0;
        mult_01 = mult_1;
        mult_act = sub_out_round;
        mult_wt  = sub_out_round;
        end
 endcase

 case(cr_16_design_v2)
  1'b0: begin
        sub_out = sub_0;
        sum_00  = mult_out;
        end
  1'b1: begin
        in_abs = sub_0;
        sum_00  = out_abs;
        end
 endcase
`endif
   
case(cr_0)
`ifdef DESIGN_V2
  1'b0: pre_sum_0 = sum_00; 
`else
  1'b0: pre_sum_0 = mult_out;
`endif
  1'b1: pre_sum_0= input_neighbour_pe_OR_input_adder_tree;
endcase

case(cr_1)
  1'b0: acc_input = sum_out;
  1'b1: acc_input = acc_output_muxed;
endcase 

case(cr_2)
  1'b0: begin
    input_relu = 0;
    if (mode_precision_adder==3'b100)
    begin
        if (overflow_n == 1)
          activation=$signed(MIN_value);
        else if (overflow_p ==1)
          activation = $signed(MAX_value);
        else
          activation = acc_output_shifted;
    end
    else
    begin
            activation = acc_output_shifted;
            if (overflow_n_0==1)
                  activation[3:0]=$signed(MIN_value);
            if (overflow_n_1==1)
                  activation[3:0]=$signed(MAX_value);
            if (overflow_p_0==1)
                activation[7:4]=$signed(MIN_value);
            if (overflow_p_1==1)
                 activation[7:4]=$signed(MAX_value);
            
    end
  end 
  1'b1: begin
    input_relu = acc_output_shifted;

    if (overflow_n == 1)
      activation=0;
    else if (overflow_p ==1)
      activation = $signed(MAX_value);
    else
      activation = output_relu;
    
  end
endcase

case(cr_3)
1'b0:  pre_out = activation;
1'b1: pre_out = input_neighbour_pe_reg;
endcase 



case(cr_9)
1'b0: out= pre_out;
1'b1: out = acc_output_shifted;
endcase

case(cr_11)
1'b0: pre_out_vertical= activation;
1'b1: pre_out_vertical = input_vertical_reg;
endcase

// vertical sending
case(cr_10)
1'b0: out_vertical = pre_out_vertical;
1'b1: out_vertical =  acc_output_shifted;
endcase

 
case(cr_13)
1'b0:   sum_0=pre_sum_0;
1'b1:   sum_0=input_bias;
endcase



end


`ifdef DESIGN_V2
assign out_abs = {7'b0, out_abs_0};
`endif

// RELU
always @(*)
begin
  if (input_relu[ACC_DATA_WIDTH-1] == 1'b1) begin
    output_relu = 0;
  end
  else begin
    output_relu = input_relu;
  end
end

// ACC reg
//
always @(*)
begin
     if (clear_mac || !((cr_8==0)&&(cr_1==1)))	 
	if (clear_mac==0)
		next_acc_output=acc_input;
	else
		next_acc_output=0;
     else
	        next_acc_output=acc_output;
end

always @(posedge clk or negedge reset)
begin
  if (!reset)
        acc_output <= 0;
  else
    if (enable_mac)
        acc_output <= next_acc_output;
    

end

// Registered output from neighboor PE
always @(posedge clk or negedge reset)
begin
  if (!reset)
        begin
        //input_neighbour_pe_reg <= 0;
        input_vertical_reg <= 0;
        end
  else
      if (enable_mac)
        begin
        //input_neighbour_pe_reg <= input_neighbour_pe;
        input_vertical_reg <= next_input_vertical;
        end
end

//next input vertical
always @(*)
begin
	if (passing_data_between_pes_cnn)
	next_input_vertical = input_vertical;
        else
	next_input_vertical = input_vertical_reg;
end

// Overflow logic
always @(*)
begin
    case(PRECISION)
    0:  //8 bits
      begin 
      MIN_value = 1<<(ACT_DATA_WIDTH-1);
      MAX_value = {(ACT_DATA_WIDTH-1){1'b1}};
      end
    1: // 4 bits
      begin 
      MIN_value = 1<<(ACT_DATA_WIDTH/2-1);
      MAX_value = {(ACT_DATA_WIDTH/2-1){1'b1}};
      end
    2: // 2 bits
      begin 
      MIN_value = 1<<(ACT_DATA_WIDTH/4-1);
      MAX_value = {(ACT_DATA_WIDTH/4-1){1'b1}};
      end
    default:
      begin 
      MIN_value = 1<<(ACT_DATA_WIDTH/2-1);
      MAX_value = {(ACT_DATA_WIDTH/2-1){1'b1}};
      end
    endcase
end 

always @(*)
begin
  overflow_p_0=0;
  overflow_p_1=0;
  overflow_n_0=0;
  overflow_n_1=0;
  overflow_n=0;
  overflow_p=0;
   overflow_p_0_0=0;
 overflow_p_0_1=0;
 overflow_p_1_0=0;
 overflow_p_1_1=0;
 overflow_n_0_0=0;
 overflow_n_0_1=0;
 overflow_n_1_0=0;
 overflow_n_1_1=0;
 
  if (mode_precision_adder==3'b100)
      case(PRECISION)
      0:
        begin
                    if (acc_output_shifted <  $signed(MIN_value[7:0]))
                      overflow_n = 1;
                    else
                      overflow_n = 0;   
                    if (acc_output_shifted > $signed(MAX_value[7:0]))
                      overflow_p = 1;
                    else
                      overflow_p = 0; 
         end
       1:
        begin
      
                      if (acc_output_shifted <  $signed(MIN_value[3:0]))
                        overflow_n = 1;
                      else
                        overflow_n = 0;   
                      if (acc_output_shifted > $signed(MAX_value[3:0]))
                        overflow_p = 1;
                      else
                        overflow_p = 0; 
                        
                        
                      if (mode_precision_adder==3'b010)
                            begin
                                if ($signed(acc_output_shifted[3:0]) <  $signed(MIN_value[3:0]))
                                      overflow_n_0 =1;
                                if ($signed(acc_output_shifted[7:4]) <  $signed(MIN_value[3:0]))
                                    overflow_n_1 =1;
                                 if ($signed(acc_output_shifted[3:0]) >  $signed(MIN_value[3:0]))
                                      overflow_p_0 =1;
                                if ($signed(acc_output_shifted[7:4]) >  $signed(MIN_value[3:0]))
                                    overflow_p_1 =1;
                            end

                        
         end
         
         2:     
         begin
                if (acc_output_shifted <  $signed(MIN_value[1:0]))
                        overflow_n = 1;
                      else
                        overflow_n = 0;   
                      if (acc_output_shifted > $signed(MAX_value[1:0]))
                        overflow_p = 1;
                      else
                        overflow_p = 0; 
                        
                        
                      if (mode_precision_adder==3'b001)
                            begin
                                    
                                    
                               if ($signed(acc_output_shifted[1:0]) <  $signed(MIN_value[1:0]))
                                      overflow_n_0_0 =1;
                              if ($signed(acc_output_shifted[3:2]) <  $signed(MIN_value[1:0]))
                                    overflow_n_0_1 =1;
                               if ($signed(acc_output_shifted[5:4]) <  $signed(MIN_value[1:0]))
                                    overflow_n_1_0 =1;     
                               if ($signed(acc_output_shifted[7:6]) <  $signed(MIN_value[1:0]))
                                    overflow_n_1_1 =1;         
                                    
                                if ($signed(acc_output_shifted[1:0]) >  $signed(MIN_value[1:0]))
                                      overflow_p_0_0 =1;
                              if ($signed(acc_output_shifted[3:2]) >  $signed(MIN_value[1:0]))
                                    overflow_p_0_1 =1;
                               if ($signed(acc_output_shifted[5:4]) >  $signed(MIN_value[1:0]))
                                    overflow_p_1_0 =1;     
                               if ($signed(acc_output_shifted[7:6]) >  $signed(MIN_value[1:0]))
                                    overflow_p_1_1 =1;         

                            end
         end
      endcase 
       
end


// PRECISION SCALABILITY
always @(*)
begin
    case(PRECISION)
      0:mode_precision_layer=3'b100;//8 bits
      1:mode_precision_layer=3'b010;//4 bits
      2:mode_precision_layer=3'b001; //2 bits
      default: mode_precision_layer=3'b100;//8 bits
    endcase
end 

always @(*)
begin
    case(mode_precision_mult) // if the mode of the multiplier is set to 8 bits or 4 bits
    3'b100: mult_1_reordered=mult_1_muxed_with_design_v2;
    3'b010: mult_1_reordered={{mult_1_muxed_with_design_v2[3:0]},{mult_1_muxed_with_design_v2[7:4]}};
    3'b001: mult_1_reordered={{mult_1_muxed_with_design_v2[1:0]},{mult_1_muxed_with_design_v2[3:2]},{mult_1_muxed_with_design_v2[5:4]},{mult_1_muxed_with_design_v2[7:6]}};
    default:  mult_1_reordered=mult_1_muxed_with_design_v2;
    endcase
end




always @(*)
  begin
      //sometimes in the same layer, the multiplier must be set to 8 bit multiplication
      
        if (!cr_6 && !cr_12 && !cr_4 &&!cr_0) // if the MAC operation of act*weight is set
            mode_precision_mult = mode_precision_layer;
        else
            mode_precision_mult = 3'b100; //set to 8 bit multiplier
  end
  
always @(*)
  begin
      //sometimes in the same layer, the adder must be set to 4 bit sum
      
        if (cr_5 && !cr_7 && !cr_0 && !cr_6 &&cr_12) // if it is EWS operation
            mode_precision_adder = mode_precision_layer;
        else
            mode_precision_adder= 3'b100; //set to 8 bit multiplier
  end 
  
always @(*)  
begin
  case(mode_precision_mult)
  3'b100: mult_out=mult_out_temp;
  3'b010: mult_out= {{7{mult_out_temp[12]}},{mult_out_temp[12:4]}};
  3'b001: mult_out = {{10{mult_out_temp[11]}},{mult_out_temp[11:6]}};
  default: mult_out=mult_out_temp;
  endcase
end
    

always @(*)
begin
`ifdef DESIGN_V2
  sum_0_muxed_with_design_v2 = sum_0;
  sub_0 = mult_00 - mult_01;
  mult_1_muxed_with_design_v2=mult_wt;
  mult_0_muxed_with_design_v2=mult_act;
`else
  sum_0_muxed_with_design_v2 = sum_0;
  mult_1_muxed_with_design_v2=mult_1;
  mult_0_muxed_with_design_v2=mult_0;
`endif
end


`ifdef DESIGN_V2

// ABS for NORM
always @(*)
begin
  if (in_abs[ACT_DATA_WIDTH] == 1'b1) begin
    out_abs_0 = -in_abs;
  end
  else begin
    out_abs_0 = in_abs;
  end
end

// Rounding subtraction output
always @(*)
begin
  sub_out_round = sub_out[ACT_DATA_WIDTH:0] + 1'b1;//sub_out[0];
end
`endif

// Multiplier
M88_top MULT_0(
    .a(mult_0_muxed_with_design_v2),
    .w(mult_1_reordered),
    .mode_8b(mode_precision_mult[2]),
    .mode_4b(mode_precision_mult[1]), 
    .mode_2b(mode_precision_mult[0]),   
    .p(mult_out_temp)
    );
     
// Adder     
adder ADD_0(
  .accumulation_between_pes(cr_0 || cr_13), //cr_0 is set to 1 when there is accumulation of results between PEs, cr_13 is set for bias adding
  .mode_precision_adder(mode_precision_adder),
  .mode_precision_mult(mode_precision_mult),
  .mode_precision_layer(mode_precision_layer),
  .input_0(sum_0_muxed_with_design_v2),
  .input_1(sum_1),
  .out(sum_out)
);
 
 
endmodule
