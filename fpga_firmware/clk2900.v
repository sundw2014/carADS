module div2900(div2900,rst_n,clk);
input rst_n,clk;
output reg div2900;
reg [11:0]cnt;
always @(posedge clk)
begin 
     if(!rst_n)begin cnt<=0;end
     if(cnt==1449)begin div2900=~div2900;cnt<=0;end
	 else begin cnt<=cnt+1;end
end
endmodule
