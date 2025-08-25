module data_sampling (

	input  wire       rst,
  input  wire       clk,

  input  wire       RX_IN,
  input  wire       data_samp_en,

  input  wire [5:0] prescale,
  input  wire [4:0] edge_cnt,
  
  output reg       sampled_bit
);

reg sample1, sample2, sample3;

always@(posedge clk or negedge rst)
	begin
	  if(!rst)
	   begin
	    sample1 <= 1'b1;
		  sample2 <= 1'b1;
		  sample3 <= 1'b1;
	   end
	  else if(data_samp_en)
	   begin
	    if(edge_cnt == ((prescale>>1)-1))
	     sample1 <= RX_IN;
	    else if(edge_cnt == prescale>>1)
	     sample2 <= RX_IN;
	    else if(edge_cnt == ((prescale>>1)+1))
	     sample3 <= RX_IN;
	   end
	   
	end
 
 always@(*)
	 begin
	  case({sample1, sample2, sample3})

			3'b000   :  sampled_bit = 1'b0;
			
			3'b001   :  sampled_bit = 1'b0;
			
			3'b010   :  sampled_bit = 1'b0;
			
			3'b011   :  sampled_bit = 1'b1;
			
			3'b100   :  sampled_bit = 1'b0;
			
			3'b101   :  sampled_bit = 1'b1;
			
			3'b110   :  sampled_bit = 1'b1;
			
			3'b111   :  sampled_bit = 1'b1;  
			
			default  :  sampled_bit = 1'b1;  

	  endcase

	 end
 
endmodule 