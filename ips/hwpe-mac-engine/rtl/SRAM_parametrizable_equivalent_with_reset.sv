module SRAM_parametrizable_equivalent_with_reset #(
parameter integer numWord=2048,
parameter integer numBit=32) (
                        reset,
                        CLK, CEB, WEB,
                        A, D, 
                        Q
);

// Define Parameter


parameter numWordAddr = $clog2(numWord);



// Mode Control   
// Normal Mode Input
input reset;
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
always @(posedge CLK or negedge reset)
  begin
     if (!reset)
      // Correction in error
       for (i=0; i< numWord; i=i+1)
         memory[i] <= 0;
     else
      if ((CEB==0) && (WEB==0))
        begin
          memory[A]<= D;
        end  
  end
  
 //Reading
 always @(posedge CLK or negedge reset)
  begin
    if (!reset)
	Q <= 0;
    else
    if ((CEB==0) && (WEB==1))
      begin
        Q <= memory[A];
      end
  end
  
endmodule
