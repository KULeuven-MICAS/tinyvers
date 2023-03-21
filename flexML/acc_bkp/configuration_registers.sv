import parameters::*;

module configuration_registers(
   clk, reset,
   wr_en_ext,
   wr_addr_ext,
   wr_data_ext,
  MEMORY_POINTER_FC,
  EXECUTION_FRAME_BY_FRAME,
  FIRST_INDEX_FC_LOG
);
input clk, reset;
input wr_en_ext;
input [31:0] wr_addr_ext;
input [31:0] wr_data_ext;
output reg [31:0] MEMORY_POINTER_FC;
output reg [31:0] FIRST_INDEX_FC_LOG;
output reg  [31:0]EXECUTION_FRAME_BY_FRAME;

//signals
reg  signed [31:0] conf_file  [0:CONF_REGISTERS_SIZE-1];

integer i;

assign MEMORY_POINTER_FC=conf_file[0]; // First index of FC layer
assign FIRST_INDEX_FC_LOG = conf_file[1];
assign EXECUTION_FRAME_BY_FRAME =conf_file[2];

always @(posedge clk or negedge reset)
begin
  if (!reset)
  begin
    for( i=0; i<CONF_REGISTERS_SIZE; i=i+1)
      begin
        conf_file[i] <= 0;
      end
  end 
  else
  begin 
      if (wr_en_ext)
        conf_file[wr_addr_ext] <= wr_data_ext;
  end
end
endmodule

