// Simple code to demonstrate shallow copy of handler from one object to another 
class first;
  int data=23;
endclass

class second;
  first f1;
  function new();
    f1=new();
  endfunction
endclass

module m;
  second s1;
  second s2;
  initial
    begin
      s1=new();
      s2=new s1;
      s2.f1.data=25;
      $display(s1.f1.data);
    end
endmodule
