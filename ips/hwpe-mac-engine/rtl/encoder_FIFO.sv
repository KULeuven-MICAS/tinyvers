import parameters::*;

module encoder_FIFO(clk, reset,
input_rd_address,
input_wr_address,
rd_enable,
wr_enable,
FIFO_TCN_total_blocks,
FIFO_TCN_block_size,
FIFO_TCN_active,
FIFO_TCN_update_pointer,
output_rd_address,
output_wr_address
);

// This module aims to encode the address sent (reading/writing) to the activation memory in order to simulate a FIFO.
// input_rd_address: address to read from act memory
// input_wr_address: address to write to act memory
// rd_enable: read enable
// wr_enable: write enable
// FIFO_TCN_active: If TCN incremental execution is activated
// FIFO_TCN_offset: Offset for TCN calculation
// FIFO_TCN_total_blocks: Total input vectors
// FIFO_TCN_update_pointer: Update FIFO
// output_rd_address: encoded address for reading
// output_wr_address: encoded address for writing

input clk, reset;
input  [INPUT_CHANNEL_ADDR_SIZE-1:0] input_wr_address; // N Write addresses for activation memory
input [INPUT_CHANNEL_ADDR_SIZE-1:0] input_rd_address; // Read Address for Activation Memory
input rd_enable, wr_enable;
input [31:0] FIFO_TCN_block_size;
input [INPUT_CHANNEL_ADDR_SIZE-1:0] FIFO_TCN_total_blocks;
input FIFO_TCN_active;
input FIFO_TCN_update_pointer;
output reg [INPUT_CHANNEL_ADDR_SIZE-1:0] output_rd_address; // Read Address for Activation Memory
output  reg [INPUT_CHANNEL_ADDR_SIZE-1:0] output_wr_address; // N Write addresses for activation memory




// signals
reg [15:0] rd_FIFO_TCN_block_size;
reg [15:0] wr_FIFO_TCN_block_size;

assign rd_FIFO_TCN_block_size=FIFO_TCN_block_size[15:0];
assign wr_FIFO_TCN_block_size=FIFO_TCN_block_size[31:16];

reg [INPUT_CHANNEL_ADDR_SIZE-1:0] FIFO_pointer;
reg [INPUT_CHANNEL_ADDR_SIZE-1:0] rd_current_address_pointer_counter;
reg [INPUT_CHANNEL_ADDR_SIZE-1:0] wr_current_address_pointer_counter;
wire [INPUT_CHANNEL_ADDR_SIZE-1:0]  total_size_buffer;
wire [INPUT_CHANNEL_ADDR_SIZE-1:0]  rd_total_size_buffer;
wire [INPUT_CHANNEL_ADDR_SIZE-1:0]  wr_total_size_buffer;


wire [INPUT_CHANNEL_ADDR_SIZE-1:0]  rd_diff;
wire [INPUT_CHANNEL_ADDR_SIZE-1:0]  wr_diff;

reg FIFO_TCN_update_pointer_reg;

assign rd_total_size_buffer  =FIFO_TCN_total_blocks*rd_FIFO_TCN_block_size;
assign wr_total_size_buffer  =FIFO_TCN_total_blocks*wr_FIFO_TCN_block_size;

//difference between total size of buffer and the current address pointer
assign rd_diff = rd_total_size_buffer-rd_current_address_pointer_counter;
assign wr_diff = wr_total_size_buffer-wr_current_address_pointer_counter;

always @(*)
  begin
  rd_current_address_pointer_counter =FIFO_pointer*rd_FIFO_TCN_block_size;
  wr_current_address_pointer_counter =FIFO_pointer*wr_FIFO_TCN_block_size;
  end 



always @(*)
begin
  if (FIFO_TCN_active==0)  // if FIFO for incremental execution is not active
  begin
  output_rd_address=input_rd_address;
  output_wr_address=input_wr_address;
  end
  else
  begin
  

   
  if ((input_rd_address +(rd_total_size_buffer - rd_current_address_pointer_counter))< rd_total_size_buffer)
   output_rd_address= input_rd_address +(rd_total_size_buffer - rd_current_address_pointer_counter);
  else
   output_rd_address= input_rd_address - rd_current_address_pointer_counter;
  if ((input_wr_address +(wr_total_size_buffer - wr_current_address_pointer_counter))< wr_total_size_buffer)
   output_wr_address= input_wr_address +(wr_total_size_buffer - wr_current_address_pointer_counter);
  else
   output_wr_address= input_wr_address -  wr_current_address_pointer_counter;

  end
  end



always @(posedge clk or negedge reset)
  begin
    if (!reset)
      FIFO_TCN_update_pointer_reg<=0;
    else
      FIFO_TCN_update_pointer_reg <= FIFO_TCN_update_pointer;
  end
  
always @(posedge clk or negedge reset)
begin
  if (!reset)
  begin
  FIFO_pointer <= 0;
  end
  else
    begin
    if (FIFO_TCN_update_pointer_reg)
      //if (FIFO_pointer==(total_size_buffer-1))

      if (FIFO_pointer==(FIFO_TCN_total_blocks-1))

        FIFO_pointer <= 0;
      else
        FIFO_pointer <= FIFO_pointer+1;
     end
end
endmodule
