// This is a code to demonstrate the working of randomize() and rand keyword 

class generator;
  rand bit [3:0] a,b;
  bit [3:0] y;
endclass

module tb;
  generator g;
  initial
    begin
      g=new();
      for(int i=0;i<10;i++)
        begin
          g.randomize();
          $display(" a = %d, b = %d ",g.a,g.b);
          #10;
        end
    end
endmodule
