// Copyright 2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.


module pad_frame
    (

        input logic [47:0][5:0] pad_cfg_i        ,

        // REF CLOCK
        output logic            ref_clk_o        ,
        output logic            clk_soc_ext_o    ,
        output logic            clk_per_ext_o    ,

        // RESET SIGNALS
        output logic            rstn_o           ,

        // JTAG SIGNALS
        output logic            jtag_tck_o       ,
        output logic            jtag_tdi_o       ,
        input  logic            jtag_tdo_i       ,
        output logic            jtag_tms_o       ,
        output logic            jtag_trst_o      ,

        input logic             oe_sdio_clk_i   ,
        input logic             oe_sdio_cmd_i    ,
        input logic             oe_sdio_data0_i   ,
        input logic             oe_sdio_data1_i   ,
        input logic             oe_sdio_data2_i   ,
        input logic             oe_sdio_data3_i   ,
        input logic             oe_spim_sdio0_i  ,
        input logic             oe_spim_sdio1_i  ,
        input logic             oe_spim_sdio2_i  ,
        input logic             oe_spim_sdio3_i  ,
        input logic             oe_spim_csn0_i   ,
        input logic             oe_spim_csn1_i   ,
        input logic             oe_spim_sck_i    ,
        input logic             oe_i2s0_sck_i    ,
        input logic             oe_i2s0_ws_i     ,
        input logic             oe_i2s0_sdi_i    ,
        input logic             oe_i2s1_sdi_i    ,
        input logic             oe_cam_pclk_i    ,
        input logic             oe_cam_hsync_i   ,
        input logic             oe_cam_data0_i   ,
        input logic             oe_cam_data1_i   ,
        input logic             oe_cam_data2_i   ,
        input logic             oe_cam_data3_i   ,
        input logic             oe_cam_data4_i   ,
        input logic             oe_cam_data5_i   ,
        input logic             oe_cam_data6_i   ,
        input logic             oe_cam_data7_i   ,
        input logic             oe_cam_vsync_i   ,
        input logic             oe_i2c0_sda_i    ,
        input logic             oe_i2c0_scl_i    ,
        input logic             oe_uart_rx_i     ,
        input logic             oe_uart_tx_i     ,

        // INPUTS SIGNALS TO THE PADS
        input logic             out_sdio_clk_i  ,
        input logic             out_sdio_cmd_i   ,
        input logic             out_sdio_data0_i  ,
        input logic             out_sdio_data1_i  ,
        input logic             out_sdio_data2_i  ,
        input logic             out_sdio_data3_i  ,
        input logic             out_spim_sdio0_i ,
        input logic             out_spim_sdio1_i ,
        input logic             out_spim_sdio2_i ,
        input logic             out_spim_sdio3_i ,
        input logic             out_spim_csn0_i  ,
        input logic             out_spim_csn1_i  ,
        input logic             out_spim_sck_i   ,
        input logic             out_i2s0_sck_i   ,
        input logic             out_i2s0_ws_i    ,
        input logic             out_i2s0_sdi_i   ,
        input logic             out_i2s1_sdi_i   ,
        input logic             out_cam_pclk_i   ,
        input logic             out_cam_hsync_i  ,
        input logic             out_cam_data0_i  ,
        input logic             out_cam_data1_i  ,
        input logic             out_cam_data2_i  ,
        input logic             out_cam_data3_i  ,
        input logic             out_cam_data4_i  ,
        input logic             out_cam_data5_i  ,
        input logic             out_cam_data6_i  ,
        input logic             out_cam_data7_i  ,
        input logic             out_cam_vsync_i  ,
        input logic             out_i2c0_sda_i   ,
        input logic             out_i2c0_scl_i   ,
        input logic             out_uart_rx_i    ,
        input logic             out_uart_tx_i    ,
        input logic             gatemram_vdd     ,
        input logic             gatemram_vdda    ,
        input logic             gatemram_vref    ,

        // step and hold
        output logic                      hold_wu,
        output logic                      step_wu,
        // manual scan chain
        output logic                      wu_bypass_en,
        output logic                      wu_bypass_data_in,
        output logic                      wu_bypass_shift,
        output logic                      wu_bypass_mux,
        input logic                       wu_bypass_data_out,
        // external power control to LLFSM
        output logic                      ext_pg_logic,
        output logic                      ext_pg_l2,
        output logic                      ext_pg_l2_udma,
        output logic                      ext_pg_l1,
        output logic                      ext_pg_udma,
        output logic                      ext_pg_mram,

        output logic            scan_en_in,
        output logic            soc_scan_in,
        input  logic            soc_scan_out,
        //output logic            per_scan_en,
        output logic            per_scan_in,
        input  logic            per_scan_out,
        //output logic            ref_scan_en,
        output logic            ref_scan_in,
        input  logic            ref_scan_out, 

        // OUTPUT SIGNALS FROM THE PADS
        output logic            in_sdio_clk_o   ,
        output logic            in_sdio_cmd_o    ,
        output logic            in_sdio_data0_mux_o   ,
        output logic            in_sdio_data1_mux_o   ,
        output logic            in_sdio_data2_mux_o   ,
        output logic            in_sdio_data3_o   ,
        output logic            in_spim_sdio0_o  ,
        output logic            in_spim_sdio1_o  ,
        output logic            in_spim_sdio2_o  ,
        output logic            in_spim_sdio3_o  ,
        output logic            in_spim_csn0_o   ,
        output logic            in_spim_csn1_o   ,
        output logic            in_spim_sck_o    ,
        output logic            in_i2s0_sck_o    ,
        output logic            in_i2s0_ws_o     ,
        output logic            in_i2s0_sdi_o    ,
        output logic            in_i2s1_sdi_o    ,
        output logic            in_cam_pclk_mux_o    ,
        output logic            in_cam_hsync_mux_o   ,
        output logic            in_cam_data0_mux_o   ,
        output logic            in_cam_data1_mux_o   ,
        output logic            in_cam_data2_mux_o   ,
        output logic            in_cam_data3_mux_o   ,
        output logic            in_cam_data4_mux_o   ,
        output logic            in_cam_data5_mux_o   ,
        output logic            in_cam_data6_mux_o   ,
        output logic            in_cam_data7_mux_o   ,
        output logic            in_cam_vsync_o   ,
        output logic            in_i2c0_sda_o    ,
        output logic            in_i2c0_scl_o    ,
        output logic            in_uart_rx_o     ,
        output logic            in_uart_tx_o     ,

        output logic            bootsel_o        ,

        // EXT CHIP TP PADS
        inout wire              pad_sdio_clk    ,
        inout wire              pad_sdio_cmd     ,
        inout wire              pad_sdio_data0    ,
        inout wire              pad_sdio_data1    ,
        inout wire              pad_sdio_data2    ,
        inout wire              pad_sdio_data3    ,
        inout wire              pad_spim_sdio0   ,
        inout wire              pad_spim_sdio1   ,
        inout wire              pad_spim_sdio2   ,
        inout wire              pad_spim_sdio3   ,
        inout wire              pad_spim_csn0    ,
        inout wire              pad_spim_csn1    ,
        inout wire              pad_spim_sck     ,
        inout wire              pad_i2s0_sck     ,
        inout wire              pad_i2s0_ws      ,
        inout wire              pad_i2s0_sdi     ,
        inout wire              pad_i2s1_sdi     ,
        inout wire              pad_cam_pclk     ,
        inout wire              pad_cam_hsync    ,
        inout wire              pad_cam_data0    ,
        inout wire              pad_cam_data1    ,
        inout wire              pad_cam_data2    ,
        inout wire              pad_cam_data3    ,
        inout wire              pad_cam_data4    ,
        inout wire              pad_cam_data5    ,
        inout wire              pad_cam_data6    ,
        inout wire              pad_cam_data7    ,
        inout wire              pad_cam_vsync    ,
        inout wire              pad_i2c0_sda     ,
        inout wire              pad_i2c0_scl     ,
        inout wire              pad_uart_rx      ,
        inout wire              pad_uart_tx      ,

        inout wire              pad_reset_n      ,
        inout wire              pad_bootsel      ,
        inout wire              pad_jtag_tck     ,
        inout wire              pad_jtag_tdi     ,
        inout wire              pad_jtag_tdo     ,
        inout wire              pad_jtag_tms     ,
        inout wire              pad_jtag_trst    ,
        inout wire              pad_xtal_in      ,
        inout wire              pad_clk_soc_ext  ,
        inout wire              pad_clk_per_ext  ,
        inout wire              pad_gatemram_vdd ,
        inout wire              pad_gatemram_vdda,
        inout wire              pad_gatemram_vref,
        inout wire              pad_hold_wu,
        inout wire              pad_step_wu,
        inout wire              pad_wu_bypass_out,
        inout wire              pad_wu_bypass_mux,
        inout wire              pad_debug_ctrl,
        inout wire              pad_scan_en_in,
        //inout wire              pad_soc_scan_in,
        inout wire              pad_soc_scan_out,
        //inout wire              pad_per_scan_en,
        //inout wire              pad_per_scan_in,
        inout wire              pad_per_scan_out,
        //inout wire              pad_ref_scan_en,
        //inout wire              pad_ref_scan_in,
        inout wire              pad_ref_scan_out
    );

    logic debug_ctrl;
    logic            in_cam_pclk_o;
    logic            in_cam_hsync_o;
    logic            in_cam_data0_o;
    logic            in_cam_data1_o;
    logic            in_cam_data2_o;
    logic            in_cam_data3_o;
    logic            in_cam_data4_o;
    logic            in_cam_data5_o;
    logic            in_cam_data6_o;
    logic            in_cam_data7_o;

    logic            in_sdio_data0_o;
    logic            in_sdio_data1_o;
    logic            in_sdio_data2_o;

    wire io_pwr_ok_a, pwr_ok_a;
    wire io_pwr_ok_b, pwr_ok_b;
    wire io_pwr_ok_c, pwr_ok_c;
    //wire netTie1;
    wire netTie0;

    assign netTie0 = 1'b0; 
    //assign netTie1 = 1'b1;

    pad_functional_h_pd padinst_sdio_data0 (.OEN(~oe_sdio_data0_i || scan_en_in ), .I(out_sdio_data0_i ), .io_pwr_ok(), .pwr_ok(), .O(in_sdio_data0_o ), .PAD(pad_sdio_data0 ), .PEN(~pad_cfg_i[22][0] || scan_en_in ) );
    pad_functional_h_pd padinst_sdio_data1 (.OEN(~oe_sdio_data1_i || scan_en_in ), .I(out_sdio_data1_i ), .io_pwr_ok(), .pwr_ok(), .O(in_sdio_data1_o ), .PAD(pad_sdio_data1 ), .PEN(~pad_cfg_i[23][0] || scan_en_in ) );
    pad_functional_h_pd padinst_sdio_data2 (.OEN(~oe_sdio_data2_i || scan_en_in ), .I(out_sdio_data2_i ), .io_pwr_ok(), .pwr_ok(),  .O(in_sdio_data2_o ), .PAD(pad_sdio_data2 ), .PEN(~pad_cfg_i[24][0] || scan_en_in ) );
    pad_functional_h_pd padinst_sdio_data3 (.OEN(~oe_sdio_data3_i ), .I(out_sdio_data3_i ), .io_pwr_ok(), .pwr_ok(),  .O(in_sdio_data3_o ), .PAD(pad_sdio_data3 ), .PEN(~pad_cfg_i[25][0]) );
    pad_functional_h_pd padinst_sdio_clk   (.OEN(~oe_sdio_clk_i  ), .I(out_sdio_clk_i  ), .io_pwr_ok(), .pwr_ok(),  .O(in_sdio_clk_o  ), .PAD(pad_sdio_clk  ), .PEN(~pad_cfg_i[20][0]) );
    pad_functional_h_pd padinst_sdio_cmd   (.OEN(~oe_sdio_cmd_i  ), .I(out_sdio_cmd_i  ), .io_pwr_ok(), .pwr_ok(),  .O(in_sdio_cmd_o  ), .PAD(pad_sdio_cmd  ), .PEN(~pad_cfg_i[21][0]) );
    pad_functional_h_pd padinst_spim_sck   (.OEN(~oe_spim_sck_i  ), .I(out_spim_sck_i  ), .io_pwr_ok(), .pwr_ok(), .O(in_spim_sck_o  ), .PAD(pad_spim_sck  ), .PEN(~pad_cfg_i[6][0] ) );
    pad_functional_h_pd padinst_spim_sdio0 (.OEN(~oe_spim_sdio0_i), .I(out_spim_sdio0_i), .io_pwr_ok(), .pwr_ok(), .O(in_spim_sdio0_o), .PAD(pad_spim_sdio0), .PEN(~pad_cfg_i[0][0] ) );
    pad_functional_h_pd padinst_spim_sdio1 (.OEN(~oe_spim_sdio1_i), .I(out_spim_sdio1_i), .io_pwr_ok(), .pwr_ok(), .O(in_spim_sdio1_o), .PAD(pad_spim_sdio1), .PEN(~pad_cfg_i[1][0] ) );
    pad_functional_h_pd padinst_spim_sdio2 (.OEN(~oe_spim_sdio2_i), .I(out_spim_sdio2_i), .io_pwr_ok(), .pwr_ok(), .O(in_spim_sdio2_o), .PAD(pad_spim_sdio2), .PEN(~pad_cfg_i[2][0] ) );
    pad_functional_h_pd padinst_spim_sdio3 (.OEN(~oe_spim_sdio3_i), .I(out_spim_sdio3_i), .io_pwr_ok(), .pwr_ok(), .O(in_spim_sdio3_o), .PAD(pad_spim_sdio3), .PEN(~pad_cfg_i[3][0] ) );
    pad_functional_h_pd padinst_spim_csn1  (.OEN(~oe_spim_csn1_i ), .I(out_spim_csn1_i ), .io_pwr_ok(), .pwr_ok(), .O(in_spim_csn1_o ), .PAD(pad_spim_csn1 ), .PEN(~pad_cfg_i[5][0] ) );
    pad_functional_h_pd padinst_spim_csn0  (.OEN(~oe_spim_csn0_i ), .I(out_spim_csn0_i ), .io_pwr_ok(), .pwr_ok(), .O(in_spim_csn0_o ), .PAD(pad_spim_csn0 ), .PEN(~pad_cfg_i[4][0] ) );

    pad_functional_h_pd padinst_i2s1_sdi   (.OEN(~oe_i2s1_sdi_i  ), .I(out_i2s1_sdi_i  ), .io_pwr_ok(), .pwr_ok(), .O(in_i2s1_sdi_o  ), .PAD(pad_i2s1_sdi  ), .PEN(~pad_cfg_i[38][0]) );
    pad_functional_h_pd padinst_i2s0_ws    (.OEN(~oe_i2s0_ws_i   ), .I(out_i2s0_ws_i   ), .io_pwr_ok(), .pwr_ok(), .O(in_i2s0_ws_o   ), .PAD(pad_i2s0_ws   ), .PEN(~pad_cfg_i[36][0]) );
    pad_functional_h_pd padinst_i2s0_sdi   (.OEN(~oe_i2s0_sdi_i  ), .I(out_i2s0_sdi_i  ), .io_pwr_ok(), .pwr_ok(), .O(in_i2s0_sdi_o  ), .PAD(pad_i2s0_sdi  ), .PEN(~pad_cfg_i[37][0]) );
    pad_functional_h_pd padinst_i2s0_sck   (.OEN(~oe_i2s0_sck_i  ), .I(out_i2s0_sck_i  ), .io_pwr_ok(), .pwr_ok(), .O(in_i2s0_sck_o  ), .PAD(pad_i2s0_sck  ), .PEN(~pad_cfg_i[35][0]) );


    pad_functional_h_pd padinst_cam_pclk   (.OEN(~oe_cam_pclk_i || debug_ctrl ), .I(out_cam_pclk_i  ), .io_pwr_ok(), .pwr_ok(), .O(in_cam_pclk_o  ), .PAD(pad_cam_pclk  ), .PEN(~pad_cfg_i[9][0] || debug_ctrl ) );
    pad_functional_h_pd padinst_cam_hsync  (.OEN(~oe_cam_hsync_i || debug_ctrl ), .I(out_cam_hsync_i ), .io_pwr_ok(), .pwr_ok(), .O(in_cam_hsync_o ), .PAD(pad_cam_hsync ), .PEN(~pad_cfg_i[10][0] || debug_ctrl) );
    pad_functional_h_pd padinst_cam_data0  (.OEN(~oe_cam_data0_i || debug_ctrl ), .I(out_cam_data0_i ), .io_pwr_ok(), .pwr_ok(), .O(in_cam_data0_o ), .PAD(pad_cam_data0 ), .PEN(~pad_cfg_i[11][0] || debug_ctrl) );
