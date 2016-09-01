module mclk_to_50(clk,rst_n,div_1000000);
input clk,rst_n;
output reg div_1000000;
reg[31:0]cnt;
always@(posedge clk)
begin
     if(!rst_n) begin cnt<=0; div_1000000<=0; end
     else begin
               if(cnt==32'd100000)begin div_1000000<=~div_1000000; cnt<=0; end
               else begin cnt<=cnt+1;end
          end
end
endmodule
