`timescale 1ns/10ps
module reg_arstn #(
parameter integer DATA_W     = 20,
parameter integer PRESET_VAL = 'b0
   )(
      input                  clk,
      input                  arst_n,
      input  [ DATA_W-1:0]   din,
      output [ DATA_W-1:0]   dout,
      input 		     wen
);

reg [DATA_W-1:0] r,nxt;

always@(posedge clk, negedge arst_n)begin
   if(arst_n==0)begin
      r <= PRESET_VAL;
   end else begin
      if(wen)
        r <= nxt;
   end
end

always@(*) begin
   nxt = din;
end

assign dout = r;

endmodule
