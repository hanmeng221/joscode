`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:16:24 09/24/2019 
// Design Name: 
// Module Name:    UART_DETECT 
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
module UART_DETECT(
	input clk,
    input rst,
    input we,
    input [31:2] addr,
    output en
    );
	 
	 assign en = (!pre_we & r_we) && ( addr == 30'h2c000000); 
	 reg pre_we;
	 reg r_we;
	 
	always@(posedge clk)
	begin
		if(rst)begin
			pre_we = 1'b0;
		end else begin
			pre_we = r_we;
			r_we = we;
		end
	end
	
endmodule
