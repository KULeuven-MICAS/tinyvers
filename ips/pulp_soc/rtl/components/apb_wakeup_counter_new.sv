`define USE_MRAM

module apb_wakeup_counter
  (
   input logic 	       clk_i,
   input logic 	       rstn_i,
   input logic [31:0]  reg_scratch_i,
   input logic 	       reg_pmu_en_i,
   input logic [31:0]  reg_pmu_mode_i,
   input logic 	       wen_i,
   output logic [31:0] reg_scratch_o,
   output logic [31:0] reg_pmu_mode_o,
   output logic        rstn_pg,
   output logic        clk_en_system,
   output logic        pg_logic_rstn_o,
   output logic        pg_udma_rstn_o,
`ifdef USE_MRAM
   output logic        pg_ram_rom_rstn_o,
   output logic        VDDA_out,
   output logic        VDD_out,
   output logic        VREF_out,
   output logic        PORb,
   output logic        RETb,
   output logic        RSTb,
   output logic        TRIM,
   output logic        DPD,
   output logic        CEb_HIGH
`else
   output logic        pg_ram_rom_rstn_o
`endif
   );

   enum 	       {
			FSM_POWER_ON,
			FSM_POWER_IO,
			FSM_POWER_MRAM,
			FSM_POWER_MEM,
			FSM_POWER_UDMA,
			FSM_POWER_LOGIC,
			FSM_POWER_OFF
			} curr_state, next_state;

   logic [5:0] 	       loopcount;
   logic 	       one_msec, s_power;
   logic [31:0]        msec_count;
   logic [31:0]        reg_scratch_reg;
   logic [31:0]        reg_pmu_mode_reg;
   logic [2:0]         enable_PD_send_LOGIC;
   logic [2:0]         enable_PD_send_L2;
   logic [2:0]         enable_PD_send_L1;
   logic [2:0]         enable_PD_send_IO;
   logic [2:0]         enable_PD_send_UDMA;
   logic [2:0]         enable_PD_ack_LOGIC;
   logic [2:0]         enable_PD_ack_L2;
   logic [2:0]         enable_PD_ack_L1;
   logic [2:0]         enable_PD_ack_IO;
   logic [2:0]         enable_PD_ack_UDMA;
   logic 	       s_power_logic, s_power_mem, s_power_io, s_power_udma, s_power_mram;
   logic 	       done_logic, done_mem, done_io, done_udma, done_mram, done_l1;
   // sleep ack signals
   wire 	       sleep_ack_io, sleep_ack_ram_rom, sleep_ack_logic, sleep_ack_udma;

   logic 	       is_sleeping;
   logic 	       wakeup_alarm;

   // PMU Mode reg mapping
   logic 	       s_sleep_udma_en;
   logic 	       s_sleep_l2_en;
   logic 	       s_sleep_mram_en;
   logic 	       s_sleep_io_en;
   logic 	       s_sleep_operation;
   logic               s_deep_sleep;
   logic 	       s_pd_mram;
   logic 	       s_pd_l2;

   assign rstn_pg = !is_sleeping;
   // Mode register mapping
   assign s_sleep_operation = reg_pmu_mode_reg[0];
   assign s_pd_io = reg_pmu_mode_reg[1];
   assign s_pd_l2 = reg_pmu_mode_reg[2];
   assign s_pd_mram = reg_pmu_mode_reg[3];
   // Decoding of mode register
   assign s_sleep_udma_en = (s_sleep_l2_en || s_sleep_mram_en) && (!s_deep_sleep);
   assign s_sleep_l2_en   = (s_sleep_operation && (!s_pd_l2)) && (!s_deep_sleep);
   assign s_sleep_mram_en = (s_sleep_operation && (!s_pd_mram)) && (!s_deep_sleep);
   assign s_sleep_io_en   = (s_sleep_operation && (!s_pd_io)) && (!s_deep_sleep);
   //assign sleep_ack_io = 1'bz;
   //assign sleep_ack_ram_rom = 1'bz;
   //assign sleep_ack_logic = 1'bz;
   //assign sleep_ack_udma = 1'bz;

/*
   assign enable_PD_ack_LOGIC = enable_PD_send_LOGIC;
   assign enable_PD_ack_L2 = enable_PD_send_L2;
   assign enable_PD_ack_L1 = enable_PD_send_L1;
   assign enable_PD_ack_IO = enable_PD_send_IO;
   assign enable_PD_ack_UDMA = enable_PD_send_UDMA;
*/
   assign done_io = 1;

   always_ff @(posedge clk_i or negedge rstn_i)
     begin : main_fsm_seq
        if(~rstn_i) begin
           curr_state <= FSM_POWER_OFF;
        end
        else begin
           curr_state <= next_state;
        end
     end // block: main_fsm_seq

   always_comb
     begin: power_down_fsm
	next_state = FSM_POWER_ON;
	case(curr_state)
	  FSM_POWER_OFF: begin
             if(~s_power) begin next_state = curr_state; end
             else begin next_state = FSM_POWER_IO; end
	  end
	  FSM_POWER_IO: begin
             if(~done_io) begin next_state = curr_state; end
             else begin
