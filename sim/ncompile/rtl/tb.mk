#
# Copyright (C) 2015-2019 ETH Zurich, University of Bologna
# All rights reserved.
#
# This software may be modified and distributed under the terms
# of the BSD license.  See the LICENSE file for details.
#

IP=tb
IP_PATH=$(RTL_PATH)/tb
LIB_NAME=$(IP)_lib

include ncompile/build.mk

.PHONY: ncompile-$(IP) ncompile-subip-tb 

ncompile-$(IP): $(LIB_PATH)/_nmake

$(LIB_PATH)/_nmake : $(LIB_PATH)/tb.nmake 
	echo $(LIB_PATH)/_nmake


SRC_SVLOG_TB=\
	$(IP_PATH)/riscv_pkg.sv\
	$(IP_PATH)/jtag_pkg.sv\
	$(IP_PATH)/pulp_tap_pkg.sv\
	$(IP_PATH)/tb_clk_gen.sv\
	$(IP_PATH)/tb_fs_handler.sv\
	$(IP_PATH)/dpi_models/dpi_models.sv\
	$(IP_PATH)/tb_driver/tb_driver.sv\
	$(IP_PATH)/tb_pulp.sv\
	$(IP_PATH)/SimJTAG.sv\
	$(IP_PATH)/SimDTM.sv
SRC_VHDL_TB=

ncompile-subip-tb: $(LIB_PATH)/tb.nmake

$(LIB_PATH)/tb.nmake: $(SRC_SVLOG_TB) $(SRC_VHDL_TB)
	$(call subip_echo,tb)
	$(SVLOG_CC) -makelib ./ncsim_libs    $(INCDIR_TB) $(SRC_SVLOG_TB) -endlib

	echo $(LIB_PATH)/tb.nmake

