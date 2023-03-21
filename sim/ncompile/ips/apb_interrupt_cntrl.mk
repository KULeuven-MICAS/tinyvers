#
# Copyright (C) 2015-2019 ETH Zurich, University of Bologna
# All rights reserved.
#
# This software may be modified and distributed under the terms
# of the BSD license.  See the LICENSE file for details.
#

IP=apb_interrupt_cntrl
IP_PATH=$(IPS_PATH)/apb_interrupt_cntrl
LIB_NAME=$(IP)_lib

include ncompile/build.mk

.PHONY: ncompile-$(IP) ncompile-subip-apb_interrupt_cntrl 

ncompile-$(IP): $(LIB_PATH)/_nmake

$(LIB_PATH)/_nmake : $(LIB_PATH)/apb_interrupt_cntrl.nmake 
	echo $(LIB_PATH)/_nmake


SRC_SVLOG_APB_INTERRUPT_CNTRL=\
	$(IP_PATH)/apb_interrupt_cntrl.sv
SRC_VHDL_APB_INTERRUPT_CNTRL=

ncompile-subip-apb_interrupt_cntrl: $(LIB_PATH)/apb_interrupt_cntrl.nmake

$(LIB_PATH)/apb_interrupt_cntrl.nmake: $(SRC_SVLOG_APB_INTERRUPT_CNTRL) $(SRC_VHDL_APB_INTERRUPT_CNTRL)
	$(call subip_echo,apb_interrupt_cntrl)
	$(SVLOG_CC) -makelib ./ncsim_libs    $(INCDIR_APB_INTERRUPT_CNTRL) $(SRC_SVLOG_APB_INTERRUPT_CNTRL) -endlib

	echo $(LIB_PATH)/apb_interrupt_cntrl.nmake

