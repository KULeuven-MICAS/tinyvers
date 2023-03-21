import parameters::*;

module encoder_FIFO(clk, reset,
input_rd_address,
input_wr_address,
rd_enable,
wr_enable,
FIFO_TCN_offset,
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
input [INPUT_CHANNEL_ADDR_SIZE-1:0] FIFO_TCN_block_size;
input [INPUT_CHANNEL_ADDR_SIZE-1:0] FIFO_TCN_total_blocks;
input [INPUT_CHANNEL_ADDR_SIZE-1:0] FIFO_TCN_offset;
input FIFO_TCN_active;
input FIFO_TCN_update_pointer;
output reg [INPUT_CHANNEL_ADDR_SIZE-1:0] output_rd_address; // Read Address for Activation Memory
output  reg [INPUT_CHANNEL_ADDR_SIZE-1:0] output_wr_address; // N Write addresses for activation memory

// signals
reg [INPUT_CHANNEL_ADDR_SIZE-1:0] FIFO_pointer;
reg [INPUT_CHANNEL_ADDR_SIZE-1:0] current_address_pointer_counter;
wire [INPUT_CHANNEL_ADDR_SIZE-1:0]  total_size_buffer;
wire [INPUT_CHANNEL_ADDR_SIZE-1:0]  diff;
reg FIFO_TCN_update_pointer_reg;

assign total_size_buffer  =FIFO_TCN_total_blocks*FIFO_TCN_block_size;
//difference between total size of buffer and the current address pointer
assign diff = total_size_buffer-current_address_pointer_counter;

always @(posedge clk or negedge reset)
begin
  if (!reset)
    current_address_pointer_counter <= 0; 
  else
    if (FIFO_TCN_update_pointer_reg)
      if (FIFO_pointer==(total_size_buffer-1))
        current_address_pointer_counter <= 0;
      else
        current_address_pointer_counter <= current_address_pointer_counter + FIFO_TCN_block_size;
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
  
  // Read address
  if ((input_rd_address + current_address_pointer_counter) < total_size_buffer )
    output_rd_address=input_rd_address + current_address_pointer_counter;
  else
    output_rd_address= input_rd_address - (diff);
  
  // Write address
    if ((input_wr_address + current_address_pointer_counter) < total_size_buffer )
    output_wr_address=input_wr_address + current_address_pointer_counter;
  else
    output_wr_address= input_wr_address - (diff);
    
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
      if (FIFO_pointer==(total_size_buffer-1))
        FIFO_pointer <= 0;
      else
        FIFO_pointer <= FIFO_pointer+1;
     end
end
endmodule
