`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   12:12:16 09/18/2019
// Design Name:   mini_machine
// Module Name:   /home/ise/xls2/jos2/testBench.v
// Project Name:  src
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: mini_machine
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module testBench;

	// Inputs
	reg sys_clk;
	reg refresh_clk;
	reg sys_rst;
	reg [31:0] din;
	reg flash_rdybsyn;
	reg sram_waitn;
	reg uart_rxd;

	// Outputs
	wire [7:0] dout1;
	wire [7:0] dout2;
	wire [4:1] sel1;
	wire [4:1] sel2;
	wire TxD1;
	wire flash_cen;
	wire flash_resetn;
	wire flash_oen;
	wire flash_wen;
	wire flash_byten;
	wire [24:0] flash_a;
	wire sram_clk;
	wire sram_cen;
	wire sram_advn;
	wire sram_oen;
	wire sram_wen;
	wire sram_psn;
	wire [21:0] sram_a;
	wire [7:0] sram_ben;
	wire start;
	wire uart_txd;

	// Bidirs
	wire [31:0] flash_dq;
	wire [31:0] sram_dq;

	// Instantiate the Unit Under Test (UUT)
	mini_machine uut (
		.sys_clk(sys_clk), 
		.refresh_clk(refresh_clk), 
		.sys_rst(sys_rst), 
		.din(din), 
		.dout1(dout1), 
		.dout2(dout2), 
		.sel1(sel1), 
		.sel2(sel2), 
		.TxD1(TxD1), 
		.flash_cen(flash_cen), 
		.flash_resetn(flash_resetn), 
		.flash_oen(flash_oen), 
		.flash_wen(flash_wen), 
		.flash_byten(flash_byten), 
		.flash_a(flash_a), 
		.flash_dq(flash_dq), 
		.flash_rdybsyn(flash_rdybsyn), 
		.sram_clk(sram_clk), 
		.sram_cen(sram_cen), 
		.sram_advn(sram_advn), 
		.sram_oen(sram_oen), 
		.sram_wen(sram_wen), 
		.sram_psn(sram_psn), 
		.sram_a(sram_a), 
		.sram_dq(sram_dq), 
		.sram_ben(sram_ben), 
		.sram_waitn(sram_waitn), 
		.start(start), 
		.uart_rxd(uart_rxd), 
		.uart_txd(uart_txd)
	);

	initial begin
		// Initialize Inputs
		sys_clk = 1;
		refresh_clk = 1;
		sys_rst = 0;
		din = 0;
		flash_rdybsyn = 1;
		sram_waitn = 0;
		uart_rxd = 0;

		// Wait 100 ns for global reset to finish
		#5 sys_rst = 1;
      #10 din[0] = 1;
		// Add stimulus here
		#13 force flash_dq =32'hc00;
		#14 force flash_dq = 32'h5;
		#14 force flash_dq = 32'h0;
		#14 force flash_dq = 32'h0;
		#16 force flash_dq = 32'h34090001;
		#4 sram_waitn = 1;
		#20 force flash_dq = 32'h340a0002;
		#24 force flash_dq = 32'h340c0004;
		#24 force flash_dq = 32'h340d0005;
		#24 force flash_dq = 32'h014b4820;
		#21 din[1] = 1;
		#11 force sram_dq = 32'h34090001;
		#16 force sram_dq = 32'h340a0002;
		#16 force sram_dq = 32'h340c0004;
		#16 force sram_dq = 32'h340d0005;
		#16 force sram_dq = 32'h014b4820;
	end
	always #1 sys_clk = ~ sys_clk;
	
	always #10 refresh_clk = ~ refresh_clk;
      
endmodule

