module UART_RX (


  input  wire          rst,
  input  wire          clk,

  input  wire   [5:0]  prescale, 

  input  wire   	     RX_IN, 
  input  wire          PAR_EN,
  input  wire          PAR_TYP,
  
  output wire          Parity_Error,
  output wire			     Stop_Error,
  output wire 			   Data_Valid,
  output wire   [7:0]  P_DATA
);



/* Internal connections */
wire  [4:0]  edge_cnt;
wire  [3:0]  bit_cnt;
wire         data_samp_en, cnt_en;
wire         strt_glitch;
wire         par_chk_en, strt_chk_en, stp_chk_en; 
wire		 deser_en;
wire		 sampled_bit;


deserializer deser_u0 (
.bit_cnt(bit_cnt),
.edge_cnt(edge_cnt),
.prescale(prescale),
.deser_en(deser_en),
.sampled_bit(sampled_bit),
.rst(rst),
.clk(clk),
.P_DATA(P_DATA)
);


UART_Rx_FSM fsm_u0 (
.RX_IN(RX_IN),
.PAR_EN(PAR_EN),
.strt_glitch(strt_glitch),
.par_err(Parity_Error),
.stp_err(Stop_Error),
.bit_cnt(bit_cnt),
.edge_cnt(edge_cnt),
.prescale(prescale),
.rst(rst),
.clk(clk),
.data_samp_en(data_samp_en),
.cnt_en(cnt_en),
.par_chk_en(par_chk_en),
.strt_chk_en(strt_chk_en),
.stp_chk_en(stp_chk_en),
.deser_en(deser_en),
.data_valid(Data_Valid)
);


data_sampling data_samp_u0 (
.RX_IN(RX_IN),
.prescale(prescale),     
.data_samp_en(data_samp_en),
.edge_cnt(edge_cnt),
.rst(rst),
.clk(clk),
.sampled_bit(sampled_bit)
);


edge_bit_counter edge_bit_counter_u0 (
.prescale(prescale),
.cnt_en(cnt_en),
.PAR_EN(PAR_EN), 
.rst(rst),
.clk(clk),    
.edge_cnt(edge_cnt),
.bit_cnt(bit_cnt)
);


start_check start_check_u0 (
.rst(rst),
.clk(clk),
.strt_chk_en(strt_chk_en),
.sampled_bit(sampled_bit),
.strt_glitch(strt_glitch)
);


parity_check parity_check_u0 (
.rst(rst),
.clk(clk),
.P_DATA(P_DATA),
.PAR_TYP(PAR_TYP),
.PAR_EN(PAR_EN),
.par_chk_en(par_chk_en),
.sampled_bit(sampled_bit),
.par_err(Parity_Error)
);


stop_check stop_check_u0 (
.rst(rst),
.clk(clk),
.stp_chk_en(stp_chk_en),
.sampled_bit(sampled_bit),
.stp_err(Stop_Error)
);

endmodule 