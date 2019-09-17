
`timescale 1ns / 1ps


module uart_ctrl (/*AUTOARG*/
  // Outputs
  usr_done_tx, usr_done_rx, usr_data_rx, uart_txd,
  // Inputs
  clk, rst, mpi_uart_en, mpi_uart_data_bw, mpi_uart_clk_div,
  mpi_uart_parity, mpi_uart_stop_bit, usr_start_tx, usr_data_tx,
  uart_rxd
  );

  

  input                     clk;
  input                     rst;

  // mpi if
  input                     mpi_uart_en;
  // Number of bits per frame, 4-8 bits
  input [3:0]               mpi_uart_data_bw;
  // clock divider, it should be : CLK_FREQUENCY / UART_FREQUENCY
  input [31:0]              mpi_uart_clk_div;
  //Parity : 0-4 = None,Odd,Even,Mark,Space  
  input [3:0]               mpi_uart_parity;
  //StopBits : 0,1,2 = 1, 1.5, 2
  input [3:0]               mpi_uart_stop_bit;


  
  // user if
  // tx
  input                     usr_start_tx; // start to uart tx, active 1
  input [8-1:0]             usr_data_tx; // data for tx
  output                    usr_done_tx; // uart tx completed, active 1
  
  // rx
  output                    usr_done_rx; // uart tx completed, active 1
  output [8-1:0]            usr_data_rx; // data received from mdio device

  // physical if
  output                    uart_txd;
  input                     uart_rxd;

  

  /*AUTOREG*/
  // Beginning of automatic regs (for this module's undeclared outputs)
  reg [8-1:0]           usr_data_rx;
  reg                   usr_done_rx;
  // End of automatics

  
  (* IOB="true"*)reg                   uart_txd;
  (* IOB="true"*)reg                   uart_rxd_iob;

  
  reg                       uart_idle_tx;
  reg                       uart_idle_rx;
  
  reg [6:0]                 tx_data_shift;
  reg [7:0]                 rx_data_shift;

  reg                       tx_clk_pos;
  reg                       tx_clk_neg;
  reg                       rx_clk_pos;
  reg                       rx_clk_neg;
  
  reg [31:0]                tx_clk_cnt;
  reg [31:0]                rx_clk_cnt;
  
  reg [7:0]                 uart_rxd_dly;
  reg                       uart_start_rx;
  reg                       uart_rxd_sample;

  reg [3:0]                 uart_dataout_cnt;
  reg [3:0]                 uart_datain_cnt;

  reg                       uart_parity_tx;
  reg                       uart_parity_rx;
  reg                       usr_done_rx_tmp;

  
  localparam S_IDLE_TX    = 'd0;
  localparam S_START_TX   = 'd1;
  localparam S_DATAOUT_TX = 'd2;
  localparam S_PARITY_TX  = 'd3;
  localparam S_STOP0_TX   = 'd4;
  localparam S_STOP1_TX   = 'd5;

  reg [3:0]                 n_state_tx;
  reg [3:0]                 c_state_tx;
  
  localparam S_IDLE_RX    = 'd0;
  localparam S_START_RX   = 'd1;
  localparam S_DATAIN_RX  = 'd2;
  localparam S_PARITY_RX  = 'd3;
  localparam S_STOP0_RX   = 'd4;
  localparam S_STOP1_RX   = 'd5;

  reg [3:0]                 n_state_rx;
  reg [3:0]                 c_state_rx;

  
  // tx 

  assign usr_done_tx = uart_idle_tx;
  

  always @ (*) begin : N_STATE_TX
    case (c_state_tx)
      S_IDLE_TX : begin
        if (usr_start_tx && mpi_uart_en) begin
          n_state_tx = S_START_TX;
        end else begin
          n_state_tx = S_IDLE_TX;
        end
      end // case: S_IDLE_TX

      S_START_TX : begin
        if (tx_clk_neg) begin
          n_state_tx = S_DATAOUT_TX;
        end else begin
          n_state_tx = S_START_TX;
        end
      end // case: S_START_TX
      
      S_DATAOUT_TX : begin
        if (tx_clk_neg && (uart_dataout_cnt >= (mpi_uart_data_bw - 4'd1))) begin
          if (|mpi_uart_parity) begin
            n_state_tx = S_PARITY_TX;
          end else begin
            n_state_tx = S_STOP0_TX;
          end
        end else begin
          n_state_tx = S_DATAOUT_TX;
        end
      end // case: S_DATAOUT_TX
      
      S_PARITY_TX : begin
        if (tx_clk_neg) begin
          n_state_tx = S_STOP0_TX;
        end else begin
          n_state_tx = S_PARITY_TX;
        end
      end // case: S_PARITY_TX
      
      S_STOP0_TX : begin
        if (tx_clk_neg) begin
          if (mpi_uart_stop_bit == 'd0) begin
            n_state_tx = S_IDLE_TX;
          end else begin
            n_state_tx = S_STOP1_TX;
          end
        end else begin
          n_state_tx = S_STOP0_TX;
        end
      end // case: S_STOP0_TX
      
      S_STOP1_TX : begin
        if (mpi_uart_stop_bit == 'd1) begin
          if (tx_clk_pos) begin
            n_state_tx = S_IDLE_TX;
          end else begin
            n_state_tx = S_STOP1_TX;
          end
        end else begin
          if (tx_clk_neg) begin
            n_state_tx = S_IDLE_TX;
          end else begin
            n_state_tx = S_STOP1_TX;
          end
        end
      end // case: S_STOP1_TX

      default : n_state_tx = S_IDLE_TX;
    endcase // case (c_state_tx)
  end // block: N_STATE_TX
  
  always @ ( posedge clk or posedge rst ) begin : C_STATE_TX
    if ( rst ) begin
      /*AUTORESET*/
      // Beginning of autoreset for uninitialized flops
      c_state_tx <= 4'h0;
      // End of automatics
    end else begin
      c_state_tx <= n_state_tx;
    end
  end // block: C_STATE_TX
  
  always @ ( posedge clk or posedge rst ) begin : UART_IDLE_TX
    if ( rst ) begin
      uart_idle_tx <= 'h1;
      /*AUTORESET*/
    end else begin
      uart_idle_tx <= (c_state_tx == S_IDLE_TX);
    end // else: !if( rst )
  end // block: UART_IDLE_TX

  always @ ( posedge clk or posedge rst ) begin : TX_CLK_CNT
    if ( rst ) begin
      tx_clk_cnt <= 16'h1;
      /*AUTORESET*/
    end else begin
      if (usr_start_tx) begin
        tx_clk_cnt <= 1;
      end else if (!uart_idle_tx) begin
        if (tx_clk_cnt < mpi_uart_clk_div) begin
          tx_clk_cnt <= tx_clk_cnt + 1;
        end else begin
          tx_clk_cnt <= 1;
        end // else: !if( tx_clk_cnt < UART_BAUD_RATE )
        
      end // if ( !uart_idle_tx )
    end // else: !if( rst )
  end // block: TX_CLK_CNT
  
  
  always @ ( posedge clk or posedge rst ) begin : TX_CLK
    if ( rst ) begin
      /*AUTORESET*/
      // Beginning of autoreset for uninitialized flops
      tx_clk_neg <= 1'h0;
      tx_clk_pos <= 1'h0;
      // End of automatics
    end else begin
      if (usr_start_tx) begin
        tx_clk_pos <= 0;
        tx_clk_neg <= 0;
      end else if (!uart_idle_tx) begin
        tx_clk_pos <= (tx_clk_cnt == mpi_uart_clk_div[31:1]);
        tx_clk_neg <= (tx_clk_cnt == mpi_uart_clk_div[31:0]);
        
      end // if ( !uart_idle_tx )
    end // else: !if( rst )
  end // block: TX_CLK
  

  always @ ( posedge clk or posedge rst ) begin : STATE_PRO_TX
    if ( rst ) begin
      uart_txd <= 'h1;
      /*AUTORESET*/
      // Beginning of autoreset for uninitialized flops
      tx_data_shift <= 7'h0;
      uart_dataout_cnt <= 4'h0;
      uart_parity_tx <= 1'h0;
      // End of automatics
    end else begin
      case (c_state_tx)
        S_IDLE_TX : begin
          if (usr_start_tx) begin
            uart_txd <= 'h0;
          end else begin
            uart_txd <= 'h1;
          end
        end // case: S_IDLE_TX
        
        S_START_TX : begin
          if (tx_clk_neg) begin
            uart_txd <= usr_data_tx[0];
            uart_parity_tx <= usr_data_tx[0];
            tx_data_shift <= usr_data_tx[7:1];
          end
          uart_dataout_cnt <= 'd0;
        end // case: S_START_TX
        
        S_DATAOUT_TX : begin
          if (tx_clk_neg && (uart_dataout_cnt < (mpi_uart_data_bw - 4'd1))) begin
            uart_txd <= tx_data_shift[0];
            uart_parity_tx <= uart_parity_tx ^ tx_data_shift[0];
            tx_data_shift[5:0] <= tx_data_shift[6:1];
            uart_dataout_cnt <= uart_dataout_cnt + 'd1;
          end
        end // case: S_DATAOUT_TX
        
        S_PARITY_TX : begin
          case (mpi_uart_parity)
            'd1 : uart_txd <= ~uart_parity_tx;
            'd2 : uart_txd <= uart_parity_tx;
            'd3 : uart_txd <= 'h1;
            default : uart_txd <= 'h0;
          endcase
        end // case: S_PARITY_TX

        default : uart_txd <= 'h1;
      endcase // case (c_state_tx)

    end // else: !if( rst )
  end // block: STATE_PRO_TX



  // rx
  always @ ( posedge clk or posedge rst ) begin : UART_START_RX
    if ( rst ) begin
      /*AUTORESET*/
      // Beginning of autoreset for uninitialized flops
      uart_rxd_dly <= 8'h0;
      uart_rxd_iob <= 1'h0;
      uart_rxd_sample <= 1'h0;
      uart_start_rx <= 1'h0;
      // End of automatics
    end
    else begin
      uart_rxd_iob <= uart_rxd;
      uart_rxd_dly <= { uart_rxd_dly[6:0], uart_rxd_iob };
      uart_start_rx <= uart_idle_rx & uart_rxd_dly[2] & ( !uart_rxd_dly[1] );

      uart_rxd_sample <= uart_rxd_dly[2];
    end // else: !if( rst )
  end // block: UART_START_RX


  always @ ( posedge clk or posedge rst ) begin : RX_CLK_CNT
    if ( rst ) begin
      rx_clk_cnt <= 16'h1;
      /*AUTORESET*/
    end
    else begin
      if ( uart_start_rx ) begin
        rx_clk_cnt <= 1;
      end
      else if ( !uart_idle_rx ) begin
        if ( rx_clk_cnt < mpi_uart_clk_div ) begin
          rx_clk_cnt <= rx_clk_cnt + 1;
        end
        else begin
          rx_clk_cnt <= 1;
        end // else: !if( rx_clk_cnt < UART_BAUD_RATE )

      end // if ( !uart_idle_rx )
    end // else: !if( rst )
  end // block: RX_CLK_CNT


  always @ ( posedge clk or posedge rst ) begin : RX_CLK
    if ( rst ) begin
      /*AUTORESET*/
      // Beginning of autoreset for uninitialized flops
      rx_clk_neg <= 1'h0;
      rx_clk_pos <= 1'h0;
      // End of automatics
    end
    else begin
      if ( uart_start_rx ) begin
        rx_clk_pos <= 0;
        rx_clk_neg <= 0;
      end
      else if ( !uart_idle_rx ) begin
        rx_clk_pos <= (rx_clk_cnt == mpi_uart_clk_div[31:1]);
        rx_clk_neg <= (rx_clk_cnt == mpi_uart_clk_div[31:0]);

      end // if ( !uart_idle_rx )
    end // else: !if( rst )
  end // block: RX_CLK


  always @ ( posedge clk or posedge rst ) begin : UART_IDLE_RX
    if ( rst ) begin
      uart_idle_rx <= 1'h1;
      /*AUTORESET*/
    end else begin
      uart_idle_rx <= (c_state_rx == S_IDLE_RX);

    end // else: !if( rst )
  end // block: UART_IDLE_RX


  always @ (*) begin : N_STATE_RX
    case (c_state_rx)
      S_IDLE_RX : begin
        if (uart_start_rx && mpi_uart_en) begin
          n_state_rx = S_START_RX;
        end else begin
          n_state_rx = S_IDLE_RX;
        end
      end // case: S_IDLE_RX

      S_START_RX : begin
        if (rx_clk_pos) begin
          if (!uart_rxd_sample) begin
            n_state_rx = S_DATAIN_RX;
          end else begin
            n_state_rx = S_IDLE_RX;
          end
        end else begin // if (rx_clk_pos)
          n_state_rx = S_START_RX;
        end
      end // case: S_START_RX

      S_DATAIN_RX : begin
        if (rx_clk_pos && (uart_datain_cnt >= (mpi_uart_data_bw - 'd1))) begin
          if (|mpi_uart_parity) begin
            n_state_rx = S_PARITY_RX;
          end else begin
            n_state_rx = S_STOP0_RX;
          end
        end else begin
          n_state_rx = S_DATAIN_RX;
        end
      end // case: S_DATAOUT_RX

      S_PARITY_RX : begin
        if (rx_clk_pos) begin
          n_state_rx = S_STOP0_RX;
        end else begin
          n_state_rx = S_PARITY_RX;
        end
      end
      
      S_STOP0_RX : begin
        if (rx_clk_pos) begin
          if (mpi_uart_stop_bit == 'd0) begin
            n_state_rx = S_IDLE_RX;
          end else begin
            n_state_rx = S_STOP1_RX;
          end
        end else begin
          n_state_rx = S_STOP0_RX;
        end
      end // case: S_STOP0_RX
      
      S_STOP1_RX : begin
        if (mpi_uart_stop_bit == 'd1) begin
          if (rx_clk_neg) begin
            n_state_rx = S_IDLE_RX;
          end else begin
            n_state_rx = S_STOP1_RX;
          end
        end else begin
          if (rx_clk_pos) begin
            n_state_rx = S_IDLE_RX;
          end else begin
            n_state_rx = S_STOP1_RX;
          end
        end
      end // case: S_STOP1_RX

      default : n_state_rx = S_IDLE_RX;
    endcase // case (c_state_rx)
  end // block: N_STATE_RX
  
  always @ ( posedge clk or posedge rst ) begin : C_STATE_RX
    if ( rst ) begin
      /*AUTORESET*/
      // Beginning of autoreset for uninitialized flops
      c_state_rx <= 4'h0;
      // End of automatics
    end else begin
      c_state_rx <= n_state_rx;
    end
  end // block: C_STATE_RX
  


  always @ ( posedge clk or posedge rst ) begin : STATE_PRO_RX
    if ( rst ) begin
      /*AUTORESET*/
      // Beginning of autoreset for uninitialized flops
      rx_data_shift <= 8'h0;
      uart_datain_cnt <= 4'h0;
      uart_parity_rx <= 1'h0;
      usr_data_rx <= {(1+(8-1)){1'b0}};
      usr_done_rx <= 1'h0;
      usr_done_rx_tmp <= 1'h0;
      // End of automatics
    end else begin
      case (c_state_rx)
        S_IDLE_RX : begin
          usr_done_rx <= 0;
          usr_done_rx_tmp <= 0;
          uart_datain_cnt <= 'd0;
          uart_parity_rx <= 'h0;
        end // case: S_IDLE_RX
        
        S_DATAIN_RX : begin
          if (rx_clk_pos) begin
            rx_data_shift <= {uart_rxd_sample, rx_data_shift[7:1]};
            uart_parity_rx <= uart_parity_rx ^ uart_rxd_sample;
            uart_datain_cnt <= uart_datain_cnt + 'd1;
          end

          if (rx_clk_pos && (uart_datain_cnt >= (mpi_uart_data_bw - 'd1))) begin
            usr_done_rx_tmp <= (mpi_uart_parity == 'd0);
          end
        end // case: S_DATAOUT_RX
        
        S_PARITY_RX : begin
          if (rx_clk_pos) begin
            case (mpi_uart_parity)
              'd1 : usr_done_rx_tmp <= ((~uart_parity_rx) == uart_rxd_sample);
              'd2 : usr_done_rx_tmp <= (uart_parity_rx == uart_rxd_sample);
              'd3 : usr_done_rx_tmp <= uart_rxd_sample;
              default : usr_done_rx_tmp <= ~uart_rxd_sample;
            endcase // case (mpi_uart_parity)
          end
        end // case: S_PARITY_RX
        
        S_STOP0_RX : begin
          usr_done_rx_tmp <= 'h0;
          usr_done_rx <= usr_done_rx_tmp;

          case(mpi_uart_data_bw)
            'd4 : usr_data_rx <= {4'h0,rx_data_shift[7:4]};
            'd5 : usr_data_rx <= {3'h0,rx_data_shift[7:3]};
            'd6 : usr_data_rx <= {4'h0,rx_data_shift[7:2]};
            'd7 : usr_data_rx <= {1'h0,rx_data_shift[7:1]};
            default : usr_data_rx <= rx_data_shift[7:0];
          endcase // case (mpi_uart_data_bw)
          
        end // case: S_STOP0_RX
        
        S_STOP1_RX : begin
          usr_done_rx <= 'h0;
          usr_done_rx_tmp <= 'h0;
        end
        
        default : ;
      endcase // case (c_state_rx)

    end // else: !if( rst )
  end // block: STATE_PRO_RX


  
  
  


endmodule // uart_ctrl




