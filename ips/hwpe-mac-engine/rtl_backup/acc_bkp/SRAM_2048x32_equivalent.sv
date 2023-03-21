import parameters::*;

module SRAM_2048x32_equivalent(
                        CLK, CEB, WEB,
                        A, D, 
                        Q
);

// Define Parameter
parameter numWord = 2048;
parameter numRow = 512;
parameter numCM = 4;
parameter numBit = 32;
parameter numWordAddr = 11;
parameter numRowAddr = 9;
parameter numCMAddr = 2;

// Mode Control   
// Normal Mode Input
input CLK;
input CEB;
input WEB;
input [numWordAddr-1:0] A;
input [numBit-1:0] D;
// Data Output
output reg [numBit-1:0] Q;

////// 
integer i;
reg [numBit-1:0] memory[numWord-1:0];

// Writing
always @(posedge CLK)
  begin
      if (CEB==0 && WEB==0)
        begin
          memory[A]<= D;
        end  
  end
  
 //Reading
 always @(posedge CLK)
  begin
    if (CEB==0 && WEB==1)
      begin
        Q <= memory[A];
      end
  end
  
endmodule