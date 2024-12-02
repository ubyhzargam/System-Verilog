// Simple code to display the size of array 

module tb;
  bit arr[]={1,0,1,1,1};
  initial
    begin
      $display($size(arr));
    end
endmodule