//    pad_functional_h_pd padinst_cam_data1  (.OEN(~oe_cam_data1_i || debug_ctrl ), .I(out_cam_data1_i ), .io_pwr_ok(), .pwr_ok(), .O(in_cam_data1_o ), .PAD(pad_cam_data1 ), .PEN(~pad_cfg_i[12][0] || debug_ctrl) );
    pad_functional_h_pd padinst_cam_data1  (.OEN(~oe_cam_data1_i ), .I(out_cam_data1_i ), .io_pwr_ok(), .pwr_ok(), .O(in_cam_data1_o ), .PAD(pad_cam_data1 ), .PEN(~pad_cfg_i[12][0]) );
    pad_functional_h_pd padinst_cam_data2  (.OEN(~oe_cam_data2_i || debug_ctrl ), .I(out_cam_data2_i ), .io_pwr_ok(), .pwr_ok(), .O(in_cam_data2_o ), .PAD(pad_cam_data2 ), .PEN(~pad_cfg_i[13][0] || debug_ctrl) );
    pad_functional_h_pd padinst_cam_data3  (.OEN(~oe_cam_data3_i || debug_ctrl ), .I(out_cam_data3_i ), .io_pwr_ok(), .pwr_ok(), .O(in_cam_data3_o ), .PAD(pad_cam_data3 ), .PEN(~pad_cfg_i[14][0] || debug_ctrl) );
    pad_functional_h_pd padinst_cam_data4  (.OEN(~oe_cam_data4_i || debug_ctrl ), .I(out_cam_data4_i ), .io_pwr_ok(), .pwr_ok(), .O(in_cam_data4_o ), .PAD(pad_cam_data4 ), .PEN(~pad_cfg_i[15][0] || debug_ctrl) );
    pad_functional_h_pd padinst_cam_data5  (.OEN(~oe_cam_data5_i || debug_ctrl ), .I(out_cam_data5_i ), .io_pwr_ok(), .pwr_ok(), .O(in_cam_data5_o ), .PAD(pad_cam_data5 ), .PEN(~pad_cfg_i[16][0] || debug_ctrl) );
    pad_functional_h_pd padinst_cam_data6  (.OEN(~oe_cam_data6_i || debug_ctrl ), .I(out_cam_data6_i ), .io_pwr_ok(), .pwr_ok(), .O(in_cam_data6_o ), .PAD(pad_cam_data6 ), .PEN(~pad_cfg_i[17][0] || debug_ctrl) );
    pad_functional_h_pd padinst_cam_data7  (.OEN(~oe_cam_data7_i || debug_ctrl ), .I(out_cam_data7_i ), .io_pwr_ok(), .pwr_ok(), .O(in_cam_data7_o ), .PAD(pad_cam_data7 ), .PEN(~pad_cfg_i[18][0] || debug_ctrl) );
    pad_functional_h_pd padinst_cam_vsync  (.OEN(~oe_cam_vsync_i ), .I(out_cam_vsync_i ), .io_pwr_ok(), .pwr_ok(), .O(in_cam_vsync_o ), .PAD(pad_cam_vsync ), .PEN(~pad_cfg_i[19][0]) );

    pad_functional_h_pd padinst_uart_rx    (.OEN(~oe_uart_rx_i   ), .I(out_uart_rx_i   ), .io_pwr_ok(), .pwr_ok(), .O(in_uart_rx_o   ), .PAD(pad_uart_rx   ), .PEN(~pad_cfg_i[33][0]) );
    pad_functional_h_pd padinst_uart_tx    (.OEN(~oe_uart_tx_i   ), .I(out_uart_tx_i   ), .io_pwr_ok(), .pwr_ok(), .O(in_uart_tx_o   ), .PAD(pad_uart_tx   ), .PEN(~pad_cfg_i[34][0]) );
    pad_functional_h_pd padinst_i2c0_sda   (.OEN(~oe_i2c0_sda_i  ), .I(out_i2c0_sda_i  ), .io_pwr_ok(), .pwr_ok(), .O(in_i2c0_sda_o  ), .PAD(pad_i2c0_sda  ), .PEN(~pad_cfg_i[7][0] ) );
    pad_functional_h_pd padinst_i2c0_scl   (.OEN(~oe_i2c0_scl_i  ), .I(out_i2c0_scl_i  ), .io_pwr_ok(), .pwr_ok(), .O(in_i2c0_scl_o  ), .PAD(pad_i2c0_scl  ), .PEN(~pad_cfg_i[8][0] ) );


    pad_functional_h_pd padinst_bootsel    (.OEN(1'b1            ), .I(                ), .io_pwr_ok(), .pwr_ok(), .O(bootsel_o      ), .PAD(pad_bootsel   ), .PEN(1'b1             ) );


