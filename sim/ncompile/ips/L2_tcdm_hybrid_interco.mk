#
# Copyright (C) 2015-2019 ETH Zurich, University of Bologna
# All rights reserved.
#
# This software may be modified and distributed under the terms
# of the BSD license.  See the LICENSE file for details.
#

IP=L2_tcdm_hybrid_interco
IP_PATH=$(IPS_PATH)/L2_tcdm_hybrid_interco
LIB_NAME=$(IP)_lib

include ncompile/build.mk

.PHONY: ncompile-$(IP) ncompile-subip-soc_interconnect 

ncompile-$(IP): $(LIB_PATH)/_nmake

$(LIB_PATH)/_nmake : $(LIB_PATH)/soc_interconnect.nmake 
	echo $(LIB_PATH)/_nmake


SRC_SVLOG_SOC_INTERCONNECT=\
	$(IP_PATH)/RTL/l2_tcdm_demux.sv\
	$(IP_PATH)/RTL/lint_2_apb.sv\
	$(IP_PATH)/RTL/lint_2_axi.sv\
	$(IP_PATH)/RTL/axi_2_lint/axi64_2_lint32.sv\
	$(IP_PATH)/RTL/axi_2_lint/axi_read_ctrl.sv\
	$(IP_PATH)/RTL/axi_2_lint/axi_write_ctrl.sv\
	$(IP_PATH)/RTL/axi_2_lint/lint64_to_32.sv\
	$(IP_PATH)/RTL/XBAR_L2/AddressDecoder_Req_L2.sv\
	$(IP_PATH)/RTL/XBAR_L2/AddressDecoder_Resp_L2.sv\
	$(IP_PATH)/RTL/XBAR_L2/ArbitrationTree_L2.sv\
	$(IP_PATH)/RTL/XBAR_L2/FanInPrimitive_Req_L2.sv\
	$(IP_PATH)/RTL/XBAR_L2/FanInPrimitive_Resp_L2.sv\
	$(IP_PATH)/RTL/XBAR_L2/MUX2_REQ_L2.sv\
	$(IP_PATH)/RTL/XBAR_L2/RequestBlock_L2_1CH.sv\
	$(IP_PATH)/RTL/XBAR_L2/RequestBlock_L2_2CH.sv\
	$(IP_PATH)/RTL/XBAR_L2/ResponseBlock_L2.sv\
	$(IP_PATH)/RTL/XBAR_L2/ResponseTree_L2.sv\
	$(IP_PATH)/RTL/XBAR_L2/RR_Flag_Req_L2.sv\
	$(IP_PATH)/RTL/XBAR_L2/XBAR_L2.sv\
	$(IP_PATH)/RTL/XBAR_BRIDGE/AddressDecoder_Req_BRIDGE.sv\
	$(IP_PATH)/RTL/XBAR_BRIDGE/AddressDecoder_Resp_BRIDGE.sv\
	$(IP_PATH)/RTL/XBAR_BRIDGE/ArbitrationTree_BRIDGE.sv\
	$(IP_PATH)/RTL/XBAR_BRIDGE/FanInPrimitive_Req_BRIDGE.sv\
	$(IP_PATH)/RTL/XBAR_BRIDGE/FanInPrimitive_Resp_BRIDGE.sv\
	$(IP_PATH)/RTL/XBAR_BRIDGE/MUX2_REQ_BRIDGE.sv\
	$(IP_PATH)/RTL/XBAR_BRIDGE/RequestBlock1CH_BRIDGE.sv\
	$(IP_PATH)/RTL/XBAR_BRIDGE/RequestBlock2CH_BRIDGE.sv\
	$(IP_PATH)/RTL/XBAR_BRIDGE/ResponseBlock_BRIDGE.sv\
	$(IP_PATH)/RTL/XBAR_BRIDGE/ResponseTree_BRIDGE.sv\
	$(IP_PATH)/RTL/XBAR_BRIDGE/RR_Flag_Req_BRIDGE.sv\
	$(IP_PATH)/RTL/XBAR_BRIDGE/XBAR_BRIDGE.sv
SRC_VHDL_SOC_INTERCONNECT=

ncompile-subip-soc_interconnect: $(LIB_PATH)/soc_interconnect.nmake

$(LIB_PATH)/soc_interconnect.nmake: $(SRC_SVLOG_SOC_INTERCONNECT) $(SRC_VHDL_SOC_INTERCONNECT)
	$(call subip_echo,soc_interconnect)
	$(SVLOG_CC) -makelib ./ncsim_libs    $(INCDIR_SOC_INTERCONNECT) $(SRC_SVLOG_SOC_INTERCONNECT) -endlib

	echo $(LIB_PATH)/soc_interconnect.nmake

