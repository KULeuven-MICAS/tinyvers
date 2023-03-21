import parameters::*;

// Weight memory containing the weights for the current neural network

module weight_memory 
(
  clk, 
  reset, 
  enable, 
  wr_en_ext_fc_w,
   wr_addr_ext_fc_w,
   wr_data_ext_fc_w,
   wr_en_ext_cnn_w,
   wr_addr_ext_cnn_w,
   wr_data_ext_cnn_w,
  mode, 
  rd_en, 
  rd_addr,  
  MEMORY_POINTER_FC,
  FIRST_INDEX_FC_LOG,
  weight_memory_pointer, 
  read_word 
);
//IO
input clk, reset, enable;
input wr_en_ext_fc_w; 
input [WEIGHT_MEMORY_ADDR_SIZE-1:0] wr_addr_ext_fc_w;
input signed [WEIGHT_DATA_WIDTH-1:0]  wr_data_ext_fc_w[N_DIM_ARRAY-1:0];
input wr_en_ext_cnn_w;
input [WEIGHT_MEMORY_ADDR_SIZE-1:0] wr_addr_ext_cnn_w;
input signed [WEIGHT_DATA_WIDTH-1:0] wr_data_ext_cnn_w[N_DIM_ARRAY-1:0];
input rd_en; // read enable
input [2:0] mode; // FC(0) or CNN(1) layer
input [31:0] MEMORY_POINTER_FC;
input [31:0] FIRST_INDEX_FC_LOG;
input [WEIGHT_MEMORY_ADDR_SIZE-1:0] rd_addr; // read address, addressable by word
input [WEIGHT_MEMORY_ADDR_SIZE-1:0] weight_memory_pointer; // read weight memory pointer indicating the initial address of the NN weights
output reg signed [WEIGHT_DATA_WIDTH-1:0] read_word [N_DIM_ARRAY-1:0][N_DIM_ARRAY-1:0]; // NxN read word. If cnn only 1/N of the maximum bandwidth is used

//signals
reg signed [WEIGHT_DATA_WIDTH-1:0] read_word_CNN_Memory [N_DIM_ARRAY-1:0]; // NxN read word. If cnn only 1/N of the maximum bandwidth is used
reg signed [WEIGHT_DATA_WIDTH-1:0] read_word_FC_Memory_reordered [N_DIM_ARRAY-1:0][N_DIM_ARRAY-1:0]; // NxN read word. If cnn only 1/N of the maximum bandwidth is used
wire [WEIGHT_MEMORY_ADDR_SIZE-1:0] rd_addr_plus_offset; // read address taking into account memory offset (weight_memory_pointer) 
wire [FC_W_MEM_SRAM_totalWordAddr-1:0] rd_addr_fc;
wire [CNN_W_MEM_SRAM_totalWordAddr-1:0] rd_addr_cnn;

//signals
reg wr_en_ext_fc_w_0; 
reg [WEIGHT_MEMORY_ADDR_SIZE-1:0] wr_addr_ext_fc_w_0;
reg signed [WEIGHT_DATA_WIDTH-1:0]  wr_data_ext_fc_w_0[N_DIM_ARRAY-1:0];
reg wr_en_ext_cnn_w_0;
reg [WEIGHT_MEMORY_ADDR_SIZE-1:0] wr_addr_ext_cnn_w_0;
reg signed [WEIGHT_DATA_WIDTH-1:0] wr_data_ext_cnn_w_0[N_DIM_ARRAY-1:0]; 
reg rd_en_0; // read enable
reg [WEIGHT_MEMORY_ADDR_SIZE-1:0] rd_addr_0; // read address, addressable by word
reg [FC_W_MEM_SRAM_totalWordAddr-1:0] rd_addr_fc_0;
reg [CNN_W_MEM_SRAM_totalWordAddr-1:0] rd_addr_cnn_0;
wire signed [WEIGHT_DATA_WIDTH-1:0] read_word_CNN_Memory_0[N_DIM_ARRAY-1:0]; // NxN read word. If cnn only 1/N of the maximum bandwidth is used
wire signed [WEIGHT_DATA_WIDTH-1:0] read_word_FC_Memory_reordered_0 [N_DIM_ARRAY-1:0][N_DIM_ARRAY-1:0]; // NxN read word. If cnn only 1/N of the maximum bandwidth is used

