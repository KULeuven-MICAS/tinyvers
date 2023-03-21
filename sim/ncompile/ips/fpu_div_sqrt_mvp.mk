#
# Copyright (C) 2015-2019 ETH Zurich, University of Bologna
# All rights reserved.
#
# This software may be modified and distributed under the terms
# of the BSD license.  See the LICENSE file for details.
#

IP=fpu_div_sqrt_mvp
IP_PATH=$(IPS_PATH)/fpu_div_sqrt_mvp
LIB_NAME=$(IP)_lib

include ncompile/build.mk

.PHONY: ncompile-$(IP) ncompile-subip-div_sqrt_top_mvp 

ncompile-$(IP): $(LIB_PATH)/_nmake

$(LIB_PATH)/_nmake : $(LIB_PATH)/div_sqrt_top_mvp.nmake 
	echo $(LIB_PATH)/_nmake


SRC_SVLOG_DIV_SQRT_TOP_MVP=\
	$(IP_PATH)/hdl/defs_div_sqrt_mvp.sv\
	$(IP_PATH)/hdl/control_mvp.sv\
	$(IP_PATH)/hdl/div_sqrt_mvp_wrapper.sv\
	$(IP_PATH)/hdl/div_sqrt_top_mvp.sv\
	$(IP_PATH)/hdl/iteration_div_sqrt_mvp.sv\
	$(IP_PATH)/hdl/norm_div_sqrt_mvp.sv\
	$(IP_PATH)/hdl/nrbd_nrsc_mvp.sv\
	$(IP_PATH)/hdl/preprocess_mvp.sv
SRC_VHDL_DIV_SQRT_TOP_MVP=

ncompile-subip-div_sqrt_top_mvp: $(LIB_PATH)/div_sqrt_top_mvp.nmake

$(LIB_PATH)/div_sqrt_top_mvp.nmake: $(SRC_SVLOG_DIV_SQRT_TOP_MVP) $(SRC_VHDL_DIV_SQRT_TOP_MVP)
	$(call subip_echo,div_sqrt_top_mvp)
	$(SVLOG_CC) -makelib ./ncsim_libs    $(INCDIR_DIV_SQRT_TOP_MVP) $(SRC_SVLOG_DIV_SQRT_TOP_MVP) -endlib

	echo $(LIB_PATH)/div_sqrt_top_mvp.nmake

