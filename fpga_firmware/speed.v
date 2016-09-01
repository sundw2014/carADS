module speed(distance,clk,rst_n,speed);
input distance,clk,rst_n;
output reg[9:0]speed;
wire[9:0]distance,temp;
reg[9:0]former_dis,present_dis,between_dis,chushu;
always@(posedge clk)
begin
     if(!rst_n)begin former_dis<=0;present_dis<=0;speed<=0;end
     else begin present_dis<=distance;former_dis<=present_dis;
               between_dis<=(former_dis-present_dis);
	           chushu<=6;
	           speed<=temp;
	      end
end
div_rill u1(.a(distance),.b(chushu),.shang(temp),.yushu());
endmodule
	
 