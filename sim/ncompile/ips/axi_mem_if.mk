#
# Copyright (C) 2015-2019 ETH Zurich, University of Bologna
# All rights reserved.
#
# This software may be modified and distributed under the terms
# of the BSD license.  See the LICENSE file for details.
#

IP=axi_mem_if
IP_PATH=$(IPS_PATH)/axi/axi_mem_if
LIB_NAME=$(IP)_lib

include ncompile/build.mk

.PHONY: ncompile-$(IP) ncompile-subip-axi_mem_if 

ncompile-$(IP): $(LIB_PATH)/_nmake

$(LIB_PATH)/_nmake : $(LIB_PATH)/axi_mem_if.nmake 
	echo $(LIB_PATH)/_nmake


SRC_SVLOG_AXI_MEM_IF=\
	$(IP_PATH)/src/axi2mem.sv\
	$(IP_PATH)/src/deprecated/axi_mem_if.sv\
	$(IP_PATH)/src/deprecated/axi_mem_if_wrap.sv\
	$(IP_PATH)/src/deprecated/axi_mem_if_var_latency.sv
SRC_VHDL_AXI_MEM_IF=

ncompile-subip-axi_mem_if: $(LIB_PATH)/axi_mem_if.nmake

$(LIB_PATH)/axi_mem_if.nmake: $(SRC_SVLOG_AXI_MEM_IF) $(SRC_VHDL_AXI_MEM_IF)
	$(call subip_echo,axi_mem_if)
	$(SVLOG_CC) -makelib ./ncsim_libs    $(INCDIR_AXI_MEM_IF) $(SRC_SVLOG_AXI_MEM_IF) -endlib

	echo $(LIB_PATH)/axi_mem_if.nmake

