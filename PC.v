
module PC(clk, next_pc, pc_wr, pc_out, reset, pc_work,pc_en);
    input clk;
	input [31:2] next_pc;
	input reset;
	input pc_wr;
	output [31:2] pc_out;
    output pc_work;
    input pc_en;
	reg [31:2] pc_out;
	reg pc_work;
	always@(posedge clk)
	begin
	    if(reset)
        begin
		    pc_out <= 30'h8000_fff0 >>2 ;
            pc_work <= 1'b0;
        end
			//pc_out <= 30'h8000_0000 >>2 ;
		else if(pc_wr & pc_en)
        begin
		    pc_out <= next_pc;
            pc_work <= ~ pc_work;
		end
	end

endmodule
