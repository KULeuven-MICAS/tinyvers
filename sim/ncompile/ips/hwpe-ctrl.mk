#
# Copyright (C) 2015-2019 ETH Zurich, University of Bologna
# All rights reserved.
#
# This software may be modified and distributed under the terms
# of the BSD license.  See the LICENSE file for details.
#

IP=hwpe_ctrl
IP_PATH=$(IPS_PATH)/hwpe-ctrl
LIB_NAME=$(IP)_lib

include ncompile/build.mk

.PHONY: ncompile-$(IP) ncompile-subip-hwpe-ctrl ncompile-subip-tb_hwpe_ctrl 

ncompile-$(IP): $(LIB_PATH)/_nmake

$(LIB_PATH)/_nmake : $(LIB_PATH)/hwpe-ctrl.nmake $(LIB_PATH)/tb_hwpe_ctrl.nmake 
	echo $(LIB_PATH)/_nmake


# hwpe-ctrl component
INCDIR_HWPE-CTRL=+incdir+$(IP_PATH)/rtl
SRC_SVLOG_HWPE-CTRL=\
	$(IP_PATH)/rtl/hwpe_ctrl_package.sv\
	$(IP_PATH)/rtl/hwpe_ctrl_interfaces.sv\
	$(IP_PATH)/rtl/hwpe_ctrl_regfile.sv\
	$(IP_PATH)/rtl/hwpe_ctrl_regfile_latch.sv\
	$(IP_PATH)/rtl/hwpe_ctrl_slave.sv\
	$(IP_PATH)/rtl/hwpe_ctrl_seq_mult.sv\
	$(IP_PATH)/rtl/hwpe_ctrl_ucode.sv
SRC_VHDL_HWPE-CTRL=

ncompile-subip-hwpe-ctrl: $(LIB_PATH)/hwpe-ctrl.nmake

$(LIB_PATH)/hwpe-ctrl.nmake: $(SRC_SVLOG_HWPE-CTRL) $(SRC_VHDL_HWPE-CTRL)
	$(call subip_echo,hwpe-ctrl)
	$(SVLOG_CC) -makelib ./ncsim_libs    $(INCDIR_HWPE-CTRL) $(SRC_SVLOG_HWPE-CTRL) -endlib

	echo $(LIB_PATH)/hwpe-ctrl.nmake

SRC_SVLOG_TB_HWPE_CTRL=\
	$(IP_PATH)/tb/tb_hwpe_ctrl_seq_mult.sv
SRC_VHDL_TB_HWPE_CTRL=

ncompile-subip-tb_hwpe_ctrl: $(LIB_PATH)/tb_hwpe_ctrl.nmake

$(LIB_PATH)/tb_hwpe_ctrl.nmake: $(SRC_SVLOG_TB_HWPE_CTRL) $(SRC_VHDL_TB_HWPE_CTRL)
	$(call subip_echo,tb_hwpe_ctrl)
	$(SVLOG_CC) -makelib ./ncsim_libs    $(INCDIR_TB_HWPE_CTRL) $(SRC_SVLOG_TB_HWPE_CTRL) -endlib

	echo $(LIB_PATH)/tb_hwpe_ctrl.nmake

