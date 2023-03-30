module apb_node (
	penable_i,
	pwrite_i,
	paddr_i,
	psel_i,
	pwdata_i,
	prdata_o,
	pready_o,
	pslverr_o,
	penable_o,
	pwrite_o,
	paddr_o,
	psel_o,
	pwdata_o,
	prdata_i,
	pready_i,
	pslverr_i,
	START_ADDR_i,
	END_ADDR_i
);
	// Trace: /home/vikramj/tinyvers/ips/apb/apb_node/src/apb_node.sv:21:19
	parameter [31:0] NB_MASTER = 8;
	// Trace: /home/vikramj/tinyvers/ips/apb/apb_node/src/apb_node.sv:22:19
	parameter [31:0] APB_DATA_WIDTH = 32;
	// Trace: /home/vikramj/tinyvers/ips/apb/apb_node/src/apb_node.sv:23:19
	parameter [31:0] APB_ADDR_WIDTH = 32;
	// Trace: /home/vikramj/tinyvers/ips/apb/apb_node/src/apb_node.sv:26:9
	input wire penable_i;
	// Trace: /home/vikramj/tinyvers/ips/apb/apb_node/src/apb_node.sv:27:9
	input wire pwrite_i;
	// Trace: /home/vikramj/tinyvers/ips/apb/apb_node/src/apb_node.sv:28:9
	input wire [APB_ADDR_WIDTH - 1:0] paddr_i;
	// Trace: /home/vikramj/tinyvers/ips/apb/apb_node/src/apb_node.sv:29:9
	input wire psel_i;
	// Trace: /home/vikramj/tinyvers/ips/apb/apb_node/src/apb_node.sv:30:9
	input wire [APB_DATA_WIDTH - 1:0] pwdata_i;
	// Trace: /home/vikramj/tinyvers/ips/apb/apb_node/src/apb_node.sv:31:9
	output reg [APB_DATA_WIDTH - 1:0] prdata_o;
	// Trace: /home/vikramj/tinyvers/ips/apb/apb_node/src/apb_node.sv:32:9
	output reg pready_o;
	// Trace: /home/vikramj/tinyvers/ips/apb/apb_node/src/apb_node.sv:33:9
	output reg pslverr_o;
	// Trace: /home/vikramj/tinyvers/ips/apb/apb_node/src/apb_node.sv:36:9
	output reg [NB_MASTER - 1:0] penable_o;
	// Trace: /home/vikramj/tinyvers/ips/apb/apb_node/src/apb_node.sv:37:9
	output reg [NB_MASTER - 1:0] pwrite_o;
	// Trace: /home/vikramj/tinyvers/ips/apb/apb_node/src/apb_node.sv:38:9
	output reg [(NB_MASTER * APB_ADDR_WIDTH) - 1:0] paddr_o;
	// Trace: /home/vikramj/tinyvers/ips/apb/apb_node/src/apb_node.sv:39:9
	output reg [NB_MASTER - 1:0] psel_o;
	// Trace: /home/vikramj/tinyvers/ips/apb/apb_node/src/apb_node.sv:40:9
	output reg [(NB_MASTER * APB_DATA_WIDTH) - 1:0] pwdata_o;
	// Trace: /home/vikramj/tinyvers/ips/apb/apb_node/src/apb_node.sv:41:9
	input wire [(NB_MASTER * APB_DATA_WIDTH) - 1:0] prdata_i;
	// Trace: /home/vikramj/tinyvers/ips/apb/apb_node/src/apb_node.sv:42:9
	input wire [NB_MASTER - 1:0] pready_i;
	// Trace: /home/vikramj/tinyvers/ips/apb/apb_node/src/apb_node.sv:43:9
	input wire [NB_MASTER - 1:0] pslverr_i;
	// Trace: /home/vikramj/tinyvers/ips/apb/apb_node/src/apb_node.sv:46:9
	input wire [(NB_MASTER * APB_ADDR_WIDTH) - 1:0] START_ADDR_i;
	// Trace: /home/vikramj/tinyvers/ips/apb/apb_node/src/apb_node.sv:47:9
	input wire [(NB_MASTER * APB_ADDR_WIDTH) - 1:0] END_ADDR_i;
	// Trace: /home/vikramj/tinyvers/ips/apb/apb_node/src/apb_node.sv:50:5
	always @(*) begin : match_address
		// Trace: /home/vikramj/tinyvers/ips/apb/apb_node/src/apb_node.sv:51:9
		psel_o = 1'sb0;
		// Trace: /home/vikramj/tinyvers/ips/apb/apb_node/src/apb_node.sv:54:9
		begin : sv2v_autoblock_1
			// Trace: /home/vikramj/tinyvers/ips/apb/apb_node/src/apb_node.sv:54:14
			reg [31:0] i;
			// Trace: /home/vikramj/tinyvers/ips/apb/apb_node/src/apb_node.sv:54:14
			for (i = 0; i < NB_MASTER; i = i + 1)
				begin
					// Trace: /home/vikramj/tinyvers/ips/apb/apb_node/src/apb_node.sv:55:13
					psel_o[i] = (psel_i & (paddr_i >= START_ADDR_i[i * APB_ADDR_WIDTH+:APB_ADDR_WIDTH])) && (paddr_i <= END_ADDR_i[i * APB_ADDR_WIDTH+:APB_ADDR_WIDTH]);
				end
		end
	end
	// Trace: /home/vikramj/tinyvers/ips/apb/apb_node/src/apb_node.sv:58:5
	always @(*) begin
		// Trace: /home/vikramj/tinyvers/ips/apb/apb_node/src/apb_node.sv:60:9
		penable_o = 1'sb0;
		// Trace: /home/vikramj/tinyvers/ips/apb/apb_node/src/apb_node.sv:61:9
		pwrite_o = 1'sb0;
		// Trace: /home/vikramj/tinyvers/ips/apb/apb_node/src/apb_node.sv:62:9
		paddr_o = 1'sb0;
		// Trace: /home/vikramj/tinyvers/ips/apb/apb_node/src/apb_node.sv:63:9
		pwdata_o = 1'sb0;
		// Trace: /home/vikramj/tinyvers/ips/apb/apb_node/src/apb_node.sv:64:9
		prdata_o = 1'sb0;
		// Trace: /home/vikramj/tinyvers/ips/apb/apb_node/src/apb_node.sv:65:9
		pready_o = 1'b0;
		// Trace: /home/vikramj/tinyvers/ips/apb/apb_node/src/apb_node.sv:66:9
		pslverr_o = 1'b0;
		// Trace: /home/vikramj/tinyvers/ips/apb/apb_node/src/apb_node.sv:68:9
		begin : sv2v_autoblock_2
			// Trace: /home/vikramj/tinyvers/ips/apb/apb_node/src/apb_node.sv:68:14
			reg [31:0] i;
			// Trace: /home/vikramj/tinyvers/ips/apb/apb_node/src/apb_node.sv:68:14
			for (i = 0; i < NB_MASTER; i = i + 1)
				begin
					// Trace: /home/vikramj/tinyvers/ips/apb/apb_node/src/apb_node.sv:70:13
					if (psel_o[i]) begin
						// Trace: /home/vikramj/tinyvers/ips/apb/apb_node/src/apb_node.sv:72:17
						penable_o[i] = penable_i;
						// Trace: /home/vikramj/tinyvers/ips/apb/apb_node/src/apb_node.sv:73:17
						pwrite_o[i] = pwrite_i;
						// Trace: /home/vikramj/tinyvers/ips/apb/apb_node/src/apb_node.sv:74:17
						paddr_o[i * APB_ADDR_WIDTH+:APB_ADDR_WIDTH] = paddr_i;
						// Trace: /home/vikramj/tinyvers/ips/apb/apb_node/src/apb_node.sv:75:17
						pwdata_o[i * APB_DATA_WIDTH+:APB_DATA_WIDTH] = pwdata_i;
						// Trace: /home/vikramj/tinyvers/ips/apb/apb_node/src/apb_node.sv:77:17
						prdata_o = prdata_i[i * APB_DATA_WIDTH+:APB_DATA_WIDTH];
						// Trace: /home/vikramj/tinyvers/ips/apb/apb_node/src/apb_node.sv:78:17
						pready_o = pready_i[i];
						// Trace: /home/vikramj/tinyvers/ips/apb/apb_node/src/apb_node.sv:79:17
						pslverr_o = pslverr_i[i];
					end
				end
		end
	end
endmodule
