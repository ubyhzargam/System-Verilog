// Write a code to use a class from another class

class first;
  int data;
  task display();
    $display(data);
  endtask
endclass

class second;
  first f1;
  function new();
    f1=new();
  endfunction
endclass

module m;
  second s;
  initial
    begin
      s=new();
      s.f1.data=45;
      s.f1.display();
    end
endmodule
