`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    07:40:51 09/18/2019 
// Design Name: 
// Module Name:    Justdgement 
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
module Justdgement(
    input sign,
    input [21:0] addr1,
    input [31:0] wr1,
    input cs1,
    input rw1,
    input [21:0] addr2,
    input [31:0] wr2,
    input cs2,
    input rw2,
    output reg  [21:0] addr,
    output reg [31:0] wr,
    output reg cs,
    output reg rw
    );
	 
	 always @(*)
	 begin
		case (sign)
		1'b0:
		begin
			addr <= addr1;
			wr <= wr1;
			cs <= cs1;
			rw <= rw1;
		end
		1'b1:
		begin
			addr <= addr2;
			wr <= wr2;
			cs <= cs2;
			rw <= rw2;
		end
		endcase
	 end
	 


endmodule
