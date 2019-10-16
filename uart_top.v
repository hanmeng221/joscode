
module uart_top (/*AUTOARG*/
  // Outputs
  mpi_cs, mpi_wren, mpi_rden, mpi_addr, mpi_data_wr, uart_txd,
  // Inputs
  clk, rst, mpi_rd_rdy, mpi_data_rd, uart_rxd
  );


`include "../top/param_mem_if.vh"
  


  input         clk;
  input         rst;

  // mpi if
  output        mpi_cs;
  output        mpi_wren;
  output        mpi_rden;
  output [14:0] mpi_addr;
  output [63:0] mpi_data_wr;

  input         mpi_rd_rdy;
  input [63:0]  mpi_data_rd;
  
  
  // uart if
  input         uart_rxd;
  output        uart_txd;
  



  
  /*AUTOWIRE*/
  // Beginning of automatic wires (for undeclared instantiated-module outputs)
  wire [7:0]            usr_data_rx;            // From u_uart_ctrl of uart_ctrl.v
  wire [7:0]            usr_data_tx;            // From u_uart_usrapp of uart_usrapp.v
  wire                  usr_done_rx;            // From u_uart_ctrl of uart_ctrl.v
  wire                  usr_done_tx;            // From u_uart_ctrl of uart_ctrl.v
  wire                  usr_start_tx;           // From u_uart_usrapp of uart_usrapp.v
  // End of automatics



  uart_ctrl u_uart_ctrl
    (
     // Inputs
     .mpi_uart_data_bw                  ('d8),
     .mpi_uart_clk_div                  (UART_BAUD_RATE),
     .mpi_uart_parity                   ('d0),
     .mpi_uart_stop_bit                 ('d0),
     .mpi_uart_en                       ('h1),

     /*AUTOINST*/
     // Outputs
     .usr_done_tx                       (usr_done_tx),
     .usr_done_rx                       (usr_done_rx),
     .usr_data_rx                       (usr_data_rx[8-1:0]),
     .uart_txd                          (uart_txd),
     // Inputs
     .clk                               (clk),
     .rst                               (rst),
     .usr_start_tx                      (usr_start_tx),
     .usr_data_tx                       (usr_data_tx[8-1:0]),
     .uart_rxd                          (uart_rxd));


  uart_usrapp u_uart_usrapp
    (/*AUTOINST*/
     // Outputs
     .mpi_cs                            (mpi_cs),
     .mpi_wren                          (mpi_wren),
     .mpi_rden                          (mpi_rden),
     .mpi_addr                          (mpi_addr[14:0]),
     .mpi_data_wr                       (mpi_data_wr[63:0]),
     .usr_start_tx                      (usr_start_tx),
     .usr_data_tx                       (usr_data_tx[7:0]),
     // Inputs
     .clk                               (clk),
     .rst                               (rst),
     .mpi_rd_rdy                        (mpi_rd_rdy),
     .mpi_data_rd                       (mpi_data_rd[63:0]),
     .usr_done_tx                       (usr_done_tx),
     .usr_done_rx                       (usr_done_rx),
     .usr_data_rx                       (usr_data_rx[7:0]));



  

endmodule // uart_top_exp
