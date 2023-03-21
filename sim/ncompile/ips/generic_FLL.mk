#
# Copyright (C) 2015-2019 ETH Zurich, University of Bologna
# All rights reserved.
#
# This software may be modified and distributed under the terms
# of the BSD license.  See the LICENSE file for details.
#

IP=generic_FLL
IP_PATH=$(IPS_PATH)/generic_FLL
LIB_NAME=$(IP)_lib

include ncompile/build.mk

.PHONY: ncompile-$(IP) ncompile-subip-fll 

ncompile-$(IP): $(LIB_PATH)/_nmake

$(LIB_PATH)/_nmake : $(LIB_PATH)/fll.nmake 
	echo $(LIB_PATH)/_nmake


SRC_SVLOG_FLL=
SRC_VHDL_FLL=\
	$(IP_PATH)/fe/model/gf22_DCO_model.tc.vhd\
	$(IP_PATH)/fe/model/gf22_FLL_model.vhd\
	$(IP_PATH)/fe/rtl/FLLPkg.vhd\
	$(IP_PATH)/fe/rtl/FLL_clk_divider.vhd\
	$(IP_PATH)/fe/rtl/FLL_clk_period_quantizer.vhd\
	$(IP_PATH)/fe/rtl/FLL_clock_gated.rtl.vhd\
	$(IP_PATH)/fe/rtl/FLL_digital.vhd\
	$(IP_PATH)/fe/rtl/FLL_dither_pattern_gen.vhd\
	$(IP_PATH)/fe/rtl/FLL_glitchfree_clkdiv.vhd\
	$(IP_PATH)/fe/rtl/FLL_glitchfree_clkmux.vhd\
	$(IP_PATH)/fe/rtl/FLL_mux.rtl.vhd\
	$(IP_PATH)/fe/rtl/FLL_loop_filter.vhd\
	$(IP_PATH)/fe/rtl/FLL_reg.vhd\
	$(IP_PATH)/fe/rtl/FLL_settling_monitor.vhd\
	$(IP_PATH)/fe/rtl/FLL_synchroedge.vhd\
	$(IP_PATH)/fe/rtl/FLL_zerodelta.vhd

ncompile-subip-fll: $(LIB_PATH)/fll.nmake

$(LIB_PATH)/fll.nmake: $(SRC_SVLOG_FLL) $(SRC_VHDL_FLL)
	$(call subip_echo,fll)
	$(VHDL_CC) -makelib ./ncsim_libs   $(SRC_VHDL_FLL) -endlib

	echo $(LIB_PATH)/fll.nmake

