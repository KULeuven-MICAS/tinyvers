#
# Copyright (C) 2015-2019 ETH Zurich, University of Bologna
# All rights reserved.
#
# This software may be modified and distributed under the terms
# of the BSD license.  See the LICENSE file for details.
#

IP=pulp_soc
IP_PATH=$(IPS_PATH)/pulp_soc
LIB_NAME=$(IP)_lib

include ncompile/build.mk

.PHONY: ncompile-$(IP) ncompile-subip-pulp_soc ncompile-subip-udma_subsystem ncompile-subip-fc ncompile-subip-components ncompile-subip-components_rtl ncompile-subip-components_behav 

ncompile-$(IP): $(LIB_PATH)/_nmake

$(LIB_PATH)/_nmake : $(LIB_PATH)/pulp_soc.nmake $(LIB_PATH)/udma_subsystem.nmake $(LIB_PATH)/fc.nmake $(LIB_PATH)/components.nmake $(LIB_PATH)/components_rtl.nmake $(LIB_PATH)/components_behav.nmake 
	echo $(LIB_PATH)/_nmake


# pulp_soc component
INCDIR_PULP_SOC=+incdir+$(IP_PATH)/../../rtl/includes
SRC_SVLOG_PULP_SOC=\
	$(IP_PATH)/rtl/pulp_soc/soc_interconnect.sv\
	$(IP_PATH)/rtl/pulp_soc/boot_rom.sv\
	$(IP_PATH)/rtl/pulp_soc/l2_ram_multi_bank.sv\
	$(IP_PATH)/rtl/pulp_soc/lint_jtag_wrap.sv\
	$(IP_PATH)/rtl/pulp_soc/periph_bus_wrap.sv\
	$(IP_PATH)/rtl/pulp_soc/soc_clk_rst_gen.sv\
	$(IP_PATH)/rtl/pulp_soc/soc_event_arbiter.sv\
	$(IP_PATH)/rtl/pulp_soc/soc_event_generator.sv\
	$(IP_PATH)/rtl/pulp_soc/soc_event_queue.sv\
	$(IP_PATH)/rtl/pulp_soc/soc_interconnect_wrap.sv\
	$(IP_PATH)/rtl/pulp_soc/soc_peripherals.sv\
	$(IP_PATH)/rtl/pulp_soc/pulp_soc.sv
SRC_VHDL_PULP_SOC=

ncompile-subip-pulp_soc: $(LIB_PATH)/pulp_soc.nmake

$(LIB_PATH)/pulp_soc.nmake: $(SRC_SVLOG_PULP_SOC) $(SRC_VHDL_PULP_SOC)
	$(call subip_echo,pulp_soc)
	$(SVLOG_CC) -makelib ./ncsim_libs    $(INCDIR_PULP_SOC) $(SRC_SVLOG_PULP_SOC) -endlib

	echo $(LIB_PATH)/pulp_soc.nmake

# udma_subsystem component
INCDIR_UDMA_SUBSYSTEM=+incdir+$(IP_PATH)/../../rtl/includes+$(IP_PATH)/.
SRC_SVLOG_UDMA_SUBSYSTEM=\
	$(IP_PATH)/rtl/udma_subsystem/udma_subsystem.sv
SRC_VHDL_UDMA_SUBSYSTEM=

ncompile-subip-udma_subsystem: $(LIB_PATH)/udma_subsystem.nmake

$(LIB_PATH)/udma_subsystem.nmake: $(SRC_SVLOG_UDMA_SUBSYSTEM) $(SRC_VHDL_UDMA_SUBSYSTEM)
	$(call subip_echo,udma_subsystem)
	$(SVLOG_CC) -makelib ./ncsim_libs    $(INCDIR_UDMA_SUBSYSTEM) $(SRC_SVLOG_UDMA_SUBSYSTEM) -endlib

	echo $(LIB_PATH)/udma_subsystem.nmake

# fc component
INCDIR_FC=+incdir+$(IP_PATH)/../../rtl/includes+$(IP_PATH)/.
SRC_SVLOG_FC=\
	$(IP_PATH)/rtl/fc/fc_demux.sv\
	$(IP_PATH)/rtl/fc/fc_subsystem.sv\
	$(IP_PATH)/rtl/fc/fc_hwpe.sv
