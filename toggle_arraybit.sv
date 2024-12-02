// Simple code to toggle every bit of given array and display it 

module tb;
  bit arr[]={1,0,1,1,1};
  initial
    begin
      for(int i=0;i<$size(arr);i++)
        arr[i]=~arr[i];
      $display("The updated array is given by : ");
      for(int i=0;i<$size(arr);i++)
        $display(arr[i]);
    end
endmodule
