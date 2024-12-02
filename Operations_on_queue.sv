// Implement basic push, pop, insert and delete operations on queue and display the changes the queue undergoes after each operation 

module tb;
  int arr1[$];
  initial
    begin
      for (int i=0;i<5;i++)
        arr1[i]=5*i;
      $display("%p",arr1);
      arr1.push_front(1);
      $display(arr1);
      arr1.push_back(1);
      $display(arr1);
      arr1.insert(2,1);
      $display(arr1);
      arr1.pop_front();
      $display(arr1);
      arr1.pop_back();
      $display(arr1);
      arr1.delete(1);
      $display(arr1);
    end
endmodule
