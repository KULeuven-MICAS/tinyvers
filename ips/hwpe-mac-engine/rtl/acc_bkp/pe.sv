import parameters::*;

// Processing element
// Computes MAC operations based on control signals

module pe 
(
  clk,reset,enable_mac,
  clear_mac, // Clear signal
  input_activation, // Activation input
  input_weight, // Weight activation
  input_neighbour_pe, // Input from neighboor PE
  input_vertical,
  cr_0,cr_1,cr_2,cr_3,cr_4,cr_5, cr_6, cr_7,cr_8,cr_9, cr_10, cr_11,cr_12,// Control signals
  out_vertical,
  shift_fixed_point,
  out // output
);

//inputs,outputs
input clk,reset;
input signed [INPUT_CHANNEL_DATA_WIDTH -1:0] input_activation,input_weight;
input signed [ACC_DATA_WIDTH-1:0] input_neighbour_pe;
input signed [ACC_DATA_WIDTH-1:0] input_vertical;
input cr_0,cr_1,cr_2,cr_3,cr_4,cr_5,cr_6,cr_7,cr_8,cr_9, cr_10,cr_11,cr_12;
input enable_mac, clear_mac;
input [7:0] shift_fixed_point;
output reg signed [ACC_DATA_WIDTH-1:0] out;
output reg signed [ACC_DATA_WIDTH-1:0] out_vertical;
//signals
reg signed [ACC_DATA_WIDTH -1:0] input_neighbour_pe_reg;
reg signed [ACC_DATA_WIDTH -1:0] input_vertical_reg;
reg  signed [INPUT_CHANNEL_DATA_WIDTH -1:0] mult_1, mult_0;
reg  signed [INPUT_CHANNEL_DATA_WIDTH -1:0] pre_mult_1;
reg signed [2*INPUT_CHANNEL_DATA_WIDTH -1:0] mult_out;
reg signed [2*INPUT_CHANNEL_DATA_WIDTH -1:0] sum_1;
reg signed [ACC_DATA_WIDTH -1:0] sum_0;
reg signed [ACC_DATA_WIDTH-1:0] pre_sum_1;
reg signed [ACC_DATA_WIDTH-1:0] sum_out;
reg signed  [ACC_DATA_WIDTH-1:0] acc_input;
reg signed [ACC_DATA_WIDTH-1:0] acc_output;
reg signed [ACC_DATA_WIDTH-1:0] acc_output_muxed;
reg signed [ACC_DATA_WIDTH-1:0]  input_relu;
reg signed [ACC_DATA_WIDTH-1:0]  output_relu;
reg signed  [ACC_DATA_WIDTH-1:0]  activation;
reg signed  [ACC_DATA_WIDTH-1:0] pre_out;
reg signed  [ACC_DATA_WIDTH-1:0] pre_out_vertical;
reg overflow_p;
reg overflow_n;
wire [ACT_DATA_WIDTH -1:0] MAX_value;
wire [ACT_DATA_WIDTH -1:0]  MIN_value;

integer i;

always @(*) begin

case(cr_8)
  1'b0: acc_output_muxed = acc_output;
  1'b1: //acc_output_muxed =acc_output >> shift_fixed_point;
     begin
         for (i=0; i< ACC_DATA_WIDTH; i=i+1)
           if (i>shift_fixed_point)
             acc_output_muxed[ACC_DATA_WIDTH-1-i]=acc_output[ACC_DATA_WIDTH-1-i+shift_fixed_point];
           else
             acc_output_muxed[ACC_DATA_WIDTH-1-i]=acc_output[ACC_DATA_WIDTH-1];
     end
  
  endcase
  
case(cr_4)
  1'b0: pre_mult_1= input_weight;
  1'b1: pre_mult_1 = acc_output_muxed;
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
  1'b1: mult_1=1;
 endcase

 

  
case(cr_0)
  1'b0: sum_0 = mult_out;
  1'b1: sum_0= input_neighbour_pe;
endcase

case(cr_1)
  1'b0: acc_input = sum_out;
  1'b1: acc_input = acc_output_muxed;
endcase



case(cr_2)
  1'b0: begin
    input_relu = 0;
    
    if (overflow_n == 1)
      activation=$signed(MIN_value);
    else if (overflow_p ==1)
      activation = $signed(MAX_value);
    else
      activation = acc_output;
  end 
  1'b1: begin
    input_relu = acc_output;

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
1'b0: out = pre_out;
1'b1: out = acc_output;
endcase

case(cr_11)
1'b0: pre_out_vertical= activation;
1'b1: pre_out_vertical = input_vertical_reg;
endcase

// vertical sending
case(cr_10)
1'b0: out_vertical = pre_out_vertical;
1'b1: out_vertical =  acc_output;
endcase


end


//Operations (MULT and SUM)
always @(*)
begin
  mult_out = mult_1*mult_0;
  sum_out = sum_1 + sum_0;
end

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
always @(posedge clk or negedge reset)
begin
  if (!reset)
        acc_output <= 0;
  else
       if (clear_mac == 0)
        acc_output <= acc_input;
       else
        acc_output <= 0;
end

// Registered output from neighboor PE
always @(posedge clk or negedge reset)
begin
  if (!reset)
        begin
        input_neighbour_pe_reg <= 0;
        input_vertical_reg <= 0;
        end
  else
        begin
        input_neighbour_pe_reg <= input_neighbour_pe;
        input_vertical_reg <= input_vertical;
        end
end

// Overflow logic
assign MIN_value = 1<<(ACT_DATA_WIDTH-1);
assign MAX_value = {(ACT_DATA_WIDTH-1){1'b1}};
always @(*)
begin
  if (acc_output <  $signed(MIN_value))
    overflow_n = 1;
  else
    overflow_n = 0;   
   if (acc_output > $signed(MAX_value))
    overflow_p = 1;
  else
    overflow_p = 0; 
end
endmodule