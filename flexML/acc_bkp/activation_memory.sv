import parameters::*;

module activation_memory 
(
  clk, reset,
  
  wr_en_ext, //external write port
  wr_addr_ext,
  wr_data_ext,
  
  wr_en,   //internal write port
  wr_addr_input, 
  wr_input_word, 
  
  rd_en_ext, // external read port
  rd_addr_ext,
  rd_data_ext, 
  
  rd_en, // internal read port
  rd_addr, 
  read_word,
  
  mode, // FC(0),CNN(1), ACTIVATION(2), ELEMENT-WISE SUM (3)
  loading_in_parallel, // For CNN processing. Signal for loading a vector of N values if 1. Otherwise only 1 values is retrived
  

  input_memory_pointer, // reading pointer to the first address of the input activations
  output_memory_pointer, //writing pointer to the first address of the output activations
  
  
);

//IO
input clk, reset, rd_en;
input [2:0] mode;
input wr_en_ext;
input [INPUT_CHANNEL_ADDR_SIZE-1:0] wr_addr_ext;
input signed [ACT_DATA_WIDTH-1:0] wr_data_ext [N_DIM_ARRAY-1:0];
input loading_in_parallel;
input signed [ACT_DATA_WIDTH-1:0] wr_input_word [N_DIM_ARRAY-1:0];
input [INPUT_CHANNEL_ADDR_SIZE-1:0] rd_addr;
input [INPUT_CHANNEL_ADDR_SIZE-1:0] input_memory_pointer;
input [INPUT_CHANNEL_ADDR_SIZE-1:0] output_memory_pointer;
input wr_en;
input [INPUT_CHANNEL_ADDR_SIZE-1:0] wr_addr_input;
input rd_en_ext;
input [INPUT_CHANNEL_ADDR_SIZE-1:0]  rd_addr_ext;
output reg signed [ACT_DATA_WIDTH-1:0]   rd_data_ext[N_DIM_ARRAY-1:0]; 
output reg signed [INPUT_CHANNEL_DATA_WIDTH-1:0]  read_word[N_DIM_ARRAY-1:0];
//signals
wire signed [INPUT_CHANNEL_DATA_WIDTH-1:0]  read_word_SRAM_0[N_DIM_ARRAY-1:0];
wire signed [INPUT_CHANNEL_DATA_WIDTH-1:0]  read_word_SRAM_1[N_DIM_ARRAY-1:0];
reg [INPUT_CHANNEL_ADDR_SIZE-1:0] output_channel_addresses;
wire [INPUT_CHANNEL_ADDR_SIZE-1:0] output_memory_pointer_shifted;
wire [INPUT_CHANNEL_ADDR_SIZE-1:0] rd_addr_shifted;
reg [INPUT_CHANNEL_ADDR_SIZE-1:0] wr_counter;
wire [INPUT_CHANNEL_ADDR_SIZE-1:0] wr_addr_plus_offset;
wire [INPUT_CHANNEL_ADDR_SIZE-1:0] rd_addr_plus_offset;
reg loading_in_parallel_reg;
reg wr_en_0;
reg [INPUT_CHANNEL_ADDR_SIZE-1:0] wr_addr_0;
reg signed [ACT_DATA_WIDTH-1:0]  wr_data_0 [N_DIM_ARRAY-1:0];
reg wr_en_1;
reg [INPUT_CHANNEL_ADDR_SIZE-1:0] wr_addr_1;
reg signed [ACT_DATA_WIDTH-1:0]  wr_data_1 [N_DIM_ARRAY-1:0];
reg wr_en_ext_0;
reg [INPUT_CHANNEL_ADDR_SIZE-1:0] wr_addr_ext_0;
reg signed [ACT_DATA_WIDTH-1:0] wr_data_ext_0 [N_DIM_ARRAY-1:0];
reg wr_en_ext_1;
reg [INPUT_CHANNEL_ADDR_SIZE-1:0] wr_addr_ext_1;
reg signed [ACT_DATA_WIDTH-1:0] wr_data_ext_1 [N_DIM_ARRAY-1:0];
reg rd_en_ext_0;
reg [INPUT_CHANNEL_ADDR_SIZE-1:0] rd_addr_ext_0;
wire signed [ACT_DATA_WIDTH-1:0] rd_data_ext_0 [N_DIM_ARRAY-1:0];
reg rd_en_ext_1;
reg [INPUT_CHANNEL_ADDR_SIZE-1:0] rd_addr_ext_1;
wire signed [ACT_DATA_WIDTH-1:0] rd_data_ext_1 [N_DIM_ARRAY-1:0];
wire  [N_DIM_ARRAY_LOG-1:0] j_signal [N_DIM_ARRAY-1:0];
reg [INPUT_CHANNEL_ADDR_SIZE-1:0] rd_addr_plus_offset_reg;
reg rd_enable_muxed;
reg [INPUT_CHANNEL_ADDR_SIZE-1:0] rd_addr_muxed;
reg rd_enable_0;
reg [INPUT_CHANNEL_ADDR_SIZE-1:0] rd_addr_0;
reg rd_enable_1;
reg [INPUT_CHANNEL_ADDR_SIZE-1:0] rd_addr_1;
reg [(N_DIM_ARRAY_LOG-1):0] index_vector;
reg wr_en_ext_muxed;
reg [INPUT_CHANNEL_ADDR_SIZE-1:0] wr_addr_ext_muxed;
reg signed [ACT_DATA_WIDTH-1:0] wr_data_ext_muxed [N_DIM_ARRAY-1:0];
reg [INPUT_CHANNEL_ADDR_SIZE-1:0] rd_addr_ext_reg;
//gen variables
genvar gj;
integer i;
integer j;


