//-------------------------------------------------------------
// Design:        M88_top
// Description:   8-bit signed array multiplier
// Working mode:  8/4/2-bit
// 8b mode: p      (16bit) = a * w
// 4b mode: p[12:4] (9bit) = a[7:4]*w[3:0] + a[3:0]*w[7:4]
// 2b mode: p[11:6] (6bit) = a[7:6]*w[1:0] + a[5:4]*w[3:2] + a[3:2]*w[5:4] + a[1:0]*w[7:6]
// Author:	      Linyan Mei
//-------------------------------------------------------------


module M88_top (a, w, p, mode_8b, mode_4b, mode_2b);

	//-------------Inputs----------------------------------	
	//----Data in--------
	input    [7:0] a;      //Activation (Signed)
	input    [7:0] w;      //Weight     (Signed)    
	//----Control in-----
	input          mode_8b;
	input          mode_4b;
	input          mode_2b;

	//-------------Outputs---------------------------------
	output  [15:0] p;     //Product

	//-------------Internal signals------------------------
	logic          sout81, sout82, sout83, sout84, sout85, sout86, sout87;           // Sum out   (@ row & colum)
	logic          cout81, cout82, cout83, cout84, cout85, cout86, cout87, cout88;   // Carry out (@ row & colum)

	logic          sin21, sin31, sin41, sin51, sin61, sin71, sin81;                  // Sum in   (@ row & colum)

	//-------------Datapath--------------------------------

	always_comb begin
		unique case (1'b1)
			mode_8b: begin		
				sin21 = 1'b1;
				sin31 = 1'b0;
				sin41 = 1'b0;
				sin51 = 1'b0;
				sin61 = 1'b0;
				sin71 = 1'b0;
				sin81 = 1'b0;
				end

			mode_4b: begin
				sin21 = 1'b0;
				sin31 = 1'b1;
				sin41 = 1'b0;
				sin51 = 1'b0;
				sin61 = 1'b1;
				sin71 = 1'b0;
				sin81 = 1'b0;
				end

			mode_2b: begin
				sin21 = 1'b0;
				sin31 = 1'b0;
				sin41 = 1'b1;
				sin51 = 1'b1;
				sin61 = 1'b0;
				sin71 = 1'b0;
				sin81 = 1'b0;
				end

		endcase
	end


	//-------------UUT instantiation----------
	M_88_0	M_88_0 (
		// Inputs
		.xr1(a[0]), .xr2(a[1]), .xr3(a[2]), .xr4(a[3]), .xr5(a[4]), .xr6(a[5]), .xr7(a[6]), .xr8(a[7]), 
		.yc1(w[7]), .yc2(w[6]), .yc3(w[5]), .yc4(w[4]), .yc5(w[3]), .yc6(w[2]), .yc7(w[1]), .yc8(w[0]),
		.sin11(1'b0), .sin12(1'b0), .sin13(1'b0), .sin14(1'b0), .sin15(1'b0), .sin16(1'b0), .sin17(1'b0), .sin18(1'b0),
		.sin21(sin21), .sin31(sin31), .sin41(sin41), .sin51(sin51), .sin61(sin61), .sin71(sin71), .sin81(sin81),
        .cin11(1'b0), .cin12(1'b0), .cin13(1'b0), .cin14(1'b0), .cin15(1'b0), .cin16(1'b0), .cin17(1'b0), .cin18(1'b0),
		.mode_2b(mode_2b), .mode_4b(mode_4b), .mode_8b(mode_8b),
		// Outputs
		.sout18(p[0]), .sout28(p[1]), .sout38(p[2]), .sout48(p[3]), .sout58(p[4]), .sout68(p[5]), .sout78(p[6]), .sout88(p[7]),
		.sout81(sout81), .sout82(sout82), .sout83(sout83), .sout84(sout84), .sout85(sout85), .sout86(sout86), .sout87(sout87), 
		.cout81(cout81), .cout82(cout82), .cout83(cout83), .cout84(cout84), .cout85(cout85), .cout86(cout86), .cout87(cout87), .cout88(cout88)
	);

	M88_downAdder	M88_downAdder (
		// Inputs
		.s({sout81,sout82,sout83,sout84,sout85,sout86,sout87}),
		.c({cout81,cout82,cout83,cout84,cout85,cout86,cout87,cout88}),
		.mode_8b(mode_8b),
		// Outputs
		.p_high(p[15:8])
	);

endmodule // M88_top

//-------------------------------------------------------------
// Design:        M_88_0
// Description:   8x8 block for signed array multiplier @ position 0
// Working mode:  --
// Author:	      Linyan Mei
//-------------------------------------------------------------

module M_88_0 (xr1, xr2, xr3, xr4, xr5, xr6, xr7, xr8, 
               yc1, yc2, yc3, yc4, yc5, yc6, yc7, yc8,
               sin11, sin12, sin13, sin14, sin15, sin16, sin17, sin18, 
               sin21, sin31, sin41, sin51, sin61, sin71, sin81,
               cin11, cin12, cin13, cin14, cin15, cin16, cin17, cin18, 
               sout18, sout28, sout38, sout48, sout58, sout68, sout78, sout88,
               sout81, sout82, sout83, sout84, sout85, sout86, sout87, 
               cout81, cout82, cout83, cout84, cout85, cout86, cout87, cout88, 
               mode_2b, mode_4b, mode_8b);

	//-------------Inputs----------------------------------	
	//----Data in--------
	input          xr1, xr2, xr3, xr4, xr5, xr6, xr7, xr8;                       // X in  (@ row 1,2,3,4,...,8)
	input          yc1, yc2, yc3, yc4, yc5, yc6, yc7, yc8;                       // Y in  (@ column 1,2,3,4,...8)
	input          sin11, sin12, sin13, sin14, sin15, sin16, sin17, sin18;       // Sum in    (@ row & colum)
	input          sin21, sin31, sin41, sin51, sin61, sin71, sin81;              // Sum in    (@ row & colum)
	input          cin11, cin12, cin13, cin14, cin15, cin16, cin17, cin18;       // Carry in  (@ row & colum)
	//----Control in-----
	input          mode_2b, mode_4b, mode_8b;

	//-------------Outputs---------------------------------
	output         sout18, sout28, sout38, sout48, sout58, sout68, sout78, sout88;   // Sum out   (@ row & colum)
	output         sout81, sout82, sout83, sout84, sout85, sout86, sout87;           // Sum out   (@ row & colum)
	output         cout81, cout82, cout83, cout84, cout85, cout86, cout87, cout88;   // Carry out (@ row & colum)
	
	//-------------Internal signals------------------------
	logic          c41_51, c42_52, c43_53, c44_54, c45_55, c46_56, c47_57, c48_58;                                         // Carry  (from .. to ..)
	logic          s41_52, s42_53, s43_54, s44_55, s45_56, s46_57,s47_58, s14_25, s24_35,s34_45, s54_65, s64_75, s74_85;   // Sum    (from .. to ..)



	//-------------UUT instantiation----------
	M_44_0	M_44_0 (
		// Inputs
		.xr1(xr1),.xr2(xr2), .xr3(xr3), .xr4(xr4),
		.yc1(yc1),.yc2(yc2), .yc3(yc3),.yc4(yc4),
		.sin11(sin11), .sin12(sin12), .sin13(sin13), .sin14(sin14),
		.sin21(sin21), .sin31(sin31), .sin41(sin41),
		.cin11(cin11), .cin12(cin12), .cin13(cin13), .cin14(cin14),
		.mode_2b (mode_2b),.mode_4b (mode_4b),.mode_8b (mode_8b),
		// Outputs
		.sout14(s14_25), .sout24(s24_35), .sout34(s34_45), .sout44(s44_55),
		.sout41(s41_52), .sout42(s42_53), .sout43(s43_54),
		.cout41(c41_51), .cout42(c42_52), .cout43(c43_53), .cout44(c44_54)
	);

	M_44_4	M_44_4 (
		// Inputs
		.xr1(xr5),.xr2(xr6), .xr3(xr7), .xr4(xr8),
		.yc1(yc1),.yc2(yc2), .yc3(yc3),.yc4(yc4),
		.sin11(sin51), .sin12(s41_52), .sin13(s42_53), .sin14(s43_54),
		.sin21(sin61), .sin31(sin71), .sin41(sin81),
		.cin11(c41_51), .cin12(c42_52), .cin13(c43_53), .cin14(c44_54),
		.mode_2b (mode_2b),.mode_4b (mode_4b),.mode_8b (mode_8b),
		// Outputs
		.sout14(s54_65), .sout24(s64_75), .sout34(s74_85), .sout44(sout84),
		.sout41(sout81), .sout42(sout82), .sout43(sout83),
		.cout41(cout81), .cout42(cout82), .cout43(cout83), .cout44(cout84)
	);

	M_44_32	M_44_32 (
		// Inputs
		.xr1(xr1),.xr2(xr2), .xr3(xr3), .xr4(xr4),
		.yc1(yc5),.yc2(yc6), .yc3(yc7),.yc4(yc8),
		.sin11(sin15), .sin12(sin16), .sin13(sin17), .sin14(sin18),
		.sin21(s14_25), .sin31(s24_35), .sin41(s34_45),
		.cin11(cin15), .cin12(cin16), .cin13(cin17), .cin14(cin18),
		.mode_2b (mode_2b),.mode_4b (mode_4b),.mode_8b (mode_8b),
		// Outputs
		.sout14(sout18), .sout24(sout28), .sout34(sout38), .sout44(sout48),
		.sout41(s45_56), .sout42(s46_57), .sout43(s47_58),
		.cout41(c45_55), .cout42(c46_56), .cout43(c47_57), .cout44(c48_58)
	);

	M_44_36	M_44_36 (
		// Inputs
		.xr1(xr5),.xr2(xr6), .xr3(xr7), .xr4(xr8),
		.yc1(yc5),.yc2(yc6), .yc3(yc7),.yc4(yc8),
		.sin11(s44_55), .sin12(s45_56), .sin13(s46_57), .sin14(s47_58),
		.sin21(s54_65), .sin31(s64_75), .sin41(s74_85),
		.cin11(c45_55), .cin12(c46_56), .cin13(c47_57), .cin14(c48_58),
		.mode_2b(mode_2b), .mode_4b(mode_4b), .mode_8b(mode_8b),
		// Outputs
		.sout14(sout58), .sout24(sout68), .sout34(sout78), .sout44(sout88),
		.sout41(sout85), .sout42(sout86), .sout43(sout87),
		.cout41(cout85), .cout42(cout86), .cout43(cout87), .cout44(cout88)
	);
endmodule // M_88_0


//-------------------------------------------------------------
// Design:        M88_downAdder
// Description:   1x8 block for downside addition
// Working mode:  --
// Author:	      Linyan Mei
//-------------------------------------------------------------

module M88_downAdder (s,c,mode_8b,p_high);

	//-------------Inputs----------------------------------
	input    [6:0] s;
	input    [7:0] c;
	input          mode_8b;

	//-------------Outputs---------------------------------
	output   [7:0] p_high;

	//-------------Datapath--------------------------------
	assign p_high = (mode_8b) ? {1'b1,s}+c : {1'b0,s}+c;

endmodule // M88_downAdder


//-------------------------------------------------------------
// Design:        M_22_0
// Description:   2x2 block for signed array multiplier @ position 0
// Working mode:  Compute / Propgate
//                possitive / negative
// Author:	      Linyan Mei
//-------------------------------------------------------------


module M_22_0 (xr1, xr2, yc1, yc2, sin11, sin12, sin21, cin11, cin12, sout21, sout22, sout12, cout21, cout22, mode_2b, mode_4b, mode_8b);

	//-------------Inputs----------------------------------	
	//----Data in--------
	input          xr1, xr2;               // X in      (@ row 1,2)
	input          yc1, yc2;               // Y in      (@ column 1,2)
	input          sin11, sin12, sin21;    // Sum in    (@ row & column)
	input          cin11, cin12;           // Carry in  (@ row & column)

	//----Control in-----
	input          mode_2b, mode_4b, mode_8b;

	//-------------Outputs---------------------------------
	output         sout21, sout22, sout12; // Sum out   (@ row & column)
	output         cout21, cout22;         // Carry out (@ row & column)
	
	//-------------Internal signals------------------------
	logic          c11_21;                 // Carry  (from .. to ..)
	logic          c12_22;                 // Carry  (from .. to ..)
	logic          s11_22;                 // Sum    (from .. to ..)

	//-------------Datapath--------------------------------

	//-------------UUT instantiation----------
	M_adderUnit	M11 (
		// Inputs
		.a         (xr1),
		.b         (yc1),
		.sin       (sin11),
		.cin       (cin11),
		.enable    (1'b1),
		.not_sel   (1'b1),
		// Outputs
		.sout      (s11_22),
		.cout      (c11_21)
	);

	M_adderUnit	M12 (
		// Inputs
		.a         (xr1),
		.b         (yc2),
		.sin       (sin12),
		.cin       (cin12),
		.enable    (1'b1),
		.not_sel   (1'b0),
		// Outputs
		.sout      (sout12),
		.cout      (c12_22)
	);

	M_adderUnit	M21 (
		// Inputs
		.a         (xr2),
		.b         (yc1),
		.sin       (sin21),
		.cin       (c11_21),
		.enable    (1'b1),
		.not_sel   (~mode_2b),
		// Outputs
		.sout      (sout21),
		.cout      (cout21)
	);

	M_adderUnit	M22 (
		// Inputs
		.a         (xr2),
		.b         (yc2),
		.sin       (s11_22),
		.cin       (c12_22),
		.enable    (1'b1),
		.not_sel   (mode_2b),
		// Outputs
		.sout      (sout22),
		.cout      (cout22)
	);
endmodule // M_22_0
//-------------------------------------------------------------
// Design:        M_22_16
// Description:   2x2 block for signed array multiplier @ position 16
// Working mode:  Compute / Propgate
//                possitive / negative
// Author:	      Linyan Mei
//-------------------------------------------------------------


module M_22_16 (xr1, xr2, yc1, yc2, sin11, sin12, sin21, cin11, cin12, sout21, sout22, sout12, cout21, cout22, mode_2b, mode_4b, mode_8b);

	//-------------Inputs----------------------------------	
	//----Data in--------
	input          xr1, xr2;               // X in      (@ row 1,2)
	input          yc1, yc2;               // Y in      (@ column 1,2)
	input          sin11, sin12, sin21;    // Sum in    (@ row & column)
	input          cin11, cin12;           // Carry in  (@ row & column)

	//----Control in-----
	input          mode_2b, mode_4b, mode_8b;

	//-------------Outputs---------------------------------
	output         sout21, sout22, sout12; // Sum out   (@ row & column)
	output         cout21, cout22;         // Carry out (@ row & column)
	
	//-------------Internal signals------------------------
	logic          c11_21;                 // Carry  (from .. to ..)
	logic          c12_22;                 // Carry  (from .. to ..)
	logic          s11_22;                 // Sum    (from .. to ..)

	//-------------Datapath--------------------------------

	//-------------UUT instantiation----------
	M_adderUnit	M11 (
		// Inputs
		.a         (xr1),
		.b         (yc1),
		.sin       (sin11),
		.cin       (cin11),
		.enable    (~mode_2b),
		.not_sel   (1'b0),
		// Outputs
		.sout      (s11_22),
		.cout      (c11_21)
	);

	M_adderUnit	M12 (
		// Inputs
		.a         (xr1),
		.b         (yc2),
		.sin       (sin12),
		.cin       (cin12),
		.enable    (~mode_2b),
		.not_sel   (1'b0),
		// Outputs
		.sout      (sout12),
		.cout      (c12_22)
	);

	M_adderUnit	M21 (
		// Inputs
		.a         (xr2),
		.b         (yc1),
		.sin       (sin21),
		.cin       (c11_21),
		.enable    (~mode_2b),
		.not_sel   (1'b0),
		// Outputs
		.sout      (sout21),
		.cout      (cout21)
	);

	M_adderUnit	M22 (
		// Inputs
		.a         (xr2),
		.b         (yc2),
		.sin       (s11_22),
		.cin       (c12_22),
		.enable    (~mode_2b),
		.not_sel   (1'b0),
		// Outputs
		.sout      (sout22),
		.cout      (cout22)
	);
endmodule // M_22_16
//-------------------------------------------------------------
// Design:        M_22_18
// Description:   2x2 block for signed array multiplier @ position 18
// Working mode:  Compute / Propgate
//                possitive / negative
// Author:	      Linyan Mei
//-------------------------------------------------------------


module M_22_18 (xr1, xr2, yc1, yc2, sin11, sin12, sin21, cin11, cin12, sout21, sout22, sout12, cout21, cout22, mode_2b, mode_4b, mode_8b);

	//-------------Inputs----------------------------------	
	//----Data in--------
	input          xr1, xr2;               // X in      (@ row 1,2)
	input          yc1, yc2;               // Y in      (@ column 1,2)
	input          sin11, sin12, sin21;    // Sum in    (@ row & column)
	input          cin11, cin12;           // Carry in  (@ row & column)

	//----Control in-----
	input          mode_2b, mode_4b, mode_8b;

	//-------------Outputs---------------------------------
	output         sout21, sout22, sout12; // Sum out   (@ row & column)
	output         cout21, cout22;         // Carry out (@ row & column)
	
	//-------------Internal signals------------------------
	logic          c11_21;                 // Carry  (from .. to ..)
	logic          c12_22;                 // Carry  (from .. to ..)
	logic          s11_22;                 // Sum    (from .. to ..)

	//-------------Datapath--------------------------------

	//-------------UUT instantiation----------
	M_adderUnit	M11 (
		// Inputs
		.a         (xr1),
		.b         (yc1),
		.sin       (sin11),
		.cin       (cin11),
		.enable    (1'b1),
		.not_sel   (mode_2b),
		// Outputs
		.sout      (s11_22),
		.cout      (c11_21)
	);

	M_adderUnit	M12 (
		// Inputs
		.a         (xr1),
		.b         (yc2),
		.sin       (sin12),
		.cin       (cin12),
		.enable    (1'b1),
		.not_sel   (1'b0),
		// Outputs
		.sout      (sout12),
		.cout      (c12_22)
	);

	M_adderUnit	M21 (
		// Inputs
		.a         (xr2),
		.b         (yc1),
		.sin       (sin21),
		.cin       (c11_21),
		.enable    (1'b1),
		.not_sel   (mode_4b),
		// Outputs
		.sout      (sout21),
		.cout      (cout21)
	);

	M_adderUnit	M22 (
		// Inputs
		.a         (xr2),
		.b         (yc2),
		.sin       (s11_22),
		.cin       (c12_22),
		.enable    (1'b1),
		.not_sel   (~mode_8b),
		// Outputs
		.sout      (sout22),
		.cout      (cout22)
	);
endmodule // M_22_18
//-------------------------------------------------------------
// Design:        M_22_22
// Description:   2x2 block for signed array multiplier @ position 22
// Working mode:  Compute / Propgate
//                possitive / negative
// Author:	      Linyan Mei
//-------------------------------------------------------------


module M_22_22 (xr1, xr2, yc1, yc2, sin11, sin12, sin21, cin11, cin12, sout21, sout22, sout12, cout21, cout22, mode_2b, mode_4b, mode_8b);

	//-------------Inputs----------------------------------	
	//----Data in--------
	input          xr1, xr2;               // X in      (@ row 1,2)
	input          yc1, yc2;               // Y in      (@ column 1,2)
	input          sin11, sin12, sin21;    // Sum in    (@ row & column)
	input          cin11, cin12;           // Carry in  (@ row & column)

	//----Control in-----
	input          mode_2b, mode_4b, mode_8b;

	//-------------Outputs---------------------------------
	output         sout21, sout22, sout12; // Sum out   (@ row & column)
	output         cout21, cout22;         // Carry out (@ row & column)
	
	//-------------Internal signals------------------------
	logic          c11_21;                 // Carry  (from .. to ..)
	logic          c12_22;                 // Carry  (from .. to ..)
	logic          s11_22;                 // Sum    (from .. to ..)

	//-------------Datapath--------------------------------

	//-------------UUT instantiation----------
	M_adderUnit	M11 (
		// Inputs
		.a         (xr1),
		.b         (yc1),
		.sin       (sin11),
		.cin       (cin11),
		.enable    (mode_8b),
		.not_sel   (1'b0),
		// Outputs
		.sout      (s11_22),
		.cout      (c11_21)
	);

	M_adderUnit	M12 (
		// Inputs
		.a         (xr1),
		.b         (yc2),
		.sin       (sin12),
		.cin       (cin12),
		.enable    (mode_8b),
		.not_sel   (1'b0),
		// Outputs
		.sout      (sout12),
		.cout      (c12_22)
	);

	M_adderUnit	M21 (
		// Inputs
		.a         (xr2),
		.b         (yc1),
		.sin       (sin21),
		.cin       (c11_21),
		.enable    (mode_8b),
		.not_sel   (1'b1),
		// Outputs
		.sout      (sout21),
		.cout      (cout21)
	);

	M_adderUnit	M22 (
		// Inputs
		.a         (xr2),
		.b         (yc2),
		.sin       (s11_22),
		.cin       (c12_22),
		.enable    (mode_8b),
		.not_sel   (1'b1),
		// Outputs
		.sout      (sout22),
		.cout      (cout22)
	);
endmodule // M_22_22
//-------------------------------------------------------------
// Design:        M_22_2
// Description:   2x2 block for signed array multiplier @ position 2
// Working mode:  Compute / Propgate
//                possitive / negative
// Author:	      Linyan Mei
//-------------------------------------------------------------


module M_22_2 (xr1, xr2, yc1, yc2, sin11, sin12, sin21, cin11, cin12, sout21, sout22, sout12, cout21, cout22, mode_2b, mode_4b, mode_8b);

	//-------------Inputs----------------------------------	
	//----Data in--------
	input          xr1, xr2;               // X in      (@ row 1,2)
	input          yc1, yc2;               // Y in      (@ column 1,2)
	input          sin11, sin12, sin21;    // Sum in    (@ row & column)
	input          cin11, cin12;           // Carry in  (@ row & column)

	//----Control in-----
	input          mode_2b, mode_4b, mode_8b;

	//-------------Outputs---------------------------------
	output         sout21, sout22, sout12; // Sum out   (@ row & column)
	output         cout21, cout22;         // Carry out (@ row & column)
	
	//-------------Internal signals------------------------
	logic          c11_21;                 // Carry  (from .. to ..)
	logic          c12_22;                 // Carry  (from .. to ..)
	logic          s11_22;                 // Sum    (from .. to ..)

	//-------------Datapath--------------------------------

	//-------------UUT instantiation----------
	M_adderUnit	M11 (
		// Inputs
		.a         (xr1),
		.b         (yc1),
		.sin       (sin11),
		.cin       (cin11),
		.enable    (~mode_2b),
		.not_sel   (1'b1),
		// Outputs
		.sout      (s11_22),
		.cout      (c11_21)
	);

	M_adderUnit	M12 (
		// Inputs
		.a         (xr1),
		.b         (yc2),
		.sin       (sin12),
		.cin       (cin12),
		.enable    (~mode_2b),
		.not_sel   (1'b0),
		// Outputs
		.sout      (sout12),
		.cout      (c12_22)
	);

	M_adderUnit	M21 (
		// Inputs
		.a         (xr2),
		.b         (yc1),
		.sin       (sin21),
		.cin       (c11_21),
		.enable    (~mode_2b),
		.not_sel   (mode_8b),
		// Outputs
		.sout      (sout21),
		.cout      (cout21)
	);

	M_adderUnit	M22 (
		// Inputs
		.a         (xr2),
		.b         (yc2),
		.sin       (s11_22),
		.cin       (c12_22),
		.enable    (~mode_2b),
		.not_sel   (mode_4b),
		// Outputs
		.sout      (sout22),
		.cout      (cout22)
	);
endmodule // M_22_2
//-------------------------------------------------------------
// Design:        M_22_32
// Description:   2x2 block for signed array multiplier @ position 32
// Working mode:  Compute / Propgate
//                possitive / negative
// Author:	      Linyan Mei
//-------------------------------------------------------------


module M_22_32 (xr1, xr2, yc1, yc2, sin11, sin12, sin21, cin11, cin12, sout21, sout22, sout12, cout21, cout22, mode_2b, mode_4b, mode_8b);

	//-------------Inputs----------------------------------	
	//----Data in--------
	input          xr1, xr2;               // X in      (@ row 1,2)
	input          yc1, yc2;               // Y in      (@ column 1,2)
	input          sin11, sin12, sin21;    // Sum in    (@ row & column)
	input          cin11, cin12;           // Carry in  (@ row & column)

	//----Control in-----
	input          mode_2b, mode_4b, mode_8b;

	//-------------Outputs---------------------------------
	output         sout21, sout22, sout12; // Sum out   (@ row & column)
	output         cout21, cout22;         // Carry out (@ row & column)
	
	//-------------Internal signals------------------------
	logic          c11_21;                 // Carry  (from .. to ..)
	logic          c12_22;                 // Carry  (from .. to ..)
	logic          s11_22;                 // Sum    (from .. to ..)

	//-------------Datapath--------------------------------

	//-------------UUT instantiation----------
	M_adderUnit	M11 (
		// Inputs
		.a         (xr1),
		.b         (yc1),
		.sin       (sin11),
		.cin       (cin11),
		.enable    (mode_8b),
		.not_sel   (1'b0),
		// Outputs
		.sout      (s11_22),
		.cout      (c11_21)
	);

	M_adderUnit	M12 (
		// Inputs
		.a         (xr1),
		.b         (yc2),
		.sin       (sin12),
		.cin       (cin12),
		.enable    (mode_8b),
		.not_sel   (1'b0),
		// Outputs
		.sout      (sout12),
		.cout      (c12_22)
	);

	M_adderUnit	M21 (
		// Inputs
		.a         (xr2),
		.b         (yc1),
		.sin       (sin21),
		.cin       (c11_21),
		.enable    (mode_8b),
		.not_sel   (1'b0),
		// Outputs
		.sout      (sout21),
		.cout      (cout21)
	);

	M_adderUnit	M22 (
		// Inputs
		.a         (xr2),
		.b         (yc2),
		.sin       (s11_22),
		.cin       (c12_22),
		.enable    (mode_8b),
		.not_sel   (1'b0),
		// Outputs
		.sout      (sout22),
		.cout      (cout22)
	);
endmodule // M_22_32
//-------------------------------------------------------------
// Design:        M_22_36
// Description:   2x2 block for signed array multiplier @ position 36
// Working mode:  Compute / Propgate
//                possitive / negative
// Author:	      Linyan Mei
//-------------------------------------------------------------


module M_22_36 (xr1, xr2, yc1, yc2, sin11, sin12, sin21, cin11, cin12, sout21, sout22, sout12, cout21, cout22, mode_2b, mode_4b, mode_8b);

	//-------------Inputs----------------------------------	
	//----Data in--------
	input          xr1, xr2;               // X in      (@ row 1,2)
	input          yc1, yc2;               // Y in      (@ column 1,2)
	input          sin11, sin12, sin21;    // Sum in    (@ row & column)
	input          cin11, cin12;           // Carry in  (@ row & column)

	//----Control in-----
	input          mode_2b, mode_4b, mode_8b;

	//-------------Outputs---------------------------------
	output         sout21, sout22, sout12; // Sum out   (@ row & column)
	output         cout21, cout22;         // Carry out (@ row & column)
	
	//-------------Internal signals------------------------
	logic          c11_21;                 // Carry  (from .. to ..)
	logic          c12_22;                 // Carry  (from .. to ..)
	logic          s11_22;                 // Sum    (from .. to ..)

	//-------------Datapath--------------------------------

	//-------------UUT instantiation----------
	M_adderUnit	M11 (
		// Inputs
		.a         (xr1),
		.b         (yc1),
		.sin       (sin11),
		.cin       (cin11),
		.enable    (1'b1),
		.not_sel   (~mode_8b),
		// Outputs
		.sout      (s11_22),
		.cout      (c11_21)
	);

	M_adderUnit	M12 (
		// Inputs
		.a         (xr1),
		.b         (yc2),
		.sin       (sin12),
		.cin       (cin12),
		.enable    (1'b1),
		.not_sel   (1'b0),
		// Outputs
		.sout      (sout12),
		.cout      (c12_22)
	);

	M_adderUnit	M21 (
		// Inputs
		.a         (xr2),
		.b         (yc1),
		.sin       (sin21),
		.cin       (c11_21),
		.enable    (1'b1),
		.not_sel   (mode_4b),
		// Outputs
		.sout      (sout21),
		.cout      (cout21)
	);

	M_adderUnit	M22 (
		// Inputs
		.a         (xr2),
		.b         (yc2),
		.sin       (s11_22),
		.cin       (c12_22),
		.enable    (1'b1),
		.not_sel   (mode_2b),
		// Outputs
		.sout      (sout22),
		.cout      (cout22)
	);
endmodule // M_22_36
//-------------------------------------------------------------
// Design:        M_22_38
// Description:   2x2 block for signed array multiplier @ position 38
// Working mode:  Compute / Propgate
//                possitive / negative
// Author:	      Linyan Mei
//-------------------------------------------------------------


module M_22_38 (xr1, xr2, yc1, yc2, sin11, sin12, sin21, cin11, cin12, sout21, sout22, sout12, cout21, cout22, mode_2b, mode_4b, mode_8b);

	//-------------Inputs----------------------------------	
	//----Data in--------
	input          xr1, xr2;               // X in      (@ row 1,2)
	input          yc1, yc2;               // Y in      (@ column 1,2)
	input          sin11, sin12, sin21;    // Sum in    (@ row & column)
	input          cin11, cin12;           // Carry in  (@ row & column)

	//----Control in-----
	input          mode_2b, mode_4b, mode_8b;

	//-------------Outputs---------------------------------
	output         sout21, sout22, sout12; // Sum out   (@ row & column)
	output         cout21, cout22;         // Carry out (@ row & column)
	
	//-------------Internal signals------------------------
	logic          c11_21;                 // Carry  (from .. to ..)
	logic          c12_22;                 // Carry  (from .. to ..)
	logic          s11_22;                 // Sum    (from .. to ..)

	//-------------Datapath--------------------------------

	//-------------UUT instantiation----------
	M_adderUnit	M11 (
		// Inputs
		.a         (xr1),
		.b         (yc1),
		.sin       (sin11),
		.cin       (cin11),
		.enable    (~mode_2b),
		.not_sel   (mode_4b),
		// Outputs
		.sout      (s11_22),
		.cout      (c11_21)
	);

	M_adderUnit	M12 (
		// Inputs
		.a         (xr1),
		.b         (yc2),
		.sin       (sin12),
		.cin       (cin12),
		.enable    (~mode_2b),
		.not_sel   (1'b0),
		// Outputs
		.sout      (sout12),
		.cout      (c12_22)
	);

	M_adderUnit	M21 (
		// Inputs
		.a         (xr2),
		.b         (yc1),
		.sin       (sin21),
		.cin       (c11_21),
		.enable    (~mode_2b),
		.not_sel   (mode_8b),
		// Outputs
		.sout      (sout21),
		.cout      (cout21)
	);

	M_adderUnit	M22 (
		// Inputs
		.a         (xr2),
		.b         (yc2),
		.sin       (s11_22),
		.cin       (c12_22),
		.enable    (~mode_2b),
		.not_sel   (~mode_2b),
		// Outputs
		.sout      (sout22),
		.cout      (cout22)
	);
endmodule // M_22_38
//-------------------------------------------------------------
// Design:        M_22_4
// Description:   2x2 block for signed array multiplier @ position 4
// Working mode:  Compute / Propgate
//                possitive / negative
// Author:	      Linyan Mei
//-------------------------------------------------------------


module M_22_4 (xr1, xr2, yc1, yc2, sin11, sin12, sin21, cin11, cin12, sout21, sout22, sout12, cout21, cout22, mode_2b, mode_4b, mode_8b);

	//-------------Inputs----------------------------------	
	//----Data in--------
	input          xr1, xr2;               // X in      (@ row 1,2)
	input          yc1, yc2;               // Y in      (@ column 1,2)
	input          sin11, sin12, sin21;    // Sum in    (@ row & column)
	input          cin11, cin12;           // Carry in (@ row & column)

	//----Control in-----
	input          mode_2b, mode_4b, mode_8b;

	//-------------Outputs---------------------------------
	output         sout21, sout22, sout12; // Sum out   (@ row & column)
	output         cout21, cout22;         // Carry out (@ row & column)
	
	//-------------Internal signals------------------------
	logic          c11_21;                 // Carry  (from .. to ..)
	logic          c12_22;                 // Carry  (from .. to ..)
	logic          s11_22;                 // Sum    (from .. to ..)

	//-------------Datapath--------------------------------

	//-------------UUT instantiation----------
	M_adderUnit	M11 (
		// Inputs
		.a         (xr1),
		.b         (yc1),
		.sin       (sin11),
		.cin       (cin11),
		.enable    (mode_8b),
		.not_sel   (1'b1),
		// Outputs
		.sout      (s11_22),
		.cout      (c11_21)
	);

	M_adderUnit	M12 (
		// Inputs
		.a         (xr1),
		.b         (yc2),
		.sin       (sin12),
		.cin       (cin12),
		.enable    (mode_8b),
		.not_sel   (1'b0),
		// Outputs
		.sout      (sout12),
		.cout      (c12_22)
	);

	M_adderUnit	M21 (
		// Inputs
		.a         (xr2),
		.b         (yc1),
		.sin       (sin21),
		.cin       (c11_21),
		.enable    (mode_8b),
		.not_sel   (1'b1),
		// Outputs
		.sout      (sout21),
		.cout      (cout21)
	);

	M_adderUnit	M22 (
		// Inputs
		.a         (xr2),
		.b         (yc2),
		.sin       (s11_22),
		.cin       (c12_22),
		.enable    (mode_8b),
		.not_sel   (1'b0),
		// Outputs
		.sout      (sout22),
		.cout      (cout22)
	);
endmodule // M_22_4
//-------------------------------------------------------------
// Design:        M_22_54
// Description:   2x2 block for signed array multiplier @ position 54
// Working mode:  Compute / Propgate
//                possitive / negative
// Author:	      Linyan Mei
//-------------------------------------------------------------


module M_22_54 (xr1, xr2, yc1, yc2, sin11, sin12, sin21, cin11, cin12, sout21, sout22, sout12, cout21, cout22, mode_2b, mode_4b, mode_8b);

	//-------------Inputs----------------------------------	
	//----Data in--------
	input          xr1, xr2;               // X in      (@ row 1,2)
	input          yc1, yc2;               // Y in      (@ column 1,2)
	input          sin11, sin12, sin21;    // Sum in    (@ row & column)
	input          cin11, cin12;           // Carry in  (@ row & column)

	//----Control in-----
	input          mode_2b, mode_4b, mode_8b;

	//-------------Outputs---------------------------------
	output         sout21, sout22, sout12; // Sum out   (@ row & column)
	output         cout21, cout22;         // Carry out (@ row & column)
	
	//-------------Internal signals------------------------
	logic          c11_21;                 // Carry  (from .. to ..)
	logic          c12_22;                 // Carry  (from .. to ..)
	logic          s11_22;                 // Sum    (from .. to ..)

	//-------------Datapath--------------------------------

	//-------------UUT instantiation----------
	M_adderUnit	M11 (
		// Inputs
		.a         (xr1),
		.b         (yc1),
		.sin       (sin11),
		.cin       (cin11),
		.enable    (1'b1),
		.not_sel   (mode_2b),
		// Outputs
		.sout      (s11_22),
		.cout      (c11_21)
	);

	M_adderUnit	M12 (
		// Inputs
		.a         (xr1),
		.b         (yc2),
		.sin       (sin12),
		.cin       (cin12),
		.enable    (1'b1),
		.not_sel   (1'b0),
		// Outputs
		.sout      (sout12),
		.cout      (c12_22)
	);

	M_adderUnit	M21 (
		// Inputs
		.a         (xr2),
		.b         (yc1),
		.sin       (sin21),
		.cin       (c11_21),
		.enable    (1'b1),
		.not_sel   (~mode_2b),
		// Outputs
		.sout      (sout21),
		.cout      (cout21)
	);

	M_adderUnit	M22 (
		// Inputs
		.a         (xr2),
		.b         (yc2),
		.sin       (s11_22),
		.cin       (c12_22),
		.enable    (1'b1),
		.not_sel   (1'b1),
		// Outputs
		.sout      (sout22),
		.cout      (cout22)
	);
endmodule // M_22_54
//-------------------------------------------------------------
// Design:        M_22_6
// Description:   2x2 block for signed array multiplier @ position 6
// Working mode:  Compute / Propgate
//                possitive / negative
// Author:	      Linyan Mei
//-------------------------------------------------------------


module M_22_6 (xr1, xr2, yc1, yc2, sin11, sin12, sin21, cin11, cin12, sout21, sout22, sout12, cout21, cout22, mode_2b, mode_4b, mode_8b);

	//-------------Inputs----------------------------------	
	//----Data in--------
	input          xr1, xr2;               // X in      (@ row 1,2)
	input          yc1, yc2;               // Y in      (@ column 1,2)
	input          sin11, sin12, sin21;    // Sum in    (@ row & column)
	input          cin11, cin12;           // Carry in (@ row & column)

	//----Control in-----
	input          mode_2b, mode_4b, mode_8b;

	//-------------Outputs---------------------------------
	output         sout21, sout22, sout12; // Sum out   (@ row & column)
	output         cout21, cout22;         // Carry out (@ row & column)
	
	//-------------Internal signals------------------------
	logic          c11_21;                 // Carry  (from .. to ..)
	logic          c12_22;                 // Carry  (from .. to ..)
	logic          s11_22;                 // Sum    (from .. to ..)

	//-------------Datapath--------------------------------

	//-------------UUT instantiation----------
	M_adderUnit	M11 (
		// Inputs
		.a         (xr1),
		.b         (yc1),
		.sin       (sin11),
		.cin       (cin11),
		.enable    (mode_8b),
		.not_sel   (1'b1),
		// Outputs
		.sout      (s11_22),
		.cout      (c11_21)
	);

	M_adderUnit	M12 (
		// Inputs
		.a         (xr1),
		.b         (yc2),
		.sin       (sin12),
		.cin       (cin12),
		.enable    (mode_8b),
		.not_sel   (1'b0),
		// Outputs
		.sout      (sout12),
		.cout      (c12_22)
	);

	M_adderUnit	M21 (
		// Inputs
		.a         (xr2),
		.b         (yc1),
		.sin       (sin21),
		.cin       (c11_21),
		.enable    (mode_8b),
		.not_sel   (1'b0),
		// Outputs
		.sout      (sout21),
		.cout      (cout21)
	);

	M_adderUnit	M22 (
		// Inputs
		.a         (xr2),
		.b         (yc2),
		.sin       (s11_22),
		.cin       (c12_22),
		.enable    (mode_8b),
		.not_sel   (1'b1),
		// Outputs
		.sout      (sout22),
		.cout      (cout22)
	);
endmodule // M_22_6
//-------------------------------------------------------------
// Design:        M_44_0
// Description:   4x4 block for signed array multiplier @ position 0
// Working mode:  --
// Author:	      Linyan Mei
//-------------------------------------------------------------


module M_44_0 (xr1, xr2, xr3, xr4, 
               yc1, yc2, yc3, yc4,
               sin11, sin12, sin13, sin14, 
               sin21, sin31, sin41,
               cin11, cin12, cin13, cin14, 
               sout14, sout24, sout34, sout44,
               sout41, sout42, sout43, 
               cout41, cout42, cout43, cout44, 
               mode_2b, mode_4b, mode_8b);

	//-------------Inputs----------------------------------	
	//----Data in--------
	input          xr1, xr2, xr3, xr4;               // X in      (@ row 1,2,3,4)
	input          yc1, yc2, yc3, yc4;               // Y in      (@ column 1,2,3,4)
	input          sin11, sin12, sin13, sin14;       // Sum in    (@ row & colum)
	input          sin21, sin31, sin41;              // Sum in    (@ row & colum)
	input          cin11, cin12, cin13, cin14;       // Carry in  (@ row & colum)
	//----Control in-----
	input          mode_2b, mode_4b, mode_8b;

	//-------------Outputs---------------------------------
	output         sout14, sout24, sout34, sout44;   // Sum out   (@ row & colum)
	output         sout41, sout42, sout43;           // Sum out   (@ row & colum)
	output         cout41, cout42, cout43, cout44;   // Carry out (@ row & colum)
	
	//-------------Internal signals------------------------
	logic          c21_31, c22_32, c23_33, c24_34;           // Carry  (from .. to ..)
	logic          s21_32, s22_33, s23_34, s12_23, s32_43;   // Sum    (from .. to ..)

	//-------------Datapath--------------------------------

	//-------------UUT instantiation----------
	M_22_0	M_22_0 (
		// Inputs
		.xr1 (xr1),.xr2 (xr2),.yc1 (yc1),.yc2 (yc2),
		.sin11 (sin11),.sin12 (sin12),.sin21 (sin21),
		.cin11 (cin11),.cin12 (cin12),
		.mode_2b (mode_2b),.mode_4b (mode_4b),.mode_8b (mode_8b),
		// Outputs
		.sout21 (s21_32),.sout22 (s22_33),.sout12 (s12_23),
		.cout21 (c21_31),.cout22 (c22_32)
	);

	M_22_2	M_22_2 (
		// Inputs
		.xr1 (xr3),.xr2 (xr4),.yc1 (yc1),.yc2 (yc2),
		.sin11 (sin31),.sin12 (s21_32),.sin21 (sin41),
		.cin11 (c21_31),.cin12 (c22_32),
		.mode_2b (mode_2b),.mode_4b (mode_4b),.mode_8b (mode_8b),
		// Outputs
		.sout21 (sout41),.sout22 (sout42),.sout12 (s32_43),
		.cout21 (cout41),.cout22 (cout42)
	);

	M_22_16	M_22_16 (
		// Inputs
		.xr1 (xr1),.xr2 (xr2),.yc1 (yc3),.yc2 (yc4),
		.sin11 (sin13),.sin12 (sin14),.sin21 (s12_23),
		.cin11 (cin13),.cin12 (cin14),
		.mode_2b (mode_2b),.mode_4b (mode_4b),.mode_8b (mode_8b),
		// Outputs
		.sout21 (s23_34),.sout22 (sout24),.sout12 (sout14),
		.cout21 (c23_33),.cout22 (c24_34)
	);

	M_22_18	M_22_18 (
		// Inputs
		.xr1 (xr3),.xr2 (xr4),.yc1 (yc3),.yc2 (yc4),
		.sin11 (s22_33),.sin12 (s23_34),.sin21 (s32_43),
		.cin11 (c23_33),.cin12 (c24_34),
		.mode_2b (mode_2b),.mode_4b (mode_4b),.mode_8b (mode_8b),
		// Outputs
		.sout21 (sout43),.sout22 (sout44),.sout12 (sout34),
		.cout21 (cout43),.cout22 (cout44)
	);
endmodule // M_44_0


//-------------------------------------------------------------
// Design:        M_44_32
// Description:   4x4 block for signed array multiplier @ position 32
// Working mode:  --
// Author:	      Linyan Mei
//-------------------------------------------------------------


module M_44_32 (xr1, xr2, xr3, xr4, 
                yc1, yc2, yc3, yc4,
                sin11, sin12, sin13, sin14, 
                sin21, sin31, sin41,
                cin11, cin12, cin13, cin14, 
                sout14, sout24, sout34, sout44,
                sout41, sout42, sout43, 
                cout41, cout42, cout43, cout44, 
                mode_2b, mode_4b, mode_8b);

	//-------------Inputs----------------------------------	
	//----Data in--------
	input          xr1, xr2, xr3, xr4;               // X in      (@ row 1,2,3,4)
	input          yc1, yc2, yc3, yc4;               // Y in      (@ column 1,2,3,4)
	input          sin11, sin12, sin13, sin14;       // Sum in    (@ row & colum)
	input          sin21, sin31, sin41;              // Sum in    (@ row & colum)
	input          cin11, cin12, cin13, cin14;       // Carry out (@ row & colum)
	//----Control in-----
	input          mode_2b, mode_4b, mode_8b;

	//-------------Outputs---------------------------------
	output         sout14, sout24, sout34, sout44;   // Sum out   (@ row & colum)
	output         sout41, sout42, sout43;           // Sum out   (@ row & colum)
	output         cout41, cout42, cout43, cout44;   // Carry out (@ row & colum)
	
	//-------------Internal signals------------------------
	logic          c21_31, c22_32, c23_33, c24_34;           // Carry  (from .. to ..)
	logic          s21_32, s22_33, s23_34, s12_23, s32_43;   // Sum    (from .. to ..)

	//-------------Datapath--------------------------------

	//-------------UUT instantiation----------
	M_22_32	M_22_32 (
		// Inputs
		.xr1 (xr1),.xr2 (xr2),.yc1 (yc1),.yc2 (yc2),
		.sin11 (sin11),.sin12 (sin12),.sin21 (sin21),
		.cin11 (cin11),.cin12 (cin12),
		.mode_2b (mode_2b),.mode_4b (mode_4b),.mode_8b (mode_8b),
		// Outputs
		.sout21 (s21_32),.sout22 (s22_33),.sout12 (s12_23),
		.cout21 (c21_31),.cout22 (c22_32)
	);

	M_22_32	M_22_34 (
		// Inputs
		.xr1 (xr3),.xr2 (xr4),.yc1 (yc1),.yc2 (yc2),
		.sin11 (sin31),.sin12 (s21_32),.sin21 (sin41),
		.cin11 (c21_31),.cin12 (c22_32),
		.mode_2b (mode_2b),.mode_4b (mode_4b),.mode_8b (mode_8b),
		// Outputs
		.sout21 (sout41),.sout22 (sout42),.sout12 (s32_43),
		.cout21 (cout41),.cout22 (cout42)
	);

	M_22_32	M_22_48 (
		// Inputs
		.xr1 (xr1),.xr2 (xr2),.yc1 (yc3),.yc2 (yc4),
		.sin11 (sin13),.sin12 (sin14),.sin21 (s12_23),
		.cin11 (cin13),.cin12 (cin14),
		.mode_2b (mode_2b),.mode_4b (mode_4b),.mode_8b (mode_8b),
		// Outputs
		.sout21 (s23_34),.sout22 (sout24),.sout12 (sout14),
		.cout21 (c23_33),.cout22 (c24_34)
	);

	M_22_32	M_22_50 (
		// Inputs
		.xr1 (xr3),.xr2 (xr4),.yc1 (yc3),.yc2 (yc4),
		.sin11 (s22_33),.sin12 (s23_34),.sin21 (s32_43),
		.cin11 (c23_33),.cin12 (c24_34),
		.mode_2b (mode_2b),.mode_4b (mode_4b),.mode_8b (mode_8b),
		// Outputs
		.sout21 (sout43),.sout22 (sout44),.sout12 (sout34),
		.cout21 (cout43),.cout22 (cout44)
	);
endmodule // M_44_32


//-------------------------------------------------------------
// Design:        M_44_36
// Description:   4x4 block for signed array multiplier @ position 36
// Working mode:  --
// Author:	      Linyan Mei
//-------------------------------------------------------------


module M_44_36 (xr1, xr2, xr3, xr4, 
               yc1, yc2, yc3, yc4,
               sin11, sin12, sin13, sin14, 
               sin21, sin31, sin41,
               cin11, cin12, cin13, cin14, 
               sout14, sout24, sout34, sout44,
               sout41, sout42, sout43, 
               cout41, cout42, cout43, cout44, 
               mode_2b, mode_4b, mode_8b);

	//-------------Inputs----------------------------------	
	//----Data in--------
	input          xr1, xr2, xr3, xr4;               // X in      (@ row 1,2,3,4)
	input          yc1, yc2, yc3, yc4;               // Y in      (@ column 1,2,3,4)
	input          sin11, sin12, sin13, sin14;       // Sum in    (@ row & colum)
	input          sin21, sin31, sin41;              // Sum in    (@ row & colum)
	input          cin11, cin12, cin13, cin14;       // Carry in  (@ row & colum)
	//----Control in-----
	input          mode_2b;
	input          mode_4b;
	input          mode_8b;

	//-------------Outputs---------------------------------
	output         sout14, sout24, sout34, sout44;   // Sum out   (@ row & colum)
	output         sout41, sout42, sout43;           // Sum out   (@ row & colum)
	output         cout41, cout42, cout43, cout44;   // Carry out (@ row & colum)
	
	//-------------Internal signals------------------------
	logic          c21_31, c22_32, c23_33, c24_34;           // Carry  (from .. to ..)
	logic          s21_32, s22_33, s23_34, s12_23, s32_43;   // Sum    (from .. to ..)

	//-------------Datapath--------------------------------

	//-------------UUT instantiation----------
	M_22_36	M_22_36 (
		// Inputs
		.xr1 (xr1),.xr2 (xr2),.yc1 (yc1),.yc2 (yc2),
		.sin11 (sin11),.sin12 (sin12),.sin21 (sin21),
		.cin11 (cin11),.cin12 (cin12),
		.mode_2b (mode_2b),.mode_4b (mode_4b),.mode_8b (mode_8b),
		// Outputs
		.sout21 (s21_32),.sout22 (s22_33),.sout12 (s12_23),
		.cout21 (c21_31),.cout22 (c22_32)
	);

	M_22_38	M_22_38 (
		// Inputs
		.xr1 (xr3),.xr2 (xr4),.yc1 (yc1),.yc2 (yc2),
		.sin11 (sin31),.sin12 (s21_32),.sin21 (sin41),
		.cin11 (c21_31),.cin12 (c22_32),
		.mode_2b (mode_2b),.mode_4b (mode_4b),.mode_8b (mode_8b),
		// Outputs
		.sout21 (sout41),.sout22 (sout42),.sout12 (s32_43),
		.cout21 (cout41),.cout22 (cout42)
	);

	M_22_16	M_22_52 (
		// Inputs
		.xr1 (xr1),.xr2 (xr2),.yc1 (yc3),.yc2 (yc4),
		.sin11 (sin13),.sin12 (sin14),.sin21 (s12_23),
		.cin11 (cin13),.cin12 (cin14),
		.mode_2b (mode_2b),.mode_4b (mode_4b),.mode_8b (mode_8b),
		// Outputs
		.sout21 (s23_34),.sout22 (sout24),.sout12 (sout14),
		.cout21 (c23_33),.cout22 (c24_34)
	);

	M_22_54	M_22_54 (
		// Inputs
		.xr1 (xr3),.xr2 (xr4),.yc1 (yc3),.yc2 (yc4),
		.sin11 (s22_33),.sin12 (s23_34),.sin21 (s32_43),
		.cin11 (c23_33),.cin12 (c24_34),
		.mode_2b (mode_2b),.mode_4b (mode_4b),.mode_8b (mode_8b),
		// Outputs
		.sout21 (sout43),.sout22 (sout44),.sout12 (sout34),
		.cout21 (cout43),.cout22 (cout44)
	);
endmodule // M_44_36


//-------------------------------------------------------------
// Design:        M_44_4
// Description:   4x4 block for signed array multiplier @ position 4
// Working mode:  --
// Author:	      Linyan Mei
//-------------------------------------------------------------


module M_44_4 (xr1, xr2, xr3, xr4, 
               yc1, yc2, yc3, yc4,
               sin11, sin12, sin13, sin14, 
               sin21, sin31, sin41,
               cin11, cin12, cin13, cin14, 
               sout14, sout24, sout34, sout44,
               sout41, sout42, sout43, 
               cout41, cout42, cout43, cout44, 
               mode_2b, mode_4b, mode_8b);

	//-------------Inputs----------------------------------	
	//----Data in--------
	input          xr1, xr2, xr3, xr4;               // X in      (@ row 1,2,3,4)
	input          yc1, yc2, yc3, yc4;               // Y in      (@ column 1,2,3,4)
	input          sin11, sin12, sin13, sin14;       // Sum in    (@ row & colum)
	input          sin21, sin31, sin41;              // Sum in    (@ row & colum)
	input          cin11, cin12, cin13, cin14;       // Carry out (@ row & colum)
	//----Control in-----
	input          mode_2b, mode_4b, mode_8b;

	//-------------Outputs---------------------------------
	output         sout14, sout24, sout34, sout44;   // Sum out   (@ row & colum)
	output         sout41, sout42, sout43;           // Sum out   (@ row & colum)
	output         cout41, cout42, cout43, cout44;   // Carry out (@ row & colum)
	
	//-------------Internal signals------------------------
	logic          c21_31, c22_32, c23_33, c24_34;           // Carry  (from .. to ..)
	logic          s21_32, s22_33, s23_34, s12_23, s32_43;   // Sum    (from .. to ..)

	//-------------Datapath--------------------------------

	//-------------UUT instantiation----------
	M_22_4	M_22_4 (
		// Inputs
		.xr1 (xr1),.xr2 (xr2),.yc1 (yc1),.yc2 (yc2),
		.sin11 (sin11),.sin12 (sin12),.sin21 (sin21),
		.cin11 (cin11),.cin12 (cin12),
		.mode_2b (mode_2b),.mode_4b (mode_4b),.mode_8b (mode_8b),
		// Outputs
		.sout21 (s21_32),.sout22 (s22_33),.sout12 (s12_23),
		.cout21 (c21_31),.cout22 (c22_32)
	);

	M_22_6	M_22_6 (
		// Inputs
		.xr1 (xr3),.xr2 (xr4),.yc1 (yc1),.yc2 (yc2),
		.sin11 (sin31),.sin12 (s21_32),.sin21 (sin41),
		.cin11 (c21_31),.cin12 (c22_32),
		.mode_2b (mode_2b),.mode_4b (mode_4b),.mode_8b (mode_8b),
		// Outputs
		.sout21 (sout41),.sout22 (sout42),.sout12 (s32_43),
		.cout21 (cout41),.cout22 (cout42)
	);

	M_22_32	M_22_20 (
		// Inputs
		.xr1 (xr1),.xr2 (xr2),.yc1 (yc3),.yc2 (yc4),
		.sin11 (sin13),.sin12 (sin14),.sin21 (s12_23),
		.cin11 (cin13),.cin12 (cin14),
		.mode_2b (mode_2b),.mode_4b (mode_4b),.mode_8b (mode_8b),
		// Outputs
		.sout21 (s23_34),.sout22 (sout24),.sout12 (sout14),
		.cout21 (c23_33),.cout22 (c24_34)
	);

	M_22_22	M_22_22 (
		// Inputs
		.xr1 (xr3),.xr2 (xr4),.yc1 (yc3),.yc2 (yc4),
		.sin11 (s22_33),.sin12 (s23_34),.sin21 (s32_43),
		.cin11 (c23_33),.cin12 (c24_34),
		.mode_2b (mode_2b),.mode_4b (mode_4b),.mode_8b (mode_8b),
		// Outputs
		.sout21 (sout43),.sout22 (sout44),.sout12 (sout34),
		.cout21 (cout43),.cout22 (cout44)
	);
endmodule // M_44_4

//-------------------------------------------------------------
// Design:        M_adderUnit
// Description:   Basic block for signed array multiplier
// Working mode:  Compute / Propgate
//                possitive / negative
// Author:	      Linyan Mei
//-------------------------------------------------------------


module M_adderUnit (a, b, sin, cin, enable, not_sel, sout, cout);

	//-------------Inputs----------------------------------	
	//----Data in--------
	input          a;
	input          b;
	input          sin;
	input          cin;

	//----Control in-----
	input          enable;  // enable = 0, propagate. // enable = 1, compute.
	input          not_sel; // not_sel = 1, not(a*b). // not_sel = 0, a*b.

	
	//-------------Outputs---------------------------------
	output         sout;
	output         cout;

	//-------------Internal signals------------------------
	logic          ab;

	//-------------Datapath--------------------------------
	always_comb begin
		if (enable)
			ab = (not_sel) ? ~(a&b) : (a&b);
		else
			ab = 1'b0;
	end	

	assign {cout,sout} = sin + cin + ab;

endmodule // M_adderUnit
