#
# Copyright (C) 2015-2019 ETH Zurich, University of Bologna
# All rights reserved.
#
# This software may be modified and distributed under the terms
# of the BSD license.  See the LICENSE file for details.
#

IP=axi
IP_PATH=$(IPS_PATH)/axi/axi
LIB_NAME=$(IP)_lib

include ncompile/build.mk

.PHONY: ncompile-$(IP) ncompile-subip-axi ncompile-subip-axi_sim 

ncompile-$(IP): $(LIB_PATH)/_nmake

$(LIB_PATH)/_nmake : $(LIB_PATH)/axi.nmake $(LIB_PATH)/axi_sim.nmake 
	echo $(LIB_PATH)/_nmake


SRC_SVLOG_AXI=\
	$(IP_PATH)/src/axi_pkg.sv\
	$(IP_PATH)/src/axi_intf.sv\
	$(IP_PATH)/src/axi_atop_filter.sv\
	$(IP_PATH)/src/axi_arbiter.sv\
	$(IP_PATH)/src/axi_address_resolver.sv\
	$(IP_PATH)/src/axi_to_axi_lite.sv\
	$(IP_PATH)/src/axi_lite_to_axi.sv\
	$(IP_PATH)/src/axi_lite_xbar.sv\
	$(IP_PATH)/src/axi_lite_cut.sv\
	$(IP_PATH)/src/axi_lite_multicut.sv\
	$(IP_PATH)/src/axi_lite_join.sv\
	$(IP_PATH)/src/axi_cut.sv\
	$(IP_PATH)/src/axi_multicut.sv\
	$(IP_PATH)/src/axi_join.sv\
	$(IP_PATH)/src/axi_modify_address.sv\
	$(IP_PATH)/src/axi_delayer.sv\
	$(IP_PATH)/src/axi_id_remap.sv
SRC_VHDL_AXI=

ncompile-subip-axi: $(LIB_PATH)/axi.nmake

$(LIB_PATH)/axi.nmake: $(SRC_SVLOG_AXI) $(SRC_VHDL_AXI)
	$(call subip_echo,axi)
	$(SVLOG_CC) -makelib ./ncsim_libs    $(INCDIR_AXI) $(SRC_SVLOG_AXI) -endlib

	echo $(LIB_PATH)/axi.nmake

SRC_SVLOG_AXI_SIM=\
	$(IP_PATH)/src/axi_test.sv
SRC_VHDL_AXI_SIM=

ncompile-subip-axi_sim: $(LIB_PATH)/axi_sim.nmake

$(LIB_PATH)/axi_sim.nmake: $(SRC_SVLOG_AXI_SIM) $(SRC_VHDL_AXI_SIM)
	$(call subip_echo,axi_sim)
	$(SVLOG_CC) -makelib ./ncsim_libs    $(INCDIR_AXI_SIM) $(SRC_SVLOG_AXI_SIM) -endlib

	echo $(LIB_PATH)/axi_sim.nmake

