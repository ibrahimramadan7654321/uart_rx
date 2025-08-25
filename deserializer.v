module deserializer (

  input  wire       rst,
  input  wire       clk,

  input  wire  [3:0]  bit_cnt,
  input  wire  [4:0]  edge_cnt,
  input  wire  [5:0]  prescale,

  input  wire  		    deser_en,
  input  wire  		    sampled_bit,
  
  output reg   [7:0]  P_DATA
);

reg [7:0] par_data;

always@(posedge clk or negedge rst)

  begin 
    if(!rst)
      begin
        P_DATA   <= 8'b0;
    	  par_data <= 8'b0;
      end
    else if(deser_en)
      begin
        par_data[bit_cnt-1] <= sampled_bit;
  	    if(bit_cnt == 8 && edge_cnt == ((prescale>>1)+2))
  	      P_DATA <= par_data;
     end
    else if(bit_cnt == 0)
      begin
        P_DATA   <= 8'b0;
  	    par_data <= 8'b0;
      end   
  end

endmodule