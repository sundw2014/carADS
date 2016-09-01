module mainlogic(rst_n,switch1,switch2,switch3,distance,speed,triangle,led1,led2,speed_control,voice,clk,out_num,angle_control);
input switch1,switch2,switch3,rst_n,clk;
input [9:0]distance,speed;
input [15:0]triangle;
output reg led1,led2,voice;
output reg[15:0]speed_control,angle_control;

parameter SPEED_LOW=0;
parameter SPEED_NORMAL=2000;

reg[9:0]timed;
wire[9:0]temp_time;
output reg[9:0]out_num;
div_rill u1(.a(distance),.b(speed),.shang(temp_time),.yushu());
always @(posedge clk or negedge rst_n)
begin 
		timed<=temp_time;
      if(!rst_n)begin led1<=0;led2<=0;voice<=0;out_num<=0;speed_control<=SPEED_NORMAL; angle_control<=1500; timed<=10; end
       else begin if(switch1==1'b1)begin out_num<=distance;end
      else begin
			   if(switch2==1)begin out_num<=speed;end
			   else begin out_num<=0;end
		  end
//	if(timed<=10'd30)begin speed_control<=(speed_control<=SPEED_LOW)?SPEED_LOW:(speed_control-50); led1<=1;end
//	else begin led1<=0;end
   if(distance<=60 && distance>=5)begin angle_control<=1000; speed_control<=SPEED_LOW; voice<=1; end
	else begin angle_control<=1500;speed_control<=SPEED_NORMAL;end
	if($signed(triangle)>16'sd10000)begin led2<=1;voice<=1;speed_control<=SPEED_LOW; end
	else begin voice<=0;led2<=0; speed_control<=SPEED_NORMAL; end
	end
end
endmodule
