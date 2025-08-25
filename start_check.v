module start_check (

  input  wire   rst,
  input  wire   clk, 

  input  wire   strt_chk_en,
  input  wire   sampled_bit,
   
  output reg    strt_glitch
);

localparam START_BIT = 1'b0;

always@(posedge clk or negedge rst)
 begin
  if(!rst)
   begin
     strt_glitch <= 0;
   end
   
  else if(strt_chk_en)
    begin
     if(sampled_bit == START_BIT)  
       strt_glitch <= 1'b0;
     else 	 	 
       strt_glitch <= 1'b1;
    end
	
 end

endmodule