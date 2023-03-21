#
# Copyright (C) 2015-2019 ETH Zurich, University of Bologna
# All rights reserved.
#
# This software may be modified and distributed under the terms
# of the BSD license.  See the LICENSE file for details.
#

IP=vip
IP_PATH=$(RTL_PATH)/vip
LIB_NAME=$(IP)_lib

include ncompile/build.mk

.PHONY: ncompile-$(IP) ncompile-subip-open_models 

ncompile-$(IP): $(LIB_PATH)/_nmake

$(LIB_PATH)/_nmake : $(LIB_PATH)/open_models.nmake 
	echo $(LIB_PATH)/_nmake


SRC_SVLOG_OPEN_MODELS=\
	$(IP_PATH)/spi_master_padframe.sv\
	$(IP_PATH)/uart_tb_rx.sv\
	$(IP_PATH)/camera/cam_vip.sv
SRC_VHDL_OPEN_MODELS=

ncompile-subip-open_models: $(LIB_PATH)/open_models.nmake

$(LIB_PATH)/open_models.nmake: $(SRC_SVLOG_OPEN_MODELS) $(SRC_VHDL_OPEN_MODELS)
	$(call subip_echo,open_models)
	$(SVLOG_CC) -makelib ./ncsim_libs    $(INCDIR_OPEN_MODELS) $(SRC_SVLOG_OPEN_MODELS) -endlib

	echo $(LIB_PATH)/open_models.nmake

