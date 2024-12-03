// Create a simple user defined constructor to initiialize value to a data member of a class

class Uby;
  int data;
  function new(input int datain);
    data=datain;
  endfunction
endclass

module tb;
  Uby H;
  initial
    begin
      H=new(45);
      $display(H.data);
    end 
endmodule
