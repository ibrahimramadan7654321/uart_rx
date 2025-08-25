module UART_Rx_FSM (

	input  wire         rst,
	input  wire         clk,

	input  wire         RX_IN,
	input  wire         PAR_EN,
	input  wire         par_err,
	input  wire         strt_glitch,
	input  wire         stp_err,

	input  wire  [3:0]  bit_cnt,
	input  wire  [4:0]  edge_cnt,
	input  wire  [5:0]  prescale,


	output reg          data_samp_en,
	output reg          cnt_en,
	output reg          par_chk_en, 
	output reg          strt_chk_en, 
	output reg          stp_chk_en, 
	output reg 			    deser_en,
	output reg			    data_valid
);




typedef enum bit [2:0] {
		IDLE   		= 3'b000,
		START  		= 3'b001,
		DATA   		= 3'b011,
		PARITY 		= 3'b010,
		STOP   		= 3'b110
} State;

					 
					 
State  Current_State, Next_State ;     

reg [3:0] frame_size;
reg       data_valid_comp;

 
always @(posedge clk or negedge rst)
 begin
  if(!rst)
    frame_size <= 4'b0;
  else if(Current_State == IDLE || Current_State == START)
    frame_size <= (PAR_EN)? 11 : 10;
 end

		
always @(posedge clk or negedge rst)
 begin
  if(!rst)
   begin
     Current_State <= IDLE ;
	 data_valid <= 0;
   end
  else
   begin
     Current_State <= Next_State ;
	 data_valid <= data_valid_comp;
   end
 end
 
/* Next state logic */
always @(*)
 begin
  case(Current_State)
  IDLE   : begin
		    if(!RX_IN)
		     Next_State   = START;
			else 
			 Next_State = IDLE;    
		   end
  START  : begin
            if(bit_cnt != 1)
		     Next_State   = START;
			else if(strt_glitch)
			 Next_State = IDLE;
			else
			 Next_State = DATA;	
           end
  DATA   : begin
		    if(bit_cnt != 9)
		     Next_State   = DATA;
			else if(PAR_EN)
			 Next_State = PARITY;
			else 
			 Next_State = STOP;
		   end	 
  PARITY : begin
			if(bit_cnt != 10)
			 Next_State = PARITY;
			else
			 Next_State = STOP;
		   end
  STOP   : begin
			if(bit_cnt != frame_size)
			 Next_State = STOP;
			else if(!RX_IN)
		     Next_State = START;
		    else 
		     Next_State = IDLE;
		   end 
  default :  Next_State = IDLE ;		 
  
  endcase
end	


/* Output logic */
always @(*)
 begin

  data_samp_en 	  = 1'b0;
  cnt_en  	   	  = 1'b0;
  par_chk_en      = 1'b0;
  strt_chk_en     = 1'b0;
  stp_chk_en      = 1'b0;
  deser_en	      = 1'b0;
  data_valid_comp = 1'b0;

    case(Current_State)
	  IDLE   : begin
				if(!RX_IN)
				 begin
				  data_samp_en = 1'b1;
			    cnt_en  	   = 1'b1;
				 end
				else 
			     begin
				  data_samp_en = 1'b0;
			    cnt_en  	   = 1'b0;
				 end
			end
	  START  : begin
	       if(bit_cnt == 0 && edge_cnt == ((prescale>>1) + 2)) //  enable the start check block
				 	strt_chk_en  = 1'b1; 
				 
				if(bit_cnt != 1)
				 begin
				  	data_samp_en = 1'b1;
			      cnt_en  	   = 1'b1;
				 end
				else 
			    begin
				  	data_samp_en = 1'b1;
			      cnt_en  	   = 1'b1;
				  	deser_en	   = 1'b1;
				 end	   
			end
	  DATA   : begin
				  if(bit_cnt != 9)
					  begin
						  data_samp_en = 1'b1;
					    cnt_en  	   = 1'b1;
						  deser_en	   = 1'b1;
					  end
				else 
			    begin
				    data_samp_en = 1'b1;
			      cnt_en  	   = 1'b1;
				    deser_en	   = 1'b0;
			     end
			end 
	  PARITY : begin
	      if(bit_cnt == 9 && edge_cnt == ((prescale>>1) + 2))  //  enable the parity check block
				 par_chk_en   = 1'b1;
				 
				if(bit_cnt != 10)
				 begin
				  data_samp_en = 1'b1;
			    cnt_en  	   = 1'b1;
				 end
				else 
			    begin
				    data_samp_en = 1'b1;
			      cnt_en  	   = 1'b1;
				  end	   
			end
	  STOP   : begin
				if(bit_cnt == (frame_size - 1) && edge_cnt == ((prescale>>1) + 2)) //  enable the stop check block
				 stp_chk_en   = 1'b1;
			    
				if(bit_cnt != frame_size)
				 begin
				  data_samp_en = 1'b1;
				  cnt_en  	   = 1'b1;
				 end
			  else
					begin
					  data_samp_en = 1'b0;
					  cnt_en  	   = 1'b0;
					end 
				 
				if(!par_err && !stp_err && bit_cnt == frame_size) 
			    data_valid_comp  = 1'b1;
				else
				 data_valid_comp  = 1'b0;
				 
			end
	 default : begin
				 data_samp_en 	  = 1'b0;
				 cnt_en  	  	  = 1'b0;
				 par_chk_en   	  = 1'b0;
			     strt_chk_en  	  = 1'b0;
			     stp_chk_en   	  = 1'b0;
				 deser_en	  	  = 1'b0;
				 data_valid_comp  = 1'b0;
			end		  
	endcase
 end	

endmodule