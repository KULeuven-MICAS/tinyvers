#
# Copyright (C) 2015-2019 ETH Zurich, University of Bologna
# All rights reserved.
#
# This software may be modified and distributed under the terms
# of the BSD license.  See the LICENSE file for details.
#

IP=apb_adv_timer
IP_PATH=$(IPS_PATH)/apb/apb_adv_timer
LIB_NAME=$(IP)_lib

include ncompile/build.mk

.PHONY: ncompile-$(IP) ncompile-subip-apb_adv_timer 

ncompile-$(IP): $(LIB_PATH)/_nmake

$(LIB_PATH)/_nmake : $(LIB_PATH)/apb_adv_timer.nmake 
	echo $(LIB_PATH)/_nmake


# apb_adv_timer component
INCDIR_APB_ADV_TIMER=+incdir+$(IP_PATH)/./rtl
SRC_SVLOG_APB_ADV_TIMER=\
	$(IP_PATH)/./rtl/adv_timer_apb_if.sv\
	$(IP_PATH)/./rtl/comparator.sv\
	$(IP_PATH)/./rtl/lut_4x4.sv\
	$(IP_PATH)/./rtl/out_filter.sv\
	$(IP_PATH)/./rtl/up_down_counter.sv\
	$(IP_PATH)/./rtl/input_stage.sv\
	$(IP_PATH)/./rtl/prescaler.sv\
	$(IP_PATH)/./rtl/apb_adv_timer.sv\
	$(IP_PATH)/./rtl/timer_cntrl.sv\
	$(IP_PATH)/./rtl/timer_module.sv
SRC_VHDL_APB_ADV_TIMER=

ncompile-subip-apb_adv_timer: $(LIB_PATH)/apb_adv_timer.nmake

$(LIB_PATH)/apb_adv_timer.nmake: $(SRC_SVLOG_APB_ADV_TIMER) $(SRC_VHDL_APB_ADV_TIMER)
	$(call subip_echo,apb_adv_timer)
	$(SVLOG_CC) -makelib ./ncsim_libs    $(INCDIR_APB_ADV_TIMER) $(SRC_SVLOG_APB_ADV_TIMER) -endlib

	echo $(LIB_PATH)/apb_adv_timer.nmake

