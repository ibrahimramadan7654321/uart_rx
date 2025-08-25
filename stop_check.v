module stop_check (

  input  wire   rst,
  input  wire   clk, 

  input  wire   stp_chk_en,
  input  wire   sampled_bit, 
    
  output reg    stp_err
);

localparam STOP_BIT  = 1'b1;

always@(posedge clk or negedge rst)
 begin
  if(!rst)
   begin
     stp_err <= 0;
   end
  else if(stp_chk_en)
    begin
     if(sampled_bit == STOP_BIT)  
       stp_err <= 1'b0;
     else 	 	 
       stp_err <= 1'b1;
    end
  
 end

endmodule