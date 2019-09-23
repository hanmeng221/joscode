
module PC(clk, next_pc, pc_wr, pc_out, reset, pc_work,pc_en,os);
   input clk;
	input [31:2] next_pc;
	input reset;
	input pc_wr;
	output [31:2] pc_out;
   output pc_work;
   input pc_en;
	input os;
	reg [31:2] pc_out;
	reg pc_work;
	
	initial pc_work = 1'b0;
	always@(posedge clk)
	begin
	    if(reset)
       begin
		    pc_out <= 30'hbff ;
			 pc_work <= 1'b0;
       end else if (os == 1'b0)
		 begin
			pc_out <= 30'hbff;
			pc_work <= 1'b0;
		 end else if(pc_wr & pc_en)
       begin
		    pc_out <= next_pc;
          pc_work <= 1'b1;
		 end else begin
			pc_work <= 1'b0;
		 end
	end

endmodule
