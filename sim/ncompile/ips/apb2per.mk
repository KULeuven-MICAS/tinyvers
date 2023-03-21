#
# Copyright (C) 2015-2019 ETH Zurich, University of Bologna
# All rights reserved.
#
# This software may be modified and distributed under the terms
# of the BSD license.  See the LICENSE file for details.
#

IP=apb2per
IP_PATH=$(IPS_PATH)/apb/apb2per
LIB_NAME=$(IP)_lib

include ncompile/build.mk

.PHONY: ncompile-$(IP) ncompile-subip-apb2per 

ncompile-$(IP): $(LIB_PATH)/_nmake

$(LIB_PATH)/_nmake : $(LIB_PATH)/apb2per.nmake 
	echo $(LIB_PATH)/_nmake


SRC_SVLOG_APB2PER=\
	$(IP_PATH)/apb2per.sv
SRC_VHDL_APB2PER=

ncompile-subip-apb2per: $(LIB_PATH)/apb2per.nmake

$(LIB_PATH)/apb2per.nmake: $(SRC_SVLOG_APB2PER) $(SRC_VHDL_APB2PER)
	$(call subip_echo,apb2per)
	$(SVLOG_CC) -makelib ./ncsim_libs    $(INCDIR_APB2PER) $(SRC_SVLOG_APB2PER) -endlib

	echo $(LIB_PATH)/apb2per.nmake

