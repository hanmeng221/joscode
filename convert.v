`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    08:37:52 09/19/2019 
// Design Name: 
// Module Name:    convert 
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
module convert(
    input clk,
    input rst,
    input work1,
    input work2,
    output reg cs1,
    output reg cs2
    );
	 reg prework1;
	 reg prework2;
	 always@(posedge clk)
	 begin
		if(rst)
		begin
			cs1 = 1'b0;
			cs2 = 1'b0;
			prework1 = 1'b0;
			prework2 = 1'b0;
		end else begin
			cs1 = work1;
			cs2 = prework2 ^ work2;
			prework1 = work1;
			prework2 = work2;
		end
	 end
	 


endmodule
