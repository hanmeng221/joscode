`include "public.v"

module testbench();
	reg clk, reset;
	reg [31:0] din;
	wire [4:1] sel1,sel2;
	wire [7:0] dout1,dout2;
	wire TxD1;
	mini_machine U_MINI_MACHINE(clk, reset, din, dout1, dout2, sel1, sel2, TxD1);
	//mips the_mips(clk, ~reset, CPUAddr, BE, CPUIn, CPUOut, IOWe, clk_out, HardInt_in);
	
	initial 
	begin
	    clk=0;
		reset=1;
		din = 0;
		#10 reset=0;
		#70 reset=1;
		//$readmemh("..\\code.txt", U_MINI_MACHINE.U_MIPS.the_IM.im);
		//$readmemh("..\\code_handler.txt", U_MINI_MACHINE.U_MIPS.the_IM.im, 1120); 
		//1120: 4180h >>2 - C00(3000>>2) and then to decimal
		//$display(U_MINI_MACHINE.U_MIPS.the_IM.im[0]);
		//$display(U_MINI_MACHINE.U_MIPS.the_IM.im[1120]);
		//$display(U_MINI_MACHINE.U_MIPS.pc_out);
		
		//#1000 din = 12345;
	
	end
	
	always
	begin
	    #(2) clk = ~clk;	
	end
	//always
		//#(1000) din = din+1;
endmodule







