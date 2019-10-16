
`timescale 1ns/1ps


module uart_usrapp (/*AUTOARG*/
  // Outputs
  mpi_cs, mpi_wren, mpi_rden, mpi_addr, mpi_data_wr, usr_start_tx,
  usr_data_tx,
  // Inputs
  clk, rst, mpi_rd_rdy, mpi_data_rd, usr_done_tx, usr_done_rx,
  usr_data_rx
  );


`include "../top/param_mem_if.vh"

  
  input              clk;
  input              rst;

  // mpi if
  output             mpi_cs;
  output             mpi_wren;
  output             mpi_rden;
  output [14:0]      mpi_addr;
  output [63:0]      mpi_data_wr;

  input              mpi_rd_rdy;
  input [63:0]       mpi_data_rd;
  
  

  // uart controller if
  // tx
  output             usr_start_tx; // start to uart tx, active 1
  output [7:0]       usr_data_tx; // data for tx
  input              usr_done_tx; // uart tx completed, active 1
  
  // rx
  input              usr_done_rx; // uart tx completed, active 1
  input [7:0]        usr_data_rx;      // data received from mdio device

  
  

  
  /*AUTOREG*/
  // Beginning of automatic regs (for this module's undeclared outputs)
  reg [14:0]            mpi_addr;
  reg                   mpi_cs;
  reg [63:0]            mpi_data_wr;
  reg                   mpi_rden;
  reg                   mpi_wren;
  // End of automatics


  reg                mpi_uart_start_pos;
  reg [2:0]          mpi_uart_start_shift;

  reg [7:0]          data_rx_cnt;
  reg [7:0]          data_tx_cnt;

  reg [7:0]          data_rx_check_cal;
  wire [7:0]         data_tx_check_cal;
  reg                data_rx_check_ok;

  reg [87:0]         data_rx_shift;
  reg [95:0]         data_tx_shift;
  
  reg                uart_timeout;
  reg [31:0]         uart_timeout_cnt;

  reg                usr_done_tx_dly;
  wire               usr_done_tx_pos;


  
  reg [3:0]          n_state_rx;
  reg [3:0]          c_state_rx;
  
  localparam S_IDLE_RX = 0;
  localparam S_DATA_RX = 1;
  localparam S_DATA_CHECK_RX  = 2;
  localparam S_DATA_DECODE_RX = 3;


  
  reg [3:0]          n_state_tx;
  reg [3:0]          c_state_tx;
  
  localparam S_IDLE_TX = 0;
  localparam S_DATA_TX = 1;


  
  assign usr_data_tx = data_tx_shift[95:88];


  
  always @ ( * ) begin : N_STATE_RX
    case ( c_state_rx )
      S_IDLE_RX : begin
        if (( usr_data_rx == 8'hf6 ) && usr_done_rx ) begin
          n_state_rx = S_DATA_RX;
        end else begin
          n_state_rx = S_IDLE_RX;
        end // else: !if( usr_data_rx == 8'hf6 )
      end // case: S_IDLE_RX
      
      S_DATA_RX : begin
        if (( data_rx_cnt >= 10 ) && usr_done_rx )begin
          n_state_rx = S_DATA_CHECK_RX;
        end else begin
          n_state_rx = S_DATA_RX;
        end // else: !if( data_rx_cnt >= 12 )
      end // case: S_DATA_RX
      
      S_DATA_CHECK_RX : begin
        if ( data_rx_check_ok ) begin
          n_state_rx = S_DATA_DECODE_RX;
        end else begin
          n_state_rx = S_IDLE_RX;
        end // else: !if( data_rx_check_ok )
      end // case: S_DATA_CHECK_RX

      S_DATA_DECODE_RX : begin
        n_state_rx = S_IDLE_RX;
      end // case: S_DATA_DECODE_RX
      
      
      default : begin
        n_state_rx = S_IDLE_RX;
      end
    endcase // case ( c_state_rx )
  end // block: N_STATE_RX
  

  always @ ( posedge clk or posedge rst ) begin : C_STATE_RX
    if ( rst ) begin
      /*AUTORESET*/
      // Beginning of autoreset for uninitialized flops
      c_state_rx <= 4'h0;
      // End of automatics
    end else begin
      if ( uart_timeout ) begin
        c_state_rx <= S_IDLE_RX;
      end else begin
        c_state_rx <= n_state_rx;
      end
      
    end // else: !if( rst )
  end // block: C_STATE_RX
  


  always @ ( posedge clk or posedge rst ) begin : S_DATA_RX_CNT
    if ( rst ) begin
      /*AUTORESET*/
      // Beginning of autoreset for uninitialized flops
      data_rx_cnt <= 8'h0;
      // End of automatics
    end
    else begin
      if ( c_state_rx == S_IDLE_RX ) begin
        data_rx_cnt <= 0;
      end else if ( usr_done_rx ) begin
        data_rx_cnt <= data_rx_cnt + 1;
      end
    end // else: !if( rst )
  end // block: S_DATA_RX_CNT
  

  always @ ( posedge clk or posedge rst ) begin : DATA_RX_CHECK_OK
    if ( rst ) begin
      data_rx_check_cal <= 8'hf6;
      /*AUTORESET*/
      // Beginning of autoreset for uninitialized flops
      data_rx_check_ok <= 1'h0;
      // End of automatics
    end
    else begin
      if ( c_state_rx == S_IDLE_RX ) begin
        data_rx_check_cal <= 8'hf6;
      end
      else if ( usr_done_rx ) begin
        data_rx_check_cal <= data_rx_check_cal ^ usr_data_rx;
      end

      data_rx_check_ok <= ( data_rx_check_cal == usr_data_rx );
      
    end // else: !if( rst )
  end // block: DATA_RX_CHECK_CAL
  
  
  always @ ( posedge clk or posedge rst ) begin : DATA_RX_SHIFT
    if ( rst ) begin
      /*AUTORESET*/
      // Beginning of autoreset for uninitialized flops
      data_rx_shift <= 88'h0;
      // End of automatics
    end
    else begin
      if (( c_state_rx == S_DATA_RX ) && usr_done_rx ) begin
        data_rx_shift <= { data_rx_shift[79:0], usr_data_rx };
      end
    end // else: !if( rst )
  end // block: DATA_RX_SHIFT
  

  always @ ( posedge clk or posedge rst ) begin : MPI_IF_OUT
    if ( rst ) begin
      /*AUTORESET*/
      // Beginning of autoreset for uninitialized flops
      mpi_addr <= 15'h0;
      mpi_cs <= 1'h0;
      mpi_data_wr <= 64'h0;
      mpi_rden <= 1'h0;
      mpi_wren <= 1'h0;
      // End of automatics
    end
    else begin
      if ( c_state_rx == S_DATA_DECODE_RX ) begin
        mpi_cs <= 1;
        mpi_wren <= ~data_rx_shift[87];
        mpi_rden <= data_rx_shift[87];
        mpi_addr <= data_rx_shift[86:72];
        mpi_data_wr <= data_rx_shift[71:8];
      end else begin
        mpi_cs <= 0;
      end // else: !if( c_state_rx == S_DATA_DECODE_RX )
    end // else: !if( rst )
  end // block: MPI_IF_OUT
  

  always @ ( posedge clk or posedge rst ) begin : UART_TIMEOUT
    if ( rst ) begin
      /*AUTORESET*/
      // Beginning of autoreset for uninitialized flops
      uart_timeout <= 1'h0;
      uart_timeout_cnt <= 32'h0;
      // End of automatics
    end
    else begin
      if ( c_state_rx == S_IDLE_RX ) begin
        uart_timeout_cnt <= 0;
      end
      else if ( uart_timeout_cnt < UART_TIMEOUT_VAL ) begin
        uart_timeout_cnt <= uart_timeout_cnt + 1;
      end // else: !if( c_state_rx == S_IDLE_RX )
      
      uart_timeout <= uart_timeout_cnt >= UART_TIMEOUT_VAL;
      
    end // else: !if( rst )
  end // block: UART_TIMEOUT

  
  // tx
  always @ ( * ) begin : N_STATE_TX
    case ( c_state_tx )
      S_IDLE_TX : begin
        if (mpi_rd_rdy && usr_done_tx) begin
          n_state_tx = S_DATA_TX;
        end else begin
          n_state_tx = S_IDLE_TX;
        end
      end // case: S_IDLE_TX

      S_DATA_TX : begin
        if ( data_tx_cnt >= 11 ) begin
          n_state_tx = S_IDLE_TX;
        end else begin
          n_state_tx = S_DATA_TX;
        end // else: !if( data_tx_cnt >= 9 )
      end // case: DATA_TX
      
      default : begin
        n_state_tx = S_IDLE_TX;
      end
    endcase // case ( c_state_tx )
  end // block: N_STATE_TX
  

  always @ ( posedge clk or posedge rst ) begin : C_STATE_TX
    if ( rst ) begin
      /*AUTORESET*/
      // Beginning of autoreset for uninitialized flops
      c_state_tx <= 4'h0;
      // End of automatics
    end else begin
      if ( uart_timeout ) begin
        c_state_tx <= S_IDLE_TX;
      end else begin
        c_state_tx <= n_state_tx;
      end
      
    end // else: !if( rst )
  end // block: C_STATE_TX
  
  always @ ( posedge clk or posedge rst ) begin : USR_DONE_TX_POS
    if ( rst ) begin
      /*AUTORESET*/
      // Beginning of autoreset for uninitialized flops
      usr_done_tx_dly <= 1'h0;
      // End of automatics
    end else begin
      usr_done_tx_dly <= usr_done_tx;
    end // else: !if( rst )
  end // block: USR_DONE_TX_POS

  assign usr_done_tx_pos = ( ~usr_done_tx_dly ) & usr_done_tx;

  always @ ( posedge clk or posedge rst ) begin : DATA_TX_CNT
    if ( rst ) begin
      /*AUTORESET*/
      // Beginning of autoreset for uninitialized flops
      data_tx_cnt <= 8'h0;
      // End of automatics
    end
    else begin
      if ( c_state_tx == S_IDLE_TX ) begin
        data_tx_cnt <= 0;
      end else if ( usr_done_tx_pos && ( c_state_tx == S_DATA_TX )) begin
        data_tx_cnt <= data_tx_cnt + 1;
      end

    end // else: !if( rst )
  end // block: DATA_TX_CNT


  assign data_tx_check_cal = { 8'hf6 ^ 
                               { mpi_rden, mpi_addr[14:8] } ^ 
                               mpi_addr[7:0] ^ 
                               mpi_data_rd[63:56] ^
                               mpi_data_rd[55:48] ^
                               mpi_data_rd[47:40] ^
                               mpi_data_rd[39:32] ^
                               mpi_data_rd[31:24] ^
                               mpi_data_rd[23:16] ^
                               mpi_data_rd[15:08] ^
                               mpi_data_rd[07:00] };
  
  
  always @ ( posedge clk or posedge rst ) begin : DATA_TX_SHIFT
    if ( rst ) begin
      /*AUTORESET*/
      // Beginning of autoreset for uninitialized flops
      data_tx_shift <= 96'h0;
      // End of automatics
    end
    else begin
      if ( mpi_rd_rdy ) begin
        data_tx_shift <= { 8'hf6,
                           { mpi_rden, mpi_addr[14:8] },
                           mpi_addr[7:0],
                           mpi_data_rd,
                           data_tx_check_cal 
                           };
      end
      else if ( usr_done_tx_pos && ( c_state_tx == S_DATA_TX )) begin
        data_tx_shift <= { data_tx_shift[95:0], 8'h0 };
      end

    end // else: !if( rst )
  end // block: DATA_TX_SHIFT

  assign usr_start_tx = mpi_rd_rdy | (usr_done_tx_pos & (c_state_tx == S_DATA_TX));
  
  
  
  

  
endmodule // uart_usrapp_exp
