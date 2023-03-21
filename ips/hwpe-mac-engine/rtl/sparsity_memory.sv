module sparsity_memory (
  input  logic clk,
  input  logic reset,
  input  logic scan_en_in,
  input  logic [15:0] CONF_STR_SPARSITY,
  input  logic wr_en_ext,
  input  logic [31:0] wr_addr_ext,
  input  logic [31:0] wr_data_ext,
  input  logic rd_en,
  input  logic [10:0] rd_addr,
  output logic [31:0] rd_data
);

logic wr_en_mem0;
logic wr_en_mem1;
logic CEB_mem0;
logic CEB_mem1;
logic wr_en_ext_reg;
logic [31:0] wr_addr_ext_reg;
logic [31:0] wr_data_ext_reg;
logic [9:0] wr_addr_mem0;
logic [9:0] wr_addr_mem1;
logic [9:0] muxed_addr_mem0;
logic [9:0] muxed_addr_mem1;
logic [31:0] wr_data_mem0;
logic [31:0] wr_data_mem1;
logic [31:0] rd_data_mem0;
logic [31:0] rd_data_mem1;
logic [9:0] rd_addr_mem0;
logic [9:0] rd_addr_mem1;
logic [10:0] rd_addr_reg;

logic rd_en_asserted;

// Modification 24 July. SEBASTIAN Use of CONF_STR_SPARSITY
assign rd_en_asserted= rd_en && (CONF_STR_SPARSITY  != 0);
always_ff @(posedge clk or negedge reset)
begin
  if (~reset) begin
    wr_en_ext_reg <= 0;
    wr_addr_ext_reg <= 0;
    wr_data_ext_reg <= 0;
    rd_addr_reg <= 0;
  end else begin
    wr_en_ext_reg <= wr_en_ext;
    wr_addr_ext_reg <= wr_addr_ext;
    wr_data_ext_reg <= wr_data_ext;
    rd_addr_reg <= rd_addr;
  end
end

// Writing 
always_comb
begin
	  if (wr_en_ext_reg) begin
	    if (wr_addr_ext_reg[10] == 1) begin
	      wr_en_mem1 = 1;
	      wr_en_mem0 = 0;
	      wr_addr_mem1 = wr_addr_ext_reg[9:0];
	      wr_data_mem1 = wr_data_ext_reg;
	      wr_addr_mem0 = '0;
	      wr_data_mem0 = '0;
	    end else begin
	      wr_en_mem0 = 1;
	      wr_en_mem1 = 0;
	      wr_addr_mem0 = wr_addr_ext_reg[9:0];
	      wr_data_mem0 = wr_data_ext_reg;
	      wr_addr_mem1 = '0;
	      wr_data_mem1 = '0;
	    end
	  end else begin
	    wr_en_mem1 = 0;
	    wr_en_mem0 = 0;
	    wr_addr_mem1 = '0;
	    wr_addr_mem0 = '0;
	    wr_data_mem0 = '0;
	    wr_data_mem1 = '0;
	  end
	end

	// Reading
	always_comb
	begin
	  // Only retrieve data when str sparsity is asserted
	  // Modification 24 July. SEBASTIAN Use of CONF_STR_SPARSITY

	  if (rd_en_asserted) begin
    if (rd_addr[10] == 1) begin
      rd_data = rd_data_mem1;
      rd_addr_mem1 = rd_addr[9:0];
      rd_addr_mem0 = '0;
    end else begin
      rd_data = rd_data_mem0;
      rd_addr_mem0 = rd_addr[9:0];
      rd_addr_mem1 = '0;
    end   
  end else begin
    rd_data = rd_data_mem0;
    rd_addr_mem1 = '0;
    rd_addr_mem0 = '0;
  end
end

always_comb
begin
// Modification 24 July. SEBASTIAN Use of CONF_STR_SPARSITY

  if (rd_en_asserted) begin
    if (wr_en_ext_reg) begin
      if (wr_addr_ext_reg[10] == 1) begin
        muxed_addr_mem0 = rd_addr_mem0;
        muxed_addr_mem1 = wr_addr_mem1;
      end else begin
        muxed_addr_mem1 = rd_addr_mem1;
        muxed_addr_mem0 = wr_addr_mem0;
      end
    end else begin
      if (rd_addr[10] == 1) begin
        muxed_addr_mem1 = rd_addr_mem1;
        muxed_addr_mem0 = rd_addr_mem0;
      end else begin
        muxed_addr_mem0 = rd_addr_mem0;
        muxed_addr_mem1 = rd_addr_mem1;
      end
    end 
  end else begin
    if (wr_en_ext_reg) begin
      if (wr_addr_ext_reg[10] == 1) begin
        muxed_addr_mem1 = wr_addr_mem1;
        muxed_addr_mem0 = wr_addr_mem0;
      end else begin
        muxed_addr_mem0 = wr_addr_mem0;
        muxed_addr_mem1 = wr_addr_mem1;
      end
    end else begin
      muxed_addr_mem0 = '0;
      muxed_addr_mem1 = '0;
    end
  end
end

always_comb
begin
// Modification 24 July. SEBASTIAN Use of CONF_STR_SPARSITY
  if (rd_en_asserted) begin
    //Only checking the LSBs of the address
    if (rd_addr_reg[9:0] !=  rd_addr[9:0]) begin
      //depending on the MSB, one of the 2 buffers is selected
      if (rd_addr_reg[10]==0)
      begin
      CEB_mem0 = 0;
      CEB_mem1 = 1;
      end
      else
      begin
      CEB_mem0 = 1;
      CEB_mem1 = 0;
      end
    end else begin
      if (wr_en_ext || wr_en_ext_reg) begin
        CEB_mem0 = 0;
        CEB_mem1 = 0;
      end else begin
        CEB_mem0 = 1;
        CEB_mem1 = 1;
      end
    end
  end else begin
    if (wr_en_ext || wr_en_ext_reg) begin
      CEB_mem0 = 0;
      CEB_mem1 = 0;
    end else begin
      CEB_mem0 = 1;
      CEB_mem1 = 1;
    end
  end
end

SRAM_parametrizable_s_equivalent sparsity_mem0(
                      .CLK(clk), .CEB(CEB_mem0), .WEB(~wr_en_mem0),
                       .scan_en_in(scan_en_in),
                       .A(muxed_addr_mem0), .D(wr_data_mem0),
                       .Q(rd_data_mem0)
);

SRAM_parametrizable_s_equivalent sparsity_mem1(
                       .CLK(clk), .CEB(CEB_mem1), .WEB(~wr_en_mem1),
                       .scan_en_in(scan_en_in),
                       .A(muxed_addr_mem1), .D(wr_data_mem1),
                       .Q(rd_data_mem1)
);





endmodule
