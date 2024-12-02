// Simple code to create a dynamic array of size 5 and display it 

module tb;
  int arr1[];
  initial
    begin
      arr1=new[5];
      for (int i=0;i<5;i++)
        arr1[i]=5*i;
      $display("%p",arr1);
    end
endmodule
