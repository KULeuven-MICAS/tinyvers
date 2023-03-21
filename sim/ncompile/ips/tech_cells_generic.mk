#
# Copyright (C) 2015-2019 ETH Zurich, University of Bologna
# All rights reserved.
#
# This software may be modified and distributed under the terms
# of the BSD license.  See the LICENSE file for details.
#

IP=tech_cells_generic
IP_PATH=$(IPS_PATH)/tech_cells_generic
LIB_NAME=$(IP)_lib

include ncompile/build.mk

.PHONY: ncompile-$(IP) ncompile-subip-tech_cells_rtl ncompile-subip-tech_cells_rtl_synth 

ncompile-$(IP): $(LIB_PATH)/_nmake

$(LIB_PATH)/_nmake : $(LIB_PATH)/tech_cells_rtl.nmake $(LIB_PATH)/tech_cells_rtl_synth.nmake 
	echo $(LIB_PATH)/_nmake


SRC_SVLOG_TECH_CELLS_RTL=\
	$(IP_PATH)/src/deprecated/cluster_clk_cells.sv\
	$(IP_PATH)/src/deprecated/cluster_pwr_cells.sv\
	$(IP_PATH)/src/deprecated/generic_memory.sv\
	$(IP_PATH)/src/deprecated/generic_rom.sv\
	$(IP_PATH)/src/deprecated/pad_functional.sv\
	$(IP_PATH)/src/deprecated/pulp_buffer.sv\
	$(IP_PATH)/src/deprecated/pulp_clk_cells.sv\
	$(IP_PATH)/src/deprecated/pulp_pwr_cells.sv\
	$(IP_PATH)/src/rtl/tc_clk.sv\
	$(IP_PATH)/src/tc_pwr.sv
SRC_VHDL_TECH_CELLS_RTL=

ncompile-subip-tech_cells_rtl: $(LIB_PATH)/tech_cells_rtl.nmake

$(LIB_PATH)/tech_cells_rtl.nmake: $(SRC_SVLOG_TECH_CELLS_RTL) $(SRC_VHDL_TECH_CELLS_RTL)
	$(call subip_echo,tech_cells_rtl)
	$(SVLOG_CC) -makelib ./ncsim_libs    $(INCDIR_TECH_CELLS_RTL) $(SRC_SVLOG_TECH_CELLS_RTL) -endlib

	echo $(LIB_PATH)/tech_cells_rtl.nmake

SRC_SVLOG_TECH_CELLS_RTL_SYNTH=\
	$(IP_PATH)/src/deprecated/pulp_clock_gating_async.sv
SRC_VHDL_TECH_CELLS_RTL_SYNTH=

ncompile-subip-tech_cells_rtl_synth: $(LIB_PATH)/tech_cells_rtl_synth.nmake

$(LIB_PATH)/tech_cells_rtl_synth.nmake: $(SRC_SVLOG_TECH_CELLS_RTL_SYNTH) $(SRC_VHDL_TECH_CELLS_RTL_SYNTH)
	$(call subip_echo,tech_cells_rtl_synth)
	$(SVLOG_CC) -makelib ./ncsim_libs    $(INCDIR_TECH_CELLS_RTL_SYNTH) $(SRC_SVLOG_TECH_CELLS_RTL_SYNTH) -endlib

	echo $(LIB_PATH)/tech_cells_rtl_synth.nmake


