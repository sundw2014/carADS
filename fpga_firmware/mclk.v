module mclk(clk,to_sr,to_dis,rst_n);
input clk,rst_n;
output  to_sr,to_dis;
clk_3125000 u1(clk,rst_n,to_sr);
div2900 u3(to_dis,rst_n,clk);
endmodule
