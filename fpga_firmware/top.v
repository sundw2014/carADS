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
  dataLED,
  newControlDataW
  );

  input clk, rst_n, key1;
  inout sda;
  output scl, MotorPWM, MotorA, MotorB, ServoPPM, clkOut;
  input uart_rx;
  output uart_tx;
  output reg [7:0] dataLED;
  output reg newControlDataW;
  
//  assign dataLED = recevData;
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
	async_receiver #(.ClkFrequency(50000000),.Baud(9600)) (.clk(clk), .RxD(uart_rx), .RxD_data_ready(recevNotify), .RxD_data(recevData));	
	
	reg [2:0] dataAssemablingState;
	reg [15:0] steer, throttle;
	reg newControlData;

//	assign newControlDataW = recevNotify;
	
	always @ (posedge recevNotify or negedge rst_n) begin
	if(!rst_n) begin
		dataAssemablingState <= 0;
	end
	else begin
		dataLED <= recevData;
		if(recevNotify) begin
			case(dataAssemablingState)
				3'd0:begin dataAssemablingState <= (recevData=="a")?3'd1:3'd0; newControlDataW <=0; end
				3'd1:begin dataAssemablingState <= (recevData=="b")?3'd2:3'd0; newControlDataW <=0; end
				3'd2:begin dataAssemablingState <= (recevData=="c")?3'd3:3'd0; newControlDataW <=1; end
				3'd3: begin steer[15:8] <= recevData; newControlData <= 1'b0; dataAssemablingState <= 3'd4; end
				3'd4: begin steer[7:0] <= recevData; dataAssemablingState <= 3'd5; end
				3'd5: begin throttle[15:8] <= recevData; dataAssemablingState <= 3'd6; end
				3'd6: begin throttle[7:0] <= recevData; dataAssemablingState <= 3'd7; end
				3'd7: begin newControlData <= 1'b1; dataAssemablingState <= 3'd0; end
				default: begin dataAssemablingState <= 3'd0; end
				endcase
		end
	end
	end
	always @ (posedge newControlData or negedge rst_n) begin
	if(!rst_n) begin
		servoDuty <= 16'd1500;
		MotorDuty <= 0;
	end
	else begin
		if(newControlData) begin
			if(throttle > 512) begin
					MotorA <= 1'b1;
					MotorB <= 1'b0; 
					MotorDuty <= {(throttle[12:0] - 13'd512),3'd0};
				end
				else begin
					MotorA <= 1'b0;
					MotorB <= 1'b1;
					MotorDuty <= {(13'd512 - throttle[12:0]),3'd0};
			end
			servoDuty <= steer + 16'd1000;
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
//       end/
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
