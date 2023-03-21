`define DESIGN_V2

import parameters::*;

// Array of Processing Elements and Input Buffer. 
// The input buffer saves data for CNN processing
// The data is sent to the PEs for calculation and retrieved through the output_array signal
module array_pes 
(
`ifdef DESIGN_V2
  cr_fifo,
  enable_strided_conv,
  enable_deconv,
  odd_X_tile,
`endif
  clk,reset,enable, 
  enable_BUFFERED_OUTPUT,
  INPUT_PRECISION,
  OUTPUT_PRECISION,
  shift_input_buffer,
  enable_bias_32bits,
  addr_bias_32bits,
 done_layer,  
  clear, // clear all the memory elements
  enable_input_fifo, // enable the shifting of the input buffer fifo
 passing_data_between_pes_cnn,
  mode, // FC or CNN
  loading_in_parallel, // Loading a value in parallel to input buffer
  CR_PE_array, // Control signals array
  fc_weights_array, // fc weights
  cnn_input, // input activation for cnn (1 element)
  cnn_weights_array, // cnn weights (N elements)
  fc_input_array, // input activations (N elements)
  output_array, // N output elements from PE array
  output_array_vertical,
  shift_fixed_point // Shift fixed point
);

`ifdef DESIGN_V2
input [1:0] cr_fifo;
input enable_strided_conv;
input enable_deconv;
input odd_X_tile;
input done_layer;
`endif
//IO
input passing_data_between_pes_cnn;
input clk, reset, enable, clear;
input enable_bias_32bits;
input [1:0] addr_bias_32bits;

input enable_BUFFERED_OUTPUT;
input [1:0] INPUT_PRECISION;
input [1:0] OUTPUT_PRECISION;
input [2:0] mode;
input loading_in_parallel;
input enable_input_fifo;
input [NUMBER_OF_CR_SIGNALS-1:0] CR_PE_array[(N_DIM_ARRAY-1):0][(N_DIM_ARRAY-1):0];
input signed [WEIGHT_DATA_WIDTH-1:0] cnn_weights_array[(N_DIM_ARRAY-1):0];
input signed [WEIGHT_DATA_WIDTH-1:0] fc_weights_array[(N_DIM_ARRAY-1):0][(N_DIM_ARRAY-1):0];
input signed  [WEIGHT_DATA_WIDTH-1:0] fc_input_array[N_DIM_ARRAY-1:0];
input signed [INPUT_CHANNEL_DATA_WIDTH-1:0] cnn_input [N_DIM_ARRAY-1:0];
input [7:0] shift_fixed_point;
input [MAXIMUM_DILATION_BITS-1:0] shift_input_buffer;
output reg signed [ACT_DATA_WIDTH-1:0] output_array[N_DIM_ARRAY-1:0];
output reg  signed  [ACT_DATA_WIDTH-1:0] output_array_vertical[(N_DIM_ARRAY-1):0];
//signals
reg signed [ACC_DATA_WIDTH-1:0] bias_32bits[N_DIM_ARRAY-1:0];
reg signed [ACC_DATA_WIDTH-1:0] input_bias[N_DIM_ARRAY-1:0];
 reg signed [ACT_DATA_WIDTH-1:0] output_array_temp[N_DIM_ARRAY-1:0];
wire signed [WEIGHT_DATA_WIDTH-1:0] cnn_weights_array_reg[(N_DIM_ARRAY-1):0];
wire signed [WEIGHT_DATA_WIDTH-1:0] fc_weights_array_reg [(N_DIM_ARRAY-1):0][(N_DIM_ARRAY-1):0];
reg signed  [WEIGHT_DATA_WIDTH -1:0]  second_input_PE_array[(N_DIM_ARRAY-1):0][(N_DIM_ARRAY-1):0];
wire signed  [WEIGHT_DATA_WIDTH*N_DIM_ARRAY -1:0]  second_input_PE_array_unrolled[(N_DIM_ARRAY-1):0];
wire signed  [INPUT_CHANNEL_DATA_WIDTH-1:0] input_buffer_array[(N_DIM_ARRAY-1):0];
wire signed [ACC_DATA_WIDTH-1:0] result_adder[N_DIM_ARRAY-1:0];

wire  signed  [ACC_DATA_WIDTH-1:0] output_PE_array[(N_DIM_ARRAY-1):0][(N_DIM_ARRAY-1):0];
wire signed [ACC_DATA_WIDTH-1:0] input_2_array[(N_DIM_ARRAY-1):0][(N_DIM_ARRAY-1):0];
wire signed [ACC_DATA_WIDTH-1:0] input_2_vertical_array[(N_DIM_ARRAY-1):0][(N_DIM_ARRAY-1):0];
wire  signed  [ACC_DATA_WIDTH-1:0] vertical_signals[(N_DIM_ARRAY-1):0][(N_DIM_ARRAY-1):0];
wire signed [ACC_DATA_WIDTH-1:0] adder_tree_signals[N_DIM_ARRAY-1:0][N_DIM_ARRAY-1:0];
 reg signed [ACT_DATA_WIDTH-1:0] BUFFERED_OUTPUT_0[N_DIM_ARRAY-1:0];
 reg signed [ACT_DATA_WIDTH-1:0] BUFFERED_OUTPUT_1[N_DIM_ARRAY-1:0];
  reg signed [ACT_DATA_WIDTH-1:0] BUFFERED_OUTPUT_2[N_DIM_ARRAY-1:0];
//gen variables
integer m;
integer n;
genvar i; 
genvar j;
genvar k;



//32 bits bias 
always @(posedge clk or negedge reset)
begin
   if (!reset)
        for (m=0; m<(N_DIM_ARRAY); m=m+1)
          bias_32bits[m] <= 0;
   else
       if (enable)
          begin
          if (enable_bias_32bits) 
              case(addr_bias_32bits)
              0:for (m=0; m<(N_DIM_ARRAY); m=m+1)
                  bias_32bits[m][7:0]<=cnn_weights_array[m];
              1:for (m=0; m<(N_DIM_ARRAY); m=m+1)
                  bias_32bits[m][15:8]<=cnn_weights_array[m];
              2:for (m=0; m<(N_DIM_ARRAY); m=m+1)
                  bias_32bits[m][23:16]<=cnn_weights_array[m];
              3:for (m=0; m<(N_DIM_ARRAY); m=m+1)
                  bias_32bits[m][31:24]<=cnn_weights_array[m];
              endcase    
            end
end

//Input buffer
input_buffer  input_buffer_instance(
  .clk(clk),.reset(reset),
  .shift_input_buffer(shift_input_buffer),
  .loading_in_parallel(loading_in_parallel),
  .parallel_input_array(fc_input_array),
  .serial_input(cnn_input),
  .mode(mode),
  .clear(clear),
  .enable(enable_input_fifo),
`ifdef DESIGN_V2
  .cr_fifo(cr_fifo),
  .enable_strided_conv(enable_strided_conv),
  .enable_deconv(enable_deconv),
  .odd_X_tile(odd_X_tile),
