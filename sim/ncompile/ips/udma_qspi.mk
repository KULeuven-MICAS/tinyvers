#
# Copyright (C) 2015-2019 ETH Zurich, University of Bologna
# All rights reserved.
#
# This software may be modified and distributed under the terms
# of the BSD license.  See the LICENSE file for details.
#

IP=udma_qspi
IP_PATH=$(IPS_PATH)/udma/udma_qspi
LIB_NAME=$(IP)_lib

include ncompile/build.mk

.PHONY: ncompile-$(IP) ncompile-subip-udma_qspi 

ncompile-$(IP): $(LIB_PATH)/_nmake

$(LIB_PATH)/_nmake : $(LIB_PATH)/udma_qspi.nmake 
	echo $(LIB_PATH)/_nmake


# udma_qspi component
INCDIR_UDMA_QSPI=+incdir+$(IP_PATH)/rtl
SRC_SVLOG_UDMA_QSPI=\
	$(IP_PATH)/rtl/udma_spim_reg_if.sv\
	$(IP_PATH)/rtl/udma_spim_ctrl.sv\
	$(IP_PATH)/rtl/udma_spim_txrx.sv\
	$(IP_PATH)/rtl/udma_spim_top.sv
SRC_VHDL_UDMA_QSPI=

ncompile-subip-udma_qspi: $(LIB_PATH)/udma_qspi.nmake

$(LIB_PATH)/udma_qspi.nmake: $(SRC_SVLOG_UDMA_QSPI) $(SRC_VHDL_UDMA_QSPI)
	$(call subip_echo,udma_qspi)
	$(SVLOG_CC) -makelib ./ncsim_libs    $(INCDIR_UDMA_QSPI) $(SRC_SVLOG_UDMA_QSPI) -endlib

	echo $(LIB_PATH)/udma_qspi.nmake

