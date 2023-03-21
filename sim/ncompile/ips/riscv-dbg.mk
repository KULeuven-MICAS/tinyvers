#
# Copyright (C) 2015-2019 ETH Zurich, University of Bologna
# All rights reserved.
#
# This software may be modified and distributed under the terms
# of the BSD license.  See the LICENSE file for details.
#

IP=riscv_dbg
IP_PATH=$(IPS_PATH)/riscv-dbg
LIB_NAME=$(IP)_lib

include ncompile/build.mk

.PHONY: ncompile-$(IP) ncompile-subip-riscv-dbg 

ncompile-$(IP): $(LIB_PATH)/_nmake

$(LIB_PATH)/_nmake : $(LIB_PATH)/riscv-dbg.nmake 
	echo $(LIB_PATH)/_nmake


SRC_SVLOG_RISCV-DBG=\
	$(IP_PATH)/src/dm_pkg.sv\
	$(IP_PATH)/debug_rom/debug_rom.sv\
	$(IP_PATH)/src/dm_csrs.sv\
	$(IP_PATH)/src/dm_mem.sv\
	$(IP_PATH)/src/dm_top.sv\
	$(IP_PATH)/src/dmi_cdc.sv\
	$(IP_PATH)/src/dmi_jtag.sv\
	$(IP_PATH)/src/dmi_jtag_tap.sv\
	$(IP_PATH)/src/dm_sba.sv
SRC_VHDL_RISCV-DBG=

ncompile-subip-riscv-dbg: $(LIB_PATH)/riscv-dbg.nmake

$(LIB_PATH)/riscv-dbg.nmake: $(SRC_SVLOG_RISCV-DBG) $(SRC_VHDL_RISCV-DBG)
	$(call subip_echo,riscv-dbg)
	$(SVLOG_CC) -makelib ./ncsim_libs    $(INCDIR_RISCV-DBG) $(SRC_SVLOG_RISCV-DBG) -endlib

	echo $(LIB_PATH)/riscv-dbg.nmake

