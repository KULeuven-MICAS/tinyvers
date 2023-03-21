#
# Copyright (C) 2015-2019 ETH Zurich, University of Bologna
# All rights reserved.
#
# This software may be modified and distributed under the terms
# of the BSD license.  See the LICENSE file for details.
#

IP=adv_dbg_if
IP_PATH=$(IPS_PATH)/adv_dbg_if
LIB_NAME=$(IP)_lib

include ncompile/build.mk

.PHONY: ncompile-$(IP) ncompile-subip-adv_dbg_if 

ncompile-$(IP): $(LIB_PATH)/_nmake

$(LIB_PATH)/_nmake : $(LIB_PATH)/adv_dbg_if.nmake 
	echo $(LIB_PATH)/_nmake


# adv_dbg_if component
INCDIR_ADV_DBG_IF=+incdir+$(IP_PATH)/rtl
SRC_SVLOG_ADV_DBG_IF=\
	$(IP_PATH)/rtl/adbg_axi_biu.sv\
	$(IP_PATH)/rtl/adbg_axi_module.sv\
	$(IP_PATH)/rtl/adbg_lint_biu.sv\
	$(IP_PATH)/rtl/adbg_lint_module.sv\
	$(IP_PATH)/rtl/adbg_crc32.v\
	$(IP_PATH)/rtl/adbg_or1k_biu.sv\
	$(IP_PATH)/rtl/adbg_or1k_module.sv\
	$(IP_PATH)/rtl/adbg_or1k_status_reg.sv\
	$(IP_PATH)/rtl/adbg_top.sv\
	$(IP_PATH)/rtl/bytefifo.v\
	$(IP_PATH)/rtl/syncflop.v\
	$(IP_PATH)/rtl/syncreg.v\
	$(IP_PATH)/rtl/adbg_tap_top.v\
	$(IP_PATH)/rtl/adv_dbg_if.sv\
	$(IP_PATH)/rtl/adbg_axionly_top.sv\
	$(IP_PATH)/rtl/adbg_lintonly_top.sv
SRC_VHDL_ADV_DBG_IF=

ncompile-subip-adv_dbg_if: $(LIB_PATH)/adv_dbg_if.nmake

$(LIB_PATH)/adv_dbg_if.nmake: $(SRC_SVLOG_ADV_DBG_IF) $(SRC_VHDL_ADV_DBG_IF)
	$(call subip_echo,adv_dbg_if)
	$(SVLOG_CC) -makelib ./ncsim_libs    $(INCDIR_ADV_DBG_IF) $(SRC_SVLOG_ADV_DBG_IF) -endlib

	echo $(LIB_PATH)/adv_dbg_if.nmake

