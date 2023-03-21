#
# Copyright (C) 2015-2019 ETH Zurich, University of Bologna
# All rights reserved.
#
# This software may be modified and distributed under the terms
# of the BSD license.  See the LICENSE file for details.
#

IP=fpnew
IP_PATH=$(IPS_PATH)/fpnew
LIB_NAME=$(IP)_lib

include ncompile/build.mk

.PHONY: ncompile-$(IP) ncompile-subip-fpnew 

ncompile-$(IP): $(LIB_PATH)/_nmake

$(LIB_PATH)/_nmake : $(LIB_PATH)/fpnew.nmake 
	echo $(LIB_PATH)/_nmake


# fpnew component
INCDIR_FPNEW=+incdir+$(IP_PATH)/../common_cells/include
SRC_SVLOG_FPNEW=\
	$(IP_PATH)/src/fpnew_pkg.sv\
	$(IP_PATH)/src/fpnew_cast_multi.sv\
	$(IP_PATH)/src/fpnew_classifier.sv\
	$(IP_PATH)/src/fpnew_divsqrt_multi.sv\
	$(IP_PATH)/src/fpnew_fma.sv\
	$(IP_PATH)/src/fpnew_fma_multi.sv\
	$(IP_PATH)/src/fpnew_noncomp.sv\
	$(IP_PATH)/src/fpnew_opgroup_block.sv\
	$(IP_PATH)/src/fpnew_opgroup_fmt_slice.sv\
	$(IP_PATH)/src/fpnew_opgroup_multifmt_slice.sv\
	$(IP_PATH)/src/fpnew_rounding.sv\
	$(IP_PATH)/src/fpnew_top.sv
SRC_VHDL_FPNEW=

ncompile-subip-fpnew: $(LIB_PATH)/fpnew.nmake

$(LIB_PATH)/fpnew.nmake: $(SRC_SVLOG_FPNEW) $(SRC_VHDL_FPNEW)
	$(call subip_echo,fpnew)
	$(SVLOG_CC) -makelib ./ncsim_libs    $(INCDIR_FPNEW) $(SRC_SVLOG_FPNEW) -endlib

	echo $(LIB_PATH)/fpnew.nmake