`ifdef USE_MRAM
             next_state = FSM_POWER_MRAM;
`else
             next_state = FSM_POWER_MEM;
`endif
             end
	  end
	  FSM_POWER_MRAM: begin
             if(~done_mram) begin next_state = curr_state; end
             else begin next_state = FSM_POWER_MEM; end
	  end
	  FSM_POWER_MEM: begin
             if(~done_mem) begin next_state = curr_state; end
             else begin next_state = FSM_POWER_UDMA; end
	  end
	  FSM_POWER_UDMA: begin
             if(~done_udma) begin next_state = curr_state; end
             else begin next_state = FSM_POWER_LOGIC; end
	  end
	  FSM_POWER_LOGIC: begin
             if(~done_logic && ~done_l1) begin next_state = curr_state; end
             else begin next_state = FSM_POWER_ON; end
	  end
	  FSM_POWER_ON: begin
             if(s_power) begin next_state = curr_state; end
             else begin next_state = FSM_POWER_OFF; end
	  end
	  default: begin
             next_state = FSM_POWER_ON;
	  end
	endcase
     end

   // signals for power_down_fsm
   always_comb
     begin
	s_power_io = 1'b0;
	s_power_mram = 1'b0;
	s_power_mem = 1'b0;
	s_power_udma = 1'b0;
	s_power_logic = 1'b0;
	case(curr_state)
	  FSM_POWER_ON: begin
             s_power_io = 1'b1;
             s_power_mram = !s_pd_mram;
             s_power_mem = 1'b1;
             s_power_udma = 1'b1;
             s_power_logic = 1'b1;
	  end
	  FSM_POWER_IO: begin
             s_power_io = 1'b1;
             s_power_mram = s_sleep_mram_en;
             s_power_mem = s_sleep_l2_en;
             s_power_udma = s_sleep_udma_en;
             s_power_logic = 1'b0;
	  end
`ifdef USE_MRAM
	  FSM_POWER_MRAM: begin
             s_power_io = 1'b1;
             s_power_mram = 1'b1;
             s_power_mem = s_sleep_l2_en;
             s_power_udma = s_sleep_udma_en;
             s_power_logic = 1'b0;
	  end
`endif
	  FSM_POWER_MEM: begin
             s_power_io = 1'b1;
             s_power_mram = 1'b1;
             s_power_mem = 1'b1;
             s_power_udma = s_sleep_udma_en;
             s_power_logic = 1'b0;
	  end
	  FSM_POWER_UDMA: begin
             s_power_io = 1'b1;
             s_power_mram = 1'b1;
             s_power_mem = 1'b1;
             s_power_udma = 1'b1;
             s_power_logic = 1'b0;
	  end
	  FSM_POWER_LOGIC: begin
             s_power_io = 1'b1;
             s_power_mram = 1'b1;
             s_power_mem = 1'b1;
             s_power_udma = 1'b1;
             s_power_logic = 1'b1;
	  end
	  FSM_POWER_OFF: begin
             s_power_io	   = s_sleep_io_en;
             s_power_mram  = s_sleep_mram_en;
             s_power_mem   = s_sleep_l2_en;
             s_power_udma  = s_sleep_udma_en;
             s_power_logic = 1'b0;
	  end
	  default: begin
             s_power_io = 1'b0;
             s_power_mram = 1'b0;
             s_power_mem = 1'b0;
             s_power_udma = 1'b0;
             s_power_logic = 1'b0;
	  end
	endcase
     end

   APC_wrapper PD_LOGIC
     (
      .clk            ( clk_i           ),
      .rst            ( rstn_i          ),
      .power          ( s_power_logic   ),
      .enable_PD_send ( enable_PD_send_LOGIC     ),
      .enable_PD_ack  ( enable_PD_ack_LOGIC     ),
      .reset          ( pg_logic_rstn_o ),
      .isolate        (                 ),
      .clk_en         (                 ),
      .done           ( done_logic      )
      );

   DOMAIN_LOGIC_ring i_logic_ring
     (
      .VDD    (                      ),
      .VSS    (                      ),
      .VSS_SW (                      ),
      .in     ( enable_PD_send_LOGIC ),
      .out    ( enable_PD_ack_LOGIC  )
     );

   APC_wrapper PD_L2
     (
      .clk            ( clk_i           ),
      .rst            ( rstn_i          ),
      .power          ( s_power_mem     ),
      .enable_PD_send ( enable_PD_send_L2      ),
      .enable_PD_ack  ( enable_PD_ack_L2       ),
      .reset          (                 ),
      .isolate        (                 ),
      .clk_en         ( clk_en_system   ),
      .done           ( done_mem        )
      );

   DOMAIN_L2_ring i_l2_ring
     (
      .VDD    (                      ),
      .VSS    (                      ),
      .VSS_SW (                      ),
      .in     ( enable_PD_send_L2    ),
      .out    ( enable_PD_ack_L2     )
     );

   APC_wrapper PD_L1
     (
      .clk            ( clk_i           ),
      .rst            ( rstn_i          ),
      .power          ( s_power_logic     ),
      .enable_PD_send ( enable_PD_send_L1      ),
      .enable_PD_ack  ( enable_PD_ack_L1       ),
      .reset          (                 ),
      .isolate        (                 ),
      .clk_en         (                 ),
      .done           ( done_l1        )
      );

   DOMAIN_L1_ring i_l1_ring
     (
      .VDD    (                      ),
      .VSS    (                      ),
      .VSS_SW (                      ),
      .in     ( enable_PD_send_L1    ),
      .out    ( enable_PD_ack_L1     )
     );

/*
   APC_wrapper PD_IO
     (
      .clk            ( clk_i           ),
      .rst            ( rstn_i          ),
      .power          ( s_power_io         ),
      .enable_PD_send ( enable_PD_send_IO          ),
      .enable_PD_ack  ( enable_PD_ack_IO           ),
      .reset          (                 ),
      .isolate        (                 ),
      .clk_en         (                 ),
      .done           ( done_io         )
      );
*/

   APC_wrapper PD_UDMA
     (
      .clk            ( clk_i           ),
      .rst            ( rstn_i          ),
      .power          ( s_power_udma         ),
      .enable_PD_send ( enable_PD_send_UDMA          ),
      .enable_PD_ack  ( enable_PD_ack_UDMA           ),
      .reset          ( pg_udma_rstn_o  ),
      .isolate        (                 ),
      .clk_en         (                 ),
      .done           ( done_udma       )
      );

   DOMAIN_DMA_ring i_dma_ring
     (
      .VDD    (                      ),
      .VSS    (                      ),
      .VSS_SW (                      ),
      .in     ( enable_PD_send_UDMA  ),
      .out    ( enable_PD_ack_UDMA   )
     );

`ifdef USE_MRAM

   PowerGateFSM_MRAM PD_MRAM
     (
      .clk            ( clk_i           ),
      .rst            ( rstn_i          ),
      .power          ( s_power_mram         ),
      .VDDA_out       ( VDDA_out        ),
      .VDD_out        ( VDD_out         ),
      .VREF_out       ( VREF_out        ),
      .PORb           ( PORb            ),
      .RETb           ( RETb            ),
      .RSTb           ( RSTb            ),
      .TRIM           ( TRIM            ),
      .DPD            ( DPD             ),
      .CEb_HIGH       ( CEb_HIGH        ),
      .isolate        (                 ),
      .done           ( done_mram       )
      );

