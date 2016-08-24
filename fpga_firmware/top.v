module top(
  clk,
  rst_n,
  sda,
  scl,
  MotorPWM,
  MotorA,
  MotorB,
  ServoPPM,
  key1,
  clkOut,
  uart_tx,
  uart_rx,
  dataLED
  );

  input clk, rst_n, key1;
  inout sda;
  output scl, MotorPWM, MotorA, MotorB, ServoPPM, clkOut;
  input uart_rx;
  output uart_tx;
  output [7:0] dataLED;
  
  assign dataLED = recevData;
  reg MotorA;
  reg MotorB;


  reg [15:0] servoDuty;
  wire clk_1MHz;
  ClockDIV #(.N(50)) DIV1MHz (
    .clk_in(clk),
    .clk_out(clk_1MHz),
    .rst_n(rst_n)
    );

  wire clk_1KHz;
  ClockDIV #(.N(50000)) DIV1kHz(
    .clk_in(clk),
    .clk_out(clk_1KHz),
    .rst_n(rst_n)
    );
  assign clkOut = clk_1MHz;

  reg [15:0] MotorDuty;
  //DC Motor
  PWM Motor1(
      .clk(clk),
      .rst_n(rst_n),
      .pwmOut(MotorPWM),
      .period(16'd5000),
      .duty(MotorDuty)
      );

  //servo
  PWM Servo(
    .clk(clk_1MHz),
    .rst_n(rst_n),
    .pwmOut(ServoPPM),
    .period(16'd20000),//period 20ms
    .duty(servoDuty)//range is 500~2500, unit is us
  );

	reg sendTrigger;
	wire recevNotify;
	wire [7:0] recevData;

	//serial port
  RS232 #(.BAUDRATE(9600)) btRemoter(
	.clk(clk),
	.rst_n(rst_n),
	.txd(uart_tx),
	.rxd(uart_rx),
	.ena(sendTrigger),
	.recevNotify(recevNotify),
	.data(recevData));
	
	always @ (posedge clk or posedge recevNotify or negedge rst_n) begin
	if(!rst_n) begin
		servoDuty <= 16'd1500;
		MotorDuty <= 0;
	end
	else begin
		if(recevNotify) begin
			case (recevData)
				"w":MotorDuty <= 10000;
				"s":MotorDuty <= 0;
				"l":servoDuty <= 1000;
				"c":servoDuty <= 1500;
				"r":servoDuty <= 2000;
			endcase
		end
	end
end
// reg [1:0] servoDutyKeyState;
// reg [9:0] servoDutyKeyCnt, servoDutyKeyCnt1;
// always @ ( posedge clk_1KHz or negedge key1 or negedge rst_n ) begin
//   if(!rst_n)
//     servoDutyKeyState <= 2'b00;
//   else
//   case (servoDutyKeyState)
//     //released
//     2'b00:begin
//       if(key1 === 1'b0) begin
//         servoDutyKeyState <= 2'b01;
//       end
//     end
//     //push triger
//     2'b01:begin
//       if(servoDutyKeyCnt > 20) begin//20ms
//         servoDutyKeyCnt <= 0;
//         if(key1 === 1'b0) begin//20ms
//           servoDutyKeyState <= 2'b10;
//         end
//         else begin
//           servoDutyKeyState <= 2'b00;
//         end
//       end
//       servoDutyKeyCnt <= servoDutyKeyCnt + 1;
//       if(key1 === 1'b1) begin
//         servoDutyKeyState <= 2'b00;
//       end
//     end
//     2'b10:begin
//       if(servoDutyKeyCnt1 > 10) begin
//         servoDutyKeyCnt1 <= 0;
//         servoDuty <= servoDuty + 1;
//       end
//
//       servoDutyKeyCnt1 <= servoDutyKeyCnt1 + 1;
//
//       if(key1 === 1'b1) begin
//         servoDutyKeyState <= 2'b00;
//       end
// 	 end
//     default:begin
//       servoDutyKeyState <= 2'b00;
// 	 end
//   endcase
// end

endmodule
