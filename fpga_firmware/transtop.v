module transtop(clk,clkout,rst_n,echo1,echo2,distance,speed);
input clk,rst_n,echo1,echo2;
output wire[13:0]distance,speed;
output  clkout;
wire to_dis,to_sr;
wire temp1,temp2;
wire[9:0]temp3;
wire[9:0]temp_dis;
assign temp2=to_dis;
assign temp3=temp_dis;
assign clkout=to_sr;
mclk u1(clk,to_sr,to_dis,rst_n);
sr_04 u2(echo1,temp2,rst_n,distance);
sr_04 u3(echo2,temp2,rst_n,temp_dis);
speed u4(temp3,temp2,rst_n,speed);
endmodule


