#
# Copyright (C) 2015-2019 ETH Zurich, University of Bologna
# All rights reserved.
#
# This software may be modified and distributed under the terms
# of the BSD license.  See the LICENSE file for details.
#

IP=jtag_pulp
IP_PATH=$(IPS_PATH)/jtag_pulp
LIB_NAME=$(IP)_lib

include ncompile/build.mk

.PHONY: ncompile-$(IP) ncompile-subip-jtag_pulp 

ncompile-$(IP): $(LIB_PATH)/_nmake

$(LIB_PATH)/_nmake : $(LIB_PATH)/jtag_pulp.nmake 
	echo $(LIB_PATH)/_nmake


# jtag_pulp component
INCDIR_JTAG_PULP=+incdir+$(IP_PATH)/../../rtl/includes
SRC_SVLOG_JTAG_PULP=\
	$(IP_PATH)/src/bscell.sv\
	$(IP_PATH)/src/jtag_axi_wrap.sv\
	$(IP_PATH)/src/jtag_enable.sv\
	$(IP_PATH)/src/jtag_enable_synch.sv\
	$(IP_PATH)/src/jtagreg.sv\
	$(IP_PATH)/src/jtag_rst_synch.sv\
	$(IP_PATH)/src/jtag_sync.sv\
	$(IP_PATH)/src/tap_top.v
SRC_VHDL_JTAG_PULP=

ncompile-subip-jtag_pulp: $(LIB_PATH)/jtag_pulp.nmake

$(LIB_PATH)/jtag_pulp.nmake: $(SRC_SVLOG_JTAG_PULP) $(SRC_VHDL_JTAG_PULP)
	$(call subip_echo,jtag_pulp)
	$(SVLOG_CC) -makelib ./ncsim_libs    $(INCDIR_JTAG_PULP) $(SRC_SVLOG_JTAG_PULP) -endlib

	echo $(LIB_PATH)/jtag_pulp.nmake

