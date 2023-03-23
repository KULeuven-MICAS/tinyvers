module one_stage_ack_aon_buf (sleep_signal_buf);
	output wire sleep_signal_buf;
	wire s_sleep_signal_buf;
	SC7P5T_AONBUFX8_CSC28L i_aon_buf(
		.A(s_sleep_signal_buf),
		.Z(sleep_signal_buf)
	);
endmodule
