module lint64_to_32 (
	clk,
	rst_n,
	data_req_i,
	data_gnt_o,
	data_wdata_i,
	data_add_i,
	data_wen_i,
	data_be_i,
	data_size_i,
	data_r_valid_o,
	data_r_rdata_o,
	data_req_o,
	data_gnt_i,
	data_wdata_o,
	data_add_o,
	data_wen_o,
	data_be_o,
	data_r_valid_i,
	data_r_rdata_i
);
	input wire clk;
	input wire rst_n;
	input wire data_req_i;
	output reg data_gnt_o;
	input wire [63:0] data_wdata_i;
	input wire [31:0] data_add_i;
	input wire data_wen_i;
	input wire [7:0] data_be_i;
	input wire data_size_i;
	output reg data_r_valid_o;
	output reg [63:0] data_r_rdata_o;
	output reg [1:0] data_req_o;
	input wire [1:0] data_gnt_i;
	output wire [63:0] data_wdata_o;
	output reg [63:0] data_add_o;
	output reg [1:0] data_wen_o;
	output wire [7:0] data_be_o;
	input wire [1:0] data_r_valid_i;
	input wire [63:0] data_r_rdata_i;
	reg [2:0] CS;
	reg [2:0] NS;
	reg [63:0] data_r_rdata_q;
	wire [1:0] sample_rdata;
	reg [1:0] gnt_mask;
	reg [1:0] rvalid_mask;
	reg [1:0] size_offset_info;
	reg update_rvalid_mask;
	assign data_wdata_o = data_wdata_i;
	assign data_be_o = data_be_i;
	always @(posedge clk or negedge rst_n)
		if (~rst_n) begin
			CS <= 3'd0;
			data_r_rdata_q <= 1'sb0;
			size_offset_info <= 1'sb0;
			rvalid_mask <= 1'sb0;
		end
		else begin
			CS <= NS;
			if (sample_rdata[0])
				data_r_rdata_q[0+:32] <= data_r_rdata_i[0+:32];
			if (sample_rdata[1])
				data_r_rdata_q[32+:32] <= data_r_rdata_i[32+:32];
			if (data_req_i & data_gnt_o)
				size_offset_info <= {data_size_i, data_add_i[2]};
			if (update_rvalid_mask)
				rvalid_mask <= gnt_mask;
		end
	assign sample_rdata = data_r_valid_i;
	always @(*) begin
		data_req_o = 1'sb0;
		data_add_o = (data_size_i ? {{data_add_i[31:3], 3'b000} + 4, data_add_i[31:3], 3'b000} : {data_add_i, data_add_i});
		data_wen_o = {data_wen_i, data_wen_i};
		data_r_valid_o = 1'sb0;
		data_r_rdata_o = data_r_rdata_i;
		data_gnt_o = 1'sb0;
		gnt_mask = 2'b00;
		update_rvalid_mask = 1'sb0;
		NS = CS;
		case (CS)
			3'd0: begin
				if (data_size_i) begin
					data_req_o = {data_req_i, data_req_i};
					gnt_mask = 2'b00;
				end
				else
					case (data_add_i[2])
						1'b0: begin
							data_req_o = {1'b0, data_req_i};
							gnt_mask = 2'b10;
						end
						1'b1: begin
							data_req_o = {data_req_i, 1'b0};
							gnt_mask = 2'b01;
						end
					endcase
				if (data_req_i)
					case (data_gnt_i | gnt_mask)
						2'b00: NS = 3'd0;
						2'b01: begin
							NS = 3'd1;
							update_rvalid_mask = 1'b1;
						end
						2'b10: begin
							NS = 3'd2;
							update_rvalid_mask = 1'b1;
						end
						2'b11: begin
							NS = 3'd3;
							data_gnt_o = 1'b1;
							update_rvalid_mask = 1'b1;
						end
					endcase
				else
					NS = 3'd0;
			end
			3'd1: begin
				data_req_o = 2'b10;
				if (data_gnt_i[1]) begin
					NS = 3'd4;
					data_gnt_o = 1'b1;
				end
				else
					NS = 3'd1;
			end
			3'd2: begin
				data_req_o = 2'b01;
				if (data_gnt_i[0]) begin
					NS = 3'd5;
					data_gnt_o = 1'b1;
				end
				else
					NS = 3'd2;
			end
			3'd3: begin
				data_r_valid_o = &(data_r_valid_i | rvalid_mask);
				if (size_offset_info[1])
					data_r_rdata_o = data_r_rdata_i;
				else
					data_r_rdata_o = (size_offset_info[0] ? {data_r_rdata_i[32+:32], 32'h00000000} : {32'h00000000, data_r_rdata_i[0+:32]});
				if (&(data_r_valid_i | rvalid_mask)) begin
					if (data_size_i) begin
						data_req_o = {data_req_i, data_req_i};
						gnt_mask = 2'b00;
					end
					else
						case (data_add_i[2])
							1'b0: begin
								data_req_o = {1'b0, data_req_i};
								gnt_mask = 2'b10;
							end
							1'b1: begin
								data_req_o = {data_req_i, 1'b0};
								gnt_mask = 2'b01;
							end
						endcase
					if (data_req_i)
						case (data_gnt_i | gnt_mask)
							2'b00: NS = 3'd0;
							2'b01: begin
								NS = 3'd1;
								update_rvalid_mask = 1'b1;
							end
							2'b10: begin
								NS = 3'd2;
								update_rvalid_mask = 1'b1;
							end
							2'b11: begin
								NS = 3'd3;
								data_gnt_o = 1'b1;
								update_rvalid_mask = 1'b1;
							end
						endcase
					else
						NS = 3'd0;
				end
				else
					case (data_r_valid_i | rvalid_mask)
						2'b00: NS = 3'd3;
						2'b10: NS = 3'd5;
						2'b01: NS = 3'd4;
						default: NS = 3'd3;
					endcase
			end
			3'd4: begin
				data_r_valid_o = data_r_valid_i[1];
				data_r_rdata_o = {data_r_rdata_i[32+:32], data_r_rdata_q[0+:32]};
				if (data_r_valid_i[1]) begin
					if (data_size_i) begin
						data_req_o = {data_req_i, data_req_i};
						gnt_mask = 2'b00;
					end
					else
						case (data_add_i[2])
							1'b0: begin
								data_req_o = {1'b0, data_req_i};
								gnt_mask = 2'b10;
							end
							1'b1: begin
								data_req_o = {data_req_i, 1'b0};
								gnt_mask = 2'b01;
							end
						endcase
					if (data_req_i)
						case (data_gnt_i)
							2'b00: NS = 3'd0;
							2'b01: begin
								NS = 3'd1;
								update_rvalid_mask = 1'b1;
							end
							2'b10: begin
								NS = 3'd2;
								update_rvalid_mask = 1'b1;
							end
							2'b11: begin
								NS = 3'd3;
								data_gnt_o = 1'b1;
								update_rvalid_mask = 1'b1;
							end
						endcase
					else
						NS = 3'd0;
				end
				else
					NS = 3'd4;
			end
			3'd5: begin
				data_r_valid_o = data_r_valid_i[0];
				data_r_rdata_o = {data_r_rdata_q[32+:32], data_r_rdata_i[0+:32]};
				if (data_r_valid_i[0]) begin
					if (data_size_i) begin
						data_req_o = {data_req_i, data_req_i};
						gnt_mask = 2'b00;
					end
					else
						case (data_add_i[2])
							1'b0: begin
								data_req_o = {1'b0, data_req_i};
								gnt_mask = 2'b10;
							end
							1'b1: begin
								data_req_o = {data_req_i, 1'b0};
								gnt_mask = 2'b01;
							end
						endcase
					if (data_req_i)
						case (data_gnt_i)
							2'b00: NS = 3'd0;
							2'b01: begin
								NS = 3'd1;
								update_rvalid_mask = 1'b1;
							end
							2'b10: begin
								NS = 3'd2;
								update_rvalid_mask = 1'b1;
							end
							2'b11: begin
								NS = 3'd3;
								data_gnt_o = 1'b1;
								update_rvalid_mask = 1'b1;
							end
						endcase
					else
						NS = 3'd0;
				end
				else
					NS = 3'd5;
			end
		endcase
	end
endmodule
