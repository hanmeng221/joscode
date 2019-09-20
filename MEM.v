`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:52:23 09/17/2019 
// Design Name: 
// Module Name:    MEM 
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
module MEM(
    output flash_cen,
    output flash_resetn,
    output flash_oen,
    output flash_wen,
    output flash_byten,
    output [24:0] flash_a,
    inout [31:0] flash_dq,
    input flash_rdybsyn,
    output sram_clk,
    output sram_cen,
    output sram_advn,
    output sram_oen,
    output sram_wen,
    output sram_psn,
    output [21:0] sram_a,
    inout [31:0] sram_dq,
    output [7:0] sram_ben,
    input sram_waitn,
    input clk_in,
    input rst_in,
    input [21:0] dm_addr,
    input dm_work,
    input dm_we,
    input [3:0] be_in,
    input [31:0] dm_datain,
    output [31:0] dm_dataout,
    input im_work,
    input [21:0] im_addr,
    output [31:0] im_dataout,
    input boot,
    output start,
    input uart_rxd,
    output uart_txd,
	 output en
    );

//TODO dm_we mem_sram_rw
wire               mem_flash_cs;
wire               mem_flash_rw;
wire  [25-1:0]     mem_flash_addr;
wire  [32-1:0]     mem_flash_data_wr;
wire  [32-1:0]     mem_flash_data_rd;
wire               mem_flash_done;
  
  // sram if to cpu
wire               mem_sram_cs;
wire               mem_sram_rw;
wire [22-1:0]      mem_sram_addr;
wire [32-1:0]      mem_sram_data_wr;
wire [32-1:0]     mem_sram_data_rd;
wire              mem_sram_done;
  
assign mem_flash_rw = 1'b1;//read
assign mem_flash_data_wr = 32'b0;

wire memcs;
wire [21:0] memaddr;
wire [31:0] memdatawrite;
wire [31:0] memdataread = mem_sram_data_rd;
wire memdone = mem_sram_done;
wire deliver_memcs;

wire memrw; 
wire [21:0] deliver_mem_sram_addr;
wire [31:0] deliver_mem_sram_data_wr;

wire [3:0] sram_bin;

wire im_cs;
wire dm_cs;

deliver the_deliver(clk_in,rst_in,boot,mem_flash_done,mem_flash_data_rd,mem_flash_addr,mem_flash_cs,mem_sram_done,deliver_mem_sram_data_wr,deliver_mem_sram_addr,deliver_memcs,start);

double_if the_double_if(
	 clk_in,rst_in,
    im_addr,im_dataout,32'b0,im_work,1'b1,4'b1111,//1'b1 means read ?
    dm_addr,dm_dataout,dm_datain,dm_work,dm_we,be_in,
    memaddr,mem_sram_data_rd,memdatawrite,memcs,memrw,sram_bin,mem_sram_done,
    en);
	 
	 
Justdgement the_Justdgement(
//signal
	start,
//deliver
	deliver_mem_sram_addr,deliver_mem_sram_data_wr,deliver_memcs,1'b0,
//double
	memaddr,memdatawrite,memcs,memrw,
//mem_if
	mem_sram_addr,mem_sram_data_wr,mem_sram_cs,mem_sram_rw
);
mem_if the_mem_if(/*AUTOARG*/
  // Outputs
  uart_txd, mem_flash_data_rd, mem_flash_done, mem_sram_data_rd,
  mem_sram_done, flash_cen, flash_resetn, flash_oen, flash_wen,
  flash_byten, flash_a, sram_clk, sram_cen, sram_advn, sram_oen,
  sram_wen, sram_psn, sram_a, sram_ben,
  // Inouts
  flash_dq, sram_dq,
  // Inputs
  clk_in, ~rst_in, uart_rxd, mem_flash_cs, mem_flash_rw,
  mem_flash_addr, mem_flash_data_wr, mem_sram_cs, mem_sram_rw,
  mem_sram_addr, mem_sram_data_wr, flash_rdybsyn, sram_waitn
  );

endmodule
