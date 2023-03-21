import parameters::*;

module outter_wrapper_SRAM_w_mem #(
parameter integer SRAM_blocks_per_row=4,
parameter integer SRAM_blocks_per_column=2,
parameter SRAM_numBit = 8,
parameter SRAM_numWordAddr = 10
)(
    clk, 
    reset,
    scan_en_in,
    MEMORY_POINTER_FC,
    FIRST_INDEX_FC_LOG,
    mode,
    rd_enable,
    rd_addr_fc,
    rd_addr_cnn,
    rd_data,
    rd_data_FC,
    wr_enable_fc,
    wr_addr_fc,
    wr_data_fc,
    wr_enable_cnn,
    wr_addr_cnn,
    wr_data_cnn
);


parameter SRAM_outter_wrapper_totalWordAddr = SRAM_numWordAddr + $clog2(SRAM_blocks_per_row) + $clog2(SRAM_blocks_per_column)+SUBBLOCK_W_MEM_NUMBER_OF_SUBBLOCKS_log;

//IO
input clk, reset, scan_en_in;
input rd_enable; // read enable
input [2:0] mode; // mode1 for CNN, mode 0 for FC, mode 2 for ACT, mode 3 for EWS
input wr_enable_cnn; // write enable for CNN port
input signed [WEIGHT_DATA_WIDTH-1:0] wr_data_cnn[SUBBLOCK_W_MEM_SRAM_blocks_per_row];
input [CNN_W_MEM_SRAM_totalWordAddr-1:0] wr_addr_cnn;

//input [SRAM_outter_wrapper_totalWordAddr-1:0] wr_addr_cnn;


input wr_enable_fc;
input signed [WEIGHT_DATA_WIDTH-1:0]  wr_data_fc[SUBBLOCK_W_MEM_SRAM_blocks_per_row]; // Write enable for FC port
input [FC_W_MEM_SRAM_totalWordAddr-1:0] wr_addr_fc;


//input [SRAM_outter_wrapper_totalWordAddr-1:0] wr_addr_fc;

input [31:0] MEMORY_POINTER_FC; // Configurable pointer for defininf the limit of the CNN memory and the beginning of the FC memory
input [31:0] FIRST_INDEX_FC_LOG; // Log2(MEMORY_POINTER_FC)
input [FC_W_MEM_SRAM_totalWordAddr-1:0] rd_addr_fc; // Read address of FC weights
input [CNN_W_MEM_SRAM_totalWordAddr-1:0] rd_addr_cnn; // Read address of CNN weights

//input [SRAM_outter_wrapper_totalWordAddr-1:0] rd_addr_fc; // Read address of FC weights
//input [SRAM_outter_wrapper_totalWordAddr-1:0] rd_addr_cnn; // Read address of CNN weights

output reg signed [WEIGHT_DATA_WIDTH-1:0]  rd_data [N_DIM_ARRAY-1:0]; // Read data from CNN memory
output reg signed [WEIGHT_DATA_WIDTH-1:0] rd_data_FC [N_DIM_ARRAY-1:0][N_DIM_ARRAY-1:0];  // Read data from FC memory


// //signals
wire [31:0] MEMORY_POINTER_FC_PER_BLOCK_fixed;
reg wr_enable_muxed[SUBBLOCK_W_MEM_NUMBER_OF_SUBBLOCKS-1:0];
reg rd_enable_muxed[SUBBLOCK_W_MEM_NUMBER_OF_SUBBLOCKS-1:0];
reg [SUBBLOCK_W_MEM_SRAM_totalWordAddr-1:0] rd_addr_muxed[SUBBLOCK_W_MEM_NUMBER_OF_SUBBLOCKS-1:0];
reg [SUBBLOCK_W_MEM_SRAM_totalWordAddr-1:0] wr_addr_muxed[SUBBLOCK_W_MEM_NUMBER_OF_SUBBLOCKS-1:0];
reg signed [WEIGHT_DATA_WIDTH-1:0] wr_data_muxed [SUBBLOCK_W_MEM_NUMBER_OF_SUBBLOCKS-1:0][SUBBLOCK_W_MEM_SRAM_blocks_per_row];
//reg [CNN_W_MEM_SRAM_totalWordAddr-1:0] rd_addr_cnn_reg;
//reg [FC_W_MEM_SRAM_totalWordAddr-1:0]  rd_addr_fc_reg;
reg [SRAM_outter_wrapper_totalWordAddr-1:0] rd_addr_cnn_reg;
reg [SRAM_outter_wrapper_totalWordAddr-1:0]  rd_addr_fc_reg;

