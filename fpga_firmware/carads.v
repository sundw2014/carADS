// Copyright (C) 1991-2013 Altera Corporation
// Your use of Altera Corporation's design tools, logic functions 
// and other software and tools, and its AMPP partner logic 
// functions, and any output files from any of the foregoing
// (including device programming or simulation files), and any 
// associated documentation or information are expressly subject 
// to the terms and conditions of the Altera Program License 
// Subscription Agreement, Altera MegaCore Function License 
// Agreement, or other applicable license agreement, including, 
// without limitation, that your use is for the sole purpose of 
// programming logic devices manufactured by Altera and sold by 
// Altera or its authorized distributors.  Please refer to the 
// applicable agreement for further details.

// PROGRAM		"Quartus II 32-bit"
// VERSION		"Version 13.0.1 Build 232 06/12/2013 Service Pack 1 SJ Web Edition"
// CREATED		"Wed Aug 31 18:10:14 2016"

module carads(
	clk,
	rst_n_key,
	echo1,
	echo2,
	switch1,
	switch2,
	key1,
	uart_rx,
	to_sr,
	led7,
	led6,
	voice,
	sda,
	scl,
	MotorA,
	MotorB,
	ServoPPM,
	uart_tx,
	clkout,
	MotorPWM,
	led5,
	num,
	sel,
	testICC
);


input wire	clk;
input wire	rst_n_key;
input wire	echo1;
input wire	echo2;
input wire	switch1;
input wire	switch2;
input wire	key1;
input wire	uart_rx;
output wire	to_sr;
output wire	led7;
output wire	led6;
output wire	voice;
inout wire	sda;
output wire	scl;
output wire	MotorA;
output wire	MotorB;
output wire	ServoPPM;
output wire	uart_tx;
output wire	clkout;
output wire	MotorPWM;
output wire	led5;
output wire	[6:0] num;
output wire	[3:0] sel;
output wire testICC;

wire	[6:0] num_ALTERA_SYNTHESIZED;
wire	[3:0] sel_ALTERA_SYNTHESIZED;
wire	[9:0] SYNTHESIZED_WIRE_1;
wire	[15:0] SYNTHESIZED_WIRE_2;
wire	[15:0] SYNTHESIZED_WIRE_3;
wire	[9:0] SYNTHESIZED_WIRE_4;

wire [15:0] angle_control;

wire [13:0] distance;

reg rst_n_inside;
wire rst_n;
assign rst_n = rst_n_key && rst_n_inside;

reg[15:0]autoResetCnt;

always@(posedge clk) begin
		if(autoResetCnt<10000) begin rst_n_inside <= 1; autoResetCnt = autoResetCnt + 1; end
		else if(autoResetCnt>=10000 && autoResetCnt < 60000) begin autoResetCnt = autoResetCnt + 1; rst_n_inside <= 0; end
		else if(autoResetCnt >= 60000) rst_n_inside = 1;
		else autoResetCnt = 0;
end
transtop	b2v_inst(
	.clk(clk),
	.rst_n(rst_n),
	.echo1(echo1),
	.echo2(echo2),
	.clkout(to_sr),
	.distance(distance),
	.speed(SYNTHESIZED_WIRE_1));


mainlogic	b2v_inst1(
	.rst_n(rst_n),
	.switch1(switch1),
	.switch2(switch2),
	.clk(clk),
	.distance(distance),
	.speed(SYNTHESIZED_WIRE_1),
	.triangle(SYNTHESIZED_WIRE_2),
	.led1(led7),
	.led2(led6),
	.voice(voice),
	.out_num(SYNTHESIZED_WIRE_4),
	.speed_control(SYNTHESIZED_WIRE_3),
	.angle_control(angle_control));


top	b2v_inst2(
	.clk(clk),
	.rst_n(rst_n),
	.key1(key1),
	.uart_rx(uart_rx),
	.sda(sda),
	
	.speed_control(SYNTHESIZED_WIRE_3),
	.scl(scl),
	.MotorPWM(MotorPWM),
	.MotorA(MotorA),
	.MotorB(MotorB),
	.ServoPPM(ServoPPM),
	.clkOut(clkout),
	.uart_tx(uart_tx),
	.newControlDataW(led5),
	.accXdata(SYNTHESIZED_WIRE_2),
	.angle_control(angle_control),
	.testICC(testICC)
	);


shumaguan	b2v_inst9(
	.clk(clk),
	.rst_n(rst_n),
	.distance(distance),
	.num(num),
	.sel(sel)
	);


endmodule
