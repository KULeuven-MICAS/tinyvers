module cam_vip (
	cam_pclk_o,
	cam_vsync_o,
	cam_href_o,
	cam_data_o
);
	parameter HRES = 640;
	parameter VRES = 480;
	output reg cam_pclk_o;
	output reg cam_vsync_o;
	output reg cam_href_o;
	output wire [7:0] cam_data_o;
	localparam clk_period = 150;
	localparam TP = 2;
	localparam TLINE = (HRES + 144) * TP;
	reg [23:0] pixel_array0 [(HRES * VRES) - 1:0];
	reg [23:0] pixel_array1 [(HRES * VRES) - 1:0];
	reg [15:0] s_targetcnt;
	reg s_startcnt;
	reg s_rstn;
	reg [15:0] r_counter;
	reg [15:0] r_target;
	reg [15:0] r_colptr;
	reg [15:0] s_colptr;
	reg [15:0] r_lineptr;
	reg [15:0] s_lineptr;
	wire [23:0] s_currentpixel;
	reg r_bytesel;
	reg s_bytesel;
	reg r_framesel;
	reg s_framesel;
	reg r_done;
	reg r_active;
	string vsim_path;
	string frame0_path;
	string frame1_path;
	reg [4:0] state;
	reg [4:0] state_next;
	assign s_currentpixel = (r_framesel ? pixel_array1[(r_lineptr * HRES) + r_colptr] : pixel_array0[(r_lineptr * HRES) + r_colptr]);
	assign cam_data_o = (r_bytesel ? {s_currentpixel[12:10], s_currentpixel[7:3]} : {s_currentpixel[23:19], s_currentpixel[15:13]});
	initial begin
		cam_pclk_o = 1'b1;
		#(clk_period)
			;
		forever cam_pclk_o = #(clk_period / 2) ~cam_pclk_o;
	end
	initial begin
		s_rstn = 1'b0;
		if ($test$plusargs("VSIM_PATH"))
			if (!$value$plusargs("VSIM_PATH=%s", vsim_path))
				vsim_path = "../";
		frame0_path = {vsim_path, "/../rtl/vip/camera/img/frame0.img"};
		frame1_path = {vsim_path, "/../rtl/vip/camera/img/frame1.img"};
		$readmemh(frame0_path, pixel_array0);
		$readmemh(frame1_path, pixel_array1);
		#(30ms) s_rstn = 1'b1;
	end
	always @(*) begin : proc_sm
		cam_vsync_o = 1'b0;
		cam_href_o = 1'b0;
		s_startcnt = 1'b0;
		s_targetcnt = 'h0;
		s_lineptr = r_lineptr;
		s_colptr = r_colptr;
		s_bytesel = r_bytesel;
		s_framesel = r_framesel;
		state_next = state;
		case (state)
			5'd0: begin
				state_next = 5'd1;
				s_startcnt = 1'b1;
				s_targetcnt = 3 * TLINE;
				s_bytesel = 1'b0;
				s_framesel = 1'b0;
			end
			5'd1: begin
				cam_vsync_o = 1'b1;
				if (r_done) begin
					state_next = 5'd2;
					s_startcnt = 1'b1;
					s_targetcnt = 17 * TLINE;
				end
			end
			5'd2:
				if (r_done) begin
					state_next = 5'd4;
					s_lineptr = 'h0;
					s_colptr = 'h0;
				end
			5'd4: begin
				cam_href_o = 1'b1;
				if (r_bytesel == 1) begin
					s_bytesel = 1'b0;
					if (r_colptr == (HRES - 1)) begin
						s_colptr = 'h0;
						if (r_lineptr == (VRES - 1)) begin
							state_next = 5'd3;
							s_startcnt = 1'b1;
							s_targetcnt = 10 * TLINE;
							s_lineptr = 'h0;
						end
						else
							s_lineptr = r_lineptr + 1;
					end
					else
						s_colptr = r_colptr + 1;
				end
				else
					s_bytesel = 1'b1;
			end
			5'd3:
				if (r_done) begin
					state_next = 5'd1;
					s_startcnt = 1'b1;
					s_targetcnt = 3 * TLINE;
					s_framesel = ~r_framesel;
				end
		endcase
	end
	always @(posedge cam_pclk_o or negedge s_rstn) begin : proc_r_bytesel
		if (~s_rstn) begin
			r_bytesel <= 'h0;
			r_colptr <= 'h0;
			r_lineptr <= 'h0;
			r_framesel <= 'h0;
		end
		else begin
			r_bytesel <= s_bytesel;
			r_colptr <= s_colptr;
			r_lineptr <= s_lineptr;
			r_framesel <= s_framesel;
		end
	end
	always @(posedge cam_pclk_o or negedge s_rstn) begin : proc_r_counter
		if (~s_rstn) begin
			r_counter <= 0;
			r_target <= 0;
			r_active <= 0;
		end
		else if (r_active) begin
			if (r_counter == r_target) begin
				r_done <= 1'b1;
				r_counter <= 'h0;
				r_active <= 1'b0;
			end
			else begin
				r_counter <= r_counter + 1;
				r_done <= 1'b0;
			end
		end
		else begin
			if (s_startcnt) begin
				r_active <= 1'b1;
				r_target <= s_targetcnt;
			end
			r_counter <= 'h0;
			r_done <= 1'b0;
		end
	end
	always @(posedge cam_pclk_o or negedge s_rstn) begin : proc_state
		if (~s_rstn)
			state <= 5'd0;
		else
			state <= state_next;
	end
endmodule
