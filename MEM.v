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
    input os,
    output start,
    input uart_rxd,
    output uart_txd
    );

//TODO dm_we mem_sram_rw

deliver the_deliver(clk_in,rst_in,boot,mem_flash_done,mem_flash_data_rd,mem_flash_addr,mem_flash_cs,mem_sram_done,mem_sram_data_wr,mem_sram_addr,mem_sram_cs,start);


mem_if the_mem_if(/*AUTOARG*/
  // Outputs
  uart_txd, mem_flash_data_rd, mem_flash_done, mem_sram_data_rd,
  mem_sram_done, flash_cen, flash_resetn, flash_oen, flash_wen,
  flash_byten, flash_a, sram_clk, sram_cen, sram_advn, sram_oen,
  sram_wen, sram_psn, sram_a, sram_ben,
  // Inouts
  flash_dq, sram_dq,
  // Inputs
  clk_in, rst_in, uart_rxd, mem_flash_cs, mem_flash_rw,
  mem_flash_addr, mem_flash_data_wr, mem_sram_cs, mem_sram_rw,
  mem_sram_addr, mem_sram_data_wr, flash_rdybsyn, sram_waitn
  );

endmodule