reg rd_enable_reg;
wire signed [WEIGHT_DATA_WIDTH-1:0] read_word_CNN_Memory[N_DIM_ARRAY-1:0][N_DIM_ARRAY-1:0];
//reg [FC_W_MEM_SRAM_totalWordAddr-1:0] wr_addr_fc_corrected;
//reg [FC_W_MEM_SRAM_totalWordAddr-1:0] wr_addr_cnn_corrected;
//reg [FC_W_MEM_SRAM_totalWordAddr-1:0] rd_addr_fc_corrected;
//reg [FC_W_MEM_SRAM_totalWordAddr-1:0] rd_addr_cnn_corrected;

reg [SRAM_outter_wrapper_totalWordAddr-1:0] wr_addr_fc_corrected;
reg [SRAM_outter_wrapper_totalWordAddr-1:0] wr_addr_cnn_corrected;
reg [SRAM_outter_wrapper_totalWordAddr-1:0] rd_addr_fc_corrected;
reg [SRAM_outter_wrapper_totalWordAddr-1:0] rd_addr_cnn_corrected;

// Genvar 
genvar k;
integer i;
integer j;

assign MEMORY_POINTER_FC_PER_BLOCK_fixed = MEMORY_POINTER_FC;
// Generation of N groups of N blocks. A group can be read for CNN layers, or the N groups can be read for FC layers 
generate
for (k=0; k < SUBBLOCK_W_MEM_NUMBER_OF_SUBBLOCKS; k =k+1) begin : row
inner_wrapper_SRAM_w_mem  #(
//.SRAM_blocks_per_row(SUBBLOCK_W_MEM_SRAM_blocks_per_row),
//.SRAM_numBit(SUBBLOCK_W_MEM_SRAM_numBit),
//.SRAM_numWordAddr(SUBBLOCK_W_MEM_SRAM_numWordAddr),
//.SRAM_blocks_per_column(SUBBLOCK_W_MEM_SRAM_blocks_per_column)
.SRAM_blocks_per_row(SRAM_blocks_per_row),
.SRAM_numBit(SRAM_numBit),
.SRAM_numWordAddr(SRAM_numWordAddr),
.SRAM_blocks_per_column(SRAM_blocks_per_column)

) BLOCK_i (
    .clk(clk), 
    .reset(reset),
    .scan_en_in(scan_en_in),
    .wr_enable(wr_enable_muxed[k]),
    .wr_addr(wr_addr_muxed[k][SRAM_outter_wrapper_totalWordAddr-1:0] ),
    .wr_data(wr_data_muxed[k]),
     .rd_enable(rd_enable_muxed[k]),
     .rd_addr(rd_addr_muxed[k][SRAM_outter_wrapper_totalWordAddr-1:0] ),
     .rd_data(read_word_CNN_Memory[k])
);
end
endgenerate



// Writing
always @(*)
begin
    //default writing port
    for (i=0; i < SUBBLOCK_W_MEM_NUMBER_OF_SUBBLOCKS; i =i+1)
      begin
        wr_enable_muxed[i]=0;
        wr_addr_muxed[i]=0;
        for (j=0; j<SUBBLOCK_W_MEM_SRAM_blocks_per_row; j=j+1)
          wr_data_muxed[i][j] =0;
      end
    
    // CNN weight writing
    for (i=0; i < SUBBLOCK_W_MEM_NUMBER_OF_SUBBLOCKS; i =i+1)
      begin
          if (wr_enable_cnn==1)
            begin
                 if (i==wr_addr_cnn[(FIRST_INDEX_FC_LOG-1)-:N_DIM_ARRAY_LOG])  
                    begin
                      wr_enable_muxed[i]=wr_enable_cnn;
                    
                      //Taking only the least significant bits of the cnn memory address
                      //for (j=0; j < SUBBLOCK_W_MEM_SRAM_totalWordAddr; j =j+1)
                      for (j=0; j < SRAM_outter_wrapper_totalWordAddr; j =j+1)                     

                        if (j<(FIRST_INDEX_FC_LOG-N_DIM_ARRAY_LOG))
                          wr_addr_cnn_corrected[j] =  wr_addr_cnn[j];
                        else  
                          wr_addr_cnn_corrected[j] = 0;     
                           
                          
                         wr_addr_muxed[i] = wr_addr_cnn_corrected;           
                          
                      wr_data_muxed[i] = wr_data_cnn;
                    end
            end 
            end
            
     // FC weight writing
      for (i=0; i < SUBBLOCK_W_MEM_NUMBER_OF_SUBBLOCKS; i =i+1)
      begin 
      if (wr_enable_fc==1)
            begin
                   if (i==wr_addr_fc[2*N_DIM_ARRAY_LOG-1:N_DIM_ARRAY_LOG])          
                    begin
                      wr_enable_muxed[i]=wr_enable_fc;
                      wr_addr_fc_corrected = wr_addr_fc >> (2*N_DIM_ARRAY_LOG);
                      wr_addr_muxed[i] = (MEMORY_POINTER_FC_PER_BLOCK_fixed) + {{wr_addr_fc_corrected},{wr_addr_fc[N_DIM_ARRAY_LOG-1:0]}};
                      wr_data_muxed[i] = wr_data_fc;
                    end  
            end
      end
