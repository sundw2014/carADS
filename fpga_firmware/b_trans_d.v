module b_trans_d(distance,clk,led_total);
input distance,clk;
output led_total;
wire[13:0]distance;
reg[27:0]led_total;
wire[13:0]thousand,million,decade,unit;
wire[13:0]tempa,tempb;
assign    thousand=distance/14'd1000;
assign	 tempa=distance%14'd1000;
assign	 million=tempa/14'd100;
assign	 tempb=tempa%14'd100;
assign	 decade=tempb/14'd10;
assign	 unit=tempb%14'd10;
always @(posedge clk)
begin
     led_total={thousand[6:0],million[6:0],decade[6:0],unit[6:0]};
end
endmodule

