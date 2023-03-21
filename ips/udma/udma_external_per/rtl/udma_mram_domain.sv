// Copyright 2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

///////////////////////////////////////////////////////////////////////////////
//
// Description: MRAM top level
//
///////////////////////////////////////////////////////////////////////////////
//
// Authors    : Antonio Pullini (pullinia@iis.ee.ethz.ch)
// Authors    : Igor Loi (igor.loi@greenwaves-technologies.com)
//
///////////////////////////////////////////////////////////////////////////////

/*
 TODO: 
 1) ADD FF on MRAM signals
 2) Add capability to write from address that is not aligned to 64 bit
*/



`timescale 1ns/1ps
module udma_mram_domain
#(
    parameter TRANS_SIZE       = 20,
    parameter MRAM_ADDR_WIDTH  = 16,

    parameter TX_CMD_WIDTH     = MRAM_ADDR_WIDTH+TRANS_SIZE+11,
    parameter TX_DATA_WIDTH    = 32,
    parameter TX_DC_FIFO_DEPTH = 4,

    parameter RX_CMD_WIDTH     = MRAM_ADDR_WIDTH+TRANS_SIZE+11,
    parameter RX_DATA_WIDTH    = 64,
    parameter RX_DC_FIFO_DEPTH = 4

)
(
    input  logic                        mram_clk_i,
    input  logic                        rstn_i,

    // Asynch IF from mram PD to Brute Force Synch
    output logic                        tx_busy_o,
    output logic                        rx_busy_o,
    output logic                        tx_done_o,
    output logic [1:0]                  rx_error_o,
    output logic                        trim_cfg_done_o,
    output logic                        erase_pending_o,
    output logic                        erase_done_o,
    output logic                        ref_line_pending_o,
    output logic                        ref_line_done_o,

    // ASYNCH IF for TX DATA
    input  logic [TX_DC_FIFO_DEPTH-1:0] data_tx_write_token_i,
    output logic [TX_DC_FIFO_DEPTH-1:0] data_tx_read_pointer_o,
    input  logic [TX_DATA_WIDTH-1:0]    data_tx_asynch_i,
    // ASYNCH IF for TX CMD
    input  logic [TX_DC_FIFO_DEPTH-1:0] cmd_tx_write_token_i,
    output logic [TX_DC_FIFO_DEPTH-1:0] cmd_tx_read_pointer_o,
    input  logic [TX_CMD_WIDTH-1:0]     cmd_tx_asynch_i,

    // ASYNCH IF for RX DATA
    output logic [RX_DC_FIFO_DEPTH-1:0] data_rx_write_token_o,
    input  logic [RX_DC_FIFO_DEPTH-1:0] data_rx_read_pointer_i,
    output logic [RX_DATA_WIDTH-1:0]    data_rx_asynch_o,
    // ASYNCH IF for RX CMD
    input  logic [RX_DC_FIFO_DEPTH-1:0] cmd_rx_write_token_i,
    output logic [RX_DC_FIFO_DEPTH-1:0] cmd_rx_read_pointer_o,
    input  logic [RX_CMD_WIDTH-1:0]     cmd_rx_asynch_i,

    // Static signals used to drive some static pins of the MRAM. Rsynchronized in the MRAM PD 
    input  logic [4:0]                  mram_mode_static_i, //{ s_mram_PORb ,s_mram_RETb ,s_mram_RSTb ,s_mram_DPD,s_mram_ECCBYPS}
    input  logic [15:0]                 mram_erase_addr_i,
    input  logic [9:0]                  mram_erase_size_i,

    output logic                        mram_clk_en_o,
    output logic                        rstn_dcfifo_o,

    //input  logic                        pmu_rstn_i,
    //input  logic                        pmu_rst_ctrl_i,
    //output logic                        pmu_rst_ack_o,
    //input  logic                        pmu_clken_i,
    input  logic                        dft_test_mode_i,
    input logic                        VDDA_i,
    input logic                        VDD_i,
    input logic                        VREF_i,
    input logic                        PORb_i,
    input logic                        RETb_i,
    input logic                        RSTb_i,
    input logic                        TRIM_i,
    input logic                        DPD_i,
    input logic                        CEb_HIGH_i
);


    // Output of the DC TX CMD FIFO
    logic                        s_cmd_tx_dc_push_req;
    logic                        s_cmd_tx_dc_push_gnt;
    logic [TX_CMD_WIDTH-1:0]     s_cmd_tx_dc_push_dat;

    // Infos carried in the DC TX_CMD FIFO
    logic [MRAM_ADDR_WIDTH-1:0]  s_cmd_tx_dc_addr;
    logic [TRANS_SIZE-1:0]       s_cmd_tx_dc_size;
    logic [7:0]                  s_mram_mode_tx;
    logic                        s_NVR_tx;
    logic                        s_TMEN_tx;
    logic                        s_AREF_tx;


    // Output of the DC TX DATA FIFO
    logic                        s_data_tx_dc_valid;
    logic                        s_data_tx_dc_ready;
    logic [TX_DATA_WIDTH-1:0]    s_data_tx_dc_wdata;

    //DC RC CMD FIFO
    logic [RX_CMD_WIDTH-1:0]     s_cmd_rx_dc_push_dat;
    logic                        s_cmd_rx_dc_push_req;
    logic                        s_cmd_rx_dc_push_gnt;
    logic [TRANS_SIZE-1:0]       s_cmd_rx_dc_size;
    logic [MRAM_ADDR_WIDTH-1:0]  s_cmd_rx_dc_addr;
    logic [7:0]                  s_mram_mode_rx;
    logic                        s_NVR_rx;
    logic                        s_TMEN_rx;
    logic                        s_AREF_rx;

    //DC RX DATA FIFO
    logic                        s_data_rx_dc_valid;
    logic                        s_data_rx_dc_ready;
    logic [RX_DATA_WIDTH-1:0]    s_data_rx_dc;


    // Static SIgnals driven by the REG IF
    logic [4:0]               s_mram_mode_synch;//{ s_mram_PORb ,s_mram_RETb ,s_mram_RSTb ,s_mram_DPD,s_mram_ECCBYPS}

    logic [7:0]               s_mram_mode_tx_out;

    // MRAM SIGNALS
    logic [15:0]              mram_waddr;
    logic [77:0]              mram_wdata;
    logic                     mram_wreq;
    logic                     mram_weot;
    logic                     mram_wgnt;

    logic [15:0]              mram_raddr;
    logic                     mram_rclk_en;
    logic                     mram_rreq;
    logic                     mram_reot;
    logic                     mram_rgnt;
    logic [RX_DATA_WIDTH-1:0] mram_rdata;
    logic [1:0]               mram_rerror;

    // FROM TX SIZE CONV to TX-RX
    logic                     mram_NVR_tx;
    logic                     mram_TMEN_tx;
    logic                     mram_AREF_tx;

    // FROM RX SIZE CONV to TX-RX
    logic                     mram_NVR_rx;
    logic                     mram_TMEN_rx;
    logic                     mram_AREF_rx;


    // Signals that go to MRAM HARD MACRO
    logic                      s_mram_CLK;     // CLOCK pin
    logic                      s_mram_CEb;     // Chip enable (active low)
    logic [15:0]               s_mram_A;       // Address Inputs
    logic [77:0]               s_mram_DIN;     // Data Inputs
    logic [77:0]               s_mram_DOUT;    // Data Outputs
    logic                      s_mram_RDEN;    // Read Enable
    logic                      s_mram_WEb;     // Write Enable (active low)
    logic                      s_mram_PROGEN;  // Program Enable
    logic                      s_mram_PROG;    // Program signal
    logic                      s_mram_ERASE;   // Erase signal
    logic                      s_mram_SCE;     // Sector erase
    logic                      s_mram_CHIP;    // Chip Erase
    logic                      s_mram_PEON;    // Read in Program/Erase

    logic                      s_mram_PORb;    // Power On Reset Input
    logic                      s_mram_RETb;    // Configuration Register Retention
    logic                      s_mram_RSTb;    // Chip Reset
    logic                      s_mram_NVR;     // NVR Sector Selection
    logic                      s_mram_TMEN;    // Test Mode Enable
    logic                      s_mram_AREF;    // Ref Column Select
    logic                      s_mram_DPD;     // Deep Power Down
    logic                      s_mram_ECCBYPS; // To Bypass ECC Encoder and Decoder

    logic                      s_mram_SHIFT;   // Configuration Shift
    logic                      s_mram_SUPD;    // Configuration Register Update
    logic                      s_mram_SDI;     // Configuration register Input
    logic                      s_mram_SCLK;    // Configuration Register Clock
    logic                      s_mram_SDO;     // Configuration Register Output Configuration

    logic                      s_mram_RDY;     // Ready Status
    logic                      s_mram_DONE;    // Program/Erase Status
    logic                      s_mram_EC;      // ECC Error Correction
    logic                      s_mram_UE;      // Unrecoverable Error

    logic                      s_rstn;
    logic                      s_rstn_sync;

    //assign mram_clk_en_o = pmu_clken_i;
    //assign s_rstn = pmu_rstn_i & rstn_i;
    assign mram_clk_en_o = 1;
    assign s_rstn = rstn_i;
    assign rstn_dcfifo_o = s_rstn;
    assign rx_error_o = mram_rerror;

    assign s_mram_SCE = '0;
    assign s_mram_PEON = '0;

    rstgen i_mram_domain_rstgen
    (
        .clk_i       ( mram_clk_i      ),
        .test_mode_i ( dft_test_mode_i ),
        .rst_ni      ( s_rstn          ),   
        .rst_no      ( s_rstn_sync     ),  //to be used by logic clocked with ref clock in AO domain
        .init_no     ( )                 //not used
    );

    rstgen i_mram_rstctrl
    (
        .clk_i       ( mram_clk_i      ),
        .test_mode_i ( dft_test_mode_i ),
        .rst_ni      ( pmu_rst_ctrl_i  ),   
        .rst_no      ( pmu_rst_ack_o   ), 
        .init_no     ( )                 //not used
    );

    ///////////////////////////////////////////////////////////////////////////////////////////
    // ████████╗██╗  ██╗        ██████╗  ██████╗        ███████╗██╗███████╗ ██████╗ ███████╗ //
    // ╚══██╔══╝╚██╗██╔╝        ██╔══██╗██╔════╝        ██╔════╝██║██╔════╝██╔═══██╗██╔════╝ //
    //    ██║    ╚███╔╝         ██║  ██║██║             █████╗  ██║█████╗  ██║   ██║███████╗ //
    //    ██║    ██╔██╗         ██║  ██║██║             ██╔══╝  ██║██╔══╝  ██║   ██║╚════██║ //
    //    ██║   ██╔╝ ██╗███████╗██████╔╝╚██████╗███████╗██║     ██║██║     ╚██████╔╝███████║ //
    //    ╚═╝   ╚═╝  ╚═╝╚══════╝╚═════╝  ╚═════╝╚══════╝╚═╝     ╚═╝╚═╝      ╚═════╝ ╚══════╝ //
    ///////////////////////////////////////////////////////////////////////////////////////////
    assign {s_mram_mode_tx, s_NVR_tx, s_TMEN_tx, s_AREF_tx, s_cmd_tx_dc_size, s_cmd_tx_dc_addr} = s_cmd_tx_dc_push_dat;

    dc_token_ring_fifo_dout
    #(
       .DATA_WIDTH    ( TX_CMD_WIDTH          ),
       .BUFFER_DEPTH  ( TX_DC_FIFO_DEPTH      )
    )
    u_push_cmd_tx_dout
    (
        .clk          ( mram_clk_i            ),
        .rstn         ( s_rstn_sync           ),

        // Synch Side (OUTPUT)
        .data         ( s_cmd_tx_dc_push_dat ),
        .valid        ( s_cmd_tx_dc_push_req ),
        .ready        ( s_cmd_tx_dc_push_gnt ),

        //Asynch Side (INPUT)
        .write_token  ( cmd_tx_write_token_i  ),
        .read_pointer ( cmd_tx_read_pointer_o ),
        .data_async   ( cmd_tx_asynch_i       )
    );


    dc_token_ring_fifo_dout
    #(
       .DATA_WIDTH    ( TX_DATA_WIDTH          ),
       .BUFFER_DEPTH  ( TX_DC_FIFO_DEPTH       )
    )
    u_dc_fifo_tx_dout
    (
        .clk          ( mram_clk_i             ),
        .rstn         ( s_rstn_sync            ),

        // Synch Side (OUTPUT)
        .data         ( s_data_tx_dc_wdata     ),
        .valid        ( s_data_tx_dc_valid     ),
        .ready        ( s_data_tx_dc_ready     ),

        //Asynch Side (INPUT)
        .write_token  ( data_tx_write_token_i  ),
        .read_pointer ( data_tx_read_pointer_o ),
        .data_async   ( data_tx_asynch_i       )
    );




    //////////////////////////////////////////////////////////////////////////////////////////
    // ██████╗ ██╗  ██╗        ██████╗  ██████╗        ███████╗██╗███████╗ ██████╗ ███████╗ //
    // ██╔══██╗╚██╗██╔╝        ██╔══██╗██╔════╝        ██╔════╝██║██╔════╝██╔═══██╗██╔════╝ //
    // ██████╔╝ ╚███╔╝         ██║  ██║██║             █████╗  ██║█████╗  ██║   ██║███████╗ //
    // ██╔══██╗ ██╔██╗         ██║  ██║██║             ██╔══╝  ██║██╔══╝  ██║   ██║╚════██║ //
    // ██║  ██║██╔╝ ██╗███████╗██████╔╝╚██████╗███████╗██║     ██║██║     ╚██████╔╝███████║ //
    // ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═════╝  ╚═════╝╚══════╝╚═╝     ╚═╝╚═╝      ╚═════╝ ╚══════╝ //
    //////////////////////////////////////////////////////////////////////////////////////////
    dc_token_ring_fifo_din
    #(
        .DATA_WIDTH   ( RX_DATA_WIDTH         ),
        .BUFFER_DEPTH ( RX_DC_FIFO_DEPTH      )
    )
    u_dc_fifo_rx_din 
    (
        .clk          ( mram_clk_i            ),
        .rstn         ( s_rstn_sync           ),
        .data         ( s_data_rx_dc          ),
        .valid        ( s_data_rx_dc_valid    ),
        .ready        ( s_data_rx_dc_ready    ),

        .write_token  ( data_rx_write_token_o  ),
        .read_pointer ( data_rx_read_pointer_i ),
        .data_async   ( data_rx_asynch_o       )
    );


    assign {s_mram_mode_rx, s_NVR_rx, s_TMEN_rx, s_AREF_rx, s_cmd_rx_dc_size, s_cmd_rx_dc_addr } = s_cmd_rx_dc_push_dat;

    dc_token_ring_fifo_dout
    #(
       .DATA_WIDTH    ( RX_CMD_WIDTH          ),
       .BUFFER_DEPTH  ( RX_DC_FIFO_DEPTH      )
    )
    u_push_cmd_rx_dout
    (
        .clk          ( mram_clk_i            ),
        .rstn         ( s_rstn_sync           ),

        // Synch Side (OUTPUT)
        .data         ( s_cmd_rx_dc_push_dat  ),
        .valid        ( s_cmd_rx_dc_push_req  ),
        .ready        ( s_cmd_rx_dc_push_gnt  ),

        //Asynch Side (INPUT)
        .write_token  ( cmd_rx_write_token_i  ),
        .read_pointer ( cmd_rx_read_pointer_o ),
        .data_async   ( cmd_rx_asynch_i       )
    );


    ////////////////////////////////////////////////////////////////////
    // ██████╗ ███████╗   ███████╗██╗   ██╗███╗   ██╗ ██████╗██╗  ██╗ //
    // ██╔══██╗██╔════╝   ██╔════╝╚██╗ ██╔╝████╗  ██║██╔════╝██║  ██║ //
    // ██████╔╝█████╗     ███████╗ ╚████╔╝ ██╔██╗ ██║██║     ███████║ //
    // ██╔══██╗██╔══╝     ╚════██║  ╚██╔╝  ██║╚██╗██║██║     ██╔══██║ //
    // ██████╔╝██║███████╗███████║   ██║   ██║ ╚████║╚██████╗██║  ██║ //
    // ╚═════╝ ╚═╝╚══════╝╚══════╝   ╚═╝   ╚═╝  ╚═══╝ ╚═════╝╚═╝  ╚═╝ //
    ////////////////////////////////////////////////////////////////////

    genvar i;
    generate
        for (i = 0; i < 5; i++)
        begin : synch_mram_mode
            pulp_sync u_pulp_sync
            (
                .clk_i    ( mram_clk_i            ),
                .rstn_i   ( s_rstn_sync           ),
                .serial_i ( mram_mode_static_i[i] ),
                .serial_o ( s_mram_mode_synch[i]  )
            );
        end
    endgenerate

    assign s_mram_PORb    = s_mram_mode_synch[4]; 
    assign s_mram_RETb    = s_mram_mode_synch[3];
    assign s_mram_RSTb    = s_mram_mode_synch[2]; 
    assign s_mram_DPD     = s_mram_mode_synch[1]; 
    assign s_mram_ECCBYPS = s_mram_mode_synch[0];






    size_conv_TX_32_to_64
    #(
        .TRANS_SIZE(TRANS_SIZE)
    )
    u_size_conv_TX_32_to_64
    (
         .clk                ( mram_clk_i            ),
         .rst_n              ( s_rstn_sync           ),

         // DATA TX FIFO
         .data_tx_wdata_i    ( s_data_tx_dc_wdata    ),
         .data_tx_valid_i    ( s_data_tx_dc_valid    ),
         .data_tx_ready_o    ( s_data_tx_dc_ready    ),
         //CMD TX FIFO
         .push_cmd_req_i     ( s_cmd_tx_dc_push_req  ),
         .push_cmd_gnt_o     ( s_cmd_tx_dc_push_gnt  ),
         .data_tx_addr_i     ( s_cmd_tx_dc_addr      ),
         .data_tx_size_i     ( s_cmd_tx_dc_size      ),

         .erase_addr_i       ( mram_erase_addr_i     ), //no synch here, datapath signals
         .erase_size_i       ( mram_erase_size_i     ), //no synch here, datapath signals

         // Control Signals to monitor the transfer status
         .pending_o          ( tx_busy_o             ),
         .tx_done_o          ( tx_done_o             ),
         .trim_cfg_done_o    ( trim_cfg_done_o       ),

         .erase_done_o       ( erase_done_o          ),
         .erase_pending_o    ( erase_pending_o       ),

         .ref_line_pending_o ( ref_line_pending_o    ),
         .ref_line_done_o    ( ref_line_done_o       ),

         // Signals to TX-RX
         .mram_mode_i        ( s_mram_mode_tx        ),
         .mram_mode_o        ( s_mram_mode_tx_out    ),
         .data_tx_wdata_o    ( mram_wdata            ),
         .data_tx_addr_o     ( mram_waddr            ),
         .data_tx_req_o      ( mram_wreq             ),
         .data_tx_eot_o      ( mram_weot             ),
         .data_tx_gnt_i      ( mram_wgnt             ),

         .NVR_i              ( s_NVR_tx              ),
         .TMEN_i             ( s_TMEN_tx             ),
         .AREF_i             ( s_AREF_tx             ),

         .mram_NVR_o         ( mram_NVR_tx           ),
         .mram_TMEN_o        ( mram_TMEN_tx          ),
         .mram_AREF_o        ( mram_AREF_tx          ),

         .mram_SHIFT_o       ( s_mram_SHIFT          ),   // Configuration Shift
         .mram_SUPD_o        ( s_mram_SUPD           ),   // Configuration Register Update
         .mram_SDI_o         ( s_mram_SDI            ),   // Configuration register Input
         .mram_SCLK_o        ( s_mram_SCLK           ),   // Configuration Register Clock
         .mram_SDO_i         ( s_mram_SDO            )    // Configuration Register Output Configuration

    );



    size_conv_RX_64_to_32
    #(
       .TRANS_SIZE(TRANS_SIZE)
    )
    u_size_conv_RX_32_to_64
    (
       .clk             ( mram_clk_i                  ),
       .rst_n           ( s_rstn_sync                 ),

       .push_cmd_req_i  ( s_cmd_rx_dc_push_req        ),
       .push_cmd_gnt_o  ( s_cmd_rx_dc_push_gnt        ),
       .data_rx_addr_i  ( s_cmd_rx_dc_addr            ),
       .data_rx_size_i  ( s_cmd_rx_dc_size            ),

       .data_rx_raddr_o ( mram_raddr                  ),
       .data_rx_clk_en_o( mram_rclk_en                ),
       .data_rx_req_o   ( mram_rreq                   ),
       .data_rx_eot_o   ( mram_reot                   ),
       .data_rx_gnt_i   ( mram_rgnt                   ),


       .mram_mode_i     ( s_mram_mode_rx              ),
       .NVR_i           ( s_NVR_rx                    ),
       .TMEN_i          ( s_TMEN_rx                   ),
       .AREF_i          ( s_AREF_rx                   ),

       .mram_NVR_o      ( mram_NVR_rx                 ),
       .mram_TMEN_o     ( mram_TMEN_rx                ),
       .mram_AREF_o     ( mram_AREF_rx                ),

       .data_rx_rdata_i ( mram_rdata                  ),
       .pending_o       ( rx_busy_o                   ),


       // If to DC fifo for read data 64 bit
       .data_rx_rdata_o ( s_data_rx_dc                ),
       .data_rx_valid_o ( s_data_rx_dc_valid          ),
       .data_rx_ready_i ( s_data_rx_dc_ready          )
    );





    TX_RX_to_MRAM i_TX_RX_to_MRAM
    (
        .clk                   ( mram_clk_i               ),
        .rst_n                 ( s_rstn_sync              ),
        .scan_en_in            ( dft_test_mode_i          ),

        .mram_mode_tx_i        ( s_mram_mode_tx_out       ),
        .data_tx_wdata_i       ( mram_wdata               ),
        .data_tx_addr_i        ( mram_waddr               ),
        .data_tx_req_i         ( mram_wreq                ),
        .data_tx_eot_i         ( mram_weot                ),
        .data_tx_gnt_o         ( mram_wgnt                ),

        .NVR_tx_i              ( mram_NVR_tx              ),
        .TMEN_tx_i             ( mram_TMEN_tx             ),
        .AREF_tx_i             ( mram_AREF_tx             ),

        .mram_mode_rx_i        ( s_mram_mode_rx           ),
        .data_rx_raddr_i       ( mram_raddr               ),
        .data_rx_clk_en_i      ( mram_rclk_en             ),
        .data_rx_req_i         ( mram_rreq                ),
        .data_rx_eot_i         ( mram_reot                ),
        .data_rx_gnt_o         ( mram_rgnt                ),
        .data_rx_rdata_o       ( mram_rdata               ),
        .data_rx_error_o       ( mram_rerror              ),

        .NVR_rx_i              ( mram_NVR_rx              ),
        .TMEN_rx_i             ( mram_TMEN_rx             ),
        .AREF_rx_i             ( mram_AREF_rx             ),


        .CEb_o                 (  s_mram_CEb              ),
        .A_o                   (  s_mram_A                ),
        .DIN_o                 (  s_mram_DIN              ),
        .RDEN_o                (  s_mram_RDEN             ),
        .WEb_o                 (  s_mram_WEb              ),
        .PROGEN_o              (  s_mram_PROGEN           ),
        .PROG_o                (  s_mram_PROG             ),
        .ERASE_o               (  s_mram_ERASE            ),
        .CHIP_o                (  s_mram_CHIP             ),
        .DONE_i                (  s_mram_DONE             ),
        .DOUT_i                (  s_mram_DOUT             ),
        .CLK_o                 (  s_mram_CLK              ),
        .EC_i                  (  s_mram_EC               ),
        .UE_i                  (  s_mram_UE               ),
        .NVR_o                 (  s_mram_NVR              ),
        .TMEN_o                (  s_mram_TMEN             ), 
        .AREF_o                (  s_mram_AREF             )
    );



`ifndef SYNTHESIS   
    supply1 VREF, VPR, VDDA, VDD_cfg, VDD;
    supply0 VSS;

    initial
    begin
        force i_MRAM_eFLASH_64Kx78.cr_lat = '0;
    end
