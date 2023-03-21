
module udma_mram_macro_wrapper
(


    input  logic                            pmu_trc_clk_i,
    input  logic                            pmu_trc_rst_n_i,
    input  logic                            pmu_trc_ret_n_i,
    input  logic                      [2:0] pmu_trc_curset_ret_i,
    input  logic                            pmu_trc_retain_en_i,
    input  logic                      [1:0] pmu_trc_prog_delay_ret_i,
    output logic                            pmu_trc_pok_ret_o,
    input  logic                            dft_test_mode_i,
    


    // Logic Control Pins
    input  logic                     mram_CLK_i,     // CLOCK pin
    input  logic                     mram_CEb_i,     // Chip enable (active low)
    input  logic [18:0]              mram_A_i,       // Address Inputs
    input  logic [77:0]              mram_DIN_i,     // Data Inputs
    output logic [77:0]              mram_DOUT_o,    // Data Outputs
    input  logic                     mram_RDEN_i,    // Read Enable
    input  logic                     mram_WEb_i,     // Write Enable (active low)
    input  logic                     mram_PROGEN_i,  // Program Enable
    input  logic                     mram_PROG_i,    // Program signal
    input  logic                     mram_ERASE_i,   // Erase signal
    input  logic                     mram_CHIP_i,    // Chip Erase

    input logic                      mram_PORb_i,    // Power On Reset Input
    input logic                      mram_RETb_i,    // Configuration Register Retention
    input logic                      mram_RSTb_i,    // Chip Reset
    input logic                      mram_NVR_i,     // NVR Sector Selection
    input logic                      mram_TMEN_i,    // Test Mode Enable
    input logic                      mram_AREF_i,    // Ref Column Select
    input logic                      mram_DPD_i,     // Deep Power Down
    input logic                      mram_ECCBYPS_i, // To Bypass ECC Encoder and Decoder

    input  logic                     mram_SHIFT_i,   // Configuration Shift
    input  logic                     mram_SUPD_i,    // Configuration Register Update
    input  logic                     mram_SDI_i,     // Configuration register Input
    input  logic                     mram_SCLK_i,    // Configuration Register Clock
    output logic                     mram_SDO_o,     // Configuration Register Output Configuration

    output logic                     mram_RDY_o,     // Ready Status
    output logic                     mram_DONE_o,    // Program/Erase Status
    output logic                     mram_EC_o,      // ECC Error Correction
    output logic                     mram_UE_o       // Unrecoverable Error


    // inout  logic                     VREF,
    // inout  logic                     VPR,
    // inout  logic                     VDDA,
    // inout  logic                     VDD_cfg,
    // inout  logic                     VDD,
    // inout  logic                     VSS
);

	logic s_ao_retain;
	logic s_ao_isolate;
	logic s_ictrl;

    ick_rvt_hstrcl20d1 u_soc_trc
    (
        .CLK            ( pmu_trc_clk_i            ), //input CLK;
        .NRST           ( pmu_trc_rst_n_i          ), //input NRST;
        .POWER          ( pmu_trc_ret_n_i          ), //input POWER;
        .CURSET         ( pmu_trc_curset_ret_i     ), //input [2:0] CURS
        .RETAIN_EN      ( pmu_trc_retain_en_i      ), //input RETAIN_EN;
        .PROG_DELAY     ( pmu_trc_prog_delay_ret_i ), //input [1:0] PROG
        .TBYPASS_MODE   ( 1'b0                     ), //input TBYPASS_MO
        .TBYPASS_ISOLATE(                          ), //input TBYPASS_IS
        .TBYPASS_RETAIN (                          ), //input TBYPASS_RE
        .POK            ( pmu_trc_pok_ret_o        ), //output POK;
        .RETAIN         ( s_ao_retain              ), //output RETAIN;
        .ISOLATE        ( s_ao_isolate             ), //output ISOLATE;
        .FB             (                          ), //output FB;
        .ICTRL          ( s_ictrl                  ), //output ICTRL;
        .ICTRL_DETECT   ( s_ictrl                  ), //input  ICTRL_DET
        .SCAN_MODE      ( dft_test_mode_i          ) //input  SCAN_MODE
        /*
        ,
        .VDDAO          (                 ), //input VDDAO;
        .VDD            (                 ), //input VDD;
        .VSS            (                 )  //input VSS;
        */
    );


    MRAM_eFLASH_512Kx78 i_MRAM_eFLASH_512Kx78
    (
        .CLK                    (  mram_CLK_i      ),
        .CEb                    (  mram_CEb_i      ),
        .A                      (  mram_A_i        ),
        .DIN                    (  mram_DIN_i      ),
        .RDEN                   (  mram_RDEN_i     ),
        .WEb                    (  mram_WEb_i      ),
        .PROGEN                 (  mram_PROGEN_i   ),
        .PROG                   (  mram_PROG_i     ),
        .ERASE                  (  mram_ERASE_i    ),
        .CHIP                   (  mram_CHIP_i     ),
        .DONE                   (  mram_DONE_o     ),
        .RDY                    (  mram_RDY_o      ),
        .DOUT                   (  mram_DOUT_o     ),

        .TMEN                   (  mram_TMEN_i     ),
        .AREF                   (  mram_AREF_i     ),
        .NVR                    (  mram_NVR_i      ),

        .PORb                   (  mram_PORb_i     ),
        .RSTb                   (  mram_RSTb_i     ),
        .RETb                   (  mram_RETb_i     ),
        .DPD                    (  mram_DPD_i      ),

        .SHIFT                  (  mram_SHIFT_i    ),
        .SUPD                   (  mram_SUPD_i     ),
        .SDI                    (  mram_SDI_i      ),
        .SCLK                   (  mram_SCLK_i     ),
        .SDO                    (  mram_SDO_o      ),

        .EC                     (  mram_EC_o       ),
        .UE                     (  mram_UE_o       ),
        .ECCBYPS                (  mram_ECCBYPS_i  ),
`ifndef SYNTHESIS   
        .VREF                   ( VREF             ),
        .VPR                    ( VPR              ),
        .VDDA                   ( VDDA             ),
        .VDD_cfg                ( VDD_cfg          ),
        .VDD                    ( VDD              ),
        .VSS                    ( VSS              ),
`endif
        .TMO                    (                  )
    );

endmodule