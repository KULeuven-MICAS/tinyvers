#
# Copyright (C) 2015-2019 ETH Zurich, University of Bologna
# All rights reserved.
#
# This software may be modified and distributed under the terms
# of the BSD license.  See the LICENSE file for details.
#

IP=udma_sdio
IP_PATH=$(IPS_PATH)/udma/udma_sdio
LIB_NAME=$(IP)_lib

include ncompile/build.mk

.PHONY: ncompile-$(IP) ncompile-subip-udma_sdio 

ncompile-$(IP): $(LIB_PATH)/_nmake

$(LIB_PATH)/_nmake : $(LIB_PATH)/udma_sdio.nmake 
	echo $(LIB_PATH)/_nmake


SRC_SVLOG_UDMA_SDIO=\
	$(IP_PATH)/rtl/sdio_crc7.sv\
	$(IP_PATH)/rtl/sdio_crc16.sv\
	$(IP_PATH)/rtl/sdio_txrx_cmd.sv\
	$(IP_PATH)/rtl/sdio_txrx_data.sv\
	$(IP_PATH)/rtl/sdio_txrx.sv\
	$(IP_PATH)/rtl/udma_sdio_reg_if.sv\
	$(IP_PATH)/rtl/udma_sdio_top.sv
SRC_VHDL_UDMA_SDIO=

ncompile-subip-udma_sdio: $(LIB_PATH)/udma_sdio.nmake

$(LIB_PATH)/udma_sdio.nmake: $(SRC_SVLOG_UDMA_SDIO) $(SRC_VHDL_UDMA_SDIO)
	$(call subip_echo,udma_sdio)
	$(SVLOG_CC) -makelib ./ncsim_libs    $(INCDIR_UDMA_SDIO) $(SRC_SVLOG_UDMA_SDIO) -endlib

	echo $(LIB_PATH)/udma_sdio.nmake

