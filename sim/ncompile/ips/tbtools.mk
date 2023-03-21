#
# Copyright (C) 2015-2019 ETH Zurich, University of Bologna
# All rights reserved.
#
# This software may be modified and distributed under the terms
# of the BSD license.  See the LICENSE file for details.
#

IP=tbtools
IP_PATH=$(IPS_PATH)/tbtools
LIB_NAME=$(IP)_lib

include ncompile/build.mk

.PHONY: ncompile-$(IP) ncompile-subip-tbtools 

ncompile-$(IP): $(LIB_PATH)/_nmake

$(LIB_PATH)/_nmake : $(LIB_PATH)/tbtools.nmake 
	echo $(LIB_PATH)/_nmake


SRC_SVLOG_TBTOOLS=\
	$(IP_PATH)/dpi_models/dpi_models.sv\
	$(IP_PATH)/tb_driver/tb_driver.sv
SRC_VHDL_TBTOOLS=

ncompile-subip-tbtools: $(LIB_PATH)/tbtools.nmake

$(LIB_PATH)/tbtools.nmake: $(SRC_SVLOG_TBTOOLS) $(SRC_VHDL_TBTOOLS)
	$(call subip_echo,tbtools)
	$(SVLOG_CC) -makelib ./ncsim_libs    $(INCDIR_TBTOOLS) $(SRC_SVLOG_TBTOOLS) -endlib

	echo $(LIB_PATH)/tbtools.nmake

