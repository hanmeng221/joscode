
module mpi_top(/*AUTOARG*/
  // Outputs
  mpi_data_rd, mpi_rd_rdy, mpi_mem_local_ctrl_en, mpi_flash_addr,
  mpi_flash_start, mpi_flash_chip_rst, mpi_flash_cmd,
  mpi_flash_data_wr, mpi_sram_addr, mpi_sram_start, mpi_sram_cmd,
  mpi_sram_data_wr,
  // Inputs
  rst_mpi, clk_mpi, mpi_cs, mpi_wren, mpi_rden, mpi_addr, mpi_data_wr,
  mpi_flash_data_rd, mpi_flash_done, mpi_flash_rdybsyn,
  mpi_sram_data_rd, mpi_sram_done, mpi_sram_waitn
  );
  


`include "param_mem_if.vh"


  
  // local bus if
  input                        rst_mpi; 
  input                        clk_mpi;
  input                        mpi_cs;
  input                        mpi_wren;
  input                        mpi_rden;
  input [14:0]                 mpi_addr;
  input [63:0]                 mpi_data_wr;
  output [63:0]                mpi_data_rd;
  output                       mpi_rd_rdy;
  
  
  output                       mpi_mem_local_ctrl_en;
    
  output [24:0]                mpi_flash_addr;
  output                       mpi_flash_start; // active posedge
  output                       mpi_flash_chip_rst; // active 0
  output                       mpi_flash_cmd;   // 1 : read, 0 : write
  output [31:0]                mpi_flash_data_wr;
  input [31:0]                 mpi_flash_data_rd;
  input                        mpi_flash_done; // active high
  input                        mpi_flash_rdybsyn; // from flash chip
  
  
  output [21:0]                mpi_sram_addr;
  output                       mpi_sram_start; // active posedge
  output                       mpi_sram_cmd;   // 1 : read, 0 : write
  output [31:0]                mpi_sram_data_wr;
  input [31:0]                 mpi_sram_data_rd;
  input                        mpi_sram_done; // active high
  input                        mpi_sram_waitn; // from sram chip


  /*AUTOREG*/
  // Beginning of automatic regs (for this module's undeclared outputs)
  reg [63:0]            mpi_data_rd;
  reg [24:0]            mpi_flash_addr;
  reg                   mpi_flash_chip_rst;
  reg                   mpi_flash_cmd;
  reg [31:0]            mpi_flash_data_wr;
  reg                   mpi_flash_start;
  reg                   mpi_mem_local_ctrl_en;
  reg                   mpi_rd_rdy;
  reg [21:0]            mpi_sram_addr;
  reg                   mpi_sram_cmd;
  reg [31:0]            mpi_sram_data_wr;
  reg                   mpi_sram_start;
  // End of automatics


  /*AUTOWIRE*/
  // Beginning of automatic wires (for undeclared instantiated-module outputs)
  wire [11:0]           mpi_flash_buffer_rx_cnt;// From u_flash_buffer_rx of fifo_wr32x2k_rd32x2k.v
  wire [31:0]           mpi_flash_buffer_rx_dout;// From u_flash_buffer_rx of fifo_wr32x2k_rd32x2k.v
  // End of automatics
  
  reg [63:0]                     mpi_reg_test_wr;

  reg [7:0]                      mpi_cs_shift;
  
  reg                            mpi_flash_buffer_clr;  
  reg                            mpi_flash_done_dly0;
  reg                            mpi_flash_buffer_rx_rden;

  reg [31:0]                     mpi_flash_buffer_rx_data;


  always @ ( posedge clk_mpi or posedge rst_mpi ) begin : MPI_WR
    if ( rst_mpi ) begin
      mpi_flash_chip_rst <= 1'h1;

      /*AUTORESET*/
      // Beginning of autoreset for uninitialized flops
      mpi_flash_addr <= 25'h0;
      mpi_flash_buffer_clr <= 1'h0;
      mpi_flash_cmd <= 1'h0;
      mpi_flash_data_wr <= 32'h0;
      mpi_flash_start <= 1'h0;
      mpi_mem_local_ctrl_en <= 1'h0;
      mpi_reg_test_wr <= 64'h0;
      mpi_sram_addr <= 22'h0;
      mpi_sram_cmd <= 1'h0;
      mpi_sram_data_wr <= 32'h0;
      mpi_sram_start <= 1'h0;
      // End of automatics
    end else begin
      if ( mpi_cs && mpi_wren ) begin
        if (mpi_addr[14:0] == 15'h01) begin
          mpi_reg_test_wr <= mpi_data_wr;
          end
            
        if ( mpi_addr[14:0] == 15'h02  ) begin
          mpi_mem_local_ctrl_en <= mpi_data_wr[0];
        end


        if ( mpi_addr[14:0] == 15'h70 ) begin
          mpi_flash_buffer_clr <= mpi_data_wr[1];
          mpi_flash_chip_rst <= mpi_data_wr[0];
        end
        if ( mpi_addr[14:0] == 15'h71 ) begin
          mpi_flash_start    <= 'h1;
          mpi_flash_cmd      <= mpi_data_wr[60];
          mpi_flash_addr     <= mpi_data_wr[56:32];
          mpi_flash_data_wr  <= mpi_data_wr[31:0];
        end
        
        if ( mpi_addr[14:0] == 15'h81 ) begin
          mpi_sram_start   <= 'h1;
          mpi_sram_cmd     <= mpi_data_wr[60];
          mpi_sram_addr    <= mpi_data_wr[53:32];
          mpi_sram_data_wr <= mpi_data_wr[31:0];
        end
        
      end else begin
        mpi_flash_start <= 'h0;
        mpi_sram_start <= 'h0;
      end
    end // else: !if( rst_mpi )
  end // block: MPI_WR

  
  always @ ( posedge clk_mpi or posedge rst_mpi ) begin : MPI_DATA_RD
    if ( rst_mpi ) begin
      /*AUTORESET*/
      // Beginning of autoreset for uninitialized flops
      mpi_data_rd <= 64'h0;
      // End of automatics
    end else begin
      mpi_data_rd <= 64'h0;
      
      case ( mpi_addr[14:0] )
        15'h00 : mpi_data_rd <= MODULE_VERSION;
        15'h01 : mpi_data_rd <= mpi_reg_test_wr;
        
        15'h02 : mpi_data_rd[0] <= mpi_mem_local_ctrl_en;

 
        15'h70 : begin
          mpi_data_rd[18:8] <= mpi_flash_buffer_rx_cnt[10:0];
          mpi_data_rd[5]    <= mpi_flash_rdybsyn;
          mpi_data_rd[4]    <= mpi_flash_done;
          mpi_data_rd[1]    <= mpi_flash_buffer_clr;
          mpi_data_rd[0]    <= mpi_flash_chip_rst;
        end
        15'h71 : begin
          mpi_data_rd[60]    <= mpi_flash_cmd;
          mpi_data_rd[56:32] <= mpi_flash_addr;
          mpi_data_rd[31:0]  <= mpi_flash_data_wr;
        end
        15'h72 : begin
          mpi_data_rd[31:0] <= mpi_flash_buffer_rx_data[31:0];
        end

        15'h80 : begin
          mpi_data_rd[1] <= mpi_sram_waitn;
          mpi_data_rd[0] <= mpi_sram_done;
        end
        15'h81 : begin
          mpi_data_rd[60]    <= mpi_sram_cmd;
          mpi_data_rd[53:32] <= mpi_sram_addr;
          mpi_data_rd[31:0]  <= mpi_sram_data_wr;
        end
        15'h82 : begin
          mpi_data_rd[31:0] <= mpi_sram_data_rd;
        end
        
        
        
        default : mpi_data_rd <= 64'h0;
      endcase // case ( mpi_addr[7:0])
    end // else: !if( rst_mpi )
  end // block: MPI_DATA_RD
  
  
  

  always @ ( posedge clk_mpi or posedge rst_mpi ) begin : MPI_RD_RDY
    if ( rst_mpi ) begin
      /*AUTORESET*/
      // Beginning of autoreset for uninitialized flops
      mpi_cs_shift <= 8'h0;
      mpi_rd_rdy <= 1'h0;
      // End of automatics
    end else begin
      mpi_cs_shift <= { mpi_cs_shift[6:0], mpi_cs }; 
      mpi_rd_rdy <= mpi_rden & mpi_cs_shift[7];

    end // else: !if( rst_mpi )
  end // block: MPI_RD_RDY


  always @ ( posedge clk_mpi or posedge rst_mpi ) begin : MPI_FLASH_DONE_DLY
    if ( rst_mpi ) begin
      /*AUTORESET*/
      // Beginning of autoreset for uninitialized flops
      mpi_flash_done_dly0 <= 1'h0;
      // End of automatics
    end else begin // if ( rst_mpi )
      mpi_flash_done_dly0 <= mpi_flash_done;
      
    end // else: !if( rst_mpi )
  end // block: MPI_FLASH_DONE_DLY
  
  
  always @ ( posedge clk_mpi or posedge rst_mpi ) begin : MPI_FLASH_BUFFER_RX_RDEN
    if ( rst_mpi ) begin
      /*AUTORESET*/
      // Beginning of autoreset for uninitialized flops
      mpi_flash_buffer_rx_data <= 32'h0;
      mpi_flash_buffer_rx_rden <= 1'h0;
      // End of automatics
    end else begin
      if ( mpi_cs && mpi_rden && (mpi_addr[14:0] == 15'h72)) begin
        mpi_flash_buffer_rx_rden <= 'h1;
        mpi_flash_buffer_rx_data <= mpi_flash_buffer_rx_dout;
      end else begin
        mpi_flash_buffer_rx_rden <= 'h0;
      end
            
    end // else: !if( rst_mpi )
  end // block: MPI_FLASH_BUFFER_RX_RDEN
  

  

  fifo_wr32x2k_rd32x2k u_flash_buffer_rx
    (
     // Outputs
     .dout                              (mpi_flash_buffer_rx_dout[31:0]),
     .data_count                        (mpi_flash_buffer_rx_cnt[11:0]),
     .full                              (),
     .empty                             (),
     
     // Inputs
     .clk                               (clk_mpi),
     .rst                               (rst_mpi | mpi_flash_buffer_clr),
     .din                               (mpi_flash_data_rd[31:0]),
     .wr_en                             (mpi_flash_cmd & 
                                         mpi_flash_done & 
                                         (~mpi_flash_done_dly0)),
     .rd_en                             (mpi_flash_buffer_rx_rden)
     
     /*AUTOINST*/);


  
endmodule // mpi_top
// Local Variables:
// verilog-library-directories:("." "../../coregen")
// End:





