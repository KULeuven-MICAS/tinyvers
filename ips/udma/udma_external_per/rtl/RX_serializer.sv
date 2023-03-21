module RX_serializer
#(
   parameter TRANS_SIZE = 16
)
(
   input  logic                        sys_clk,
   input  logic                        rst_n,

   // signal from DC_FIFO
   input  logic [63:0]                 data_rx_rdata_i,
   input  logic                        data_rx_valid_i,
   output logic                        data_rx_ready_o,

   //Signal To L2
   output logic [31:0]                 data_rx_rdata_o,
   output logic                        data_rx_valid_o,
   input  logic                        data_rx_ready_i
);




   enum logic { SER_IDLE, SER_DISP} NS_SER, CS_SER;

   always_ff @(posedge sys_clk or negedge rst_n)
   begin
      if(~rst_n)
      begin
         CS_SER <= SER_IDLE;
      end
      else
      begin
         CS_SER <= NS_SER;
      end
   end

   always_comb 
   begin : proc_serializer_rdata
      data_rx_ready_o   = 1'b0;
      data_rx_valid_o   = 0;
      data_rx_rdata_o   = data_rx_rdata_i[31:0];

      case(CS_SER)
         SER_IDLE:
         begin
            data_rx_valid_o  = data_rx_valid_i;
            data_rx_ready_o  = 1'b0; // old data

            if( data_rx_valid_i & data_rx_ready_i )
               NS_SER = SER_DISP;
            else
               NS_SER = SER_IDLE;
         end

         SER_DISP:
         begin
            data_rx_valid_o   = 1'b1;
            data_rx_ready_o   = data_rx_ready_i;
            data_rx_rdata_o   = data_rx_rdata_i[63:32];

            if( data_rx_ready_i )
               NS_SER = SER_IDLE;
            else
               NS_SER = SER_DISP;

         end

      endcase
   end

endmodule // RX_deserializer