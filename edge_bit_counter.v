module edge_bit_counter (

  input  wire         rst,
  input  wire         clk,

  input  wire  [5:0]  prescale,
  
  input  wire  		    cnt_en,
  input  wire         PAR_EN,
  
  output reg  [4:0]   edge_cnt,
  output reg  [3:0]   bit_cnt
);

reg [3:0] frame_size;
 
always @(posedge clk or negedge rst)
 begin
  if(!rst)
    frame_size <= 4'b0 ;
  else if(bit_cnt == 0 || bit_cnt == 1)
    frame_size <= (PAR_EN)? 11 : 10;
 end


always @(posedge clk or negedge rst)
 begin
  if(!rst)
   begin
     edge_cnt <= 5'b0 ;
	 bit_cnt  <= 4'b0 ;
   end
  else if(cnt_en)
   begin
    if(edge_cnt != (prescale-1)) 
	 edge_cnt <= edge_cnt + 5'b1 ;
	
	else if(bit_cnt != frame_size)
	   begin
	    bit_cnt  <= bit_cnt + 4'b1 ;
	    edge_cnt <= 5'b0 ;
	   end
	  else 
	   begin
	    edge_cnt <= 5'b0 ;
		bit_cnt  <= 4'b0 ;
	   end  
   end
  else 
   begin
	    edge_cnt <= 5'b0 ;
		bit_cnt  <= 4'b0 ;
   end  
 end

endmodule