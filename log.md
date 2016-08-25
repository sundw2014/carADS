# 电子设计小学期工作日志

## 0x00
### 上午

小学期第一天，困的要死。上午没有完成任何工作。
### 下午
 拿到了mpu6050、超声波、电机驱动（bts7960)以及几个红外光电传感器  
 在网上找了一个I2C读mpu6050的轮子，出人意料地工作正常。仅有的一点点收获是，我们为了验证找到的代码是否正常，就写了下面一段代码：
```
tmpData[15:0] = {ACC_XH_READ,ACC_XL_READ};
if(($signed(tmpData)>16000)) begin
	LED <= 1'b1;
end
else begin
	LED <= 1'b0;
end
```
用到了符号数的相关知识, 下面是verilog中符号数的相关知识(source:http://guqian110.github.io/pages/2014/07/07/fpga_digital_processing_basic_2.html)  
1.操作数的类型判定  
__字面值整型常量__  
字面值整型常量标准格式为`<null|+|-> [size] ' [sign:s|S] [base:d|D|h|H|o|O|b|B] <0~9|0～f|0~7|0~1|x|z>`  
一串 0～9 组成的数字，前面可能有 +/- 符号，默认解释为有符号数  
`<size>'<s><base><value>`默认是无符号数，除非明确使用 s 字段, 另外size表示的是多少个bits。  
__reg和wire__  
这两个东西是什么类型取决于在定义时是否有signed修饰。

可以使用$signed()在表达式中强制转换

当一个表达式中所有操作数__全部__被判定为signed类型时，则不会发生转换，否则全部转换为unsigned类型进行计算。

关于原文中所讲的rtl schematics以及technology schematics参见下面(source:http://www.xilinx.com/support/answers/41500.html)
>Description

>After XST synthesis is completed, I am able to view both RTL and technology schematic.I frequently observe discrepancies between these two schematics.

>What is the difference between them?
Solution

>RTL View

>Viewing an RTL schematic opens an NGR file that can be viewed as a gate-level schematic.

>This schematic is generated after the HDL synthesis phase of the synthesis process. It shows a representation of the pre-optimized design in terms of generic symbols, such as adders, multipliers, counters, AND gates, and OR gates, that are independent of the targeted Xilinx device.

>Technology View

>Viewing a Technology schematic opens an NGC file that can be viewed as an architecture-specific schematic.

>This schematic is generated after the optimization and technology targeting phase of the synthesis process. It shows a representation of the design in terms of logic elements optimized to the target Xilinx device or "technology"; for example, in terms of of LUTs, carry logic, I/O buffers, and other technology-specific components. Viewing this schematic allows you to see a technology-level representation of your HDL optimized for a specific Xilinx architecture, which might help you discover design issues early in the design process.

>You should always refer to technology schematic for synthesized result.

>To disable RTL schematic generation to speed up synthesis, you can set XST property Generate RTL Schematic (-rtlview) to "No".

## 0x01
### 上午

画PCB的原理图， 主要是两路电机驱动（四个btn7970)、LDO(LM1084)、以及几排用来接舵机的排针。电机驱动的信号输入用74HC244D作了缓冲，以增加驱动能力以及电气隔离。

### 下午

画PCB，电路比较简单，比较开心。此次布线参照之前经验，对大电流的地回路以及电源回路直接多边形铺铜。但是有一件事想不明白，btn7970的输出端与接插件之间的连接如果进行多边形铺铜就会导致焊盘与铺铜relief connection，讲道理这样是科学的，便于焊接。但是看起来不爽，直接使用solder铺铜，direct connection，板子做好了可以实际焊接测试一下影响有多大。如果想让大焊盘direct，小焊盘relief，应该可以通过rules匹配语句实现，可以学习一下。

## 0x02
### 上午
今天开始正式写verilog了，写了一个PWM模块，并实例化出电机驱动和舵机驱动。
问题：同步赋值和异步赋值出现在同一个always中，异步对性能的影响,比较一下两种赋值的rtl schematics？
结果：

问题：分频时的问题，代码如下
```
always @ ( posedge clk_in or negedge rst_n ) begin
  if(!rst_n) begin
    clk_cnt <= 0;
	 clk_out <= 0;
  end
  else begin
 	 clk_cnt <= clk_cnt + 1;

    if(clk_cnt < (N/2)) begin
      clk_out <= 1'b1;
    end
    else begin
      clk_out <= 1'b0;
    end

    if(clk_cnt > N-2 ) begin
      clk_cnt <= 0;
    end
	end
end
```
为何需要减2
结果:
### 下午
加入了一个RS232模块，实现了串口接收数据。

## 0x03
###上午
调试舵机和电机
###下午

## 0x04
###上午
添加蓝牙控制功能  
整个上午都在写蓝牙控制的app，对接了原有app的stickView和蓝牙功能，中间找到stickView的一个bug。。。除此之外别无收获  
###下午
遇到玩车模的大神，被吐槽。大神帮我把小车重新弄了一遍，过程很有意思，详述：  
小车使用的差速器类型是珠差（滚珠差速器，多年之前还属于高端货），小车差速器在组装的时候轴套与轴由于精度问题有些打滑，遂与大神一起去南门买了一罐厌氧胶一罐金属粘接剂把轴套固定，同时把一众橡胶垫圈、O环固定，改装之后效果良好。  
小车属于 ，依靠T形板提供后悬挂恢复力，但是小车的T形板竟然与车体只有一个螺丝。。。于是打了两个孔，放了两个机米螺丝限位。  
然后大神又帮我调了四轮定位、底盘高，齿轮齿隙。   
唯一遗憾是没有硅油，不能给T形板加阻尼。  
然后就放上电调连上接收机跑了一圈，拔群！！！弄完才想起来这些跟小学期没一毛钱关系。
###晚上
送走大神之后就开始调FPGA的串口，最后发现网上找的232模块误码率太高，换了一个瞬间好了。可以实现蓝牙控制了但是没有电机驱动，等PCB到了再试。
