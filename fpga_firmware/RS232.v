`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Company  : 杭州电子科技大学
// Engineer  : 晓晓川
// Create Date : 2012.08.26
// Design Name : serial_test
// Module Name : serial_test
// Project Name: serial_test
// Target Device: CycloneII EP2C5T144C8
// Tool versions: Quartus II 11.0
// Revision  : V1.0
// Description : 一个极为简单的串口收发工程，适于串口收发的入门。只能收发单个字节,没有
//                奇偶校验位。
//        工作流程为：串口发送数据给FPGA，以LED灯的亮灭直观显示接收到数据，按下
//                         相应按键并弹起后，FPGA又将接收到的串口数据发送出去。
// Additional Comments :
//
////////////////////////////////////////////////////////////////////////////////
module RS232(
  clk,
  rst_n,
  ena,
  recevNotify,
  txd,
  rxd,
  data
  );
input clk;         //系统输入时钟
input rst_n;       //异步复位
input ena;         //FPGA发送使能，即按键输入端
input rxd;         //FPGA接收端
output txd;        //FPGA发送端
output [7:0] data; //至LED显示的数据
output recevNotify;

parameter  BAUDRATE=115200;

wire   [7:0] data;
wire   txd;
wire   clk2;       //PLL输出时钟
wire   clk_baud;   //波特率时钟
pll0p24  u1(.inclk0(clk),.c0(clk2));                                               //PLL输出低频时钟
clk_baud_gen #(.BAUDRATE(BAUDRATE)) u2(.clk(clk2),.rst_n(rst_n),.clk_baud(clk_baud));                //产生波特率时钟
serial_txd  u3(.clk(clk_baud),.rst_n(rst_n),.ena(ena),.data(data),.txd(txd));  //FPGA发送模块
serial_rxd  u4(.clk(clk_baud),.rst_n(rst_n),.rxd(rxd),.data(data),.recevNotify(recevNotify));            //FPGA接收模块
endmodule

//此模块是FPGA控制模块从串口接收数据，不接收起始位“0”和停止位“1”
//在接收端，若串口没有数据发出，则一直处于高电平，有数据发出时，先发送起始位“0”，即如果
//接收端出现由高到低的跳变，说明串口有数据发出，应开始接收
module  serial_rxd(rst_n,clk,rxd,data,recevNotify);
input   rst_n;          //全局复位
input   clk;            //接收时钟
input   rxd;            //FPGA接收串口数据的接收端
output  [7:0] data;     //FPGA接收的来自串口的数据，输出至LED显示

output reg recevNotify;

reg     [3:0] cnt;      //接收数据计数器
reg     rec_reg1;       //起始位检测寄存器1
reg     rec_reg2;       //起始位检测寄存器2
reg     [7:0] data;     //FPGA接收的数据
always @(posedge clk or negedge rst_n)
  if(!rst_n)
  begin
  rec_reg1<=1'b1;     //起始位检测寄存器置1，
  rec_reg2<=1'b1;     //处于等待接收状态
  data<=8'hzz;        //输出复位,LED全灭
  recevNotify <= 1'b0;
  end
  else if(rec_reg1&&rec_reg2)
  begin
  rec_reg1<=rxd;      //rec_reg1寄存rxd当前周期的值
  rec_reg2<=rec_reg1; //rec_reg2寄存rxd前一周期的值
  end
  else if(!rec_reg1&&rec_reg2) begin   //检测rxd下降沿，也即是否有低电平到来
  case (cnt)
  4'd0:begin data[0]<=rxd; recevNotify <= 1'b0; end  //接收第一位数据
  4'd1:data[1]<=rxd;  //接收第二位数据
  4'd2:data[2]<=rxd;  //接收第三位数据
  4'd3:data[3]<=rxd;  //接收第四位数据
  4'd4:data[4]<=rxd;  //接收第五位数据
  4'd5:data[5]<=rxd;  //接收第六位数据
  4'd6:data[6]<=rxd;  //接收第七位数据
  4'd7:begin
      data[7]<=rxd;  //接收第八位数据
      rec_reg1<=1'b1;//数据接收完毕，起始位检测寄存器复位
      rec_reg2<=1'b1;//以准备下次接收
      recevNotify <= 1'b1;
      end
      default:begin
         data<=8'hzz;
           rec_reg1<=1'b1;
         rec_reg2<=1'b1;
         end
  endcase
  end
always @(posedge clk or negedge rst_n)
  if(!rst_n)
	 cnt<=4'd0;          //复位，接收数据计数器清零
  else if(!rec_reg1&&rec_reg2) begin
    cnt<=(cnt<4'd7)?cnt+4'd1:4'd0; //检测到起始位后，接收数据计数器启动
  end
endmodule

//此模块的作用是FPGA控制模块向串口发送数据，起始位为“0”，停止位为“1”
//延时电路的设计思想为按键按下弹起之后开始计时，时长为1010/11920秒
//延时去抖结束后给出发送标志位，直至FPGA向串口发送完毕
module   serial_txd(rst_n,clk,ena,data,txd);
input    rst_n;           //全局复位
input    clk;             //串口发送时钟
input    ena;             //串口发送使能输入端,即按键输入端
input    [7:0] data;      //FPGA向串口发送的数据
output   txd;             //FPGA向串口发送数据的发送端

reg      txd;
reg      [3:0] cnt;       //发送数据计数器
reg      [9:0] cnt_delay; //延时去抖计数器，延时时间为1010/11920秒
reg      ena_reg1;        //按键状态寄存器1
reg      ena_reg2;        //按键状态寄存器2
wire     tx_flag;         //发送标志位，高电平表示正在发送串口数据
always @(posedge clk or negedge rst_n)
      if(!rst_n)
  begin
  ena_reg1<=1'b1;
  ena_reg2<=1'b1;
  cnt_delay<=10'd0;
  end
  else if(ena_reg1&!ena_reg2)          //检测按键按下后弹起，即ena的上升沿（因为无动作时连接按键的pin处于高电平）
  case (cnt_delay)
  10'd1011:begin
         cnt_delay<=10'd0;            //延时去抖结束，计数器清零
     ena_reg1<=1'b1;              //按键状态寄存器置1，等待下次ena上升沿的到来
         ena_reg2<=1'b1;
     end
  default:cnt_delay<=cnt_delay+10'd1;  //检测到上升沿，延时去抖计数器启动
  endcase
  else
  begin
  ena_reg1<=ena;                       //ena_reg1寄存ena当前周期的状态
  ena_reg2<=ena_reg1;                  //ena_reg2寄存ena前一周期的状态
  end
assign  tx_flag=((cnt_delay>=10'd1000)&&   //延时去抖结束后给出发送忙标志，持续10
                 (cnt_delay<=10'd1010));   //个周期，以等待FPGA向串口发送完毕
always @(posedge clk or negedge rst_n)
      if(!rst_n)
    cnt<=4'd0;                        //串口发送计数器复位
  else if(!tx_flag)
    cnt<=4'd0;                        //若没有检测到串口发送标志位，则计数器等待
      else
    cnt<=(cnt>=4'd10)?4'd11:cnt+4'd1; //检测到串口发送标志位，启动计数器
always @(posedge clk or negedge rst_n)
      if(!rst_n)
     txd<=1'bz;              //发送端复位，高阻态
  else
       case (cnt)
   4'd0:txd<=1'bz;
   4'd1:txd<=1'b0;         //发送起始位
   4'd2:txd<=data[0];      //发送第一位
   4'd3:txd<=data[1];      //发送第二位
   4'd4:txd<=data[2];      //发送第三位
   4'd5:txd<=data[3];      //发送第四位
   4'd6:txd<=data[4];      //发送第五位
   4'd7:txd<=data[5];      //发送第六位
   4'd8:txd<=data[6];      //发送第七位
   4'd9:txd<=data[7];      //发送第八位
   4'd10:txd<=1'b1;        //发送停止位
   default:txd<=1'bz;
  endcase
endmodule

//此模块为波特率生成模块，修改BAUDRATE的值可改变波特率
//串口波特率时钟的高电平仅仅持续一个clk周期
module   clk_baud_gen(clk,rst_n,clk_baud);
input  clk;       //波特率基准时钟，此时钟来自PLL
input  rst_n;     //全局复位
output clk_baud;  //串口波特率时钟
wire   clk_baud;
reg    [10:0] cnt; //波特率时钟计数器

parameter  BAUDRATE=115200;
parameter  baudClkDiv=(12000000/BAUDRATE);

always @(posedge clk or negedge rst_n)
      if(!rst_n)
    cnt<=10'd0;
  else
    cnt<=(cnt==baudClkDiv-10'd2)?10'd0:cnt+1'b1;  //波特率时钟计数器启动
assign   clk_baud=(cnt==baudClkDiv-10'd2);
endmodule
