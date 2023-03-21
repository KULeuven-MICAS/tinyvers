#
# Copyright (C) 2015-2019 ETH Zurich, University of Bologna
# All rights reserved.
#
# This software may be modified and distributed under the terms
# of the BSD license.  See the LICENSE file for details.
#

IP=scm
IP_PATH=$(IPS_PATH)/scm
LIB_NAME=$(IP)_lib

include ncompile/build.mk

.PHONY: ncompile-$(IP) ncompile-subip-scm 

ncompile-$(IP): $(LIB_PATH)/_nmake

$(LIB_PATH)/_nmake : $(LIB_PATH)/scm.nmake 
	echo $(LIB_PATH)/_nmake


SRC_SVLOG_SCM=\
	$(IP_PATH)/latch_scm/register_file_1r_1w_test_wrap.sv\
	$(IP_PATH)/latch_scm/register_file_1w_64b_multi_port_read_32b_1row.sv\
	$(IP_PATH)/latch_scm/register_file_1w_multi_port_read_1row.sv\
	$(IP_PATH)/latch_scm/register_file_1r_1w_all.sv\
	$(IP_PATH)/latch_scm/register_file_1r_1w_all_test_wrap.sv\
	$(IP_PATH)/latch_scm/register_file_1r_1w_be.sv\
	$(IP_PATH)/latch_scm/register_file_1r_1w.sv\
	$(IP_PATH)/latch_scm/register_file_1r_1w_1row.sv\
	$(IP_PATH)/latch_scm/register_file_1w_128b_multi_port_read_32b.sv\
	$(IP_PATH)/latch_scm/register_file_1w_64b_multi_port_read_32b.sv\
	$(IP_PATH)/latch_scm/register_file_1w_64b_1r_32b.sv\
	$(IP_PATH)/latch_scm/register_file_1w_multi_port_read_be.sv\
	$(IP_PATH)/latch_scm/register_file_1w_multi_port_read.sv\
	$(IP_PATH)/latch_scm/register_file_2r_1w_asymm.sv\
	$(IP_PATH)/latch_scm/register_file_2r_1w_asymm_test_wrap.sv\
	$(IP_PATH)/latch_scm/register_file_2r_2w.sv\
	$(IP_PATH)/latch_scm/register_file_3r_2w.sv\
	$(IP_PATH)/latch_scm/register_file_3r_2w_be.sv\
	$(IP_PATH)/latch_scm/register_file_multi_way_1w_64b_multi_port_read_32b.sv\
	$(IP_PATH)/latch_scm/register_file_multi_way_1w_multi_port_read.sv
SRC_VHDL_SCM=

ncompile-subip-scm: $(LIB_PATH)/scm.nmake

$(LIB_PATH)/scm.nmake: $(SRC_SVLOG_SCM) $(SRC_VHDL_SCM)
	$(call subip_echo,scm)
	$(SVLOG_CC) -makelib ./ncsim_libs    $(INCDIR_SCM) $(SRC_SVLOG_SCM) -endlib

	echo $(LIB_PATH)/scm.nmake


