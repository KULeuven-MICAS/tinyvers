#
# Copyright (C) 2015-2019 ETH Zurich, University of Bologna
# All rights reserved.
#
# This software may be modified and distributed under the terms
# of the BSD license.  See the LICENSE file for details.
#

IP=pulpissimo
IP_PATH=$(RTL_PATH)/pulpissimo
LIB_NAME=$(IP)_lib

include ncompile/build.mk

.PHONY: ncompile-$(IP) ncompile-subip-pulpissimo 

ncompile-$(IP): $(LIB_PATH)/_nmake

$(LIB_PATH)/_nmake : $(LIB_PATH)/pulpissimo.nmake 
	echo $(LIB_PATH)/_nmake


# pulpissimo component
INCDIR_PULPISSIMO=+incdir+$(IP_PATH)/../includes
SRC_SVLOG_PULPISSIMO=\
	$(IP_PATH)/reg_arstn.sv\
	$(IP_PATH)/PowerGateFSM.sv\
	$(IP_PATH)/PowerGateFSM_MRAM.sv\
	$(IP_PATH)/gf_mem_wrapper.sv\
	$(IP_PATH)/jtag_tap_top.sv\
	$(IP_PATH)/pad_control.sv\
	$(IP_PATH)/pad_frame.sv\
	$(IP_PATH)/safe_domain.sv\
	$(IP_PATH)/soc_domain.sv\
	$(IP_PATH)/rtc_date.sv\
	$(IP_PATH)/rtc_clock.sv\
	$(IP_PATH)/pulpissimo.sv
SRC_VHDL_PULPISSIMO=

ncompile-subip-pulpissimo: $(LIB_PATH)/pulpissimo.nmake

$(LIB_PATH)/pulpissimo.nmake: $(SRC_SVLOG_PULPISSIMO) $(SRC_VHDL_PULPISSIMO)
	$(call subip_echo,pulpissimo)
	$(SVLOG_CC) -makelib ./ncsim_libs    $(INCDIR_PULPISSIMO) $(SRC_SVLOG_PULPISSIMO) -endlib

	echo $(LIB_PATH)/pulpissimo.nmake

