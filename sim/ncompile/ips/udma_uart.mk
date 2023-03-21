#
# Copyright (C) 2015-2019 ETH Zurich, University of Bologna
# All rights reserved.
#
# This software may be modified and distributed under the terms
# of the BSD license.  See the LICENSE file for details.
#

IP=udma_uart
IP_PATH=$(IPS_PATH)/udma/udma_uart
LIB_NAME=$(IP)_lib

include ncompile/build.mk

.PHONY: ncompile-$(IP) ncompile-subip-udma_uart 

ncompile-$(IP): $(LIB_PATH)/_nmake

$(LIB_PATH)/_nmake : $(LIB_PATH)/udma_uart.nmake 
	echo $(LIB_PATH)/_nmake


SRC_SVLOG_UDMA_UART=\
	$(IP_PATH)/rtl/udma_uart_reg_if.sv\
	$(IP_PATH)/rtl/udma_uart_top.sv\
	$(IP_PATH)/rtl/udma_uart_rx.sv\
	$(IP_PATH)/rtl/udma_uart_tx.sv
SRC_VHDL_UDMA_UART=

ncompile-subip-udma_uart: $(LIB_PATH)/udma_uart.nmake

$(LIB_PATH)/udma_uart.nmake: $(SRC_SVLOG_UDMA_UART) $(SRC_VHDL_UDMA_UART)
	$(call subip_echo,udma_uart)
	$(SVLOG_CC) -makelib ./ncsim_libs    $(INCDIR_UDMA_UART) $(SRC_SVLOG_UDMA_UART) -endlib

	echo $(LIB_PATH)/udma_uart.nmake

