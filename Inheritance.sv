// Simple code to demonstrate the use of inheritance between classes 

class first;
int data =32;
endclass

class second extends first;
  int temp=23;
endclass

module tb;
second s;
  initial
    begin
      s=new();
      $display(s.data," ",s.temp);
    end
endmodule
