module pulpemu_stdout (
	ref_clk_i,
	rst_ni,
	fetch_en_i,
	stdout_slave_aw_valid,
	stdout_slave_aw_addr,
	stdout_slave_aw_prot,
	stdout_slave_aw_region,
	stdout_slave_aw_len,
	stdout_slave_aw_size,
	stdout_slave_aw_burst,
	stdout_slave_aw_lock,
	stdout_slave_aw_cache,
	stdout_slave_aw_qos,
	stdout_slave_aw_id,
	stdout_slave_aw_user,
	stdout_slave_aw_ready,
	stdout_slave_ar_valid,
	stdout_slave_ar_addr,
	stdout_slave_ar_prot,
	stdout_slave_ar_region,
	stdout_slave_ar_len,
	stdout_slave_ar_size,
	stdout_slave_ar_burst,
	stdout_slave_ar_lock,
	stdout_slave_ar_cache,
	stdout_slave_ar_qos,
	stdout_slave_ar_id,
	stdout_slave_ar_user,
	stdout_slave_ar_ready,
	stdout_slave_w_valid,
	stdout_slave_w_data,
	stdout_slave_w_strb,
	stdout_slave_w_user,
	stdout_slave_w_last,
	stdout_slave_w_ready,
	stdout_slave_r_valid,
	stdout_slave_r_data,
	stdout_slave_r_resp,
	stdout_slave_r_last,
	stdout_slave_r_user,
	stdout_slave_r_ready,
	stdout_slave_b_valid,
	stdout_slave_b_resp,
	stdout_slave_b_user,
	stdout_slave_b_ready,
	stdout_master_aw_valid,
	stdout_master_aw_addr,
	stdout_master_aw_prot,
	stdout_master_aw_region,
	stdout_master_aw_len,
	stdout_master_aw_size,
	stdout_master_aw_burst,
	stdout_master_aw_lock,
	stdout_master_aw_cache,
	stdout_master_aw_qos,
	stdout_master_aw_id,
	stdout_master_aw_user,
	stdout_master_aw_ready,
	stdout_master_ar_valid,
	stdout_master_ar_addr,
	stdout_master_ar_prot,
	stdout_master_ar_region,
	stdout_master_ar_len,
	stdout_master_ar_size,
	stdout_master_ar_burst,
	stdout_master_ar_lock,
	stdout_master_ar_cache,
	stdout_master_ar_qos,
	stdout_master_ar_id,
	stdout_master_ar_user,
	stdout_master_ar_ready,
	stdout_master_w_valid,
	stdout_master_w_data,
	stdout_master_w_strb,
	stdout_master_w_user,
	stdout_master_w_last,
	stdout_master_w_ready,
	stdout_master_r_valid,
	stdout_master_r_data,
	stdout_master_r_resp,
	stdout_master_r_last,
	stdout_master_r_id,
	stdout_master_r_user,
	stdout_master_r_ready,
	stdout_master_b_valid,
	stdout_master_b_resp,
	stdout_master_b_id,
	stdout_master_b_user,
	stdout_master_b_ready,
	stdout_flushed,
	stdout_wait
);
	parameter STDOUT_BUFFER_DIM = 65536;
	input wire ref_clk_i;
	input wire rst_ni;
	input wire fetch_en_i;
	output wire stdout_slave_aw_valid;
	output wire [31:0] stdout_slave_aw_addr;
	output wire [2:0] stdout_slave_aw_prot;
	output wire [3:0] stdout_slave_aw_region;
	output wire [7:0] stdout_slave_aw_len;
	output wire [2:0] stdout_slave_aw_size;
	output wire [1:0] stdout_slave_aw_burst;
	output wire stdout_slave_aw_lock;
	output wire [3:0] stdout_slave_aw_cache;
	output wire [3:0] stdout_slave_aw_qos;
	output wire [9:0] stdout_slave_aw_id;
	output wire [5:0] stdout_slave_aw_user;
	input wire stdout_slave_aw_ready;
	output wire stdout_slave_ar_valid;
	output wire [31:0] stdout_slave_ar_addr;
	output wire [2:0] stdout_slave_ar_prot;
	output wire [3:0] stdout_slave_ar_region;
	output wire [7:0] stdout_slave_ar_len;
	output wire [2:0] stdout_slave_ar_size;
	output wire [1:0] stdout_slave_ar_burst;
	output wire stdout_slave_ar_lock;
	output wire [3:0] stdout_slave_ar_cache;
	output wire [3:0] stdout_slave_ar_qos;
	output wire [9:0] stdout_slave_ar_id;
	output wire [5:0] stdout_slave_ar_user;
	input wire stdout_slave_ar_ready;
	output wire stdout_slave_w_valid;
	output wire [31:0] stdout_slave_w_data;
	output wire [3:0] stdout_slave_w_strb;
	output wire [5:0] stdout_slave_w_user;
	output wire stdout_slave_w_last;
	input wire stdout_slave_w_ready;
	input wire stdout_slave_r_valid;
	input wire [31:0] stdout_slave_r_data;
	input wire [1:0] stdout_slave_r_resp;
	input wire stdout_slave_r_last;
	input wire [5:0] stdout_slave_r_user;
	output wire stdout_slave_r_ready;
	input wire stdout_slave_b_valid;
	input wire [1:0] stdout_slave_b_resp;
	input wire [5:0] stdout_slave_b_user;
	output wire stdout_slave_b_ready;
	input wire stdout_master_aw_valid;
	input wire [31:0] stdout_master_aw_addr;
	input wire [2:0] stdout_master_aw_prot;
	input wire [3:0] stdout_master_aw_region;
	input wire [7:0] stdout_master_aw_len;
	input wire [2:0] stdout_master_aw_size;
	input wire [1:0] stdout_master_aw_burst;
	input wire stdout_master_aw_lock;
	input wire [3:0] stdout_master_aw_cache;
	input wire [3:0] stdout_master_aw_qos;
	input wire [9:0] stdout_master_aw_id;
	input wire [5:0] stdout_master_aw_user;
	output wire stdout_master_aw_ready;
	input wire stdout_master_ar_valid;
	input wire [31:0] stdout_master_ar_addr;
	input wire [2:0] stdout_master_ar_prot;
	input wire [3:0] stdout_master_ar_region;
	input wire [7:0] stdout_master_ar_len;
	input wire [2:0] stdout_master_ar_size;
	input wire [1:0] stdout_master_ar_burst;
	input wire stdout_master_ar_lock;
	input wire [3:0] stdout_master_ar_cache;
	input wire [3:0] stdout_master_ar_qos;
	input wire [9:0] stdout_master_ar_id;
	input wire [5:0] stdout_master_ar_user;
	output wire stdout_master_ar_ready;
	input wire stdout_master_w_valid;
	input wire [63:0] stdout_master_w_data;
	input wire [7:0] stdout_master_w_strb;
	input wire [5:0] stdout_master_w_user;
	input wire stdout_master_w_last;
	output wire stdout_master_w_ready;
	output wire stdout_master_r_valid;
	output wire [63:0] stdout_master_r_data;
	output wire [1:0] stdout_master_r_resp;
	output wire stdout_master_r_last;
	output wire [9:0] stdout_master_r_id;
	output wire [5:0] stdout_master_r_user;
	input wire stdout_master_r_ready;
	output wire stdout_master_b_valid;
	output wire [1:0] stdout_master_b_resp;
	output wire [9:0] stdout_master_b_id;
	output wire [5:0] stdout_master_b_user;
	input wire stdout_master_b_ready;
	input wire stdout_flushed;
	output wire stdout_wait;
	localparam STDOUT_THRESHOLD = ((STDOUT_BUFFER_DIM / 4) / 16) * 15;
	localparam STDOUT_ADDR_HIGH = $clog2(STDOUT_BUFFER_DIM / 4) - 1;
	reg [63:0] counter;
	reg [31:0] gen_addr;
	reg [3:0] gen_strb;
	reg [31:0] gen_data;
	reg [1:0] which_core;
	reg ex_stdout_slave_b_valid;
	reg [9:0] stdout_slave_r_id_r;
	wire [9:0] stdout_slave_r_id;
	wire [9:0] stdout_slave_b_id;
	reg stdout_wait_r;
	assign stdout_master_aw_ready = stdout_slave_aw_ready & ~stdout_wait_r;
	assign stdout_master_ar_ready = stdout_slave_ar_ready & ~stdout_wait_r;
	assign stdout_master_w_ready = stdout_slave_w_ready;
	assign stdout_master_r_valid = stdout_slave_r_valid;
	assign stdout_master_r_data = stdout_slave_r_data;
	assign stdout_master_r_resp = stdout_slave_r_resp;
	assign stdout_master_r_last = stdout_slave_r_last;
	assign stdout_master_r_id = stdout_slave_r_id;
	assign stdout_master_r_user = stdout_slave_r_user;
	assign stdout_master_b_valid = stdout_slave_b_valid;
	assign stdout_master_b_resp = stdout_slave_b_resp;
	assign stdout_master_b_id = stdout_slave_b_id;
	assign stdout_master_b_user = stdout_slave_b_user;
	assign stdout_slave_aw_valid = stdout_master_aw_valid;
	assign stdout_slave_aw_addr = gen_addr;
	assign stdout_slave_aw_prot = stdout_master_aw_prot;
	assign stdout_slave_aw_region = stdout_master_aw_region;
	assign stdout_slave_aw_len = stdout_master_aw_len;
	assign stdout_slave_aw_size = stdout_master_aw_size;
	assign stdout_slave_aw_burst = stdout_master_aw_burst;
	assign stdout_slave_aw_lock = stdout_master_aw_lock;
	assign stdout_slave_aw_cache = stdout_master_aw_cache;
	assign stdout_slave_aw_qos = stdout_master_aw_qos;
	assign stdout_slave_aw_id = stdout_master_aw_id;
	assign stdout_slave_aw_user = stdout_master_aw_user;
	assign stdout_slave_ar_valid = stdout_master_ar_valid;
	assign stdout_slave_ar_addr = stdout_master_ar_addr;
	assign stdout_slave_ar_prot = stdout_master_ar_prot;
	assign stdout_slave_ar_region = stdout_master_ar_region;
	assign stdout_slave_ar_len = stdout_master_ar_len;
	assign stdout_slave_ar_size = stdout_master_ar_size;
	assign stdout_slave_ar_burst = stdout_master_ar_burst;
	assign stdout_slave_ar_lock = stdout_master_ar_lock;
	assign stdout_slave_ar_cache = stdout_master_ar_cache;
	assign stdout_slave_ar_qos = stdout_master_ar_qos;
	assign stdout_slave_ar_id = stdout_master_ar_id;
	assign stdout_slave_ar_user = stdout_master_ar_user;
	assign stdout_slave_w_valid = stdout_master_w_valid;
	assign stdout_slave_w_data = gen_data;
	assign stdout_slave_w_strb = gen_strb;
	assign stdout_slave_w_user = stdout_master_w_user;
	assign stdout_slave_w_last = stdout_master_w_last;
	assign stdout_slave_r_ready = stdout_master_r_ready;
	assign stdout_slave_b_ready = stdout_master_b_ready;
	always @(posedge ref_clk_i or negedge rst_ni)
		if (rst_ni == 1'b0)
			stdout_slave_r_id_r = 10'b0000000000;
		else if (stdout_slave_aw_valid == 1'b1)
			stdout_slave_r_id_r = stdout_master_aw_id;
	assign stdout_slave_r_id = (stdout_slave_r_valid == 1'b1 ? stdout_slave_r_id_r : 10'b0000000000);
	assign stdout_slave_b_id = (stdout_slave_b_valid == 1'b1 ? stdout_slave_r_id_r : 10'b0000000000);
	always @(posedge ref_clk_i or negedge rst_ni)
		if (rst_ni == 1'b0)
			ex_stdout_slave_b_valid = 1'b0;
		else
			ex_stdout_slave_b_valid = stdout_slave_b_valid;
	always @(posedge ref_clk_i or negedge rst_ni)
		if (rst_ni == 1'b0)
			stdout_wait_r = 1'b0;
		else if ((((counter[0+:16] >= STDOUT_THRESHOLD) || (counter[16+:16] >= STDOUT_THRESHOLD)) || (counter[32+:16] >= STDOUT_THRESHOLD)) || (counter[48+:16] >= STDOUT_THRESHOLD))
			stdout_wait_r = 1'b1;
		else
			stdout_wait_r = 1'b0;
	assign stdout_wait = stdout_wait_r;
	always @(posedge ref_clk_i or negedge rst_ni)
		if (rst_ni == 1'b0) begin
			counter[0+:16] = 16'h0000;
			counter[16+:16] = 16'h0000;
			counter[32+:16] = 16'h0000;
			counter[48+:16] = 16'h0000;
		end
		else if (fetch_en_i == 1'b0) begin
			counter[0+:16] = 16'h0000;
			counter[16+:16] = 16'h0000;
			counter[32+:16] = 16'h0000;
			counter[48+:16] = 16'h0000;
		end
		else if (stdout_flushed == 1'b1) begin
			counter[0+:16] = 16'h0000;
			counter[16+:16] = 16'h0000;
			counter[32+:16] = 16'h0000;
			counter[48+:16] = 16'h0000;
		end
		else if (stdout_master_w_valid == 1'b1)
			counter[which_core * 16+:16] = counter[which_core * 16+:16] + 16'h0001;
	always @(posedge ref_clk_i or negedge rst_ni)
		if (rst_ni == 1'b0)
			which_core = 0;
		else if (stdout_slave_aw_valid == 1'b1)
			which_core = (stdout_master_aw_addr[7:0] == 8'h00 ? 2'h0 : (stdout_master_aw_addr[7:0] == 8'h20 ? 2'h1 : (stdout_master_aw_addr[7:0] == 8'h40 ? 2'h2 : (stdout_master_aw_addr[7:0] == 8'h60 ? 2'h3 : 2'h0))));
	always @(*) begin
		gen_data <= {stdout_master_w_data[7:0], stdout_master_w_data[7:0], stdout_master_w_data[7:0], stdout_master_w_data[7:0]};
		gen_addr <= {16'b0000000000000000, which_core, counter[(which_core * 16) + (STDOUT_ADDR_HIGH >= 2 ? STDOUT_ADDR_HIGH : (STDOUT_ADDR_HIGH + (STDOUT_ADDR_HIGH >= 2 ? STDOUT_ADDR_HIGH - 1 : 3 - STDOUT_ADDR_HIGH)) - 1)-:(STDOUT_ADDR_HIGH >= 2 ? STDOUT_ADDR_HIGH - 1 : 3 - STDOUT_ADDR_HIGH)], 2'b00};
		gen_strb <= (counter[(which_core * 16) + 1-:2] == 2'h0 ? 4'h1 : (counter[(which_core * 16) + 1-:2] == 2'h1 ? 4'h2 : (counter[(which_core * 16) + 1-:2] == 2'h2 ? 4'h4 : (counter[(which_core * 16) + 1-:2] == 2'h3 ? 4'h8 : 4'h0))));
	end
endmodule
