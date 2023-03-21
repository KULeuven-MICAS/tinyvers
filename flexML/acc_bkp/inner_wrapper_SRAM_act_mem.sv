import parameters::*;

module inner_wrapper_SRAM_act_mem #(
parameter integer SRAM_blocks_per_row=4,
parameter integer SRAM_blocks_per_column=2,
parameter SRAM_numBit = 8,
parameter SRAM_numWordAddr = 7
) (
    clk, reset,
    rd_enable,
    rd_addr,
    rd_data,
    wr_enable_ext,
    wr_addr_ext,
    wr_data_ext,
    rd_enable_ext,
    rd_addr_ext,
    rd_data_ext,
    wr_enable,
    wr_addr,
    wr_data
);

parameter SRAM_blocks_per_row_log = $clog2(SRAM_blocks_per_row);
parameter SRAM_totalWordAddr = SRAM_numWordAddr + SRAM_blocks_per_row_log + $clog2(SRAM_blocks_per_column);


//IO
input clk, reset;
input rd_enable, wr_enable;
input signed [SRAM_numBit-1:0] wr_data [SRAM_blocks_per_row-1:0];
//input [SRAM_totalWordAddr-1:0] wr_addr [SRAM_blocks_per_row-1:0];
input [SRAM_totalWordAddr-1:0] wr_addr;
input [SRAM_totalWordAddr-1:0] rd_addr;
input [SRAM_totalWordAddr-1:0] wr_addr_ext;
input wr_enable_ext;
input signed [SRAM_numBit-1:0] wr_data_ext [SRAM_blocks_per_row-1:0];
input rd_enable_ext;
input [SRAM_totalWordAddr-1:0] rd_addr_ext;
output reg signed [SRAM_numBit-1:0] rd_data_ext [N_DIM_ARRAY-1:0];
output signed [SRAM_numBit-1:0] rd_data [SRAM_blocks_per_row-1:0];

//Signals

reg signed [SRAM_numBit-1:0] rd_data_temp [SRAM_blocks_per_row-1:0];
reg [SRAM_totalWordAddr-1:0] rd_addr_muxed;
reg rd_enable_muxed;
reg rd_enable_ext_reg;
reg rd_enable_reg_0;
reg rd_enable_reg_1;
reg [SRAM_totalWordAddr-1:0] rd_addr_reg; // last read address
reg [SRAM_totalWordAddr-(SRAM_numWordAddr+SRAM_blocks_per_row_log)-1:0] last_block_column; //last block column
reg [SRAM_totalWordAddr-(SRAM_numWordAddr+SRAM_blocks_per_row_log)-1:0] current_block_column ; //last block column
reg CEB [SRAM_blocks_per_column-1:0][SRAM_blocks_per_row-1:0];
reg WEB [SRAM_blocks_per_column-1:0][SRAM_blocks_per_row-1:0];
reg [SRAM_numWordAddr-1:0] A [SRAM_blocks_per_column-1:0][SRAM_blocks_per_row-1:0];
reg [SRAM_numBit-1:0] D [SRAM_blocks_per_column-1:0][SRAM_blocks_per_row-1:0];


wire [SRAM_blocks_per_row*SRAM_numBit-1:0] D_concatenated [SRAM_blocks_per_column-1:0];


reg [SRAM_numBit-1:0] BWEB [SRAM_blocks_per_column-1:0];
wire [SRAM_numBit-1:0] Q [SRAM_blocks_per_column-1:0][SRAM_blocks_per_row-1:0];
wire [SRAM_blocks_per_row*SRAM_numBit-1:0] Q_concatenated [SRAM_blocks_per_column-1:0];
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
reg [1:0] TSEL_WP[SRAM_blocks_per_column-1:0];
reg updated_rd_address_reg;
wire updated_rd_address;
reg state;
// Genvar
integer i;
integer m;
integer n;
integer h;
genvar j;
genvar k;           
      
// there is a new transaction in case the rd_enable is 1 and the MSB of the address sent is different from the previous cycle. An exception is done when the 2 accesses are done to the same address.
assign updated_rd_address= rd_enable_muxed && (rd_addr_muxed[SRAM_totalWordAddr-1:SRAM_blocks_per_row_log] !=rd_addr_reg[SRAM_totalWordAddr-1:SRAM_blocks_per_row_log]) || (rd_addr_muxed == rd_addr_reg);



// Read Port

//muxing
always @(*)
begin
    if (rd_enable_ext==1)
    begin
      rd_enable_muxed=rd_enable_ext;
      rd_addr_muxed=rd_addr_ext;
    end 
    else
    begin
      rd_enable_muxed=rd_enable;
      rd_addr_muxed=rd_addr;
    end
end


