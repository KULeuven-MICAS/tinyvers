// Copyright 2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

`define REG_SIGNATURE   8'h00  //BASEADDR+0x00 CONTAINS A READ-ONLY Signature
`define REG_SCRATCH     8'h04  //BASEADDR+0x04 R/W REGISTER AS SCRATCH
`define REG_PMU_TRIG    8'h08  //BASEADDR+0x08 TRIGGER WAKEUP COUNTER
`define REG_PMU_MODE    8'h0C  //BASEADDR+0x08 TRIGGER WAKEUP COUNTER

`define USE_MRAM

module apb_wakeup
  #(
    parameter APB_ADDR_WIDTH = 12  // APB slaves are 4KB by default
    )
   (
    input logic 		     HCLK,
    input logic                      clk_soc_ext_i,
    // step and hold
    input logic                      hold_wu,
    input logic                      step_wu,
    // manual scan chain
    input logic                      wu_bypass_en,
    input logic                      wu_bypass_data_in,
    input logic                      wu_bypass_shift,
    input logic                      wu_bypass_mux,
    output logic                     wu_bypass_data_out,
    // external power control to LLFSM
    input logic                      ext_pg_logic,
    input logic                      ext_pg_l2,
    input logic                      ext_pg_l2_udma,
    input logic                      ext_pg_l1,
    input logic                      ext_pg_udma,
    input logic                      ext_pg_mram,
    input logic 		     HRESETn,
    input logic [APB_ADDR_WIDTH-1:0] PADDR,
    input logic [31:0] 		     PWDATA,
    input logic 		     PWRITE,
    input logic 		     PSEL,
    input logic 		     PENABLE,
    output logic [31:0] 	     PRDATA,
    output logic 		     PREADY,
    output logic 		     PSLVERR,
    input logic 		     ref_clk_i,
    input logic 		     rstn_i,
    output logic                     clk_en_system,
    output logic 		     pg_logic_rstn_o,
    output logic 		     pg_udma_rstn_o,
`ifdef USE_MRAM
    output logic 		     pg_ram_rom_rstn_o,
    output logic 		     VDDA_out,
    output logic 		     VDD_out,
    output logic 		     VREF_out,
    output logic 		     PORb,
    output logic 		     RETb,
    output logic 		     RSTb,
    output logic 		     TRIM,
    output logic 		     DPD,
    output logic 		     CEb_HIGH
