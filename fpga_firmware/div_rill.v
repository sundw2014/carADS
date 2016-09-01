module div_rill(a,b,shang,yushu);  
input a,b;
output shang,yushu;
wire[31:0]a,b;
reg[31:0] tempa,tempb,shang,yushu; 
reg[63:0] temp_a;  
reg[63:0] temp_b;    
integer i;  
always @(a or b)  
begin  
     tempa <= a;  
     tempb <= b;  
end  
always @(tempa or tempb)  
begin  
     temp_a = {32'h00000000,tempa};  
     temp_b = {tempb,32'h00000000};   
     for(i = 0;i < 32;i = i + 1)  
     begin  
          temp_a = {temp_a[62:0],1'b0};  
          if(temp_a[63:32] >= tempb)begin temp_a = temp_a - temp_b + 1'b1;end  
          else begin temp_a = temp_a;end  
     end   
     shang <= temp_a[31:0];  
     yushu <= temp_a[63:32];  
end   
endmodule  