`ifndef PULP_FPGA_EMUL
  pad_functional_h_pd padinst_ref_clk    (.OEN(1'b1            ), .I(                ), .io_pwr_ok(), .pwr_ok(), .O(ref_clk_o      ), .PAD(pad_xtal_in   ), .PEN(1'b1             ) );
  pad_functional_h_pd padinst_clk_soc_ext(.OEN(1'b1            ), .I(                ), .io_pwr_ok(), .pwr_ok(), .O(clk_soc_ext_o  ), .PAD(pad_clk_soc_ext), .PEN(1'b1             ) );
  pad_functional_h_pd padinst_clk_per_ext(.OEN(1'b1            ), .I(                ), .io_pwr_ok(), .pwr_ok(), .O(clk_per_ext_o  ), .PAD(pad_clk_per_ext), .PEN(1'b1             ) );
  pad_functional_h_pd padinst_reset_n    (.OEN(1'b1            ), .I(                ), .io_pwr_ok(), .pwr_ok(), .O(rstn_o         ), .PAD(pad_reset_n   ), .PEN(1'b1             ) );
  pad_functional_h_pd padinst_jtag_tck   (.OEN(1'b1            ), .I(                ), .io_pwr_ok(), .pwr_ok(), .O(jtag_tck_o     ), .PAD(pad_jtag_tck  ), .PEN(1'b1             ) );
  pad_functional_h_pd padinst_jtag_tms   (.OEN(1'b1            ), .I(                ), .io_pwr_ok(), .pwr_ok(), .O(jtag_tms_o     ), .PAD(pad_jtag_tms  ), .PEN(1'b1             ) );
  pad_functional_h_pd padinst_jtag_tdi   (.OEN(1'b1            ), .I(                ), .io_pwr_ok(), .pwr_ok(), .O(jtag_tdi_o     ), .PAD(pad_jtag_tdi  ), .PEN(1'b1             ) );
  pad_functional_h_pd padinst_jtag_trstn (.OEN(1'b1            ), .I(                ), .io_pwr_ok(), .pwr_ok(), .O(jtag_trst_o    ), .PAD(pad_jtag_trst ), .PEN(1'b1             ) );
  pad_functional_h_pd padinst_jtag_tdo   (.OEN(1'b0            ), .I(jtag_tdo_i      ), .io_pwr_ok(), .pwr_ok(), .O(               ), .PAD(pad_jtag_tdo  ), .PEN(1'b1             ) );
  pad_functional_h_pd padinst_gatemram_vdd  (.OEN(1'b0            ), .I( gatemram_vdd  ), .io_pwr_ok(), .pwr_ok(), .O(               ), .PAD(pad_gatemram_vdd ), .PEN(1'b1             ) );
  pad_functional_h_pd padinst_gatemram_vdda (.OEN(1'b0            ), .I( gatemram_vdda ), .io_pwr_ok(), .pwr_ok(), .O(               ), .PAD(pad_gatemram_vdda), .PEN(1'b1             ) );
  pad_functional_h_pd padinst_gatemram_vref (.OEN(1'b0            ), .I( gatemram_vref ), .io_pwr_ok(), .pwr_ok(), .O(               ), .PAD(pad_gatemram_vref), .PEN(1'b1             ) );
  pad_functional_h_pd padinst_wu_bypass  (.OEN(1'b0            ), .I( wu_bypass_data_out  ), .io_pwr_ok(), .pwr_ok(), .O(               ), .PAD(pad_wu_bypass_out ), .PEN(1'b1             ) );
  pad_functional_h_pd padinst_wu_bypass_mux (.OEN(1'b1            ), .I(                ), .io_pwr_ok(), .pwr_ok(), .O(wu_bypass_mux   ), .PAD(pad_wu_bypass_mux  ), .PEN(1'b1             ) );
  pad_functional_h_pd padinst_hold_wu    (.OEN(1'b1            ), .I(                ), .io_pwr_ok(), .pwr_ok(), .O(hold_wu      ), .PAD(pad_hold_wu   ), .PEN(1'b1             ) );
  pad_functional_h_pd padinst_step_wu    (.OEN(1'b1            ), .I(                ), .io_pwr_ok(), .pwr_ok(), .O(step_wu      ), .PAD(pad_step_wu   ), .PEN(1'b1             ) );
  pad_functional_h_pd padinst_debug      (.OEN(1'b1            ), .I(                ), .io_pwr_ok(), .pwr_ok(), .O(debug_ctrl   ), .PAD(pad_debug_ctrl), .PEN(1'b1             ) );
// scan chains related IOs
  pad_functional_h_pd padinst_scan_chain_en (.OEN(1'b1            ), .I(                ), .io_pwr_ok(), .pwr_ok(), .O(scan_en_in      ), .PAD(pad_scan_en_in   ), .PEN(1'b1             ) );
  //pad_functional_h_pd padinst_scan_chain_soc_in (.OEN(1'b1            ), .I(                ), .io_pwr_ok(), .pwr_ok(), .O(soc_scan_in      ), .PAD(pad_soc_scan_in   ), .PEN(1'b1             ) );
  pad_functional_h_pd padinst_scan_chain_soc_out(.OEN(1'b0            ), .I(                ), .io_pwr_ok(), .pwr_ok(), .O(                 ), .PAD(pad_soc_scan_out  ), .PEN(1'b1             ) );

  //pad_functional_h_pd padinst_scan_chain_per_en (.OEN(1'b1            ), .I(                ), .io_pwr_ok(), .pwr_ok(), .O(per_scan_en      ), .PAD(pad_per_scan_en   ), .PEN(1'b1             ) );
  //pad_functional_h_pd padinst_scan_chain_per_in (.OEN(1'b1            ), .I(                ), .io_pwr_ok(), .pwr_ok(), .O(per_scan_in      ), .PAD(pad_per_scan_in   ), .PEN(1'b1             ) );
  pad_functional_h_pd padinst_scan_chain_per_out(.OEN(1'b0            ), .I(                ), .io_pwr_ok(), .pwr_ok(), .O(                 ), .PAD(pad_per_scan_out  ), .PEN(1'b1             ) );

  //pad_functional_h_pd padinst_scan_chain_ref_en (.OEN(1'b1            ), .I(                ), .io_pwr_ok(), .pwr_ok(), .O(ref_scan_en      ), .PAD(pad_ref_scan_en   ), .PEN(1'b1             ) );
  //pad_functional_h_pd padinst_scan_chain_ref_in (.OEN(1'b1            ), .I(                ), .io_pwr_ok(), .pwr_ok(), .O(ref_scan_in      ), .PAD(pad_ref_scan_in   ), .PEN(1'b1             ) );
  pad_functional_h_pd padinst_scan_chain_ref_out(.OEN(1'b0            ), .I(                ), .io_pwr_ok(), .pwr_ok(), .O(                 ), .PAD(pad_ref_scan_out  ), .PEN(1'b1             ) );

`else
  assign ref_clk_o = pad_xtal_in;
  assign rstn_o = pad_reset_n;

  //JTAG signals
  assign pad_jtag_tdo = jtag_tdo_i;
  assign jtag_trst_o = pad_jtag_trst;
  assign jtag_tms_o = pad_jtag_tms;
  assign jtag_tck_o = pad_jtag_tck;
  assign jtag_tdi_o = pad_jtag_tdi;
