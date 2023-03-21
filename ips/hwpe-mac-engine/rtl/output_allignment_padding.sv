`define DESIGN_V2

import parameters::*;

module output_allignment_padding(
	clk, reset,
	reinitialize_padding,
	padd_zeros_left,
	padd_zeros_right,

	input_word,
	input_enable,

	output_word,
	output_enable
);
input clk, reset;
input [2:0] padd_zeros_left;
input [2:0] padd_zeros_right;
input reinitialize_padding;
input signed  [ACT_DATA_WIDTH - 1:0] input_word [N_DIM_ARRAY-1:0]; 
input input_enable;

output reg signed  [ACT_DATA_WIDTH - 1:0] output_word [N_DIM_ARRAY-1:0];
output reg output_enable;
integer i;
integer j;
// MEMORY
reg signed [ACT_DATA_WIDTH -1:0] memory[N_DIM_ARRAY-1:0][N_DIM_ARRAY-1:0];
// up to 64
reg [2:0] counter;

always @(*)
begin
	output_enable=input_enable;
   if (padd_zeros_left ==0)
   begin
    output_word=input_word;
    end
    else
    begin
       
	   for (i=0; i<N_DIM_ARRAY; i=i+1)
                 begin
			 if (i< padd_zeros_left)
			    // Bug fixing SEBASTIAN (SEPTEMBER 2020) POST TAPE OUT	
                            //output_word[i]= memory[counter][(N_DIM_ARRAY-1)- i];
                               output_word[i] = memory[counter][(N_DIM_ARRAY)-padd_zeros_left + i ];
		         else
		            output_word[i]= input_word[i-padd_zeros_left];

		 end

    end


    // PADDING ZEROS TO THE RIGHT
    if (padd_zeros_right == 0)
    begin
	    output_word = output_word;
    end
    else
    begin
	    for (i=0; i<N_DIM_ARRAY; i=i+1)
                 begin
			 if (i<padd_zeros_right)
				 output_word[(N_DIM_ARRAY-1)-i]=0;
                 end
    end

end

always @(posedge clk or negedge reset)
begin
	if (!reset)
		counter <= 0;
	else
		if (input_enable)
			counter <= counter+1;
end


always @(posedge clk or negedge reset)
begin
	if (!reset)
		for (i=0; i<N_DIM_ARRAY; i=i+1)
			for (j=0; j<N_DIM_ARRAY; j=j+1)
				memory[i][j]<=0;
	else 
		if (reinitialize_padding)
			for (i=0; i<N_DIM_ARRAY; i=i+1)
                         for (j=0; j<N_DIM_ARRAY; j=j+1)
                                 memory[i][j]<=0;

		else
		if (input_enable)
		 memory[counter] <= input_word;
end



endmodule
