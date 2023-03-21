#
# Copyright (C) 2015-2019 ETH Zurich, University of Bologna
# All rights reserved.
#
# This software may be modified and distributed under the terms
# of the BSD license.  See the LICENSE file for details.
#

IP=udma_core
IP_PATH=$(IPS_PATH)/udma/udma_core
LIB_NAME=$(IP)_lib

include ncompile/build.mk

.PHONY: ncompile-$(IP) ncompile-subip-udma_core 

ncompile-$(IP): $(LIB_PATH)/_nmake

$(LIB_PATH)/_nmake : $(LIB_PATH)/udma_core.nmake 
	echo $(LIB_PATH)/_nmake


# udma_core component
INCDIR_UDMA_CORE=+incdir+$(IP_PATH)/./rtl
SRC_SVLOG_UDMA_CORE=\
	$(IP_PATH)/rtl/core/udma_ch_addrgen.sv\
	$(IP_PATH)/rtl/core/udma_arbiter.sv\
	$(IP_PATH)/rtl/core/udma_core.sv\
	$(IP_PATH)/rtl/core/udma_rx_channels.sv\
	$(IP_PATH)/rtl/core/udma_tx_channels.sv\
	$(IP_PATH)/rtl/core/udma_stream_unit.sv\
	$(IP_PATH)/rtl/common/udma_ctrl.sv\
	$(IP_PATH)/rtl/common/udma_apb_if.sv\
	$(IP_PATH)/rtl/common/io_clk_gen.sv\
	$(IP_PATH)/rtl/common/io_event_counter.sv\
	$(IP_PATH)/rtl/common/io_generic_fifo.sv\
	$(IP_PATH)/rtl/common/io_tx_fifo.sv\
	$(IP_PATH)/rtl/common/io_tx_fifo_mark.sv\
	$(IP_PATH)/rtl/common/io_tx_fifo_dc.sv\
	$(IP_PATH)/rtl/common/io_shiftreg.sv\
	$(IP_PATH)/rtl/common/udma_dc_fifo.sv\
	$(IP_PATH)/rtl/common/udma_clkgen.sv\
	$(IP_PATH)/rtl/common/udma_clk_div_cnt.sv
SRC_VHDL_UDMA_CORE=

ncompile-subip-udma_core: $(LIB_PATH)/udma_core.nmake

$(LIB_PATH)/udma_core.nmake: $(SRC_SVLOG_UDMA_CORE) $(SRC_VHDL_UDMA_CORE)
	$(call subip_echo,udma_core)
	$(SVLOG_CC) -makelib ./ncsim_libs    $(INCDIR_UDMA_CORE) $(SRC_SVLOG_UDMA_CORE) -endlib

	echo $(LIB_PATH)/udma_core.nmake

