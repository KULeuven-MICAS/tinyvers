#
# Copyright (C) 2015-2019 ETH Zurich, University of Bologna
# All rights reserved.
#
# This software may be modified and distributed under the terms
# of the BSD license.  See the LICENSE file for details.
#

IP=ibex
IP_PATH=$(IPS_PATH)/ibex
LIB_NAME=$(IP)_lib

include ncompile/build.mk

.PHONY: ncompile-$(IP) ncompile-subip-ibex ncompile-subip-ibex_vip_rtl ncompile-subip-ibex_regfile_rtl 

ncompile-$(IP): $(LIB_PATH)/_nmake

$(LIB_PATH)/_nmake : $(LIB_PATH)/ibex.nmake $(LIB_PATH)/ibex_vip_rtl.nmake $(LIB_PATH)/ibex_regfile_rtl.nmake 
	echo $(LIB_PATH)/_nmake


# ibex component
INCDIR_IBEX=+incdir+$(IP_PATH)/rtl
SRC_SVLOG_IBEX=\
	$(IP_PATH)/rtl/ibex_pkg.sv\
	$(IP_PATH)/rtl/ibex_alu.sv\
	$(IP_PATH)/rtl/ibex_compressed_decoder.sv\
	$(IP_PATH)/rtl/ibex_controller.sv\
	$(IP_PATH)/rtl/ibex_cs_registers.sv\
	$(IP_PATH)/rtl/ibex_decoder.sv\
	$(IP_PATH)/rtl/ibex_ex_block.sv\
	$(IP_PATH)/rtl/ibex_id_stage.sv\
	$(IP_PATH)/rtl/ibex_if_stage.sv\
	$(IP_PATH)/rtl/ibex_load_store_unit.sv\
	$(IP_PATH)/rtl/ibex_multdiv_slow.sv\
	$(IP_PATH)/rtl/ibex_multdiv_fast.sv\
	$(IP_PATH)/rtl/ibex_prefetch_buffer.sv\
	$(IP_PATH)/rtl/ibex_fetch_fifo.sv\
	$(IP_PATH)/rtl/ibex_pmp.sv\
	$(IP_PATH)/rtl/ibex_core.sv
SRC_VHDL_IBEX=

ncompile-subip-ibex: $(LIB_PATH)/ibex.nmake

$(LIB_PATH)/ibex.nmake: $(SRC_SVLOG_IBEX) $(SRC_VHDL_IBEX)
	$(call subip_echo,ibex)
	$(SVLOG_CC) -makelib ./ncsim_libs    $(INCDIR_IBEX) $(SRC_SVLOG_IBEX) -endlib

	echo $(LIB_PATH)/ibex.nmake

SRC_SVLOG_IBEX_VIP_RTL=\
	$(IP_PATH)/rtl/ibex_pkg.sv\
	$(IP_PATH)/rtl/ibex_tracer_pkg.sv\
	$(IP_PATH)/rtl/ibex_tracer.sv\
	$(IP_PATH)/rtl/ibex_core_tracing.sv
SRC_VHDL_IBEX_VIP_RTL=

ncompile-subip-ibex_vip_rtl: $(LIB_PATH)/ibex_vip_rtl.nmake

$(LIB_PATH)/ibex_vip_rtl.nmake: $(SRC_SVLOG_IBEX_VIP_RTL) $(SRC_VHDL_IBEX_VIP_RTL)
	$(call subip_echo,ibex_vip_rtl)
	$(SVLOG_CC) -makelib ./ncsim_libs    $(INCDIR_IBEX_VIP_RTL) $(SRC_SVLOG_IBEX_VIP_RTL) -endlib

	echo $(LIB_PATH)/ibex_vip_rtl.nmake

SRC_SVLOG_IBEX_REGFILE_RTL=\
	$(IP_PATH)/rtl/ibex_register_file_latch.sv
SRC_VHDL_IBEX_REGFILE_RTL=

ncompile-subip-ibex_regfile_rtl: $(LIB_PATH)/ibex_regfile_rtl.nmake

$(LIB_PATH)/ibex_regfile_rtl.nmake: $(SRC_SVLOG_IBEX_REGFILE_RTL) $(SRC_VHDL_IBEX_REGFILE_RTL)
	$(call subip_echo,ibex_regfile_rtl)
	$(SVLOG_CC) -makelib ./ncsim_libs    $(INCDIR_IBEX_REGFILE_RTL) $(SRC_SVLOG_IBEX_REGFILE_RTL) -endlib

	echo $(LIB_PATH)/ibex_regfile_rtl.nmake


