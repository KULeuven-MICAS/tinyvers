module uart_tb_rx (
	rx,
	rx_en,
	word_done
);
	parameter BAUD_RATE = 115200;
	parameter PARITY_EN = 0;
	input wire rx;
	input wire rx_en;
	output reg word_done;
	localparam NS_UNIT_SCALER = 1000000000;
	real BIT_PERIOD = NS_UNIT_SCALER / BAUD_RATE;
	reg [7:0] character;
	reg [2047:0] stringa;
	reg parity;
	integer charnum;
	integer file;
	initial file = $fopen("stdout/uart", "w");
	always if (rx_en) begin
		@(negedge rx)
			;
		#(BIT_PERIOD / 2)
			;
		begin : sv2v_autoblock_1
			reg signed [31:0] i;
			for (i = 0; i <= 7; i = i + 1)
				#(BIT_PERIOD) character[i] = rx;
		end
		if (PARITY_EN == 1) begin
			#(BIT_PERIOD) parity = rx;
			begin : sv2v_autoblock_2
				reg signed [31:0] i;
				for (i = 7; i >= 0; i = i - 1)
					parity = character[i] ^ parity;
			end
			if (parity == 1'b1)
				$display("Parity error detected");
		end
		#(BIT_PERIOD)
			;
		$fwrite(file, "%c", character);
		stringa[(255 - charnum) * 8+:8] = character;
		if ((character == 8'h0a) || (charnum == 254)) begin
			if (character == 8'h0a)
				stringa[(255 - charnum) * 8+:8] = 8'h00;
			else
				stringa[((255 - charnum) - 1) * 8+:8] = 8'h00;
			$write("RX string: %s\n", stringa);
			charnum = 0;
			stringa = "";
			word_done = 1;
			#(100) word_done = 0;
		end
		else
			charnum = charnum + 1;
	end
	else begin
		charnum = 0;
		stringa = "";
		word_done = 0;
		#(10)
			;
	end
endmodule
