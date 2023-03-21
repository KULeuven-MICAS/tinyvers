module SRAM_parametrizable_equivalent #(
parameter integer numWord=2048,
parameter integer numBit=32) (
                        CLK, CEB, WEB,
                        A, D, 
                        Q
);

// Define Parameter


parameter numWordAddr = $clog2(numWord);



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
/*integer i;
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
*/

MEMS1D_BUFG_2048x32_wrapper SRAM_i
         (
            .CLK   ( CLK         ),
            .D     ( D           ),
            .AS    ( A[10:9]     ),
            .AW    ( A[8:2]      ),
            .AC    ( A[1:0]      ),
            .CEN   ( CEB         ),
            .RDWEN ( WEB         ),
            .BW    ( '1          ),
            .Q     ( Q           )
         );  
endmodule
