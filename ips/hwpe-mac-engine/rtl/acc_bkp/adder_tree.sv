import parameters::*;

module adder_tree(
operands,
result
);

wire signed [ACC_DATA_WIDTH-1:0] intermediate [N_DIM_ARRAY-1:0];

input signed [ACC_DATA_WIDTH-1:0]  operands [N_DIM_ARRAY-1:0];
output signed [ACC_DATA_WIDTH-1:0] result;
//reg

genvar i;
assign result = intermediate[N_DIM_ARRAY-1];
generate 
   for (i=0; i<N_DIM_ARRAY; i=i+1) begin: row
        if (i==0)
          assign intermediate[i]=operands[i];
        else
          assign intermediate[i]=intermediate[i-1]+operands[i];
  end

endgenerate 


endmodule