// Copyright 2019 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License. You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

module cluster_clock_and2 (
  input  logic clk0_i,
  input  logic clk1_i,
  output logic clk_o
);

  assign clk_o = clk0_i & clk1_i;

endmodule

module cluster_clock_buffer (
  input  logic clk_i,
  output logic clk_o
);

  assign clk_o = clk_i;

endmodule

// Description: Behavioral model of an integrated clock-gating cell (ICG)
module cluster_clock_gating (
   input  logic clk_i,
   input  logic en_i,
   input  logic test_en_i,
   output logic clk_o
);

/*  logic clk_en;

  always_latch begin
    if (clk_i == 1'b0) clk_en <= en_i | test_en_i;
  end

  assign clk_o = clk_i & clk_en;
*/
  SC7P5T_CKGPRELATNX1_CSC28L cg_cluster(.E(en_i), .CLK(clk_i),
      .TE(test_en_i), .Z(clk_o));
  //C12T28SOI_LRP_CNHLSX7_P0 cg_cluster(.E(en_i), .CP(clk_i),
  //    .TE(test_en_i), .Q(clk_o));

endmodule

module cluster_clock_inverter (
  input  logic clk_i,
  output logic clk_o
);

  assign clk_o = ~clk_i;

endmodule

module cluster_clock_mux2 (
  input  logic clk0_i,
  input  logic clk1_i,
  input  logic clk_sel_i,
  output logic clk_o
);

  assign clk_o = (clk_sel_i) ? clk1_i : clk0_i;

endmodule

module cluster_clock_xor2 (
  input  logic clk0_i,
  input  logic clk1_i,
  output logic clk_o
);

  assign clk_o = clk0_i ^ clk1_i;

endmodule
