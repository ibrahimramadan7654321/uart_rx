module parity_check (

  input  wire           rst,
  input  wire           clk, 

  input  wire   [7:0]   P_DATA,
  
  input  wire     	    PAR_TYP,PAR_EN,     
  input  wire 		      par_chk_en,
  input  wire 		      sampled_bit,
  
  output reg 		        par_err
);

wire parity_bit;

assign parity_bit = PAR_TYP? (~^ P_DATA) : (^ P_DATA) ;

always@(posedge clk or negedge rst)
 begin
  if(!rst)
    begin
      par_err <= 0;
    end
  else if(!PAR_EN)        /* PARITY DISABLED */
    par_err <= 1'b0;
   
  else if(par_chk_en)
    begin
    
    	if(sampled_bit == parity_bit)
    	  par_err <= 1'b0;
    	else
    	  par_err <= 1'b1;
	
	  end
	
 end

endmodule
