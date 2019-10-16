
module Bridge(CPU_addr, CPU_din, CPUWe, CPU_be, CPU_dout, deviceCounter_din, 
			deviceSwitch_din, device_addr, device_dout, weCounter, weNumber, weUART, device_BE, CPUPC, DigitNumber);
    input [31:2] CPU_addr;
	input [31:0] CPU_din;
	input CPUWe;
	input [3:0] CPU_be;
	output [31:0] CPU_dout;
	
	input [31:0] deviceCounter_din;
	input [31:0] deviceSwitch_din;
	output [3:2] device_addr;
	output [31:0] device_dout;
	output [3:0] device_BE;
	output weCounter;
	output weNumber;
	output weUART;
	
	input [31:2] CPUPC;
	output [31:0] DigitNumber;
	
	wire hitCounter;
	wire hitNumber;
	wire hitSwitch;
	wire hitUART;
	
	assign device_addr = CPU_addr[3:2];
	assign device_dout = CPU_din;
	assign device_BE = CPU_be;
	assign hitCounter = (CPU_addr[31:4] == 28'h00007F0) ? 1'b1:1'b0;
	assign hitSwitch = (CPU_addr[31:4] == 28'h00007F1) ? 1'b1:1'b0;
	assign hitNumber = (CPU_addr[31:4] == 28'h00007F2) ? 1'b1:1'b0;
	assign hitUART = (CPU_addr[31:4] == 28'h00007F3) ? 1'b1:1'b0;
	
	assign CPU_dout = (hitCounter) ? deviceCounter_din : 
						(hitSwitch) ? deviceSwitch_din :
						32'd0;
						
	assign weCounter = (hitCounter && CPUWe) ? 1'b1:1'b0;
	assign weNumber = (hitNumber && CPUWe) ? 1'b1:1'b0;
	assign weUART = (hitUART && CPUWe) ? 1'b1:1'b0;
	
	assign DigitNumber={CPUPC,2'b00};
	
	
endmodule






