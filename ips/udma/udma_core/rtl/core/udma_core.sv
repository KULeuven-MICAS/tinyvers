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
// Description: Top level of udma core block
//
///////////////////////////////////////////////////////////////////////////////
//
// Authors    : Antonio Pullini (pullinia@iis.ee.ethz.ch)
//
///////////////////////////////////////////////////////////////////////////////


module udma_core
  #(
    parameter L2_DATA_WIDTH     = 64,
    parameter L2_AWIDTH_NOAL    = 16,
    parameter DATA_WIDTH        = 32,
    parameter APB_ADDR_WIDTH    = 12,  //APB slaves are 4KB by default
    parameter N_RX_LIN_CHANNELS = 8,
    parameter N_RX_EXT_CHANNELS = 8,
    parameter N_TX_LIN_CHANNELS = 8,
    parameter N_TX_EXT_CHANNELS = 8,
    parameter N_PERIPHS         = 8,
    parameter N_STREAMS         = 4,
    parameter DEST_SIZE         = 2,
    parameter STREAM_ID_WIDTH   = 3,
    parameter TRANS_SIZE        = 16
    )
   (
    input  logic                        sys_clk_i,
    input  logic                        per_clk_i,

    input  logic                        dft_cg_enable_i,

    input  logic                        HRESETn,
    input  logic   [APB_ADDR_WIDTH-1:0] PADDR,
    input  logic                 [31:0] PWDATA,
    input  logic                        PWRITE,
    input  logic                        PSEL,
    input  logic                        PENABLE,
    output logic                 [31:0] PRDATA,
    output logic                        PREADY,
    output logic                        PSLVERR,

    input  logic                        event_valid_i,
    input  logic                  [7:0] event_data_i,
    output logic                        event_ready_o,
    output logic                  [3:0] event_o,

    output logic        [N_PERIPHS-1:0] periph_per_clk_o,
    output logic        [N_PERIPHS-1:0] periph_sys_clk_o,

    output logic                 [31:0] periph_data_to_o,
    output logic                  [4:0] periph_addr_o,
    output logic                        periph_rwn_o,
    input  logic [N_PERIPHS-1:0] [31:0] periph_data_from_i,
    output logic [N_PERIPHS-1:0]        periph_valid_o,
    input  logic [N_PERIPHS-1:0]        periph_ready_i,

    output logic                        rx_l2_req_o,
    input  logic                        rx_l2_gnt_i,
    output logic                 [31:0] rx_l2_addr_o,
    output logic  [L2_DATA_WIDTH/8-1:0] rx_l2_be_o,
    output logic    [L2_DATA_WIDTH-1:0] rx_l2_wdata_o,

    output logic                        tx_l2_req_o,
    input  logic                        tx_l2_gnt_i,
    output logic                 [31:0] tx_l2_addr_o,
    input  logic    [L2_DATA_WIDTH-1:0] tx_l2_rdata_i,
    input  logic                        tx_l2_rvalid_i,

    output logic [N_STREAMS-1:0]          [DATA_WIDTH-1 : 0] stream_data_o,
    output logic [N_STREAMS-1:0]                     [1 : 0] stream_datasize_o,
    output logic [N_STREAMS-1:0]                             stream_valid_o,
    output logic [N_STREAMS-1:0]                             stream_sot_o,
    output logic [N_STREAMS-1:0]                             stream_eot_o,
    input  logic [N_STREAMS-1:0]                             stream_ready_i,

    input  logic [N_RX_LIN_CHANNELS-1:0]                         rx_lin_valid_i,
    input  logic [N_RX_LIN_CHANNELS-1:0]      [DATA_WIDTH-1 : 0] rx_lin_data_i,
    input  logic [N_RX_LIN_CHANNELS-1:0]                 [1 : 0] rx_lin_datasize_i,
    input  logic [N_RX_LIN_CHANNELS-1:0]       [DEST_SIZE-1 : 0] rx_lin_destination_i,      
    output logic [N_RX_LIN_CHANNELS-1:0]                         rx_lin_ready_o,
    output logic [N_RX_LIN_CHANNELS-1:0]                         rx_lin_events_o,
    output logic [N_RX_LIN_CHANNELS-1:0]                         rx_lin_en_o,
    output logic [N_RX_LIN_CHANNELS-1:0]                         rx_lin_pending_o,
    output logic [N_RX_LIN_CHANNELS-1:0]  [L2_AWIDTH_NOAL-1 : 0] rx_lin_curr_addr_o,
    output logic [N_RX_LIN_CHANNELS-1:0]      [TRANS_SIZE-1 : 0] rx_lin_bytes_left_o,
    input  logic [N_RX_LIN_CHANNELS-1:0]  [L2_AWIDTH_NOAL-1 : 0] rx_lin_cfg_startaddr_i,
    input  logic [N_RX_LIN_CHANNELS-1:0]      [TRANS_SIZE-1 : 0] rx_lin_cfg_size_i,
    input  logic [N_RX_LIN_CHANNELS-1:0]                         rx_lin_cfg_continuous_i,
    input  logic [N_RX_LIN_CHANNELS-1:0]                         rx_lin_cfg_en_i,
    input  logic [N_RX_LIN_CHANNELS-1:0]                 [1 : 0] rx_lin_cfg_stream_i,
    input  logic [N_RX_LIN_CHANNELS-1:0] [STREAM_ID_WIDTH-1 : 0] rx_lin_cfg_stream_id_i,
    input  logic [N_RX_LIN_CHANNELS-1:0]                         rx_lin_cfg_clr_i,

    input  logic [N_RX_EXT_CHANNELS-1:0]  [L2_AWIDTH_NOAL-1 : 0] rx_ext_addr_i,
    input  logic [N_RX_EXT_CHANNELS-1:0]                 [1 : 0] rx_ext_datasize_i,
    input  logic [N_RX_EXT_CHANNELS-1:0]       [DEST_SIZE-1 : 0] rx_ext_destination_i,
    input  logic [N_RX_EXT_CHANNELS-1:0]                 [1 : 0] rx_ext_stream_i,
    input  logic [N_RX_EXT_CHANNELS-1:0] [STREAM_ID_WIDTH-1 : 0] rx_ext_stream_id_i,
    input  logic [N_RX_EXT_CHANNELS-1:0]                         rx_ext_sot_i,
    input  logic [N_RX_EXT_CHANNELS-1:0]                         rx_ext_eot_i,
    input  logic [N_RX_EXT_CHANNELS-1:0]                         rx_ext_valid_i,
    input  logic [N_RX_EXT_CHANNELS-1:0]      [DATA_WIDTH-1 : 0] rx_ext_data_i,
    output logic [N_RX_EXT_CHANNELS-1:0]                         rx_ext_ready_o,

    input  logic [N_TX_LIN_CHANNELS-1:0]                        tx_lin_req_i,
    output logic [N_TX_LIN_CHANNELS-1:0]                        tx_lin_gnt_o,
    output logic [N_TX_LIN_CHANNELS-1:0]                        tx_lin_valid_o,
    output logic [N_TX_LIN_CHANNELS-1:0]     [DATA_WIDTH-1 : 0] tx_lin_data_o,
    input  logic [N_TX_LIN_CHANNELS-1:0]                        tx_lin_ready_i,
    input  logic [N_TX_LIN_CHANNELS-1:0]                [1 : 0] tx_lin_datasize_i,
    input  logic [N_TX_LIN_CHANNELS-1:0]                [1 : 0] tx_lin_destination_i,
    output logic [N_TX_LIN_CHANNELS-1:0]                        tx_lin_events_o,
    output logic [N_TX_LIN_CHANNELS-1:0]                        tx_lin_en_o,
    output logic [N_TX_LIN_CHANNELS-1:0]                        tx_lin_pending_o,
    output logic [N_TX_LIN_CHANNELS-1:0] [L2_AWIDTH_NOAL-1 : 0] tx_lin_curr_addr_o,
    output logic [N_TX_LIN_CHANNELS-1:0]     [TRANS_SIZE-1 : 0] tx_lin_bytes_left_o,
    input  logic [N_TX_LIN_CHANNELS-1:0] [L2_AWIDTH_NOAL-1 : 0] tx_lin_cfg_startaddr_i,
    input  logic [N_TX_LIN_CHANNELS-1:0]     [TRANS_SIZE-1 : 0] tx_lin_cfg_size_i,
    input  logic [N_TX_LIN_CHANNELS-1:0]                        tx_lin_cfg_continuous_i,
    input  logic [N_TX_LIN_CHANNELS-1:0]                        tx_lin_cfg_en_i,
    input  logic [N_TX_LIN_CHANNELS-1:0]                        tx_lin_cfg_clr_i,
    
    input  logic [N_TX_EXT_CHANNELS-1:0]                        tx_ext_req_i,
    input  logic [N_TX_EXT_CHANNELS-1:0]                [1 : 0] tx_ext_datasize_i,
    input  logic [N_TX_EXT_CHANNELS-1:0]                [1 : 0] tx_ext_destination_i,
    input  logic [N_TX_EXT_CHANNELS-1:0] [L2_AWIDTH_NOAL-1 : 0] tx_ext_addr_i,
    output logic [N_TX_EXT_CHANNELS-1:0]                        tx_ext_gnt_o,
    output logic [N_TX_EXT_CHANNELS-1:0]                        tx_ext_valid_o,
    output logic [N_TX_EXT_CHANNELS-1:0]     [DATA_WIDTH-1 : 0] tx_ext_data_o,
    input  logic [N_TX_EXT_CHANNELS-1:0]                        tx_ext_ready_i
    
    );

    localparam N_REAL_TX_EXT_CHANNELS = N_TX_EXT_CHANNELS + N_STREAMS;
    localparam N_REAL_PERIPHS         = N_PERIPHS + 1;

    logic [N_STREAMS-1:0]                             s_tx_ch_req;
    logic [N_STREAMS-1:0]      [L2_AWIDTH_NOAL-1 : 0] s_tx_ch_addr;
    logic [N_STREAMS-1:0]                     [1 : 0] s_tx_ch_datasize;
    logic [N_STREAMS-1:0]                             s_tx_ch_gnt;
    logic [N_STREAMS-1:0]                             s_tx_ch_valid;
    logic [N_STREAMS-1:0]          [DATA_WIDTH-1 : 0] s_tx_ch_data;
    logic [N_STREAMS-1:0]                             s_tx_ch_ready;

    logic [N_STREAMS-1:0]                             s_cfg_en;
    logic [N_STREAMS-1:0]      [L2_AWIDTH_NOAL-1 : 0] s_cfg_addr;
    logic [N_STREAMS-1:0]          [TRANS_SIZE-1 : 0] s_cfg_buffsize;
    logic [N_STREAMS-1:0]                     [1 : 0] s_cfg_datasize;

    logic [N_REAL_TX_EXT_CHANNELS-1:0]                        s_tx_ext_req;
    logic [N_REAL_TX_EXT_CHANNELS-1:0]                [1 : 0] s_tx_ext_datasize;
    logic [N_REAL_TX_EXT_CHANNELS-1:0]                [1 : 0] s_tx_ext_dest;
    logic [N_REAL_TX_EXT_CHANNELS-1:0] [L2_AWIDTH_NOAL-1 : 0] s_tx_ext_addr;
    logic [N_REAL_TX_EXT_CHANNELS-1:0]                        s_tx_ext_gnt;
    logic [N_REAL_TX_EXT_CHANNELS-1:0]                        s_tx_ext_valid;
    logic [N_REAL_TX_EXT_CHANNELS-1:0]     [DATA_WIDTH-1 : 0] s_tx_ext_data;
    logic [N_REAL_TX_EXT_CHANNELS-1:0]                        s_tx_ext_ready;
    logic [N_REAL_TX_EXT_CHANNELS-1:0]                        s_tx_ext_events;

    logic                      [31:0] s_periph_data_to;
    logic                       [4:0] s_periph_addr;
    logic                             s_periph_rwn;
    logic [N_REAL_PERIPHS-1:0] [31:0] s_periph_data_from;
    logic [N_REAL_PERIPHS-1:0]        s_periph_valid;
    logic [N_REAL_PERIPHS-1:0]        s_periph_ready;

    logic                 s_periph_ready_from_cgunit;
    logic          [31:0] s_periph_data_from_cgunit;
    logic [N_PERIPHS-1:0] s_cg_value;

    logic               s_clk_core;
    logic               s_clk_core_en;

    assign periph_data_to_o = s_periph_data_to;
    assign periph_addr_o    = s_periph_addr;
    assign periph_rwn_o     = s_periph_rwn;
    assign periph_valid_o   = s_periph_valid[N_REAL_PERIPHS-1:1];
    assign s_periph_ready[0]                      = s_periph_ready_from_cgunit;
    assign s_periph_data_from[0]                  = s_periph_data_from_cgunit;
    assign s_periph_ready[N_REAL_PERIPHS-1:1]     = periph_ready_i;
    assign s_periph_data_from[N_REAL_PERIPHS-1:1] = periph_data_from_i;
   

    always_comb
    begin
      for(int i=0;i<N_TX_EXT_CHANNELS;i++)
      begin
        s_tx_ext_req[i]      = tx_ext_req_i[i];
        s_tx_ext_datasize[i] = tx_ext_datasize_i[i];
        s_tx_ext_dest[i]     = tx_ext_destination_i[i];
        s_tx_ext_addr[i]     = tx_ext_addr_i[i];
        tx_ext_gnt_o[i]      = s_tx_ext_gnt[i];
        tx_ext_valid_o[i]    = s_tx_ext_valid[i];
        tx_ext_data_o[i]     = s_tx_ext_data[i];
        s_tx_ext_ready[i]    = tx_ext_ready_i[i];
      end
      for(int i=0;i<N_STREAMS;i++)
      begin
        s_tx_ext_req[N_TX_EXT_CHANNELS+i]      = s_tx_ch_req[i];
        s_tx_ext_datasize[N_TX_EXT_CHANNELS+i] = s_tx_ch_datasize[i];
        s_tx_ext_dest[N_TX_EXT_CHANNELS+i]     = 2'b00;
        s_tx_ext_addr[N_TX_EXT_CHANNELS+i]     = s_tx_ch_addr[i];
        s_tx_ch_gnt[i]                         = s_tx_ext_gnt[N_TX_EXT_CHANNELS+i];
        s_tx_ch_valid[i]                       = s_tx_ext_valid[N_TX_EXT_CHANNELS+i];
        s_tx_ch_data[i]                        = s_tx_ext_data[N_TX_EXT_CHANNELS+i];
        s_tx_ext_ready[N_TX_EXT_CHANNELS+i]    = s_tx_ch_ready[i];
      end
    end

  udma_tx_channels
  #(
      .L2_DATA_WIDTH(L2_DATA_WIDTH),
      .L2_AWIDTH_NOAL(L2_AWIDTH_NOAL),
      .DATA_WIDTH(32),
      .N_LIN_CHANNELS(N_TX_LIN_CHANNELS),
      .N_EXT_CHANNELS(N_REAL_TX_EXT_CHANNELS),
      .TRANS_SIZE(TRANS_SIZE)
    ) u_tx_channels (
      .clk_i                ( s_clk_core          ),
      .rstn_i               ( HRESETn             ),
    
      .l2_req_o             ( tx_l2_req_o         ),
      .l2_gnt_i             ( tx_l2_gnt_i         ),
      .l2_addr_o            ( tx_l2_addr_o        ),
      .l2_rdata_i           ( tx_l2_rdata_i       ),
      .l2_rvalid_i          ( tx_l2_rvalid_i      ),
      
      .lin_req_i            ( tx_lin_req_i            ),
      .lin_gnt_o            ( tx_lin_gnt_o            ),
      .lin_valid_o          ( tx_lin_valid_o          ),
      .lin_data_o           ( tx_lin_data_o           ),
      .lin_ready_i          ( tx_lin_ready_i          ),
      .lin_datasize_i       ( tx_lin_datasize_i       ),
      .lin_destination_i    ( tx_lin_destination_i    ),
      .lin_events_o         ( tx_lin_events_o         ),
      .lin_en_o             ( tx_lin_en_o             ),
      .lin_pending_o        ( tx_lin_pending_o        ),
      .lin_curr_addr_o      ( tx_lin_curr_addr_o      ),
      .lin_bytes_left_o     ( tx_lin_bytes_left_o     ),
      .lin_cfg_startaddr_i  ( tx_lin_cfg_startaddr_i  ),
      .lin_cfg_size_i       ( tx_lin_cfg_size_i       ),
      .lin_cfg_continuous_i ( tx_lin_cfg_continuous_i ),
      .lin_cfg_en_i         ( tx_lin_cfg_en_i         ),
      .lin_cfg_clr_i        ( tx_lin_cfg_clr_i        ),
    
      .ext_req_i            ( s_tx_ext_req            ),
      .ext_datasize_i       ( s_tx_ext_datasize       ),
      .ext_destination_i    ( s_tx_ext_dest           ),
      .ext_addr_i           ( s_tx_ext_addr           ),
      .ext_gnt_o            ( s_tx_ext_gnt            ),
      .ext_valid_o          ( s_tx_ext_valid          ),
      .ext_data_o           ( s_tx_ext_data           ),
      .ext_ready_i          ( s_tx_ext_ready          )
    );

  udma_rx_channels
  #(
      .L2_DATA_WIDTH(L2_DATA_WIDTH),
      .L2_AWIDTH_NOAL(L2_AWIDTH_NOAL),
      .DATA_WIDTH(32),
      .N_STREAMS(N_STREAMS),
      .N_LIN_CHANNELS(N_RX_LIN_CHANNELS),
      .N_EXT_CHANNELS(N_RX_EXT_CHANNELS),
      .STREAM_ID_WIDTH(STREAM_ID_WIDTH),
      .TRANS_SIZE(TRANS_SIZE)
    ) u_rx_channels (
      .clk_i               ( s_clk_core              ),
      .rstn_i              ( HRESETn                 ),
    
      .l2_req_o            ( rx_l2_req_o             ),
      .l2_addr_o           ( rx_l2_addr_o            ),
      .l2_be_o             ( rx_l2_be_o              ),
      .l2_wdata_o          ( rx_l2_wdata_o           ),
      .l2_gnt_i            ( rx_l2_gnt_i             ), 

      .stream_data_o       ( stream_data_o           ),
      .stream_datasize_o   ( stream_datasize_o       ),
      .stream_valid_o      ( stream_valid_o          ),
      .stream_sot_o        ( stream_sot_o            ),
      .stream_eot_o        ( stream_eot_o            ),
      .stream_ready_i      ( stream_ready_i          ),

      .tx_ch_req_o         ( s_tx_ch_req             ),
      .tx_ch_addr_o        ( s_tx_ch_addr            ),
      .tx_ch_datasize_o    ( s_tx_ch_datasize        ),
      .tx_ch_gnt_i         ( s_tx_ch_gnt             ),
      .tx_ch_valid_i       ( s_tx_ch_valid           ),
      .tx_ch_data_i        ( s_tx_ch_data            ),
      .tx_ch_ready_o       ( s_tx_ch_ready           ),

      .lin_ch_valid_i          ( rx_lin_valid_i          ),
      .lin_ch_data_i           ( rx_lin_data_i           ),
      .lin_ch_ready_o          ( rx_lin_ready_o          ),
      .lin_ch_datasize_i       ( rx_lin_datasize_i       ),
      .lin_ch_destination_i    ( rx_lin_destination_i    ),
      .lin_ch_events_o         ( rx_lin_events_o         ),
      .lin_ch_en_o             ( rx_lin_en_o             ),
      .lin_ch_pending_o        ( rx_lin_pending_o        ),
      .lin_ch_curr_addr_o      ( rx_lin_curr_addr_o      ),
      .lin_ch_bytes_left_o     ( rx_lin_bytes_left_o     ),
      .lin_ch_cfg_startaddr_i  ( rx_lin_cfg_startaddr_i  ),
      .lin_ch_cfg_size_i       ( rx_lin_cfg_size_i       ),
      .lin_ch_cfg_continuous_i ( rx_lin_cfg_continuous_i ),
      .lin_ch_cfg_en_i         ( rx_lin_cfg_en_i         ),
      .lin_ch_cfg_stream_i     ( rx_lin_cfg_stream_i     ),
      .lin_ch_cfg_stream_id_i  ( rx_lin_cfg_stream_id_i  ),
      .lin_ch_cfg_clr_i        ( rx_lin_cfg_clr_i        ),
      
      .ext_ch_addr_i           ( rx_ext_addr_i           ),
      .ext_ch_datasize_i       ( rx_ext_datasize_i       ),
      .ext_ch_destination_i    ( rx_ext_destination_i    ),
      .ext_ch_stream_i         ( rx_ext_stream_i         ),
      .ext_ch_stream_id_i      ( rx_ext_stream_id_i      ),
      .ext_ch_sot_i            ( rx_ext_sot_i            ),
      .ext_ch_eot_i            ( rx_ext_eot_i            ),
      .ext_ch_valid_i          ( rx_ext_valid_i          ),
      .ext_ch_data_i           ( rx_ext_data_i           ),
      .ext_ch_ready_o          ( rx_ext_ready_o          )

    );

    udma_apb_if #(
        .APB_ADDR_WIDTH(APB_ADDR_WIDTH),
        .N_PERIPHS(N_REAL_PERIPHS)
    ) u_apb_if (
        .PADDR(PADDR),
        .PWDATA(PWDATA),
        .PWRITE(PWRITE),
        .PSEL(PSEL),
        .PENABLE(PENABLE),
        .PRDATA(PRDATA),
        .PREADY(PREADY),
        .PSLVERR(PSLVERR),

        .periph_data_o(s_periph_data_to),
        .periph_addr_o(s_periph_addr),
        .periph_data_i(s_periph_data_from),
        .periph_ready_i(s_periph_ready),
        .periph_valid_o(s_periph_valid),
        .periph_rwn_o(s_periph_rwn)
    );

    udma_ctrl #(
      .L2_AWIDTH_NOAL(L2_AWIDTH_NOAL),
      .TRANS_SIZE    (TRANS_SIZE    ),
      .N_PERIPHS     (N_PERIPHS     )
    )  u_udma_ctrl (
        .clk_i(sys_clk_i),
        .rstn_i(HRESETn),

        .cfg_data_i(s_periph_data_to),
        .cfg_addr_i(s_periph_addr),
        .cfg_valid_i(s_periph_valid[0]),
        .cfg_rwn_i(s_periph_rwn),
        .cfg_data_o(s_periph_data_from_cgunit),
        .cfg_ready_o(s_periph_ready_from_cgunit),

        .cg_value_o(s_cg_value),
        .cg_core_o(s_clk_core_en),

        .rst_value_o(), //TODO 

        .event_valid_i(event_valid_i),
        .event_data_i (event_data_i),
        .event_ready_o(event_ready_o),

        .event_o(event_o)
    );

    pulp_clock_gating i_clk_gate_sys_udma
    (
        .clk_i(sys_clk_i),
        .en_i(s_clk_core_en),
        .test_en_i(dft_cg_enable_i),
        .clk_o(s_clk_core)
    );

    genvar i;
    generate
      for (i=0;i<N_PERIPHS;i++)
      begin
        pulp_clock_gating_async i_clk_gate_per
        (
            .clk_i(per_clk_i),
            .rstn_i(HRESETn),
            .en_async_i(s_cg_value[i]),
            .en_ack_o(),
            .test_en_i(dft_cg_enable_i),
            .clk_o(periph_per_clk_o[i])
        );
    
        pulp_clock_gating i_clk_gate_sys
        (
            .clk_i(s_clk_core),
            .en_i(s_cg_value[i]),
            .test_en_i(dft_cg_enable_i),
            .clk_o(periph_sys_clk_o[i])
        );
      end
    endgenerate

endmodule