reg wr_en_ext_fc_w_1; 
reg [WEIGHT_MEMORY_ADDR_SIZE-1:0] wr_addr_ext_fc_w_1;
reg signed [WEIGHT_DATA_WIDTH-1:0]  wr_data_ext_fc_w_1[N_DIM_ARRAY-1:0];
reg wr_en_ext_cnn_w_1;
reg [WEIGHT_MEMORY_ADDR_SIZE-1:0] wr_addr_ext_cnn_w_1;
reg signed [WEIGHT_DATA_WIDTH-1:0] wr_data_ext_cnn_w_1[N_DIM_ARRAY-1:0]; 
reg rd_en_1; // read enable
reg [WEIGHT_MEMORY_ADDR_SIZE-1:0] rd_addr_1; // read address, addressable by word
reg [FC_W_MEM_SRAM_totalWordAddr-1:0] rd_addr_fc_1;
reg [CNN_W_MEM_SRAM_totalWordAddr-1:0] rd_addr_cnn_1;
wire signed [WEIGHT_DATA_WIDTH-1:0] read_word_CNN_Memory_1[N_DIM_ARRAY-1:0]; // NxN read word. If cnn only 1/N of the maximum bandwidth is used
wire signed [WEIGHT_DATA_WIDTH-1:0] read_word_FC_Memory_reordered_1 [N_DIM_ARRAY-1:0][N_DIM_ARRAY-1:0]; // NxN read word. If cnn only 1/N of the maximum bandwidth is used

  reg rd_en_reg;  
  reg ping_pong_bit;

// gen variables
integer i;
integer j;
integer k;
integer m;
genvar r;
    