end

wire [31:0] temp_variable;
assign temp_variable=rd_addr_cnn[(FIRST_INDEX_FC_LOG-1)-:N_DIM_ARRAY_LOG];
//Reading estimulation
always @(*)
begin
    // Default read port
     for (i=0; i < SUBBLOCK_W_MEM_NUMBER_OF_SUBBLOCKS; i =i+1)
      begin
        rd_enable_muxed[i]=0;
        rd_addr_muxed[i]=0;
        rd_addr_cnn_corrected=0;
        rd_addr_fc_corrected=0;
      end
      
      // CNN read port
      for (i=0; i < SUBBLOCK_W_MEM_NUMBER_OF_SUBBLOCKS; i =i+1)
      begin
        if (rd_enable==1 && (mode==MODE_CNN))
          begin
             if (i==rd_addr_cnn[(FIRST_INDEX_FC_LOG-1)-:N_DIM_ARRAY_LOG])  
           //  if (i==temp_variable)

                    begin
                      rd_enable_muxed[i]=rd_enable;
                      
                      //for (j=0; j < SUBBLOCK_W_MEM_SRAM_totalWordAddr; j =j+1)
                     for (j=0; j < SRAM_outter_wrapper_totalWordAddr; j =j+1)
                        if (j<(FIRST_INDEX_FC_LOG-N_DIM_ARRAY_LOG))
                         rd_addr_cnn_corrected[j] =  rd_addr_cnn[j];
                        else  
                          rd_addr_cnn_corrected[j] = 0;
                      
                      rd_addr_muxed[i] = rd_addr_cnn_corrected;
                    end  
                    
                    
          end
        end 
        
        // FC read port
        for (i=0; i < SUBBLOCK_W_MEM_NUMBER_OF_SUBBLOCKS; i =i+1)
        begin
         if (rd_enable==1 && (mode != MODE_CNN))
          begin
                    begin
                      rd_enable_muxed[i]=rd_enable;
                      rd_addr_fc_corrected = rd_addr_fc >> (2*N_DIM_ARRAY_LOG);
                     rd_addr_muxed[i]=(MEMORY_POINTER_FC_PER_BLOCK_fixed) +{{rd_addr_fc_corrected},{rd_addr_fc[N_DIM_ARRAY_LOG-1:0]}};
                    end 
          end
      end
      
      
end

// Reading selection of data 
always @(*)
begin
    // default
  for (i=0; i < SUBBLOCK_W_MEM_NUMBER_OF_SUBBLOCKS; i =i+1)
      begin
        rd_data[i]=0;
            for (j=0; j < N_DIM_ARRAY; j =j+1)
              rd_data_FC[i][j]=0;
      end
      
    // cnn reading selection  
  for (i=0; i < SUBBLOCK_W_MEM_NUMBER_OF_SUBBLOCKS; i =i+1)
      begin
        if ((rd_enable_reg==1) && (mode==MODE_CNN))
          begin
              if (i==rd_addr_cnn_reg[(FIRST_INDEX_FC_LOG-1)-:N_DIM_ARRAY_LOG])  
                    begin
                      rd_data= read_word_CNN_Memory[i];
                    end
          end 
     end 
    
         if ((rd_enable_reg==1) && (mode!=MODE_CNN)) 
          begin
                      rd_data_FC = read_word_CNN_Memory;
          end
      
end

// Registers
always @(posedge clk or negedge reset)
begin
  if (!reset)
    begin
      rd_enable_reg <= 0;
     rd_addr_cnn_reg <= 0;
     rd_addr_fc_reg <= 0;
    end 
  else
    begin
     rd_enable_reg <= rd_enable;
     rd_addr_cnn_reg <= rd_addr_cnn;
     rd_addr_fc_reg <= rd_addr_fc;
    end
end


endmodule                                    
