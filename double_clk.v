`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:09:34 02/27/2019 
// Design Name: 
// Module Name:    double_clk 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module double_clk(
    input clk_in,
    output reg clk_out
    );
	initial clk_out=0;
	always@(posedge clk_in)
		clk_out=~clk_out;

endmodule