`endif


`ifndef PULP_FPGA_EMUL
    MRAM_eFLASH_64Kx78 i_MRAM_eFLASH_64Kx78
    (
        .CLK                    (  s_mram_CLK      ),
        .CEb                    (  s_mram_CEb || CEb_HIGH_i ),
        .A                      (  s_mram_A        ),
        .DIN                    (  s_mram_DIN      ),
        .RDEN                   (  s_mram_RDEN     ),
        .WEb                    (  s_mram_WEb      ),
        .PROGEN                 (  s_mram_PROGEN   ),
        .PROG                   (  s_mram_PROG     ),
        .ERASE                  (  s_mram_ERASE    ),
        .SCE                    (  s_mram_SCE      ),
        .CHIP                   (  s_mram_CHIP     ),
        .PEON                   (  s_mram_PEON     ),
        .DONE                   (  s_mram_DONE     ),
        .RDY                    (  s_mram_RDY      ),
        .DOUT                   (  s_mram_DOUT     ),

        .TMEN                   (  s_mram_TMEN     ),
        //.AREF                   (  s_mram_AREF     ),
        .NVR                    (  s_mram_NVR      ),

        .PORb                   (  s_mram_PORb || PORb_i    ),
        .RSTb                   (  s_mram_RSTb || RSTb_i    ),
        .RETb                   (  s_mram_RETb || RETb_i    ),
        .DPD                    (  s_mram_DPD  || DPD_i     ),

        .SHIFT                  (  s_mram_SHIFT    ),
        .SUPD                   (  s_mram_SUPD     ),
        .SDI                    (  s_mram_SDI      ),
        .SCLK                   (  s_mram_SCLK     ),
        .SDO                    (  s_mram_SDO      ),

        .EC                     (  s_mram_EC       ),
        .UE                     (  s_mram_UE       ),
        .ECCBYPS                (  s_mram_ECCBYPS  ),
`ifndef SYNTHESIS   
        .VREF                   ( VREF_i           ),
        .VPR                    ( VPR              ),
        .VDDA                   ( VDDA_i           ),
        .VDD_cfg                ( VDD_cfg          ),
        .VDD                    ( VDD_i            ),
        .VSS                    ( VSS              ),
`endif
        .TMO                    (                  )
    );


`else // !`ifndef PULP_FPGA_EMUL
   assign s_mram_DONE = '0;
   assign s_mram_RDY  = '0;
   assign s_mram_DOUT = '0;
   assign s_mram_SDO  = '0;
   assign s_mram_EC   = '0;
   assign s_mram_UE   = '0;
`endif


endmodule // mram_domain
