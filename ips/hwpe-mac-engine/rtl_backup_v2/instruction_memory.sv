import parameters::*;

module instruction_memory(
clk, reset, PC,
wr_addr_ext_im,
wr_data_ext_im,
wr_en_ext_im,
instruction
);

// Instruction memory that saves the layers to be executed

input clk, reset;
input wr_en_ext_im;
input [BIT_WIDTH_EXTERNAL_PORT-1:0] wr_addr_ext_im;
input [BIT_WIDTH_EXTERNAL_PORT-1:0] wr_data_ext_im;
input [31:0] PC;
output  [INSTRUCTION_MEMORY_WIDTH-1:0] instruction[INSTRUCTION_MEMORY_FIELDS-1:0];
//regs
reg [INSTRUCTION_MEMORY_WIDTH-1:0] instruction_memory[INSTRUCTION_MEMORY_SIZE-1:0][INSTRUCTION_MEMORY_FIELDS-1:0]; // 32 possible layers with 24 options of 16 bits
reg   [INSTRUCTION_MEMORY_WIDTH-1:0] im_file  [0:INSTRUCTION_MEMORY_SIZE*INSTRUCTION_MEMORY_FIELDS-1];
integer i;
integer l;

always @(posedge clk or negedge reset)
begin
    if (!reset)
  begin
          for( i=0; i<INSTRUCTION_MEMORY_SIZE; i=i+1) //Can be statically unrolled
            for( l=0;l<INSTRUCTION_MEMORY_FIELDS; l=l+1)
              instruction_memory[i][l] <= 0;
  end 
  else
  begin 
      if (wr_en_ext_im)
        instruction_memory[wr_addr_ext_im[31:$clog2(INSTRUCTION_MEMORY_FIELDS)]][wr_addr_ext_im[$clog2(INSTRUCTION_MEMORY_FIELDS)-1:0]] <= wr_data_ext_im;
  end
end 

assign instruction = instruction_memory[PC];

endmodule
