 module ClockDIV( 
   clk_in, 
  clk_out, 
   rst_n 
); 
 input clk_in,rst_n; 
 output clk_out; 
 parameter N = 10; 
 
 
reg [15:0] clk_cnt; 
reg clk_out; 
 
always @ ( posedge clk_in or negedge rst_n ) begin 
  if(!rst_n) begin 
    clk_cnt <= 0; 
	 clk_out <= 0; 
   end 
  else begin 
  	 clk_cnt <= clk_cnt + 1; 

 
    if(clk_cnt < (N/2)) begin 
      clk_out <= 1'b1; 
     end 
     else begin 
      clk_out <= 1'b0; 
    end 

 
    if(clk_cnt > N-2 ) begin 
      clk_cnt <= 0; 
     end 
 	end 
end 

 
endmodule 
