#
# Copyright (C) 2015-2019 ETH Zurich, University of Bologna
# All rights reserved.
#
# This software may be modified and distributed under the terms
# of the BSD license.  See the LICENSE file for details.
#

IP=timer_unit
IP_PATH=$(IPS_PATH)/timer_unit
LIB_NAME=$(IP)_lib

include ncompile/build.mk

.PHONY: ncompile-$(IP) ncompile-subip-timer_unit 

ncompile-$(IP): $(LIB_PATH)/_nmake

$(LIB_PATH)/_nmake : $(LIB_PATH)/timer_unit.nmake 
	echo $(LIB_PATH)/_nmake


# timer_unit component
INCDIR_TIMER_UNIT=+incdir+$(IP_PATH)/rtl
SRC_SVLOG_TIMER_UNIT=\
	$(IP_PATH)/./rtl/apb_timer_unit.sv\
	$(IP_PATH)/./rtl/timer_unit.sv\
	$(IP_PATH)/./rtl/timer_unit_counter.sv\
	$(IP_PATH)/./rtl/timer_unit_counter_presc.sv
SRC_VHDL_TIMER_UNIT=

ncompile-subip-timer_unit: $(LIB_PATH)/timer_unit.nmake

$(LIB_PATH)/timer_unit.nmake: $(SRC_SVLOG_TIMER_UNIT) $(SRC_VHDL_TIMER_UNIT)
	$(call subip_echo,timer_unit)
	$(SVLOG_CC) -makelib ./ncsim_libs    $(INCDIR_TIMER_UNIT) $(SRC_SVLOG_TIMER_UNIT) -endlib

	echo $(LIB_PATH)/timer_unit.nmake

