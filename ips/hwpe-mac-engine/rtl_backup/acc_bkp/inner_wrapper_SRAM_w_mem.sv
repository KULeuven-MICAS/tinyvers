import parameters::*;

module inner_wrapper_SRAM_w_mem #(
parameter integer SRAM_blocks_per_row=4,
parameter integer SRAM_blocks_per_column=2,
parameter SRAM_numBit = 8,
parameter SRAM_numWordAddr = 10
) (
    clk, reset,
    rd_enable,
    rd_addr,
    rd_data,
    wr_enable,
    wr_addr,
    wr_data
);

parameter SRAM_blocks_per_row_log = $clog2(SRAM_blocks_per_row);
parameter SRAM_totalWordAddr = SRAM_numWordAddr + SRAM_blocks_per_row_log + $clog2(SRAM_blocks_per_column);

//IO
input clk, reset;
input rd_enable, wr_enable;
input signed [SRAM_numBit-1:0] wr_data[SRAM_blocks_per_row-1:0];
input [SUBBLOCK_W_MEM_SRAM_totalWordAddr-1:0] wr_addr;
input [SUBBLOCK_W_MEM_SRAM_totalWordAddr-1:0] rd_addr;
output reg signed [SRAM_numBit-1:0] rd_data [SRAM_blocks_per_row-1:0];

//Signals
wire [SRAM_blocks_per_row*SRAM_numBit-1:0] D_concatenated [SRAM_blocks_per_column-1:0];
wire [SRAM_blocks_per_row*SRAM_numBit-1:0] Q_concatenated [SRAM_blocks_per_column-1:0];
reg rd_enable_reg;
reg [SRAM_totalWordAddr-(SRAM_numWordAddr+SRAM_blocks_per_row_log)-1:0] last_block_column; //last block column
reg [SRAM_totalWordAddr-(SRAM_numWordAddr+SRAM_blocks_per_row_log)-1:0] current_block_column; //last block column
reg CEB [SRAM_blocks_per_column-1:0][SRAM_blocks_per_row-1:0];
reg WEB [SRAM_blocks_per_column-1:0][SRAM_blocks_per_row-1:0];
reg [SRAM_numWordAddr-1:0] A [SRAM_blocks_per_column-1:0][SRAM_blocks_per_row-1:0];
reg [SRAM_numBit-1:0] D [SRAM_blocks_per_column-1:0][SRAM_blocks_per_row-1:0];
reg [SRAM_numBit-1:0] BWEB [SRAM_blocks_per_column-1:0];
// Data Output
wire [SRAM_numBit-1:0] Q [SRAM_blocks_per_column-1:0][SRAM_blocks_per_row-1:0];
reg [1:0] TSEL [SRAM_blocks_per_column-1:0];
reg CEB_RP  [SRAM_blocks_per_column-1:0][SRAM_blocks_per_row-1:0];
reg WEB_RP  [SRAM_blocks_per_column-1:0][SRAM_blocks_per_row-1:0];
reg [SRAM_numWordAddr-1:0] A_RP [SRAM_blocks_per_column-1:0][SRAM_blocks_per_row-1:0];
reg [SRAM_numBit-1:0] D_RP [SRAM_blocks_per_column-1:0][SRAM_blocks_per_row-1:0];
reg [SRAM_numBit-1:0] BWEB_RP[SRAM_blocks_per_column-1:0];
// Data Output
reg [1:0] TSEL_RP[SRAM_blocks_per_column-1:0];
reg CEB_WP [SRAM_blocks_per_column-1:0][SRAM_blocks_per_row-1:0];
reg WEB_WP  [SRAM_blocks_per_column-1:0][SRAM_blocks_per_row-1:0];
reg [SRAM_numWordAddr-1:0] A_WP [SRAM_blocks_per_column-1:0][SRAM_blocks_per_row-1:0];
reg [SRAM_numBit-1:0] D_WP [SRAM_blocks_per_column-1:0][SRAM_blocks_per_row-1:0];
reg [SRAM_numBit-1:0] BWEB_WP[SRAM_blocks_per_column-1:0];
// debug points
wire [SRAM_numWordAddr-1:0] A_temp;
wire [SRAM_numBit-1:0] D_temp;

