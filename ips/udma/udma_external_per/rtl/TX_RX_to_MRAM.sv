`define INT_DIV(A, B) ( (A%B==0) ? A/B : A/B+1)


module TX_RX_to_MRAM
(
    input  logic                  clk,
    input  logic                  rst_n,
    input  logic                  scan_en_in,
    input  logic [7:0]            mram_mode_tx_i,
    input  logic [7:0]            mram_mode_rx_i,

    input  logic [77:0]           data_tx_wdata_i,
    input  logic [15:0]           data_tx_addr_i,
    input  logic                  data_tx_req_i,
    input  logic                  data_tx_eot_i,
    output logic                  data_tx_gnt_o,

    input  logic                  NVR_tx_i,
    input  logic                  TMEN_tx_i,
    input  logic                  AREF_tx_i,

    input  logic [15:0]           data_rx_raddr_i,
    input  logic                  data_rx_clk_en_i,
    input  logic                  data_rx_req_i,
    input  logic                  data_rx_eot_i,
    output logic                  data_rx_gnt_o,
    output logic [63:0]           data_rx_rdata_o,
    output logic [1:0]            data_rx_error_o,

    input  logic                  NVR_rx_i,
    input  logic                  TMEN_rx_i,
    input  logic                  AREF_rx_i,

    output logic                  CEb_o,
    output logic [15:0]           A_o,
    output logic [77:0]           DIN_o,
    output logic                  RDEN_o,
    output logic                  WEb_o,
    output logic                  PROGEN_o,
    output logic                  PROG_o,
    output logic                  ERASE_o,
    output logic                  CHIP_o,
    input  logic                  DONE_i,
    input  logic [77:0]           DOUT_i,
    output logic                  CLK_o,
    input  logic                  EC_i,
    input  logic                  UE_i,

    output logic                  NVR_o,
    output logic                  TMEN_o,
    output logic                  AREF_o

);

    localparam CLK_PERIOD    = 25; // 10 MHz
    localparam tPROG_COUNT   = `INT_DIV(200,  CLK_PERIOD); // Min Pulse Width PROG
    localparam tPGS_COUNT    = `INT_DIV(20000, CLK_PERIOD); // setup time Prog,Wen --> Progen
    localparam tADS_COUNT    = `INT_DIV(100,  CLK_PERIOD); //  setup time Address  --> Prog
    localparam tRW_COUNT     = `INT_DIV(3000, CLK_PERIOD); //  Latency from Write to Read
    localparam tAREF_COUNT   = `INT_DIV(100,  CLK_PERIOD); //  Latency from Write to Read

    localparam CMD_TRIM_CFG           = 8'b00000001;
    localparam CMD_NORMAL_TX          = 8'b00000010;
    localparam CMD_ERASE_CHIP         = 8'b00000100;
    localparam CMD_ERASE_SECT         = 8'b00001000;
    localparam CMD_ERASE_WORD         = 8'b00010000;
    localparam CMD_PWDN               = 8'b00100000;
    localparam CMD_READ_RX            = 8'b01000000;
    localparam CMD_REF_LINE_P         = 8'b10000000;
    localparam CMD_REF_LINE_AP        = 8'b11000000;

    enum logic [4:0] { STDBY=7, INIT_AREF_TMEM_NVR=3, INIT_CEB=2, INIT_PROG=0, PULSE_PROG=4,  
                       WAIT_PROG_ADDR_SETUP=12,  WAIT_LAT_NEXT_OPERATION=6, GO_STDBY=9, GO_CHECK_DONE=5, 
                       CHECK_DONE=1 , INIT_ERASE=14, WAIT_NEXT_WRITE=13, 
                       INIT_READ=11, LAST_READ=10 } CS, NS;

    logic                DONE_synch;
    logic [15:0]         Counter_CS, Counter_NS;
    logic [15:0]         Counter_Program;
    logic                start_next_prog_timeout, next_prog_timeout;
    logic                is_erase_CS, is_erase_NS;
    logic                is_chip_erase_NS, is_chip_erase_CS;

    logic                CEb_int;
    logic [15:0]         A_int;
    logic [77:0]         DIN_int;
    logic                RDEN_int;
    logic                WEb_int;
    logic                PROGEN_int;
    logic                PROG_int;
    logic                ERASE_int;
    logic                CHIP_int;
    logic                CLK_int;
    logic                en_clock_Q;


    assign data_rx_rdata_o = DOUT_i;
    assign CEb_o      = CEb_int;
    assign A_o        = A_int;
    assign DIN_o      = DIN_int;
    assign RDEN_o     = RDEN_int;
    assign WEb_o      = WEb_int;
    assign PROGEN_o   = PROGEN_int;
    assign PROG_o     = PROG_int;
    assign ERASE_o    = ERASE_int;
    assign CHIP_o     = CHIP_int;
    assign en_clock_Q = data_rx_clk_en_i;

