import parameters::*;

// Nonlinear function generator and pooling operation
// Generates a vector of N values with N inputs
module nonlinear_block(
clk, reset,
PRECISION,
 wr_en_ext_lut,
   wr_addr_ext_lut,
   wr_data_ext_lut,
NUMBER_OF_ACTIVATION_CYCLES,
SHIFT_FIXED_POINT,
enable_nonlinear_block, // Start execution of Nonlinear function
enable_pooling,
enable_sig_tanh,
PADDED_C_X,
PADDED_O_X,
type_nonlinear_function, // Type of nonlinear function
input_channel_rd_addr,
input_channel_rd_en,
read_word, // N input values
wr_en_output_buffer_nl,
finished_activation,
wr_addr_nl,
output_word // N output values
);

input clk, reset;
input wr_en_ext_lut;
input [1:0] PRECISION;
input [LUT_ADDR-1:0]wr_addr_ext_lut;
input signed [LUT_DATA_WIDTH-1:0] wr_data_ext_lut;
input enable_nonlinear_block;
input enable_pooling;
input enable_sig_tanh;
input [7:0] SHIFT_FIXED_POINT;
input [15:0] PADDED_C_X;
input [15:0] PADDED_O_X;
input [31:0] NUMBER_OF_ACTIVATION_CYCLES; 
input [NUMBER_OF_NONLINEAR_FUNCTIONS_BITS-1:0] type_nonlinear_function;
input signed [INPUT_CHANNEL_DATA_WIDTH-1:0]  read_word[N_DIM_ARRAY-1:0];
output reg [INPUT_CHANNEL_ADDR_SIZE-1:0] input_channel_rd_addr; // Address to be read from the activation memory
output reg input_channel_rd_en; // Enable to read from the activation memory
output reg wr_en_output_buffer_nl;
output reg [INPUT_CHANNEL_ADDR_SIZE-1:0] wr_addr_nl; // Address to write each of the N values retrieved from the PE array
output reg signed [INPUT_CHANNEL_DATA_WIDTH-1:0]  output_word[N_DIM_ARRAY-1:0];
output reg finished_activation;

//SIGNALS
 reg [INPUT_CHANNEL_ADDR_SIZE-1:0] input_channel_rd_addr_pool; // Address to be read from the activation memory
reg input_channel_rd_en_pool; // Enable to read from the activation memory
 reg wr_en_output_buffer_nl_pool;
reg [INPUT_CHANNEL_ADDR_SIZE-1:0] wr_addr_nl_pool; // Address to write each of the N values retrieved from the PE array
reg signed [INPUT_CHANNEL_DATA_WIDTH-1:0]  output_word_pool[N_DIM_ARRAY-1:0];
reg finished_activation_pool;


 reg [INPUT_CHANNEL_ADDR_SIZE-1:0] input_channel_rd_addr_st; // Address to be read from the activation memory
reg input_channel_rd_en_st; // Enable to read from the activation memory
 reg wr_en_output_buffer_nl_st;
reg [INPUT_CHANNEL_ADDR_SIZE-1:0] wr_addr_nl_st; // Address to write each of the N values retrieved from the PE array
reg signed [INPUT_CHANNEL_DATA_WIDTH-1:0]  output_word_st[N_DIM_ARRAY-1:0];
reg finished_activation_st;

pooling POOLING_BLOCK(
    .clk(clk), .reset(reset),
    .PRECISION(PRECISION),
    .NUMBER_OF_ACTIVATION_CYCLES(NUMBER_OF_ACTIVATION_CYCLES),
    .PADDED_C_X(PADDED_C_X),
    .PADDED_O_X(PADDED_O_X),
    .SHIFT_FIXED_POINT(SHIFT_FIXED_POINT),
    .finished_activation(finished_activation_pool),
    .input_channel_rd_addr(input_channel_rd_addr_pool),
    .input_channel_rd_en(input_channel_rd_en_pool),
   .wr_en_output_buffer_nl(wr_en_output_buffer_nl_pool),
   .wr_addr_nl(wr_addr_nl_pool),
   .read_word(read_word),
   .output_word(output_word_pool),
   .type_nonlinear_function(type_nonlinear_function),
  .enable_nonlinear_block(enable_nonlinear_block)
); 

sig_tanh SIG_TANH_BLOCK(
    .clk(clk), .reset(reset),
    .PRECISION(PRECISION),
    .wr_en_ext_lut(wr_en_ext_lut),
   .wr_addr_ext_lut(wr_addr_ext_lut),
   .wr_data_ext_lut(wr_data_ext_lut),
    .NUMBER_OF_ACTIVATION_CYCLES(NUMBER_OF_ACTIVATION_CYCLES),
    .PADDED_C_X(PADDED_C_X),
    .SHIFT_FIXED_POINT(SHIFT_FIXED_POINT),
    .finished_activation(finished_activation_st),
    .input_channel_rd_addr(input_channel_rd_addr_st),
    .input_channel_rd_en(input_channel_rd_en_st),
   .wr_en_output_buffer_nl(wr_en_output_buffer_nl_st),
   .wr_addr_nl(wr_addr_nl_st),
   .read_word(read_word),
   .output_word(output_word_st),
   .type_nonlinear_function(type_nonlinear_function),
  .enable_nonlinear_block(enable_nonlinear_block)
); 

always @(*)
begin
    
    if (enable_pooling==1)
      begin
        input_channel_rd_addr=input_channel_rd_addr_pool; // Address to be read from the activation memory
        input_channel_rd_en=input_channel_rd_en_pool; // Enable to read from the activation memory
         wr_en_output_buffer_nl=wr_en_output_buffer_nl_pool;
        wr_addr_nl=wr_addr_nl_pool; // Address to write each of the N values retrieved from the PE array
        output_word=output_word_pool;
        finished_activation=finished_activation_pool;
      end 
    else if (enable_sig_tanh==1)
      begin
        input_channel_rd_addr=input_channel_rd_addr_st; // Address to be read from the activation memory
        input_channel_rd_en=input_channel_rd_en_st; // Enable to read from the activation memory
         wr_en_output_buffer_nl=wr_en_output_buffer_nl_st;
        wr_addr_nl=wr_addr_nl_st; // Address to write each of the N values retrieved from the PE array
        output_word=output_word_st;
        finished_activation=finished_activation_st;
      end
    else
      begin
          input_channel_rd_addr=input_channel_rd_addr_pool; // Address to be read from the activation memory
        input_channel_rd_en=input_channel_rd_en_pool; // Enable to read from the activation memory
         wr_en_output_buffer_nl=wr_en_output_buffer_nl_pool;
        wr_addr_nl=wr_addr_nl_pool; // Address to write each of the N values retrieved from the PE array
        output_word=output_word_pool;
        finished_activation=finished_activation_pool;
      end
end
endmodule
