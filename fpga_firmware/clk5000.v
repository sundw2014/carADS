module clk_5000(clk,rst_n,div5000);
input clk,rst_n;
output div5000;
reg div5000;
reg[12:0]cnt;
always @(posedge clk)
begin 
     if(!rst_n)begin cnt<=0;end
     if(cnt==4999)begin div5000<=1;cnt<=0;end
     else begin cnt<=cnt+1;div5000<=0;end
end
endmodule

