//-----------------------------------------------------------------------------
// Title         : devb_exp_top
// Project       : devb
//-----------------------------------------------------------------------------
// File          : devb_exp_top.v
// Author        : 
// Created       : 03.01.2015
// Last modified : 03.01.2015
//-----------------------------------------------------------------------------
// Description :
// 
//
//-----------------------------------------------------------------------------
// Copyright (c) 2015 by  This model is the confidential and
// proprietary property of  and the possession or use of this
// file requires a written license from .
//-----------------------------------------------------------------------------
// Modification history :
// 03.01.2015 : created
//-----------------------------------------------------------------------------



module mem_if (/*AUTOARG*/
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


  
`include "./param_mem_if.vh"

  
  // clock 
  input               clk_in;
  input               rst_in;

  
  // uart if
  input               uart_rxd;
  output              uart_txd;

  // flash if to cpu
  input               mem_flash_cs;
  input               mem_flash_rw;
  input [25-1:0]      mem_flash_addr;
  input [32-1:0]      mem_flash_data_wr;
  output [32-1:0]     mem_flash_data_rd;
  output              mem_flash_done;
  
  // sram if to cpu
  input               mem_sram_cs;
  input               mem_sram_rw;
  input [22-1:0]      mem_sram_addr;
  input [32-1:0]      mem_sram_data_wr;
  output [32-1:0]     mem_sram_data_rd;
  output              mem_sram_done;
  


  //flash if
  output              flash_cen;
  output              flash_resetn;
  output              flash_oen;
  output              flash_wen;
  output              flash_byten;
  output [24:0]       flash_a;
  inout [31:0]        flash_dq; 
  input               flash_rdybsyn;

  // sram if
  output              sram_clk;                
  output              sram_cen;      
  output              sram_advn;      
  output              sram_oen;      
  output              sram_wen;      
  output              sram_psn;      
  output [21:0]       sram_a;                
  inout [31:0]        sram_dq;    
  output [7:0]        sram_ben; // LB,UB
  input               sram_waitn;     


/* -----\/----- EXCLUDED -----\/-----
  //SD card
  output               sdcard_clk;
  output               sdcard_wp;      
  output               sdcard_cd;      
  output               sdcard_cmd;     
  output [3:0]         sdcard_data; 
 -----/\----- EXCLUDED -----/\----- */
  
  

  
  /*AUTOWIRE*/
  // Beginning of automatic wires (for undeclared instantiated-module outputs)
  wire [14:0]           mpi_addr;               // From u_uart_top of uart_top.v
  wire                  mpi_cs;                 // From u_uart_top of uart_top.v
  wire [63:0]           mpi_data_rd;            // From u_mpi_top of mpi_top.v
  wire [63:0]           mpi_data_wr;            // From u_uart_top of uart_top.v
  wire [24:0]           mpi_flash_addr;         // From u_mpi_top of mpi_top.v
  wire                  mpi_flash_chip_rst;     // From u_mpi_top of mpi_top.v
  wire                  mpi_flash_cmd;          // From u_mpi_top of mpi_top.v
  wire [31:0]           mpi_flash_data_wr;      // From u_mpi_top of mpi_top.v
  wire                  mpi_flash_done;         // From u_flash_ctrl of mem_ctrl.v
  wire                  mpi_flash_start;        // From u_mpi_top of mpi_top.v
  wire                  mpi_mem_local_ctrl_en;  // From u_mpi_top of mpi_top.v
  wire                  mpi_rd_rdy;             // From u_mpi_top of mpi_top.v
  wire                  mpi_rden;               // From u_uart_top of uart_top.v
  wire [21:0]           mpi_sram_addr;          // From u_mpi_top of mpi_top.v
  wire                  mpi_sram_cmd;           // From u_mpi_top of mpi_top.v
  wire [31:0]           mpi_sram_data_wr;       // From u_mpi_top of mpi_top.v
  wire                  mpi_sram_done;          // From u_sram_ctrl of mem_ctrl.v
  wire                  mpi_sram_start;         // From u_mpi_top of mpi_top.v
  wire                  mpi_wren;               // From u_uart_top of uart_top.v
  // End of automatics

  wire                  rst;


  wire                  flash_wren   ;
  wire                  flash_rden   ;
  wire [24:0]           flash_addr   ;
  wire [31:0]           flash_data_wr;
  
  
  wire                  sram_wren   ;
  wire                  sram_rden   ;
  wire [21:0]           sram_addr   ;
  wire [31:0]           sram_data_wr;


  
  // for test
  //  assign uart_txd = uart_rxd;
  
  assign rst = ~rst_in;


  
  
  uart_top u_uart_top
    (
     // Inputs
     .clk                               (clk_in),
     // Outputs
     //.uart_txd                          (),
     
     /*AUTOINST*/
     // Outputs
     .mpi_cs                            (mpi_cs),
     .mpi_wren                          (mpi_wren),
     .mpi_rden                          (mpi_rden),
     .mpi_addr                          (mpi_addr[14:0]),
     .mpi_data_wr                       (mpi_data_wr[63:0]),
     .uart_txd                          (uart_txd),
     // Inputs
     .rst                               (rst),
     .mpi_rd_rdy                        (mpi_rd_rdy),
     .mpi_data_rd                       (mpi_data_rd[63:0]),
     .uart_rxd                          (uart_rxd));
  
  mpi_top u_mpi_top
    (
     // Inputs
     .rst_mpi                           (rst),
     .clk_mpi                           (clk_in),

     .mpi_flash_data_rd                 (mem_flash_data_rd[31:0]),
     .mpi_sram_data_rd                  (mem_sram_data_rd[31:0]),

     /*AUTOINST*/
     // Outputs
     .mpi_data_rd                       (mpi_data_rd[63:0]),
     .mpi_rd_rdy                        (mpi_rd_rdy),
     .mpi_mem_local_ctrl_en             (mpi_mem_local_ctrl_en),
     .mpi_flash_addr                    (mpi_flash_addr[24:0]),
     .mpi_flash_start                   (mpi_flash_start),
     .mpi_flash_chip_rst                (mpi_flash_chip_rst),
     .mpi_flash_cmd                     (mpi_flash_cmd),
     .mpi_flash_data_wr                 (mpi_flash_data_wr[31:0]),
     .mpi_sram_addr                     (mpi_sram_addr[21:0]),
     .mpi_sram_start                    (mpi_sram_start),
     .mpi_sram_cmd                      (mpi_sram_cmd),
     .mpi_sram_data_wr                  (mpi_sram_data_wr[31:0]),
     // Inputs
     .mpi_cs                            (mpi_cs),
     .mpi_wren                          (mpi_wren),
     .mpi_rden                          (mpi_rden),
     .mpi_addr                          (mpi_addr[14:0]),
     .mpi_data_wr                       (mpi_data_wr[63:0]),
     .mpi_flash_done                    (mpi_flash_done),
     .mpi_flash_rdybsyn                 (mpi_flash_rdybsyn),
     .mpi_sram_done                     (mpi_sram_done),
     .mpi_sram_waitn                    (mpi_sram_waitn));



  assign flash_cs      = mpi_mem_local_ctrl_en ? mpi_flash_start : mem_flash_cs;
  assign flash_rw      = mpi_mem_local_ctrl_en ? mpi_flash_cmd   : mem_flash_rw;
  assign flash_addr    = mpi_mem_local_ctrl_en ? mpi_flash_addr[25-1:0]    : mem_flash_addr[25-1:0];
  assign flash_data_wr = mpi_mem_local_ctrl_en ? mpi_flash_data_wr[32-1:0] : mem_flash_data_wr[32-1:0];

  assign sram_cs      = mpi_mem_local_ctrl_en ? mpi_sram_start : mem_sram_cs;
  assign sram_rw      = mpi_mem_local_ctrl_en ? mpi_sram_cmd   : mem_sram_rw;
  assign sram_addr    = mpi_mem_local_ctrl_en ? mpi_sram_addr[22-1:0]    : mem_sram_addr[22-1:0];
  assign sram_data_wr = mpi_mem_local_ctrl_en ? mpi_sram_data_wr[32-1:0] : mem_sram_data_wr[32-1:0];
     
     
     
     
  assign flash_byten = 'h0;
  assign flash_resetn = mpi_flash_chip_rst;
  assign mpi_flash_rdybsyn = flash_rdybsyn;
  assign mem_flash_done = mpi_flash_done;

  
  assign sram_clk = 'h0;                
  assign sram_advn = 'h0;      
  assign sram_psn  = 'h0;  // cre
  assign sram_ben  = 'h0; // LB,UB
  assign mpi_sram_waitn = sram_waitn;     
  assign mem_sram_done = mpi_sram_done;

  mem_ctrl # 
    (
     // Parameters
     .ADDR_BW                  (25),
     .DATA_BW                  (32),
     .CLK_FREQ                 (25000000), // Hz
     .OPT_WAIT_TIME_NS         (120) // ns
     )
  u_flash_ctrl
    (
     // Outputs
     .mpi_mem_data_rd                   (mem_flash_data_rd[32-1:0]),
     .mpi_mem_done                      (mpi_flash_done),
     .mem_cen                           (flash_cen),
     .mem_oen                           (flash_oen),
     .mem_wen                           (flash_wen),
     .mem_a                             (flash_a[25-1:0]),
     // Inouts
     .mem_dq                            (flash_dq[32-1:0]),
     // Inputs
     .clk                               (clk_in),
     .rst                               (rst),
     .mpi_mem_cs                        (flash_cs),
     .mpi_mem_rw                        (flash_rw),
     .mpi_mem_addr                      (flash_addr[25-1:0]),
     .mpi_mem_data_wr                   (flash_data_wr[32-1:0])
     /*AUTOINST*/);



  mem_ctrl # 
    (
     // Parameters
     .ADDR_BW                  (22),
     .DATA_BW                  (32),
     .CLK_FREQ                 (25000000), // Hz
     .OPT_WAIT_TIME_NS         (70) // ns
     )
  u_sram_ctrl
    (
     // Outputs
     .mpi_mem_data_rd                   (mem_sram_data_rd[32-1:0]),
     .mpi_mem_done                      (mpi_sram_done),
     .mem_cen                           (sram_cen),
     .mem_oen                           (sram_oen),
     .mem_wen                           (sram_wen),
     .mem_a                             (sram_a[21:0]),
     // Inouts
     .mem_dq                            (sram_dq[32-1:0]),
     // Inputs
     .clk                               (clk_in),
     .rst                               (rst),
     .mpi_mem_cs                        (sram_cs),
     .mpi_mem_rw                        (sram_rw),
     .mpi_mem_addr                      (sram_addr[21:0]),
     .mpi_mem_data_wr                   (sram_data_wr[32-1:0])
     /*AUTOINST*/);


  
endmodule // mem_if





// Local Variables:
// verilog-library-directories:(".""../uart")
// End:

