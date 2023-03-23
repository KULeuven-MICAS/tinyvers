module dm_csrs (
	clk_i,
	rst_ni,
	testmode_i,
	dmi_rst_ni,
	dmi_req_valid_i,
	dmi_req_ready_o,
	dmi_req_i,
	dmi_resp_valid_o,
	dmi_resp_ready_i,
	dmi_resp_o,
	ndmreset_o,
	dmactive_o,
	hartinfo_i,
	halted_i,
	unavailable_i,
	resumeack_i,
	hartsel_o,
	haltreq_o,
	resumereq_o,
	clear_resumeack_o,
	cmd_valid_o,
	cmd_o,
	cmderror_valid_i,
	cmderror_i,
	cmdbusy_i,
	progbuf_o,
	data_o,
	data_i,
	data_valid_i,
	sbaddress_o,
	sbaddress_i,
	sbaddress_write_valid_o,
	sbreadonaddr_o,
	sbautoincrement_o,
	sbaccess_o,
	sbreadondata_o,
	sbdata_o,
	sbdata_read_valid_o,
	sbdata_write_valid_o,
	sbdata_i,
	sbdata_valid_i,
	sbbusy_i,
	sberror_valid_i,
	sberror_i
);
	parameter signed [31:0] NrHarts = 1;
	parameter signed [31:0] BusWidth = 32;
	parameter [NrHarts - 1:0] SelectableHarts = 1;
	input wire clk_i;
	input wire rst_ni;
	input wire testmode_i;
	input wire dmi_rst_ni;
	input wire dmi_req_valid_i;
	output wire dmi_req_ready_o;
	input wire [40:0] dmi_req_i;
	output wire dmi_resp_valid_o;
	input wire dmi_resp_ready_i;
	output wire [33:0] dmi_resp_o;
	output wire ndmreset_o;
	output wire dmactive_o;
	input wire [(NrHarts * 32) - 1:0] hartinfo_i;
	input wire [NrHarts - 1:0] halted_i;
	input wire [NrHarts - 1:0] unavailable_i;
	input wire [NrHarts - 1:0] resumeack_i;
	output wire [19:0] hartsel_o;
	output reg [NrHarts - 1:0] haltreq_o;
	output reg [NrHarts - 1:0] resumereq_o;
	output reg clear_resumeack_o;
	output wire cmd_valid_o;
	output wire [31:0] cmd_o;
	input wire cmderror_valid_i;
	input wire [2:0] cmderror_i;
	input wire cmdbusy_i;
	localparam [4:0] dm_ProgBufSize = 5'h08;
	output wire [255:0] progbuf_o;
	localparam [3:0] dm_DataCount = 4'h2;
	output wire [63:0] data_o;
	input wire [63:0] data_i;
	input wire data_valid_i;
	output wire [BusWidth - 1:0] sbaddress_o;
	input wire [BusWidth - 1:0] sbaddress_i;
	output reg sbaddress_write_valid_o;
	output wire sbreadonaddr_o;
	output wire sbautoincrement_o;
	output wire [2:0] sbaccess_o;
	output wire sbreadondata_o;
	output wire [BusWidth - 1:0] sbdata_o;
	output reg sbdata_read_valid_o;
	output reg sbdata_write_valid_o;
	input wire [BusWidth - 1:0] sbdata_i;
	input wire sbdata_valid_i;
	input wire sbbusy_i;
	input wire sberror_valid_i;
	input wire [2:0] sberror_i;
	localparam HartSelLen = (NrHarts == 1 ? 1 : $clog2(NrHarts));
	wire [1:0] dtm_op;
	function automatic [1:0] sv2v_cast_2;
		input reg [1:0] inp;
		sv2v_cast_2 = inp;
	endfunction
	assign dtm_op = sv2v_cast_2(dmi_req_i[33-:2]);
	wire resp_queue_full;
	wire resp_queue_empty;
	wire resp_queue_push;
	wire resp_queue_pop;
	reg [31:0] resp_queue_data;
	function automatic [7:0] sv2v_cast_8;
		input reg [7:0] inp;
		sv2v_cast_8 = inp;
	endfunction
	localparam [7:0] DataEnd = sv2v_cast_8(8'h04 + {4'b0000, dm_DataCount});
	localparam [7:0] ProgBufEnd = sv2v_cast_8(8'h20 + {4'b0000, dm_ProgBufSize});
	reg [31:0] haltsum0;
	reg [31:0] haltsum1;
	reg [31:0] haltsum2;
	reg [31:0] haltsum3;
	reg [((((NrHarts - 1) / 32) + 1) * 32) - 1:0] halted;
	reg [(((NrHarts - 1) / 32) >= 0 ? ((((NrHarts - 1) / 32) + 1) * 32) - 1 : ((1 - ((NrHarts - 1) / 32)) * 32) + ((((NrHarts - 1) / 32) * 32) - 1)):(((NrHarts - 1) / 32) >= 0 ? 0 : ((NrHarts - 1) / 32) * 32)] halted_reshaped0;
	reg [((NrHarts / 1024) >= 0 ? (((NrHarts / 1024) + 1) * 32) - 1 : ((1 - (NrHarts / 1024)) * 32) + (((NrHarts / 1024) * 32) - 1)):((NrHarts / 1024) >= 0 ? 0 : (NrHarts / 1024) * 32)] halted_reshaped1;
	reg [((NrHarts / 32768) >= 0 ? (((NrHarts / 32768) + 1) * 32) - 1 : ((1 - (NrHarts / 32768)) * 32) + (((NrHarts / 32768) * 32) - 1)):((NrHarts / 32768) >= 0 ? 0 : (NrHarts / 32768) * 32)] halted_reshaped2;
	reg [(((NrHarts / 1024) + 1) * 32) - 1:0] halted_flat1;
	reg [(((NrHarts / 32768) + 1) * 32) - 1:0] halted_flat2;
	reg [31:0] halted_flat3;
	always @(*) begin
		halted = 1'sb0;
		halted[NrHarts - 1:0] = halted_i;
		halted_reshaped0 = halted;
		haltsum0 = halted_reshaped0[(((NrHarts - 1) / 32) >= 0 ? hartsel_o[19:5] : ((NrHarts - 1) / 32) - hartsel_o[19:5]) * 32+:32];
	end
	always @(*) begin : p_reduction1
		halted_flat1 = 1'sb0;
		begin : sv2v_autoblock_1
			reg signed [31:0] k;
			for (k = 0; k < (((NrHarts - 1) / 32) + 1); k = k + 1)
				halted_flat1[k] = |halted_reshaped0[(((NrHarts - 1) / 32) >= 0 ? k : ((NrHarts - 1) / 32) - k) * 32+:32];
		end
		halted_reshaped1 = halted_flat1;
		haltsum1 = halted_reshaped1[((NrHarts / 1024) >= 0 ? hartsel_o[19:10] : (NrHarts / 1024) - hartsel_o[19:10]) * 32+:32];
	end
	always @(*) begin : p_reduction2
		halted_flat2 = 1'sb0;
		begin : sv2v_autoblock_2
			reg signed [31:0] k;
			for (k = 0; k < ((NrHarts / 1024) + 1); k = k + 1)
				halted_flat2[k] = |halted_reshaped1[((NrHarts / 1024) >= 0 ? k : (NrHarts / 1024) - k) * 32+:32];
		end
		halted_reshaped2 = halted_flat2;
		haltsum2 = halted_reshaped2[((NrHarts / 32768) >= 0 ? hartsel_o[19:15] : (NrHarts / 32768) - hartsel_o[19:15]) * 32+:32];
	end
	always @(*) begin : p_reduction3
		halted_flat3 = 1'sb0;
		begin : sv2v_autoblock_3
			reg signed [31:0] k;
			for (k = 0; k < ((NrHarts / 32768) + 1); k = k + 1)
				halted_flat3[k] = |halted_reshaped2[((NrHarts / 32768) >= 0 ? k : (NrHarts / 32768) - k) * 32+:32];
		end
		haltsum3 = halted_flat3;
	end
	reg [31:0] dmstatus;
	reg [31:0] dmcontrol_d;
	reg [31:0] dmcontrol_q;
	reg [31:0] abstractcs;
	reg [2:0] cmderr_d;
	reg [2:0] cmderr_q;
	reg [31:0] command_d;
	reg [31:0] command_q;
	reg cmd_valid_d;
	reg cmd_valid_q;
	reg [31:0] abstractauto_d;
	reg [31:0] abstractauto_q;
	reg [31:0] sbcs_d;
	reg [31:0] sbcs_q;
	reg [63:0] sbaddr_d;
	reg [63:0] sbaddr_q;
	reg [63:0] sbdata_d;
	reg [63:0] sbdata_q;
	reg [NrHarts - 1:0] havereset_d;
	reg [NrHarts - 1:0] havereset_q;
	reg [255:0] progbuf_d;
	reg [255:0] progbuf_q;
	reg [(({3'b000, dm_DataCount} + 0) * 32) + 127:128] data_d;
	reg [(({3'b000, dm_DataCount} + 0) * 32) + 127:128] data_q;
	reg [HartSelLen - 1:0] selected_hart;
	localparam [1:0] dm_DTM_SUCCESS = 2'h0;
	assign dmi_resp_o[1-:2] = dm_DTM_SUCCESS;
	assign dmi_resp_valid_o = ~resp_queue_empty;
	assign dmi_req_ready_o = ~resp_queue_full;
	assign resp_queue_push = dmi_req_valid_i & dmi_req_ready_o;
	assign sbautoincrement_o = sbcs_q[16];
	assign sbreadonaddr_o = sbcs_q[20];
	assign sbreadondata_o = sbcs_q[15];
	assign sbaccess_o = sbcs_q[19-:3];
	assign sbdata_o = sbdata_q[BusWidth - 1:0];
	assign sbaddress_o = sbaddr_q[BusWidth - 1:0];
	assign hartsel_o = {dmcontrol_q[15-:10], dmcontrol_q[25-:10]};
	localparam [3:0] dm_DbgVersion013 = 4'h2;
	function automatic [31:0] sv2v_cast_32;
		input reg [31:0] inp;
		sv2v_cast_32 = inp;
	endfunction
	function automatic [2:0] sv2v_cast_3;
		input reg [2:0] inp;
		sv2v_cast_3 = inp;
	endfunction
	function automatic [11:0] sv2v_cast_12;
		input reg [11:0] inp;
		sv2v_cast_12 = inp;
	endfunction
	function automatic [15:0] sv2v_cast_16;
		input reg [15:0] inp;
		sv2v_cast_16 = inp;
	endfunction
	function automatic [63:0] sv2v_cast_64;
		input reg [63:0] inp;
		sv2v_cast_64 = inp;
	endfunction
	always @(*) begin : csr_read_write
		dmstatus = 1'sb0;
		dmstatus[3-:4] = dm_DbgVersion013;
		dmstatus[7] = 1'b1;
		dmstatus[5] = 1'b0;
		dmstatus[19] = havereset_q[selected_hart];
		dmstatus[18] = havereset_q[selected_hart];
		dmstatus[17] = resumeack_i[selected_hart];
		dmstatus[16] = resumeack_i[selected_hart];
		dmstatus[13] = unavailable_i[selected_hart];
		dmstatus[12] = unavailable_i[selected_hart];
		dmstatus[15] = (hartsel_o > (NrHarts - 1) ? 1'b1 : 1'b0);
		dmstatus[14] = (hartsel_o > (NrHarts - 1) ? 1'b1 : 1'b0);
		dmstatus[9] = halted_i[selected_hart] & ~unavailable_i[selected_hart];
		dmstatus[8] = halted_i[selected_hart] & ~unavailable_i[selected_hart];
		dmstatus[11] = ~halted_i[selected_hart] & ~unavailable_i[selected_hart];
		dmstatus[10] = ~halted_i[selected_hart] & ~unavailable_i[selected_hart];
		abstractcs = 1'sb0;
		abstractcs[3-:4] = dm_DataCount;
		abstractcs[28-:5] = dm_ProgBufSize;
		abstractcs[12] = cmdbusy_i;
		abstractcs[10-:3] = cmderr_q;
		abstractauto_d = abstractauto_q;
		abstractauto_d[15-:4] = 1'sb0;
		havereset_d = havereset_q;
		dmcontrol_d = dmcontrol_q;
		cmderr_d = cmderr_q;
		command_d = command_q;
		progbuf_d = progbuf_q;
		data_d = data_q;
		sbcs_d = sbcs_q;
		sbaddr_d = sbaddress_i;
		sbdata_d = sbdata_q;
		resp_queue_data = 32'b00000000000000000000000000000000;
		cmd_valid_d = 1'b0;
		sbaddress_write_valid_o = 1'b0;
		sbdata_read_valid_o = 1'b0;
		sbdata_write_valid_o = 1'b0;
		clear_resumeack_o = 1'b0;
		if ((dmi_req_ready_o && dmi_req_valid_i) && (dtm_op == 2'h1))
			if ((8'h04 <= {1'b0, dmi_req_i[40-:7]}) && (DataEnd >= {1'b0, dmi_req_i[40-:7]})) begin
				resp_queue_data = data_q[dmi_req_i[38:34] * 32+:32];
				if (!cmdbusy_i)
					cmd_valid_d = abstractauto_q[dmi_req_i[37:34] - 32'sh00000004];
			end
			else if ({1'b0, dmi_req_i[40-:7]} == 8'h10)
				resp_queue_data = dmcontrol_q;
			else if ({1'b0, dmi_req_i[40-:7]} == 8'h11)
				resp_queue_data = dmstatus;
			else if ({1'b0, dmi_req_i[40-:7]} == 8'h12)
				resp_queue_data = hartinfo_i[selected_hart * 32+:32];
			else if ({1'b0, dmi_req_i[40-:7]} == 8'h16)
				resp_queue_data = abstractcs;
			else if ({1'b0, dmi_req_i[40-:7]} == 8'h18)
				resp_queue_data = abstractauto_q;
			else if ({1'b0, dmi_req_i[40-:7]} == 8'h17)
				resp_queue_data = 1'sb0;
			else if ((8'h20 <= {1'b0, dmi_req_i[40-:7]}) && (ProgBufEnd >= {1'b0, dmi_req_i[40-:7]})) begin
				resp_queue_data = progbuf_q[dmi_req_i[38:34] * 32+:32];
				if (!cmdbusy_i)
					cmd_valid_d = abstractauto_q[0 + (dmi_req_i[37:34] + 16)];
			end
			else if ({1'b0, dmi_req_i[40-:7]} == 8'h40)
				resp_queue_data = haltsum0;
			else if ({1'b0, dmi_req_i[40-:7]} == 8'h13)
				resp_queue_data = haltsum1;
			else if ({1'b0, dmi_req_i[40-:7]} == 8'h34)
				resp_queue_data = haltsum2;
			else if ({1'b0, dmi_req_i[40-:7]} == 8'h35)
				resp_queue_data = haltsum3;
			else if ({1'b0, dmi_req_i[40-:7]} == 8'h38)
				resp_queue_data = sbcs_q;
			else if ({1'b0, dmi_req_i[40-:7]} == 8'h39) begin
				if (sbbusy_i)
					sbcs_d[22] = 1'b1;
				else
					resp_queue_data = sbaddr_q[31:0];
			end
			else if ({1'b0, dmi_req_i[40-:7]} == 8'h3a) begin
				if (sbbusy_i)
					sbcs_d[22] = 1'b1;
				else
					resp_queue_data = sbaddr_q[63:32];
			end
			else if ({1'b0, dmi_req_i[40-:7]} == 8'h3c) begin
				if (sbbusy_i)
					sbcs_d[22] = 1'b1;
				else begin
					sbdata_read_valid_o = sbcs_q[14-:3] == {3 {1'sb0}};
					resp_queue_data = sbdata_q[31:0];
				end
			end
			else if ({1'b0, dmi_req_i[40-:7]} == 8'h3d)
				if (sbbusy_i)
					sbcs_d[22] = 1'b1;
				else
					resp_queue_data = sbdata_q[63:32];
		if ((dmi_req_ready_o && dmi_req_valid_i) && (dtm_op == 2'h2)) begin : sv2v_autoblock_4
			reg [7:0] sv2v_temp_41277;
			sv2v_temp_41277 = sv2v_cast_8({1'b0, dmi_req_i[40-:7]});
			if ((8'h04 <= sv2v_temp_41277) && (DataEnd >= sv2v_temp_41277)) begin
				if (!cmdbusy_i && 1'd1) begin
					data_d[dmi_req_i[38:34] * 32+:32] = dmi_req_i[31-:32];
					cmd_valid_d = abstractauto_q[dmi_req_i[37:34] - 32'sh00000004];
				end
			end
			else if (sv2v_temp_41277 == 8'h10) begin : sv2v_autoblock_5
				reg [31:0] dmcontrol;
				dmcontrol = sv2v_cast_32(dmi_req_i[31-:32]);
				if (dmcontrol[28])
					havereset_d[selected_hart] = 1'b0;
				dmcontrol_d = dmi_req_i[31-:32];
			end
			else if (sv2v_temp_41277 == 8'h11)
				;
			else if (sv2v_temp_41277 == 8'h12)
				;
			else if (sv2v_temp_41277 == 8'h16) begin : sv2v_autoblock_6
				reg [31:0] a_abstractcs;
				a_abstractcs = sv2v_cast_32(dmi_req_i[31-:32]);
				if (!cmdbusy_i)
					cmderr_d = sv2v_cast_3(~a_abstractcs[10-:3] & cmderr_q);
				else if (cmderr_q == 3'd0)
					cmderr_d = 3'd1;
			end
			else if (sv2v_temp_41277 == 8'h17) begin
				if (!cmdbusy_i) begin
					cmd_valid_d = 1'b1;
					command_d = sv2v_cast_32(dmi_req_i[31-:32]);
				end
				else if (cmderr_q == 3'd0)
					cmderr_d = 3'd1;
			end
			else if (sv2v_temp_41277 == 8'h18) begin
				if (!cmdbusy_i) begin
					abstractauto_d = 32'b00000000000000000000000000000000;
					abstractauto_d[11-:12] = sv2v_cast_12(dmi_req_i[1:0]);
					abstractauto_d[31-:16] = sv2v_cast_16(dmi_req_i[23:16]);
				end
				else if (cmderr_q == 3'd0)
					cmderr_d = 3'd1;
			end
			else if ((8'h20 <= sv2v_temp_41277) && (ProgBufEnd >= sv2v_temp_41277)) begin
				if (!cmdbusy_i) begin
					progbuf_d[dmi_req_i[38:34] * 32+:32] = dmi_req_i[31-:32];
					cmd_valid_d = abstractauto_q[0 + (dmi_req_i[37:34] + 16)];
				end
			end
			else if (sv2v_temp_41277 == 8'h38) begin
				if (sbbusy_i)
					sbcs_d[22] = 1'b1;
				else begin : sv2v_autoblock_7
					reg [31:0] sbcs;
					sbcs = sv2v_cast_32(dmi_req_i[31-:32]);
					sbcs_d = sbcs;
					sbcs_d[22] = sbcs_q[22] & ~sbcs[22];
					sbcs_d[14-:3] = sbcs_q[14-:3] & ~sbcs[14-:3];
				end
			end
			else if (sv2v_temp_41277 == 8'h39) begin
				if (sbbusy_i)
					sbcs_d[22] = 1'b1;
				else begin
					sbaddr_d[31:0] = dmi_req_i[31-:32];
					sbaddress_write_valid_o = sbcs_q[14-:3] == {3 {1'sb0}};
				end
			end
			else if (sv2v_temp_41277 == 8'h3a) begin
				if (sbbusy_i)
					sbcs_d[22] = 1'b1;
				else
					sbaddr_d[63:32] = dmi_req_i[31-:32];
			end
			else if (sv2v_temp_41277 == 8'h3c) begin
				if (sbbusy_i)
					sbcs_d[22] = 1'b1;
				else begin
					sbdata_d[31:0] = dmi_req_i[31-:32];
					sbdata_write_valid_o = sbcs_q[14-:3] == {3 {1'sb0}};
				end
			end
			else if (sv2v_temp_41277 == 8'h3d)
				if (sbbusy_i)
					sbcs_d[22] = 1'b1;
				else
					sbdata_d[63:32] = dmi_req_i[31-:32];
		end
		if (cmderror_valid_i)
			cmderr_d = cmderror_i;
		if (data_valid_i)
			data_d = data_i;
		if (ndmreset_o)
			havereset_d = 1'sb1;
		if (sberror_valid_i)
			sbcs_d[14-:3] = sberror_i;
		if (sbdata_valid_i)
			sbdata_d = sv2v_cast_64(sbdata_i);
		dmcontrol_d[26] = 1'b0;
		dmcontrol_d[29] = 1'b0;
		dmcontrol_d[3] = 1'b0;
		dmcontrol_d[2] = 1'b0;
		dmcontrol_d[27] = 1'sb0;
		dmcontrol_d[5-:2] = 1'sb0;
		dmcontrol_d[28] = 1'b0;
		if (!dmcontrol_q[30] && dmcontrol_d[30])
			clear_resumeack_o = 1'b1;
		if (dmcontrol_q[30] && resumeack_i)
			dmcontrol_d[30] = 1'b0;
		sbcs_d[31-:3] = 3'b001;
		sbcs_d[21] = sbbusy_i;
		sbcs_d[11-:7] = BusWidth;
		sbcs_d[4] = 1'b0;
		sbcs_d[3] = BusWidth == 64;
		sbcs_d[2] = BusWidth == 32;
		sbcs_d[1] = 1'b0;
		sbcs_d[0] = 1'b0;
		sbcs_d[19-:3] = (BusWidth == 64 ? 2'd3 : 2'd2);
	end
	always @(*) begin
		selected_hart = hartsel_o[HartSelLen - 1:0];
		haltreq_o = 1'sb0;
		resumereq_o = 1'sb0;
		haltreq_o[selected_hart] = dmcontrol_q[31];
		resumereq_o[selected_hart] = dmcontrol_q[30];
	end
	assign dmactive_o = dmcontrol_q[0];
	assign cmd_o = command_q;
	assign cmd_valid_o = cmd_valid_q;
	assign progbuf_o = progbuf_q;
	assign data_o = data_q;
	assign resp_queue_pop = dmi_resp_ready_i & ~resp_queue_empty;
	assign ndmreset_o = dmcontrol_q[1];
	fifo_v2_020E9 #(.DEPTH(2)) i_fifo(
		.clk_i(clk_i),
		.rst_ni(dmi_rst_ni),
		.flush_i(1'b0),
		.testmode_i(testmode_i),
		.full_o(resp_queue_full),
		.empty_o(resp_queue_empty),
		.alm_full_o(),
		.alm_empty_o(),
		.data_i(resp_queue_data),
		.push_i(resp_queue_push),
		.data_o(dmi_resp_o[33-:32]),
		.pop_i(resp_queue_pop)
	);
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni) begin
			dmcontrol_q <= 1'sb0;
			cmderr_q <= 3'd0;
			command_q <= 1'sb0;
			abstractauto_q <= 1'sb0;
			progbuf_q <= 1'sb0;
			data_q <= 1'sb0;
			sbcs_q <= 1'sb0;
			sbaddr_q <= 1'sb0;
			sbdata_q <= 1'sb0;
		end
		else if (!dmcontrol_q[0]) begin
			dmcontrol_q[31] <= 1'sb0;
			dmcontrol_q[30] <= 1'sb0;
			dmcontrol_q[29] <= 1'sb0;
			dmcontrol_q[27] <= 1'sb0;
			dmcontrol_q[26] <= 1'sb0;
			dmcontrol_q[25-:10] <= 1'sb0;
			dmcontrol_q[15-:10] <= 1'sb0;
			dmcontrol_q[5-:2] <= 1'sb0;
			dmcontrol_q[3] <= 1'sb0;
			dmcontrol_q[2] <= 1'sb0;
			dmcontrol_q[1] <= 1'sb0;
			dmcontrol_q[0] <= dmcontrol_d[0];
			cmderr_q <= 3'd0;
			command_q <= 1'sb0;
			cmd_valid_q <= 1'sb0;
			abstractauto_q <= 1'sb0;
			progbuf_q <= 1'sb0;
			data_q <= 1'sb0;
			sbcs_q <= 1'sb0;
			sbaddr_q <= 1'sb0;
			sbdata_q <= 1'sb0;
		end
		else begin
			dmcontrol_q <= dmcontrol_d;
			cmderr_q <= cmderr_d;
			command_q <= command_d;
			cmd_valid_q <= cmd_valid_d;
			abstractauto_q <= abstractauto_d;
			progbuf_q <= progbuf_d;
			data_q <= data_d;
			sbcs_q <= sbcs_d;
			sbaddr_q <= sbaddr_d;
			sbdata_q <= sbdata_d;
		end
	genvar k;
	generate
		for (k = 0; k < NrHarts; k = k + 1) begin : gen_havereset
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					havereset_q[k] <= 1'b1;
				else
					havereset_q[k] <= (SelectableHarts[k] ? havereset_d[k] : 1'b0);
		end
	endgenerate
endmodule
