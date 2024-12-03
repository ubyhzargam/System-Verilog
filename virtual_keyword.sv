// This is a simple code to demonstrate the usage of the keyword 'virtual' in S.V.

class first;
int data=23;
  virtual function void display();
    $display(data);
  endfunction
endclass

class second extends first;
  int temp=45;
  function void display();
    $display(temp);
  endfunction
endclass

module tb;
first f1;
second s1;
initial
  begin
    f1=new();
    s1=new();
    f1=s1;
    f1.display();
  end
endmodule