`endif
  .output_array(input_buffer_array)
);

generate
    for (i=0; i<(N_DIM_ARRAY); i=i+1) begin : dim_0 // <-- example block name
      for (j=0; j<(N_DIM_ARRAY); j=j+1) begin : dim_1 // <-- example block name
        assign second_input_PE_array_unrolled[i][INPUT_CHANNEL_DATA_WIDTH*(j+1)-1:INPUT_CHANNEL_DATA_WIDTH*(j)]=second_input_PE_array[i][j];
      end
    end 
  endgenerate

  
  // Bias muxing
  
  always @(*)
  begin
     //default value
        for (m=0; m<(N_DIM_ARRAY); m=m+1)
         input_bias[m]=0;
       ////////////////////////
 
      if (mode == MODE_CNN)
        input_bias = bias_32bits;
      else
        for (m=0; m<(N_DIM_ARRAY); m=m+1)
          input_bias[m] = second_input_PE_array_unrolled[m][31:0];
  end
//Generation of PE array
generate
    for (i=0; i<(N_DIM_ARRAY); i=i+1) begin : row // <-- example block name

// Using of an adder tree
//       adder_tree ADDER_TREE_i(
//       .operands(output_PE_array[i])
//       );
    for (j=0; j < (N_DIM_ARRAY); j=j+1) begin:        column

      
      //horizontal shifting
      if (j != (N_DIM_ARRAY-1)) // If this is not the last element in the row 
        assign input_2_array[i][j] =output_PE_array[i][j+1];
      else
       assign input_2_array[i][j] ={ACC_DATA_WIDTH{1'b0}};
      
      //vertical shifting
    if (i!= (N_DIM_ARRAY-1))
       assign input_2_vertical_array[i][j]= vertical_signals[i+1][j];
    else
      assign input_2_vertical_array[i][j]= {ACC_DATA_WIDTH{1'b0}};
      
    if (j==0) 
      assign adder_tree_signals[i][j]= result_adder[i];
    else
     assign adder_tree_signals[i][j]= 0;
 

        pe pe_i(
  .clk(clk), .reset(reset),
  .PRECISION(INPUT_PRECISION),
   .passing_data_between_pes_cnn(passing_data_between_pes_cnn),
    .shift_fixed_point(shift_fixed_point),
   .input_activation(input_buffer_array[j]),
   .input_weight(second_input_PE_array[i][j]),
   .input_bias(input_bias[i]),
   .input_neighbour_pe(input_2_array[i][j]),
   .input_adder_tree(adder_tree_signals[i][j]),
  .cr_0(CR_PE_array[i][j][0]),
  .cr_1(CR_PE_array[i][j][1]),
  .cr_2(CR_PE_array[i][j][2]),
  .cr_3(CR_PE_array[i][j][3]),
  .cr_4(CR_PE_array[i][j][4]), 
  .cr_5(CR_PE_array[i][j][5]), 
  .cr_6(CR_PE_array[i][j][6]), 
  .cr_7(CR_PE_array[i][j][7]), 
  .cr_8(CR_PE_array[i][j][8]),
  .cr_9(CR_PE_array[i][j][9]),
  .cr_10(CR_PE_array[i][j][10]),
  .cr_11(CR_PE_array[i][j][11]),
  .cr_12(CR_PE_array[i][j][12]),
  .cr_13(CR_PE_array[i][j][13]),
  .cr_14(CR_PE_array[i][j][14]),
  .cr_15_design_v2(CR_PE_array[i][j][15]),
  .cr_16_design_v2(CR_PE_array[i][j][16]),
  .cr_17(CR_PE_array[i][j][17]),
  .input_vertical(input_2_vertical_array[i][j]),
  .out_vertical(vertical_signals[i][j]),
  .clear_mac(clear),.enable_mac(enable),
  .out(output_PE_array[i][j])
);
end
end

endgenerate     
    
//Adder Trees

generate
    for (i=0; i<(N_DIM_ARRAY); i=i+1) begin : adder_row // <-- example block name
    
    adder_tree adder_tree_i(
.use_adder_tree(1'b1),
.operand_0(output_PE_array[i][0]),
.operand_1(output_PE_array[i][1]),
.operand_2(output_PE_array[i][2]),
.operand_3(output_PE_array[i][3]),
.operand_4(output_PE_array[i][4]),
.operand_5(output_PE_array[i][5]),
.operand_6(output_PE_array[i][6]),
.operand_7(output_PE_array[i][7]),
.result(result_adder[i])
    );
    end

endgenerate    
    
// Use of FC or CNN weights for second input of each processing element
// Mode=0 for FC, Mode=1 for CNN
always @(*)
begin
  if ((mode==MODE_FC) || (mode==MODE_EWS)) 
    begin
      for (m=0; m< N_DIM_ARRAY; m=m+1)
       for (n=0; n< N_DIM_ARRAY; n=n+1)
        second_input_PE_array[m][n] = fc_weights_array[m][n];
    end
  else
    begin
      for (m=0; m< N_DIM_ARRAY; m=m+1)
       for (n=0; n< N_DIM_ARRAY; n=n+1)
        second_input_PE_array[m][n]=cnn_weights_array[m];
    end
  end    

// Output of PE array
always @(*)
begin 
  //default value
  for (m=0; m< N_DIM_ARRAY; m=m+1)
    output_array_temp[m]=0;
  ////////////////////////////////
  
  for (m=0; m< N_DIM_ARRAY; m=m+1)
    begin
    if ((mode==MODE_CNN) || (mode==MODE_EWS) ) //if it is a CNN or EWS take the outputs vertically
      output_array_temp[m] = vertical_signals[0][m];
    else
      output_array_temp[m] = output_PE_array[m][0];
    end
end

//Buffering data if 4 bit precision is used.
always @(posedge clk or negedge reset)
begin
  if (!reset)
    for (m=0; m< N_DIM_ARRAY; m=m+1)
      begin
      BUFFERED_OUTPUT_0[m] <=0;
      BUFFERED_OUTPUT_1[m] <=0;
      BUFFERED_OUTPUT_2[m] <=0;
      end
  else
    if (enable==1)
    begin
    
    //if (clear) // BUG FIXING : 20 MAY 2020, CLEARING OF BUFFERS 
    if (done_layer) // BUG FIXING : 29 June 2020, CLEARING OF BUFFERS with enable signal.
    
 	begin
         for (m=0; m< N_DIM_ARRAY; m=m+1)
          begin
           BUFFERED_OUTPUT_0[m] <=0; 
           BUFFERED_OUTPUT_1[m] <=0;
           BUFFERED_OUTPUT_2[m] <=0;
          end
	end
    else if (enable_BUFFERED_OUTPUT)
      begin
        BUFFERED_OUTPUT_0 <= output_array_temp;
        BUFFERED_OUTPUT_1 <= BUFFERED_OUTPUT_0;
        BUFFERED_OUTPUT_2 <= BUFFERED_OUTPUT_1;
      end
   end   
end  
always @(*)
begin
    case(OUTPUT_PRECISION)
    0: output_array = output_array_temp;
    //temp
    1: 
    
         if (mode!=MODE_CNN)
         begin
         for (m=0; m< N_DIM_ARRAY; m=m+1)
          begin
           if (m< (N_DIM_ARRAY/2))
             output_array[m] = {{BUFFERED_OUTPUT_0[2*m+1][INPUT_CHANNEL_DATA_WIDTH/2-1:0]},{BUFFERED_OUTPUT_0[2*m][INPUT_CHANNEL_DATA_WIDTH/2-1:0]}};
           else
             output_array[m] = {{output_array_temp[2*(m-(N_DIM_ARRAY/2))+1][INPUT_CHANNEL_DATA_WIDTH/2-1:0]},{output_array_temp[2*(m-(N_DIM_ARRAY/2))][INPUT_CHANNEL_DATA_WIDTH/2-1:0]}};
           end 
        end
        else
          begin
          for (m=0; m< N_DIM_ARRAY; m=m+1)
            output_array[m] = {{output_array_temp[m][INPUT_CHANNEL_DATA_WIDTH/2-1:0]},{BUFFERED_OUTPUT_0[m][INPUT_CHANNEL_DATA_WIDTH/2-1:0]}};
            end
    2: //for (m=0; m< N_DIM_ARRAY; m=m+1)
          // output_array[m] = {{output_array_temp[m][INPUT_CHANNEL_DATA_WIDTH/4-1:0]},{BUFFERED_OUTPUT_0[m][INPUT_CHANNEL_DATA_WIDTH/4-1:0]},{BUFFERED_OUTPUT_1[m][INPUT_CHANNEL_DATA_WIDTH/4-1:0]},{BUFFERED_OUTPUT_2[m][INPUT_CHANNEL_DATA_WIDTH/4-1:0]}};
    
    
    
    
    if (mode!=MODE_CNN)
         begin
         for (m=0; m< N_DIM_ARRAY; m=m+1)
          begin
           if (m< (N_DIM_ARRAY/4))
            output_array[m] = {{BUFFERED_OUTPUT_2[4*m+3][1:0]},{BUFFERED_OUTPUT_2[4*m+2][1:0]},{BUFFERED_OUTPUT_2[4*m+1][1:0]},{BUFFERED_OUTPUT_2[4*m][1:0]}};
           else if (m < (N_DIM_ARRAY/2))
            output_array[m] = {{BUFFERED_OUTPUT_1[4*(m-(N_DIM_ARRAY/4))+3][1:0]},{BUFFERED_OUTPUT_1[4*(m-(N_DIM_ARRAY/4))+2][1:0]},{BUFFERED_OUTPUT_1[4*(m-(N_DIM_ARRAY/4))+1][1:0]},{BUFFERED_OUTPUT_1[4*(m-(N_DIM_ARRAY/4))][1:0]}};
           else if (m < (3*N_DIM_ARRAY/4))
             output_array[m] = {{BUFFERED_OUTPUT_0[4*(m-(N_DIM_ARRAY/2))+3][1:0]},{BUFFERED_OUTPUT_0[4*(m-(N_DIM_ARRAY/2))+2][1:0]},{BUFFERED_OUTPUT_0[4*(m-(N_DIM_ARRAY/2))+1][1:0]},{BUFFERED_OUTPUT_0[4*(m-(N_DIM_ARRAY/2))][1:0]}};
            else
            output_array[m] = {{output_array_temp[4*(m-(3*N_DIM_ARRAY/4))+3][1:0]},{output_array_temp[4*(m-(3*N_DIM_ARRAY/4))+2][1:0]},{output_array_temp[4*(m-(3*N_DIM_ARRAY/4))+1][1:0]},{output_array_temp[4*(m-(3*N_DIM_ARRAY/4))][1:0]}};
           end 
        end
        else
          for (m=0; m< N_DIM_ARRAY; m=m+1)
            output_array[m] = {{output_array_temp[m][1:0]},{BUFFERED_OUTPUT_0[m][1:0]},{BUFFERED_OUTPUT_1[m][1:0]},{BUFFERED_OUTPUT_2[m][1:0]}};

            
    default: output_array = output_array_temp;
    endcase
end
endmodule
