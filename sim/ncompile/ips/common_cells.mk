#
# Copyright (C) 2015-2019 ETH Zurich, University of Bologna
# All rights reserved.
#
# This software may be modified and distributed under the terms
# of the BSD license.  See the LICENSE file for details.
#

IP=common_cells
IP_PATH=$(IPS_PATH)/common_cells
LIB_NAME=$(IP)_lib

include ncompile/build.mk

.PHONY: ncompile-$(IP) ncompile-subip-common_cells_all 

ncompile-$(IP): $(LIB_PATH)/_nmake

$(LIB_PATH)/_nmake : $(LIB_PATH)/common_cells_all.nmake 
	echo $(LIB_PATH)/_nmake


SRC_SVLOG_COMMON_CELLS_ALL=\
	$(IP_PATH)/src/cdc_2phase.sv\
	$(IP_PATH)/src/clk_div.sv\
	$(IP_PATH)/src/counter.sv\
	$(IP_PATH)/src/edge_propagator_tx.sv\
	$(IP_PATH)/src/fifo_v3.sv\
	$(IP_PATH)/src/lfsr_8bit.sv\
	$(IP_PATH)/src/lzc.sv\
	$(IP_PATH)/src/mv_filter.sv\
	$(IP_PATH)/src/onehot_to_bin.sv\
	$(IP_PATH)/src/plru_tree.sv\
	$(IP_PATH)/src/popcount.sv\
	$(IP_PATH)/src/rr_arb_tree.sv\
	$(IP_PATH)/src/rstgen_bypass.sv\
	$(IP_PATH)/src/serial_deglitch.sv\
	$(IP_PATH)/src/shift_reg.sv\
	$(IP_PATH)/src/spill_register.sv\
	$(IP_PATH)/src/stream_demux.sv\
	$(IP_PATH)/src/stream_filter.sv\
	$(IP_PATH)/src/stream_fork.sv\
	$(IP_PATH)/src/stream_mux.sv\
	$(IP_PATH)/src/sync.sv\
	$(IP_PATH)/src/sync_wedge.sv\
	$(IP_PATH)/src/edge_detect.sv\
	$(IP_PATH)/src/id_queue.sv\
	$(IP_PATH)/src/rstgen.sv\
	$(IP_PATH)/src/stream_delay.sv\
	$(IP_PATH)/src/fall_through_register.sv\
	$(IP_PATH)/src/stream_arbiter_flushable.sv\
	$(IP_PATH)/src/stream_register.sv\
	$(IP_PATH)/src/stream_arbiter.sv\
	$(IP_PATH)/src/deprecated/clock_divider_counter.sv\
	$(IP_PATH)/src/deprecated/find_first_one.sv\
	$(IP_PATH)/src/deprecated/generic_LFSR_8bit.sv\
	$(IP_PATH)/src/deprecated/generic_fifo.sv\
	$(IP_PATH)/src/deprecated/generic_fifo_adv.sv\
	$(IP_PATH)/src/deprecated/pulp_sync.sv\
	$(IP_PATH)/src/deprecated/pulp_sync_wedge.sv\
	$(IP_PATH)/src/deprecated/clock_divider.sv\
	$(IP_PATH)/src/deprecated/fifo_v2.sv\
	$(IP_PATH)/src/deprecated/prioarbiter.sv\
	$(IP_PATH)/src/deprecated/rrarbiter.sv\
	$(IP_PATH)/src/deprecated/fifo_v1.sv\
	$(IP_PATH)/src/edge_propagator.sv\
	$(IP_PATH)/src/edge_propagator_rx.sv
SRC_VHDL_COMMON_CELLS_ALL=

ncompile-subip-common_cells_all: $(LIB_PATH)/common_cells_all.nmake

$(LIB_PATH)/common_cells_all.nmake: $(SRC_SVLOG_COMMON_CELLS_ALL) $(SRC_VHDL_COMMON_CELLS_ALL)
	$(call subip_echo,common_cells_all)
	$(SVLOG_CC) -makelib ./ncsim_libs    $(INCDIR_COMMON_CELLS_ALL) $(SRC_SVLOG_COMMON_CELLS_ALL) -endlib

	echo $(LIB_PATH)/common_cells_all.nmake

