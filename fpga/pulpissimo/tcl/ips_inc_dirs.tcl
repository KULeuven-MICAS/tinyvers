if ![info exists INCLUDE_DIRS] {
	set INCLUDE_DIRS ""
}

eval "set INCLUDE_DIRS {
    /volume1/users/vjain/pulpissimo/rtl/includes \
    /volume1/users/vjain/pulpissimo/ips/adv_dbg_if/rtl \
    /volume1/users/vjain/pulpissimo/ips/apb/apb_adv_timer/./rtl \
    /volume1/users/vjain/pulpissimo/ips/axi/axi_node/./src/ \
    /volume1/users/vjain/pulpissimo/ips/timer_unit/rtl \
    /volume1/users/vjain/pulpissimo/ips/fpnew/../common_cells/include \
    /volume1/users/vjain/pulpissimo/ips/jtag_pulp/../../rtl/includes \
    /volume1/users/vjain/pulpissimo/ips/riscv/./rtl/include \
    /volume1/users/vjain/pulpissimo/ips/riscv/../../rtl/includes \
    /volume1/users/vjain/pulpissimo/ips/riscv/./rtl/include \
    /volume1/users/vjain/pulpissimo/ips/ibex/rtl \
    /volume1/users/vjain/pulpissimo/ips/udma/udma_core/./rtl \
    /volume1/users/vjain/pulpissimo/ips/udma/udma_qspi/rtl \
    /volume1/users/vjain/pulpissimo/ips/hwpe-ctrl/rtl \
    /volume1/users/vjain/pulpissimo/ips/hwpe-stream/rtl \
    /volume1/users/vjain/pulpissimo/ips/hwpe-mac-engine/rtl \
    /volume1/users/vjain/pulpissimo/ips/pulp_soc/../../rtl/includes \
    /volume1/users/vjain/pulpissimo/ips/pulp_soc/../../rtl/includes \
    /volume1/users/vjain/pulpissimo/ips/pulp_soc/. \
    /volume1/users/vjain/pulpissimo/ips/pulp_soc/../../rtl/includes \
    /volume1/users/vjain/pulpissimo/ips/pulp_soc/. \
    /volume1/users/vjain/pulpissimo/ips/pulp_soc/../../rtl/includes \
	${INCLUDE_DIRS} \
}"
