import parameters::*;

module adder (
  accumulation_between_pes,
  mode_precision_adder,
  mode_precision_mult,
  mode_precision_layer,
  input_0,
  input_1,
  out // output
);
input accumulation_between_pes; // this variable represents also the bias adding
input [2:0] mode_precision_layer;
input [2:0] mode_precision_adder;
input [2:0] mode_precision_mult;
//input signed  [2*INPUT_CHANNEL_DATA_WIDTH -1:0] input_0;
input signed  [ACC_DATA_WIDTH -1:0] input_0;
input signed [ACC_DATA_WIDTH -1:0] input_1;
output  reg signed [ACC_DATA_WIDTH-1:0] out;

//signals
reg signed [ACT_DATA_WIDTH/2-1:0] subword_input_0;
reg signed  [ACT_DATA_WIDTH/2-1:0]subword_input_1;
reg signed  [ACC_DATA_WIDTH-1:0] input_muxed;
reg [ACC_DATA_WIDTH -1:0] intermediate_0, intermediate_1, sum_of_intermediates;
reg [ACC_DATA_WIDTH -1:0] intermediate_0_0,intermediate_0_1, intermediate_1_1,intermediate_1_0;
reg signed [ACC_DATA_WIDTH -1:0] input_0_temp;
assign subword_input_1=$signed(input_0[ACT_DATA_WIDTH-1:ACT_DATA_WIDTH/2]);
assign subword_input_0=$signed(input_0[ACT_DATA_WIDTH/2-1:0]);

always @(*)
begin
    case(mode_precision_mult)
    3'b100: 
          
        
           if (accumulation_between_pes==0)
              if (mode_precision_layer==3'b010)
                  input_0_temp = $signed({{28{input_0[3]}},{input_0[3:0]}});
              else if (mode_precision_layer==3'b001)
                  input_0_temp = $signed({{30{input_0[1]}},{input_0[1:0]}});
              else
                  input_0_temp = $signed(input_0);

           else
            input_0_temp=$signed(input_0);
            
    3'b010: input_0_temp = $signed({{16{input_0[15]}},{input_0[15:0]}});
    
    3'b001: input_0_temp = $signed({{16{input_0[15]}},{input_0[15:0]}});
    
    default:input_0_temp = $signed({{16{input_0[15]}},{input_0[15:0]}});
    endcase
    
end

//adder
always @(*)
begin
    intermediate_0= input_0[3:0] + input_1[3:0];
    intermediate_1 = input_0[7:4] + input_1[7:4];
    
    intermediate_0_0 = input_0[1:0]+input_1[1:0];
    intermediate_0_1 = input_0[3:2]+input_1[3:2];
    intermediate_1_0 = input_0[5:4]+input_1[5:4];
    intermediate_1_1 = input_0[7:6]+input_1[7:6];
    
    if (mode_precision_layer==3'b100)
      sum_of_intermediates  = input_0  +input_1;
    else 
      sum_of_intermediates  =   input_0_temp+input_1;
end


always @(*)
begin
  out =0;
  case(mode_precision_adder)
  3'b100: out = sum_of_intermediates;
  3'b010: out = {{intermediate_1[3:0]},{intermediate_0[3:0]}};
  3'b001: out = {{intermediate_1_1[1:0]},{intermediate_1_0[1:0],{intermediate_0_1[1:0]},{intermediate_0_0[1:0]}}};
  default:out = sum_of_intermediates;
  endcase
end


endmodule
