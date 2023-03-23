module power_gating_shift (
	sleep_send_LOGIC,
	sleep_send_L2,
	sleep_send_L2_UDMA,
	sleep_send_L1,
	sleep_send_UDMA,
	sleep_ack_LOGIC,
	sleep_ack_L2,
	sleep_ack_L2_UDMA,
	sleep_ack_L1,
	sleep_ack_UDMA
);
	input wire sleep_send_LOGIC;
	input wire sleep_send_L2;
	input wire sleep_send_L2_UDMA;
	input wire sleep_send_L1;
	input wire sleep_send_UDMA;
	output wire sleep_ack_LOGIC;
	output wire sleep_ack_L2;
	output wire sleep_ack_L2_UDMA;
	output wire sleep_ack_L1;
	output wire sleep_ack_UDMA;
	wire s_sleep_send_LOGIC;
	wire s_sleep_send_L2;
	wire s_sleep_send_L2_UDMA;
	wire s_sleep_send_L1;
	wire s_sleep_send_UDMA;
	wire s_sleep_ack_LOGIC;
	wire s_sleep_ack_L2;
	wire s_sleep_ack_L2_UDMA;
	wire s_sleep_ack_L1;
	wire s_sleep_ack_UDMA;
	SC7P5T_BUFX4_CSC28L send_logic_buf(
		.A(sleep_send_LOGIC),
		.Z(s_sleep_send_LOGIC)
	);
	SC7P5T_BUFX4_CSC28L send_l2_buf(
		.A(sleep_send_L2),
		.Z(s_sleep_send_L2)
	);
	SC7P5T_BUFX4_CSC28L send_l2_udma_buf(
		.A(sleep_send_L2_UDMA),
		.Z(s_sleep_send_L2_UDMA)
	);
	SC7P5T_BUFX4_CSC28L send_l1_buf(
		.A(sleep_send_L1),
		.Z(s_sleep_send_L1)
	);
	SC7P5T_BUFX4_CSC28L send_udma_buf(
		.A(sleep_send_UDMA),
		.Z(s_sleep_send_UDMA)
	);
	SC7P5T_BUFX4_CSC28L ack_logic_buf(
		.A(s_sleep_ack_LOGIC),
		.Z(sleep_ack_LOGIC)
	);
	SC7P5T_BUFX4_CSC28L ack_l2_buf(
		.A(s_sleep_ack_L2),
		.Z(sleep_ack_L2)
	);
	SC7P5T_BUFX4_CSC28L ack_l2_udma_buf(
		.A(s_sleep_ack_L2_UDMA),
		.Z(sleep_ack_L2_UDMA)
	);
	SC7P5T_BUFX4_CSC28L ack_l1_buf(
		.A(s_sleep_ack_L1),
		.Z(sleep_ack_L1)
	);
	SC7P5T_BUFX4_CSC28L ack_udma_buf(
		.A(s_sleep_ack_UDMA),
		.Z(sleep_ack_UDMA)
	);
	dummy_decap i_dummy_decap_shift();
endmodule
