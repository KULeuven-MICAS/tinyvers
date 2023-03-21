#
# Copyright (C) 2015-2019 ETH Zurich, University of Bologna
# All rights reserved.
#
# This software may be modified and distributed under the terms
# of the BSD license.  See the LICENSE file for details.
#

IP=riscv
IP_PATH=$(IPS_PATH)/riscv
LIB_NAME=$(IP)_lib

include ncompile/build.mk

.PHONY: ncompile-$(IP) ncompile-subip-riscv_regfile_rtl ncompile-subip-riscv ncompile-subip-riscv_vip_rtl 

ncompile-$(IP): $(LIB_PATH)/_nmake

$(LIB_PATH)/_nmake : $(LIB_PATH)/riscv_regfile_rtl.nmake $(LIB_PATH)/riscv.nmake $(LIB_PATH)/riscv_vip_rtl.nmake 
	echo $(LIB_PATH)/_nmake


# riscv_regfile_rtl component
INCDIR_RISCV_REGFILE_RTL=+incdir+$(IP_PATH)/./rtl/include
SRC_SVLOG_RISCV_REGFILE_RTL=\
	$(IP_PATH)/./rtl/register_file_test_wrap.sv\
	$(IP_PATH)/./rtl/riscv_register_file_latch.sv
SRC_VHDL_RISCV_REGFILE_RTL=

ncompile-subip-riscv_regfile_rtl: $(LIB_PATH)/riscv_regfile_rtl.nmake

$(LIB_PATH)/riscv_regfile_rtl.nmake: $(SRC_SVLOG_RISCV_REGFILE_RTL) $(SRC_VHDL_RISCV_REGFILE_RTL)
	$(call subip_echo,riscv_regfile_rtl)
	$(SVLOG_CC) -makelib ./ncsim_libs    $(INCDIR_RISCV_REGFILE_RTL) $(SRC_SVLOG_RISCV_REGFILE_RTL) -endlib

	echo $(LIB_PATH)/riscv_regfile_rtl.nmake

# riscv component
INCDIR_RISCV=+incdir+$(IP_PATH)/./rtl/include+$(IP_PATH)/../../rtl/includes
SRC_SVLOG_RISCV=\
	$(IP_PATH)/./rtl/include/apu_core_package.sv\
	$(IP_PATH)/./rtl/include/riscv_defines.sv\
	$(IP_PATH)/./rtl/include/riscv_tracer_defines.sv\
	$(IP_PATH)/./rtl/riscv_alu.sv\
	$(IP_PATH)/./rtl/riscv_alu_basic.sv\
	$(IP_PATH)/./rtl/riscv_alu_div.sv\
	$(IP_PATH)/./rtl/riscv_compressed_decoder.sv\
	$(IP_PATH)/./rtl/riscv_controller.sv\
	$(IP_PATH)/./rtl/riscv_cs_registers.sv\
	$(IP_PATH)/./rtl/riscv_decoder.sv\
	$(IP_PATH)/./rtl/riscv_int_controller.sv\
	$(IP_PATH)/./rtl/riscv_ex_stage.sv\
	$(IP_PATH)/./rtl/riscv_hwloop_controller.sv\
	$(IP_PATH)/./rtl/riscv_hwloop_regs.sv\
	$(IP_PATH)/./rtl/riscv_id_stage.sv\
	$(IP_PATH)/./rtl/riscv_if_stage.sv\
	$(IP_PATH)/./rtl/riscv_load_store_unit.sv\
	$(IP_PATH)/./rtl/riscv_mult.sv\
	$(IP_PATH)/./rtl/riscv_prefetch_buffer.sv\
	$(IP_PATH)/./rtl/riscv_prefetch_L0_buffer.sv\
	$(IP_PATH)/./rtl/riscv_core.sv\
	$(IP_PATH)/./rtl/riscv_apu_disp.sv\
	$(IP_PATH)/./rtl/riscv_fetch_fifo.sv\
	$(IP_PATH)/./rtl/riscv_L0_buffer.sv\
	$(IP_PATH)/./rtl/riscv_pmp.sv
SRC_VHDL_RISCV=

ncompile-subip-riscv: $(LIB_PATH)/riscv.nmake

$(LIB_PATH)/riscv.nmake: $(SRC_SVLOG_RISCV) $(SRC_VHDL_RISCV)
	$(call subip_echo,riscv)
	$(SVLOG_CC) -makelib ./ncsim_libs    $(INCDIR_RISCV) $(SRC_SVLOG_RISCV) -endlib

	echo $(LIB_PATH)/riscv.nmake

# riscv_vip_rtl component
INCDIR_RISCV_VIP_RTL=+incdir+$(IP_PATH)/./rtl/include
SRC_SVLOG_RISCV_VIP_RTL=\
	$(IP_PATH)/./rtl/riscv_tracer.sv
SRC_VHDL_RISCV_VIP_RTL=

ncompile-subip-riscv_vip_rtl: $(LIB_PATH)/riscv_vip_rtl.nmake

$(LIB_PATH)/riscv_vip_rtl.nmake: $(SRC_SVLOG_RISCV_VIP_RTL) $(SRC_VHDL_RISCV_VIP_RTL)
	$(call subip_echo,riscv_vip_rtl)
	$(SVLOG_CC) -makelib ./ncsim_libs    $(INCDIR_RISCV_VIP_RTL) $(SRC_SVLOG_RISCV_VIP_RTL) -endlib

	echo $(LIB_PATH)/riscv_vip_rtl.nmake




