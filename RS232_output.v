`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:50:46 03/11/2019 
// Design Name: 
// Module Name:    RS232_output 
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
///////uart ����ģ�飻
module  RS232_output (
        input    wire             i_clk            , //25MHZ;
        input    wire             i_rst_n          ,
        input    wire             i_send_en        , //�򿪷��ͣ�
        input    wire    [7:0]    i_data_i         ,
        output   wire             o_tx             ,
        output   wire             o_tx_done          //�������ָʾ��
);
/////////////////������ѡ��
//parameter [14:0] BPS_CNT_MAX = 25_000_000/9600;  //ʱ�Ӹ�����Ҫ�޸ģ�
parameter [14:0] BPS_CNT_MAX = 15'd2; //����ʹ��2�����̷���ʱ�䣻
reg r_i_send_en;
always @(posedge i_clk) begin
    r_i_send_en <= i_send_en;//�Ƴ�����"ͬ������"��˵��
end 
reg [7:0] tx_data;
always @(posedge i_clk or negedge i_rst_n) begin
    if (~i_rst_n) begin
        tx_data <= 0;
    end //if
    else begin
        if (i_send_en) begin
            tx_data <= i_data_i;
        end  
        else begin
            tx_data <= tx_data;  
        end  
    end //else
end //always
reg tx_en; //���������������ʹ�ܣ�
reg [14:0] bps_cnt;
reg [3:0] cnt;
always @(posedge i_clk or negedge i_rst_n) begin
    if (~i_rst_n) begin
        tx_en <= 0;
    end //if
    else begin
        if (r_i_send_en) begin
            tx_en <= 1'b1;
        end   
        else begin
            if ((cnt == 4'd10) && (bps_cnt == (BPS_CNT_MAX - 15'd1))) begin
                tx_en <= 1'b0;
            end
        end
    end //else
end //always
always @(posedge i_clk or negedge i_rst_n) begin
    if (~i_rst_n) begin
        bps_cnt <= 0;
    end //if
    else begin
        if (tx_en) begin
            if (bps_cnt == (BPS_CNT_MAX - 15'd1)) begin
                bps_cnt <= 0;
            end
            else begin
                bps_cnt <= bps_cnt + 15'd1;
            end
        end 
        else begin
            bps_cnt <= 0;  
        end   
    end //else
end //always
always @(posedge i_clk or negedge i_rst_n) begin
    if (~i_rst_n) begin
        cnt <= 0;
    end //if
    else begin
        if (tx_en) begin
            if (bps_cnt == (BPS_CNT_MAX - 15'd1)) begin
                cnt <= cnt + 4'd1; //bps���������ֵ��cnt��1��
            end
        end 
        else begin
            cnt <= 0;       
        end   
    end //else
end //always
reg tx_done;
reg tx;
always @(posedge i_clk) begin
    case (cnt)
        0 : begin tx <= 1'b1;tx_done <= 1'b0; end //txĬ��Ϊ�ߵ�ƽ��
        1 : begin tx <= 1'b0; end
        2 : begin tx <= tx_data[0]; end
        3 : begin tx <= tx_data[1]; end
        4 : begin tx <= tx_data[2]; end
        5 : begin tx <= tx_data[3]; end
        6 : begin tx <= tx_data[4]; end
        7 : begin tx <= tx_data[5]; end
        8 : begin tx <= tx_data[6]; end
        9 : begin tx <= tx_data[7]; end
        10: begin tx <= 1'b1;tx_done <= 1'b1;end //����tx�������������ָʾ�źţ�
        default:  begin tx <= 1'b1;tx_done <= 1'b0; end
    endcase //case
end //always
assign o_tx = tx;
assign o_tx_done = tx_done;

endmodule