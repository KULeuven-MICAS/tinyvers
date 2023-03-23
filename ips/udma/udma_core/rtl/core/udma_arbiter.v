module udma_arbiter (
	clk_i,
	rstn_i,
	req_i,
	grant_o,
	grant_ack_i,
	anyGrant_o
);
	parameter N = 8;
	parameter S = 3;
	input wire clk_i;
	input wire rstn_i;
	input wire [N - 1:0] req_i;
	output wire [N - 1:0] grant_o;
	input wire grant_ack_i;
	output wire anyGrant_o;
	reg [N - 1:0] r_priority;
	reg [N - 1:0] g [S:0];
	reg [N - 1:0] p [S - 1:0];
	wire anyGnt;
	wire [N - 1:0] gnt;
	assign anyGrant_o = anyGnt;
	assign grant_o = gnt;
	integer i;
	integer j;
	always @(*) begin
		p[0] = {~req_i[N - 2:0], ~req_i[N - 1]};
		g[0] = r_priority;
		for (i = 1; i < S; i = i + 1)
			for (j = 0; j < N; j = j + 1)
				if ((j - (2 ** (i - 1))) < 0) begin
					g[i][j] = g[i - 1][j] | (p[i - 1][j] & g[i - 1][(N + j) - (2 ** (i - 1))]);
					p[i][j] = p[i - 1][j] & p[i - 1][(N + j) - (2 ** (i - 1))];
				end
				else begin
					g[i][j] = g[i - 1][j] | (p[i - 1][j] & g[i - 1][j - (2 ** (i - 1))]);
					p[i][j] = p[i - 1][j] & p[i - 1][j - (2 ** (i - 1))];
				end
		for (j = 0; j < N; j = j + 1)
			if ((j - (2 ** (S - 1))) < 0)
				g[S][j] = g[S - 1][j] | (p[S - 1][j] & g[S - 1][(N + j) - (2 ** (S - 1))]);
			else
				g[S][j] = g[S - 1][j] | (p[S - 1][j] & g[S - 1][j - (2 ** (S - 1))]);
	end
	assign anyGnt = ~(p[S - 1][N - 1] & p[S - 1][(N / 2) - 1]);
	assign gnt = req_i & g[S];
	always @(posedge clk_i or negedge rstn_i)
		if (rstn_i == 1'b0)
			r_priority <= 1;
		else if (anyGnt && grant_ack_i) begin
			r_priority[N - 1:1] <= gnt[N - 2:0];
			r_priority[0] <= gnt[N - 1];
		end
endmodule
