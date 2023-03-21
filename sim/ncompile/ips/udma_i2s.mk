#
# Copyright (C) 2015-2019 ETH Zurich, University of Bologna
# All rights reserved.
#
# This software may be modified and distributed under the terms
# of the BSD license.  See the LICENSE file for details.
#

IP=udma_i2s
IP_PATH=$(IPS_PATH)/udma/udma_i2s
LIB_NAME=$(IP)_lib

include ncompile/build.mk

.PHONY: ncompile-$(IP) ncompile-subip-udma_i2s 

ncompile-$(IP): $(LIB_PATH)/_nmake

$(LIB_PATH)/_nmake : $(LIB_PATH)/udma_i2s.nmake 
	echo $(LIB_PATH)/_nmake


SRC_SVLOG_UDMA_I2S=\
	$(IP_PATH)/rtl/i2s_clk_gen.sv\
	$(IP_PATH)/rtl/i2s_rx_channel.sv\
	$(IP_PATH)/rtl/i2s_tx_channel.sv\
	$(IP_PATH)/rtl/i2s_ws_gen.sv\
	$(IP_PATH)/rtl/i2s_clkws_gen.sv\
	$(IP_PATH)/rtl/i2s_txrx.sv\
	$(IP_PATH)/rtl/cic_top.sv\
	$(IP_PATH)/rtl/cic_integrator.sv\
	$(IP_PATH)/rtl/cic_comb.sv\
	$(IP_PATH)/rtl/pdm_top.sv\
	$(IP_PATH)/rtl/udma_i2s_reg_if.sv\
	$(IP_PATH)/rtl/udma_i2s_top.sv
SRC_VHDL_UDMA_I2S=

ncompile-subip-udma_i2s: $(LIB_PATH)/udma_i2s.nmake

$(LIB_PATH)/udma_i2s.nmake: $(SRC_SVLOG_UDMA_I2S) $(SRC_VHDL_UDMA_I2S)
	$(call subip_echo,udma_i2s)
	$(SVLOG_CC) -makelib ./ncsim_libs    $(INCDIR_UDMA_I2S) $(SRC_SVLOG_UDMA_I2S) -endlib

	echo $(LIB_PATH)/udma_i2s.nmake