/*
    always_ff @(posedge clk or negedge rst_n)
    begin : proc_seq_Deglitching
        if(~rst_n)
        begin
            CEb_o      <= 1'b1;
            A_o        <= '0;
            DIN_o      <= '0;
            RDEN_o     <= 1'b0;
            WEb_o      <= 1'b1;
            PROGEN_o   <= 1'b0;
            PROG_o     <= 1'b0;
            ERASE_o    <= 1'b0;
            CHIP_o     <= 1'b0; 
            en_clock_Q <= 1'b0;
        end
        else
        begin
            CEb_o      <= CEb_int;
            A_o        <= A_int;
            DIN_o      <= DIN_int;
            RDEN_o     <= RDEN_int;
            WEb_o      <= WEb_int;
            PROGEN_o   <= PROGEN_int;
            PROG_o     <= PROG_int;
            ERASE_o    <= ERASE_int;
            CHIP_o     <= CHIP_int;
            en_clock_Q <= data_rx_clk_en_i;
        end
    end
*/


    pulp_sync i_DONE_synchronizer
    (
      .clk_i    ( clk               ),
      .rstn_i   ( rst_n             ),
      .serial_i ( DONE_i            ),
      .serial_o ( DONE_synch        )
    );

   cluster_clock_gating i_CLK_out_CG
   (
      .clk_i     ( clk              ),
      .en_i      ( en_clock_Q && ~scan_en_in      ),
      .test_en_i ( 1'b0             ),
      .clk_o     ( CLK_o            )
   );
   

    assign next_prog_timeout = (Counter_Program == 0);

    // Counters
    always_ff @(posedge clk or negedge rst_n)
    begin : proc_seq_CNTs
      if(~rst_n)
      begin
         Counter_CS          <= '0;
         Counter_Program     <= tRW_COUNT;
      end 
      else
      begin
         Counter_CS         <= Counter_NS;

         if(start_next_prog_timeout == 1'b1)
            Counter_Program <= tRW_COUNT;
         else if(Counter_Program > 0)
                Counter_Program <= Counter_Program - 1'b1;
      end
    end


   // FSM
   always_ff @(posedge clk or negedge rst_n)
   begin : proc_seq_FSM
     if(~rst_n)
     begin
         CS  <= STDBY;
         is_erase_CS = 1'b0;
         is_chip_erase_CS = 1'b0;
     end
     else
     begin
         CS <= NS;
         is_erase_CS      = is_erase_NS;
         is_chip_erase_CS = is_chip_erase_NS;
     end
   end


   assign NVR_o  = (CS == STDBY) ? 1'b0 :  ((CS == LAST_READ) | (CS == INIT_READ)) ?  NVR_rx_i  : NVR_tx_i ;
   assign TMEN_o = (CS == STDBY) ? 1'b0 :  ((CS == LAST_READ) | (CS == INIT_READ)) ?  TMEN_rx_i : TMEN_tx_i ;
   assign AREF_o = (CS == STDBY) ? 1'b0 :  ((CS == LAST_READ) | (CS == INIT_READ)) ?  AREF_rx_i : AREF_tx_i ;


   always_comb 
   begin
      // default
      CEb_int          = 1'b1;
      WEb_int          = 1'b1;
      A_int            = '0;
      PROGEN_int       = 1'b0;
      PROG_int         = 1'b0;
      ERASE_int        = 1'b0;
      CHIP_int         = 1'b0;
      
      DIN_int          = '0;
      RDEN_int         = 1'b0;

      data_tx_gnt_o    = 1'b0;
      data_rx_gnt_o    = 1'b0;
      data_rx_error_o  = 2'b00;


      start_next_prog_timeout = 1'b0;
      Counter_NS     = Counter_CS;
      
      NS = CS;

      is_erase_NS      = is_erase_CS;
      is_chip_erase_NS = is_chip_erase_CS;



      case(CS)

        STDBY:
        begin
            Counter_NS = '0;

            if(data_tx_req_i)
            begin
                 NS = (next_prog_timeout) ?  INIT_AREF_TMEM_NVR : WAIT_LAT_NEXT_OPERATION;
                 is_erase_NS      = ( (mram_mode_tx_i ==  CMD_ERASE_CHIP) || (mram_mode_tx_i ==  CMD_ERASE_SECT) || (mram_mode_tx_i ==  CMD_ERASE_WORD) || (mram_mode_tx_i == CMD_REF_LINE_AP ) );
                 is_chip_erase_NS = (mram_mode_tx_i ==  CMD_ERASE_CHIP);
            end
            else
            begin
              if(data_rx_req_i)
              begin
                  data_rx_gnt_o = 1'b0;
                  NS = INIT_READ;
              end
              else
              begin
                  NS = STDBY;
              end
            end

        end //~ STDBY


        WAIT_LAT_NEXT_OPERATION:
        begin

            data_tx_gnt_o = 1'b0;
            Counter_NS = '0;

            if(next_prog_timeout)
            begin
              NS = INIT_CEB;
            end
            else
            begin
              NS = WAIT_LAT_NEXT_OPERATION;
            end

        end

        INIT_READ:
        begin
            CEb_int         = 1'b0;
            WEb_int         = 1'b1;
            A_int           = data_rx_raddr_i;
            RDEN_int        = data_rx_req_i;
            data_rx_gnt_o = 1'b1;
            data_rx_error_o = {EC_i, UE_i};

            if(data_rx_eot_i) 
                NS = LAST_READ;
            else
                NS = INIT_READ;
        end

        LAST_READ:
        begin
            data_rx_gnt_o   = 1'b0;
            CEb_int           = 1'b0;
            WEb_int           = 1'b1;
            RDEN_int          = 1'b0;
            data_rx_error_o = {EC_i, UE_i};
            NS = STDBY;
        end


        INIT_AREF_TMEM_NVR:
        begin
          CHIP_int     = is_chip_erase_CS;

          if(Counter_CS < tAREF_COUNT )
          begin
            Counter_NS = Counter_CS + 1'b1;
            NS = INIT_AREF_TMEM_NVR;
          end
          else
          begin
            Counter_NS = '0;
            NS = INIT_CEB;
          end

        end

        INIT_CEB:
        begin
          CHIP_int     = is_chip_erase_CS;
          CEb_int      = 1'b0;
          Counter_NS = '0;

          NS = INIT_PROG;
        end



        INIT_PROG:
        begin
          CEb_int          = 1'b0;
          WEb_int          = 1'b0;
          PROG_int         = ~is_erase_CS;
          ERASE_int        =  is_erase_CS;
          CHIP_int         =  is_chip_erase_CS;

          A_int            = data_tx_addr_i;
          DIN_int          = data_tx_wdata_i;

          if(Counter_CS < tPGS_COUNT)
          begin
            Counter_NS = Counter_CS + 1'b1;
            NS = INIT_PROG;
          end
          else
          begin
            Counter_NS = '0;
            NS = PULSE_PROG;
          end
        end


        PULSE_PROG:
        begin
          CEb_int          = 1'b0;
          WEb_int          = 1'b0;
          PROG_int         = ~is_erase_CS;
          ERASE_int        =  is_erase_CS;
          CHIP_int         = is_chip_erase_CS;
          A_int            = data_tx_addr_i;
          DIN_int          = data_tx_wdata_i;
          PROGEN_int     = 1'b1;

          NS = GO_CHECK_DONE;
        end


        GO_CHECK_DONE:
        begin

          CEb_int          = 1'b0;
          WEb_int          = 1'b0;
          PROG_int         = ~is_erase_CS;
          ERASE_int        =  is_erase_CS;
          CHIP_int         = is_chip_erase_CS;
          A_int            = data_tx_addr_i;
          DIN_int          = data_tx_wdata_i;
          PROGEN_int     = 1'b1;
          Counter_NS     = '0;

          NS = CHECK_DONE; 
        end //~ GO_CHECK_DONE


        CHECK_DONE:
        begin
          CEb_int          = 1'b0;
          WEb_int          = 1'b0;
          PROG_int         = ~is_erase_CS;
          ERASE_int        =  is_erase_CS;
          CHIP_int         =  is_chip_erase_CS;
          A_int            = data_tx_addr_i;
          DIN_int          = data_tx_wdata_i;
          PROGEN_int     = 1'b1;
          Counter_NS = '0;

          data_tx_gnt_o = DONE_synch;

          if(DONE_synch)
          begin

                if(data_tx_eot_i) // is the last write:
                begin
                  NS = GO_STDBY;
                  is_erase_NS = 1'b0;
                  start_next_prog_timeout = 1'b1;
                end
                else
                begin
                  NS = WAIT_NEXT_WRITE;
                end

          end
          else
          begin
              NS = CHECK_DONE;
          end
        end //~ CHECK_DONE


        WAIT_NEXT_WRITE:
        begin

          CEb_int          = 1'b0;
          WEb_int          = 1'b0;
          PROG_int         = ~is_erase_CS;
          ERASE_int        =  is_erase_CS;
          CHIP_int         = is_chip_erase_CS;
          A_int            = data_tx_addr_i;
          DIN_int          = data_tx_wdata_i;

          Counter_NS = '0;

            if(data_tx_req_i)
                NS = WAIT_PROG_ADDR_SETUP;
            else
                NS = WAIT_NEXT_WRITE;
        end //~ WAIT_NEXT_WRITE



        WAIT_PROG_ADDR_SETUP:
        begin

          CEb_int          = 1'b0;
          WEb_int          = 1'b0;
          PROG_int         = ~is_erase_CS;
          ERASE_int        =  is_erase_CS;
          CHIP_int         =  is_chip_erase_CS;
          A_int            = data_tx_addr_i;
          DIN_int          = data_tx_wdata_i;

            if(Counter_CS < tADS_COUNT)
            begin
              Counter_NS = Counter_CS + 1'b1;
              NS = WAIT_PROG_ADDR_SETUP;
            end
            else
            begin
              Counter_NS = '0;
              NS = PULSE_PROG;
            end
        end //~WAIT_PROG_ADDR_SETUP



        GO_STDBY:
        begin
          CEb_int          = 1'b0;
          WEb_int          = 1'b1;
          is_erase_NS      = 1'b0;
          is_chip_erase_NS = 1'b0;

          CHIP_int         = 1'b0;
          PROG_int         = 1'b0;
          ERASE_int        = 1'b0;
          
          A_int            = data_tx_addr_i;
          DIN_int          = data_tx_wdata_i;
          PROGEN_int     = 1'b0;

        
          if(Counter_CS < tAREF_COUNT)
          begin
            Counter_NS = Counter_CS + 1'b1;
            NS = GO_STDBY;
          end
          else
          begin
            Counter_NS = '0;
            NS =  STDBY;
          end

        end //~ GO_STDBY



        endcase // CS
    end


endmodule // TX_RX_to_MRAM