`endif

  always_comb begin
    if (debug_ctrl) begin
      wu_bypass_en = in_cam_pclk_o;
      wu_bypass_data_in = in_cam_hsync_o;
      wu_bypass_shift = in_cam_data0_o;
      //wu_bypass_mux = in_cam_data1_o;
      ext_pg_logic = in_cam_data2_o;
      ext_pg_l2 = in_cam_data3_o;
      ext_pg_l2_udma = in_cam_data4_o;
      ext_pg_l1 = in_cam_data5_o;
      ext_pg_udma = in_cam_data6_o;
      ext_pg_mram = in_cam_data7_o;
      in_cam_pclk_mux_o = 1'b0;
      in_cam_hsync_mux_o = 1'b0;
      in_cam_data0_mux_o = 1'b0;
      in_cam_data1_mux_o = 1'b0;
      in_cam_data2_mux_o = 1'b0;
      in_cam_data3_mux_o = 1'b0;
      in_cam_data4_mux_o = 1'b0;
      in_cam_data5_mux_o = 1'b0;
      in_cam_data6_mux_o = 1'b0;
      in_cam_data7_mux_o = 1'b0;
    end else begin
      in_cam_pclk_mux_o = in_cam_pclk_o;
      in_cam_hsync_mux_o = in_cam_hsync_o;
      in_cam_data0_mux_o = in_cam_data0_o;
      in_cam_data1_mux_o = in_cam_data1_o;
      in_cam_data2_mux_o = in_cam_data2_o;
      in_cam_data3_mux_o = in_cam_data3_o;
      in_cam_data4_mux_o = in_cam_data4_o;
      in_cam_data5_mux_o = in_cam_data5_o;
      in_cam_data6_mux_o = in_cam_data6_o;
      in_cam_data7_mux_o = in_cam_data7_o;
      wu_bypass_en = 1'b0;
      wu_bypass_data_in = 1'b0;
      wu_bypass_shift = 1'b0;
      //wu_bypass_mux = 1'b0;
      ext_pg_logic = 1'b0;
      ext_pg_l2 = 1'b0;
      ext_pg_l2_udma = 1'b0; 
      ext_pg_l1 = 1'b0;
      ext_pg_udma = 1'b0;
      ext_pg_mram = 1'b0;
    end
  end

  always_comb begin
    if (scan_en_in) begin
      soc_scan_in = in_sdio_data0_o;
      per_scan_in = in_sdio_data1_o;
      ref_scan_in = in_sdio_data2_o;
      in_sdio_data0_mux_o = 1'b0;
      in_sdio_data1_mux_o = 1'b0;
      in_sdio_data2_mux_o = 1'b0;
    end else begin
      in_sdio_data0_mux_o = in_sdio_data0_o;
      in_sdio_data1_mux_o = in_sdio_data1_o;
      in_sdio_data2_mux_o = in_sdio_data2_o;
      soc_scan_in = 1'b0;
      per_scan_in = 1'b0;
      ref_scan_in = 1'b0;
    end
  end

endmodule // pad_frame
