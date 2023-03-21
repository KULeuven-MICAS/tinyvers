module SRAM_parametrizable_w_equivalent #(
parameter integer numWord=2048,
parameter integer numBit=32) (
                        CLK, CEB, WEB,
                        scan_en_in,
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
input scan_en_in;
input [numWordAddr-1:0] A;
input [numBit-1:0] D;
// Data Output
output reg [numBit-1:0] Q;

wire CLK_gated;

/*
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
*/

        MEMS1D_BUFG_512x32_wrapper SRAM_i
         (
            .CLK   ( CLK_gated   ),
            .D     ( D           ),
            .AS    ( A[8]        ),
            .AW    ( A[7:2]      ),
            .AC    ( A[1:0]      ),
            .CEN   ( CEB         ),
            .RDWEN ( WEB         ),
            .BW    ( '1          ),
            .Q     ( Q           )
         );

pulp_clock_gating i_clk_gate_l1_wt
  (
    .clk_i(CLK),
    .en_i(~scan_en_in),
    .test_en_i(1'b0),
    .clk_o(CLK_gated)
  );

endmodule
