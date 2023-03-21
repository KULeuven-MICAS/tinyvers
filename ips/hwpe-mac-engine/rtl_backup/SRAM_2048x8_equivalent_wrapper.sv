module SRAM_2048x8_equivalent_wrapper(
                        CLK, CEB, WEB,
                        A, D, 
                        Q0, Q1, Q2, Q3
);

parameter numWord = 4096;
parameter numRow = 512;
parameter numCM = 4;
parameter numBit = 32;
parameter numWordAddr = 12;
parameter numRowAddr = 9;
parameter numCMAddr = 2;
parameter integer SRAM_blocks_per_row=4;
parameter integer SRAM_numBit=8;

input CLK;
input CEB;
input WEB;
input [numWordAddr-1:0] A;
input [numBit-1:0] D;
// Data Output
output reg [SRAM_numBit-1:0] Q0;
output reg [SRAM_numBit-1:0] Q1;
output reg [SRAM_numBit-1:0] Q2;
output reg [SRAM_numBit-1:0] Q3;

reg [SRAM_numBit-1:0] D_s [SRAM_blocks_per_row-1:0];
reg [numBit-1:0] Q_s;
genvar j;

//assign D_s[0] = D[7:0];
//assign D_s[1] = D[15:8];
//assign D_s[2] = D[23:16];
//assign D_s[3] = D[31:24];

assign Q3 = Q_s[7:0];
assign Q2 = Q_s[15:8];
assign Q1 = Q_s[23:16];
assign Q0 = Q_s[31:24];

ST_SPHD_LOLEAK_4096x32m8_bTMRl_wrapper SRAM_equivalent_i
         (
            .CK    ( CLK         ),
            .INITN ( 1'b1        ),
            .D     ( D           ),
            .A     ( A           ),
            .CSN   ( CEB         ),
            .WEN   ( WEB         ),
            .M     ( '0        ),
            .Q     ( Q_s         )
         );

endmodule
