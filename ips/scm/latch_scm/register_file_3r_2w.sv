// Copyright 2014-2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

////////////////////////////////////////////////////////////////////////////////
// Company:        Institute of Integrated Systems // ETH Zurich              //
//                                                                            //
// Engineer:      Igor Loi - igor.loi@unibo.it                                //
//                                                                            //
// Additional contributions by:                                               //
//                 Davide Rossi                                               //
//                 Michael Gautschi                                           //
//                 Antonio Pullini                                            //
//                                                                            //
// Create Date:    12/03/2015                                                 // 
// Design Name:    scm memory multiport                                       // 
// Module Name:    register_file_3r_2w                                        //
// Project Name:   PULP                                                       //
// Language:       SystemVerilog                                              //
//                                                                            //
// Description:    scm memory multiport: 3 read Ports, 2 Write ports          //
//                                                                            //
// Revision:                                                                  //
// Revision v0.1 - File Created                                               //
// Revision v0.2 - Improved Identation                                        //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////


module register_file_3r_2w
#(
    parameter ADDR_WIDTH    = 5,
    parameter ADDR_WIDTH_C  = 5,
    parameter DATA_WIDTH    = 32
)
(
    // Clock and Reset
    input  logic                        clk,
    input  logic                        rst_n,

    //Read port R1
    input  logic [ADDR_WIDTH-1:0]       raddr_a_i,
    output logic [DATA_WIDTH-1:0]       rdata_a_o,

    //Read port R2
    input  logic [ADDR_WIDTH-1:0]       raddr_b_i,
    output logic [DATA_WIDTH-1:0]       rdata_b_o,

    //Read port R3
    input  logic [ADDR_WIDTH_C-1:0]     raddr_c_i,
    output logic [DATA_WIDTH-1:0]       rdata_c_o,

    // Write port W1
    input logic [ADDR_WIDTH-1:0]        waddr_a_i,
    input logic [DATA_WIDTH-1:0]        wdata_a_i,
    input logic                         we_a_i,

    // Write port W2
    input logic [ADDR_WIDTH-1:0]        waddr_b_i,
    input logic [DATA_WIDTH-1:0]        wdata_b_i,
    input logic                         we_b_i
);

    localparam    NUM_WORDS = 2**ADDR_WIDTH;

    // Read address register, located at the input of the address decoder
    logic [ADDR_WIDTH-1:0]                         RAddrRegxDPa; 
    logic [ADDR_WIDTH-1:0]                         RAddrRegxDPb; 
    logic [ADDR_WIDTH-1:0]                         RAddrRegxDPc; 
    logic [NUM_WORDS-1:0]                          RAddrOneHotxD;
    logic [ADDR_WIDTH-1:0]                         s_raddr_c;

    logic [DATA_WIDTH-1:0]                         MemContentxDP[NUM_WORDS];

    logic [NUM_WORDS-1:0]                          WAddrOneHotxDa;
    logic [NUM_WORDS-1:0]                          WAddrOneHotxDb;
    logic [NUM_WORDS-1:0]                          WAddrOneHotxDb_reg;

    logic [NUM_WORDS-1:0]                          ClocksxC;
    logic [DATA_WIDTH-1:0]                         WDataIntxDa;
    logic [DATA_WIDTH-1:0]                         WDataIntxDb;

    logic clk_int;

    logic we_int;

    int unsigned i;
    int unsigned j;
    int unsigned k;
    int unsigned l;
    int unsigned m;

    genvar x;
    genvar y;

    assign we_int = we_a_i | we_b_i;

    localparam ADDR_DIFF = ADDR_WIDTH-ADDR_WIDTH_C;

    assign s_raddr_c = (ADDR_WIDTH == ADDR_WIDTH_C) ? raddr_c_i : {{ADDR_DIFF{1'b1}},raddr_c_i};

    cluster_clock_gating CG_WE_GLOBAL
    (
        .clk_o(clk_int),
        .en_i(we_int),
        .test_en_i(1'b0),
        .clk_i(clk)
    );

    //-----------------------------------------------------------------------------
    //-- READ : Read address register
    //-----------------------------------------------------------------------------
    //    always_ff @(posedge clk)
    //    begin : p_RAddrReg_a
    //            if(ren_a_i)
    //                    RAddrRegxDPa <= raddr_a_i;
    //    end
    //
    //    always_ff @(posedge clk)
    //    begin : p_RAddrReg_b
    //            if(ren_b_i)
    //                    RAddrRegxDPb <= raddr_b_i;
    //    end

    //-----------------------------------------------------------------------------
    //-- READ : Read address decoder RAD
    //-----------------------------------------------------------------------------  
    //    assign rdata_a_o = MemContentxDP[RAddrRegxDPa];
    //    assign rdata_b_o = MemContentxDP[RAddrRegxDPb];
    assign rdata_a_o = MemContentxDP[raddr_a_i];
    assign rdata_b_o = MemContentxDP[raddr_b_i];
    assign rdata_c_o = MemContentxDP[s_raddr_c];


    //-----------------------------------------------------------------------------
    //-- WRITE : Write Address Decoder (WAD), combinatorial process
    //-----------------------------------------------------------------------------
    always_comb
    begin : p_WADa
        for(i=0; i<NUM_WORDS; i++)
        begin : p_WordItera
            if ( (we_a_i == 1'b1 ) && (waddr_a_i == i) )
                WAddrOneHotxDa[i] = 1'b1;
            else
                WAddrOneHotxDa[i] = 1'b0;
        end
    end

    always_comb
    begin : p_WADb
        for(j=0; j<NUM_WORDS; j++)
        begin : p_WordIterb
            if ( (we_b_i == 1'b1 ) && (waddr_b_i == j) )
                WAddrOneHotxDb[j] = 1'b1;
            else
                WAddrOneHotxDb[j] = 1'b0;
        end
    end

    always_ff @(posedge clk_int)
    begin 
        if(we_a_i | we_b_i)
            WAddrOneHotxDb_reg <= WAddrOneHotxDb;
    end

    //-----------------------------------------------------------------------------
    //-- WRITE : Clock gating (if integrated clock-gating cells are available)
    //-----------------------------------------------------------------------------
    generate
    for(x=0; x<NUM_WORDS; x++)
    begin : CG_CELL_WORD_ITER
        cluster_clock_gating CG_Inst
        (
            .clk_o(ClocksxC[x]),
            .en_i(WAddrOneHotxDa[x] | WAddrOneHotxDb[x]),
            .test_en_i(1'b0),
            .clk_i(clk_int)
        );
        end
    endgenerate

    //-----------------------------------------------------------------------------
    // WRITE : SAMPLE INPUT DATA
    //---------------------------------------------------------------------------  
    always_ff @(posedge clk)
    begin : sample_waddr
        if(we_a_i)
            WDataIntxDa <= wdata_a_i;
        if(we_b_i)
            WDataIntxDb <= wdata_b_i;
    end

    //-----------------------------------------------------------------------------
    //-- WRITE : Write operation
    //-----------------------------------------------------------------------------  
    //-- Generate M = WORDS sequential processes, each of which describes one
    //-- word of the memory. The processes are synchronized with the clocks
    //-- ClocksxC(i), i = 0, 1, ..., M-1
    //-- Use active low, i.e. transparent on low latches as storage elements
    //-- Data is sampled on rising clock edge


    always_latch
    begin : latch_wdata
        for(k=0; k<NUM_WORDS; k++)
        begin : w_WordIter
            if( ClocksxC[k] == 1'b1)
                MemContentxDP[k] = WAddrOneHotxDb_reg[k] ? WDataIntxDb : WDataIntxDa;
        end
    end


endmodule