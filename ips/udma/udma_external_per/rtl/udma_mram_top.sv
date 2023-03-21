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





`timescale 1ns/1ps
module udma_mram_top
#(
    parameter L2_AWIDTH_NOAL   = 12,
    parameter TRANS_SIZE       = 16,
    parameter MRAM_ADDR_WIDTH  = 16,

    parameter TX_CMD_WIDTH     = MRAM_ADDR_WIDTH+TRANS_SIZE+11,
    parameter TX_DATA_WIDTH    = 32,
    parameter TX_DC_FIFO_DEPTH = 4,

    parameter RX_CMD_WIDTH     = MRAM_ADDR_WIDTH+TRANS_SIZE+11,
    parameter RX_DATA_WIDTH    = 64,
    parameter RX_DC_FIFO_DEPTH = 4
)
(
    input  logic                      sys_clk_i,
    input  logic                      periph_clk_i,
    input  logic                      rstn_i,

    input  logic                      dft_test_mode_i,
    input  logic                      dft_cg_enable_i,

    input  logic               [31:0] cfg_data_i,
    input  logic                [4:0] cfg_addr_i,
    input  logic                      cfg_valid_i,
    input  logic                      cfg_rwn_i,
    output logic                      cfg_ready_o,
    output logic               [31:0] cfg_data_o,

    output logic [L2_AWIDTH_NOAL-1:0] cfg_rx_startaddr_o,
    output logic     [TRANS_SIZE-1:0] cfg_rx_size_o,
    output logic                      cfg_rx_continuous_o,
    output logic                      cfg_rx_en_o,
    output logic                      cfg_rx_clr_o,
    input  logic                      cfg_rx_en_i,
    input  logic                      cfg_rx_pending_i,
    input  logic [L2_AWIDTH_NOAL-1:0] cfg_rx_curr_addr_i,
    input  logic     [TRANS_SIZE-1:0] cfg_rx_bytes_left_i,

    output logic [L2_AWIDTH_NOAL-1:0] cfg_tx_startaddr_o,
    output logic     [TRANS_SIZE-1:0] cfg_tx_size_o,
    output logic                      cfg_tx_continuous_o,
    output logic                      cfg_tx_en_o,
    output logic                      cfg_tx_clr_o,
    input  logic                      cfg_tx_en_i,
    input  logic                      cfg_tx_pending_i,
    input  logic [L2_AWIDTH_NOAL-1:0] cfg_tx_curr_addr_i,
    input  logic     [TRANS_SIZE-1:0] cfg_tx_bytes_left_i,

    // FROM_to L2
    output logic                      data_tx_req_o,
    input  logic                      data_tx_gnt_i,
    output logic                [1:0] data_tx_datasize_o, // 8 , 16 o 32
    input  logic               [31:0] data_tx_i,
    input  logic                      data_tx_valid_i,
    output logic                      data_tx_ready_o,

    output logic                [1:0] data_rx_datasize_o,
    output logic               [31:0] data_rx_o,
    output logic                      data_rx_valid_o,
    input  logic                      data_rx_ready_i,

    output logic                      erase_done_event_o,
    output logic                      ref_line_done_event_o,
    output logic                      trim_cfg_done_event_o,
    output logic                      tx_done_event_o,



    // Asynch IF from mram PD to Brute Force Synch
    input logic                       tx_busy_i,
    input logic                       rx_busy_i,
    input logic                       tx_done_i,
    input logic [1:0]                 rx_error_i,
    input logic                       trim_cfg_done_i,
    input logic                       erase_pending_i,
    input logic                       erase_done_i,
    input logic                       ref_line_pending_i,
    input logic                       ref_line_done_i,

    // ASYNCH IF for TX DATA
    output logic [TX_DC_FIFO_DEPTH-1:0] data_tx_write_token_o,
    input  logic [TX_DC_FIFO_DEPTH-1:0] data_tx_read_pointer_i,
    output logic [TX_DATA_WIDTH-1:0]    data_tx_asynch_o,
    // ASYNCH IF for TX CMD
    output logic [TX_DC_FIFO_DEPTH-1:0] cmd_tx_write_token_o,
    input  logic [TX_DC_FIFO_DEPTH-1:0] cmd_tx_read_pointer_i,
    output logic [TX_CMD_WIDTH-1:0]     cmd_tx_asynch_o,

    // ASYNCH IF for RX DATA
    input  logic [RX_DC_FIFO_DEPTH-1:0] data_rx_write_token_i,
    output logic [RX_DC_FIFO_DEPTH-1:0] data_rx_read_pointer_o,
    input  logic [RX_DATA_WIDTH-1:0]    data_rx_asynch_i,
    // ASYNCH IF for RX CMD
    output logic [RX_DC_FIFO_DEPTH-1:0] cmd_rx_write_token_o,
    input  logic [RX_DC_FIFO_DEPTH-1:0] cmd_rx_read_pointer_i,
    output logic [RX_CMD_WIDTH-1:0]     cmd_rx_asynch_o,

    // Static signals used to drive some static pins of the MRAM. Rsynchronized in the MRAM PD 
    output logic [4:0]                  mram_mode_static_o, //{ s_mram_PORb ,s_mram_RETb ,s_mram_RSTb ,s_mram_DPD,s_mram_ECCBYPS }

    input  logic                        rstn_dcfifo_i,
    // Mram Clock
    output logic                        mram_clk_o,
    input  logic                        mram_clk_en_i,
    output logic [15:0]                 mram_erase_addr_o,
    output logic [9:0]                  mram_erase_size_o
);

    logic                        mram_push_tx_req;
    logic [3:0]                  mram_irq_enable;
    logic                        cfg_tx_en_int;
    logic                        cfg_rx_en_int;

    // CLock Generator Signals
    logic                        s_clkdiv_valid;
    logic [7:0]                  s_clkdiv_data;
    logic                        s_clkdiv_ack;

    // Signals from DC_TX_FIFO to IO_FIFO
    logic                        s_data_tx_valid;
    logic                        s_data_tx_ready;
    logic [TX_DATA_WIDTH-1:0]    s_data_tx;

    logic [MRAM_ADDR_WIDTH-1:0]  s_cfg_tx_dest_addr;
    logic [TX_CMD_WIDTH-1:0]     s_cmd_tx_data;
    logic                        s_cmd_tx_valid;
    logic                        s_cmd_tx_ready;


    // RX Signals From DC FIFO to SERIALIZER
    logic [RX_DATA_WIDTH-1:0]    s_data_rx_to_ser;
    logic                        s_data_rx_valid_to_ser;
    logic                        s_data_rx_ready_from_ser;

    logic [MRAM_ADDR_WIDTH-1:0]  s_cfg_rx_dest_addr;
    logic [RX_CMD_WIDTH-1:0]     s_cmd_rx_data;
    logic                        s_cmd_rx_valid;    
    logic                        s_cmd_rx_ready;


    // Synchronized Signals from the MRAM PD (mram Clock --| sys_clock)
    logic                        s_tx_busy_synch;
    logic                        s_rx_busy_synch;
    logic                        s_erase_pending_synch;
    logic                        s_erase_done_synch;
    logic                        s_trim_cfg_done_synch;
    logic                        s_tx_done_synch;
    logic                        s_ref_line_pending_synch;
    logic                        s_ref_line_done_synch;

    // Signals from REG_IF to MRAM PD
    logic [31:0]                 s_mram_mode;
    logic [3:0]                  s_mram_event_synch;

    logic                        s_rstn_dcfifo_sync;

    logic                        s_clk_mram;

    assign  data_tx_datasize_o = 2'b10; // 32 bit transactions
    assign  data_rx_datasize_o = 2'b10; // 32 bit transactions

    assign  s_mram_event_synch =  {s_ref_line_done_synch, s_trim_cfg_done_synch, s_tx_done_synch, s_erase_done_synch};

    assign mram_mode_static_o = { s_mram_mode[7],s_mram_mode[6],s_mram_mode[5],s_mram_mode[1],s_mram_mode[0]};

    rstgen i_mram_dcfifo_rstgen
    (
        .clk_i       ( sys_clk_i          ),
        .test_mode_i ( dft_test_mode_i    ),
        .rst_ni      ( rstn_dcfifo_i      ),   
        .rst_no      ( s_rstn_dcfifo_sync ),  
        .init_no     ( )                
    );

    //////////////////////////////////////////////////////////////////////////
    //  ██████╗██╗      ██████╗  ██████╗██╗  ██╗ ██████╗ ███████╗███╗   ██╗ //
    // ██╔════╝██║     ██╔═══██╗██╔════╝██║ ██╔╝██╔════╝ ██╔════╝████╗  ██║ //
    // ██║     ██║     ██║   ██║██║     █████╔╝ ██║  ███╗█████╗  ██╔██╗ ██║ //
    // ██║     ██║     ██║   ██║██║     ██╔═██╗ ██║   ██║██╔══╝  ██║╚██╗██║ //
    // ╚██████╗███████╗╚██████╔╝╚██████╗██║  ██╗╚██████╔╝███████╗██║ ╚████║ //
    //  ╚═════╝╚══════╝ ╚═════╝  ╚═════╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚═╝  ╚═══╝ //
    //////////////////////////////////////////////////////////////////////////
    udma_clkgen u_clockgen
    (
        .clk_i           ( periph_clk_i    ),
        .rstn_i          ( rstn_i          ),

        .dft_test_mode_i ( dft_test_mode_i ),
        .dft_cg_enable_i ( dft_cg_enable_i ),

        .clock_enable_i  ( 1'b1            ),

        .clk_div_data_i  ( s_clkdiv_data   ),
        .clk_div_valid_i ( s_clkdiv_valid  ),
        .clk_div_ack_o   ( s_clkdiv_ack    ),

        .clk_o           ( s_clk_mram      )
    );

    pulp_clock_gating_async i_soc_cg
    (
        .clk_i     ( s_clk_mram      ),
        .rstn_i    ( rstn_i          ),
        .test_en_i ( dft_cg_enable_i ),
        .en_async_i( mram_clk_en_i   ),
        .en_ack_o  ( ),
        .clk_o     ( mram_clk_o      )
    );  

    //////////////////////////////////////////////////
    // ██████╗ ███████╗ ██████╗         ██╗███████╗ //
    // ██╔══██╗██╔════╝██╔════╝         ██║██╔════╝ //
    // ██████╔╝█████╗  ██║  ███╗        ██║█████╗   //
    // ██╔══██╗██╔══╝  ██║   ██║        ██║██╔══╝   //
    // ██║  ██║███████╗╚██████╔╝███████╗██║██║      //
    // ╚═╝  ╚═╝╚══════╝ ╚═════╝ ╚══════╝╚═╝╚═╝      //
    //////////////////////////////////////////////////
    udma_mram_reg_if
    #(
        .L2_AWIDTH_NOAL  ( L2_AWIDTH_NOAL  ),
        .TRANS_SIZE      ( TRANS_SIZE      ),
        .MRAM_ADDR_WIDTH ( MRAM_ADDR_WIDTH )
    )
    i_reg_if
    (
        .clk_i                   ( sys_clk_i                ),
        .rstn_i                  ( rstn_i                   ),

        .cfg_data_i              ( cfg_data_i               ),
        .cfg_addr_i              ( cfg_addr_i               ),
        .cfg_valid_i             ( cfg_valid_i              ),
        .cfg_rwn_i               ( cfg_rwn_i                ),
        .cfg_ready_o             ( cfg_ready_o              ),
        .cfg_data_o              ( cfg_data_o               ),

        .cfg_rx_startaddr_o      ( cfg_rx_startaddr_o       ),
        .cfg_rx_size_o           ( cfg_rx_size_o            ),
        .cfg_rx_dest_addr_o      ( s_cfg_rx_dest_addr       ),
        .cfg_rx_continuous_o     ( cfg_rx_continuous_o      ),
        .cfg_rx_en_o             ( cfg_rx_en_int            ),
        .cfg_rx_clr_o            ( cfg_rx_clr_o             ),
        .cfg_rx_en_i             ( cfg_rx_en_i              ),
        .cfg_rx_pending_i        ( cfg_rx_pending_i         ),
        .cfg_rx_curr_addr_i      ( cfg_rx_curr_addr_i       ),
        .cfg_rx_bytes_left_i     ( cfg_rx_bytes_left_i      ),
        .cfg_rx_busy_i           ( s_rx_busy_synch          ),

        .cfg_tx_startaddr_o      ( cfg_tx_startaddr_o       ),
        .cfg_tx_dest_addr_o      ( s_cfg_tx_dest_addr       ),
        .cfg_tx_size_o           ( cfg_tx_size_o            ),
        .cfg_tx_continuous_o     ( cfg_tx_continuous_o      ),
        .cfg_tx_en_o             ( cfg_tx_en_int            ),
        .cfg_tx_clr_o            ( cfg_tx_clr_o             ),
        .cfg_tx_en_i             ( cfg_tx_en_i              ),
        .cfg_tx_pending_i        ( cfg_tx_pending_i         ),
        .cfg_tx_curr_addr_i      ( cfg_tx_curr_addr_i       ),
        .cfg_tx_bytes_left_i     ( cfg_tx_bytes_left_i      ),
        .cfg_tx_busy_i           ( s_tx_busy_synch          ),

        .mram_mode_o             ( s_mram_mode              ),
        .mram_erase_addr_o       ( mram_erase_addr_o        ), //no synch here, datapath signals
        .mram_erase_size_o       ( mram_erase_size_o        ), //no synch here, datapath signals

        .mram_erase_pending_i    ( s_erase_pending_synch    ),
        .mram_ref_line_pending_i ( s_ref_line_pending_synch ),

        .mram_event_done_i       ( s_mram_event_synch       ),
        .mram_rx_ecc_error_i     ( rx_error_i               ),

        .cfg_clkdiv_data_o       ( s_clkdiv_data            ),
        .cfg_clkdiv_valid_o      ( s_clkdiv_valid           ),
        .cfg_clkdiv_ack_i        ( s_clkdiv_ack             ),

        .mram_push_tx_req_o      ( mram_push_tx_req         ),
        .mram_push_tx_ack_i      ( 1'b1                     ),

        .mram_irq_enable_o       ( mram_irq_enable          ),
        .mram_push_rx_req_o      (                          ),
        .mram_push_rx_ack_i      (                          )
    );





    ////////////////////////////////////////////////////////////////////////////
    // ██╗ ██████╗      ████████╗██╗  ██╗        ███████╗██╗███████╗ ██████╗  //
    // ██║██╔═══██╗     ╚══██╔══╝╚██╗██╔╝        ██╔════╝██║██╔════╝██╔═══██╗ //
    // ██║██║   ██║        ██║    ╚███╔╝         █████╗  ██║█████╗  ██║   ██║ //
    // ██║██║   ██║        ██║    ██╔██╗         ██╔══╝  ██║██╔══╝  ██║   ██║ //
    // ██║╚██████╔╝███████╗██║   ██╔╝ ██╗███████╗██║     ██║██║     ╚██████╔╝ //
    // ╚═╝ ╚═════╝ ╚══════╝╚═╝   ╚═╝  ╚═╝╚══════╝╚═╝     ╚═╝╚═╝      ╚═════╝  //
    ////////////////////////////////////////////////////////////////////////////
    io_tx_fifo
    #(
      .DATA_WIDTH   ( TX_DATA_WIDTH ),
      .BUFFER_DEPTH ( 4             )
    )
    u_io_tx_fifo
    (
        .clk_i   ( sys_clk_i        ),
        .rstn_i  ( rstn_i           ),
        .clr_i   ( 1'b0             ),

        .req_o   ( data_tx_req_o    ),
        .gnt_i   ( data_tx_gnt_i    ),

        .data_o  ( s_data_tx        ),
        .valid_o ( s_data_tx_valid  ),
        .ready_i ( s_data_tx_ready  ),

        .valid_i ( data_tx_valid_i  ),
        .data_i  ( data_tx_i        ),
        .ready_o ( data_tx_ready_o  )
    );


    ///////////////////////////////////////////////////////////////////////////////////////////
    // ████████╗██╗  ██╗        ██████╗  ██████╗        ███████╗██╗███████╗ ██████╗ ███████╗ //
    // ╚══██╔══╝╚██╗██╔╝        ██╔══██╗██╔════╝        ██╔════╝██║██╔════╝██╔═══██╗██╔════╝ //
    //    ██║    ╚███╔╝         ██║  ██║██║             █████╗  ██║█████╗  ██║   ██║███████╗ //
    //    ██║    ██╔██╗         ██║  ██║██║             ██╔══╝  ██║██╔══╝  ██║   ██║╚════██║ //
    //    ██║   ██╔╝ ██╗███████╗██████╔╝╚██████╗███████╗██║     ██║██║     ╚██████╔╝███████║ //
    //    ╚═╝   ╚═╝  ╚═╝╚══════╝╚═════╝  ╚═════╝╚══════╝╚═╝     ╚═╝╚═╝      ╚═════╝ ╚══════╝ //
    ///////////////////////////////////////////////////////////////////////////////////////////

    assign s_cmd_tx_data   =  {s_mram_mode[15:8], s_mram_mode[4:2], cfg_tx_size_o, s_cfg_tx_dest_addr};
    assign s_cmd_tx_valid  =  (cfg_tx_en_int & cfg_tx_en_i)  | mram_push_tx_req;
    assign cfg_tx_en_o     =  cfg_tx_en_int & s_cmd_tx_ready;
    dc_token_ring_fifo_din
    #(
        .DATA_WIDTH   ( TX_CMD_WIDTH     ),
        .BUFFER_DEPTH ( TX_DC_FIFO_DEPTH )
    )
    u_push_cmd_tx_din 
    (
        .clk          ( sys_clk_i               ),
        .rstn         ( s_rstn_dcfifo_sync      ),
        .data         ( s_cmd_tx_data           ),
        .valid        ( s_cmd_tx_valid          ),
        .ready        ( s_cmd_tx_ready          ),

        .write_token  ( cmd_tx_write_token_o    ),
        .read_pointer ( cmd_tx_read_pointer_i   ),
        .data_async   ( cmd_tx_asynch_o         )
    );
    

    dc_token_ring_fifo_din
    #(
        .DATA_WIDTH   ( TX_DATA_WIDTH     ),
        .BUFFER_DEPTH ( TX_DC_FIFO_DEPTH  )
    )
    u_dc_fifo_tx_din 
    (
        .clk          ( sys_clk_i                ),
        .rstn         ( s_rstn_dcfifo_sync       ),
        .data         ( s_data_tx                ),
        .valid        ( s_data_tx_valid          ),
        .ready        ( s_data_tx_ready          ),

        .write_token  ( data_tx_write_token_o    ),
        .read_pointer ( data_tx_read_pointer_i   ),
        .data_async   ( data_tx_asynch_o         )
    );




    ////////////////////////////////////////////////////////////////////////////////////////////////////
    // ██████╗ ██╗  ██╗        ███████╗███████╗██████╗ ██╗ █████╗ ██╗     ██╗███████╗███████╗██████╗  //
    // ██╔══██╗╚██╗██╔╝        ██╔════╝██╔════╝██╔══██╗██║██╔══██╗██║     ██║╚══███╔╝██╔════╝██╔══██╗ //
    // ██████╔╝ ╚███╔╝         ███████╗█████╗  ██████╔╝██║███████║██║     ██║  ███╔╝ █████╗  ██████╔╝ //
    // ██╔══██╗ ██╔██╗         ╚════██║██╔══╝  ██╔══██╗██║██╔══██║██║     ██║ ███╔╝  ██╔══╝  ██╔══██╗ //
    // ██║  ██║██╔╝ ██╗███████╗███████║███████╗██║  ██║██║██║  ██║███████╗██║███████╗███████╗██║  ██║ //
    // ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝╚═╝  ╚═╝╚═╝╚═╝  ╚═╝╚══════╝╚═╝╚══════╝╚══════╝╚═╝  ╚═╝ //
    ////////////////////////////////////////////////////////////////////////////////////////////////////
    RX_serializer u_RX_serializer
    (
       .sys_clk         ( sys_clk_i                ),
       .rst_n           ( rstn_i                   ),

       // signal from DC_FIFO
       .data_rx_rdata_i ( s_data_rx_to_ser         ),
       .data_rx_valid_i ( s_data_rx_valid_to_ser   ),
       .data_rx_ready_o ( s_data_rx_ready_from_ser ),

       //Signal To L2
       .data_rx_rdata_o ( data_rx_o                ),
       .data_rx_valid_o ( data_rx_valid_o          ),
       .data_rx_ready_i ( data_rx_ready_i          )
    );

    //////////////////////////////////////////////////////////////////////////////////////////
    // ██████╗ ██╗  ██╗        ██████╗  ██████╗        ███████╗██╗███████╗ ██████╗ ███████╗ //
    // ██╔══██╗╚██╗██╔╝        ██╔══██╗██╔════╝        ██╔════╝██║██╔════╝██╔═══██╗██╔════╝ //
    // ██████╔╝ ╚███╔╝         ██║  ██║██║             █████╗  ██║█████╗  ██║   ██║███████╗ //
    // ██╔══██╗ ██╔██╗         ██║  ██║██║             ██╔══╝  ██║██╔══╝  ██║   ██║╚════██║ //
    // ██║  ██║██╔╝ ██╗███████╗██████╔╝╚██████╗███████╗██║     ██║██║     ╚██████╔╝███████║ //
    // ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═════╝  ╚═════╝╚══════╝╚═╝     ╚═╝╚═╝      ╚═════╝ ╚══════╝ //

    dc_token_ring_fifo_dout
    #(
       .DATA_WIDTH    ( RX_DATA_WIDTH              ),
       .BUFFER_DEPTH  ( RX_DC_FIFO_DEPTH           )
    )
    u_dc_fifo_rx_dout
    (
        .clk          ( sys_clk_i                  ),
        .rstn         ( s_rstn_dcfifo_sync         ),
        // Synch Side
        .data         ( s_data_rx_to_ser           ),
        .valid        ( s_data_rx_valid_to_ser     ),
        .ready        ( s_data_rx_ready_from_ser   ),

        //Asynch Side
        .write_token  ( data_rx_write_token_i      ),
        .read_pointer ( data_rx_read_pointer_o     ),
        .data_async   ( data_rx_asynch_i           )
    );




    assign s_cmd_rx_data   =  {s_mram_mode[15:8], s_mram_mode[4:2], cfg_rx_size_o, s_cfg_rx_dest_addr};
    assign s_cmd_rx_valid  =  cfg_rx_en_int & cfg_rx_en_i;
    assign cfg_rx_en_o     =  cfg_rx_en_int & s_cmd_rx_ready;

    dc_token_ring_fifo_din
    #(
        .DATA_WIDTH   ( RX_CMD_WIDTH       ),
        .BUFFER_DEPTH ( RX_DC_FIFO_DEPTH   )
    )
    u_push_cmd_rx_din 
    (
        .clk          ( sys_clk_i               ),
        .rstn         ( s_rstn_dcfifo_sync      ),
        .data         ( s_cmd_rx_data           ),
        .valid        ( s_cmd_rx_valid          ),
        .ready        ( s_cmd_rx_ready          ),

        .write_token  ( cmd_rx_write_token_o    ),
        .read_pointer ( cmd_rx_read_pointer_i   ),
        .data_async   ( cmd_rx_asynch_o         )
    );







    ////////////////////////////////////////////////////////////////////
    // ██████╗ ███████╗   ███████╗██╗   ██╗███╗   ██╗ ██████╗██╗  ██╗ //
    // ██╔══██╗██╔════╝   ██╔════╝╚██╗ ██╔╝████╗  ██║██╔════╝██║  ██║ //
    // ██████╔╝█████╗     ███████╗ ╚████╔╝ ██╔██╗ ██║██║     ███████║ //
    // ██╔══██╗██╔══╝     ╚════██║  ╚██╔╝  ██║╚██╗██║██║     ██╔══██║ //
    // ██████╔╝██║███████╗███████║   ██║   ██║ ╚████║╚██████╗██║  ██║ //
    // ╚═════╝ ╚═╝╚══════╝╚══════╝   ╚═╝   ╚═╝  ╚═══╝ ╚═════╝╚═╝  ╚═╝ //
    ////////////////////////////////////////////////////////////////////

    pulp_sync u_pulp_sync_ref_line_done
    (
        .clk_i    ( sys_clk_i               ),
        .rstn_i   ( rstn_i                  ),
        .serial_i ( ref_line_done_i         ),
        .serial_o ( s_ref_line_done_synch   )
    );

    pulp_sync u_pulp_sync_ref_line_pending
    (
        .clk_i    ( sys_clk_i                ),
        .rstn_i   ( rstn_i                   ),
        .serial_i ( ref_line_pending_i       ),
        .serial_o ( s_ref_line_pending_synch )
    );


    pulp_sync u_pulp_sync_erase_done
    (
        .clk_i    ( sys_clk_i              ),
        .rstn_i   ( rstn_i                 ),
        .serial_i ( erase_done_i           ),
        .serial_o ( s_erase_done_synch     )
    );

    pulp_sync u_pulp_sync_erase_pending
    (
        .clk_i    ( sys_clk_i                ),
        .rstn_i   ( rstn_i                   ),
        .serial_i ( erase_pending_i          ),
        .serial_o ( s_erase_pending_synch    )
    );

    pulp_sync u_pulp_sync_trim_cfg_done
    (
        .clk_i    ( sys_clk_i                ),
        .rstn_i   ( rstn_i                   ),
        .serial_i ( trim_cfg_done_i          ),
        .serial_o ( s_trim_cfg_done_synch    )
    );


    pulp_sync u_pulp_sync_tx_done
    (
        .clk_i    ( sys_clk_i                ),
        .rstn_i   ( rstn_i                   ),
        .serial_i ( tx_done_i                ),
        .serial_o ( s_tx_done_synch          )
    );


    pulp_sync u_pulp_sync_tx_busy
    (
        .clk_i    ( sys_clk_i                ),
        .rstn_i   ( rstn_i                   ),
        .serial_i ( tx_busy_i                ),
        .serial_o ( s_tx_busy_synch          )
    );

    pulp_sync u_pulp_sync_rx_busy
    (
        .clk_i    ( sys_clk_i                ),
        .rstn_i   ( rstn_i                   ),
        .serial_i ( rx_busy_i                ),
        .serial_o ( s_rx_busy_synch          )
    );


    ////////////////////////////////////////////////////////////////////////////////////////////
    // ███████╗██╗   ██╗███╗   ██╗ ██████╗        ██╗    ██╗███████╗██████╗  ██████╗ ███████╗ //
    // ██╔════╝╚██╗ ██╔╝████╗  ██║██╔════╝        ██║    ██║██╔════╝██╔══██╗██╔════╝ ██╔════╝ //
    // ███████╗ ╚████╔╝ ██╔██╗ ██║██║             ██║ █╗ ██║█████╗  ██║  ██║██║  ███╗█████╗   //
    // ╚════██║  ╚██╔╝  ██║╚██╗██║██║             ██║███╗██║██╔══╝  ██║  ██║██║   ██║██╔══╝   //
    // ███████║   ██║   ██║ ╚████║╚██████╗███████╗╚███╔███╔╝███████╗██████╔╝╚██████╔╝███████╗ //
    // ╚══════╝   ╚═╝   ╚═╝  ╚═══╝ ╚═════╝╚══════╝ ╚══╝╚══╝ ╚══════╝╚═════╝  ╚═════╝ ╚══════╝ //
    ////////////////////////////////////////////////////////////////////////////////////////////
    pulp_sync_wedge erase_done_int_sync
    (
        .clk_i    ( sys_clk_i                               ),
        .rstn_i   ( rstn_i                                  ),
        .en_i     ( 1'b1                                    ),
        .serial_i ( s_erase_done_synch & mram_irq_enable[0] ),
        .r_edge_o ( erase_done_event_o                      ),
        .f_edge_o (                                         ),
        .serial_o (                                         )
    );


    pulp_sync_wedge tx_done_int_sync
    (
        .clk_i    ( sys_clk_i                             ),
        .rstn_i   ( rstn_i                                ),
        .en_i     ( 1'b1                                  ),
        .serial_i ( s_tx_done_synch & mram_irq_enable[1]  ),
        .r_edge_o ( tx_done_event_o                       ),
        .f_edge_o (                                       ),
        .serial_o (                                       )
    );

    pulp_sync_wedge trm_cfg_done_int_sync
    (
        .clk_i    ( sys_clk_i                                  ),
        .rstn_i   ( rstn_i                                     ),
        .en_i     ( 1'b1                                       ),
        .serial_i ( s_trim_cfg_done_synch & mram_irq_enable[2] ),
        .r_edge_o ( trim_cfg_done_event_o                      ),
        .f_edge_o (                                            ),
        .serial_o (                                            )
    );

    pulp_sync_wedge ref_line_done_int_sync
    (
        .clk_i    ( sys_clk_i                                  ),
        .rstn_i   ( rstn_i                                     ),
        .en_i     ( 1'b1                                       ),
        .serial_i ( s_ref_line_done_synch & mram_irq_enable[3] ),
        .r_edge_o ( ref_line_done_event_o                      ),
        .f_edge_o (                                            ),
        .serial_o (                                            )
    );

endmodule // udma_mram_top
