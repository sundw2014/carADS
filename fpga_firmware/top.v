module top(
  clk,
  rst_n,
  sda,
  scl,
  MotorPWM,
  MotorA,
  MotorB,
  ServoPPM,
  key1
  );

  input clk, rst_n, key1;
  inout sda;
  output scl, MotorPWM, MotorA, MotorB, ServoPPM;

  //DC Motor
  PWM(
    .clk(clk),
    .rst_n(rst_n),
    .pwmOut(MotorPWM),
    .period(16'd5000),
    .duty(16'd1000)
  );

  reg [15:0] servoDuty;
  reg [2:0] clk_1MHz_cnt;
  reg clk_1MHz;

  always @ ( posedge clk ) begin

      clk_1MHz_cnt <= clk_1MHz_cnt + 1;

      if(clk_1MHz_cnt < 3) begin
        clk_1MHz <= 1'b1;
      end
      else begin
        clk_1MHz <= 1'b0;
      end

      if(clk_1MHz_cnt > 4) begin
        clk_1MHz_cnt <= 0;
      end

  end

  reg [11:0] clk_1KHz_cnt;
  reg clk_1KHz;

  always @ ( posedge clk ) begin

      clk_1KHz_cnt <= clk_1KHz_cnt + 1;

      if(clk_1KHz_cnt < 3000) begin
        clk_1KHz <= 1'b1;
      end
      else begin
        clk_1KHz <= 1'b0;
      end

      if(clk_1KHz_cnt > 4999) begin
        clk_1KHz_cnt <= 0;
      end

  end

  //servo
  PWM(
    .clk(clk_1MHz),
    .rst_n(rst_n),
    .pwmOut(ServoPPM),
    .period(16'd20000),//period 20ms
    .duty(servoDuty)//range is 500~1500, unit is us
  );

  assign MotorA = 1'b1;
  assign MotorB = 1'b0;

reg [1:0] servoDutyKeyState;
reg [9:0] servoDutyKeyCnt, servoDutyKeyCnt1;
always @ ( posedge clk_1KHz or negedge key1 ) begin
  case (servoDutyKeyState)
    //released
    2'b00:
      if(key1 === 1'b0) begin
        servoDutyKeyState <= 2'b01;
      end;
    //push triger
    2'b01:
      if(servoDutyKeyCnt > 20) begin//20ms
        servoDutyKeyCnt <= 0;
        if(key1 === 1'b0) begin//20ms
          servoDutyKeyState <= 2'b10;
        end
        else begin
          servoDutyKeyState <= 2'b00;
        end
      end
      servoDutyKeyCnt <= servoDutyKeyCnt + 1;
      if(key1 === 1'b1) begin
        servoDutyKeyState <= 2'b00;
      end
    2'b10:
      if(servoDutyKeyCnt1 > 10) begin
        servoDutyKeyCnt1 <= 0;
        servoDuty <= servoDuty + 1;
      end

      servoDutyKeyCnt1 <= servoDutyKeyCnt1 + 1;

      if(key1 === 1'b1) begin
        servoDutyKeyState <= 2'b00;
      end

    default:
      servoDutyKeyState <= 2'b00;
  endcase
end
initial begin
  servoDuty <= 15'd1000;
  clk_1MHz_cnt <= 3'b0;
  clk_1MHz <= 1'b0;
  servoDutyKeyState <= 2'b00;
  servoDutyKeyCnt <= 0;
  servoDutyKeyCnt1 <= 0;
end
endmodule
