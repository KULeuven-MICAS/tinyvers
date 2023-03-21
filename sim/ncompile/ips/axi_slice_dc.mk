#
# Copyright (C) 2015-2019 ETH Zurich, University of Bologna
# All rights reserved.
#
# This software may be modified and distributed under the terms
# of the BSD license.  See the LICENSE file for details.
#

IP=axi_slice_dc
IP_PATH=$(IPS_PATH)/axi/axi_slice_dc
LIB_NAME=$(IP)_lib

include ncompile/build.mk

.PHONY: ncompile-$(IP) ncompile-subip-axi_slice_dc 

ncompile-$(IP): $(LIB_PATH)/_nmake

$(LIB_PATH)/_nmake : $(LIB_PATH)/axi_slice_dc.nmake 
	echo $(LIB_PATH)/_nmake


SRC_SVLOG_AXI_SLICE_DC=\
	$(IP_PATH)/src/axi_slice_dc_master.sv\
	$(IP_PATH)/src/axi_slice_dc_slave.sv\
	$(IP_PATH)/src/dc_data_buffer.sv\
	$(IP_PATH)/src/dc_full_detector.v\
	$(IP_PATH)/src/dc_synchronizer.v\
	$(IP_PATH)/src/dc_token_ring_fifo_din.v\
	$(IP_PATH)/src/dc_token_ring_fifo_dout.v\
	$(IP_PATH)/src/dc_token_ring.v\
	$(IP_PATH)/src/axi_slice_dc_master_wrap.sv\
	$(IP_PATH)/src/axi_slice_dc_slave_wrap.sv\
	$(IP_PATH)/src/axi_cdc.sv
SRC_VHDL_AXI_SLICE_DC=

ncompile-subip-axi_slice_dc: $(LIB_PATH)/axi_slice_dc.nmake

$(LIB_PATH)/axi_slice_dc.nmake: $(SRC_SVLOG_AXI_SLICE_DC) $(SRC_VHDL_AXI_SLICE_DC)
	$(call subip_echo,axi_slice_dc)
	$(SVLOG_CC) -makelib ./ncsim_libs    $(INCDIR_AXI_SLICE_DC) $(SRC_SVLOG_AXI_SLICE_DC) -endlib

	echo $(LIB_PATH)/axi_slice_dc.nmake

