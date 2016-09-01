module clk625(clk,div625,rst_n);
input clk,rst_n;
output  div625;
reg [9:0]cnt1,cnt2;
reg clk_temp1,clk_temp2;
always@(posedge clk)
begin
     if(!rst_n)begin clk_temp1=0;clk_temp2=0;cnt1<=0;end
     if(cnt1==10'd624)begin cnt1<=0;end
     else begin cnt1<=cnt1+1;end
     if(cnt1==10'd0)begin clk_temp1=1;end
     if(cnt1==10'd312)begin clk_temp1=0;end
end
always@(negedge clk)
begin 
    if(!rst_n)begin cnt2<=0;end
     if(cnt2==10'd624)begin cnt2<=0;end
     else begin cnt2<=cnt2+1;end
     if(cnt2==10'd0)begin clk_temp2=1;end
     if(cnt2==10'd312)begin clk_temp2=0;end
end
assign div625=clk_temp1|clk_temp2;

endmodule
