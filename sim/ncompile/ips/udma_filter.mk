#
# Copyright (C) 2015-2019 ETH Zurich, University of Bologna
# All rights reserved.
#
# This software may be modified and distributed under the terms
# of the BSD license.  See the LICENSE file for details.
#

IP=udma_filter
IP_PATH=$(IPS_PATH)/udma/udma_filter
LIB_NAME=$(IP)_lib

include ncompile/build.mk

.PHONY: ncompile-$(IP) ncompile-subip-udma_filter 

ncompile-$(IP): $(LIB_PATH)/_nmake

$(LIB_PATH)/_nmake : $(LIB_PATH)/udma_filter.nmake 
	echo $(LIB_PATH)/_nmake


SRC_SVLOG_UDMA_FILTER=\
	$(IP_PATH)/rtl/udma_filter_au.sv\
	$(IP_PATH)/rtl/udma_filter_bincu.sv\
	$(IP_PATH)/rtl/udma_filter_rx_dataout.sv\
	$(IP_PATH)/rtl/udma_filter_tx_datafetch.sv\
	$(IP_PATH)/rtl/udma_filter_reg_if.sv\
	$(IP_PATH)/rtl/udma_filter.sv
SRC_VHDL_UDMA_FILTER=

ncompile-subip-udma_filter: $(LIB_PATH)/udma_filter.nmake

$(LIB_PATH)/udma_filter.nmake: $(SRC_SVLOG_UDMA_FILTER) $(SRC_VHDL_UDMA_FILTER)
	$(call subip_echo,udma_filter)
	$(SVLOG_CC) -makelib ./ncsim_libs    $(INCDIR_UDMA_FILTER) $(SRC_SVLOG_UDMA_FILTER) -endlib

	echo $(LIB_PATH)/udma_filter.nmake

