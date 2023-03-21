module size_conv_TX_32_to_64
#(
   parameter TRANS_SIZE       = 16,
   parameter NUM_TRIM_BYTE    = 532,
   parameter NUM_CYCLE_STROBE = 3,
   parameter NUM_CYCLE_GO_SUP = 6
)
(
   input  logic                        clk,
   input  logic                        rst_n,

   // From L2
   input  logic [31:0]                 data_tx_wdata_i,
   input  logic                        data_tx_valid_i,
   output logic                        data_tx_ready_o,

   // comand  from reg_if
   input  logic                        push_cmd_req_i,
   output logic                        push_cmd_gnt_o,
   input  logic [15:0]                 data_tx_addr_i,
   input  logic [TRANS_SIZE-1:0]       data_tx_size_i,
   
   // Data
   output logic [77:0]                 data_tx_wdata_o,
   output logic [15:0]                 data_tx_addr_o,
   output logic                        data_tx_req_o,
   output logic                        data_tx_eot_o,
   input  logic                        data_tx_gnt_i,

   output logic                        pending_o,
   output logic                        tx_done_o,
   output logic                        trim_cfg_done_o,
   
   input  logic [15:0]                 erase_addr_i,
   input  logic [9:0]                  erase_size_i,

   output logic                        erase_done_o,
   output logic                        erase_pending_o,

   output logic                        ref_line_pending_o,
   output logic                        ref_line_done_o,


   input  logic [7:0]                  mram_mode_i, // 0 --> Write on MRAM, 1 --> trim CFG
   output logic [7:0]                  mram_mode_o,

   output logic                        mram_SHIFT_o,   // Configuration Shift
   output logic                        mram_SUPD_o,    // Configuration Register Update
   output logic                        mram_SDI_o,     // Configuration register Input
   output logic                        mram_SCLK_o,    // Configuration Register Clock
   input  logic                        mram_SDO_i,     // Configuration Register Output Configuration

   input  logic                        NVR_i,
   input  logic                        TMEN_i,
   input  logic                        AREF_i,

   output logic                        mram_NVR_o,
   output logic                        mram_TMEN_o,
   output logic                        mram_AREF_o
);



   enum logic [4:0] { IDLE, GOT_1, DISPATCH, WAIT_1, DISPATCH_DONE, INIT_SHIFT,  STROBE_HI, STROBE_LOW, GOING_SUPD, DO_SUPD, TRIMG_CFG_DONE , PERFORM_ERASE , ERASE_DONE, REF_LINE_P0, REF_LINE_P1, REF_LINE_AP0, REF_LINE_AP1, REF_LINE_DONE } NS, CS;

    localparam CMD_TRIM_CFG           = 8'b0000_0001;
    localparam CMD_NORMAL_TX          = 8'b0000_0010;
    localparam CMD_ERASE_CHIP         = 8'b0000_0100;
    localparam CMD_ERASE_SECT         = 8'b0000_1000;
    localparam CMD_ERASE_WORD         = 8'b0001_0000;
    localparam CMD_PWDN               = 8'b0010_0000;
    localparam CMD_READ_RX            = 8'b0100_0000;
    localparam CMD_REF_LINE_P         = 8'b1000_0000;
    localparam CMD_REF_LINE_AP        = 8'b1100_0000;


   logic [15:0]                 data_tx_addr_int;
   logic [TRANS_SIZE-1:0]       data_tx_size_int;

   logic valid_cmd;
   logic save_addr, update_addr;
   logic clear_1, clear_2;
   logic update_1, update_2, shift_1;
   logic mram_SCLK_int;

   logic [2:0]                  counter_CS, counter_NS;
   logic [4:0]                  shift_cnt_CS, shift_cnt_NS;
   logic [11:0]                 word_cnt_CS, word_cnt_NS;

   logic [1:0][31:0]            data_tx_wdata_Q;
   logic [19:0]                 data_tx_addr_Q;
   logic [TRANS_SIZE-1:0]       data_tx_size_Q;
   logic [7:0]                  mram_mode_Q;

   logic                        save_erase_info, update_erase_info;
   logic [15:0]                 erase_addr_Q;
   logic [9:0]                  erase_size_Q;

   logic clear_mram_signal, save_mram_signal;



  assign {data_tx_size_int,data_tx_addr_int} = {data_tx_size_i,data_tx_addr_i};
  assign valid_cmd = push_cmd_req_i;
  assign push_cmd_gnt_o = save_addr;

  assign mram_mode_o = mram_mode_Q;
