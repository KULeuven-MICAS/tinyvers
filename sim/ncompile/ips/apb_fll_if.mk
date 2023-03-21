#
# Copyright (C) 2015-2019 ETH Zurich, University of Bologna
# All rights reserved.
#
# This software may be modified and distributed under the terms
# of the BSD license.  See the LICENSE file for details.
#

IP=apb_fll_if
IP_PATH=$(IPS_PATH)/apb/apb_fll_if
LIB_NAME=$(IP)_lib

include ncompile/build.mk

.PHONY: ncompile-$(IP) ncompile-subip-apb_fll_if 

ncompile-$(IP): $(LIB_PATH)/_nmake

$(LIB_PATH)/_nmake : $(LIB_PATH)/apb_fll_if.nmake 
	echo $(LIB_PATH)/_nmake


SRC_SVLOG_APB_FLL_IF=\
	$(IP_PATH)/apb_fll_if.sv
SRC_VHDL_APB_FLL_IF=

ncompile-subip-apb_fll_if: $(LIB_PATH)/apb_fll_if.nmake

$(LIB_PATH)/apb_fll_if.nmake: $(SRC_SVLOG_APB_FLL_IF) $(SRC_VHDL_APB_FLL_IF)
	$(call subip_echo,apb_fll_if)
	$(SVLOG_CC) -makelib ./ncsim_libs    $(INCDIR_APB_FLL_IF) $(SRC_SVLOG_APB_FLL_IF) -endlib

	echo $(LIB_PATH)/apb_fll_if.nmake

