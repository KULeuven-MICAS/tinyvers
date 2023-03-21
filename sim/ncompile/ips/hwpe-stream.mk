#
# Copyright (C) 2015-2019 ETH Zurich, University of Bologna
# All rights reserved.
#
# This software may be modified and distributed under the terms
# of the BSD license.  See the LICENSE file for details.
#

IP=hwpe_stream
IP_PATH=$(IPS_PATH)/hwpe-stream
LIB_NAME=$(IP)_lib

include ncompile/build.mk

.PHONY: ncompile-$(IP) ncompile-subip-hwpe-stream ncompile-subip-tb_hwpe_stream 

ncompile-$(IP): $(LIB_PATH)/_nmake

$(LIB_PATH)/_nmake : $(LIB_PATH)/hwpe-stream.nmake $(LIB_PATH)/tb_hwpe_stream.nmake 
	echo $(LIB_PATH)/_nmake


# hwpe-stream component
INCDIR_HWPE-STREAM=+incdir+$(IP_PATH)/rtl
SRC_SVLOG_HWPE-STREAM=\
	$(IP_PATH)/rtl/hwpe_stream_package.sv\
	$(IP_PATH)/rtl/hwpe_stream_interfaces.sv\
	$(IP_PATH)/rtl/hwpe_stream_addressgen.sv\
	$(IP_PATH)/rtl/hwpe_stream_fifo_earlystall_sidech.sv\
	$(IP_PATH)/rtl/hwpe_stream_fifo_earlystall.sv\
	$(IP_PATH)/rtl/hwpe_stream_fifo_scm.sv\
	$(IP_PATH)/rtl/hwpe_stream_fifo_sidech.sv\
	$(IP_PATH)/rtl/hwpe_stream_fifo.sv\
	$(IP_PATH)/rtl/hwpe_stream_buffer.sv\
	$(IP_PATH)/rtl/hwpe_stream_merge.sv\
	$(IP_PATH)/rtl/hwpe_stream_fence.sv\
	$(IP_PATH)/rtl/hwpe_stream_assign.sv\
	$(IP_PATH)/rtl/hwpe_stream_split.sv\
	$(IP_PATH)/rtl/hwpe_stream_sink.sv\
	$(IP_PATH)/rtl/hwpe_stream_source.sv\
	$(IP_PATH)/rtl/hwpe_stream_sink_realign.sv\
	$(IP_PATH)/rtl/hwpe_stream_source_realign.sv\
	$(IP_PATH)/rtl/hwpe_stream_mux_static.sv\
	$(IP_PATH)/rtl/hwpe_stream_demux_static.sv\
	$(IP_PATH)/rtl/hwpe_stream_tcdm_fifo_load.sv\
	$(IP_PATH)/rtl/hwpe_stream_tcdm_fifo_load_sidech.sv\
	$(IP_PATH)/rtl/hwpe_stream_tcdm_fifo_store.sv\
	$(IP_PATH)/rtl/hwpe_stream_tcdm_mux.sv\
	$(IP_PATH)/rtl/hwpe_stream_tcdm_mux_static.sv\
	$(IP_PATH)/rtl/hwpe_stream_tcdm_reorder.sv\
	$(IP_PATH)/rtl/hwpe_stream_tcdm_reorder_static.sv
SRC_VHDL_HWPE-STREAM=

ncompile-subip-hwpe-stream: $(LIB_PATH)/hwpe-stream.nmake

$(LIB_PATH)/hwpe-stream.nmake: $(SRC_SVLOG_HWPE-STREAM) $(SRC_VHDL_HWPE-STREAM)
	$(call subip_echo,hwpe-stream)
	$(SVLOG_CC) -makelib ./ncsim_libs    $(INCDIR_HWPE-STREAM) $(SRC_SVLOG_HWPE-STREAM) -endlib

	echo $(LIB_PATH)/hwpe-stream.nmake

SRC_SVLOG_TB_HWPE_STREAM=\
	$(IP_PATH)/tb/tb_hwpe_stream_reservoir.sv\
	$(IP_PATH)/tb/tb_hwpe_stream_receiver.sv
SRC_VHDL_TB_HWPE_STREAM=

ncompile-subip-tb_hwpe_stream: $(LIB_PATH)/tb_hwpe_stream.nmake

$(LIB_PATH)/tb_hwpe_stream.nmake: $(SRC_SVLOG_TB_HWPE_STREAM) $(SRC_VHDL_TB_HWPE_STREAM)
	$(call subip_echo,tb_hwpe_stream)
	$(SVLOG_CC) -makelib ./ncsim_libs    $(INCDIR_TB_HWPE_STREAM) $(SRC_SVLOG_TB_HWPE_STREAM) -endlib

	echo $(LIB_PATH)/tb_hwpe_stream.nmake