always @(*)
begin
  for (m=0; m < (SRAM_blocks_per_column); m=m+1) 
  begin
  
    // Default values
     TSEL_RP[m]=2'b01;
    BWEB_RP[m]=0;    
    for (i=0; i < (SRAM_blocks_per_row); i=i+1) 
      begin
            D_RP[m][i]=0;
              CEB_RP[m][i]=1;  
             A_RP[m][i]=0;
            WEB_RP[m][i]=1;
      end    
   
   
 /// Internal reading  
    for (i=0; i < (SRAM_blocks_per_row); i=i+1) 
      begin
      // If there is a new read from the activation memory and the correspoding block is requested
    if ((rd_enable_muxed==1) && (m==(rd_addr_muxed[SRAM_totalWordAddr-1:(SRAM_numWordAddr+SRAM_blocks_per_row_log)] )))
          begin
          
          // Select the output from the last block activated in case a new block is accessed in the current cycle
           if ( last_block_column != current_block_column)
                  rd_data_temp[i]= Q[last_block_column][i][SRAM_numBit-1:0];       
           else   
                  rd_data_temp[i]=Q[current_block_column][i][SRAM_numBit-1:0];  
           
           // Only assert Chip select if the address has been updated
           if (updated_rd_address)
                  begin
                  CEB_RP[m][i]=0;
                  WEB_RP[m][i]=1;
                  A_RP[m][i]= rd_addr_muxed[(SRAM_numWordAddr+SRAM_blocks_per_row_log)-1:SRAM_blocks_per_row_log];
                  end
                  else
                  begin
                  CEB_RP[m][i]=1;
                  WEB_RP[m][i]=1;
                  A_RP[m][i]= rd_addr_muxed[(SRAM_numWordAddr+SRAM_blocks_per_row_log)-1:SRAM_blocks_per_row_log];
                  end
          end
      else
            rd_data_temp[i]= Q[last_block_column][i][SRAM_numBit-1:0];      
          
    end   
    end 
    

    
    
    
    
    
    end




//Write Port
always @(*)
begin
    //Default values
     for (m=0; m < (SRAM_blocks_per_column); m=m+1) 
     begin
     BWEB_WP[m]=0;
    TSEL_WP[m]=2'b01;
     for (i=0; i < (SRAM_blocks_per_row); i=i+1) 
      begin
          A_WP[m][i]= 0;
          D_WP[m][i] = 0;
          CEB_WP[m][i]=1;
          WEB_WP[m][i]=1;
     end
    end 
    


for (i=0; i < SRAM_blocks_per_row; i=i+1)
  begin
    for (m=0; m< (SRAM_blocks_per_column); m=m+1)
      begin
       // External writing  (wr_enable_ext==1)
       if ((wr_enable_ext==1)  && (m==wr_addr_ext[SRAM_totalWordAddr-1:(SRAM_numWordAddr+SRAM_blocks_per_row_log)]))
        begin
          A_WP[m][i]= wr_addr_ext[(SRAM_numWordAddr+SRAM_blocks_per_row_log)-1:SRAM_blocks_per_row_log];
          D_WP[m][i] = wr_data_ext[i];
          CEB_WP[m][i]=0;
          WEB_WP[m][i]=0;
        end 
       // Internal Writing (wr_enable==1)
         else if ((wr_enable==1) && (m==wr_addr[SRAM_totalWordAddr-1:(SRAM_numWordAddr+SRAM_blocks_per_row_log)]))
          begin
            A_WP[m][i]= wr_addr[(SRAM_numWordAddr+SRAM_blocks_per_row_log)-1:SRAM_blocks_per_row_log];
            D_WP[m][i]= wr_data[i];
            CEB_WP[m][i]=0;
          WEB_WP[m][i]=0;
          end
      end
  end
 
 
 
 end


//SELECTION OF READ OR WRITING PORT FOR SRAM estimulation
always @(*)
begin

  // If a write transaction is needed
  if ((wr_enable_ext==1) || (wr_enable==1))
  begin
   CEB = CEB_WP;
   WEB = WEB_WP;
   A = A_WP;
   D = D_WP;
   BWEB = BWEB_WP;
   TSEL = TSEL_WP;
  end
  else // Use Read Port as default
  begin
   CEB = CEB_RP;
   WEB = WEB_RP;
   A = A_RP;
   D = D_RP;
   BWEB = BWEB_RP;
   TSEL = TSEL_RP;
  end
end 

//Concatenation of the output of the SRAM blocks
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

//SRAM instances
generate
    
    for (k=0; k < (SRAM_blocks_per_column); k=k+1) begin: generation_blocks 
       /*TS1N65LPLL2048X32M8  SRAM_i(                             
                       
                        .CLK(clk),  .CEB(CEB[k][0]), .WEB(WEB[k][0]),

                         .A(A[k][0]), .D({D[k][3], D[k][2], D[k][1],D[k][0]}), .BWEB({BWEB[0],BWEB[1],BWEB[2],BWEB[3]}),

                      
                        .Q(Q_concatenated[k]),

                        .TSEL(TSEL[k])
                                    );              */  
       
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


// Reading from last block
always @(*)
begin
      current_block_column= (rd_addr_muxed[SRAM_totalWordAddr-1:(SRAM_numWordAddr+SRAM_blocks_per_row_log)]);
end
always @(posedge clk or negedge reset)
begin
  if (!reset)
    last_block_column<= 0;
  else
    if (rd_enable_muxed==1)
    last_block_column <= current_block_column;
end

always @(posedge clk or negedge reset)
begin
  if (!reset)
    begin
    rd_addr_reg <= 0;
    rd_enable_ext_reg <= 0;
    end
    else
      // if the address has changed
       begin
       rd_enable_ext_reg <= rd_enable_ext;
      if (rd_enable)
        begin
          begin
          rd_addr_reg <= rd_addr_muxed;
          end
        end
        end
end

always @(*)
begin
  if (rd_enable_ext_reg==1)
    rd_data_ext = rd_data_temp;
  else
    for (i=0; i<N_DIM_ARRAY; i=i+1)
      rd_data_ext[i]=0;
end

assign rd_data =rd_data_temp;

endmodule                                    
