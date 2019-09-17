`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:58:46 08/02/2019 
// Design Name: 
// Module Name:    doubledata 
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
module doubledata(
    input clk,
    input dmwork,
    input dmwe,
    input [3:0] dmbin,
    input [21:0] dmaddr,
    input [31:0] dmdatain,
    output reg [31:0] dmdataout,
    input [21:0] imaddr,
    output reg [31:0] imdataout,
    input imwork,
    output reg done,//to cpu
    output reg memcs,
    output reg memrw,
    output reg [21:0] memaddr,
    output reg [31:0] memdatawrite,
    input [31:0] memdataread,
    input memdone
    );
//todo done can not access 1
initial
begin
	memcs = 1'b0;
	done = 1'b1;
	prework = 1'b0;
end

reg work= 1'b0;

reg lastimwork;

reg lastdmwork;

reg prework;
reg lastwork;

reg [1:0] workstate = 2'b0;
reg [1:0] finishnum = 2'b0;
reg ptr = 1'b0;

reg prefinishnum1;
reg predone;
always@(posedge clk)
begin
	if(memdone & ~predone)
		begin
		if (ptr)
		begin
			imdataout = memdataread;
		end else begin
			dmdataout = memdataread;
		end
	end
	workstate = {(~lastimwork & imwork )|(lastimwork & ~imwork),(~lastdmwork & dmwork) | (lastdmwork & ~dmwork)};
	lastimwork = imwork;
	lastdmwork = dmwork;
	case (workstate)
	2'b10:
	begin
		finishnum = 2'b01;
		ptr = 1'b1;
		work = ~work;
		done = 1'b0;
	end
	2'b01:
	begin
		finishnum = 2'b01;
		ptr = 1'b0;
		work = ~work;
		done = 1'b0;
	end
	2'b11:
	begin
		finishnum = 2'b10;
		ptr = 1'b1;
		work = ~work;
		done = 1'b0;
	end
	2'b00:
	begin
		work = (~ptr & memdone & finishnum[1] & ~finishnum[0])|(ptr & memdone & finishnum[1] & ~finishnum[0])?~work:work;
		ptr = (~ptr & ~memdone & finishnum[1] & ~finishnum[0] ) | (ptr & ~memdone & finishnum[1] & ~finishnum[0] ) | (ptr & ~memdone & ~finishnum[1] & finishnum[0]);
		prefinishnum1 = finishnum[1];
		finishnum[1] = (~ptr & ~memdone & finishnum[1] &~finishnum[0]) | (ptr & ~memdone & finishnum[1] & ~finishnum[0]);		
		finishnum[0] = (~ptr & ~memdone & ~prefinishnum1 & finishnum[0])|(~ptr & memdone & prefinishnum1 & ~finishnum[0]) | (ptr & ~memdone & ~prefinishnum1 & finishnum[0] ) | (ptr & memdone & prefinishnum1 & ~finishnum[0]);
		done = ~(finishnum[1] | finishnum[0]);
	end
	endcase
	lastwork = prework;
	prework = work;
	memcs = (~lastwork & prework) | (lastwork & ~prework);
	memaddr = ptr ? imaddr:dmaddr;	
	memdatawrite = ptr ? 32'b0:dmdatain;
	memrw = ptr ? 1'b0:dmwe;	
	predone = memdone;
	
end

endmodule
