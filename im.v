
module im_2m( clk, addr, dout ) ;
	input clk;
	input [20:2] addr ;  // address bus
	output [31:0] dout ;  // 32-bit memory output
	reg [31:0] im[1024:0] ;
	
	wire [20:2] pc_base = 19'h0080>>2; //3072:C00 -> decimal
	assign dout = im[addr[11:2]];
	//assign dout = im[addr-pc_base];
	//IM_4B2K im(~clk, addr - pc_base, dout);
	initial
		$readmemh("..\\code.txt", im);

endmodule