// Offset handling
// Adjusting the offset of the read and write memory, depending on the input and output memory pointer
assign wr_addr_plus_offset =wr_addr_input+(output_memory_pointer>> (N_DIM_ARRAY_LOG));  // N-word Addressable
assign rd_addr_plus_offset = rd_addr + (input_memory_pointer >> N_DIM_ARRAY_LOG); // N-word Addressable
assign rd_addr_shifted = (rd_addr  >> (N_DIM_ARRAY_LOG))+(input_memory_pointer>>(N_DIM_ARRAY_LOG)); // used for reading N2 words at the same time, otherwise use address with offset

///////////////////////// WRITING //////////////////////////////////////////////////////////////////////////////////////
// Writing process with double buffering using the internal interface
always @(*)
begin
    wr_en_0=0;
    wr_en_1=0;

    for( j=0; j<N_DIM_ARRAY; j=j+1)
      begin
      wr_data_0[j]=0;
      wr_data_1[j]=0;
      end
    if ((wr_en==1) && (wr_addr_plus_offset[INPUT_CHANNEL_ADDR_SIZE-1]==0)) // if the transaction is for buffer 0 
    begin
    wr_en_0= wr_en;
    wr_data_0 = wr_input_word;
    wr_addr_0={wr_addr_plus_offset[INPUT_CHANNEL_ADDR_SIZE-N_DIM_ARRAY_LOG-1:0],{N_DIM_ARRAY_LOG{1'b0}}};
    end 
    else if ((wr_en==1) && (wr_addr_plus_offset[INPUT_CHANNEL_ADDR_SIZE-1]==1)) // if the transaction is for buffer 0 
    begin
    wr_en_1= wr_en;
    wr_data_1 = wr_input_word;
    wr_addr_1={wr_addr_plus_offset[INPUT_CHANNEL_ADDR_SIZE-N_DIM_ARRAY_LOG-1:0],{N_DIM_ARRAY_LOG{1'b0}}};
    end 
end
// Writing process with double buffering using the external interface

always @(*)
begin
wr_en_ext_0=0;
wr_en_ext_1=0;
wr_addr_ext_0=0;
wr_addr_ext_1=0;
for( j=0; j<N_DIM_ARRAY; j=j+1)
      begin
      wr_data_ext_0[j]=0;
      wr_data_ext_1[j]=0;
      end
      
    if ((wr_en_ext==1) && (wr_addr_ext[INPUT_CHANNEL_ADDR_SIZE-1]==0)) // if the transaction is for buffer 0 
    begin
    wr_en_ext_0= wr_en_ext;
    wr_data_ext_0 = wr_data_ext;
    wr_addr_ext_0 = wr_addr_ext; 
    end 
    else if ((wr_en==1) && (wr_addr_ext[INPUT_CHANNEL_ADDR_SIZE-1]==1)) // if the transaction is for buffer 0 
    begin
    wr_en_ext_1= wr_en_ext;
    wr_data_ext_1 = wr_data_ext;
    wr_addr_ext_1 = wr_addr_ext; 
    end 
end
/////////////// Reading process with double buffering using the internal interface
always @(*)
begin
    rd_addr_0=0;
    rd_enable_0=0;
    rd_addr_1=0;
    rd_enable_1=0;
    
    if ((rd_en==1) && (rd_addr[INPUT_CHANNEL_ADDR_SIZE-1]==0)) // if the transaction is for buffer 0 
    begin
        rd_enable_0= rd_en;
        if ((mode==MODE_FC) || (mode==MODE_EWS) ) // If fc or element wise operation
    begin
      rd_addr_0={{rd_addr_plus_offset[INPUT_CHANNEL_ADDR_SIZE-N_DIM_ARRAY_LOG-1:0]}, {N_DIM_ARRAY_LOG{1'b0}}} ;
    end
    else //CNN
      begin
         if (loading_in_parallel==1) // If it is loading N words at the same time
            rd_addr_0 = {{rd_addr_shifted[INPUT_CHANNEL_ADDR_SIZE-1:0]}, {N_DIM_ARRAY_LOG{1'b0}}};
         else // If one element is needed
            rd_addr_0 = {{rd_addr_shifted[INPUT_CHANNEL_ADDR_SIZE-1:0]}, {rd_addr_plus_offset[(N_DIM_ARRAY_LOG-1):0]}};
      end
    end
    else if ((rd_en==1) && (rd_addr[INPUT_CHANNEL_ADDR_SIZE-1]==1))
    begin
      rd_enable_1= rd_en;
        if ((mode==MODE_FC) || (mode==MODE_EWS) ) // If fc or element wise operation
    begin
      rd_addr_1={{rd_addr_plus_offset[INPUT_CHANNEL_ADDR_SIZE-N_DIM_ARRAY_LOG-1:0]}, {N_DIM_ARRAY_LOG{1'b0}}} ;
    end
    else //CNN
      begin
         if (loading_in_parallel==1) // If it is loading N words at the same time
            rd_addr_1= {{rd_addr_shifted[INPUT_CHANNEL_ADDR_SIZE-1:0]}, {N_DIM_ARRAY_LOG{1'b0}}};
         else // If one element is needed
            rd_addr_1 = {{rd_addr_shifted[INPUT_CHANNEL_ADDR_SIZE-1:0]}, {rd_addr_plus_offset[(N_DIM_ARRAY_LOG-1):0]}};
      end
    end
    
   
    if ((mode==MODE_FC) || (mode==MODE_EWS) ) // If fc or element wise operation
    begin
      rd_addr_muxed={{rd_addr_plus_offset[INPUT_CHANNEL_ADDR_SIZE-N_DIM_ARRAY_LOG-1:0]}, {N_DIM_ARRAY_LOG{1'b0}}} ;
    end
    else //CNN
      begin
         if (loading_in_parallel==1) // If it is loading N words at the same time
            rd_addr_muxed = {{rd_addr_shifted[INPUT_CHANNEL_ADDR_SIZE-1:0]}, {N_DIM_ARRAY_LOG{1'b0}}};
         else // If one element is needed
            rd_addr_muxed = {{rd_addr_shifted[INPUT_CHANNEL_ADDR_SIZE-1:0]}, {rd_addr_plus_offset[(N_DIM_ARRAY_LOG-1):0]}};
      end

end

///// Reading interface using the external interface
always @(*)
begin
rd_en_ext_0=0;
rd_en_ext_1=0;
rd_addr_ext_0=0;
rd_addr_ext_1=0;
    if ((rd_en_ext==1) && (rd_addr_ext[INPUT_CHANNEL_ADDR_SIZE-1]==0)) // if the transaction is for buffer 0 
    begin
    rd_en_ext_0= rd_en_ext;
    rd_addr_ext_0 = rd_addr_ext; 
    end 
    else if ((rd_en==1) && (rd_addr_ext[INPUT_CHANNEL_ADDR_SIZE-1]==1)) // if the transaction is for buffer 0 
    begin
    rd_en_ext_1= rd_en_ext;
    rd_addr_ext_1 = rd_addr_ext; 
    end 
end

always @(*)
begin
  if (rd_addr_ext_reg[INPUT_CHANNEL_ADDR_SIZE-1]==0)
    rd_data_ext= rd_data_ext_0;
  else
    rd_data_ext = rd_data_ext_1;
end

// Wrapper for activation memory
inner_wrapper_SRAM_act_mem  #(
.SRAM_blocks_per_row(ACT_MEM_SRAM_blocks_per_row),
.SRAM_numBit(ACT_MEM_SRAM_numBit),
.SRAM_numWordAddr(ACT_MEM_SRAM_numWordAddr),
.SRAM_blocks_per_column(ACT_MEM_SRAM_blocks_per_column)
) ACT_MEM_0 (.clk(clk), 
    .reset(reset),
    .rd_enable(rd_enable_0),
    .rd_addr(rd_addr_0[ACT_MEM_SRAM_totalWordAddr-1:0]),
     .rd_data(read_word_SRAM_0),
    .rd_enable_ext(rd_en_ext_0),
    .rd_addr_ext(rd_addr_ext_0[ACT_MEM_SRAM_totalWordAddr-1:0]), 
    .rd_data_ext(rd_data_ext_0),
    .wr_enable(wr_en_0),
    .wr_addr(wr_addr_0[ACT_MEM_SRAM_totalWordAddr-1:0]),
    .wr_data(wr_data_0),
    .wr_enable_ext(wr_en_ext_0),
    .wr_addr_ext(wr_addr_ext_0[ACT_MEM_SRAM_totalWordAddr-1:0]),
    .wr_data_ext(wr_data_ext_0)
);    

inner_wrapper_SRAM_act_mem  #(
.SRAM_blocks_per_row(ACT_MEM_SRAM_blocks_per_row),
.SRAM_numBit(ACT_MEM_SRAM_numBit),
.SRAM_numWordAddr(ACT_MEM_SRAM_numWordAddr),
.SRAM_blocks_per_column(ACT_MEM_SRAM_blocks_per_column)
) ACT_MEM_1 (.clk(clk), 
    .reset(reset),
    .rd_enable(rd_enable_1),
    .rd_addr(rd_addr_1[ACT_MEM_SRAM_totalWordAddr-1:0]),
     .rd_data(read_word_SRAM_1),
     .rd_enable_ext(rd_en_ext_1),
    .rd_addr_ext(rd_addr_ext_1[ACT_MEM_SRAM_totalWordAddr-1:0]), 
    .rd_data_ext(rd_data_ext_1),
    .wr_enable(wr_en_1),
    .wr_addr(wr_addr_1[ACT_MEM_SRAM_totalWordAddr-1:0]),
    .wr_data(wr_data_1),
    .wr_enable_ext(wr_en_ext_1),
    .wr_addr_ext(wr_addr_ext_1[ACT_MEM_SRAM_totalWordAddr-1:0]),
    .wr_data_ext(wr_data_ext_1)
);    








// Since there is one cycle delay between the processing of the read port and putting the read word in the SRAM ports, the state of the read port must be saved 

always @(posedge clk or negedge reset)
begin
  if (!reset)
    begin
    rd_addr_plus_offset_reg <=0;
    rd_addr_ext_reg <= 0;
    end
  else
    begin
    rd_addr_plus_offset_reg <=rd_addr_plus_offset;
    rd_addr_ext_reg <= rd_addr_ext;
    end
end

  always @(posedge clk or negedge reset)
  begin
  if (!reset)
  loading_in_parallel_reg <= 0;
  else
  loading_in_parallel_reg <= loading_in_parallel;
  end

    always @(*)
    begin
    
    //buffer 0
    if (rd_addr_plus_offset_reg[INPUT_CHANNEL_ADDR_SIZE-1]==0)
    begin
      if ((mode==MODE_CNN) && (loading_in_parallel_reg==0)) // If CNN and it is loading N words
      begin
          for( j=0; j<N_DIM_ARRAY; j=j+1)
            begin
            index_vector = rd_addr_plus_offset_reg[MAXIMUM_DILATION_BITS-1:0] + j;  // Taking into account dilation to get a new word
           read_word[j] = read_word_SRAM_0[index_vector];
                end
      end 
      else
      begin
          read_word = read_word_SRAM_0;
      end
    end  
      
    else 
   begin
       if ((mode==MODE_CNN) && (loading_in_parallel_reg==0)) // If CNN and it is loading N words
      begin
          for( j=0; j<N_DIM_ARRAY; j=j+1)
            begin
            index_vector = rd_addr_plus_offset_reg[MAXIMUM_DILATION_BITS-1:0] + j;  // Taking into account dilation to get a new word
           read_word[j] = read_word_SRAM_1[index_vector];
                end
      end 
      else
      begin
          read_word = read_word_SRAM_1;
      end
   end
    end
    
    
endmodule

