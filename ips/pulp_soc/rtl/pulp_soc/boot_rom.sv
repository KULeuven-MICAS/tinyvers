// Copyright 2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.


`include "../../../../rtl/includes/pulp_soc_defines.sv"

module boot_rom #(
    parameter ROM_ADDR_WIDTH = 13
    )
    (
     input logic             clk_i,
     input logic             rst_ni,
     input logic             init_ni,
     input logic             scan_en_in,
     UNICAD_MEM_BUS_32.Slave mem_slave,
     input logic             test_mode_i
    );

    logic clk_gated;

    `ifndef PULP_FPGA_EMUL

        generic_rom #(
            .ADDR_WIDTH(ROM_ADDR_WIDTH-2),
            .DATA_WIDTH(32)
         ) rom_mem_i (
            .CLK            (  clk_gated            ),
            .CEN            (  mem_slave.csn        ),
            .A              (  mem_slave.add[ROM_ADDR_WIDTH-1:2]  ),
            .Q              (  mem_slave.rdata      )
        );

/*       MEMROMIU_FUN_wrapper rom_mem_i
         (
            .CLK   ( clk_i                 ),
            .AS    ( mem_slave.add[12]     ),
            .AW    ( mem_slave.add[11:7]   ),
            .AC    ( mem_slave.add[6:2]    ),
            .CEN   ( mem_slave.csn         ),
            .Q     ( mem_slave.rdata       )
         ); 
*/
        //assign mem_slave.add[31:ROM_ADDR_WIDTH] = '0;

    `else // !`ifndef PULP_FPGA_EMUL

    fpga_bootrom #(
                   .ADDR_WIDTH(ROM_ADDR_WIDTH-2),
                   .DATA_WIDTH(32)
                   ) rom_mem_i (
                            .CLK(clk_i),
                            .CEN(mem_slave.csn),
                            .A(mem_slave.add[ROM_ADDR_WIDTH-1:2]),
                            .Q(mem_slave.rdata)
                            );

    `endif

pulp_clock_gating i_clk_gate_rom
  (
    .clk_i(clk_i),
    .en_i(~scan_en_in),
    .test_en_i(1'b0),
    .clk_o(clk_gated)
  );

endmodule
