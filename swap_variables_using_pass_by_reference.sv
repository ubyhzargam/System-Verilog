// Simple code to create a task to swap values 

module tb;
  task automatic swap(ref int x,y);
    int temp;
    temp=x;
    x=y;
    y=temp;
  endtask
  
  int x,y;
  
  initial
    begin
      x=2;y=4;
      $display("The value of x=%d and y=%d ",x,y);
      swap(x,y);
      $strobe("The value of x=%d and y=%d ",x,y);
    end
  endmodule
