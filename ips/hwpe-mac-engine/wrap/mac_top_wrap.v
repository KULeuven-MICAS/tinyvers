module mac_top_wrap (
	clk_i,
	rst_ni,
	test_mode_i,
	evt_o,
	tcdm_req,
	tcdm_gnt,
	tcdm_add,
	tcdm_wen,
	tcdm_be,
	tcdm_data,
	tcdm_r_data,
	tcdm_r_valid,
	periph_req,
	periph_gnt,
	periph_add,
	periph_wen,
	periph_be,
	periph_data,
	periph_id,
	periph_r_data,
	periph_r_valid,
	periph_r_id,
	scan_en_in
);
	parameter N_CORES = 2;
	parameter MP = 4;
	parameter ID = 10;
	input wire clk_i;
	input wire rst_ni;
	input wire test_mode_i;
	localparam [31:0] hwpe_ctrl_package_REGFILE_N_EVT = 2;
	output wire [(N_CORES * hwpe_ctrl_package_REGFILE_N_EVT) - 1:0] evt_o;
	output wire [MP - 1:0] tcdm_req;
	input wire [MP - 1:0] tcdm_gnt;
	output wire [(MP * 32) - 1:0] tcdm_add;
	output wire [MP - 1:0] tcdm_wen;
	output wire [(MP * 4) - 1:0] tcdm_be;
	output wire [(MP * 32) - 1:0] tcdm_data;
	input wire [(MP * 32) - 1:0] tcdm_r_data;
	input wire [MP - 1:0] tcdm_r_valid;
	input wire periph_req;
	output reg periph_gnt;
	input wire [31:0] periph_add;
	input wire periph_wen;
	input wire [3:0] periph_be;
	input wire [31:0] periph_data;
	input wire [ID - 1:0] periph_id;
	output reg [31:0] periph_r_data;
	output reg periph_r_valid;
	output reg [ID - 1:0] periph_r_id;
	input wire scan_en_in;
	hwpe_stream_intf_tcdm tcdm[MP - 1:0](.clk(clk_i));
	hwpe_ctrl_intf_periph #(.ID_WIDTH(ID)) periph(.clk(clk_i));
	genvar ii;
	generate
		for (ii = 0; ii < MP; ii = ii + 1) begin : tcdm_binding
			assign tcdm_req[ii] = tcdm[ii].req;
			assign tcdm_add[ii * 32+:32] = tcdm[ii].add;
			assign tcdm_wen[ii] = tcdm[ii].wen;
			assign tcdm_be[ii * 4+:4] = tcdm[ii].be;
			assign tcdm_data[ii * 32+:32] = tcdm[ii].data;
			assign tcdm[ii].gnt = tcdm_gnt[ii];
			assign tcdm[ii].r_data = tcdm_r_data[ii * 32+:32];
			assign tcdm[ii].r_valid = tcdm_r_valid[ii];
		end
	endgenerate
	always @(*) begin
		periph.req = periph_req;
		periph.add = periph_add;
		periph.wen = periph_wen;
		periph.be = periph_be;
		periph.data = periph_data;
		periph.id = periph_id;
		periph_gnt = periph.gnt;
		periph_r_data = periph.r_data;
		periph_r_valid = periph.r_valid;
		periph_r_id = periph.r_id;
	end
	mac_top #(
		.N_CORES(N_CORES),
		.MP(MP),
		.ID(ID)
	) i_mac_top(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.test_mode_i(test_mode_i),
		.evt_o(evt_o),
		.tcdm(tcdm),
		.periph(periph),
		.scan_en_in(scan_en_in)
	);
endmodule
