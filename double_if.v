module double_if(
    input clk,
    input rst,
    input [21:0] addr1,
    output reg [31:0] data_rd1,
    input [31:0] data_wr1,
    input cs1,
    input we1,
	 input [3:0] data_bin1,
    input [21:0] addr2,
    output reg [31:0] data_rd2,
    input [31:0] data_wr2,
    input cs2,
    input we2,
	 input [3:0] data_bin2,
    output reg [21:0] sram_addr,
    input [31:0] sram_data_out,
    output reg [31:0] sram_data_write,
    output reg sram_cs,
    output reg sram_we,
	 output reg [3:0] sram_bin,
    input sram_ready,
    output reg data_ready
    );

    reg [2:0] pipe_state;
    reg [2:0] next_pipe_state;
    
    reg [21:0] temp_addr1;
    reg [21:0] temp_addr2;
    
    reg temp_we1;
    reg temp_we2;
    
    reg [31:0] temp_data_wr1;
    reg [31:0] temp_data_wr2;
    
    reg temp_cs1;
    reg temp_cs2;
	 
	 reg [3:0] temp_data_bin1;
	 reg [3:0] temp_data_bin2;
	 always @(posedge clk or negedge clk)
    begin
        if (rst)
        begin
            data_ready = 1'b1;
            sram_cs = 1'b0;
            sram_we = 1'b0;
            sram_addr = 22'b0;
				sram_bin = 4'b0;
            data_rd2 = 32'b0;
            data_rd1 = 32'b0;
            pipe_state = 3'b0;
            next_pipe_state = 3'b0;
            temp_addr1 = 22'b0;
            temp_addr2 = 22'b0;
            temp_we1 = 1'b0;
            temp_we2 = 1'b0;
            temp_data_wr1 = 32'b0;
            temp_data_wr2 = 32'b0;
            temp_cs1 = 1'b0;
            temp_cs2 = 1'b0;
				temp_data_bin1 = 4'b0;
				temp_data_bin2 = 4'b0;
        end else begin
            pipe_state = next_pipe_state;
            case (pipe_state)
            3'd0://init
            begin
                data_ready = 1'b1;
					 sram_cs = 1'b0;
                if(cs1 == 1'b1 || cs2 == 1'b1)//has job
                begin
                    temp_cs1 = cs1;
                    temp_cs2 = cs2;
                    next_pipe_state = 3'b1;
                    data_ready = 1'b0;
                    if(cs1 == 1'b1)
                    begin
                        temp_addr1 = addr1;
                        temp_we1 = we1;
                        temp_data_wr1 = data_wr1;
                        temp_data_bin1 = data_bin1;
                    end
                    if(cs2 == 1'b1)
                    begin
                        temp_addr2 = addr2;
                        temp_we2 = we2;
                        temp_data_wr2 = data_wr2;
								temp_data_bin2 = data_bin2;
                    end
                end
            end
            3'd1://deal with the job
            begin
                if(temp_cs1 == 1'b1)
                begin
                    if(sram_ready == 1'b1)
                    begin
                        sram_cs = 1'b1;
                        sram_addr = temp_addr1;
                        sram_data_write = temp_data_wr1;
                        sram_we = temp_we1;
								sram_bin = temp_data_bin1;
                        next_pipe_state = 3'd2;
                    end
                end else if(temp_cs2 == 1'b1)
                begin
                    if(sram_ready == 1'b1)
                    begin
                        sram_cs = 1'b1;
                        sram_addr = temp_addr2;
                        sram_data_write = temp_data_wr2;
                        sram_we = temp_we2;
								sram_bin = temp_data_bin2;
                        next_pipe_state = 3'd3;
                    end
                end
            end
            3'd2://wait a timer for sram
            begin
					if(sram_ready == 1'b0)
					begin
						next_pipe_state = 3'd4;
						sram_cs = 1'b0;
					end
            end
            3'd3://wait a timer for sram
            begin
					if(sram_ready == 1'b0)
					begin
						next_pipe_state = 3'd5;
						sram_cs = 1'b0;
					end
            end
            3'd4://wait sram ready
            begin
                if(sram_ready == 1'b1)//data ready
                begin
                    data_rd1 = sram_data_out;
                    temp_cs1 = 1'b0;
                    if(temp_cs2)
                    begin
                        next_pipe_state = 3'd1;
                    end else begin
                        next_pipe_state = 3'd0;
                    end
                end
            end
            3'd5://wait sram ready
            begin
                if(sram_ready == 1'b1)//data ready
                begin
                    data_rd2 = sram_data_out;
                    temp_cs2 = 1'b0;
                    if(temp_cs1)
                    begin
                        next_pipe_state = 3'd1;
                    end else begin
                        next_pipe_state = 3'd0;
                    end
                end
            end
            endcase
        end
    end

endmodule