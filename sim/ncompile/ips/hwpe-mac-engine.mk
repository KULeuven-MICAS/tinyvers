#
# Copyright (C) 2015-2019 ETH Zurich, University of Bologna
# All rights reserved.
#
# This software may be modified and distributed under the terms
# of the BSD license.  See the LICENSE file for details.
#

IP=hwpe_mac_engine
IP_PATH=$(IPS_PATH)/hwpe-mac-engine
LIB_NAME=$(IP)_lib

include ncompile/build.mk

.PHONY: ncompile-$(IP) ncompile-subip-hw-mac-engine 

ncompile-$(IP): $(LIB_PATH)/_nmake

$(LIB_PATH)/_nmake : $(LIB_PATH)/hw-mac-engine.nmake 
	echo $(LIB_PATH)/_nmake


# hw-mac-engine component
INCDIR_HW-MAC-ENGINE=+incdir+$(IP_PATH)/rtl
SRC_SVLOG_HW-MAC-ENGINE=\
	$(IP_PATH)/rtl/mac_package.sv\
	$(IP_PATH)/rtl/parameters.sv\
	$(IP_PATH)/rtl/32bTO64b.sv\
	$(IP_PATH)/rtl/mac_ctrl.sv\
	$(IP_PATH)/rtl/mac_streamer.sv\
	$(IP_PATH)/rtl/mac_engine.sv\
	$(IP_PATH)/rtl/mac_top.sv\
	$(IP_PATH)/wrap/mac_top_wrap.sv\
	$(IP_PATH)/rtl/panda_fsm.sv\
	$(IP_PATH)/rtl/activation_memory.sv\
	$(IP_PATH)/rtl/adder.sv\
	$(IP_PATH)/rtl/adder_tree.sv\
	$(IP_PATH)/rtl/array_pes.sv\
	$(IP_PATH)/rtl/sparsity_memory.sv\
	$(IP_PATH)/rtl/output_allignment_padding.sv\
	$(IP_PATH)/rtl/instruction_memory.sv\
	$(IP_PATH)/rtl/inner_wrapper_SRAM_act_mem.sv\
	$(IP_PATH)/rtl/inner_wrapper_SRAM_w_mem.sv\
	$(IP_PATH)/rtl/outter_wrapper_SRAM_w_mem.sv\
	$(IP_PATH)/rtl/encoder_FIFO.sv\
	$(IP_PATH)/rtl/configuration_registers.sv\
	$(IP_PATH)/rtl/control_unit.sv\
	$(IP_PATH)/rtl/cpu.sv\
	$(IP_PATH)/rtl/cpu_wrapper.sv\
	$(IP_PATH)/rtl/input_buffer.sv\
	$(IP_PATH)/rtl/multiplier.sv\
	$(IP_PATH)/rtl/mult_top.sv\
	$(IP_PATH)/rtl/nonlinear_block.sv\
	$(IP_PATH)/rtl/pe.sv\
	$(IP_PATH)/rtl/pooling.sv\
	$(IP_PATH)/rtl/sig_tanh.sv\
	$(IP_PATH)/rtl/SRAM_parametrizable_equivalent.sv\
	$(IP_PATH)/rtl/SRAM_parametrizable_w_equivalent.sv\
	$(IP_PATH)/rtl/SRAM_parametrizable_s_equivalent.sv\
	$(IP_PATH)/rtl/SRAM_2048x64_equivalent.sv\
	$(IP_PATH)/rtl/SRAM_2048x32_equivalent.sv\
	$(IP_PATH)/rtl/weight_memory.sv
SRC_VHDL_HW-MAC-ENGINE=

ncompile-subip-hw-mac-engine: $(LIB_PATH)/hw-mac-engine.nmake

$(LIB_PATH)/hw-mac-engine.nmake: $(SRC_SVLOG_HW-MAC-ENGINE) $(SRC_VHDL_HW-MAC-ENGINE)
	$(call subip_echo,hw-mac-engine)
	$(SVLOG_CC) -makelib ./ncsim_libs    $(INCDIR_HW-MAC-ENGINE) $(SRC_SVLOG_HW-MAC-ENGINE) -endlib

	echo $(LIB_PATH)/hw-mac-engine.nmake

