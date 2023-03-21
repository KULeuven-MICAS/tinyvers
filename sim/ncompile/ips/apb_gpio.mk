#
# Copyright (C) 2015-2019 ETH Zurich, University of Bologna
# All rights reserved.
#
# This software may be modified and distributed under the terms
# of the BSD license.  See the LICENSE file for details.
#

IP=apb_gpio
IP_PATH=$(IPS_PATH)/apb/apb_gpio
LIB_NAME=$(IP)_lib

include ncompile/build.mk

.PHONY: ncompile-$(IP) ncompile-subip-apb_gpio 

ncompile-$(IP): $(LIB_PATH)/_nmake

$(LIB_PATH)/_nmake : $(LIB_PATH)/apb_gpio.nmake 
	echo $(LIB_PATH)/_nmake


SRC_SVLOG_APB_GPIO=\
	$(IP_PATH)/./rtl/apb_gpio.sv
SRC_VHDL_APB_GPIO=

ncompile-subip-apb_gpio: $(LIB_PATH)/apb_gpio.nmake

$(LIB_PATH)/apb_gpio.nmake: $(SRC_SVLOG_APB_GPIO) $(SRC_VHDL_APB_GPIO)
	$(call subip_echo,apb_gpio)
	$(SVLOG_CC) -makelib ./ncsim_libs    $(INCDIR_APB_GPIO) $(SRC_SVLOG_APB_GPIO) -endlib

	echo $(LIB_PATH)/apb_gpio.nmake

