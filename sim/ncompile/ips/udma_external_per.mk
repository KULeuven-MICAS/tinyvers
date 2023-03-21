#
# Copyright (C) 2015-2019 ETH Zurich, University of Bologna
# All rights reserved.
#
# This software may be modified and distributed under the terms
# of the BSD license.  See the LICENSE file for details.
#

IP=udma_external_per
IP_PATH=$(IPS_PATH)/udma/udma_external_per
LIB_NAME=$(IP)_lib

include ncompile/build.mk

.PHONY: ncompile-$(IP) ncompile-subip-udma_external_per 

ncompile-$(IP): $(LIB_PATH)/_nmake

$(LIB_PATH)/_nmake : $(LIB_PATH)/udma_external_per.nmake 
	echo $(LIB_PATH)/_nmake


SRC_SVLOG_UDMA_EXTERNAL_PER=\
	$(IP_PATH)/rtl/RX_serializer.sv\
	$(IP_PATH)/rtl/udma_mram_reg_if.sv\
	$(IP_PATH)/rtl/udma_mram_top.sv\
	$(IP_PATH)/rtl/size_conv_TX_32_to_64.sv\
	$(IP_PATH)/rtl/size_conv_RX_64_to_32.sv\
	$(IP_PATH)/rtl/TX_RX_to_MRAM.sv\
	$(IP_PATH)/rtl/udma_dc_fifo_mram.sv\
	$(IP_PATH)/rtl/dc_token_ring_fifo_din_mram.v\
	$(IP_PATH)/rtl/dc_full_detector_mram.v\
	$(IP_PATH)/rtl/udma_mram_macro_wrapper.sv\
	$(IP_PATH)/rtl/udma_mram_domain.sv\
	$(IP_PATH)/rtl/udma_mram_top_wrapper.sv
SRC_VHDL_UDMA_EXTERNAL_PER=

ncompile-subip-udma_external_per: $(LIB_PATH)/udma_external_per.nmake

$(LIB_PATH)/udma_external_per.nmake: $(SRC_SVLOG_UDMA_EXTERNAL_PER) $(SRC_VHDL_UDMA_EXTERNAL_PER)
	$(call subip_echo,udma_external_per)
	$(SVLOG_CC) -makelib ./ncsim_libs    $(INCDIR_UDMA_EXTERNAL_PER) $(SRC_SVLOG_UDMA_EXTERNAL_PER) -endlib

	echo $(LIB_PATH)/udma_external_per.nmake

