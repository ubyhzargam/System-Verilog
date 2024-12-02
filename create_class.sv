// Simple code to create class, create handler for class and allocate memory to handler and access data members of class 

class Uby;
  bit [3:0] data;
  bit data1;
endclass

module m;
  Uby h;
  
  initial 
    begin
      h=new();
      h.data=4'd13;
      h.data1=1'd0;
      #1
      $display("data= %0d, data1=%0d",h.data,h.data1);
    end
endmodule