/*
   generic_fifo
   #(
      .DATA_WIDTH ( TRANS_SIZE+19 ),
      .DATA_DEPTH ( 4             )
   )
   tx_cmd_fifo
   (
      .clk           ( clk                                 ),
      .rst_n         ( rst_n                               ),
      .data_i        ( {data_tx_size_i,data_tx_addr_i}     ),
      .valid_i       ( push_cmd_req_i                      ),
      .grant_o       ( push_cmd_gnt_o                      ),
      .data_o        ( {data_tx_size_int,data_tx_addr_int} ),
      .valid_o       ( valid_cmd                           ),
      .grant_i       ( save_addr                           ),
      .test_mode_i   ( 1'b0                                )
   );
*/

   assign pending_o =  (valid_cmd== 1'b1) || (CS != IDLE);

   always_ff @(posedge clk or negedge rst_n) 
   begin : proc_FSM_Seq
      if(~rst_n)
      begin
         CS <= IDLE;
         counter_CS      <= '0;
         shift_cnt_CS    <= '0;
         word_cnt_CS     <= '0;
         mram_SCLK_o     <= '0;

         data_tx_wdata_Q <= '0;
         data_tx_addr_Q  <= '0;
         data_tx_size_Q  <= '0;

         erase_addr_Q    <= '0;
         erase_size_Q    <= '0;

         mram_mode_Q     <= '0;
            
         mram_AREF_o <= 1'b0;
         mram_TMEN_o <= 1'b0;
         mram_NVR_o  <= 1'b0;

      end
      else
      begin
         CS <= NS;
         counter_CS     <= counter_NS;
         shift_cnt_CS   <= shift_cnt_NS ;
         word_cnt_CS    <= word_cnt_NS  ;

         mram_SCLK_o    <= mram_SCLK_int;


         if(clear_mram_signal)
         begin
            mram_AREF_o <= '0;
            mram_TMEN_o <= '0;
            mram_NVR_o  <= '0;
         end
         else
         begin 
               if(save_mram_signal)
               begin
                  mram_AREF_o <= AREF_i;
                  mram_TMEN_o <= TMEN_i;
                  mram_NVR_o  <= NVR_i;
               end
         end


         if(save_addr)
            mram_mode_Q    <= mram_mode_i;
         else
            if(CS == IDLE)
                  mram_mode_Q <= '0;

         if(save_erase_info)
         begin
            erase_addr_Q   <= erase_addr_i;
            erase_size_Q   <= erase_size_i;
         end
         else if(update_erase_info)
              begin 
                 erase_addr_Q   <= (mram_mode_Q == CMD_ERASE_WORD ) ? erase_addr_Q+1 : {erase_addr_Q[15:8]+1, 8'b0000_0000 };
                 erase_size_Q   <=  erase_size_Q-1;
              end




         if(clear_1)
            data_tx_wdata_Q[0] <= '0;
         else if(update_1)
               data_tx_wdata_Q[0] <= data_tx_wdata_i;
              else if ( shift_1 )
                   begin
                     data_tx_wdata_Q[0][30:0] <= data_tx_wdata_Q[0][31:1];
                     data_tx_wdata_Q[0][31]   <= 1'bx;
                   end

         if(clear_2)
            data_tx_wdata_Q[1] <= '0;
         else if(update_2)
               data_tx_wdata_Q[1] <= data_tx_wdata_i;

         if(save_addr)
         begin
            data_tx_addr_Q  <= {data_tx_addr_int,1'b0};
            data_tx_size_Q  <= data_tx_size_int-4;
         end
         else
         begin
            if(update_addr)
            begin
               data_tx_addr_Q  <= data_tx_addr_Q+1;
               data_tx_size_Q  <= data_tx_size_Q-4;
            end
         end
      end
   end



   always_comb
   begin : proc_FSM_comb
      //default
      data_tx_addr_o  = data_tx_addr_Q[19:1];
      save_addr       = 1'b0;
      update_addr     = 1'b0;
      update_1        = 1'b0;
      update_2        = 1'b0;
      clear_2         = 1'b0;
      clear_1         = 1'b0;
      data_tx_req_o   = 1'b0;

      data_tx_ready_o = 1'b0;

      shift_1         = 1'b0;
      mram_SHIFT_o    = 1'b0;
      mram_SUPD_o     = 1'b0;
      mram_SDI_o      = 1'b0;
      mram_SCLK_int   = 1'b0;
      counter_NS      = counter_CS;
      word_cnt_NS     = word_cnt_CS;
      shift_cnt_NS    = shift_cnt_CS;
      trim_cfg_done_o = 1'b0;
      erase_pending_o = 1'b0;
      erase_done_o    = 1'b0;
      data_tx_eot_o   = 1'b0;
      save_erase_info = 1'b0;
      update_erase_info = 1'b0;

      data_tx_wdata_o  = {14'h000, ~data_tx_wdata_Q};

      ref_line_pending_o = '0;
      ref_line_done_o    = '0;

      save_mram_signal  = 1'b0;
      clear_mram_signal = 1'b0;

      tx_done_o         = 1'b0;

      case (CS)
         IDLE:
         begin

            if(push_cmd_req_i)
            begin

                  case(mram_mode_i)

                  CMD_TRIM_CFG:
                  begin
                     data_tx_ready_o  = 1'b1;
                     save_addr        = data_tx_valid_i;
                     save_mram_signal = data_tx_valid_i;

                     if(data_tx_valid_i)
                     begin
                        NS = INIT_SHIFT;
                        update_1     = 1'b1;
                        shift_cnt_NS = 31;
                        word_cnt_NS  = NUM_TRIM_BYTE/4-1;
                     end
                     else
                     begin
                        NS = IDLE;
                     end

                  end

                  CMD_NORMAL_TX:
                  begin
                           data_tx_ready_o = 1'b1;
                           save_addr = data_tx_valid_i;

                           update_1         = data_tx_valid_i;
                           data_tx_addr_o   = data_tx_addr_int;
                           save_mram_signal = data_tx_valid_i;
          

                           if(data_tx_valid_i)
                           begin
                              if( data_tx_size_int <= 4 )
                              begin
                                 NS = DISPATCH_DONE;
                                 clear_2 = 1'b1;
                              end
                              else
                              begin
                                 NS = GOT_1;
                              end
                           end
                           else
                           begin
                              NS = IDLE;
                           end

                  end

                  CMD_ERASE_SECT, CMD_ERASE_CHIP, CMD_ERASE_WORD:
                  begin
                     save_addr        = 1'b1;
                     NS               = PERFORM_ERASE;
                     save_erase_info  = 1'b1;
                     save_mram_signal = 1'b1;
                  end

                  CMD_REF_LINE_P:
                  begin
                     NS               = REF_LINE_P0;
                     word_cnt_NS      = '0;
                     save_mram_signal = 1'b1;
                     save_addr        = 1'b1;
                  end

                  CMD_REF_LINE_AP:
                  begin
                     NS               = REF_LINE_AP0;
                     word_cnt_NS      = '0;
                     save_mram_signal = 1'b1;
                     save_addr        = 1'b1;
                  end

                  default: begin
                     NS = IDLE;
                     save_addr       = 1'b1;
                  end

                  endcase
            end
            else
            begin
               NS = IDLE;
            end


         end







         REF_LINE_P0:
         begin
            ref_line_pending_o   = 1'b1;
            data_tx_wdata_o      = '1;
            data_tx_addr_o[15:7] = word_cnt_CS;
            data_tx_addr_o[6:0]  = 7'h00;
            data_tx_req_o        = 1'b1;

            if(data_tx_gnt_i)
            begin       
               NS = REF_LINE_P1;
            end
            else
            begin
               NS = REF_LINE_P0;
            end

         end



         REF_LINE_P1:
         begin
            ref_line_pending_o   = 1'b1;
            data_tx_wdata_o      = '1;
            data_tx_addr_o[15:7] = word_cnt_CS;
            data_tx_addr_o[6:0]  = 7'h60;
            data_tx_req_o        = 1'b1;
            data_tx_eot_o        = &word_cnt_CS;

            if(data_tx_gnt_i)
            begin
               word_cnt_NS = word_cnt_CS + 1'b1;
               if(word_cnt_CS == '1)
               begin
                  NS = REF_LINE_DONE;
               end
               else
               begin
                  NS = REF_LINE_P0;
               end
            end
            else
            begin
               NS = REF_LINE_P1;
            end
         end




         REF_LINE_AP0:
         begin
            ref_line_pending_o   = 1'b1;
            data_tx_wdata_o      = '1;
            data_tx_addr_o[15:7] = word_cnt_CS;
            data_tx_addr_o[6:0]  = 7'h20;
            data_tx_req_o        = 1'b1;

            if(data_tx_gnt_i)
            begin       
               NS = REF_LINE_AP1;
            end
            else
            begin
               NS = REF_LINE_AP0;
            end

         end



         REF_LINE_AP1:
         begin
            ref_line_pending_o   = 1'b1;
            data_tx_wdata_o      = '1;
            data_tx_addr_o[15:7] = word_cnt_CS;
            data_tx_addr_o[6:0]  = 7'h40;
            data_tx_req_o        = 1'b1;
            data_tx_eot_o        = &word_cnt_CS;

            if(data_tx_gnt_i)
            begin
               word_cnt_NS = word_cnt_CS + 1'b1;
               if(word_cnt_CS == '1)
               begin
                  NS = REF_LINE_DONE;
               end
               else
               begin
                  NS = REF_LINE_AP0;
               end
            end
            else
            begin
               NS = REF_LINE_AP1;
            end
         end


         REF_LINE_DONE:
         begin
            ref_line_done_o = 1'b1;
            NS = IDLE;
         end





         PERFORM_ERASE:
         begin
            erase_pending_o = 1'b1;
            
            data_tx_wdata_o = '1;
            data_tx_req_o   = 1'b1;
            data_tx_addr_o  = erase_addr_Q;

            update_erase_info = data_tx_gnt_i;

            if(data_tx_gnt_i)
            begin
               case(mram_mode_Q)
                  CMD_ERASE_CHIP:
                  begin
                     NS = ERASE_DONE;
                     data_tx_eot_o = 1'b1;
                  end

                  default:
                  begin
                        if(erase_size_Q > 0)
                        begin
                           NS = PERFORM_ERASE;
                        end
                        else
                        begin
                           NS = ERASE_DONE;
                           data_tx_eot_o = 1'b1;
                        end
                  end
               endcase // mram_mode_Q

            end
            else
            begin
               NS = PERFORM_ERASE;
            end

         end

         ERASE_DONE:
         begin
            erase_done_o = 1'b1;
            NS = IDLE;
         end





         GOT_1:
         begin
            update_2    = data_tx_valid_i;
            update_addr = data_tx_valid_i;

            data_tx_ready_o = 1'b1;

            if(data_tx_valid_i)
            begin
               if( data_tx_size_Q <= 4 )
               begin
                  NS = DISPATCH_DONE;
               end
               else
               begin
                  NS = DISPATCH;
               end
            end
            else
            begin
               NS = GOT_1;
            end
         end

         DISPATCH:
         begin
            data_tx_req_o = 1'b1;

            data_tx_ready_o = data_tx_gnt_i;

            if(data_tx_gnt_i)
            begin
                  update_1    = data_tx_valid_i;
                  update_addr = data_tx_valid_i;

                  if(data_tx_valid_i)
                  begin
                     if( data_tx_size_Q <= 4 )
                     begin
                        NS      = DISPATCH_DONE;
                        clear_2 = 1'b1;
                     end
                     else
                     begin
                        NS = GOT_1;
                     end
                  end
                  else
                  begin
                     NS = WAIT_1;
                  end
            end
            else
            begin
               NS = DISPATCH;
            end

         end


         WAIT_1:
         begin
                  update_1        = data_tx_valid_i;
                  update_addr     = data_tx_valid_i;
                  data_tx_ready_o = 1'b1;

                  if(data_tx_valid_i)
                  begin
                     if( data_tx_size_Q <= 4 )
                     begin
                        NS      = DISPATCH_DONE;
                        clear_2 = 1'b1;
                     end
                     else
                     begin
                        NS = GOT_1;
                     end
                  end
                  else
                  begin
                     NS = WAIT_1;
                  end   
         end


         DISPATCH_DONE:
         begin
            data_tx_eot_o  = 1'b1;

            data_tx_req_o = 1'b1;
            data_tx_ready_o = 1'b0;

            if(data_tx_gnt_i)
            begin
               NS = IDLE;
               tx_done_o       = 1'b1;
            end
            else
            begin
               NS = DISPATCH_DONE;
            end

         end




         INIT_SHIFT:
         begin
            data_tx_ready_o = 1'b0;
            mram_SHIFT_o    = 1'b1;
            mram_SDI_o      = data_tx_wdata_Q[0][0];
            mram_SCLK_int   = 1'b0;
            counter_NS      = '0;
            shift_1         = 1'b0;

            NS = STROBE_HI;
         end

         STROBE_HI:
         begin
            mram_SHIFT_o    = 1'b1;
            mram_SCLK_int   = 1'b1;
            counter_NS      = counter_CS + 1'b1;
            mram_SDI_o      = data_tx_wdata_Q[0][0];

            if(counter_CS < NUM_CYCLE_STROBE-1)
            begin
               NS = STROBE_HI;
            end
            else
            begin
               NS = STROBE_LOW;
               counter_NS      = '0;
            end
         end

         STROBE_LOW:
         begin
            mram_SHIFT_o    = 1'b1;
            mram_SCLK_int   = 1'b0;
            mram_SDI_o      = data_tx_wdata_Q[0][0];
            counter_NS      = counter_CS + 1'b1;

            if(counter_CS < NUM_CYCLE_STROBE-1)
            begin
               NS = STROBE_LOW;
            end
            else
            begin
               
                  if(word_cnt_CS == 0)
                  begin
                     counter_NS   = '0;

                     if(shift_cnt_CS == 4) // Check if we finished the 32 bit in the word
                     begin
                        NS =  GOING_SUPD;
                     end
                     else
                     begin
                        NS = STROBE_HI;
                        shift_1      = 1'b1;
                        shift_cnt_NS = shift_cnt_CS - 1'b1;
                     end

                  end
                  else
                  begin

                     if(shift_cnt_CS == 0) // Check if we finished the 32 bit in the word
                     begin
                           word_cnt_NS = word_cnt_CS -1;
                           data_tx_ready_o = 1'b1;

                           if(data_tx_valid_i)
                           begin                        
                              update_1 = 1'b1;
                              shift_cnt_NS = 31;
                              counter_NS   = '0;
                              NS = STROBE_HI;
                           end
                           else
                           begin
                              NS = STROBE_LOW;
                           end
                     end
                     else
                     begin
                        NS = STROBE_HI;
                        counter_NS   = '0;
                        shift_1      = 1'b1;
                        shift_cnt_NS = shift_cnt_CS - 1'b1;
                     end
                     
                  end




            end
         end


         GOING_SUPD:
         begin

            if(counter_CS <= NUM_CYCLE_GO_SUP)
            begin
               NS = GOING_SUPD;
               counter_NS = counter_CS + 1'b1;
            end
            else
            begin
               NS = DO_SUPD;
               counter_NS = '0;
            end
         end


         DO_SUPD:
         begin
            mram_SUPD_o     = 1'b1;

            if(counter_CS <= NUM_CYCLE_GO_SUP )
            begin
               NS = DO_SUPD;
               counter_NS = counter_CS + 1'b1;
            end
            else
            begin
               NS = TRIMG_CFG_DONE;
               counter_NS = '0;
            end
         end


         TRIMG_CFG_DONE:
         begin
            trim_cfg_done_o = 1'b1;
            NS = IDLE;
         end



         default :
         begin
            NS = IDLE;
         end

      endcase
   end


endmodule // size_conv_TX_64_to_32