`else
    output logic                     pg_ram_rom_rstn_o
`endif
    );


   logic 			     s_apb_write;
   logic [3:0] 			     s_apb_addr;
   logic [31:0] 		     reg_signature;
   logic [31:0] 		     reg_scratch, reg_scratch_pmu;
   logic 			     reg_pmu_en;
   logic [31:0] 		     reg_pmu_mode, reg_pmu_mode_pmu;
   logic 			     r_restore;
   //logic [5:0] loopcount;
   //logic one_sec, power_on, s_power_o;
   //logic [31:0] sec_count;

   logic 			     s_pmu_ack;
   logic 			     s_pmu_ack_sync;
   logic 			     s_pmu_write_en;
   logic 			     s_pmu_req, r_pmu_req, s_fsm_pready;
   logic                             pg_logic_rstn_unsyncd, pg_udma_rstn_unsyncd, pg_ram_rom_rstn_unsyncd;
   enum 			     {
				      FSM_IDLE,
				      FSM_PMU_REQ,
				      FSM_PMU_ACK,
				      FSM_PREADY
				      }
				     curr_state, next_state;

   assign s_apb_write = PSEL && PENABLE && PWRITE;
   
   assign s_apb_addr = PADDR[3:0]; //check whether it is REG_SIGNATURE or REG_SCRATCH

   assign reg_signature = 24'hDA41DE;

   // write data
   // Each apb write transaction will copy all registers to PMU.
   // This requires that all the apb registers should be in sync with pmu registers
   // After waking from sleep, r_restore is set to 1 with the reset
   // and causes to load the apb regisers 
   
   always_ff @(posedge HCLK, negedge HRESETn)
     begin
	if(~HRESETn) begin
           reg_scratch  <= '0;
           reg_pmu_en   <= 1'b0;
           reg_pmu_mode <= '0;
	   r_restore <= 1'b1;
	end
	else begin
	   if (r_restore) begin
	      r_restore <= 1'b0;
	      // Do not restore TRIG reg.
	      // This could cause the system to go to a sleep mode
	      // when writing to a APB register other than TRIG
	      reg_scratch <= reg_scratch_pmu;
	      reg_pmu_mode <= reg_pmu_mode_pmu;
	   end else if (s_apb_write) begin
	      case (s_apb_addr) 
		`REG_SCRATCH: begin
		   reg_scratch <= PWDATA;		  
		end
		`REG_PMU_TRIG: begin
		   reg_pmu_en <= PWDATA;		  
		end
		`REG_PMU_MODE: begin
		   reg_pmu_mode <= PWDATA;	  
		end
	      endcase // case (s_apb_addr)
	   end // if (s_apb_write)
	end // else: !if(~HRESETn)       
     end // always_ff @
   

   // read data
   always_comb
     begin
        PRDATA = '0;
        case (s_apb_addr)
          `REG_SIGNATURE : begin
             PRDATA = reg_signature;
          end
          `REG_SCRATCH : begin
             PRDATA = reg_scratch;
          end
          `REG_PMU_TRIG : begin
             PRDATA = reg_pmu_en;
          end
          `REG_PMU_MODE : begin
             PRDATA = reg_pmu_mode;
          end
          default: begin
             PRDATA = '0;
          end
        endcase
     end

   assign PREADY     = s_fsm_pready;
   assign PSLVERR    = 1'b0;
   

   // State machine to control PREADY	      
   always @ (posedge HCLK, negedge HRESETn) begin
      if(~HRESETn) begin
	 curr_state <= FSM_IDLE;
      end else begin
	 curr_state <= next_state;
	 r_pmu_req <= s_pmu_req;
      end     
   end
   
   always @ (*) begin
      next_state = curr_state;
      s_pmu_req = 0;
      s_fsm_pready = 0;
      case (curr_state) 
	FSM_IDLE: begin
	   if(s_apb_write) begin
	      // A write takes longer as it needs to propagate to the ref_clk_domain
	      next_state = FSM_PMU_REQ;
	      s_fsm_pready = 0;
	   end else begin
	      // A read can be completed in one cycle
	      s_fsm_pready = 1;
	   end
	end
	FSM_PMU_REQ: begin
	   // Send a write request to the PMU
	   // the signal is registerd to prevent glitches
	   // when passing it through the synchronizer
	   if (s_pmu_ack_sync) begin
	      // Received acknowledge of PMU
	      next_state = FSM_PMU_ACK;
	   end else begin
	      // Waiting for PMU to acknowledge the write
	      s_pmu_req = 1;
	      next_state = FSM_PMU_REQ;
	   end
	end
	FSM_PMU_ACK: begin
	   // Wait until the acknowledge signal
	   // disappears after releasing the req
	   if (s_pmu_ack_sync) begin
	      next_state = FSM_PMU_ACK;
	   end else begin
	      next_state = FSM_PREADY;
	   end
	end
	FSM_PREADY: begin
	   // Acknowledge disappeared
	   // Complete the transaction with PREADY
	   s_fsm_pready = 1'b1;
	   next_state = FSM_IDLE;
	end
      endcase	  
   end
   // End of state machine for controlling pready
   
   // Synchronize write transaction towards pmu
   // This synchronizer is put in logic domain
   // So it doesn't need to run when in a deep sleep mode
   pulp_sync_wedge #(2) i_pmu_write_sync
     (// Outputs
      .r_edge_o				(s_pmu_write_en),
      .f_edge_o				(),
      .serial_o				(s_pmu_ack),
      // Inputs
      .clk_i				(ref_clk_i),
      .rstn_i				(HRESETn),
      .en_i				(1'b1),
      .serial_i				(s_pmu_req));

   // Sync the acknowledge back to system clock domain
   // for use in the FSM
   pulp_sync_wedge #(2) i_pmu_ack_sync
     (// Outputs
      .r_edge_o				(),
      .f_edge_o				(),
      .serial_o				(s_pmu_ack_sync),
      // Inputs
      .clk_i				(HCLK),
      .rstn_i				(HRESETn),
      .en_i				(1'b1),
      .serial_i				(s_pmu_ack));

   // Sync the pg_logic_rstn back to system clock domain
   pulp_sync_n #(2) i_pg_logic_rstn_sync
     (// Outputs
      .serial_o                         (pg_logic_rstn_o),
      // Inputs
      .clk_i                            (clk_soc_ext_i),
      .serial_i                         (pg_logic_rstn_unsyncd));
   
   // Sync the pg_udma_rstn back to system clock domain
   pulp_sync_n #(2) i_pg_udma_rstn_sync
     (// Outputs
      .serial_o                         (pg_udma_rstn_o),
      // Inputs
      .clk_i                            (clk_soc_ext_i),
      .serial_i                         (pg_udma_rstn_unsyncd));

   // Sync the pg_ram_rom_rstn back to system clock domain
   pulp_sync_n #(2) i_pg_ram_rom_rstn_sync
     (// Outputs
      .serial_o                         (pg_ram_rom_rstn_o),
      // Inputs
      .clk_i                            (clk_soc_ext_i),
      .serial_i                         (pg_ram_rom_rstn_unsyncd));
 
 
   power_gating_shift i_power_gating_shift (
     .sleep_send_LOGIC(sleep_send_LOGIC),
     .sleep_send_L2(sleep_send_L2),
     .sleep_send_L2_UDMA(sleep_send_L2_UDMA),
     .sleep_send_L1(sleep_send_L1),
     .sleep_send_UDMA(sleep_send_UDMA),
     .sleep_ack_LOGIC(sleep_ack_LOGIC),
     .sleep_ack_L2(sleep_ack_L2),
     .sleep_ack_L2_UDMA(sleep_ack_L2_UDMA),
     .sleep_ack_L1(sleep_ack_L1),
     .sleep_ack_UDMA(sleep_ack_UDMA)
/*
     .sleep_send_LOGIC_shift(sleep_send_LOGIC_shift),
     .sleep_send_L2_shift(sleep_send_L2_shift),
     .sleep_send_L2_UDMA_shift(sleep_send_L2_UDMA_shift),
     .sleep_send_L1_shift(sleep_send_L1_shift),
     .sleep_send_UDMA_shift(sleep_send_UDMA_shift),
     .sleep_ack_LOGIC_shift(sleep_ack_LOGIC_shift),
     .sleep_ack_L2_shift(sleep_ack_L2_shift),
     .sleep_ack_L2_UDMA_shift(sleep_ack_L2_UDMA_shift),
     .sleep_ack_L1_shift(sleep_ack_L1_shift),
     .sleep_ack_UDMA_shift(sleep_ack_UDMA_shift)
*/
   );
    
   /* Wake up counter */

   apb_wakeup_counter i_apb_wakeup_counter 
     (
      .clk_i(ref_clk_i),
      .rstn_i(rstn_i),
      // step and hold
      .hold_wu(hold_wu),
      .step_wu(step_wu),
      // manual scan chain
      .wu_bypass_en(wu_bypass_en),
      .wu_bypass_data_in(wu_bypass_data_in),
      .wu_bypass_shift(wu_bypass_shift),
      .wu_bypass_mux(wu_bypass_mux),
      .wu_bypass_data_out(wu_bypass_data_out),
      // external power control to LLFSM
      .ext_pg_logic(ext_pg_logic),
      .ext_pg_l2(ext_pg_l2),
      .ext_pg_l2_udma(ext_pg_l2_udma),
      .ext_pg_l1(ext_pg_l1),
      .ext_pg_udma(ext_pg_udma),
      .ext_pg_mram(ext_pg_mram),

      .sleep_send_LOGIC(sleep_send_LOGIC),
      .sleep_send_L2(sleep_send_L2),
      .sleep_send_L2_UDMA(sleep_send_L2_UDMA),
      .sleep_send_L1(sleep_send_L1),
      .sleep_send_UDMA(sleep_send_UDMA),
      .sleep_ack_LOGIC(sleep_ack_LOGIC),
      .sleep_ack_L2(sleep_ack_L2),
      .sleep_ack_L2_UDMA(sleep_ack_L2_UDMA),
      .sleep_ack_L1(sleep_ack_L1),
      .sleep_ack_UDMA(sleep_ack_UDMA),

      //others
      .reg_scratch_i(reg_scratch),
      .reg_pmu_en_i(reg_pmu_en),
      .reg_pmu_mode_i(reg_pmu_mode),
      .wen_i(s_pmu_write_en),
      .reg_scratch_o(reg_scratch_pmu),
      .reg_pmu_mode_o(reg_pmu_mode_pmu),
      .rstn_pg(rstn_pg),
      .clk_en_system(clk_en_system),
      .pg_logic_rstn_o ( pg_logic_rstn_unsyncd     ),
      .pg_udma_rstn_o  ( pg_udma_rstn_unsyncd      ),
`ifdef USE_MRAM
      .pg_ram_rom_rstn_o( pg_ram_rom_rstn_unsyncd  ),
      .VDDA_out   ( VDDA_out              ),
      .VDD_out    ( VDD_out               ),
      .VREF_out   ( VREF_out              ),
      .PORb       ( PORb                  ),
      .RETb       ( RETb                  ),
      .RSTb       ( RSTb                  ),
      .TRIM       ( TRIM                  ),
      .DPD        ( DPD                   ),
      .CEb_HIGH   ( CEb_HIGH              )
`else
      .pg_ram_rom_rstn_o( pg_ram_rom_rstn_unsyncd)
`endif
      );
      
endmodule
