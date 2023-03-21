#
# Copyright (C) 2015-2019 ETH Zurich, University of Bologna
# All rights reserved.
#
# This software may be modified and distributed under the terms
# of the BSD license.  See the LICENSE file for details.
#

IP=apb_node
IP_PATH=$(IPS_PATH)/apb/apb_node
LIB_NAME=$(IP)_lib

include ncompile/build.mk

.PHONY: ncompile-$(IP) ncompile-subip-apb_node 

ncompile-$(IP): $(LIB_PATH)/_nmake

$(LIB_PATH)/_nmake : $(LIB_PATH)/apb_node.nmake 
	echo $(LIB_PATH)/_nmake


SRC_SVLOG_APB_NODE=\
	$(IP_PATH)/src/apb_node.sv\
	$(IP_PATH)/src/apb_node_wrap.sv
SRC_VHDL_APB_NODE=

ncompile-subip-apb_node: $(LIB_PATH)/apb_node.nmake

$(LIB_PATH)/apb_node.nmake: $(SRC_SVLOG_APB_NODE) $(SRC_VHDL_APB_NODE)
	$(call subip_echo,apb_node)
	$(SVLOG_CC) -makelib ./ncsim_libs    $(INCDIR_APB_NODE) $(SRC_SVLOG_APB_NODE) -endlib

	echo $(LIB_PATH)/apb_node.nmake

