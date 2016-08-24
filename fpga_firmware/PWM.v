module PWM(
    clk,
    rst_n,
    pwmOut,
    period,
    duty
    );

input clk,rst_n;
output reg pwmOut;
input wire [15:0] period, duty;

reg [15:0] cnt;

always@(posedge clk or negedge rst_n) begin
if(!rst_n) begin
  cnt <= 16'd0;
  pwmOut <= 1'b1;
end
else begin

  if(cnt > duty) begin
    pwmOut <= 1'b0;
  end
  else begin
    pwmOut <= 1'b1;
  end

  cnt <= cnt + 1;

  if(cnt === period) begin
    cnt <= 0;
  end

end
end
endmodule
