`define DESIGN_V2

import parameters::*;

module output_buffer(
mode, 
clk, reset,
input_word,
input_addr,
input_en,
output_word,
output_addr,
output_en
);

//io
input [2:0] mode;
input clk, reset;
input signed  [ACT_DATA_WIDTH - 1:0] input_word [N_DIM_ARRAY-1:0];
input input_en;
input [31:0] input_addr;
output reg [31:0] output_addr;
output reg signed [ACT_DATA_WIDTH-1:0]output_word[N_DIM_ARRAY-1:0];
output reg output_en;

// signals
integer i, j,k;
reg signed  [INPUT_CHANNEL_DATA_WIDTH-1:0]buffer[N_DIM_ARRAY-1:0][N_DIM_ARRAY-1:0];
reg signed [INPUT_CHANNEL_DATA_WIDTH-1:0] buffer_fc[N_DIM_ARRAY-1:0];
reg signed [ACT_DATA_WIDTH-1:0]output_word_temp[3:0];
reg output_en_temp;
reg [2:0] current_mode;

always @(posedge clk or negedge reset)
begin
	if (!reset)
		current_mode <= 0;
	else
		if (input_en)
			current_mode <= mode;
end
//logic

always @(*)
begin
	if (N_DIM_ARRAY==4)
		begin
			output_en=input_en;
			output_word=input_word;
			output_addr=input_addr;
		end	
	else if (N_DIM_ARRAY==8)
		begin
			output_en=input_en;
			output_word=input_word;
			output_addr=input_addr;
		end
end


//FIFO logic
reg [3:0] WR_FIFO_POINTER;
reg [3:0] RD_FIFO_POINTER;
wire full_cnn, full_fc;
wire empty_cnn, empty_fc;
reg empty;
reg full;
assign full_cnn=(WR_FIFO_POINTER[2:0]==0 && (RD_FIFO_POINTER[3:0] != WR_FIFO_POINTER[3:0]));
assign empty_cnn=(RD_FIFO_POINTER[3:0]==WR_FIFO_POINTER[3:0]);
assign full_fc=(WR_FIFO_POINTER[0]==0 && (RD_FIFO_POINTER[1:0] != WR_FIFO_POINTER[1:0]));
assign empty_fc=(RD_FIFO_POINTER[1:0]==WR_FIFO_POINTER[1:0]);

always @(*)
begin
	empty=empty_fc;
	full = full_fc;
	if (current_mode==MODE_CNN)
	begin
 	  empty=empty_cnn;
          full = full_cnn;
 
	end

end

always @(posedge clk or negedge reset)
	begin
		if (!reset)
			WR_FIFO_POINTER <=0;
		else
			if (input_en)
				WR_FIFO_POINTER <= WR_FIFO_POINTER+1;
	end

always @(posedge clk or negedge reset)
	begin
		if (!reset)
			for (i=0; i<N_DIM_ARRAY; i=i+1)
				for (j=0; j<N_DIM_ARRAY; j=j+1)
					buffer[i][j]<=0;
		
		else
			if (input_en)
				begin
				buffer[WR_FIFO_POINTER[2:0]] <= input_word;
				end
	end

//FSM reading
localparam [2:0] IDLE=0, READING_0=1, READING_1=2, READING_0_FC=3, READING_1_FC=4;
reg [2:0] state, next_state;

always @(posedge clk or negedge reset)
	begin
if (!reset)
	state <= IDLE;
else
	state <= next_state;
end

always @(*)
begin
case(state)
IDLE:
		if (full)
			next_state = READING_0;
		else
			next_state = state;
READING_0:
		if (empty)
			next_state = IDLE;
		else
			next_state= READING_1;

READING_1:
	
	if (empty)
		next_state=IDLE;
	else
		next_state=READING_0;


endcase
end

always @(posedge clk or negedge reset)
begin
	if (!reset)
		RD_FIFO_POINTER <= 0;
	else
	begin
	case(state)
	IDLE:
		RD_FIFO_POINTER<= RD_FIFO_POINTER;
	READING_0:
		RD_FIFO_POINTER <= RD_FIFO_POINTER;
	READING_1:
		RD_FIFO_POINTER <= RD_FIFO_POINTER+1;
	endcase
	end
end
always @(*)
begin
                           output_en_temp =0;
                        for (i=0; i<N_DIM_ARRAY; i=i+1)
                                output_word_temp[i] =0;
	
       case(state)
	IDLE:
		begin
			output_en_temp =0;
			for (i=0; i<N_DIM_ARRAY; i=i+1)
				output_word_temp[i] =0;
		end
	READING_0:
		begin  
                        if (!empty)
			begin
			output_en_temp=1;
			output_word_temp = buffer[RD_FIFO_POINTER[2:0]][3:0];
			end
		end
	READING_1: 
		begin 
			if (!empty)
			begin
			output_en_temp=1;
                        output_word_temp = buffer[RD_FIFO_POINTER[2:0]][7:4];
			end
		end
	
	endcase
end
endmodule
