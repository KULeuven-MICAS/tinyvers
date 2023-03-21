#
# Copyright (C) 2015-2019 ETH Zurich, University of Bologna
# All rights reserved.
#
# This software may be modified and distributed under the terms
# of the BSD license.  See the LICENSE file for details.
#

IP=axi_node
IP_PATH=$(IPS_PATH)/axi/axi_node
LIB_NAME=$(IP)_lib

include ncompile/build.mk

.PHONY: ncompile-$(IP) ncompile-subip-axi_node 

ncompile-$(IP): $(LIB_PATH)/_nmake

$(LIB_PATH)/_nmake : $(LIB_PATH)/axi_node.nmake 
	echo $(LIB_PATH)/_nmake


# axi_node component
INCDIR_AXI_NODE=+incdir+$(IP_PATH)/./src/
SRC_SVLOG_AXI_NODE=\
	$(IP_PATH)/src/apb_regs_top.sv\
	$(IP_PATH)/src/axi_address_decoder_AR.sv\
	$(IP_PATH)/src/axi_address_decoder_AW.sv\
	$(IP_PATH)/src/axi_address_decoder_BR.sv\
	$(IP_PATH)/src/axi_address_decoder_BW.sv\
	$(IP_PATH)/src/axi_address_decoder_DW.sv\
	$(IP_PATH)/src/axi_AR_allocator.sv\
	$(IP_PATH)/src/axi_ArbitrationTree.sv\
	$(IP_PATH)/src/axi_AW_allocator.sv\
	$(IP_PATH)/src/axi_BR_allocator.sv\
	$(IP_PATH)/src/axi_BW_allocator.sv\
	$(IP_PATH)/src/axi_DW_allocator.sv\
	$(IP_PATH)/src/axi_FanInPrimitive_Req.sv\
	$(IP_PATH)/src/axi_multiplexer.sv\
	$(IP_PATH)/src/axi_node.sv\
	$(IP_PATH)/src/axi_node_intf_wrap.sv\
	$(IP_PATH)/src/axi_node_wrap_with_slices.sv\
	$(IP_PATH)/src/axi_regs_top.sv\
	$(IP_PATH)/src/axi_request_block.sv\
	$(IP_PATH)/src/axi_response_block.sv\
	$(IP_PATH)/src/axi_RR_Flag_Req.sv
SRC_VHDL_AXI_NODE=

ncompile-subip-axi_node: $(LIB_PATH)/axi_node.nmake

$(LIB_PATH)/axi_node.nmake: $(SRC_SVLOG_AXI_NODE) $(SRC_VHDL_AXI_NODE)
	$(call subip_echo,axi_node)
	$(SVLOG_CC) -makelib ./ncsim_libs    $(INCDIR_AXI_NODE) $(SRC_SVLOG_AXI_NODE) -endlib

	echo $(LIB_PATH)/axi_node.nmake

