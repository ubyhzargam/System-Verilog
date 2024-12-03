// Write a code to demonstrate the copying of object of a class 

class first;
  int data;
endclass


module m;
  first f1;
  first f2;
  initial
    begin
      f1=new();
      f1.data=45;
      $display(f1.data);
      f2=new f1;
      $display(f2.data);
      f1.data=18;
      $display(f2.data);
    end
endmodule
