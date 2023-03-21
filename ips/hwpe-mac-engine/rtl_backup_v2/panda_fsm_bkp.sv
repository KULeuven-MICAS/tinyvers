/*
 * TODO: Write logic for:
 - Controlling the *packet_counter_enable*
 - Write_enable of the accelerator memories
 - Ready signals of the incoming address and data streams
 * These signals should depend on the state of:
 - the current state fo the FSM
 - the current state of the valid signals of incoming data and address streams
 */

import mac_package::*;
import hwpe_ctrl_package::*;

module panda_fsm
  (
   // global signals
   input logic clk_i,
   input logic rst_ni,
   input logic test_mode_i,
   input logic clear_i,
   // ctrl & flags
  output ctrl_streamer_t      ctrl_streamer_o,
  input  flags_streamer_t     flags_streamer_i,
  output ctrl_engine_t        ctrl_engine_o,
  input  flags_engine_t       flags_engine_i,
  output ctrl_slave_t         ctrl_slave_o,
  input  flags_slave_t        flags_slave_i,
  input  ctrl_regfile_t       reg_file_i
);
   
   enum 		  {
			   FSM_IDLE,
			   FSM_LOAD_CONFIGURATION,
			   FSM_LOAD_INSTRUCTION,
                           FSM_LOAD_LUT,
                           FSM_LOAD_SPARSITY,
			   FSM_LOAD_WEIGHT_CONV,
			   FSM_LOAD_WEIGHT_FC,
			   FSM_LOAD_ACTIVATION,
			   FSM_ACCEL_RUN,
                           FSM_ACCEL_RUNNING,
                           FSM_TERMINATE
			   } curr_state, next_state;

   // Memory control signals
   logic 		  a_stream_valid;
   logic 		  b_stream_valid;
   logic                  c_stream_valid;
   // Internal FSM sigals
   //state_panda_fsm_t curr_state, next_state;
   // This checks if all streamers are ready to start.
   logic 		  streamers_ready;
   logic                  output_streamer_ready;
   assign streamers_ready = flags_streamer_i.a_source_flags.ready_start &&
			    flags_streamer_i.b_source_flags.ready_start;
   assign output_streamer_ready = flags_streamer_i.c_sink_flags.ready_start;

   logic 		  fsm_write_en;			  
   int unsigned 	  accelerator_memory_select;
   // Streamers control signals
   logic [31:0] 	  trans_size;
   logic [31:0] 	  base_address_address;
   logic [31:0] 	  out_trans_size;
   logic [31:0] 	  out_base_address_data;
   logic [31:0] 	  base_address_data;
   logic 		  fsm_stream_ready;
   logic                  fsm_output_stream_ready;
   // Packet counter signals
   logic [31:0] 	  packet_cnt, packet_cnt_next;
   logic 		  packet_counter_clear, packet_counter_clear_next;
   logic 		  packet_counter_enable;//, packet_counter_enable_next; //Converted to comb logic
   logic [31:0]           out_packet_cnt, out_packet_cnt_next;
   logic                  out_packet_counter_clear, out_packet_counter_clear_next;
   logic                  out_packet_counter_enable;
   logic                  tile_fsm_en;
   logic [4:0]            tiling_en;
   logic [4:0]            nb_tile;
   logic [4:0]            count_nb_tile;
   logic [4:0]            next_count_nb_tile;
   logic [1:0]            load_next_param_tile;
   logic [1:0]            next_load_next_param_tile;

   // Count a packet on each valid handshake
   assign packet_counter_enable = (fsm_stream_ready && a_stream_valid && b_stream_valid);
   assign out_packet_counter_enable = (fsm_output_stream_ready && c_stream_valid);
   // Enable the write enable on a valid handshake
   assign fsm_write_en = fsm_stream_ready; //fsm_stream_ready && a_stream_valid && b_stream_valid;
   //assign fsm_write_en = fsm_stream_ready; //fsm_stream_ready && a_stream_valid && b_stream_valid;

   /***********************************************************************************
    ***********************************************************************************
    * Connect signals to struct
    * Note: You can change the field names of the structs if other namings suit better
    ************************************************************************************
    ************************************************************************************/
   // Control signals
   assign ctrl_engine_o.stream_ready = fsm_stream_ready;
   assign ctrl_engine_o.wr_en = fsm_write_en;
   assign ctrl_engine_o.mem_sel = accelerator_memory_select;
   // Flags
   assign a_stream_valid = flags_engine_i.a_stream_valid;
   assign b_stream_valid = flags_engine_i.b_stream_valid;
   assign c_stream_valid = flags_engine_i.c_stream_valid;
   /*
    * FSM State Registers
    */
   always_ff @(posedge clk_i or negedge rst_ni)
     begin : main_fsm_seq
	if(~rst_ni) begin
	   curr_state <= FSM_IDLE;
	end
	else if(clear_i) begin
	   curr_state <= FSM_IDLE;
	end
	else begin
	   curr_state <= next_state;
	end
     end // block: main_fsm_seq

   /*
    * Counter updates for tiling
    */
   always_ff @(posedge clk_i or negedge rst_ni)
     begin : tile_fsm_seq
        if(~rst_ni) begin
           count_nb_tile <= '0;
           load_next_param_tile <= '0;
        end
        else if(clear_i) begin
           count_nb_tile <= '0; 
           load_next_param_tile <= '0;
        end
        else begin
           count_nb_tile <= next_count_nb_tile;
           load_next_param_tile <= next_load_next_param_tile;
        end
     end // block: tile_fsm_seq

   /*
    * Registers for control signals of the FSM
    */
   // packet_counter_enable is converted to comb logic
   always_ff @(posedge clk_i or negedge rst_ni)
     begin : fsm_control_signals_seq
      if(~rst_ni) begin
	 packet_counter_clear  <= '0;
	 //packet_counter_enable <= '0;
      end
      else if(clear_i) begin
	 packet_counter_clear  <= '0;
	 //packet_counter_enable <= '0;
      end
      else begin
	 packet_counter_clear  <= packet_counter_clear_next;
	 //packet_counter_enable <= packet_counter_enable_next;
      end
   end

   /*
    * Registers for control signals of the FSM (output)
    */
   // packet_counter_enable is converted to comb logic
   always_ff @(posedge clk_i or negedge rst_ni)
     begin : fsm_control_signals_seq_out
      if(~rst_ni) begin
         out_packet_counter_clear  <= '0;
         //packet_counter_enable <= '0;
      end
      else if(clear_i) begin
         out_packet_counter_clear  <= '0;
         //packet_counter_enable <= '0;
      end
      else begin
         out_packet_counter_clear  <= out_packet_counter_clear_next;
         //packet_counter_enable <= packet_counter_enable_next;
      end
   end

   always_comb
     begin : main_fsm_comb
	//Configure the streamers depending on the state, see always block below
	// a stream (Address stream)
	ctrl_streamer_o.a_source_ctrl.addressgen_ctrl.trans_size   = trans_size;
	ctrl_streamer_o.a_source_ctrl.addressgen_ctrl.line_stride  = '0;
	ctrl_streamer_o.a_source_ctrl.addressgen_ctrl.line_length  = trans_size;
	ctrl_streamer_o.a_source_ctrl.addressgen_ctrl.feat_stride  = '0;
	ctrl_streamer_o.a_source_ctrl.addressgen_ctrl.feat_length  = 1;
	ctrl_streamer_o.a_source_ctrl.addressgen_ctrl.base_addr    = base_address_address;
	ctrl_streamer_o.a_source_ctrl.addressgen_ctrl.feat_roll    = '0;
	ctrl_streamer_o.a_source_ctrl.addressgen_ctrl.loop_outer   = '0;
	ctrl_streamer_o.a_source_ctrl.addressgen_ctrl.realign_type = '0;
	// b stream (Data stream)
	ctrl_streamer_o.b_source_ctrl.addressgen_ctrl.trans_size   = trans_size;
	ctrl_streamer_o.b_source_ctrl.addressgen_ctrl.line_stride  = '0;
	ctrl_streamer_o.b_source_ctrl.addressgen_ctrl.line_length  = trans_size;
	ctrl_streamer_o.b_source_ctrl.addressgen_ctrl.feat_stride  = '0;
	ctrl_streamer_o.b_source_ctrl.addressgen_ctrl.feat_length  = 1;
	ctrl_streamer_o.b_source_ctrl.addressgen_ctrl.base_addr    = base_address_data;
	ctrl_streamer_o.b_source_ctrl.addressgen_ctrl.feat_roll    = '0;
	ctrl_streamer_o.b_source_ctrl.addressgen_ctrl.loop_outer   = '0;
	ctrl_streamer_o.b_source_ctrl.addressgen_ctrl.realign_type = '0;
        // c stream (Output stream)
        ctrl_streamer_o.c_sink_ctrl.addressgen_ctrl.trans_size   = out_trans_size; //reg_file_i.hwpe_params[PANDA_OUTPUT_DATA_N];
        ctrl_streamer_o.c_sink_ctrl.addressgen_ctrl.line_stride  = '0;
        ctrl_streamer_o.c_sink_ctrl.addressgen_ctrl.line_length  = out_trans_size; //reg_file_i.hwpe_params[PANDA_OUTPUT_DATA_N];
        ctrl_streamer_o.c_sink_ctrl.addressgen_ctrl.feat_stride  = '0;
        ctrl_streamer_o.c_sink_ctrl.addressgen_ctrl.feat_length  = 1;
        ctrl_streamer_o.c_sink_ctrl.addressgen_ctrl.base_addr    = out_base_address_data; //reg_file_i.hwpe_params[PANDA_OUTPUT_DATA];;
        ctrl_streamer_o.c_sink_ctrl.addressgen_ctrl.feat_roll    = '0;
        ctrl_streamer_o.c_sink_ctrl.addressgen_ctrl.loop_outer   = '0;
        ctrl_streamer_o.c_sink_ctrl.addressgen_ctrl.realign_type = '0;

	// slave
	ctrl_slave_o.done = '0; // Tells the register file that the accelerator has finished computing
	ctrl_slave_o.evt  = '0; // Not used

        tile_fsm_en = 1'b0;
        tiling_en = reg_file_i.hwpe_params[PANDA_NB_TILE];
        nb_tile = flags_engine_i.nb_weight_tile;
        //load_next_param_tile = '0;
        next_load_next_param_tile = load_next_param_tile;
        next_count_nb_tile = count_nb_tile;
	
	// engine
	ctrl_engine_o.clear      = '0; // Reset accelerator
	ctrl_engine_o.enable     = '1; // Power on accelerator
	ctrl_engine_o.start      = '0; // Start accelerator

	// real finite-state machine
	next_state   = curr_state;
	ctrl_streamer_o.a_source_ctrl.req_start = '0;
	ctrl_streamer_o.b_source_ctrl.req_start = '0;
	ctrl_streamer_o.c_sink_ctrl.req_start   = '0; // TODO: We are not controlling the output stream yet !!
        fsm_stream_ready = 1'b0;
        fsm_output_stream_ready = 1'b0;
	// Packet counter control
	packet_counter_clear_next =  1;  // Clear counter by default
        out_packet_counter_clear_next = 1;
	//packet_counter_enable     = '0;  // Do not enable counter by default

	case(curr_state)
	  FSM_IDLE: begin
	     ctrl_engine_o.clear =  '1; // Keep engine in reset when in idle state
	     ctrl_engine_o.enable = '0; // Do not enable engine when in idle state
             tile_fsm_en = 1'b0;
             next_load_next_param_tile = '0;
             next_count_nb_tile = '0;
             // wait for a start signal
             if(flags_slave_i.start) begin
		next_state = FSM_LOAD_CONFIGURATION;
             end
	  end
	  /*************************************
	   * State to load CONFIGURATION MEMORY
	   *************************************/
	  FSM_LOAD_CONFIGURATION: begin
	     packet_counter_clear_next = '0;           // Unclear counter
             fsm_stream_ready = ~packet_counter_clear && a_stream_valid && b_stream_valid;// Ready to accept stream once counter is operational, and both datas are valid.
	     if(packet_cnt==trans_size) begin
		fsm_stream_ready=1'b0; // Received all packets for this state, do not accept new ones
		// All configurations are written
		// Clear packet counter and configure next memory
		next_state = FSM_LOAD_INSTRUCTION;
		packet_counter_clear_next = '1; // Reset counter when switching to next state
	     end else if(streamers_ready) begin 	     // Wait until the streamers are ready
		// When no packets are received yet, try to start the streamers
		ctrl_streamer_o.a_source_ctrl.req_start = (packet_cnt=='0); 
		ctrl_streamer_o.b_source_ctrl.req_start = (packet_cnt=='0);
	     end else begin // if (streamers_ready)
		// Streamers not ready, stay in this state
		// Assignment is done above case statement
             end // else: !if(streamers_ready)
	  end // case: FSM_LOAD_CONFIGURATION
	  /**********************************
	   * State to load INSTRUCTION MEMORY
	   **********************************/
	  FSM_LOAD_INSTRUCTION: begin
	     packet_counter_clear_next = '0;            // Unclear counter
	     fsm_stream_ready = ~packet_counter_clear && a_stream_valid && b_stream_valid;// Ready to accept stream once counter is operational, and both datas are valid.
	     if(packet_cnt==trans_size) begin
		fsm_stream_ready=1'b0; // Received all packets for this state, do not accept new ones
		// All configurations are written
		// Clear packet counter and configure next memory
		next_state = FSM_LOAD_LUT;
		packet_counter_clear_next = '1; // Reset counter when switching to next state
	     end else if(streamers_ready) begin  	     // Wait until the streamers are ready
		// When no packets are received yet, try to start the streamers
		ctrl_streamer_o.a_source_ctrl.req_start = (packet_cnt=='0); 
		ctrl_streamer_o.b_source_ctrl.req_start = (packet_cnt=='0);
	     end else begin // if (streamers_ready)
		// Streamers not ready, stay in this state
		// Assignment is done above case statement
             end // else: !if(streamers_ready)
	  end // case: FSM_LOAD_INSTRUCTION
          /**********************************
           * State to load LUT MEMORY
           **********************************/
          FSM_LOAD_LUT: begin
             packet_counter_clear_next = '0;            // Unclear counter
             fsm_stream_ready = ~packet_counter_clear && a_stream_valid && b_stream_valid;// Ready to accept stream once counter is operational, and both datas are valid.
             if(packet_cnt==trans_size) begin
                fsm_stream_ready=1'b0; // Received all packets for this state, do not accept new ones
                // All configurations are written
                // Clear packet counter and configure next memory
                next_state = FSM_LOAD_SPARSITY;
                packet_counter_clear_next = '1; // Reset counter when switching to next state
             end else if(streamers_ready) begin              // Wait until the streamers are ready
                // When no packets are received yet, try to start the streamers
                ctrl_streamer_o.a_source_ctrl.req_start = (packet_cnt=='0);
                ctrl_streamer_o.b_source_ctrl.req_start = (packet_cnt=='0);
             end else begin // if (streamers_ready)
                // Streamers not ready, stay in this state
                // Assignment is done above case statement
             end // else: !if(streamers_ready)
          end // case: FSM_LOAD_INSTRUCTION
          /**********************************
           * State to load SPARSITY MEMORY
           **********************************/
          FSM_LOAD_SPARSITY: begin
             packet_counter_clear_next = '0;            // Unclear counter
             fsm_stream_ready = ~packet_counter_clear && a_stream_valid && b_stream_valid;// Ready to accept stream once counter is operational, and both datas are valid.
             if(packet_cnt==trans_size) begin
                fsm_stream_ready=1'b0; // Received all packets for this state, do not accept new ones
                // All configurations are written
                // Clear packet counter and configure next memory
                next_state = FSM_LOAD_ACTIVATION;
                packet_counter_clear_next = '1; // Reset counter when switching to next state
             end else if(streamers_ready) begin              // Wait until the streamers are ready
                // When no packets are received yet, try to start the streamers
                ctrl_streamer_o.a_source_ctrl.req_start = (packet_cnt=='0);
                ctrl_streamer_o.b_source_ctrl.req_start = (packet_cnt=='0);
             end else begin // if (streamers_ready)
                // Streamers not ready, stay in this state
                // Assignment is done above case statement
             end // else: !if(streamers_ready)
          end // case: FSM_LOAD_INSTRUCTION
	  /*********************************
	   * State to load ACTIVATION MEMORY
	   *********************************/
	  FSM_LOAD_ACTIVATION: begin
	     packet_counter_clear_next = '0;            // Unclear counter
             fsm_stream_ready = ~packet_counter_clear && a_stream_valid && b_stream_valid; // Ready to accept stream once counter is operational, and both datas are valid.
	     if(packet_cnt==trans_size) begin
		fsm_stream_ready=1'b0; // Received all packets for this state, do not accept new ones
		// All configurations are written
		// Clear packet counter and configure next memory
                if (flags_engine_i.mode == 1) begin // If mode is CNN
		  next_state = FSM_LOAD_WEIGHT_CONV;
                end else if (flags_engine_i.mode == 0) begin // If mode is FC 
                  next_state = FSM_LOAD_WEIGHT_FC; 
			end
		//////////// ADDED BY SEBASTIAN ///////////////////77
                else
		  next_state= FSM_ACCEL_RUN;
            
                 /////////////////////////////////////////////////////////7










                
		packet_counter_clear_next = '1; // Reset counter when switching to next state
	     end else if(streamers_ready) begin 	     // Wait until the streamers are ready
		// When no packets are received yet, try to start the streamers
		ctrl_streamer_o.a_source_ctrl.req_start = (packet_cnt=='0); 
		ctrl_streamer_o.b_source_ctrl.req_start = (packet_cnt=='0);
	     end else begin // if (streamers_ready)
		// Streamers not ready, stay in this state
		// Assignment is done above case statement
             end // else: !if(streamers_ready)
	  end

	     /**********************************
	      * State to load CONV WEIGHT MEMORY
	      **********************************/
	     FSM_LOAD_WEIGHT_CONV: begin
		packet_counter_clear_next = '0;           // Unclear counter
		fsm_stream_ready = ~packet_counter_clear && a_stream_valid && b_stream_valid; // Ready to accept stream once counter is operational, and both datas are valid.
		if(packet_cnt==trans_size) begin
		   fsm_stream_ready=1'b0; // Received all packets for this state, do not accept new ones
		   // All configurations are written
		   // Clear packet counter and configure next memory
                   if (tiling_en == 0) begin
		     next_state = FSM_LOAD_WEIGHT_FC;
                   end else begin
                     next_state = FSM_ACCEL_RUN;
                     next_count_nb_tile = count_nb_tile + 1;
                   end
		   packet_counter_clear_next = '1; // Reset counter when switching to next state
		end else if(streamers_ready) begin  	     // Wait until the streamers are ready
		   // When no packets are received yet, try to start the streamers
		   ctrl_streamer_o.a_source_ctrl.req_start = (packet_cnt=='0); 
		   ctrl_streamer_o.b_source_ctrl.req_start = (packet_cnt=='0);
		end else begin // if (streamers_ready)
		   // Streamers not ready, stay in this state
		   // Assignment is done above case statement
		end // else: !if(streamers_ready)
	     end // case: FSM_LOAD_WEIGHT_CONV
	  /**********************************
	   * State to load FC WEIGHT MEMORY
	   **********************************/
	  FSM_LOAD_WEIGHT_FC: begin
	     packet_counter_clear_next = '0;           // Unclear counter
	     fsm_stream_ready = ~packet_counter_clear && a_stream_valid && b_stream_valid; // Ready to accept stream once counter is operational, and both datas are valid.
	     if(packet_cnt==trans_size) begin
		fsm_stream_ready=1'b0; // Received all packets for this state, do not accept new ones
		// All configurations are written
		// Clear packet counter and configure next memory
		next_state = FSM_ACCEL_RUN;
                if (tiling_en == 1) 
                  next_count_nb_tile = count_nb_tile + 1;
		packet_counter_clear_next = '1; // Reset counter when switching to next state
	     end else if(streamers_ready) begin  	     // Wait until the streamers are ready
		// When no packets are received yet, try to start the streamers
		ctrl_streamer_o.a_source_ctrl.req_start = (packet_cnt=='0); 
		ctrl_streamer_o.b_source_ctrl.req_start = (packet_cnt=='0);
	     end else begin // if (streamers_ready)
		// Streamers not ready, stay in this state
		// Assignment is done above case statement
	     end // else: !if(streamers_ready)
	  end // case: FSM_LOAD_WEIGHT_CONV

	  /*************************
	   * Start accelerator
	   ************************/
	  FSM_ACCEL_RUN: begin
	     ctrl_engine_o.start = 1'b1;
             next_state = FSM_ACCEL_RUNNING;
          end
         
          FSM_ACCEL_RUNNING: begin
             ctrl_engine_o.start = 1'b0;
             tile_fsm_en = 1'b1;
             //nb_tile = flags_engine_i.nb_input_tile;
             out_packet_counter_clear_next = '0;           // Unclear counter
             fsm_output_stream_ready = ~out_packet_counter_clear && c_stream_valid;// Ready to accept stream once counter is operational, and both datas are valid.
             packet_counter_clear_next = '0;            // Unclear counter
             fsm_stream_ready = ~packet_counter_clear && a_stream_valid && b_stream_valid; // Ready to accept stream once counter is operational, and both datas are valid.
             if(out_packet_cnt==out_trans_size) begin
                fsm_output_stream_ready=1'b0; // Received all packets for this state, do not accept new ones
                // All configurations are written
                // Clear packet counter and configure next memory
                out_packet_counter_clear_next = '1; // Reset counter when switching to next state
                //nb_tile = flags_engine_i.nb_input_tile;
                //next_count_nb_tile = count_nb_tile + 1;
                if (count_nb_tile == nb_tile)
                  next_count_nb_tile = '0;
                next_load_next_param_tile = '0;
             //end if(out_packet_cnt==out_trans_size-1) begin
             //   next_count_nb_tile = count_nb_tile + 1;
             end else if(output_streamer_ready) begin              // Wait until the streamers are ready
                // When no packets are received yet, try to start the streamers
                ctrl_streamer_o.c_sink_ctrl.req_start = (out_packet_cnt=='0);

             end else begin // if (output_streamer_ready)
                // Streamers not ready, stay in this state
                // Assignment is done above case statement
               
               if (flags_engine_i.done_layer) begin
               if (count_nb_tile == nb_tile) begin
                 next_count_nb_tile = '0;
               end else begin
                 next_count_nb_tile = count_nb_tile + 1;
                 next_load_next_param_tile = '0;
               end
               end

               if (load_next_param_tile < 2) begin
                if(packet_cnt==trans_size) begin
                  fsm_stream_ready=1'b0; // Received all packets for this state, do not accept new ones
                  // All configurations are written
                  // Clear packet counter and configure next memory
                  //next_state = FSM_LOAD_WEIGHT_CONV;
                  next_load_next_param_tile = load_next_param_tile + 1;
                  packet_counter_clear_next = '1; // Reset counter when switching to next state
                end else if(streamers_ready) begin              // Wait until the streamers are ready
                  // When no packets are received yet, try to start the streamers
                  ctrl_streamer_o.a_source_ctrl.req_start = (packet_cnt=='0);
                  ctrl_streamer_o.b_source_ctrl.req_start = (packet_cnt=='0);
                end else begin // if (streamers_ready)
                  // Streamers not ready, stay in this state
                  // Assignment is done above case statement
                end // else: !if(streamers_ready)
               end

             end // else: !if(output_streamer_ready)

	     if(flags_engine_i.done) begin
		next_state = FSM_TERMINATE;
	     end
	  end

	  FSM_TERMINATE: begin
             // wait for the flags to be ok then go back to idle
             ctrl_engine_o.clear  = 1'b0;
             ctrl_engine_o.enable = 1'b0;
             ctrl_engine_o.start = 1'b0;
             if(streamers_ready) begin
		next_state = FSM_IDLE;
		ctrl_slave_o.done = 1'b1;
             end
	  end // case: FSM_TERMINATE
	endcase // curr_state
     end // block: main_fsm_comb


   /*
    * Multiplexer, configures the streamers:
    * -     Base address depending on the current state
    * -     Transaction length dependin on the current state
    * And controls the memory demux in the accelerator wrapper
    */
   always_comb
     begin: streamer_config
        trans_size            = '0;
        base_address_address  = base_address_address;//'0;
        out_trans_size        = '0;
        out_base_address_data = '0;
        base_address_data     = base_address_data;//'0;
        accelerator_memory_select = PANDA_FSM_SEL_NULL;

	case (curr_state)
	  FSM_LOAD_CONFIGURATION: begin
	     trans_size           = reg_file_i.hwpe_params[PANDA_CONFIG_MEMORY_N];
	     base_address_address = reg_file_i.hwpe_params[PANDA_CONFIG_AMEMORY_ADDRESS];
	     base_address_data    = reg_file_i.hwpe_params[PANDA_CONFIG_DMEMORY_ADDRESS];
	     accelerator_memory_select = PANDA_FSM_SEL_CONFIG_MEMORY;
	  end
	  FSM_LOAD_INSTRUCTION: begin
	     trans_size           = reg_file_i.hwpe_params[PANDA_INSTRUCTION_MEMORY_N];
	     base_address_address = reg_file_i.hwpe_params[PANDA_INSTRUCTION_AMEMORY_ADDRESS];
	     base_address_data    = reg_file_i.hwpe_params[PANDA_INSTRUCTION_DMEMORY_ADDRESS];
	     accelerator_memory_select = PANDA_FSM_SEL_INSTRUCTION_MEMORY;
	  end
          FSM_LOAD_LUT: begin
             trans_size           = reg_file_i.hwpe_params[PANDA_LUT_MEMORY_N];
             base_address_address = reg_file_i.hwpe_params[PANDA_LUT_AMEMORY_ADDRESS];
             base_address_data    = reg_file_i.hwpe_params[PANDA_LUT_DMEMORY_ADDRESS];
             accelerator_memory_select = PANDA_FSM_SEL_LUT_MEMORY;
          end
          FSM_LOAD_SPARSITY: begin
             trans_size           = reg_file_i.hwpe_params[PANDA_SPARSITY_MEMORY_N];
             base_address_address = reg_file_i.hwpe_params[PANDA_SPARSITY_AMEMORY_ADDRESS];
             base_address_data    = reg_file_i.hwpe_params[PANDA_SPARSITY_DMEMORY_ADDRESS];
             accelerator_memory_select = PANDA_FSM_SEL_SPARSITY_MEMORY;
          end
	  FSM_LOAD_ACTIVATION: begin
	     trans_size           = reg_file_i.hwpe_params[PANDA_ACTIVATION_MEMORY_N];
	     base_address_address = reg_file_i.hwpe_params[PANDA_ACTIVATION_AMEMORY_ADDRESS];
	     base_address_data    = reg_file_i.hwpe_params[PANDA_ACTIVATION_DMEMORY_ADDRESS];
	     accelerator_memory_select = PANDA_FSM_SEL_ACTIVATION_MEMORY;
	  end
	  FSM_LOAD_WEIGHT_CONV: begin
	     trans_size           = reg_file_i.hwpe_params[PANDA_WEIGHT_CONV_MEMORY_N];
	     base_address_address = reg_file_i.hwpe_params[PANDA_WEIGHT_CONV_AMEMORY_ADDRESS];
	     base_address_data    = reg_file_i.hwpe_params[PANDA_WEIGHT_CONV_DMEMORY_ADDRESS];
	     accelerator_memory_select = PANDA_FSM_SEL_WEIGHT_CONV_MEMORY;
	  end
	  FSM_LOAD_WEIGHT_FC: begin
	     trans_size           = reg_file_i.hwpe_params[PANDA_WEIGHT_FC_MEMORY_N];
	     base_address_address = reg_file_i.hwpe_params[PANDA_WEIGHT_FC_AMEMORY_ADDRESS];
	     base_address_data    = reg_file_i.hwpe_params[PANDA_WEIGHT_FC_DMEMORY_ADDRESS];
	     accelerator_memory_select = PANDA_FSM_SEL_WEIGHT_FC_MEMORY;
	  end
          FSM_ACCEL_RUN: begin
            out_trans_size           = reg_file_i.hwpe_params[PANDA_OUTPUT_DATA_N];
	    out_base_address_data    = reg_file_i.hwpe_params[PANDA_OUTPUT_DATA];
          end

          FSM_ACCEL_RUNNING: begin

            out_trans_size           = reg_file_i.hwpe_params[PANDA_OUTPUT_DATA_N];
            out_base_address_data    = reg_file_i.hwpe_params[PANDA_OUTPUT_DATA];

            if (count_nb_tile != 0 && count_nb_tile < nb_tile) begin
              //out_trans_size           = flags_engine_i.out_tile_size;//reg_file_i.hwpe_params[PANDA_OUTPUT_DATA_N];
	      //out_base_address_data    = reg_file_i.hwpe_params[PANDA_OUTPUT_DATA] + ((count_nb_tile) * (flags_engine_i.out_tile_size));//(reg_file_i.hwpe_params[PANDA_OUTPUT_DATA_N] << 2));

              if (load_next_param_tile == 0 && (flags_engine_i.mode == 1 || flags_engine_i.mode == 0)) begin
                if (flags_engine_i.sparsity == 0)
                  trans_size = 0;
                else
                  trans_size = flags_engine_i.weight_tile_size>>2;
                
                base_address_address = reg_file_i.hwpe_params[PANDA_SPARSITY_AMEMORY_ADDRESS] + (count_nb_tile * ( flags_engine_i.weight_tile_size));//(reg_file_i.hwpe_params[PANDA_ACTIVATION_MEMORY_N] << 2));
                base_address_data    = reg_file_i.hwpe_params[PANDA_SPARSITY_DMEMORY_ADDRESS] + (count_nb_tile * ( flags_engine_i.weight_tile_size));//(reg_file_i.hwpe_params[PANDA_ACTIVATION_MEMORY_N] << 2));
                accelerator_memory_select = PANDA_FSM_SEL_SPARSITY_MEMORY;
              end 
              else if (load_next_param_tile == 1  && flags_engine_i.mode == 1) begin
                trans_size           =  flags_engine_i.weight_tile_size>>2; //reg_file_i.hwpe_params[PANDA_WEIGHT_CONV_MEMORY_N];

                base_address_address = reg_file_i.hwpe_params[PANDA_WEIGHT_CONV_AMEMORY_ADDRESS] + (count_nb_tile * (flags_engine_i.weight_tile_size));
                base_address_data    = reg_file_i.hwpe_params[PANDA_WEIGHT_CONV_DMEMORY_ADDRESS] + (count_nb_tile * (flags_engine_i.weight_tile_size));
                accelerator_memory_select = PANDA_FSM_SEL_WEIGHT_CONV_MEMORY; 
              end
              else if (load_next_param_tile == 1  && flags_engine_i.mode == 0) begin
                trans_size           = flags_engine_i.weight_tile_size>>2; //reg_file_i.hwpe_params[PANDA_WEIGHT_FC_MEMORY_N];
                base_address_address = reg_file_i.hwpe_params[PANDA_WEIGHT_FC_AMEMORY_ADDRESS] + (count_nb_tile * (flags_engine_i.weight_tile_size));//(reg_file_i.hwpe_params[PANDA_WEIGHT_FC_MEMORY_N] << 2));
                base_address_data    = reg_file_i.hwpe_params[PANDA_WEIGHT_FC_DMEMORY_ADDRESS] + (count_nb_tile * (flags_engine_i.weight_tile_size));//(reg_file_i.hwpe_params[PANDA_WEIGHT_FC_MEMORY_N] << 2));
                accelerator_memory_select = PANDA_FSM_SEL_WEIGHT_FC_MEMORY; 
              end else begin
                base_address_address = base_address_address;
                base_address_data    = base_address_data;
              end
            //end else begin
            // out_trans_size           = reg_file_i.hwpe_params[PANDA_OUTPUT_DATA_N];
            // out_base_address_data    = reg_file_i.hwpe_params[PANDA_OUTPUT_DATA];
            end
          end 

	endcase // case (curr_state)

     end

   /*	
    * Packet counter for writing accelerator memories
    */
   always_ff @(posedge clk_i, negedge rst_ni)
     begin: packet_counter
	if(~rst_ni) begin
	   packet_cnt <= '0;
	end
	else if(clear_i||packet_counter_clear) begin
	   packet_cnt <= '0;
	end
	else if(packet_counter_enable) begin
	   packet_cnt <= packet_cnt+1;
	end
     end

    /*
    * Packet counter for writing accelerator memories(output)
    */
   always_ff @(posedge clk_i, negedge rst_ni)
     begin: packet_counter_out
        if(~rst_ni) begin
           out_packet_cnt <= '0;
        end
        else if(clear_i||out_packet_counter_clear) begin
           out_packet_cnt <= '0;
        end
        else if(out_packet_counter_enable) begin
           out_packet_cnt <= out_packet_cnt+1;
        end
     end

endmodule // memory_fsm
