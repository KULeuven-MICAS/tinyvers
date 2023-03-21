#
# Copyright (C) 2015-2019 ETH Zurich, University of Bologna
# All rights reserved.
#
# This software may be modified and distributed under the terms
# of the BSD license.  See the LICENSE file for details.
#

IP=udma_camera
IP_PATH=$(IPS_PATH)/udma/udma_camera
LIB_NAME=$(IP)_lib

include ncompile/build.mk

.PHONY: ncompile-$(IP) ncompile-subip-udma_camera 

ncompile-$(IP): $(LIB_PATH)/_nmake

$(LIB_PATH)/_nmake : $(LIB_PATH)/udma_camera.nmake 
	echo $(LIB_PATH)/_nmake


SRC_SVLOG_UDMA_CAMERA=\
	$(IP_PATH)/rtl/camera_reg_if.sv\
	$(IP_PATH)/rtl/camera_if.sv
SRC_VHDL_UDMA_CAMERA=

ncompile-subip-udma_camera: $(LIB_PATH)/udma_camera.nmake

$(LIB_PATH)/udma_camera.nmake: $(SRC_SVLOG_UDMA_CAMERA) $(SRC_VHDL_UDMA_CAMERA)
	$(call subip_echo,udma_camera)
	$(SVLOG_CC) -makelib ./ncsim_libs    $(INCDIR_UDMA_CAMERA) $(SRC_SVLOG_UDMA_CAMERA) -endlib

	echo $(LIB_PATH)/udma_camera.nmake

