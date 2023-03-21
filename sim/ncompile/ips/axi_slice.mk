#
# Copyright (C) 2015-2019 ETH Zurich, University of Bologna
# All rights reserved.
#
# This software may be modified and distributed under the terms
# of the BSD license.  See the LICENSE file for details.
#

IP=axi_slice
IP_PATH=$(IPS_PATH)/axi/axi_slice
LIB_NAME=$(IP)_lib

include ncompile/build.mk

.PHONY: ncompile-$(IP) ncompile-subip-axi_slice 

ncompile-$(IP): $(LIB_PATH)/_nmake

$(LIB_PATH)/_nmake : $(LIB_PATH)/axi_slice.nmake 
	echo $(LIB_PATH)/_nmake


SRC_SVLOG_AXI_SLICE=\
	$(IP_PATH)/src/axi_single_slice.sv\
	$(IP_PATH)/src/axi_ar_buffer.sv\
	$(IP_PATH)/src/axi_aw_buffer.sv\
	$(IP_PATH)/src/axi_b_buffer.sv\
	$(IP_PATH)/src/axi_r_buffer.sv\
	$(IP_PATH)/src/axi_slice.sv\
	$(IP_PATH)/src/axi_w_buffer.sv\
	$(IP_PATH)/src/axi_slice_wrap.sv
SRC_VHDL_AXI_SLICE=

ncompile-subip-axi_slice: $(LIB_PATH)/axi_slice.nmake

$(LIB_PATH)/axi_slice.nmake: $(SRC_SVLOG_AXI_SLICE) $(SRC_VHDL_AXI_SLICE)
	$(call subip_echo,axi_slice)
	$(SVLOG_CC) -makelib ./ncsim_libs    $(INCDIR_AXI_SLICE) $(SRC_SVLOG_AXI_SLICE) -endlib

	echo $(LIB_PATH)/axi_slice.nmake

