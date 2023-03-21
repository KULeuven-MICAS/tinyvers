#
# Copyright (C) 2015-2019 ETH Zurich, University of Bologna
# All rights reserved.
#
# This software may be modified and distributed under the terms
# of the BSD license.  See the LICENSE file for details.
#

IP=udma_i2c
IP_PATH=$(IPS_PATH)/udma/udma_i2c
LIB_NAME=$(IP)_lib

include ncompile/build.mk

.PHONY: ncompile-$(IP) ncompile-subip-udma_i2c 

ncompile-$(IP): $(LIB_PATH)/_nmake

$(LIB_PATH)/_nmake : $(LIB_PATH)/udma_i2c.nmake 
	echo $(LIB_PATH)/_nmake


SRC_SVLOG_UDMA_I2C=\
	$(IP_PATH)/rtl/udma_i2c_reg_if.sv\
	$(IP_PATH)/rtl/udma_i2c_bus_ctrl.sv\
	$(IP_PATH)/rtl/udma_i2c_control.sv\
	$(IP_PATH)/rtl/udma_i2c_top.sv
SRC_VHDL_UDMA_I2C=

ncompile-subip-udma_i2c: $(LIB_PATH)/udma_i2c.nmake

$(LIB_PATH)/udma_i2c.nmake: $(SRC_SVLOG_UDMA_I2C) $(SRC_VHDL_UDMA_I2C)
	$(call subip_echo,udma_i2c)
	$(SVLOG_CC) -makelib ./ncsim_libs    $(INCDIR_UDMA_I2C) $(SRC_SVLOG_UDMA_I2C) -endlib

	echo $(LIB_PATH)/udma_i2c.nmake

