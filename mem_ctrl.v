
module mem_ctrl (/*AUTOARG*/
  // Outputs
  mpi_mem_data_rd, mpi_mem_done, mem_cen, mem_oen, mem_wen, mem_a,
  // Inouts
  mem_dq,
  // Inputs
  clk, rst, mpi_mem_cs, mpi_mem_rw, mpi_mem_addr, mpi_mem_data_wr
  );



  parameter ADDR_BW = 32;
  parameter DATA_BW = 32;  
  parameter CLK_FREQ = 50_000_000; // unit: Hz
  parameter OPT_WAIT_TIME_NS = 120; //ns
  parameter OPT_WAIT_CNT_NUM = (((CLK_FREQ / 1_000_000) * OPT_WAIT_TIME_NS) / 1_000);
  

  
  input                 clk;    // more than 10MHz
  input                 rst;

  // mpi if
  input                 mpi_mem_cs;   // active posedge, only one cycle
  input                 mpi_mem_rw;   // 1:read, 0:write;
  input [ADDR_BW-1:0]   mpi_mem_addr;
  input [DATA_BW-1:0]   mpi_mem_data_wr;
  output [DATA_BW-1:0]  mpi_mem_data_rd;
  output                mpi_mem_done; // active high
  
  // mem if
  output                mem_cen;
  output                mem_oen;
  output                mem_wen;
  output [ADDR_BW-1:0]  mem_a;
  inout [DATA_BW-1:0]   mem_dq; 

  

  /*AUTOREG*/
  // Beginning of automatic regs (for this module's undeclared outputs)
  reg [ADDR_BW-1:0]     mem_a;
  reg                   mem_cen;
  reg                   mem_oen;
  reg                   mem_wen;
  reg [DATA_BW-1:0]     mpi_mem_data_rd;
  // End of automatics


  
  reg [7:0]             opt_wait_cnt;


  reg [DATA_BW-1:0]     mem_dq_out;

  
  localparam S_IDLE = 0;
  localparam S_WAIT = 1;

  reg [3:0]             n_state;
  reg [3:0]             c_state;


  always @ (*) begin : N_STATE
    case (c_state)
      S_IDLE : begin
        if (mpi_mem_cs) begin
          n_state = S_WAIT;
        end else begin
          n_state = S_IDLE;
        end
      end // case: S_IDLE
      
      S_WAIT : begin
        if (opt_wait_cnt > OPT_WAIT_CNT_NUM) begin
          n_state = S_IDLE;
        end else begin
          n_state = S_WAIT;
        end
      end
      
      default : begin
        n_state = S_IDLE;
      end
    endcase // case (c_state)
  end // block: N_STATE

  always @ (posedge clk or posedge rst) begin : C_STATE
    if (rst) begin
      /*AUTORESET*/
      // Beginning of autoreset for uninitialized flops
      c_state <= 4'h0;
      // End of automatics
    end else begin
      c_state <= n_state;
    end
  end // block: C_STATE
  

                         
  always @ (posedge clk or posedge rst) begin : SIGNAL_PRO
    if (rst) begin
      /*AUTORESET*/
      // Beginning of autoreset for uninitialized flops
      mem_a <= {ADDR_BW{1'b0}};
      mem_cen <= 1'h0;
      mem_dq_out <= {DATA_BW{1'b0}};
      mem_oen <= 1'h0;
      mem_wen <= 1'h0;
      mpi_mem_data_rd <= {DATA_BW{1'b0}};
      opt_wait_cnt <= 8'h0;
      // End of automatics
    end else begin
      case (c_state)
        S_IDLE : begin
          if (mpi_mem_cs) begin
            mem_cen <= 'h0;
            mem_oen <= ~mpi_mem_rw;
            mem_wen <= mpi_mem_rw;
            mem_a <= mpi_mem_addr;
            mem_dq_out <= mpi_mem_data_wr;
            opt_wait_cnt <= 'd0;
          end else begin // if (mpi_mem_cs)
            mem_cen <= 'h1;
            mem_oen <= 'h1;
            mem_wen <= 'h1;
            mem_a <= 'h0;
            mem_dq_out <= 'h0;
            opt_wait_cnt <= 'd0;
          end
        end // case: S_IDLE
        
        S_WAIT : begin
          opt_wait_cnt <= opt_wait_cnt + 'd1;
          if (opt_wait_cnt > OPT_WAIT_CNT_NUM) begin
            mem_cen <= 'h1;
            mem_oen <= 'h1;
            mem_wen <= 'h1;
            mpi_mem_data_rd <= mem_dq;
          end
        end
        default : ;
      endcase // case (c_state)
    end // else: !if(rst)
  end // block: SIGNAL_PRO
  
        
  
  
      
`ifdef SIM_MODE
  assign mem_dq = ((~mem_cen) & (~mem_wen)) ? 
                    mem_dq_out : 32'he;
`else
  assign mem_dq = ((~mem_cen) & (~mem_wen)) ? 
                    mem_dq_out : {DATA_BW{1'bz}};
`endif // !`ifdef SIM_MODE
  
  assign mpi_mem_done = (c_state == S_IDLE);
    

  

endmodule // mem_ctrl

// Local Variables:
// verilog-library-directories:("." "../")
// End:
