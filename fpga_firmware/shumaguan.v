module shumaguan(clk,distance,num,sel,rst_n);
input clk,rst_n;
input[13:0]distance;
output [6:0]num;
output [3:0]sel;
wire[27:0]led_total;
wire clk50;

mclk_to_50 u1(clk,rst_n,clk50);
b_trans_d u2(distance,clk,led_total);
show_num u3(led_total,clk50,num,sel,rst_n);
endmodule
