
module mini_machine(sys_clk, refresh_clk, sys_rst, din, dout1, dout2, sel1, sel2, TxD1,flash_cen,flash_resetn,flash_oen,flash_wen,flash_byten,flash_a,flash_dq,flash_rdybsyn,sram_clk,sram_cen,sram_advn,sram_oen,sram_wen,sram_psn,sram_a,sram_dq,sram_ben,sram_waitn,start,uart_rxd,uart_txd);
    input sys_clk;
	input refresh_clk;
	input sys_rst;
	input [31:0] din;
	output [7:0] dout1;
	output [7:0] dout2;
	output [4:1] sel1;
	output [4:1] sel2;
	output TxD1;
    
	  output flash_cen;
    output flash_resetn;
    output flash_oen;
    output flash_wen;
    output flash_byten;
    output [24:0] flash_a;
    inout [31:0] flash_dq;
    input flash_rdybsyn;
    output sram_clk;
    output sram_cen;
    output sram_advn;
    output sram_oen;
    output sram_wen;
    output sram_psn;
    output [21:0] sram_a;
    inout [31:0] sram_dq;
    output [7:0] sram_ben;
    input sram_waitn;
    output start;
    
    input uart_rxd;
    output uart_txd;
    
	wire rst;
	//wire refresh_clk;
	//assign refresh_clk = sys_clk;
	//clk_50to10 u_clk_changer(sys_clk, clk);
	//assign clk = sys_clk;
	
	assign rst = ~sys_rst;
	
	wire clk;
	wire ram_clk;
	double_clk the_double_clk(sys_clk, clk);
	assign ram_clk=sys_clk;
    
	wire [31:0] switch_din;
	wire [31:0] switch_dout;
	Switches switches(switch_din, switch_dout);
    
	wire [31:2] CPUAddr;
	wire [3:0] BE;
	wire [31:0] CPUIn;
	wire [31:0] CPUOut;
	wire IOWe;
	wire clk_out;
	wire [7:2] HardInt_in;
	wire [31:2] CPU_PC;
	
	wire [14:0] dm_addr;
	wire  [3:0] be_in;
	wire [31:0] dm_din;
	wire dm_we;
	wire  [31:0] dm_dout;
	wire  dm_cs;
	
	wire  [20:2] im_addr;
	wire  [31:0] im_dout;
	wire im_cs;
	wire mem_en;
	wire uart_tx_done;
	mips U_MIPS(clk,ram_clk, rst, CPUAddr, BE, CPUIn, CPUOut, IOWe, clk_out, HardInt_in, CPU_PC,dm_addr,be_in,dm_din,dm_we,dm_dout,dm_cs,im_addr,im_dout,im_cs,mem_en & uart_tx_done,switch_dout[1] &start );
	
	wire [31:2] CPU_addr;
	wire [31:0] CPU_din;
	wire CPUWe;
	wire [3:0] CPU_be;
	wire [31:0] CPU_dout;
	wire [31:0] deviceCounter_din;
	wire [31:0] deviceSwitch_din;
	wire [3:2] device_addr;
	wire [31:0] device_dout;
	wire weCounter;
	wire weNumber;
	wire weUART;
	wire [3:0] device_BE;
	wire [31:2] CPUPC;
	wire [31:0] DigitNumber;
	
	UART_DETECT the_UART_DETECT(clk,rst,IOWe,CPUAddr,uartEn);
	
	Bridge U_BRIDGE(CPU_addr, CPU_din, CPUWe, CPU_be, CPU_dout, deviceCounter_din, deviceSwitch_din, device_addr, device_dout, weCounter, weNumber, weUART, device_BE, CPUPC, DigitNumber);
	
	wire CLK_I, RST_I;
	wire [3:2] ADD_I;
	wire WE_I;
	wire [31:0] DAT_I;
	wire [31:0] DAT_O;
	wire IRQ;
	timecounter U_TIMER(CLK_I, RST_I, ADD_I, WE_I, DAT_I, DAT_O, IRQ, device_BE);
	
	wire [31:0] numbers_din;
	wire numbers_we;
	Numbers numbers(refresh_clk, numbers_din, numbers_we, dout1, dout2, sel1, sel2);
	
	wire uart_senden;
	wire [7:0] uart_send;
	wire uart_tx;
	RS232_output U_UART(sys_clk, ~rst, uartEn, dm_din[7:0], uart_tx, uart_tx_done);
	
	assign CPUIn = CPU_dout;
	assign HardInt_in = {5'b0, IRQ};
	
	
	assign CPU_addr = CPUAddr;
	assign CPU_din = CPUOut;
	assign CPU_be = BE;
	assign CPUWe = IOWe;
	assign deviceCounter_din = DAT_O;
	assign deviceSwitch_din = switch_dout;
	
	assign CPUPC=CPU_PC;
	
	assign CLK_I = clk_out;
	assign RST_I = rst;
	assign ADD_I = device_addr[3:2];
	assign WE_I = weCounter;
	assign DAT_I = device_dout;
	
	assign switch_din = din;
	assign numbers_din = DigitNumber;
	assign numbers_we = 1'b1;
	
	assign uart_senden = weUART;
	assign uart_send = device_dout[7:0];
	assign TxD1 = uart_tx;
	wire pc_work,dm_work;
	assign pc_work = im_cs;
	assign dm_work = dm_cs;
	
 MEM the_MEM(flash_cen,flash_resetn,flash_oen,flash_wen,flash_byten,flash_a,flash_dq,flash_rdybsyn,sram_clk,sram_cen,sram_advn,sram_oen,sram_wen,sram_psn,sram_a,sram_dq,sram_ben,sram_waitn,ram_clk,rst,{7'h0,dm_addr},dm_work, dm_we,be_in,dm_din,dm_dout,pc_work,{3'h0,im_addr},im_dout,switch_dout[0],start,uart_rxd,uart_txd,mem_en);
 
endmodule