SRC_VHDL_FC=

ncompile-subip-fc: $(LIB_PATH)/fc.nmake

$(LIB_PATH)/fc.nmake: $(SRC_SVLOG_FC) $(SRC_VHDL_FC)
	$(call subip_echo,fc)
	$(SVLOG_CC) -makelib ./ncsim_libs    $(INCDIR_FC) $(SRC_SVLOG_FC) -endlib

	echo $(LIB_PATH)/fc.nmake

# components component
INCDIR_COMPONENTS=+incdir+$(IP_PATH)/../../rtl/includes
SRC_SVLOG_COMPONENTS=\
	$(IP_PATH)/rtl/components/apb_clkdiv.sv\
	$(IP_PATH)/rtl/components/apb_timer_unit.sv\
	$(IP_PATH)/rtl/components/apb_soc_ctrl.sv\
	$(IP_PATH)/rtl/components/memory_models.sv\
	$(IP_PATH)/rtl/components/pulp_interfaces.sv\
	$(IP_PATH)/rtl/components/axi_slice_dc_master_wrap.sv\
	$(IP_PATH)/rtl/components/axi_slice_dc_slave_wrap.sv\
	$(IP_PATH)/rtl/components/glitch_free_clk_mux.sv\
	$(IP_PATH)/rtl/components/scm_2048x32.sv\
	$(IP_PATH)/rtl/components/scm_512x32.sv\
	$(IP_PATH)/rtl/components/tcdm_arbiter_2x1.sv\
	$(IP_PATH)/rtl/components/apb_wakeup.sv\
	$(IP_PATH)/rtl/components/apb_wakeup_counter.sv
SRC_VHDL_COMPONENTS=

ncompile-subip-components: $(LIB_PATH)/components.nmake

$(LIB_PATH)/components.nmake: $(SRC_SVLOG_COMPONENTS) $(SRC_VHDL_COMPONENTS)
	$(call subip_echo,components)
	$(SVLOG_CC) -makelib ./ncsim_libs    $(INCDIR_COMPONENTS) $(SRC_SVLOG_COMPONENTS) -endlib

	echo $(LIB_PATH)/components.nmake

# components_rtl component
INCDIR_COMPONENTS_RTL=+incdir+$(IP_PATH)/../../rtl/includes
SRC_SVLOG_COMPONENTS_RTL=\
	$(IP_PATH)/rtl/components/glitch_free_clk_mux.sv\
	$(IP_PATH)/rtl/components/apb_dummy.sv
SRC_VHDL_COMPONENTS_RTL=

ncompile-subip-components_rtl: $(LIB_PATH)/components_rtl.nmake

$(LIB_PATH)/components_rtl.nmake: $(SRC_SVLOG_COMPONENTS_RTL) $(SRC_VHDL_COMPONENTS_RTL)
	$(call subip_echo,components_rtl)
	$(SVLOG_CC) -makelib ./ncsim_libs    $(INCDIR_COMPONENTS_RTL) $(SRC_SVLOG_COMPONENTS_RTL) -endlib

	echo $(LIB_PATH)/components_rtl.nmake

# components_behav component
INCDIR_COMPONENTS_BEHAV=+incdir+$(IP_PATH)/../../rtl/includes
SRC_SVLOG_COMPONENTS_BEHAV=\
	$(IP_PATH)/rtl/components/freq_meter.sv
SRC_VHDL_COMPONENTS_BEHAV=

ncompile-subip-components_behav: $(LIB_PATH)/components_behav.nmake

$(LIB_PATH)/components_behav.nmake: $(SRC_SVLOG_COMPONENTS_BEHAV) $(SRC_VHDL_COMPONENTS_BEHAV)
	$(call subip_echo,components_behav)
	$(SVLOG_CC) -makelib ./ncsim_libs    $(INCDIR_COMPONENTS_BEHAV) $(SRC_SVLOG_COMPONENTS_BEHAV) -endlib

	echo $(LIB_PATH)/components_behav.nmake

