// Copyright 2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.


module pad_functional_h_pd (
  input  logic OEN,
  input  logic I,
  inout  logic io_pwr_ok,
  inout  logic pwr_ok,
  output logic O,
  input  logic PEN,
  inout  wire  PAD
);

  LP_INLINE_IO_H pad_i (.DATA(I ), .Y(O ), .PAD(PAD ), .IOPWROK(), .PWROK(), .NDIN(1'b0),.RXEN(OEN ),.DRV({1'b1,1'b1}),.TRIEN(OEN ),.PUEN(1'b0),.PDEN(1'b1), .RETC() );

endmodule

module pad_functional_v_pd (
  input  logic OEN,
  input  logic I,
  inout  logic io_pwr_ok,
  inout  logic pwr_ok,
  output logic O,
  input  logic PEN,
  inout  wire  PAD
);

  LP_INLINE_IO_H pad_i (.DATA(I ), .Y(O ), .PAD(PAD ), .IOPWROK(), .PWROK(), .NDIN(1'b0),.RXEN(OEN ),.DRV({1'b1,1'b1}),.TRIEN(OEN ),.PUEN(1'b0),.PDEN(1'b1),.RETC() );

endmodule

module pad_functional_h_pu (
  input  logic OEN,
  input  logic I,
  inout  logic io_pwr_ok,
  inout  logic pwr_ok,
  output logic O,
  input  logic PEN,
  inout  wire  PAD
);

  LP_INLINE_IO_H pad_i (.DATA(I ), .Y(O ), .PAD(PAD ), .IOPWROK(), .PWROK(), .NDIN(1'b0),.RXEN(OEN ),.DRV({1'b1,1'b1}),.TRIEN(OEN ),.PUEN(1'b1),.PDEN(1'b0), .RETC() );

endmodule

module pad_functional_v_pu (
  input  logic OEN,
  input  logic I,
  inout  logic io_pwr_ok,
  input  logic pwr_ok,
  output logic O,
  input  logic PEN,
  inout  wire  PAD
);

  LP_INLINE_IO_H pad_i (.DATA(I ), .Y(O ), .PAD(PAD ), .IOPWROK(), .PWROK(), .NDIN(1'b0),.RXEN(OEN ),.DRV({1'b1,1'b1}),.TRIEN(OEN ),.PUEN(1'b1),.PDEN(1'b0), .RETC());

endmodule