// Data Output
reg [1:0] TSEL_WP[SRAM_blocks_per_column-1:0];
integer i;
integer m;
genvar j;
genvar k;
// Read Port
always @(*)
begin
  for (m=0; m < (SRAM_blocks_per_column); m=m+1) 
  begin
    //default values
    TSEL_RP[m]=2'b01;
    BWEB_RP[m]=0;           
    
    for (i=0; i < (SRAM_blocks_per_row); i=i+1) 
      begin
            D_RP[m][i]=0;
              CEB_RP[m][i]=1;
             A_RP[m][i]=0;
            WEB_RP[m][i]=1;
      end       
      
   // Reading from last block if a new block is addressed   
  for (i=0; i < (SRAM_blocks_per_row); i=i+1) 
      begin
           if ( last_block_column != current_block_column)
                  rd_data[i]= Q[last_block_column][i][SRAM_numBit-1:0];       
           else   
                  rd_data[i]=Q[current_block_column][i][SRAM_numBit-1:0];  
      end 
      
   // If read enable and block m is accessed
    if ((rd_enable==1 ) && (m==(rd_addr[SRAM_totalWordAddr-1:(SRAM_numWordAddr+SRAM_blocks_per_row_log)] )))
          begin
         
           //if there is a change of column. The read must be done in the previous block
           if ( last_block_column != current_block_column)
                  for (i=0; i < (SRAM_blocks_per_row); i=i+1) 
                    rd_data[i]= Q[last_block_column][i][SRAM_numBit-1:0];       
           else   
                for (i=0; i < (SRAM_blocks_per_row); i=i+1) 
                  rd_data[i]=Q[current_block_column][i][SRAM_numBit-1:0];
              for (i=0; i < (SRAM_blocks_per_row); i=i+1) 
              begin
                  CEB_RP[m][i]=0;
                  WEB_RP[m][i]=1;
                  A_RP[m][i]= rd_addr[(SRAM_numWordAddr+SRAM_blocks_per_row_log)-1:SRAM_blocks_per_row_log];
              end
          end
  end
end



//Write Port
always @(*)
begin
for (m=0; m < (SRAM_blocks_per_column); m=m+1) 
  begin
    
    // Default values
    BWEB_WP[m]=0;
    TSEL_WP[m]=2'b01;
    for (i=0; i < (SRAM_blocks_per_row); i=i+1) 
      begin
      A_WP[m][i]= 0;
      D_WP[m][i] = 0;
      CEB_WP[m][i]=1;
      WEB_WP[m][i]=1;
      end
    
      // If write enable is asserted
       for (i=0; i < (SRAM_blocks_per_row); i=i+1) 
       begin
        //if ((wr_enable==1)  && (m==wr_addr[SRAM_totalWordAddr-1:(SRAM_numWordAddr+SRAM_blocks_per_row_log)]) && (wr_addr[SRAM_blocks_per_row_log-1:0]==i))
         if ((wr_enable==1)  && (m==wr_addr[SRAM_totalWordAddr-1:(SRAM_numWordAddr+SRAM_blocks_per_row_log)]))
        begin
          A_WP[m][i]= wr_addr[(SRAM_numWordAddr+SRAM_blocks_per_row_log)-1:SRAM_blocks_per_row_log];
          D_WP[m][i] = wr_data[i];
          CEB_WP[m][i]=0;
          WEB_WP[m][i]=0;
      end
      end
  end
end

//SELECTION OF PORT
always @(*)
begin

  if (wr_enable==1)
  begin
   CEB = CEB_WP;
   WEB = WEB_WP;
   A = A_WP;
   D = D_WP;
   BWEB = BWEB_WP;
   TSEL = TSEL_WP;
  end
  else
  begin
   CEB = CEB_RP;
   WEB = WEB_RP;
   A = A_RP;
   D = D_RP;
   BWEB = BWEB_RP;
   TSEL = TSEL_RP;
  end