`endif


   assign one_msec = loopcount[5];
   assign s_power = !is_sleeping;

   // Register which tells we are in running state
   always @ (posedge clk_i, negedge rstn_i ) begin
      if (~rstn_i) begin
	 // Wakeup system on reset
	 is_sleeping <= '0;
      end else begin
	 // By default, keep current state
	 is_sleeping <= is_sleeping;
	 // Check state transition
	 case (is_sleeping)
	   1'b0: begin
	      // wen_i is synchronized to ref_clk
	      // so no timing violations here.
	      is_sleeping <= wen_i && reg_pmu_en_i;
	   end
	   1'b1: begin
	      is_sleeping <= !wakeup_alarm;
	   end
	 endcase // case (is_sleeping)
      end // else: !if(~rstn_i)
   end // always @ (posedge clk_i, negedge rstn_i )

   // Save values from APB bus
   // wen_i is already synchronized to clk_i
   // in apb_wakeup
   always @ (posedge clk_i, negedge rstn_i) begin
      if(~rstn_i) begin
	 reg_scratch_reg <= '0;
	 reg_pmu_mode_reg <= '0;
      end else begin
	 if(wen_i == 1'b1) begin
	    reg_scratch_reg <= reg_scratch_i;
	    reg_pmu_mode_reg <= reg_pmu_mode_i;
	 end
      end
   end // always @ (posedge clk_i, negedge rstn_i)
   assign reg_scratch_o = reg_scratch_reg;
   assign reg_pmu_mode_o = reg_pmu_mode_reg;


   // Loop counter
   // Counts on 32.768 kHz clock
   always_ff @(posedge clk_i, negedge rstn_i)
     begin
	if (~rstn_i) begin
	   loopcount <= '0;
	end else begin
	   if (~is_sleeping || one_msec) begin
              loopcount <= '0;
	   end else begin
              if (is_sleeping) begin
		 loopcount <= loopcount + 1;
              end
	   end
	end // else: !if(~rstn_i)
     end // always_ff @

   // Mili second counter
   always_ff @(posedge clk_i, negedge rstn_i)
     begin
	if (~rstn_i) begin
	   msec_count <= '0;
	end else begin
	   if (is_sleeping) begin
	      if (one_msec) begin
		 msec_count <= msec_count + 1;
	      end
	   end else begin
	      msec_count <= '0;
	   end
	end // else: !if(~rstn_i)
     end // always_ff @

   // wakeup alarm and deep sleep
   // Use >= instead of == for extra safety
   assign wakeup_alarm = (msec_count >= reg_scratch_reg);
   assign s_deep_sleep = (msec_count >= reg_pmu_mode_reg[31:4]);

endmodule
