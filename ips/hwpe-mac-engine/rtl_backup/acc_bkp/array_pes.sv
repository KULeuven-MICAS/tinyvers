import parameters::*;

// Array of Processing Elements and Input Buffer. 
// The input buffer saves data for CNN processing
// The data is sent to the PEs for calculation and retrieved through the output_array signal
module array_pes 
(
  clk,reset,enable, 
  shift_input_buffer,
  clear, // clear all the memory elements
  enable_input_fifo, // enable the shifting of the input buffer fifo
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
//IO
input clk, reset, enable, clear;
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
wire signed [WEIGHT_DATA_WIDTH-1:0] cnn_weights_array_reg[(N_DIM_ARRAY-1):0];
wire signed [WEIGHT_DATA_WIDTH-1:0] fc_weights_array_reg [(N_DIM_ARRAY-1):0][(N_DIM_ARRAY-1):0];
reg signed  [WEIGHT_DATA_WIDTH -1:0]  second_input_PE_array[(N_DIM_ARRAY-1):0][(N_DIM_ARRAY-1):0];
wire signed  [INPUT_CHANNEL_DATA_WIDTH-1:0] input_buffer_array[(N_DIM_ARRAY-1):0];
wire  signed  [ACC_DATA_WIDTH-1:0] output_PE_array[(N_DIM_ARRAY-1):0][(N_DIM_ARRAY-1):0];
wire signed [ACC_DATA_WIDTH-1:0] input_2_array[(N_DIM_ARRAY-1):0][(N_DIM_ARRAY-1):0];
wire signed [ACC_DATA_WIDTH-1:0] input_2_vertical_array[(N_DIM_ARRAY-1):0][(N_DIM_ARRAY-1):0];
wire  signed  [ACC_DATA_WIDTH-1:0] vertical_signals[(N_DIM_ARRAY-1):0][(N_DIM_ARRAY-1):0];
//gen variables
integer m;
integer n;
genvar i; 
genvar j;

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
  .output_array(input_buffer_array)
);

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
      
        pe pe_i(
  .clk(clk), .reset(reset),
    .shift_fixed_point(shift_fixed_point),
   .input_activation(input_buffer_array[j]),.input_weight(second_input_PE_array[i][j]),
   .input_neighbour_pe(input_2_array[i][j]),
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
  .input_vertical(input_2_vertical_array[i][j]),
  .out_vertical(vertical_signals[i][j]),
  .clear_mac(clear),.enable_mac(enable),
  .out(output_PE_array[i][j])
);
end
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
  for (m=0; m< N_DIM_ARRAY; m=m+1)
    begin
    if ((mode==MODE_CNN) || (mode==MODE_EWS) ) //if it is a CNN or EWS take the outputs vertically
      output_array[m] = vertical_signals[0][m];
    else
      output_array[m] = output_PE_array[m][0];
    end
end

endmodule