end 


//Concatenation of outputs from the SRAM blocks
generate   
  for (k=0; k < (SRAM_blocks_per_column); k=k+1) begin:r_q
      for (j=0; j < (SRAM_blocks_per_row); j=j+1) begin:c_q
        assign Q[k][j] = Q_concatenated[k][(j+1)*INPUT_CHANNEL_DATA_WIDTH-1:j*INPUT_CHANNEL_DATA_WIDTH];
        end
        end
endgenerate

generate
  for (k=0; k < (SRAM_blocks_per_column); k=k+1) begin:r_d
  for (j=0; j < (SRAM_blocks_per_row); j=j+1) begin:c_d
    assign D_concatenated[k][(j+1)*INPUT_CHANNEL_DATA_WIDTH-1:j*INPUT_CHANNEL_DATA_WIDTH] = D[k][j];
  end
  end
endgenerate 
//
generate
    
    for (k=0; k < (SRAM_blocks_per_column); k=k+1) begin: generation_blocks
       /*   for (k=0; k < (SRAM_blocks_per_column); k=k+1) begin: row 
        TS1N65LPLL2048X32M8  SRAM_i(                             

                        .CLK(clk),  .CEB(CEB[k][0]), .WEB(WEB[k][0]),

                         .A(A[k][0]), .D({D[k][3], D[k][2], D[k][1],D[k][0]}), .BWEB({BWEB[0],BWEB[1],BWEB[2],BWEB[3]}),

                       

                        .Q(Q_concatenated[k]),

                        .TSEL(TSEL[k])
                                    );                  */  
         
         if (N_DIM_ARRAY==8)
          begin
        SRAM_2048x64_equivalent  SRAM_equivalent_i(                             
                        .CLK(clk),  .CEB(CEB[k][0]), .WEB(WEB[k][0]),
                         .A(A[k][0]), .D(D_concatenated[k]), 
                        .Q(Q_concatenated[k])
                                    );  
          end
          else
          begin
          /* SRAM_2048x32_equivalent  SRAM_equivalent_i(                             
                        .CLK(clk),  .CEB(CEB[k][0]), .WEB(WEB[k][0]),
                         .A(A[k][0]), .D(D_concatenated[k]), 
                        .Q(Q_concatenated[k])
                                    ); */
          /*SRAM_2048x8_equivalent_wrapper  SRAM_equivalent_wrapper_i(
                        .CLK(clk),  .CEB(CEB[k][0]), .WEB(WEB[k][0]),
                         .A(A[k][0]), .D({D[k][0], D[k][1], D[k][2], D[k][3]}),
                        .Q0(Q[k][0]), .Q1(Q[k][1]), .Q2(Q[k][2]), .Q3(Q[k][3])
                        );*/
          /*SRAM_2048x8_equivalent_wrapper  SRAM_equivalent_wrapper_i(
                        .CLK(clk),  .CEB(CEB[0][k]), .WEB(WEB[0][k]),
                         .A(A[0][k]), .D({D[0][k], D[1][k], D[2][k], D[3][k]}),
                        .Q0(Q[0][k]), .Q1(Q[1][k]), .Q2(Q[2][k]), .Q3(Q[3][k])
                        );*/
         ST_SPHD_LOLEAK_4096x32m8_bTMRl_wrapper SRAM_equivalent_i
         (
            .CK    ( clk         ),
            .INITN ( 1'b1        ),
            .D     ( D_concatenated[k]           ),
            .A     ( A[k][0]           ),
            .CSN   ( CEB[k][0]         ),
            .WEN   ( WEB[k][0]         ),
            .M     ( '0        ),
            .Q     ( Q_concatenated[k]         )
         );
        
          end
                                    
    end                                
endgenerate




always @(*)
begin
  current_block_column = (rd_addr[SRAM_totalWordAddr-1:(SRAM_numWordAddr+SRAM_blocks_per_row_log)]);
end
always @(posedge clk or negedge reset)
begin
  if (!reset)
    last_block_column <= 0;
  else
    last_block_column <= current_block_column;
end

endmodule                                    
