`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:08:50 08/28/2019 
// Design Name: 
// Module Name:    deliver 
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
module deliver(
    input clk,
	 input rst,
	 input startFlag,
	 input flashReady,
	 input  [31:0] flashData,
    output	reg [24:0] flashAddr,
	 output reg flashCs,
	 
	 input sramReady,
    output reg [31:0]  sramData,
    output reg [21:0]   sramAddr,
	 output reg  sramCs,
	 output reg led
    );
	 
	 reg [31:0] instCount;
	 reg [31:0] dataCount;
	 
	 reg [4:0] DeliverState  /* synthesis preserve = 1 */;
	 reg [4:0] State;
	 
	 reg [31:0] instSize;
	 reg [31:0] dataSize;
	 
	 reg [21:0] instAddr;
	 reg [21:0] dataAddr;
	 
	 
	 reg [24:0] preflashAddr;
	 
	 always @(posedge clk or posedge rst)
	 begin
		if(rst)
		begin
			instCount = 32'b0;
			dataCount = 32'b0;
			
			DeliverState = 5'b0;
			State = 5'b0;
            
			flashAddr = 25'b0;
			sramAddr = 22'b0;
			
			instSize = 32'b0;
			dataSize = 32'b0;
			
			sramData = 32'b0;
			
			sramCs = 1'b0;
			flashCs = 1'b0;
			
			instAddr = 21'b0;
			dataAddr = 21'b0;
			
			preflashAddr = 25'b0;
			led = 1'b1;
		end else
		begin
            State = DeliverState;
			case (State)
			5'd0://read instAddr
			begin
				if(flashReady && startFlag)
				begin
					flashCs = 1'b1;
					DeliverState = 5'd1;
					flashAddr = 0;
				end
			end
            5'd1://wait a timer
            begin
                DeliverState = 5'd2;
            end
			5'd2://read instSize
			begin
				flashCs = 1'b0;
				if(flashReady)
				begin
					instAddr = flashData[21:0];
					flashCs = 1'b1;
					DeliverState = 5'd3;
					flashAddr = 1;
				end
			end
            5'd3://wait a timer
            begin
                DeliverState = 5'd4;
            end
			5'd4://read dataAddr
			begin
				flashCs = 1'b0;
				if(flashReady)
				begin
					instSize = flashData;
					flashCs = 1'b1;
					DeliverState = 5'd5;
					flashAddr = 2;
				end
			end
            5'd5://wait a timer
            begin
                DeliverState = 5'd6;
            end
			5'd6://read dataSize
			begin
				flashCs = 1'b0;
				if(flashReady)
				begin
					dataAddr = flashData[21:0];
					flashCs = 1'b1;
					DeliverState = 5'd7;
					flashAddr = 3;
				end
			end
            5'd7://wait a timer
            begin
                DeliverState = 5'd8;
            end
			5'd8://deliver inst init
			begin
				flashCs = 1'b0;
				if(flashReady)
				begin
					dataSize = flashData;
					preflashAddr = 4;
					if(instSize == 0)
					begin
						DeliverState = 5'd13;//TODO
					end else begin
						DeliverState = 5'd9;
						instCount = 0;
					end
				end
			end
			5'd9://read inst from flash
			begin
				sramCs = 1'b0;
				if(sramReady)
				begin
					DeliverState = 5'd10;
					flashAddr = preflashAddr + instCount[24:0];
					flashCs = 1'b1;
				end
			end
            5'd10://wait a timer
            begin
                DeliverState = 5'd11;
            end
			5'd11://write inst to sram
			begin
				flashCs = 1'b0;
				if(flashReady)
				begin
					sramCs = 1'b1;
					sramData = flashData;
					sramAddr = instAddr + instCount[21:0];
					instCount = instCount + 1'b1;
                    DeliverState = 5'd12;
				end
			end
            5'd12://wait a timer
            begin
                if(instCount == instSize)
					DeliverState = 5'd13;
				else
					DeliverState = 5'd9;
            end
			5'd13://deliver data init
			begin
				sramCs = 1'b0;
				flashCs = 1'b0;
				if (flashReady)
				begin
					if (dataSize == 0)
					begin
						DeliverState = 5'd18;//TODO
					end else begin
						DeliverState = 5'd14;
						preflashAddr = preflashAddr + instSize[24:0];
						dataCount = 0;
					end
				end
			end
			5'd14://read data from flash
			begin
				sramCs = 1'b0;
				if(sramReady)
				begin
					DeliverState = 5'd15;
					flashAddr = preflashAddr + dataCount[24:0];
					flashCs = 1'b1;
				end
			end
            5'd15://wait a timer
            begin
                DeliverState = 5'd16;
            end
			5'd16://write data ot sram
			begin
				flashCs = 1'b0;
				if(flashReady)
				begin
					sramCs = 1'b1;
					sramData = flashData;
					sramAddr = dataAddr + dataCount[21:0];
					dataCount = dataCount + 1'b1;
                    DeliverState = 5'd17;
				end
			end
            5'd17://wait a timer
            begin
                if(dataCount == dataSize)
					DeliverState = 5'd18;
				else
					DeliverState = 5'd14;
            end
			5'd18://end
			begin
				//led on
				led = 1'b0;
			end
			endcase
            
		end
	end
endmodule
