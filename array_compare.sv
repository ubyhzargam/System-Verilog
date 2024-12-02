// Simple code to compare to arrays and display 1 if both arrays are equal else display 0

module tb;
  bit arr1[]='{100{1}};
  bit arr2[]='{100{1}};
  int status;
  initial
    begin
      status =(arr1==arr2);
      $display("%d",status);
    end
endmodule
