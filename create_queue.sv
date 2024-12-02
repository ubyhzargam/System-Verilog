// Simple code to create and display a queue in system verilog 

module tb;
  int arr1[$];
  initial
    begin
      for (int i=0;i<5;i++)
        arr1[i]=5*i;
      $display("%p",arr1);
    end
endmodule
