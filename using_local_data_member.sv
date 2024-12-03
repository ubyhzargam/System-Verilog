// A code to use local data member of a class outside the class

class first;
  local int data;
  task set(input int datain);
    data=datain;
  endtask
  function int get();
    return data;
  endfunction
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
      s.f1.set(45);
      $display(s.f1.get());
    end
endmodule
