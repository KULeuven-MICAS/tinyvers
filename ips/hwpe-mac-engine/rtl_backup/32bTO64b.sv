`define DESIGN_V2

import parameters::*;


module stream32bTO64b(
clk, reset,
input_en,
input_word,
input_addr,
output_word,
output_addr,
output_en
);

//io
input clk, reset;
input input_en;
//input [31:0] input_word;
input signed [ACT_DATA_WIDTH-1:0] input_word[3:0];

input [31:0] input_addr;
output signed [ACT_DATA_WIDTH-1:0]  output_word [N_DIM_ARRAY-1:0];
output  [31:0] output_addr;
output  output_en;


//signals
integer i;
reg  signed [ACT_DATA_WIDTH-1:0]  output_word_temp[N_DIM_ARRAY-1:0]; 
reg [31:0] output_addr_temp;
reg output_en_temp;

localparam first_32b=0, second_32b=1;
reg state;
reg signed [ACT_DATA_WIDTH-1:0] last_word[3:0];

//Register information
always @(posedge clk or negedge reset)
        begin
        if (!reset)
		for (i=0; i<4;i=i+1)
	                last_word[i] <= 0;
        else
                if (input_en)
                        last_word <= input_word;
end

// next state logic
always @(posedge clk or negedge reset)
begin
	if (!reset)
		state <= first_32b;
	else
		if (input_en)
			case(state)
			first_32b: state <= second_32b;
			second_32b: state <= first_32b;
			endcase
end



// output logic
always @(*)
begin
  output_addr_temp=input_addr;
end
always @(*)
        begin
        case(state)
                        first_32b: output_en_temp=0;
                        second_32b: output_en_temp=input_en;
                        endcase

        end

always @(*)
begin
	for (i=0;i<N_DIM_ARRAY; i=i+1)
	begin
		if (i<N_DIM_ARRAY/2)
			output_word_temp[i] = last_word[i];	
		else
			output_word_temp[i] = input_word[i-N_DIM_ARRAY/2];
	end
end

assign output_addr=output_addr_temp;
assign output_en=output_en_temp;
assign output_word = output_word_temp;
//assign output_addr=input_addr;
//assign output_en=input_en;
//assign output_word = input_word;

endmodule
