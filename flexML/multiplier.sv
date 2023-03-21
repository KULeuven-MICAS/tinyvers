import parameters::*;

module multiplier (
  input_0,
  input_1,
  out // output
);
input  signed [INPUT_CHANNEL_DATA_WIDTH -1:0] input_0, input_1;
output reg signed [2*INPUT_CHANNEL_DATA_WIDTH -1:0] out;

always @(*)
begin
  out=input_0*input_1;
end
endmodule
