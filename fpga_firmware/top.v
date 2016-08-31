module top(
  clk,
  rst_n,
  sda,
  speed_control,
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
  newControlDataW,
  accXdata,
  angle_control
  );

  input clk, rst_n, key1;
  inout sda;
 input[15:0]speed_control;
  output scl, MotorPWM, MotorA, MotorB, ServoPPM, clkOut;
  input uart_rx;
  output uart_tx;
  output reg [7:0] dataLED;
  output wire newControlDataW;
  output wire[32:0]accXdata;
  input[15:0]angle_control;
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
   I2C u1(.clk(clk),.scl(scl),.sda(sda),.rst_n(rst_n),.LED(),.accXdata(accXdata));
	reg sendTrigger;
	wire recevNotify;
	wire [7:0] recevData;

	//serial port
	async_receiver #(.ClkFrequency(50000000),.Baud(9600)) (.clk(clk), .RxD(uart_rx), .RxD_data_ready(recevNotify), .RxD_data(recevData));	
	
	reg [3:0] dataAssemablingState;
	reg [15:0] steer, throttle;
	reg newControlData;
	reg controlMode;
	assign newControlDataW = controlMode;
	
	always @ (posedge recevNotify or negedge rst_n) begin
	if(!rst_n) begin
		dataAssemablingState <= 0;
		controlMode <= 1;
	end
	else begin
		dataLED <= recevData;
		if(recevNotify) begin
			case(dataAssemablingState)
				4'd0:begin dataAssemablingState <= (recevData=="a")?3'd1:3'd0; end
				4'd1:begin dataAssemablingState <= (recevData=="b")?3'd2:3'd0; end
				4'd2:begin 
						if(recevData=="c") begin dataAssemablingState <= 3'd3; newControlData <= 1'b0; end
						else if(recevData=="m") begin dataAssemablingState <= 4'd8; end
						else dataAssemablingState <= 3'd0;
                  end
				4'd3: begin steer[15:8] <= recevData; dataAssemablingState <= 3'd4; end
				4'd4: begin steer[7:0] <= recevData; dataAssemablingState <= 3'd5; end
				4'd5: begin throttle[15:8] <= recevData; dataAssemablingState <= 3'd6; end
				4'd6: begin throttle[7:0] <= recevData; dataAssemablingState <= 3'd7; end
				4'd7: begin newControlData <= 1'b1; dataAssemablingState <= 3'd0; end
				4'd8: begin controlMode <= recevData[0]; dataAssemablingState <= 3'd0; end
				default: begin dataAssemablingState <= 3'd0; end
				endcase
		end
	end
	end
	always @ (posedge newControlData or posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		servoDuty <= 16'd1500;
		MotorDuty <= 0;
	end
	else begin
		if(newControlData) begin
			if(controlMode) begin
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
		else begin
			if(!controlMode) begin
				//MotorDuty <= speed_control;
				//servoDuty <= angle_control;
			end
		end
	end
end

endmodule
