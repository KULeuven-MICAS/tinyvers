module one_stage_send_aon_buf (sleep_signal_buf);
	input wire sleep_signal_buf;
	wire s_sleep_signal_buf;
	SC7P5T_AONBUFX8_CSC28L i_aon_buf(
		.A(sleep_signal_buf),
		.Z(s_sleep_signal_buf)
	);
endmodule
