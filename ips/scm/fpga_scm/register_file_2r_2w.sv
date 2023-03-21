// Copyright 2014-2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

/*
 * Francesco Conti <f.conti@unibo.it>
 */
module register_file_2r_2w
#(
    parameter ADDR_WIDTH    = 5,
    parameter DATA_WIDTH    = 32
)
(
    // Clock and Reset
    input  logic         clk,
    input  logic         rst_n,

    //Read port R1
    input  logic [ADDR_WIDTH-1:0]  raddr_a_i,
    output logic [DATA_WIDTH-1:0]  rdata_a_o,

    //Read port R2
    input  logic [ADDR_WIDTH-1:0]  raddr_b_i,
    output logic [DATA_WIDTH-1:0]  rdata_b_o,

    // Write port W1
    input logic [ADDR_WIDTH-1:0]   waddr_a_i,
    input logic [DATA_WIDTH-1:0]   wdata_a_i,
    input logic                    we_a_i,

    // Write port W2
    input logic [ADDR_WIDTH-1:0]   waddr_b_i,
    input logic [DATA_WIDTH-1:0]   wdata_b_i,
    input logic                    we_b_i
);

  localparam    NUM_WORDS = 2**ADDR_WIDTH;

  (* ram_style = "block" *) logic [NUM_WORDS-1:0][DATA_WIDTH-1:0] rf_reg;
  logic [NUM_WORDS-1:0]                 we_a_dec;
  logic [NUM_WORDS-1:0]                 we_b_dec;

  always_comb
  begin : we_a_decoder
    for (int i=0; i<NUM_WORDS; i++) begin
      if (waddr_a_i == i)
        we_a_dec[i] <= we_a_i;
      else
        we_a_dec[i] <= 1'b0;
    end
  end

  always_comb
  begin : we_b_decoder
    for (int i=0; i<NUM_WORDS; i++) begin
      if (waddr_b_i == i)
        we_b_dec[i] <= we_b_i;
      else
        we_b_dec[i] <= 1'b0;
    end
  end

  genvar i;
  generate
    for (i=0; i<NUM_WORDS; i++)
    begin : rf_gen

      always_ff @(posedge clk or negedge rst_n)
      begin : register_write_behavioral
        if (rst_n==1'b0) begin
          rf_reg[i] <= 'b0;
        end
        else begin
          // port B has priority
          if(we_b_dec[i] == 1'b1)
            rf_reg[i] <= wdata_b_i;
          else if(we_a_dec[i] == 1'b1)
            rf_reg[i] <= wdata_a_i;
          else
            rf_reg[i] <= rf_reg[i];
        end
      end

    end
  endgenerate

  always_comb
  begin : register_read_a_behavioral
    rdata_a_o <= rf_reg[raddr_a_i];
  end

  always_comb
  begin : register_read_b_behavioral
    rdata_b_o <= rf_reg[raddr_b_i];
  end

endmodule
