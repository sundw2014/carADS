module clk_3125000(clk,rst_n,div50);
input clk,rst_n;
output reg div50;
reg[32:0]cnt;
always @(posedge clk)
begin
      if(!rst_n)begin cnt<=0;div50<=0;end
     if(cnt==32'd1562499)begin div50<=~div50;cnt<=0;end
     else begin cnt<=cnt+1;end
end
endmodule