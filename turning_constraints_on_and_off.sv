// A simple code to demonstrate how to turn on and off the constraints 

class generator;
  
randc bit [3:0] a,b;
  
  constraint data{
    a inside {[0:11]}; b inside {[1:5],[8:13]};
  }
  
  constraint ctrl{
    (a==b);
  }
  
  extern function void display();
    
endclass
    
function void generator:: display();
  $display("The values of a = %0d and b=%0d",a,b);
endfunction
    
module tb;
 generator g;
  initial
    begin
      g=new();
      $display("Section 1");
      g.ctrl.constraint_mode(0);
      for(int i=0;i<10;i++) begin
        g.randomize();
        g.display();
      end
      $display("Section 2");
      g.ctrl.constraint_mode(1);
       for(int i=0;i<10;i++) begin
        g.randomize();
        g.display();
      end
      g=null;
    end
endmodule