// reading process
assign rd_addr_plus_offset = rd_addr+ weight_memory_pointer; // reading pointer
assign rd_addr_fc={rd_addr_plus_offset[FC_W_MEM_SRAM_totalWordAddr-2*N_DIM_ARRAY_LOG-1:0],{2*N_DIM_ARRAY_LOG{1'b0}}}; // Read address for FC layers (The least 2*NDIMARRAYLOG bits are ignored)

assign rd_addr_cnn = {rd_addr_plus_offset[CNN_W_MEM_SRAM_totalWordAddr-N_DIM_ARRAY_LOG-1:0],{N_DIM_ARRAY_LOG{1'b0}}}; // Read address for CNN layers


//BUG FIXING SEBASTIAN, JUNE 15TH 2020. The pointers were not correctly set.
//assign rd_addr_fc={rd_addr_plus_offset[FC_W_MEM_SRAM_totalWordAddr-1:0],{2*N_DIM_ARRAY_LOG{1'b0}}}; // Read address for FC layers (The least 2*NDIMARRAYLOG bits are ignored)

//assign rd_addr_cnn = {rd_addr_plus_offset[CNN_W_MEM_SRAM_totalWordAddr-1:0],{N_DIM_ARRAY_LOG{1'b0}}}; // Read address for CNN layers






always @(*)
begin
// Double buffering for writing
//Writing FC weights
if (wr_en_ext_fc_w)
    begin
      if (wr_addr_ext_fc_w[WEIGHT_MEMORY_ADDR_SIZE-1]==1)
        begin
            wr_en_ext_fc_w_0=0;
            wr_addr_ext_fc_w_0=0;
            for (j=0; j < N_DIM_ARRAY; j =j+1)
              wr_data_ext_fc_w_0[j] = {WEIGHT_DATA_WIDTH{1'b0}};
            
            wr_en_ext_fc_w_1=wr_en_ext_fc_w;
            wr_addr_ext_fc_w_1=wr_addr_ext_fc_w;
            wr_data_ext_fc_w_1=wr_data_ext_fc_w;
        end
      else
        begin
            wr_en_ext_fc_w_1=0;
            wr_addr_ext_fc_w_1=0;
            for (j=0; j < N_DIM_ARRAY; j =j+1)
              wr_data_ext_fc_w_1[j] = {WEIGHT_DATA_WIDTH{1'b0}};
            
            wr_en_ext_fc_w_0=wr_en_ext_fc_w;
            wr_addr_ext_fc_w_0=wr_addr_ext_fc_w;
            wr_data_ext_fc_w_0=wr_data_ext_fc_w;
        end
    end
else
    begin
    
            wr_en_ext_fc_w_0=0;
            wr_addr_ext_fc_w_0=0;
            for (j=0; j < N_DIM_ARRAY; j =j+1)
              wr_data_ext_fc_w_0[j] = {WEIGHT_DATA_WIDTH{1'b0}};
            wr_en_ext_fc_w_1=0;
            wr_addr_ext_fc_w_1=0;
            for (j=0; j < N_DIM_ARRAY; j =j+1)
              wr_data_ext_fc_w_1[j]  = {WEIGHT_DATA_WIDTH{1'b0}};
    end 

    
    //Writing CNN weights
if (wr_en_ext_cnn_w)
    begin
      if (wr_addr_ext_cnn_w[WEIGHT_MEMORY_ADDR_SIZE-1]==1)
        begin
            wr_en_ext_cnn_w_0=0;
            wr_addr_ext_cnn_w_0=0;
            for (j=0; j < N_DIM_ARRAY; j =j+1)
              wr_data_ext_cnn_w_0[j] = {WEIGHT_DATA_WIDTH{1'b0}};
          
            wr_en_ext_cnn_w_1=wr_en_ext_cnn_w;
            wr_addr_ext_cnn_w_1=wr_addr_ext_cnn_w;
            wr_data_ext_cnn_w_1=wr_data_ext_cnn_w;
        end
      else
        begin
            wr_en_ext_cnn_w_1=0;
            wr_addr_ext_cnn_w_1=0;
            for (j=0; j < N_DIM_ARRAY; j =j+1)
              wr_data_ext_cnn_w_1[j] = {WEIGHT_DATA_WIDTH{1'b0}};
            
            wr_en_ext_cnn_w_0=wr_en_ext_cnn_w;
            wr_addr_ext_cnn_w_0=wr_addr_ext_cnn_w;
            wr_data_ext_cnn_w_0=wr_data_ext_cnn_w;
        end
    end    
else
  begin
            wr_en_ext_cnn_w_0=0;
            wr_addr_ext_cnn_w_0=0;
            for (j=0; j < N_DIM_ARRAY; j =j+1)
              wr_data_ext_cnn_w_0[j] = {WEIGHT_DATA_WIDTH{1'b0}};
              wr_en_ext_cnn_w_1=0;
            wr_addr_ext_cnn_w_1=0;
            for (j=0; j < N_DIM_ARRAY; j =j+1)
              wr_data_ext_cnn_w_1[j] = {WEIGHT_DATA_WIDTH{1'b0}};
  end


//Reading FC
if (rd_en)
  begin
    // BUG FIXING SEBASTIAN 20 APRIL 2020
    if (weight_memory_pointer[WEIGHT_MEMORY_ADDR_SIZE-(2*N_DIM_ARRAY_LOG)-1])
    // BUG FIXING SEBASTIAN June 15, 2020
    //if (weight_memory_pointer[WEIGHT_MEMORY_ADDR_SIZE-1])

    //if (rd_addr_fc[WEIGHT_MEMORY_ADDR_SIZE-1])
            begin
            rd_addr_fc_1=rd_addr_fc;
            rd_addr_fc_0=0;
            end
    else
            begin
            rd_addr_fc_0=rd_addr_fc;
            rd_addr_fc_1=0;
            end
  end 
else
  begin
      rd_addr_fc_0=0;
      rd_addr_fc_1=0;
  end

if (rd_en)
  begin
     // BUG FIXING SEBASTIAN 20 APRIL 2020
     if (weight_memory_pointer[WEIGHT_MEMORY_ADDR_SIZE-(N_DIM_ARRAY_LOG)-1])
    //if (rd_addr_cnn[WEIGHT_MEMORY_ADDR_SIZE-1])
      begin
      rd_addr_cnn_1=rd_addr_cnn;
      rd_addr_cnn_0=0;
      end
    else
      begin
      rd_addr_cnn_0=rd_addr_cnn;
      rd_addr_cnn_1=0;
      end
  end 
else
  begin
      rd_addr_cnn_0=0;
      rd_addr_cnn_1=0;
  end  
 


 
if (rd_en)
    begin
       // BUG FIXING SEBASTIAN 20 APRIL 2020
     //if (rd_addr_plus_offset[WEIGHT_MEMORY_ADDR_SIZE-1])
     // if ((  (rd_addr_cnn[WEIGHT_MEMORY_ADDR_SIZE-1])) || (  (rd_addr_fc[WEIGHT_MEMORY_ADDR_SIZE-1]) )) 
     // BUG FIXING SEBASTIAN MAY 28th, 2020
    //if (((mode==MODE_CNN) && (rd_addr_cnn[WEIGHT_MEMORY_ADDR_SIZE-1])) || ((mode==MODE_FC) &&  (rd_addr_fc[WEIGHT_MEMORY_ADDR_SIZE-1]) ))
   // BUG FIXING SEBASTIAN june 15th, 2020
   // if (((mode==MODE_CNN) && (rd_addr_cnn[WEIGHT_MEMORY_ADDR_SIZE-1])) || ((mode==MODE_FC) &&  (weight_memory_pointer[WEIGHT_MEMORY_ADDR_SIZE-1]) ))
   // BUG FIXING SEBASTIAN june 15th, 2020
    if (((mode==MODE_CNN) && (rd_addr_cnn[WEIGHT_MEMORY_ADDR_SIZE-1])) || ((mode==MODE_FC) &&  (weight_memory_pointer[WEIGHT_MEMORY_ADDR_SIZE-2*N_DIM_ARRAY_LOG-1]) ))

        begin
          rd_en_1=rd_en;
          rd_en_0=0;
        end 
      else
        begin
          rd_en_0=rd_en;
          rd_en_1=0;
        end
    end
   else
    begin
        rd_en_0=0;
          rd_en_1=0;
    end
   
 // Reading word
 if (rd_en_reg)
  begin
    if (ping_pong_bit==1)
      begin
      read_word_FC_Memory_reordered = read_word_FC_Memory_reordered_1;
      read_word_CNN_Memory =read_word_CNN_Memory_1;
      end
    else 
      begin
    read_word_FC_Memory_reordered = read_word_FC_Memory_reordered_0;
    read_word_CNN_Memory =read_word_CNN_Memory_0;
      end
  end 
 else
  begin
      read_word_FC_Memory_reordered = read_word_FC_Memory_reordered_0;
      read_word_CNN_Memory =read_word_CNN_Memory_0;
  end
end




outter_wrapper_SRAM_w_mem #(
.SRAM_blocks_per_row(SUBBLOCK_W_MEM_SRAM_blocks_per_row),
.SRAM_numBit(SUBBLOCK_W_MEM_SRAM_numBit),
.SRAM_numWordAddr(SUBBLOCK_W_MEM_SRAM_numWordAddr),
.SRAM_blocks_per_column(SUBBLOCK_W_MEM_SRAM_blocks_per_column/2)
) UNIFIED_W_0 (
    .clk(clk), 
    .reset(reset),
    .MEMORY_POINTER_FC(MEMORY_POINTER_FC),
    .FIRST_INDEX_FC_LOG(FIRST_INDEX_FC_LOG),
    .mode(mode),
    .rd_enable(rd_en_0),
    .rd_addr_fc({{1'b0},rd_addr_fc_0[WEIGHT_MEMORY_ADDR_SIZE-2:0]}),
    .rd_addr_cnn(rd_addr_cnn_0),
    .wr_enable_fc(wr_en_ext_fc_w_0),
    .wr_addr_fc({{1'b0},wr_addr_ext_fc_w_0[WEIGHT_MEMORY_ADDR_SIZE-2:0]}),
    .wr_data_fc(wr_data_ext_fc_w_0),
    .wr_enable_cnn(wr_en_ext_cnn_w_0),
    .wr_addr_cnn(wr_addr_ext_cnn_w_0),
    .wr_data_cnn(wr_data_ext_cnn_w_0),
    .rd_data(read_word_CNN_Memory_0),
    .rd_data_FC(read_word_FC_Memory_reordered_0)
);

outter_wrapper_SRAM_w_mem #(
.SRAM_blocks_per_row(SUBBLOCK_W_MEM_SRAM_blocks_per_row),
.SRAM_numBit(SUBBLOCK_W_MEM_SRAM_numBit),
.SRAM_numWordAddr(SUBBLOCK_W_MEM_SRAM_numWordAddr),
.SRAM_blocks_per_column(SUBBLOCK_W_MEM_SRAM_blocks_per_column/2)
)  UNIFIED_W_1 (
    .clk(clk), 
    .reset(reset),
    .MEMORY_POINTER_FC(MEMORY_POINTER_FC),
    .FIRST_INDEX_FC_LOG(FIRST_INDEX_FC_LOG),
    .mode(mode),
    
    .rd_enable(rd_en_1),
    .rd_addr_fc({{1'b0},rd_addr_fc_1[WEIGHT_MEMORY_ADDR_SIZE-2:0]}),
    .rd_addr_cnn(rd_addr_cnn_1),
    .wr_enable_fc(wr_en_ext_fc_w_1),
    .wr_addr_fc({{1'b0}, wr_addr_ext_fc_w_1[WEIGHT_MEMORY_ADDR_SIZE-2:0]}),
    .wr_data_fc(wr_data_ext_fc_w_1),
    .wr_enable_cnn(wr_en_ext_cnn_w_1),
    .wr_addr_cnn(wr_addr_ext_cnn_w_1),
    .wr_data_cnn(wr_data_ext_cnn_w_1),
    .rd_data(read_word_CNN_Memory_1),
    .rd_data_FC(read_word_FC_Memory_reordered_1)
);


// Multiplexing Reading
always @(*)
begin
  for (i=0; i < N_DIM_ARRAY; i =i+1)
   for (j=0; j < N_DIM_ARRAY; j =j+1)
    read_word[i][j]=0; 
  
  // If CNN get only N values from the read word array
  if (mode==MODE_CNN)
    begin
        for (j=0; j < N_DIM_ARRAY; j =j+1)
                if (j==0)
                  begin
                      for (k=0; k < N_DIM_ARRAY; k =k+1)
                        read_word[j][k] =read_word_CNN_Memory[k];
                  end
                else
                  begin
                  for (k=0; k < N_DIM_ARRAY; k =k+1)
                      read_word[j][k]= 0;  
                  end    

    end
  else
    begin
        read_word =read_word_FC_Memory_reordered;
    end
end
    

 always @(posedge clk or negedge reset)
  begin
    if (!reset)
      begin
        rd_en_reg <= 0;
        ping_pong_bit <=0;
      end
   else
      begin
        rd_en_reg <= rd_en;
        if (mode==MODE_CNN)
         ping_pong_bit <= rd_addr_cnn[WEIGHT_MEMORY_ADDR_SIZE-1];
        else

         // BUG FIXING JUNE 15, 2020
        // ping_pong_bit <= rd_addr_fc[WEIGHT_MEMORY_ADDR_SIZE-1];
        ping_pong_bit <= weight_memory_pointer[WEIGHT_MEMORY_ADDR_SIZE-2*N_DIM_ARRAY_LOG-1];
        end
  end
  
endmodule

